-- BP-04: structured property title / conveyance history.
create table if not exists game.property_title_events (
 id uuid primary key default gen_random_uuid(),
 event_ref text not null unique,
 property_id uuid not null references game.properties(id) on delete restrict,
 event_type text not null check(event_type in (
  'initial_registration','transfer','sale','gift','inheritance','court_order',
  'subdivision','amalgamation','title_correction','restriction_registered',
  'restriction_discharged','caveat_registered','caveat_removed',
  'lease_registered','lease_discharged','mortgage_registered','mortgage_discharged',
  'other'
 )),
 occurred_on date,
 recorded_on date,
 prior_title_reference text,
 resulting_title_reference text,
 instrument_type text,
 instrument_reference text,
 transferor_person_id uuid references game.persons(id) on delete restrict,
 transferor_organisation_id uuid references game.organisations(id) on delete restrict,
 transferee_person_id uuid references game.persons(id) on delete restrict,
 transferee_organisation_id uuid references game.organisations(id) on delete restrict,
 interest_transferred text,
 share_transferred_pct numeric check(share_transferred_pct is null or (share_transferred_pct>0 and share_transferred_pct<=100)),
 consideration_amount numeric check(consideration_amount is null or consideration_amount>=0),
 consideration_currency text,
 registration_status text not null default 'recorded' check(registration_status in ('draft','lodged','recorded','rejected','withdrawn','unknown')),
 supersedes_event_id uuid references game.property_title_events(id) on delete restrict,
 source_reference text,
 source_description text,
 event_details jsonb not null default '{}'::jsonb check(jsonb_typeof(event_details)='object'),
 created_at timestamptz not null default now(),
 check((transferor_person_id is null) or (transferor_organisation_id is null)),
 check((transferee_person_id is null) or (transferee_organisation_id is null)),
 check(supersedes_event_id is null or supersedes_event_id<>id)
);
create index if not exists property_title_events_property_date_idx
 on game.property_title_events(property_id,occurred_on,recorded_on);
create index if not exists property_title_events_instrument_idx
 on game.property_title_events(instrument_reference) where instrument_reference is not null;

create or replace function game.validate_property_title_event()
returns trigger language plpgsql as $$
declare v_property uuid;
begin
 if tg_op<>'INSERT' then
  raise exception 'Property title events are append-only; add a correction event instead';
 end if;
 if new.supersedes_event_id is not null then
  select property_id into v_property from game.property_title_events where id=new.supersedes_event_id;
  if v_property is null or v_property<>new.property_id then
   raise exception 'A title correction must reference an earlier event for the same property';
  end if;
 end if;
 return new;
end $$;
drop trigger if exists property_title_events_immutable on game.property_title_events;
create trigger property_title_events_immutable before update or delete on game.property_title_events
for each row execute function game.validate_property_title_event();

create or replace function game.get_property_title_history(p_property_ref text)
returns jsonb language sql stable as $$
 select jsonb_build_object(
  'property',jsonb_build_object('id',p.id,'ref',p.property_ref,'address',p.address_line,
   'property_type',p.property_type,'land_use',p.land_use,'status',p.status),
  'current_registered_title',coalesce((select jsonb_agg(jsonb_build_object(
   'title_reference',i.title_reference,'holder_type',d.holder_type,'holder_ref',d.holder_ref,
   'holder_name',d.holder_name,'share_pct',i.ownership_share_pct,'valid_from',i.valid_from,
   'valid_to',i.valid_to,'source_description',i.source_description)
   order by i.valid_from desc nulls last)
   from game.property_interest_records i
   join game.property_interest_dossiers d on d.property_interest_id=i.id
   where i.property_id=p.id and i.interest_type='registered_owner' and i.valid_to is null),'[]'::jsonb),
  'title_events',coalesce((select jsonb_agg(to_jsonb(e) order by e.occurred_on nulls first,e.recorded_on nulls first,e.created_at)
   from game.property_title_events e where e.property_id=p.id),'[]'::jsonb),
  'history_status',case when exists(select 1 from game.property_title_events e where e.property_id=p.id)
   then 'events_recorded' else 'no_transfer_or_title_history_recorded' end,
  'limitations',jsonb_build_array('Current registered-title entries are seeded city-register records',
   'No historical transfers, title instruments or conveyances are inferred',
   'An empty event history means no history is recorded, not that no transfer ever occurred'))
 from game.properties p where p.property_ref=p_property_ref;
$$;

create or replace function game.get_property_asset_history(p_property_ref text)
returns jsonb language sql stable as $$
 select jsonb_build_object(
  'property',jsonb_build_object('id',p.id,'ref',p.property_ref,'address',p.address_line),
  'asset_events',coalesce((select jsonb_agg(to_jsonb(e) order by e.occurred_on nulls first,e.created_at)
   from game.property_asset_events e where e.property_id=p.id),'[]'::jsonb),
  'event_count',(select count(*) from game.property_asset_events e where e.property_id=p.id),
  'history_status',case when exists(select 1 from game.property_asset_events e where e.property_id=p.id)
   then 'events_recorded' else 'no_asset_events_recorded' end)
 from game.properties p where p.property_ref=p_property_ref;
$$;

alter table game.property_title_events enable row level security;
revoke all on game.property_title_events from public,anon,authenticated;
grant all on game.property_title_events to service_role;
