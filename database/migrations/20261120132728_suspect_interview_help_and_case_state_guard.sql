create or replace function game.record_case_suspect_interview(p_interview_ref text,p_reason text,p_actor_ref text,p_command_id uuid)
returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare v_interview game.case_interviews%rowtype; v_actor game.police_personnel%rowtype; v_clock timestamptz; v_person game.persons%rowtype; v_case game.cases%rowtype;
begin
 select * into v_interview from game.case_interviews where interview_ref=btrim(p_interview_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','interview_not_found','message','Interview reference not found.'); end if;
 select * into v_case from game.cases where id=v_interview.case_id;
 if not found or v_case.status='closed' then return jsonb_build_object('ok',false,'code','case_closed','message','A closed or missing case cannot receive a suspect interview classification.'); end if;
 if exists(select 1 from game.case_interview_events e where e.interview_id=v_interview.id and e.event_type in ('interview_concluded','interview_interrupted')) then return jsonb_build_object('ok',false,'code','interview_ended','message','A concluded or interrupted interview cannot be newly classified as a suspect interview.'); end if;
 select * into v_person from game.persons where id=v_interview.interviewee_person_id and person_status='active';
 if not found then return jsonb_build_object('ok',false,'code','person_unavailable','message','Interviewee must be an active person record.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found or v_actor.id<>v_interview.interviewer_personnel_id then return jsonb_build_object('ok',false,'code','interviewer_mismatch','message','Only the recorded interviewer may classify this as a suspect interview.'); end if;
 if exists(select 1 from game.case_suspect_interview_records where interview_id=v_interview.id) then return jsonb_build_object('ok',false,'code','already_classified','message','This interview is already recorded as a suspect interview.'); end if;
 if length(btrim(coalesce(p_reason,''))) not between 3 and 2000 then return jsonb_build_object('ok',false,'code','invalid_reason','message','A reason of 3 to 2,000 characters is required.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before recording suspect interview details.'); end if;
 if not exists(select 1 from game.case_persons cp where cp.case_id=v_interview.case_id and cp.person_id=v_person.id and cp.case_role='suspect') then
  insert into game.case_persons(case_id,person_id,case_role,notes) values(v_interview.case_id,v_person.id,'suspect','Recorded as a suspect in a case interview; classification is an investigative record, not a finding of guilt.');
 end if;
 insert into game.case_suspect_interview_records(interview_id,case_id,suspect_person_id,recorded_by_personnel_id,recorded_at_game_time,reason,source_command_id)
 values(v_interview.id,v_interview.case_id,v_person.id,v_actor.id,v_clock,btrim(p_reason),p_command_id);
 return jsonb_build_object('ok',true,'interview_ref',v_interview.interview_ref,'suspect',v_person.person_ref,'case_ref',v_case.case_ref,'recorded_at',v_clock,'message','Suspect interview classification recorded. This is an investigative status, not a determination of guilt.');
end $$;

create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare v_i jsonb; v_type text; v_payload jsonb; v_cmd game.game_commands%rowtype; v_result jsonb; v_actor game.police_personnel%rowtype;
begin
 v_i:=game.interpret_text_command(p_command_text); v_type:=v_i->>'command_type'; v_payload:=coalesce(v_i->'payload','{}'::jsonb);
 if v_type='help' then
  v_result:=game.execute_text_command_before_suspect_interviews(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  return jsonb_set(v_result,'{available_commands}',coalesce(v_result->'available_commands','[]'::jsonb)||jsonb_build_array('classify_case_suspect_interview','assess_case_suspect_interview_turn','get_case_suspect_interview_review'),true);
 end if;
 if coalesce((v_i->>'recognized')::boolean,false)=false or v_type not in ('classify_case_suspect_interview','assess_case_suspect_interview_turn','get_case_suspect_interview_review') then
  return game.execute_text_command_before_suspect_interviews(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
 end if;
 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then raise exception 'Command text must contain between 1 and 4000 characters'; end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key between 8 and 200 characters is required'; end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload) values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload) on conflict(idempotency_key) do nothing;
 if not found then
  select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if v_cmd.command_text<>p_command_text or v_cmd.command_type<>v_type or v_cmd.payload<>v_payload then return jsonb_build_object('ok',false,'code','idempotency_conflict','message','This command key was already used for a different command.','command_id',v_cmd.id); end if;
  return coalesce(v_cmd.result,jsonb_build_object('ok',v_cmd.status='completed','status',v_cmd.status,'command_id',v_cmd.id))||jsonb_build_object('duplicate',true);
 end if;
 select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 if v_type='get_case_suspect_interview_review' then v_result:=game.get_case_suspect_interview_review(v_payload->>'interview_ref');
 else
  select * into v_actor from game.police_personnel where personnel_ref=btrim(v_payload->>'actor_ref');
  if not found or (p_actor_personnel_id is not null and p_actor_personnel_id<>v_actor.id) then v_result:=jsonb_build_object('ok',false,'code','actor_mismatch','message','The command actor must match the named police personnel record.');
  elsif v_type='classify_case_suspect_interview' then v_result:=game.record_case_suspect_interview(v_payload->>'interview_ref',v_payload->>'reason',v_payload->>'actor_ref',v_cmd.id);
  else v_result:=game.assess_case_suspect_interview_turn(v_payload->>'interview_ref',v_payload->>'turn_ref',v_payload->>'assessment',v_payload->>'reason',v_payload->>'actor_ref',v_cmd.id);
  end if;
 end if;
 if coalesce((v_result->>'ok')::boolean,false) then
  v_result:=v_result||jsonb_build_object('status','completed','command_id',v_cmd.id);
  update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_cmd.id;
 else
  update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Suspect interview command rejected.'),result=v_result,completed_at=now() where id=v_cmd.id;
  v_result:=v_result||jsonb_build_object('command_id',v_cmd.id);
 end if;
 return v_result;
end $$;
revoke all on function game.record_case_suspect_interview(text,text,text,uuid),game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.record_case_suspect_interview(text,text,text,uuid),game.execute_text_command(text,text,uuid,uuid) to service_role;
