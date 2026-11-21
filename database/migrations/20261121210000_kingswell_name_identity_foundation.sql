-- Permanent Kingswell naming foundation. Fictional simulation data only.

create schema if not exists extensions;
create extension if not exists unaccent with schema extensions;
create extension if not exists pg_trgm with schema extensions;

create or replace function game.normalise_entity_name_v2(p_name text)
returns text language sql immutable parallel safe
set search_path = pg_catalog, extensions
as $$
  select regexp_replace(lower(extensions.unaccent(coalesce(p_name,''))), '[^[:alnum:]]', '', 'g');
$$;

create or replace function game.normalise_road_base_name(p_name text)
returns text language sql immutable parallel safe
set search_path = pg_catalog, game
as $$
  select regexp_replace(game.normalise_entity_name_v2(p_name),
    '(ringroad|expressway|parkway|boulevard|avenue|street|road|bridge|close|drive|crescent|lane|mews|yard|approach|way|square|service|path|walk|wharf|terrace|place|court|highway)$','','g');
$$;

create sequence if not exists game.person_family_ref_seq;

create table if not exists game.surname_name_catalog (
  id bigserial primary key,
  surname text not null,
  normalised_name text generated always as (game.normalise_entity_name_v2(surname)) stored,
  source text not null default 'solvenium/names-dataset',
  source_url text not null default 'https://github.com/solvenium/names-dataset',
  source_license text not null default 'MIT',
  created_at timestamptz not null default now(),
  constraint surname_name_catalog_nonblank check (btrim(surname)<>''),
  constraint surname_name_catalog_normalised_unique unique (normalised_name)
);

create table if not exists game.person_families (
  id uuid primary key default gen_random_uuid(),
  family_ref text not null unique default ('KW-FAM-' || lpad(nextval('game.person_family_ref_seq')::text,8,'0')),
  family_name text not null,
  normalised_family_name text generated always as (game.normalise_entity_name_v2(family_name)) stored,
  name_source text not null default 'surname_catalog',
  family_status text not null default 'active' check (family_status in ('active','retired')),
  created_at timestamptz not null default now(),
  constraint person_families_nonblank_name check (btrim(family_name)<>''),
  constraint person_families_unique_surname unique (normalised_family_name)
);

alter table game.persons add column if not exists family_id uuid references game.person_families(id) on delete restrict;
create index if not exists persons_family_id_idx on game.persons(family_id);

create table if not exists game.person_family_name_history (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null references game.persons(id) on delete restrict,
  previous_family_id uuid references game.person_families(id) on delete restrict,
  resulting_family_id uuid references game.person_families(id) on delete restrict,
  previous_family_name text,
  resulting_family_name text not null,
  change_reason text not null,
  recorded_at timestamptz not null default now()
);

create or replace function game.allocate_person_family(p_family_name text default null)
returns uuid language plpgsql
set search_path = pg_catalog, game
as $$
declare v_surname text; v_family_id uuid; v_normalised text;
begin
  if nullif(btrim(p_family_name),'') is not null then
    v_normalised:=game.normalise_entity_name_v2(p_family_name);
    if v_normalised='' then raise exception 'Family surname must contain letters or numbers'; end if;
    if exists(select 1 from game.person_families f where f.normalised_family_name=v_normalised) then
      raise exception 'Surname "%" already belongs to a recorded family; supply that family ID to join it',p_family_name;
    end if;
    insert into game.person_families(family_name,name_source)
    values (btrim(p_family_name),'explicitly_created')
    returning id into v_family_id;
    return v_family_id;
  end if;
  select c.surname into v_surname
  from game.surname_name_catalog c
  where not exists (select 1 from game.person_families f where f.normalised_family_name=c.normalised_name)
  order by md5(c.normalised_name),c.normalised_name
  for update skip locked limit 1;
  if v_surname is null then raise exception 'Kingswell surname reference pool is exhausted'; end if;
  insert into game.person_families(family_name,name_source)
  values (v_surname,'surname_catalog')
  returning id into v_family_id;
  return v_family_id;
end;
$$;

