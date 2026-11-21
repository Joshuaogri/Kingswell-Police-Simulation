-- BP-03 / BP-04 canonical identity and display-name uniqueness remediation.
-- Corrects generated fictional seed repetition without changing canonical IDs or relationships.
-- Existing names are retained in an append-only correction ledger.

begin;

create table if not exists game.canonical_name_corrections (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null check (entity_type in
    ('person','business','organisation','property','property_address','site','road')),
  entity_id uuid not null,
  entity_ref text not null,
  field_name text not null,
  previous_value text,
  corrected_value text not null,
  correction_reason text not null,
  migration_ref text not null,
  recorded_at timestamptz not null default now()
);

alter table game.canonical_name_corrections enable row level security;
revoke all on game.canonical_name_corrections from public, anon, authenticated;
grant select on game.canonical_name_corrections to service_role;

create or replace function game.prevent_canonical_name_correction_mutation()
returns trigger
language plpgsql
set search_path = pg_catalog, game
as $$
begin
  raise exception 'Canonical name correction history is append-only';
end;
$$;

drop trigger if exists canonical_name_corrections_immutable on game.canonical_name_corrections;
create trigger canonical_name_corrections_immutable
before update or delete on game.canonical_name_corrections
for each row execute function game.prevent_canonical_name_correction_mutation();

create or replace function game.normalise_entity_name(p_name text)
returns text
language sql
immutable
parallel safe
set search_path = pg_catalog
as $$
  select regexp_replace(lower(btrim(coalesce(p_name,''))), '[^[:alnum:]]', '', 'g');
$$;

-- ---------------------------------------------------------------------------
-- BP-03: give every resident a distinct full name while preserving given name,
-- family name, date of birth, person_ref, and every relationship/reference.
-- The existing seed has 40 given names x 25 family names, with up to 126
-- people sharing one given/family combination. A 40 x 25 middle-name pair
-- space gives 1,000 deterministic, distinct middle-name combinations per pair.
-- ---------------------------------------------------------------------------

do $$
declare v_max_group integer;
begin
  select max(n) into v_max_group
  from (
    select count(*)::integer n
    from game.persons
    group by lower(given_name), lower(family_name)
  ) grouped;
  if coalesce(v_max_group,0) > 1000 then
    raise exception 'Person name remediation capacity exceeded: largest base-name group is %',v_max_group;
  end if;
end;
$$;

with ranked as (
  select p.id,p.person_ref,p.given_name,p.family_name,
    row_number() over (
      partition by lower(p.given_name),lower(p.family_name)
      order by p.person_ref
    )::integer as name_rank
  from game.persons p
),
generated as (
  select id,
    (array['Ari','Mara','Jon','Iris','Noah','Talia','Eli','Nia','Milan','Amara',
      'Theo','Zara','Caleb','Leila','Micah','Sana','Ezra','Mira','Daniel','Ada',
      'Samuel','Lina','Rafael','Kira','Isaac','Naomi','Owen','Esme','Gabriel','Asha',
      'Felix','Imani','David','Elena','Nathan','Sofia','Joel','Maya','Simon','Amina'])
      [((name_rank-1)/25)+1]
    || ' ' ||
    (array['Aster','Bennett','Caldwell','Dawson','Ellery','Farrow','Givens','Hale',
      'Iver','Jensen','Kellan','Lang','Morrow','Nolan','Orwell','Parker',
      'Quinn','Rowe','Sutton','Tallis','Underwood','Vale','West','Yarrow','Zorin'])
      [((name_rank-1)%25)+1] as middle_names
  from ranked
)
insert into game.canonical_name_corrections(
  entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,
  correction_reason,migration_ref
)
select 'person',p.id,p.person_ref,'display_name',
  concat_ws(' ',p.given_name,nullif(p.middle_names,''),p.family_name),
  concat_ws(' ',p.given_name,g.middle_names,p.family_name),
  'BP-03 generated population reused only 1,000 full-name combinations across 100,000 distinct people; assigned deterministic unique middle names.',
  '20261121340000_bp03_bp04_canonical_name_uniqueness'
