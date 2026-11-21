create table game.case_suspect_interview_records (
 id uuid primary key default gen_random_uuid(),
 interview_id uuid not null unique references game.case_interviews(id) on delete restrict,
 case_id uuid not null references game.cases(id) on delete restrict,
 suspect_person_id uuid not null references game.persons(id) on delete restrict,
 recorded_by_personnel_id uuid not null references game.police_personnel(id) on delete restrict,
 recorded_at_game_time timestamptz not null,
 reason text not null check(length(btrim(reason)) between 3 and 2000),
 source_command_id uuid not null references game.game_commands(id) on delete restrict,
 created_at timestamptz not null default now()
);
create table game.case_suspect_interview_assessments (
 id uuid primary key default gen_random_uuid(),
 interview_id uuid not null references game.case_interviews(id) on delete restrict,
 turn_id uuid not null references game.case_interview_turns(id) on delete restrict,
 case_id uuid not null references game.cases(id) on delete restrict,
 response_assessment text not null check(response_assessment in ('admission','denial','no_comment','qualified_response','correction','other')),
 assessment_reason text not null check(length(btrim(assessment_reason)) between 3 and 2000),
 assessed_by_personnel_id uuid not null references game.police_personnel(id) on delete restrict,
 assessed_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id) on delete restrict,
 created_at timestamptz not null default now()
);
create index case_suspect_interview_assessments_interview_idx on game.case_suspect_interview_assessments(interview_id,assessed_at_game_time);
create index case_suspect_interview_assessments_turn_idx on game.case_suspect_interview_assessments(turn_id,created_at);
alter table game.case_suspect_interview_records enable row level security;
alter table game.case_suspect_interview_assessments enable row level security;

create or replace function game.reject_suspect_interview_history_mutation()
returns trigger language plpgsql set search_path to 'pg_catalog','game' as $$
begin raise exception 'Suspect interview history is append-only'; end $$;
create trigger case_suspect_interview_records_immutable before update or delete on game.case_suspect_interview_records for each row execute function game.reject_suspect_interview_history_mutation();
create trigger case_suspect_interview_assessments_immutable before update or delete on game.case_suspect_interview_assessments for each row execute function game.reject_suspect_interview_history_mutation();

create or replace function game.record_case_suspect_interview(p_interview_ref text,p_reason text,p_actor_ref text,p_command_id uuid)
returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare v_interview game.case_interviews%rowtype; v_actor game.police_personnel%rowtype; v_clock timestamptz; v_person game.persons%rowtype; v_result record;
begin
 select * into v_interview from game.case_interviews where interview_ref=btrim(p_interview_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','interview_not_found','message','Interview reference not found.'); end if;
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
 return jsonb_build_object('ok',true,'interview_ref',v_interview.interview_ref,'suspect',v_person.person_ref,'case_ref',(select case_ref from game.cases where id=v_interview.case_id),'recorded_at',v_clock,'message','Suspect interview classification recorded. This is an investigative status, not a determination of guilt.');
end $$;

create or replace function game.assess_case_suspect_interview_turn(p_interview_ref text,p_turn_ref text,p_assessment text,p_reason text,p_actor_ref text,p_command_id uuid)
returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare v_interview game.case_interviews%rowtype; v_turn game.case_interview_turns%rowtype; v_actor game.police_personnel%rowtype; v_clock timestamptz; v_assessment game.case_suspect_interview_assessments%rowtype;
begin
 select * into v_interview from game.case_interviews where interview_ref=btrim(p_interview_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','interview_not_found','message','Interview reference not found.'); end if;
 if not exists(select 1 from game.case_suspect_interview_records where interview_id=v_interview.id) then return jsonb_build_object('ok',false,'code','not_suspect_interview','message','Classify the interview as a suspect interview first.'); end if;
 select * into v_turn from game.case_interview_turns where turn_ref=btrim(p_turn_ref) and interview_id=v_interview.id;
 if not found then return jsonb_build_object('ok',false,'code','turn_not_found','message','Question-and-answer turn does not belong to this suspect interview.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found or v_actor.id<>v_interview.interviewer_personnel_id then return jsonb_build_object('ok',false,'code','interviewer_mismatch','message','Only the recorded interviewer may assess suspect interview responses.'); end if;
 if p_assessment not in ('admission','denial','no_comment','qualified_response','correction','other') or length(btrim(coalesce(p_reason,''))) not between 3 and 2000 then return jsonb_build_object('ok',false,'code','invalid_assessment','message','Choose a supported response classification and provide a reason.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before assessing a suspect response.'); end if;
 insert into game.case_suspect_interview_assessments(interview_id,turn_id,case_id,response_assessment,assessment_reason,assessed_by_personnel_id,assessed_at_game_time,source_command_id)
 values(v_interview.id,v_turn.id,v_interview.case_id,p_assessment,btrim(p_reason),v_actor.id,v_clock,p_command_id) returning * into v_assessment;
 return jsonb_build_object('ok',true,'interview_ref',v_interview.interview_ref,'turn_ref',v_turn.turn_ref,'assessment',v_assessment.response_assessment,'assessed_at',v_clock,'message','Suspect response assessment appended to the interview record.');
end $$;

create or replace function game.get_case_suspect_interview_review(p_interview_ref text)
returns jsonb language plpgsql stable set search_path to 'pg_catalog','game' as $$
declare v_interview game.case_interviews%rowtype; v_record game.case_suspect_interview_records%rowtype; v_turns jsonb;
begin
 select * into v_interview from game.case_interviews where interview_ref=btrim(p_interview_ref);
 if not found then return jsonb_build_object('ok',false,'code','interview_not_found','message','Interview reference not found.'); end if;
 select * into v_record from game.case_suspect_interview_records where interview_id=v_interview.id;
 if not found then return jsonb_build_object('ok',false,'code','not_suspect_interview','message','This interview has not been classified as a suspect interview.'); end if;
 select coalesce(jsonb_agg(jsonb_build_object('turn_ref',t.turn_ref,'turn_number',t.turn_number,'question',t.question_text,'answer',t.answer_text,'assessments',coalesce((select jsonb_agg(jsonb_build_object('classification',a.response_assessment,'reason',a.assessment_reason,'assessed_by',pp.personnel_ref,'game_time',a.assessed_at_game_time) order by a.assessed_at_game_time,a.created_at) from game.case_suspect_interview_assessments a join game.police_personnel pp on pp.id=a.assessed_by_personnel_id where a.turn_id=t.id),'[]'::jsonb)) order by t.turn_number),'[]'::jsonb)
 into v_turns from game.case_interview_turns t where t.interview_id=v_interview.id;
 return jsonb_build_object('ok',true,'case_id',v_interview.case_id,'interview_ref',v_interview.interview_ref,'suspect_reason',v_record.reason,'classified_at',v_record.recorded_at_game_time,'turn_count',jsonb_array_length(v_turns),'turns',v_turns);
end $$;

revoke all on game.case_suspect_interview_records,game.case_suspect_interview_assessments from public,anon,authenticated;
grant select,insert on game.case_suspect_interview_records,game.case_suspect_interview_assessments to service_role;
revoke all on function game.reject_suspect_interview_history_mutation(),game.record_case_suspect_interview(text,text,text,uuid),game.assess_case_suspect_interview_turn(text,text,text,text,text,uuid),game.get_case_suspect_interview_review(text) from public,anon,authenticated;
grant execute on function game.record_case_suspect_interview(text,text,text,uuid),game.assess_case_suspect_interview_turn(text,text,text,text,text,uuid),game.get_case_suspect_interview_review(text) to service_role;
