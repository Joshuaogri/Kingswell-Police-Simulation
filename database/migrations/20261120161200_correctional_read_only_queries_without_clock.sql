DO $migration$
DECLARE
  v_definition text;
  v_old text := 'IF n IS NULL THEN RETURN jsonb_build_object(''ok'',false,''code'',''clock_not_initialized'',''message'',''Initialize the fictional clock before correctional operations.''); END IF;';
  v_new text := 'IF n IS NULL AND p_type NOT IN (''correctional_get_record'',''correctional_list_facilities'') THEN RETURN jsonb_build_object(''ok'',false,''code'',''clock_not_initialized'',''message'',''Initialize the fictional clock before changing correctional game state.''); END IF;';
BEGIN
  SELECT pg_get_functiondef('game.execute_correctional_command(uuid,text,jsonb,uuid)'::regprocedure)
    INTO v_definition;
  IF position(v_old IN v_definition) = 0 THEN
    RAISE EXCEPTION 'Expected correctional clock guard was not found; refusing to modify runtime function';
  END IF;
  v_definition := replace(v_definition, v_old, v_new);
  EXECUTE v_definition;
END
$migration$;
