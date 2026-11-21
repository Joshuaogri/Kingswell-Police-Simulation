alter table game.case_task_events drop constraint case_task_events_event_type_check;
alter table game.case_task_events add constraint case_task_events_event_type_check check(event_type=any(array['created','assigned','reassigned','status_changed','completed','cancelled','updated','completion_submitted','completion_accepted','completion_returned','dependency_added']));
alter function game.interpret_text_command(text) rename to interpret_text_command_before_task_submissions;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path=pg_catalog,game as $$
declare t text:=btrim(coalesce(p_command_text,''));m text[];
begin
 m:=regexp_match(t,'^case task submit ([^[:space:]]+) by ([^[:space:]]+) because "(.+)"$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','submit_case_task','payload',jsonb_build_object('task_ref',m[1],'actor_ref',m[2],'note',m[3]));end if;
 m:=regexp_match(t,'^case task submission evidence ([^[:space:]]+) ([^[:space:]]+) by ([^[:space:]]+) because "(.+)"$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','link_case_task_submission_evidence','payload',jsonb_build_object('submission_ref',m[1],'evidence_ref',m[2],'actor_ref',m[3],'reason',m[4]));end if;
 m:=regexp_match(t,'^case task submission review ([^[:space:]]+) set (accepted|returned) by ([^[:space:]]+) because "(.+)"$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','review_case_task_submission','payload',jsonb_build_object('submission_ref',m[1],'disposition',lower(m[2]),'actor_ref',m[3],'reason',m[4]));end if;
 m:=regexp_match(t,'^case task submissions ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','get_case_task_submissions','payload',jsonb_build_object('task_ref',m[1],'actor_ref',m[2]));end if;
 return game.interpret_text_command_before_task_submissions(p_command_text);
end $$;
alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_task_submissions;
create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare v_i jsonb;v_type text;v_payload jsonb;v_cmd game.game_commands%rowtype;v_result jsonb;v_actor game.police_personnel%rowtype;v_task game.case_tasks%rowtype;v_case_id uuid;
begin
 v_i:=game.interpret_text_command(p_command_text);v_type:=v_i->>'command_type';v_payload:=coalesce(v_i->'payload','{}'::jsonb);
 if v_type='help' then
  v_result:=game.execute_text_command_before_task_submissions(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  return jsonb_set(v_result,'{available_commands}',(select coalesce(jsonb_agg(distinct x),'[]'::jsonb) from jsonb_array_elements_text(coalesce(v_result->'available_commands','[]'::jsonb)||jsonb_build_array('submit_case_task','link_case_task_submission_evidence','review_case_task_submission','get_case_task_submissions')) x),true);
 end if;
 if v_type not in ('submit_case_task','link_case_task_submission_evidence','review_case_task_submission','get_case_task_submissions') then return game.execute_text_command_before_task_submissions(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);end if;
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
  if v_type='submit_case_task' then v_result:=game.submit_case_task(v_payload->>'task_ref',v_actor.personnel_ref,v_payload->>'note',v_cmd.id);
  elsif v_type='link_case_task_submission_evidence' then v_result:=game.link_case_task_submission_evidence(v_payload->>'submission_ref',v_payload->>'evidence_ref',v_payload->>'reason',v_actor.personnel_ref,v_cmd.id);
  elsif v_type='review_case_task_submission' then v_result:=game.review_case_task_submission(v_payload->>'submission_ref',v_payload->>'disposition',v_payload->>'reason',v_actor.personnel_ref,v_cmd.id);
  else
   select t.* into v_task from game.case_tasks t join game.case_task_submissions s on s.task_id=t.id where s.submission_ref=v_payload->>'task_ref';
   if not found then v_result:=jsonb_build_object('ok',false,'code','task_not_found','message','Task or its submissions were not found.');
   elsif not exists(select 1 from game.case_assignments a where a.case_id=v_task.case_id and a.personnel_id=v_actor.id and a.status='active' and a.released_at is null) and v_task.assigned_personnel_id is distinct from v_actor.id and not exists(select 1 from game.cases c where c.id=v_task.case_id and c.lead_personnel_id=v_actor.id) then
    v_result:=jsonb_build_object('ok',false,'code','case_access_denied','message','The officer must be assigned to the case or be the task assignee.');
   else v_result:=game.get_case_task_submissions(v_task.task_ref);end if;
  end if;
 end if;
 if coalesce((v_result->>'ok')::boolean,false) then v_result:=v_result||jsonb_build_object('status','completed','command_id',v_cmd.id);update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_cmd.id;
 else update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Task submission command rejected.'),result=v_result,completed_at=now() where id=v_cmd.id;v_result:=v_result||jsonb_build_object('command_id',v_cmd.id);end if;
 return v_result;
end $$;
revoke all on function game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) to service_role;
