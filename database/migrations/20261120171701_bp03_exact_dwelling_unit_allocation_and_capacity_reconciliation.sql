
-- BP-03: precise dwelling allocation and a reconciled 100,000-person housing capacity.
ALTER TABLE game.households
  ADD COLUMN primary_building_unit_id uuid
  REFERENCES game.building_units(id) ON DELETE RESTRICT;

ALTER TABLE game.person_addresses
  ADD COLUMN building_unit_id uuid
  REFERENCES game.building_units(id) ON DELETE RESTRICT;

CREATE INDEX households_primary_building_unit_idx
  ON game.households(primary_building_unit_id)
  WHERE primary_building_unit_id IS NOT NULL;

CREATE INDEX person_addresses_building_unit_idx
  ON game.person_addresses(building_unit_id)
  WHERE building_unit_id IS NOT NULL;

CREATE UNIQUE INDEX households_one_active_household_per_dwelling
  ON game.households(primary_building_unit_id)
  WHERE household_status='active' AND primary_building_unit_id IS NOT NULL;

CREATE OR REPLACE FUNCTION game.validate_household_dwelling_unit()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, game
AS $$
DECLARE
  v_property_id uuid;
  v_use_class text;
BEGIN
  IF NEW.primary_building_unit_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT b.property_id, up.use_class
    INTO v_property_id, v_use_class
  FROM game.building_units bu
  JOIN game.buildings b ON b.id=bu.building_id
  JOIN game.building_unit_profiles up ON up.building_unit_id=bu.id
  WHERE bu.id=NEW.primary_building_unit_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Household dwelling unit must reference an existing profiled building unit';
  END IF;
  IF v_use_class <> 'dwelling' THEN
    RAISE EXCEPTION 'Household primary unit must be classified as a dwelling';
  END IF;
  IF NEW.primary_property_id IS NULL THEN
    NEW.primary_property_id := v_property_id;
  ELSIF NEW.primary_property_id <> v_property_id THEN
    RAISE EXCEPTION 'Household property does not match its primary building unit';
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER households_validate_dwelling_unit
BEFORE INSERT OR UPDATE OF primary_building_unit_id, primary_property_id
ON game.households
FOR EACH ROW EXECUTE FUNCTION game.validate_household_dwelling_unit();

CREATE OR REPLACE FUNCTION game.validate_person_address_dwelling_unit()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, game
AS $$
DECLARE
  v_property_id uuid;
  v_use_class text;
  v_household_unit_id uuid;
BEGIN
  IF NEW.building_unit_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT b.property_id, up.use_class
    INTO v_property_id, v_use_class
  FROM game.building_units bu
  JOIN game.buildings b ON b.id=bu.building_id
  JOIN game.building_unit_profiles up ON up.building_unit_id=bu.id
  WHERE bu.id=NEW.building_unit_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Person address unit must reference an existing profiled building unit';
  END IF;
  IF NEW.property_id <> v_property_id THEN
    RAISE EXCEPTION 'Person address property does not match its building unit';
  END IF;
  IF NEW.address_role='residence' AND v_use_class <> 'dwelling' THEN
    RAISE EXCEPTION 'A residential address must reference a dwelling unit';
  END IF;

  IF NEW.address_role='residence' AND NEW.is_current THEN
    SELECT h.primary_building_unit_id INTO v_household_unit_id
    FROM game.household_memberships hm
    JOIN game.households h ON h.id=hm.household_id
    WHERE hm.person_id=NEW.person_id AND hm.is_primary AND hm.valid_to IS NULL
      AND h.household_status='active'
    ORDER BY hm.valid_from DESC
    LIMIT 1;
    IF v_household_unit_id IS NOT NULL AND v_household_unit_id <> NEW.building_unit_id THEN
      RAISE EXCEPTION 'Current primary residence unit must match the person primary household unit';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER person_addresses_validate_dwelling_unit
BEFORE INSERT OR UPDATE OF building_unit_id, property_id, address_role, is_current, person_id
ON game.person_addresses
FOR EACH ROW EXECUTE FUNCTION game.validate_person_address_dwelling_unit();

