
create sequence game.arrest_ref_seq;
create sequence game.arrest_transport_ref_seq;
create sequence game.custody_episode_ref_seq;
create sequence game.custody_property_ref_seq;

create table game.arrests(
 id uuid primary key default gen_random_uuid(),
 arrest_ref text not null unique default ('KWA-'||lpad(nextval('game.arrest_ref_seq')::text,7,'0')),
 case_id uuid not null references game.cases(id),
 person_id uuid not null references game.persons(id),
 incident_id uuid references game.incidents(id),
 arresting_personnel_id uuid not null references game.police_personnel(id),
 arrest_basis text not null check(arrest_basis in ('warrant','grounds','other')),
 authority_reference text,
 grounds_description text not null,
 arrest_location text not null,
 arrested_at_game_time timestamptz not null,
 force_used text not null default 'none',
 injury_or_complaint text not null default 'none_recorded',
 warnings_or_rights_record text not null,
 witness_details text,
 body_camera_reference text,
 status text not null default 'arrested' check(status in ('arrested','transporting','booked','released','transferred')),
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now(),
 check(arrest_basis<>'warrant' or nullif(btrim(authority_reference),'') is not null)
);
create table game.arrest_events(
 id uuid primary key default gen_random_uuid(),
 arrest_id uuid not null references game.arrests(id),
 event_type text not null,
 actor_personnel_id uuid not null references game.police_personnel(id),
 event_at_game_time timestamptz not null,
 event_data jsonb not null default '{}'::jsonb,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now()
);
create table game.arrest_transport_legs(
 id uuid primary key default gen_random_uuid(),
 transport_ref text not null unique default ('KWT-'||lpad(nextval('game.arrest_transport_ref_seq')::text,7,'0')),
 arrest_id uuid not null references game.arrests(id),
 transporting_personnel_id uuid not null references game.police_personnel(id),
 departure_location text not null,
 destination_location text not null,
 vehicle_description text not null,
 departed_at_game_time timestamptz not null,
 arrived_at_game_time timestamptz not null,
 handover_notes text not null,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now(),
 check(arrived_at_game_time>=departed_at_game_time)
);
create table game.custody_episodes(
 id uuid primary key default gen_random_uuid(),
 custody_ref text not null unique default ('KWC-'||lpad(nextval('game.custody_episode_ref_seq')::text,7,'0')),
 arrest_id uuid not null unique references game.arrests(id),
 case_id uuid not null references game.cases(id),
 person_id uuid not null references game.persons(id),
 booking_officer_id uuid not null references game.police_personnel(id),
 booked_at_game_time timestamptz not null,
 identity_check text not null,
 risk_assessment text not null,
 health_welfare_screen text not null,
 medication_disclosure text,
 safeguarding_notes text,
 cell_location text not null,
 status text not null default 'in_custody' check(status in ('in_custody','released','transferred')),
 release_or_transfer_at_game_time timestamptz,
 final_outcome text,
 final_reason text,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now(),
 check((status='in_custody' and release_or_transfer_at_game_time is null and final_outcome is null) or (status<>'in_custody' and release_or_transfer_at_game_time is not null and final_outcome is not null))
);
create table game.custody_property(
 id uuid primary key default gen_random_uuid(),
 property_ref text not null unique default ('KWP-'||lpad(nextval('game.custody_property_ref_seq')::text,7,'0')),
 custody_episode_id uuid not null references game.custody_episodes(id),
 recorded_by_personnel_id uuid not null references game.police_personnel(id),
 item_description text not null,
 condition_description text not null,
 disposition text not null check(disposition in ('stored','retained_as_evidence','returned','transferred')),
 storage_location text,
 evidence_id uuid references game.evidence_items(id),
 recorded_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now(),
 check((disposition='retained_as_evidence' and evidence_id is not null) or (disposition<>'retained_as_evidence' and evidence_id is null))
);
create table game.custody_events(
 id uuid primary key default gen_random_uuid(),
 custody_episode_id uuid not null references game.custody_episodes(id),
 event_type text not null check(event_type in ('risk_review','health_review','medication_disclosure','cell_change','meal','rest_period','interview_access','legal_counsel','visitor','use_of_force','incident','supervisor_review','handover','other')),
 actor_personnel_id uuid not null references game.police_personnel(id),
 event_at_game_time timestamptz not null,
 details text not null,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now()
);
create table game.custody_welfare_checks(
 id uuid primary key default gen_random_uuid(),
 custody_episode_id uuid not null references game.custody_episodes(id),
 check_type text not null check(check_type in ('welfare','health','risk','observation')),
 officer_personnel_id uuid not null references game.police_personnel(id),
 checked_at_game_time timestamptz not null,
 observation text not null,
 escalation text,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now()
);

