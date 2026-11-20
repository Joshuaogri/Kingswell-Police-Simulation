
create table game.case_supervisory_reviews (
 id uuid primary key default gen_random_uuid(),
 review_ref text not null unique,
 case_id uuid not null references game.cases(id),
 outcome text not null check (outcome in ('continue_investigation','further_enquiries','recommend_submission','recommend_suspension','recommend_closure','recommend_reopening')),
 review_reason text not null check (length(btrim(review_reason))>0),
 reviewed_by_personnel_id uuid not null references game.police_personnel(id),
 reviewed_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now()
);
create index case_supervisory_reviews_case_time_idx on game.case_supervisory_reviews(case_id,reviewed_at_game_time desc);
create table game.case_status_events (
 id uuid primary key default gen_random_uuid(),
 event_ref text not null unique,
 case_id uuid not null references game.cases(id),
 previous_status text not null,
 new_status text not null check (new_status in ('open','under_investigation','suspended','submitted','closed','reopened')),
 reason text not null check (length(btrim(reason))>0),
 changed_by_personnel_id uuid not null references game.police_personnel(id),
 changed_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now(),
 check (previous_status<>new_status)
);
create index case_status_events_case_time_idx on game.case_status_events(case_id,changed_at_game_time desc);
alter table game.case_supervisory_reviews enable row level security;
alter table game.case_status_events enable row level security;
revoke all on game.case_supervisory_reviews,game.case_status_events from public,anon,authenticated;
grant select,insert on game.case_supervisory_reviews,game.case_status_events to service_role;
grant usage,select on all sequences in schema game to service_role;

create or replace function game.prevent_case_governance_mutation()
returns trigger language plpgsql set search_path to 'pg_catalog','game' as $$
begin raise exception 'Case governance history is append-only'; end $$;
create trigger case_supervisory_reviews_immutable before update or delete on game.case_supervisory_reviews for each row execute function game.prevent_case_governance_mutation();
create trigger case_status_events_immutable before update or delete on game.case_status_events for each row execute function game.prevent_case_governance_mutation();

create or replace function game.record_case_supervisory_review(p_case_ref text,p_outcome text,p_reason text,p_actor_personnel_id uuid,p_source_command_id uuid)
returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare v_case game.cases%rowtype; v_now timestamptz; v_ref text; v_id uuid;
begin
 if p_outcome not in ('continue_investigation','further_enquiries','recommend_submission','recommend_suspension','recommend_closure','recommend_reopening') then raise exception 'Unsupported supervisory review outcome'; end if;
 if p_reason is null or length(btrim(p_reason))=0 then raise exception 'A review reason is required'; end if;
 select current_game_time into v_now from game.simulation_state where id=1;
 if v_now is null then raise exception 'The fictional clock must be initialized before recording a supervisory review'; end if;
 select * into v_case from game.cases where case_ref=btrim(p_case_ref) for update;
 if not found then raise exception 'Case reference not found'; end if;
 if not exists(select 1 from game.case_assignments a where a.case_id=v_case.id and a.personnel_id=p_actor_personnel_id and a.assignment_role='supervisor' and a.status='active' and a.released_at is null) then raise exception 'An active supervisor assignment to this case is required'; end if;
 v_ref:='KSR-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
 insert into game.case_supervisory_reviews(review_ref,case_id,outcome,review_reason,reviewed_by_personnel_id,reviewed_at_game_time,source_command_id)
 values(v_ref,v_case.id,p_outcome,btrim(p_reason),p_actor_personnel_id,p_source_command_id,v_now) returning id into v_id;
 return jsonb_build_object('ok',true,'review_ref',v_ref,'case_ref',v_case.case_ref,'outcome',p_outcome,'reason',btrim(p_reason),'reviewed_at_game_time',v_now);
end $$;

