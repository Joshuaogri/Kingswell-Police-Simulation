create or replace function game.release_case_investigator(
 p_case_ref text,p_personnel_ref text,p_assignment_role text,p_reason text,p_actor_personnel_ref text,p_source_command_id uuid default null
) returns jsonb language plpgsql set search_path to 'pg_catalog','game'
as $$
declare v_case game.cases%rowtype; v_person game.police_personnel%rowtype; v_actor game.police_personnel%rowtype;
 v_assignment game.case_assignments%rowtype; v_clock timestamptz;
begin
 if nullif(btrim(p_case_ref),'') is null or nullif(btrim(p_personnel_ref),'') is null
  or lower(coalesce(p_assignment_role,'')) not in ('lead_investigator','investigator','supervisor','specialist')
  or nullif(btrim(p_reason),'') is null or char_length(p_reason)>2000 then
  return jsonb_build_object('ok',false,'code','invalid_release','message','Provide case, personnel, assignment role and release reason (maximum 2,000 characters).');
 end if;
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional game clock before releasing investigators.'); end if;
 select * into v_case from game.cases where case_ref=btrim(p_case_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference was not found.'); end if;
 select * into v_person from game.police_personnel where personnel_ref=btrim(p_personnel_ref);
 if not found then return jsonb_build_object('ok',false,'code','personnel_not_found','message','Personnel reference was not found.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_personnel_ref);
 if not found or v_actor.employment_status not in ('active','seconded') then return jsonb_build_object('ok',false,'code','invalid_actor','message','The recording officer must be active or seconded police personnel.'); end if;
 select * into v_assignment from game.case_assignments where case_id=v_case.id and personnel_id=v_person.id
  and assignment_role=lower(p_assignment_role) and status='active' for update;
 if not found then return jsonb_build_object('ok',false,'code','assignment_not_found','message','No active assignment exists for that investigator in the specified role on this case.'); end if;
 update game.case_assignments set status='released',released_at=v_clock where id=v_assignment.id;
 insert into game.case_assignment_events(assignment_id,case_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id)
 values(v_assignment.id,v_case.id,'released',v_actor.id,v_clock,
  jsonb_build_object('personnel_ref',v_person.personnel_ref,'assignment_role',v_assignment.assignment_role,'reason',btrim(p_reason)),p_source_command_id);
 if v_assignment.assignment_role='lead_investigator' then update game.cases set lead_personnel_id=null,updated_at=now() where id=v_case.id and lead_personnel_id=v_person.id; end if;
 return jsonb_build_object('ok',true,'case_ref',v_case.case_ref,'personnel_ref',v_person.personnel_ref,
  'assignment_role',v_assignment.assignment_role,'released_at_game_time',v_clock,'reason',btrim(p_reason));
end $$;
revoke all on function game.release_case_investigator(text,text,text,text,text,uuid) from public,anon,authenticated;
grant execute on function game.release_case_investigator(text,text,text,text,text,uuid) to service_role;

create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game'
as $$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^case[[:space:]]+assign[[:space:]]+([^[:space:]]+)[[:space:]]+to[[:space:]]+([^[:space:]]+)[[:space:]]+role[[:space:]]+(lead_investigator|investigator|supervisor|specialist)[[:space:]]+by[[:space:]]+([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','assign_case_investigator','payload',jsonb_build_object('case_ref',m[1],'personnel_ref',m[2],'assignment_role',lower(m[3]),'actor_ref',m[4])); end if;
 m:=regexp_match(t,'^case[[:space:]]+unassign[[:space:]]+([^[:space:]]+)[[:space:]]+([^[:space:]]+)[[:space:]]+role[[:space:]]+(lead_investigator|investigator|supervisor|specialist)[[:space:]]+because[[:space:]]+"([^"]+)"[[:space:]]+by[[:space:]]+([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','release_case_investigator','payload',jsonb_build_object('case_ref',m[1],'personnel_ref',m[2],'assignment_role',lower(m[3]),'reason',m[4],'actor_ref',m[5])); end if;
 m:=regexp_match(t,'^case[[:space:]]+assignments[[:space:]]+([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','list_case_assignments','payload',jsonb_build_object('case_ref',m[1])); end if;
 return game.interpret_text_command_before_case_assignments(p_command_text);
end $$;

create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path to 'pg_catalog','game'
as $$
declare v_i jsonb; v_type text; v_payload jsonb; v_cmd game.game_commands%rowtype; v_result jsonb; v_actor game.police_personnel%rowtype;
begin
 v_i:=game.interpret_text_command(p_command_text); v_type:=v_i->>'command_type';
 if coalesce((v_i->>'recognized')::boolean,false)=false or v_type not in ('assign_case_investigator','release_case_investigator','list_case_assignments') then
  v_result:=game.execute_text_command_before_case_assignments(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  if v_type='help' and coalesce((v_result->>'ok')::boolean,false) then
   return jsonb_set(v_result,'{available_commands}',coalesce(v_result->'available_commands','[]'::jsonb)||jsonb_build_array('assign_case_investigator','release_case_investigator','list_case_assignments'));
  end if;
  return v_result;
 end if;
 v_payload:=coalesce(v_i->'payload','{}'::jsonb);
 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then raise exception 'Command text must contain between 1 and 4000 characters'; end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key between 8 and 200 characters is required'; end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload) values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload) on conflict(idempotency_key) do nothing;
 if not found then
  select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if v_cmd.command_text<>p_command_text or v_cmd.command_type<>v_type or v_cmd.payload<>v_payload then return jsonb_build_object('ok',false,'code','idempotency_conflict','message','This command key was already used for a different command.','command_id',v_cmd.id); end if;
  return coalesce(v_cmd.result,jsonb_build_object('ok',v_cmd.status='completed','status',v_cmd.status,'command_id',v_cmd.id))||jsonb_build_object('duplicate',true);
 end if;
 select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 if v_type in ('assign_case_investigator','release_case_investigator') then
  select * into v_actor from game.police_personnel where personnel_ref=btrim(v_payload->>'actor_ref');
  if not found or (p_actor_personnel_id is not null and p_actor_personnel_id<>v_actor.id) then
   v_result:=jsonb_build_object('ok',false,'code','actor_mismatch','message','The command actor must match the named active police personnel record.');
  elsif v_type='assign_case_investigator' then
   v_result:=game.assign_case_investigator(v_payload->>'case_ref',v_payload->>'personnel_ref',v_payload->>'assignment_role',v_payload->>'actor_ref',v_cmd.id);
  else
   v_result:=game.release_case_investigator(v_payload->>'case_ref',v_payload->>'personnel_ref',v_payload->>'assignment_role',v_payload->>'reason',v_payload->>'actor_ref',v_cmd.id);
  end if;
 else v_result:=game.get_case_assignments(v_payload->>'case_ref',null,true);
 end if;
 if coalesce((v_result->>'ok')::boolean,false) then
  v_result:=v_result||jsonb_build_object('status','completed','command_id',v_cmd.id);
  update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_cmd.id;
 else
  update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Case assignment command rejected.'),result=v_result,completed_at=now() where id=v_cmd.id;
  v_result:=v_result||jsonb_build_object('command_id',v_cmd.id);
 end if;
 return v_result;
end $$;
