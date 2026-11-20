-- Kingswell BP-02 property, building, address, access and landmark foundation.
-- Applied migration version: 20261120111654.
-- Fictional local-grid coordinates only; deterministic, idempotent seed.

alter table game.properties
 add column if not exists x_m integer,
 add column if not exists y_m integer,
 add column if not exists parcel_area_sqm integer,
 add column if not exists frontage_width_m numeric(8,2),
 add column if not exists land_use text,
 add column if not exists frontage_segment_id uuid references game.road_segments(id),
 add column if not exists postal_code text;
alter table game.buildings
 add column if not exists x_m integer,
 add column if not exists y_m integer,
 add column if not exists footprint_width_m numeric(8,2),
 add column if not exists footprint_depth_m numeric(8,2),
 add column if not exists footprint_area_sqm integer,
 add column if not exists construction_type text,
 add column if not exists occupancy_status text default 'occupied_or_available';

create table if not exists game.property_addresses (
 id uuid primary key default gen_random_uuid(), address_ref text not null unique,
 property_id uuid not null references game.properties(id) on delete restrict,
 address_type text not null default 'postal', street_number text not null, street_name text not null,
 neighbourhood_name text not null, district_name text not null, postal_code text not null,
 formatted_address text not null, is_primary boolean not null default true,
 created_at timestamptz not null default now(), constraint property_addresses_property_ref_unique unique(property_id,address_ref)
);
create unique index if not exists uq_property_primary_address on game.property_addresses(property_id) where is_primary;
create index if not exists idx_property_addresses_postal on game.property_addresses(postal_code);
create index if not exists idx_property_addresses_formatted on game.property_addresses(formatted_address);

create table if not exists game.property_access_points (
 id uuid primary key default gen_random_uuid(), access_ref text not null unique,
 property_id uuid not null references game.properties(id) on delete restrict,
 building_id uuid references game.buildings(id) on delete restrict,
 road_segment_id uuid not null references game.road_segments(id) on delete restrict,
 nearest_junction_id uuid not null references game.road_junctions(id) on delete restrict,
 access_type text not null, x_m integer not null, y_m integer not null,
 access_profile text not null default 'public', is_primary boolean not null default true,
 created_at timestamptz not null default now()
);
create unique index if not exists uq_property_primary_access on game.property_access_points(property_id) where is_primary;
create index if not exists idx_property_access_road_segment on game.property_access_points(road_segment_id);
create index if not exists idx_property_access_junction on game.property_access_points(nearest_junction_id);

create table if not exists game.city_landmarks (
 id uuid primary key default gen_random_uuid(), landmark_ref text not null unique, name text not null,
 landmark_type text not null, city_id uuid not null references game.cities(id) on delete restrict,
 district_id uuid not null references game.districts(id) on delete restrict,
 neighbourhood_id uuid not null references game.neighbourhoods(id) on delete restrict,
 property_id uuid not null references game.properties(id) on delete restrict,
 building_id uuid not null references game.buildings(id) on delete restrict,
 access_point_id uuid not null references game.property_access_points(id) on delete restrict,
 x_m integer not null, y_m integer not null, public_access text not null default 'public',
 significance text, created_at timestamptz not null default now()
);
create index if not exists idx_city_landmarks_location on game.city_landmarks(city_id,district_id,neighbourhood_id);
create index if not exists idx_city_landmarks_property on game.city_landmarks(property_id);

alter table game.property_addresses enable row level security;
alter table game.property_access_points enable row level security;
alter table game.city_landmarks enable row level security;
revoke all on game.property_addresses,game.property_access_points,game.city_landmarks from public,anon,authenticated;
grant all on game.property_addresses,game.property_access_points,game.city_landmarks to service_role;
revoke all on game.properties,game.buildings,game.building_units from public,anon,authenticated;
grant all on game.properties,game.buildings,game.building_units to service_role;

do $seed$
declare n record; lot integer; side_no integer; v_city uuid; v_district uuid; v_neighbourhood uuid;
 v_road uuid; v_segment uuid; v_junction uuid; v_property uuid; v_building uuid; v_access uuid;
 v_property_ref text; v_building_ref text; v_address_ref text; v_access_ref text; v_number text;
 v_street text; v_neighbourhood_name text; v_district_name text; v_postal text; v_formatted text;
 v_x integer; v_y integer; v_width integer; v_depth integer; v_area integer; v_land_use text;
 v_property_type text; v_building_type text; v_floors integer; v_construction text;
 v_landmark_name text; v_landmark_type text; v_unit_count integer; u integer; v_unit_ref text;
