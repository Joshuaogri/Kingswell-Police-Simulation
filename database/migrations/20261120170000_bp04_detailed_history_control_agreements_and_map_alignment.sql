
-- BP-04 additive detail and geography-alignment refinement.
-- Existing canonical property, building, unit, organisation and site identities are preserved.

-- 1. Align stored parcel/building geometry metadata with the authoritative BP-02 map.
update game.property_profiles pp
set parcel_outline=jsonb_set(pp.parcel_outline,'{coordinate_system}',to_jsonb(c.map_version),true),
    updated_at=now()
from game.properties p
join game.cities c on c.id=p.city_id
where pp.property_id=p.id
  and pp.parcel_outline->>'coordinate_system' is distinct from c.map_version;

update game.building_profiles bp
set footprint_outline=jsonb_set(bp.footprint_outline,'{coordinate_system}',to_jsonb(c.map_version),true),
    updated_at=now()
from game.buildings b
join game.properties p on p.id=b.property_id
join game.cities c on c.id=p.city_id
where bp.building_id=b.id
  and bp.footprint_outline->>'coordinate_system' is distinct from c.map_version;

-- 2. Preserve dated property valuation history; the first row is a snapshot of
--    the existing profile and uses its already-recorded fictional assessment date.
create table if not exists game.property_valuation_records (
 id uuid primary key default gen_random_uuid(),
 property_id uuid not null references game.properties(id) on delete restrict,
 assessed_on date not null,
 land_value numeric(18,2) not null check(land_value>=0),
 improvement_value numeric(18,2) not null check(improvement_value>=0),
 currency text not null,
 annual_property_charge numeric(14,2),
 insurance_value numeric(18,2),
 valuation_basis text not null,
 confidence text not null default 'estimated'
   check(confidence in ('confirmed','recorded','estimated','disputed','unknown')),
 source_description text not null,
 valuation_details jsonb not null default '{}'::jsonb
   check(jsonb_typeof(valuation_details)='object'),
 created_at timestamptz not null default now(),
 unique(property_id,assessed_on,valuation_basis)
);
insert into game.property_valuation_records(
 property_id,assessed_on,land_value,improvement_value,currency,annual_property_charge,
 insurance_value,valuation_basis,confidence,source_description,valuation_details
)
select pp.property_id,pp.last_assessed_on,pp.assessed_land_value,pp.assessed_improvement_value,
 pp.assessed_currency,pp.annual_property_charge,pp.insurance_value,'seeded_planning_assessment',
 'estimated','Snapshot of the existing fictional BP-04 property profile; not an independent appraisal.',
 jsonb_build_object('snapshot_source','game.property_profiles','profile_version',pp.profile_version)
from game.property_profiles pp
where pp.last_assessed_on is not null
  and pp.assessed_land_value is not null
  and pp.assessed_improvement_value is not null
on conflict(property_id,assessed_on,valuation_basis) do nothing;

create index if not exists property_valuation_records_history_idx
 on game.property_valuation_records(property_id,assessed_on desc);

-- 3. Add an append-only style event register for property/building/unit condition,
--    inspections, defects and maintenance. No fictional events are invented here.
create table if not exists game.property_asset_events (
 id uuid primary key default gen_random_uuid(),
 property_id uuid not null references game.properties(id) on delete restrict,
 building_id uuid references game.buildings(id) on delete restrict,
 building_unit_id uuid references game.building_units(id) on delete restrict,
 event_type text not null check(event_type in (
  'inspection','condition_assessment','defect','maintenance','repair','alteration',
  'refurbishment','construction','demolition','safety_review','utility_event','damage','other'
 )),
 event_status text not null default 'recorded'
  check(event_status in ('planned','open','in_progress','completed','cancelled','recorded','unknown')),
 severity text not null default 'unknown'
  check(severity in ('not_applicable','low','moderate','high','critical','unknown')),
 occurred_on date,
 completed_on date,
 subject text not null,
 description text not null,
 findings text,
 action_required text,
 responsible_organisation_id uuid references game.organisations(id) on delete restrict,
 responsible_person_id uuid references game.persons(id) on delete restrict,
 source_reference text,
 source_description text,
 event_details jsonb not null default '{}'::jsonb
  check(jsonb_typeof(event_details)='object'),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 check(building_unit_id is null or building_id is not null),
 check(occurred_on is null or completed_on is null or completed_on>=occurred_on)
);

