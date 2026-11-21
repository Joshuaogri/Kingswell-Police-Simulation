-- Rollback-only BP-29 correctional staff directory regression.
-- The text runtime uses layered dispatch wrappers; verify the delegated handler,
-- not only the outermost wrapper's source text.
BEGIN;
DO $test$
DECLARE r jsonb; v text;
BEGIN
 r:=game.interpret_text_command('prison staff list KWCF-000001 by KW-TEST');
 IF r->>'command_type'<>'correctional_staff_list' THEN RAISE EXCEPTION 'Staff list parser failed: %',r; END IF;
 r:=game.interpret_text_command('prison staff appoint KWPERS-000001 to KWCF-000001 role correctional_officer by KW-TEST');
 IF r->>'command_type'='correctional_staff_appoint' THEN RAISE EXCEPTION 'Police-driven correctional appointment must not be exposed'; END IF;
 r:=game.interpret_text_command('prison facilities by KW-TEST');
 IF r->>'command_type'<>'correctional_list_facilities' THEN RAISE EXCEPTION 'Existing facilities parser regressed: %',r; END IF;
 r:=game.interpret_text_command('court verdict record KWC-000001 at KWH-000001 by KWO-000001 as guilty because "Regression"');
 IF r->>'command_type'<>'record_trial_verdict' THEN RAISE EXCEPTION 'Existing court parser regressed: %',r; END IF;

 SELECT pg_get_functiondef('game.execute_text_command_before_unit_infrastructure(text,text,uuid,uuid)'::regprocedure) INTO v;
 IF position('correctional_staff_list' IN v)=0 OR position('game.execute_correctional_command' IN v)=0 THEN
  RAISE EXCEPTION 'Delegated text runtime does not route the correctional staff directory to its handler';
 END IF;

 r:=game.execute_text_command('prison staff list KWCF-000001 by KW-TEST','test-correctional-staff-routing-0001',NULL,NULL);
 IF r->>'code'<>'actor_mismatch' THEN
  RAISE EXCEPTION 'Staff directory command did not reach actor validation: %',r;
 END IF;
 IF NOT (SELECT relrowsecurity FROM pg_class WHERE oid='game.correctional_staff_profiles'::regclass) THEN RAISE EXCEPTION 'Staff profiles RLS disabled'; END IF;
 IF NOT (SELECT relrowsecurity FROM pg_class WHERE oid='game.correctional_staff_events'::regclass) THEN RAISE EXCEPTION 'Staff events RLS disabled'; END IF;
END
$test$;
ROLLBACK;
