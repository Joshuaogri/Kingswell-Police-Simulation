
begin;

create table if not exists game.family_surname_components (
  ordinal integer primary key,
  surname_component text not null unique
);
alter table game.family_surname_components enable row level security;
revoke all on game.family_surname_components from public,anon,authenticated;
grant select,insert on game.family_surname_components to service_role;

insert into game.family_surname_components(ordinal,surname_component)
select ordinality::integer,component
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
]::text[]) with ordinality as names(component,ordinality)
on conflict (ordinal) do nothing;

create table if not exists game.family_units (
  id uuid primary key default gen_random_uuid(),
  family_ref text not null unique,
  family_name text not null,
  family_type text not null check (family_type in ('household_family','individual')),
  household_id uuid references game.households(id),
  anchor_person_id uuid references game.persons(id),
  created_at timestamptz not null default now(),
  check (
    (family_type='household_family' and household_id is not null and anchor_person_id is null)
    or
    (family_type='individual' and household_id is null and anchor_person_id is not null)
  ),
  check (length(btrim(family_name))>0)
);

create unique index if not exists family_units_unique_normalised_name_uidx
on game.family_units(game.normalise_entity_name(family_name));
create unique index if not exists family_units_one_family_per_household_uidx
on game.family_units(household_id) where family_type='household_family';
create unique index if not exists family_units_one_individual_family_uidx
on game.family_units(anchor_person_id) where family_type='individual';

alter table game.family_units enable row level security;
revoke all on game.family_units from public,anon,authenticated;
grant select,insert,update on game.family_units to service_role;

alter table game.persons add column if not exists family_id uuid references game.family_units(id);
alter table game.household_memberships add column if not exists family_id uuid references game.family_units(id);

create sequence if not exists game.family_surname_sequence
  start with 27794 increment by 1 minvalue 1 maxvalue 100172 no cycle;

create or replace function game.next_family_surname()
returns text
language plpgsql
volatile
set search_path=pg_catalog,game
as $$
declare
  v_n bigint;
  v_i integer;
  v_offset integer;
  v_j integer;
  v_one text;
  v_two text;
begin
  v_n:=nextval('game.family_surname_sequence');
  if v_n>100172 then raise exception 'Kingswell family surname capacity exhausted'; end if;
  v_i:=((v_n-1)/316)::integer+1;
  v_offset:=((v_n-1)%316)::integer+1;
  v_j:=case when v_offset<v_i then v_offset else v_offset+1 end;
  select surname_component into v_one from game.family_surname_components where ordinal=v_i;
  select surname_component into v_two from game.family_surname_components where ordinal=v_j;
  if v_one is null or v_two is null then raise exception 'Family surname component lookup failed'; end if;
  return v_one||'-'||v_two;
end $$;

-- Initial family units: one per family household; one per resident in shared housing.
with family_sources as (
  select 'household_family'::text family_type,h.id household_id,
         null::uuid anchor_person_id,'KWFAM-H-'||h.household_ref family_ref
  from game.households h where h.household_type='family'
  union all
  select 'individual'::text family_type,null::uuid household_id,
         hm.person_id anchor_person_id,'KWFAM-I-'||p.person_ref family_ref
  from game.household_memberships hm
  join game.households h on h.id=hm.household_id
  join game.persons p on p.id=hm.person_id
  where h.household_type='shared' and hm.valid_to is null
),
ranked as (
  select *,row_number() over(order by family_ref)::bigint rn
  from family_sources
),
components as (
  select array_agg(surname_component order by ordinal) surnames
  from game.family_surname_components
),
named as (
  select r.*,
    ((r.rn-1)/316)::integer+1 as component_i,
    ((r.rn-1)%316)::integer+1 as component_offset
  from ranked r
)
insert into game.family_units(family_ref,family_name,family_type,household_id,anchor_person_id)
select n.family_ref,
       c.surnames[n.component_i]||'-'||c.surnames[
         case when n.component_offset<n.component_i then n.component_offset else n.component_offset+1 end
       ],
       n.family_type,n.household_id,n.anchor_person_id
from named n cross join components c;

