-- BP-04: source-backed property planning and development event history.
-- Reuses the existing global text-command runtime, command audit/idempotency,
-- property dossier and actor validation. No historic events are seeded or inferred.

CREATE TABLE game.property_development_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_ref text NOT NULL UNIQUE,
  property_id uuid NOT NULL REFERENCES game.properties(id) ON DELETE RESTRICT,
  building_id uuid REFERENCES game.buildings(id) ON DELETE RESTRICT,
  building_unit_id uuid REFERENCES game.building_units(id) ON DELETE RESTRICT,
  event_type text NOT NULL CHECK (event_type IN (
    'planning_application','planning_decision','planning_condition','condition_discharge',
    'building_permit','construction_commenced','construction_progress','construction_completed',
    'completion_certificate','occupancy_authorisation','change_of_use_application',
    'change_of_use_decision','demolition_application','demolition_completed','inspection',
    'enforcement_notice','stop_work_notice','appeal','appeal_outcome','heritage_consent',
    'environmental_consent','other'
  )),
  event_status text NOT NULL CHECK (event_status IN (
    'unknown','proposed','submitted','under_review','approved','refused','granted',
    'conditional','withdrawn','commenced','in_progress','completed','discharged',
    'served','complied','breached','appealed','upheld','quashed','closed'
  )),
  occurred_on date,
  recorded_on date,
  planning_reference text,
  subject text NOT NULL CHECK (char_length(subject) BETWEEN 1 AND 200),
  description text NOT NULL CHECK (char_length(description) BETWEEN 1 AND 4000),
  source_reference text NOT NULL CHECK (char_length(source_reference) BETWEEN 1 AND 200),
  source_description text NOT NULL CHECK (char_length(source_description) BETWEEN 1 AND 1000),
  recorded_by_personnel_id uuid NOT NULL REFERENCES game.police_personnel(id) ON DELETE RESTRICT,
  command_id uuid NOT NULL REFERENCES game.game_commands(id) ON DELETE RESTRICT,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (building_unit_id IS NULL OR building_id IS NOT NULL)
);

CREATE INDEX property_development_events_property_date_idx
  ON game.property_development_events(property_id, occurred_on, recorded_on, created_at);
CREATE INDEX property_development_events_planning_reference_idx
  ON game.property_development_events(planning_reference)
  WHERE planning_reference IS NOT NULL;

CREATE OR REPLACE FUNCTION game.validate_property_development_event()
RETURNS trigger
LANGUAGE plpgsql
SET search_path TO 'pg_catalog','game'
AS $function$
BEGIN
  IF TG_OP <> 'INSERT' THEN
    RAISE EXCEPTION 'Property development events are append-only; record a correction or subsequent event instead';
  END IF;
  RETURN NEW;
END;
$function$;

CREATE TRIGGER property_development_events_immutable
BEFORE UPDATE OR DELETE ON game.property_development_events
FOR EACH ROW EXECUTE FUNCTION game.validate_property_development_event();

ALTER TABLE game.property_development_events ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON game.property_development_events FROM PUBLIC, anon, authenticated;
GRANT ALL ON game.property_development_events TO service_role;

CREATE OR REPLACE FUNCTION game.get_property_development_history(p_property_ref text)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path TO 'pg_catalog','game'
AS $function$
  SELECT jsonb_build_object(
    'property', jsonb_build_object(
      'id',p.id,'property_ref',p.property_ref,'address',p.address_line,
      'property_type',p.property_type,'land_use',p.land_use
    ),
    'development_events',coalesce((
      SELECT jsonb_agg(jsonb_build_object(
        'event',to_jsonb(e),
        'building_ref',b.building_ref,
        'unit_ref',u.unit_ref
      ) ORDER BY e.occurred_on DESC NULLS LAST,e.recorded_on DESC NULLS LAST,e.created_at DESC)
      FROM game.property_development_events e
      LEFT JOIN game.buildings b ON b.id=e.building_id
      LEFT JOIN game.building_units u ON u.id=e.building_unit_id
      WHERE e.property_id=p.id
    ),'[]'::jsonb),
    'event_count',(
      SELECT count(*) FROM game.property_development_events e WHERE e.property_id=p.id
    ),
    'record_coverage',jsonb_build_object(
      'planning_and_development_history','source_backed_recorded_events_only',
      'unknown_dates_are_null',true,
      'empty_history_does_not_prove_no_historical_event',true,
      'current_property_or_planning_status_is_not_mutated',true
    )
  )
  FROM game.properties p
  WHERE p.property_ref=p_property_ref;
