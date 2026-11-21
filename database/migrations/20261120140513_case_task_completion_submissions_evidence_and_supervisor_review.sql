create table game.case_task_submissions(
 id uuid primary key default gen_random_uuid(),
 submission_ref text not null unique,
 task_id uuid not null references game.case_tasks(id),
 submitted_by_personnel_id uuid not null references game.police_personnel(id),
 submitted_at_game_time timestamptz not null,
 completion_note text not null check(char_length(btrim(completion_note)) between 1 and 4000),
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now()
);
create table game.case_task_submission_evidence(
 id uuid primary key default gen_random_uuid(),
 submission_id uuid not null references game.case_task_submissions(id),
 evidence_id uuid not null references game.evidence_items(id),
 reason text not null check(char_length(btrim(reason)) between 1 and 1000),
 linked_by_personnel_id uuid not null references game.police_personnel(id),
 linked_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now(),
 unique(submission_id,evidence_id)
);
create table game.case_task_submission_reviews(
 id uuid primary key default gen_random_uuid(),
 review_ref text not null unique,
 submission_id uuid not null references game.case_task_submissions(id),
 disposition text not null check(disposition in ('accepted','returned')),
 reason text not null check(char_length(btrim(reason)) between 1 and 4000),
 reviewed_by_personnel_id uuid not null references game.police_personnel(id),
 reviewed_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now()
);
create index case_task_submissions_task_idx on game.case_task_submissions(task_id,submitted_at_game_time desc);
create index case_task_submission_evidence_submission_idx on game.case_task_submission_evidence(submission_id);
create index case_task_submission_reviews_submission_idx on game.case_task_submission_reviews(submission_id,reviewed_at_game_time desc);
alter table game.case_task_submissions enable row level security;
alter table game.case_task_submission_evidence enable row level security;
alter table game.case_task_submission_reviews enable row level security;
revoke all on game.case_task_submissions,game.case_task_submission_evidence,game.case_task_submission_reviews from public,anon,authenticated;
grant select,insert on game.case_task_submissions,game.case_task_submission_evidence,game.case_task_submission_reviews to service_role;
create or replace function game.prevent_case_task_submission_mutation()
returns trigger language plpgsql set search_path=pg_catalog,game as $$
begin raise exception 'Case task submissions, evidence links and review history are append-only';end $$;
create trigger case_task_submissions_immutable before update or delete on game.case_task_submissions for each row execute function game.prevent_case_task_submission_mutation();
create trigger case_task_submission_evidence_immutable before update or delete on game.case_task_submission_evidence for each row execute function game.prevent_case_task_submission_mutation();
create trigger case_task_submission_reviews_immutable before update or delete on game.case_task_submission_reviews for each row execute function game.prevent_case_task_submission_mutation();
create or replace function game.enforce_case_task_completion_review()
returns trigger language plpgsql set search_path=pg_catalog,game as $$
begin
 if new.status='completed' and old.status is distinct from new.status then
  if not exists(select 1 from game.case_task_submissions s join game.case_task_submission_reviews r on r.submission_id=s.id
    where s.task_id=new.id and r.disposition='accepted') then
   raise exception 'Task completion requires an accepted supervisor review of a submitted completion record';
  end if;
  if not exists(select 1 from game.case_assignments a where a.case_id=new.case_id and a.personnel_id=new.updated_by_personnel_id
    and a.assignment_role='supervisor' and a.status='active' and a.released_at is null) then
   raise exception 'Only an active case supervisor may approve task completion';
  end if;
 end if;
 return new;
