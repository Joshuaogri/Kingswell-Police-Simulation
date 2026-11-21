
-- Activate neighbourhood retail at tower podiums and in existing Riverside mixed-use premises.
-- These are extensions to existing canonical units, not duplicate properties or premises.

update game.building_units u
set unit_type='retail_unit',
    unit_name='Ground-floor neighbourhood retail unit '||right(u.unit_ref,3),
    floor_label='Ground'
from game.buildings b
where b.id=u.building_id and b.building_ref like 'KNG-B-RH%'
  and right(u.unit_ref,3) in ('001','002');

update game.building_unit_profiles up
set floor_number=0,suite_code=(select unit_ref from game.building_units u where u.id=up.building_unit_id),
    use_class='retail',internal_area_sqm=110,occupancy_capacity=18,
    bedroom_count=null,bathroom_count=1,security_zone='commercial_podium',
    unit_description='Ground-floor neighbourhood shopfront integrated with the residential tower lobby and shared building services.'
where up.building_unit_id in (
 select u.id from game.building_units u join game.buildings b on b.id=u.building_id
 where b.building_ref like 'KNG-B-RH%' and right(u.unit_ref,3) in ('001','002')
);

update game.building_unit_profiles up
set use_class='neighbourhood_mixed_use',internal_area_sqm=160,occupancy_capacity=20,
    unit_description='Riverside mixed-use premises with a street-facing commercial frontage and upper/shared residential or service use.'
where up.building_unit_id in (
 select u.id from game.building_units u join game.buildings b on b.id=u.building_id
 join game.properties p on p.id=b.property_id
 where p.neighbourhood_id in (select id from game.neighbourhoods where code in ('KMX-01','KMX-02'))
 and u.unit_type='mixed_use'
);

update game.building_profiles bp
set floor_directory=jsonb_set(bp.floor_directory,'{0,primary_use}','"residential_lobby_and_neighbourhood_retail"'::jsonb,true),
    building_description=bp.building_description||' The ground floor includes two neighbourhood retail premises alongside resident access and building services.'
from game.buildings b
where b.id=bp.building_id and b.building_ref like 'KNG-B-RH%';

create temporary table bp04_neighbourhood_business_units on commit drop as
with tower_shops as (
 select n.code neighbourhood_code,n.name neighbourhood_name,d.code district_code,p.id property_id,u.id unit_id,u.unit_ref
 from game.building_units u join game.buildings b on b.id=u.building_id
 join game.properties p on p.id=b.property_id
 join game.neighbourhoods n on n.id=p.neighbourhood_id
 join game.districts d on d.id=p.district_id
 where b.building_ref like 'KNG-B-RH%' and right(u.unit_ref,3) in ('001','002')
),
riverside_shops as (
 select n.code neighbourhood_code,n.name neighbourhood_name,d.code district_code,p.id property_id,u.id unit_id,u.unit_ref
 from game.building_units u join game.buildings b on b.id=u.building_id
 join game.properties p on p.id=b.property_id
 join game.neighbourhoods n on n.id=p.neighbourhood_id
 join game.districts d on d.id=p.district_id
 where n.code in ('KMX-01','KMX-02') and u.unit_type='mixed_use'
)
select row_number() over(order by neighbourhood_code,unit_ref)::integer seq,
 neighbourhood_code,neighbourhood_name,district_code,property_id,unit_id,unit_ref
from (select * from tower_shops union all select * from riverside_shops) q;

create temporary table bp04_neighbourhood_business_seed on commit drop as
select s.*,
 'KWORG-BIZ-'||lpad((1100+seq)::text,6,'0') organisation_ref,
 'AF-BIZ-'||lpad((1100+seq)::text,6,'0') business_number,
 case ((seq-1)%16)
  when 0 then 'grocery_and_convenience'
  when 1 then 'pharmacy_and_health_retail'
  when 2 then 'cafe_and_bakery'
  when 3 then 'restaurant_and_takeaway'
  when 4 then 'hair_and_beauty'
  when 5 then 'laundry_and_cleaning'
  when 6 then 'electronics_and_device_repair'
  when 7 then 'fitness_and_wellness'
  when 8 then 'childcare_and_learning'
  when 9 then 'books_and_stationery'
  when 10 then 'hardware_and_home'
  when 11 then 'family_health_clinic'
  when 12 then 'specialist_food_shop'
  when 13 then 'bar_and_social_venue'
  when 14 then 'pet_and_household_services'
  else 'personal_and_community_services' end subsector
from bp04_neighbourhood_business_units s;

insert into game.organisations(organisation_ref,name,organisation_type,status)
select organisation_ref,neighbourhood_name||' '||
 case subsector
  when 'grocery_and_convenience' then 'Grocers'
  when 'pharmacy_and_health_retail' then 'Community Pharmacy'
  when 'cafe_and_bakery' then 'Coffee and Bakehouse'
  when 'restaurant_and_takeaway' then 'Kitchen and Dining'
  when 'hair_and_beauty' then 'Hair and Beauty Studio'
  when 'laundry_and_cleaning' then 'Laundry and Cleaners'
  when 'electronics_and_device_repair' then 'Electronics Repair'
  when 'fitness_and_wellness' then 'Fitness and Wellness'
  when 'childcare_and_learning' then 'Learning and Childcare'
  when 'books_and_stationery' then 'Books and Stationery'
  when 'hardware_and_home' then 'Hardware and Home'
  when 'family_health_clinic' then 'Family Health Clinic'
  when 'specialist_food_shop' then 'Specialist Food Hall'
  when 'bar_and_social_venue' then 'Bar and Social House'
  when 'pet_and_household_services' then 'Pet and Household Care'
  else 'Personal Services' end||' '||lpad(seq::text,3,'0'),
 'business','active'
