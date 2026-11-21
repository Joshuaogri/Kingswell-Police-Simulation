-- BP-04: grounded branch/site dossiers plus explicit organisation-structure records.
create table if not exists game.organisation_site_dossiers (
 organisation_location_id uuid primary key references game.organisation_locations(id) on delete restrict,
 site_dossier_ref text not null unique,
 organisation_id uuid not null references game.organisations(id) on delete restrict,
 site_ref text not null,
 site_class text not null,
 site_status text not null,
 property_id uuid not null references game.properties(id) on delete restrict,
 building_unit_id uuid not null references game.building_units(id) on delete restrict,
 physical_address text,
 property_type text,
 land_use text,
 building_ref text,
 building_name text,
 building_type text,
 unit_ref text,
 unit_name text,
 unit_type text,
 floor_label text,
 use_class text,
 internal_area_sqm numeric,
 occupancy_capacity integer,
 operating_hours jsonb not null default '{}'::jsonb,
 premises_operating_profile jsonb not null default '{}'::jsonb,
 linked_occupancy_agreement_ref text,
 provenance jsonb not null default '{}'::jsonb check(jsonb_typeof(provenance)='object'),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
insert into game.organisation_site_dossiers(
 organisation_location_id,site_dossier_ref,organisation_id,site_ref,site_class,site_status,
 property_id,building_unit_id,physical_address,property_type,land_use,building_ref,building_name,
 building_type,unit_ref,unit_name,unit_type,floor_label,use_class,internal_area_sqm,occupancy_capacity,
 operating_hours,premises_operating_profile,linked_occupancy_agreement_ref,provenance
)
select ol.id,'KWSITE-'||replace(ol.id::text,'-',''),ol.organisation_id,ol.site_ref,
 case when ol.location_role='head_office' then 'head_office'
      when ol.location_role='tenant' then 'occupied_tenant_site'
      when ol.location_role='owner_occupier' then 'owner_occupied_site'
      else 'other_recorded_site' end,
 ol.occupancy_status,ol.property_id,ol.building_unit_id,
 concat_ws(', ',nullif(p.address_line,''),nullif(p.postal_code,''),'Kingswell'),
 p.property_type,p.land_use,b.building_ref,b.name,b.building_type,bu.unit_ref,bu.unit_name,bu.unit_type,bu.floor_label,
 up.use_class,up.internal_area_sqm,up.occupancy_capacity,coalesce(ol.operating_hours,'{}'::jsonb),
 coalesce(ol.site_details,'{}'::jsonb),a.agreement_ref,
 jsonb_build_object('source','canonical organisation_locations, properties, buildings and building_units',
 'classification','derived site dossier','physical_site_is_not_staff_assignment',true,
 'operating_profile_source','existing organisation_locations record')
from game.organisation_locations ol
join game.properties p on p.id=ol.property_id
join game.building_units bu on bu.id=ol.building_unit_id
join game.buildings b on b.id=bu.building_id
left join game.building_unit_profiles up on up.building_unit_id=bu.id
left join game.organisation_site_agreement_locations al on al.organisation_location_id=ol.id
left join game.organisation_site_agreements a on a.id=al.agreement_id
on conflict(organisation_location_id) do nothing;

-- These are canonical structures for future in-game recording. They remain empty
-- until an organisation's actual internal structure is established in play.
create table if not exists game.organisation_departments (
 id uuid primary key default gen_random_uuid(),
 department_ref text not null unique,
 organisation_id uuid not null references game.organisations(id) on delete restrict,
 parent_department_id uuid references game.organisation_departments(id) on delete restrict,
 department_name text not null,
 department_type text not null,
 remit text,
 department_status text not null default 'active',
 base_organisation_location_id uuid references game.organisation_locations(id) on delete restrict,
 manager_employment_id uuid references game.organisation_personnel(id) on delete restrict,
 valid_from date,
 valid_to date,
 provenance jsonb not null default '{}'::jsonb check(jsonb_typeof(provenance)='object'),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now(),
 unique(organisation_id,department_ref),
 check(valid_to is null or valid_from is null or valid_to>=valid_from)
);
create table if not exists game.organisation_department_positions (
 id uuid primary key default gen_random_uuid(),
 position_ref text not null unique,
 department_id uuid not null references game.organisation_departments(id) on delete restrict,
 position_title text not null,
 reports_to_position_id uuid references game.organisation_department_positions(id) on delete restrict,
 position_description text,
 position_status text not null default 'active',
 authority_profile jsonb not null default '{}'::jsonb,
 provenance jsonb not null default '{}'::jsonb check(jsonb_typeof(provenance)='object'),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table if not exists game.organisation_department_assignments (
 id uuid primary key default gen_random_uuid(),
 assignment_ref text not null unique,
 organisation_personnel_id uuid not null references game.organisation_personnel(id) on delete restrict,
 department_id uuid not null references game.organisation_departments(id) on delete restrict,
 position_id uuid references game.organisation_department_positions(id) on delete restrict,
 site_dossier_id uuid references game.organisation_site_dossiers(organisation_location_id) on delete restrict,
 supervisor_employment_id uuid references game.organisation_personnel(id) on delete restrict,
 valid_from date,
 valid_to date,
 assignment_status text not null default 'current',
 assignment_basis text,
 provenance jsonb not null default '{}'::jsonb check(jsonb_typeof(provenance)='object'),
 created_at timestamptz not null default now(),
 check(valid_to is null or valid_from is null or valid_to>=valid_from)
);
create index if not exists organisation_site_dossiers_org_idx on game.organisation_site_dossiers(organisation_id,site_class);
create index if not exists organisation_departments_org_idx on game.organisation_departments(organisation_id,parent_department_id);
create index if not exists organisation_department_positions_dept_idx on game.organisation_department_positions(department_id);
create index if not exists organisation_department_assignments_employment_idx on game.organisation_department_assignments(organisation_personnel_id,assignment_status);
create index if not exists organisation_department_assignments_department_idx on game.organisation_department_assignments(department_id);

create or replace function game.get_organisation_site_record(p_site_ref text)
returns jsonb language sql stable as $$
 select jsonb_build_object('site',to_jsonb(sd),
 'organisation',jsonb_build_object('id',o.id,'ref',o.organisation_ref,'name',o.name),
 'department_base',coalesce((select jsonb_agg(jsonb_build_object('department_ref',d.department_ref,
 'department_name',d.department_name,'department_type',d.department_type)
 order by d.department_name) from game.organisation_departments d
 join game.organisation_department_assignments da on da.department_id=d.id
 where d.base_organisation_location_id=sd.organisation_location_id),'[]'::jsonb))
 from game.organisation_site_dossiers sd join game.organisations o on o.id=sd.organisation_id
 where sd.site_ref=p_site_ref;
$$;

create or replace function game.get_organisation_structure_record(p_organisation_ref text)
returns jsonb language sql stable as $$
 select jsonb_build_object('organisation',jsonb_build_object('id',o.id,'ref',o.organisation_ref,'name',o.name),
 'departments',coalesce((select jsonb_agg(jsonb_build_object('department',to_jsonb(d),
 'positions',coalesce((select jsonb_agg(to_jsonb(pos)) from game.organisation_department_positions pos
 where pos.department_id=d.id),'[]'::jsonb),
 'assignments',coalesce((select jsonb_agg(jsonb_build_object('assignment',to_jsonb(da),
 'employment',to_jsonb(op),'site',to_jsonb(sd)))
 from game.organisation_department_assignments da
 join game.organisation_personnel op on op.id=da.organisation_personnel_id
 left join game.organisation_site_dossiers sd on sd.organisation_location_id=da.site_dossier_id
 where da.department_id=d.id),'[]'::jsonb))
 order by d.department_name) from game.organisation_departments d where d.organisation_id=o.id),'[]'::jsonb),
 'sites',coalesce((select jsonb_agg(to_jsonb(sd) order by sd.site_class,sd.site_ref)
 from game.organisation_site_dossiers sd where sd.organisation_id=o.id),'[]'::jsonb),
 'structure_status',case when exists(select 1 from game.organisation_departments d where d.organisation_id=o.id)
 then 'recorded' else 'not_yet_recorded' end)
 from game.organisations o where o.organisation_ref=p_organisation_ref;
$$;

alter table game.organisation_site_dossiers enable row level security;
alter table game.organisation_departments enable row level security;
alter table game.organisation_department_positions enable row level security;
alter table game.organisation_department_assignments enable row level security;
revoke all on game.organisation_site_dossiers,game.organisation_departments,
 game.organisation_department_positions,game.organisation_department_assignments from public,anon,authenticated;
grant all on game.organisation_site_dossiers,game.organisation_departments,
 game.organisation_department_positions,game.organisation_department_assignments to service_role;
