
begin;

-- Canonical natural names for Kingswell's current physical and commercial entities.
-- Stable IDs, references, ownership, occupancy, employment and geometry are unchanged.

create temporary table kingswell_road_names(code text primary key, canonical_name text not null) on commit drop;
insert into kingswell_road_names(code,canonical_name) values
('KNG-BR01','Bellview Bridge'),
('KNG-BR02','Carter Bridge'),
('KNG-BR03','Millbrook Bridge'),
('KNG-L-KAS01','Ford Street'),
('KNG-L-KAS02','Ashdown Road'),
('KNG-L-KCB01','Briar Lane'),
('KNG-L-KCB02','Crown Avenue'),
('KNG-L-KCI01','Elm Street'),
('KNG-L-KCI02','Hawthorn Close'),
('KNG-L-KDW01','Kingsley Drive'),
('KNG-L-KDW02','Millfield Road'),
('KNG-L-KED01','Orchard Way'),
('KNG-L-KED02','Rosewood Crescent'),
('KNG-L-KIN01','St James Street'),
('KNG-L-KIN02','Victoria Avenue'),
('KNG-L-KLG01','Westbrook Road'),
('KNG-L-KLG02','Church Lane'),
('KNG-L-KMA01','Station Approach'),
('KNG-L-KMA02','Market Lane'),
('KNG-L-KMX01','Harper Street'),
('KNG-L-KMX02','Bennett Road'),
('KNG-L-KNA01','Park View Drive'),
('KNG-L-KNA02','Meadow Crescent'),
('KNG-L-KPT01','Brook Street'),
('KNG-L-KPT02','Queens Road'),
('KNG-L-KST01','Mason Street'),
('KNG-L-KST02','Linden Avenue'),
('KNG-R001','Kingswell Ring Road'),
('KNG-R002','Civic Boulevard'),
('KNG-R003','Northgate Avenue'),
('KNG-R004','University Road'),
('KNG-R005','Foundry Boulevard'),
('KNG-R006','Harbour Parkway'),
('KNG-R007','Terminal Way'),
('KNG-R008','Airport Expressway'),
('KNG-R009','Port Access Road'),
('KNG-R010','Westhaven Road'),
('KNG-R011','Cedar Avenue'),
('KNG-R012','Assembly Avenue'),
('KNG-R013','Exchange Street'),
('KNG-R014','Campus Drive'),
('KNG-R015','Railway Road'),
('KNG-R016','Market Street'),
('KNG-R017','Works Road'),
('KNG-R018','Freightway'),
('KNG-R019','Dock Road'),
('KNG-R020','Riverside Drive'),
('KNG-R021','Aerodrome Road'),
('KNG-R022','Civic Square Approach'),
('KNG-R023','Merchants Lane'),
('KNG-R024','Harbour View Road'),
('KNG-SL-KAS01','Orchard Mews'),
('KNG-SL-KAS02','Dunstan Lane'),
('KNG-SL-KCB01','Foundry Yard'),
('KNG-SL-KCB02','Dockside Mews'),
('KNG-SL-KCI01','Station Mews'),
('KNG-SL-KCI02','Pine Yard'),
('KNG-SL-KDW01','Market Yard'),
('KNG-SL-KDW02','Harbour Mews'),
('KNG-SL-KED01','Kingsway Service Road'),
('KNG-SL-KED02','Railway Mews'),
('KNG-SL-KIN01','West Yard'),
('KNG-SL-KIN02','Northfield Mews'),
('KNG-SL-KLG01','Briar Close'),
('KNG-SL-KLG02','Exchange Mews'),
('KNG-SL-KMA01','Civic Lane'),
('KNG-SL-KMA02','Assembly Lane'),
('KNG-SL-KMX01','Willow Mews'),
('KNG-SL-KMX02','Old Mill Lane'),
('KNG-SL-KNA01','Riverside Mews'),
('KNG-SL-KNA02','Terminal Road'),
('KNG-SL-KPT01','Freight Yard'),
('KNG-SL-KPT02','Merchants Mews'),
('KNG-SL-KST01','Ironworks Lane'),
('KNG-SL-KST02','Parkside Lane');