create or replace function game.validate_property_asset_event_location()
returns trigger language plpgsql as $$
begin
 if new.building_id is not null and not exists(
  select 1 from game.buildings b
  where b.id=new.building_id and b.property_id=new.property_id
 ) then
  raise exception 'BP-04 asset event building must belong to the selected property';
 end if;
 if new.building_unit_id is not null and not exists(
  select 1 from game.building_units u
  join game.buildings b on b.id=u.building_id
  where u.id=new.building_unit_id and b.id=new.building_id and b.property_id=new.property_id
 ) then
  raise exception 'BP-04 asset event unit must belong to the selected building and property';
 end if;
 new.updated_at=now();
 return new;
end;
$$;
drop trigger if exists property_asset_events_validate_location on game.property_asset_events;
create trigger property_asset_events_validate_location
before insert or update of property_id,building_id,building_unit_id
on game.property_asset_events
for each row execute function game.validate_property_asset_event_location();

create index if not exists property_asset_events_property_history_idx
 on game.property_asset_events(property_id,occurred_on desc,created_at desc);
create index if not exists property_asset_events_building_history_idx
 on game.property_asset_events(building_id,occurred_on desc) where building_id is not null;
create index if not exists property_asset_events_unit_history_idx
 on game.property_asset_events(building_unit_id,occurred_on desc) where building_unit_id is not null;

-- 4. Add organisation ownership/control relationships. Parent-company hierarchy
--    remains in organisations.parent_organisation_id; this table does not duplicate it.
create table if not exists game.organisation_control_interests (
 id uuid primary key default gen_random_uuid(),
 organisation_id uuid not null references game.organisations(id) on delete restrict,
 holder_person_id uuid references game.persons(id) on delete restrict,
 holder_organisation_id uuid references game.organisations(id) on delete restrict,
 control_type text not null check(control_type in (
  'beneficial_owner','shareholder','director','partner','controlling_person',
  'franchise_operator','other'
 )),
 ownership_share_pct numeric(7,4) check(ownership_share_pct is null or (ownership_share_pct>0 and ownership_share_pct<=100)),
 voting_share_pct numeric(7,4) check(voting_share_pct is null or (voting_share_pct>=0 and voting_share_pct<=100)),
 valid_from date,
 valid_to date,
 source_reference text,
 source_description text,
 control_details jsonb not null default '{}'::jsonb
  check(jsonb_typeof(control_details)='object'),
 created_at timestamptz not null default now(),
 check((holder_person_id is not null and holder_organisation_id is null)
    or (holder_person_id is null and holder_organisation_id is not null)),
 check(holder_organisation_id is null or holder_organisation_id<>organisation_id),
 check(valid_from is null or valid_to is null or valid_to>=valid_from)
);
create unique index if not exists organisation_control_interests_current_uidx
 on game.organisation_control_interests(
  organisation_id,coalesce(holder_person_id,'00000000-0000-0000-0000-000000000000'::uuid),
  coalesce(holder_organisation_id,'00000000-0000-0000-0000-000000000000'::uuid),control_type
 ) where valid_to is null;
create index if not exists organisation_control_interests_org_history_idx
 on game.organisation_control_interests(organisation_id,valid_from desc);
create index if not exists organisation_control_interests_person_idx
 on game.organisation_control_interests(holder_person_id) where holder_person_id is not null;

-- 5. Turn the existing tenant-site lease references into retrievable agreement records.
--    Dates and actual monetary amounts are deliberately left null when not recorded.
create table if not exists game.organisation_site_agreements (
 id uuid primary key default gen_random_uuid(),
 agreement_ref text not null unique,
 agreement_type text not null,
 tenant_organisation_id uuid not null references game.organisations(id) on delete restrict,
 counterparty_organisation_id uuid references game.organisations(id) on delete restrict,
 counterparty_person_id uuid references game.persons(id) on delete restrict,
 counterparty_role text,
 agreement_status text not null default 'unknown'
  check(agreement_status in ('proposed','executed','active','expired','terminated','surrendered','disputed','unknown')),
 execution_date date,
 effective_from date,
 effective_to date,
 break_date date,
 renewal_date date,
 notice_days integer check(notice_days is null or notice_days>=0),
 rent_band text,
 rent_amount numeric(16,2) check(rent_amount is null or rent_amount>=0),
 rent_currency text,
 rent_frequency text,
 deposit_amount numeric(16,2) check(deposit_amount is null or deposit_amount>=0),
 permitted_use text,
 restrictions text,
 repair_responsibility text,
 service_charge_responsibility text,
 subletting_allowed boolean,
 source_reference text,
 source_description text,
 agreement_details jsonb not null default '{}'::jsonb
  check(jsonb_typeof(agreement_details)='object'),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 check(not(counterparty_organisation_id is not null and counterparty_person_id is not null)),
 check(effective_from is null or effective_to is null or effective_to>=effective_from)
);

