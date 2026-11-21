
create temporary table bp04_new_sites on commit drop as
with bounds as (
  select n.id neighbourhood_id,n.code neighbourhood_code,n.name neighbourhood_name,d.id district_id,d.code district_code,d.name district_name,
         min(p.x_m) min_x,max(p.x_m) max_x,min(p.y_m) min_y,max(p.y_m) max_y
  from game.neighbourhoods n join game.districts d on d.id=n.district_id
  join game.properties p on p.neighbourhood_id=n.id group by n.id,n.code,n.name,d.id,d.code,d.name
),
residential as (
  select b.*,'residential'::text site_kind,g.slot,
    b.min_x+90+((g.slot-1)%4)*120 x_m,b.min_y+90+((g.slot-1)/4)*180 y_m
  from bounds b cross join generate_series(1,12) g(slot)
  where b.neighbourhood_code in ('KDW-01','KDW-02','KNA-01','KNA-02','KMX-01','KMX-02','KED-01','KED-02')
),
commercial as (
  select b.*,'commercial'::text site_kind,g.slot,b.min_x+70+(g.slot-1)*95 x_m,b.min_y+270 y_m
  from bounds b cross join generate_series(1,5) g(slot)
  where b.district_code in ('KCB','KCI','KST','KMA','KLG','KIN','KPT','KAS')
),
numbered as (
  select a.*,row_number() over(partition by site_kind order by neighbourhood_code,slot)::integer local_no
  from (select * from residential union all select * from commercial) a
)
select n.*,
  case when site_kind='residential' then 'KNG-P-RH'||lpad(local_no::text,4,'0') else 'KNG-P-CM'||lpad(local_no::text,4,'0') end property_ref,
  case when site_kind='residential' then 'KNG-B-RH'||lpad(local_no::text,4,'0') else 'KNG-B-CM'||lpad(local_no::text,4,'0') end building_ref,
  case when site_kind='residential' then 'KNG-ADR-RH'||lpad(local_no::text,4,'0') else 'KNG-ADR-CM'||lpad(local_no::text,4,'0') end address_ref,
  case when site_kind='residential' then 'KNG-ACC-RH'||lpad(local_no::text,4,'0') else 'KNG-ACC-CM'||lpad(local_no::text,4,'0') end access_ref,
  near.road_id,near.frontage_segment_id,seg.from_junction_id nearest_junction_id,road.name road_name,
  null::uuid property_id,null::uuid building_id
from numbered n
cross join lateral (
  select p.road_id,p.frontage_segment_id from game.properties p where p.neighbourhood_id=n.neighbourhood_id
  order by ((p.x_m-n.x_m)*(p.x_m-n.x_m)+(p.y_m-n.y_m)*(p.y_m-n.y_m)),p.property_ref limit 1
) near
join game.road_segments seg on seg.id=near.frontage_segment_id
join game.roads road on road.id=near.road_id;

insert into game.properties(property_ref,city_id,district_id,neighbourhood_id,road_id,street_number,address_line,property_type,status,x_m,y_m,parcel_area_sqm,frontage_width_m,land_use,frontage_segment_id,postal_code)
select s.property_ref,c.id,s.district_id,s.neighbourhood_id,s.road_id,
  case when site_kind='residential' then (200+local_no)::text else (500+local_no)::text end,
  case when site_kind='residential' then 'Residential tower parcel' else 'Commercial development parcel' end,
  case when site_kind='residential' then 'residential_highrise'
    when district_code in ('KLG','KPT') then 'logistics_commercial' when district_code='KIN' then 'industrial_commercial'
    when district_code='KMA' then 'retail_commercial' when district_code='KST' then 'transport_commercial'
    when district_code='KAS' then 'aviation_commercial' else 'commercial' end,
  'active',x_m,y_m,case when site_kind='residential' then 5200 else 9000 end,
  case when site_kind='residential' then 58 else 90 end,
  case when site_kind='residential' then 'residential'
    when district_code='KLG' then 'logistics' when district_code='KIN' then 'industrial'
    when district_code='KMA' then 'retail_and_wholesale' when district_code='KST' then 'transport_and_commercial'
    when district_code='KAS' then 'aviation' when district_code='KPT' then 'port_and_maritime' else 'commercial' end,
  frontage_segment_id,'KNG-'||replace(neighbourhood_code,'-','')
from bp04_new_sites s join game.cities c on c.code='KNG';