begin
 select id into v_city from game.cities where code='KNG';
 if v_city is null then raise exception 'Kingswell city KNG missing'; end if;
 for n in select * from (values
 ('KDW-01',2200,9000),('KDW-02',3800,11200),('KNA-01',6800,13700),('KNA-02',8800,12200),
 ('KCI-01',8500,8200),('KCI-02',10800,10000),('KCB-01',11800,10500),('KCB-02',14000,8200),
 ('KED-01',3600,14500),('KED-02',5600,12800),('KST-01',9000,4800),('KST-02',11000,6200),
 ('KMA-01',14000,7200),('KMA-02',16000,5600),('KIN-01',16500,11500),('KIN-02',18500,13200),
 ('KLG-01',16500,8200),('KLG-02',18500,6200),('KPT-01',15500,3500),('KPT-02',18500,1800),
 ('KAS-01',2200,3500),('KAS-02',4500,1500),('KMX-01',8500,3000),('KMX-02',6500,1200)
 ) v(code,cx,cy) loop
  select d.id,d.name,h.id,h.name into v_district,v_district_name,v_neighbourhood,v_neighbourhood_name
   from game.neighbourhoods h join game.districts d on d.id=h.district_id
   where h.code=n.code and d.city_id=v_city;
  select id,name into v_road,v_street from game.roads where city_id=v_city and code='KNG-L-'||replace(n.code,'-','');
  for lot in 1..20 loop
   side_no:=((lot-1)/5)::integer;
   if side_no=0 then v_x:=n.cx-250+(lot-1)*83+41; v_y:=n.cy+270;
   elsif side_no=1 then v_x:=n.cx+270; v_y:=n.cy+250-((lot-6)*83+41);
   elsif side_no=2 then v_x:=n.cx+250-((lot-11)*83+41); v_y:=n.cy-270;
   else v_x:=n.cx-270; v_y:=n.cy-250+((lot-16)*83+41); end if;
   select s.id,case when ((jf.x_m-v_x)::bigint*(jf.x_m-v_x)::bigint+(jf.y_m-v_y)::bigint*(jf.y_m-v_y)::bigint)
      <= ((jt.x_m-v_x)::bigint*(jt.x_m-v_x)::bigint+(jt.y_m-v_y)::bigint*(jt.y_m-v_y)::bigint)
      then jf.id else jt.id end into v_segment,v_junction
    from game.road_segments s join game.road_junctions jf on jf.id=s.from_junction_id
    join game.road_junctions jt on jt.id=s.to_junction_id
    where s.city_id=v_city and s.segment_code='N-'||replace(n.code,'-','')||'-0'||(side_no+1);
   v_property_ref:='KNG-P-'||replace(n.code,'-','')||lpad(lot::text,3,'0');
   v_building_ref:='KNG-B-'||replace(n.code,'-','')||lpad(lot::text,3,'0');
   v_address_ref:='KNG-ADR-'||replace(n.code,'-','')||lpad(lot::text,3,'0');
   v_access_ref:='KNG-ACC-'||replace(n.code,'-','')||lpad(lot::text,3,'0');
   v_number:=lot::text; v_postal:='KNG-'||replace(n.code,'-','');
   v_formatted:=v_number||' '||v_street||', '||v_neighbourhood_name||', '||v_district_name||', Kingswell, Asterfell, '||v_postal;
   if n.code like 'KDW%' or n.code like 'KNA%' then
    v_land_use:='residential'; v_property_type:='residential';
    v_building_type:=case when lot%5=0 then 'apartment_block' else 'detached_house' end; v_floors:=case when lot%5=0 then 4 else 2 end;
   elsif n.code like 'KCI%' then
    v_land_use:='civic_and_public'; v_property_type:='civic_institution';
    v_building_type:=case when lot%4=0 then 'public_service_building' else 'civic_office' end; v_floors:=3+(lot%4);
   elsif n.code like 'KCB%' then
    v_land_use:='commercial'; v_property_type:='commercial';
    v_building_type:=case when lot%4=0 then 'retail_block' else 'office_building' end; v_floors:=4+(lot%9);
   elsif n.code like 'KED%' then
    v_land_use:='education_and_health'; v_property_type:='institutional';
    v_building_type:=case when lot%3=0 then 'medical_facility' else 'education_building' end; v_floors:=2+(lot%6);
   elsif n.code like 'KST%' then
    v_land_use:='transport_and_commercial'; v_property_type:='transport_commercial';
    v_building_type:=case when lot%4=0 then 'transport_facility' else 'commercial_terminal_premises' end; v_floors:=2+(lot%6);
   elsif n.code like 'KMA%' then
    v_land_use:='retail_and_wholesale'; v_property_type:='retail_commercial';
    v_building_type:=case when lot%3=0 then 'market_hall' else 'shop_or_market_premises' end; v_floors:=1+(lot%3);
   elsif n.code like 'KIN%' then
    v_land_use:='industrial'; v_property_type:='industrial';
    v_building_type:=case when lot%3=0 then 'factory' else 'industrial_workshop' end; v_floors:=1+(lot%3);
   elsif n.code like 'KLG%' then
    v_land_use:='logistics'; v_property_type:='logistics';
    v_building_type:=case when lot%3=0 then 'distribution_centre' else 'warehouse' end; v_floors:=1+(lot%2);
   elsif n.code like 'KPT%' then
    v_land_use:='port_and_maritime'; v_property_type:='maritime';
    v_building_type:=case when lot%3=0 then 'port_operations_building' else 'port_warehouse' end; v_floors:=1+(lot%3);
   elsif n.code like 'KAS%' then
    v_land_use:='aviation'; v_property_type:='aviation';
    v_building_type:=case when lot%3=0 then 'airport_support_facility' else 'aviation_service_building' end; v_floors:=1+(lot%4);
   else
    v_land_use:='mixed_use'; v_property_type:='mixed_use';
    v_building_type:=case when lot%3=0 then 'mixed_use_block' else 'apartment_and_retail' end; v_floors:=3+(lot%7);
   end if;
   v_width:=case when v_land_use in ('industrial','logistics','port_and_maritime','aviation') then 42+(lot%5)*6
    when v_land_use in ('education_and_health','civic_and_public') then 24+(lot%4)*5 else 10+(lot%4)*3 end;
   v_depth:=case when v_land_use in ('industrial','logistics','port_and_maritime','aviation') then 55+(lot%4)*10 else 18+(lot%5)*6 end;
   v_area:=v_width*v_depth;
   v_construction:=case when v_land_use in ('industrial','logistics','port_and_maritime') then 'steel_frame_or_masonry'
    when v_floors>=6 then 'reinforced_concrete' else 'masonry_or_concrete' end;
   insert into game.properties(property_ref,city_id,district_id,neighbourhood_id,road_id,street_number,address_line,
    property_type,latitude,longitude,status,x_m,y_m,parcel_area_sqm,frontage_width_m,land_use,frontage_segment_id,postal_code)
   values(v_property_ref,v_city,v_district,v_neighbourhood,v_road,v_number,v_formatted,v_property_type,null,null,'active',
    v_x,v_y,greatest(300,v_width*v_depth*3),v_width,v_land_use,v_segment,v_postal)
   on conflict(property_ref) do update set x_m=excluded.x_m,y_m=excluded.y_m,frontage_segment_id=excluded.frontage_segment_id,
    land_use=excluded.land_use,parcel_area_sqm=excluded.parcel_area_sqm,frontage_width_m=excluded.frontage_width_m,
    postal_code=excluded.postal_code,address_line=excluded.address_line,street_number=excluded.street_number;
   select id into v_property from game.properties where property_ref=v_property_ref;
   insert into game.buildings(building_ref,property_id,name,building_type,floors,x_m,y_m,footprint_width_m,
    footprint_depth_m,footprint_area_sqm,construction_type,occupancy_status)
   values(v_building_ref,v_property,case when lot=1 then v_neighbourhood_name||' Landmark Building'
    else v_neighbourhood_name||' '||case when v_land_use='residential' then 'Residence' else 'Premises' end||' '||lpad(lot::text,2,'0') end,
    v_building_type,v_floors,v_x,v_y,v_width,v_depth,v_area,v_construction,'occupied_or_available')
   on conflict(building_ref) do update set x_m=excluded.x_m,y_m=excluded.y_m,building_type=excluded.building_type,
    floors=excluded.floors,footprint_width_m=excluded.footprint_width_m,footprint_depth_m=excluded.footprint_depth_m,
    footprint_area_sqm=excluded.footprint_area_sqm,construction_type=excluded.construction_type;
   select id into v_building from game.buildings where building_ref=v_building_ref;
   insert into game.property_addresses(address_ref,property_id,address_type,street_number,street_name,
    neighbourhood_name,district_name,postal_code,formatted_address,is_primary)
   values(v_address_ref,v_property,'postal',v_number,v_street,v_neighbourhood_name,v_district_name,v_postal,v_formatted,true)
   on conflict(address_ref) do update set property_id=excluded.property_id,formatted_address=excluded.formatted_address,
    street_number=excluded.street_number,street_name=excluded.street_name,postal_code=excluded.postal_code;
   insert into game.property_access_points(access_ref,property_id,building_id,road_segment_id,nearest_junction_id,
    access_type,x_m,y_m,access_profile,is_primary)
   values(v_access_ref,v_property,v_building,v_segment,v_junction,'street_entrance',v_x,v_y,
    case when v_land_use in ('aviation','port_and_maritime','industrial','logistics') then 'controlled_service_or_public' else 'public' end,true)
   on conflict(access_ref) do update set building_id=excluded.building_id,road_segment_id=excluded.road_segment_id,
    nearest_junction_id=excluded.nearest_junction_id,x_m=excluded.x_m,y_m=excluded.y_m;
   select id into v_access from game.property_access_points where access_ref=v_access_ref;
   if v_building_type='apartment_block' or v_building_type in ('mixed_use_block','apartment_and_retail') then
    v_unit_count:=case when v_building_type='apartment_block' then 8 else 4 end;
    for u in 1..v_unit_count loop
     v_unit_ref:='KNG-U-'||replace(n.code,'-','')||lpad(lot::text,3,'0')||'-'||lpad(u::text,2,'0');
     insert into game.building_units(unit_ref,building_id,parent_unit_id,unit_name,unit_type,floor_label)
     values(v_unit_ref,v_building,null,case when v_building_type='apartment_block' then 'Flat '||u else 'Unit '||u end,
      case when v_building_type='apartment_block' then 'residential' else 'mixed_use' end,((u-1)/2+1)::text)
     on conflict(unit_ref) do nothing;
    end loop;
   else
    v_unit_ref:='KNG-U-'||replace(n.code,'-','')||lpad(lot::text,3,'0')||'-01';
    insert into game.building_units(unit_ref,building_id,parent_unit_id,unit_name,unit_type,floor_label)
    values(v_unit_ref,v_building,null,'Primary Premises','whole_premises','Ground')
    on conflict(unit_ref) do nothing;
   end if;
   if lot=1 then
    v_landmark_name:=case n.code
     when 'KDW-01' then 'Westhaven Community Hall' when 'KDW-02' then 'Willow Park Pavilion'
     when 'KNA-01' then 'Northgate Civic Library' when 'KNA-02' then 'Cedar Estate Recreation Centre'
     when 'KCI-01' then 'Kingswell City Hall' when 'KCI-02' then 'Asterfell Assembly House'
     when 'KCB-01' then 'Kingswell Exchange Tower' when 'KCB-02' then 'Central Reserve Building'
     when 'KED-01' then 'Kingswell National University' when 'KED-02' then 'Kingswell Central Hospital'
     when 'KST-01' then 'Kingswell Central Station' when 'KST-02' then 'Railway Heritage Hall'
     when 'KMA-01' then 'Grand Kingswell Market' when 'KMA-02' then 'Merchants Exchange Hall'
     when 'KIN-01' then 'Foundry Works Museum' when 'KIN-02' then 'Industrial Innovation Centre'
     when 'KLG-01' then 'Kingswell Freight Exchange' when 'KLG-02' then 'East Logistics Control Centre'
     when 'KPT-01' then 'Kingswell Port Authority' when 'KPT-02' then 'Docklands Maritime Museum'
     when 'KAS-01' then 'Kingswell International Airport Terminal' when 'KAS-02' then 'Aviation Heritage Centre'
     when 'KMX-01' then 'Riverside Promenade Pavilion' else 'Riverside Arts Centre' end;
    v_landmark_type:=case when n.code like 'KCI%' then 'government'
     when n.code='KED-02' then 'hospital' when n.code like 'KED%' then 'education'
     when n.code like 'KST%' then 'transport' when n.code like 'KMA%' then 'market'
     when n.code like 'KIN%' then 'industrial_heritage' when n.code like 'KLG%' then 'logistics'
     when n.code like 'KPT%' then 'maritime' when n.code like 'KAS%' then 'aviation'
     when n.code like 'KCB%' then 'commercial' else 'community' end;
    insert into game.city_landmarks(landmark_ref,name,landmark_type,city_id,district_id,neighbourhood_id,
     property_id,building_id,access_point_id,x_m,y_m,public_access,significance)
    values('KNG-LM-'||replace(n.code,'-',''),v_landmark_name,v_landmark_type,v_city,v_district,v_neighbourhood,
     v_property,v_building,v_access,v_x,v_y,
     case when n.code in ('KCI-02','KCB-02','KLG-02','KAS-01','KPT-01') then 'controlled_or_scheduled' else 'public' end,
     'Named city landmark and operational location reference for navigation, dispatch and investigations.')
    on conflict(landmark_ref) do update set name=excluded.name,property_id=excluded.property_id,
     building_id=excluded.building_id,access_point_id=excluded.access_point_id,x_m=excluded.x_m,y_m=excluded.y_m;
   end if;
  end loop;
 end loop;
end $seed$;

create index if not exists idx_properties_city_xy on game.properties(city_id,x_m,y_m);
create index if not exists idx_properties_frontage_segment on game.properties(frontage_segment_id);
create index if not exists idx_buildings_property_xy on game.buildings(property_id,x_m,y_m);
