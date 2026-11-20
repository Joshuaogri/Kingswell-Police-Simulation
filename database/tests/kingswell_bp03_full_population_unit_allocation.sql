-- BP-03 full population, household, dwelling, employment and routine load regression.
-- All NPCs are fictional. The entire 100,000-person seed is test-only and rolled back.
-- This test must never initialise or advance the fictional game clock.
BEGIN;

CREATE TEMP TABLE bp03_test_units ON COMMIT DROP AS
WITH ranked AS (
  SELECT up.building_unit_id,
         bu.unit_ref,
         b.property_id,
         p.neighbourhood_id,
         n.code neighbourhood_code,
         up.occupancy_capacity,
         row_number() OVER (ORDER BY n.code,bu.unit_ref)::integer unit_no
  FROM game.building_unit_profiles up
  JOIN game.building_units bu ON bu.id=up.building_unit_id
  JOIN game.buildings b ON b.id=bu.building_id
  JOIN game.properties p ON p.id=b.property_id
  JOIN game.neighbourhoods n ON n.id=p.neighbourhood_id
  WHERE up.use_class='dwelling'
)
SELECT unit_no,building_unit_id,unit_ref,property_id,neighbourhood_id,
       neighbourhood_code,occupancy_capacity,
       coalesce(sum(occupancy_capacity) OVER (
         ORDER BY unit_no ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
       ),0)::integer first_person_no,
       sum(occupancy_capacity) OVER (ORDER BY unit_no)::integer last_person_no
FROM ranked;

CREATE TEMP TABLE bp03_test_allocation ON COMMIT DROP AS
SELECT g::integer person_no,u.unit_no,u.building_unit_id,u.property_id,
       u.occupancy_capacity,
       (g-u.first_person_no)::integer member_position
FROM generate_series(1,100000) g
JOIN bp03_test_units u
  ON g>u.first_person_no AND g<=u.last_person_no;

DO $$
DECLARE
  v_city uuid;
  v_people integer;
  v_households integer;
  v_addresses integer;
  v_memberships integer;
  v_jobs integer;
  v_routines integer;
  v_events integer;
  v_relationships integer;
  v_summary record;
  v_rejected boolean;
  v_clock timestamptz;
  v_test_person uuid;
  v_target_household uuid;
  v_target_unit uuid;
  v_target_property uuid;
  v_donor_person uuid;
  v_wrong_unit uuid;
  v_wrong_property uuid;
