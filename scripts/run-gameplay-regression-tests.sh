#!/usr/bin/env bash
set -Eeuo pipefail

: "${DATABASE_URL:?DATABASE_URL must point to the isolated local test database}"

# Safety guard: this runner must never be pointed at hosted Supabase.
case "$DATABASE_URL" in
  postgresql://postgres:postgres@127.0.0.1:54322/postgres|postgres://postgres:postgres@127.0.0.1:54322/postgres) ;;
  *)
    echo "::error::Refusing to run gameplay tests against a non-local database URL."
    exit 2
    ;;
esac

shopt -s nullglob
test_files=(database/tests/*.sql)
if (("${#test_files[@]}" == 0)); then
  echo "::error::No SQL regression tests found in database/tests."
  exit 1
fi

echo "Running ${#test_files[@]} Kingswell SQL regression tests against the disposable local database."
passed=0
for test_file in "${test_files[@]}"; do
  # Each regression must own a transaction and roll back its test fixtures.
  if ! grep -Eiq '^[[:space:]]*begin[[:space:]]*;' "$test_file"; then
    echo "::error file=$test_file::Regression test must begin a transaction."
    exit 1
  fi
  if ! grep -Eiq '^[[:space:]]*rollback[[:space:]]*;' "$test_file"; then
    echo "::error file=$test_file::Regression test must roll back its fixtures."
    exit 1
  fi

  echo "::group::${test_file}"
  psql "$DATABASE_URL" -X --no-psqlrc -v ON_ERROR_STOP=1 -f "$test_file"
  echo "::endgroup::"
  ((passed+=1))
done

echo "Gameplay regression suite passed: $passed/${#test_files[@]} SQL files."