from generated g join game.persons p on p.id=g.id
where p.middle_names is null or btrim(p.middle_names)='';

with ranked as (
  select p.id,p.person_ref,p.given_name,p.family_name,
    row_number() over (
      partition by lower(p.given_name),lower(p.family_name)
      order by p.person_ref
    )::integer as name_rank
  from game.persons p
),
generated as (
  select id,
    (array['Ari','Mara','Jon','Iris','Noah','Talia','Eli','Nia','Milan','Amara',
      'Theo','Zara','Caleb','Leila','Micah','Sana','Ezra','Mira','Daniel','Ada',
      'Samuel','Lina','Rafael','Kira','Isaac','Naomi','Owen','Esme','Gabriel','Asha',
      'Felix','Imani','David','Elena','Nathan','Sofia','Joel','Maya','Simon','Amina'])
      [((name_rank-1)/25)+1]
    || ' ' ||
    (array['Aster','Bennett','Caldwell','Dawson','Ellery','Farrow','Givens','Hale',
      'Iver','Jensen','Kellan','Lang','Morrow','Nolan','Orwell','Parker',
      'Quinn','Rowe','Sutton','Tallis','Underwood','Vale','West','Yarrow','Zorin'])
      [((name_rank-1)%25)+1] as middle_names
  from ranked
)
update game.persons p
set middle_names=g.middle_names,updated_at=now()
from generated g
where p.id=g.id and (p.middle_names is null or btrim(p.middle_names)='');

create unique index if not exists persons_unique_full_display_name_uidx
on game.persons (
  game.normalise_entity_name(concat_ws(' ',given_name,nullif(middle_names,''),family_name))
);

-- Future BP-03 person generation gets an unused middle-name pair automatically.
create or replace function game.assign_unique_person_middle_name()
returns trigger
language plpgsql
set search_path = pg_catalog, game
as $$
declare
  v_rank integer;
  v_lock_key bigint;
begin
  if new.middle_names is not null and btrim(new.middle_names)<>'' then
    return new;
  end if;

  v_lock_key:=hashtextextended(lower(coalesce(new.given_name,'')||'|'||coalesce(new.family_name,'')),0);
  perform pg_advisory_xact_lock(v_lock_key);

  select count(*)::integer+1 into v_rank
  from game.persons p
  where lower(p.given_name)=lower(new.given_name)
    and lower(p.family_name)=lower(new.family_name)
    and (new.id is null or p.id<>new.id);

  if v_rank>1000 then
    raise exception 'No unused generated middle-name combination remains for % %',
      new.given_name,new.family_name;
  end if;

  new.middle_names :=
    (array['Ari','Mara','Jon','Iris','Noah','Talia','Eli','Nia','Milan','Amara',
      'Theo','Zara','Caleb','Leila','Micah','Sana','Ezra','Mira','Daniel','Ada',
      'Samuel','Lina','Rafael','Kira','Isaac','Naomi','Owen','Esme','Gabriel','Asha',
      'Felix','Imani','David','Elena','Nathan','Sofia','Joel','Maya','Simon','Amina'])
      [((v_rank-1)/25)+1]
    || ' ' ||
    (array['Aster','Bennett','Caldwell','Dawson','Ellery','Farrow','Givens','Hale',
      'Iver','Jensen','Kellan','Lang','Morrow','Nolan','Orwell','Parker',
      'Quinn','Rowe','Sutton','Tallis','Underwood','Vale','West','Yarrow','Zorin'])
      [((v_rank-1)%25)+1];

  return new;
end;
$$;

drop trigger if exists persons_00_assign_unique_middle_name on game.persons;
create trigger persons_00_assign_unique_middle_name
before insert or update of given_name,middle_names,family_name on game.persons
for each row execute function game.assign_unique_person_middle_name();

