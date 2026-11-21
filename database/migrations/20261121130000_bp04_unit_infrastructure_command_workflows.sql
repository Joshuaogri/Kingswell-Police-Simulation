-- BP-04: source-backed building-unit infrastructure capture and retrieval.
-- Reuses the existing profile table and game command audit/idempotency records.
-- No infrastructure facts are seeded or inferred.

-- Preserve the established runtime functions and add a narrow command interceptor.
ALTER FUNCTION game.interpret_text_command(text)
  RENAME TO interpret_text_command_before_unit_infrastructure;
ALTER FUNCTION game.execute_text_command(text,text,uuid,uuid)
  RENAME TO execute_text_command_before_unit_infrastructure;

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
  v_match:=regexp_match(v_text,
    $regex$^unit infrastructure ([^[:space:]]+) (unknown|connected|disconnected|shared|independent|not_applicable) (unknown|connected|disconnected|shared|independent|not_applicable) (unknown|connected|disconnected|shared|independent|not_applicable) (unknown|connected|disconnected|shared|independent|not_applicable) (unknown|connected|disconnected|shared|independent|not_applicable) (unknown|central|unit_level|none|not_applicable) (unknown|present|absent|shared|not_applicable) (unknown|present|absent|shared|not_applicable) (unknown|controlled|mechanical_key|open_access|shared|not_applicable) "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" "([^"]*)" by ([^[:space:]]+)\Z$regex$,'i');
  IF v_match IS NOT NULL THEN
    RETURN jsonb_build_object(
      'recognized',true,
      'command_type','unit_infrastructure_record',
      'payload',jsonb_build_object(
        'unit_ref',v_match[1],
        'electrical_supply_status',lower(v_match[2]),
        'water_supply_status',lower(v_match[3]),
        'wastewater_status',lower(v_match[4]),
        'gas_supply_status',lower(v_match[5]),
        'telecoms_status',lower(v_match[6]),
        'heating_cooling_status',lower(v_match[7]),
        'fire_detection_status',lower(v_match[8]),
        'fire_suppression_status',lower(v_match[9]),
        'access_control_status',lower(v_match[10]),
        'meter_register_notes',v_match[11],
        'utility_details_notes',v_match[12],
        'access_details_notes',v_match[13],
        'fire_safety_details_notes',v_match[14],
        'source_reference',nullif(v_match[15],''),
        'source_description',nullif(v_match[16],''),
        'actor_ref',v_match[17]
      )
    );
  END IF;

  v_match:=regexp_match(v_text,
    '^unit infrastructure record ([^[:space:]]+) by ([^[:space:]]+)$','i');
  IF v_match IS NOT NULL THEN
    RETURN jsonb_build_object(
      'recognized',true,
      'command_type','unit_infrastructure_get_record',
      'payload',jsonb_build_object('unit_ref',v_match[1],'actor_ref',v_match[2])
    );
  END IF;

  RETURN game.interpret_text_command_before_unit_infrastructure(p_command_text);
END;
$function$;

CREATE OR REPLACE FUNCTION game.get_unit_infrastructure_record(p_unit_ref text)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path TO 'pg_catalog','game'
AS $function$
  SELECT jsonb_build_object(
    'unit',to_jsonb(u),
    'building',to_jsonb(b),
    'property',to_jsonb(p),
    'infrastructure',to_jsonb(i),
    'record_coverage',jsonb_build_object(
      'infrastructure','recorded_profile_only',
      'unknown_values_are_not_inferred',true,
      'missing_profile_does_not_prove_absence',true
    )
  )
  FROM game.building_units u
  JOIN game.buildings b ON b.id=u.building_id
  JOIN game.properties p ON p.id=b.property_id
  LEFT JOIN game.building_unit_infrastructure_profiles i ON i.building_unit_id=u.id
  WHERE u.unit_ref=p_unit_ref;
$function$;

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
  v_unit game.building_units%rowtype;
  v_profile game.building_unit_infrastructure_profiles%rowtype;
  v_result jsonb;
