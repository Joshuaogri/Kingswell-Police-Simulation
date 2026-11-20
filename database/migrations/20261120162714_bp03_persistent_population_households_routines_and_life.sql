-- BP-03 population and individual-life foundation.
-- Extend canonical persons/addresses/relationships; never create a second person identity table.

alter table game.persons
  add column if not exists birth_region_id uuid references game.regions(id) on delete set null,
  add column if not exists birth_city_id uuid references game.cities(id) on delete set null,
  add column if not exists date_of_death date,
  add column if not exists preferred_language text,
  add column if not exists personality_profile jsonb not null default '{}'::jsonb,
  add column if not exists behaviour_profile jsonb not null default '{}'::jsonb,
  add column if not exists simulation_level text not null default 'background',
  add column if not exists simulation_promoted_at_game_time timestamptz,
  add column if not exists simulation_promoted_reason text;

do $$
begin
  if not exists (select 1 from pg_constraint where conname='persons_date_of_death_after_birth') then
    alter table game.persons add constraint persons_date_of_death_after_birth
      check (date_of_death is null or date_of_birth is null or date_of_death >= date_of_birth);
  end if;
  if not exists (select 1 from pg_constraint where conname='persons_simulation_level_check') then
    alter table game.persons add constraint persons_simulation_level_check
      check (simulation_level in ('background','active','police_relevant','full'));
  end if;
  if not exists (select 1 from pg_constraint where conname='persons_personality_profile_object') then
    alter table game.persons add constraint persons_personality_profile_object
      check (jsonb_typeof(personality_profile)='object');
  end if;
  if not exists (select 1 from pg_constraint where conname='persons_behaviour_profile_object') then
    alter table game.persons add constraint persons_behaviour_profile_object
      check (jsonb_typeof(behaviour_profile)='object');
  end if;
  if not exists (select 1 from pg_constraint where conname='person_relationships_valid_dates') then
    alter table game.person_relationships add constraint person_relationships_valid_dates
      check (valid_from is null or valid_to is null or valid_to >= valid_from);
  end if;
  if not exists (select 1 from pg_constraint where conname='organisation_personnel_valid_dates') then
    alter table game.organisation_personnel add constraint organisation_personnel_valid_dates
      check (valid_from is null or valid_to is null or valid_to >= valid_from);
  end if;
end $$;

alter table game.person_addresses
  add column if not exists is_primary boolean not null default false;
alter table game.person_addresses alter column valid_from drop default;

create index if not exists persons_birth_region_fk_idx on game.persons(birth_region_id);
create index if not exists persons_birth_city_fk_idx on game.persons(birth_city_id);
create unique index if not exists person_addresses_one_current_primary_uidx
  on game.person_addresses(person_id) where is_current and is_primary;
create unique index if not exists person_addresses_one_current_role_uidx
  on game.person_addresses(person_id,address_role) where is_current;
create unique index if not exists person_relationships_one_current_pair_uidx
  on game.person_relationships(person_id,related_person_id,relationship_type) where valid_to is null;

create sequence if not exists game.household_ref_seq;
create sequence if not exists game.person_life_event_ref_seq;
create sequence if not exists game.person_routine_ref_seq;
create sequence if not exists game.person_activity_ref_seq;

create table if not exists game.households (
  id uuid primary key default gen_random_uuid(),
  household_ref text not null unique default ('KWHH-' || lpad(nextval('game.household_ref_seq')::text,8,'0')),
  household_type text not null check (household_type in ('single_person','family','shared','institutional','group','other')),
  primary_property_id uuid references game.properties(id) on delete set null,
  household_status text not null default 'active' check (household_status in ('active','dissolved')),
  formed_on date,
  dissolved_on date,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint households_valid_dates check (formed_on is null or dissolved_on is null or dissolved_on >= formed_on)
);

create table if not exists game.household_memberships (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references game.households(id) on delete restrict,
  person_id uuid not null references game.persons(id) on delete restrict,
  household_role text not null check (household_role in ('head','partner','child','parent','relative','dependent','housemate','lodger','other')),
  is_primary boolean not null default true,
  valid_from date not null,
  valid_to date,
  source_command_id uuid references game.game_commands(id) on delete set null,
  created_at timestamptz not null default now(),
  constraint household_memberships_valid_dates check (valid_to is null or valid_to >= valid_from)
);

