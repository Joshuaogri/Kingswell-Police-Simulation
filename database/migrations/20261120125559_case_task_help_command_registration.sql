-- Include case-task command types in the existing player help response.
create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path to 'pg_catalog','game'
as $$
declare v_interpreted jsonb; v_type text; v_payload jsonb; v_command game.game_commands%rowtype;
 v_result jsonb; v_actor game.police_personnel%rowtype; v_assignee game.police_personnel%rowtype;
begin
 v_interpreted:=game.interpret_text_command(p_command_text); v_type:=v_interpreted->>'command_type';
 if coalesce((v_interpreted->>'recognized')::boolean,false)=false or v_type not in ('create_case_task','update_case_task','assign_case_task','list_case_tasks','get_case_task') then
  v_result:=game.execute_text_command_before_case_tasks(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  if v_type='help' and coalesce((v_result->>'ok')::boolean,false) then
   return jsonb_set(v_result,'{available_commands}',coalesce(v_result->'available_commands','[]'::jsonb)||jsonb_build_array('create_case_task','update_case_task','assign_case_task','list_case_tasks','get_case_task'));
  end if;
  return v_result;
 end if;
 v_payload:=coalesce(v_interpreted->'payload','{}'::jsonb);
 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then raise exception 'Command text must contain between 1 and 4000 characters'; end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key between 8 and 200 characters is required'; end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload) values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload) on conflict(idempotency_key) do nothing;
 if not found then
  select * into v_command from game.game_commands where idempotency_key=p_idempotency_key for update;
  if v_command.command_text<>p_command_text or v_command.command_type<>v_type or v_command.payload<>v_payload then return jsonb_build_object('ok',false,'code','idempotency_conflict','message','This command key was already used for a different command.','command_id',v_command.id); end if;
  return coalesce(v_command.result,jsonb_build_object('ok',v_command.status='completed','status',v_command.status,'command_id',v_command.id,'message','Previously received command; no duplicate action was executed.'))||jsonb_build_object('duplicate',true);
 end if;
 select * into v_command from game.game_commands where idempotency_key=p_idempotency_key for update;
 if v_type in ('create_case_task','update_case_task','assign_case_task') then
  select * into v_actor from game.police_personnel where personnel_ref=btrim(v_payload->>'actor_ref');
  if not found or (p_actor_personnel_id is not null and p_actor_personnel_id<>v_actor.id) then v_result:=jsonb_build_object('ok',false,'code','actor_mismatch','message','The command actor must match the named active police personnel record.');
  elsif v_type='create_case_task' then v_result:=game.create_case_task(v_payload->>'case_ref',v_payload->>'task_type',v_payload->>'title',v_payload->>'description',v_payload->>'priority',v_payload->>'assignee_ref',v_payload->>'actor_ref',null,v_command.id);
  elsif v_type='update_case_task' then v_result:=game.update_case_task(v_payload->>'task_ref',v_payload->>'status',v_payload->>'outcome',null,v_payload->>'actor_ref',v_command.id);
  else
   select * into v_assignee from game.police_personnel where personnel_ref=btrim(v_payload->>'assignee_ref');
   if not found or v_assignee.employment_status not in ('active','seconded') then v_result:=jsonb_build_object('ok',false,'code','invalid_assignee','message','The assigned investigator must be active or seconded police personnel.');
   else v_result:=game.update_case_task(v_payload->>'task_ref',(select status from game.case_tasks where task_ref=v_payload->>'task_ref'),null,v_payload->>'assignee_ref',v_payload->>'actor_ref',v_command.id); end if;
  end if;
 else
  if v_type='list_case_tasks' then v_result:=game.get_case_tasks(v_payload->>'case_ref',null,100); else v_result:=game.get_case_tasks(null,v_payload->>'task_ref',10); end if;
 end if;
 if coalesce((v_result->>'ok')::boolean,false) then
  v_result:=v_result||jsonb_build_object('status','completed','command_id',v_command.id);
  update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_command.id;
 else
  update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Case task command rejected.'),result=v_result,completed_at=now() where id=v_command.id;
  v_result:=v_result||jsonb_build_object('command_id',v_command.id);
 end if;
 return v_result;
end;
$$;