BEGIN
  v_interpreted:=game.interpret_text_command(p_command_text);
  v_type:=v_interpreted->>'command_type';
  v_payload:=coalesce(v_interpreted->'payload','{}'::jsonb);

  IF v_type='help' THEN
    v_result:=game.execute_text_command_before_unit_infrastructure(
      p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id
    );
    RETURN jsonb_set(
      v_result,'{available_commands}',
      (SELECT coalesce(jsonb_agg(DISTINCT x),'[]'::jsonb)
       FROM jsonb_array_elements_text(
         coalesce(v_result->'available_commands','[]'::jsonb)
         ||jsonb_build_array('unit_infrastructure_record','unit_infrastructure_get_record')
       ) x),true
    );
  END IF;

  IF v_type IS NULL OR v_type NOT IN ('unit_infrastructure_record','unit_infrastructure_get_record') THEN
    RETURN game.execute_text_command_before_unit_infrastructure(
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
    v_result:=jsonb_build_object('ok',false,'code','actor_mismatch');
  ELSIF v_type='unit_infrastructure_get_record' THEN
    v_result:=game.get_unit_infrastructure_record(v_payload->>'unit_ref');
    IF v_result IS NULL THEN
      v_result:=jsonb_build_object('ok',false,'code','unit_not_found','unit_ref',v_payload->>'unit_ref');
    ELSE
      v_result:=jsonb_build_object('ok',true,'record_type','unit_infrastructure','record',v_result);
    END IF;
  ELSE
    SELECT * INTO v_unit FROM game.building_units
    WHERE unit_ref=v_payload->>'unit_ref';

    IF v_unit.id IS NULL THEN
      v_result:=jsonb_build_object('ok',false,'code','unit_not_found');
    ELSIF v_payload->>'electrical_supply_status' NOT IN ('unknown','connected','disconnected','shared','independent','not_applicable')
       OR v_payload->>'water_supply_status' NOT IN ('unknown','connected','disconnected','shared','independent','not_applicable')
       OR v_payload->>'wastewater_status' NOT IN ('unknown','connected','disconnected','shared','independent','not_applicable')
       OR v_payload->>'gas_supply_status' NOT IN ('unknown','connected','disconnected','shared','independent','not_applicable')
       OR v_payload->>'telecoms_status' NOT IN ('unknown','connected','disconnected','shared','independent','not_applicable')
       OR v_payload->>'heating_cooling_status' NOT IN ('unknown','central','unit_level','none','not_applicable')
       OR v_payload->>'fire_detection_status' NOT IN ('unknown','present','absent','shared','not_applicable')
       OR v_payload->>'fire_suppression_status' NOT IN ('unknown','present','absent','shared','not_applicable')
       OR v_payload->>'access_control_status' NOT IN ('unknown','controlled','mechanical_key','open_access','shared','not_applicable') THEN
      v_result:=jsonb_build_object('ok',false,'code','invalid_infrastructure_status');
    ELSE
      INSERT INTO game.building_unit_infrastructure_profiles(
        building_unit_id,electrical_supply_status,water_supply_status,wastewater_status,
        gas_supply_status,telecoms_status,heating_cooling_status,fire_detection_status,
        fire_suppression_status,access_control_status,meter_register,utility_details,
        access_details,fire_safety_details,source_reference,source_description,provenance,updated_at
      ) VALUES (
        v_unit.id,
        lower(v_payload->>'electrical_supply_status'),
        lower(v_payload->>'water_supply_status'),
        lower(v_payload->>'wastewater_status'),
        lower(v_payload->>'gas_supply_status'),
        lower(v_payload->>'telecoms_status'),
        lower(v_payload->>'heating_cooling_status'),
        lower(v_payload->>'fire_detection_status'),
        lower(v_payload->>'fire_suppression_status'),
        lower(v_payload->>'access_control_status'),
        CASE WHEN nullif(v_payload->>'meter_register_notes','') IS NULL THEN '{}'::jsonb
          ELSE jsonb_build_object('recorded_details',v_payload->>'meter_register_notes') END,
        CASE WHEN nullif(v_payload->>'utility_details_notes','') IS NULL THEN '{}'::jsonb
          ELSE jsonb_build_object('recorded_details',v_payload->>'utility_details_notes') END,
        CASE WHEN nullif(v_payload->>'access_details_notes','') IS NULL THEN '{}'::jsonb
          ELSE jsonb_build_object('recorded_details',v_payload->>'access_details_notes') END,
        CASE WHEN nullif(v_payload->>'fire_safety_details_notes','') IS NULL THEN '{}'::jsonb
          ELSE jsonb_build_object('recorded_details',v_payload->>'fire_safety_details_notes') END,
        nullif(v_payload->>'source_reference',''),
        nullif(v_payload->>'source_description',''),
        jsonb_build_object(
          'recorded_by_personnel_ref',v_actor.personnel_ref,
          'command_id',v_command.id,
          'capture_method','unit_infrastructure_command'
        ),
        now()
      )
      ON CONFLICT(building_unit_id) DO UPDATE SET
        electrical_supply_status=excluded.electrical_supply_status,
        water_supply_status=excluded.water_supply_status,
        wastewater_status=excluded.wastewater_status,
        gas_supply_status=excluded.gas_supply_status,
        telecoms_status=excluded.telecoms_status,
        heating_cooling_status=excluded.heating_cooling_status,
        fire_detection_status=excluded.fire_detection_status,
        fire_suppression_status=excluded.fire_suppression_status,
        access_control_status=excluded.access_control_status,
        meter_register=excluded.meter_register,
        utility_details=excluded.utility_details,
        access_details=excluded.access_details,
        fire_safety_details=excluded.fire_safety_details,
        source_reference=excluded.source_reference,
        source_description=excluded.source_description,
        provenance=excluded.provenance,
        updated_at=now()
      RETURNING * INTO v_profile;

      v_result:=jsonb_build_object(
        'ok',true,'record_type','unit_infrastructure',
        'unit_ref',v_unit.unit_ref,'infrastructure',to_jsonb(v_profile)
      );
    END IF;
  END IF;

  IF coalesce((v_result->>'ok')::boolean,false) THEN
    v_result:=v_result||jsonb_build_object('status','completed','command_id',v_command.id);
    UPDATE game.game_commands SET status='completed',result=v_result,completed_at=now()
    WHERE id=v_command.id;
  ELSE
    UPDATE game.game_commands SET status='rejected',
      rejection_reason=coalesce(v_result->>'message',v_result->>'code','Unit infrastructure command rejected.'),
      result=v_result,completed_at=now()
    WHERE id=v_command.id;
    v_result:=v_result||jsonb_build_object('command_id',v_command.id);
  END IF;

  RETURN v_result;
END;
$function$;

REVOKE ALL ON FUNCTION game.interpret_text_command(text),
  game.execute_text_command(text,text,uuid,uuid),
  game.get_unit_infrastructure_record(text)
FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION game.interpret_text_command(text),
  game.execute_text_command(text,text,uuid,uuid),
  game.get_unit_infrastructure_record(text)
TO service_role;
,'i');
  IF v_match IS NOT NULL THEN
    RETURN jsonb_build_object(
      'recognized',true,
      'command_type','unit_infrastructure_record',
      'payload',jsonb_build_object(
        'unit_ref',v_match[1],
        'electrical_supply_status',lower(v_match[2]),
        'water_supply_status',lower(v_match[3]),
        'wastewater_status',lower(v_match[4]),
        'gas_supply_status',lower(v_match[5]),
        'telecoms_status',lower(v_match[6]),
        'heating_cooling_status',lower(v_match[7]),
        'fire_detection_status',lower(v_match[8]),
        'fire_suppression_status',lower(v_match[9]),
        'access_control_status',lower(v_match[10]),
        'meter_register_notes',v_match[11],
        'utility_details_notes',v_match[12],
        'access_details_notes',v_match[13],
        'fire_safety_details_notes',v_match[14],
        'source_reference',nullif(v_match[15],''),
        'source_description',nullif(v_match[16],''),
        'actor_ref',v_match[17]
      )
    );
  END IF;

  v_match:=regexp_match(v_text,
    '^unit infrastructure record ([^[:space:]]+) by ([^[:space:]]+)$','i');
  IF v_match IS NOT NULL THEN
    RETURN jsonb_build_object(
      'recognized',true,
      'command_type','unit_infrastructure_get_record',
      'payload',jsonb_build_object('unit_ref',v_match[1],'actor_ref',v_match[2])
    );
  END IF;

  RETURN game.interpret_text_command_before_unit_infrastructure(p_command_text);
