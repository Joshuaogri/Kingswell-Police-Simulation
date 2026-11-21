BEGIN;

DO $$
DECLARE
  parsed jsonb;
  malformed jsonb;
  routed jsonb;
  missing_history jsonb;
BEGIN
  parsed := game.interpret_text_command(
    'property development event PROP-TEST-01 DEV-TEST-01 planning_application submitted unknown 2026-11-21 unknown unknown "PLN-2026-001" "Rear extension application" "Application recorded in the planning register." "PLANNING-REG-001" "Certified planning register extract" by KNG-TEST-0001'
  );
  IF parsed->>'command_type'<>'property_development_event_record'
     OR parsed#>>'{payload,property_ref}'<>'PROP-TEST-01'
     OR parsed#>>'{payload,event_type}'<>'planning_application'
     OR parsed#>>'{payload,event_status}'<>'submitted'
     OR parsed#>>'{payload,occurred_on}' IS NOT NULL
     OR parsed#>>'{payload,recorded_on}'<>'2026-11-21'
     OR parsed#>>'{payload,planning_reference}'<>'PLN-2026-001'
     OR parsed#>>'{payload,source_reference}'<>'PLANNING-REG-001' THEN
    RAISE EXCEPTION 'Property development event parser returned incorrect fields: %',parsed;
  END IF;

  parsed := game.interpret_text_command(
    'property development history PROP-TEST-01 by KNG-TEST-0001'
  );
  IF parsed->>'command_type'<>'property_development_history_get'
     OR parsed#>>'{payload,property_ref}'<>'PROP-TEST-01' THEN
    RAISE EXCEPTION 'Property development history retrieval command was not recognised: %',parsed;
  END IF;

  malformed := game.interpret_text_command(
    'property development event PROP-TEST-01 DEV-TEST-02 fake_status submitted unknown unknown unknown unknown "" "Subject" "Description" "SRC-1" "Source" by KNG-TEST-0001'
  );
  IF malformed->>'command_type'='property_development_event_record' THEN
    RAISE EXCEPTION 'Invalid event type/status should not be accepted: %',malformed;
  END IF;

  missing_history := game.get_property_development_history('PROP-DOES-NOT-EXIST');
  IF missing_history IS NOT NULL THEN
    RAISE EXCEPTION 'Unknown property unexpectedly returned a development history: %',missing_history;
  END IF;

  routed := game.execute_text_command(
    'property development history PROP-DOES-NOT-EXIST by KNG-NONEXISTENT',
    'bp04-property-development-read-01',NULL,NULL
  );
  IF routed->>'code'<>'actor_mismatch' THEN
    RAISE EXCEPTION 'Property development retrieval bypassed actor validation: %',routed;
  END IF;

  routed := game.execute_text_command(
    'property development event PROP-DOES-NOT-EXIST DEV-TEST-03 planning_application submitted unknown unknown unknown unknown "" "Subject" "Description" "SRC-1" "Source" by KNG-NONEXISTENT',
    'bp04-property-development-write-01',NULL,NULL
  );
  IF routed->>'code'<>'actor_mismatch' THEN
    RAISE EXCEPTION 'Property development capture bypassed actor validation: %',routed;
  END IF;
END;
$$;

ROLLBACK;
