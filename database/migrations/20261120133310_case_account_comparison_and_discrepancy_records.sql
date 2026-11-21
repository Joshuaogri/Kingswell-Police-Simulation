create sequence game.case_account_comparison_ref_seq;

create table game.case_account_comparisons (
 id uuid primary key default gen_random_uuid(),
 comparison_ref text not null unique default ('KNG-CMP-'||lpad(nextval('game.case_account_comparison_ref_seq')::text,7,'0')),
 case_id uuid not null references game.cases(id) on delete restrict,
 first_source_type text not null check(first_source_type in ('witness_statement','interview_turn')),
 first_source_ref text not null,
 first_statement_id uuid references game.case_witness_statements(id) on delete restrict,
 first_turn_id uuid references game.case_interview_turns(id) on delete restrict,
 first_person_id uuid not null references game.persons(id) on delete restrict,
 second_source_type text not null check(second_source_type in ('witness_statement','interview_turn')),
 second_source_ref text not null,
 second_statement_id uuid references game.case_witness_statements(id) on delete restrict,
 second_turn_id uuid references game.case_interview_turns(id) on delete restrict,
 second_person_id uuid not null references game.persons(id) on delete restrict,
 discrepancy_category text not null check(discrepancy_category in ('timeline_conflict','location_conflict','sequence_conflict','action_conflict','identity_conflict','description_conflict','other')),
 discrepancy_description text not null check(length(btrim(discrepancy_description)) between 3 and 4000),
 recorded_by_personnel_id uuid not null references game.police_personnel(id) on delete restrict,
 recorded_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id) on delete restrict,
 created_at timestamptz not null default now(),
 check(first_source_ref<>second_source_ref),
 check((first_source_type='witness_statement' and first_statement_id is not null and first_turn_id is null) or (first_source_type='interview_turn' and first_turn_id is not null and first_statement_id is null)),
 check((second_source_type='witness_statement' and second_statement_id is not null and second_turn_id is null) or (second_source_type='interview_turn' and second_turn_id is not null and second_statement_id is null))
);

create table game.case_account_comparison_assessments (
 id uuid primary key default gen_random_uuid(),
 comparison_id uuid not null references game.case_account_comparisons(id) on delete restrict,
 case_id uuid not null references game.cases(id) on delete restrict,
 disposition text not null check(disposition in ('unresolved','explained','partially_explained','not_a_conflict')),
 assessment text not null check(length(btrim(assessment)) between 3 and 4000),
 assessed_by_personnel_id uuid not null references game.police_personnel(id) on delete restrict,
 assessed_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id) on delete restrict,
 created_at timestamptz not null default now()
);

create table game.case_account_comparison_evidence_links (
 id uuid primary key default gen_random_uuid(),
 comparison_id uuid not null references game.case_account_comparisons(id) on delete restrict,
 case_id uuid not null references game.cases(id) on delete restrict,
 evidence_id uuid not null references game.evidence_items(id) on delete restrict,
 reason text not null check(length(btrim(reason)) between 3 and 2000),
 linked_by_personnel_id uuid not null references game.police_personnel(id) on delete restrict,
 linked_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id) on delete restrict,
 created_at timestamptz not null default now(),
 unique(comparison_id,evidence_id)
);

create index case_account_comparisons_case_time_idx on game.case_account_comparisons(case_id,recorded_at_game_time);
create index case_account_comparisons_first_statement_idx on game.case_account_comparisons(first_statement_id);
create index case_account_comparisons_second_statement_idx on game.case_account_comparisons(second_statement_id);
create index case_account_comparisons_first_turn_idx on game.case_account_comparisons(first_turn_id);
create index case_account_comparisons_second_turn_idx on game.case_account_comparisons(second_turn_id);
create index case_account_comparison_assessments_history_idx on game.case_account_comparison_assessments(comparison_id,assessed_at_game_time,created_at);
create index case_account_comparison_evidence_links_case_idx on game.case_account_comparison_evidence_links(case_id,evidence_id);

alter table game.case_account_comparisons enable row level security;
alter table game.case_account_comparison_assessments enable row level security;
alter table game.case_account_comparison_evidence_links enable row level security;

create or replace function game.reject_case_account_comparison_mutation()
returns trigger language plpgsql set search_path to 'pg_catalog','game' as $$
begin raise exception 'Case account comparison history is append-only'; end $$;
create trigger case_account_comparisons_immutable before update or delete on game.case_account_comparisons for each row execute function game.reject_case_account_comparison_mutation();
create trigger case_account_comparison_assessments_immutable before update or delete on game.case_account_comparison_assessments for each row execute function game.reject_case_account_comparison_mutation();
create trigger case_account_comparison_evidence_links_immutable before update or delete on game.case_account_comparison_evidence_links for each row execute function game.reject_case_account_comparison_mutation();