-- ---------------------------------------------------------------------------
-- BP-04: independently named businesses and legal organisations.
-- Trading names are rebuilt from a deterministic 3 x 40 x 25 name space and
-- sector-specific descriptors. Legal organisation names use distinct legal
-- forms and are not copied from their trading names.
-- ---------------------------------------------------------------------------

create temporary table bp04_name_rebuild on commit drop as
with ranked as (
  select bp.organisation_id,bp.business_number,bp.ownership_form,bp.sector,
    row_number() over(order by bp.business_number)::integer rn
  from game.business_profiles bp
),
generated as (
  select r.*,
    concat(
      (array['Asterfell','Kingswell','Eastmarch'])[((rn-1)/1000)+1],' ',
      (array['Ari','Mara','Jon','Iris','Noah','Talia','Eli','Nia','Milan','Amara',
        'Theo','Zara','Caleb','Leila','Micah','Sana','Ezra','Mira','Daniel','Ada',
        'Samuel','Lina','Rafael','Kira','Isaac','Naomi','Owen','Esme','Gabriel','Asha',
        'Felix','Imani','David','Elena','Nathan','Sofia','Joel','Maya','Simon','Amina'])
        [(((rn-1)%1000)/25)+1],' ',
      (array['Aster','Bennett','Caldwell','Dawson','Ellery','Farrow','Givens','Hale',
        'Iver','Jensen','Kellan','Lang','Morrow','Nolan','Orwell','Parker',
        'Quinn','Rowe','Sutton','Tallis','Underwood','Vale','West','Yarrow','Zorin'])
        [((rn-1)%25)+1],' ',
      case sector
        when 'financial_services' then 'Capital'
        when 'import_export' then 'International Trading'
        when 'logistics_warehousing' then 'Freight and Warehousing'
        when 'transport_services' then 'Transport'
        when 'manufacturing' then 'Manufacturing'
        when 'wholesale_trade' then 'Wholesale Supply'
        when 'retail' then 'Retail'
        when 'hospitality_entertainment' then 'Hospitality'
        when 'professional_services' then 'Advisory'
        when 'technology_media' then 'Digital Media'
        when 'construction_property' then 'Property Development'
        else 'Property Management'
      end
    ) as trading_name
  from ranked r
)
select generated.*,
  trading_name ||
  case ownership_form
    when 'private_limited' then ' Limited'
    when 'public_company' then ' Public Limited Company'
    when 'partnership' then ' Partnership'
    when 'family_enterprise' then ' Family Enterprise'
    when 'sole_trader' then ' Trading Concern'
    else ' Registered Entity'
  end as legal_name
from generated;

do $$
declare v_count integer; v_distinct integer;
begin
  select count(*),count(distinct game.normalise_entity_name(trading_name))
  into v_count,v_distinct from bp04_name_rebuild;
  if v_count<>v_distinct then
    raise exception 'Generated BP-04 trading names are not unique: % records, % unique',v_count,v_distinct;
  end if;
end;
$$;

insert into game.canonical_name_corrections(
  entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,
  correction_reason,migration_ref
)
select 'business',bp.organisation_id,bp.business_number,'trading_name',
  bp.trading_name,n.trading_name,
  'BP-04 seed used a small set of repeated brand names distinguished only by serial suffixes; assigned distinct fictional trading names.',
  '20261121340000_bp03_bp04_canonical_name_uniqueness'
from game.business_profiles bp
join bp04_name_rebuild n on n.organisation_id=bp.organisation_id
where bp.trading_name is distinct from n.trading_name;

update game.business_profiles bp
set trading_name=n.trading_name,updated_at=now()
from bp04_name_rebuild n
where n.organisation_id=bp.organisation_id
  and bp.trading_name is distinct from n.trading_name;

