create table game.case_activity_records(
 id uuid primary key default gen_random_uuid(),
 activity_ref text not null unique,
 case_id uuid not null references game.cases(id),
 activity_type text not null check(activity_type in ('surveillance','search','interview_activity','suspect_contact','arrest','warrant_execution','forensic_examination','scene_visit','document_review','digital_enquiry','phone_enquiry','briefing','liaison','intelligence_development','other')),
 method text not null check(char_length(btrim(method)) between 2 and 120),
 description text not null check(char_length(btrim(description)) between 3 and 8000),
 result text not null check(char_length(btrim(result)) between 2 and 8000),
 outcome text not null check(outcome in ('information_obtained','no_information','corroborated','contradicted','inconclusive','unable_to_complete','arrest_made','evidence_recovered','referral_required','other')),
 conducted_by_personnel_id uuid not null references game.police_personnel(id),
 recorded_by_personnel_id uuid not null references game.police_personnel(id),
 occurred_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now()
);
create table game.case_activity_links(
 id uuid primary key default gen_random_uuid(),
 activity_id uuid not null references game.case_activity_records(id),
 case_id uuid not null references game.cases(id),
 entity_type text not null check(entity_type in ('person','lead','enquiry','task','evidence','interview','witness_statement','incident')),
 entity_ref text not null,
 reason text not null check(char_length(btrim(reason)) between 2 and 1000),
 linked_by_personnel_id uuid not null references game.police_personnel(id),
 linked_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now(),
 unique(activity_id,entity_type,entity_ref)
);
create index case_activity_records_case_time_idx on game.case_activity_records(case_id,occurred_at_game_time desc);
create index case_activity_links_activity_idx on game.case_activity_links(activity_id);
create index case_activity_links_case_entity_idx on game.case_activity_links(case_id,entity_type,entity_ref);
alter table game.case_activity_records enable row level security;
alter table game.case_activity_links enable row level security;
revoke all on game.case_activity_records,game.case_activity_links from public,anon,authenticated;
grant select,insert on game.case_activity_records,game.case_activity_links to service_role;
create or replace function game.prevent_case_activity_mutation()
returns trigger language plpgsql set search_path=pg_catalog,game as $$ begin raise exception 'Case activity records and links are append-only';end $$;
create trigger case_activity_records_immutable before update or delete on game.case_activity_records for each row execute function game.prevent_case_activity_mutation();
create trigger case_activity_links_immutable before update or delete on game.case_activity_links for each row execute function game.prevent_case_activity_mutation();
create or replace function game.record_case_activity(p_case_ref text,p_type text,p_method text,p_description text,p_result text,p_outcome text,p_conductor_ref text,p_actor_ref text,p_command_id uuid)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare v_case game.cases%rowtype;v_conductor game.police_personnel%rowtype;v_actor game.police_personnel%rowtype;v_clock timestamptz;v_row game.case_activity_records%rowtype;
begin
 select * into v_case from game.cases where case_ref=btrim(p_case_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference not found.');end if;
 if v_case.status in ('closed','archived') then return jsonb_build_object('ok',false,'code','case_closed','message','Activity cannot be added to a closed case.');end if;
 select * into v_conductor from game.police_personnel where personnel_ref=btrim(p_conductor_ref) and employment_status in ('active','seconded');
 if not found then return jsonb_build_object('ok',false,'code','conductor_unavailable','message','The officer conducting the activity must be active or seconded.');end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found then return jsonb_build_object('ok',false,'code','actor_unavailable','message','The recording officer must be active or seconded.');end if;
 if not exists(select 1 from game.case_assignments a where a.case_id=v_case.id and a.personnel_id=v_conductor.id and a.status='active' and a.released_at is null)
 and v_case.lead_personnel_id is distinct from v_conductor.id then return jsonb_build_object('ok',false,'code','conductor_not_assigned','message','The conducting officer must be the case lead or actively assigned to the case.');end if;
 if not exists(select 1 from game.case_assignments a where a.case_id=v_case.id and a.personnel_id=v_actor.id and a.status='active' and a.released_at is null)
 and v_case.lead_personnel_id is distinct from v_actor.id then return jsonb_build_object('ok',false,'code','actor_not_assigned','message','The recording officer must be the case lead or actively assigned to the case.');end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before recording case activity.');end if;
 if p_type not in ('surveillance','search','interview_activity','suspect_contact','arrest','warrant_execution','forensic_examination','scene_visit','document_review','digital_enquiry','phone_enquiry','briefing','liaison','intelligence_development','other')
 or char_length(btrim(coalesce(p_method,''))) not between 2 and 120
 or char_length(btrim(coalesce(p_description,''))) not between 3 and 8000
 or char_length(btrim(coalesce(p_result,''))) not between 2 and 8000
 or p_outcome not in ('information_obtained','no_information','corroborated','contradicted','inconclusive','unable_to_complete','arrest_made','evidence_recovered','referral_required','other') then
 return jsonb_build_object('ok',false,'code','invalid_activity','message','Activity type, method, description, result or outcome is invalid.');end if;
 insert into game.case_activity_records(activity_ref,case_id,activity_type,method,description,result,outcome,conducted_by_personnel_id,recorded_by_personnel_id,occurred_at_game_time,source_command_id)
 values('KWA-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),v_case.id,p_type,btrim(p_method),btrim(p_description),btrim(p_result),p_outcome,v_conductor.id,v_actor.id,v_clock,p_command_id) returning * into v_row;
 return jsonb_build_object('ok',true,'activity_ref',v_row.activity_ref,'case_ref',v_case.case_ref,'activity_type',v_row.activity_type,'outcome',v_row.outcome,'occurred_at_game_time',v_clock,'message','Case activity recorded.');
end $$;
create or replace function game.link_case_activity(p_activity_ref text,p_entity_type text,p_entity_ref text,p_reason text,p_actor_ref text,p_command_id uuid)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare v_a game.case_activity_records%rowtype;v_actor game.police_personnel%rowtype;v_clock timestamptz;v_ok boolean:=false;
begin
 select * into v_a from game.case_activity_records where activity_ref=btrim(p_activity_ref);
 if not found then return jsonb_build_object('ok',false,'code','activity_not_found','message','Activity reference not found.');end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found then return jsonb_build_object('ok',false,'code','actor_unavailable','message','The linking officer must be active or seconded.');end if;
 if not exists(select 1 from game.case_assignments a where a.case_id=v_a.case_id and a.personnel_id=v_actor.id and a.status='active' and a.released_at is null) and not exists(select 1 from game.cases c where c.id=v_a.case_id and c.lead_personnel_id=v_actor.id) then return jsonb_build_object('ok',false,'code','case_access_denied','message','The linking officer must be assigned to the case.');end if;
 if char_length(btrim(coalesce(p_reason,''))) not between 2 and 1000 then return jsonb_build_object('ok',false,'code','invalid_reason','message','A link reason is required.');end if;
 case p_entity_type
 when 'person' then select exists(select 1 from game.case_persons cp join game.persons p on p.id=cp.person_id where cp.case_id=v_a.case_id and p.person_ref=btrim(p_entity_ref)) into v_ok;
 when 'lead' then select exists(select 1 from game.case_leads l where l.case_id=v_a.case_id and l.lead_ref=btrim(p_entity_ref)) into v_ok;
 when 'enquiry' then select exists(select 1 from game.case_enquiries e where e.case_id=v_a.case_id and e.enquiry_ref=btrim(p_entity_ref)) into v_ok;
 when 'task' then select exists(select 1 from game.case_tasks t where t.case_id=v_a.case_id and t.task_ref=btrim(p_entity_ref)) into v_ok;
 when 'evidence' then select exists(select 1 from game.evidence_items e where e.case_id=v_a.case_id and e.evidence_ref=btrim(p_entity_ref)) into v_ok;
 when 'interview' then select exists(select 1 from game.case_interviews i where i.case_id=v_a.case_id and i.interview_ref=btrim(p_entity_ref)) into v_ok;
 when 'witness_statement' then select exists(select 1 from game.case_witness_statements s where s.case_id=v_a.case_id and s.statement_ref=btrim(p_entity_ref)) into v_ok;
 when 'incident' then select exists(select 1 from game.case_incidents ci join game.incidents i on i.id=ci.incident_id where ci.case_id=v_a.case_id and i.incident_ref=btrim(p_entity_ref)) into v_ok;
 else return jsonb_build_object('ok',false,'code','invalid_entity_type','message','Unsupported linked entity type.');end case;
 if not v_ok then return jsonb_build_object('ok',false,'code','entity_not_in_case','message','The referenced entity does not exist in this case.');end if;
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before linking case activity.');end if;
 insert into game.case_activity_links(activity_id,case_id,entity_type,entity_ref,reason,linked_by_personnel_id,linked_at_game_time,source_command_id)
 values(v_a.id,v_a.case_id,p_entity_type,btrim(p_entity_ref),btrim(p_reason),v_actor.id,v_clock,p_command_id) on conflict(activity_id,entity_type,entity_ref) do nothing;
 return jsonb_build_object('ok',true,'activity_ref',v_a.activity_ref,'entity_type',p_entity_type,'entity_ref',p_entity_ref,'linked',true);
end $$;
create or replace function game.get_case_activity(p_case_ref text,p_limit integer default 200)
returns jsonb language plpgsql stable set search_path=pg_catalog,game as $$
declare v_case game.cases%rowtype;v_rows jsonb;
begin
 select * into v_case from game.cases where case_ref=btrim(p_case_ref);
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference not found.');end if;
 if p_limit not between 1 and 500 then return jsonb_build_object('ok',false,'code','invalid_limit','message','Limit must be between 1 and 500.');end if;
 select coalesce(jsonb_agg(x.item order by x.at_time desc),'[]'::jsonb) into v_rows from (
  select a.occurred_at_game_time at_time,jsonb_build_object('activity_ref',a.activity_ref,'activity_type',a.activity_type,'method',a.method,'description',a.description,'result',a.result,'outcome',a.outcome,'conducted_by',cp.personnel_ref,'recorded_by',rp.personnel_ref,'occurred_at_game_time',a.occurred_at_game_time,
   'links',(select coalesce(jsonb_agg(jsonb_build_object('entity_type',l.entity_type,'entity_ref',l.entity_ref,'reason',l.reason,'linked_by',lp.personnel_ref,'linked_at_game_time',l.linked_at_game_time) order by l.created_at),'[]'::jsonb) from game.case_activity_links l join game.police_personnel lp on lp.id=l.linked_by_personnel_id where l.activity_id=a.id)) item
  from game.case_activity_records a join game.police_personnel cp on cp.id=a.conducted_by_personnel_id join game.police_personnel rp on rp.id=a.recorded_by_personnel_id where a.case_id=v_case.id order by a.occurred_at_game_time desc limit p_limit
 ) x;
 return jsonb_build_object('ok',true,'case_ref',v_case.case_ref,'activities',v_rows,'count',jsonb_array_length(v_rows));
end $$;
revoke all on function game.record_case_activity(text,text,text,text,text,text,text,text,uuid),game.link_case_activity(text,text,text,text,text,uuid),game.get_case_activity(text,integer) from public,anon,authenticated;
grant execute on function game.record_case_activity(text,text,text,text,text,text,text,text,uuid),game.link_case_activity(text,text,text,text,text,uuid),game.get_case_activity(text,integer) to service_role;
