create table game.patrol_observations (
 id uuid primary key default gen_random_uuid(),
 observation_ref text not null unique,
 session_id uuid not null references game.patrol_activity_sessions(id),
 unit_id uuid not null references game.police_units(id),
 personnel_id uuid not null references game.police_personnel(id),
 beat_id uuid not null references game.patrol_beats(id),
 observed_at_game_time timestamptz not null,
 location_access_point_id uuid not null references game.property_access_points(id),
 category text not null check(category in ('suspicious_activity','traffic','property_condition','vulnerable_person','public_order','environmental_hazard','community_concern','wanted_vehicle','other')),
 description text not null check(length(btrim(description))>0),
 source_command_id uuid references game.game_commands(id),
 created_at timestamptz not null default now()
);
create table game.patrol_contacts (
 id uuid primary key default gen_random_uuid(),
 contact_ref text not null unique,
 session_id uuid not null references game.patrol_activity_sessions(id),
 unit_id uuid not null references game.police_units(id),
 personnel_id uuid not null references game.police_personnel(id),
 beat_id uuid not null references game.patrol_beats(id),
 contacted_at_game_time timestamptz not null,
 location_access_point_id uuid not null references game.property_access_points(id),
 contact_type text not null check(contact_type in ('person_spoken_to','business_visit','community_contact','welfare_check','witness_contact','other')),
 person_id uuid references game.persons(id),
 organisation_id uuid references game.organisations(id),
 property_id uuid references game.properties(id),
 incident_id uuid references game.incidents(id),
 outcome text not null check(length(btrim(outcome))>0),
 notes text,
 source_command_id uuid references game.game_commands(id),
 created_at timestamptz not null default now(),
 check(person_id is not null or organisation_id is not null or property_id is not null or incident_id is not null or contact_type in ('community_contact','other'))
);
create index patrol_observations_session_time_idx on game.patrol_observations(session_id,observed_at_game_time);
create index patrol_observations_beat_time_idx on game.patrol_observations(beat_id,observed_at_game_time desc);
create index patrol_contacts_session_time_idx on game.patrol_contacts(session_id,contacted_at_game_time);
create index patrol_contacts_person_time_idx on game.patrol_contacts(person_id,contacted_at_game_time desc) where person_id is not null;
create index patrol_contacts_organisation_time_idx on game.patrol_contacts(organisation_id,contacted_at_game_time desc) where organisation_id is not null;
create index patrol_contacts_property_time_idx on game.patrol_contacts(property_id,contacted_at_game_time desc) where property_id is not null;
create index patrol_contacts_incident_time_idx on game.patrol_contacts(incident_id,contacted_at_game_time desc) where incident_id is not null;

alter table game.patrol_observations enable row level security;
alter table game.patrol_contacts enable row level security;
revoke all on game.patrol_observations,game.patrol_contacts from public,anon,authenticated;
grant select,insert on game.patrol_observations,game.patrol_contacts to service_role;

create or replace function game.reject_patrol_record_mutation()
returns trigger language plpgsql set search_path to ''
as $f$ begin raise exception 'Patrol observations and contact records are append-only'; end; $f$;
create trigger patrol_observations_append_only before update or delete on game.patrol_observations for each row execute function game.reject_patrol_record_mutation();
create trigger patrol_contacts_append_only before update or delete on game.patrol_contacts for each row execute function game.reject_patrol_record_mutation();

