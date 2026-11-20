# Arrest, transport, booking and custody — implementation update

**Status:** Implemented, deployed and verified on 2026-11-20.

## Delivered

- Case-linked arrest execution for an existing case suspect/person of interest.
- Recorded arrest basis, authority reference, grounds, location, force, injury/complaint, warnings, witnesses and body-camera reference.
- Append-only arrest event history.
- Suspect transport legs with explicit duration, departure/arrival timestamps and fictional clock-history entries.
- Custody booking linked to the arrest, case and existing person record.
- Identity check, risk assessment, health/welfare screening, medication disclosure, safeguarding notes and cell location.
- Detainee property inventory; property retained as evidence creates an item in the existing case evidence register.
- Append-only custody welfare checks and operational events.
- Final release or transfer state with linked arrest/custody event records.
- Case-level arrest retrieval and consolidated case-dossier integration.
- Idempotent player commands, active-personnel attribution, case-access checks, private-schema access and RLS.

## Player commands

- `arrest execute`
- `arrest transport`
- `custody book`
- `custody property`
- `custody check`
- `custody event`
- `custody release`
- `custody transfer`
- `case arrests`

Full syntax: [ARREST-TRANSPORT-BOOKING-CUSTODY.md](../operations/ARREST-TRANSPORT-BOOKING-CUSTODY.md).

## Fictional clock

Only transport advances the clock, and only by the duration explicitly entered by the player (1–240 minutes). A `game_clock_history` row records the previous time, resulting time, duration and reason. Arrest, booking, property, welfare, event, release and retrieval commands do not advance time.

## Verification

The rollback-only test `database/tests/kingswell_arrest_custody_workflow.sql` executes the actual text command interface using two temporary assigned officers, a temporary suspect and case, and a temporary clock. It verifies:
- Arrest creation and idempotent replay.
- Transport duration persistence and exact fictional clock advancement.
- Custody booking and property inventory.
- Retention of custody property in the shared evidence register.
- Welfare checks and custody events.
- Case arrest retrieval and dossier integration.
- Release transition and final status.
- Append-only arrest and welfare-check histories.
- Help registration and no unintended clock advancement.

The test passed and rolled back all temporary fixtures and clock changes. The live game has no seeded police personnel or test arrest/custody records, and its fictional clock remains uninitialized.

## Database controls

Seven new tables are in the private `game` schema, all with RLS enabled. `anon` and `authenticated` have no table-read privileges; `service_role` has the required runtime access. The new tables have supporting indexes for all foreign keys. Arrest and custody event histories, transport legs, property inventory and welfare-check records are append-only.