do $$
declare v_expected integer; v_actual integer; v_unique integer;
begin
  select count(*) into v_expected from game.roads;
  select count(*) into v_actual from kingswell_road_names;
  select count(distinct game.normalise_entity_name(canonical_name)) into v_unique from kingswell_road_names;
  if v_expected<>75 or v_actual<>v_expected or v_unique<>v_expected then
    raise exception 'Road naming manifest mismatch: roads %, mappings %, unique names %',v_expected,v_actual,v_unique;
  end if;
end $$;

-- Keep an immutable record of each changed canonical label.
insert into game.canonical_name_corrections(
 entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,correction_reason,migration_ref
)
select 'road',r.id,coalesce(r.code,r.id::text),'official_name',r.official_name,m.canonical_name,
 'Replaced mechanical or generic seed labels with distinct natural street and bridge names.',
 '20261121350000_kingswell_natural_entity_naming'
from game.roads r join kingswell_road_names m on m.code=r.code
where r.official_name is distinct from m.canonical_name;

update game.roads r
set name=m.canonical_name,official_name=m.canonical_name,name_origin='fictional_gazetteer'
from kingswell_road_names m
where m.code=r.code
  and (r.name is distinct from m.canonical_name or r.official_name is distinct from m.canonical_name);

-- Refresh current address projections after the gazetteer rename.
update game.properties p
set address_line=concat_ws(', ',concat_ws(' ',p.street_number,r.official_name),n.name,d.name,'Kingswell','Asterfell',p.postal_code)
from game.roads r,game.neighbourhoods n,game.districts d
where p.road_id=r.id and p.neighbourhood_id=n.id and p.district_id=d.id;

update game.property_addresses a
set street_name=r.official_name,
    formatted_address=concat_ws(', ',concat_ws(' ',a.street_number,r.official_name),a.neighbourhood_name,a.district_name,'Kingswell','Asterfell',a.postal_code)
from game.properties p join game.roads r on r.id=p.road_id
where a.property_id=p.id;

-- Use real street addresses as the unique public-facing property identity.
insert into game.canonical_name_corrections(
 entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,correction_reason,migration_ref
)
select 'property',p.id,p.property_ref,'property_name',p.property_name,
 concat_ws(' ',p.street_number,r.official_name),
 'Replaced numbered parcel placeholders with the actual unique street address as the property display name.',
 '20261121350000_kingswell_natural_entity_naming'
from game.properties p join game.roads r on r.id=p.road_id
where p.property_name is distinct from concat_ws(' ',p.street_number,r.official_name);

update game.properties p
set property_name=concat_ws(' ',p.street_number,r.official_name)
from game.roads r
where r.id=p.road_id
  and p.property_name is distinct from concat_ws(' ',p.street_number,r.official_name);

do $$
declare v_total integer; v_distinct integer;
begin
 select count(*),count(distinct game.normalise_entity_name(property_name)) into v_total,v_distinct from game.properties;
 if v_total<>v_distinct then raise exception 'Property address-derived names collide: % rows, % unique',v_total,v_distinct; end if;
end $$;

-- Building names are named from the property's real street address and actual use.
insert into game.canonical_name_corrections(
 entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,correction_reason,migration_ref
)
select 'building',b.id,b.building_ref,'name',b.name,
 concat_ws(' ',p.street_number,r.official_name,
   case
    when b.building_type ilike '%residential%' or b.building_type ilike '%apartment%' then 'Apartments'
    when b.building_type ilike '%industrial%' or b.building_type ilike '%factory%' then 'Works'
    when b.building_type ilike '%warehouse%' or b.building_type ilike '%logistic%' then 'Warehouse'
    when b.building_type ilike '%aviation%' or b.building_type ilike '%terminal%' then 'Terminal'
    when b.building_type ilike '%maritime%' or b.building_type ilike '%port%' then 'Quay'
    when b.building_type ilike '%institution%' or b.building_type ilike '%civic%' then 'House'
    else 'Building'
   end),
 'Replaced mechanically numbered building labels with a unique address-based building name.',
 '20261121350000_kingswell_natural_entity_naming'
