do $$
declare v_definition text;
begin
  select pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure) into v_definition;
  if position('and pp.current_unit_id=v_unit_id' in v_definition)=0 then
    raise exception 'Expected home-unit restriction not found; refusing an unverified replacement.';
  end if;
  v_definition:=replace(v_definition,'and pp.current_unit_id=v_unit_id','');
  execute v_definition;
end;
$$;
