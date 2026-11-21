-- Kingswell BP-02 initial geographic foundation and map network.
-- All coordinates are fictional local-grid metres; no real-world geodata is used.

create table if not exists game.district_map_areas (
  id uuid primary key default gen_random_uuid(),
  district_id uuid not null unique references game.districts(id) on delete cascade,
  map_version text not null default 'KNG-MAP-0.1',
  min_x_m integer not null,
  max_x_m integer not null,
  min_y_m integer not null,
  max_y_m integer not null,
  boundary_kind text not null default 'planning_envelope',
  created_at timestamptz not null default now(),
  constraint district_map_area_valid_extent check (min_x_m < max_x_m and min_y_m < max_y_m)
);

create table if not exists game.road_junctions (
  id uuid primary key default gen_random_uuid(),
  city_id uuid not null references game.cities(id) on delete restrict,
  junction_code text not null,
  junction_name text not null,
  x_m integer not null,
  y_m integer not null,
  junction_type text not null default 'at_grade',
  access_profile text not null default 'public',
  created_at timestamptz not null default now(),
  unique(city_id, junction_code)
);

create table if not exists game.road_segments (
  id uuid primary key default gen_random_uuid(),
  city_id uuid not null references game.cities(id) on delete restrict,
  road_id uuid not null references game.roads(id) on delete restrict,
  segment_code text not null,
  from_junction_id uuid not null references game.road_junctions(id) on delete restrict,
  to_junction_id uuid not null references game.road_junctions(id) on delete restrict,
  segment_length_m integer not null,
  road_class text not null,
  lanes_each_direction smallint not null default 1,
  speed_limit_kph smallint not null,
  directionality text not null default 'two_way',
  surface_type text not null default 'sealed',
  crossing_type text not null default 'at_grade',
  access_profile text not null default 'public',
  is_routable boolean not null default true,
  created_at timestamptz not null default now(),
  unique(city_id, segment_code),
  constraint road_segment_distinct_junctions check (from_junction_id <> to_junction_id),
  constraint road_segment_positive_length check (segment_length_m > 0),
  constraint road_segment_lanes check (lanes_each_direction between 1 and 6),
  constraint road_segment_speed check (speed_limit_kph between 5 and 130)
);

create index if not exists road_junctions_city_xy_idx on game.road_junctions(city_id, x_m, y_m);
create index if not exists road_segments_from_idx on game.road_segments(from_junction_id);
create index if not exists road_segments_to_idx on game.road_segments(to_junction_id);
create index if not exists road_segments_road_idx on game.road_segments(road_id);
create index if not exists district_map_areas_district_idx on game.district_map_areas(district_id);

alter table game.district_map_areas enable row level security;
alter table game.road_junctions enable row level security;
alter table game.road_segments enable row level security;
revoke all on game.district_map_areas, game.road_junctions, game.road_segments from public, anon, authenticated;
grant all on game.district_map_areas, game.road_junctions, game.road_segments to service_role;

-- Seed one fictional country and its capital region. The country name is a working label.
insert into game.world_countries(code,name,is_fictional)
values ('AST','Republic of Asterfell',true)
on conflict (code) do nothing;

insert into game.regions(country_id,code,name)
select id,'CAP','Kingswell Capital Region'
from game.world_countries where code='AST'
on conflict (country_id,code) do nothing;

insert into game.cities(region_id,code,name,population,is_primary_city)
select r.id,'KNG','Kingswell',100000,true
from game.regions r join game.world_countries c on c.id=r.country_id
where c.code='AST' and r.code='CAP'
on conflict (region_id,code) do nothing;

with city as (select id from game.cities where code='KNG'),
district_seed(code,name,district_type) as (values
 ('KDW','Westhaven','residential_mixed'),
 ('KNA','Northgate','residential'),
 ('KCI','Civic Quarter','government_civic'),
 ('KCB','Central Exchange','business_finance'),
 ('KED','University Heights','education_health'),
 ('KST','Kingswell Central Terminal','passenger_transport'),
 ('KMA','Market Ward','commercial_wholesale'),
 ('KIN','Foundry Park','industrial_manufacturing'),
 ('KLG','East Logistics','logistics_freight'),
 ('KPT','South Harbour','port_maritime'),
 ('KAS','Aerodrome','airport_aviation'),
 ('KMX','Riverside','mixed_riverfront')
)
insert into game.districts(city_id,code,name,district_type)
select city.id,d.code,d.name,d.district_type from city cross join district_seed d
on conflict (city_id,code) do nothing;

