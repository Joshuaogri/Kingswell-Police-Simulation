
create schema if not exists game;
comment on schema game is 'Private authoritative schema for the fictional Kingswell Police Simulation';

create table game.world_countries (
 id uuid primary key default gen_random_uuid(), code text not null unique, name text not null,
 is_fictional boolean not null default true, created_at timestamptz not null default now()
);
create table game.regions (
 id uuid primary key default gen_random_uuid(), country_id uuid not null references game.world_countries(id),
 code text not null, name text not null, created_at timestamptz not null default now(), unique(country_id,code)
);
create table game.cities (
 id uuid primary key default gen_random_uuid(), region_id uuid not null references game.regions(id),
 code text not null, name text not null, population integer check(population>=0),
 is_primary_city boolean not null default false, created_at timestamptz not null default now(),
 unique(region_id,code)
);
create table game.districts (
 id uuid primary key default gen_random_uuid(), city_id uuid not null references game.cities(id),
 code text not null, name text not null, district_type text, created_at timestamptz not null default now(),
 unique(city_id,code)
);
create table game.neighbourhoods (
 id uuid primary key default gen_random_uuid(), district_id uuid not null references game.districts(id),
 code text not null, name text not null, created_at timestamptz not null default now(), unique(district_id,code)
);
create table game.roads (
 id uuid primary key default gen_random_uuid(), city_id uuid not null references game.cities(id),
 district_id uuid references game.districts(id), code text, name text not null, road_type text,
 created_at timestamptz not null default now()
);
create table game.organisations (
 id uuid primary key default gen_random_uuid(), organisation_ref text not null unique,
 name text not null, organisation_type text not null, parent_organisation_id uuid references game.organisations(id),
 status text not null default 'active' check(status in ('active','inactive','dissolved')),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table game.properties (
 id uuid primary key default gen_random_uuid(), property_ref text not null unique,
 city_id uuid not null references game.cities(id), district_id uuid references game.districts(id),
 neighbourhood_id uuid references game.neighbourhoods(id), road_id uuid references game.roads(id),
 street_number text, address_line text, property_type text, latitude numeric(9,6), longitude numeric(9,6),
 status text not null default 'active', created_at timestamptz not null default now()
);
create table game.buildings (
 id uuid primary key default gen_random_uuid(), building_ref text not null unique,
 property_id uuid not null references game.properties(id), name text, building_type text,
 floors integer check(floors is null or floors>=0), created_at timestamptz not null default now()
);
create table game.building_units (
 id uuid primary key default gen_random_uuid(), unit_ref text not null unique,
 building_id uuid not null references game.buildings(id), parent_unit_id uuid references game.building_units(id),
 unit_name text not null, unit_type text, floor_label text, created_at timestamptz not null default now()
);
create table game.persons (
 id uuid primary key default gen_random_uuid(), person_ref text not null unique,
 given_name text, middle_names text, family_name text, preferred_name text,
 date_of_birth date, person_status text not null default 'active'
 check(person_status in ('active','deceased','missing','unknown','inactive')),
 nationality text, occupation text, notes text, created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table game.person_addresses (
 id uuid primary key default gen_random_uuid(), person_id uuid not null references game.persons(id),
 property_id uuid not null references game.properties(id), address_role text not null default 'residence',
 valid_from date not null default current_date, valid_to date, is_current boolean not null default true,
 check(valid_to is null or valid_to>=valid_from)
);
create table game.person_relationships (
 id uuid primary key default gen_random_uuid(), person_id uuid not null references game.persons(id),
 related_person_id uuid not null references game.persons(id), relationship_type text not null,
 valid_from date, valid_to date, notes text, check(person_id<>related_person_id)
);
create table game.organisation_locations (
 id uuid primary key default gen_random_uuid(), organisation_id uuid not null references game.organisations(id),
 property_id uuid not null references game.properties(id), location_role text not null default 'operating_site',
 valid_from date, valid_to date
);
create table game.organisation_personnel (
 id uuid primary key default gen_random_uuid(), organisation_id uuid not null references game.organisations(id),
 person_id uuid not null references game.persons(id), job_title text, employment_type text,
 valid_from date, valid_to date, is_current boolean not null default true
);

create table game.police_commands (
 id uuid primary key default gen_random_uuid(), command_ref text not null unique,
 organisation_id uuid not null references game.organisations(id), parent_command_id uuid references game.police_commands(id),
 command_name text not null, command_level text not null, area_district_id uuid references game.districts(id),
 status text not null default 'active'
);
create table game.police_stations (
 id uuid primary key default gen_random_uuid(), station_ref text not null unique,
 command_id uuid references game.police_commands(id), organisation_id uuid references game.organisations(id),
 property_id uuid references game.properties(id), station_name text not null, station_type text,
 status text not null default 'active'
);
create table game.police_ranks (
 id uuid primary key default gen_random_uuid(), rank_code text not null unique,
 rank_name text not null, rank_level integer not null unique, is_officer_rank boolean not null default true
);
create table game.police_units (
 id uuid primary key default gen_random_uuid(), unit_ref text not null unique,
 command_id uuid references game.police_commands(id), station_id uuid references game.police_stations(id),
 parent_unit_id uuid references game.police_units(id), unit_name text not null, unit_type text not null,
 status text not null default 'active'
);
create table game.police_positions (
 id uuid primary key default gen_random_uuid(), position_code text not null unique,
 position_title text not null, unit_id uuid references game.police_units(id),
 supervisor_position_id uuid references game.police_positions(id), position_description text,
 is_active boolean not null default true
);
create table game.police_personnel (
 id uuid primary key default gen_random_uuid(), personnel_ref text not null unique,
 person_id uuid not null unique references game.persons(id), service_number text not null unique,
 current_rank_id uuid references game.police_ranks(id), current_unit_id uuid references game.police_units(id),
 current_position_id uuid references game.police_positions(id), current_station_id uuid references game.police_stations(id),
 employment_status text not null default 'recruit'
 check(employment_status in ('applicant','recruit','probationary','active','leave','suspended','restricted','seconded','former')),
 joined_on date, left_on date, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table game.personnel_service_history (
 id uuid primary key default gen_random_uuid(), personnel_id uuid not null references game.police_personnel(id),
 rank_id uuid references game.police_ranks(id), unit_id uuid references game.police_units(id),
 position_id uuid references game.police_positions(id), station_id uuid references game.police_stations(id),
 change_type text not null, effective_from timestamptz not null, effective_to timestamptz,
 recorded_at timestamptz not null default now(), notes text
);
create table game.personnel_qualifications (
 id uuid primary key default gen_random_uuid(), personnel_id uuid not null references game.police_personnel(id),
 qualification_code text not null, qualification_name text not null, awarded_on date,
 expires_on date, status text not null default 'valid'
);
create table game.duty_rosters (
 id uuid primary key default gen_random_uuid(), roster_ref text not null unique,
 unit_id uuid not null references game.police_units(id), shift_name text not null,
 starts_at timestamptz not null, ends_at timestamptz not null, status text not null default 'planned',
 check(ends_at>starts_at)
);
create table game.duty_assignments (
 id uuid primary key default gen_random_uuid(), roster_id uuid not null references game.duty_rosters(id),
 personnel_id uuid not null references game.police_personnel(id), assignment_role text,
 assigned_station_id uuid references game.police_stations(id), starts_at timestamptz not null,
 ends_at timestamptz not null, status text not null default 'assigned', check(ends_at>starts_at)
);
create table game.police_resources (
 id uuid primary key default gen_random_uuid(), resource_ref text not null unique,
 station_id uuid references game.police_stations(id), unit_id uuid references game.police_units(id),
 resource_type text not null, resource_name text not null, status text not null default 'available',
 details jsonb not null default '{}'::jsonb
);

create table game.simulation_state (
 id smallint primary key default 1 check(id=1), world_name text not null default 'Kingswell',
 current_game_time timestamptz not null, time_paused boolean not null default true,
 time_scale numeric(8,2) not null default 1 check(time_scale>0),
 updated_at timestamptz not null default now()
);
create table game.incident_types (
 id uuid primary key default gen_random_uuid(), type_code text not null unique,
 type_name text not null, category text not null, default_priority smallint check(default_priority between 1 and 5),
 is_crime_related boolean not null default false, is_active boolean not null default true
);
create table game.incidents (
 id uuid primary key default gen_random_uuid(), incident_ref text not null unique,
 incident_type_id uuid references game.incident_types(id), reported_at timestamptz not null default now(),
 occurred_from timestamptz, occurred_to timestamptz, location_property_id uuid references game.properties(id),
 location_building_unit_id uuid references game.building_units(id), location_description text,
 priority smallint check(priority between 1 and 5), status text not null default 'new'
 check(status in ('new','graded','queued','dispatched','attending','active','resolved','closed','cancelled')),
 summary text not null, details jsonb not null default '{}'::jsonb, created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table game.incident_parties (
 id uuid primary key default gen_random_uuid(), incident_id uuid not null references game.incidents(id),
 person_id uuid not null references game.persons(id), party_role text not null,
 notes text, unique(incident_id,person_id,party_role)
);
create table game.dispatch_calls (
 id uuid primary key default gen_random_uuid(), call_ref text not null unique,
 incident_id uuid references game.incidents(id), received_at timestamptz not null default now(),
 caller_person_id uuid references game.persons(id), caller_name text, caller_contact text,
 call_channel text not null default 'telephone', call_taker_personnel_id uuid references game.police_personnel(id),
 call_summary text, call_record jsonb not null default '{}'::jsonb, status text not null default 'received'
);
create table game.dispatch_events (
 id uuid primary key default gen_random_uuid(), incident_id uuid not null references game.incidents(id),
 event_at timestamptz not null default now(), event_type text not null,
 personnel_id uuid references game.police_personnel(id), unit_id uuid references game.police_units(id),
 details jsonb not null default '{}'::jsonb
);
create table game.incident_deployments (
 id uuid primary key default gen_random_uuid(), incident_id uuid not null references game.incidents(id),
 personnel_id uuid references game.police_personnel(id), unit_id uuid references game.police_units(id),
 dispatched_at timestamptz, arrived_at timestamptz, cleared_at timestamptz,
 deployment_role text, status text not null default 'assigned'
);
create table game.cases (
 id uuid primary key default gen_random_uuid(), case_ref text not null unique,
 case_title text not null, case_type text, status text not null default 'open'
 check(status in ('open','under_investigation','suspended','submitted','closed','reopened')),
 lead_personnel_id uuid references game.police_personnel(id), opened_at timestamptz not null default now(),
 closed_at timestamptz, summary text, case_data jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table game.case_incidents (
 case_id uuid not null references game.cases(id), incident_id uuid not null references game.incidents(id),
 relationship_type text not null default 'originating', primary key(case_id,incident_id)
);
create table game.case_persons (
 id uuid primary key default gen_random_uuid(), case_id uuid not null references game.cases(id),
 person_id uuid not null references game.persons(id), case_role text not null, notes text,
 unique(case_id,person_id,case_role)
);
create table game.case_assignments (
 id uuid primary key default gen_random_uuid(), case_id uuid not null references game.cases(id),
 personnel_id uuid not null references game.police_personnel(id), assignment_role text not null default 'investigator',
 assigned_at timestamptz not null default now(), released_at timestamptz, status text not null default 'active'
);
create table game.evidence_items (
 id uuid primary key default gen_random_uuid(), evidence_ref text not null unique,
 case_id uuid references game.cases(id), incident_id uuid references game.incidents(id),
 collected_by_personnel_id uuid references game.police_personnel(id),
 evidence_type text not null, description text not null, collected_at timestamptz,
 collection_location text, current_status text not null default 'held',
 storage_location text, metadata jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now()
);
create table game.evidence_transfers (
 id uuid primary key default gen_random_uuid(), evidence_id uuid not null references game.evidence_items(id),
 transferred_at timestamptz not null default now(), from_personnel_id uuid references game.police_personnel(id),
 to_personnel_id uuid references game.police_personnel(id), from_location text, to_location text,
 transfer_reason text not null, notes text
);
create table game.game_events (
 id bigint generated always as identity primary key, event_key text not null,
 occurred_at timestamptz not null default now(), game_time timestamptz,
 actor_personnel_id uuid references game.police_personnel(id),
 entity_type text not null, entity_id uuid, event_data jsonb not null default '{}'::jsonb
);

create index idx_person_addresses_person on game.person_addresses(person_id);
create index idx_person_relationships_person on game.person_relationships(person_id);
create index idx_org_personnel_person on game.organisation_personnel(person_id);
create index idx_properties_location on game.properties(city_id,district_id,neighbourhood_id);
create index idx_personnel_unit on game.police_personnel(current_unit_id);
create index idx_service_history_person_time on game.personnel_service_history(personnel_id,effective_from desc);
create index idx_duty_assignments_person_time on game.duty_assignments(personnel_id,starts_at,ends_at);
create index idx_incidents_status_time on game.incidents(status,reported_at desc);
create index idx_incidents_location on game.incidents(location_property_id);
create index idx_dispatch_events_incident_time on game.dispatch_events(incident_id,event_at);
create index idx_deployments_incident on game.incident_deployments(incident_id);
create index idx_cases_status on game.cases(status,opened_at desc);
create index idx_case_persons_person on game.case_persons(person_id);
create index idx_evidence_case on game.evidence_items(case_id);
create index idx_evidence_transfers_item_time on game.evidence_transfers(evidence_id,transferred_at);
create index idx_game_events_entity_time on game.game_events(entity_type,entity_id,occurred_at);

do $$
declare t record;
begin
 for t in select tablename from pg_tables where schemaname='game' loop
  execute format('alter table game.%I enable row level security',t.tablename);
 end loop;
end $$;

revoke all on schema game from public, anon, authenticated;
grant usage on schema game to service_role;
grant all privileges on all tables in schema game to service_role;
grant all privileges on all sequences in schema game to service_role;
alter default privileges in schema game grant all on tables to service_role;
alter default privileges in schema game grant all on sequences to service_role;