$function$;

-- Extend the canonical property dossier without replacing its established sections.
ALTER FUNCTION game.get_property_record(text)
  RENAME TO get_property_record_before_development_history;

CREATE OR REPLACE FUNCTION game.get_property_record(p_property_ref text)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path TO 'pg_catalog','game'
AS $function$
  SELECT base.record || jsonb_build_object(
    'planning_and_development_history',
    coalesce(history->'development_events','[]'::jsonb),
    'planning_and_development_coverage',
    coalesce(history->'record_coverage','{}'::jsonb)
  )
  FROM (SELECT game.get_property_record_before_development_history(p_property_ref) AS record) base
  LEFT JOIN LATERAL (
    SELECT game.get_property_development_history(p_property_ref) AS history
  ) h ON true
  WHERE base.record IS NOT NULL;
$function$;

-- Add a narrow interceptor; all existing commands continue through the established runtime.
ALTER FUNCTION game.interpret_text_command(text)
  RENAME TO interpret_text_command_before_property_development;

CREATE OR REPLACE FUNCTION game.interpret_text_command(p_command_text text)
RETURNS jsonb
LANGUAGE plpgsql
IMMUTABLE
SET search_path TO 'pg_catalog','game'
AS $function$
DECLARE
  v_text text := btrim(coalesce(p_command_text,''));
  v_match text[];
BEGIN
  v_match := regexp_match(v_text,
    '^property development event ([^[:space:]]+) ([^[:space:]]+) (planning_application|planning_decision|planning_condition|condition_discharge|building_permit|construction_commenced|construction_progress|construction_completed|completion_certificate|occupancy_authorisation|change_of_use_application|change_of_use_decision|demolition_application|demolition_completed|inspection|enforcement_notice|stop_work_notice|appeal|appeal_outcome|heritage_consent|environmental_consent|other) (unknown|proposed|submitted|under_review|approved|refused|granted|conditional|withdrawn|commenced|in_progress|completed|discharged|served|complied|breached|appealed|upheld|quashed|closed) (unknown|[0-9]{4}-[0-9]{2}-[0-9]{2}) (unknown|[0-9]{4}-[0-9]{2}-[0-9]{2}) (unknown|[^[:space:]]+) (unknown|[^[:space:]]+) "([^"]*)" "([^"]+)" "([^"]+)" "([^"]+)" "([^"]+)" by ([^[:space:]]+)$','i');
  IF v_match IS NOT NULL THEN
    RETURN jsonb_build_object(
      'recognized',true,'command_type','property_development_event_record',
      'payload',jsonb_build_object(
        'property_ref',v_match[1],'event_ref',v_match[2],
        'event_type',lower(v_match[3]),'event_status',lower(v_match[4]),
        'occurred_on',CASE WHEN lower(v_match[5])='unknown' THEN NULL ELSE v_match[5] END,
        'recorded_on',CASE WHEN lower(v_match[6])='unknown' THEN NULL ELSE v_match[6] END,
        'building_ref',CASE WHEN lower(v_match[7])='unknown' THEN NULL ELSE v_match[7] END,
        'unit_ref',CASE WHEN lower(v_match[8])='unknown' THEN NULL ELSE v_match[8] END,
        'planning_reference',nullif(v_match[9],''),
        'subject',v_match[10],'description',v_match[11],
        'source_reference',v_match[12],'source_description',v_match[13],
        'actor_ref',v_match[14]
      )
    );
  END IF;

  v_match := regexp_match(v_text,
    '^property development history ([^[:space:]]+) by ([^[:space:]]+)$','i');
  IF v_match IS NOT NULL THEN
    RETURN jsonb_build_object(
      'recognized',true,'command_type','property_development_history_get',
      'payload',jsonb_build_object('property_ref',v_match[1],'actor_ref',v_match[2])
    );
  END IF;

  RETURN game.interpret_text_command_before_property_development(p_command_text);
