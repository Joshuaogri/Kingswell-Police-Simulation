
begin;

-- A household family is one family unit. Shared-household members remain separate
-- family units unless explicit kinship records connect them.
create table if not exists game.family_surname_bank (
  family_name text primary key,
  component_one text not null,
  component_two text not null,
  assigned_family_id uuid,
  assigned_at timestamptz
);

alter table game.family_surname_bank enable row level security;
revoke all on game.family_surname_bank from public, anon, authenticated;
grant select, insert, update on game.family_surname_bank to service_role;

-- The 317 components are established real-world surname forms. Ordered pairs
-- create a large reserve of distinct, pronounceable double-barrelled surnames.
do $$
declare v_components text[]; v_count integer;
begin
  select array_agg(distinct x order by x) into v_components
  from unnest(array[
  'Smith','Johnson','Williams','Brown','Jones','Miller','Davis','Garcia','Rodriguez','Wilson',
  'Martinez','Anderson','Taylor','Thomas','Hernandez','Moore','Martin','Jackson','Thompson','White',
  'Lopez','Lee','Gonzalez','Harris','Clark','Lewis','Robinson','Walker','Perez','Hall',
  'Young','Allen','Sanchez','Wright','King','Scott','Green','Baker','Adams','Nelson',
  'Hill','Ramirez','Campbell','Mitchell','Roberts','Carter','Phillips','Evans','Turner','Torres',
  'Parker','Collins','Edwards','Stewart','Flores','Morris','Nguyen','Murphy','Rivera','Cook',
  'Rogers','Morgan','Peterson','Cooper','Reed','Bailey','Bell','Gomez','Kelly','Howard',
  'Ward','Cox','Diaz','Richardson','Wood','Watson','Brooks','Bennett','Gray','James',
  'Reyes','Cruz','Hughes','Price','Myers','Long','Foster','Sanders','Ross','Morales',
  'Powell','Sullivan','Russell','Ortiz','Jenkins','Gutierrez','Perry','Butler','Barnes','Fisher',
  'Henderson','Coleman','Simmons','Patterson','Jordan','Reynolds','Hamilton','Graham','Kim','Gonzales',
  'Alexander','Ramos','Wallace','Griffin','West','Cole','Hayes','Chavez','Gibson','Bryant',
  'Ellis','Stevens','Murray','Ford','Marshall','Owens','Harrison','Ruiz','Kennedy','Wells',
  'Alvarez','Woods','Mendoza','Castillo','Olson','Webb','Washington','Tucker','Freeman','Burns',
  'Henry','Vasquez','Snyder','Simpson','Crawford','Jimenez','Porter','Mason','Shaw','Gordon',
  'Wagner','Hunter','Romero','Hicks','Dixon','Hunt','Palmer','Robertson','Black','Holmes',
  'Stone','Meyer','Boyd','Mills','Warren','Fox','Rose','Rice','Moreno','Schmidt',
  'Patel','Ferguson','Nichols','Herrera','Medina','Ryan','Fernandez','Weaver','Daniels','Stephens',
  'Gardner','Payne','Kelley','Dunn','Pierce','Arnold','Tran','Spencer','Peters','Hawkins',
  'Grant','Hansen','Castro','Hoffman','Hart','Elliott','Cunningham','Knight','Bradley','Carroll',
  'Hudson','Duncan','Armstrong','Berry','Andrews','Johnston','Ray','Lane','Riley','Carpenter',
  'Perkins','Aguilar','Silva','Richards','Willis','Matthews','Chapman','Lawrence','Garza','Vargas',
  'Watkins','Wheeler','Larson','Carlson','Harper','George','Greene','Burke','Guzman','Morrison',
  'Munoz','Jacobs','Obrien','Lawson','Franklin','Lynch','Bishop','Carr','Salazar','Austin',
  'Mendez','Gilbert','Jensen','Williamson','Montgomery','Harvey','Oliver','Howell','Dean','Hanson',
  'Weber','Garrett','Sims','Burton','Fuller','Soto','Mccoy','Welch','Chen','Schultz',
  'Walters','Reid','Fields','Walsh','Little','Fowler','Bowman','Davidson','May','Day',
  'Schneider','Newman','Brewer','Lucas','Holland','Wong','Banks','Santos','Curtis','Pearson',
  'Delgado','Valdez','Pena','Rios','Douglas','Sandoval','Barrett','Hopkins','Keller','Guerrero',
  'Stanley','Bates','Alvarado','Beck','Ortega','Wade','Estrada','Contreras','Barnett','Caldwell',
  'Santiago','Lambert','Powers','Chambers','Nunez','Craig','Leonard','Lowe','Rhodes','Byrd',
  'Gregory','Shelton','Frazier','Becker','Maldonado','Fleming','Fletcher'
  ]::text[]) x;

  select cardinality(v_components) into v_count;
  if v_count < 317 then raise exception 'Surname component bank too small: %',v_count; end if;

  insert into game.family_surname_bank(family_name,component_one,component_two)
  select v_components[i]||'-'||v_components[j],v_components[i],v_components[j]
  from generate_subscripts(v_components,1) as ai(i)
  cross join generate_subscripts(v_components,1) as aj(j)
  where i<>j
  on conflict (family_name) do nothing;
