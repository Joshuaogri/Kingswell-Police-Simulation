-- Register every implemented command in the player's help catalogue.
do $$
declare v_definition text;
begin
  select pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure) into v_definition;
  if position('jsonb_build_array(''help'',''status'',''initialize_clock'',''advance_time'')' = 0 then
    if position('jsonb_build_array(''help'',''status'',''initialize_clock'',''advance_time'',''receive_call'',''dispatch_unit'')' > 0 then
      raise notice 'All operational commands already registered.';
      return;
    end if;
    raise exception 'Expected base help catalogue not found.';
  end if;
  v_definition:=replace(v_definition,
    'jsonb_build_array(''help'',''status'',''initialize_clock'',''advance_time'')',
    'jsonb_build_array(''help'',''status'',''initialize_clock'',''advance_time'',''receive_call'',''dispatch_unit'')');
  execute v_definition;
end;
$$;