insert into game.canonical_name_corrections(
  entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,
  correction_reason,migration_ref
)
select 'organisation',o.id,o.organisation_ref,'name',o.name,n.legal_name,
  'BP-04 legal organisation names must be distinct from the linked business trading names; this is a fictional canonical identity correction.',
  '20261121340000_bp03_bp04_canonical_name_uniqueness'
from game.organisations o
join bp04_name_rebuild n on n.organisation_id=o.id
where o.name is distinct from n.legal_name;

update game.organisations o
set name=n.legal_name,updated_at=now()
from bp04_name_rebuild n
where n.organisation_id=o.id
  and o.name is distinct from n.legal_name;

-- Site display names follow the business trading identity, not the legal entity name.
insert into game.canonical_name_corrections(
  entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,
  correction_reason,migration_ref
)
select 'site',ol.id,ol.site_ref,'site_name',ol.site_name,bp.trading_name,
  'Synchronised the site display name with its canonical business trading identity.',
  '20261121340000_bp03_bp04_canonical_name_uniqueness'
from game.organisation_locations ol
join game.business_profiles bp on bp.organisation_id=ol.organisation_id
where ol.site_name is distinct from bp.trading_name;

update game.organisation_locations ol
set site_name=bp.trading_name
from game.business_profiles bp
where bp.organisation_id=ol.organisation_id
  and ol.site_name is distinct from bp.trading_name;

create unique index if not exists business_profiles_unique_trading_name_uidx
on game.business_profiles(game.normalise_entity_name(trading_name));

create unique index if not exists organisations_unique_display_name_uidx
on game.organisations(game.normalise_entity_name(name));

-- ---------------------------------------------------------------------------
-- BP-04: every property receives a distinct named identity. Repeated generic
-- address placeholders are replaced by the full, already-defined street address.
-- Building names were already unique and are protected below.
-- ---------------------------------------------------------------------------

alter table game.properties add column if not exists property_name text;

with named as (
  select p.id,p.property_ref,n.name neighbourhood_name,
    initcap(replace(p.property_type,'_',' ')) property_type_label,
    row_number() over(
      partition by p.neighbourhood_id,p.property_type
      order by p.property_ref
    )::integer name_number
  from game.properties p
  join game.neighbourhoods n on n.id=p.neighbourhood_id
),
generated as (
  select id,property_ref,
    neighbourhood_name||' '||property_type_label||' Parcel '||lpad(name_number::text,3,'0') property_name
  from named
)
insert into game.canonical_name_corrections(
  entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,
  correction_reason,migration_ref
)
select 'property',p.id,p.property_ref,'property_name',p.property_name,g.property_name,
  'Assigned a distinct canonical property name based on neighbourhood, property use and local sequence.',
  '20261121340000_bp03_bp04_canonical_name_uniqueness'
from game.properties p join generated g on g.id=p.id
where p.property_name is distinct from g.property_name;

with named as (
  select p.id,p.property_ref,n.name neighbourhood_name,
    initcap(replace(p.property_type,'_',' ')) property_type_label,
    row_number() over(
      partition by p.neighbourhood_id,p.property_type
      order by p.property_ref
    )::integer name_number
  from game.properties p
  join game.neighbourhoods n on n.id=p.neighbourhood_id
)
update game.properties p
set property_name=n.neighbourhood_name||' '||n.property_type_label||
  ' Parcel '||lpad(n.name_number::text,3,'0')
from named n
where n.id=p.id
  and p.property_name is distinct from
    (n.neighbourhood_name||' '||n.property_type_label||' Parcel '||lpad(n.name_number::text,3,'0'));

insert into game.canonical_name_corrections(
  entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,
  correction_reason,migration_ref
)
select 'property_address',p.id,p.property_ref,'address_line',p.address_line,
  concat_ws(', ',concat_ws(' ',p.street_number,r.name),n.name,d.name,'Kingswell','Asterfell',p.postal_code),
  'Replaced a repeated generic parcel placeholder with the already-defined unique street address.',
  '20261121340000_bp03_bp04_canonical_name_uniqueness'