create or replace function game.record_patrol_observation(
 p_command_id uuid,p_session_ref text,p_category text,p_access_ref text,p_description text,p_actor_personnel_id uuid
) returns jsonb language plpgsql set search_path to ''
as $f$
declare clk timestamptz; s game.patrol_activity_sessions%rowtype; ap game.property_access_points%rowtype; o game.patrol_observations%rowtype; actor_id uuid; ref text;
begin
 if p_command_id is null or nullif(btrim(p_description),'') is null then raise exception 'Command identifier and observation description are required'; end if;
 if p_category not in ('suspicious_activity','traffic','property_condition','vulnerable_person','public_order','environmental_hazard','community_concern','wanted_vehicle','other') then raise exception 'Unsupported patrol observation category'; end if;
 select current_game_time into clk from game.simulation_state where id=1 for update;
 if clk is null then raise exception 'Fictional clock is not initialized'; end if;
 select * into s from game.patrol_activity_sessions where session_ref=p_session_ref and status='active' for update;
 if not found then raise exception 'An active patrol activity session is required'; end if;
 if p_actor_personnel_id is null or p_actor_personnel_id is distinct from s.personnel_id then raise exception 'Only the officer assigned to this patrol activity may record it'; end if;
 select id into actor_id from game.police_personnel where id=s.personnel_id and employment_status='active';
 if actor_id is null then raise exception 'Assigned officer is no longer active'; end if;
 select * into ap from game.property_access_points where access_ref=coalesce(nullif(btrim(p_access_ref),''),(select a.access_ref from game.property_access_points a where a.id=s.location_access_point_id));
 if not found or ap.id is distinct from s.location_access_point_id then raise exception 'Observation location must match the recorded patrol activity location'; end if;
 ref:='KPO-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
 insert into game.patrol_observations(observation_ref,session_id,unit_id,personnel_id,beat_id,observed_at_game_time,location_access_point_id,category,description,source_command_id)
 values(ref,s.id,s.unit_id,s.personnel_id,s.beat_id,clk,ap.id,p_category,btrim(p_description),p_command_id) returning * into o;
 insert into game.patrol_activity_events(session_id,event_type,event_time_game_time,command_id,details)
 values(s.id,'observation_recorded',clk,p_command_id,jsonb_build_object('observation_ref',ref,'category',p_category,'location_access_point_id',ap.id));
 insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data)
 values('patrol.observation.recorded.'||replace(p_command_id::text,'-',''),clk,p_actor_personnel_id,'police_unit',s.unit_id,jsonb_build_object('observation_ref',ref,'session_ref',s.session_ref,'category',p_category,'description',btrim(p_description)));
 return jsonb_build_object('ok',true,'status','completed','observation_ref',ref,'session_ref',s.session_ref,'category',p_category,'location_access_ref',ap.access_ref,'observed_at',clk,'game_time',clk);
end;$f$;

