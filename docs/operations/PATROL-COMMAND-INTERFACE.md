# Patrol command interface and beat coverage

Patrol operations are now available through the same natural-language command path as dispatch and scene operations. Commands are submitted through `game.execute_text_command` and retain the existing command ledger/idempotency behavior.

## Commands

- `assign beat UNIT_REF to BEAT_REF because REASON`
- `schedule patrol SCHEDULE_REF UNIT_REF in BEAT_REF from 2026-11-20T13:30:00+00:00 to 2026-11-20T16:00:00+00:00`
- `start patrol UNIT_REF because REASON`
- `end patrol UNIT_REF because REASON`
- `patrol status` (also `patrol coverage` or `beat coverage`)

Schedule timestamps must be ISO-8601 timestamps with timezone offsets. The current command grammar schedules a unit/beat time window; an optional roster reference remains available through the underlying database function but is not yet accepted by this concise command form.

The coverage report lists every active beat, active on-patrol units and schedule window, and covered/uncovered totals. A beat is counted covered only while a unit is actively on patrol on that beat; a scheduled but not commenced patrol does not count as coverage.

All commands use the established command ledger and idempotency keys. Patrol operations do not advance fictional time. The regression test uses temporary fixtures in a transaction ending in ROLLBACK.

Regression: `database/tests/kingswell_patrol_command_interface.sql`.
