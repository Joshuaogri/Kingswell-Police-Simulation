-- BP-04: extend canonical property/building/unit and organisation/location identities.
create sequence if not exists game.organisation_location_ref_seq;
create table if not exists game.property_profiles (
 property_id uuid primary key references game.properties(id) on delete restrict,
 parcel_number text not null unique,title_number text unique,cadastral_block text,
 zoning_code text not null,permitted_uses text[] not null default '{}',
 development_intensity text not null,tenure_type text not null default 'freehold',
 heritage_status text not null default 'none',flood_exposure text not null default 'low',
 contamination_status text not null default 'not_assessed',
 assessed_land_value numeric(18,2),assessed_improvement_value numeric(18,2),
 assessed_currency text not null default 'AFC',annual_property_charge numeric(14,2),insurance_value numeric(18,2),
 utility_connections jsonb not null default '{}'::jsonb check(jsonb_typeof(utility_connections)='object'),
 security_profile jsonb not null default '{}'::jsonb check(jsonb_typeof(security_profile)='object'),
 fire_safety_profile jsonb not null default '{}'::jsonb check(jsonb_typeof(fire_safety_profile)='object'),
 accessibility_profile jsonb not null default '{}'::jsonb check(jsonb_typeof(accessibility_profile)='object'),
 parcel_outline jsonb not null default '{}'::jsonb check(jsonb_typeof(parcel_outline)='object'),
 map_label text,site_description text not null,planning_notes text,last_assessed_on date,
 profile_version integer not null default 1 check(profile_version>0),
 created_at timestamptz not null default now(),updated_at timestamptz not null default now()
);
create table if not exists game.building_profiles (
 building_id uuid primary key references game.buildings(id) on delete restrict,
 architectural_style text,structural_system text,roof_form text,
 exterior_materials text[] not null default '{}',basement_levels smallint not null default 0 check(basement_levels>=0),
 gross_floor_area_sqm integer,estimated_height_m numeric(8,2),construction_year smallint,last_major_renovation_year smallint,
 condition_grade text not null default 'good' check(condition_grade in ('excellent','good','fair','poor','derelict','under_construction')),
 lift_count smallint not null default 0 check(lift_count>=0),stairwell_count smallint not null default 1 check(stairwell_count>=0),
 fire_compartment_count smallint not null default 1 check(fire_compartment_count>0),sprinklered boolean not null default false,
 fire_alarm_type text,backup_power boolean not null default false,generator_capacity_kva numeric(10,2),
 cctv_coverage text not null default 'basic',access_control_type text not null default 'managed_keys',
 loading_bay_count smallint not null default 0 check(loading_bay_count>=0),dock_door_count smallint not null default 0 check(dock_door_count>=0),
 parking_capacity integer not null default 0 check(parking_capacity>=0),service_yard_area_sqm integer not null default 0 check(service_yard_area_sqm>=0),
 floor_directory jsonb not null default '[]'::jsonb check(jsonb_typeof(floor_directory)='array'),
 footprint_outline jsonb not null default '{}'::jsonb check(jsonb_typeof(footprint_outline)='object'),
 building_description text not null,building_systems jsonb not null default '{}'::jsonb check(jsonb_typeof(building_systems)='object'),
 created_at timestamptz not null default now(),updated_at timestamptz not null default now()
);
create table if not exists game.building_unit_profiles (
 building_unit_id uuid primary key references game.building_units(id) on delete restrict,
 floor_number smallint,suite_code text,use_class text not null,internal_area_sqm numeric(10,2),
 occupancy_capacity integer,bedroom_count smallint,bathroom_count smallint,
 utility_meter_refs jsonb not null default '{}'::jsonb check(jsonb_typeof(utility_meter_refs)='object'),
 access_notes text,security_zone text,
 condition_grade text not null default 'good' check(condition_grade in ('excellent','good','fair','poor','uninhabitable')),
 unit_description text not null,created_at timestamptz not null default now(),updated_at timestamptz not null default now()
);
create table if not exists game.business_profiles (
 organisation_id uuid primary key references game.organisations(id) on delete restrict,
 business_number text not null unique,trading_name text,sector text not null,subsector text not null,
 business_size text not null check(business_size in ('micro','small','medium','large','major_corporate')),
 ownership_form text not null,incorporation_date date,estimated_employee_count integer not null default 0 check(estimated_employee_count>=0),
 annual_turnover_band text,
 import_export_activity text not null default 'none' check(import_export_activity in ('none','importer','exporter','importer_exporter','trade_services','customs_brokerage')),
 principal_goods_categories text[] not null default '{}',service_description text not null,
 business_hours jsonb not null default '{}'::jsonb check(jsonb_typeof(business_hours)='object'),
 cash_handling_profile text not null default 'low',
 security_arrangements jsonb not null default '{}'::jsonb check(jsonb_typeof(security_arrangements)='object'),
 trade_profile jsonb not null default '{}'::jsonb check(jsonb_typeof(trade_profile)='object'),
 fictional_website_domain text,profile_notes text,created_at timestamptz not null default now(),updated_at timestamptz not null default now()
);
alter table game.organisation_locations
 add column if not exists building_unit_id uuid references game.building_units(id) on delete restrict,
 add column if not exists site_ref text,
 add column if not exists is_primary_location boolean not null default false,
 add column if not exists occupancy_status text not null default 'active',
 add column if not exists site_name text,
 add column if not exists operating_hours jsonb not null default '{}'::jsonb,
 add column if not exists site_details jsonb not null default '{}'::jsonb;