create table if not exists game.organisation_site_agreement_locations (
 agreement_id uuid not null references game.organisation_site_agreements(id) on delete restrict,
 organisation_location_id uuid not null references game.organisation_locations(id) on delete restrict,
 primary key(agreement_id,organisation_location_id),
 unique(organisation_location_id)
);
create index if not exists organisation_site_agreements_tenant_history_idx
 on game.organisation_site_agreements(tenant_organisation_id,effective_from desc);
create index if not exists organisation_site_agreement_locations_location_idx
 on game.organisation_site_agreement_locations(organisation_location_id);

insert into game.organisation_site_agreements(
 agreement_ref,agreement_type,tenant_organisation_id,counterparty_organisation_id,counterparty_role,
 agreement_status,rent_band,source_reference,source_description,agreement_details
)
select l.lease_reference,l.lease_type,l.organisation_id,landlord.holder_organisation_id,
 case when landlord.holder_organisation_id is not null then 'landlord' else null end,
 case when l.occupancy_status='active' then 'active' else 'unknown' end,
 l.rent_band,l.lease_reference,
 'Backfilled from the existing BP-04 tenant site record. Missing contract dates and actual monetary amounts have not been inferred.',
 l.lease_details || jsonb_build_object('backfilled_from_site_ref',l.site_ref,
   'site_occupancy_valid_from',l.valid_from,'site_occupancy_valid_to',l.valid_to)
from game.organisation_locations l
left join lateral (
 select pir.holder_organisation_id
 from game.property_interest_records pir
 where pir.property_id=l.property_id and pir.interest_type='landlord' and pir.valid_to is null
 order by pir.created_at,pir.id limit 1
) landlord on true
where l.location_role='tenant' and l.lease_reference is not null
on conflict(agreement_ref) do nothing;

insert into game.organisation_site_agreement_locations(agreement_id,organisation_location_id)
select a.id,l.id
from game.organisation_site_agreements a
join game.organisation_locations l on l.lease_reference=a.agreement_ref
where l.location_role='tenant'
on conflict do nothing;

-- 6. Preserve the existing property and business dossier interfaces, extending their output.
create or replace function game.get_property_record(p_property_ref text)
returns jsonb language sql stable as $$
 select jsonb_build_object(
  'property',to_jsonb(p),
  'district',jsonb_build_object('code',d.code,'name',d.name,'type',d.district_type),
  'neighbourhood',jsonb_build_object('code',n.code,'name',n.name),
  'road',jsonb_build_object('name',r.name,'type',r.road_type),
  'profile',to_jsonb(pp),
  'addresses',coalesce((select jsonb_agg(to_jsonb(a) order by a.is_primary desc,a.address_ref) from game.property_addresses a where a.property_id=p.id),'[]'::jsonb),
  'access_points',coalesce((select jsonb_agg(jsonb_build_object('access',to_jsonb(ap),'road_segment',to_jsonb(rs),
    'nearest_junction',jsonb_build_object('code',j.junction_code,'name',j.junction_name,'x_m',j.x_m,'y_m',j.y_m))
    order by ap.is_primary desc,ap.access_ref)
    from game.property_access_points ap join game.road_segments rs on rs.id=ap.road_segment_id
    join game.road_junctions j on j.id=ap.nearest_junction_id where ap.property_id=p.id),'[]'::jsonb),
  'interests',coalesce((select jsonb_agg(jsonb_build_object('interest',to_jsonb(pi),'holder_organisation',to_jsonb(o))
    order by pi.interest_type,pi.valid_from)
    from game.property_interest_records pi left join game.organisations o on o.id=pi.holder_organisation_id
    where pi.property_id=p.id),'[]'::jsonb),
  'valuation_history',coalesce((select jsonb_agg(to_jsonb(v) order by v.assessed_on desc,v.created_at desc)
    from game.property_valuation_records v where v.property_id=p.id),'[]'::jsonb),
  'asset_events',coalesce((select jsonb_agg(to_jsonb(e) order by e.occurred_on desc nulls last,e.created_at desc)
    from game.property_asset_events e where e.property_id=p.id),'[]'::jsonb),
  'site_agreements',coalesce((select jsonb_agg(jsonb_build_object('agreement',to_jsonb(a),'site',to_jsonb(ol),
    'tenant',to_jsonb(tenant),'counterparty_organisation',to_jsonb(cp))
    order by a.agreement_ref)
    from game.organisation_site_agreement_locations al
    join game.organisation_site_agreements a on a.id=al.agreement_id
    join game.organisation_locations ol on ol.id=al.organisation_location_id
    join game.organisations tenant on tenant.id=a.tenant_organisation_id
    left join game.organisations cp on cp.id=a.counterparty_organisation_id
    where ol.property_id=p.id),'[]'::jsonb),
  'buildings',coalesce((select jsonb_agg(jsonb_build_object('building',to_jsonb(b),'profile',to_jsonb(bp),
    'units',(select coalesce(jsonb_agg(jsonb_build_object('unit',to_jsonb(u),'profile',to_jsonb(up),
      'occupiers',(select coalesce(jsonb_agg(jsonb_build_object('organisation',to_jsonb(oo),'business',to_jsonb(biz),'site',to_jsonb(ol))),'[]'::jsonb)
       from game.organisation_locations ol join game.organisations oo on oo.id=ol.organisation_id
       left join game.business_profiles biz on biz.organisation_id=oo.id
       where ol.building_unit_id=u.id and ol.valid_to is null))
      order by up.floor_number,u.unit_ref),'[]'::jsonb)
     from game.building_units u left join game.building_unit_profiles up on up.building_unit_id=u.id where u.building_id=b.id))
    order by b.building_ref) from game.buildings b left join game.building_profiles bp on bp.building_id=b.id where b.property_id=p.id),'[]'::jsonb)
 )
 from game.properties p join game.districts d on d.id=p.district_id
 join game.neighbourhoods n on n.id=p.neighbourhood_id
 left join game.roads r on r.id=p.road_id
 left join game.property_profiles pp on pp.property_id=p.id
 where p.property_ref=p_property_ref;