end $$;

create table if not exists game.family_units (
  id uuid primary key default gen_random_uuid(),
  family_ref text not null unique,
  family_name text not null references game.family_surname_bank(family_name),
  family_type text not null check (family_type in ('household_family','individual')),
  household_id uuid references game.households(id),
  anchor_person_id uuid references game.persons(id),
  created_at timestamptz not null default now(),
  check (
    (family_type='household_family' and household_id is not null and anchor_person_id is null)
    or
    (family_type='individual' and household_id is null and anchor_person_id is not null)
  )
);

create unique index if not exists family_units_unique_normalised_name_uidx
on game.family_units(game.normalise_entity_name(family_name));
create unique index if not exists family_units_one_family_per_household_uidx
on game.family_units(household_id) where family_type='household_family';
create unique index if not exists family_units_one_individual_family_uidx
on game.family_units(anchor_person_id) where family_type='individual';

create table if not exists game.family_unit_members (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references game.family_units(id),
  person_id uuid not null references game.persons(id),
  household_membership_id uuid not null references game.household_memberships(id),
  member_role text not null,
  valid_from date not null default current_date,
  valid_to date,
  created_at timestamptz not null default now()
);

create unique index if not exists family_unit_members_one_active_family_per_person_uidx
on game.family_unit_members(person_id) where valid_to is null;
create unique index if not exists family_unit_members_one_active_link_per_membership_uidx
on game.family_unit_members(household_membership_id) where valid_to is null;
create index if not exists family_unit_members_family_id_idx
on game.family_unit_members(family_id);
create index if not exists family_unit_members_person_id_idx
on game.family_unit_members(person_id);

alter table game.family_units enable row level security;
alter table game.family_unit_members enable row level security;
revoke all on game.family_units,game.family_unit_members from public,anon,authenticated;
grant select,insert,update on game.family_units,game.family_unit_members to service_role;

-- Assign one family identity to each family household and one individual identity
-- to each person living in a shared household.
do $$
declare v_family_count integer; v_bank_count integer;
begin
  select
    (select count(*) from game.households where household_type='family')
    +
    (select count(*) from game.household_memberships hm
      join game.households h on h.id=hm.household_id
      where h.household_type='shared' and hm.valid_to is null)
  into v_family_count;

  select count(*) into v_bank_count
  from game.family_surname_bank where assigned_family_id is null;

  if v_family_count<>27793 then
    raise exception 'Unexpected family-unit source count: %',v_family_count;
  end if;
  if v_bank_count<v_family_count then
    raise exception 'Insufficient unused family surnames: % for % families',v_bank_count,v_family_count;
  end if;
end $$;

with family_sources as (
  select 'household_family'::text family_type,h.id household_id,
         null::uuid anchor_person_id,'KWFAM-H-'||h.household_ref family_ref
  from game.households h
  where h.household_type='family'
  union all
  select 'individual'::text family_type,null::uuid household_id,
         hm.person_id anchor_person_id,'KWFAM-I-'||p.person_ref family_ref
  from game.household_memberships hm
  join game.households h on h.id=hm.household_id
  join game.persons p on p.id=hm.person_id
  where h.household_type='shared' and hm.valid_to is null
),
ranked_sources as (
  select *,row_number() over(order by family_ref)::bigint rn
  from family_sources
),
ranked_surnames as (
  select family_name,row_number() over(order by family_name)::bigint rn
  from game.family_surname_bank
  where assigned_family_id is null
)
insert into game.family_units(family_ref,family_name,family_type,household_id,anchor_person_id)
select s.family_ref,n.family_name,s.family_type,s.household_id,s.anchor_person_id
from ranked_sources s join ranked_surnames n using(rn);

