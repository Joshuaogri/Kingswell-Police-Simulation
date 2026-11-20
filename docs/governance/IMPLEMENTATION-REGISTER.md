# Kingswell Implementation Register

**Status date:** 2026-11-20  
**Overall stage:** Stage 2 — Simulation runtime foundation  
**Register status:** Updated after live database-to-blueprint audit

This register tracks actual progress. A design being written does not mean it has been implemented in software.

## Current service setup

| Item | Status | Detail |
|---|---|---|
| GitHub repository | Complete | `Joshuaogri/Kingswell-Police-Simulation` |
| Working branch | Complete | `main` only |
| Supabase project | Complete | `Kingswell-Police-Simulation`, project ref `gdbzkgejyfwfackyuorl` |
| Supabase connection | Verified | Project healthy; live SQL query succeeded |
| Master blueprint | Approved | BP-01 to BP-44 approved as the design baseline on 2026-11-20; individual divisions retain their recorded refinement notes |
| Implementation register | Started | This file |
| Technical architecture | Initial draft | See `docs/architecture/TECHNICAL-ARCHITECTURE.md` |
| Database schema | Runtime foundation and forensic laboratory workflow implemented | Private `game` schema; 67 tables, 182 foreign keys and 298 indexes; 37 migrations applied; six runtime functions; RLS enabled on all 67 tables; no fictional world/personnel data seeded; fictional clock remains uninitialized |
| Application/gameplay code | In progress | Database-backed text command interpreter, controlled clock, emergency-call/dispatch/arrival, scene-control, field-report and resource-request workflows implemented; full domain handlers remain outstanding |
| Runtime regression tests | Implemented; transaction smoke-tested | `database/tests/runtime_foundation.sql`, `database/tests/text_interpreter_dispatch.sql`, `database/tests/unit_dispatch.sql`, `database/tests/dispatch_acknowledgement_arrival.sql` and `database/tests/scene_control_field_reports.sql` cover the implemented runtime and operational slices; all test data rolls back |

## Master blueprint divisions

