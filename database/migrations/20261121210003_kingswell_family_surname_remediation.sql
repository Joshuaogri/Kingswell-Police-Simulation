SET TRANSACTION READ WRITE;
DO $remediate$
DECLARE changed_rows integer; pass_no integer:=0; duplicate_names bigint; unassigned bigint;
        component_count bigint; family_count bigint;
BEGIN
 CREATE TEMP TABLE kng_family_edges(a uuid,b uuid) ON COMMIT DROP;
 INSERT INTO kng_family_edges
 SELECT person_id,related_person_id FROM game.person_relationships
 WHERE relationship_type IN ('relative','partner','child_parent','parent_child','sibling')
 UNION
 SELECT related_person_id,person_id FROM game.person_relationships
 WHERE relationship_type IN ('relative','partner','child_parent','parent_child','sibling');
 CREATE TEMP TABLE kng_family_components(person_id uuid PRIMARY KEY,root_id uuid NOT NULL) ON COMMIT DROP;
 INSERT INTO kng_family_components SELECT id,id FROM game.persons;
 LOOP
  UPDATE kng_family_components c SET root_id=x.min_root
  FROM (
   SELECT person_id,min(root_id::text)::uuid min_root FROM (
    SELECT e.a person_id,b.root_id FROM kng_family_edges e JOIN kng_family_components b ON b.person_id=e.b
    UNION ALL
    SELECT e.b person_id,a.root_id FROM kng_family_edges e JOIN kng_family_components a ON a.person_id=e.a
   ) q GROUP BY person_id
  ) x
  WHERE c.person_id=x.person_id AND c.root_id::text>x.min_root::text;
  GET DIAGNOSTICS changed_rows=ROW_COUNT;
  pass_no:=pass_no+1;
  EXIT WHEN changed_rows=0;
  IF pass_no>100 THEN RAISE EXCEPTION 'Family component assignment did not converge'; END IF;
 END LOOP;
 CREATE TEMP TABLE kng_family_names ON COMMIT DROP AS
 WITH fam AS (SELECT DISTINCT root_id FROM kng_family_components),
 pool AS (
  SELECT surname,normalised_name,row_number() OVER(ORDER BY md5(normalised_name),normalised_name) rn
  FROM game.surname_name_catalog c
  WHERE NOT EXISTS (SELECT 1 FROM game.persons p
   WHERE game.normalise_entity_name_v2(p.family_name)=c.normalised_name)
 ),
 ranked AS (SELECT root_id,row_number() OVER(ORDER BY root_id) rn FROM fam)
 SELECT r.root_id,r.rn,p.surname,p.normalised_name FROM ranked r JOIN pool p USING(rn);
 SELECT count(DISTINCT root_id) INTO component_count FROM kng_family_components;
 SELECT count(*) INTO family_count FROM kng_family_names;
 IF component_count<>family_count THEN RAISE EXCEPTION 'Surname pool insufficient: % families, % surnames',component_count,family_count; END IF;
 CREATE TEMP TABLE kng_old_person_names ON COMMIT DROP AS
 SELECT id,person_ref,family_name FROM game.persons;
 INSERT INTO game.person_families(id,family_ref,family_name,name_source,family_status)
 SELECT gen_random_uuid(),'KNG-FAM-'||lpad(rn::text,6,'0'),surname,'curated_catalog','active'
 FROM kng_family_names ORDER BY rn;
 UPDATE game.persons p SET family_id=f.id,family_name=f.family_name,updated_at=now()
 FROM kng_family_components c JOIN kng_family_names n ON n.root_id=c.root_id
 JOIN game.person_families f ON f.normalised_family_name=n.normalised_name
 WHERE p.id=c.person_id;
 INSERT INTO game.canonical_name_corrections(entity_type,entity_id,entity_ref,field_name,previous_value,corrected_value,correction_reason,migration_ref)
 SELECT 'person',o.id,o.person_ref,'family_name',o.family_name,p.family_name,
 'Distinct surname assigned to actual kinship-connected family; housemate links excluded',
 '20261121210003_kingswell_realistic_name_remediation'
 FROM kng_old_person_names o JOIN game.persons p ON p.id=o.id
 WHERE o.family_name IS DISTINCT FROM p.family_name;
 ALTER TABLE game.persons ALTER COLUMN family_id SET NOT NULL;
 ALTER TABLE game.persons ALTER COLUMN family_name SET NOT NULL;
 CREATE UNIQUE INDEX IF NOT EXISTS persons_unique_full_display_name_v2_uidx
 ON game.persons(game.normalise_entity_name_v2(concat_ws(' ',nullif(btrim(given_name),''),nullif(btrim(middle_names),''),nullif(btrim(family_name),''))));
 SELECT count(*) INTO duplicate_names FROM (
  SELECT game.normalise_entity_name_v2(concat_ws(' ',given_name,nullif(middle_names,''),family_name)) n
  FROM game.persons GROUP BY 1 HAVING count(*)>1
 ) d;
 SELECT count(*) INTO unassigned FROM game.persons WHERE family_id IS NULL;
 IF duplicate_names<>0 OR unassigned<>0 THEN
  RAISE EXCEPTION 'Family validation failed: duplicate names %, unassigned people %',duplicate_names,unassigned;
 END IF;
END
$remediate$;