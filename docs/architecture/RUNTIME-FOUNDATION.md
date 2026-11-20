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
- `set boundary PERSONNEL_REF for SCENE_REF: DESCRIPTION | REASON`, `resource approve|decline|fulfil|cancel PERSONNEL_REF REQUEST_REF: NOTES`, `release scene PERSONNEL_REF SCENE_REF because REASON` and `reopen scene PERSONNEL_REF SCENE_REF because REASON`

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

Scene activity entries and officer field reports are separately stored and linked to the originating incident/scene. Scene entry and exit events record personnel, zone, purpose and fictional time; unmatched exits and duplicate entries are rejected. A resource request is recorded with type, quantity, priority and reason as `requested`. The current scene manager can approve, decline or cancel it; an officer on scene can record fulfilment after approval. Each response is retained in a separate request-event history. This is a recorded operational response, not an automated stock allocation or proof of dispatch from an external resource system. All command retries are idempotent. The new tables have RLS enabled and remain inside the private `game` schema.

Supported scene/field commands are listed above. The regression suite is `database/tests/scene_control_field_reports.sql`; it covers scene creation, command transfer, field updates/reports, resource requests, access-log pairing and invalid resource quantities. Scene safety, boundary management and resource response/lifecycle are implemented in subsequent slices. Multi-agency attendance, specialist examination plans, detailed zone geometry, formal evidence/material handover, resource inventory and deployment integration remain future work.


## Scene safety and boundary control

A deployed officer recorded on scene can append a safety assessment describing hazards, people at risk, controls taken and residual risk. The scene's safety status updates to assessed, while the assessment itself remains a separate historical record. The current scene manager can set or revise the scene boundary. Each revision is retained; the prior active boundary becomes superseded, and the current boundary description is reflected on the scene record. A non-manager cannot revise the boundary. Both workflows use the fictional game clock and write scene activity/game events.

Commands: `scene safety PERSONNEL_REF for SCENE_REF: HAZARDS | CONTROLS | RESIDUAL RISK` and `set boundary PERSONNEL_REF for SCENE_REF: DESCRIPTION | REASON`. Regression script: `database/tests/scene_safety_and_boundaries.sql`. This is an initial recordkeeping layer; specialist hazard response, formal authority review, detailed zone geometry, multi-agency safety coordination and partial zone release remain outstanding. Formal full-scene release and reopening are implemented in the resource/lifecycle layer below.


## Resource response and scene lifecycle

The current scene manager can approve, decline or cancel a scene resource request. An approved request can be marked fulfilled by an actively employed officer with an on-scene deployment at the originating incident. Every response stores the actor, fictional timestamp, notes and source command in `scene_resource_request_events`; the request record retains its current state and responder/fulfilment details. This records a reported fulfilment and does not yet reserve stock, dispatch a vehicle or verify an external unit's physical arrival.

A scene manager can formally release a scene only after at least one safety assessment exists, no resource request remains requested/acknowledged/approved, and all recorded scene entries have matching exits. The release is stored in the scene record and a separate lifecycle history. An officer deployed on scene can reopen a released scene if the originating incident is still active; reopening transfers scene command to that officer. Reopening after incident resolution, closure or cancellation is rejected. Each release/reopening remains in the lifecycle history.

Commands: `resource approve PERSONNEL_REF REQUEST_REF: NOTES`, `resource decline PERSONNEL_REF REQUEST_REF: NOTES`, `resource fulfil PERSONNEL_REF REQUEST_REF: NOTES`, `resource cancel PERSONNEL_REF REQUEST_REF: NOTES`, `release scene PERSONNEL_REF SCENE_REF because REASON`, `reopen scene PERSONNEL_REF SCENE_REF because REASON`. Regression script: `database/tests/scene_resource_lifecycle.sql`.


## Specialist attendance and scene examination

Specialist attendance is recorded separately from ordinary scene access. A specialist must have an active on-scene deployment at the originating incident and a current personnel qualification whose code or name exactly matches the declared discipline. Attendance stores the scene, incident, officer, deployed unit, deployment, qualification, discipline, purpose and fictional arrival time. Duplicate active attendance by the same person at the same scene is rejected. Departure records a reason and is blocked while that specialist has a planned or in-progress examination.

The current scene manager alone can authorise an examination plan. The named examiner must be actively employed, signed in as a specialist at that scene, remain on scene and hold a current matching qualification. The plan stores the examination question, scope and known limitations. Only the assigned examiner can start or complete it. Completion requires separate observations, findings and limitations; the result is stored in a separate record, and the plan/event history is retained. The assigned examiner or current scene manager can cancel an uncompleted plan with a reason.

A scene cannot be released while specialist attendance remains open or any examination plan is planned/in progress. These records do not automatically create an evidence item, alter evidence custody, establish laboratory capability, validate a forensic method or turn an examiner's recorded findings into a case conclusion. Formal forensic service allocation, method validation, peer/technical review, report authorisation and evidence handover remain later BP-23/BP-24 work.

Commands:
- `specialist attend PERSONNEL_REF at SCENE_REF as DISCIPLINE: PURPOSE`
- `specialist depart PERSONNEL_REF from SCENE_REF because REASON`
- `plan examination SCENE_MANAGER_REF for SCENE_REF by EXAMINER_REF in DISCIPLINE: QUESTION | SCOPE | LIMITATIONS`
- `start examination EXAMINER_REF PLAN_REF because REASON`
- `complete examination EXAMINER_REF PLAN_REF: OBSERVATIONS | FINDINGS | LIMITATIONS`
- `cancel examination PERSONNEL_REF PLAN_REF because REASON`

Regression script: `database/tests/scene_specialist_examination.sql`.


## Contamination recording, evidence recovery and custody — 2026-11-20

