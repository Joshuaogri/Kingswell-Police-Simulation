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
- `acknowledge PERSONNEL_REF for INCIDENT_REF`
- `arrive PERSONNEL_REF at INCIDENT_REF`
- `establish scene SCENE_REF at INCIDENT_REF by PERSONNEL_REF because REASON`
- `take command PERSONNEL_REF of SCENE_REF`
- `scene update PERSONNEL_REF for SCENE_REF: TEXT`
- `field report PERSONNEL_REF for INCIDENT_REF [at SCENE_REF]: TEXT`
- `request resource PERSONNEL_REF for SCENE_REF: RESOURCE_TYPE | REASON`
- `scene entry PERSONNEL_REF into SCENE_REF for PURPOSE`
- `scene exit PERSONNEL_REF from SCENE_REF for PURPOSE`
- `scene safety PERSONNEL_REF for SCENE_REF: HAZARDS | CONTROLS | RESIDUAL RISK`
- `set boundary PERSONNEL_REF for SCENE_REF: DESCRIPTION | REASON`

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

This is initial BP-11/BP-12 functionality, not a complete dispatch centre or incident lifecycle. Unit dispatch is now implemented through `dispatch UNIT_REF to INCIDENT_REF`. It requires an active unit, an active roster covering the current fictional time, active employed personnel assigned to that roster, including temporary cross-unit attachments, an active duty assignment and no conflicting existing deployment. Each eligible officer receives an incident-deployment record; the incident and originating call move to `dispatched`. No arrival is assumed. Qualification/authorisation checks, vehicle/resource availability, dispatch supervisor authority, radio acknowledgement integration and incident closure remain outstanding. Each dispatched officer can now acknowledge individually (`dispatched` → `responding`) and report arrival (`responding` → `on_scene`). Arrival records the fictional time, writes dispatch and game events, and moves the incident from `dispatched` to `attending` on first arrival. An officer cannot arrive before acknowledging, and retries are idempotent.

## Clock and event history
The singleton `game.simulation_state` row is paused and its fictional time remains unset until explicitly configured. Manual time advancement is a deliberate player command. Leaving ChatGPT does not advance the game. No autonomous event processor or NPC scheduler is active yet.

## Security boundary
The command functions use invoker rights, are in the private `game` schema, and are executable by `service_role` only; authenticated and anonymous roles have no execute grant. No public Edge Function is deployed. Player authentication/session mapping and the fictional officer identity/authority model must be implemented before exposing a player-facing privileged endpoint. No service-role secret belongs in GitHub or client code.

## Verification
- `database/tests/runtime_foundation.sql` — command ledger, idempotency, clock guards, advancement, event history and duration validation.
- `database/tests/text_interpreter_dispatch.sql` — text parsing, call/incident creation, event linkage, duplicate prevention, unknown-command rejection and invalid-priority rejection.
- `database/tests/unit_dispatch.sql` — roster eligibility, deployment creation, incident/call state changes, dispatch event history, help catalogue and idempotent retry.
- `database/tests/dispatch_acknowledgement_arrival.sql` — acknowledgement/arrival parsing, required state order, fictional timestamps, incident attendance, event history and idempotent retries.

All three scripts run in a transaction and roll back all generated test records.


## Scene control and field reporting

Initial BP-12/BP-22 scene and field workflows are now implemented through the explicit command parser and the `game.execute_scene_action` handler. An officer must be actively employed and have an on-scene deployment at the incident to establish scene control, take scene command, submit a field report, add a scene update or request resources. Scene creation records a unique scene reference, originating incident, location, designation reason, confidence, initial controlled status, scene manager and fictional control timestamps. Scene command transfers are recorded as separate activity and game events.

Scene activity entries and officer field reports are separately stored and linked to the originating incident/scene. Scene entry and exit events record personnel, zone, purpose and fictional time; unmatched exits and duplicate entries are rejected. A resource request is recorded with type, quantity, priority and reason as `requested`; this does not falsely imply approval, allocation or deployment. All command retries are idempotent. The new tables have RLS enabled and remain inside the private `game` schema.

Supported scene/field commands are listed above. The regression suite is `database/tests/scene_control_field_reports.sql`; it covers scene creation, command transfer, field updates/reports, resource requests, access-log pairing and invalid resource quantities. Scene safety assessments, boundary/zone management, multi-agency attendance, specialist examination plans, formal evidence handover, release/reopening and resource approval/deployment remain future work.


## Scene safety and boundary control

A deployed officer recorded on scene can append a safety assessment describing hazards, people at risk, controls taken and residual risk. The scene's safety status updates to assessed, while the assessment itself remains a separate historical record. The current scene manager can set or revise the scene boundary. Each revision is retained; the prior active boundary becomes superseded, and the current boundary description is reflected on the scene record. A non-manager cannot revise the boundary. Both workflows use the fictional game clock and write scene activity/game events.

Commands: `scene safety PERSONNEL_REF for SCENE_REF: HAZARDS | CONTROLS | RESIDUAL RISK` and `set boundary PERSONNEL_REF for SCENE_REF: DESCRIPTION | REASON`. Regression script: `database/tests/scene_safety_and_boundaries.sql`. This is an initial recordkeeping layer; specialist hazard response, formal authority review, detailed zone geometry, multi-agency safety coordination, partial release and scene release/reopening remain outstanding.
