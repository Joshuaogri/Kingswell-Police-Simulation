-- BP-04: physical assets, utility/service systems, unit infrastructure and append-only maintenance history.
create sequence if not exists game.physical_asset_ref_seq;

create table if not exists game.property_physical_assets (
 id uuid primary key default gen_random_uuid(),
 asset_ref text not null unique default ('KWASSET-' || lpad(nextval('game.physical_asset_ref_seq')::text,9,'0')),
 property_id uuid not null references game.properties(id) on delete restrict,
 building_id uuid references game.buildings(id) on delete restrict,
 building_unit_id uuid references game.building_units(id) on delete restrict,
 parent_asset_id uuid references game.property_physical_assets(id) on delete restrict,
 asset_category text not null check(asset_category in (
  'utility_connection','electrical_system','water_system','wastewater_system','gas_system',
  'telecommunications','heating_ventilation_air_conditioning','lift_escalator',
  'fire_detection','fire_suppression','fire_escape','access_control','lock_and_key',
  'intrusion_detection','cctv','perimeter_security','lighting','generator_backup_power',
  'drainage_flood_control','structural_component','roofing','building_envelope',
  'mechanical_plant','other'
 )),
 asset_name text not null,
 asset_description text,
 system_subtype text,
 manufacturer text,
 model_reference text,
 serial_reference text,
 installation_date date,
 commissioning_date date,
 decommissioning_date date,
 asset_status text not null default 'unknown' check(asset_status in (
  'unknown','planned','installed','operational','degraded','out_of_service','under_maintenance','removed','decommissioned'
 )),
 condition_grade text not null default 'unknown' check(condition_grade in ('unknown','excellent','good','fair','poor','critical')),
 service_provider_organisation_id uuid references game.organisations(id) on delete restrict,
 owner_organisation_id uuid references game.organisations(id) on delete restrict,
 source_reference text,
 source_description text,
 technical_details jsonb not null default '{}'::jsonb check(jsonb_typeof(technical_details)='object'),
 provenance jsonb not null default '{}'::jsonb check(jsonb_typeof(provenance)='object'),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 check(building_unit_id is null or building_id is not null),
 check(decommissioning_date is null or installation_date is null or decommissioning_date>=installation_date)
);
create index if not exists property_physical_assets_property_idx on game.property_physical_assets(property_id,asset_category);
create index if not exists property_physical_assets_building_idx on game.property_physical_assets(building_id,asset_category);
create index if not exists property_physical_assets_unit_idx on game.property_physical_assets(building_unit_id,asset_category);
create index if not exists property_physical_assets_parent_idx on game.property_physical_assets(parent_asset_id);

create table if not exists game.physical_asset_maintenance_events (
 id uuid primary key default gen_random_uuid(),
 event_ref text not null unique default ('KWMAINT-' || lpad(nextval('game.physical_asset_ref_seq')::text,9,'0')),
 asset_id uuid not null references game.property_physical_assets(id) on delete restrict,
 event_type text not null check(event_type in (
  'inspection','preventive_maintenance','corrective_maintenance','repair','replacement',
  'testing','certification','failure','fault_report','servicing','installation','commissioning',
  'decommissioning','incident_damage','other'
 )),
 event_status text not null default 'recorded' check(event_status in ('reported','scheduled','in_progress','completed','cancelled','deferred','recorded','unknown')),
 priority text not null default 'unknown' check(priority in ('unknown','routine','low','normal','high','urgent','emergency')),
 occurred_at timestamptz,
 scheduled_for timestamptz,
 completed_at timestamptz,
 summary text not null,
 findings text,
 work_performed text,
 outstanding_actions text,
 contractor_organisation_id uuid references game.organisations(id) on delete restrict,
 responsible_person_id uuid references game.persons(id) on delete restrict,
 cost_amount numeric check(cost_amount is null or cost_amount>=0),
 cost_currency text,
 certificate_reference text,
 work_order_reference text,
 supersedes_event_id uuid references game.physical_asset_maintenance_events(id) on delete restrict,
 source_reference text,
 source_description text,
 event_details jsonb not null default '{}'::jsonb check(jsonb_typeof(event_details)='object'),
 created_at timestamptz not null default now(),
 check(completed_at is null or scheduled_for is null or completed_at>=scheduled_for)
);
create index if not exists physical_asset_maintenance_asset_date_idx on game.physical_asset_maintenance_events(asset_id,occurred_at,created_at);
create index if not exists physical_asset_maintenance_status_idx on game.physical_asset_maintenance_events(event_status,scheduled_for);
create index if not exists physical_asset_maintenance_work_order_idx on game.physical_asset_maintenance_events(work_order_reference) where work_order_reference is not null;

