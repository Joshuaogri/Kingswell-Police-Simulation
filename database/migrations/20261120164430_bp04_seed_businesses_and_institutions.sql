
create temporary table bp04_special_orgs(
 organisation_ref text primary key,name text not null,organisation_type text not null,district_code text not null,role_group text not null
) on commit drop;
insert into bp04_special_orgs values
('KWORG-EST-01','Kingswell Metropolitan Estates Group','property_holding_company','KCB','estate'),
('KWORG-EST-02','Asterfell Crown Commercial Properties','property_holding_company','KCB','estate'),
('KWORG-EST-03','Westhaven Residential Holdings','property_holding_company','KDW','estate'),
('KWORG-EST-04','Northgate Urban Living Group','property_holding_company','KNA','estate'),
('KWORG-EST-05','Riverside Development Partners','property_holding_company','KMX','estate'),
('KWORG-EST-06','Foundry Industrial Estates','property_holding_company','KIN','estate'),
('KWORG-EST-07','Eastmarch Logistics Parks','property_holding_company','KLG','estate'),
('KWORG-EST-08','South Harbour Property Company','property_holding_company','KPT','estate'),
('KWORG-EST-09','Kingswell Retail and Market Estates','property_holding_company','KMA','estate'),
('KWORG-EST-10','Capital District Property Trust','property_holding_company','KCI','estate'),
('KWORG-EST-11','Kingswell Airport Property Holdings','property_holding_company','KAS','estate'),
('KWORG-EST-12','Central Terminal Property Group','property_holding_company','KST','estate'),
('KWORG-PUB-01','Asterfell Public Estates Authority','public_estate_authority','KCI','public'),
('KWORG-PUB-02','Parliament of Asterfell','legislature','KCI','public'),
('KWORG-PUB-03','Office of the President of Asterfell','executive_office','KCI','public'),
('KWORG-PUB-04','Asterfell Cabinet Secretariat','government_department','KCI','public'),
('KWORG-PUB-05','Asterfell Ministry of Finance','government_ministry','KCI','public'),
('KWORG-PUB-06','Asterfell Ministry of Trade and Industry','government_ministry','KCI','public'),
('KWORG-PUB-07','Asterfell Ministry of Transport and Infrastructure','government_ministry','KCI','public'),
('KWORG-PUB-08','Asterfell Ministry of Justice','government_ministry','KCI','public'),
('KWORG-PUB-09','Asterfell Ministry of Interior and Public Safety','government_ministry','KCI','public'),
('KWORG-PUB-10','Asterfell Ministry of Foreign Affairs','government_ministry','KCI','public'),
('KWORG-PUB-11','Central Bank of Asterfell','central_bank','KCB','public'),
('KWORG-PUB-12','Asterfell Securities and Exchange Commission','financial_regulator','KCB','public'),
('KWORG-PUB-13','Asterfell National Revenue Authority','revenue_authority','KCI','public'),
('KWORG-PUB-14','Asterfell Customs Service','customs_authority','KPT','public'),
('KWORG-PUB-15','Kingswell City Authority','city_government','KCI','public'),
('KWORG-PUB-16','Kingswell Port Authority','port_authority','KPT','public'),
('KWORG-PUB-17','Kingswell Airport Authority','airport_authority','KAS','public'),
('KWORG-PUB-18','Asterfell National Rail Authority','transport_authority','KST','public'),
('KWORG-PUB-19','Kingswell Metropolitan Transit Corporation','public_transport_operator','KST','public'),
('KWORG-PUB-20','Kingswell Metropolitan Hospital','public_hospital','KED','public'),
('KWORG-PUB-21','Kingswell National University','public_university','KED','public'),
('KWORG-PUB-22','Kingswell Fire and Rescue Service','emergency_service','KCI','public'),
('KWORG-PUB-23','Asterfell National Archives','national_archive','KCI','public'),
('KWORG-PUB-24','Asterfell Export Promotion Agency','trade_promotion_agency','KCB','public'),
('KWORG-PUB-25','Asterfell Maritime and Trade Commission','trade_authority','KPT','public'),
('KWORG-PUB-26','Asterfell Public Broadcasting Service','public_broadcaster','KCB','public');
insert into game.organisations(organisation_ref,name,organisation_type,status)
select organisation_ref,name,organisation_type,'active' from bp04_special_orgs;

