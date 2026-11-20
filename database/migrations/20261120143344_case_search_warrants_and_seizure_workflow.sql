-- Kingswell fictional search warrant, premises search, property recovery and seizure workflow.
create sequence game.search_warrant_ref_seq;
create sequence game.search_operation_ref_seq;
create sequence game.search_premises_ref_seq;
create sequence game.search_log_ref_seq;
create sequence game.recovered_property_ref_seq;
create sequence game.seizure_ref_seq;

create table game.recovered_property(
  id uuid not null default gen_random_uuid(),
  recovery_ref text not null default ('KWRP-'::text || lpad((nextval('game.recovered_property_ref_seq'::regclass))::text, 7, '0'::text)),
  operation_id uuid not null,
  premises_id uuid not null,
  found_by_personnel_id uuid not null,
  item_category text not null,
  item_description text not null,
  found_location text not null,
  condition_on_recovery text not null,
  recovered_at_game_time timestamp with time zone not null,
  disposition text not null default 'retained'::text,
  source_command_id uuid not null,
  created_at timestamp with time zone not null default now()
);

create table game.search_logs(
  id uuid not null default gen_random_uuid(),
  log_ref text not null default ('KWSL-'::text || lpad((nextval('game.search_log_ref_seq'::regclass))::text, 7, '0'::text)),
  operation_id uuid not null,
  premises_id uuid not null,
  event_type text not null,
  location_within_premises text not null,
  narrative text not null,
  recorded_by_personnel_id uuid not null,
  recorded_at_game_time timestamp with time zone not null,
  source_command_id uuid not null,
  created_at timestamp with time zone not null default now()
);

create table game.search_operation_events(
  id uuid not null default gen_random_uuid(),
  operation_id uuid not null,
  event_type text not null,
  actor_personnel_id uuid not null,
  event_at_game_time timestamp with time zone not null,
  event_data jsonb not null default '{}'::jsonb,
  source_command_id uuid not null,
  created_at timestamp with time zone not null default now()
);

create table game.search_operation_team(
  id uuid not null default gen_random_uuid(),
  operation_id uuid not null,
  personnel_id uuid not null,
  team_role text not null,
  assigned_by_personnel_id uuid not null,
  assigned_at_game_time timestamp with time zone not null,
  source_command_id uuid not null,
  created_at timestamp with time zone not null default now()
);

create table game.search_operations(
  id uuid not null default gen_random_uuid(),
  operation_ref text not null default ('KWSR-'::text || lpad((nextval('game.search_operation_ref_seq'::regclass))::text, 7, '0'::text)),
  case_id uuid not null,
  warrant_id uuid not null,
  method text not null,
  objective text not null,
  planned_by_personnel_id uuid not null,
  status text not null default 'planned'::text,
  created_at_game_time timestamp with time zone not null,
  started_at_game_time timestamp with time zone,
  closed_at_game_time timestamp with time zone,
  closure_reason text,
  source_command_id uuid not null,
  created_at timestamp with time zone not null default now()
);

create table game.search_premises(
  id uuid not null default gen_random_uuid(),
  premises_ref text not null default ('KWSP-'::text || lpad((nextval('game.search_premises_ref_seq'::regclass))::text, 7, '0'::text)),
  operation_id uuid not null,
  property_id uuid not null,
  premises_description text not null,
  status text not null default 'planned'::text,
  searched_at_game_time timestamp with time zone,
  outcome_summary text,
  added_by_personnel_id uuid not null,
  source_command_id uuid not null,
  created_at timestamp with time zone not null default now()
);

create table game.search_seizures(
  id uuid not null default gen_random_uuid(),
  seizure_ref text not null default ('KWSE-'::text || lpad((nextval('game.seizure_ref_seq'::regclass))::text, 7, '0'::text)),
  recovery_id uuid not null,
  operation_id uuid not null,
  premises_id uuid not null,
  evidence_id uuid not null,
  seized_by_personnel_id uuid not null,
  seized_at_game_time timestamp with time zone not null,
  seizure_reason text not null,
  packaging_description text not null,
  seal_identifier text not null,
  storage_location text not null,
  source_command_id uuid not null,
  created_at timestamp with time zone not null default now()
);

create table game.search_warrants(
  id uuid not null default gen_random_uuid(),
  warrant_ref text not null default ('KWW-'::text || lpad((nextval('game.search_warrant_ref_seq'::regclass))::text, 7, '0'::text)),
  case_id uuid not null,
  issuing_authority text not null,
  scope_description text not null,
  issued_by_personnel_id uuid not null,
  issued_at_game_time timestamp with time zone not null,
  valid_until_game_time timestamp with time zone not null,
  status text not null default 'issued'::text,
  source_command_id uuid not null,
  created_at timestamp with time zone not null default now()
);

