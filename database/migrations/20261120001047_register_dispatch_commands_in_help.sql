do $$
declare v_definition text;
begin
  select pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure) into v_definition;
  if position('jsonb_build_array(''help'',''status'',''initialize_clock'',''advance_time'')' in v_definition)=0 then
    raise exception 'Expected help command list not found.';
  end if;
  v_definition:=replace(v_definition,
    'jsonb_build_array(''help'',''status'',''initialize_clock'',''advance_time'')',
    'jsonb_build_array(''help'',''status'',''initialize_clock'',''advance_time'',''receive_call'',''dispatch_unit'')');
  execute v_definition;
end;
$$;