| ID | Division | Status |
|---|---|---|
| BP-01 | Game Identity, Foundations and Governing Rules | Approved |
| BP-02 | Country, City and Geographical Architecture | Approved; several details open |
| BP-03 | Population and Individual Simulation Architecture | Approved; processing model open |
| BP-04 | Buildings, Properties, Businesses and Organisations | Approved |
| BP-05 | Police Architecture | Approved; initial proposal; detailed structure remains open |
| BP-06 | Police Personnel | Approved |
| BP-07 | Career System | Approved; detailed rules remain open for refinement |
| BP-08 | Units and Deployment | Approved; roster-validated deployment, individual dispatch acknowledgement and on-scene arrival implemented; resource, qualification, command and remaining deployment lifecycle rules remain outstanding |
| BP-09 | Police Resources | Approved; details to refine with later operational divisions |
| BP-10 | Patrol Operations | Approved; roster-validated patrol-unit dispatch, individual acknowledgement and arrival state implemented; patrol presence and wider field-status workflows remain outstanding |
| BP-11 | Emergency Communications | Approved; text call intake, linked incident creation, roster-validated dispatch and individual officer acknowledgement/arrival events implemented; radio integration and live dispatch-console workflows remain outstanding |
| BP-12 | Incident Management | Approved; incident intake, dispatch, attendance, linked scene records, field reports and resource requests implemented; ownership transfer, full progression, resolution and closure remain outstanding |
| BP-13 | Crime Architecture | Approved; detailed fictional offence catalogue to populate |
| BP-14 | Crime Generation | Approved; frequency and behaviour tuning to follow |
| BP-15 | Case Management | Approved; investigative methods and legal review to refine |
| BP-16 | Investigation | Approved; specialist procedures and legal powers to refine |
| BP-17 | Victims and Witnesses | Approved; specialist safeguarding and legal procedures to refine |
| BP-18 | Suspects and Offenders | Approved; legal-status interfaces and specialist procedures to refine |
| BP-19 | Interviews and Interrogations | Approved; legal safeguards and specialist procedures to refine |
| BP-20 | Surveillance | Approved; statutory definitions, authorisations and oversight to refine |
| BP-21 | Intelligence | Approved; statutory powers, source handling and governance to refine |
| BP-22 | Crime Scenes | Approved; scene designation/control, manager transfer, activity/access/safety/boundary histories, resource response, release/reopening, qualified specialist attendance, examination plans/results, contamination records, evidence recovery, sealed recovery metadata and custody transfer implemented and seeded end-to-end transaction-tested; detailed zones, multi-agency command and specialist hazard response remain outstanding |
| BP-23 | Evidence Management | Approved; evidential rules, retention and professional standards to refine |
| BP-24 | Forensics | Approved; scene recovery and laboratory workflow implemented and seeded end-to-end transaction-tested: case-linked requests and triage, canonical custody transfer, independently qualified method validation, qualified examiner assignment, structured findings, independent qualified review and report issuance. Service capability catalogue, external-provider routing, full validation evidence, QA/proficiency, raw data/derivatives and disclosure/court interfaces remain outstanding |
| BP-25 | Arrests and Warrants | Approved; design only; no arrest or warrant software implemented |
| BP-26 | Custody Management | Approved; design only; no custody software or facilities implemented |
| BP-27 | Legal Processes | Approved; design only; no legal-process software implemented |
| BP-28 | Courts and Outcomes | Approved; design only; no court software implemented |
| BP-29 | Corrections | Approved; design only; no correctional software implemented |
| BP-30 | Department Governance | Approved; design only; no governance software implemented |
| BP-31 | Professional Standards | Approved; design only; no professional standards software implemented |
| BP-32 | Training and Development | Approved; design only; no training or competence software implemented |
| BP-33 | Human Resources | Approved; design only; no HR or workforce software implemented |
| BP-34 | Finance and Procurement | Approved; design only; no finance or procurement software implemented |
| BP-35 | Simulation Engine | Approved; typed command intake, limited text interpreter, idempotency, dispatch, scene control, safety, boundary, resource response, specialist examination, contamination, evidence recovery/custody and forensic laboratory command handlers implemented; seeded end-to-end scene-to-custody and lab-to-report regression fixtures pass in rollback transactions; broader domain handlers, scheduler and NPC processing outstanding |
| BP-36 | Relationships and Social Context | Approved; design only; no relationship or social-context system implemented |
| BP-37 | Time and Scheduling | Approved; paused singleton clock, explicit initialization/advancement and clock history implemented; fictional calendar configuration and scheduler outstanding |
| BP-38 | Records and Databases | Approved; 67-table private schema and 37 migrations implemented; command/clock, dispatch, scene, evidence custody, specialist examination, forensic laboratory request/intake/finding/review/report records integrated; full domain coverage incomplete |
| BP-39 | Persistence and Recovery | Approved; design only; no backup or restore process implemented |
| BP-40 | Interface | Approved; ChatGPT remains the intended text interface; limited explicit text command grammar exists; live ChatGPT-to-runtime connection remains outstanding |
| BP-41 | Notifications and Reporting | Approved; design only; no notification or reporting service implemented |
| BP-42 | Security and Permissions | Approved; RLS enabled on all 55 tables; private schema remains unexposed; player authentication and fictional authority enforcement outstanding |
| BP-43 | Testing and Quality Assurance | Approved; seeded scene-specialist-examination-to-contamination/recovery/custody and forensic request-to-report SQL end-to-end regression tests pass inside rolled-back transactions, alongside parser/help/RLS/clock guards; CI and broader domain tests outstanding |
| BP-44 | Configuration and Expansion | Approved; design only; no configuration or expansion framework implemented |

## Delivery stages

0. Master blueprint
1. Foundation
2. Department
3. Operations
4. Incidents and crime
5. Investigations
6. Evidence and forensics
7. Justice
8. Advanced policing
9. Living simulation
10. Comprehensive integration

## Status meanings

- **Not started:** no substantive work recorded.
- **In progress:** work is underway.
- **Drafted:** a working design exists but is not complete.
- **Implemented:** built in the project.
- **Verified:** tested and confirmed to work.
- **Blocked:** a specific obstacle prevents progress.

## Database foundation delivered — 2026-11-19

The first live Supabase database foundation is implemented in the private `game` schema.

- At the audit snapshot, the initial schema contained 40 tables covering world geography, organisations, properties/buildings, people and relationships, police structure/personnel, rosters/resources, clock state, incidents/dispatch, cases, evidence and game event history. The live schema has since expanded to 47 tables.
- At the audit snapshot, 78 foreign-key relationships connected those initial records; the live schema now has 100.
- Supporting indexes are present, including indexes for foreign-key lookups.
- At the audit snapshot, RLS was enabled on all 40 tables. It is now enabled on all 47 tables. The schema remains private and unexposed to the public API.
- No fictional game content has been seeded yet. The database foundation is structure only.

