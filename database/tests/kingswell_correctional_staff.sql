-- Rollback-only BP-29 correctional staff command regression.
BEGIN;
DO $test$
DECLARE r jsonb; v text;
BEGIN
 r:=game.interpret_text_command('prison staff appoint KWPERS-000001 to KWCF-000001 role correctional_officer by KW-TEST');
 IF r->>'command_type'<>'correctional_staff_appoint' OR r#>>'{payload,role}'<>'correctional_officer' THEN RAISE EXCEPTION 'Staff appointment parser failed: %',r; END IF;
 r:=game.interpret_text_command('prison staff list KWCF-000001 by KW-TEST');
 IF r->>'command_type'<>'correctional_staff_list' THEN RAISE EXCEPTION 'Staff list parser failed: %',r; END IF;
 r:=game.interpret_text_command('prison facilities by KW-TEST');
 IF r->>'command_type'<>'correctional_list_facilities' THEN RAISE EXCEPTION 'Existing correctional parser regressed: %',r; END IF;
 r:=game.interpret_text_command('court verdict record KWC-000001 at KWH-000001 by KWO-000001 as guilty because "Regression"');
 IF r->>'command_type'<>'record_trial_verdict' THEN RAISE EXCEPTION 'Existing court parser regressed: %',r; END IF;
 r:=game.execute_text_command('prison staff appoint KWPERS-000001 to KWCF-000001 role correctional_officer by KW-TEST','test-staff-appoint-0001',NULL,NULL);
 IF r->>'code'<>'actor_mismatch' THEN RAISE EXCEPTION 'Staff command dispatch failed: %',r; END IF;
 SELECT pg_get_functiondef('game.execute_text_command(text,text,uuid,uuid)'::regprocedure) INTO v;
 IF position('correctional_staff_appoint' IN v)=0 OR position('correctional_staff_list' IN v)=0 THEN RAISE EXCEPTION 'Staff commands absent from runtime help/allow-list'; END IF;
 IF NOT (SELECT relrowsecurity FROM pg_class WHERE oid='game.correctional_staff_profiles'::regclass) THEN RAISE EXCEPTION 'Staff profiles RLS disabled'; END IF;
 IF NOT (SELECT relrowsecurity FROM pg_class WHERE oid='game.correctional_staff_events'::regclass) THEN RAISE EXCEPTION 'Staff events RLS disabled'; END IF;
END
$test$;
ROLLBACK;
