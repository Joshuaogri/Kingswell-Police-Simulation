BEGIN;

DO $$
DECLARE
  parsed jsonb;
  malformed jsonb;
  routed jsonb;
  missing_record jsonb;
BEGIN
  parsed:=game.interpret_text_command(
    'unit infrastructure UNIT-TEST-0001 connected shared connected disconnected connected central present shared controlled "Electricity meter M-01; water meter W-02" "Main supply from shared riser" "Key-controlled entrance" "Shared detection panel; unit suppression unknown" "FAC-REF-01" "Facilities inspection record" by KNG-TEST-0001'
  );
  IF parsed->>'command_type'<>'unit_infrastructure_record'
     OR parsed#>>'{payload,unit_ref}'<>'UNIT-TEST-0001'
     OR parsed#>>'{payload,electrical_supply_status}'<>'connected'
     OR parsed#>>'{payload,water_supply_status}'<>'shared'
     OR parsed#>>'{payload,fire_detection_status}'<>'present'
     OR parsed#>>'{payload,access_control_status}'<>'controlled'
     OR parsed#>>'{payload,meter_register_notes}'<>'Electricity meter M-01; water meter W-02'
     OR parsed#>>'{payload,source_reference}'<>'FAC-REF-01' THEN
    RAISE EXCEPTION 'Unit infrastructure parser returned incorrect fields: %',parsed;
  END IF;

  parsed:=game.interpret_text_command(
    'unit infrastructure UNIT-TEST-0001 unknown unknown unknown unknown unknown unknown unknown unknown unknown "" "" "" "" "" "" by KNG-TEST-0001'
  );
  IF parsed->>'command_type'<>'unit_infrastructure_record'
     OR parsed#>>'{payload,electrical_supply_status}'<>'unknown' THEN
    RAISE EXCEPTION 'Unknown infrastructure values were not preserved: %',parsed;
  END IF;

  malformed:=game.interpret_text_command(
    'unit infrastructure UNIT-TEST-0001 invented unknown unknown unknown unknown unknown unknown unknown unknown "" "" "" "" "" "" by KNG-TEST-0001'
  );
  IF malformed->>'command_type'='unit_infrastructure_record' THEN
    RAISE EXCEPTION 'Invalid infrastructure status should not be accepted by the parser.';
  END IF;

  parsed:=game.interpret_text_command(
    'unit infrastructure record UNIT-TEST-0001 by KNG-TEST-0001'
  );
  IF parsed->>'command_type'<>'unit_infrastructure_get_record'
     OR parsed#>>'{payload,unit_ref}'<>'UNIT-TEST-0001' THEN
    RAISE EXCEPTION 'Unit infrastructure retrieval command was not recognised: %',parsed;
  END IF;

  missing_record:=game.get_unit_infrastructure_record('UNIT-DOES-NOT-EXIST');
  IF missing_record IS NOT NULL THEN
    RAISE EXCEPTION 'Unknown unit unexpectedly returned an infrastructure record: %',missing_record;
  END IF;

  routed:=game.execute_text_command(
    'unit infrastructure UNIT-DOES-NOT-EXIST unknown unknown unknown unknown unknown unknown unknown unknown unknown "" "" "" "" "" "" by KNG-NONEXISTENT',
    'bp04-unit-infrastructure-route-01',NULL,NULL
  );
  IF routed->>'code'<>'actor_mismatch' THEN
    RAISE EXCEPTION 'Unit infrastructure command bypassed runtime actor validation: %',routed;
  END IF;

  routed:=game.execute_text_command(
    'unit infrastructure record UNIT-DOES-NOT-EXIST by KNG-NONEXISTENT',
    'bp04-unit-infrastructure-read-route-01',NULL,NULL
  );
  IF routed->>'code'<>'actor_mismatch' THEN
    RAISE EXCEPTION 'Unit infrastructure retrieval bypassed runtime actor validation: %',routed;
  END IF;
END;
$$;

ROLLBACK;