create or replace function game.record_case_account_comparison(
 p_case_ref text,p_first_type text,p_first_ref text,p_second_type text,p_second_ref text,p_category text,p_description text,p_actor_ref text,p_command_id uuid
) returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare v_case game.cases%rowtype; v_actor game.police_personnel%rowtype; v_clock timestamptz; v_first_person uuid; v_second_person uuid;
 v_first_statement uuid;v_second_statement uuid;v_first_turn uuid;v_second_turn uuid;v_comparison game.case_account_comparisons%rowtype;
begin
 select * into v_case from game.cases where case_ref=btrim(p_case_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference not found.'); end if;
 if v_case.status='closed' then return jsonb_build_object('ok',false,'code','case_closed','message','A closed case cannot receive a new account comparison.'); end if;
 if p_first_type not in ('witness_statement','interview_turn') or p_second_type not in ('witness_statement','interview_turn') or btrim(coalesce(p_first_ref,''))=btrim(coalesce(p_second_ref,'')) then
  return jsonb_build_object('ok',false,'code','invalid_sources','message','Select two different existing witness_statement or interview_turn sources.');
 end if;
 if p_first_type='witness_statement' then select id,witness_person_id into v_first_statement,v_first_person from game.case_witness_statements where statement_ref=btrim(p_first_ref) and case_id=v_case.id;
 else select t.id,i.interviewee_person_id into v_first_turn,v_first_person from game.case_interview_turns t join game.case_interviews i on i.id=t.interview_id where t.turn_ref=btrim(p_first_ref) and t.case_id=v_case.id; end if;
 if v_first_person is null then return jsonb_build_object('ok',false,'code','first_source_not_found','message','The first source does not resolve to an existing account in this case.'); end if;
 if p_second_type='witness_statement' then select id,witness_person_id into v_second_statement,v_second_person from game.case_witness_statements where statement_ref=btrim(p_second_ref) and case_id=v_case.id;
 else select t.id,i.interviewee_person_id into v_second_turn,v_second_person from game.case_interview_turns t join game.case_interviews i on i.id=t.interview_id where t.turn_ref=btrim(p_second_ref) and t.case_id=v_case.id; end if;
 if v_second_person is null then return jsonb_build_object('ok',false,'code','second_source_not_found','message','The second source does not resolve to an existing account in this case.'); end if;
 if p_category not in ('timeline_conflict','location_conflict','sequence_conflict','action_conflict','identity_conflict','description_conflict','other') or length(btrim(coalesce(p_description,''))) not between 3 and 4000 then return jsonb_build_object('ok',false,'code','invalid_comparison','message','Choose a supported discrepancy category and provide a description.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found then return jsonb_build_object('ok',false,'code','actor_unavailable','message','The recording officer must be active or seconded.'); end if;
 if v_case.lead_personnel_id is distinct from v_actor.id and not exists(select 1 from game.case_assignments a where a.case_id=v_case.id and a.personnel_id=v_actor.id and a.status='active') then return jsonb_build_object('ok',false,'code','not_assigned','message','The officer must be the case lead or hold an active assignment to this case.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before recording account comparisons.'); end if;
 insert into game.case_account_comparisons(case_id,first_source_type,first_source_ref,first_statement_id,first_turn_id,first_person_id,second_source_type,second_source_ref,second_statement_id,second_turn_id,second_person_id,discrepancy_category,discrepancy_description,recorded_by_personnel_id,recorded_at_game_time,source_command_id)
 values(v_case.id,p_first_type,btrim(p_first_ref),v_first_statement,v_first_turn,v_first_person,p_second_type,btrim(p_second_ref),v_second_statement,v_second_turn,v_second_person,p_category,btrim(p_description),v_actor.id,v_clock,p_command_id) returning * into v_comparison;
 return jsonb_build_object('ok',true,'comparison_ref',v_comparison.comparison_ref,'case_ref',v_case.case_ref,'first_source',p_first_ref,'second_source',p_second_ref,'category',p_category,'recorded_at',v_clock,'message','Account discrepancy recorded for investigation. This record does not determine which account is accurate.');
end $$;

create or replace function game.assess_case_account_comparison(p_comparison_ref text,p_disposition text,p_assessment text,p_actor_ref text,p_command_id uuid)
returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare v_comparison game.case_account_comparisons%rowtype;v_case game.cases%rowtype;v_actor game.police_personnel%rowtype;v_clock timestamptz;v_row game.case_account_comparison_assessments%rowtype;
begin
 select * into v_comparison from game.case_account_comparisons where comparison_ref=btrim(p_comparison_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','comparison_not_found','message','Comparison reference not found.'); end if;
 select * into v_case from game.cases where id=v_comparison.case_id;
 if v_case.status='closed' then return jsonb_build_object('ok',false,'code','case_closed','message','A closed case cannot receive a new comparison assessment.'); end if;
 if p_disposition not in ('unresolved','explained','partially_explained','not_a_conflict') or length(btrim(coalesce(p_assessment,''))) not between 3 and 4000 then return jsonb_build_object('ok',false,'code','invalid_assessment','message','Choose a supported disposition and provide the assessment basis.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found or (v_case.lead_personnel_id is distinct from v_actor.id and not exists(select 1 from game.case_assignments a where a.case_id=v_case.id and a.personnel_id=v_actor.id and a.status='active')) then return jsonb_build_object('ok',false,'code','not_assigned','message','The officer must be the case lead or hold an active assignment to this case.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before assessing a comparison.'); end if;
 insert into game.case_account_comparison_assessments(comparison_id,case_id,disposition,assessment,assessed_by_personnel_id,assessed_at_game_time,source_command_id)
 values(v_comparison.id,v_comparison.case_id,p_disposition,btrim(p_assessment),v_actor.id,v_clock,p_command_id) returning * into v_row;
 return jsonb_build_object('ok',true,'comparison_ref',v_comparison.comparison_ref,'disposition',v_row.disposition,'assessed_at',v_clock,'message','Comparison assessment appended. Earlier assessments remain in the record.');
end $$;

create or replace function game.link_case_account_comparison_evidence(p_comparison_ref text,p_evidence_ref text,p_reason text,p_actor_ref text,p_command_id uuid)
returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare v_comparison game.case_account_comparisons%rowtype;v_case game.cases%rowtype;v_actor game.police_personnel%rowtype;v_evidence game.evidence_items%rowtype;v_clock timestamptz;v_link game.case_account_comparison_evidence_links%rowtype;
begin
 select * into v_comparison from game.case_account_comparisons where comparison_ref=btrim(p_comparison_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','comparison_not_found','message','Comparison reference not found.'); end if;
 select * into v_case from game.cases where id=v_comparison.case_id;
 if v_case.status='closed' then return jsonb_build_object('ok',false,'code','case_closed','message','A closed case cannot receive a new evidence link.'); end if;
 select * into v_evidence from game.evidence_items where evidence_ref=btrim(p_evidence_ref) and (case_id is null or case_id=v_case.id);
 if not found then return jsonb_build_object('ok',false,'code','evidence_not_found','message','Evidence reference not found or belongs to another case.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found or (v_case.lead_personnel_id is distinct from v_actor.id and not exists(select 1 from game.case_assignments a where a.case_id=v_case.id and a.personnel_id=v_actor.id and a.status='active')) then return jsonb_build_object('ok',false,'code','not_assigned','message','The officer must be the case lead or hold an active assignment to this case.'); end if;
 if length(btrim(coalesce(p_reason,''))) not between 3 and 2000 then return jsonb_build_object('ok',false,'code','invalid_reason','message','A reason between 3 and 2000 characters is required.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before linking evidence.'); end if;
 select * into v_link from game.case_account_comparison_evidence_links where comparison_id=v_comparison.id and evidence_id=v_evidence.id;
 if found then return jsonb_build_object('ok',true,'duplicate',true,'comparison_ref',v_comparison.comparison_ref,'evidence_ref',p_evidence_ref,'message','Evidence is already linked to this comparison.'); end if;
 insert into game.case_account_comparison_evidence_links(comparison_id,case_id,evidence_id,reason,linked_by_personnel_id,linked_at_game_time,source_command_id)
 values(v_comparison.id,v_case.id,v_evidence.id,btrim(p_reason),v_actor.id,v_clock,p_command_id) returning * into v_link;
 return jsonb_build_object('ok',true,'comparison_ref',v_comparison.comparison_ref,'evidence_ref',p_evidence_ref,'linked_at',v_clock,'message','Existing case evidence linked to the account comparison.');
end $$;

create or replace function game.get_case_account_comparisons(p_case_ref text,p_comparison_ref text default null)
returns jsonb language plpgsql stable set search_path to 'pg_catalog','game' as $$
declare v_case game.cases%rowtype;v_result jsonb;
begin
 select * into v_case from game.cases where case_ref=btrim(p_case_ref);
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference not found.'); end if;
 if p_comparison_ref is not null and not exists(select 1 from game.case_account_comparisons where comparison_ref=btrim(p_comparison_ref) and case_id=v_case.id) then return jsonb_build_object('ok',false,'code','comparison_not_found','message','Comparison does not belong to this case.'); end if;
 select coalesce(jsonb_agg(jsonb_build_object(
  'comparison_ref',c.comparison_ref,'category',c.discrepancy_category,'description',c.discrepancy_description,'recorded_at',c.recorded_at_game_time,'recorded_by',pp.personnel_ref,
  'first_source',jsonb_build_object('type',c.first_source_type,'ref',c.first_source_ref,'person',p1.person_ref,'text',case when c.first_source_type='witness_statement' then s1.statement_text else t1.answer_text end,'question',t1.question_text),
  'second_source',jsonb_build_object('type',c.second_source_type,'ref',c.second_source_ref,'person',p2.person_ref,'text',case when c.second_source_type='witness_statement' then s2.statement_text else t2.answer_text end,'question',t2.question_text),
  'latest_assessment',(select jsonb_build_object('disposition',a.disposition,'assessment',a.assessment,'assessed_by',ap.personnel_ref,'assessed_at',a.assessed_at_game_time) from game.case_account_comparison_assessments a join game.police_personnel ap on ap.id=a.assessed_by_personnel_id where a.comparison_id=c.id order by a.assessed_at_game_time desc,a.created_at desc limit 1),
  'assessment_history',(select coalesce(jsonb_agg(jsonb_build_object('disposition',a.disposition,'assessment',a.assessment,'assessed_by',ap.personnel_ref,'assessed_at',a.assessed_at_game_time) order by a.assessed_at_game_time,a.created_at),'[]'::jsonb) from game.case_account_comparison_assessments a join game.police_personnel ap on ap.id=a.assessed_by_personnel_id where a.comparison_id=c.id),
  'linked_evidence',(select coalesce(jsonb_agg(jsonb_build_object('evidence_ref',e.evidence_ref,'reason',l.reason,'linked_by',lp.personnel_ref,'linked_at',l.linked_at_game_time) order by l.created_at),'[]'::jsonb) from game.case_account_comparison_evidence_links l join game.evidence_items e on e.id=l.evidence_id join game.police_personnel lp on lp.id=l.linked_by_personnel_id where l.comparison_id=c.id)
 ) order by c.recorded_at_game_time,c.created_at),'[]'::jsonb)
 into v_result
 from game.case_account_comparisons c join game.persons p1 on p1.id=c.first_person_id join game.persons p2 on p2.id=c.second_person_id join game.police_personnel pp on pp.id=c.recorded_by_personnel_id
 left join game.case_witness_statements s1 on s1.id=c.first_statement_id left join game.case_interview_turns t1 on t1.id=c.first_turn_id
 left join game.case_witness_statements s2 on s2.id=c.second_statement_id left join game.case_interview_turns t2 on t2.id=c.second_turn_id
 where c.case_id=v_case.id and (p_comparison_ref is null or c.comparison_ref=btrim(p_comparison_ref));
 return jsonb_build_object('ok',true,'case_ref',v_case.case_ref,'comparison_count',jsonb_array_length(v_result),'comparisons',v_result);
end $$;

revoke all on game.case_account_comparisons,game.case_account_comparison_assessments,game.case_account_comparison_evidence_links from public,anon,authenticated;
grant select,insert on game.case_account_comparisons,game.case_account_comparison_assessments,game.case_account_comparison_evidence_links to service_role;
revoke all on function game.reject_case_account_comparison_mutation(),game.record_case_account_comparison(text,text,text,text,text,text,text,text,uuid),game.assess_case_account_comparison(text,text,text,text,uuid),game.link_case_account_comparison_evidence(text,text,text,text,uuid),game.get_case_account_comparisons(text,text) from public,anon,authenticated;
grant execute on function game.record_case_account_comparison(text,text,text,text,text,text,text,text,uuid),game.assess_case_account_comparison(text,text,text,text,uuid),game.link_case_account_comparison_evidence(text,text,text,text,uuid),game.get_case_account_comparisons(text,text) to service_role;