do $$
declare v_units integer; v_components integer; v_capacity integer;
begin
 select count(*) into v_units from game.family_units;
 select count(*) into v_components from game.family_surname_components;
 v_capacity:=v_components*(v_components-1);
 if v_components<>317 or v_capacity<100000 or v_units<>27793 then
   raise exception 'Family naming capacity or unit count failed: components %, capacity %, units %',v_components,v_capacity,v_units;
 end if;
end $$;

alter table game.canonical_name_corrections
 drop constraint if exists canonical_name_corrections_entity_type_check;
alter table game.canonical_name_corrections
 add constraint canonical_name_corrections_entity_type_check
 check (entity_type in ('person','business','organisation','property','property_address','site','road','building','family'));

-- One immutable correction record per family identity, not one row per family member.
insert into game.canonical_name_corrections(
 entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,
 correction_reason,migration_ref
)
select 'family',fu.id,fu.family_ref,'family_name',prior.previous_name,fu.family_name,
 'Created an independently named family identity; members of the same family household share its surname, while shared-household housemates receive separate family identities.',
 '20261121351000_kingswell_family_identity_naming'
from game.family_units fu
left join lateral (
 select min(p.family_name) previous_name
 from game.persons p
 join game.household_memberships hm on hm.person_id=p.id and hm.valid_to is null
 where (fu.family_type='household_family' and hm.household_id=fu.household_id)
    or (fu.family_type='individual' and p.id=fu.anchor_person_id)
) prior on true;

-- Apply family_id and family_name to every current resident without changing identity references.
alter table game.persons disable trigger persons_10_cross_domain_name_separation;

with mapping as (
 select hm.person_id,fu.id family_id,fu.family_name
 from game.household_memberships hm
 join game.family_units fu on fu.family_type='household_family' and fu.household_id=hm.household_id
 where hm.valid_to is null
 union all
 select hm.person_id,fu.id family_id,fu.family_name
 from game.household_memberships hm
 join game.family_units fu on fu.family_type='individual' and fu.anchor_person_id=hm.person_id
 where hm.valid_to is null
)
update game.persons p
set family_id=m.family_id,family_name=m.family_name,updated_at=now()
from mapping m
where p.id=m.person_id;

update game.household_memberships hm
set family_id=p.family_id
from game.persons p
where p.id=hm.person_id and hm.valid_to is null;

alter table game.persons enable trigger persons_10_cross_domain_name_separation;

create index if not exists persons_family_id_idx on game.persons(family_id);
create index if not exists household_memberships_family_id_idx on game.household_memberships(family_id);

-- Family surnames may only be changed on the authoritative family-unit record.
create or replace function game.enforce_person_family_name_consistency()
returns trigger
language plpgsql
set search_path=pg_catalog,game
as $$
declare v_family_name text;
begin
  if new.family_id is not null then
    select family_name into v_family_name from game.family_units where id=new.family_id;
    if v_family_name is null or game.normalise_entity_name(new.family_name)<>game.normalise_entity_name(v_family_name) then
      raise exception 'Person family surname must match the authoritative family unit';
    end if;
  end if;
  return new;
end $$;

drop trigger if exists persons_family_name_consistency on game.persons;
create trigger persons_family_name_consistency
before insert or update of family_id,family_name on game.persons
for each row execute function game.enforce_person_family_name_consistency();

-- Family surname changes propagate to current members.
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
    ) values (
      'family',new.id,new.family_ref,'family_name',old.family_name,new.family_name,
      'Family surname updated through its authoritative family-unit record.',
      'family_unit_surname_change'
    );

    update game.persons
    set family_name=new.family_name,updated_at=now()
    where family_id=new.id and family_name is distinct from new.family_name;
  end if;
  return new;
end $$;

drop trigger if exists family_units_propagate_surname on game.family_units;
create trigger family_units_propagate_surname
after update of family_name on game.family_units
for each row execute function game.propagate_family_surname_to_members();

-- Future household membership inserts receive a family identity automatically.
create or replace function game.assign_family_to_household_membership()
returns trigger
language plpgsql
set search_path=pg_catalog,game
as $$
declare
  v_household_type text;
  v_household_ref text;
  v_family_id uuid;
  v_family_name text;
  v_person_ref text;
