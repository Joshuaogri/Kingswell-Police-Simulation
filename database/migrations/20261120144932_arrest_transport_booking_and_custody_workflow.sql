-- Kingswell fictional arrest, suspect transport, booking and custody workflow.
create sequence game.arrest_ref_seq;
create sequence game.arrest_transport_ref_seq;
create sequence game.custody_episode_ref_seq;
create sequence game.custody_property_ref_seq;

create table game.arrest_events(
  id uuid not null default gen_random_uuid(),
  arrest_id uuid not null,
  event_type text not null,
  actor_personnel_id uuid not null,
  event_at_game_time timestamp with time zone not null,
  event_data jsonb not null default '{}'::jsonb,
  source_command_id uuid not null,
  created_at timestamp with time zone not null default now()
);

create table game.arrest_transport_legs(
  id uuid not null default gen_random_uuid(),
  transport_ref text not null default ('KWT-'::text || lpad((nextval('game.arrest_transport_ref_seq'::regclass))::text, 7, '0'::text)),
  arrest_id uuid not null,
  transporting_personnel_id uuid not null,
  departure_location text not null,
  destination_location text not null,
  vehicle_description text not null,
  departed_at_game_time timestamp with time zone not null,
  arrived_at_game_time timestamp with time zone not null,
  handover_notes text not null,
  source_command_id uuid not null,
  created_at timestamp with time zone not null default now(),
  duration_minutes integer not null default 1
);

create table game.arrests(
  id uuid not null default gen_random_uuid(),
  arrest_ref text not null default ('KWA-'::text || lpad((nextval('game.arrest_ref_seq'::regclass))::text, 7, '0'::text)),
  case_id uuid not null,
  person_id uuid not null,
  incident_id uuid,
  arresting_personnel_id uuid not null,
  arrest_basis text not null,
  authority_reference text,
  grounds_description text not null,
  arrest_location text not null,
  arrested_at_game_time timestamp with time zone not null,
  force_used text not null default 'none'::text,
  injury_or_complaint text not null default 'none_recorded'::text,
  warnings_or_rights_record text not null,
  witness_details text,
  body_camera_reference text,
  status text not null default 'arrested'::text,
  source_command_id uuid not null,
  created_at timestamp with time zone not null default now()
);

create table game.custody_episodes(
  id uuid not null default gen_random_uuid(),
  custody_ref text not null default ('KWC-'::text || lpad((nextval('game.custody_episode_ref_seq'::regclass))::text, 7, '0'::text)),
  arrest_id uuid not null,
  case_id uuid not null,
  person_id uuid not null,
  booking_officer_id uuid not null,
  booked_at_game_time timestamp with time zone not null,
  identity_check text not null,
  risk_assessment text not null,
  health_welfare_screen text not null,
  medication_disclosure text,
  safeguarding_notes text,
  cell_location text not null,
  status text not null default 'in_custody'::text,
  release_or_transfer_at_game_time timestamp with time zone,
  final_outcome text,
  final_reason text,
  source_command_id uuid not null,
  created_at timestamp with time zone not null default now()
);

create table game.custody_events(
  id uuid not null default gen_random_uuid(),
  custody_episode_id uuid not null,
  event_type text not null,
  actor_personnel_id uuid not null,
  event_at_game_time timestamp with time zone not null,
  details text not null,
  source_command_id uuid not null,
  created_at timestamp with time zone not null default now()
);

create table game.custody_property(
  id uuid not null default gen_random_uuid(),
  property_ref text not null default ('KWP-'::text || lpad((nextval('game.custody_property_ref_seq'::regclass))::text, 7, '0'::text)),
  custody_episode_id uuid not null,
  recorded_by_personnel_id uuid not null,
  item_description text not null,
  condition_description text not null,
  disposition text not null,
  storage_location text,
  evidence_id uuid,
  recorded_at_game_time timestamp with time zone not null,
  source_command_id uuid not null,
  created_at timestamp with time zone not null default now()
);

create table game.custody_welfare_checks(
  id uuid not null default gen_random_uuid(),
  custody_episode_id uuid not null,
  check_type text not null,
  officer_personnel_id uuid not null,
  checked_at_game_time timestamp with time zone not null,
  observation text not null,
  escalation text,
  source_command_id uuid not null,
  created_at timestamp with time zone not null default now()
);

