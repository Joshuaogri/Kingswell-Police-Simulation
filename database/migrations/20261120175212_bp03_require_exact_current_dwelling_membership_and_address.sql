CREATE OR REPLACE FUNCTION game.validate_household_dwelling_unit()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, game
AS $$
DECLARE
  v_property_id uuid;
  v_use_class text;
BEGIN
  IF TG_OP='UPDATE' THEN
    IF OLD.primary_building_unit_id IS DISTINCT FROM NEW.primary_building_unit_id
       AND EXISTS(SELECT 1 FROM game.household_memberships hm
                  WHERE hm.household_id=OLD.id AND hm.valid_to IS NULL) THEN
      RAISE EXCEPTION 'A household dwelling unit cannot change while current members remain assigned';
    END IF;
    IF NEW.household_status='dissolved'
       AND EXISTS(SELECT 1 FROM game.household_memberships hm
                  WHERE hm.household_id=OLD.id AND hm.valid_to IS NULL) THEN
      RAISE EXCEPTION 'Current household memberships must be closed before dissolution';
    END IF;
  END IF;

  IF NEW.primary_building_unit_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT b.property_id, up.use_class INTO v_property_id, v_use_class
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

DROP TRIGGER IF EXISTS households_validate_dwelling_unit ON game.households;
CREATE TRIGGER households_validate_dwelling_unit
BEFORE INSERT OR UPDATE OF primary_building_unit_id, primary_property_id, household_status
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
  IF NEW.address_role='residence' AND NEW.is_current AND NEW.building_unit_id IS NULL THEN
    RAISE EXCEPTION 'A current residential address must reference an exact dwelling unit';
  END IF;
  IF NEW.building_unit_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT b.property_id, up.use_class INTO v_property_id, v_use_class
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

CREATE OR REPLACE FUNCTION game.enforce_household_dwelling_capacity()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = pg_catalog, game
AS $$
DECLARE
  v_unit_id uuid;
  v_capacity integer;
  v_existing integer;
  v_status text;
BEGIN
  IF NEW.valid_to IS NOT NULL THEN
    RETURN NEW;
  END IF;

  SELECT h.primary_building_unit_id,h.household_status,up.occupancy_capacity
    INTO v_unit_id,v_status,v_capacity
  FROM game.households h
  LEFT JOIN game.building_unit_profiles up ON up.building_unit_id=h.primary_building_unit_id
  WHERE h.id=NEW.household_id;

  IF v_status IS DISTINCT FROM 'active' THEN
    RAISE EXCEPTION 'Current household membership requires an active household';
  END IF;
  IF v_unit_id IS NULL THEN
    RAISE EXCEPTION 'Current household membership requires an exact dwelling unit';
  END IF;
  IF v_capacity IS NULL OR v_capacity < 1 THEN
    RAISE EXCEPTION 'Dwelling unit must have a positive recorded occupancy capacity';
  END IF;

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