Added three private-schema records: `scene_contamination_events` records a potential contaminant/source, affected zone and control action without automatically declaring an exhibit contaminated; `scene_evidence_recoveries` links a recovered exhibit to its scene and examination plan and preserves recovery location/method, packaging, unique seal identifier and condition; `scene_evidence_transfer_events` links each custody transfer to the canonical `evidence_transfers` row and preserves both custodians, locations, reason, time and command provenance.

Only an actively deployed officer can record potential contamination at an active scene. Evidence recovery is restricted to the assigned examiner on an active/completed examination plan, with an attending specialist record and current matching qualification. Recovery creates the canonical `evidence_items` record as well as a scene recovery record. Seal identifiers are unique. Evidence transfer requires the current recorded custodian, a different active receiving officer, both locations and a reason; the canonical evidence transfer and scene-linked event are written together. These operations use the fictional clock and command idempotency.

Commands:
- `record contamination PERSONNEL_REF at SCENE_REF: ZONE | MATERIAL_OR_SOURCE | CONTROL_ACTION`
- `recover evidence PERSONNEL_REF from SCENE_REF under PLAN_REF: TYPE | DESCRIPTION | LOCATION | METHOD | PACKAGING | SEAL | CONDITION`
- `transfer evidence PERSONNEL_REF EVIDENCE_REF to RECIPIENT_REF: FROM_LOCATION | TO_LOCATION | REASON`

Regression script: `database/tests/scene_contamination_evidence_custody.sql`. Parser, help-catalogue, private-table RLS and uninitialized-clock guard checks pass in a rolled-back transaction. The database has no seeded operational records, so full end-to-end scene/examiner/recovery/custody scenarios still require the integrated seeded-world regression fixture. No public policies or Data API exposure were added.


### Source migration recovery — 2026-11-20

The two already-applied live migrations for scene contamination, evidence recovery, custody transfer and command registration now have committed SQL source files:

- `database/migrations/20261120103202_scene_contamination_evidence_recovery_and_custody.sql`
- `database/migrations/20261120103219_register_evidence_recovery_commands_in_help.sql`

The SQL was reconstructed from the live PostgreSQL definitions and schema metadata, including table constraints, indexes, RLS, function bodies, command routing, parser grammar and help catalogue. These files restore source-control reproducibility; they were **not** reapplied to the live database because their migration versions are already present there.


The evidence-action handler's execute ACL was separately hardened in applied migration `20261120103649_restrict_evidence_action_execution.sql`: execution is granted to `service_role` only; `PUBLIC`, `anon` and `authenticated` are explicitly revoked. A live privilege check confirms `anon` and `authenticated` cannot execute it, while `service_role` can.


## Forensic laboratory workflow — 2026-11-20

Implemented the first laboratory workflow across nine private, RLS-enabled records: forensic methods, method-validation reviews, requests, request/evidence links, laboratory submissions, examinations, findings, technical reviews and versioned reports.

- Requests are tied to an open case and an evidence item already linked to that case. Request details preserve discipline, examination question, scope, recorded authority and priority; triage decisions and rationale are retained.
- Laboratory intake uses the canonical `evidence_transfers` ledger. The submitting officer must be the recorded current custodian and the receiving officer must be a different active employee. Receipt condition and seal condition are recorded; discrepancies or non-intact seals quarantine the submission. “None”/“no discrepancy” values are treated as no discrepancy.
- A method is registered as `verification_pending`. It cannot be self-certified: a different active officer with a current qualification matching the method discipline must record an independent validation decision. The method-validation review and rationale are retained.
- Examiner assignment requires a received, non-quarantined submission, an active validated method matching the request discipline, and a current matching examiner qualification.
- Findings separate observations, interpretation, propositions and limitations. Outcomes include supports, contradicts, inconclusive, no result and neutral; none constitutes an automatic legal conclusion.
- Technical, peer or independent finding review requires a different reviewer with a current matching qualification. A report can be issued only after examinations are complete and the latest finding for each examination has a latest approved review. Reports are versioned and previous issued versions are superseded, not overwritten. A reported request can be reissued as a new report version after the same completion and latest-approved-review checks are met.

Commands are registered in `help`: `forensic method`, `validate forensic method`, `forensic request`, `triage forensic`, `receive lab submission`, `assign forensic`, `start forensic`, `record forensic findings`, `review forensic` and `issue forensic report`. They use the existing idempotent command ledger and explicit fictional clock.

Limitations: the in-game validation decision is not a full method-validation study. A service/capability catalogue, lab capacity and workload, external-provider routing, raw instrument data, sample derivatives/consumption, proficiency testing, detailed quality records, disclosure/court interfaces and seeded end-to-end operational tests remain outstanding. No suspects or offenders are inferred or revealed by these commands.

Regression script: `database/tests/forensic_laboratory_workflow.sql`. Parser, help, runtime-routing, clock-guard and RLS checks pass in a rolled-back transaction. No forensic data is seeded or persisted; the fictional clock remains uninitialized.


Forensic source migrations are committed under `database/migrations/`: `20261120103941_forensic_laboratory_workflow_records.sql`, `20261120104208_forensic_laboratory_commands_and_review_workflow.sql`, `20261120104229_correct_forensic_request_command_spacing.sql`, `20261120104301_index_forensic_and_scene_foreign_keys.sql`, `20261120104349_treat_no_discrepancy_as_normal_lab_receipt.sql`, `20261120104502_independent_forensic_method_validation_and_review_qualification.sql`, `20261120104523_index_forensic_method_review_command_reference.sql` and `20261120104643_allow_versioned_forensic_report_reissue.sql`. These files match the applied Supabase migration versions; no already-applied migration was rerun.
