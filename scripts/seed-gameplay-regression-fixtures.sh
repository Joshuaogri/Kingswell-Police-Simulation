#!/usr/bin/env bash
set -Eeuo pipefail

: "${DATABASE_URL:?DATABASE_URL must point to the isolated local test database}"

# This fixture loader is deliberately restricted to the disposable CI database.
case "$DATABASE_URL" in
  postgresql://postgres:postgres@127.0.0.1:54322/postgres|postgres://postgres:postgres@127.0.0.1:54322/postgres) ;;
  *)
    echo "::error::Refusing to seed a non-local database URL."
    exit 2
    ;;
esac

psql_cmd=(psql "$DATABASE_URL" -X --no-psqlrc -v ON_ERROR_STOP=1)

echo "Seeding the canonical 100,000-person Kingswell population in committed batches."
for ((first=1; first<=24512; first+=1000)); do
  last=$((first+999))
  (( last > 24512 )) && last=24512
  "${psql_cmd[@]}" -c "select game.seed_kingswell_population_unit_batch($first,$last);"
done

echo "Seeding all 43,412 canonical business employment links in committed batches."
for ((first=1; first<=43412; first+=1000)); do
  last=$((first+999))
  (( last > 43412 )) && last=43412
  "${psql_cmd[@]}" -c "select game.seed_kingswell_business_employment_batch($first,$last);"
done

echo "Generating the complete BP-04 fictional world after canonical people and workforce are committed."
"${psql_cmd[@]}" -Atc "
DO \$\$
DECLARE r jsonb;
BEGIN
  r:=game.seed_bp04_complete_world();
  IF coalesce((r->>'ok')::boolean,false) IS NOT TRUE THEN
    RAISE EXCEPTION 'BP-04 complete-world seed failed: %',r;
  END IF;
  IF (SELECT count(*) FROM game.organisation_department_assignments)
     <> (SELECT count(*) FROM game.organisation_personnel) THEN
    RAISE EXCEPTION 'BP-04 structure seed did not assign every canonical employment record';
  END IF;
  IF (SELECT count(*) FROM game.building_unit_infrastructure_profiles)
     <> (SELECT count(*) FROM game.building_units) THEN
    RAISE EXCEPTION 'BP-04 infrastructure seed did not cover every building unit';
  END IF;
END
\$\$;
"

echo "Verifying deterministic fixture totals."
"${psql_cmd[@]}" -Atc "
DO \$\$
BEGIN
  IF (SELECT count(*) FROM game.persons) <> 100000 THEN
    RAISE EXCEPTION 'Expected 100000 seeded persons; found %', (SELECT count(*) FROM game.persons);
  END IF;
  IF (SELECT count(*) FROM game.organisation_personnel) <> 43412 THEN
    RAISE EXCEPTION 'Expected 43412 employment links; found %', (SELECT count(*) FROM game.organisation_personnel);
  END IF;
  IF (SELECT count(DISTINCT job_title) FROM game.organisation_personnel) <> 13 THEN
    RAISE EXCEPTION 'Expected 13 canonical employment titles; found %', (SELECT count(DISTINCT job_title) FROM game.organisation_personnel);
  END IF;
END
\$\$;
"
echo "Kingswell gameplay fixtures seeded and verified."
