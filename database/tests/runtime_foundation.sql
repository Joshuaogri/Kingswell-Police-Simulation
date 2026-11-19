-- Runtime foundation regression test. Run against a disposable/test database.
-- Every write is rolled back; the live game clock and event history remain unchanged.
begin;
do $test$
declare
  r jsonb;
  t timestamptz;
begin
  r := game.submit_command('Runtime status test','status','{}'::jsonb,'runtime-test-status-0001');
  if r->>'ok' <> 'true' or r->>'clock_initialized' <> 'false' then
    raise exception 'Status test failed: %', r;
  end if;

  r := game.submit_command('Reject decimal duration','advance_time','{"minutes":1.5}'::jsonb,'runtime-test-decimal-0001');
  if r->>'code' <> 'invalid_duration' then raise exception 'Decimal duration validation failed: %', r; end if;

  r := game.submit_command('Advance before clock setup','advance_time','{"minutes":60}'::jsonb,'runtime-test-no-clock-0001');
  if r->>'code' <> 'clock_not_initialized' then
    raise exception 'Uninitialized-clock guard failed: %', r;
  end if;

  r := game.submit_command('Initialize test clock','initialize_clock','{"start_at":"2030-04-05T08:00:00Z"}'::jsonb,'runtime-test-clock-init-0001');
  if r->>'ok' <> 'true' then raise exception 'Clock initialization failed: %', r; end if;

  r := game.submit_command('Initialize test clock','initialize_clock','{"start_at":"2030-04-05T08:00:00Z"}'::jsonb,'runtime-test-clock-init-0001');
  if r->>'duplicate' <> 'true' then raise exception 'Idempotent retry failed: %', r; end if;

  r := game.submit_command('Different command, same key','help','{}'::jsonb,'runtime-test-clock-init-0001');
  if r->>'code' <> 'idempotency_conflict' then raise exception 'Idempotency conflict failed: %', r; end if;

  r := game.submit_command('Advance test clock','advance_time','{"minutes":60,"reason":"automated regression test"}'::jsonb,'runtime-test-advance-0001');
  if r->>'ok' <> 'true' or r->>'advanced_minutes' <> '60' then
    raise exception 'Time advancement failed: %', r;
  end if;

  select current_game_time into t from game.simulation_state where id=1;
  if t <> '2030-04-05T09:00:00Z'::timestamptz then raise exception 'Wrong resulting time: %', t; end if;

  r := game.submit_command('Reject oversized time advance','advance_time','{"minutes":1441}'::jsonb,'runtime-test-oversized-0001');
  if r->>'code' <> 'duration_out_of_range' then raise exception 'Duration guard failed: %', r; end if;

  if (select count(*) from game.game_clock_history) <> 2 then raise exception 'Expected two clock history entries'; end if;
  if (select count(*) from game.game_events where event_key like 'runtime.clock.%') <> 2 then raise exception 'Expected two runtime clock events'; end if;
end;
$test$;
rollback;