from game.properties p
join game.roads r on r.id=p.road_id
join game.neighbourhoods n on n.id=p.neighbourhood_id
join game.districts d on d.id=p.district_id
where p.address_line in ('Residential tower parcel','Commercial development parcel');

update game.properties p
set address_line=concat_ws(', ',concat_ws(' ',p.street_number,r.name),n.name,d.name,'Kingswell','Asterfell',p.postal_code)
from game.roads r,game.neighbourhoods n,game.districts d
where p.road_id=r.id and p.neighbourhood_id=n.id and p.district_id=d.id
  and p.address_line in ('Residential tower parcel','Commercial development parcel');

create unique index if not exists properties_unique_property_name_uidx
on game.properties(game.normalise_entity_name(property_name));
create unique index if not exists properties_unique_address_line_uidx
on game.properties(game.normalise_entity_name(address_line));
create unique index if not exists buildings_unique_display_name_uidx
on game.buildings(game.normalise_entity_name(name));

-- ---------------------------------------------------------------------------
-- BP-02 roads: all 75 road names were already unique. Populate the formal
-- official_name field for the 51 missing records and enforce city-level uniqueness.
-- ---------------------------------------------------------------------------

insert into game.canonical_name_corrections(
  entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,
  correction_reason,migration_ref
)
select 'road',r.id,coalesce(r.code,r.id::text),'official_name',r.official_name,r.name,
  'Filled the missing official gazetteer name from the existing unique canonical road name.',
  '20261121340000_bp03_bp04_canonical_name_uniqueness'
from game.roads r
where r.official_name is null or btrim(r.official_name)='';

update game.roads
set official_name=name
where official_name is null or btrim(official_name)='';

create unique index if not exists roads_city_unique_official_name_uidx
on game.roads(city_id,game.normalise_entity_name(official_name));
create unique index if not exists roads_city_unique_name_uidx
on game.roads(city_id,game.normalise_entity_name(name));

-- ---------------------------------------------------------------------------
-- Expose the new canonical property name in every property dossier.
-- ---------------------------------------------------------------------------

alter function game.get_property_record(text)
rename to get_property_record_before_bp03_bp04_name_uniqueness;

create or replace function game.get_property_record(p_property_ref text)
returns jsonb
language plpgsql
stable
set search_path to pg_catalog, game
as $function$
declare
  v_record jsonb;
  v_property_name text;
begin
  v_record:=game.get_property_record_before_bp03_bp04_name_uniqueness(p_property_ref);
  if v_record is null then return null; end if;

  select property_name into v_property_name
  from game.properties
  where property_ref=btrim(p_property_ref);

  return jsonb_set(v_record,'{property,property_name}',to_jsonb(v_property_name),true);
end;
$function$;

revoke all on function game.get_property_record(text) from public,anon,authenticated;
grant execute on function game.get_property_record(text) to service_role;

-- ---------------------------------------------------------------------------
-- Cross-domain guard: exact or punctuation-only duplicate display names cannot
-- be introduced between BP-03 people and BP-04 business/organisation/property
-- records, nor between those records and named roads/buildings.
-- ---------------------------------------------------------------------------

create or replace function game.enforce_cross_domain_name_separation()
returns trigger
language plpgsql
set search_path = pg_catalog, game
as $function$
declare
  v_name text;
  v_exclude uuid;