create temporary table bp04_business_seed on commit drop as
with raw as (
 select n,case when n<=150 then 'financial_services' when n<=280 then 'import_export'
  when n<=450 then 'logistics_warehousing' when n<=550 then 'transport_services'
  when n<=650 then 'manufacturing' when n<=750 then 'wholesale_trade'
  when n<=850 then 'retail' when n<=930 then 'hospitality_entertainment'
  when n<=990 then 'professional_services' when n<=1040 then 'technology_media'
  when n<=1080 then 'construction_property' else 'property_management' end sector
 from generate_series(1,1100) n
),
assigned as (
 select r.*,
  case when sector='financial_services' and n<=100 then 'KCB' when sector='financial_services' then 'KCI'
   when sector='import_export' and n<=230 then 'KPT' when sector='import_export' then 'KLG'
   when sector='logistics_warehousing' and n<=420 then 'KLG' when sector='logistics_warehousing' then 'KPT'
   when sector='transport_services' and n<=500 then 'KST' when sector='transport_services' then 'KAS'
   when sector in ('manufacturing','construction_property') then 'KIN'
   when sector='wholesale_trade' then 'KMA' when sector='retail' and n<=820 then 'KMA' when sector='retail' then 'KCB'
   when sector='hospitality_entertainment' and n<=880 then 'KST'
   when sector='hospitality_entertainment' and n<=900 then 'KMA'
   when sector='hospitality_entertainment' then 'KPT'
   when sector in ('professional_services','property_management') then 'KCI'
   when sector='technology_media' then 'KCB' else 'KCB' end district_code
 from raw r
)
select n,'KWORG-BIZ-'||lpad(n::text,6,'0') organisation_ref,
 case sector
  when 'financial_services' then (array['Kingswell Meridian Capital','Asterfell Crown Banking','Harbourlight Financial','Northstar Insurance','Civic Exchange Investment'])[1+((n*7)%5)]
  when 'import_export' then (array['South Coast Import Export','Asterfell Global Trade','Harbour Gate Commodities','Meridian International Trading','Eastmarch Export House'])[1+((n*7)%5)]
  when 'logistics_warehousing' then (array['Eastmarch Freight','Kingswell Distribution','Asterfell Cargo Logistics','Rivergate Warehousing','Crownline Supply Chain'])[1+((n*7)%5)]
  when 'transport_services' then (array['Kingswell Mobility','Asterfell Transit Services','Capital Coach and Fleet','Harbour Link Transport','AeroRoad Passenger Services'])[1+((n*7)%5)]
  when 'manufacturing' then (array['Foundry Works','Asterfell Industrial Products','Kingswell Engineering','Ironvale Manufacturing','Meridian Components'])[1+((n*7)%5)]
  when 'wholesale_trade' then (array['Grand Market Wholesale','Merchants Exchange Supply','Kingswell Bulk Trade','Asterfell Food and Goods','Market Ward Distributors'])[1+((n*7)%5)]
  when 'retail' then (array['Kingswell Retail House','Crown Arcade Stores','Riverside Merchants','Asterfell Department Stores','Exchange Street Retail'])[1+((n*7)%5)]
  when 'hospitality_entertainment' then (array['Crown Hotels and Leisure','Kingswell Live Entertainment','Harbourfront Hospitality','Asterfell Screen and Stage','Riverside Dining Group'])[1+((n*7)%5)]
  when 'professional_services' then (array['Capital Advisory Partners','Kingswell Legal and Business','Asterfell Consulting Group','Meridian Audit and Assurance','Civic Quarter Chambers'])[1+((n*7)%5)]
  when 'technology_media' then (array['Asterfell Digital Systems','Kingswell Media Network','Meridian Technology Works','Capital Data Services','Northstar Communications'])[1+((n*7)%5)]
  when 'construction_property' then (array['Kingswell Urban Construction','Foundry Build and Engineering','Asterfell Civil Works','Capital Property Development','Eastmarch Infrastructure'])[1+((n*7)%5)]
  else (array['Kingswell Estate Management','Asterfell Property Services','Capital Asset Managers','Meridian Facilities Group','Crown Property Partners'])[1+((n*7)%5)] end||' '||lpad(n::text,4,'0') name,
 sector,district_code,
 case when n<=40 then 'major_corporate' when n<=180 then 'large' when n<=500 then 'medium' when n<=850 then 'small' else 'micro' end business_size,
 case when n%10=0 then 'public_company' when n%7=0 then 'partnership' when n%5=0 then 'family_enterprise' else 'private_limited' end ownership_form,
 date '1978-01-01'+((n*17)%16500)::integer incorporation_date,
 case when n<=40 then 1200+(n%3800) when n<=180 then 250+(n%750) when n<=500 then 50+(n%200)
  when n<=850 then 10+(n%40) else 2+(n%8) end employee_count,
 case when n<=40 then 'AFC 1 billion and above' when n<=180 then 'AFC 100 million to 1 billion'
  when n<=500 then 'AFC 10 million to 100 million' when n<=850 then 'AFC 1 million to 10 million' else 'Below AFC 1 million' end turnover_band,
 case when sector='import_export' then 'importer_exporter'
  when sector in ('logistics_warehousing','transport_services','financial_services') then 'trade_services'
  when sector='manufacturing' then 'exporter' when sector='wholesale_trade' then 'importer' else 'none' end trade_activity,
 case when sector='financial_services' then array['banking','insurance','capital_markets','payments']
  when sector='import_export' then array['machinery','foodstuffs','consumer_goods','industrial_materials']
  when sector='logistics_warehousing' then array['container_freight','general_cargo','cold_chain','distribution']
  when sector='transport_services' then array['passenger_transport','fleet','freight','urban_mobility']
  when sector='manufacturing' then array['metal_products','machinery','packaging','consumer_goods']
  when sector='wholesale_trade' then array['food','building_materials','consumer_goods','industrial_supplies']
  when sector='retail' then array['household_goods','clothing','electronics','food']
  when sector='hospitality_entertainment' then array['accommodation','food_service','live_events','cinema_and_arts']
  when sector='professional_services' then array['legal','accounting','consulting','engineering']
  when sector='technology_media' then array['software','telecommunications','broadcasting','digital_services']
  when sector='construction_property' then array['construction','civil_engineering','property_development']
  else array['property_management','facilities','commercial_estates'] end goods,
 case sector
  when 'financial_services' then 'Provides banking, insurance, investment, payments or financial-market services to households and businesses.'
  when 'import_export' then 'Trades goods across Asterfell and international markets, using Kingswell port, airport and freight corridors.'
  when 'logistics_warehousing' then 'Provides freight forwarding, warehousing, distribution, inventory handling and supply-chain services.'
  when 'transport_services' then 'Provides passenger, fleet, urban mobility or freight transport services across the capital and national network.'
  when 'manufacturing' then 'Produces, assembles or repairs industrial and consumer goods for domestic and export markets.'
  when 'wholesale_trade' then 'Supplies bulk goods to retailers, institutions, manufacturers and regional distributors.'
  when 'retail' then 'Operates customer-facing shops, department stores, specialist outlets and neighbourhood retail services.'
  when 'hospitality_entertainment' then 'Provides accommodation, food, nightlife, performance, cinema, events and visitor services.'
  when 'professional_services' then 'Provides legal, accounting, engineering, advisory, consulting and corporate support services.'
  when 'technology_media' then 'Provides software, communications, digital infrastructure, broadcasting and media services.'
  when 'construction_property' then 'Provides construction, civil engineering, building maintenance and property development services.'
  else 'Owns, leases, manages and maintains commercial and residential property assets.' end service_description
