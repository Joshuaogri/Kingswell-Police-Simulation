-- Assertion for the corrected dispatch event insert.
-- The complete corrected function definition is committed in
-- 20261120030000_text_interpreter_dispatch_intake.sql.
do $$
declare v_definition text;
begin
  select pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure) into v_definition;
  if position('values(v_incident_id,v_clock.current_game_time,''call_received'',p_actor_personnel_id,' in v_definition)=0 then
    raise exception 'Dispatch event type correction is missing.';
  end if;
end;
$$;