create or replace function game.transition_case_status(p_case_ref text,p_new_status text,p_reason text,p_actor_personnel_id uuid,p_source_command_id uuid)
returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare v_case game.cases%rowtype; v_now timestamptz; v_allowed boolean:=false; v_ref text;
begin
 if p_new_status not in ('open','under_investigation','suspended','submitted','closed','reopened') then raise exception 'Unsupported case status'; end if;
 if p_reason is null or length(btrim(p_reason))=0 then raise exception 'A case status reason is required'; end if;
 select current_game_time into v_now from game.simulation_state where id=1;
 if v_now is null then raise exception 'The fictional clock must be initialized before changing case status'; end if;
 select * into v_case from game.cases where case_ref=btrim(p_case_ref) for update;
 if not found then raise exception 'Case reference not found'; end if;
 if not exists(select 1 from game.case_assignments a where a.case_id=v_case.id and a.personnel_id=p_actor_personnel_id and a.assignment_role='supervisor' and a.status='active' and a.released_at is null) then raise exception 'An active supervisor assignment to this case is required'; end if;
 v_allowed:=case v_case.status
  when 'open' then p_new_status in ('under_investigation','suspended','submitted','closed')
  when 'under_investigation' then p_new_status in ('suspended','submitted','closed')
  when 'suspended' then p_new_status in ('reopened','under_investigation','closed')
  when 'submitted' then p_new_status in ('reopened','closed')
  when 'closed' then p_new_status='reopened'
  when 'reopened' then p_new_status in ('under_investigation','suspended','submitted','closed')
  else false end;
 if not v_allowed then raise exception 'Invalid case status transition: % -> %',v_case.status,p_new_status; end if;
 v_ref:='KST-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
 insert into game.case_status_events(event_ref,case_id,previous_status,new_status,reason,changed_by_personnel_id,changed_at_game_time,source_command_id)
 values(v_ref,v_case.id,v_case.status,p_new_status,btrim(p_reason),p_actor_personnel_id,v_now,p_source_command_id);
 update game.cases set status=p_new_status,closed_at=case when p_new_status='closed' then v_now else null end,updated_at=now() where id=v_case.id;
 return jsonb_build_object('ok',true,'case_ref',v_case.case_ref,'previous_status',v_case.status,'status',p_new_status,'event_ref',v_ref,'reason',btrim(p_reason),'changed_at_game_time',v_now);
end $$;

create or replace function game.get_case_governance_history(p_case_ref text)
returns jsonb language plpgsql stable set search_path to 'pg_catalog','game' as $$
declare v_case game.cases%rowtype;
begin
 select * into v_case from game.cases where case_ref=btrim(p_case_ref);
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference not found'); end if;
 return jsonb_build_object(
  'ok',true,'case',jsonb_build_object('case_ref',v_case.case_ref,'title',v_case.case_title,'status',v_case.status,'opened_at',v_case.opened_at,'closed_at',v_case.closed_at,'summary',v_case.summary),
  'supervisory_reviews',(select coalesce(jsonb_agg(jsonb_build_object('review_ref',r.review_ref,'outcome',r.outcome,'reason',r.review_reason,'reviewed_by',p.personnel_ref,'reviewed_at_game_time',r.reviewed_at_game_time) order by r.reviewed_at_game_time,r.created_at),'[]'::jsonb) from game.case_supervisory_reviews r join game.police_personnel p on p.id=r.reviewed_by_personnel_id where r.case_id=v_case.id),
  'status_history',(select coalesce(jsonb_agg(jsonb_build_object('event_ref',e.event_ref,'from',e.previous_status,'to',e.new_status,'reason',e.reason,'changed_by',p.personnel_ref,'changed_at_game_time',e.changed_at_game_time) order by e.changed_at_game_time,e.created_at),'[]'::jsonb) from game.case_status_events e join game.police_personnel p on p.id=e.changed_by_personnel_id where e.case_id=v_case.id)
 );
end $$;

alter function game.interpret_text_command(text) rename to interpret_text_command_before_case_governance;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game' as $$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^case supervisory review ([^[:space:]]+) outcome ([a-z_]+) because "(.+)" by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','record_case_supervisory_review','payload',jsonb_build_object('case_ref',m[1],'outcome',lower(m[2]),'reason',m[3],'actor_ref',m[4])); end if;
 m:=regexp_match(t,'^case status ([^[:space:]]+) set ([a-z_]+) because "(.+)" by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','transition_case_status','payload',jsonb_build_object('case_ref',m[1],'new_status',lower(m[2]),'reason',m[3],'actor_ref',m[4])); end if;
 m:=regexp_match(t,'^case governance ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','get_case_governance_history','payload',jsonb_build_object('case_ref',m[1],'actor_ref',m[2])); end if;
 return game.interpret_text_command_before_case_governance(p_command_text);