alter table game.arrest_events add constraint arrest_events_actor_personnel_id_fkey FOREIGN KEY (actor_personnel_id) REFERENCES game.police_personnel(id);
alter table game.arrest_events add constraint arrest_events_arrest_id_fkey FOREIGN KEY (arrest_id) REFERENCES game.arrests(id);
alter table game.arrest_events add constraint arrest_events_pkey PRIMARY KEY (id);
alter table game.arrest_events add constraint arrest_events_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id);
alter table game.arrest_transport_legs add constraint arrest_transport_duration_valid CHECK (((duration_minutes >= 1) AND (duration_minutes <= 240)));
alter table game.arrest_transport_legs add constraint arrest_transport_legs_arrest_id_fkey FOREIGN KEY (arrest_id) REFERENCES game.arrests(id);
alter table game.arrest_transport_legs add constraint arrest_transport_legs_check CHECK ((arrived_at_game_time >= departed_at_game_time));
alter table game.arrest_transport_legs add constraint arrest_transport_legs_pkey PRIMARY KEY (id);
alter table game.arrest_transport_legs add constraint arrest_transport_legs_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id);
alter table game.arrest_transport_legs add constraint arrest_transport_legs_transport_ref_key UNIQUE (transport_ref);
alter table game.arrest_transport_legs add constraint arrest_transport_legs_transporting_personnel_id_fkey FOREIGN KEY (transporting_personnel_id) REFERENCES game.police_personnel(id);
alter table game.arrests add constraint arrests_arrest_basis_check CHECK ((arrest_basis = ANY (ARRAY['warrant'::text, 'grounds'::text, 'other'::text])));
alter table game.arrests add constraint arrests_arrest_ref_key UNIQUE (arrest_ref);
alter table game.arrests add constraint arrests_arresting_personnel_id_fkey FOREIGN KEY (arresting_personnel_id) REFERENCES game.police_personnel(id);
alter table game.arrests add constraint arrests_case_id_fkey FOREIGN KEY (case_id) REFERENCES game.cases(id);
alter table game.arrests add constraint arrests_check CHECK (((arrest_basis <> 'warrant'::text) OR (NULLIF(btrim(authority_reference), ''::text) IS NOT NULL)));
alter table game.arrests add constraint arrests_incident_id_fkey FOREIGN KEY (incident_id) REFERENCES game.incidents(id);
alter table game.arrests add constraint arrests_person_id_fkey FOREIGN KEY (person_id) REFERENCES game.persons(id);
alter table game.arrests add constraint arrests_pkey PRIMARY KEY (id);
alter table game.arrests add constraint arrests_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id);
alter table game.arrests add constraint arrests_status_check CHECK ((status = ANY (ARRAY['arrested'::text, 'transporting'::text, 'booked'::text, 'released'::text, 'transferred'::text])));
alter table game.custody_episodes add constraint custody_episodes_arrest_id_fkey FOREIGN KEY (arrest_id) REFERENCES game.arrests(id);
alter table game.custody_episodes add constraint custody_episodes_arrest_id_key UNIQUE (arrest_id);
alter table game.custody_episodes add constraint custody_episodes_booking_officer_id_fkey FOREIGN KEY (booking_officer_id) REFERENCES game.police_personnel(id);
alter table game.custody_episodes add constraint custody_episodes_case_id_fkey FOREIGN KEY (case_id) REFERENCES game.cases(id);
alter table game.custody_episodes add constraint custody_episodes_check CHECK ((((status = 'in_custody'::text) AND (release_or_transfer_at_game_time IS NULL) AND (final_outcome IS NULL)) OR ((status <> 'in_custody'::text) AND (release_or_transfer_at_game_time IS NOT NULL) AND (final_outcome IS NOT NULL))));
alter table game.custody_episodes add constraint custody_episodes_custody_ref_key UNIQUE (custody_ref);
alter table game.custody_episodes add constraint custody_episodes_person_id_fkey FOREIGN KEY (person_id) REFERENCES game.persons(id);
alter table game.custody_episodes add constraint custody_episodes_pkey PRIMARY KEY (id);
alter table game.custody_episodes add constraint custody_episodes_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id);
alter table game.custody_episodes add constraint custody_episodes_status_check CHECK ((status = ANY (ARRAY['in_custody'::text, 'released'::text, 'transferred'::text])));
alter table game.custody_events add constraint custody_events_actor_personnel_id_fkey FOREIGN KEY (actor_personnel_id) REFERENCES game.police_personnel(id);
alter table game.custody_events add constraint custody_events_custody_episode_id_fkey FOREIGN KEY (custody_episode_id) REFERENCES game.custody_episodes(id);
alter table game.custody_events add constraint custody_events_event_type_check CHECK ((event_type = ANY (ARRAY['risk_review'::text, 'health_review'::text, 'medication_disclosure'::text, 'cell_change'::text, 'meal'::text, 'rest_period'::text, 'interview_access'::text, 'legal_counsel'::text, 'visitor'::text, 'use_of_force'::text, 'incident'::text, 'supervisor_review'::text, 'handover'::text, 'other'::text])));
alter table game.custody_events add constraint custody_events_pkey PRIMARY KEY (id);
alter table game.custody_events add constraint custody_events_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id);
alter table game.custody_property add constraint custody_property_check CHECK ((((disposition = 'retained_as_evidence'::text) AND (evidence_id IS NOT NULL)) OR ((disposition <> 'retained_as_evidence'::text) AND (evidence_id IS NULL))));
alter table game.custody_property add constraint custody_property_custody_episode_id_fkey FOREIGN KEY (custody_episode_id) REFERENCES game.custody_episodes(id);
alter table game.custody_property add constraint custody_property_disposition_check CHECK ((disposition = ANY (ARRAY['stored'::text, 'retained_as_evidence'::text, 'returned'::text, 'transferred'::text])));
alter table game.custody_property add constraint custody_property_evidence_id_fkey FOREIGN KEY (evidence_id) REFERENCES game.evidence_items(id);
alter table game.custody_property add constraint custody_property_pkey PRIMARY KEY (id);
alter table game.custody_property add constraint custody_property_property_ref_key UNIQUE (property_ref);
alter table game.custody_property add constraint custody_property_recorded_by_personnel_id_fkey FOREIGN KEY (recorded_by_personnel_id) REFERENCES game.police_personnel(id);
alter table game.custody_property add constraint custody_property_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id);
alter table game.custody_welfare_checks add constraint custody_welfare_checks_check_type_check CHECK ((check_type = ANY (ARRAY['welfare'::text, 'health'::text, 'risk'::text, 'observation'::text])));
alter table game.custody_welfare_checks add constraint custody_welfare_checks_custody_episode_id_fkey FOREIGN KEY (custody_episode_id) REFERENCES game.custody_episodes(id);
alter table game.custody_welfare_checks add constraint custody_welfare_checks_officer_personnel_id_fkey FOREIGN KEY (officer_personnel_id) REFERENCES game.police_personnel(id);
alter table game.custody_welfare_checks add constraint custody_welfare_checks_pkey PRIMARY KEY (id);
alter table game.custody_welfare_checks add constraint custody_welfare_checks_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id);

CREATE INDEX arrest_events_actor_idx ON game.arrest_events USING btree (actor_personnel_id);
CREATE INDEX arrest_events_arrest_idx ON game.arrest_events USING btree (arrest_id, event_at_game_time);
CREATE INDEX arrest_events_command_idx ON game.arrest_events USING btree (source_command_id);
CREATE INDEX arrest_transport_arrest_idx ON game.arrest_transport_legs USING btree (arrest_id, departed_at_game_time);
CREATE INDEX arrest_transport_command_idx ON game.arrest_transport_legs USING btree (source_command_id);
CREATE INDEX arrest_transport_officer_idx ON game.arrest_transport_legs USING btree (transporting_personnel_id);
CREATE INDEX arrests_case_idx ON game.arrests USING btree (case_id, arrested_at_game_time);
CREATE INDEX arrests_command_idx ON game.arrests USING btree (source_command_id);
CREATE INDEX arrests_incident_idx ON game.arrests USING btree (incident_id);
CREATE INDEX arrests_officer_idx ON game.arrests USING btree (arresting_personnel_id);
CREATE INDEX arrests_person_idx ON game.arrests USING btree (person_id, arrested_at_game_time);
CREATE INDEX custody_episodes_booking_officer_idx ON game.custody_episodes USING btree (booking_officer_id);
CREATE INDEX custody_episodes_case_idx ON game.custody_episodes USING btree (case_id, booked_at_game_time);
CREATE INDEX custody_episodes_command_idx ON game.custody_episodes USING btree (source_command_id);
CREATE INDEX custody_episodes_person_idx ON game.custody_episodes USING btree (person_id);
CREATE INDEX custody_events_actor_idx ON game.custody_events USING btree (actor_personnel_id);
CREATE INDEX custody_events_command_idx ON game.custody_events USING btree (source_command_id);
CREATE INDEX custody_events_episode_idx ON game.custody_events USING btree (custody_episode_id, event_at_game_time);
CREATE INDEX custody_property_command_idx ON game.custody_property USING btree (source_command_id);
CREATE INDEX custody_property_episode_idx ON game.custody_property USING btree (custody_episode_id);
CREATE INDEX custody_property_evidence_idx ON game.custody_property USING btree (evidence_id);
CREATE INDEX custody_property_officer_idx ON game.custody_property USING btree (recorded_by_personnel_id);
CREATE INDEX custody_welfare_command_idx ON game.custody_welfare_checks USING btree (source_command_id);
CREATE INDEX custody_welfare_episode_idx ON game.custody_welfare_checks USING btree (custody_episode_id, checked_at_game_time);
CREATE INDEX custody_welfare_officer_idx ON game.custody_welfare_checks USING btree (officer_personnel_id);

