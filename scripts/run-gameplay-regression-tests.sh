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
failed=0
failures=()

for test_file in "${test_files[@]}"; do
  # Each test owns a transaction or is wrapped in one. A failed psql process
  # closes its connection, so PostgreSQL rolls back any still-open transaction.
  has_begin=0
  has_rollback=0
  grep -Eiq '^[[:space:]]*begin[[:space:]]*;' "$test_file" && has_begin=1 || true
  grep -Eiq '^[[:space:]]*rollback[[:space:]]*;' "$test_file" && has_rollback=1 || true

  echo "::group::${test_file}"
  if ((has_begin && has_rollback)); then
    if psql "$DATABASE_URL" -X --no-psqlrc -v ON_ERROR_STOP=1 -f "$test_file"; then
      ((passed+=1))
      echo "PASS: $test_file"
    else
      ((failed+=1))
      failures+=("$test_file")
      echo "::error file=$test_file::Regression test failed; continuing to collect remaining failures."
    fi
  elif ((!has_begin && !has_rollback)); then
    if psql "$DATABASE_URL" -X --no-psqlrc -v ON_ERROR_STOP=1 \
      -c 'BEGIN;' -f "$test_file" -c 'ROLLBACK;'; then
      ((passed+=1))
      echo "PASS: $test_file"
    else
      ((failed+=1))
      failures+=("$test_file")
      echo "::error file=$test_file::Regression test failed; continuing to collect remaining failures."
    fi
  else
    ((failed+=1))
    failures+=("$test_file (incomplete transaction boundary)")
    echo "::error file=$test_file::Test has an incomplete transaction boundary."
  fi
  echo "::endgroup::"
done

echo "Gameplay regression results: $passed passed, $failed failed, ${#test_files[@]} total."
if ((failed)); then
  printf 'FAILED: %s\n' "${failures[@]}"
  exit 1
fi
