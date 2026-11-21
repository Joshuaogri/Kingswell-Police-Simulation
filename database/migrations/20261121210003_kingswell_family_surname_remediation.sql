SET TRANSACTION READ WRITE;
-- Stable kinship components; housemate edges are intentionally excluded.
CREATE TEMP TABLE kng_family_components ON COMMIT DROP AS
WITH RECURSIVE edges(a,b) AS (
  SELECT person_id,related_person_id FROM game.person_relationships
  WHERE relationship_type IN ('relative','partner','child_parent','parent_child','sibling')
  UNION
  SELECT related_person_id,person_id FROM game.person_relationships
  WHERE relationship_type IN ('relative','partner','child_parent','parent_child','sibling')
), reach(start_id,node_id) AS (
  SELECT id,id FROM game.persons
  UNION
  SELECT r.start_id,e.b FROM reach r JOIN edges e ON e.a=r.node_id
), roots AS (
  SELECT node_id,min(start_id::text)::uuid root_id FROM reach GROUP BY node_id
)
SELECT node_id person_id,root_id FROM roots;

CREATE TEMP TABLE kng_family_names ON COMMIT DROP AS
WITH fam AS (SELECT DISTINCT root_id FROM kng_family_components),
pool AS (
 SELECT surname,normalised_name,
        row_number() OVER(ORDER BY md5(normalised_name),normalised_name) rn
 FROM game.surname_name_catalog
 WHERE normalised_name NOT IN
   (SELECT game.normalise_entity_name_v2(family_name) FROM game.persons)
), ranked AS (
 SELECT root_id,row_number() OVER(ORDER BY root_id) rn FROM fam
)
SELECT r.root_id,r.rn,p.surname,p.normalised_name
FROM ranked r JOIN pool p USING(rn);

DO $$ BEGIN
 IF (SELECT count(*) FROM kng_family_names) <>
    (SELECT count(DISTINCT root_id) FROM kng_family_components)
 THEN RAISE EXCEPTION 'Not enough unique surnames for family components'; END IF;
END $$;

CREATE TEMP TABLE kng_old_person_names ON COMMIT DROP AS
SELECT id,person_ref,family_name FROM game.persons;

INSERT INTO game.person_families
 (id,family_ref,family_name,normalised_family_name,name_source,family_status)
SELECT gen_random_uuid(),'KNG-FAM-'||lpad(rn::text,6,'0'),
       surname,normalised_name,'curated_catalog','active'
FROM kng_family_names ORDER BY rn;

UPDATE game.persons p
SET family_id=f.id, family_name=f.family_name, updated_at=now()
FROM kng_family_components c
JOIN kng_family_names n ON n.root_id=c.root_id
JOIN game.person_families f ON f.normalised_family_name=n.normalised_name
WHERE p.id=c.person_id;

INSERT INTO game.canonical_name_corrections
 (entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,correction_reason,migration_ref)
SELECT 'person',o.id,o.person_ref,'family_name',o.family_name,p.family_name,
 'Distinct surname assigned to the actual kinship-connected family; housemate links excluded',
 '20261121210003_kingswell_realistic_name_remediation'
FROM kng_old_person_names o JOIN game.persons p ON p.id=o.id
WHERE o.family_name IS DISTINCT FROM p.family_name;

ALTER TABLE game.persons ALTER COLUMN family_id SET NOT NULL;
ALTER TABLE game.persons ALTER COLUMN family_name SET NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS persons_unique_full_display_name_v2_uidx
ON game.persons (game.normalise_entity_name_v2(
 concat_ws(' ',nullif(btrim(given_name),''),nullif(btrim(middle_names),''),nullif(btrim(family_name),''))));

DO $$
DECLARE duplicates bigint; unassigned bigint; families bigint; components bigint;
BEGIN
 SELECT count(*) INTO duplicates FROM (
  SELECT game.normalise_entity_name_v2(concat_ws(' ',given_name,nullif(middle_names,''),family_name)) n
  FROM game.persons GROUP BY 1 HAVING count(*)>1
 ) d;
 SELECT count(*) INTO unassigned FROM game.persons WHERE family_id IS NULL;
 SELECT count(*) INTO families FROM game.person_families;
 SELECT count(DISTINCT root_id) INTO components FROM kng_family_components;
 IF duplicates<>0 OR unassigned<>0 OR families<>components THEN
  RAISE EXCEPTION 'Family remediation validation failed: duplicate_names %, unassigned %, family_records %, components %',
   duplicates,unassigned,families,components;
 END IF;
END $$;
