-- BP-03 live population acceptance checks.
-- Read-only: safe to run against the populated live city. Returns measured values;
-- no test fixtures, clock changes or persistent writes are performed.

-- 1. Canonical resident identity and core profile completeness.
SELECT count(*) AS people,
       count(DISTINCT person_ref) AS unique_person_refs,
       count(*) FILTER (WHERE given_name IS NULL OR family_name IS NULL
                         OR date_of_birth IS NULL OR birth_city_id IS NULL
                         OR personality_profile IS NULL OR behaviour_profile IS NULL) AS incomplete_profiles
FROM game.persons
WHERE person_ref LIKE 'KNG-P-%';

-- 2. Household population and exact dwelling capacity.
SELECT count(*) AS households,
       count(*) FILTER (WHERE household_status='active') AS active_households,
       count(*) FILTER (WHERE primary_building_unit_id IS NULL) AS households_without_unit
FROM game.households
WHERE household_ref LIKE 'KWHH-KNG-%';

SELECT count(*) AS dwelling_occupancy_mismatches
FROM (
  SELECT h.id,up.occupancy_capacity,count(hm.id) AS occupants
  FROM game.households h
  JOIN game.building_unit_profiles up ON up.building_unit_id=h.primary_building_unit_id
  LEFT JOIN game.household_memberships hm ON hm.household_id=h.id AND hm.valid_to IS NULL
  WHERE h.household_ref LIKE 'KWHH-KNG-%'
  GROUP BY h.id,up.occupancy_capacity
  HAVING count(hm.id)<>up.occupancy_capacity
) q;

-- 3. One current primary household membership and exact home address per resident.
SELECT count(*) AS current_household_memberships
FROM game.household_memberships hm
JOIN game.persons p ON p.id=hm.person_id
WHERE p.person_ref LIKE 'KNG-P-%' AND hm.is_primary AND hm.valid_to IS NULL;

SELECT count(*) AS current_primary_addresses,
       count(*) FILTER (WHERE a.building_unit_id IS NULL) AS addresses_without_unit
FROM game.person_addresses a
JOIN game.persons p ON p.id=a.person_id
WHERE p.person_ref LIKE 'KNG-P-%' AND a.is_current AND a.is_primary;

SELECT count(*) AS address_household_unit_mismatches
FROM game.person_addresses a
JOIN game.household_memberships hm ON hm.person_id=a.person_id
  AND hm.is_primary AND hm.valid_to IS NULL
JOIN game.households h ON h.id=hm.household_id
WHERE a.is_current AND a.is_primary
  AND (a.building_unit_id<>h.primary_building_unit_id OR a.property_id<>h.primary_property_id);

-- 4. Distinct city population summary (categories intentionally overlap).
SELECT * FROM game.get_population_summary('KNG');

-- 5. Business employee counts must match every BP-04 business estimate.
SELECT sum(bp.estimated_employee_count) AS estimated_business_jobs,
       count(op.id) AS actual_current_employment_links,
       count(DISTINCT op.person_id) AS distinct_current_employees
FROM game.business_profiles bp
LEFT JOIN game.organisation_personnel op
  ON op.organisation_id=bp.organisation_id AND op.is_current;

SELECT count(*) AS businesses_with_headcount_mismatch
FROM (
  SELECT bp.organisation_id,bp.estimated_employee_count,count(op.id) AS actual
  FROM game.business_profiles bp
  LEFT JOIN game.organisation_personnel op
    ON op.organisation_id=bp.organisation_id AND op.is_current
  GROUP BY bp.organisation_id,bp.estimated_employee_count
  HAVING count(op.id)<>bp.estimated_employee_count
) q;

-- 6. Weekly routines: seven sleep records per resident and five work records per employee.
SELECT day_of_week,count(*) AS sleep_routines,
       count(DISTINCT person_id) AS residents_with_sleep_routine
FROM game.person_routines
WHERE routine_category='sleep' AND routine_status='active'
GROUP BY day_of_week ORDER BY day_of_week;

SELECT count(*) AS weekday_work_routines,
       count(DISTINCT person_id) AS employed_people_with_work_routines
FROM game.person_routines
WHERE routine_category='work' AND routine_status='active';

SELECT count(*) AS employees_not_assigned_five_weekday_routines
FROM (
  SELECT op.person_id,count(r.id) AS workdays
  FROM game.organisation_personnel op
  LEFT JOIN game.person_routines r ON r.person_id=op.person_id
    AND r.routine_category='work' AND r.routine_status='active'
  WHERE op.is_current
  GROUP BY op.person_id
  HAVING count(r.id)<>5
) q;

-- 7. Individual life-history and relationship coverage.
SELECT count(*) AS birth_events,
       count(DISTINCT person_id) AS people_with_birth_events
FROM game.person_life_events
WHERE event_type='birth';

SELECT count(*) AS relationship_records,
       count(*) FILTER (WHERE person_id=related_person_id) AS self_relationships
FROM game.person_relationships;

-- 8. Fictional time must remain stopped until the player starts the simulation.
SELECT current_game_time AS fictional_clock
FROM game.simulation_state
WHERE id=1;
