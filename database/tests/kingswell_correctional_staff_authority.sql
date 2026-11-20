-- Rollback-only BP-29 correctional staff authority-boundary regression.
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
 SELECT pg_get_functiondef('game.execute_text_command(text,text,uuid,uuid)'::regprocedure) INTO v;
 IF position('correctional_staff_appoint' IN v)>0 THEN RAISE EXCEPTION 'Police-driven staff appointment remains in runtime'; END IF;
 IF position('correctional_staff_list' IN v)=0 THEN RAISE EXCEPTION 'Staff directory command missing from runtime'; END IF;
END
$test$;
ROLLBACK;