from game.buildings b join game.properties p on p.id=b.property_id
join game.roads r on r.id=p.road_id
where b.name is distinct from concat_ws(' ',p.street_number,r.official_name,
   case
    when b.building_type ilike '%residential%' or b.building_type ilike '%apartment%' then 'Apartments'
    when b.building_type ilike '%industrial%' or b.building_type ilike '%factory%' then 'Works'
    when b.building_type ilike '%warehouse%' or b.building_type ilike '%logistic%' then 'Warehouse'
    when b.building_type ilike '%aviation%' or b.building_type ilike '%terminal%' then 'Terminal'
    when b.building_type ilike '%maritime%' or b.building_type ilike '%port%' then 'Quay'
    when b.building_type ilike '%institution%' or b.building_type ilike '%civic%' then 'House'
    else 'Building'
   end);

update game.buildings b
set name=concat_ws(' ',p.street_number,r.official_name,
   case
    when b.building_type ilike '%residential%' or b.building_type ilike '%apartment%' then 'Apartments'
    when b.building_type ilike '%industrial%' or b.building_type ilike '%factory%' then 'Works'
    when b.building_type ilike '%warehouse%' or b.building_type ilike '%logistic%' then 'Warehouse'
    when b.building_type ilike '%aviation%' or b.building_type ilike '%terminal%' then 'Terminal'
    when b.building_type ilike '%maritime%' or b.building_type ilike '%port%' then 'Quay'
    when b.building_type ilike '%institution%' or b.building_type ilike '%civic%' then 'House'
    else 'Building'
   end)
from game.properties p join game.roads r on r.id=p.road_id
where p.id=b.property_id;

