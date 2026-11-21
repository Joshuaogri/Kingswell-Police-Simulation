do $$
declare
  v_definition text;
begin
  select pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure)
    into v_definition;
  if position('values(v_incident_id,v_clock.current_game_time,p_actor_personnel_id,' in v_definition)=0 then
    raise exception 'Expected dispatch event insert signature not found; refusing to patch an unexpected function definition.';
  end if;
  v_definition:=replace(v_definition,
    'values(v_incident_id,v_clock.current_game_time,p_actor_personnel_id,',
    'values(v_incident_id,v_clock.current_game_time,''call_received'',p_actor_personnel_id,');
  execute v_definition;
end;
$$;