Migration files in `database/migrations/`:
- `20261119220423_kingswell_core_game_database.sql`
- `20261119220538_index_game_foreign_keys.sql`
- `20261120010000_runtime_foundation_commands_clock.sql`
- `20261120020000_harden_runtime_command_validation.sql`
- `20261120030000_text_interpreter_dispatch_intake.sql`
- `20261120040000_fix_dispatch_call_event_type.sql`
- `20261120050000_validate_optional_dispatch_call_fields.sql`
- `20261120060000_unit_dispatch_and_rostered_personnel.sql`
- `20261120070000_register_dispatch_commands_in_help.sql`
- `20261120080000_honour_rostered_cross_unit_attachments.sql`
- `20261120094953_officer_dispatch_acknowledgement_and_scene_arrival.sql`
- `20261120095028_correct_dispatch_acknowledgement_event_columns.sql`
- `20261120095728_scene_control_field_reports_and_resource_requests.sql`
- `20261120095856_harden_scene_access_order_and_input_validation.sql`
- `20261120095948_enable_rls_for_scene_and_field_records.sql`
- `20261120100100_index_scene_workflow_foreign_keys.sql`
- `20261120100301_scene_safety_assessment_and_boundary_control.sql`
- `20261120100309_enable_rls_for_scene_safety_and_boundaries.sql`
- `20261120100311_index_scene_safety_and_boundary_foreign_keys.sql`

The original two migrations established the base schema. The current live schema has 55 tables, 133 foreign keys, 223 indexes and RLS enabled on all 55 tables. Twenty-six migrations are recorded in Supabase; four runtime functions are present. The latest advisor run found no unindexed foreign keys. Unused-index notices remain expected while the database is empty.

Update this register when work actually changes. Do not mark design as implemented or implemented as verified without evidence.


## Database-to-blueprint audit — 2026-11-20

The live repository, approved BP-01 to BP-44 baseline, migration history and Supabase project were inspected. The detailed findings are recorded in `docs/audits/2026-11-20-database-to-blueprint-audit.md`.

### Audit-time baseline (before runtime additions)

- Supabase project was `ACTIVE_HEALTHY`, PostgreSQL 17.12, region `eu-west-1`.
- Private `game` schema at that audit point: 40 base tables, 78 foreign keys, 141 indexes.
- RLS was enabled on all 40 base tables. This historical snapshot predates the command, clock-history and dispatch runtime migrations.
- Both committed migrations are present in live migration history.
- The singleton `simulation_state` row exists with the clock unset and paused. Command, clock-history and all fictional world/personnel/incident/case tables remain empty; no fictional world or police data has been seeded.
- A prior temporary end-to-end relationship smoke test passed and rolled back cleanly; this is not an automated test suite.
- Security advisor reports 40 informational RLS-enabled/no-policy findings. This is consistent with the current private, server-only schema boundary; do not expose tables or add broad policies as a shortcut. Define the actual game access model when the runtime access layer is implemented.
- Performance advisor reports 73 unused indexes. With an empty database and no gameplay workload, this is informational; retain indexes until representative workload testing supports changes. Health advisor returned no findings.

### Implemented schema coverage

- **World foundation:** countries, regions, cities, districts, neighbourhoods, roads, properties, buildings and building units.
- **People and organisations:** persons, addresses, relationships, organisations, organisation locations and personnel.
- **Police foundation:** commands, stations, ranks, units, positions, personnel, service history, qualifications, duty rosters, duty assignments and resources.
- **Operations and cases:** simulation state, incident types, incidents, incident parties, dispatch calls/events, deployments, cases, case incidents/persons/assignments, evidence items/transfers and game events.

### Blueprint coverage assessment

The current relational schema is a useful foundation, not a completed implementation of the 44 divisions. Coverage is partial across BP-02 to BP-18, BP-23, BP-32 to BP-38 and BP-42 to BP-43. BP-19 to BP-21, BP-25 to BP-31, BP-34, BP-39, BP-41 and BP-44 have no substantive dedicated implementation yet; BP-22 now has an operational scene and examination slice, not full scene lifecycle coverage. The detailed division-by-division mapping and gaps are in the audit report.

### Immediate build sequence