CREATE OR REPLACE FUNCTION game.execute_arrest_custody_command(p_command_id uuid, p_type text, p jsonb, p_actor_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare n timestamptz; v_arrival timestamptz; v_minutes integer; v_arrest game.arrests%rowtype; ce game.custody_episodes%rowtype; v_person_id uuid;v_case_id uuid;inc_id uuid;target_id uuid;result jsonb;ev uuid;prop_id uuid;actor_ref text;
begin
 select current_game_time into n from game.simulation_state where id=1 for update;
 if n is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before arrest or custody operations.');end if;
 actor_ref:= (select personnel_ref from game.police_personnel where id=p_actor_id);
 if p_type='execute_arrest' then
  select c.id into v_case_id from game.cases c where c.case_ref=p->>'case_ref' and c.status='open';
  select pe.id into v_person_id from game.persons pe where pe.person_ref=p->>'person_ref';
  if v_case_id is null or v_person_id is null then return jsonb_build_object('ok',false,'code','case_or_person_not_found');end if;
  if not exists(select 1 from game.case_persons cp where cp.case_id=v_case_id and cp.person_id=v_person_id and cp.case_role in ('suspect','person_of_interest')) then return jsonb_build_object('ok',false,'code','person_not_linked_as_suspect','message','Person must already be linked to the case as a suspect or person of interest.');end if;
  if not exists(select 1 from game.case_assignments ca where ca.case_id=v_case_id and ca.personnel_id=p_actor_id and ca.status='active' and ca.released_at is null) and not exists(select 1 from game.cases c where c.id=v_case_id and c.lead_personnel_id=p_actor_id) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  if nullif(btrim(p->>'grounds'),'') is null or nullif(btrim(p->>'location'),'') is null or nullif(btrim(p->>'warnings'),'') is null then return jsonb_build_object('ok',false,'code','arrest_record_incomplete');end if;
  if p->>'basis' not in ('warrant','grounds','other') or (p->>'basis'='warrant' and nullif(btrim(p->>'authority_reference'),'') is null) then return jsonb_build_object('ok',false,'code','arrest_basis_invalid');end if;
  if exists(select 1 from game.arrests where game.arrests.case_id=v_case_id and game.arrests.person_id=v_person_id and status in ('arrested','transporting','booked')) then return jsonb_build_object('ok',false,'code','active_arrest_exists');end if;
  insert into game.arrests(case_id,person_id,incident_id,arresting_personnel_id,arrest_basis,authority_reference,grounds_description,arrest_location,arrested_at_game_time,force_used,injury_or_complaint,warnings_or_rights_record,witness_details,body_camera_reference,source_command_id)
  values(v_case_id,v_person_id,(select id from game.incidents where incident_ref=p->>'incident_ref'),p_actor_id,p->>'basis',nullif(p->>'authority_reference',''),p->>'grounds',p->>'location',n,coalesce(nullif(p->>'force',''),'none'),coalesce(nullif(p->>'injuries',''),'none_recorded'),p->>'warnings',nullif(p->>'witnesses',''),nullif(p->>'body_camera',''),p_command_id) returning * into v_arrest;
  insert into game.arrest_events(arrest_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(v_arrest.id,'arrest_executed',p_actor_id,n,to_jsonb(v_arrest)-'id'-'source_command_id',p_command_id);
  return jsonb_build_object('ok',true,'arrest_ref',v_arrest.arrest_ref,'status',v_arrest.status);
 elsif p_type='transport_arrest' then
  select * into v_arrest from game.arrests where arrest_ref=p->>'arrest_ref' for update;
  if v_arrest.id is null or v_arrest.status<>'arrested' then return jsonb_build_object('ok',false,'code','arrest_not_transportable');end if;
  if v_arrest.arresting_personnel_id<>p_actor_id and not exists(select 1 from game.case_assignments ca where ca.case_id=v_arrest.case_id and ca.personnel_id=p_actor_id and ca.status='active' and ca.released_at is null) and not exists(select 1 from game.cases c where c.id=v_arrest.case_id and c.lead_personnel_id=p_actor_id) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  v_minutes:=coalesce((p->>'duration_minutes')::integer,0);
  if nullif(btrim(p->>'destination'),'') is null or nullif(btrim(p->>'vehicle'),'') is null or nullif(btrim(p->>'handover'),'') is null or v_minutes not between 1 and 240 then return jsonb_build_object('ok',false,'code','transport_details_incomplete','message','Destination, vehicle, handover and a 1–240 minute duration are required.');end if;
  v_arrival:=n+make_interval(mins=>v_minutes);
  insert into game.arrest_transport_legs(arrest_id,transporting_personnel_id,departure_location,destination_location,vehicle_description,departed_at_game_time,arrived_at_game_time,duration_minutes,handover_notes,source_command_id) values(v_arrest.id,p_actor_id,v_arrest.arrest_location,p->>'destination',p->>'vehicle',n,v_arrival,v_minutes,p->>'handover',p_command_id);
  update game.arrests set status='transporting' where id=v_arrest.id;
  update game.simulation_state set current_game_time=v_arrival,updated_at=now() where id=1;
  insert into game.game_clock_history(command_id,previous_game_time,resulting_game_time,advancement_minutes,reason) values(p_command_id,n,v_arrival,v_minutes,'Arrest transport: '||btrim(p->>'handover'));
  insert into game.arrest_events(arrest_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(v_arrest.id,'transport_arrived',p_actor_id,v_arrival,jsonb_build_object('destination',p->>'destination','vehicle',p->>'vehicle','handover',p->>'handover','duration_minutes',v_minutes),p_command_id);
  return jsonb_build_object('ok',true,'arrest_ref',v_arrest.arrest_ref,'status','transporting','departed_at',n,'arrived_at',v_arrival,'duration_minutes',v_minutes);
 elsif p_type='book_custody' then
  select * into v_arrest from game.arrests where arrest_ref=p->>'arrest_ref' for update;
  if v_arrest.id is null or v_arrest.status<>'transporting' then return jsonb_build_object('ok',false,'code','transport_arrival_required');end if;
  if v_arrest.arresting_personnel_id<>p_actor_id and not exists(select 1 from game.case_assignments ca where ca.case_id=v_arrest.case_id and ca.personnel_id=p_actor_id and ca.status='active' and ca.released_at is null) and not exists(select 1 from game.cases c where c.id=v_arrest.case_id and c.lead_personnel_id=p_actor_id) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  if nullif(btrim(p->>'identity_check'),'') is null or nullif(btrim(p->>'risk'),'') is null or nullif(btrim(p->>'health'),'') is null or nullif(btrim(p->>'cell'),'') is null then return jsonb_build_object('ok',false,'code','booking_details_incomplete');end if;
  insert into game.custody_episodes(arrest_id,case_id,person_id,booking_officer_id,booked_at_game_time,identity_check,risk_assessment,health_welfare_screen,medication_disclosure,safeguarding_notes,cell_location,source_command_id)
  values(v_arrest.id,v_arrest.case_id,v_arrest.person_id,p_actor_id,n,p->>'identity_check',p->>'risk',p->>'health',nullif(p->>'medication',''),nullif(p->>'safeguarding',''),p->>'cell',p_command_id) returning * into ce;
  update game.arrests set status='booked' where id=v_arrest.id;
  insert into game.arrest_events(arrest_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(v_arrest.id,'custody_booking',p_actor_id,n,jsonb_build_object('custody_ref',ce.custody_ref,'cell',ce.cell_location),p_command_id);
  return jsonb_build_object('ok',true,'custody_ref',ce.custody_ref,'arrest_ref',v_arrest.arrest_ref,'status',ce.status);
 elsif p_type='record_custody_property' then
  select * into ce from game.custody_episodes where custody_ref=p->>'custody_ref' for update;
  if ce.id is null or ce.status<>'in_custody' then return jsonb_build_object('ok',false,'code','custody_not_active');end if;
  if ce.booking_officer_id<>p_actor_id and not exists(select 1 from game.case_assignments ca where ca.case_id=ce.case_id and ca.personnel_id=p_actor_id and ca.status='active' and ca.released_at is null) and not exists(select 1 from game.cases c where c.id=ce.case_id and c.lead_personnel_id=p_actor_id) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  if nullif(btrim(p->>'item'),'') is null or nullif(btrim(p->>'condition'),'') is null or p->>'disposition' not in ('stored','retained_as_evidence','returned','transferred') then return jsonb_build_object('ok',false,'code','property_details_invalid');end if;
  if p->>'disposition'='retained_as_evidence' then
   insert into game.evidence_items(evidence_ref,case_id,collected_by_personnel_id,evidence_type,description,collected_at,collection_location,current_status,storage_location,metadata)
   values('KWE-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),ce.case_id,p_actor_id,'custody_property',p->>'item',n,'Custody booking','held',coalesce(nullif(p->>'storage',''),'Evidence Store'),jsonb_build_object('source','custody_property','custody_ref',ce.custody_ref,'condition',p->>'condition')) returning id into ev;
  end if;
  insert into game.custody_property(custody_episode_id,recorded_by_personnel_id,item_description,condition_description,disposition,storage_location,evidence_id,recorded_at_game_time,source_command_id)
  values(ce.id,p_actor_id,p->>'item',p->>'condition',p->>'disposition',nullif(p->>'storage',''),ev,n,p_command_id) returning id into prop_id;
  return jsonb_build_object('ok',true,'property_ref',(select property_ref from game.custody_property where id=prop_id),'evidence_id',ev);
 elsif p_type='custody_check' then
  select * into ce from game.custody_episodes where custody_ref=p->>'custody_ref';
  if ce.id is null or ce.status<>'in_custody' then return jsonb_build_object('ok',false,'code','custody_not_active');end if;
  if ce.booking_officer_id<>p_actor_id and not exists(select 1 from game.case_assignments ca where ca.case_id=ce.case_id and ca.personnel_id=p_actor_id and ca.status='active' and ca.released_at is null) and not exists(select 1 from game.cases c where c.id=ce.case_id and c.lead_personnel_id=p_actor_id) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  if p->>'check_type' not in ('welfare','health','risk','observation') or nullif(btrim(p->>'observation'),'') is null then return jsonb_build_object('ok',false,'code','check_details_invalid');end if;
  insert into game.custody_welfare_checks(custody_episode_id,check_type,officer_personnel_id,checked_at_game_time,observation,escalation,source_command_id) values(ce.id,p->>'check_type',p_actor_id,n,p->>'observation',nullif(p->>'escalation',''),p_command_id);
  return jsonb_build_object('ok',true,'custody_ref',ce.custody_ref,'check_type',p->>'check_type');
 elsif p_type='custody_event' then
  select * into ce from game.custody_episodes where custody_ref=p->>'custody_ref';
  if ce.id is null or ce.status<>'in_custody' then return jsonb_build_object('ok',false,'code','custody_not_active');end if;
  if ce.booking_officer_id<>p_actor_id and not exists(select 1 from game.case_assignments ca where ca.case_id=ce.case_id and ca.personnel_id=p_actor_id and ca.status='active' and ca.released_at is null) and not exists(select 1 from game.cases c where c.id=ce.case_id and c.lead_personnel_id=p_actor_id) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  if nullif(btrim(p->>'details'),'') is null then return jsonb_build_object('ok',false,'code','event_details_required');end if;
  insert into game.custody_events(custody_episode_id,event_type,actor_personnel_id,event_at_game_time,details,source_command_id) values(ce.id,p->>'event_type',p_actor_id,n,p->>'details',p_command_id);
  return jsonb_build_object('ok',true,'custody_ref',ce.custody_ref,'event_type',p->>'event_type');
 elsif p_type in ('release_custody','transfer_custody') then
  select * into ce from game.custody_episodes where custody_ref=p->>'custody_ref' for update;
  if ce.id is null or ce.status<>'in_custody' then return jsonb_build_object('ok',false,'code','custody_not_active');end if;
  if ce.booking_officer_id<>p_actor_id and not exists(select 1 from game.case_assignments ca where ca.case_id=ce.case_id and ca.personnel_id=p_actor_id and ca.status='active' and ca.released_at is null) and not exists(select 1 from game.cases c where c.id=ce.case_id and c.lead_personnel_id=p_actor_id) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  if nullif(btrim(p->>'reason'),'') is null then return jsonb_build_object('ok',false,'code','final_reason_required');end if;
  if p_type='transfer_custody' and nullif(btrim(p->>'destination'),'') is null then return jsonb_build_object('ok',false,'code','transfer_destination_required');end if;
  update game.custody_episodes set status=case when p_type='release_custody' then 'released' else 'transferred' end,release_or_transfer_at_game_time=n,final_outcome=case when p_type='release_custody' then coalesce(p->>'outcome','released') else 'transferred' end,final_reason=p->>'reason' where id=ce.id;
  update game.arrests set status=case when p_type='release_custody' then 'released' else 'transferred' end where id=ce.arrest_id;
  insert into game.custody_events(custody_episode_id,event_type,actor_personnel_id,event_at_game_time,details,source_command_id) values(ce.id,case when p_type='release_custody' then 'handover' else 'handover' end,p_actor_id,n,case when p_type='release_custody' then 'Released: '||(p->>'outcome')||'. '||(p->>'reason') else 'Transferred to '||(p->>'destination')||'. '||(p->>'reason') end,p_command_id);
  insert into game.arrest_events(arrest_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(ce.arrest_id,case when p_type='release_custody' then 'released' else 'transferred' end,p_actor_id,n,jsonb_build_object('outcome',p->>'outcome','destination',p->>'destination','reason',p->>'reason'),p_command_id);
  return jsonb_build_object('ok',true,'custody_ref',ce.custody_ref,'status',case when p_type='release_custody' then 'released' else 'transferred' end);
 elsif p_type='get_case_arrests' then
  if not exists(select 1 from game.cases c where c.case_ref=p->>'case_ref' and (c.lead_personnel_id=p_actor_id or exists(select 1 from game.case_assignments ca where ca.case_id=c.id and ca.personnel_id=p_actor_id and ca.status='active' and ca.released_at is null))) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  return jsonb_build_object('ok',true,'arrests',(select coalesce(jsonb_agg(jsonb_build_object('arrest_ref',ar.arrest_ref,'person_ref',pe.person_ref,'status',ar.status,'basis',ar.arrest_basis,'grounds',ar.grounds_description,'location',ar.arrest_location,'arrested_at',ar.arrested_at_game_time,'transport',(select jsonb_agg(to_jsonb(t)-'id' order by t.departed_at_game_time) from game.arrest_transport_legs t where t.arrest_id=ar.id),'custody',(select to_jsonb(cu)-'id' from game.custody_episodes cu where cu.arrest_id=ar.id),'events',(select jsonb_agg(to_jsonb(ae)-'id' order by ae.event_at_game_time) from game.arrest_events ae where ae.arrest_id=ar.id)) order by ar.arrested_at_game_time),'[]'::jsonb) from game.arrests ar join game.persons pe on pe.id=ar.person_id where ar.case_id=(select id from game.cases where case_ref=p->>'case_ref')));
 end if;
 return jsonb_build_object('ok',false,'code','unsupported_command');
end $function$


CREATE OR REPLACE FUNCTION game.interpret_arrest_custody_command(p_command_text text)
 RETURNS jsonb
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare t text:=btrim(coalesce(p_command_text,''));m text[];
begin
 m:=regexp_match(t,'^arrest execute ([^[:space:]]+) person ([^[:space:]]+) by ([^[:space:]]+) basis ([^[:space:]]+) location "([^"]+)" grounds "([^"]+)" force "([^"]+)" injuries "([^"]+)" warnings "([^"]+)"(?: authority "([^"]+)")?(?: witnesses "([^"]+)")?(?: body_camera "([^"]+)")?(?: incident ([^[:space:]]+))?$','i');
 if m is not null then return jsonb_build_object('command_type','execute_arrest','payload',jsonb_build_object('case_ref',m[1],'person_ref',m[2],'actor_ref',m[3],'basis',lower(m[4]),'location',m[5],'grounds',m[6],'force',m[7],'injuries',m[8],'warnings',m[9],'authority_reference',m[10],'witnesses',m[11],'body_camera',m[12],'incident_ref',m[13]));end if;
 m:=regexp_match(t,'^arrest transport ([^[:space:]]+) by ([^[:space:]]+) to "([^"]+)" vehicle "([^"]+)" handover "([^"]+)" duration ([0-9]+) minutes$','i');
 if m is not null then return jsonb_build_object('command_type','transport_arrest','payload',jsonb_build_object('arrest_ref',m[1],'actor_ref',m[2],'destination',m[3],'vehicle',m[4],'handover',m[5],'duration_minutes',m[6]));end if;
 m:=regexp_match(t,'^custody book ([^[:space:]]+) by ([^[:space:]]+) identity "([^"]+)" risk "([^"]+)" health "([^"]+)" cell "([^"]+)"(?: medication "([^"]+)")?(?: safeguarding "([^"]+)")?$','i');
 if m is not null then return jsonb_build_object('command_type','book_custody','payload',jsonb_build_object('arrest_ref',m[1],'actor_ref',m[2],'identity_check',m[3],'risk',m[4],'health',m[5],'cell',m[6],'medication',m[7],'safeguarding',m[8]));end if;
 m:=regexp_match(t,'^custody property ([^[:space:]]+) by ([^[:space:]]+) item "([^"]+)" condition "([^"]+)" disposition ([^[:space:]]+)(?: storage "([^"]+)")?$','i');
 if m is not null then return jsonb_build_object('command_type','record_custody_property','payload',jsonb_build_object('custody_ref',m[1],'actor_ref',m[2],'item',m[3],'condition',m[4],'disposition',lower(m[5]),'storage',m[6]));end if;
 m:=regexp_match(t,'^custody check ([^[:space:]]+) by ([^[:space:]]+) type ([^[:space:]]+) observation "([^"]+)"(?: escalation "([^"]+)")?$','i');
 if m is not null then return jsonb_build_object('command_type','custody_check','payload',jsonb_build_object('custody_ref',m[1],'actor_ref',m[2],'check_type',lower(m[3]),'observation',m[4],'escalation',m[5]));end if;
 m:=regexp_match(t,'^custody event ([^[:space:]]+) by ([^[:space:]]+) type ([^[:space:]]+) details "([^"]+)"$','i');
 if m is not null then return jsonb_build_object('command_type','custody_event','payload',jsonb_build_object('custody_ref',m[1],'actor_ref',m[2],'event_type',lower(m[3]),'details',m[4]));end if;
 m:=regexp_match(t,'^custody release ([^[:space:]]+) by ([^[:space:]]+) outcome ([^[:space:]]+) because "([^"]+)"$','i');
 if m is not null then return jsonb_build_object('command_type','release_custody','payload',jsonb_build_object('custody_ref',m[1],'actor_ref',m[2],'outcome',lower(m[3]),'reason',m[4]));end if;
 m:=regexp_match(t,'^custody transfer ([^[:space:]]+) by ([^[:space:]]+) to "([^"]+)" because "([^"]+)"$','i');
 if m is not null then return jsonb_build_object('command_type','transfer_custody','payload',jsonb_build_object('custody_ref',m[1],'actor_ref',m[2],'destination',m[3],'reason',m[4]));end if;
 m:=regexp_match(t,'^case arrests ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','get_case_arrests','payload',jsonb_build_object('case_ref',m[1],'actor_ref',m[2]));end if;
 return null;
end $function$


CREATE OR REPLACE FUNCTION game.reject_custody_history_mutation()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'game'
AS $function$
begin raise exception 'Arrest and custody history is append-only; record a new event instead.';end $function$


alter function game.interpret_text_command(text) rename to interpret_text_command_before_arrest_custody;
alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_arrest_custody;

CREATE OR REPLACE FUNCTION game.interpret_text_command(p_command_text text)
 RETURNS jsonb
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare r jsonb;
begin r:=game.interpret_arrest_custody_command(p_command_text);if r is not null then return r;end if;return game.interpret_text_command_before_arrest_custody(p_command_text);end $function$


CREATE OR REPLACE FUNCTION game.execute_text_command(p_command_text text, p_idempotency_key text, p_session_id uuid DEFAULT NULL::uuid, p_actor_personnel_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare i jsonb;typ text;d jsonb;cmd game.game_commands%rowtype;actor game.police_personnel%rowtype;res jsonb;
begin
 i:=game.interpret_text_command(p_command_text);typ:=i->>'command_type';d:=coalesce(i->'payload','{}'::jsonb);
 if typ='help' then res:=game.execute_text_command_before_arrest_custody(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);return jsonb_set(res,'{available_commands}',(select coalesce(jsonb_agg(distinct x),'[]') from jsonb_array_elements_text(coalesce(res->'available_commands','[]')||jsonb_build_array('execute_arrest','transport_arrest','book_custody','record_custody_property','custody_check','custody_event','release_custody','transfer_custody','get_case_arrests'))x),true);end if;
 if typ not in ('execute_arrest','transport_arrest','book_custody','record_custody_property','custody_check','custody_event','release_custody','transfer_custody','get_case_arrests') then return game.execute_text_command_before_arrest_custody(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key is required';end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload) values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,typ,d) on conflict(idempotency_key) do nothing;
 if not found then select * into cmd from game.game_commands where idempotency_key=p_idempotency_key for update;if cmd.command_text<>p_command_text or cmd.command_type<>typ or cmd.payload<>d then return jsonb_build_object('ok',false,'code','idempotency_conflict');end if;return coalesce(cmd.result,jsonb_build_object('ok',cmd.status='completed'))||jsonb_build_object('duplicate',true);end if;
 select * into cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 select * into actor from game.police_personnel where personnel_ref=d->>'actor_ref' and employment_status in ('active','seconded');
 if actor.id is null or (p_actor_personnel_id is not null and p_actor_personnel_id<>actor.id) then res:=jsonb_build_object('ok',false,'code','actor_mismatch');else res:=game.execute_arrest_custody_command(cmd.id,typ,d,actor.id);end if;
 if coalesce((res->>'ok')::boolean,false) then res:=res||jsonb_build_object('status','completed','command_id',cmd.id);update game.game_commands set status='completed',result=res,completed_at=now() where id=cmd.id;else update game.game_commands set status='rejected',result=res,rejection_reason=coalesce(res->>'message','Arrest/custody command rejected'),completed_at=now() where id=cmd.id;res:=res||jsonb_build_object('command_id',cmd.id);end if;return res;
end $function$


CREATE OR REPLACE FUNCTION game.get_case_review_dossier(p_case_ref text)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare v_case game.cases%rowtype; v_result jsonb; v_lead_ref text;
begin
 select * into v_case from game.cases where case_ref=btrim(p_case_ref);
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference not found.'); end if;
 select pp.personnel_ref into v_lead_ref from game.police_personnel pp where pp.id=v_case.lead_personnel_id;

 select jsonb_build_object(
  'ok',true,'dossier_version','1.0','generated_at',now(),
  'case',jsonb_build_object('case_ref',v_case.case_ref,'title',v_case.case_title,'type',v_case.case_type,'status',v_case.status,'summary',v_case.summary,'opened_at',v_case.opened_at,'closed_at',v_case.closed_at,'lead_personnel_ref',v_lead_ref,'case_data',v_case.case_data),
  'supervisory_reviews',(select coalesce(jsonb_agg(jsonb_build_object('review_ref',r.review_ref,'outcome',r.outcome,'reason',r.review_reason,'reviewed_by',pp.personnel_ref,'reviewed_at_game_time',r.reviewed_at_game_time) order by r.reviewed_at_game_time,r.created_at),'[]'::jsonb) from game.case_supervisory_reviews r join game.police_personnel pp on pp.id=r.reviewed_by_personnel_id where r.case_id=v_case.id),
  'status_history',(select coalesce(jsonb_agg(jsonb_build_object('event_ref',e.event_ref,'previous_status',e.previous_status,'new_status',e.new_status,'reason',e.reason,'changed_by',pp.personnel_ref,'changed_at_game_time',e.changed_at_game_time) order by e.changed_at_game_time,e.created_at),'[]'::jsonb) from game.case_status_events e join game.police_personnel pp on pp.id=e.changed_by_personnel_id where e.case_id=v_case.id),
  'assignments',(select coalesce(jsonb_agg(jsonb_build_object('personnel_ref',pp.personnel_ref,'name',concat_ws(' ',p.given_name,p.middle_names,p.family_name),'role',a.assignment_role,'status',a.status,'assigned_at',a.assigned_at,'released_at',a.released_at,'history',(select coalesce(jsonb_agg(jsonb_build_object('event_type',e.event_type,'at',e.event_at_game_time,'actor',ap.personnel_ref,'data',e.event_data) order by e.event_at_game_time,e.created_at),'[]'::jsonb) from game.case_assignment_events e join game.police_personnel ap on ap.id=e.actor_personnel_id where e.assignment_id=a.id)) order by a.assigned_at,a.id),'[]'::jsonb) from game.case_assignments a join game.police_personnel pp on pp.id=a.personnel_id join game.persons p on p.id=pp.person_id where a.case_id=v_case.id),
  'incidents',(select coalesce(jsonb_agg(jsonb_build_object('incident_ref',i.incident_ref,'relationship',ci.relationship_type,'type_id',i.incident_type_id,'reported_at',i.reported_at,'occurred_from',i.occurred_from,'occurred_to',i.occurred_to,'location',i.location_description,'priority',i.priority,'status',i.status,'summary',i.summary) order by i.reported_at),'[]'::jsonb) from game.case_incidents ci join game.incidents i on i.id=ci.incident_id where ci.case_id=v_case.id),
  'people',(select coalesce(jsonb_agg(jsonb_build_object('person_ref',p.person_ref,'name',concat_ws(' ',p.given_name,p.middle_names,p.family_name),'role',cp.case_role,'notes',cp.notes) order by cp.case_role,p.family_name,p.given_name),'[]'::jsonb) from game.case_persons cp join game.persons p on p.id=cp.person_id where cp.case_id=v_case.id),
  'tasks',(select coalesce(jsonb_agg(jsonb_build_object('task_ref',t.task_ref,'type',t.task_type,'title',t.title,'description',t.description,'priority',t.priority,'status',t.status,'assigned_to',ap.personnel_ref,'created_by',cp.personnel_ref,'created_at',t.created_at_game_time,'due_at',t.due_at_game_time,'completed_at',t.completed_at_game_time,'outcome',t.outcome,'updated_at',t.updated_at_game_time,'updated_by',up.personnel_ref) order by t.created_at_game_time,t.task_ref),'[]'::jsonb) from game.case_tasks t left join game.police_personnel ap on ap.id=t.assigned_personnel_id left join game.police_personnel cp on cp.id=t.created_by_personnel_id left join game.police_personnel up on up.id=t.updated_by_personnel_id where t.case_id=v_case.id),
  'leads',(select coalesce(jsonb_agg(jsonb_build_object('lead_ref',l.lead_ref,'title',l.title,'description',l.description,'source_type',l.source_type,'source_reference',l.source_reference,'assigned_to',ap.personnel_ref,'status',l.status,'priority',l.priority,'confidence',l.confidence,'assessment_reason',l.assessment_reason,'created_at',l.created_at_game_time,'updated_at',l.updated_at_game_time,
    'events',(select coalesce(jsonb_agg(jsonb_build_object('event_type',e.event_type,'at',e.event_at_game_time,'actor',ep.personnel_ref,'data',e.event_data) order by e.event_at_game_time,e.created_at),'[]'::jsonb) from game.case_lead_events e join game.police_personnel ep on ep.id=e.actor_personnel_id where e.lead_id=l.id),
    'enquiries',(select coalesce(jsonb_agg(jsonb_build_object('enquiry_ref',q.enquiry_ref,'method',q.method,'action',q.action,'result',q.result,'outcome',q.outcome,'source_reference',q.source_reference,'conducted_by',cp.personnel_ref,'conducted_at',q.conducted_at_game_time,'recorded_by',rp.personnel_ref,'events',(select coalesce(jsonb_agg(jsonb_build_object('event_type',qe.event_type,'at',qe.event_at_game_time,'actor',qep.personnel_ref,'data',qe.event_data) order by qe.event_at_game_time,qe.created_at),'[]'::jsonb) from game.case_enquiry_events qe join game.police_personnel qep on qep.id=qe.actor_personnel_id where qe.enquiry_id=q.id)) order by q.conducted_at_game_time),'[]'::jsonb) from game.case_enquiries q join game.police_personnel cp on cp.id=q.conducted_by_personnel_id join game.police_personnel rp on rp.id=q.recorded_by_personnel_id where q.lead_id=l.id),
    'entity_links',(select coalesce(jsonb_agg(jsonb_build_object('link_ref',x.link_ref,'entity_type',x.entity_type,'entity_ref',x.entity_ref,'reason',x.reason,'linked_by',lp.personnel_ref,'linked_at',x.linked_at_game_time) order by x.created_at),'[]'::jsonb) from game.case_lead_entity_links x join game.police_personnel lp on lp.id=x.linked_by_personnel_id where x.lead_id=l.id)
   ) order by l.created_at_game_time,l.created_at),'[]'::jsonb) from game.case_leads l left join game.police_personnel ap on ap.id=l.assigned_personnel_id where l.case_id=v_case.id),
  'interviews',(select coalesce(jsonb_agg(jsonb_build_object('interview_ref',iv.interview_ref,'interviewee',jsonb_build_object('person_ref',p.person_ref,'name',concat_ws(' ',p.given_name,p.middle_names,p.family_name)),'interviewer',ip.personnel_ref,'method',iv.method,'purpose',iv.purpose,'location',iv.location_description,'notes',iv.notes,'started_at',iv.started_at_game_time,'suspect_interview',exists(select 1 from game.case_suspect_interview_records sr where sr.interview_id=iv.id),'suspect_classification',(select jsonb_build_object('reason',sr.reason,'recorded_by',sp.personnel_ref,'recorded_at',sr.recorded_at_game_time) from game.case_suspect_interview_records sr join game.police_personnel sp on sp.id=sr.recorded_by_personnel_id where sr.interview_id=iv.id),
    'events',(select coalesce(jsonb_agg(jsonb_build_object('event_type',e.event_type,'at',e.event_at_game_time,'reason',e.reason,'actor',ep.personnel_ref) order by e.event_at_game_time,e.created_at),'[]'::jsonb) from game.case_interview_events e join game.police_personnel ep on ep.id=e.actor_personnel_id where e.interview_id=iv.id),
    'turns',(select coalesce(jsonb_agg(jsonb_build_object('turn_ref',t.turn_ref,'number',t.turn_number,'question',t.question_text,'answer',t.answer_text,'recorded_by',tp.personnel_ref,'recorded_at',t.recorded_at_game_time,'suspect_response_assessments',(select coalesce(jsonb_agg(jsonb_build_object('assessment',a.response_assessment,'reason',a.assessment_reason,'assessed_by',ap2.personnel_ref,'at',a.assessed_at_game_time) order by a.assessed_at_game_time,a.created_at),'[]'::jsonb) from game.case_suspect_interview_assessments a join game.police_personnel ap2 on ap2.id=a.assessed_by_personnel_id where a.turn_id=t.id)) order by t.turn_number),'[]'::jsonb) from game.case_interview_turns t join game.police_personnel tp on tp.id=t.recorded_by_personnel_id where t.interview_id=iv.id),
    'linked_statements',(select coalesce(jsonb_agg(jsonb_build_object('statement_ref',s.statement_ref,'form',s.statement_form,'recorded_at',s.recorded_at_game_time,'statement_text',s.statement_text,'outcomes',(select coalesce(jsonb_agg(jsonb_build_object('event_type',se.event_type,'at',se.event_at_game_time,'reason',se.reason,'actor',sep.personnel_ref) order by se.event_at_game_time,se.created_at),'[]'::jsonb) from game.case_witness_statement_events se join game.police_personnel sep on sep.id=se.actor_personnel_id where se.statement_id=s.id)) order by s.recorded_at_game_time),'[]'::jsonb) from game.case_witness_statements s where s.interview_id=iv.id)
   ) order by iv.started_at_game_time,iv.created_at),'[]'::jsonb) from game.case_interviews iv join game.persons p on p.id=iv.interviewee_person_id join game.police_personnel ip on ip.id=iv.interviewer_personnel_id where iv.case_id=v_case.id),
  'witness_statements',(select coalesce(jsonb_agg(jsonb_build_object('statement_ref',s.statement_ref,'witness',wp.person_ref,'witness_name',concat_ws(' ',wp.given_name,wp.middle_names,wp.family_name),'interview_ref',iv.interview_ref,'form',s.statement_form,'text',s.statement_text,'supplements',prior.statement_ref,'recorded_by',rp.personnel_ref,'recorded_at',s.recorded_at_game_time,'events',(select coalesce(jsonb_agg(jsonb_build_object('event_type',e.event_type,'at',e.event_at_game_time,'reason',e.reason,'actor',ep.personnel_ref) order by e.event_at_game_time,e.created_at),'[]'::jsonb) from game.case_witness_statement_events e join game.police_personnel ep on ep.id=e.actor_personnel_id where e.statement_id=s.id)) order by s.recorded_at_game_time),'[]'::jsonb) from game.case_witness_statements s join game.persons wp on wp.id=s.witness_person_id join game.police_personnel rp on rp.id=s.recorded_by_personnel_id left join game.case_interviews iv on iv.id=s.interview_id left join game.case_witness_statements prior on prior.id=s.supplements_statement_id where s.case_id=v_case.id),
  'account_comparisons',game.get_case_account_comparisons(v_case.case_ref,null)->'comparisons',
  'evidence',(select coalesce(jsonb_agg(jsonb_build_object('evidence_ref',e.evidence_ref,'type',e.evidence_type,'description',e.description,'collected_at',e.collected_at,'collected_by',cp.personnel_ref,'collection_location',e.collection_location,'status',e.current_status,'storage_location',e.storage_location,'metadata',e.metadata,
    'transfers',(select coalesce(jsonb_agg(jsonb_build_object('transferred_at',tr.transferred_at,'from_personnel',fp.personnel_ref,'to_personnel',tp.personnel_ref,'from_location',tr.from_location,'to_location',tr.to_location,'reason',tr.transfer_reason,'notes',tr.notes) order by tr.transferred_at,tr.id),'[]'::jsonb) from game.evidence_transfers tr left join game.police_personnel fp on fp.id=tr.from_personnel_id left join game.police_personnel tp on tp.id=tr.to_personnel_id where tr.evidence_id=e.id),
    'forensic_requests',(select coalesce(jsonb_agg(jsonb_build_object('request_ref',fr.request_ref,'discipline',fr.discipline,'question',fr.examination_question,'scope',fr.scope,'priority',fr.priority,'status',fr.status,'triage_decision',fr.triage_decision,'triage_notes',fr.triage_notes,'submitted_at',fr.submitted_at,'examinations',(select coalesce(jsonb_agg(jsonb_build_object('examination_ref',fx.examination_ref,'method_version',fx.method_version_snapshot,'question',fx.examination_question,'scope',fx.scope,'status',fx.status,'assigned_at',fx.assigned_at,'started_at',fx.started_at,'completed_at',fx.completed_at,'findings',(select coalesce(jsonb_agg(jsonb_build_object('finding_ref',ff.finding_ref,'version',ff.version_number,'observations',ff.observations,'interpretation',ff.interpretation,'propositions',ff.propositions,'limitations',ff.limitations,'outcome',ff.outcome,'recorded_at',ff.recorded_at,'reviews',(select coalesce(jsonb_agg(jsonb_build_object('review_ref',rv.review_ref,'type',rv.review_type,'decision',rv.decision,'notes',rv.review_notes,'reviewed_at',rv.reviewed_at) order by rv.reviewed_at),'[]'::jsonb) from game.forensic_reviews rv where rv.finding_id=ff.id)) order by ff.version_number),'[]'::jsonb) from game.forensic_findings ff where ff.examination_id=fx.id)) order by fx.assigned_at),'[]'::jsonb) from game.forensic_examinations fx where fx.request_id=fr.id),
    'reports',(select coalesce(jsonb_agg(jsonb_build_object('report_ref',rp.report_ref,'version',rp.version_number,'summary',rp.report_summary,'body',rp.report_body,'status',rp.status,'issued_at',rp.issued_at) order by rp.version_number),'[]'::jsonb) from game.forensic_reports rp where rp.request_id=fr.id)
   ) order by fr.created_at),'[]'::jsonb) from game.forensic_requests fr where fr.case_id=v_case.id and exists(select 1 from game.forensic_request_items ri where ri.request_id=fr.id and ri.evidence_id=e.id))
   ) order by e.collected_at,e.evidence_ref),'[]'::jsonb) from game.evidence_items e left join game.police_personnel cp on cp.id=e.collected_by_personnel_id where e.case_id=v_case.id or exists(select 1 from game.case_account_comparison_evidence_links cel where cel.case_id=v_case.id and cel.evidence_id=e.id) or exists(select 1 from game.case_lead_entity_links lel where lel.case_id=v_case.id and lel.evidence_id=e.id) or exists(select 1 from game.forensic_request_items fri join game.forensic_requests frx on frx.id=fri.request_id where frx.case_id=v_case.id and fri.evidence_id=e.id)),
  'activities',game.get_case_activity(v_case.case_ref,500)->'activities',
  'surveillance_operations',game.get_surveillance_operations(v_case.case_ref,100)->'operations',
  'search_operations',game.get_search_operations(v_case.id)->'operations',
  'arrests',(select coalesce(jsonb_agg(jsonb_build_object(
    'arrest_ref',a.arrest_ref,'person_ref',p.person_ref,'person_name',concat_ws(' ',p.given_name,p.middle_names,p.family_name),
    'basis',a.arrest_basis,'authority_reference',a.authority_reference,'grounds',a.grounds_description,'location',a.arrest_location,
    'arrested_at',a.arrested_at_game_time,'force_used',a.force_used,'injury_or_complaint',a.injury_or_complaint,
    'warnings_or_rights_record',a.warnings_or_rights_record,'witness_details',a.witness_details,'body_camera_reference',a.body_camera_reference,'status',a.status,
    'arresting_officer',ap.personnel_ref,
    'transport',(select coalesce(jsonb_agg(jsonb_build_object('transport_ref',tr.transport_ref,'officer',tp.personnel_ref,'from',tr.departure_location,'to',tr.destination_location,'vehicle',tr.vehicle_description,'departed_at',tr.departed_at_game_time,'arrived_at',tr.arrived_at_game_time,'handover',tr.handover_notes) order by tr.departed_at_game_time),'[]'::jsonb) from game.arrest_transport_legs tr join game.police_personnel tp on tp.id=tr.transporting_personnel_id where tr.arrest_id=a.id),
    'custody',(select jsonb_build_object('custody_ref',cu.custody_ref,'status',cu.status,'booked_at',cu.booked_at_game_time,'identity_check',cu.identity_check,'risk_assessment',cu.risk_assessment,'health_welfare_screen',cu.health_welfare_screen,'medication_disclosure',cu.medication_disclosure,'safeguarding_notes',cu.safeguarding_notes,'cell_location',cu.cell_location,'final_outcome',cu.final_outcome,'final_reason',cu.final_reason,
      'property',(select coalesce(jsonb_agg(jsonb_build_object('property_ref',pr.property_ref,'item',pr.item_description,'condition',pr.condition_description,'disposition',pr.disposition,'storage',pr.storage_location,'evidence_ref',ei.evidence_ref) order by pr.recorded_at_game_time),'[]'::jsonb) from game.custody_property pr left join game.evidence_items ei on ei.id=pr.evidence_id where pr.custody_episode_id=cu.id),
      'welfare_checks',(select coalesce(jsonb_agg(jsonb_build_object('type',wc.check_type,'officer',wp.personnel_ref,'at',wc.checked_at_game_time,'observation',wc.observation,'escalation',wc.escalation) order by wc.checked_at_game_time),'[]'::jsonb) from game.custody_welfare_checks wc join game.police_personnel wp on wp.id=wc.officer_personnel_id where wc.custody_episode_id=cu.id),
      'events',(select coalesce(jsonb_agg(jsonb_build_object('type',ce.event_type,'officer',ep.personnel_ref,'at',ce.event_at_game_time,'details',ce.details) order by ce.event_at_game_time),'[]'::jsonb) from game.custody_events ce join game.police_personnel ep on ep.id=ce.actor_personnel_id where ce.custody_episode_id=cu.id)
    ) from game.custody_episodes cu where cu.arrest_id=a.id),
    'events',(select coalesce(jsonb_agg(jsonb_build_object('type',ae.event_type,'officer',ep.personnel_ref,'at',ae.event_at_game_time,'data',ae.event_data) order by ae.event_at_game_time),'[]'::jsonb) from game.arrest_events ae join game.police_personnel ep on ep.id=ae.actor_personnel_id where ae.arrest_id=a.id)
  ) order by a.arrested_at_game_time),'[]'::jsonb) from game.arrests a join game.persons p on p.id=a.person_id join game.police_personnel ap on ap.id=a.arresting_personnel_id where a.case_id=v_case.id),
  'forensic_requests',(select coalesce(jsonb_agg(jsonb_build_object('request_ref',fr.request_ref,'discipline',fr.discipline,'question',fr.examination_question,'scope',fr.scope,'priority',fr.priority,'status',fr.status,'triage_decision',fr.triage_decision,'triage_notes',fr.triage_notes,'submitted_at',fr.submitted_at,'items',(select coalesce(jsonb_agg(jsonb_build_object('evidence_ref',e.evidence_ref,'context',ri.requested_context) order by e.evidence_ref),'[]'::jsonb) from game.forensic_request_items ri join game.evidence_items e on e.id=ri.evidence_id where ri.request_id=fr.id),'reports',(select coalesce(jsonb_agg(jsonb_build_object('report_ref',rp.report_ref,'version',rp.version_number,'summary',rp.report_summary,'body',rp.report_body,'status',rp.status,'issued_at',rp.issued_at) order by rp.version_number),'[]'::jsonb) from game.forensic_reports rp where rp.request_id=fr.id)) order by fr.created_at),'[]'::jsonb) from game.forensic_requests fr where fr.case_id=v_case.id)
 ) into v_result;
 return v_result;
end
$function$


CREATE TRIGGER arrest_events_append_only BEFORE DELETE OR UPDATE ON game.arrest_events FOR EACH ROW EXECUTE FUNCTION game.reject_custody_history_mutation();
CREATE TRIGGER arrest_transport_legs_append_only BEFORE DELETE OR UPDATE ON game.arrest_transport_legs FOR EACH ROW EXECUTE FUNCTION game.reject_custody_history_mutation();
CREATE TRIGGER custody_events_append_only BEFORE DELETE OR UPDATE ON game.custody_events FOR EACH ROW EXECUTE FUNCTION game.reject_custody_history_mutation();
CREATE TRIGGER custody_property_append_only BEFORE DELETE OR UPDATE ON game.custody_property FOR EACH ROW EXECUTE FUNCTION game.reject_custody_history_mutation();
CREATE TRIGGER custody_welfare_checks_append_only BEFORE DELETE OR UPDATE ON game.custody_welfare_checks FOR EACH ROW EXECUTE FUNCTION game.reject_custody_history_mutation();

do $$ declare t text;begin foreach t in array array['arrests','arrest_events','arrest_transport_legs','custody_episodes','custody_property','custody_events','custody_welfare_checks'] loop execute format('alter table game.%I enable row level security',t);execute format('revoke all on game.%I from anon,authenticated',t);execute format('grant select,insert,update,delete on game.%I to service_role',t);end loop;end $$;
grant usage,select on all sequences in schema game to service_role;
revoke all on function game.reject_custody_history_mutation() from public,anon,authenticated;
revoke all on function game.execute_arrest_custody_command(uuid,text,jsonb,uuid) from public,anon,authenticated;
grant execute on function game.execute_arrest_custody_command(uuid,text,jsonb,uuid) to service_role;
revoke all on function game.interpret_arrest_custody_command(text) from public,anon,authenticated;
grant execute on function game.interpret_arrest_custody_command(text) to service_role;
revoke all on function game.interpret_text_command(text) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text) to service_role;
revoke all on function game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.execute_text_command(text,text,uuid,uuid) to service_role;