alter table game.recovered_property add constraint recovered_property_disposition_check CHECK ((disposition = ANY (ARRAY['retained'::text, 'seized'::text, 'left_in_place'::text, 'returned'::text, 'released'::text])));
alter table game.recovered_property add constraint recovered_property_found_by_personnel_id_fkey FOREIGN KEY (found_by_personnel_id) REFERENCES game.police_personnel(id);
alter table game.recovered_property add constraint recovered_property_operation_id_fkey FOREIGN KEY (operation_id) REFERENCES game.search_operations(id);
alter table game.recovered_property add constraint recovered_property_pkey PRIMARY KEY (id);
alter table game.recovered_property add constraint recovered_property_premises_id_fkey FOREIGN KEY (premises_id) REFERENCES game.search_premises(id);
alter table game.recovered_property add constraint recovered_property_recovery_ref_key UNIQUE (recovery_ref);
alter table game.recovered_property add constraint recovered_property_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id);
alter table game.search_logs add constraint search_logs_event_type_check CHECK ((event_type = ANY (ARRAY['arrival'::text, 'entry'::text, 'area_examined'::text, 'item_found'::text, 'person_present'::text, 'damage_or_condition'::text, 'departure'::text, 'other'::text])));
alter table game.search_logs add constraint search_logs_log_ref_key UNIQUE (log_ref);
alter table game.search_logs add constraint search_logs_operation_id_fkey FOREIGN KEY (operation_id) REFERENCES game.search_operations(id);
alter table game.search_logs add constraint search_logs_pkey PRIMARY KEY (id);
alter table game.search_logs add constraint search_logs_premises_id_fkey FOREIGN KEY (premises_id) REFERENCES game.search_premises(id);
alter table game.search_logs add constraint search_logs_recorded_by_personnel_id_fkey FOREIGN KEY (recorded_by_personnel_id) REFERENCES game.police_personnel(id);
alter table game.search_logs add constraint search_logs_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id);
alter table game.search_operation_events add constraint search_operation_events_actor_personnel_id_fkey FOREIGN KEY (actor_personnel_id) REFERENCES game.police_personnel(id);
alter table game.search_operation_events add constraint search_operation_events_operation_id_fkey FOREIGN KEY (operation_id) REFERENCES game.search_operations(id);
alter table game.search_operation_events add constraint search_operation_events_pkey PRIMARY KEY (id);
alter table game.search_operation_events add constraint search_operation_events_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id);
alter table game.search_operation_team add constraint search_operation_team_assigned_by_personnel_id_fkey FOREIGN KEY (assigned_by_personnel_id) REFERENCES game.police_personnel(id);
alter table game.search_operation_team add constraint search_operation_team_operation_id_fkey FOREIGN KEY (operation_id) REFERENCES game.search_operations(id);
alter table game.search_operation_team add constraint search_operation_team_operation_id_personnel_id_key UNIQUE (operation_id, personnel_id);
alter table game.search_operation_team add constraint search_operation_team_personnel_id_fkey FOREIGN KEY (personnel_id) REFERENCES game.police_personnel(id);
alter table game.search_operation_team add constraint search_operation_team_pkey PRIMARY KEY (id);
alter table game.search_operation_team add constraint search_operation_team_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id);
alter table game.search_operation_team add constraint search_operation_team_team_role_check CHECK ((team_role = ANY (ARRAY['team_lead'::text, 'search_officer'::text, 'evidence_officer'::text, 'photographer'::text, 'other'::text])));
alter table game.search_operations add constraint search_operations_case_id_fkey FOREIGN KEY (case_id) REFERENCES game.cases(id);
alter table game.search_operations add constraint search_operations_method_check CHECK ((method = ANY (ARRAY['premises_search'::text, 'vehicle_search'::text, 'storage_search'::text, 'mixed'::text, 'other'::text])));
alter table game.search_operations add constraint search_operations_operation_ref_key UNIQUE (operation_ref);
alter table game.search_operations add constraint search_operations_pkey PRIMARY KEY (id);
alter table game.search_operations add constraint search_operations_planned_by_personnel_id_fkey FOREIGN KEY (planned_by_personnel_id) REFERENCES game.police_personnel(id);
alter table game.search_operations add constraint search_operations_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id);
alter table game.search_operations add constraint search_operations_status_check CHECK ((status = ANY (ARRAY['planned'::text, 'executing'::text, 'completed'::text, 'cancelled'::text])));
alter table game.search_operations add constraint search_operations_warrant_id_fkey FOREIGN KEY (warrant_id) REFERENCES game.search_warrants(id);
alter table game.search_premises add constraint search_premises_added_by_personnel_id_fkey FOREIGN KEY (added_by_personnel_id) REFERENCES game.police_personnel(id);
alter table game.search_premises add constraint search_premises_operation_id_fkey FOREIGN KEY (operation_id) REFERENCES game.search_operations(id);
alter table game.search_premises add constraint search_premises_operation_id_property_id_key UNIQUE (operation_id, property_id);
alter table game.search_premises add constraint search_premises_pkey PRIMARY KEY (id);
alter table game.search_premises add constraint search_premises_premises_ref_key UNIQUE (premises_ref);
alter table game.search_premises add constraint search_premises_property_id_fkey FOREIGN KEY (property_id) REFERENCES game.properties(id);
alter table game.search_premises add constraint search_premises_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id);
alter table game.search_premises add constraint search_premises_status_check CHECK ((status = ANY (ARRAY['planned'::text, 'searched'::text, 'not_searched'::text])));
alter table game.search_seizures add constraint search_seizures_evidence_id_fkey FOREIGN KEY (evidence_id) REFERENCES game.evidence_items(id);
alter table game.search_seizures add constraint search_seizures_evidence_id_key UNIQUE (evidence_id);
alter table game.search_seizures add constraint search_seizures_operation_id_fkey FOREIGN KEY (operation_id) REFERENCES game.search_operations(id);
alter table game.search_seizures add constraint search_seizures_pkey PRIMARY KEY (id);
alter table game.search_seizures add constraint search_seizures_premises_id_fkey FOREIGN KEY (premises_id) REFERENCES game.search_premises(id);
alter table game.search_seizures add constraint search_seizures_recovery_id_fkey FOREIGN KEY (recovery_id) REFERENCES game.recovered_property(id);
alter table game.search_seizures add constraint search_seizures_recovery_id_key UNIQUE (recovery_id);
alter table game.search_seizures add constraint search_seizures_seized_by_personnel_id_fkey FOREIGN KEY (seized_by_personnel_id) REFERENCES game.police_personnel(id);
alter table game.search_seizures add constraint search_seizures_seizure_ref_key UNIQUE (seizure_ref);
alter table game.search_seizures add constraint search_seizures_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id);
alter table game.search_warrants add constraint search_warrants_case_id_fkey FOREIGN KEY (case_id) REFERENCES game.cases(id);
alter table game.search_warrants add constraint search_warrants_check CHECK ((valid_until_game_time > issued_at_game_time));
alter table game.search_warrants add constraint search_warrants_issued_by_personnel_id_fkey FOREIGN KEY (issued_by_personnel_id) REFERENCES game.police_personnel(id);
alter table game.search_warrants add constraint search_warrants_pkey PRIMARY KEY (id);
alter table game.search_warrants add constraint search_warrants_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id);
alter table game.search_warrants add constraint search_warrants_status_check CHECK ((status = ANY (ARRAY['issued'::text, 'executed'::text, 'revoked'::text, 'expired'::text])));
alter table game.search_warrants add constraint search_warrants_warrant_ref_key UNIQUE (warrant_ref);