begin
  if tg_op='UPDATE' and old.household_id is distinct from new.household_id then
    raise exception 'Close the existing household membership and insert a new membership to preserve family history';
  end if;
  if tg_op='UPDATE' and old.person_id is distinct from new.person_id then
    raise exception 'A household membership cannot be reassigned to a different person';
  end if;

  if new.valid_to is not null then return new; end if;

  select household_type,household_ref into v_household_type,v_household_ref
  from game.households where id=new.household_id;
  select person_ref into v_person_ref from game.persons where id=new.person_id;

  if v_household_type='family' then
    select id,family_name into v_family_id,v_family_name
    from game.family_units
    where family_type='household_family' and household_id=new.household_id
    for update;

    if v_family_id is null then
      v_family_name:=game.next_family_surname();
      insert into game.family_units(family_ref,family_name,family_type,household_id)
      values('KWFAM-H-'||v_household_ref,v_family_name,'household_family',new.household_id)
      returning id into v_family_id;
    end if;
  elsif v_household_type='shared' then
    select id,family_name into v_family_id,v_family_name
    from game.family_units
    where family_type='individual' and anchor_person_id=new.person_id
    for update;

    if v_family_id is null then
      v_family_name:=game.next_family_surname();
      insert into game.family_units(family_ref,family_name,family_type,anchor_person_id)
      values('KWFAM-I-'||v_person_ref,v_family_name,'individual',new.person_id)
      returning id into v_family_id;
    end if;
  else
    raise exception 'Unsupported household type for family naming: %',v_household_type;
  end if;

  new.family_id:=v_family_id;
  update game.persons
  set family_id=v_family_id,family_name=v_family_name,updated_at=now()
  where id=new.person_id
    and (family_id is distinct from v_family_id or family_name is distinct from v_family_name);

  return new;
end $$;

drop trigger if exists household_memberships_assign_family on game.household_memberships;
create trigger household_memberships_assign_family
before insert or update of household_id,person_id,valid_to on game.household_memberships
for each row execute function game.assign_family_to_household_membership();

-- Validate complete personal-name uniqueness and family consistency.
do $$
declare
 v_people integer; v_assigned integer; v_families integer; v_unique_surnames integer;
 v_full_names integer; v_unique_full_names integer; v_bad_households integer; v_shared_collisions integer;
begin
 select count(*) into v_people from game.persons;
 select count(*) into v_assigned from game.persons where family_id is not null;
 select count(*) into v_families from game.family_units;
 select count(distinct game.normalise_entity_name(family_name)) into v_unique_surnames from game.family_units;
 select count(*),count(distinct game.normalise_entity_name(concat_ws(' ',given_name,nullif(middle_names,''),family_name)))
 into v_full_names,v_unique_full_names from game.persons;
 select count(*) into v_bad_households
 from game.households h
 join game.household_memberships hm on hm.household_id=h.id and hm.valid_to is null
 join game.persons p on p.id=hm.person_id
 where h.household_type='family'
 group by h.id
 having count(distinct p.family_id)<>1;
 select count(*) into v_shared_collisions
 from (
   select h.id
   from game.households h
   join game.household_memberships hm on hm.household_id=h.id and hm.valid_to is null
   join game.persons p on p.id=hm.person_id
   where h.household_type='shared'
   group by h.id
   having count(distinct p.family_id)<>count(*)
 ) s;

 if v_people<>100000 or v_assigned<>100000 or v_families<>27793 then
   raise exception 'Family assignment failed: people %, assigned %, family units %',v_people,v_assigned,v_families;
 end if;
 if v_unique_surnames<>v_families then
   raise exception 'Family surnames are not unique: families %, surnames %',v_families,v_unique_surnames;
 end if;
 if v_full_names<>v_unique_full_names then
   raise exception 'Complete personal names are not unique: people %, unique names %',v_full_names,v_unique_full_names;
 end if;
 if coalesce(v_bad_households,0)<>0 or coalesce(v_shared_collisions,0)<>0 then
   raise exception 'Family/household relationship integrity failed';
 end if;
end $$;

commit;