1. Complete the first coherent world and police seed dataset using the existing schema; do not add duplicate tables before checking the approved BP-38 requirements.
2. Implement the first runtime vertical slice: player/personnel identity, current duty and assignment, command intake, validation, state transition, event history and persistence.
3. Connect dispatch, incident creation, deployment and reporting to that same runtime and authoritative database.
4. Add automated tests for the complete workflow, including time control, authority checks, event history and persistence.
5. Expand the schema only where the approved divisions require missing records or behaviours; add migrations to GitHub `main` and apply the same migrations to Supabase.

**Current verified completion:** infrastructure, initial relational schema, typed command intake, explicit clock controls, command idempotency, clock audit history, limited text interpretation and initial emergency-call/incident creation are implemented and transaction-tested. **The game is not yet fully playable:** no fictional world/personnel seed data, live ChatGPT-to-runtime connection, full dispatch/deployment workflow, full domain command handlers, authenticated player mapping, deployed Edge Function, complete automated test pipeline or backup/restore workflow exists.


## Runtime foundation — 2026-11-20

Implemented the first database-backed runtime slice under BP-35, BP-37, BP-38, BP-40 and BP-43.

- Added `game.game_commands` for command text, typed intent, payload, idempotency, outcome and timestamps.
- Added `game.game_clock_history` for auditable clock initialization and advancement.
- Added `game.submit_command(...)` as an invoker-rights command entry function in the private `game` schema.
- Added foundation commands: `help`, `status`, `initialize_clock` and `advance_time`.
- Created the singleton clock row in a paused state, with no fictional date/time selected. The game clock remains uninitialized until a fictional start point is explicitly chosen.
- Explicit advancement is limited to 1–1,440 minutes per command. No real-world elapsed time advances the fictional clock.
- Clock changes and matching `game_events` records commit in the same transaction.
- Added a repeatable SQL regression script; its transaction smoke test passed and rolled back all test records. Fractional and out-of-range time requests are rejected and retained as rejected commands rather than aborting the transaction.
- No public Edge Function was deployed because player authentication/session mapping is not yet implemented. The private database function is not exposed through the public Data API.

Migrations: `database/migrations/20261120010000_runtime_foundation_commands_clock.sql` and `database/migrations/20261120020000_harden_runtime_command_validation.sql`.

The runtime is a foundation, not a playable police simulation. Natural-language parsing, fictional officer identity/authority, domain actions, event handlers, autonomous schedules and NPC processing remain to be implemented.


## Text interpreter and initial dispatch workflow — 2026-11-20

Implemented a limited explicit text grammar through `game.interpret_text_command` and `game.execute_text_command`. Initial BP-11/BP-12 call intake creates a linked incident, dispatch call, `call_received` dispatch event and game event using the configured fictional clock. The separate `dispatch UNIT_REF to INCIDENT_REF` command deploys eligible personnel from the selected unit's active roster and records the dispatch. Invalid or unrecognised commands are rejected; retries remain idempotent.

Supported forms include `help`, `status`, `advance time N minutes`, `911/call/report/radio [report] at [location]`, `dispatch UNIT_REF to INCIDENT_REF`, `acknowledge PERSONNEL_REF for INCIDENT_REF`, `arrive PERSONNEL_REF at INCIDENT_REF`, `establish scene SCENE_REF at INCIDENT_REF by PERSONNEL_REF because REASON`, `take command PERSONNEL_REF of SCENE_REF`, `scene update PERSONNEL_REF for SCENE_REF: TEXT`, `field report PERSONNEL_REF for INCIDENT_REF [at SCENE_REF]: TEXT`, `request resource PERSONNEL_REF for SCENE_REF: RESOURCE_TYPE | REASON`, `scene entry PERSONNEL_REF into SCENE_REF for PURPOSE` and `scene exit PERSONNEL_REF from SCENE_REF for PURPOSE`, `scene safety PERSONNEL_REF for SCENE_REF: HAZARDS | CONTROLS | RESIDUAL RISK` and `set boundary PERSONNEL_REF for SCENE_REF: DESCRIPTION | REASON`, `resource approve|decline|fulfil|cancel PERSONNEL_REF REQUEST_REF: NOTES`, `release scene PERSONNEL_REF SCENE_REF because REASON` and `reopen scene PERSONNEL_REF SCENE_REF because REASON`. The parser does not turn questions into actions.