create table if not exists game.person_population_memberships (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null references game.persons(id) on delete restrict,
  population_category text not null check (population_category in (
    'permanent_resident','temporary_resident','commuter','domestic_visitor','international_visitor',
    'government_worker','commercial_worker','transport_worker','institutional_worker',
    'student','retired','unemployed','other'
  )),
  valid_from date not null,
  valid_to date,
  details jsonb not null default '{}'::jsonb check (jsonb_typeof(details)='object'),
  source_command_id uuid references game.game_commands(id) on delete set null,
  created_at timestamptz not null default now(),
  constraint person_population_memberships_valid_dates check (valid_to is null or valid_to >= valid_from)
);

create table if not exists game.person_life_events (
  id uuid primary key default gen_random_uuid(),
  life_event_ref text not null unique default ('KWLE-' || lpad(nextval('game.person_life_event_ref_seq')::text,9,'0')),
  person_id uuid not null references game.persons(id) on delete restrict,
  event_type text not null check (event_type in (
    'birth','name_change','education_started','education_completed','qualification_awarded',
    'employment_started','employment_changed','employment_ended','address_changed',
    'household_joined','household_left','relationship_started','relationship_ended',
    'migration_in','migration_out','retirement','death','other'
  )),
  effective_on date not null,
  property_id uuid references game.properties(id) on delete set null,
  related_person_id uuid references game.persons(id) on delete set null,
  organisation_id uuid references game.organisations(id) on delete set null,
  details jsonb not null default '{}'::jsonb check (jsonb_typeof(details)='object'),
  source_command_id uuid references game.game_commands(id) on delete set null,
  recorded_at timestamptz not null default now()
);

