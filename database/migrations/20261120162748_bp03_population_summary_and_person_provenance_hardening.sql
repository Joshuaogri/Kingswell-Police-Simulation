-- BP-03 hardening: isolate promotion provenance and index every new foreign key.
alter table game.person_population_memberships
  add column if not exists city_id uuid references game.cities(id) on delete set null;

create index if not exists person_population_memberships_city_fk_idx
  on game.person_population_memberships(city_id);
create index if not exists household_memberships_source_command_fk_idx
  on game.household_memberships(source_command_id);
create index if not exists household_memberships_person_history_idx
  on game.household_memberships(person_id,valid_from desc);
create index if not exists person_population_memberships_source_command_fk_idx
  on game.person_population_memberships(source_command_id);
create index if not exists person_life_events_source_command_fk_idx
  on game.person_life_events(source_command_id);
create index if not exists person_routines_source_command_fk_idx
  on game.person_routines(source_command_id);
create index if not exists person_activity_events_source_command_fk_idx
  on game.person_activity_events(source_command_id);

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
  perform set_config('game.person_promotion_source_type','',true);
  perform set_config('game.person_promotion_source_id','',true);
  return true;
end;
$$;

create or replace function game.get_population_summary(p_city_code text)
returns table(
  city_code text,
  unique_people bigint,
  permanent_residents bigint,
  temporary_residents bigint,
  commuters bigint,
  domestic_visitors bigint,
  international_visitors bigint,
  government_workers bigint,
  commercial_workers bigint,
  transport_workers bigint,
  institutional_workers bigint,
  current_households bigint
)
language sql
stable
as $$
  with city as (
    select id,code from game.cities where code=p_city_code
  ),
  city_people as (
    select distinct m.person_id
    from game.person_population_memberships m
    join city c on c.id=m.city_id
    where m.valid_to is null
    union
    select distinct a.person_id
    from game.person_addresses a
    join game.properties p on p.id=a.property_id
    join city c on c.id=p.city_id
    where a.is_current
  ),
  category_counts as (
    select
      count(distinct person_id) filter(where population_category='permanent_resident') permanent_residents,
      count(distinct person_id) filter(where population_category='temporary_resident') temporary_residents,
      count(distinct person_id) filter(where population_category='commuter') commuters,
      count(distinct person_id) filter(where population_category='domestic_visitor') domestic_visitors,
      count(distinct person_id) filter(where population_category='international_visitor') international_visitors,
      count(distinct person_id) filter(where population_category='government_worker') government_workers,
      count(distinct person_id) filter(where population_category='commercial_worker') commercial_workers,
      count(distinct person_id) filter(where population_category='transport_worker') transport_workers,
      count(distinct person_id) filter(where population_category='institutional_worker') institutional_workers
    from game.person_population_memberships m
    join city c on c.id=m.city_id
    where m.valid_to is null
  ),
  household_counts as (
    select count(*)::bigint current_households
    from game.households h
    join game.properties p on p.id=h.primary_property_id
    join city c on c.id=p.city_id
    where h.household_status='active'
  )
  select c.code,
    (select count(*)::bigint from city_people),
    coalesce(cc.permanent_residents,0),
    coalesce(cc.temporary_residents,0),
    coalesce(cc.commuters,0),
    coalesce(cc.domestic_visitors,0),
    coalesce(cc.international_visitors,0),
    coalesce(cc.government_workers,0),
    coalesce(cc.commercial_workers,0),
    coalesce(cc.transport_workers,0),
    coalesce(cc.institutional_workers,0),
    hc.current_households
  from city c cross join category_counts cc cross join household_counts hc;
$$;

revoke all on function game.get_population_summary(text) from public,anon,authenticated;
grant execute on function game.get_population_summary(text) to service_role;