from bp04_neighbourhood_business_seed;

insert into game.business_profiles(
 organisation_id,business_number,trading_name,sector,subsector,business_size,ownership_form,
 incorporation_date,estimated_employee_count,annual_turnover_band,import_export_activity,
 principal_goods_categories,service_description,business_hours,cash_handling_profile,
 security_arrangements,trade_profile,fictional_website_domain,profile_notes
)
select o.id,s.business_number,o.name,'neighbourhood_services',s.subsector,
 case when s.seq%5=0 then 'small' else 'micro' end,
 case when s.seq%3=0 then 'partnership' when s.seq%7=0 then 'family_enterprise' else 'sole_trader' end,
 date '1995-01-01'+((s.seq*23)%10500)::integer,
 case when s.seq%5=0 then 5+(s.seq%10) else 2+(s.seq%6) end,
 case when s.seq%5=0 then 'AFC 1 million to 10 million' else 'Below AFC 1 million' end,
 'none',
 case s.subsector
  when 'grocery_and_convenience' then array['groceries','household_essentials']
  when 'pharmacy_and_health_retail' then array['non_prescription_health_goods','personal_care']
  when 'cafe_and_bakery' then array['coffee','baked_goods','light_meals']
  when 'restaurant_and_takeaway' then array['prepared_food','beverages']
  when 'hair_and_beauty' then array['personal_care_services']
  when 'laundry_and_cleaning' then array['laundry','garment_care']
  when 'electronics_and_device_repair' then array['electronics','device_repair']
  when 'fitness_and_wellness' then array['fitness','wellness_services']
  when 'childcare_and_learning' then array['childcare','learning_services']
  when 'books_and_stationery' then array['books','stationery']
  when 'hardware_and_home' then array['hardware','home_goods']
  when 'family_health_clinic' then array['primary_health_services']
  when 'specialist_food_shop' then array['specialist_food','fresh_produce']
  when 'bar_and_social_venue' then array['food','beverages','social_entertainment']
  when 'pet_and_household_services' then array['pet_care','household_services']
  else array['personal_services','community_services'] end,
 case s.subsector
  when 'grocery_and_convenience' then 'A local convenience grocer serving residents and passing neighbourhood foot traffic.'
  when 'pharmacy_and_health_retail' then 'A neighbourhood pharmacy and personal-health retail outlet.'
  when 'cafe_and_bakery' then 'A café and bakery serving breakfast, refreshments and daily baked goods.'
  when 'restaurant_and_takeaway' then 'A small restaurant and takeaway serving residents, workers and visitors.'
  when 'hair_and_beauty' then 'A local hair, grooming and beauty service business.'
  when 'laundry_and_cleaning' then 'A neighbourhood laundry, dry-cleaning and garment-care service.'
  when 'electronics_and_device_repair' then 'An electronics retailer and small-device repair workshop.'
  when 'fitness_and_wellness' then 'A local gym, studio or wellness service.'
  when 'childcare_and_learning' then 'A small childcare and supplementary learning provider.'
  when 'books_and_stationery' then 'A bookshop and stationery supplier serving students and households.'
  when 'hardware_and_home' then 'A neighbourhood hardware and home-maintenance shop.'
  when 'family_health_clinic' then 'A small private family-health clinic and appointment-based care provider.'
  when 'specialist_food_shop' then 'A specialist food shop supplying fresh and prepared food.'
  when 'bar_and_social_venue' then 'A neighbourhood bar and social venue with evening trading.'
  when 'pet_and_household_services' then 'A pet-care and household support business.'
  else 'A small personal-service business serving the local community.' end,
 jsonb_build_object('monday_saturday','07:00-20:00','sunday','09:00-16:00',
  'evening_trade',s.subsector in ('restaurant_and_takeaway','bar_and_social_venue')),
 'low_to_moderate',
 jsonb_build_object('shopfront','street_facing','cctv','site_specific','alarm','site_specific'),
 jsonb_build_object('business_role','neighbourhood_service','neighbourhood',s.neighbourhood_code,
  'serves_residential_population',true,'trade_hub_dependency',false),
 'www.'||lower(replace(s.organisation_ref,'KWORG-',''))||'.kingswell.asterfell',
 'Fictional neighbourhood-scale business. Employee NPCs, customer visits, supplier relationships and daily transactions are generated by later simulation systems.'
from bp04_neighbourhood_business_seed s
join game.organisations o on o.organisation_ref=s.organisation_ref;

insert into game.organisation_locations(
 organisation_id,property_id,location_role,valid_from,building_unit_id,is_primary_location,
 occupancy_status,site_name,operating_hours,site_details,lease_reference,lease_type,rent_band,lease_details
)
select o.id,s.property_id,'tenant',date '2020-01-01',s.unit_id,true,'active',o.name,
 jsonb_build_object('monday_saturday','07:00-20:00','sunday','09:00-16:00'),
 jsonb_build_object('business_number',s.business_number,'unit_ref',s.unit_ref,
  'neighbourhood',s.neighbourhood_code,'site_function','neighbourhood_shop_or_service'),
 'KW-LEASE-'||right(s.business_number,6),'small_commercial_lease','small_business',
 jsonb_build_object('lease_basis','fictional_game_record','premises_type','tower_podium_or_existing_riverside_mixed_use')
from bp04_neighbourhood_business_seed s
join game.organisations o on o.organisation_ref=s.organisation_ref;