from assigned;

insert into game.organisations(organisation_ref,name,organisation_type,status)
select organisation_ref,name,'business','active' from bp04_business_seed;

insert into game.business_profiles(
 organisation_id,business_number,trading_name,sector,subsector,business_size,ownership_form,incorporation_date,
 estimated_employee_count,annual_turnover_band,import_export_activity,principal_goods_categories,
 service_description,business_hours,cash_handling_profile,security_arrangements,trade_profile,fictional_website_domain,profile_notes
)
select o.id,'AF-BIZ-'||lpad(b.n::text,6,'0'),b.name,b.sector,replace(b.sector,'_',' '),b.business_size,
 b.ownership_form,b.incorporation_date,b.employee_count,b.turnover_band,b.trade_activity,b.goods,b.service_description,
 jsonb_build_object('monday_friday','08:00-18:00','saturday','09:00-14:00','sunday','closed',
  'sector_variation',case when b.sector in ('logistics_warehousing','transport_services','import_export') then 'extended_or_shift_operations'
   when b.sector='hospitality_entertainment' then 'evening_and_weekend_operations' else 'standard_business_hours' end),
 case when b.sector in ('retail','wholesale_trade','hospitality_entertainment') then 'moderate'
  when b.sector='financial_services' then 'controlled_high_value' else 'low_to_moderate' end,
 jsonb_build_object('intrusion_alarm','site_specific','cctv','business_specific',
  'cash_controls',case when b.sector in ('retail','wholesale_trade','hospitality_entertainment','financial_services') then 'present' else 'not_primary' end,
  'security_provider','not_seeded'),
 jsonb_build_object('sector',b.sector,'trade_activity',b.trade_activity,'principal_goods',to_jsonb(b.goods),
  'capital_city_trade_hub',true,'port_access_relevant',b.sector in ('import_export','logistics_warehousing','wholesale_trade','manufacturing'),
  'airport_access_relevant',b.sector in ('import_export','logistics_warehousing','transport_services'),
  'national_distribution',b.sector in ('logistics_warehousing','transport_services','wholesale_trade')),
 'www.'||lower(replace(b.organisation_ref,'KWORG-',''))||'.kingswell.asterfell',
 'Fictional business identity. Staff, directors, ownership persons, customers, suppliers, contracts and transactions belong to their linked simulation systems.'