create index arrests_case_idx on game.arrests(case_id,arrested_at_game_time);
create index arrests_person_idx on game.arrests(person_id,arrested_at_game_time);
create index arrests_incident_idx on game.arrests(incident_id);
create index arrests_officer_idx on game.arrests(arresting_personnel_id);
create index arrests_command_idx on game.arrests(source_command_id);
create index arrest_events_arrest_idx on game.arrest_events(arrest_id,event_at_game_time);
create index arrest_events_actor_idx on game.arrest_events(actor_personnel_id);
create index arrest_events_command_idx on game.arrest_events(source_command_id);
create index arrest_transport_arrest_idx on game.arrest_transport_legs(arrest_id,departed_at_game_time);
create index arrest_transport_officer_idx on game.arrest_transport_legs(transporting_personnel_id);
create index arrest_transport_command_idx on game.arrest_transport_legs(source_command_id);
create index custody_episodes_case_idx on game.custody_episodes(case_id,booked_at_game_time);
create index custody_episodes_person_idx on game.custody_episodes(person_id);
create index custody_episodes_booking_officer_idx on game.custody_episodes(booking_officer_id);
create index custody_episodes_command_idx on game.custody_episodes(source_command_id);
create index custody_property_episode_idx on game.custody_property(custody_episode_id);
create index custody_property_officer_idx on game.custody_property(recorded_by_personnel_id);
create index custody_property_evidence_idx on game.custody_property(evidence_id);
create index custody_property_command_idx on game.custody_property(source_command_id);
create index custody_events_episode_idx on game.custody_events(custody_episode_id,event_at_game_time);
create index custody_events_actor_idx on game.custody_events(actor_personnel_id);
create index custody_events_command_idx on game.custody_events(source_command_id);
create index custody_welfare_episode_idx on game.custody_welfare_checks(custody_episode_id,checked_at_game_time);
create index custody_welfare_officer_idx on game.custody_welfare_checks(officer_personnel_id);
create index custody_welfare_command_idx on game.custody_welfare_checks(source_command_id);

create or replace function game.reject_custody_history_mutation() returns trigger language plpgsql set search_path=pg_catalog,game as $$
begin raise exception 'Arrest and custody history is append-only; record a new event instead.';end $$;
do $$ declare t text;begin foreach t in array array['arrest_events','arrest_transport_legs','custody_property','custody_events','custody_welfare_checks'] loop execute format('create trigger %I before update or delete on game.%I for each row execute function game.reject_custody_history_mutation()',t||'_append_only',t);end loop;end $$;
do $$ declare t text;begin foreach t in array array['arrests','arrest_events','arrest_transport_legs','custody_episodes','custody_property','custody_events','custody_welfare_checks'] loop execute format('alter table game.%I enable row level security',t);execute format('revoke all on game.%I from anon,authenticated',t);execute format('grant select,insert,update,delete on game.%I to service_role',t);end loop;end $$;
grant usage,select on all sequences in schema game to service_role;

