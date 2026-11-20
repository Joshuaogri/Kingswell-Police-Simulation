-- Kingswell BP-02: police facilities, patrol sectors, neighbourhood beats and road coverage.
-- All records are fictional planning data; no personnel, units or incidents are seeded.

create table game.police_facilities (
 id uuid primary key default gen_random_uuid(),
 facility_ref text not null unique,
 facility_name text not null,
 facility_type text not null check (facility_type in ('headquarters','district_station','custody_facility','operations_centre','forensic_facility','training_centre','fleet_facility')),
 status text not null default 'active' check (status in ('active','planned','temporarily_closed','closed')),
 district_id uuid not null references game.districts(id),
 neighbourhood_id uuid not null references game.neighbourhoods(id),
 property_id uuid not null references game.properties(id),
 building_id uuid not null references game.buildings(id),
 address_id uuid not null references game.property_addresses(id),
 access_point_id uuid not null references game.property_access_points(id),
 x_m integer not null,
 y_m integer not null,
 operating_profile text not null,
 created_at timestamptz not null default now(),
 unique(property_id)
);
create table game.patrol_sectors (
 id uuid primary key default gen_random_uuid(),
 sector_ref text not null unique,
 sector_name text not null,
 district_id uuid not null unique references game.districts(id),
 command_level text not null default 'district',
 status text not null default 'active' check (status in ('active','suspended','retired')),
 created_at timestamptz not null default now()
);
create table game.patrol_beats (
 id uuid primary key default gen_random_uuid(),
 beat_ref text not null unique,
 beat_name text not null,
 sector_id uuid not null references game.patrol_sectors(id),
 district_id uuid not null references game.districts(id),
 neighbourhood_id uuid not null unique references game.neighbourhoods(id),
 beat_type text not null default 'neighbourhood',
 status text not null default 'active' check (status in ('active','suspended','retired')),
 created_at timestamptz not null default now()
);
create table game.patrol_beat_road_segments (
 id uuid primary key default gen_random_uuid(),
 beat_id uuid not null references game.patrol_beats(id) on delete cascade,
 road_segment_id uuid not null references game.road_segments(id),
 coverage_order integer not null check (coverage_order > 0),
 coverage_role text not null default 'local_coverage',
 created_at timestamptz not null default now(),
 unique(beat_id,road_segment_id),
 unique(road_segment_id),
 unique(beat_id,coverage_order)
);
alter table game.police_stations add column facility_id uuid references game.police_facilities(id);
alter table game.police_units add column base_facility_id uuid references game.police_facilities(id);
alter table game.police_units add column assigned_beat_id uuid references game.patrol_beats(id);
create index police_facilities_district_idx on game.police_facilities(district_id);
create index police_facilities_access_idx on game.police_facilities(access_point_id);
create index patrol_beats_sector_idx on game.patrol_beats(sector_id);
create index patrol_beats_district_idx on game.patrol_beats(district_id);
create index patrol_beat_road_segments_segment_idx on game.patrol_beat_road_segments(road_segment_id);
create index police_units_base_facility_idx on game.police_units(base_facility_id);
create index police_units_assigned_beat_idx on game.police_units(assigned_beat_id);
alter table game.police_facilities enable row level security;
alter table game.patrol_sectors enable row level security;
alter table game.patrol_beats enable row level security;
alter table game.patrol_beat_road_segments enable row level security;
revoke all on game.police_facilities,game.patrol_sectors,game.patrol_beats,game.patrol_beat_road_segments from public, anon, authenticated;
grant all on game.police_facilities,game.patrol_sectors,game.patrol_beats,game.patrol_beat_road_segments to service_role;