do $$ declare t text; begin foreach t in array array['search_warrants','search_operations','search_operation_team','search_premises','search_logs','recovered_property','search_seizures','search_operation_events'] loop execute format('alter table game.%I enable row level security',t); execute format('revoke all on game.%I from anon,authenticated',t); execute format('grant select,insert,update,delete on game.%I to service_role',t); end loop; end $$;
grant usage,select on all sequences in schema game to service_role;

CREATE OR REPLACE FUNCTION game.prevent_search_history_mutation()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'game'
AS $function$ begin raise exception 'Search operation history is append-only';end $function$


alter function game.interpret_text_command(text) rename to interpret_text_command_before_search_warrant_runtime;
alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_search_warrant_runtime;

CREATE OR REPLACE FUNCTION game.execute_search_command(p_command_id uuid, p_command_type text, p_payload jsonb, p_actor_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare n timestamptz;c game.cases%rowtype;w game.search_warrants%rowtype;o game.search_operations%rowtype;prm game.search_premises%rowtype;prop game.properties%rowtype;rp game.recovered_property%rowtype;actor game.police_personnel%rowtype;target game.police_personnel%rowtype;eid uuid;eref text;wref text;oref text;pref text;rref text;lref text;sref text;cust uuid;trid uuid;
begin
 select current_game_time into n from game.simulation_state where id=1 for update;if n is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','This action requires the fictional game clock.');end if;
 select * into actor from game.police_personnel where id=p_actor_id and employment_status in ('active','seconded');if actor.id is null then return jsonb_build_object('ok',false,'code','personnel_unavailable','message','Active or seconded personnel required.');end if;
 if p_command_type='create_search_warrant' then
  select * into c from game.cases where case_ref=p_payload->>'case_ref' and status not in ('closed','cancelled');if c.id is null then return jsonb_build_object('ok',false,'code','case_not_found');end if;
  if c.lead_personnel_id is distinct from p_actor_id and not exists(select 1 from game.case_assignments a where a.case_id=c.id and a.personnel_id=p_actor_id and a.status='active' and a.released_at is null) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  if nullif(btrim(p_payload->>'authority'),'') is null or nullif(btrim(p_payload->>'scope'),'') is null or coalesce((p_payload->>'valid_hours')::int,72) not between 1 and 720 then return jsonb_build_object('ok',false,'code','warrant_details_required','message','Authority, scope and validity (1–720 hours) are required.');end if;
  insert into game.search_warrants(case_id,issuing_authority,scope_description,issued_by_personnel_id,issued_at_game_time,valid_until_game_time,source_command_id) values(c.id,btrim(p_payload->>'authority'),btrim(p_payload->>'scope'),p_actor_id,n,n+make_interval(hours=>coalesce((p_payload->>'valid_hours')::int,72)),p_command_id) returning warrant_ref into wref;
  insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data) values('search.warrant_issued',n,p_actor_id,'search_warrant',(select id from game.search_warrants where warrant_ref=wref),jsonb_build_object('command_id',p_command_id,'scope',p_payload->>'scope'));
  return jsonb_build_object('ok',true,'warrant_ref',wref,'valid_until_game_time',n+make_interval(hours=>coalesce((p_payload->>'valid_hours')::int,72)));
 elsif p_command_type='create_search_operation' then
  select * into c from game.cases where case_ref=p_payload->>'case_ref' and status not in ('closed','cancelled');if c.id is null then return jsonb_build_object('ok',false,'code','case_not_found');end if;
  select * into w from game.search_warrants where warrant_ref=p_payload->>'warrant_ref' and case_id=c.id;if w.id is null or w.status<>'issued' or n>=w.valid_until_game_time then return jsonb_build_object('ok',false,'code','warrant_unavailable');end if;
  if c.lead_personnel_id is distinct from p_actor_id and not exists(select 1 from game.case_assignments a where a.case_id=c.id and a.personnel_id=p_actor_id and a.status='active' and a.released_at is null) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  if p_payload->>'method' not in ('premises_search','vehicle_search','storage_search','mixed','other') or nullif(btrim(p_payload->>'objective'),'') is null then return jsonb_build_object('ok',false,'code','search_plan_details_required');end if;
  insert into game.search_operations(case_id,warrant_id,method,objective,planned_by_personnel_id,created_at_game_time,source_command_id) values(c.id,w.id,p_payload->>'method',btrim(p_payload->>'objective'),p_actor_id,n,p_command_id) returning operation_ref into oref;
  select * into o from game.search_operations where operation_ref=oref;insert into game.search_operation_events(operation_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(o.id,'operation_planned',p_actor_id,n,jsonb_build_object('warrant_ref',w.warrant_ref),p_command_id);
  return jsonb_build_object('ok',true,'operation_ref',oref,'warrant_ref',w.warrant_ref);
 elsif p_command_type='add_search_team' then
  select * into o from game.search_operations where operation_ref=p_payload->>'operation_ref' for update;if o.id is null or o.status<>'planned' then return jsonb_build_object('ok',false,'code','operation_not_planned');end if;
  select * into c from game.cases where id=o.case_id;
  if c.lead_personnel_id is distinct from p_actor_id and not exists(select 1 from game.case_assignments a where a.case_id=c.id and a.personnel_id=p_actor_id and a.status='active' and a.released_at is null) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  select * into target from game.police_personnel where personnel_ref=p_payload->>'personnel_ref' and employment_status in ('active','seconded');
  if target.id is null or (target.id<>p_actor_id and target.id is distinct from c.lead_personnel_id and not exists(select 1 from game.case_assignments a where a.case_id=c.id and a.personnel_id=target.id and a.status='active' and a.released_at is null)) then return jsonb_build_object('ok',false,'code','team_member_unavailable');end if;
  if p_payload->>'role' not in ('team_lead','search_officer','evidence_officer','photographer','other') then return jsonb_build_object('ok',false,'code','invalid_team_role');end if;
  insert into game.search_operation_team(operation_id,personnel_id,team_role,assigned_by_personnel_id,assigned_at_game_time,source_command_id) values(o.id,target.id,p_payload->>'role',p_actor_id,n,p_command_id);
  insert into game.search_operation_events(operation_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(o.id,'team_member_assigned',p_actor_id,n,jsonb_build_object('personnel_ref',target.personnel_ref,'role',p_payload->>'role'),p_command_id);
  return jsonb_build_object('ok',true,'operation_ref',o.operation_ref,'personnel_ref',target.personnel_ref,'role',p_payload->>'role');
 elsif p_command_type='add_search_premises' then
  select * into o from game.search_operations where operation_ref=p_payload->>'operation_ref' for update;if o.id is null or o.status<>'planned' then return jsonb_build_object('ok',false,'code','operation_not_planned');end if;
  if not exists(select 1 from game.search_operation_team where operation_id=o.id and personnel_id=p_actor_id) then return jsonb_build_object('ok',false,'code','team_members_only');end if;
  select * into prop from game.properties where property_ref=p_payload->>'property_ref';if prop.id is null then return jsonb_build_object('ok',false,'code','property_not_found');end if;
  insert into game.search_premises(operation_id,property_id,premises_description,added_by_personnel_id,source_command_id) values(o.id,prop.id,btrim(p_payload->>'description'),p_actor_id,p_command_id) returning premises_ref into pref;
  return jsonb_build_object('ok',true,'premises_ref',pref,'property_ref',prop.property_ref);
 elsif p_command_type='start_search_operation' then
  select * into o from game.search_operations where operation_ref=p_payload->>'operation_ref' for update;if o.id is null or o.status<>'planned' then return jsonb_build_object('ok',false,'code','operation_not_planned');end if;
  if not exists(select 1 from game.search_operation_team where operation_id=o.id and personnel_id=p_actor_id) then return jsonb_build_object('ok',false,'code','team_members_only');end if;
  if not exists(select 1 from game.search_operation_team where operation_id=o.id and team_role='team_lead') then return jsonb_build_object('ok',false,'code','team_lead_required');end if;
  if not exists(select 1 from game.search_premises where operation_id=o.id) then return jsonb_build_object('ok',false,'code','premises_required');end if;
  select * into w from game.search_warrants where id=o.warrant_id for update;if w.status<>'issued' or n>=w.valid_until_game_time then return jsonb_build_object('ok',false,'code','warrant_unavailable');end if;
  update game.search_operations set status='executing',started_at_game_time=n where id=o.id;update game.search_warrants set status='executed' where id=w.id;
  insert into game.search_operation_events(operation_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(o.id,'operation_started',p_actor_id,n,jsonb_build_object('warrant_ref',w.warrant_ref),p_command_id);
  return jsonb_build_object('ok',true,'operation_ref',o.operation_ref,'status','executing');
 elsif p_command_type='record_search_log' then
  select * into o from game.search_operations where operation_ref=p_payload->>'operation_ref';select * into prm from game.search_premises where premises_ref=p_payload->>'premises_ref' and operation_id=o.id;
  if o.id is null or o.status<>'executing' or prm.id is null then return jsonb_build_object('ok',false,'code','search_not_active');end if;
  if not exists(select 1 from game.search_operation_team where operation_id=o.id and personnel_id=p_actor_id) then return jsonb_build_object('ok',false,'code','team_members_only');end if;
  if p_payload->>'event_type' not in ('arrival','entry','area_examined','item_found','person_present','damage_or_condition','departure','other') or nullif(btrim(p_payload->>'location'),'') is null or nullif(btrim(p_payload->>'narrative'),'') is null then return jsonb_build_object('ok',false,'code','search_log_details_required');end if;
  insert into game.search_logs(operation_id,premises_id,event_type,location_within_premises,narrative,recorded_by_personnel_id,recorded_at_game_time,source_command_id) values(o.id,prm.id,p_payload->>'event_type',btrim(p_payload->>'location'),btrim(p_payload->>'narrative'),p_actor_id,n,p_command_id) returning log_ref into lref;
  insert into game.search_operation_events(operation_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(o.id,'search_log_recorded',p_actor_id,n,jsonb_build_object('log_ref',lref),p_command_id);return jsonb_build_object('ok',true,'log_ref',lref);
 elsif p_command_type='recover_search_property' then
  select * into o from game.search_operations where operation_ref=p_payload->>'operation_ref';select * into prm from game.search_premises where premises_ref=p_payload->>'premises_ref' and operation_id=o.id;
  if o.id is null or o.status<>'executing' or prm.id is null then return jsonb_build_object('ok',false,'code','search_not_active');end if;
  if not exists(select 1 from game.search_operation_team where operation_id=o.id and personnel_id=p_actor_id) then return jsonb_build_object('ok',false,'code','team_members_only');end if;
  if nullif(btrim(p_payload->>'category'),'') is null or nullif(btrim(p_payload->>'description'),'') is null or nullif(btrim(p_payload->>'location'),'') is null or nullif(btrim(p_payload->>'condition'),'') is null then return jsonb_build_object('ok',false,'code','recovery_details_required');end if;
  insert into game.recovered_property(operation_id,premises_id,found_by_personnel_id,item_category,item_description,found_location,condition_on_recovery,recovered_at_game_time,source_command_id) values(o.id,prm.id,p_actor_id,btrim(p_payload->>'category'),btrim(p_payload->>'description'),btrim(p_payload->>'location'),btrim(p_payload->>'condition'),n,p_command_id) returning recovery_ref into rref;
  insert into game.search_operation_events(operation_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(o.id,'property_recovered',p_actor_id,n,jsonb_build_object('recovery_ref',rref),p_command_id);return jsonb_build_object('ok',true,'recovery_ref',rref,'message','Recovered property recorded; not yet seized.');
 elsif p_command_type='seize_search_property' then
  select * into rp from game.recovered_property where recovery_ref=p_payload->>'recovery_ref' for update;select * into o from game.search_operations where id=rp.operation_id;
  if rp.id is null or o.status<>'executing' then return jsonb_build_object('ok',false,'code','recovered_property_unavailable');end if;
  if not exists(select 1 from game.search_operation_team where operation_id=o.id and personnel_id=p_actor_id) then return jsonb_build_object('ok',false,'code','team_members_only');end if;
  if nullif(btrim(p_payload->>'reason'),'') is null or nullif(btrim(p_payload->>'packaging'),'') is null or nullif(btrim(p_payload->>'seal'),'') is null or nullif(btrim(p_payload->>'storage'),'') is null then return jsonb_build_object('ok',false,'code','seizure_details_required');end if;
  eref:='KWE-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  insert into game.evidence_items(evidence_ref,case_id,collected_by_personnel_id,evidence_type,description,collected_at,collection_location,current_status,storage_location,metadata) values(eref,o.case_id,p_actor_id,coalesce(nullif(p_payload->>'evidence_type',''),rp.item_category),rp.item_description,n,rp.found_location,'held',btrim(p_payload->>'storage'),jsonb_build_object('source','search_seizure','operation_ref',o.operation_ref,'premises_ref',(select premises_ref from game.search_premises where id=rp.premises_id),'recovery_ref',rp.recovery_ref,'condition_on_recovery',rp.condition_on_recovery,'packaging',p_payload->>'packaging','seal_identifier',p_payload->>'seal')) returning id into eid;
  insert into game.search_seizures(recovery_id,operation_id,premises_id,evidence_id,seized_by_personnel_id,seized_at_game_time,seizure_reason,packaging_description,seal_identifier,storage_location,source_command_id) values(rp.id,o.id,rp.premises_id,eid,p_actor_id,n,btrim(p_payload->>'reason'),btrim(p_payload->>'packaging'),btrim(p_payload->>'seal'),btrim(p_payload->>'storage'),p_command_id) returning seizure_ref into sref;
  update game.recovered_property set disposition='seized' where id=rp.id;
  insert into game.search_operation_events(operation_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(o.id,'property_seized',p_actor_id,n,jsonb_build_object('seizure_ref',sref,'evidence_ref',eref),p_command_id);return jsonb_build_object('ok',true,'seizure_ref',sref,'evidence_ref',eref);
 elsif p_command_type='transfer_search_evidence' then
  select id,collected_by_personnel_id into eid,cust from game.evidence_items where evidence_ref=p_payload->>'evidence_ref' and metadata->>'source'='search_seizure' for update;if eid is null then return jsonb_build_object('ok',false,'code','seized_evidence_not_found');end if;
  select to_personnel_id into cust from game.evidence_transfers where evidence_id=eid order by transferred_at desc,id desc limit 1;if cust is null then select collected_by_personnel_id into cust from game.evidence_items where id=eid;end if;
  if cust is distinct from p_actor_id then return jsonb_build_object('ok',false,'code','evidence_custodian_mismatch');end if;
  select * into target from game.police_personnel where personnel_ref=p_payload->>'to_ref' and employment_status in ('active','seconded');if target.id is null or target.id=p_actor_id then return jsonb_build_object('ok',false,'code','recipient_unavailable');end if;
  if nullif(btrim(p_payload->>'from_location'),'') is null or nullif(btrim(p_payload->>'to_location'),'') is null or nullif(btrim(p_payload->>'reason'),'') is null then return jsonb_build_object('ok',false,'code','transfer_details_required');end if;
  insert into game.evidence_transfers(evidence_id,transferred_at,from_personnel_id,to_personnel_id,from_location,to_location,transfer_reason,notes) values(eid,n,p_actor_id,target.id,btrim(p_payload->>'from_location'),btrim(p_payload->>'to_location'),btrim(p_payload->>'reason'),nullif(btrim(p_payload->>'notes'),'')) returning id into trid;
  update game.evidence_items set current_status='transferred',storage_location=btrim(p_payload->>'to_location') where id=eid;return jsonb_build_object('ok',true,'evidence_ref',p_payload->>'evidence_ref','to_personnel_ref',target.personnel_ref,'transfer_id',trid);
 elsif p_command_type='close_search_operation' then
  select * into o from game.search_operations where operation_ref=p_payload->>'operation_ref' for update;if o.id is null or o.status<>'executing' then return jsonb_build_object('ok',false,'code','operation_not_executing');end if;
  if not exists(select 1 from game.search_operation_team where operation_id=o.id and personnel_id=p_actor_id and team_role='team_lead') then return jsonb_build_object('ok',false,'code','team_lead_required');end if;
  if nullif(btrim(p_payload->>'reason'),'') is null then return jsonb_build_object('ok',false,'code','closure_reason_required');end if;
  update game.search_operations set status='completed',closed_at_game_time=n,closure_reason=btrim(p_payload->>'reason') where id=o.id;update game.search_premises set status='searched',searched_at_game_time=n,outcome_summary='Search completed; see individual logs.' where operation_id=o.id and status='planned';
  insert into game.search_operation_events(operation_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(o.id,'operation_completed',p_actor_id,n,jsonb_build_object('reason',p_payload->>'reason'),p_command_id);return jsonb_build_object('ok',true,'operation_ref',o.operation_ref,'status','completed');
 elsif p_command_type='get_search_operations' then
  select * into c from game.cases where case_ref=p_payload->>'case_ref';if c.id is null then return jsonb_build_object('ok',false,'code','case_not_found');end if;
  if c.lead_personnel_id is distinct from p_actor_id and not exists(select 1 from game.case_assignments a where a.case_id=c.id and a.personnel_id=p_actor_id and a.status='active' and a.released_at is null) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  return game.get_search_operations(c.id);end if;return jsonb_build_object('ok',false,'code','unsupported_search_command');
end $function$


CREATE OR REPLACE FUNCTION game.execute_text_command(p_command_text text, p_idempotency_key text, p_session_id uuid DEFAULT NULL::uuid, p_actor_personnel_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare i jsonb;typ text;d jsonb;cmd game.game_commands%rowtype;res jsonb;actor game.police_personnel%rowtype;
begin i:=game.interpret_text_command(p_command_text);typ:=i->>'command_type';d:=coalesce(i->'payload','{}'::jsonb);
 if typ='help' then res:=game.execute_text_command_before_search_warrant_runtime(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);return jsonb_set(res,'{available_commands}',(select coalesce(jsonb_agg(distinct x),'[]') from jsonb_array_elements_text(coalesce(res->'available_commands','[]')||jsonb_build_array('create_search_warrant','create_search_operation','add_search_team','add_search_premises','start_search_operation','record_search_log','recover_search_property','seize_search_property','transfer_search_evidence','close_search_operation','get_search_operations'))x),true);end if;
 if typ not in ('create_search_warrant','create_search_operation','add_search_team','add_search_premises','start_search_operation','record_search_log','recover_search_property','seize_search_property','transfer_search_evidence','close_search_operation','get_search_operations') then return game.execute_text_command_before_search_warrant_runtime(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key is required';end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload) values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,typ,d) on conflict(idempotency_key) do nothing;
 if not found then select * into cmd from game.game_commands where idempotency_key=p_idempotency_key for update;if cmd.command_text<>p_command_text or cmd.command_type<>typ or cmd.payload<>d then return jsonb_build_object('ok',false,'code','idempotency_conflict');end if;return coalesce(cmd.result,jsonb_build_object('ok',cmd.status='completed'))||jsonb_build_object('duplicate',true);end if;
 select * into cmd from game.game_commands where idempotency_key=p_idempotency_key for update;select * into actor from game.police_personnel where personnel_ref=d->>'actor_ref' and employment_status in ('active','seconded');
 if actor.id is null or (p_actor_personnel_id is not null and p_actor_personnel_id<>actor.id) then res:=jsonb_build_object('ok',false,'code','actor_mismatch');else res:=game.execute_search_command(cmd.id,typ,d,actor.id);end if;
 if coalesce((res->>'ok')::boolean,false) then res:=res||jsonb_build_object('status','completed','command_id',cmd.id);update game.game_commands set status='completed',result=res,completed_at=now() where id=cmd.id;else update game.game_commands set status='rejected',result=res,rejection_reason=coalesce(res->>'message','Search command rejected.'),completed_at=now() where id=cmd.id;res:=res||jsonb_build_object('command_id',cmd.id);end if;return res;end $function$


CREATE OR REPLACE FUNCTION game.get_search_operations(p_case_id uuid)
 RETURNS jsonb
 LANGUAGE sql
 STABLE
 SET search_path TO 'pg_catalog', 'game'
AS $function$
select jsonb_build_object('ok',true,'case_ref',c.case_ref,
'warrants',(select coalesce(jsonb_agg(jsonb_build_object('warrant_ref',sw.warrant_ref,'authority',sw.issuing_authority,'scope',sw.scope_description,'issued_at',sw.issued_at_game_time,'valid_until',sw.valid_until_game_time,'status',sw.status) order by sw.issued_at_game_time),'[]'::jsonb) from game.search_warrants sw where sw.case_id=c.id),
'operations',(select coalesce(jsonb_agg(jsonb_build_object('operation_ref',so.operation_ref,'warrant_ref',sw.warrant_ref,'method',so.method,'objective',so.objective,'status',so.status,
'team',(select coalesce(jsonb_agg(jsonb_build_object('personnel_ref',p.personnel_ref,'role',tm.team_role) order by tm.created_at),'[]'::jsonb) from game.search_operation_team tm join game.police_personnel p on p.id=tm.personnel_id where tm.operation_id=so.id),
'premises',(select coalesce(jsonb_agg(jsonb_build_object('premises_ref',sp.premises_ref,'property_ref',pr.property_ref,'description',sp.premises_description,'status',sp.status,
'logs',(select coalesce(jsonb_agg(jsonb_build_object('log_ref',sl.log_ref,'type',sl.event_type,'location',sl.location_within_premises,'narrative',sl.narrative,'at',sl.recorded_at_game_time) order by sl.recorded_at_game_time),'[]'::jsonb) from game.search_logs sl where sl.premises_id=sp.id),
'recovered_property',(select coalesce(jsonb_agg(jsonb_build_object('recovery_ref',rp.recovery_ref,'description',rp.item_description,'category',rp.item_category,'disposition',rp.disposition,'seizure_ref',ss.seizure_ref,'evidence_ref',ei.evidence_ref) order by rp.recovered_at_game_time),'[]'::jsonb) from game.recovered_property rp left join game.search_seizures ss on ss.recovery_id=rp.id left join game.evidence_items ei on ei.id=ss.evidence_id where rp.premises_id=sp.id)
) order by sp.created_at),'[]'::jsonb) from game.search_premises sp join game.properties pr on pr.id=sp.property_id where sp.operation_id=so.id),
'events',(select coalesce(jsonb_agg(jsonb_build_object('type',ev.event_type,'at',ev.event_at_game_time,'actor',p.personnel_ref,'data',ev.event_data) order by ev.event_at_game_time,ev.created_at),'[]'::jsonb) from game.search_operation_events ev join game.police_personnel p on p.id=ev.actor_personnel_id where ev.operation_id=so.id)
) order by so.created_at_game_time),'[]'::jsonb) from game.search_operations so join game.search_warrants sw on sw.id=so.warrant_id where so.case_id=c.id))
from game.cases c where c.id=p_case_id
$function$


CREATE OR REPLACE FUNCTION game.interpret_search_command(p_command_text text)
 RETURNS jsonb
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'game'
AS $function$ declare t text:=btrim(coalesce(p_command_text,''));m text[];begin
 m:=regexp_match(t,'^warrant create ([^[:space:]]+) by ([^[:space:]]+) authority "(.+)" scope "(.+)"(?: valid_for ([0-9]+) hours)?$','i');if m is not null then return jsonb_build_object('recognized',true,'command_type','create_search_warrant','payload',jsonb_build_object('case_ref',m[1],'actor_ref',m[2],'authority',m[3],'scope',m[4],'valid_hours',coalesce(m[5],'72')));end if;
 m:=regexp_match(t,'^search plan create ([^[:space:]]+) warrant ([^[:space:]]+) by ([^[:space:]]+) method ([^[:space:]]+) objective "(.+)"$','i');if m is not null then return jsonb_build_object('recognized',true,'command_type','create_search_operation','payload',jsonb_build_object('case_ref',m[1],'warrant_ref',m[2],'actor_ref',m[3],'method',lower(m[4]),'objective',m[5]));end if;
 m:=regexp_match(t,'^search team add ([^[:space:]]+) ([^[:space:]]+) role ([^[:space:]]+) by ([^[:space:]]+)$','i');if m is not null then return jsonb_build_object('recognized',true,'command_type','add_search_team','payload',jsonb_build_object('operation_ref',m[1],'personnel_ref',m[2],'role',lower(m[3]),'actor_ref',m[4]));end if;
 m:=regexp_match(t,'^search premises add ([^[:space:]]+) property ([^[:space:]]+) by ([^[:space:]]+) description "(.+)"$','i');if m is not null then return jsonb_build_object('recognized',true,'command_type','add_search_premises','payload',jsonb_build_object('operation_ref',m[1],'property_ref',m[2],'actor_ref',m[3],'description',m[4]));end if;
 m:=regexp_match(t,'^search execute ([^[:space:]]+) by ([^[:space:]]+)$','i');if m is not null then return jsonb_build_object('recognized',true,'command_type','start_search_operation','payload',jsonb_build_object('operation_ref',m[1],'actor_ref',m[2]));end if;
 m:=regexp_match(t,'^search log ([^[:space:]]+) premises ([^[:space:]]+) by ([^[:space:]]+) type ([^[:space:]]+) at "(.+)" narrative "(.+)"$','i');if m is not null then return jsonb_build_object('recognized',true,'command_type','record_search_log','payload',jsonb_build_object('operation_ref',m[1],'premises_ref',m[2],'actor_ref',m[3],'event_type',lower(m[4]),'location',m[5],'narrative',m[6]));end if;
 m:=regexp_match(t,'^search recover ([^[:space:]]+) premises ([^[:space:]]+) by ([^[:space:]]+) category "(.+)" description "(.+)" at "(.+)" condition "(.+)"$','i');if m is not null then return jsonb_build_object('recognized',true,'command_type','recover_search_property','payload',jsonb_build_object('operation_ref',m[1],'premises_ref',m[2],'actor_ref',m[3],'category',m[4],'description',m[5],'location',m[6],'condition',m[7]));end if;
 m:=regexp_match(t,'^search seize ([^[:space:]]+) by ([^[:space:]]+) reason "(.+)" packaging "(.+)" seal "(.+)" storage "(.+)"(?: evidence_type ([^[:space:]]+))?$','i');if m is not null then return jsonb_build_object('recognized',true,'command_type','seize_search_property','payload',jsonb_build_object('recovery_ref',m[1],'actor_ref',m[2],'reason',m[3],'packaging',m[4],'seal',m[5],'storage',m[6],'evidence_type',coalesce(m[7],'physical_item')));end if;
 m:=regexp_match(t,'^search evidence transfer ([^[:space:]]+) to ([^[:space:]]+) by ([^[:space:]]+) from "(.+)" at "(.+)" because "(.+)"$','i');if m is not null then return jsonb_build_object('recognized',true,'command_type','transfer_search_evidence','payload',jsonb_build_object('evidence_ref',m[1],'to_ref',m[2],'actor_ref',m[3],'from_location',m[4],'to_location',m[5],'reason',m[6]));end if;
 m:=regexp_match(t,'^search close ([^[:space:]]+) by ([^[:space:]]+) because "(.+)"$','i');if m is not null then return jsonb_build_object('recognized',true,'command_type','close_search_operation','payload',jsonb_build_object('operation_ref',m[1],'actor_ref',m[2],'reason',m[3]));end if;
 m:=regexp_match(t,'^search operations ([^[:space:]]+) by ([^[:space:]]+)$','i');if m is not null then return jsonb_build_object('recognized',true,'command_type','get_search_operations','payload',jsonb_build_object('case_ref',m[1],'actor_ref',m[2]));end if;return null;end $function$


CREATE OR REPLACE FUNCTION game.interpret_text_command(p_command_text text)
 RETURNS jsonb
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'game'
AS $function$ declare r jsonb;begin r:=game.interpret_search_command(p_command_text);if r is not null then return r;end if;return game.interpret_text_command_before_search_warrant_runtime(p_command_text);end $function$


CREATE TRIGGER search_logs_append_only BEFORE DELETE OR UPDATE ON game.search_logs FOR EACH ROW EXECUTE FUNCTION game.prevent_search_history_mutation();
CREATE TRIGGER search_events_append_only BEFORE DELETE OR UPDATE ON game.search_operation_events FOR EACH ROW EXECUTE FUNCTION game.prevent_search_history_mutation();
CREATE TRIGGER search_team_append_only BEFORE DELETE OR UPDATE ON game.search_operation_team FOR EACH ROW EXECUTE FUNCTION game.prevent_search_history_mutation();
CREATE TRIGGER search_seizures_append_only BEFORE DELETE OR UPDATE ON game.search_seizures FOR EACH ROW EXECUTE FUNCTION game.prevent_search_history_mutation();

CREATE INDEX recovered_property_operation_idx ON game.recovered_property USING btree (operation_id, recovered_at_game_time);
CREATE INDEX recovered_property_premises_idx ON game.recovered_property USING btree (premises_id);
CREATE INDEX search_logs_operation_idx ON game.search_logs USING btree (operation_id, recorded_at_game_time);
CREATE INDEX search_logs_premises_idx ON game.search_logs USING btree (premises_id);
CREATE INDEX search_events_operation_idx ON game.search_operation_events USING btree (operation_id, event_at_game_time);
CREATE UNIQUE INDEX search_operation_one_team_lead_idx ON game.search_operation_team USING btree (operation_id) WHERE (team_role = 'team_lead'::text);
CREATE INDEX search_team_personnel_idx ON game.search_operation_team USING btree (personnel_id, operation_id);
CREATE INDEX search_operations_case_idx ON game.search_operations USING btree (case_id, status);
CREATE INDEX search_operations_warrant_idx ON game.search_operations USING btree (warrant_id);
CREATE INDEX search_premises_operation_idx ON game.search_premises USING btree (operation_id, status);
CREATE INDEX search_premises_property_idx ON game.search_premises USING btree (property_id);
CREATE INDEX search_seizures_evidence_idx ON game.search_seizures USING btree (evidence_id);
CREATE INDEX search_seizures_operation_idx ON game.search_seizures USING btree (operation_id);
CREATE INDEX search_warrants_case_idx ON game.search_warrants USING btree (case_id, issued_at_game_time);

revoke all on function game.execute_search_command(uuid,text,jsonb,uuid) from public,anon,authenticated;
grant execute on function game.execute_search_command(uuid,text,jsonb,uuid) to service_role;
revoke all on function game.get_search_operations(uuid) from public,anon,authenticated;
grant execute on function game.get_search_operations(uuid) to service_role;
revoke all on function game.interpret_search_command(text) from public,anon,authenticated;
grant execute on function game.interpret_search_command(text) to service_role;
revoke all on function game.interpret_text_command(text) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text) to service_role;
revoke all on function game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.execute_text_command(text,text,uuid,uuid) to service_role;
