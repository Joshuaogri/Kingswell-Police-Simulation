-- A live duty roster assignment may represent a temporary cross-unit attachment.
-- The roster's unit, not the employee's substantive home unit, determines operational deployment eligibility.
do $$
declare v_definition text;
begin
  select pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure) into v_definition;
  if position('and pp.current_unit_id=v_unit_id' in v_definition)=0 then
    raise exception 'Expected home-unit restriction not found.';
  end if;
  v_definition:=replace(v_definition,'and pp.current_unit_id=v_unit_id','');
  execute v_definition;
end;
$$;
