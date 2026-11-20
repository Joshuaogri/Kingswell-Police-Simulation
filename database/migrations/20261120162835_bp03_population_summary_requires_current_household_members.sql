-- BP-03 population summary counts only active households with at least one current member.
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
      and exists(select 1 from game.household_memberships hm
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
