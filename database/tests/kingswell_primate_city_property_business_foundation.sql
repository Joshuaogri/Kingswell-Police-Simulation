-- BP-04 rollback-only primate-city property, building, business, map and game-command regression.
begin;
do $bp04$
declare
 v_person uuid;
 v_officer uuid;
 v_result jsonb;
 v_route uuid;
 v_route_status text;
 v_route_distance integer;
begin
 for v_person in select id from game.neighbourhoods loop
  v_result:=game.get_neighbourhood_property_map((select code from game.neighbourhoods where id=v_person));
  if v_result is null or jsonb_array_length(v_result->'properties')<>(select count(*) from game.properties where neighbourhood_id=v_person) then
   raise exception 'Neighbourhood map coverage failed for %',v_person;
  end if;
 end loop;
 if (select count(*) from game.properties where city_id=(select id from game.cities where code='KNG'))<>656 then
  raise exception 'Kingswell property count must be 656';
 end if;
 if (select count(*) from game.buildings b join game.properties p on p.id=b.property_id where p.city_id=(select id from game.cities where code='KNG'))<>656 then
  raise exception 'Every property must have one canonical building';
 end if;
 if (select count(*) from game.building_units u join game.buildings b on b.id=u.building_id join game.properties p on p.id=b.property_id where p.city_id=(select id from game.cities where code='KNG'))<>26888 then
  raise exception 'Kingswell building-unit count must be 26888';
 end if;
 if (select count(*) from game.properties where property_ref like 'KNG-P-RH%')<>96
  or (select count(*) from game.properties where property_ref like 'KNG-P-CM%')<>80 then
  raise exception 'The residential tower and commercial centre expansion counts are incorrect';
 end if;
 if (select count(*) from game.building_units u join game.buildings b on b.id=u.building_id where b.building_ref like 'KNG-B-RH%' and u.unit_type='residential')<>24384 then
  raise exception 'Residential tower apartment capacity is incorrect';
 end if;
 if (select count(*) from game.building_units u join game.buildings b on b.id=u.building_id where b.building_ref like 'KNG-B-CM%')<>1600 then
  raise exception 'Commercial centre unit count is incorrect';
 end if;
 if (select count(*) from game.property_profiles)<>656
  or (select count(*) from game.building_profiles)<>656
  or (select count(*) from game.building_unit_profiles)<>26888 then
  raise exception 'Detailed property, building or unit dossier coverage is incomplete';
 end if;
 if exists(select 1 from game.properties p left join game.property_profiles x on x.property_id=p.id where x.property_id is null)
  or exists(select 1 from game.buildings b left join game.building_profiles x on x.building_id=b.id where x.building_id is null)
  or exists(select 1 from game.building_units u left join game.building_unit_profiles x on x.building_unit_id=u.id where x.building_unit_id is null) then
  raise exception 'A canonical property/building/unit is missing its one-to-one profile';
 end if;
 if exists(select 1 from game.properties p left join game.property_addresses a on a.property_id=p.id and a.is_primary where a.id is null)
  or exists(select 1 from game.properties p left join game.property_access_points a on a.property_id=p.id and a.is_primary where a.id is null) then
  raise exception 'A property is missing its primary address or access point';
 end if;
 if exists(select 1 from game.property_access_points a
  left join game.road_segments s on s.id=a.road_segment_id
  left join game.road_junctions j on j.id=a.nearest_junction_id
  where s.id is null or j.id is null) then
  raise exception 'A property access point is detached from the road network';
 end if;
 if exists(select 1 from game.properties where x_m<0 or x_m>20000 or y_m<0 or y_m>16000) then
  raise exception 'A property lies outside the Kingswell local grid';
 end if;
 if exists(select 1 from game.properties p join game.properties q on p.id<q.id
  where (p.property_ref like 'KNG-P-RH%' or p.property_ref like 'KNG-P-CM%')
   and sqrt(power(p.x_m-q.x_m,2)+power(p.y_m-q.y_m,2))<60) then
  raise exception 'A new property centre collides with another property centre';
 end if;
 if exists(select 1 from game.properties p left join game.property_interest_records x
  on x.property_id=p.id and x.interest_type='registered_owner' and x.valid_to is null
  group by p.id having count(x.id)<>1) then
  raise exception 'Every property must have exactly one current registered owner';
 end if;
 if (select count(*) from game.business_profiles)<>1452 then
  raise exception 'Business seed must contain 1452 unique businesses';
 end if;
 if (select count(*) from game.business_profiles where sector='neighbourhood_services')<>352 then
  raise exception 'Neighbourhood service business seed is incomplete';
 end if;
 if (select count(*) from game.organisation_locations ol join game.business_profiles bp on bp.organisation_id=ol.organisation_id where ol.valid_to is null)<>1452 then
  raise exception 'Every seeded business must have a current operating site';
 end if;
 if exists(select 1 from game.organisation_locations where building_unit_id is not null and valid_to is null and occupancy_status='active'
  group by building_unit_id having count(*)>1) then
  raise exception 'A building unit has more than one active occupier';
 end if;
 if (select count(*) from game.organisation_locations ol join game.organisations o on o.id=ol.organisation_id
  where o.organisation_ref like 'KWORG-PUB-%' and ol.valid_to is null)<>25 then
  raise exception 'The public institutional site register is incomplete';
 end if;
 if (select count(*) from game.property_interest_records where interest_type='registered_owner' and valid_to is null)<>656 then
  raise exception 'Property title ownership records are incomplete';
 end if;
 if (select count(*) from game.property_interest_records where holder_person_id is not null and holder_organisation_id is not null)<>0 then
  raise exception 'A property interest has two holder identities';
 end if;

 if game.get_property_record('KNG-P-RH0001')->'property'->>'property_ref'<>'KNG-P-RH0001' then
  raise exception 'Property record query did not return the canonical property';
 end if;
 if jsonb_array_length(game.get_property_record('KNG-P-RH0001')->'buildings'->0->'units')<>256 then
  raise exception 'Property record query did not return all tower units';
 end if;
 if game.get_neighbourhood_property_map('KDW-01')->>'property_count'<>'32' then
  raise exception 'Neighbourhood property map did not return the expected property count';
 end if;
 if (select count(*) from game.list_business_directory('logistics_warehousing','KLG',null,500))<>140 then
  raise exception 'Business directory sector/district filter returned the wrong result count';
 end if;
 if (select count(*) from game.list_business_directory('neighbourhood_services',null,null,500))<>352 then
  raise exception 'Neighbourhood services directory does not return all local businesses';
 end if;
 if (select count(*) from game.list_business_directory(null,null,null,500))<>500 then
  raise exception 'Business directory maximum result window is incorrect';
 end if;
 if game.get_business_record('AF-BIZ-000281')->'business'->>'business_number'<>'AF-BIZ-000281' then
  raise exception 'Business record query failed';
 end if;
 if game.get_city_property_summary('KNG')->'totals'->>'properties'<>'656' then
  raise exception 'City property summary is inconsistent';
 end if;

 -- Test actual route calculation from a newly seeded tower and commercial centre.
 select id into v_route from game.road_route_calculations where false;
 v_route:=game.calculate_road_route(
  (select id from game.property_access_points where access_ref='KNG-ACC-RH0001'),
  (select access_point_id from game.police_facilities where facility_ref='KNG-PF-HQ'),
  'police','fastest');
 select route_status,distance_m into v_route_status,v_route_distance
 from game.road_route_calculations where id=v_route;
 if v_route_status<>'calculated' or v_route_distance is null
  or not exists(select 1 from game.road_route_legs where route_id=v_route) then
  raise exception 'New residential tower did not route to police headquarters';
 end if;
 v_route:=game.calculate_road_route(
  (select id from game.property_access_points where access_ref='KNG-ACC-CM0001'),
  (select access_point_id from game.police_facilities where facility_ref='KNG-PF-HQ'),
  'public','fastest');
 if not exists(select 1 from game.road_route_calculations where id=v_route and route_status='calculated') then
  raise exception 'New commercial centre did not route to police headquarters';
 end if;

 -- Exercise the actual text-first property/business commands with temporary NPC officer fixtures.
 insert into game.persons(person_ref,given_name,family_name,person_status)
 values('KW-TEST-PERSON-BP04','BP04','Test','active') returning id into v_person;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status)
 values('KW-TEST-OFFICER-BP04',v_person,'KW-TEST-SN-BP04','active') returning id into v_officer;
 perform set_config('bp04.test_officer_id',v_officer::text,true);

 v_result:=game.execute_text_command('property record KNG-P-RH0001 by KW-TEST-OFFICER-BP04','bp04-property-record-test-0001',null,v_officer);
 if coalesce((v_result->>'ok')::boolean,false) is not true or v_result->'record'->'property'->>'property_ref'<>'KNG-P-RH0001' then
  raise exception 'Property record game command failed';
 end if;
 v_result:=game.execute_text_command('property map KDW-01 by KW-TEST-OFFICER-BP04','bp04-property-map-test-0001',null,v_officer);
 if coalesce((v_result->>'ok')::boolean,false) is not true or v_result->'map'->>'property_count'<>'32' then
  raise exception 'Neighbourhood property map game command failed';
 end if;
 v_result:=game.execute_text_command('business directory sector logistics_warehousing by KW-TEST-OFFICER-BP04','bp04-business-directory-test-0001',null,v_officer);
 if coalesce((v_result->>'ok')::boolean,false) is not true or (v_result->>'count')::integer<>170 then
  raise exception 'Business directory game command failed';
 end if;
 v_result:=game.execute_text_command('business record AF-BIZ-000281 by KW-TEST-OFFICER-BP04','bp04-business-record-test-0001',null,v_officer);
 if coalesce((v_result->>'ok')::boolean,false) is not true or v_result->'record'->'business'->>'business_number'<>'AF-BIZ-000281' then
  raise exception 'Business record game command failed';
 end if;
 v_result:=game.execute_text_command('property summary by KW-TEST-OFFICER-BP04','bp04-property-summary-test-0001',null,v_officer);
 if coalesce((v_result->>'ok')::boolean,false) is not true or v_result->'summary'->'totals'->>'properties'<>'656' then
  raise exception 'Property summary game command failed';
 end if;
 v_result:=game.execute_text_command('property record KNG-P-RH0001 by KW-TEST-OFFICER-BP04','bp04-property-record-test-0001',null,v_officer);
 if v_result->>'duplicate'<>'true' then raise exception 'Property command idempotency failed'; end if;
 if game.interpret_text_command('prison facilities by KW-TEST-OFFICER-BP04')->>'command_type'<>'correctional_list_facilities' then
  raise exception 'Existing correctional parser was broken by BP-04 command extension';
 end if;
 v_result:=game.execute_text_command('help','bp04-help-test-0001',null,v_officer);
 if not exists(select 1 from jsonb_array_elements_text(v_result->'available_commands') x where x='property_neighbourhood_map') then
  raise exception 'Property map help entry is missing';
 end if;

 if (select current_game_time from game.simulation_state where id=1) is not null then
  raise exception 'BP-04 tests must not initialise fictional game time';
 end if;
 if exists(select 1 from (values ('property_profiles'),('building_profiles'),('building_unit_profiles'),('business_profiles'),('property_interest_records')) v(name)
  where not (select c.relrowsecurity from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='game' and c.relname=v.name)) then
  raise exception 'RLS is missing from a new BP-04 table';
 end if;
 if has_schema_privilege('anon','game','USAGE') or has_schema_privilege('authenticated','game','USAGE') then
  raise exception 'The private game schema is exposed to API roles';
 end if;
