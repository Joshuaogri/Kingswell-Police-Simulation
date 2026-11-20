CREATE OR REPLACE FUNCTION game.seed_kingswell_population_unit_batch(
  p_first_unit integer,
  p_last_unit integer
)
RETURNS jsonb
LANGUAGE plpgsql
SET search_path = pg_catalog, game
AS $$
DECLARE
  v_city_id uuid;
  v_rows integer;
BEGIN
  IF p_first_unit < 1 OR p_last_unit < p_first_unit OR p_last_unit > 24512
     OR p_last_unit - p_first_unit > 999 THEN
    RAISE EXCEPTION 'Population unit batch must cover 1-1000 units within 1-24512';
  END IF;

  SELECT id INTO v_city_id FROM game.cities WHERE code='KNG';
  IF v_city_id IS NULL THEN RAISE EXCEPTION 'Canonical Kingswell city KNG is missing'; END IF;

  CREATE TEMP TABLE bp03_seed_units ON COMMIT DROP AS
  WITH ranked AS (
    SELECT row_number() OVER (ORDER BY n.code, bu.unit_ref)::integer AS unit_no,
           bu.id AS unit_id, b.property_id, up.occupancy_capacity,
           sum(up.occupancy_capacity) OVER (
             ORDER BY n.code, bu.unit_ref ROWS UNBOUNDED PRECEDING
           )::integer AS cumulative_person
    FROM game.building_unit_profiles up
    JOIN game.building_units bu ON bu.id=up.building_unit_id
    JOIN game.buildings b ON b.id=bu.building_id
    JOIN game.properties p ON p.id=b.property_id
    JOIN game.neighbourhoods n ON n.id=p.neighbourhood_id
    WHERE up.use_class='dwelling'
  )
  SELECT unit_no,unit_id,property_id,occupancy_capacity,
         cumulative_person-occupancy_capacity AS prior_person,
         'KWHH-KNG-'||lpad(unit_no::text,8,'0') AS household_ref
  FROM ranked
  WHERE unit_no BETWEEN p_first_unit AND p_last_unit;

  IF (SELECT count(*) FROM bp03_seed_units) <> p_last_unit-p_first_unit+1 THEN
    RAISE EXCEPTION 'Dwelling inventory changed or is incomplete for requested batch';
  END IF;

  CREATE TEMP TABLE bp03_seed_people ON COMMIT DROP AS
  SELECT u.unit_no,u.unit_id,u.property_id,u.household_ref,
         u.prior_person+s.slot AS person_no,s.slot::integer AS household_slot,
         CASE
           WHEN s.slot=1 THEN 30+mod(u.unit_no*17,51)
           WHEN s.slot=2 THEN 25+mod(u.unit_no*13,46)
           WHEN s.slot=3 THEN 6+mod(u.unit_no*11,23)
           WHEN s.slot=4 THEN 3+mod(u.unit_no*7,18)
           ELSE mod(u.unit_no*5,16)
         END::integer AS age_years
  FROM bp03_seed_units u
  CROSS JOIN LATERAL generate_series(1,u.occupancy_capacity) s(slot);

  ALTER TABLE bp03_seed_people ADD PRIMARY KEY(person_no);
  CREATE INDEX ON bp03_seed_people(household_ref,household_slot);

  INSERT INTO game.households(
    household_ref,household_type,primary_property_id,primary_building_unit_id,formed_on,notes
  )
  SELECT household_ref,
         CASE WHEN unit_no%23=0 THEN 'shared' ELSE 'family' END,
         property_id,unit_id,date '2010-01-01',
         'Initial Kingswell census household; allocated to the canonical dwelling unit'
  FROM bp03_seed_units
  ON CONFLICT (household_ref) DO NOTHING;
  GET DIAGNOSTICS v_rows = ROW_COUNT;

  INSERT INTO game.persons(
    person_ref,given_name,family_name,date_of_birth,nationality,person_status,
    birth_city_id,occupation,preferred_language,personality_profile,behaviour_profile
  )
  SELECT
    'KNG-P-'||lpad(person_no::text,6,'0'),
    (ARRAY['Ari','Mara','Jon','Iris','Noah','Talia','Eli','Nia','Milan','Amara',
           'Theo','Zara','Caleb','Leila','Micah','Sana','Ezra','Mira','Daniel','Ada',
           'Samuel','Lina','Rafael','Kira','Isaac','Naomi','Owen','Esme','Gabriel','Asha',
           'Felix','Imani','David','Elena','Nathan','Sofia','Joel','Maya','Simon','Amina'])
      [mod(person_no*17,40)+1],
    (ARRAY['Aster','Bennett','Caldwell','Dawson','Ellery','Farrow','Givens','Hale',
           'Iver','Jensen','Kellan','Lang','Morrow','Nolan','Orwell','Parker',
           'Quinn','Rowe','Sutton','Tallis','Underwood','Vale','West','Yarrow','Zorin'])
      [mod(unit_no*7,25)+1],
    date '2026-01-01'-(age_years*365+mod(person_no*97,365))::integer,
    'Asterfellian','active',v_city_id,
    CASE WHEN age_years<5 THEN 'Young child'
         WHEN age_years<23 THEN 'Student'
         WHEN age_years>=65 THEN 'Retired'
         ELSE 'Unemployed' END,
    'Asterian',
    jsonb_build_object(
      'temperament',(ARRAY['measured','outgoing','reserved','curious','practical'])
        [mod(person_no*11,5)+1],
      'sociability',1+mod(person_no*7,5),
      'patience',1+mod(person_no*13,5),
      'adaptability',1+mod(person_no*19,5)
    ),
    jsonb_build_object(
      'routine_preference',(ARRAY['early','standard','late','variable'])
        [mod(person_no*3,4)+1],
      'community_participation',mod(person_no*23,5),
      'mobility_pattern',(ARRAY['local','cross_district','commuter'])
        [mod(person_no*5,3)+1],
      'profile_version',1
    )
  FROM bp03_seed_people
  ON CONFLICT (person_ref) DO NOTHING;
  GET DIAGNOSTICS v_rows = ROW_COUNT;

  INSERT INTO game.household_memberships(
    household_id,person_id,household_role,is_primary,valid_from
  )
  SELECT h.id,p.id,
         CASE
           WHEN h.household_type='shared' AND x.household_slot=1 THEN 'head'
           WHEN h.household_type='shared' THEN 'housemate'
           WHEN x.household_slot=1 THEN 'head'
           WHEN x.household_slot=2 THEN 'partner'
           WHEN x.age_years<18 THEN 'child'
           ELSE 'relative'
         END,
         true,greatest(p.date_of_birth,date '2010-01-01')
  FROM bp03_seed_people x
  JOIN game.persons p ON p.person_ref='KNG-P-'||lpad(x.person_no::text,6,'0')
  JOIN game.households h ON h.household_ref=x.household_ref
  WHERE NOT EXISTS (
    SELECT 1 FROM game.household_memberships hm
    WHERE hm.household_id=h.id AND hm.person_id=p.id AND hm.valid_to IS NULL
  )
  ORDER BY h.household_ref,x.household_slot;
  GET DIAGNOSTICS v_rows = ROW_COUNT;

  INSERT INTO game.person_addresses(
    person_id,property_id,building_unit_id,address_role,valid_from,is_current,is_primary
  )
  SELECT p.id,x.property_id,x.unit_id,'residence',
         greatest(p.date_of_birth,date '2010-01-01'),true,true
  FROM bp03_seed_people x
  JOIN game.persons p ON p.person_ref='KNG-P-'||lpad(x.person_no::text,6,'0')
  WHERE NOT EXISTS (
    SELECT 1 FROM game.person_addresses a
    WHERE a.person_id=p.id AND a.address_role='residence' AND a.is_current
  );
  GET DIAGNOSTICS v_rows = ROW_COUNT;

  INSERT INTO game.person_population_memberships(
    person_id,city_id,population_category,valid_from,details
  )
  SELECT p.id,v_city_id,'permanent_resident',
         greatest(p.date_of_birth,date '2010-01-01'),
         jsonb_build_object('census_cohort','KNG-2026-BASELINE','household_ref',x.household_ref,
                            'neighbourhood_unit_no',x.unit_no)
  FROM bp03_seed_people x
  JOIN game.persons p ON p.person_ref='KNG-P-'||lpad(x.person_no::text,6,'0')
  WHERE NOT EXISTS (
    SELECT 1 FROM game.person_population_memberships pm
    WHERE pm.person_id=p.id AND pm.population_category='permanent_resident' AND pm.valid_to IS NULL
  );

  INSERT INTO game.person_population_memberships(
    person_id,city_id,population_category,valid_from,details
  )
  SELECT p.id,v_city_id,
         CASE WHEN x.age_years>=65 THEN 'retired' ELSE 'student' END,
         greatest(p.date_of_birth,date '2010-01-01'),
         jsonb_build_object('census_cohort','KNG-2026-BASELINE','age_at_census',x.age_years)
  FROM bp03_seed_people x
  JOIN game.persons p ON p.person_ref='KNG-P-'||lpad(x.person_no::text,6,'0')
  WHERE (x.age_years>=65 OR x.age_years BETWEEN 5 AND 22)
    AND NOT EXISTS (
      SELECT 1 FROM game.person_population_memberships pm
      WHERE pm.person_id=p.id
        AND pm.population_category=CASE WHEN x.age_years>=65 THEN 'retired' ELSE 'student' END
        AND pm.valid_to IS NULL
    );

  INSERT INTO game.person_life_events(person_id,event_type,effective_on,details)
  SELECT p.id,'birth',p.date_of_birth,
         jsonb_build_object('source','Kingswell initial population seed','cohort','KNG-2026-BASELINE')
  FROM bp03_seed_people x
  JOIN game.persons p ON p.person_ref='KNG-P-'||lpad(x.person_no::text,6,'0')
  WHERE NOT EXISTS (
    SELECT 1 FROM game.person_life_events le
    WHERE le.person_id=p.id AND le.event_type='birth'
  );

  INSERT INTO game.person_routines(
    person_id,routine_category,activity_type,day_of_week,start_time,end_time,
    crosses_midnight,location_property_id,priority,confidence,routine_source,details
  )
  SELECT p.id,'sleep','sleep',d.dow,time '22:00',time '06:00',true,
         x.property_id,3,0.900,'npc_generated',
         jsonb_build_object('seed_cohort','KNG-2026-BASELINE','pattern','weekly_sleep')
  FROM bp03_seed_people x
  JOIN game.persons p ON p.person_ref='KNG-P-'||lpad(x.person_no::text,6,'0')
  CROSS JOIN generate_series(0,6) d(dow)
  WHERE NOT EXISTS (
    SELECT 1 FROM game.person_routines r
    WHERE r.person_id=p.id AND r.routine_category='sleep' AND r.day_of_week=d.dow
      AND r.routine_status='active'
  );

  INSERT INTO game.person_relationships(
    person_id,related_person_id,relationship_type,valid_from,notes
  )
  SELECT a.id,b.id,pair.relationship_type,
         greatest(a.date_of_birth,b.date_of_birth,date '2010-01-01'),
         'Initial household relationship generated from the household composition'
  FROM bp03_seed_people x
  JOIN bp03_seed_people y ON y.household_ref=x.household_ref
       AND y.household_slot>x.household_slot
  JOIN game.persons a ON a.person_ref='KNG-P-'||lpad(x.person_no::text,6,'0')
  JOIN game.persons b ON b.person_ref='KNG-P-'||lpad(y.person_no::text,6,'0')
  JOIN game.households h ON h.household_ref=x.household_ref
  CROSS JOIN LATERAL (
    SELECT CASE
      WHEN h.household_type='shared' THEN 'housemate'
      WHEN x.household_slot=1 AND y.household_slot=2 THEN 'partner'
      WHEN x.household_slot=1 AND y.age_years<18 THEN 'parent_child'
      WHEN x.household_slot=1 THEN 'relative'
      WHEN x.age_years<18 AND y.age_years<18 THEN 'sibling'
      ELSE 'relative'
    END AS relationship_type
  ) pair
  UNION ALL
  SELECT b.id,a.id,
         CASE
           WHEN h.household_type='shared' THEN 'housemate'
           WHEN x.household_slot=1 AND y.household_slot=2 THEN 'partner'
           WHEN x.household_slot=1 AND y.age_years<18 THEN 'child_parent'
           WHEN x.household_slot=1 THEN 'relative'
           WHEN x.age_years<18 AND y.age_years<18 THEN 'sibling'
           ELSE 'relative'
         END,
         greatest(a.date_of_birth,b.date_of_birth,date '2010-01-01'),
         'Initial household relationship generated from the household composition'
  FROM bp03_seed_people x
  JOIN bp03_seed_people y ON y.household_ref=x.household_ref
       AND y.household_slot>x.household_slot
  JOIN game.persons a ON a.person_ref='KNG-P-'||lpad(x.person_no::text,6,'0')
  JOIN game.persons b ON b.person_ref='KNG-P-'||lpad(y.person_no::text,6,'0')
  JOIN game.households h ON h.household_ref=x.household_ref
  ON CONFLICT DO NOTHING;

  RETURN jsonb_build_object(
    'unit_start',p_first_unit,'unit_end',p_last_unit,
    'households',p_last_unit-p_first_unit+1,
    'people',(SELECT count(*) FROM bp03_seed_people),
    'population_categories',true,'addresses',true,'relationships',true,
    'birth_events',true,'weekly_sleep_routines',true
  );
