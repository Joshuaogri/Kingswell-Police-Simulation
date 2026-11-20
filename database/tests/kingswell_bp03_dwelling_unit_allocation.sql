-- BP-03 exact dwelling-unit allocation and capacity enforcement integration regression.
-- 100 fictional NPC fixtures exercise the live schema; all records are rolled back.
BEGIN;
CREATE TEMP TABLE bp03_u ON COMMIT DROP AS
SELECT row_number() over(order by n.code,bu.unit_ref)::integer unit_no,bu.id unit_id,b.property_id,up.occupancy_capacity
FROM game.building_units bu JOIN game.buildings b ON b.id=bu.building_id
JOIN game.properties p ON p.id=b.property_id JOIN game.neighbourhoods n ON n.id=p.neighbourhood_id
JOIN game.building_unit_profiles up ON up.building_unit_id=bu.id WHERE up.use_class='dwelling';
CREATE TEMP TABLE bp03_a ON COMMIT DROP AS
SELECT g::integer person_no,ceil(g::numeric/4)::integer unit_no FROM generate_series(1,100) g;
INSERT INTO game.persons(person_ref,given_name,family_name,date_of_birth,nationality,person_status,birth_city_id)
SELECT 'KW-BP03-INT-'||lpad(g::text,3,'0'),'Ari','Aster',date '1980-01-01','Asterfell','active',
(SELECT id FROM game.cities WHERE code='KNG') FROM generate_series(1,100) g;
INSERT INTO game.households(household_ref,household_type,primary_property_id,primary_building_unit_id,formed_on)
SELECT 'KW-BP03-INT-HH-'||lpad(unit_no::text,3,'0'),'family',property_id,unit_id,'2020-01-01' FROM bp03_u WHERE unit_no<=25;
INSERT INTO game.household_memberships(household_id,person_id,household_role,is_primary,valid_from)
SELECT h.id,p.id,CASE WHEN a.person_no%4=1 THEN 'head' WHEN a.person_no%4=2 THEN 'partner' ELSE 'child' END,true,'2020-01-01'
FROM bp03_a a JOIN game.persons p ON p.person_ref='KW-BP03-INT-'||lpad(a.person_no::text,3,'0')
JOIN game.households h ON h.household_ref='KW-BP03-INT-HH-'||lpad(a.unit_no::text,3,'0');
INSERT INTO game.person_addresses(person_id,property_id,building_unit_id,address_role,valid_from,is_current,is_primary)
SELECT p.id,u.property_id,u.unit_id,'residence','2020-01-01',true,true FROM bp03_a a
JOIN bp03_u u ON u.unit_no=a.unit_no JOIN game.persons p ON p.person_ref='KW-BP03-INT-'||lpad(a.person_no::text,3,'0');
INSERT INTO game.person_population_memberships(person_id,city_id,population_category,valid_from)
SELECT id,(SELECT id FROM game.cities WHERE code='KNG'),'permanent_resident','2020-01-01'
FROM game.persons WHERE person_ref LIKE 'KW-BP03-INT-%';
INSERT INTO game.person_relationships(person_id,related_person_id,relationship_type,valid_from)
SELECT head.id,member.id,'family','2020-01-01' FROM bp03_a a
JOIN game.persons member ON member.person_ref='KW-BP03-INT-'||lpad(a.person_no::text,3,'0')
JOIN game.persons head ON head.person_ref='KW-BP03-INT-'||lpad((a.person_no-a.person_no%4+1)::text,3,'0')
WHERE a.person_no%4<>1;
INSERT INTO game.person_routines(person_id,routine_category,activity_type,day_of_week,start_time,end_time,crosses_midnight)
SELECT id,'sleep','sleep',1,'22:00','06:00',true FROM game.persons WHERE person_ref LIKE 'KW-BP03-INT-%';
INSERT INTO game.person_life_events(person_id,event_type,effective_on,details)
SELECT id,'birth',date_of_birth,'{"source":"rollback integration test"}'::jsonb
FROM game.persons WHERE person_ref LIKE 'KW-BP03-INT-%';
DO $$
DECLARE v_rejected boolean; v_household uuid; v_donor1 uuid; v_donor2 uuid; v_unit uuid; v_property uuid;
BEGIN
 IF (SELECT count(*) FROM game.person_addresses WHERE person_id IN
     (SELECT id FROM game.persons WHERE person_ref LIKE 'KW-BP03-INT-%')
     AND building_unit_id IS NOT NULL)<>100 THEN RAISE EXCEPTION 'Exact unit address link failed'; END IF;
 IF (SELECT count(*) FROM game.household_memberships hm JOIN game.households h ON h.id=hm.household_id
     WHERE h.household_ref LIKE 'KW-BP03-INT-HH-%' AND hm.valid_to IS NULL)<>100
 THEN RAISE EXCEPTION 'Household membership failed'; END IF;
 SELECT h.id INTO v_household FROM game.households h
 JOIN game.building_unit_profiles up ON up.building_unit_id=h.primary_building_unit_id
 WHERE h.household_ref LIKE 'KW-BP03-INT-HH-%' AND up.occupancy_capacity=5 LIMIT 1;
 SELECT p.id INTO v_donor1 FROM game.persons p WHERE p.person_ref LIKE 'KW-BP03-INT-%'
 AND NOT EXISTS(SELECT 1 FROM game.household_memberships hm WHERE hm.person_id=p.id AND hm.household_id=v_household) LIMIT 1;
 INSERT INTO game.household_memberships(household_id,person_id,household_role,is_primary,valid_from)
 VALUES(v_household,v_donor1,'housemate',false,'2020-01-01');
 SELECT p.id INTO v_donor2 FROM game.persons p WHERE p.person_ref LIKE 'KW-BP03-INT-%'
 AND p.id<>v_donor1 AND NOT EXISTS(SELECT 1 FROM game.household_memberships hm WHERE hm.person_id=p.id AND hm.household_id=v_household) LIMIT 1;
 v_rejected:=false;
 BEGIN
  INSERT INTO game.household_memberships(household_id,person_id,household_role,is_primary,valid_from)
  VALUES(v_household,v_donor2,'housemate',false,'2020-01-01');
 EXCEPTION WHEN raise_exception THEN
  IF SQLERRM LIKE 'Dwelling occupancy capacity exceeded:%' THEN v_rejected:=true; ELSE RAISE; END IF;
 END;
 IF NOT v_rejected THEN RAISE EXCEPTION 'Sixth occupant was not rejected'; END IF;
 SELECT bu.id,b.property_id INTO v_unit,v_property FROM game.building_units bu
 JOIN game.buildings b ON b.id=bu.building_id JOIN game.building_unit_profiles up ON up.building_unit_id=bu.id
 WHERE up.use_class<>'dwelling' LIMIT 1;
 v_rejected:=false;
 BEGIN
  INSERT INTO game.households(household_ref,household_type,primary_property_id,primary_building_unit_id,formed_on)
  VALUES('KW-BP03-INT-NEG','family',v_property,v_unit,'2020-01-01');
 EXCEPTION WHEN raise_exception THEN
  IF SQLERRM LIKE 'Household primary unit must be classified as a dwelling%' THEN v_rejected:=true; ELSE RAISE; END IF;
 END;
 IF NOT v_rejected THEN RAISE EXCEPTION 'Non-dwelling unit was accepted'; END IF;
END $$;
ROLLBACK;