end $bp04$;
set local role service_role;
do $bp04$
declare v_officer uuid:=current_setting('bp04.test_officer_id')::uuid; v_result jsonb;
begin
 v_result:=game.execute_text_command('property record KNG-P-RH0001 by KW-TEST-OFFICER-BP04','bp04-service-property-record-0001',null,v_officer);
 if coalesce((v_result->>'ok')::boolean,false) is not true then raise exception 'Service-role property record command failed'; end if;
 v_result:=game.execute_text_command('business record AF-BIZ-000281 by KW-TEST-OFFICER-BP04','bp04-service-business-record-0001',null,v_officer);
 if coalesce((v_result->>'ok')::boolean,false) is not true then raise exception 'Service-role business record command failed'; end if;
 v_result:=game.execute_text_command('business directory sector neighbourhood_services by KW-TEST-OFFICER-BP04','bp04-service-business-directory-0001',null,v_officer);
 if coalesce((v_result->>'ok')::boolean,false) is not true or (v_result->>'count')::integer<>352 then
  raise exception 'Service-role business directory command failed';
 end if;
 v_result:=game.execute_text_command('property map KMX-01 by KW-TEST-OFFICER-BP04','bp04-service-property-map-0001',null,v_officer);
 if coalesce((v_result->>'ok')::boolean,false) is not true then raise exception 'Service-role property map command failed'; end if;
end $bp04$;
reset role;
rollback;