with ranked as (
 select p.*, row_number() over(partition by d.code order by p.property_ref) rn
 from game.properties p join game.districts d on d.id=p.district_id
), specs(facility_ref,facility_name,facility_type,district_code,property_rank,operating_profile) as (
 values
 ('KNG-PF-HQ','Kingswell Police Headquarters','headquarters','KCI',1,'continuous_command'),
 ('KNG-PF-KDW','Westhaven District Police Station','district_station','KDW',1,'public_counter_and_patrol'),
 ('KNG-PF-KNA','Northgate District Police Station','district_station','KNA',1,'public_counter_and_patrol'),
 ('KNG-PF-KCI','Civic Quarter District Police Station','district_station','KCI',2,'public_counter_and_patrol'),
 ('KNG-PF-KCB','Central Exchange District Police Station','district_station','KCB',1,'public_counter_and_patrol'),
 ('KNG-PF-KED','University Heights District Police Station','district_station','KED',1,'public_counter_and_patrol'),
 ('KNG-PF-KST','Central Terminal District Police Station','district_station','KST',1,'public_counter_and_patrol'),
 ('KNG-PF-KMA','Market Ward District Police Station','district_station','KMA',1,'public_counter_and_patrol'),
 ('KNG-PF-KIN','Foundry Park District Police Station','district_station','KIN',1,'public_counter_and_patrol'),
 ('KNG-PF-KLG','East Logistics District Police Station','district_station','KLG',1,'public_counter_and_patrol'),
 ('KNG-PF-KPT','South Harbour District Police Station','district_station','KPT',1,'public_counter_and_patrol'),
 ('KNG-PF-KAS','Aerodrome District Police Station','district_station','KAS',1,'public_counter_and_patrol'),
 ('KNG-PF-KMX','Riverside District Police Station','district_station','KMX',1,'public_counter_and_patrol'),
 ('KNG-PF-CUSTODY','Kingswell Central Custody Facility','custody_facility','KCI',3,'secure_custody_operations'),
 ('KNG-PF-COMMS','Kingswell Police Operations and Communications Centre','operations_centre','KST',2,'continuous_dispatch_operations'),
 ('KNG-PF-FORENSICS','Kingswell Forensic Services Centre','forensic_facility','KED',2,'scheduled_specialist_operations'),
 ('KNG-PF-TRAIN','Kingswell Police Training Centre','training_centre','KDW',2,'scheduled_training'),
 ('KNG-PF-FLEET','Kingswell Police Fleet and Workshop','fleet_facility','KAS',2,'scheduled_fleet_support')
)
insert into game.police_facilities
 (facility_ref,facility_name,facility_type,district_id,neighbourhood_id,property_id,building_id,address_id,access_point_id,x_m,y_m,operating_profile)
select s.facility_ref,s.facility_name,s.facility_type,d.id,p.neighbourhood_id,p.id,b.id,pa.id,ap.id,p.x_m,p.y_m,s.operating_profile
from specs s
join game.districts d on d.code=s.district_code
join ranked p on p.district_id=d.id and p.rn=s.property_rank
join game.buildings b on b.property_id=p.id
join game.property_addresses pa on pa.property_id=p.id and pa.is_primary
join game.property_access_points ap on ap.property_id=p.id and ap.is_primary;

insert into game.police_stations(station_ref,station_name,station_type,status,property_id,facility_id)
select case when f.facility_type='headquarters' then 'KNG-STA-HQ' else 'KNG-STA-'||d.code end,
       case when f.facility_type='headquarters' then 'Kingswell Police Headquarters' else d.name||' District Police Station' end,
       case when f.facility_type='headquarters' then 'headquarters' else 'district' end,
       'active',f.property_id,f.id
from game.police_facilities f
join game.districts d on d.id=f.district_id
where f.facility_type in ('headquarters','district_station');

insert into game.patrol_sectors(sector_ref,sector_name,district_id)
select 'KNG-SEC-'||code,name||' Patrol Sector',id from game.districts;

insert into game.patrol_beats(beat_ref,beat_name,sector_id,district_id,neighbourhood_id)
select 'KNG-BEAT-'||n.code,n.name||' Beat',s.id,d.id,n.id
from game.neighbourhoods n
join game.districts d on d.id=n.district_id
join game.patrol_sectors s on s.district_id=d.id;

with neighbourhood_centres as (
 select n.id neighbourhood_id,avg(p.x_m)::numeric cx,avg(p.y_m)::numeric cy
 from game.neighbourhoods n join game.properties p on p.neighbourhood_id=n.id
 group by n.id
), segment_centres as (
 select rs.id road_segment_id,(j1.x_m+j2.x_m)::numeric/2 sx,(j1.y_m+j2.y_m)::numeric/2 sy
 from game.road_segments rs
 join game.road_junctions j1 on j1.id=rs.from_junction_id
 join game.road_junctions j2 on j2.id=rs.to_junction_id
 where rs.is_routable
), assignments as (
 select sc.road_segment_id,nc.neighbourhood_id,
 row_number() over(partition by nc.neighbourhood_id order by sc.road_segment_id) coverage_order
 from segment_centres sc
 cross join lateral (
  select neighbourhood_id from neighbourhood_centres nc
  order by power(sc.sx-nc.cx,2)+power(sc.sy-nc.cy,2),neighbourhood_id
  limit 1
 ) nc
)
insert into game.patrol_beat_road_segments(beat_id,road_segment_id,coverage_order,coverage_role)
select b.id,a.road_segment_id,a.coverage_order,'geographic_beat_coverage'
from assignments a join game.patrol_beats b on b.neighbourhood_id=a.neighbourhood_id;
