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

# Bound individual SQL statements, lock waits, and total test runtime so one
# pathological query cannot leave the CI job apparently running forever.
TEST_TIMEOUT_SECONDS="${TEST_TIMEOUT_SECONDS:-180}"
TOTAL_TIMEOUT_SECONDS="${TOTAL_TIMEOUT_SECONDS:-1500}"
if ! [[ "$TEST_TIMEOUT_SECONDS" =~ ^[1-9][0-9]*$ && "$TOTAL_TIMEOUT_SECONDS" =~ ^[1-9][0-9]*$ ]]; then
  echo "::error::Test timeout values must be positive whole seconds."
  exit 2
fi

shopt -s nullglob
test_files=(database/tests/*.sql)
if (("${#test_files[@]}" == 0)); then
  echo "::error::No SQL regression tests found in database/tests."
  exit 1
fi

echo "Running ${#test_files[@]} Kingswell SQL regression tests against the disposable local database."
echo "Per-test limit: ${TEST_TIMEOUT_SECONDS}s; total suite limit: ${TOTAL_TIMEOUT_SECONDS}s."
passed=0
failed=0
failures=()
suite_started=$SECONDS

for test_file in "${test_files[@]}"; do
  elapsed=$((SECONDS-suite_started))
  if ((elapsed >= TOTAL_TIMEOUT_SECONDS)); then
    failed=$((failed+1))
    failures+=("$test_file and remaining tests (total suite timeout)")
    echo "::error::Total regression-suite timeout reached after ${elapsed}s; stopping remaining tests."
    break
  fi

  # Each test owns a transaction or is wrapped in one. A failed psql process
  # closes its connection, so PostgreSQL rolls back any still-open transaction.
  has_begin=0
  has_rollback=0
  grep -Eiq '^[[:space:]]*begin[[:space:]]*;' "$test_file" && has_begin=1 || true
  grep -Eiq '^[[:space:]]*rollback[[:space:]]*;' "$test_file" && has_rollback=1 || true

  echo "::group::${test_file}"
  echo "START $(date -u +'%Y-%m-%dT%H:%M:%SZ') — ${test_file}"
  test_started=$SECONDS
  psql_cmd=(timeout --signal=TERM --kill-after=10s "${TEST_TIMEOUT_SECONDS}s" env
    "PGOPTIONS=-c statement_timeout=${TEST_TIMEOUT_SECONDS}000 -c lock_timeout=30000"
    "PGAPPNAME=kingswell-regression")
  if ((has_begin && has_rollback)); then
    if "${psql_cmd[@]}" psql "$DATABASE_URL" -X --no-psqlrc -v ON_ERROR_STOP=1 -f "$test_file"; then
      ((passed+=1))
      echo "PASS: $test_file ($((SECONDS-test_started))s)"
    else
      rc=$?
      ((failed+=1))
      failures+=("$test_file")
      if ((rc==124 || rc==137)); then
        echo "::error file=$test_file::Test exceeded its ${TEST_TIMEOUT_SECONDS}s execution limit."
      else
        echo "::error file=$test_file::Regression test failed (exit $rc); continuing."
      fi
    fi
  elif ((!has_begin && !has_rollback)); then
    if "${psql_cmd[@]}" psql "$DATABASE_URL" -X --no-psqlrc -v ON_ERROR_STOP=1 \
      -c 'BEGIN;' -f "$test_file" -c 'ROLLBACK;'; then
      ((passed+=1))
      echo "PASS: $test_file ($((SECONDS-test_started))s)"
    else
      rc=$?
      ((failed+=1))
      failures+=("$test_file")
      if ((rc==124 || rc==137)); then
        echo "::error file=$test_file::Test exceeded its ${TEST_TIMEOUT_SECONDS}s execution limit."
      else
        echo "::error file=$test_file::Regression test failed (exit $rc); continuing."
      fi
    fi
  else
    ((failed+=1))
    failures+=("$test_file (incomplete transaction boundary)")
    echo "::error file=$test_file::Test has an incomplete transaction boundary."
  fi
  echo "::endgroup::"
done

echo "Gameplay regression results: $passed passed, $failed failed, ${#test_files[@]} discovered."
if ((failed)); then
  printf 'FAILED: %s\n' "${failures[@]}"
  exit 1
fi