update game.organisation_locations set site_ref='KWLOC-'||lpad(nextval('game.organisation_location_ref_seq')::text,9,'0') where site_ref is null;
alter table game.organisation_locations alter column site_ref set not null;
alter table game.organisation_locations alter column site_ref set default ('KWLOC-'||lpad(nextval('game.organisation_location_ref_seq')::text,9,'0'));
alter table game.organisation_locations add constraint organisation_locations_site_ref_unique unique(site_ref);
alter table game.organisation_locations add constraint organisation_locations_valid_dates_bp04 check(valid_from is null or valid_to is null or valid_to>=valid_from);
alter table game.organisation_locations add constraint organisation_locations_occupancy_status_bp04 check(occupancy_status in ('active','vacant','suspended','closed','under_fitout'));
alter table game.organisation_locations add constraint organisation_locations_hours_object_bp04 check(jsonb_typeof(operating_hours)='object');
alter table game.organisation_locations add constraint organisation_locations_details_object_bp04 check(jsonb_typeof(site_details)='object');
create table if not exists game.property_interest_records (
 id uuid primary key default gen_random_uuid(),property_id uuid not null references game.properties(id) on delete restrict,
 holder_person_id uuid references game.persons(id) on delete restrict,
 holder_organisation_id uuid references game.organisations(id) on delete restrict,
 interest_type text not null check(interest_type in ('registered_owner','beneficial_owner','freeholder','leaseholder','landlord','mortgagee','property_manager','receiver','other')),
 ownership_share_pct numeric(6,3) check(ownership_share_pct is null or (ownership_share_pct>0 and ownership_share_pct<=100)),
 valid_from date,valid_to date,title_reference text,source_description text,
 interest_details jsonb not null default '{}'::jsonb check(jsonb_typeof(interest_details)='object'),
 created_at timestamptz not null default now(),
 constraint property_interest_exactly_one_holder check((holder_person_id is not null and holder_organisation_id is null) or (holder_person_id is null and holder_organisation_id is not null)),
 constraint property_interest_valid_dates check(valid_from is null or valid_to is null or valid_to>=valid_from)
);
create index if not exists property_profiles_zoning_idx on game.property_profiles(zoning_code);
create index if not exists property_profiles_heritage_idx on game.property_profiles(heritage_status);
create index if not exists building_profiles_condition_idx on game.building_profiles(condition_grade);
create index if not exists building_unit_profiles_use_idx on game.building_unit_profiles(use_class);
create index if not exists business_profiles_sector_idx on game.business_profiles(sector,subsector);
create index if not exists business_profiles_trade_idx on game.business_profiles(import_export_activity);
create index if not exists organisation_locations_unit_fk_idx on game.organisation_locations(building_unit_id);
create index if not exists organisation_locations_current_site_idx on game.organisation_locations(organisation_id,valid_to,location_role);
create unique index if not exists organisation_locations_one_current_operator_per_unit_uidx on game.organisation_locations(building_unit_id) where building_unit_id is not null and valid_to is null and occupancy_status='active';
create index if not exists property_interest_records_property_history_idx on game.property_interest_records(property_id,interest_type,valid_from desc);
create index if not exists property_interest_records_person_fk_idx on game.property_interest_records(holder_person_id);
create index if not exists property_interest_records_organisation_fk_idx on game.property_interest_records(holder_organisation_id);
create unique index if not exists property_interest_one_current_owner_per_org_uidx on game.property_interest_records(property_id,holder_organisation_id,interest_type) where valid_to is null and holder_organisation_id is not null;
create unique index if not exists property_interest_one_current_owner_per_person_uidx on game.property_interest_records(property_id,holder_person_id,interest_type) where valid_to is null and holder_person_id is not null;
alter table game.property_profiles enable row level security;
alter table game.building_profiles enable row level security;
alter table game.building_unit_profiles enable row level security;
alter table game.business_profiles enable row level security;
alter table game.property_interest_records enable row level security;
revoke all on game.property_profiles,game.building_profiles,game.building_unit_profiles,game.business_profiles,game.property_interest_records from public,anon,authenticated;
grant all on game.property_profiles,game.building_profiles,game.building_unit_profiles,game.business_profiles,game.property_interest_records to service_role;
revoke all on sequence game.organisation_location_ref_seq from public,anon,authenticated;
grant usage,select on sequence game.organisation_location_ref_seq to service_role;