-- Natural, sector-appropriate trading names. The surname bank is drawn from
-- real-world surname forms; the business descriptors reflect the actual trade.
create temporary table kingswell_business_name_map on commit drop as
with surname_bank as (
 select array[
 'Smith','Johnson','Williams','Brown','Jones','Miller','Davis','Garcia','Rodriguez','Wilson',
 'Martinez','Anderson','Taylor','Thomas','Hernandez','Moore','Martin','Jackson','Thompson','White',
 'Lopez','Lee','Gonzalez','Harris','Clark','Lewis','Robinson','Walker','Perez','Hall',
 'Young','Allen','Sanchez','Wright','King','Scott','Green','Baker','Adams','Nelson',
 'Hill','Ramirez','Campbell','Mitchell','Roberts','Carter','Phillips','Evans','Turner','Torres',
 'Parker','Collins','Edwards','Stewart','Flores','Morris','Nguyen','Murphy','Rivera','Cook',
 'Rogers','Morgan','Peterson','Cooper','Reed','Bailey','Bell','Gomez','Kelly','Howard',
 'Ward','Cox','Diaz','Richardson','Wood','Watson','Brooks','Bennett','Gray','James',
 'Reyes','Cruz','Hughes','Price','Myers','Long','Foster','Sanders','Ross','Morales',
 'Powell','Sullivan','Russell','Ortiz','Jenkins','Gutierrez','Perry','Butler','Barnes','Fisher',
 'Henderson','Coleman','Simmons','Patterson','Jordan','Reynolds','Hamilton','Graham','Kim','Gonzales',
 'Alexander','Ramos','Wallace','Griffin','West','Cole','Hayes','Chavez','Gibson','Bryant',
 'Ellis','Stevens','Murray','Ford','Marshall','Owens','Harrison','Ruiz','Kennedy','Wells',
 'Alvarez','Woods','Mendoza','Castillo','Olson','Webb','Washington','Tucker','Freeman','Burns',
 'Henry','Vasquez','Snyder','Simpson','Crawford','Jimenez','Porter','Mason','Shaw','Gordon',
 'Wagner','Hunter','Romero','Hicks','Dixon','Hunt','Palmer','Robertson','Black','Holmes',
 'Stone','Meyer','Boyd','Mills','Warren','Fox','Rose'
 ]::text[] surnames
),
ranked as (
 select bp.organisation_id,bp.business_number,bp.ownership_form,bp.sector,bp.subsector,
  row_number() over(partition by bp.sector,bp.subsector order by bp.business_number)::integer as group_rank
 from game.business_profiles bp
),
named as (
 select x.*,
  (select surnames[((x.group_rank-1)%array_length(surnames,1))+1] from surname_bank) as surname,
  case
   when x.sector='financial_services' then case when x.group_rank<=168 then 'Capital' else 'Finance' end
   when x.sector='import_export' then case when x.group_rank<=168 then 'International Trading' else 'Mercantile' end
   when x.sector='logistics_warehousing' then case when x.group_rank<=168 then 'Freight' else 'Haulage' end
   when x.sector='transport_services' then 'Transport'
   when x.sector='manufacturing' then 'Engineering'
   when x.sector='wholesale_trade' then 'Wholesale'
   when x.sector='retail' then 'Stores'
   when x.sector='hospitality_entertainment' then 'Hospitality'
   when x.sector='professional_services' then 'Consulting'
   when x.sector='technology_media' then 'Technologies'
   when x.sector='construction_property' then 'Developments'
   when x.sector='property_management' then 'Property Management'
   when x.subsector='bar_and_social_venue' then 'Public House'
   when x.subsector='fitness_and_wellness' then 'Fitness Club'
   when x.subsector='grocery_and_convenience' then 'Grocers'
   when x.subsector='hair_and_beauty' then 'Hair Studio'
   when x.subsector='hardware_and_home' then 'Hardware'
   when x.subsector='laundry_and_cleaning' then 'Laundry'
   when x.subsector='personal_and_community_services' then 'Community Services'
   when x.subsector='pet_and_household_services' then 'Pet Supplies'
   when x.subsector='pharmacy_and_health_retail' then 'Pharmacy'
   when x.subsector='restaurant_and_takeaway' then 'Kitchen'
   when x.subsector='specialist_food_shop' then 'Fine Foods'
   when x.subsector='electronics_and_device_repair' then 'Electronics'
   when x.subsector='family_health_clinic' then 'Medical Clinic'
   when x.subsector='childcare_and_learning' then 'Nursery'
   when x.subsector='cafe_and_bakery' then 'Cafe'
   when x.subsector='books_and_stationery' then 'Books'
   else 'Services'
  end as descriptor
 from ranked x
)
select organisation_id,business_number,
 surname||' '||descriptor||
 case when group_rank>168 then ' '||case when group_rank>336 then 'Group' else 'Company' end else '' end as trading_name,
 ownership_form
from named;

do $$
declare v_total integer; v_unique integer;
begin
 select count(*),count(distinct game.normalise_entity_name(trading_name)) into v_total,v_unique from kingswell_business_name_map;
 if v_total<>1452 or v_total<>v_unique then
   raise exception 'Business name manifest failed: rows %, unique %',v_total,v_unique;
 end if;
end $$;

insert into game.canonical_name_corrections(
 entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,correction_reason,migration_ref
)
select 'business',bp.organisation_id,bp.business_number,'trading_name',bp.trading_name,m.trading_name,
 'Replaced formulaic generated business labels with distinct natural surname-and-trade names.',
 '20261121350000_kingswell_natural_entity_naming'
from game.business_profiles bp join kingswell_business_name_map m on m.organisation_id=bp.organisation_id
where bp.trading_name is distinct from m.trading_name;

update game.business_profiles bp
set trading_name=m.trading_name,updated_at=now()
from kingswell_business_name_map m
where m.organisation_id=bp.organisation_id
 and bp.trading_name is distinct from m.trading_name;

