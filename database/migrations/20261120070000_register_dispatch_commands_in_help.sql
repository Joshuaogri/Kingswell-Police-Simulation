-- Extend the supported help catalogue with call intake and unit dispatch.
do $$
declare v_definition text;
begin
  select pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure) into v_definition;
  if position('jsonb_build_array(''help'',''status'',''initialize_clock'',''advance_time'',''receive_call'',''dispatch_unit'')' in v_definition)=0 then
    raise exception 'Help command catalogue does not include the registered operational commands.';
  end if;
end;
$$;
