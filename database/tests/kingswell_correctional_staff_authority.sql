-- Rollback-only BP-29 correctional staff authority-boundary regression.
-- Verify the layered dispatcher and confirm police-player appointment remains unavailable.
BEGIN;
DO $test$
DECLARE r jsonb; v text;
BEGIN
 r:=game.interpret_text_command('prison staff list KWCF-000001 by KW-TEST');
 IF r->>'command_type'<>'correctional_staff_list' THEN RAISE EXCEPTION 'Staff list parser failed: %',r; END IF;
 r:=game.interpret_text_command('prison staff appoint KWPERS-000001 to KWCF-000001 role correctional_officer by KW-TEST');
 IF r->>'command_type'='correctional_staff_appoint' THEN RAISE EXCEPTION 'Police-driven staff appointment must not be exposed'; END IF;
 r:=game.interpret_text_command('prison facilities by KW-TEST');
 IF r->>'command_type'<>'correctional_list_facilities' THEN RAISE EXCEPTION 'Existing facilities parser regressed: %',r; END IF;

 SELECT pg_get_functiondef('game.execute_text_command_before_unit_infrastructure(text,text,uuid,uuid)'::regprocedure) INTO v;
 IF position('correctional_staff_list' IN v)=0 OR position('game.execute_correctional_command' IN v)=0 THEN
  RAISE EXCEPTION 'Delegated text runtime does not route the staff directory to the correctional executor';
 END IF;
 SELECT pg_get_functiondef('game.execute_correctional_command(uuid,text,jsonb,uuid)'::regprocedure) INTO v;
 IF position('correctional_staff_list' IN v)=0 THEN
  RAISE EXCEPTION 'Correctional staff list handler missing from correctional executor';
 END IF;
 IF position('correctional_staff_appoint' IN v)>0 THEN
  RAISE EXCEPTION 'Police-driven staff appointment remains in correctional executor';
 END IF;
 r:=game.execute_text_command('prison staff list KWCF-000001 by KW-TEST','test-correctional-staff-authority-0001',NULL,NULL);
 IF r->>'code'<>'actor_mismatch' THEN
  RAISE EXCEPTION 'Staff directory did not reach actor validation: %',r;
 END IF;
END
$test$;
ROLLBACK;