from bp04_business_seed b join game.organisations o on o.organisation_ref=b.organisation_ref;

with ranked_businesses as (
 select b.*,o.id organisation_id,row_number() over(partition by b.district_code order by b.n) slot
 from bp04_business_seed b join game.organisations o on o.organisation_ref=b.organisation_ref
),
ranked_units as (
 select d.code district_code,p.id property_id,bu.id unit_id,bu.unit_ref,
  row_number() over(partition by d.code order by p.property_ref,bu.unit_ref) slot
 from game.properties p join game.districts d on d.id=p.district_id
 join game.buildings b on b.property_id=p.id join game.building_units bu on bu.building_id=b.id
 where p.property_ref like 'KNG-P-CM%'
)
insert into game.organisation_locations(
 organisation_id,property_id,location_role,valid_from,valid_to,building_unit_id,is_primary_location,
 occupancy_status,site_name,operating_hours,site_details,lease_reference,lease_type,rent_band,lease_details
)
select b.organisation_id,u.property_id,case when b.n%5=0 then 'owner_occupier' else 'tenant' end,
 b.incorporation_date,null,u.unit_id,true,'active',b.name,
 jsonb_build_object('monday_friday','08:00-18:00','weekend','sector_dependent'),
 jsonb_build_object('unit_ref',u.unit_ref,'business_number','AF-BIZ-'||lpad(b.n::text,6,'0'),'site_function','primary_operating_site','district',b.district_code),
 case when b.n%5=0 then null else 'KW-LEASE-'||lpad(b.n::text,7,'0') end,
 case when b.n%5=0 then null else 'commercial_lease' end,
 case when b.business_size in ('large','major_corporate') then 'premium' when b.business_size='medium' then 'standard' else 'small_business' end,
 jsonb_build_object('lease_basis','fictional_game_record','rent_review','periodic','service_charges','building_specific','deposit','contract_specific')
from ranked_businesses b join ranked_units u on u.district_code=b.district_code and u.slot=b.slot;

with orgs as (
 select s.*,o.id organisation_id,row_number() over(partition by s.district_code order by s.organisation_ref) slot
 from bp04_special_orgs s join game.organisations o on o.organisation_ref=s.organisation_ref
 where s.role_group='public' and s.organisation_ref<>'KWORG-PUB-01'
),
premises as (
 select d.code district_code,p.id property_id,bu.id unit_id,bu.unit_ref,
  row_number() over(partition by d.code order by p.property_ref,bu.unit_ref) slot
 from game.properties p join game.districts d on d.id=p.district_id
 join game.buildings b on b.property_id=p.id join game.building_units bu on bu.building_id=b.id
 where p.property_ref not like 'KNG-P-RH%' and p.property_ref not like 'KNG-P-CM%'
)
insert into game.organisation_locations(
 organisation_id,property_id,location_role,valid_from,building_unit_id,is_primary_location,occupancy_status,site_name,operating_hours,site_details
)
select o.organisation_id,p.property_id,'head_office',date '1990-01-01',p.unit_id,true,'active',o.name,
 jsonb_build_object('monday_friday','08:00-17:00','weekend','closed'),
 jsonb_build_object('institutional_headquarters',true,'district',o.district_code,'unit_ref',p.unit_ref)
from orgs o join premises p on p.district_code=o.district_code and p.slot=o.slot;
