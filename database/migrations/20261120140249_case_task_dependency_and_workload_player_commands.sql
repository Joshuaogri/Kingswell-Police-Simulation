alter function game.interpret_text_command(text) rename to interpret_text_command_before_task_commands;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path=pg_catalog,game as $$
declare t text:=btrim(coalesce(p_command_text,''));m text[];
begin
 m:=regexp_match(t,'^case task dependency ([^[:space:]]+) requires ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','add_case_task_dependency','payload',jsonb_build_object('task_ref',m[1],'prerequisite_ref',m[2],'actor_ref',m[3]));end if;
 m:=regexp_match(t,'^case task workload(?: case ([^[:space:]]+))?(?: officer ([^[:space:]]+))? by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','get_case_task_workload','payload',jsonb_build_object('case_ref',nullif(m[1],''),'personnel_ref',nullif(m[2],''),'actor_ref',m[3]));end if;
 m:=regexp_match(t,'^case tasks ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','get_case_tasks','payload',jsonb_build_object('case_ref',m[1],'actor_ref',m[2]));end if;
 return game.interpret_text_command_before_task_commands(p_command_text);
end $$;
alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_task_commands;
create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare v_i jsonb;v_type text;v_payload jsonb;v_cmd game.game_commands%rowtype;v_result jsonb;v_actor game.police_personnel%rowtype;v_case_id uuid;v_task_case_id uuid;v_case_ref text;
begin
 v_i:=game.interpret_text_command(p_command_text);v_type:=v_i->>'command_type';v_payload:=coalesce(v_i->'payload','{}'::jsonb);
 if v_type='help' then
  v_result:=game.execute_text_command_before_task_commands(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  return jsonb_set(v_result,'{available_commands}',(select coalesce(jsonb_agg(distinct x),'[]'::jsonb) from jsonb_array_elements_text(coalesce(v_result->'available_commands','[]'::jsonb)||jsonb_build_array('add_case_task_dependency','get_case_task_workload','get_case_tasks')) x),true);
 end if;
 if v_type not in ('add_case_task_dependency','get_case_task_workload','get_case_tasks') then return game.execute_text_command_before_task_commands(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);end if;
 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then raise exception 'Command text must contain between 1 and 4000 characters';end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key between 8 and 200 characters is required';end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload) values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload) on conflict(idempotency_key) do nothing;
 if not found then select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if v_cmd.command_text<>p_command_text or v_cmd.command_type<>v_type or v_cmd.payload<>v_payload then return jsonb_build_object('ok',false,'code','idempotency_conflict','message','This command key was already used for a different command.','command_id',v_cmd.id);end if;
  return coalesce(v_cmd.result,jsonb_build_object('ok',v_cmd.status='completed','status',v_cmd.status,'command_id',v_cmd.id))||jsonb_build_object('duplicate',true);
 end if;
 select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(v_payload->>'actor_ref');
 if v_actor.id is null or v_actor.employment_status not in ('active','seconded') or (p_actor_personnel_id is not null and p_actor_personnel_id<>v_actor.id) then
  v_result:=jsonb_build_object('ok',false,'code','actor_mismatch','message','The named command actor must match active or seconded personnel.');
 else
  if v_type='get_case_task_workload' and v_payload->>'case_ref' is null and v_payload->>'personnel_ref' is null then
   if not exists(select 1 from game.case_assignments a where a.personnel_id=v_actor.id and a.assignment_role='supervisor' and a.status='active' and a.released_at is null) then
    v_result:=jsonb_build_object('ok',false,'code','supervisor_access_denied','message','A current case supervisor assignment is required for department-wide workload.');
   else v_result:=game.get_case_task_workload(null,null,500);end if;
  else
   if v_type='add_case_task_dependency' then
    select c.id,c.case_ref into v_case_id,v_case_ref from game.case_tasks t join game.cases c on c.id=t.case_id where t.task_ref=v_payload->>'task_ref';
    if v_case_id is null then v_result:=jsonb_build_object('ok',false,'code','task_not_found','message','Task reference was not found.');
    elsif not exists(select 1 from game.case_assignments a where a.case_id=v_case_id and a.personnel_id=v_actor.id and a.status='active' and a.released_at is null) and not exists(select 1 from game.cases c where c.id=v_case_id and c.lead_personnel_id=v_actor.id) then v_result:=jsonb_build_object('ok',false,'code','case_access_denied','message','The officer must be assigned to this case.');
    else v_result:=game.add_case_task_dependency(v_payload->>'task_ref',v_payload->>'prerequisite_ref',v_actor.personnel_ref,v_cmd.id);end if;
   elsif v_type='get_case_tasks' then
    select id into v_case_id from game.cases where case_ref=v_payload->>'case_ref';
    if v_case_id is null then v_result:=jsonb_build_object('ok',false,'code','case_not_found','message','Case reference was not found.');
    elsif not exists(select 1 from game.case_assignments a where a.case_id=v_case_id and a.personnel_id=v_actor.id and a.status='active' and a.released_at is null) and not exists(select 1 from game.cases c where c.id=v_case_id and c.lead_personnel_id=v_actor.id) then v_result:=jsonb_build_object('ok',false,'code','case_access_denied','message','The officer must be assigned to this case.');
    else v_result:=game.get_case_tasks(v_payload->>'case_ref',null,500);end if;
   else
    if v_payload->>'case_ref' is not null then
     select id into v_case_id from game.cases where case_ref=v_payload->>'case_ref';
     if v_case_id is null then v_result:=jsonb_build_object('ok',false,'code','case_not_found','message','Case reference was not found.');
     elsif not exists(select 1 from game.case_assignments a where a.case_id=v_case_id and a.personnel_id=v_actor.id and a.status='active' and a.released_at is null) and not exists(select 1 from game.cases c where c.id=v_case_id and c.lead_personnel_id=v_actor.id) then v_result:=jsonb_build_object('ok',false,'code','case_access_denied','message','The officer must be assigned to this case.');
     else v_result:=game.get_case_task_workload(v_payload->>'case_ref',null,500);end if;
    elsif v_payload->>'personnel_ref' is not null then
     if v_payload->>'personnel_ref'<>v_actor.personnel_ref and not exists(select 1 from game.case_assignments a where a.personnel_id=v_actor.id and a.assignment_role='supervisor' and a.status='active' and a.released_at is null) then v_result:=jsonb_build_object('ok',false,'code','supervisor_access_denied','message','Only a supervisor may inspect another officer workload.');
     else v_result:=game.get_case_task_workload(null,v_payload->>'personnel_ref',500);end if;
    else v_result:=jsonb_build_object('ok',false,'code','invalid_scope','message','Specify a case or officer, or hold a supervisor assignment for department-wide workload.');end if;
   end if;
  end if;
 end if;
 if coalesce((v_result->>'ok')::boolean,false) then v_result:=v_result||jsonb_build_object('status','completed','command_id',v_cmd.id);update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_cmd.id;
 else update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Task command rejected.'),result=v_result,completed_at=now() where id=v_cmd.id;v_result:=v_result||jsonb_build_object('command_id',v_cmd.id);end if;
 return v_result;
end $$;
revoke all on function game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) to service_role;