Regression tests: `database/tests/runtime_foundation.sql`, `database/tests/text_interpreter_dispatch.sql`, `database/tests/unit_dispatch.sql`, `database/tests/dispatch_acknowledgement_arrival.sql`, `database/tests/scene_control_field_reports.sql`, `database/tests/scene_safety_and_boundaries.sql`, `database/tests/scene_resource_lifecycle.sql` and `database/tests/scene_specialist_examination.sql`; all eight passed in transactions with rollback. Live verification: 55 tables, 133 foreign keys, 223 indexes, all 55 tables with RLS, 26 migration records and four runtime functions. All regression fixtures rolled back.


## Roster-validated unit dispatch — 2026-11-20

Implemented `dispatch UNIT_REF to INCIDENT_REF`. The command checks the active unit, current game clock, active roster, time-bounded duty assignments, active employment, matching home unit and existing conflicting deployments. It creates one deployment and dispatch event per eligible officer, changes the incident and linked call to `dispatched`, and writes a game event. It does not record arrival or invent vehicle/resource availability. The workflow is covered by `database/tests/unit_dispatch.sql` and passed inside a rolled-back transaction.


The roster-validated dispatch test passed with temporary fictional home-unit and cross-unit attached personnel, unit, roster, incident and call records; the transaction rolled back. Help output was separately verified to include `receive_call` and `dispatch_unit`. Live state after tests: 42 tables, 80 foreign keys, 147 indexes, 12 migration records, 3 runtime functions, zero game commands/calls/incidents/deployments/events and an uninitialized fictional clock.


## Officer acknowledgement and scene arrival — 2026-11-20

Implemented two individual deployment commands:

- `acknowledge PERSONNEL_REF for INCIDENT_REF` changes the officer's deployment from `dispatched` to `responding` and records a `dispatch_acknowledged` dispatch event plus a game event.
- `arrive PERSONNEL_REF at INCIDENT_REF` requires the officer to have acknowledged, stores `arrived_at` from the fictional game clock, changes the deployment to `on_scene`, records an `officer_arrived` dispatch event plus a game event, and moves the incident from `dispatched` to `attending` on first arrival.

Each officer progresses independently. Early arrival, missing deployments, invalid order and time reversal are rejected. Idempotency prevents repeated commands from duplicating state changes. Regression script: `database/tests/dispatch_acknowledgement_arrival.sql`; passed in a rolled-back transaction. Vehicle/resource checks, radio integration, scene command, incident progression and closure remain outstanding.


## Scene control and field reporting — 2026-11-20

Implemented BP-12/BP-22 initial operational slice:

- Five new tables: `incident_scenes`, `scene_activity_logs`, `scene_access_events`, `incident_field_reports` and `incident_resource_requests`.
- Scene establishment requires an active on-scene deployment at the originating incident. It records the scene identity, location, reason, confidence, control status, manager and fictional timestamps.
- Scene command can transfer to another officer who is on scene; transfer is recorded.
- Scene updates and field reports are separate incident-linked records.
- Entry/exit logs record personnel, zone, purpose and fictional time. Duplicate entry and unmatched exit are rejected; a monotonic event sequence preserves ordering when fictional timestamps are equal.
- Resource requests record type, quantity, priority and reason, and remain requested until a later response workflow exists. They are not automatically approved or deployed.
- All five new tables have RLS enabled in the private `game` schema. No test data persists.

Eight SQL regression suites pass, including `database/tests/scene_control_field_reports.sql`, `database/tests/scene_safety_and_boundaries.sql`, `database/tests/scene_resource_lifecycle.sql` and `database/tests/scene_specialist_examination.sql`. The performance advisor reports no unindexed foreign keys; unused-index notices are expected because the database contains no persistent workload data. Remaining BP-22 work includes detailed zones, multi-agency command, specialist hazard response, contamination records, formal evidence handover and review. Remaining BP-12 work includes accountable ownership transfer, referrals, full incident progression and closure.


## Scene safety and boundary control — 2026-11-20

Added two scene-management records: `scene_safety_assessments` stores each assessment as a separate historical entry; `scene_boundary_revisions` retains each boundary version and identifies the active version. `incident_scenes` now stores the current safety status and boundary description. A deployed officer on scene can record hazards, people at risk, controls and residual risk. Only the current scene manager can revise the boundary, and every revision supersedes rather than overwrites the prior active boundary. New tables have RLS enabled and indexed foreign keys. The eight SQL regression suites pass in rolled-back transactions. Resource response, formal scene release/reopening, qualified specialist attendance and scene examination planning/results are now implemented; remaining work includes specialist hazard response, detailed zone geometry, multi-agency coordination, forensic service governance and evidence handover.


