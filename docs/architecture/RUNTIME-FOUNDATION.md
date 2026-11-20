# Runtime foundation

**Status:** Initial command interpreter and emergency-call intake are implemented and transaction-tested. Kingswell remains an entirely fictional game; these systems create fictional records only.

## Architecture
- ChatGPT is the player-facing text interface.
- Supabase's private `game` schema is authoritative for persisted game state.
- GitHub `main` holds migrations, tests, documentation and implementation history.
- Fictional operational timestamps use the configured game clock. Real-world database timestamps are audit metadata only and never advance game time.

## Text command interpreter
`game.interpret_text_command(text)` translates a deliberately small, explicit command grammar into typed commands. `game.execute_text_command(text, idempotency_key, ...)` interprets the text and submits the result through `game.submit_command(...)`.

Supported player text:
- `help` or `commands`
- `status`, `game status` or `clock status`
- `advance time 30 minutes` (whole minutes, 1–1,440)
- `911 <caller report> at <location>`
- `call <caller report> at <location>`
- `report <caller report> at <location>`
- `radio <radio report> at <location>`
- `dispatch UNIT_REF to INCIDENT_REF`

The call grammar is intentionally narrow. It does not guess missing locations, turn questions into actions, invent caller identities or dispatch officers automatically. Unrecognised text is logged as a rejected command. Idempotency keys prevent duplicate execution on retries.

## Initial emergency-call workflow
A recognised call command:
1. Validates the summary, location, channel and optional priority/caller reference.
2. Requires the fictional game clock to have been explicitly initialized.
3. Creates one incident in `game.incidents`.
4. Creates its linked call record in `game.dispatch_calls`.
5. Creates a `call_received` dispatch event and linked `game_events` record.
6. Returns the call and incident references and confirms that no unit has yet been dispatched.

Priority is 1 (highest) through 5 (lowest); omitted priority defaults to 3. Malformed supplied values are rejected. Call and incident timestamps use the same authoritative fictional game time. All inserts and the command outcome are committed in one transaction.

This is initial BP-11/BP-12 functionality, not a complete dispatch centre or incident lifecycle. Unit dispatch is now implemented through `dispatch UNIT_REF to INCIDENT_REF`. It requires an active unit, an active roster covering the current fictional time, active employed personnel assigned to that roster, including temporary cross-unit attachments, an active duty assignment and no conflicting existing deployment. Each eligible officer receives an incident-deployment record; the incident and originating call move to `dispatched`. No arrival is assumed. Qualification/authorisation checks, vehicle/resource availability, dispatch supervisor authority, radio acknowledgements, arrival, scene management and incident closure remain outstanding.

## Clock and event history
The singleton `game.simulation_state` row is paused and its fictional time remains unset until explicitly configured. Manual time advancement is a deliberate player command. Leaving ChatGPT does not advance the game. No autonomous event processor or NPC scheduler is active yet.

## Security boundary
The command functions use invoker rights, are in the private `game` schema, and are executable by `service_role` only; authenticated and anonymous roles have no execute grant. No public Edge Function is deployed. Player authentication/session mapping and the fictional officer identity/authority model must be implemented before exposing a player-facing privileged endpoint. No service-role secret belongs in GitHub or client code.

## Verification
- `database/tests/runtime_foundation.sql` — command ledger, idempotency, clock guards, advancement, event history and duration validation.
- `database/tests/text_interpreter_dispatch.sql` — text parsing, call/incident creation, event linkage, duplicate prevention, unknown-command rejection and invalid-priority rejection.
- `database/tests/unit_dispatch.sql` — roster eligibility, deployment creation, incident/call state changes, dispatch event history, help catalogue and idempotent retry.

All three scripts run in a transaction and roll back all generated test records.
