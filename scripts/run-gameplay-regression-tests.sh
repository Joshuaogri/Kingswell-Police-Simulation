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
  # Existing tests may manage their own transaction. For legacy tests without
  # either boundary, wrap the entire file in one transaction so writes cannot persist.
  has_begin=0
  has_rollback=0
  grep -Eiq '^[[:space:]]*begin[[:space:]]*;' "$test_file" && has_begin=1 || true
  grep -Eiq '^[[:space:]]*rollback[[:space:]]*;' "$test_file" && has_rollback=1 || true

  echo "::group::${test_file}"
  if ((has_begin && has_rollback)); then
    psql "$DATABASE_URL" -X --no-psqlrc -v ON_ERROR_STOP=1 -f "$test_file"
  elif ((!has_begin && !has_rollback)); then
    psql "$DATABASE_URL" -X --no-psqlrc -v ON_ERROR_STOP=1 \
      -c 'BEGIN;' -f "$test_file" -c 'ROLLBACK;'
  else
    echo "::error file=$test_file::Test has an incomplete transaction boundary."
    exit 1
  fi
  echo "::endgroup::"
  ((passed+=1))
done

echo "Gameplay regression suite passed: $passed/${#test_files[@]} SQL files."