## Resource response and scene lifecycle — 2026-11-20

Added `scene_resource_request_events` and `scene_lifecycle_events`, plus resource responder and fulfilment timestamp fields. The scene manager can approve, decline or cancel a request; an on-scene officer can record fulfilment of an approved request. Every transition records actor, fictional time, notes and command provenance. This is an explicit response/fulfilment record, not automated inventory allocation or proof of a separate unit's physical dispatch.

Formal scene release requires a recorded safety assessment, no outstanding resource requests and no unmatched scene-entry records. Only the current scene manager can release. An on-scene officer can reopen a released scene while the originating incident remains active; scene command transfers to that officer. Reopening after incident resolution, closure or cancellation is rejected. Release/reopening history is append-only. Regression suite: `database/tests/scene_resource_lifecycle.sql`.

Current verified state after the forensic workflow regression: 67 tables, 182 foreign keys, 298 indexes, RLS enabled on all 67 tables, 37 migrations and six runtime functions. Zero persistent forensic records or test commands; no world/personnel seed data; fictional clock remains uninitialized. The performance advisor reports no unindexed foreign keys. Unused-index notices are expected while the database is empty. The security advisor reports RLS-enabled/no-policy INFO notices because the private `game` schema is intentionally not exposed to the Data API and no public player access has been deployed.


## Specialist attendance and scene examination — 2026-11-20

Added four tables: `scene_specialist_attendances`, `scene_examination_plans`, `scene_examination_events` and `scene_examination_records`. A specialist can sign in only while actively deployed on scene and only with a current, valid personnel qualification exactly matching the declared discipline. The attendance record links the deployment, unit and qualification. The scene manager alone can authorise a plan; the examiner must be the qualified attending specialist and remain deployed on scene. The examiner records start and completion; completion stores observations, reported findings and limitations. The assigned examiner or scene manager can cancel an open plan. Every transition is linked to scene activity, the command ledger and game event history.

Scene release now also requires all specialist attendances to be closed and all examination plans to be completed or cancelled. Specialist departure is blocked while assigned plans remain open. Examination records are not automatically evidence items and do not replace BP-23 custody records or BP-24 laboratory method validation, technical review and formal report authorisation.

Commands and full regression coverage are documented in `docs/architecture/RUNTIME-FOUNDATION.md` and `database/tests/scene_specialist_examination.sql`. Eight regression suites pass in rolled-back transactions. Verified live state: 55 tables, 133 foreign keys, 223 indexes, RLS on all 55 tables, 26 migrations and four runtime functions. The database remains unseeded; all test fixtures were rolled back.


## Scene contamination and forensic evidence custody — 2026-11-20

Added three tables: `scene_contamination_events`, `scene_evidence_recoveries` and `scene_evidence_transfer_events`. All three have RLS enabled and remain in private schema `game`. The command parser and help catalogue now include contamination recording, evidence recovery and custody transfer. Contamination entries preserve affected zone, material/source and control action without asserting contamination as a proven fact. Recovery requires the assigned, qualified specialist examiner with an active attendance and an authorised examination plan; it creates the canonical evidence item and linked recovery record, including unique seal, packaging, condition, location and method. Custody transfer checks the current custodian and active recipient, then writes the canonical transfer and linked scene event atomically. All actions use the fictional clock, command ledger and game-event history.

Regression script: `database/tests/scene_contamination_evidence_custody.sql`. Parser, help catalogue, RLS and clock-guard assertions passed in a rolled-back transaction. A seeded rollback-only end-to-end test now covers specialist attendance, examination, contamination reporting, evidence recovery with seal/packaging/condition, current-custodian transfer and linked custody history. The test passes; no fixture records persist. Verified live state: 58 tables, 150 foreign keys, 238 indexes, RLS on all 58 tables, 28 migrations and four runtime functions. No persistent incidents, deployments, scenes, evidence recoveries or custody transfers were created by tests; the fictional clock remains uninitialized.


### Migration source reconciliation — 2026-11-20

Resolved the source-control gap for the scene contamination/evidence recovery/custody slice. Committed the source for the two applied migration versions `20261120103202` and `20261120103219`. The files include the three table definitions and constraints, indexes, RLS enablement, evidence action handler, command routing, text parser and help catalogue. Source was reconstructed from the live database definitions and checked against the applied migration history. No live migration was rerun and no operational/test records were added.