BEGIN
  SELECT id INTO v_city FROM game.cities WHERE code='KNG';
  IF v_city IS NULL THEN RAISE EXCEPTION 'Kingswell city missing'; END IF;
  IF EXISTS(SELECT 1 FROM game.persons) OR EXISTS(SELECT 1 FROM game.households) THEN
    RAISE EXCEPTION 'Expected clean unseeded population before BP-03 load regression';
  END IF;

  IF (SELECT count(*) FROM bp03_test_units)<>24512
     OR (SELECT sum(occupancy_capacity) FROM bp03_test_units)<>100000
     OR (SELECT count(*) FROM bp03_test_allocation)<>100000 THEN
    RAISE EXCEPTION 'Dwelling inventory does not allocate exactly 100,000 people';
  END IF;
  IF EXISTS(
    SELECT unit_no FROM bp03_test_allocation
    GROUP BY unit_no,occupancy_capacity
    HAVING count(*)>max(occupancy_capacity)
  ) THEN RAISE EXCEPTION 'Allocation plan exceeds a dwelling capacity'; END IF;

  INSERT INTO game.persons(
    person_ref,given_name,family_name,date_of_birth,nationality,person_status,
    birth_city_id,occupation,preferred_language,personality_profile,behaviour_profile
  )
  SELECT 'KW-BP03-FULL-'||lpad(g::text,6,'0'),
         (ARRAY['Ari','Mara','Jon','Iris','Noah','Talia','Eli','Nia','Sam','Leah','Kian','Mina'])[((g-1)%12)+1],
         (ARRAY['Aster','Bennett','Caldwell','Dawson','Ellery','Farrow','Givens','Hale','Iver','Jensen','Kerr','Linden','Marlow','Nolan','Orin','Pryce'])[((g*7-1)%16)+1],
         date '1940-01-01'+((g*37)%27000),
         'Asterfell','active',v_city,
         CASE WHEN g<=43412 THEN 'Business employee' ELSE 'Resident' END,
         'Asterian',
         jsonb_build_object('temperament',CASE WHEN g%3=0 THEN 'reserved' WHEN g%3=1 THEN 'outgoing' ELSE 'measured' END,
                            'interests',jsonb_build_array('community','work')),
         jsonb_build_object('routine_profile','baseline')
  FROM generate_series(1,100000) g;

  INSERT INTO game.households(
    household_ref,household_type,primary_property_id,primary_building_unit_id,formed_on
  )
  SELECT 'KW-BP03-FULL-HH-'||lpad(u.unit_no::text,6,'0'),
         CASE WHEN u.occupancy_capacity=5 OR u.unit_no%10<7 THEN 'family'
              WHEN u.unit_no%10<9 THEN 'shared' ELSE 'group' END,
         u.property_id,u.building_unit_id,'2020-01-01'
  FROM bp03_test_units u;

  INSERT INTO game.household_memberships(
    household_id,person_id,household_role,is_primary,valid_from
  )
  SELECT h.id,p.id,
         CASE WHEN a.member_position=1 THEN 'head'
              WHEN h.household_type='family' AND a.member_position=2 THEN 'partner'
              WHEN h.household_type='family' AND a.member_position IN (3,4) THEN 'child'
              WHEN h.household_type='family' AND a.member_position=5 THEN 'dependent'
              ELSE 'housemate' END,
         true,'2020-01-01'
  FROM bp03_test_allocation a
  JOIN game.persons p ON p.person_ref='KW-BP03-FULL-'||lpad(a.person_no::text,6,'0')
  JOIN game.households h ON h.household_ref='KW-BP03-FULL-HH-'||lpad(a.unit_no::text,6,'0');

  INSERT INTO game.person_addresses(
    person_id,property_id,building_unit_id,address_role,valid_from,is_current,is_primary
  )
  SELECT p.id,a.property_id,a.building_unit_id,'residence','2020-01-01',true,true
  FROM bp03_test_allocation a
  JOIN game.persons p ON p.person_ref='KW-BP03-FULL-'||lpad(a.person_no::text,6,'0');

  INSERT INTO game.person_population_memberships(person_id,city_id,population_category,valid_from)
  SELECT id,v_city,'permanent_resident','2020-01-01' FROM game.persons;

  INSERT INTO game.person_population_memberships(person_id,city_id,population_category,valid_from)
  SELECT id,v_city,'commercial_worker','2020-01-01'
  FROM game.persons WHERE person_ref BETWEEN
    'KW-BP03-FULL-000001' AND 'KW-BP03-FULL-043412';

  CREATE TEMP TABLE bp03_test_business_jobs ON COMMIT DROP AS
  SELECT organisation_id,estimated_employee_count,
         coalesce(sum(estimated_employee_count) OVER (
           ORDER BY business_number ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
         ),0)::integer first_job,
         sum(estimated_employee_count) OVER (ORDER BY business_number)::integer last_job
  FROM game.business_profiles;

  INSERT INTO game.organisation_personnel(
    organisation_id,person_id,job_title,employment_type,valid_from,is_current
  )
  SELECT j.organisation_id,p.id,'Business employee','full_time','2020-01-01',true
  FROM generate_series(1,43412) g
  JOIN bp03_test_business_jobs j ON g>j.first_job AND g<=j.last_job
  JOIN game.persons p ON p.person_ref='KW-BP03-FULL-'||lpad(g::text,6,'0');

  INSERT INTO game.person_relationships(person_id,related_person_id,relationship_type,valid_from)
  SELECT head.id,member.id,
         CASE WHEN h.household_type='family' AND a.member_position=2 THEN 'partner'
              WHEN h.household_type='family' AND a.member_position IN (3,4) THEN 'child'
              WHEN h.household_type='family' AND a.member_position=5 THEN 'dependent'
              ELSE 'housemate' END,
         '2020-01-01'
  FROM bp03_test_allocation a
  JOIN game.persons member ON member.person_ref='KW-BP03-FULL-'||lpad(a.person_no::text,6,'0')
  JOIN game.persons head ON head.person_ref='KW-BP03-FULL-'||lpad((a.person_no-a.member_position+1)::text,6,'0')
  JOIN game.households h ON h.household_ref='KW-BP03-FULL-HH-'||lpad(a.unit_no::text,6,'0')
  WHERE a.member_position>1;

  INSERT INTO game.person_routines(
    person_id,routine_category,activity_type,day_of_week,start_time,end_time,
    crosses_midnight,priority,confidence,routine_source
  )
  SELECT id,'sleep','sleep',1,'22:00','06:00',true,3,0.8,'npc_generated'
  FROM game.persons;

  INSERT INTO game.person_routines(
    person_id,routine_category,activity_type,day_of_week,start_time,end_time,
    crosses_midnight,location_property_id,priority,confidence,routine_source
  )
  SELECT p.id,'work','work shift',1,'09:00','17:00',false,ol.property_id,3,0.8,'npc_generated'
  FROM game.organisation_personnel op
  JOIN game.persons p ON p.id=op.person_id
  JOIN LATERAL (
    SELECT property_id FROM game.organisation_locations
    WHERE organisation_id=op.organisation_id AND is_primary_location
      AND valid_to IS NULL
    ORDER BY id LIMIT 1
  ) ol ON true
  WHERE op.is_current;

  INSERT INTO game.person_life_events(person_id,event_type,effective_on,details)
  SELECT id,'birth',date_of_birth,jsonb_build_object('source','BP-03 rollback full-population test')
  FROM game.persons;

  SELECT count(*) INTO v_people FROM game.persons;
  SELECT count(*) INTO v_households FROM game.households;
  SELECT count(*) INTO v_addresses FROM game.person_addresses
    WHERE is_current AND is_primary AND building_unit_id IS NOT NULL;
  SELECT count(*) INTO v_memberships FROM game.person_population_memberships
    WHERE population_category='permanent_resident' AND valid_to IS NULL;
  SELECT count(*) INTO v_jobs FROM game.organisation_personnel WHERE is_current;
  SELECT count(*) INTO v_routines FROM game.person_routines;
  SELECT count(*) INTO v_events FROM game.person_life_events;
  SELECT count(*) INTO v_relationships FROM game.person_relationships;
  SELECT * INTO v_summary FROM game.get_population_summary('KNG');

  IF v_people<>100000 OR v_households<>24512 OR v_addresses<>100000
     OR v_memberships<>100000 OR v_jobs<>43412
     OR v_routines<100000 OR v_events<>100000 OR v_relationships<>75488 THEN
    RAISE EXCEPTION 'Full load totals mismatch: people %, households %, addresses %, residents %, jobs %, routines %, life events %, relationships %',
      v_people,v_households,v_addresses,v_memberships,v_jobs,v_routines,v_events,v_relationships;
  END IF;
  IF v_summary.unique_people<>100000 OR v_summary.permanent_residents<>100000
     OR v_summary.commercial_workers<>43412 OR v_summary.current_households<>24512 THEN
    RAISE EXCEPTION 'Population summary mismatch: %',row_to_json(v_summary);
  END IF;
  IF EXISTS(
    SELECT 1 FROM game.person_addresses a
    JOIN game.persons p ON p.id=a.person_id
    JOIN game.household_memberships hm ON hm.person_id=p.id AND hm.is_primary AND hm.valid_to IS NULL
    JOIN game.households h ON h.id=hm.household_id
    WHERE a.is_current AND a.address_role='residence'
      AND (a.building_unit_id IS DISTINCT FROM h.primary_building_unit_id
           OR a.property_id IS DISTINCT FROM h.primary_property_id)
  ) THEN RAISE EXCEPTION 'Person address and primary household unit/property do not reconcile'; END IF;
  IF EXISTS(
    SELECT 1 FROM game.household_memberships hm
    JOIN game.households h ON h.id=hm.household_id
    JOIN game.building_unit_profiles up ON up.building_unit_id=h.primary_building_unit_id
    WHERE hm.valid_to IS NULL
    GROUP BY h.primary_building_unit_id,up.occupancy_capacity
    HAVING count(*)>up.occupancy_capacity
  ) THEN RAISE EXCEPTION 'Dwelling occupancy capacity was exceeded'; END IF;
  IF EXISTS(SELECT person_ref FROM game.persons GROUP BY person_ref HAVING count(*)>1) THEN
    RAISE EXCEPTION 'Duplicate canonical person identities found'; END IF;

  -- Negative test: a full dwelling must reject one additional current occupant.
  SELECT h.id,h.primary_building_unit_id,h.primary_property_id
    INTO v_target_household,v_target_unit,v_target_property
  FROM game.households h
  JOIN game.building_unit_profiles up ON up.building_unit_id=h.primary_building_unit_id
  WHERE up.occupancy_capacity=5
  ORDER BY h.household_ref LIMIT 1;
  SELECT p.id INTO v_donor_person
  FROM game.persons p
  JOIN game.household_memberships hm ON hm.person_id=p.id AND hm.valid_to IS NULL
  JOIN game.households h ON h.id=hm.household_id
  WHERE h.id<>v_target_household LIMIT 1;
  v_rejected:=false;
  BEGIN
    INSERT INTO game.household_memberships(household_id,person_id,household_role,is_primary,valid_from)
    VALUES(v_target_household,v_donor_person,'housemate',false,'2020-01-01');
  EXCEPTION WHEN raise_exception THEN
    IF SQLERRM LIKE 'Dwelling occupancy capacity exceeded:%' THEN v_rejected:=true; ELSE RAISE; END IF;
  END;
  IF NOT v_rejected THEN RAISE EXCEPTION 'Over-capacity household admission was not rejected'; END IF;

  -- Negative test: a commercial unit cannot become a household dwelling.
  SELECT bu.id,b.property_id INTO v_wrong_unit,v_wrong_property
  FROM game.building_units bu
  JOIN game.buildings b ON b.id=bu.building_id
  JOIN game.building_unit_profiles up ON up.building_unit_id=bu.id
  WHERE up.use_class<>'dwelling' LIMIT 1;
  v_rejected:=false;
  BEGIN
    INSERT INTO game.households(household_ref,household_type,primary_property_id,primary_building_unit_id,formed_on)
    VALUES('KW-BP03-NEGATIVE-NONDWELLING','family',v_wrong_property,v_wrong_unit,'2020-01-01');
  EXCEPTION WHEN raise_exception THEN
    IF SQLERRM LIKE 'Household primary unit must be classified as a dwelling%' THEN v_rejected:=true; ELSE RAISE; END IF;
  END;
  IF NOT v_rejected THEN RAISE EXCEPTION 'Non-dwelling household allocation was not rejected'; END IF;

  -- Negative test: unit and property mismatch must be rejected.
  SELECT a.person_id,p.property_id INTO v_test_person,v_wrong_property
  FROM game.person_addresses a
  JOIN game.properties p ON p.id<>a.property_id
  WHERE a.is_current AND a.building_unit_id IS NOT NULL LIMIT 1;
  SELECT a.building_unit_id INTO v_wrong_unit
  FROM game.person_addresses a WHERE a.person_id=v_test_person AND a.is_current LIMIT 1;
  v_rejected:=false;
  BEGIN
    INSERT INTO game.person_addresses(person_id,property_id,building_unit_id,address_role,valid_from,is_current,is_primary)
    VALUES(v_test_person,v_wrong_property,v_wrong_unit,'mailing','2020-01-01',false,false);
  EXCEPTION WHEN raise_exception THEN
    IF SQLERRM LIKE 'Person address property does not match its building unit%' THEN v_rejected:=true; ELSE RAISE; END IF;
  END;
  IF NOT v_rejected THEN RAISE EXCEPTION 'Mismatched property/unit address was not rejected'; END IF;

  SELECT current_game_time INTO v_clock FROM game.simulation_state WHERE id=1;
  IF v_clock IS NOT NULL THEN RAISE EXCEPTION 'BP-03 test initialised or advanced the fictional clock'; END IF;
  IF (SELECT count(*) FROM pg_tables WHERE schemaname='game'
      AND tablename IN ('households','household_memberships','person_population_memberships',
                        'person_life_events','person_routines','person_activity_events',
                        'person_simulation_promotions') AND rowsecurity)<>7 THEN
    RAISE EXCEPTION 'RLS is not enabled across all BP-03 tables';
  END IF;
  IF has_schema_privilege('anon','game','USAGE') OR has_schema_privilege('authenticated','game','USAGE') THEN
    RAISE EXCEPTION 'Private game schema is exposed to API roles';
  END IF;
  RAISE NOTICE 'BP-03 full population regression passed: 100,000 people; 24,512 households; 100,000 exact unit addresses; 43,412 employee links; 75,488 relationships; routines and life events; all negative tests passed.';
END $$;

ROLLBACK;