END;
$function$;

CREATE OR REPLACE FUNCTION game.get_unit_infrastructure_record(p_unit_ref text)
RETURNS jsonb
LANGUAGE sql
STABLE
SECURITY INVOKER
SET search_path TO 'pg_catalog','game'
AS $function$
  SELECT jsonb_build_object(
    'unit',to_jsonb(u),
    'building',to_jsonb(b),
    'property',to_jsonb(p),
    'infrastructure',to_jsonb(i),
    'record_coverage',jsonb_build_object(
      'infrastructure','recorded_profile_only',
      'unknown_values_are_not_inferred',true,
      'missing_profile_does_not_prove_absence',true
    )
  )
  FROM game.building_units u
  JOIN game.buildings b ON b.id=u.building_id
  JOIN game.properties p ON p.id=b.property_id
  LEFT JOIN game.building_unit_infrastructure_profiles i ON i.building_unit_id=u.id
  WHERE u.unit_ref=p_unit_ref;
$function$;

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
  v_unit game.building_units%rowtype;
  v_profile game.building_unit_infrastructure_profiles%rowtype;
  v_result jsonb;
BEGIN
  v_interpreted:=game.interpret_text_command(p_command_text);
  v_type:=v_interpreted->>'command_type';
  v_payload:=coalesce(v_interpreted->'payload','{}'::jsonb);

  IF v_type='help' THEN
    v_result:=game.execute_text_command_before_unit_infrastructure(
      p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id
    );
    RETURN jsonb_set(
      v_result,'{available_commands}',
      (SELECT coalesce(jsonb_agg(DISTINCT x),'[]'::jsonb)
       FROM jsonb_array_elements_text(
         coalesce(v_result->'available_commands','[]'::jsonb)
         ||jsonb_build_array('unit_infrastructure_record','unit_infrastructure_get_record')
       ) x),true
    );
  END IF;

  IF v_type NOT IN ('unit_infrastructure_record','unit_infrastructure_get_record') THEN
    RETURN game.execute_text_command_before_unit_infrastructure(
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
    v_result:=jsonb_build_object('ok',false,'code','actor_mismatch');
  ELSIF v_type='unit_infrastructure_get_record' THEN
    v_result:=game.get_unit_infrastructure_record(v_payload->>'unit_ref');
    IF v_result IS NULL THEN
      v_result:=jsonb_build_object('ok',false,'code','unit_not_found','unit_ref',v_payload->>'unit_ref');
    ELSE
      v_result:=jsonb_build_object('ok',true,'record_type','unit_infrastructure','record',v_result);
    END IF;
  ELSE
    SELECT * INTO v_unit FROM game.building_units
    WHERE unit_ref=v_payload->>'unit_ref';

    IF v_unit.id IS NULL THEN
      v_result:=jsonb_build_object('ok',false,'code','unit_not_found');
    ELSIF v_payload->>'electrical_supply_status' NOT IN ('unknown','connected','disconnected','shared','independent','not_applicable')
       OR v_payload->>'water_supply_status' NOT IN ('unknown','connected','disconnected','shared','independent','not_applicable')
       OR v_payload->>'wastewater_status' NOT IN ('unknown','connected','disconnected','shared','independent','not_applicable')
       OR v_payload->>'gas_supply_status' NOT IN ('unknown','connected','disconnected','shared','independent','not_applicable')
       OR v_payload->>'telecoms_status' NOT IN ('unknown','connected','disconnected','shared','independent','not_applicable')
       OR v_payload->>'heating_cooling_status' NOT IN ('unknown','central','unit_level','none','not_applicable')
       OR v_payload->>'fire_detection_status' NOT IN ('unknown','present','absent','shared','not_applicable')
       OR v_payload->>'fire_suppression_status' NOT IN ('unknown','present','absent','shared','not_applicable')
       OR v_payload->>'access_control_status' NOT IN ('unknown','controlled','mechanical_key','open_access','shared','not_applicable') THEN
      v_result:=jsonb_build_object('ok',false,'code','invalid_infrastructure_status');
    ELSE
      INSERT INTO game.building_unit_infrastructure_profiles(
        building_unit_id,electrical_supply_status,water_supply_status,wastewater_status,
        gas_supply_status,telecoms_status,heating_cooling_status,fire_detection_status,
        fire_suppression_status,access_control_status,meter_register,utility_details,
        access_details,fire_safety_details,source_reference,source_description,provenance,updated_at
      ) VALUES (
        v_unit.id,
        lower(v_payload->>'electrical_supply_status'),
        lower(v_payload->>'water_supply_status'),
        lower(v_payload->>'wastewater_status'),
        lower(v_payload->>'gas_supply_status'),
        lower(v_payload->>'telecoms_status'),
        lower(v_payload->>'heating_cooling_status'),
        lower(v_payload->>'fire_detection_status'),
        lower(v_payload->>'fire_suppression_status'),
        lower(v_payload->>'access_control_status'),
        CASE WHEN nullif(v_payload->>'meter_register_notes','') IS NULL THEN '{}'::jsonb
          ELSE jsonb_build_object('recorded_details',v_payload->>'meter_register_notes') END,
        CASE WHEN nullif(v_payload->>'utility_details_notes','') IS NULL THEN '{}'::jsonb
          ELSE jsonb_build_object('recorded_details',v_payload->>'utility_details_notes') END,
        CASE WHEN nullif(v_payload->>'access_details_notes','') IS NULL THEN '{}'::jsonb
          ELSE jsonb_build_object('recorded_details',v_payload->>'access_details_notes') END,
        CASE WHEN nullif(v_payload->>'fire_safety_details_notes','') IS NULL THEN '{}'::jsonb
          ELSE jsonb_build_object('recorded_details',v_payload->>'fire_safety_details_notes') END,
        nullif(v_payload->>'source_reference',''),
        nullif(v_payload->>'source_description',''),
        jsonb_build_object(
          'recorded_by_personnel_ref',v_actor.personnel_ref,
          'command_id',v_command.id,
          'capture_method','unit_infrastructure_command'
        ),
        now()
      )
      ON CONFLICT(building_unit_id) DO UPDATE SET
        electrical_supply_status=excluded.electrical_supply_status,
        water_supply_status=excluded.water_supply_status,
        wastewater_status=excluded.wastewater_status,
        gas_supply_status=excluded.gas_supply_status,
        telecoms_status=excluded.telecoms_status,
        heating_cooling_status=excluded.heating_cooling_status,
        fire_detection_status=excluded.fire_detection_status,
        fire_suppression_status=excluded.fire_suppression_status,
        access_control_status=excluded.access_control_status,
        meter_register=excluded.meter_register,
        utility_details=excluded.utility_details,
        access_details=excluded.access_details,
        fire_safety_details=excluded.fire_safety_details,
        source_reference=excluded.source_reference,
        source_description=excluded.source_description,
        provenance=excluded.provenance,
        updated_at=now()
      RETURNING * INTO v_profile;

      v_result:=jsonb_build_object(
        'ok',true,'record_type','unit_infrastructure',
        'unit_ref',v_unit.unit_ref,'infrastructure',to_jsonb(v_profile)
      );
    END IF;
  END IF;

  IF coalesce((v_result->>'ok')::boolean,false) THEN
    v_result:=v_result||jsonb_build_object('status','completed','command_id',v_command.id);
    UPDATE game.game_commands SET status='completed',result=v_result,completed_at=now()
    WHERE id=v_command.id;
  ELSE
    UPDATE game.game_commands SET status='rejected',
      rejection_reason=coalesce(v_result->>'message',v_result->>'code','Unit infrastructure command rejected.'),
      result=v_result,completed_at=now()
    WHERE id=v_command.id;
    v_result:=v_result||jsonb_build_object('command_id',v_command.id);
  END IF;

  RETURN v_result;
END;
$function$;

REVOKE ALL ON FUNCTION game.interpret_text_command(text),
  game.execute_text_command(text,text,uuid,uuid),
  game.get_unit_infrastructure_record(text)
FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION game.interpret_text_command(text),
  game.execute_text_command(text,text,uuid,uuid),
  game.get_unit_infrastructure_record(text)
TO service_role;