The evidence-action handler's execute ACL was separately hardened in applied migration `20261120103649_restrict_evidence_action_execution.sql`: execution is granted to `service_role` only; `PUBLIC`, `anon` and `authenticated` are explicitly revoked. A live privilege check confirms `anon` and `authenticated` cannot execute it, while `service_role` can.


## Forensic laboratory workflow — 2026-11-20

Implemented the first laboratory workflow across nine private, RLS-enabled records: forensic methods, method-validation reviews, requests, request/evidence links, laboratory submissions, examinations, findings, technical reviews and versioned reports.

- Requests are tied to an open case and an evidence item already linked to that case. Request details preserve discipline, examination question, scope, recorded authority and priority; triage decisions and rationale are retained.
- Laboratory intake uses the canonical `evidence_transfers` ledger. The submitting officer must be the recorded current custodian and the receiving officer must be a different active employee. Receipt condition and seal condition are recorded; discrepancies or non-intact seals quarantine the submission. “None”/“no discrepancy” values are treated as no discrepancy.
- A method is registered as `verification_pending`. It cannot be self-certified: a different active officer with a current qualification matching the method discipline must record an independent validation decision. The method-validation review and rationale are retained.
- Examiner assignment requires a received, non-quarantined submission, an active validated method matching the request discipline, and a current matching examiner qualification.
- Findings separate observations, interpretation, propositions and limitations. Outcomes include supports, contradicts, inconclusive, no result and neutral; none constitutes an automatic legal conclusion.
- Technical, peer or independent finding review requires a different reviewer with a current matching qualification. A report can be issued only after examinations are complete and the latest finding for each examination has a latest approved review. Reports are versioned and previous issued versions are superseded, not overwritten.

Commands are registered in `help`: `forensic method`, `validate forensic method`, `forensic request`, `triage forensic`, `receive lab submission`, `assign forensic`, `start forensic`, `record forensic findings`, `review forensic` and `issue forensic report`. They use the existing idempotent command ledger and explicit fictional clock.

Limitations: the in-game validation decision is not a full method-validation study. A service/capability catalogue, lab capacity and workload, external-provider routing, raw instrument data, sample derivatives/consumption, proficiency testing, detailed quality records, disclosure/court interfaces and seeded end-to-end operational tests remain outstanding. No suspects or offenders are inferred or revealed by these commands.

Regression scripts: `database/tests/forensic_laboratory_workflow.sql` and `database/tests/forensic_laboratory_end_to_end.sql`. The new seeded rollback-only end-to-end test passes through independent method validation, case/evidence-linked request, triage, laboratory intake and canonical custody transfer, qualified examiner assignment, examination, findings, independent qualified review and report issuance. A negative self-review assertion also passes. No forensic/personnel/case/evidence fixture records persist; the fictional clock remains uninitialized.


Forensic workflow source migrations (all applied and committed on `main`): `20261120103941_forensic_laboratory_workflow_records.sql`; `20261120104208_forensic_laboratory_commands_and_review_workflow.sql`; `20261120104229_correct_forensic_request_command_spacing.sql`; `20261120104301_index_forensic_and_scene_foreign_keys.sql`; `20261120104349_treat_no_discrepancy_as_normal_lab_receipt.sql`; `20261120104502_independent_forensic_method_validation_and_review_qualification.sql`; `20261120104523_index_forensic_method_review_command_reference.sql`; and `20261120104643_allow_versioned_forensic_report_reissue.sql`. Regression script: `database/tests/forensic_laboratory_workflow.sql`.


## Seeded end-to-end forensic and scene verification — 2026-11-20

Two full rollback-only seeded integration suites now pass against the live Supabase database:

- `database/tests/scene_specialist_examination.sql`: creates fictional personnel, current qualifications, rostered deployments, incident, controlled scene, specialist attendance and examination plan; records contamination; starts/completes the assigned examination; recovers evidence with packaging, unique seal and condition; transfers custody to a different active officer; verifies canonical evidence, recovery and transfer records; completes specialist departure and scene release.
- `database/tests/forensic_laboratory_end_to_end.sql`: creates four fictional officers, two current DNA qualifications, case and evidence; registers and independently validates a method; submits and accepts a case-linked request; receives the sealed item through canonical evidence custody; assigns a qualified examiner; starts examination; records structured findings; rejects examiner self-review; accepts independent qualified review; issues the report; and verifies final request, submission, examination, report and custody states.