create or replace function game.record_patrol_contact(
 p_command_id uuid,p_session_ref text,p_contact_type text,p_access_ref text,p_person_ref text,p_organisation_ref text,p_property_ref text,p_incident_ref text,p_outcome text,p_notes text,p_actor_personnel_id uuid
) returns jsonb language plpgsql set search_path to ''
as $f$
declare clk timestamptz; s game.patrol_activity_sessions%rowtype; ap game.property_access_points%rowtype; person_id uuid; org_id uuid; property_id uuid; incident_id uuid; ref text; c game.patrol_contacts%rowtype;
begin
 if p_command_id is null or nullif(btrim(p_outcome),'') is null then raise exception 'Command identifier and contact outcome are required'; end if;
 if p_contact_type not in ('person_spoken_to','business_visit','community_contact','welfare_check','witness_contact','other') then raise exception 'Unsupported patrol contact type'; end if;
 select current_game_time into clk from game.simulation_state where id=1 for update;
 if clk is null then raise exception 'Fictional clock is not initialized'; end if;
 select * into s from game.patrol_activity_sessions where session_ref=p_session_ref and status='active' for update;
 if not found then raise exception 'An active patrol activity session is required'; end if;
 if p_actor_personnel_id is null or p_actor_personnel_id is distinct from s.personnel_id then raise exception 'Only the officer assigned to this patrol activity may record it'; end if;
 if not exists(select 1 from game.police_personnel where id=s.personnel_id and employment_status='active') then raise exception 'Assigned officer is no longer active'; end if;
 select * into ap from game.property_access_points where access_ref=coalesce(nullif(btrim(p_access_ref),''),(select a.access_ref from game.property_access_points a where a.id=s.location_access_point_id));
 if not found or ap.id is distinct from s.location_access_point_id then raise exception 'Contact location must match the recorded patrol activity location'; end if;
 if nullif(btrim(p_person_ref),'') is not null then select id into person_id from game.persons where person_ref=btrim(p_person_ref); if person_id is null then raise exception 'Person reference not found'; end if; end if;
 if nullif(btrim(p_organisation_ref),'') is not null then select id into org_id from game.organisations where organisation_ref=btrim(p_organisation_ref) and status='active'; if org_id is null then raise exception 'Active organisation reference not found'; end if; end if;
 if nullif(btrim(p_property_ref),'') is not null then select id into property_id from game.properties where property_ref=btrim(p_property_ref) and status='active'; if property_id is null then raise exception 'Active property reference not found'; end if; end if;
 if nullif(btrim(p_incident_ref),'') is not null then select id into incident_id from game.incidents where incident_ref=btrim(p_incident_ref); if incident_id is null then raise exception 'Incident reference not found'; end if; end if;
 if person_id is null and org_id is null and property_id is null and incident_id is null and p_contact_type not in ('community_contact','other') then raise exception 'Link a person, organisation, property or incident for this contact type'; end if;
 ref:='KPC-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
 insert into game.patrol_contacts(contact_ref,session_id,unit_id,personnel_id,beat_id,contacted_at_game_time,location_access_point_id,contact_type,person_id,organisation_id,property_id,incident_id,outcome,notes,source_command_id)
 values(ref,s.id,s.unit_id,s.personnel_id,s.beat_id,clk,ap.id,p_contact_type,person_id,org_id,property_id,incident_id,btrim(p_outcome),nullif(btrim(p_notes),''),p_command_id) returning * into c;
 insert into game.patrol_activity_events(session_id,event_type,event_time_game_time,command_id,details)
 values(s.id,'contact_recorded',clk,p_command_id,jsonb_build_object('contact_ref',ref,'contact_type',p_contact_type,'person_id',person_id,'organisation_id',org_id,'property_id',property_id,'incident_id',incident_id));
 insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data)
 values('patrol.contact.recorded.'||replace(p_command_id::text,'-',''),clk,p_actor_personnel_id,'police_unit',s.unit_id,jsonb_build_object('contact_ref',ref,'session_ref',s.session_ref,'contact_type',p_contact_type,'person_id',person_id,'organisation_id',org_id,'property_id',property_id,'incident_id',incident_id,'outcome',btrim(p_outcome)));
 return jsonb_build_object('ok',true,'status','completed','contact_ref',ref,'session_ref',s.session_ref,'contact_type',p_contact_type,'person_ref',p_person_ref,'organisation_ref',p_organisation_ref,'property_ref',p_property_ref,'incident_ref',p_incident_ref,'location_access_ref',ap.access_ref,'contacted_at',clk,'game_time',clk);
end;$f$;

revoke all on function game.record_patrol_observation(uuid,text,text,text,text,uuid) from public,anon,authenticated;
revoke all on function game.record_patrol_contact(uuid,text,text,text,text,text,text,text,text,text,uuid) from public,anon,authenticated;
grant execute on function game.record_patrol_observation(uuid,text,text,text,text,uuid) to service_role;
grant execute on function game.record_patrol_contact(uuid,text,text,text,text,text,text,text,text,text,uuid) to service_role;