end $$;

alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_case_governance;
create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare v_i jsonb;v_type text;v_payload jsonb;v_cmd game.game_commands%rowtype;v_result jsonb;v_actor game.police_personnel%rowtype;v_case_id uuid;
begin
 v_i:=game.interpret_text_command(p_command_text);v_type:=v_i->>'command_type';v_payload:=coalesce(v_i->'payload','{}'::jsonb);
 if v_type='help' then
  v_result:=game.execute_text_command_before_case_governance(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  v_result:=jsonb_set(v_result,'{available_commands}',(select coalesce(jsonb_agg(distinct x),'[]'::jsonb) from jsonb_array_elements_text(coalesce(v_result->'available_commands','[]'::jsonb)||jsonb_build_array('record_case_supervisory_review','transition_case_status','get_case_governance_history')) x),true);
  return v_result;
 end if;
 if v_type not in ('record_case_supervisory_review','transition_case_status','get_case_governance_history') then return game.execute_text_command_before_case_governance(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id); end if;
 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then raise exception 'Command text must contain between 1 and 4000 characters'; end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key between 8 and 200 characters is required'; end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload) values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload) on conflict(idempotency_key) do nothing;
 if not found then
  select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if v_cmd.command_text<>p_command_text or v_cmd.command_type<>v_type or v_cmd.payload<>v_payload then return jsonb_build_object('ok',false,'code','idempotency_conflict','message','This command key was already used for a different command.','command_id',v_cmd.id); end if;
  return coalesce(v_cmd.result,jsonb_build_object('ok',v_cmd.status='completed','status',v_cmd.status,'command_id',v_cmd.id))||jsonb_build_object('duplicate',true);
 end if;
 select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(v_payload->>'actor_ref');
 select id into v_case_id from game.cases where case_ref=btrim(v_payload->>'case_ref');
 if not found then v_result:=jsonb_build_object('ok',false,'code','case_not_found','message','Case reference not found.');
 elsif v_actor.id is null or v_actor.employment_status not in ('active','seconded') or (p_actor_personnel_id is not null and p_actor_personnel_id<>v_actor.id) then v_result:=jsonb_build_object('ok',false,'code','actor_mismatch','message','The command actor must match an active or seconded named personnel record.');
 elsif not exists(select 1 from game.case_assignments a where a.case_id=v_case_id and a.personnel_id=v_actor.id and a.assignment_role='supervisor' and a.status='active' and a.released_at is null) then v_result:=jsonb_build_object('ok',false,'code','supervisor_access_denied','message','An active supervisor assignment to this case is required.');
 else
  begin
   if v_type='record_case_supervisory_review' then v_result:=game.record_case_supervisory_review(v_payload->>'case_ref',v_payload->>'outcome',v_payload->>'reason',v_actor.id,v_cmd.id);
   elsif v_type='transition_case_status' then v_result:=game.transition_case_status(v_payload->>'case_ref',v_payload->>'new_status',v_payload->>'reason',v_actor.id,v_cmd.id);
   else v_result:=game.get_case_governance_history(v_payload->>'case_ref'); end if;
  exception when others then v_result:=jsonb_build_object('ok',false,'code','case_governance_rejected','message',sqlerrm); end;
 end if;
 if coalesce((v_result->>'ok')::boolean,false) then
  v_result:=v_result||jsonb_build_object('status','completed','command_id',v_cmd.id);
  update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_cmd.id;
 else
  update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Case governance command rejected.'),result=v_result,completed_at=now() where id=v_cmd.id;
  v_result:=v_result||jsonb_build_object('command_id',v_cmd.id);
 end if;
 return v_result;
end $$;

revoke all on function game.record_case_supervisory_review(text,text,text,uuid,uuid),game.transition_case_status(text,text,text,uuid,uuid),game.get_case_governance_history(text),game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.record_case_supervisory_review(text,text,text,uuid,uuid),game.transition_case_status(text,text,text,uuid,uuid),game.get_case_governance_history(text),game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) to service_role;