CREATE OR REPLACE FUNCTION game.enforce_household_dwelling_capacity()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, game
AS $$
DECLARE
  v_unit_id uuid;
  v_capacity integer;
  v_existing integer;
BEGIN
  IF NEW.valid_to IS NOT NULL THEN
    RETURN NEW;
  END IF;

  SELECT h.primary_building_unit_id, up.occupancy_capacity
    INTO v_unit_id, v_capacity
  FROM game.households h
  LEFT JOIN game.building_unit_profiles up ON up.building_unit_id=h.primary_building_unit_id
  WHERE h.id=NEW.household_id;

  IF v_unit_id IS NULL THEN
    RETURN NEW;
  END IF;
  IF v_capacity IS NULL OR v_capacity < 1 THEN
    RAISE EXCEPTION 'Dwelling unit must have a positive recorded occupancy capacity';
  END IF;

  -- Serialize admissions to the same dwelling before checking its occupancy.
  PERFORM 1 FROM game.building_units WHERE id=v_unit_id FOR UPDATE;

  SELECT count(*) INTO v_existing
  FROM game.household_memberships hm
  WHERE hm.household_id=NEW.household_id AND hm.valid_to IS NULL
    AND (TG_OP <> 'UPDATE' OR hm.id <> NEW.id);

  IF v_existing + 1 > v_capacity THEN
    RAISE EXCEPTION 'Dwelling occupancy capacity exceeded: capacity %, current %, attempted %',
      v_capacity, v_existing, v_existing+1;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER household_memberships_enforce_dwelling_capacity
BEFORE INSERT OR UPDATE OF household_id, valid_to
ON game.household_memberships
FOR EACH ROW EXECUTE FUNCTION game.enforce_household_dwelling_capacity();

-- BP-02/BP-04 set a 100,000 permanent-resident baseline. The previous
-- 24,512 x 4 profile capacity was only 98,048. Increase the planning limit
-- to five in 244 dwellings in each of Kingswell's eight residential
-- neighbourhoods, distributed evenly and deterministically.
DO $$
DECLARE
  v_neighbourhoods integer;
  v_updated integer;
BEGIN
  SELECT count(*) INTO v_neighbourhoods
  FROM (
    SELECT p.neighbourhood_id
    FROM game.building_unit_profiles up
    JOIN game.building_units bu ON bu.id=up.building_unit_id
    JOIN game.buildings b ON b.id=bu.building_id
    JOIN game.properties p ON p.id=b.property_id
    WHERE up.use_class='dwelling'
    GROUP BY p.neighbourhood_id
  ) n;
  IF v_neighbourhoods <> 8 THEN
    RAISE EXCEPTION 'Expected eight residential neighbourhoods; found %',v_neighbourhoods;
  END IF;

  WITH ranked AS (
    SELECT up.building_unit_id,
           row_number() OVER (PARTITION BY p.neighbourhood_id ORDER BY bu.unit_ref)::integer rn
    FROM game.building_unit_profiles up
    JOIN game.building_units bu ON bu.id=up.building_unit_id
    JOIN game.buildings b ON b.id=bu.building_id
    JOIN game.properties p ON p.id=b.property_id
    WHERE up.use_class='dwelling'
  )
  UPDATE game.building_unit_profiles up
  SET occupancy_capacity=5,
      unit_description=concat_ws(' ',nullif(up.unit_description,''),
        'Planning occupancy limit: five residents for selected larger-family households.')
  FROM ranked r
  WHERE r.building_unit_id=up.building_unit_id AND r.rn<=244;

  GET DIAGNOSTICS v_updated = ROW_COUNT;
  IF v_updated <> 1952 THEN
    RAISE EXCEPTION 'Expected to increase capacity in 1,952 dwellings; updated %',v_updated;
  END IF;
END;
$$;

DO $$
DECLARE
  v_units integer;
  v_capacity integer;
BEGIN
  SELECT count(*),sum(occupancy_capacity)
    INTO v_units,v_capacity
  FROM game.building_unit_profiles
  WHERE use_class='dwelling';
  IF v_units <> 24512 OR v_capacity <> 100000 THEN
    RAISE EXCEPTION 'BP-03 housing capacity reconciliation failed: units %, capacity %',v_units,v_capacity;
  END IF;
END;
$$;