begin
  if tg_table_name='persons' then
    v_name:=game.normalise_entity_name(concat_ws(' ',new.given_name,nullif(new.middle_names,''),new.family_name));
    v_exclude:=new.id;
    if exists(select 1 from game.business_profiles b where game.normalise_entity_name(b.trading_name)=v_name)
      or exists(select 1 from game.organisations o where game.normalise_entity_name(o.name)=v_name)
      or exists(select 1 from game.properties p where game.normalise_entity_name(p.property_name)=v_name)
      or exists(select 1 from game.buildings b where game.normalise_entity_name(b.name)=v_name)
      or exists(select 1 from game.roads r where game.normalise_entity_name(coalesce(nullif(r.official_name,''),r.name))=v_name)
    then raise exception 'Person display name conflicts with another canonical entity'; end if;

  elsif tg_table_name='business_profiles' then
    v_name:=game.normalise_entity_name(new.trading_name);
    if exists(select 1 from game.persons p where game.normalise_entity_name(concat_ws(' ',p.given_name,nullif(p.middle_names,''),p.family_name))=v_name)
      or exists(select 1 from game.organisations o where game.normalise_entity_name(o.name)=v_name)
      or exists(select 1 from game.properties p where game.normalise_entity_name(p.property_name)=v_name)
      or exists(select 1 from game.buildings b where game.normalise_entity_name(b.name)=v_name)
      or exists(select 1 from game.roads r where game.normalise_entity_name(coalesce(nullif(r.official_name,''),r.name))=v_name)
    then raise exception 'Business trading name conflicts with another canonical entity'; end if;

  elsif tg_table_name='organisations' then
    v_name:=game.normalise_entity_name(new.name);
    if exists(select 1 from game.persons p where game.normalise_entity_name(concat_ws(' ',p.given_name,nullif(p.middle_names,''),p.family_name))=v_name)
      or exists(select 1 from game.business_profiles b where game.normalise_entity_name(b.trading_name)=v_name)
      or exists(select 1 from game.properties p where game.normalise_entity_name(p.property_name)=v_name)
      or exists(select 1 from game.buildings b where game.normalise_entity_name(b.name)=v_name)
      or exists(select 1 from game.roads r where game.normalise_entity_name(coalesce(nullif(r.official_name,''),r.name))=v_name)
    then raise exception 'Organisation name conflicts with another canonical entity'; end if;

  elsif tg_table_name='properties' then
    v_name:=game.normalise_entity_name(new.property_name);
    if v_name<>'' and (
      exists(select 1 from game.persons p where game.normalise_entity_name(concat_ws(' ',p.given_name,nullif(p.middle_names,''),p.family_name))=v_name)
      or exists(select 1 from game.business_profiles b where game.normalise_entity_name(b.trading_name)=v_name)
      or exists(select 1 from game.organisations o where game.normalise_entity_name(o.name)=v_name)
      or exists(select 1 from game.buildings b where game.normalise_entity_name(b.name)=v_name)
      or exists(select 1 from game.roads r where game.normalise_entity_name(coalesce(nullif(r.official_name,''),r.name))=v_name)
    ) then raise exception 'Property name conflicts with another canonical entity'; end if;

  elsif tg_table_name='roads' then
    v_name:=game.normalise_entity_name(coalesce(nullif(new.official_name,''),new.name));
    if exists(select 1 from game.persons p where game.normalise_entity_name(concat_ws(' ',p.given_name,nullif(p.middle_names,''),p.family_name))=v_name)
      or exists(select 1 from game.business_profiles b where game.normalise_entity_name(b.trading_name)=v_name)
      or exists(select 1 from game.organisations o where game.normalise_entity_name(o.name)=v_name)
      or exists(select 1 from game.properties p where game.normalise_entity_name(p.property_name)=v_name)
      or exists(select 1 from game.buildings b where game.normalise_entity_name(b.name)=v_name)
    then raise exception 'Road name conflicts with another canonical entity'; end if;

  elsif tg_table_name='buildings' then
    v_name:=game.normalise_entity_name(new.name);
    if exists(select 1 from game.persons p where game.normalise_entity_name(concat_ws(' ',p.given_name,nullif(p.middle_names,''),p.family_name))=v_name)
      or exists(select 1 from game.business_profiles b where game.normalise_entity_name(b.trading_name)=v_name)
      or exists(select 1 from game.organisations o where game.normalise_entity_name(o.name)=v_name)
      or exists(select 1 from game.properties p where game.normalise_entity_name(p.property_name)=v_name)
      or exists(select 1 from game.roads r where game.normalise_entity_name(coalesce(nullif(r.official_name,''),r.name))=v_name)
    then raise exception 'Building name conflicts with another canonical entity'; end if;
  end if;

  return new;
