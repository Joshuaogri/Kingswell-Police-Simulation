CREATE UNIQUE INDEX IF NOT EXISTS organisation_personnel_one_current_person_org_uidx
ON game.organisation_personnel(organisation_id,person_id)
WHERE is_current;

CREATE UNIQUE INDEX IF NOT EXISTS person_routines_one_current_seeded_work_pattern_uidx
ON game.person_routines(person_id,day_of_week)
WHERE routine_category='work' AND routine_status='active' AND (details ? 'business_number');

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
  v_employment_rows integer;
  v_routine_rows integer;
BEGIN
  IF p_first_job < 1 OR p_last_job < p_first_job OR p_last_job > 43412
     OR p_last_job-p_first_job > 999 THEN
    RAISE EXCEPTION 'Employment batch must cover 1-1000 jobs within 1-43412';
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
  ON CONFLICT (organisation_id,person_id) WHERE is_current DO NOTHING;
  GET DIAGNOSTICS v_employment_rows = ROW_COUNT;

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
  ON CONFLICT (person_id,day_of_week)
  WHERE routine_category='work' AND routine_status='active' AND (details ? 'business_number')
  DO NOTHING;
  GET DIAGNOSTICS v_routine_rows = ROW_COUNT;

  RETURN jsonb_build_object(
    'job_start',p_first_job,'job_end',p_last_job,
    'employees',v_total_jobs,'employment_links',v_employment_rows,
    'work_routines',v_routine_rows
  );
END;
$$;

REVOKE ALL ON FUNCTION game.seed_kingswell_business_employment_batch(integer,integer) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION game.seed_kingswell_business_employment_batch(integer,integer) TO service_role;