create table if not exists game.person_routines (
  id uuid primary key default gen_random_uuid(),
  routine_ref text not null unique default ('KWR-' || lpad(nextval('game.person_routine_ref_seq')::text,9,'0')),
  person_id uuid not null references game.persons(id) on delete restrict,
  routine_category text not null check (routine_category in (
    'work','education','sleep','commute','care','social','shopping','exercise','leisure','cultural','other'
  )),
  activity_type text not null,
  day_of_week smallint not null check (day_of_week between 0 and 6),
  start_time time not null,
  end_time time not null,
  crosses_midnight boolean not null default false,
  location_property_id uuid references game.properties(id) on delete set null,
  destination_property_id uuid references game.properties(id) on delete set null,
  recurrence_start date,
  recurrence_end date,
  priority smallint not null default 3 check (priority between 1 and 5),
  confidence numeric(4,3) not null default 0.800 check (confidence between 0 and 1),
  routine_status text not null default 'active' check (routine_status in ('active','suspended','ended')),
  routine_source text not null default 'npc_generated' check (routine_source in ('seeded','person_reported','observed','inferred','npc_generated','other')),
  details jsonb not null default '{}'::jsonb check (jsonb_typeof(details)='object'),
  source_command_id uuid references game.game_commands(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint person_routines_valid_time check (
    (crosses_midnight and end_time < start_time) or
    (not crosses_midnight and end_time > start_time)
  ),
  constraint person_routines_valid_dates check (
    recurrence_start is null or recurrence_end is null or recurrence_end >= recurrence_start
  )
);

create table if not exists game.person_activity_events (
  id uuid primary key default gen_random_uuid(),
  activity_ref text not null unique default ('KWPA-' || lpad(nextval('game.person_activity_ref_seq')::text,9,'0')),
  person_id uuid not null references game.persons(id) on delete restrict,
  routine_id uuid references game.person_routines(id) on delete set null,
  activity_type text not null,
  activity_status text not null check (activity_status in ('completed','interrupted','cancelled')),
  started_at_game_time timestamptz not null,
  ended_at_game_time timestamptz not null,
  origin_property_id uuid references game.properties(id) on delete set null,
  destination_property_id uuid references game.properties(id) on delete set null,
  details jsonb not null default '{}'::jsonb check (jsonb_typeof(details)='object'),
  source_command_id uuid references game.game_commands(id) on delete set null,
  recorded_at timestamptz not null default now(),
  constraint person_activity_events_valid_time check (ended_at_game_time >= started_at_game_time)
);

create table if not exists game.person_simulation_promotions (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null references game.persons(id) on delete restrict,
  from_level text not null check (from_level in ('background','active','police_relevant','full')),
  to_level text not null check (to_level in ('background','active','police_relevant','full')),
  promotion_reason text not null,
  source_entity_type text not null,
  source_entity_id uuid,
  promoted_at_game_time timestamptz,
  recorded_at timestamptz not null default now(),
  constraint person_simulation_promotions_increase check (
    case from_level when 'background' then 1 when 'active' then 2 when 'police_relevant' then 3 else 4 end
    <
    case to_level when 'background' then 1 when 'active' then 2 when 'police_relevant' then 3 else 4 end
  )
);

create index if not exists households_primary_property_fk_idx on game.households(primary_property_id);
create index if not exists household_memberships_household_fk_idx on game.household_memberships(household_id);
create index if not exists household_memberships_person_fk_idx on game.household_memberships(person_id);
create unique index if not exists household_memberships_one_current_person_uidx
  on game.household_memberships(household_id,person_id) where valid_to is null;
create unique index if not exists household_memberships_one_primary_household_uidx
  on game.household_memberships(person_id) where valid_to is null and is_primary;
create index if not exists person_population_memberships_person_fk_idx on game.person_population_memberships(person_id);
create index if not exists person_population_memberships_category_current_idx
  on game.person_population_memberships(population_category,person_id) where valid_to is null;
create unique index if not exists person_population_memberships_one_current_category_uidx
  on game.person_population_memberships(person_id,population_category) where valid_to is null;
create index if not exists person_life_events_person_date_idx on game.person_life_events(person_id,effective_on desc);
create index if not exists person_life_events_related_person_fk_idx on game.person_life_events(related_person_id);
create index if not exists person_life_events_property_fk_idx on game.person_life_events(property_id);
create index if not exists person_life_events_organisation_fk_idx on game.person_life_events(organisation_id);
create index if not exists person_routines_person_schedule_idx on game.person_routines(person_id,day_of_week,start_time) where routine_status='active';
create index if not exists person_routines_location_fk_idx on game.person_routines(location_property_id);
create index if not exists person_routines_destination_fk_idx on game.person_routines(destination_property_id);
create index if not exists person_activity_events_person_time_idx on game.person_activity_events(person_id,started_at_game_time desc);
create index if not exists person_activity_events_routine_fk_idx on game.person_activity_events(routine_id);
create index if not exists person_activity_events_origin_fk_idx on game.person_activity_events(origin_property_id);
create index if not exists person_activity_events_destination_fk_idx on game.person_activity_events(destination_property_id);
create index if not exists person_simulation_promotions_person_time_idx
  on game.person_simulation_promotions(person_id,recorded_at desc);

create or replace function game.reject_person_history_mutation()
returns trigger
language plpgsql
as $$
begin
  raise exception 'Person history is append-only: % is not permitted on %', tg_op, tg_table_name;
end;
$$;

create or replace function game.guard_person_simulation_level()
returns trigger
language plpgsql
as $$
declare
  v_old_rank integer;
  v_new_rank integer;
  v_game_time timestamptz;
begin
  v_old_rank := case old.simulation_level when 'background' then 1 when 'active' then 2 when 'police_relevant' then 3 else 4 end;
  v_new_rank := case new.simulation_level when 'background' then 1 when 'active' then 2 when 'police_relevant' then 3 else 4 end;
  if v_new_rank < v_old_rank then
    raise exception 'Person simulation detail cannot be downgraded';
  end if;
  if v_new_rank > v_old_rank then
    if nullif(btrim(new.simulation_promoted_reason),'') is null then
      raise exception 'A reason is required when increasing person simulation detail';
    end if;
    if new.simulation_promoted_at_game_time is null then
      select current_game_time into v_game_time from game.simulation_state where id=1;
      new.simulation_promoted_at_game_time := v_game_time;
    end if;
  end if;
  return new;
end;
$$;

create or replace function game.log_person_simulation_promotion()
returns trigger
language plpgsql
as $$
declare
  v_source_type text;
  v_source_id text;
begin
  if new.simulation_level is distinct from old.simulation_level then
    v_source_type := coalesce(nullif(current_setting('game.person_promotion_source_type',true),''),'direct_update');
    v_source_id := nullif(current_setting('game.person_promotion_source_id',true),'');
    insert into game.person_simulation_promotions(
      person_id,from_level,to_level,promotion_reason,source_entity_type,source_entity_id,promoted_at_game_time
    ) values (
      new.id,old.simulation_level,new.simulation_level,new.simulation_promoted_reason,
      v_source_type,case when v_source_id is null then null else v_source_id::uuid end,
      new.simulation_promoted_at_game_time
    );
  end if;
  return new;
end;
$$;

create or replace function game.promote_person_simulation(
  p_person_id uuid,
  p_target_level text,
  p_reason text,
  p_source_entity_type text default 'manual',
  p_source_entity_id uuid default null
)
returns boolean
language plpgsql
as $$
declare
  v_current_level text;
  v_current_rank integer;
  v_target_rank integer;
  v_game_time timestamptz;
begin
  if p_target_level not in ('background','active','police_relevant','full') then
    raise exception 'Invalid person simulation level';
  end if;
  if nullif(btrim(p_reason),'') is null then
    raise exception 'A promotion reason is required';
  end if;
  select simulation_level into v_current_level from game.persons where id=p_person_id for update;
  if not found then raise exception 'Person not found'; end if;
  v_current_rank := case v_current_level when 'background' then 1 when 'active' then 2 when 'police_relevant' then 3 else 4 end;
  v_target_rank := case p_target_level when 'background' then 1 when 'active' then 2 when 'police_relevant' then 3 else 4 end;
  if v_target_rank <= v_current_rank then return false; end if;
  select current_game_time into v_game_time from game.simulation_state where id=1;
  perform set_config('game.person_promotion_source_type',coalesce(p_source_entity_type,'manual'),true);
  perform set_config('game.person_promotion_source_id',coalesce(p_source_entity_id::text,''),true);
  update game.persons
  set simulation_level=p_target_level,
      simulation_promoted_at_game_time=coalesce(simulation_promoted_at_game_time,v_game_time),
      simulation_promoted_reason=p_reason,
      updated_at=now()
  where id=p_person_id;
  return true;
end;
$$;

create or replace function game.promote_person_on_case_link()
returns trigger
language plpgsql
as $$
declare v_case_ref text;
begin
  select case_ref into v_case_ref from game.cases where id=new.case_id;
  perform game.promote_person_simulation(
    new.person_id,'full',
    'Linked to case ' || coalesce(v_case_ref,new.case_id::text) || ' as ' || new.case_role,
    'case_person',new.case_id
  );
  return new;
end;
$$;

create or replace function game.promote_person_on_incident_link()
returns trigger
language plpgsql
as $$
declare v_incident_ref text;
begin
  select incident_ref into v_incident_ref from game.incidents where id=new.incident_id;
  perform game.promote_person_simulation(
    new.person_id,'full',
    'Linked to incident ' || coalesce(v_incident_ref,new.incident_id::text) || ' as ' || new.party_role,
    'incident_party',new.incident_id
  );
  return new;
end;
$$;

create or replace function game.promote_dispatch_caller()
returns trigger
language plpgsql
as $$
begin
  if new.caller_person_id is not null then
    perform game.promote_person_simulation(
      new.caller_person_id,'full',
      'Recorded as caller on dispatch call ' || new.call_ref,
      'dispatch_call',new.id
    );
  end if;
  return new;
end;
$$;

create or replace function game.promote_residents_at_incident_property()
returns trigger
language plpgsql
as $$
declare v_person record;
begin
  if new.location_property_id is not null
    and (tg_op='INSERT' or old.location_property_id is distinct from new.location_property_id) then
    for v_person in
      select distinct person_id
      from game.person_addresses
      where property_id=new.location_property_id
        and is_current
        and address_role='residence'
    loop
      perform game.promote_person_simulation(
        v_person.person_id,'full',
        'Current resident at incident location ' || new.incident_ref,
        'incident_location_resident',new.id
      );
    end loop;
  end if;
  return new;
end;
$$;

create or replace function game.apply_person_death_event()
returns trigger
language plpgsql
as $$
begin
  if new.event_type='death' then
    update game.persons
    set person_status='deceased',date_of_death=new.effective_on,updated_at=now()
    where id=new.person_id and person_status<>'deceased';
    if not found and not exists(
      select 1 from game.persons where id=new.person_id and person_status='deceased' and date_of_death=new.effective_on
    ) then
      raise exception 'Person already has a conflicting death record';
    end if;
  end if;
  return new;
end;
$$;

create or replace function game.require_person_activity_clock()
returns trigger
language plpgsql
as $$
declare v_clock timestamptz;
begin
  select current_game_time into v_clock from game.simulation_state where id=1;
  if v_clock is null then raise exception 'Fictional game clock is not initialized'; end if;
  if new.ended_at_game_time > v_clock then
    raise exception 'Person activity cannot end after the current fictional game time';
  end if;
  return new;
end;
$$;

create or replace function game.calculate_person_age(p_person_id uuid)
returns integer
language sql
stable
as $$
  select case
    when p.date_of_birth is null then null
    when p.person_status='deceased' and p.date_of_death is not null
      then date_part('year',age(p.date_of_death,p.date_of_birth))::integer
    when s.current_game_time is not null
      then date_part('year',age(s.current_game_time::date,p.date_of_birth))::integer
    else null
  end
  from game.persons p
  cross join game.simulation_state s
  where p.id=p_person_id and s.id=1;
$$;

create trigger persons_simulation_level_guard
before update of simulation_level on game.persons
for each row execute function game.guard_person_simulation_level();

create trigger persons_simulation_promotion_history
after update of simulation_level on game.persons
for each row execute function game.log_person_simulation_promotion();

create trigger person_life_events_death_sync
after insert on game.person_life_events
for each row execute function game.apply_person_death_event();

create trigger person_life_events_append_only
before update or delete on game.person_life_events
for each row execute function game.reject_person_history_mutation();

create trigger person_activity_events_clock_guard
before insert on game.person_activity_events
for each row execute function game.require_person_activity_clock();

create trigger person_activity_events_append_only
before update or delete on game.person_activity_events
for each row execute function game.reject_person_history_mutation();

create trigger person_simulation_promotions_append_only
before update or delete on game.person_simulation_promotions
for each row execute function game.reject_person_history_mutation();

create trigger case_persons_promote_person
after insert or update of person_id on game.case_persons
for each row execute function game.promote_person_on_case_link();

create trigger incident_parties_promote_person
after insert or update of person_id on game.incident_parties
for each row execute function game.promote_person_on_incident_link();

create trigger dispatch_calls_promote_caller
after insert or update of caller_person_id on game.dispatch_calls
for each row execute function game.promote_dispatch_caller();

create trigger incidents_promote_residents_at_location
after insert or update of location_property_id on game.incidents
for each row execute function game.promote_residents_at_incident_property();

alter table game.households enable row level security;
alter table game.household_memberships enable row level security;
alter table game.person_population_memberships enable row level security;
alter table game.person_life_events enable row level security;
alter table game.person_routines enable row level security;
alter table game.person_activity_events enable row level security;
alter table game.person_simulation_promotions enable row level security;

revoke all on game.households,game.household_memberships,game.person_population_memberships,
  game.person_life_events,game.person_routines,game.person_activity_events,
  game.person_simulation_promotions from public,anon,authenticated;
grant all on game.households,game.household_memberships,game.person_population_memberships,
  game.person_life_events,game.person_routines,game.person_activity_events,
  game.person_simulation_promotions to service_role;

revoke all on sequence game.household_ref_seq,game.person_life_event_ref_seq,
  game.person_routine_ref_seq,game.person_activity_ref_seq from public,anon,authenticated;
grant usage,select on sequence game.household_ref_seq,game.person_life_event_ref_seq,
  game.person_routine_ref_seq,game.person_activity_ref_seq to service_role;

revoke all on function game.promote_person_simulation(uuid,text,text,text,uuid) from public,anon,authenticated;
grant execute on function game.promote_person_simulation(uuid,text,text,text,uuid) to service_role;
revoke all on function game.calculate_person_age(uuid) from public,anon,authenticated;
grant execute on function game.calculate_person_age(uuid) to service_role;