$$;

create or replace function game.get_business_record(p_business_number text)
returns jsonb language sql stable as $$
 select jsonb_build_object(
  'organisation',to_jsonb(o),
  'business',to_jsonb(bp),
  'control_interests',coalesce((select jsonb_agg(jsonb_build_object(
    'interest',to_jsonb(ci),'holder_person_id',ci.holder_person_id,
    'holder_organisation',to_jsonb(holder_org))
    order by ci.control_type,ci.valid_from)
    from game.organisation_control_interests ci
    left join game.organisations holder_org on holder_org.id=ci.holder_organisation_id
    where ci.organisation_id=o.id),'[]'::jsonb),
  'sites',coalesce((select jsonb_agg(jsonb_build_object(
    'site',to_jsonb(ol),'property',to_jsonb(p),'property_profile',to_jsonb(pp),
    'address',to_jsonb(pa),'district',jsonb_build_object('code',d.code,'name',d.name),
    'neighbourhood',jsonb_build_object('code',n.code,'name',n.name),
    'building',to_jsonb(b),'unit',to_jsonb(u),'unit_profile',to_jsonb(up))
    order by ol.is_primary_location desc,p.property_ref)
    from game.organisation_locations ol
    join game.properties p on p.id=ol.property_id
    join game.districts d on d.id=p.district_id
    join game.neighbourhoods n on n.id=p.neighbourhood_id
    left join game.property_profiles pp on pp.property_id=p.id
    left join game.property_addresses pa on pa.property_id=p.id and pa.is_primary
    left join game.building_units u on u.id=ol.building_unit_id
    left join game.buildings b on b.id=u.building_id
    left join game.building_unit_profiles up on up.building_unit_id=u.id
    where ol.organisation_id=o.id),'[]'::jsonb),
  'site_agreements',coalesce((select jsonb_agg(jsonb_build_object(
    'agreement',to_jsonb(a),'site',to_jsonb(ol),'counterparty_organisation',to_jsonb(cp))
    order by a.agreement_ref)
    from game.organisation_site_agreement_locations al
    join game.organisation_site_agreements a on a.id=al.agreement_id
    join game.organisation_locations ol on ol.id=al.organisation_location_id
    left join game.organisations cp on cp.id=a.counterparty_organisation_id
    where a.tenant_organisation_id=o.id),'[]'::jsonb)
 )
 from game.business_profiles bp
 join game.organisations o on o.id=bp.organisation_id
 where bp.business_number=p_business_number;
$$;

-- New record tables are private game data; backend service_role is the access path.
revoke all on game.property_valuation_records,game.property_asset_events,
 game.organisation_control_interests,game.organisation_site_agreements,
 game.organisation_site_agreement_locations from public,anon,authenticated;
grant all on game.property_valuation_records,game.property_asset_events,
 game.organisation_control_interests,game.organisation_site_agreements,
 game.organisation_site_agreement_locations to service_role;