create or replace function game.guard_person_family_identity()
returns trigger language plpgsql
set search_path = pg_catalog, game
as $$
declare v_family_name text;
begin
  if tg_op='INSERT' then
    if new.family_id is null then new.family_id:=game.allocate_person_family(new.family_name); end if;
    select family_name into v_family_name from game.person_families
    where id=new.family_id and family_status='active';
    if not found then raise exception 'A valid active family ID is required'; end if;
    if new.family_name is not null
       and game.normalise_entity_name_v2(new.family_name)<>game.normalise_entity_name_v2(v_family_name) then
      raise exception 'The supplied surname does not match the selected family ID';
    end if;
    new.family_name:=v_family_name;
    return new;
  end if;
  if new.family_id is not distinct from old.family_id then
    if new.family_name is distinct from old.family_name then
      raise exception 'A surname cannot be edited directly; assign the person to a family ID';
    end if;
    return new;
  end if;
  select family_name into v_family_name from game.person_families
  where id=new.family_id and family_status='active';
  if not found then raise exception 'A valid active family ID is required'; end if;
  new.family_name:=v_family_name;
  return new;
end;
$$;

create trigger persons_00_family_identity_guard
before insert or update of family_id,family_name on game.persons
for each row execute function game.guard_person_family_identity();

create or replace function game.guard_person_family_name_immutable()
returns trigger language plpgsql
as $$
begin
  if new.family_name is distinct from old.family_name
     or new.normalised_family_name is distinct from old.normalised_family_name then
    raise exception 'Family surnames are immutable; create a new family identity and reassign members';
  end if;
  return new;
end;
$$;

create trigger person_families_name_immutable
before update of family_name on game.person_families
for each row execute function game.guard_person_family_name_immutable();

create or replace function game.log_person_family_name_change()
returns trigger language plpgsql
set search_path = pg_catalog, game
as $$
begin
  if new.family_id is distinct from old.family_id then
    insert into game.person_family_name_history(
      person_id,previous_family_id,resulting_family_id,previous_family_name,resulting_family_name,change_reason
    ) values (
      new.id,old.family_id,new.family_id,old.family_name,new.family_name,
      'Person reassigned to a different explicit family-name identity'
    );
  end if;
  return new;
end;
$$;

create trigger persons_family_name_history
after update of family_id on game.persons
for each row when (new.family_id is distinct from old.family_id)
execute function game.log_person_family_name_change();

create table if not exists game.canonical_entity_name_history (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null,
  entity_id uuid not null,
  entity_ref text,
  canonical_name text not null,
  normalised_name text generated always as (game.normalise_entity_name_v2(canonical_name)) stored,
  is_current boolean not null default true,
  valid_from timestamptz not null default now(),
  valid_to timestamptz,
  recorded_at timestamptz not null default now(),
  constraint canonical_entity_name_history_nonblank check (btrim(canonical_name)<>'')
);
create unique index if not exists canonical_entity_name_history_entity_name_uidx
  on game.canonical_entity_name_history(entity_type,normalised_name,entity_id);
create unique index if not exists canonical_entity_name_history_one_current_uidx
  on game.canonical_entity_name_history(entity_type,normalised_name) where is_current;
create index if not exists canonical_entity_name_history_entity_idx
  on game.canonical_entity_name_history(entity_type,entity_id,valid_from desc);

create table if not exists game.name_similarity_flags (
  id uuid primary key default gen_random_uuid(),
  entity_type text not null,
  entity_id uuid not null,
  entity_ref text,
  entity_name text not null,
  compared_entity_id uuid not null,
  compared_entity_ref text,
  compared_name text not null,
  similarity_score numeric(5,4) not null,
  flag_reason text not null,
  review_status text not null default 'pending' check (review_status in ('pending','accepted','corrected','dismissed')),
  recorded_at timestamptz not null default now(),
  constraint name_similarity_flags_distinct_entities check (entity_id<>compared_entity_id)
);
create index if not exists name_similarity_flags_status_idx
  on game.name_similarity_flags(review_status,entity_type,similarity_score desc);

comment on table game.surname_name_catalog is 'Reference-only fictional name-generation vocabulary; source and MIT licence are recorded on each row.';
comment on table game.person_families is 'Canonical surname identities. A surname is shared only by persons explicitly assigned to the same family ID.';
comment on column game.persons.family_id is 'Authoritative family-name identity; family_name is derived and protected by a trigger.';
comment on table game.canonical_entity_name_history is 'Canonical-name history used to prevent retired names being silently reassigned.';
comment on table game.name_similarity_flags is 'Review queue for lookalike names; similarity alone does not auto-rename a person.';