end $$;
create trigger case_task_completion_review_gate before update of status on game.case_tasks
for each row execute function game.enforce_case_task_completion_review();
create or replace function game.submit_case_task(p_task_ref text,p_actor_ref text,p_note text,p_source_command_id uuid)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare v_task game.case_tasks%rowtype;v_actor game.police_personnel%rowtype;v_clock timestamptz;v_ref text;
begin
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before submitting task work.');end if;
 if nullif(btrim(p_note),'') is null or char_length(p_note)>4000 then return jsonb_build_object('ok',false,'code','invalid_note','message','A completion note of 1–4,000 characters is required.');end if;
 select * into v_task from game.case_tasks where task_ref=btrim(p_task_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','task_not_found','message','Task reference was not found.');end if;
 if v_task.status<>'in_progress' then return jsonb_build_object('ok',false,'code','task_not_in_progress','message','Only an in-progress task can be submitted for review.');end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref);
 if not found or v_actor.employment_status not in ('active','seconded') then return jsonb_build_object('ok',false,'code','invalid_actor','message','The submitting officer must be active or seconded.');end if;
 if v_task.assigned_personnel_id is distinct from v_actor.id and not exists(select 1 from game.case_assignments a where a.case_id=v_task.case_id and a.personnel_id=v_actor.id and a.status='active' and a.released_at is null) then
  return jsonb_build_object('ok',false,'code','case_access_denied','message','The submitter must be the assigned officer or actively assigned to the case.');end if;
 if exists(select 1 from game.case_task_submissions s where s.task_id=v_task.id and not exists(select 1 from game.case_task_submission_reviews r where r.submission_id=s.id)) then
  return jsonb_build_object('ok',false,'code','submission_pending','message','This task already has a completion submission awaiting review.');end if;
 v_ref:='KWS-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
 insert into game.case_task_submissions(submission_ref,task_id,submitted_by_personnel_id,submitted_at_game_time,completion_note,source_command_id)
 values(v_ref,v_task.id,v_actor.id,v_clock,btrim(p_note),p_source_command_id);
 insert into game.case_task_events(task_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id)
 values(v_task.id,'completion_submitted',v_actor.id,v_clock,jsonb_build_object('submission_ref',v_ref,'note',btrim(p_note)),p_source_command_id);
 return jsonb_build_object('ok',true,'submission_ref',v_ref,'task_ref',v_task.task_ref,'status','pending_review','submitted_at_game_time',v_clock);
end $$;
create or replace function game.link_case_task_submission_evidence(p_submission_ref text,p_evidence_ref text,p_reason text,p_actor_ref text,p_source_command_id uuid)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare v_s game.case_task_submissions%rowtype;v_t game.case_tasks%rowtype;v_e game.evidence_items%rowtype;v_actor game.police_personnel%rowtype;v_clock timestamptz;
begin
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before linking task evidence.');end if;
 if nullif(btrim(p_reason),'') is null or char_length(p_reason)>1000 then return jsonb_build_object('ok',false,'code','invalid_reason','message','A reason of 1–1,000 characters is required.');end if;
 select * into v_s from game.case_task_submissions where submission_ref=btrim(p_submission_ref);
 if not found then return jsonb_build_object('ok',false,'code','submission_not_found','message','Submission reference was not found.');end if;
 select * into v_t from game.case_tasks where id=v_s.task_id;
 select * into v_e from game.evidence_items where evidence_ref=btrim(p_evidence_ref);
 if not found then return jsonb_build_object('ok',false,'code','evidence_not_found','message','Evidence reference was not found.');end if;
 if v_e.case_id is distinct from v_t.case_id then return jsonb_build_object('ok',false,'code','evidence_case_mismatch','message','Evidence must already belong to the same case as the task.');end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref);
 if not found or v_actor.employment_status not in ('active','seconded') then return jsonb_build_object('ok',false,'code','invalid_actor','message','The recording officer must be active or seconded.');end if;
 if v_s.submitted_by_personnel_id<>v_actor.id and not exists(select 1 from game.case_assignments a where a.case_id=v_t.case_id and a.personnel_id=v_actor.id and a.status='active' and a.released_at is null) then return jsonb_build_object('ok',false,'code','case_access_denied','message','The officer must be the submitter or actively assigned to the case.');end if;
 if exists(select 1 from game.case_task_submission_reviews r where r.submission_id=v_s.id) then return jsonb_build_object('ok',false,'code','submission_already_reviewed','message','Evidence cannot be added after a submission has been reviewed.');end if;
 insert into game.case_task_submission_evidence(submission_id,evidence_id,reason,linked_by_personnel_id,linked_at_game_time,source_command_id)
 values(v_s.id,v_e.id,btrim(p_reason),v_actor.id,v_clock,p_source_command_id) on conflict(submission_id,evidence_id) do nothing;
 return jsonb_build_object('ok',true,'submission_ref',v_s.submission_ref,'evidence_ref',v_e.evidence_ref,'linked',true);
