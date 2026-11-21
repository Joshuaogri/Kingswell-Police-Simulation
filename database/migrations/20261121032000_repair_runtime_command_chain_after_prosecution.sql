-- Restore command handlers bypassed by the prosecution runtime wrapper.
-- Keep the existing command chain intact and intercept the four affected command families.

ALTER FUNCTION game.interpret_text_command(text) RENAME TO interpret_text_command_before_runtime_chain_repair;
ALTER FUNCTION game.execute_text_command(text,text,uuid,uuid) RENAME TO execute_text_command_before_runtime_chain_repair;

CREATE OR REPLACE FUNCTION game.interpret_text_command(p_command_text text)
RETURNS jsonb
LANGUAGE plpgsql IMMUTABLE
SET search_path TO 'pg_catalog','game'
AS $$
DECLARE
  v_result jsonb;
  v_text text := btrim(coalesce(p_command_text,''));
  v_match text[];
BEGIN
  v_result := game.interpret_arrest_custody_command(p_command_text);
  IF v_result IS NOT NULL THEN RETURN v_result; END IF;

  v_result := game.interpret_prosecution_command(p_command_text);
  IF v_result IS NOT NULL THEN RETURN v_result; END IF;

  v_result := game.interpret_correctional_command(p_command_text);
  IF v_result IS NOT NULL THEN RETURN v_result; END IF;

  v_match := regexp_match(v_text,'^patrol[[:space:]]+intelligence[[:space:]]+links(?:[[:space:]]+for[[:space:]]+([^[:space:]]+))?$','i');
  IF v_match IS NOT NULL THEN
    RETURN jsonb_build_object(
      'recognized',true,
      'command_type','patrol_intelligence_links',
      'payload',jsonb_build_object('reference',nullif(btrim(v_match[1]),''))
    );
  END IF;

  RETURN game.interpret_text_command_before_runtime_chain_repair(p_command_text);
END;
$$;