alter function game.interpret_text_command(text) rename to interpret_text_command_before_records;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game'
as $f$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^record[[:space:]]+patrol[[:space:]]+observation[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+category[[:space:]]+(suspicious_activity|traffic|property_condition|vulnerable_person|public_order|environmental_hazard|community_concern|wanted_vehicle|other)(?:[[:space:]]+at[[:space:]]+([A-Za-z0-9._/-]+))?[[:space:]]+because[[:space:]]+(.+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','record_patrol_observation','payload',jsonb_build_object('session_ref',m[1],'category',lower(m[2]),'access_ref',m[3],'description',btrim(m[4]))); end if;
 m:=regexp_match(t,'^record[[:space:]]+patrol[[:space:]]+contact[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+type[[:space:]]+(person_spoken_to|business_visit|community_contact|welfare_check|witness_contact|other)(?:[[:space:]]+person[[:space:]]+([A-Za-z0-9._/-]+))?(?:[[:space:]]+organisation[[:space:]]+([A-Za-z0-9._/-]+))?(?:[[:space:]]+property[[:space:]]+([A-Za-z0-9._/-]+))?(?:[[:space:]]+incident[[:space:]]+([A-Za-z0-9._/-]+))?[[:space:]]+outcome[[:space:]]+(.+?)(?:[[:space:]]+notes[[:space:]]+(.+))?$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','record_patrol_contact','payload',jsonb_build_object('session_ref',m[1],'contact_type',lower(m[2]),'person_ref',m[3],'organisation_ref',m[4],'property_ref',m[5],'incident_ref',m[6],'outcome',btrim(m[7]),'notes',nullif(btrim(m[8]),''))); end if;
 if lower(t) in ('patrol intelligence','patrol gaps','patrol analysis') then return jsonb_build_object('recognized',true,'command_type','patrol_intelligence','payload','{}'::jsonb); end if;
 m:=regexp_match(t,'^start[[:space:]]+patrol[[:space:]]+activity[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+by[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+at[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+type[[:space:]]+(foot_patrol|stationary_observation|community_engagement|business_visit|area_check|vehicle_patrol_stop|other)[[:space:]]+because[[:space:]]+(.+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','start_patrol_activity','payload',jsonb_build_object('unit_ref',m[1],'personnel_ref',m[2],'access_ref',m[3],'activity_type',lower(m[4]),'reason',btrim(m[5]))); end if;
 m:=regexp_match(t,'^end[[:space:]]+patrol[[:space:]]+activity[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+after[[:space:]]+([0-9]+)[[:space:]]+minutes[[:space:]]+because[[:space:]]+(.+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','end_patrol_activity','payload',jsonb_build_object('session_ref',m[1],'duration_minutes',m[2]::integer,'reason',btrim(m[3]))); end if;
 m:=regexp_match(t,'^patrol[[:space:]]+move[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+to[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+because[[:space:]]+(.+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','patrol_move','payload',jsonb_build_object('unit_ref',m[1],'destination_access_ref',m[2],'reason',btrim(m[3]))); end if;
 return game.interpret_text_command_before_records(p_command_text);
end;$f$;
revoke all on function game.interpret_text_command(text) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text) to service_role;

do $patch$
declare def text; marker text; injected text;
begin
 def:=pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure);
 marker:=$m$  elsif v_type='end_patrol_activity' then
    v_result:=game.end_patrol_activity(v_command.id,p_payload->>'session_ref',(p_payload->>'duration_minutes')::integer,p_payload->>'reason') || jsonb_build_object('ok',true,'status','completed','command_id',v_command.id);
$m$;
 injected:=$i$  elsif v_type='record_patrol_observation' then
    v_result:=game.record_patrol_observation(v_command.id,p_payload->>'session_ref',p_payload->>'category',p_payload->>'access_ref',p_payload->>'description',p_actor_personnel_id);
  elsif v_type='record_patrol_contact' then
    v_result:=game.record_patrol_contact(v_command.id,p_payload->>'session_ref',p_payload->>'contact_type',p_payload->>'access_ref',p_payload->>'person_ref',p_payload->>'organisation_ref',p_payload->>'property_ref',p_payload->>'incident_ref',p_payload->>'outcome',p_payload->>'notes',p_actor_personnel_id);
$i$;
 if position(marker in def)=0 then raise exception 'Could not locate patrol activity dispatcher branch'; end if;
 def:=replace(def,marker,marker||injected);
 execute def;
end;$patch$;