create or replace function game.execute_arrest_custody_command(p_command_id uuid,p_type text,p jsonb,p_actor_id uuid) returns jsonb language plpgsql security definer set search_path=pg_catalog,game as $$
declare n timestamptz; a game.arrests%rowtype; ce game.custody_episodes%rowtype; person_id uuid;case_id uuid;inc_id uuid;target_id uuid;result jsonb;ev uuid;prop_id uuid;actor_ref text;
begin
 select current_game_time into n from game.simulation_state where id=1;
 if n is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before arrest or custody operations.');end if;
 actor_ref:= (select personnel_ref from game.police_personnel where id=p_actor_id);
 if p_type='execute_arrest' then
  select c.id into case_id from game.cases c where c.case_ref=p->>'case_ref' and c.status='open';
  select pe.id into person_id from game.persons pe where pe.person_ref=p->>'person_ref';
  if case_id is null or person_id is null then return jsonb_build_object('ok',false,'code','case_or_person_not_found');end if;
  if not exists(select 1 from game.case_persons cp where cp.case_id=case_id and cp.person_id=person_id and cp.case_role in ('suspect','person_of_interest')) then return jsonb_build_object('ok',false,'code','person_not_linked_as_suspect','message','Person must already be linked to the case as a suspect or person of interest.');end if;
  if not exists(select 1 from game.case_assignments ca where ca.case_id=case_id and ca.personnel_id=p_actor_id and ca.status='active' and ca.released_at is null) and not exists(select 1 from game.cases c where c.id=case_id and c.lead_personnel_id=p_actor_id) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  if nullif(btrim(p->>'grounds'),'') is null or nullif(btrim(p->>'location'),'') is null or nullif(btrim(p->>'warnings'),'') is null then return jsonb_build_object('ok',false,'code','arrest_record_incomplete');end if;
  if p->>'basis' not in ('warrant','grounds','other') or (p->>'basis'='warrant' and nullif(btrim(p->>'authority_reference'),'') is null) then return jsonb_build_object('ok',false,'code','arrest_basis_invalid');end if;
  if exists(select 1 from game.arrests where case_id=case_id and person_id=person_id and status in ('arrested','transporting','booked')) then return jsonb_build_object('ok',false,'code','active_arrest_exists');end if;
  insert into game.arrests(case_id,person_id,incident_id,arresting_personnel_id,arrest_basis,authority_reference,grounds_description,arrest_location,arrested_at_game_time,force_used,injury_or_complaint,warnings_or_rights_record,witness_details,body_camera_reference,source_command_id)
  values(case_id,person_id,(select id from game.incidents where incident_ref=p->>'incident_ref'),p_actor_id,p->>'basis',nullif(p->>'authority_reference',''),p->>'grounds',p->>'location',n,coalesce(nullif(p->>'force',''),'none'),coalesce(nullif(p->>'injuries',''),'none_recorded'),p->>'warnings',nullif(p->>'witnesses',''),nullif(p->>'body_camera',''),p_command_id) returning * into a;
  insert into game.arrest_events(arrest_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(a.id,'arrest_executed',p_actor_id,n,to_jsonb(a)-'id'-'source_command_id',p_command_id);
  return jsonb_build_object('ok',true,'arrest_ref',a.arrest_ref,'status',a.status);
 elsif p_type='transport_arrest' then
  select * into a from game.arrests where arrest_ref=p->>'arrest_ref' for update;
  if a.id is null or a.status<>'arrested' then return jsonb_build_object('ok',false,'code','arrest_not_transportable');end if;
  if a.arresting_personnel_id<>p_actor_id and not exists(select 1 from game.case_assignments ca where ca.case_id=a.case_id and ca.personnel_id=p_actor_id and ca.status='active' and ca.released_at is null) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  if nullif(btrim(p->>'destination'),'') is null or nullif(btrim(p->>'vehicle'),'') is null or nullif(btrim(p->>'handover'),'') is null then return jsonb_build_object('ok',false,'code','transport_details_incomplete');end if;
  insert into game.arrest_transport_legs(arrest_id,transporting_personnel_id,departure_location,destination_location,vehicle_description,departed_at_game_time,arrived_at_game_time,handover_notes,source_command_id) values(a.id,p_actor_id,a.arrest_location,p->>'destination',p->>'vehicle',n,n,p->>'handover',p_command_id);
  update game.arrests set status='transporting' where id=a.id;
  insert into game.arrest_events(arrest_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(a.id,'transport_arrived',p_actor_id,n,jsonb_build_object('destination',p->>'destination','vehicle',p->>'vehicle','handover',p->>'handover'),p_command_id);
  return jsonb_build_object('ok',true,'arrest_ref',a.arrest_ref,'status','transporting');
 elsif p_type='book_custody' then
  select * into a from game.arrests where arrest_ref=p->>'arrest_ref' for update;
  if a.id is null or a.status<>'transporting' then return jsonb_build_object('ok',false,'code','transport_arrival_required');end if;
  if nullif(btrim(p->>'identity_check'),'') is null or nullif(btrim(p->>'risk'),'') is null or nullif(btrim(p->>'health'),'') is null or nullif(btrim(p->>'cell'),'') is null then return jsonb_build_object('ok',false,'code','booking_details_incomplete');end if;
  insert into game.custody_episodes(arrest_id,case_id,person_id,booking_officer_id,booked_at_game_time,identity_check,risk_assessment,health_welfare_screen,medication_disclosure,safeguarding_notes,cell_location,source_command_id)
  values(a.id,a.case_id,a.person_id,p_actor_id,n,p->>'identity_check',p->>'risk',p->>'health',nullif(p->>'medication',''),nullif(p->>'safeguarding',''),p->>'cell',p_command_id) returning * into ce;
  update game.arrests set status='booked' where id=a.id;
  insert into game.arrest_events(arrest_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(a.id,'custody_booking',p_actor_id,n,jsonb_build_object('custody_ref',ce.custody_ref,'cell',ce.cell_location),p_command_id);
  return jsonb_build_object('ok',true,'custody_ref',ce.custody_ref,'arrest_ref',a.arrest_ref,'status',ce.status);
 elsif p_type='record_custody_property' then
  select * into ce from game.custody_episodes where custody_ref=p->>'custody_ref' for update;
  if ce.id is null or ce.status<>'in_custody' then return jsonb_build_object('ok',false,'code','custody_not_active');end if;
  if nullif(btrim(p->>'item'),'') is null or nullif(btrim(p->>'condition'),'') is null or p->>'disposition' not in ('stored','retained_as_evidence','returned','transferred') then return jsonb_build_object('ok',false,'code','property_details_invalid');end if;
  if p->>'disposition'='retained_as_evidence' then
   insert into game.evidence_items(case_id,collected_by_personnel_id,evidence_type,description,collected_at,collection_location,current_status,storage_location,metadata)
   values(ce.case_id,p_actor_id,'custody_property',p->>'item',n,'Custody booking','held',coalesce(nullif(p->>'storage',''),'Evidence Store'),jsonb_build_object('source','custody_property','custody_ref',ce.custody_ref,'condition',p->>'condition')) returning id into ev;
  end if;
  insert into game.custody_property(custody_episode_id,recorded_by_personnel_id,item_description,condition_description,disposition,storage_location,evidence_id,recorded_at_game_time,source_command_id)
  values(ce.id,p_actor_id,p->>'item',p->>'condition',p->>'disposition',nullif(p->>'storage',''),ev,n,p_command_id) returning id into prop_id;
  return jsonb_build_object('ok',true,'property_ref',(select property_ref from game.custody_property where id=prop_id),'evidence_id',ev);
 elsif p_type='custody_check' then
  select * into ce from game.custody_episodes where custody_ref=p->>'custody_ref';
  if ce.id is null or ce.status<>'in_custody' then return jsonb_build_object('ok',false,'code','custody_not_active');end if;
  if p->>'check_type' not in ('welfare','health','risk','observation') or nullif(btrim(p->>'observation'),'') is null then return jsonb_build_object('ok',false,'code','check_details_invalid');end if;
  insert into game.custody_welfare_checks(custody_episode_id,check_type,officer_personnel_id,checked_at_game_time,observation,escalation,source_command_id) values(ce.id,p->>'check_type',p_actor_id,n,p->>'observation',nullif(p->>'escalation',''),p_command_id);
  return jsonb_build_object('ok',true,'custody_ref',ce.custody_ref,'check_type',p->>'check_type');
 elsif p_type='custody_event' then
  select * into ce from game.custody_episodes where custody_ref=p->>'custody_ref';
  if ce.id is null or ce.status<>'in_custody' then return jsonb_build_object('ok',false,'code','custody_not_active');end if;
  if nullif(btrim(p->>'details'),'') is null then return jsonb_build_object('ok',false,'code','event_details_required');end if;
  insert into game.custody_events(custody_episode_id,event_type,actor_personnel_id,event_at_game_time,details,source_command_id) values(ce.id,p->>'event_type',p_actor_id,n,p->>'details',p_command_id);
  return jsonb_build_object('ok',true,'custody_ref',ce.custody_ref,'event_type',p->>'event_type');
 elsif p_type in ('release_custody','transfer_custody') then
  select * into ce from game.custody_episodes where custody_ref=p->>'custody_ref' for update;
  if ce.id is null or ce.status<>'in_custody' then return jsonb_build_object('ok',false,'code','custody_not_active');end if;
  if nullif(btrim(p->>'reason'),'') is null then return jsonb_build_object('ok',false,'code','final_reason_required');end if;
  if p_type='transfer_custody' and nullif(btrim(p->>'destination'),'') is null then return jsonb_build_object('ok',false,'code','transfer_destination_required');end if;
  update game.custody_episodes set status=case when p_type='release_custody' then 'released' else 'transferred' end,release_or_transfer_at_game_time=n,final_outcome=case when p_type='release_custody' then coalesce(p->>'outcome','released') else 'transferred' end,final_reason=p->>'reason' where id=ce.id;
  update game.arrests set status=case when p_type='release_custody' then 'released' else 'transferred' end where id=ce.arrest_id;
  insert into game.custody_events(custody_episode_id,event_type,actor_personnel_id,event_at_game_time,details,source_command_id) values(ce.id,case when p_type='release_custody' then 'handover' else 'handover' end,p_actor_id,n,case when p_type='release_custody' then 'Released: '||p->>'outcome'||'. '||p->>'reason' else 'Transferred to '||p->>'destination'||'. '||p->>'reason' end,p_command_id);
  insert into game.arrest_events(arrest_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(ce.arrest_id,case when p_type='release_custody' then 'released' else 'transferred' end,p_actor_id,n,jsonb_build_object('outcome',p->>'outcome','destination',p->>'destination','reason',p->>'reason'),p_command_id);
  return jsonb_build_object('ok',true,'custody_ref',ce.custody_ref,'status',case when p_type='release_custody' then 'released' else 'transferred' end);
 elsif p_type='get_case_arrests' then
  if not exists(select 1 from game.cases c where c.case_ref=p->>'case_ref' and (c.lead_personnel_id=p_actor_id or exists(select 1 from game.case_assignments ca where ca.case_id=c.id and ca.personnel_id=p_actor_id and ca.status='active' and ca.released_at is null))) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  return jsonb_build_object('ok',true,'arrests',(select coalesce(jsonb_agg(jsonb_build_object('arrest_ref',a.arrest_ref,'person_ref',pe.person_ref,'status',a.status,'basis',a.arrest_basis,'grounds',a.grounds_description,'location',a.arrest_location,'arrested_at',a.arrested_at_game_time,'transport',(select jsonb_agg(to_jsonb(t)-'id' order by t.departed_at_game_time) from game.arrest_transport_legs t where t.arrest_id=a.id),'custody',(select to_jsonb(cu)-'id' from game.custody_episodes cu where cu.arrest_id=a.id),'events',(select jsonb_agg(to_jsonb(ae)-'id' order by ae.event_at_game_time) from game.arrest_events ae where ae.arrest_id=a.id)) order by a.arrested_at_game_time),'[]'::jsonb) from game.arrests a join game.persons pe on pe.id=a.person_id where a.case_id=(select id from game.cases where case_ref=p->>'case_ref')));
 end if;
 return jsonb_build_object('ok',false,'code','unsupported_command');
end $$;

alter function game.interpret_text_command(text) rename to interpret_text_command_before_arrest_custody;
alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_arrest_custody;

create or replace function game.interpret_arrest_custody_command(p_command_text text) returns jsonb language plpgsql immutable set search_path=pg_catalog,game as $$
declare t text:=btrim(coalesce(p_command_text,''));m text[];
begin
 m:=regexp_match(t,'^arrest execute ([^[:space:]]+) person ([^[:space:]]+) by ([^[:space:]]+) basis ([^[:space:]]+) location "(.+)" grounds "(.+)" force "(.+)" injuries "(.+)" warnings "(.+)"(?: authority "(.+)")?(?: witnesses "(.+)")?(?: body_camera "(.+)")?(?: incident ([^[:space:]]+))?$','i');
 if m is not null then return jsonb_build_object('command_type','execute_arrest','payload',jsonb_build_object('case_ref',m[1],'person_ref',m[2],'actor_ref',m[3],'basis',lower(m[4]),'location',m[5],'grounds',m[6],'force',m[7],'injuries',m[8],'warnings',m[9],'authority_reference',m[10],'witnesses',m[11],'body_camera',m[12],'incident_ref',m[13]));end if;
 m:=regexp_match(t,'^arrest transport ([^[:space:]]+) by ([^[:space:]]+) to "(.+)" vehicle "(.+)" handover "(.+)"$','i');
 if m is not null then return jsonb_build_object('command_type','transport_arrest','payload',jsonb_build_object('arrest_ref',m[1],'actor_ref',m[2],'destination',m[3],'vehicle',m[4],'handover',m[5]));end if;
 m:=regexp_match(t,'^custody book ([^[:space:]]+) by ([^[:space:]]+) identity "(.+)" risk "(.+)" health "(.+)" cell "(.+)"(?: medication "(.+)")?(?: safeguarding "(.+)")?$','i');
 if m is not null then return jsonb_build_object('command_type','book_custody','payload',jsonb_build_object('arrest_ref',m[1],'actor_ref',m[2],'identity_check',m[3],'risk',m[4],'health',m[5],'cell',m[6],'medication',m[7],'safeguarding',m[8]));end if;
 m:=regexp_match(t,'^custody property ([^[:space:]]+) by ([^[:space:]]+) item "(.+)" condition "(.+)" disposition ([^[:space:]]+)(?: storage "(.+)")?$','i');
 if m is not null then return jsonb_build_object('command_type','record_custody_property','payload',jsonb_build_object('custody_ref',m[1],'actor_ref',m[2],'item',m[3],'condition',m[4],'disposition',lower(m[5]),'storage',m[6]));end if;
 m:=regexp_match(t,'^custody check ([^[:space:]]+) by ([^[:space:]]+) type ([^[:space:]]+) observation "(.+)"(?: escalation "(.+)")?$','i');
 if m is not null then return jsonb_build_object('command_type','custody_check','payload',jsonb_build_object('custody_ref',m[1],'actor_ref',m[2],'check_type',lower(m[3]),'observation',m[4],'escalation',m[5]));end if;
 m:=regexp_match(t,'^custody event ([^[:space:]]+) by ([^[:space:]]+) type ([^[:space:]]+) details "(.+)"$','i');
 if m is not null then return jsonb_build_object('command_type','custody_event','payload',jsonb_build_object('custody_ref',m[1],'actor_ref',m[2],'event_type',lower(m[3]),'details',m[4]));end if;
 m:=regexp_match(t,'^custody release ([^[:space:]]+) by ([^[:space:]]+) outcome ([^[:space:]]+) because "(.+)"$','i');
 if m is not null then return jsonb_build_object('command_type','release_custody','payload',jsonb_build_object('custody_ref',m[1],'actor_ref',m[2],'outcome',lower(m[3]),'reason',m[4]));end if;
 m:=regexp_match(t,'^custody transfer ([^[:space:]]+) by ([^[:space:]]+) to "(.+)" because "(.+)"$','i');
 if m is not null then return jsonb_build_object('command_type','transfer_custody','payload',jsonb_build_object('custody_ref',m[1],'actor_ref',m[2],'destination',m[3],'reason',m[4]));end if;
 m:=regexp_match(t,'^case arrests ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','get_case_arrests','payload',jsonb_build_object('case_ref',m[1],'actor_ref',m[2]));end if;
 return null;
end $$;

create or replace function game.interpret_text_command(p_command_text text) returns jsonb language plpgsql immutable set search_path=pg_catalog,game as $$
declare r jsonb;
begin r:=game.interpret_arrest_custody_command(p_command_text);if r is not null then return r;end if;return game.interpret_text_command_before_arrest_custody(p_command_text);end $$;

create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null) returns jsonb language plpgsql set search_path=pg_catalog,game as $$
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
end $$;

revoke all on function game.reject_custody_history_mutation() from public,anon,authenticated;
revoke all on function game.execute_arrest_custody_command(uuid,text,jsonb,uuid) from public,anon,authenticated;
grant execute on function game.execute_arrest_custody_command(uuid,text,jsonb,uuid) to service_role;
revoke all on function game.interpret_arrest_custody_command(text) from public,anon,authenticated;
grant execute on function game.interpret_arrest_custody_command(text) to service_role;
revoke all on function game.interpret_text_command(text) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text) to service_role;
revoke all on function game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.execute_text_command(text,text,uuid,uuid) to service_role;