-- Legal names are independently identifiable and use the correct legal form.
insert into game.canonical_name_corrections(
 entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,correction_reason,migration_ref
)
select 'organisation',o.id,o.organisation_ref,'name',o.name,
 m.trading_name||case bp.ownership_form
  when 'private_limited' then ' Limited'
  when 'public_company' then ' Public Limited Company'
  when 'partnership' then ' Partnership'
  when 'family_enterprise' then ' Family Enterprise'
  when 'sole_trader' then ' Trading Company'
  else ' Group Limited'
 end,
 'Replaced repetitive generated legal entity labels with distinct legal names linked to each independent trading identity.',
 '20261121350000_kingswell_natural_entity_naming'
from game.organisations o
join kingswell_business_name_map m on m.organisation_id=o.id
join game.business_profiles bp on bp.organisation_id=o.id
where o.name is distinct from (m.trading_name||case bp.ownership_form
  when 'private_limited' then ' Limited'
  when 'public_company' then ' Public Limited Company'
  when 'partnership' then ' Partnership'
  when 'family_enterprise' then ' Family Enterprise'
  when 'sole_trader' then ' Trading Company'
  else ' Group Limited' end);

update game.organisations o
set name=m.trading_name||case bp.ownership_form
  when 'private_limited' then ' Limited'
  when 'public_company' then ' Public Limited Company'
  when 'partnership' then ' Partnership'
  when 'family_enterprise' then ' Family Enterprise'
  when 'sole_trader' then ' Trading Company'
  else ' Group Limited'
 end,
 updated_at=now()
from kingswell_business_name_map m
join game.business_profiles bp on bp.organisation_id=m.organisation_id
where o.id=m.organisation_id;

-- Every site is individually identifiable by its organisation and actual premises.
insert into game.canonical_name_corrections(
 entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,correction_reason,migration_ref
)
select 'site',ol.id,ol.site_ref,'site_name',ol.site_name,
 concat_ws(' - ',o.name,p.property_name),
 'Named each operating site using its legal organisation and unique premises identity.',
 '20261121350000_kingswell_natural_entity_naming'
from game.organisation_locations ol
join game.organisations o on o.id=ol.organisation_id
join game.properties p on p.id=ol.property_id
where ol.site_name is distinct from concat_ws(' - ',o.name,p.property_name);

update game.organisation_locations ol
set site_name=concat_ws(' - ',o.name,p.property_name)
from game.organisations o,game.properties p
where o.id=ol.organisation_id and p.id=ol.property_id;

-- Synchronise live site/property dossiers; event and historical snapshots are intentionally untouched.
update game.organisation_site_dossiers sd
set physical_address=p.address_line,
    building_name=b.name,
    updated_at=now()
from game.properties p
left join game.buildings b on b.property_id=p.id
where sd.property_id=p.id;

update game.property_profiles pp
set map_label=p.property_name,updated_at=now()
from game.properties p
where pp.property_id=p.id
 and pp.map_label is distinct from p.property_name;

-- Verify core canonical name domains before commit.
do $$
declare v_count integer; v_distinct integer;
begin
 select count(*),count(distinct game.normalise_entity_name(official_name)) into v_count,v_distinct from game.roads;
 if v_count<>75 or v_count<>v_distinct then raise exception 'Road uniqueness verification failed'; end if;
 select count(*),count(distinct game.normalise_entity_name(property_name)) into v_count,v_distinct from game.properties;
 if v_count<>656 or v_count<>v_distinct then raise exception 'Property uniqueness verification failed'; end if;
 select count(*),count(distinct game.normalise_entity_name(name)) into v_count,v_distinct from game.buildings;
 if v_count<>656 or v_count<>v_distinct then raise exception 'Building uniqueness verification failed'; end if;
 select count(*),count(distinct game.normalise_entity_name(trading_name)) into v_count,v_distinct from game.business_profiles;
 if v_count<>1452 or v_count<>v_distinct then raise exception 'Business uniqueness verification failed'; end if;
 select count(*),count(distinct game.normalise_entity_name(name)) into v_count,v_distinct from game.organisations;
 if v_count<>1490 or v_count<>v_distinct then raise exception 'Organisation uniqueness verification failed'; end if;
end $$;

commit;