create or replace function game.prevent_physical_asset_maintenance_mutation()
returns trigger language plpgsql as $$
declare v_asset uuid;
begin
 if tg_op <> 'INSERT' then
  raise exception 'Maintenance history is append-only; record a correction or follow-up event';
 end if;
 if new.supersedes_event_id is not null then
  select asset_id into v_asset from game.physical_asset_maintenance_events where id=new.supersedes_event_id;
  if v_asset is null or v_asset <> new.asset_id then
   raise exception 'A maintenance correction must reference an earlier event for the same asset';
  end if;
 end if;
 return new;
end $$;
drop trigger if exists physical_asset_maintenance_append_only on game.physical_asset_maintenance_events;
create trigger physical_asset_maintenance_append_only
 before update or delete on game.physical_asset_maintenance_events
 for each row execute function game.prevent_physical_asset_maintenance_mutation();

create table if not exists game.building_unit_infrastructure_profiles (
 building_unit_id uuid primary key references game.building_units(id) on delete restrict,
 electrical_supply_status text not null default 'unknown' check(electrical_supply_status in ('unknown','connected','disconnected','shared','independent','not_applicable')),
 water_supply_status text not null default 'unknown' check(water_supply_status in ('unknown','connected','disconnected','shared','independent','not_applicable')),
 wastewater_status text not null default 'unknown' check(wastewater_status in ('unknown','connected','disconnected','shared','independent','not_applicable')),
 gas_supply_status text not null default 'unknown' check(gas_supply_status in ('unknown','connected','disconnected','shared','independent','not_applicable')),
 telecoms_status text not null default 'unknown' check(telecoms_status in ('unknown','connected','disconnected','shared','independent','not_applicable')),
 heating_cooling_status text not null default 'unknown' check(heating_cooling_status in ('unknown','central','unit_level','none','not_applicable')),
 fire_detection_status text not null default 'unknown' check(fire_detection_status in ('unknown','present','absent','shared','not_applicable')),
 fire_suppression_status text not null default 'unknown' check(fire_suppression_status in ('unknown','present','absent','shared','not_applicable')),
 access_control_status text not null default 'unknown' check(access_control_status in ('unknown','controlled','mechanical_key','open_access','shared','not_applicable')),
 meter_register jsonb not null default '{}'::jsonb check(jsonb_typeof(meter_register)='object'),
 utility_details jsonb not null default '{}'::jsonb check(jsonb_typeof(utility_details)='object'),
 access_details jsonb not null default '{}'::jsonb check(jsonb_typeof(access_details)='object'),
 fire_safety_details jsonb not null default '{}'::jsonb check(jsonb_typeof(fire_safety_details)='object'),
 source_reference text,
 source_description text,
 provenance jsonb not null default '{}'::jsonb check(jsonb_typeof(provenance)='object'),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);

create or replace function game.get_building_physical_asset_dossier(p_building_ref text)
returns jsonb language sql stable security invoker set search_path=game,public as $$
 select jsonb_build_object(
  'building',jsonb_build_object('id',b.id,'building_ref',b.building_ref,'name',b.name,'building_type',b.building_type,'property_ref',p.property_ref,'address',p.address_line),
  'physical_assets',coalesce((select jsonb_agg(to_jsonb(a) order by a.asset_category,a.asset_ref) from game.property_physical_assets a where a.building_id=b.id),'[]'::jsonb),
  'asset_count',(select count(*) from game.property_physical_assets a where a.building_id=b.id),
  'maintenance_events',coalesce((select jsonb_agg(jsonb_build_object('event',to_jsonb(m),'asset_ref',a.asset_ref,'asset_name',a.asset_name) order by m.occurred_at nulls last,m.created_at) from game.physical_asset_maintenance_events m join game.property_physical_assets a on a.id=m.asset_id where a.building_id=b.id),'[]'::jsonb),
  'units',coalesce((select jsonb_agg(jsonb_build_object('unit_ref',u.unit_ref,'unit_name',u.unit_name,'infrastructure',to_jsonb(i)) order by u.unit_ref) from game.building_units u left join game.building_unit_infrastructure_profiles i on i.building_unit_id=u.id where u.building_id=b.id),'[]'::jsonb),
  'data_quality',jsonb_build_object('inventory_is_record_based',true,'unrecorded_assets_are_not_assumed_absent',true,'unknown_values_are_not_inferred',true)
 )
 from game.buildings b join game.properties p on p.id=b.property_id where b.building_ref=p_building_ref;
$$;

alter table game.property_physical_assets enable row level security;
alter table game.physical_asset_maintenance_events enable row level security;
alter table game.building_unit_infrastructure_profiles enable row level security;
revoke all on game.property_physical_assets,game.physical_asset_maintenance_events,game.building_unit_infrastructure_profiles from public,anon,authenticated;
grant all on game.property_physical_assets,game.physical_asset_maintenance_events,game.building_unit_infrastructure_profiles to service_role;
revoke all on function game.get_building_physical_asset_dossier(text) from public,anon,authenticated;
grant execute on function game.get_building_physical_asset_dossier(text) to service_role;