CREATE OR REPLACE FUNCTION game.execute_text_command(
  p_command_text text,
  p_idempotency_key text,
  p_session_id uuid DEFAULT NULL,
  p_actor_personnel_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SET search_path TO 'pg_catalog','game'
AS $$
DECLARE
  v_interpreted jsonb;
  v_type text;
  v_payload jsonb;
  v_command game.game_commands%rowtype;
  v_actor game.police_personnel%rowtype;
  v_result jsonb;
BEGIN
  v_interpreted := game.interpret_text_command(p_command_text);
  v_type := v_interpreted->>'command_type';
  v_payload := coalesce(v_interpreted->'payload','{}'::jsonb);

  IF v_type='help' THEN
    v_result := game.execute_text_command_before_runtime_chain_repair(
      p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id
    );
    RETURN jsonb_set(
      v_result,
      '{available_commands}',
      (
        SELECT coalesce(jsonb_agg(DISTINCT x),'[]'::jsonb)
        FROM jsonb_array_elements_text(
          coalesce(v_result->'available_commands','[]'::jsonb)
          || jsonb_build_array(
            'execute_arrest','transport_arrest','book_custody','record_custody_property',
            'custody_check','custody_event','release_custody','transfer_custody','get_case_arrests',
            'submit_prosecution_referral','decide_prosecution_referral','get_prosecution_referrals',
            'correctional_create_facility','correctional_admit','correctional_add_sentence',
            'correctional_place_prisoner','correctional_get_record','correctional_list_facilities',
            'correctional_staff_appoint','correctional_staff_list','patrol_intelligence_links'
          )
        ) x
      ),
      true
    );
  END IF;

  IF v_type IS NULL OR v_type NOT IN (
    'execute_arrest','transport_arrest','book_custody','record_custody_property',
    'custody_check','custody_event','release_custody','transfer_custody','get_case_arrests',
    'submit_prosecution_referral','decide_prosecution_referral','get_prosecution_referrals',
    'correctional_create_facility','correctional_admit','correctional_add_sentence',
    'correctional_place_prisoner','correctional_get_record','correctional_list_facilities',
    'correctional_staff_appoint','correctional_staff_list','patrol_intelligence_links'
  ) THEN
    RETURN game.execute_text_command_before_runtime_chain_repair(
      p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id
    );
  END IF;

  IF p_command_text IS NULL OR char_length(btrim(p_command_text)) NOT BETWEEN 1 AND 4000 THEN
    RAISE EXCEPTION 'Command text must contain between 1 and 4000 characters';
  END IF;
  IF p_idempotency_key IS NULL OR char_length(p_idempotency_key) NOT BETWEEN 8 AND 200 THEN
    RAISE EXCEPTION 'A unique idempotency key between 8 and 200 characters is required';
  END IF;

  INSERT INTO game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload)
  VALUES(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload)
  ON CONFLICT(idempotency_key) DO NOTHING;

  IF NOT FOUND THEN
    SELECT * INTO v_command FROM game.game_commands
    WHERE idempotency_key=p_idempotency_key FOR UPDATE;
    IF v_command.command_text<>p_command_text
       OR v_command.command_type<>v_type
       OR v_command.payload<>v_payload THEN
      RETURN jsonb_build_object(
        'ok',false,'code','idempotency_conflict',
        'message','This command key was already used for a different command.',
        'command_id',v_command.id
      );
    END IF;
    RETURN coalesce(
      v_command.result,
      jsonb_build_object('ok',v_command.status='completed','status',v_command.status,'command_id',v_command.id)
    ) || jsonb_build_object('duplicate',true);
  END IF;

  SELECT * INTO v_command FROM game.game_commands
  WHERE idempotency_key=p_idempotency_key FOR UPDATE;

  IF v_type='patrol_intelligence_links' THEN
    IF p_actor_personnel_id IS NOT NULL THEN
      SELECT * INTO v_actor FROM game.police_personnel
      WHERE id=p_actor_personnel_id AND employment_status IN ('active','seconded');
    END IF;
    IF v_actor.id IS NULL THEN
      v_result:=jsonb_build_object('ok',false,'code','actor_mismatch','message','An active officer is required for this lookup.');
    ELSE
      v_result:=game.get_patrol_intelligence_links(v_payload->>'reference',100);
    END IF;
  ELSE
    SELECT * INTO v_actor FROM game.police_personnel
    WHERE personnel_ref=btrim(v_payload->>'actor_ref')
      AND employment_status IN ('active','seconded');

    IF v_actor.id IS NULL OR (p_actor_personnel_id IS NOT NULL AND p_actor_personnel_id<>v_actor.id) THEN
      v_result:=jsonb_build_object('ok',false,'code','actor_mismatch','message','The named command actor must match active or seconded personnel.');
    ELSIF v_type IN (
      'execute_arrest','transport_arrest','book_custody','record_custody_property',
      'custody_check','custody_event','release_custody','transfer_custody','get_case_arrests'
    ) THEN
      v_result:=game.execute_arrest_custody_command(v_command.id,v_type,v_payload,v_actor.id);
    ELSIF v_type IN (
      'submit_prosecution_referral','decide_prosecution_referral','get_prosecution_referrals'
    ) THEN
      v_result:=game.execute_prosecution_command(v_command.id,v_type,v_payload,v_actor.id);
    ELSE
      v_result:=game.execute_correctional_command(v_command.id,v_type,v_payload,v_actor.id);
    END IF;
  END IF;

  IF coalesce((v_result->>'ok')::boolean,false) THEN
    v_result:=v_result||jsonb_build_object('status','completed','command_id',v_command.id);
    UPDATE game.game_commands
    SET status='completed',result=v_result,completed_at=now()
    WHERE id=v_command.id;
  ELSE
    UPDATE game.game_commands
    SET status='rejected',
        rejection_reason=coalesce(v_result->>'message','Runtime command rejected.'),
        result=v_result,completed_at=now()
    WHERE id=v_command.id;
    v_result:=v_result||jsonb_build_object('command_id',v_command.id);
  END IF;

  RETURN v_result;
END;
$$;
