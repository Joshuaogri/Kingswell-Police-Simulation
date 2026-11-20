-- Rollback-only regression: correctional read commands remain available before game start.
BEGIN;
DO $test$
DECLARE
  v_result jsonb;
  v_definition text;
  v_clock timestamptz;
BEGIN
  v_result := game.interpret_text_command('prison facilities by KWPD-000001');
  IF v_result->>'command_type' <> 'correctional_list_facilities' THEN
    RAISE EXCEPTION 'Facility-list command parser regression: %', v_result;
  END IF;

  v_result := game.interpret_text_command('prison record KWPA-0000001 by KWPD-000001');
  IF v_result->>'command_type' <> 'correctional_get_record' THEN
    RAISE EXCEPTION 'Prison-record command parser regression: %', v_result;
  END IF;

  SELECT pg_get_functiondef('game.execute_correctional_command(uuid,text,jsonb,uuid)'::regprocedure)
    INTO v_definition;
  IF position('IF n IS NULL AND p_type NOT IN' IN v_definition) = 0 THEN
    RAISE EXCEPTION 'Correctional clock guard still blocks read-only queries';
  END IF;

  SELECT current_game_time INTO v_clock FROM game.simulation_state WHERE id=1;
  IF v_clock IS NOT NULL THEN
    RAISE EXCEPTION 'Regression test expected the game clock to remain uninitialized';
  END IF;
END
$test$;
ROLLBACK;
