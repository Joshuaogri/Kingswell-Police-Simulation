-- Validate optional caller and priority values on call-intake commands.
do $$
declare v_definition text;
begin
  select pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure) into v_definition;
  v_definition:=replace(v_definition,
    '    if jsonb_typeof(p_payload->''priority'')=''number'' and pg_input_is_valid(p_payload->>''priority'',''smallint'') then',
    '    if p_payload ? ''priority'' and (jsonb_typeof(p_payload->''priority'')<>''number'' or not pg_input_is_valid(p_payload->>''priority'',''smallint'')) then
      v_result:=jsonb_build_object(''ok'',false,''code'',''invalid_priority'',''message'',''Priority must be a whole number from 1 to 5.'');
      update game.game_commands set status=''rejected'',rejection_reason=''Invalid priority value.'',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object(''command_id'',v_command.id);
    end if;
    if jsonb_typeof(p_payload->''priority'')=''number'' and pg_input_is_valid(p_payload->>''priority'',''smallint'') then');
  v_definition:=replace(v_definition,
    '    insert into game.incidents(incident_ref,reported_at,location_description,priority,status,summary,details)',
    '    if p_payload ? ''caller_person_id'' and not pg_input_is_valid(p_payload->>''caller_person_id'',''uuid'') then
      v_result:=jsonb_build_object(''ok'',false,''code'',''invalid_caller_reference'',''message'',''Caller person reference is not a valid fictional person ID.'');
      update game.game_commands set status=''rejected'',rejection_reason=''Invalid caller person UUID.'',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object(''command_id'',v_command.id);
    end if;
    insert into game.incidents(incident_ref,reported_at,location_description,priority,status,summary,details)');
  if position('Invalid priority value' in v_definition)=0 then raise exception 'Priority validation patch did not apply.'; end if;
  execute v_definition;
end;
$$;
