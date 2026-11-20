-- BP-03: a death life event ends current living memberships and excludes deceased people from live counts.
create or replace function game.apply_person_death_event()
returns trigger
language plpgsql
as $$
declare
  v_birth date;
  v_status text;
  v_death date;
begin
  if new.event_type='death' then
    select date_of_birth,person_status,date_of_death
      into v_birth,v_status,v_death
    from game.persons where id=new.person_id for update;
    if v_birth is not null and new.effective_on<v_birth then
      raise exception 'Death event cannot precede date of birth';
    end if;
    if v_status='deceased' and v_death is not null and v_death<>new.effective_on then
      raise exception 'Person already has a conflicting death record';
    end if;
    if exists(select 1 from game.person_addresses where person_id=new.person_id and is_current and valid_from>new.effective_on)
      or exists(select 1 from game.household_memberships where person_id=new.person_id and valid_to is null and valid_from>new.effective_on)
      or exists(select 1 from game.person_population_memberships where person_id=new.person_id and valid_to is null and valid_from>new.effective_on)
      or exists(select 1 from game.organisation_personnel where person_id=new.person_id and is_current and valid_from>new.effective_on) then
      raise exception 'Death date conflicts with a future-dated current person membership';
    end if;

    update game.persons
    set person_status='deceased',date_of_death=new.effective_on,updated_at=now()
    where id=new.person_id;

    update game.person_addresses
    set is_current=false,valid_to=new.effective_on
    where person_id=new.person_id and is_current;

    update game.household_memberships
    set valid_to=new.effective_on
    where person_id=new.person_id and valid_to is null;

    update game.person_population_memberships
    set valid_to=new.effective_on
    where person_id=new.person_id and valid_to is null;

    update game.person_routines
    set routine_status='ended',updated_at=now()
    where person_id=new.person_id and routine_status='active';

    update game.organisation_personnel
    set is_current=false,valid_to=new.effective_on
    where person_id=new.person_id and is_current;
  end if;
  return new;
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
    join game.persons person on person.id=m.person_id and person.person_status<>'deceased'
    join city c on c.id=m.city_id
    where m.valid_to is null
    union
    select distinct a.person_id
    from game.person_addresses a
    join game.persons person on person.id=a.person_id and person.person_status<>'deceased'
    join game.properties p on p.id=a.property_id
    join city c on c.id=p.city_id
    where a.is_current
  ),
  category_counts as (
    select
      count(distinct m.person_id) filter(where m.population_category='permanent_resident') permanent_residents,
      count(distinct m.person_id) filter(where m.population_category='temporary_resident') temporary_residents,
      count(distinct m.person_id) filter(where m.population_category='commuter') commuters,
      count(distinct m.person_id) filter(where m.population_category='domestic_visitor') domestic_visitors,
      count(distinct m.person_id) filter(where m.population_category='international_visitor') international_visitors,
      count(distinct m.person_id) filter(where m.population_category='government_worker') government_workers,
      count(distinct m.person_id) filter(where m.population_category='commercial_worker') commercial_workers,
      count(distinct m.person_id) filter(where m.population_category='transport_worker') transport_workers,
      count(distinct m.person_id) filter(where m.population_category='institutional_worker') institutional_workers
    from game.person_population_memberships m
    join game.persons person on person.id=m.person_id and person.person_status<>'deceased'
    join city c on c.id=m.city_id
    where m.valid_to is null
  ),
  household_counts as (
    select count(*)::bigint current_households
    from game.households h
    join game.properties p on p.id=h.primary_property_id
    join city c on c.id=p.city_id
    where h.household_status='active'
      and exists(select 1 from game.household_memberships hm
        join game.persons person on person.id=hm.person_id and person.person_status<>'deceased'
        where hm.household_id=h.id and hm.valid_to is null)
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
