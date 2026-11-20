-- BP-04 agreement lifecycle event history and dedicated agreement dossier.
-- No fictional renewals, terminations, notices, variations or disputes are fabricated.
create table if not exists game.organisation_site_agreement_events (
 id uuid primary key default gen_random_uuid(),
 event_ref text not null unique,
 agreement_id uuid not null references game.organisation_site_agreements(id) on delete restrict,
 event_type text not null check(event_type in (
  'proposed','executed','commenced','varied','rent_reviewed','break_notice_served',
  'renewal_offered','renewed','expired','terminated','surrendered',
  'dispute_opened','dispute_resolved','assigned','subletting_consented',
  'counterparty_changed','corrected','other'
 )),
 occurred_on date,
 recorded_on date not null,
 prior_status text check(prior_status is null or prior_status in
  ('proposed','executed','active','expired','terminated','surrendered','disputed','unknown')),
 resulting_status text check(resulting_status is null or resulting_status in
  ('proposed','executed','active','expired','terminated','surrendered','disputed','unknown')),
 subject text not null,
 description text not null,
 actor_organisation_id uuid references game.organisations(id) on delete restrict,
 actor_person_id uuid references game.persons(id) on delete restrict,
 source_reference text,
 source_description text not null,
 event_details jsonb not null default '{}'::jsonb
  check(jsonb_typeof(event_details)='object'),
 created_at timestamptz not null default now(),
 check(not(actor_organisation_id is not null and actor_person_id is not null))
);
create index if not exists organisation_site_agreement_events_timeline_idx
 on game.organisation_site_agreement_events(agreement_id,occurred_on desc nulls last,recorded_on desc,created_at desc);
create index if not exists organisation_site_agreement_events_type_idx
 on game.organisation_site_agreement_events(event_type,occurred_on desc);

-- Lifecycle history is append-only. Corrections are represented by a new event.
create or replace function game.prevent_site_agreement_event_mutation()
returns trigger language plpgsql as $$
begin
 raise exception 'BP-04 agreement lifecycle events are immutable; append a correction event instead';
end;
$$;
drop trigger if exists organisation_site_agreement_events_immutable on game.organisation_site_agreement_events;
create trigger organisation_site_agreement_events_immutable
before update or delete on game.organisation_site_agreement_events
for each row execute function game.prevent_site_agreement_event_mutation();

create or replace function game.get_site_agreement_record(p_agreement_ref text)
returns jsonb language sql stable as $$
 select jsonb_build_object(
  'agreement',to_jsonb(a),
  'tenant',to_jsonb(t),
  'counterparty_organisation',to_jsonb(cp),
  'counterparty_person_id',a.counterparty_person_id,
  'sites',coalesce((
   select jsonb_agg(jsonb_build_object(
    'site',to_jsonb(ol),'property',to_jsonb(p),
    'building',to_jsonb(b),'unit',to_jsonb(u)
   ) order by p.property_ref,ol.site_ref)
   from game.organisation_site_agreement_locations al
   join game.organisation_locations ol on ol.id=al.organisation_location_id
   join game.properties p on p.id=ol.property_id
   left join game.building_units u on u.id=ol.building_unit_id
   left join game.buildings b on b.id=u.building_id
   where al.agreement_id=a.id
  ),'[]'::jsonb),
  'lifecycle_events',coalesce((
   select jsonb_agg(to_jsonb(e) order by e.occurred_on,e.recorded_on,e.created_at)
   from game.organisation_site_agreement_events e where e.agreement_id=a.id
  ),'[]'::jsonb),
  'term_coverage',coalesce(a.agreement_details->'contract_term_coverage','{}'::jsonb),
  'provenance',jsonb_build_object(
   'source_reference',a.source_reference,
   'source_description',a.source_description,
   'unknown_terms_preserved',true,
   'occupancy_dates_are_contract_dates',false
  )
 )
 from game.organisation_site_agreements a
 join game.organisations t on t.id=a.tenant_organisation_id
 left join game.organisations cp on cp.id=a.counterparty_organisation_id
 where a.agreement_ref=p_agreement_ref;
$$;

alter table game.organisation_site_agreement_events enable row level security;
revoke all on game.organisation_site_agreement_events from public,anon,authenticated;
grant all on game.organisation_site_agreement_events to service_role;