The earlier `database/tests/scene_contamination_evidence_custody.sql` parser/help/RLS/clock-guard regression also passes. Each test runs in a transaction and ends with rollback. A post-test live count confirms zero persons, police personnel, cases, evidence items and forensic requests; the fictional clock remains uninitialized. Current live structural counts: 67 tables, 182 foreign keys, 298 indexes, RLS on all 67 tables and 37 migrations.


## BP-02 — Kingswell initial geographic map and road skeleton — 2026-11-20

Created and committed the first authored, non-generated vector city map and geographic specification:
- `docs/geography/KINGSWELL-MASTER-MAP.md`
- `docs/geography/kingswell-city-map.svg`

The working map uses a fictional 20 km × 16 km local coordinate grid, north-up orientation, a southern coastal edge, a proposed eastern river corridor and twelve proposed districts. It establishes the geographic hierarchy and road-network modelling rules. District envelopes are explicitly planning extents, not surveyed cadastral boundaries. The twelve district names and their placement remain an initial proposal for refinement; BP-02 itself remains approved and unchanged.

Applied the initial geographic database foundation and seed:
- one fictional country and capital region; Kingswell city seeded at the BP-02 baseline of 100,000 permanent residents;
- 12 districts and 24 neighbourhoods;
- 12 district map envelopes;
- 24 named roads;
- 16 road junctions and 22 routable road segments;
- new private, RLS-enabled tables: `district_map_areas`, `road_junctions`, and `road_segments`.

Road topology is stored independently from named roads. Junctions use local-grid metre coordinates, and segments reference both endpoint junctions and a canonical road. The initial network has a connected 16-junction graph, with explicit road class, length, lane count, speed limit, directionality, surface, crossing and access fields. All three new tables remain in private schema `game`; direct access is revoked from PUBLIC, anon and authenticated and granted to service_role.

Regression: `database/tests/kingswell_geography_seed.sql` checks the seeded hierarchy, district extents, named roads, junctions, valid same-city references, graph connectivity and RLS. This is the first geographic foundation only: local street grids, full property/address coverage, exact district polygons, bridge/tunnel detail, traffic and travel-time calibration remain subsequent build stages. Live verification: 70 game tables with RLS enabled on all 70, 39 applied migrations, and the seeded Kingswell network integrity regression passes. The road graph reaches all 16 seeded junctions; all 22 segments have valid same-city endpoints and road references. Migration source is committed as `20261120110252_kingswell_bp02_geographic_foundation.sql`; `20261120110246_kingswell_bp02_geographic_foundation.sql` is an intentional no-op history marker.


## BP-02 — Asterfell approval and complete connected road network — 2026-11-20

Asterfell is approved as the fictional sovereign country setting for Kingswell. The database's formal country record remains `Republic of Asterfell`; Asterfell is the approved country name/short form. The initial geographic seed is extended by the complete neighbourhood street layer. Each of the 24 neighbourhoods has a named local street loop, four local junctions and a collector tie into the arterial graph. Three river crossings are explicit bridge segments with separate bank junctions and approach connections: East River Bridge North, Riverside Bridge and Harbour River Bridge. Airport and port approaches retain their dedicated access profile.

Verified live network: 51 named roads, 118 junctions, 151 routable segments, three bridge segments, all 118 junctions reachable from arterial junction `J001`, and zero neighbourhoods without a dedicated local street. Segment references are same-city and each route segment retains its parent road, endpoints, calculated local-grid length, class, lane count, speed, directionality, surface, crossing type and access profile. Geography tables remain private with RLS enabled. Regression: `database/tests/kingswell_geography_seed.sql` checks the complete network and rolls back without changing live data.

Applied migration: `20261120110935_kingswell_bp02_complete_neighbourhood_road_network.sql`. Source is committed at the same path. A follow-up coordinate correction migration `20261120111152_correct_east_river_bridge_coordinates.sql` places bridge banks across the mapped eastern river corridor (x=16,400–17,400 m) and recalculates approach/bridge segment lengths. Next geographic layer: properties, buildings, address ranges and named landmarks; after that, police facilities, patrol sectors and network-based route/time calculations. Exact cadastral boundaries, turn restrictions, terrain, traffic and calibrated travel times are not claimed complete.