insert into game.family_unit_members(
 family_id,person_id,household_membership_id,member_role,valid_from,valid_to
)
select fu.id,hm.person_id,hm.id,hm.household_role,coalesce(hm.valid_from,current_date),hm.valid_to
from game.family_units fu
join game.household_memberships hm on hm.household_id=fu.household_id
where fu.family_type='household_family'
union all
select fu.id,hm.person_id,hm.id,'self',coalesce(hm.valid_from,current_date),hm.valid_to
from game.family_units fu
join game.household_memberships hm on hm.person_id=fu.anchor_person_id
where fu.family_type='individual' and hm.valid_to is null;

update game.family_surname_bank b
set assigned_family_id=fu.id,assigned_at=now()
from game.family_units fu
where b.family_name=fu.family_name;

-- Log and apply the family-aware surname correction without touching any person ID,
-- given name, middle name, DOB, relationship, household or employment link.
insert into game.canonical_name_corrections(
 entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,correction_reason,migration_ref
)
select 'person',p.id,p.person_ref,'display_name',
 concat_ws(' ',p.given_name,nullif(p.middle_names,''),p.family_name),
 concat_ws(' ',p.given_name,nullif(p.middle_names,''),fu.family_name),
 'Assigned a unique family surname to each independently modelled family unit; household relatives share the surname, shared-household housemates do not.',
 '20261121351000_kingswell_family_identity_naming'
from game.persons p
join game.family_unit_members fm on fm.person_id=p.id and fm.valid_to is null
join game.family_units fu on fu.id=fm.family_id
where p.family_name is distinct from fu.family_name;

alter table game.persons disable trigger persons_10_cross_domain_name_separation;

update game.persons p
set family_name=fu.family_name,updated_at=now()
from game.family_unit_members fm
join game.family_units fu on fu.id=fm.family_id
where fm.person_id=p.id and fm.valid_to is null
  and p.family_name is distinct from fu.family_name;

alter table game.persons enable trigger persons_10_cross_domain_name_separation;

-- Enforce that a person's current family surname is controlled by their active family unit.
create or replace function game.enforce_person_family_name_consistency()
returns trigger
language plpgsql
set search_path=pg_catalog,game
as $$
declare v_family_name text;
begin
  if new.family_name is distinct from old.family_name then
    select fu.family_name into v_family_name
    from game.family_unit_members fm
    join game.family_units fu on fu.id=fm.family_id
    where fm.person_id=new.id and fm.valid_to is null
    limit 1;
    if v_family_name is not null
       and game.normalise_entity_name(new.family_name)<>game.normalise_entity_name(v_family_name) then
      raise exception 'A person's family surname must be changed through their family unit';
    end if;
  end if;
  return new;
end $$;

drop trigger if exists persons_family_name_consistency on game.persons;
create trigger persons_family_name_consistency
before update of family_name on game.persons
for each row execute function game.enforce_person_family_name_consistency();

-- Future household membership changes automatically maintain family-unit membership
-- and assign an unused surname; retired family surnames remain reserved forever.
create or replace function game.sync_person_family_from_household_membership()
returns trigger
language plpgsql
set search_path=pg_catalog,game
as $$
declare
  v_household_type text;
  v_household_ref text;
  v_family_id uuid;
  v_family_name text;
  v_family_ref text;
  v_person_ref text;