END;
$$;

CREATE OR REPLACE FUNCTION game.seed_kingswell_business_employment_batch(
  p_first_job integer,
  p_last_job integer
)
RETURNS jsonb
LANGUAGE plpgsql
SET search_path = pg_catalog, game
AS $$
DECLARE
  v_total_jobs integer;
  v_rows integer;
BEGIN
  IF p_first_job < 1 OR p_last_job < p_first_job OR p_last_job > 43412
     OR p_last_job-p_first_job > 4999 THEN
    RAISE EXCEPTION 'Employment batch must cover 1-5000 jobs within 1-43412';
  END IF;

  CREATE TEMP TABLE bp03_seed_jobs ON COMMIT DROP AS
  WITH business_jobs AS (
    SELECT bp.organisation_id,bp.business_number,bp.sector,
           gs.job_slot,
           row_number() OVER (ORDER BY bp.business_number,gs.job_slot)::integer AS job_no
    FROM game.business_profiles bp
    CROSS JOIN LATERAL generate_series(1,bp.estimated_employee_count) gs(job_slot)
  ),
  eligible_people AS (
    SELECT p.id,p.person_ref,p.date_of_birth,
           row_number() OVER (ORDER BY p.person_ref)::integer AS employee_no
    FROM game.persons p
    WHERE p.person_ref LIKE 'KNG-P-%'
      AND extract(year FROM age(date '2026-01-01',p.date_of_birth)) BETWEEN 18 AND 65
  ),
  sites AS (
    SELECT DISTINCT ON (ol.organisation_id)
           ol.organisation_id,ol.property_id
    FROM game.organisation_locations ol
    WHERE ol.occupancy_status='active'
    ORDER BY ol.organisation_id,ol.is_primary_location DESC,ol.site_ref
  )
  SELECT j.job_no,j.organisation_id,j.business_number,j.sector,
         p.id AS person_id,p.person_ref,p.date_of_birth,s.property_id AS work_property_id,
         home.property_id AS home_property_id,
         CASE j.sector
           WHEN 'financial_services' THEN 'Financial Services Associate'
           WHEN 'import_export' THEN 'Trade Operations Associate'
           WHEN 'logistics_warehousing' THEN 'Logistics and Warehouse Operative'
           WHEN 'transport_services' THEN 'Transport Operations Associate'
           WHEN 'manufacturing' THEN 'Production Operative'
           WHEN 'wholesale_trade' THEN 'Wholesale Trade Associate'
           WHEN 'retail' THEN 'Retail Associate'
           WHEN 'hospitality_entertainment' THEN 'Hospitality and Entertainment Associate'
           WHEN 'professional_services' THEN 'Professional Services Associate'
           WHEN 'technology_media' THEN 'Technology and Media Associate'
           WHEN 'construction_property' THEN 'Construction and Property Associate'
           WHEN 'property_management' THEN 'Property Management Associate'
           ELSE 'Neighbourhood Services Associate'
         END AS job_title
  FROM business_jobs j
  JOIN eligible_people p ON p.employee_no=j.job_no
  JOIN sites s ON s.organisation_id=j.organisation_id
  LEFT JOIN LATERAL (
    SELECT a.property_id FROM game.person_addresses a
    WHERE a.person_id=p.id AND a.is_current AND a.is_primary
    ORDER BY a.valid_from DESC LIMIT 1
  ) home ON true
  WHERE j.job_no BETWEEN p_first_job AND p_last_job;

  SELECT count(*) INTO v_total_jobs FROM bp03_seed_jobs;
  IF v_total_jobs <> p_last_job-p_first_job+1 THEN
    RAISE EXCEPTION 'Employment allocation mismatch: requested %, available %',
      p_last_job-p_first_job+1,v_total_jobs;
  END IF;

  INSERT INTO game.organisation_personnel(
    organisation_id,person_id,job_title,employment_type,valid_from,is_current
  )
  SELECT organisation_id,person_id,job_title,'full_time',
         greatest(date_of_birth,date '2018-01-01'),true
  FROM bp03_seed_jobs
  ON CONFLICT DO NOTHING;

  UPDATE game.persons p
  SET occupation=j.job_title,updated_at=now()
  FROM bp03_seed_jobs j
  WHERE p.id=j.person_id;

  INSERT INTO game.person_population_memberships(
    person_id,city_id,population_category,valid_from,details
  )
  SELECT j.person_id,(SELECT id FROM game.cities WHERE code='KNG'),
         CASE WHEN j.sector IN ('transport_services','logistics_warehousing')
              THEN 'transport_worker' ELSE 'commercial_worker' END,
         greatest(j.date_of_birth,date '2018-01-01'),
         jsonb_build_object('business_number',j.business_number,'sector',j.sector,
                            'employment_cohort','KNG-2026-BASELINE')
  FROM bp03_seed_jobs j
  WHERE NOT EXISTS (
    SELECT 1 FROM game.person_population_memberships pm
    WHERE pm.person_id=j.person_id
      AND pm.population_category=CASE WHEN j.sector IN ('transport_services','logistics_warehousing')
                                      THEN 'transport_worker' ELSE 'commercial_worker' END
      AND pm.valid_to IS NULL
  );

  INSERT INTO game.person_life_events(
    person_id,event_type,effective_on,organisation_id,details
  )
  SELECT j.person_id,'employment_started',
         greatest(j.date_of_birth,date '2018-01-01'),j.organisation_id,
         jsonb_build_object('business_number',j.business_number,'job_title',j.job_title,
                            'source','Kingswell BP-03 business workforce seed')
  FROM bp03_seed_jobs j
  WHERE NOT EXISTS (
    SELECT 1 FROM game.person_life_events le
    WHERE le.person_id=j.person_id AND le.event_type='employment_started'
      AND le.organisation_id=j.organisation_id
  );

  INSERT INTO game.person_routines(
    person_id,routine_category,activity_type,day_of_week,start_time,end_time,
    crosses_midnight,location_property_id,destination_property_id,
    priority,confidence,routine_source,details
  )
  SELECT j.person_id,'work','work',d.dow,time '09:00',time '17:00',false,
         j.work_property_id,j.home_property_id,4,0.850,'npc_generated',
         jsonb_build_object('business_number',j.business_number,'job_title',j.job_title,
                            'work_pattern','weekday')
  FROM bp03_seed_jobs j
  CROSS JOIN generate_series(1,5) d(dow)
  WHERE NOT EXISTS (
    SELECT 1 FROM game.person_routines r
    WHERE r.person_id=j.person_id AND r.routine_category='work'
      AND r.day_of_week=d.dow AND r.routine_status='active'
  );

  RETURN jsonb_build_object(
    'job_start',p_first_job,'job_end',p_last_job,
    'employees',v_total_jobs,'work_routines',v_total_jobs*5
  );
END;
$$;

REVOKE ALL ON FUNCTION game.seed_kingswell_population_unit_batch(integer,integer) FROM PUBLIC, anon, authenticated;
REVOKE ALL ON FUNCTION game.seed_kingswell_business_employment_batch(integer,integer) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION game.seed_kingswell_population_unit_batch(integer,integer) TO service_role;
GRANT EXECUTE ON FUNCTION game.seed_kingswell_business_employment_batch(integer,integer) TO service_role;