with inserted as (
  insert into game.buildings(building_ref,property_id,name,building_type,floors,x_m,y_m,footprint_width_m,footprint_depth_m,footprint_area_sqm,construction_type,occupancy_status)
  select s.building_ref,p.id,
    case when site_kind='residential' then neighbourhood_name||' Heights Residential Tower '||lpad(local_no::text,2,'0')
      when district_code='KCB' then 'Kingswell Financial and Corporate Centre '||lpad(local_no::text,2,'0')
      when district_code='KCI' then 'Civic and Professional House '||lpad(local_no::text,2,'0')
      when district_code='KST' then 'Central Passenger Exchange Commercial Block '||lpad(local_no::text,2,'0')
      when district_code='KMA' then 'Grand Market Trade Arcade '||lpad(local_no::text,2,'0')
      when district_code='KLG' then 'East Logistics Distribution Centre '||lpad(local_no::text,2,'0')
      when district_code='KIN' then 'Foundry Business and Industrial Centre '||lpad(local_no::text,2,'0')
      when district_code='KPT' then 'South Harbour Trade Centre '||lpad(local_no::text,2,'0')
      else 'Aerodrome Commercial and Cargo Centre '||lpad(local_no::text,2,'0') end,
    case when site_kind='residential' then 'residential_tower' when district_code='KCB' then 'office_tower'
      when district_code='KCI' then 'office_and_civic_commercial' when district_code='KST' then 'transport_commercial_complex'
      when district_code='KMA' then 'retail_market_complex' when district_code='KLG' then 'logistics_business_centre'
      when district_code='KIN' then 'industrial_business_centre' when district_code='KPT' then 'port_trade_complex'
      else 'aviation_commercial_complex' end,
    case when site_kind='residential' then 32 when district_code='KCB' then 14 when district_code='KCI' then 12
      when district_code='KST' then 8 when district_code='KMA' then 6 when district_code='KLG' then 5
      when district_code='KIN' then 6 when district_code='KPT' then 7 else 8 end,
    s.x_m,s.y_m,case when site_kind='residential' then 45 else 60 end,
    case when site_kind='residential' then 40 else 60 end,case when site_kind='residential' then 1800 else 3600 end,
    case when site_kind='residential' or district_code in ('KCB','KCI') then 'reinforced_concrete' else 'steel_frame_or_reinforced_concrete' end,
    'occupied_or_available'
  from bp04_new_sites s join game.properties p on p.property_ref=s.property_ref
  returning id,building_ref
)
update bp04_new_sites s set building_id=i.id from inserted i where i.building_ref=s.building_ref;

insert into game.property_addresses(address_ref,property_id,address_type,street_number,street_name,neighbourhood_name,district_name,postal_code,formatted_address,is_primary)
select s.address_ref,p.id,'postal',
  case when site_kind='residential' then (200+local_no)::text else (500+local_no)::text end,
  s.road_name,s.neighbourhood_name,s.district_name,'KNG-'||replace(s.neighbourhood_code,'-',''),
  (case when site_kind='residential' then (200+local_no)::text else (500+local_no)::text end)||' '||s.road_name||', '||s.neighbourhood_name||', '||s.district_name||', Kingswell, Asterfell, KNG-'||replace(s.neighbourhood_code,'-',''),
  true
from bp04_new_sites s join game.properties p on p.property_ref=s.property_ref;

insert into game.property_access_points(access_ref,property_id,building_id,road_segment_id,nearest_junction_id,access_type,x_m,y_m,access_profile,is_primary)
select s.access_ref,p.id,s.building_id,s.frontage_segment_id,s.nearest_junction_id,
  case when site_kind='residential' then 'primary_entrance_and_vehicle_access' else 'primary_commercial_vehicle_access' end,
  s.x_m,s.y_m,'public',true
from bp04_new_sites s join game.properties p on p.property_ref=s.property_ref;

insert into game.building_units(unit_ref,building_id,parent_unit_id,unit_name,unit_type,floor_label)
select 'KNG-U-RH'||lpad(s.local_no::text,4,'0')||'-'||lpad(g.unit_no::text,3,'0'),
  s.building_id,null,'Apartment '||lpad(g.unit_no::text,2,'0'),'residential',
  'Level '||lpad(ceil(g.unit_no/8.0)::integer::text,2,'0')
from bp04_new_sites s cross join lateral generate_series(1,256) g(unit_no) where s.site_kind='residential';

insert into game.building_units(unit_ref,building_id,parent_unit_id,unit_name,unit_type,floor_label)
select 'KNG-U-CM'||lpad(s.local_no::text,4,'0')||'-'||lpad(g.unit_no::text,2,'0'),
  s.building_id,null,
  case when s.district_code in ('KLG','KPT') then 'Trade and Logistics Suite '
    when s.district_code='KIN' then 'Industrial Business Unit ' when s.district_code='KMA' then 'Market and Retail Unit '
    when s.district_code in ('KST','KAS') then 'Transport Services Unit ' else 'Office and Commercial Suite ' end||lpad(g.unit_no::text,2,'0'),
  case when s.district_code in ('KLG','KPT') then 'warehouse_bay' when s.district_code='KIN' then 'industrial_unit'
    when s.district_code='KMA' then 'retail_unit' when s.district_code in ('KST','KAS') then 'transport_unit' else 'office_suite' end,
  'Level '||lpad(ceil(g.unit_no/2.0)::integer::text,2,'0')
from bp04_new_sites s cross join lateral generate_series(1,20) g(unit_no) where s.site_kind='commercial';