end $$;
create or replace function game.review_case_task_submission(p_submission_ref text,p_disposition text,p_reason text,p_actor_ref text,p_source_command_id uuid)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare v_s game.case_task_submissions%rowtype;v_t game.case_tasks%rowtype;v_actor game.police_personnel%rowtype;v_clock timestamptz;v_ref text;v_result jsonb;
begin
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before reviewing task submissions.');end if;
 if lower(coalesce(p_disposition,'')) not in ('accepted','returned') or nullif(btrim(p_reason),'') is null or char_length(p_reason)>4000 then return jsonb_build_object('ok',false,'code','invalid_review','message','Choose accepted or returned and provide a reason of up to 4,000 characters.');end if;
 select * into v_s from game.case_task_submissions where submission_ref=btrim(p_submission_ref);
 if not found then return jsonb_build_object('ok',false,'code','submission_not_found','message','Submission reference was not found.');end if;
 select * into v_t from game.case_tasks where id=v_s.task_id for update;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref);
 if not found or v_actor.employment_status not in ('active','seconded') then return jsonb_build_object('ok',false,'code','invalid_actor','message','The reviewing supervisor must be active or seconded.');end if;
 if not exists(select 1 from game.case_assignments a where a.case_id=v_t.case_id and a.personnel_id=v_actor.id and a.assignment_role='supervisor' and a.status='active' and a.released_at is null) then return jsonb_build_object('ok',false,'code','supervisor_access_denied','message','An active supervisor assignment to the case is required.');end if;
 if exists(select 1 from game.case_task_submission_reviews r where r.submission_id=v_s.id) then return jsonb_build_object('ok',false,'code','submission_already_reviewed','message','This submission already has a final review; the officer must submit a new version if returned.');end if;
 v_ref:='KWR-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
 insert into game.case_task_submission_reviews(review_ref,submission_id,disposition,reason,reviewed_by_personnel_id,reviewed_at_game_time,source_command_id)
 values(v_ref,v_s.id,lower(p_disposition),btrim(p_reason),v_actor.id,v_clock,p_source_command_id);
 insert into game.case_task_events(task_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id)
 values(v_t.id,'completion_'||lower(p_disposition),v_actor.id,v_clock,jsonb_build_object('submission_ref',v_s.submission_ref,'review_ref',v_ref,'reason',btrim(p_reason)),p_source_command_id);
 if lower(p_disposition)='accepted' then
  v_result:=game.update_case_task(v_t.task_ref,'completed',v_s.completion_note,null,v_actor.personnel_ref,p_source_command_id);
  if not coalesce((v_result->>'ok')::boolean,false) then raise exception 'Accepted submission could not complete task: %',v_result;end if;
 else
  v_result:=jsonb_build_object('ok',true,'task_ref',v_t.task_ref,'status',v_t.status,'submission_status','returned');
 end if;
 return jsonb_build_object('ok',true,'review_ref',v_ref,'submission_ref',v_s.submission_ref,'disposition',lower(p_disposition),'task_result',v_result);
end $$;
create or replace function game.get_case_task_submissions(p_task_ref text)
returns jsonb language plpgsql stable set search_path=pg_catalog,game as $$
declare v_task game.case_tasks%rowtype;v_rows jsonb;
begin
 select * into v_task from game.case_tasks where task_ref=btrim(p_task_ref);
 if not found then return jsonb_build_object('ok',false,'code','task_not_found','message','Task reference was not found.');end if;
 select coalesce(jsonb_agg(jsonb_build_object('submission_ref',s.submission_ref,'submitted_by',sp.personnel_ref,'submitted_at_game_time',s.submitted_at_game_time,'completion_note',s.completion_note,
 'evidence',(select coalesce(jsonb_agg(jsonb_build_object('evidence_ref',e.evidence_ref,'reason',l.reason) order by e.evidence_ref),'[]'::jsonb) from game.case_task_submission_evidence l join game.evidence_items e on e.id=l.evidence_id where l.submission_id=s.id),
 'reviews',(select coalesce(jsonb_agg(jsonb_build_object('review_ref',r.review_ref,'disposition',r.disposition,'reason',r.reason,'reviewed_by',rp.personnel_ref,'reviewed_at_game_time',r.reviewed_at_game_time) order by r.reviewed_at_game_time),'[]'::jsonb) from game.case_task_submission_reviews r join game.police_personnel rp on rp.id=r.reviewed_by_personnel_id where r.submission_id=s.id)
 ) order by s.submitted_at_game_time),'[]'::jsonb) into v_rows
 from game.case_task_submissions s join game.police_personnel sp on sp.id=s.submitted_by_personnel_id where s.task_id=v_task.id;
 return jsonb_build_object('ok',true,'task_ref',v_task.task_ref,'submissions',v_rows,'count',jsonb_array_length(v_rows));
end $$;
revoke all on function game.submit_case_task(text,text,text,uuid),game.link_case_task_submission_evidence(text,text,text,text,uuid),game.review_case_task_submission(text,text,text,text,uuid),game.get_case_task_submissions(text) from public,anon,authenticated;
grant execute on function game.submit_case_task(text,text,text,uuid),game.link_case_task_submission_evidence(text,text,text,text,uuid),game.review_case_task_submission(text,text,text,text,uuid),game.get_case_task_submissions(text) to service_role;