END;
$function$;

ALTER FUNCTION game.execute_text_command(text,text,uuid,uuid)
  RENAME TO execute_text_command_before_property_development;

CREATE OR REPLACE FUNCTION game.execute_text_command(
  p_command_text text,
  p_idempotency_key text,
  p_session_id uuid DEFAULT NULL,
  p_actor_personnel_id uuid DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SET search_path TO 'pg_catalog','game'
AS $function$
DECLARE
  v_interpreted jsonb;
  v_type text;
  v_payload jsonb;
  v_command game.game_commands%rowtype;
  v_actor game.police_personnel%rowtype;
  v_property game.properties%rowtype;
  v_building game.buildings%rowtype;
  v_unit game.building_units%rowtype;
  v_existing game.property_development_events%rowtype;
  v_event game.property_development_events%rowtype;
  v_result jsonb;
BEGIN
  v_interpreted := game.interpret_text_command(p_command_text);
  v_type := v_interpreted->>'command_type';
  v_payload := coalesce(v_interpreted->'payload','{}'::jsonb);

  IF v_type IS NULL OR v_type NOT IN (
    'property_development_event_record','property_development_history_get'
  ) THEN
    RETURN game.execute_text_command_before_property_development(
      p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id
    );
  END IF;

  IF p_command_text IS NULL OR char_length(btrim(p_command_text)) NOT BETWEEN 1 AND 4000 THEN
    RAISE EXCEPTION 'Command text must contain between 1 and 4000 characters';
  END IF;
  IF p_idempotency_key IS NULL OR char_length(p_idempotency_key) NOT BETWEEN 8 AND 200 THEN
    RAISE EXCEPTION 'A unique idempotency key between 8 and 200 characters is required';
  END IF;

  INSERT INTO game.game_commands(
    idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload
  ) VALUES (
    p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload
  ) ON CONFLICT(idempotency_key) DO NOTHING;

  IF NOT FOUND THEN
    SELECT * INTO v_command FROM game.game_commands
    WHERE idempotency_key=p_idempotency_key FOR UPDATE;
    IF v_command.command_text<>p_command_text
       OR v_command.command_type<>v_type
       OR v_command.payload<>v_payload THEN
      RETURN jsonb_build_object('ok',false,'code','idempotency_conflict','command_id',v_command.id);
    END IF;
    RETURN coalesce(v_command.result,
      jsonb_build_object('ok',v_command.status='completed','status',v_command.status,'command_id',v_command.id))
      ||jsonb_build_object('duplicate',true);
  END IF;

  SELECT * INTO v_command FROM game.game_commands
  WHERE idempotency_key=p_idempotency_key FOR UPDATE;

  SELECT * INTO v_actor FROM game.police_personnel
  WHERE personnel_ref=v_payload->>'actor_ref'
    AND employment_status IN ('active','seconded');

  IF v_actor.id IS NULL OR (p_actor_personnel_id IS NOT NULL AND p_actor_personnel_id<>v_actor.id) THEN
    v_result := jsonb_build_object('ok',false,'code','actor_mismatch');
  ELSIF v_type='property_development_history_get' THEN
    v_result := game.get_property_development_history(v_payload->>'property_ref');
    IF v_result IS NULL THEN
      v_result := jsonb_build_object('ok',false,'code','property_not_found',
        'property_ref',v_payload->>'property_ref');
    ELSE
      v_result := jsonb_build_object('ok',true,'record_type','property_development_history','record',v_result);
    END IF;
  ELSE
    SELECT * INTO v_property FROM game.properties
    WHERE property_ref=v_payload->>'property_ref';

    IF v_property.id IS NULL THEN
      v_result := jsonb_build_object('ok',false,'code','property_not_found');
    ELSE
      IF nullif(v_payload->>'building_ref','') IS NOT NULL THEN
        SELECT * INTO v_building FROM game.buildings
        WHERE building_ref=v_payload->>'building_ref'
          AND property_id=v_property.id;
      END IF;
      IF nullif(v_payload->>'unit_ref','') IS NOT NULL THEN
        SELECT * INTO v_unit FROM game.building_units
        WHERE unit_ref=v_payload->>'unit_ref';
      END IF;

      IF nullif(v_payload->>'building_ref','') IS NOT NULL AND v_building.id IS NULL THEN
        v_result := jsonb_build_object('ok',false,'code','building_not_found_for_property');
      ELSIF nullif(v_payload->>'unit_ref','') IS NOT NULL
        AND (v_unit.id IS NULL OR v_building.id IS NULL OR v_unit.building_id<>v_building.id) THEN
        v_result := jsonb_build_object('ok',false,'code','unit_not_found_for_building');
      ELSE
        SELECT * INTO v_existing FROM game.property_development_events
        WHERE event_ref=v_payload->>'event_ref';

        IF v_existing.id IS NOT NULL THEN
          IF v_existing.property_id=v_property.id
             AND v_existing.building_id IS NOT DISTINCT FROM v_building.id
             AND v_existing.building_unit_id IS NOT DISTINCT FROM v_unit.id
             AND v_existing.event_type=v_payload->>'event_type'
             AND v_existing.event_status=v_payload->>'event_status'
             AND v_existing.occurred_on IS NOT DISTINCT FROM nullif(v_payload->>'occurred_on','')::date
             AND v_existing.recorded_on IS NOT DISTINCT FROM nullif(v_payload->>'recorded_on','')::date
             AND v_existing.planning_reference IS NOT DISTINCT FROM nullif(v_payload->>'planning_reference','')
             AND v_existing.subject=v_payload->>'subject'
             AND v_existing.description=v_payload->>'description'
             AND v_existing.source_reference=v_payload->>'source_reference'
             AND v_existing.source_description=v_payload->>'source_description' THEN
            v_result := jsonb_build_object('ok',true,'record_type','property_development_event',
              'duplicate',true,'event',to_jsonb(v_existing));
          ELSE
            v_result := jsonb_build_object('ok',false,'code','development_event_ref_conflict');
          END IF;
        ELSE
          INSERT INTO game.property_development_events(
            event_ref,property_id,building_id,building_unit_id,event_type,event_status,
            occurred_on,recorded_on,planning_reference,subject,description,
            source_reference,source_description,recorded_by_personnel_id,command_id
          ) VALUES (
            v_payload->>'event_ref',v_property.id,v_building.id,v_unit.id,
            v_payload->>'event_type',v_payload->>'event_status',
            nullif(v_payload->>'occurred_on','')::date,
            nullif(v_payload->>'recorded_on','')::date,
            nullif(v_payload->>'planning_reference',''),
            v_payload->>'subject',v_payload->>'description',
            v_payload->>'source_reference',v_payload->>'source_description',
            v_actor.id,v_command.id
          ) RETURNING * INTO v_event;

          v_result := jsonb_build_object('ok',true,'record_type','property_development_event',
            'event',to_jsonb(v_event));
        END IF;
      END IF;
    END IF;
  END IF;

  IF coalesce((v_result->>'ok')::boolean,false) THEN
    v_result := v_result || jsonb_build_object('status','completed','command_id',v_command.id);
    UPDATE game.game_commands SET status='completed',result=v_result,completed_at=now()
    WHERE id=v_command.id;
  ELSE
    UPDATE game.game_commands SET status='rejected',
      rejection_reason=coalesce(v_result->>'message',v_result->>'code','Property development command rejected'),
      result=v_result,completed_at=now()
    WHERE id=v_command.id;
    v_result := v_result || jsonb_build_object('command_id',v_command.id);
  END IF;

  RETURN v_result;
END;
$function$;

REVOKE ALL ON FUNCTION game.get_property_development_history(text),
  game.get_property_record(text),game.interpret_text_command(text),
  game.execute_text_command(text,text,uuid,uuid)
FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION game.get_property_development_history(text),
  game.get_property_record(text),game.interpret_text_command(text),
  game.execute_text_command(text,text,uuid,uuid)
TO service_role;