with district_neighbourhoods(district_code,code,name) as (values
 ('KDW','KDW-01','Old Westhaven'),('KDW','KDW-02','Willow Park'),
 ('KNA','KNA-01','Northgate Heights'),('KNA','KNA-02','Cedar Estate'),
 ('KCI','KCI-01','Civic Centre'),('KCI','KCI-02','Assembly Gardens'),
 ('KCB','KCB-01','Exchange Square'),('KCB','KCB-02','Bank Quarter'),
 ('KED','KED-01','University Campus'),('KED','KED-02','Hospital Hill'),
 ('KST','KST-01','Terminal Quarter'),('KST','KST-02','Railway Approach'),
 ('KMA','KMA-01','Grand Market'),('KMA','KMA-02','Merchants Row'),
 ('KIN','KIN-01','Foundry Estate'),('KIN','KIN-02','Works Park'),
 ('KLG','KLG-01','Freight Village'),('KLG','KLG-02','Distribution Park'),
 ('KPT','KPT-01','Harbourfront'),('KPT','KPT-02','Docklands'),
 ('KAS','KAS-01','Airport Campus'),('KAS','KAS-02','Aviation Village'),
 ('KMX','KMX-01','Riverside East'),('KMX','KMX-02','Riverside West')
)
insert into game.neighbourhoods(district_id,code,name)
select d.id,n.code,n.name
from district_neighbourhoods n
join game.districts d on d.code=n.district_code
join game.cities c on c.id=d.city_id and c.code='KNG'
on conflict (district_id,code) do nothing;

with area_seed(code,min_x,max_x,min_y,max_y) as (values
 ('KDW',0,5000,7000,13000),('KNA',5000,10000,11000,16000),
 ('KCI',7000,12000,7000,11000),('KCB',10000,15000,7000,12000),
 ('KED',2000,7000,12000,16000),('KST',8000,12000,4000,7000),
 ('KMA',12000,17000,5000,9000),('KIN',14000,20000,9000,14000),
 ('KLG',15000,20000,5000,9000),('KPT',12000,20000,0,5000),
 ('KAS',0,6000,0,5000),('KMX',5000,12000,0,5000)
)
insert into game.district_map_areas(district_id,min_x_m,max_x_m,min_y_m,max_y_m)
select d.id,a.min_x*1000,a.max_x*1000,a.min_y*1000,a.max_y*1000
from area_seed a join game.districts d on d.code=a.code
join game.cities c on c.id=d.city_id and c.code='KNG'
on conflict (district_id) do nothing;

with road_seed(code,name,road_type,district_code) as (values
 ('KNG-R001','Kingswell Outer Ring Road','primary',null),
 ('KNG-R002','Inner Civic Loop','primary','KCI'),
 ('KNG-R003','Northgate Avenue','primary','KNA'),
 ('KNG-R004','University Road','primary','KED'),
 ('KNG-R005','Foundry Boulevard','primary','KIN'),
 ('KNG-R006','Harbour Parkway','primary','KPT'),
 ('KNG-R007','Terminal Way','primary','KST'),
 ('KNG-R008','Airport Expressway','primary','KAS'),
 ('KNG-R009','Port Access Road','primary','KLG'),
 ('KNG-R010','Westhaven Road','secondary','KDW'),
 ('KNG-R011','Cedar Avenue','secondary','KNA'),
 ('KNG-R012','Assembly Avenue','secondary','KCI'),
 ('KNG-R013','Exchange Street','secondary','KCB'),
 ('KNG-R014','Campus Drive','secondary','KED'),
 ('KNG-R015','Railway Road','secondary','KST'),
 ('KNG-R016','Market Street','secondary','KMA'),
 ('KNG-R017','Works Road','secondary','KIN'),
 ('KNG-R018','Freightway','secondary','KLG'),
 ('KNG-R019','Dock Road','secondary','KPT'),
 ('KNG-R020','Riverside Drive','secondary','KMX'),
 ('KNG-R021','Aerodrome Road','secondary','KAS'),
 ('KNG-R022','Civic Square','local','KCI'),
 ('KNG-R023','Merchants Lane','local','KMA'),
 ('KNG-R024','Harbour View Road','local','KPT')
)
insert into game.roads(city_id,district_id,code,name,road_type)
select c.id,d.id,r.code,r.name,r.road_type
from road_seed r join game.cities c on c.code='KNG'
left join game.districts d on d.city_id=c.id and d.code=r.district_code
where not exists (select 1 from game.roads old where old.city_id=c.id and old.code=r.code);