begin
  if tg_op='UPDATE' and (
      old.valid_to is null
      and (new.valid_to is not null or old.household_id is distinct from new.household_id)
  ) then
    update game.family_unit_members
    set valid_to=coalesce(new.valid_to,current_date)
    where household_membership_id=new.id and valid_to is null;
  end if;

  if new.valid_to is not null then return new; end if;

  select h.household_type,h.household_ref
  into v_household_type,v_household_ref
  from game.households h where h.id=new.household_id;

  select p.person_ref into v_person_ref from game.persons p where p.id=new.person_id;

  if v_household_type='family' then
    select id,family_name into v_family_id,v_family_name
    from game.family_units
    where family_type='household_family' and household_id=new.household_id
    for update;

    if v_family_id is null then
      select family_name into v_family_name
      from game.family_surname_bank
      where assigned_family_id is null
      order by family_name
      for update skip locked
      limit 1;

      if v_family_name is null then raise exception 'Kingswell family surname reserve exhausted'; end if;

      v_family_ref:='KWFAM-H-'||v_household_ref;
      insert into game.family_units(family_ref,family_name,family_type,household_id)
      values(v_family_ref,v_family_name,'household_family',new.household_id)
      returning id into v_family_id;

      update game.family_surname_bank
      set assigned_family_id=v_family_id,assigned_at=now()
      where family_name=v_family_name;
    end if;
    v_family_ref:=null;
  elsif v_household_type='shared' then
    select id,family_name into v_family_id,v_family_name
    from game.family_units
    where family_type='individual' and anchor_person_id=new.person_id
    for update;

    if v_family_id is null then
      select family_name into v_family_name
      from game.family_surname_bank
      where assigned_family_id is null
      order by family_name
      for update skip locked
      limit 1;

      if v_family_name is null then raise exception 'Kingswell family surname reserve exhausted'; end if;

      v_family_ref:='KWFAM-I-'||v_person_ref;
      insert into game.family_units(family_ref,family_name,family_type,anchor_person_id)
      values(v_family_ref,v_family_name,'individual',new.person_id)
      returning id into v_family_id;

      update game.family_surname_bank
      set assigned_family_id=v_family_id,assigned_at=now()
      where family_name=v_family_name;
    end if;
  else
    raise exception 'Unsupported household type for family naming: %',v_household_type;
  end if;

  insert into game.family_unit_members(
    family_id,person_id,household_membership_id,member_role,valid_from
  ) values (
    v_family_id,new.person_id,new.id,
    case when v_household_type='shared' then 'self' else new.household_role end,
    coalesce(new.valid_from,current_date)
  );

  update game.persons
  set family_name=v_family_name,updated_at=now()
  where id=new.person_id and family_name is distinct from v_family_name;

  return new;
end $$;

drop trigger if exists household_memberships_family_identity on game.household_memberships;
create trigger household_memberships_family_identity
after insert or update of household_id,valid_to on game.household_memberships
for each row execute function game.sync_person_family_from_household_membership();

-- Family surname changes propagate to every current member and remain auditable.
create or replace function game.propagate_family_surname_to_members()
returns trigger
language plpgsql
set search_path=pg_catalog,game
as $$
begin
  if new.family_name is distinct from old.family_name then
    insert into game.canonical_name_corrections(
      entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,
      correction_reason,migration_ref
    )
    select 'person',p.id,p.person_ref,'display_name',
      concat_ws(' ',p.given_name,nullif(p.middle_names,''),p.family_name),
      concat_ws(' ',p.given_name,nullif(p.middle_names,''),new.family_name),
      'Family surname updated through the authoritative family-unit record.',
      'family_unit_surname_change'
    from game.family_unit_members fm
    join game.persons p on p.id=fm.person_id
    where fm.family_id=new.id and fm.valid_to is null
      and p.family_name is distinct from new.family_name;

    update game.persons p
    set family_name=new.family_name,updated_at=now()
    from game.family_unit_members fm
    where fm.family_id=new.id and fm.person_id=p.id and fm.valid_to is null
      and p.family_name is distinct from new.family_name;
  end if;
  return new;
end $$;

drop trigger if exists family_units_propagate_surname on game.family_units;
create trigger family_units_propagate_surname
after update of family_name on game.family_units
for each row execute function game.propagate_family_surname_to_members();

-- Final integrity checks.
do $$
declare v_people integer; v_members integer; v_families integer;
        v_unique_surnames integer; v_full_names integer; v_unique_full_names integer;
        v_unassigned integer;
begin
 select count(*) into v_people from game.persons;
 select count(*) into v_members from game.family_unit_members where valid_to is null;
 select count(*) into v_families from game.family_units;
 select count(distinct game.normalise_entity_name(family_name)) into v_unique_surnames from game.family_units;
 select count(*) into v_unassigned from game.persons p
 where not exists(select 1 from game.family_unit_members fm where fm.person_id=p.id and fm.valid_to is null);

 select count(*),count(distinct game.normalise_entity_name(concat_ws(' ',given_name,nullif(middle_names,''),family_name)))
 into v_full_names,v_unique_full_names from game.persons;

 if v_people<>100000 or v_members<>100000 or v_families<>27793 or v_unassigned<>0 then
   raise exception 'Family membership integrity failed: people %, active memberships %, family units %, unassigned %',
     v_people,v_members,v_families,v_unassigned;
 end if;
 if v_unique_surnames<>v_families then
   raise exception 'Family surnames are not unique: families %, surnames %',v_families,v_unique_surnames;
 end if;
 if v_full_names<>v_unique_full_names then
   raise exception 'Complete personal names are not unique: people %, unique full names %',v_full_names,v_unique_full_names;
 end if;
end $$;

commit;