end;
$function$;

drop trigger if exists persons_10_cross_domain_name_separation on game.persons;
create trigger persons_10_cross_domain_name_separation
before insert or update of given_name,middle_names,family_name on game.persons
for each row execute function game.enforce_cross_domain_name_separation();

drop trigger if exists business_profiles_cross_domain_name_separation on game.business_profiles;
create trigger business_profiles_cross_domain_name_separation
before insert or update of trading_name on game.business_profiles
for each row execute function game.enforce_cross_domain_name_separation();

drop trigger if exists organisations_cross_domain_name_separation on game.organisations;
create trigger organisations_cross_domain_name_separation
before insert or update of name on game.organisations
for each row execute function game.enforce_cross_domain_name_separation();

drop trigger if exists properties_cross_domain_name_separation on game.properties;
create trigger properties_cross_domain_name_separation
before insert or update of property_name on game.properties
for each row execute function game.enforce_cross_domain_name_separation();

drop trigger if exists roads_cross_domain_name_separation on game.roads;
create trigger roads_cross_domain_name_separation
before insert or update of name,official_name on game.roads
for each row execute function game.enforce_cross_domain_name_separation();

drop trigger if exists buildings_cross_domain_name_separation on game.buildings;
create trigger buildings_cross_domain_name_separation
before insert or update of name on game.buildings
for each row execute function game.enforce_cross_domain_name_separation();

-- Verify every required namespace is unique before committing the remediation.
do $$
declare
  v_people bigint;
  v_person_names bigint;
  v_businesses bigint;
  v_business_names bigint;
  v_orgs bigint;
  v_org_names bigint;
  v_properties bigint;
  v_property_names bigint;
  v_addresses bigint;
  v_unique_addresses bigint;
  v_roads bigint;
  v_official_roads bigint;
  v_missing_official bigint;
begin
  select count(*),count(distinct game.normalise_entity_name(concat_ws(' ',given_name,nullif(middle_names,''),family_name)))
    into v_people,v_person_names from game.persons;
  select count(*),count(distinct game.normalise_entity_name(trading_name))
    into v_businesses,v_business_names from game.business_profiles;
  select count(*),count(distinct game.normalise_entity_name(name))
    into v_orgs,v_org_names from game.organisations;
  select count(*),count(distinct game.normalise_entity_name(property_name)),
    count(distinct game.normalise_entity_name(address_line))
    into v_properties,v_property_names,v_unique_addresses from game.properties;
  select count(*),count(*) filter(where official_name is not null and btrim(official_name)<>''),
    count(*) filter(where official_name is null or btrim(official_name)='')
    into v_roads,v_official_roads,v_missing_official from game.roads;

  if v_people<>v_person_names then raise exception 'BP-03 person full-name uniqueness failed: % records / % unique',v_people,v_person_names; end if;
  if v_businesses<>v_business_names then raise exception 'BP-04 business trading-name uniqueness failed'; end if;
  if v_orgs<>v_org_names then raise exception 'BP-04 organisation-name uniqueness failed'; end if;
  if v_properties<>v_property_names or v_properties<>v_unique_addresses then raise exception 'BP-04 property-name/address uniqueness failed'; end if;
  if v_roads<>v_official_roads or v_missing_official<>0 then raise exception 'BP-02 official road-name completeness failed'; end if;
end;
$$;

commit;