-- First connected arterial skeleton on the 20 km x 16 km local grid.
with city as (select id from game.cities where code='KNG'),
junction_seed(code,name,x,y) as (values
 ('J001','Northwest Gateway',1000,14000),('J002','North Central',6000,14000),
 ('J003','Northeast Gateway',14000,14000),('J004','East Industrial Gateway',19000,12000),
 ('J005','West Central',2000,8000),('J006','Civic West',7000,9000),
 ('J007','Civic Centre',9500,9000),('J008','Central Exchange',12500,9000),
 ('J009','East Logistics',17000,7000),('J010','Southwest Airport Gate',1000,2000),
 ('J011','Riverside South',7000,2500),('J012','Terminal Interchange',10000,5500),
 ('J013','Market Junction',14500,6000),('J014','Harbour Gate',17000,2500),
 ('J015','Southwest Ring',2500,500),('J016','Southeast Ring',18500,500)
)
insert into game.road_junctions(city_id,junction_code,junction_name,x_m,y_m)
select city.id,j.code,j.name,j.x,j.y from city cross join junction_seed j
on conflict (city_id,junction_code) do nothing;

with segment_seed(code,road_code,from_code,to_code,length_m,class,lanes,speed) as (values
 ('S001','KNG-R001','J001','J002',5000,'primary',2,60),
 ('S002','KNG-R001','J002','J003',8000,'primary',2,60),
 ('S003','KNG-R001','J003','J004',5800,'primary',2,60),
 ('S004','KNG-R001','J004','J009',5200,'primary',2,60),
 ('S005','KNG-R001','J009','J013',3500,'primary',2,60),
 ('S006','KNG-R001','J013','J014',3800,'primary',2,60),
 ('S007','KNG-R001','J014','J016',2500,'primary',2,60),
 ('S008','KNG-R001','J016','J015',16000,'primary',2,60),
 ('S009','KNG-R001','J015','J010',2500,'primary',2,60),
 ('S010','KNG-R001','J010','J005',6500,'primary',2,60),
 ('S011','KNG-R001','J005','J001',6500,'primary',2,60),
 ('S012','KNG-R002','J006','J007',2500,'primary',2,40),
 ('S013','KNG-R002','J007','J008',3000,'primary',2,40),
 ('S014','KNG-R003','J002','J006',5200,'primary',2,50),
 ('S015','KNG-R004','J005','J006',4200,'primary',2,50),
 ('S016','KNG-R005','J008','J009',5200,'primary',2,50),
 ('S017','KNG-R006','J011','J012',3500,'primary',2,50),
 ('S018','KNG-R006','J012','J013',4700,'primary',2,50),
 ('S019','KNG-R007','J007','J012',3600,'primary',2,40),
 ('S020','KNG-R008','J010','J005',6500,'primary',2,70),
 ('S021','KNG-R009','J009','J013',3500,'primary',2,50),
 ('S022','KNG-R006','J013','J014',3800,'primary',2,50)
)
insert into game.road_segments(city_id,road_id,segment_code,from_junction_id,to_junction_id,segment_length_m,road_class,lanes_each_direction,speed_limit_kph)
select c.id,r.id,s.code,jf.id,jt.id,s.length_m,s.class,s.lanes,s.speed
from segment_seed s
join game.cities c on c.code='KNG'
join game.roads r on r.city_id=c.id and r.code=s.road_code
join game.road_junctions jf on jf.city_id=c.id and jf.junction_code=s.from_code
join game.road_junctions jt on jt.city_id=c.id and jt.junction_code=s.to_code
where not exists (select 1 from game.road_segments old where old.city_id=c.id and old.segment_code=s.code);
