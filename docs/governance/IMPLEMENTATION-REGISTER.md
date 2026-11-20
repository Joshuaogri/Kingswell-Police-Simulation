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
| Database schema | Runtime foundation and multiple police/justice/correctional/population/property/business systems implemented | Private `game` schema; live audit snapshot: 185 tables, 627 foreign keys, 912 indexes; RLS enabled on all 185 tables; Kingswell BP-02 geography and BP-04 property/business layer seeded; BP-03 life/household/routine foundation deployed; no persistent persons, households, cases, incidents, evidence, dispatch calls or route records; fictional clock remains uninitialized |
| Application/gameplay code | In progress | Database-backed text command interpreter, controlled clock, emergency-call/dispatch/arrival, scene-control, field-report and resource-request workflows implemented; full domain handlers remain outstanding |
| Runtime regression tests | Implemented; transaction smoke-tested | Runtime, dispatch, scene, evidence, forensic laboratory, geography and police-facility/patrol-geography SQL regression scripts cover implemented slices; test fixtures roll back |

## Master blueprint divisions

| ID | Division | Status |
|---|---|---|
| BP-01 | Game Identity, Foundations and Governing Rules | Approved |
| BP-02 | Country, City and Geographical Architecture | Complete and verified; Asterfell's eight regions, Kingswell's 20 km × 16 km grid, 12 districts/24 neighbourhoods, 51 roads/118 junctions/151 segments/3 bridges/24 landmarks; corrected all 12 map envelopes; route and dispatch integration regression suites pass |
| BP-03 | Population and Individual Simulation Architecture | Foundation implemented and tested; persistent identities, households, overlapping population memberships, life events, routines and monotonic relevance promotion; BP-04 now supplies 24,512 residential units for the 100,000-person seed; population/household allocation is next; routine execution awaits BP-35 |
| BP-04 | Buildings, Properties, Businesses and Organisations | Implemented and regression-tested: 656 properties/buildings, 26,888 units, 1,452 businesses, 25 public institutional sites, full property/building/unit dossiers, ownership/occupancy and neighbourhood map queries/commands |
| BP-05 | Police Architecture | Approved; initial headquarters, 12 district stations, five specialist facilities and 12 district patrol sectors geographically seeded; command/personnel structure remains outstanding |
| BP-06 | Police Personnel | Approved |
| BP-07 | Career System | Approved; detailed rules remain open for refinement |
| BP-08 | Units and Deployment | Approved; roster-validated deployment, individual dispatch acknowledgement and on-scene arrival implemented; resource, qualification, command and remaining deployment lifecycle rules remain outstanding |
| BP-09 | Police Resources | Approved; details to refine with later operational divisions |
| BP-10 | Patrol Operations | Approved; roster-validated patrol dispatch, road movement, segment-level beat coverage, coverage-gap intelligence, foot-patrol/stationary-observation/community/business activity sessions, structured patrol observations, person/organisation/property/incident-linked contacts, searchable patrol intelligence, repeat-location reporting, immutable links to existing incidents/cases and link-history lookup implemented and rollback-tested; wider field-status workflows remain outstanding |
| BP-11 | Emergency Communications | Approved; text call intake, linked incident creation, roster-validated dispatch and individual officer acknowledgement/arrival events implemented; radio integration and live dispatch-console workflows remain outstanding |
| BP-12 | Incident Management | Approved; incident intake, dispatch, attendance, linked scene records, field reports and resource requests implemented; ownership transfer, full progression, resolution and closure remain outstanding |
| BP-13 | Crime Architecture | Approved; detailed fictional offence catalogue to populate |
| BP-14 | Crime Generation | Approved; frequency and behaviour tuning to follow |
| BP-15 | Case Management | Approved; case task management with player-facing task listing, dependency and workload commands, immutable prerequisite gates, fictional-time overdue/workload reporting, completion submissions with existing-evidence links, immutable supervisor review history and enforced approval gate, investigator ownership/assignment history, investigative lead register, enquiry records, interview transcripts, witness statements, suspect response assessments, consolidated case review dossier, supervisory reviews/status transitions and immutable lead handovers with continuity notes implemented; full case progression, disclosure and legal review remain outstanding |
| BP-16 | Investigation | Approved; lead creation, source classification, investigator allocation, priority/confidence assessment, immutable enquiry actions/results and history, chronological investigative activity records, dedicated surveillance plans/deployments and personnel-backed end-to-end verification, dedicated search warrants and execution, search teams, premises registers and explicit outcomes, append-only search logs, recovered-property records, seizure records and shared evidence-chain custody transfers implemented and verified by a rollback-only personnel-backed end-to-end test; case dossier includes activity, surveillance and search chronologies; other specialised operational methods and specialist procedures remain outstanding; typed lead links and case interview/witness statement workflows are implemented |
| BP-17 | Victims and Witnesses | Approved; specialist safeguarding and legal procedures to refine |
| BP-18 | Suspects and Offenders | Approved; legal-status interfaces and specialist procedures to refine |
| BP-19 | Interviews and Interrogations | Approved; legal safeguards and specialist procedures to refine |
| BP-20 | Surveillance | Approved; statutory definitions, authorisations and oversight to refine |
| BP-21 | Intelligence | Approved; statutory powers, source handling and governance to refine |
| BP-22 | Crime Scenes | Approved; scene designation/control, manager transfer, activity/access/safety/boundary histories, resource response, release/reopening, qualified specialist attendance, examination plans/results, contamination records, evidence recovery, sealed recovery metadata and custody transfer implemented and seeded end-to-end transaction-tested; detailed zones, multi-agency command and specialist hazard response remain outstanding |
| BP-23 | Evidence Management | Approved; evidential rules, retention and professional standards to refine |
| BP-24 | Forensics | Approved; scene recovery and laboratory workflow implemented and seeded end-to-end transaction-tested: case-linked requests and triage, canonical custody transfer, independently qualified method validation, qualified examiner assignment, structured findings, independent qualified review and report issuance. Service capability catalogue, external-provider routing, full validation evidence, QA/proficiency, raw data/derivatives and disclosure/court interfaces remain outstanding |
| BP-25 | Arrests and Warrants | Approved; fictional search-warrant issue/validity/scope and search execution implemented; arrest execution linked to existing case suspects/persons with recorded basis, grounds, location, force, injury/complaint, warnings, witnesses and body-camera reference; arrest event history, transport and custody status integration implemented and rollback-tested; dedicated arrest-warrant records, warrant-service/return workflow and further warrant categories remain outstanding |
| BP-26 | Custody Management | Approved; arrest transport legs with explicit duration and fictional clock history, custody booking/episode creation, identity/risk/health-welfare screening, medication/safeguarding notes, cell allocation, detainee property inventory, evidence-register integration, append-only welfare checks and custody events, release/transfer outcomes and case-dossier integration implemented and rollback-tested; central custody facility location and property/access linkage seeded; facility staffing, cell-capacity allocation, scheduled review/deadline rules and specialist custody processes remain outstanding |
| BP-27 | Legal Processes | Approved; design only; no legal-process software implemented |
| BP-28 | Courts and Outcomes | Approved; design only; no court software implemented |
| BP-29 | Corrections | Approved; design only; no correctional software implemented |
| BP-30 | Department Governance | Approved; design only; no governance software implemented |
| BP-31 | Professional Standards | Approved; design only; no professional standards software implemented |
| BP-32 | Training and Development | Approved; police training-centre location seeded; training programmes, courses, attendance and competence workflows remain outstanding |
| BP-33 | Human Resources | Approved; design only; no HR or workforce software implemented |
| BP-34 | Finance and Procurement | Approved; design only; no finance or procurement software implemented |
| BP-35 | Simulation Engine | Approved; typed command intake, limited text interpreter, idempotency, dispatch, scene control, patrol movement/activity/observations/contacts/intelligence, case tasks/ownership/leads/enquiries/interviews/witness statements/suspect interviews, safety, boundary, resource response, specialist examination, contamination, evidence recovery/custody and forensic laboratory command handlers implemented; seeded end-to-end regression fixtures pass in rollback transactions; broader domain handlers, scheduler and NPC processing outstanding |
| BP-36 | Relationships and Social Context | Approved; design only; no relationship or social-context system implemented |
| BP-37 | Time and Scheduling | Approved; paused singleton clock, explicit initialization/advancement and clock history implemented; fictional calendar configuration and scheduler outstanding |
| BP-38 | Records and Databases | Approved; 123-table private schema, 421 foreign keys, 589 indexes and 100 migrations implemented; command/clock, dispatch, scene, evidence custody, specialist examination, forensic laboratory, police geography, patrol intelligence and case investigation records integrated; full domain coverage incomplete |
| BP-39 | Persistence and Recovery | Approved; design only; no backup or restore process implemented |
| BP-40 | Interface | Approved; ChatGPT remains the intended text interface; limited explicit text command grammar exists; live ChatGPT-to-runtime connection remains outstanding |
| BP-41 | Notifications and Reporting | Approved; design only; no notification or reporting service implemented |
| BP-42 | Security and Permissions | Approved; RLS enabled on all 123 tables; private schema remains unexposed; service-role-only runtime execution; player authentication and fictional authority enforcement outstanding |
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


## BP-02 — Property, building, address and landmark layer — 2026-11-20

Implemented and live in Supabase. The existing property/building/unit foundation was extended rather than duplicated. Properties now carry local-grid x/y, parcel area, frontage width, land-use classification, frontage road-segment reference and postal code. Buildings carry local-grid x/y, footprint dimensions/area, construction type and occupancy state. Added private tables `game.property_addresses`, `game.property_access_points` and `game.city_landmarks`; all three have RLS enabled and service_role-only privileges. Existing properties, buildings and building_units remain private and service_role-only.

Seeded city inventory: 480 properties (20 in each of 24 neighbourhoods; 40 in each district), 480 buildings, 712 building units/premises, 480 structured postal addresses, 480 primary access points and 24 named landmarks. Every property resolves to its district, neighbourhood, named street, frontage road segment, building, postal address and access point. Every access point resolves to a routable road segment and junction. Each landmark resolves to an actual property, building and access point. Coordinates use the fictional local metric grid; they are planning points, not surveyed cadastral geometry.

Applied migration: `20261120111654_kingswell_bp02_properties_buildings_addresses_landmarks.sql`. Follow-up correction migration: `20261120111935_correct_property_access_nearest_junctions.sql`, ensuring each access point selects the nearer endpoint of its frontage segment. Regression test: `database/tests/kingswell_properties_buildings_addresses.sql` (transactional assertions; rollback only). Test passed on the live project, and the committed seed migration source replayed successfully inside a rolled-back transaction. BP-02 next work: police facilities, patrol sectors and network-based routing/response calculations; detailed cadastral geometry, floor plans, additional entrances and traffic calibration remain future refinements.


## BP-02 — Police facilities, patrol sectors and beat geography — 2026-11-20

Implemented and live in Supabase. The police geography layer is built on the existing property, building, postal-address, access-point and road-segment records; it does not create duplicate map locations.

Seeded facilities:
- 18 operational facility records: Kingswell Police Headquarters; 12 district police stations; Central Custody Facility; Police Operations and Communications Centre; Forensic Services Centre; Police Training Centre; and Police Fleet and Workshop.
- The headquarters and all 12 district stations are represented in the existing `game.police_stations` register (13 stations total).
- Every facility resolves to a real seeded property, building, structured address and primary road access point, with district/neighbourhood and local-grid coordinates.
- Facility records carry stable refs, type, status and operating profile.

Patrol geography:
- 12 district patrol sectors, one per district.
- 24 neighbourhood beats, one per neighbourhood, each linked to its parent district sector.
- 151 road-segment-to-beat coverage links, assigning every currently routable road segment to one geographic beat. This is geographic coverage attribution, not a sequenced navigation route.
- Existing `game.police_units` now has nullable base-facility and assigned-beat links, ready for later unit creation and basing. No police units or personnel have been seeded.

New private RLS-enabled tables: `game.police_facilities`, `game.patrol_sectors`, `game.patrol_beats` and `game.patrol_beat_road_segments`. Sensitive access remains service_role-only. The existing police station and unit tables were extended with facility/base/beat references.

Follow-up index migration: `database/migrations/20261120112545_index_police_geography_and_landmark_foreign_keys.sql` (covers all nine FK-index findings from the performance advisor). Migration: `database/migrations/20261120112406_kingswell_police_facilities_patrol_sectors_and_beats.sql`. Regression: `database/tests/kingswell_police_facilities_patrol_geography.sql`; live rollback-only assertions passed for facility counts and physical links, station links, all 24 beats, all 12 sectors, complete 151-segment coverage and RLS.

This does not yet implement road routing, turn-by-turn paths, route optimisation, travel-time estimates, traffic, patrol schedules, active unit deployment bases or beat-level staffing. The local-grid property/facility coordinates remain planning-level fictional coordinates, not surveyed geometry.

## BP-02 — Weighted road-routing engine — 2026-11-20

Implemented and live in Supabase. Added a Dijkstra shortest-path engine over the existing 118-junction, 151-segment road graph. It calculates and persists ordered route legs between property access points (including police facilities and, later, incident addresses).

Capabilities:
- Fastest-route optimisation weights each segment by posted speed limit and segment length.
- Shortest-route optimisation weights by distance.
- Respects segment routability, one-way directionality and access profiles.
- Public profile is limited to public roads and public property access points.
- Police/emergency profiles can also use the two public_emergency_freight road segments and controlled service/public access points.
- Route output stores ordered segment legs, direction of travel, distance per leg, estimated seconds per leg, total distance and total estimated duration.
- Route calculation records include profile, optimisation, endpoint access points/junctions, algorithm version and calculation timestamp.
- Unreachable paths are recorded as unreachable rather than returning fabricated travel metrics.
- Function is SECURITY INVOKER in private schema game; execution is restricted to service_role. Route tables have RLS and no anon/authenticated grants.

The duration is a baseline estimate derived from posted segment speeds, rounded up per segment. It is not live traffic, dispatch-priority driving, siren/emergency speed uplift, turn-delay modelling or calibrated real-world travel time. The existing map is planning-level fictional geometry. No route calculations are left seeded in live data.

Migrations:
- database/migrations/20261120112929_kingswell_weighted_road_routing_engine.sql
- database/migrations/20261120113000_index_road_route_junction_foreign_keys.sql

Regression: database/tests/kingswell_weighted_road_routing.sql; rollback-only live test passed for police fastest/shortest routes, public route restrictions, ordered route legs, distance/time reconciliation, one-way validation and RLS/function security. The test leaves no route fixtures in the live database.

### Current live database baseline — 2026-11-20

The current private `game` schema contains 79 tables, 223 foreign keys and 367 indexes. RLS is enabled on all 79 tables. Supabase records 45 applied migrations. The post-build performance advisor reports no unindexed foreign keys; unused-index notices are expected while the fictional gameplay workload is still empty. These are the current live counts; older database snapshots elsewhere in this register are retained as historical audit observations, not current totals.


## Live dispatch routing integration — 2026-11-20

Implemented the first route-aware dispatch integration across BP-08, BP-10, BP-11, BP-12, BP-35, BP-37, BP-38 and BP-43.

- Police units now support an optional current map access point. Dispatch route origin prefers that position and falls back to the unit's base-facility access point.
- Each new incident deployment now receives a route snapshot and ETA using the existing weighted road-routing engine.
- Incident destinations resolve only through the structured incident property link and its primary routable access point. A free-text location is never converted into a guessed map point.
- Deployment records retain route ID, origin/destination access points, status, distance, baseline duration, estimated arrival, basis and computation time.
- New private RLS-enabled table deployment_route_history retains the initial route outcome and origin source for every deployment.
- game.get_dispatch_candidates(incident_ref) lists only active units with at least one currently rostered, duty-assigned, active employee who has no conflicting active deployment. It returns the eligible personnel and route/ETA snapshot.
- The existing dispatch command and its command-ledger idempotency and eligibility checks are unchanged; the new insert trigger adds route snapshotting after eligible deployment records are created.
- Route estimates use posted speed limits only. No live traffic, siren uplift, turn delays, guaranteed arrival or fictional-clock advancement is implied.
- Unresolved locations and unreachable routes are explicitly represented without fabricated distances or ETAs.
- All new foreign keys have covering indexes. Deployment route history is append-only for service_role: SELECT/INSERT only, with UPDATE/DELETE revoked. Security advisor retains the existing private-schema RLS-enabled/no-policy informational findings (80 tables); performance advisor has no remaining unindexed-FK finding after five additional indexes; health advisor returned no findings.

Migrations applied to Supabase and committed on main:
- database/migrations/20261120114500_kingswell_live_dispatch_route_integration.sql
- database/migrations/20261120114600_index_dispatch_route_foreign_keys.sql
- database/migrations/20261120114700_enforce_deployment_route_history_append_only.sql

Regression source:
- database/tests/kingswell_live_dispatch_route_integration.sql

Verification:
- Migration applied successfully.
- Regression guard transaction passed: route-history RLS, service-role-only candidate function ACL, deployment snapshot trigger, uninitialized-clock guard, missing/non-dispatchable incident guard, five route-FK indexes, and no unexpected persistent route/history writes.
- Current live baseline: 80 game tables, 231 foreign keys, 376 indexes, 50 applied migrations.
- No personnel, police units, incidents, deployments or route calculations have been seeded. Full seeded deployment-to-route/ETA end-to-end verification is therefore still pending; no fictional clock was initialized.
- The candidate function currently creates persisted route-calculation records when it evaluates eligible units. This is an auditable route computation, not a state/time advancement.

Completed: rollback-only seeded dispatch integration, ETA-ranked dispatch candidates, explicit unit-position gameplay command and auditable route recalculation after unit movement or road availability changes.


Route-history integrity hardening: deployment_route_history is now append-only for the runtime role. service_role has SELECT and INSERT only; UPDATE and DELETE are revoked. The regression test asserts this restriction. Applied migration and main source: database/migrations/20261120114700_enforce_deployment_route_history_append_only.sql. Current migration count: 50.

## Seeded dispatch-to-route end-to-end verification — 2026-11-20

**PASS:** `database/tests/kingswell_dispatch_route_end_to_end.sql` executed successfully against live Supabase inside a transaction ending in ROLLBACK.

The test temporarily creates:
- one fictional person and active police personnel record;
- one active patrol unit attached to an existing police facility;
- one active roster and on-duty assignment;
- one new incident at a different existing property with a primary routable access point.

It then verifies:
- candidate selection returns the eligible patrol unit and its on-duty officer;
- candidate routing resolves the correct facility origin and incident access point;
- route status is calculated and distance/duration are populated;
- estimated arrival equals the fixed test game time plus the posted-speed route duration;
- the real `game.submit_command(..., 'dispatch_unit', ...)` path dispatches the officer;
- the deployment trigger stores a calculated route, endpoints, distance, duration and ETA;
- exactly one initial route-history record is written for the deployment;
- replaying the same idempotency key returns the same command ID and does not duplicate deployment;
- incident status and dispatch event are updated;
- fictional game time does not advance.

All temporary persons, personnel, units, rosters, assignments, incidents, deployments, command-ledger rows, route calculations and route-history records are rolled back. The test leaves no fixture data in the live game.

Source: `database/tests/kingswell_dispatch_route_end_to_end.sql`.


## ETA-ranked candidates, unit position and route recalculation — 2026-11-20

**Implemented and verified.** Migration source:
- database/migrations/20261120115000_dispatch_eta_ranking_unit_position_and_recalculation.sql
- database/migrations/20261120115200_register_unit_position_as_gameplay_command.sql

Runtime capabilities:
- `game.get_dispatch_candidates_ranked(incident_ref)` wraps the eligibility and route-aware candidate resolver and orders units by earliest calculated ETA, with unresolved ETAs last, then duration, distance and unit reference as stable tie-breakers.
- `game.record_unit_position(unit_ref, access_point_uuid, reason)` stores a unit's current registered access point and fictional game-time timestamp. It rejects inactive units, missing/unroutable access points, missing reasons and an uninitialized clock.
- Text gameplay command: `position unit UNIT_REF at ACCESS_POINT_UUID because REASON`. The command is registered in the interpreter, help output and idempotent command ledger. It emits a game event.
- Moving a unit recalculates each of its active deployment routes and appends a route-history entry.
- Changing a road segment's `is_routable` state automatically recalculates routes for active deployments. Each result is retained in the append-only deployment route history; closed roads are excluded by the route engine.
- No route action advances the fictional clock. ETA remains a baseline posted-speed estimate without traffic, siren uplift or turn-delay modelling.

**PASS:** `database/tests/kingswell_eta_ranked_dispatch_candidates.sql` verifies two eligible units are ordered by ETA, with the unit already at the incident location first.

**PASS:** `database/tests/kingswell_unit_position_and_road_recalculation.sql` verifies the player-facing text command, position persistence, recalculation on movement, route-history append on road closure and reopening, and no fictional-clock advancement. Both tests end in ROLLBACK.

After verification, the live game remains unseeded: zero police units, incidents, deployments, route calculations and route-history records; the fictional clock remains uninitialized. Migration count is 53.


## Player-facing dispatch options and unit reassignment — 2026-11-20

**Implemented and verified.** Migration source: `database/migrations/20261120115500_player_dispatch_options_and_unit_reassignment.sql`.

Player commands:
- `dispatch options for INCIDENT_REF` returns incident context and ETA-ranked candidate units, each with available officer names, personnel references, service numbers, base facility, route status, route distance, baseline duration and estimated arrival. It does not dispatch anyone.
- `reassign UNIT_REF to INCIDENT_REF because REASON` transfers an active response to a different eligible unit.

Reassignment preserves the previous deployment rows, marking them cancelled with the fictional reassignment time rather than deleting them. It writes outgoing/incoming dispatch events and a game event with the reason, creates new deployment rows for the replacement unit's eligible on-duty officers, and relies on the deployment route-snapshot trigger to create each replacement route snapshot and history entry.

Whole-unit reassignment is deliberately blocked if:
- the incident has no active deployment;
- multiple different units are currently deployed to the incident;
- any officer has already arrived at the scene;
- the replacement unit is inactive, the same as the current unit, or has no eligible on-duty personnel.

The command is idempotent through the existing command ledger. No fictional time is advanced.

**PASS:** `database/tests/kingswell_player_dispatch_options_and_reassignment.sql` verifies parser/help registration, two ranked candidates with named officers, read-only options, initial dispatch, reassignment, preserved old deployment and route history, replacement deployment and route snapshot, outgoing/incoming dispatch events, game-event audit and unchanged fictional clock. The test is transaction-wrapped and ends in ROLLBACK.

The test was rerun from the committed GitHub file. Live game remains unseeded: zero units, incidents, deployments, route calculations and route-history records; fictional clock remains uninitialized. All 80 game tables remain RLS-enabled. New dispatch helper functions are executable by service_role and not by anon/authenticated.


## Arrival-driven patrol unit position history — 2026-11-20

**Implemented and rollback-only integration-tested.** Applied migration: `database/migrations/20261120115821_unit_location_history_and_arrival_position_sync.sql`.

- Added private RLS-enabled `game.unit_location_history` with unit, access point, fictional timestamp, source, deployment, officer, reason and contextual details.
- The deployment arrival transition now updates the patrol unit's current map access point to the incident's registered primary routable property access point.
- Each arrival appends a permanent location-history record. Runtime service_role can SELECT/INSERT but cannot UPDATE/DELETE the history.
- Other active, not-yet-arrived deployments assigned to the same unit have their routes recalculated from the new position; the deployment that just arrived is excluded.
- The trigger requires an initialized fictional clock, exact agreement between arrival time and current game time, and a registered routable incident access point. It does not advance the clock.

**PASS:** `database/tests/kingswell_unit_arrival_position_sync.sql` ran against live Supabase in a transaction ending in ROLLBACK. It verified unit position synchronization, exactly one arrival-history entry and unchanged fictional time. No fixture records or clock changes remain.

Documentation: `docs/operations/PATROL-UNIT-LOCATION-HISTORY.md` and the updated `docs/operations/LIVE-DISPATCH-ROUTING.md`.


## Patrol unit operational-state lifecycle — 2026-11-20

**Implemented and rollback-only regression-tested.** Migrations:
- `database/migrations/20261120120000_patrol_unit_operational_state_lifecycle.sql`
- `database/migrations/20261120120100_block_dispatch_to_out_of_service_units.sql`

Patrol units now have explicit operational states: `at_station`, `on_patrol`, `responding`, `on_scene`, `returning` and `out_of_service`. Dispatch creation automatically sets responding; officer arrival sets on-scene; ending the last active deployment sets returning. If another active deployment remains, the unit state reflects whether any officer is already on scene or still responding.

The service-role function `game.set_unit_operational_state(unit_ref,state,reason)` supports manual transitions to at-station, on-patrol, returning and out-of-service. Active deployments prevent a unit being marked at-station, on-patrol or out-of-service. Returning to station relocates the unit to its registered base access point. A database guard rejects deployment creation or reassignment to an out-of-service unit.

Every change is recorded in private RLS-enabled append-only `game.unit_operational_state_history`; service_role cannot update/delete its history. This is an authoritative state layer, not yet a complete patrol scheduler: patrol beat assignment, scheduled patrol tasks, player-facing state commands and automatic patrol commencement/return workflows remain outstanding.

**PASS:** `database/tests/kingswell_patrol_operational_state_lifecycle.sql` verified initial station state, patrol, dispatch, arrival, clearing, return to station, out-of-service status, rejection of a deployment to an out-of-service unit, history entries and unchanged fictional clock. Transaction rolled back. Post-test checks confirm zero persistent test units, zero state/location history rows, uninitialized fictional clock, RLS enabled and no service_role UPDATE/DELETE grants on state history.


## Patrol beat assignment, scheduling and coverage — 2026-11-20

**Implemented and rollback-only regression-tested.** Migration: `database/migrations/20261120121000_patrol_beat_assignment_scheduling_and_coverage.sql`.

- Added `game.patrol_schedules` for unit/beat/roster-linked patrol windows, overlap prevention and schedule lifecycle.
- Added append-only `game.patrol_coverage_events` to record beat changes and patrol starts/ends.
- Added `game.assign_unit_patrol_beat`, `game.schedule_unit_patrol`, `game.start_unit_patrol` and `game.end_unit_patrol` service-role functions.
- Patrol start requires an initialized game clock, active duty roster covering current game time, active assigned beat, matching current schedule and no active incident deployment.
- Patrol end completes the schedule and returns the unit to its registered base location when available; otherwise it transitions to returning without inventing a position.
- Beat reassignment is blocked during responding, on-scene, returning and out-of-service states. Overlapping schedules for the same unit are rejected.

**PASS:** `database/tests/kingswell_patrol_beat_scheduling_coverage.sql` verified scheduling, start/end transitions, coverage events and unchanged fictional time in a transaction ending in ROLLBACK. No fixtures persist.

Player-facing parser integration and automatic schedule commencement are not yet implemented; these functions are currently callable through the secured runtime database interface.

Documentation: `docs/operations/PATROL-BEAT-SCHEDULING-COVERAGE.md`.


## Player-facing patrol commands and live beat coverage — 2026-11-20

**Implemented and end-to-end regression-tested.** The existing natural-language command path now recognises and executes patrol commands through `game.execute_text_command`, retaining the existing command ledger and idempotency model.

Commands:
- `assign beat UNIT_REF to BEAT_REF because REASON`
- `schedule patrol SCHEDULE_REF UNIT_REF in BEAT_REF from ISO_TIMESTAMP to ISO_TIMESTAMP`
- `start patrol UNIT_REF because REASON`
- `end patrol UNIT_REF because REASON`
- `patrol status` (aliases: `patrol coverage`, `beat coverage`)

The coverage report returns all active beats, on-patrol unit details and schedule windows, plus covered/uncovered beat totals. Scheduled-but-not-started units do not count as covering a beat. Timestamps in schedule commands require ISO-8601 offsets. The command grammar does not yet expose optional roster selection, although the database scheduling function supports it.

**PASS:** `database/tests/kingswell_patrol_command_interface.sql` exercises assignment, scheduling, patrol start, live coverage query and patrol end through the real text-command dispatcher. It verifies the unit returns to station and the fictional clock remains unchanged. Transaction ends in ROLLBACK; no fixtures persist.

Parser and coverage function execution are restricted to service_role. Documentation: `docs/operations/PATROL-COMMAND-INTERFACE.md`.


## Automatic patrol interruption on incident deployment — 2026-11-20

**Implemented and rollback-only regression-tested.** When a patrol unit leaves `on_patrol` for `responding`, `on_scene`, `returning` or `out_of_service`, its active patrol schedule is automatically marked `suspended`. An append-only `coverage_interrupted` event records the game time and before/after operational states. Suspended units immediately stop counting toward beat coverage. Patrols are not silently resumed after an incident; an explicit new patrol start workflow is required.

**PASS:** `database/tests/kingswell_patrol_incident_interruption.sql` verifies schedule suspension, interruption event and unchanged fictional clock; transaction ends in ROLLBACK.

Migration: `database/migrations/20261120121300_suspend_patrol_coverage_on_incident_deployment.sql`. Documentation: `docs/operations/PATROL-INCIDENT-INTERRUPTION.md`.


## Patrol road movement and segment-level coverage — 2026-11-20

**Implemented and rollback-only end-to-end regression-tested.** The player command `patrol move UNIT_REF to ACCESS_REF because REASON` uses the existing police-profile weighted road-routing engine to move an on-patrol unit from its current registered access point to a destination access point on its assigned beat.

- Added append-only `game.patrol_movement_events`, one row per route leg, linked to the canonical route calculation, route leg, road segment and junction pair.
- Each leg records distance, estimated duration, fictional departure/arrival time, reason and whether the road segment belongs to the assigned beat. Transit legs outside the beat remain in the movement history but do not count as beat coverage.
- Unit current access point and location timestamp update to the destination.
- The explicit movement command advances the fictional clock by the route's estimated duration and records the change in `game_clock_history` and `game_events`; no background progression occurs.
- Movement is rejected if the unit is not actively on patrol, has no active schedule, the destination is not on its assigned beat, no route exists, or travel would exceed the patrol schedule.
- `patrol status` now includes visited road segments, on-beat patrol distance and latest movement per beat, plus citywide movement totals.
- Patrol commands are registered in `help` and dispatched through their own command handlers, not the forensic workflow.

**PASS:** `database/tests/kingswell_patrol_road_movement.sql` exercises patrol start, movement through `game.execute_text_command`, per-leg records, current-position update, explicit clock advancement, beat movement coverage and help registration. It runs in a transaction ending in ROLLBACK; no fixture data persists.

Migrations: `20261120121400_patrol_road_movement_and_segment_history.sql`, `20261120121500_fix_patrol_movement_route_variable_ambiguity.sql`, `20261120121600_record_transit_and_on_beat_patrol_segments.sql`, `20261120121700_include_road_movement_in_patrol_coverage.sql`, `20261120121800_register_patrol_commands_in_runtime_help.sql`, `20261120121900_remove_patrol_commands_from_forensic_dispatch.sql`.
Documentation: `docs/operations/PATROL-ROAD-MOVEMENT.md`.


## Patrol intelligence and coverage-gap reporting — 2026-11-20

**Implemented and rollback-only end-to-end regression-tested.** The player command `patrol intelligence` (aliases `patrol gaps`, `patrol analysis`) reports actual recorded patrol movement against the registered road-segment inventory of every active beat.

- Per-beat visited/total road segments, coverage percentage, movement-leg count, distance, movement minutes, distinct patrol days, latest movement and fictional hours since last movement.
- Beat coverage-gap classifications: never visited in the selected window, partially visited, or all registered segments visited.
- Least-visited road-segment list with traversal counts and last traversal time.
- Unit-level movement legs, distinct segments, distance, movement minutes and latest movement.
- Citywide totals for never/partially/fully visited beats, distinct segments, patrol distance and movement minutes.
- Optional reporting-window function parameters; the player command defaults to all recorded history through current fictional time. Future windows and invalid ranges are rejected.
- Movement minutes count recorded road-leg movement inside the assigned beat only. This is not stationary presence time, foot-patrol time or a measure of policing effectiveness.
- Added indexes for beat/time and road-segment/time reporting. Function and parser execution remain restricted to service_role; private schema and RLS posture unchanged.

**PASS:** `database/tests/kingswell_patrol_intelligence.sql` starts a temporary patrol, moves it along a real calculated route through the text command interface, verifies road/beat/unit/time metrics and help registration, then rolls back all fixtures. Reporting does not advance fictional time.

Migration: `database/migrations/20261120122000_patrol_intelligence_and_coverage_gap_reporting.sql`.
Documentation: `docs/operations/PATROL-INTELLIGENCE.md`.


## Patrol activity sessions and officer activity intelligence — 2026-11-20

**Implemented and rollback-only end-to-end tested.** Migrations: `database/migrations/20261120123000_patrol_activity_sessions_and_intelligence.sql` and `database/migrations/20261120122500_harden_patrol_activity_record_history.sql`; movement-history foreign-key indexes were added in `database/migrations/20261120122600_index_patrol_movement_event_foreign_keys.sql`.

- Added private RLS-enabled `game.patrol_activity_sessions` and append-only `game.patrol_activity_events`.
- Player commands: `start patrol activity UNIT_REF by PERSONNEL_REF at ACCESS_REF type TYPE because REASON` and `end patrol activity SESSION_REF after N minutes because REASON`.
- Supports foot patrol, stationary observation, community engagement, business visits, area checks, vehicle patrol stops and other logged activity.
- Validates active/on-patrol unit, active schedule and beat, active officer assigned to that unit, and an access point matching the unit's recorded location inside its beat. One active activity per unit/officer.
- A unit cannot move or end patrol while an activity remains open. Activity events are append-only.
- Starting an activity does not advance fictional time. Completing it advances time only by the explicitly supplied 1–720 minute duration and cannot exceed the active schedule.
- `patrol intelligence` now reports sessions/minutes by activity type and unit, separately from vehicle movement. Open sessions do not accrue assumed time.

**PASS:** `database/tests/kingswell_patrol_activity.sql` exercised both commands through `game.execute_text_command`, checked the explicit 15-minute clock advancement, activity intelligence, append-only event history and help registration. The SQL test completed successfully inside a transaction ending in ROLLBACK. No fixtures persist.

Documentation: `docs/operations/PATROL-ACTIVITY-SESSIONS.md` and updated `docs/operations/PATROL-COMMAND-INTERFACE.md`.



## Patrol observations, civilian contacts and linked intelligence — 2026-11-20

**Implemented and rollback-only end-to-end tested.** Migrations:
- `database/migrations/20261120124000_patrol_observations_and_civilian_contacts.sql`
- `database/migrations/20261120124100_patrol_intelligence_observation_contact_reporting.sql`
- `database/migrations/20261120124200_allow_patrol_observation_contact_events.sql`

- Added private RLS-enabled `game.patrol_observations` and `game.patrol_contacts`; both are append-only and link to activity session, officer, unit, beat, location and source command.
- Observation records have structured categories and a narrative description.
- Contact records can link existing persons, organisations/businesses, properties and incidents. Required entity-link rules vary by contact type; no duplicate people or organisations are created.
- Both commands require an active patrol activity session and the officer assigned to it. Supplied location must match the session's registered access point.
- Observation/contact records use current fictional game time and do not advance it.
- Player commands: `record patrol observation SESSION_REF category CATEGORY [at ACCESS_REF] because DESCRIPTION`; `record patrol contact SESSION_REF type TYPE [person PERSON_REF] [organisation ORG_REF] [property PROPERTY_REF] [incident INCIDENT_REF] outcome OUTCOME [notes NOTES]`.
- `patrol intelligence` now includes observation totals by category and contact totals by type with linked-entity counts.
- Help command list and activity-event types updated.

**PASS:** `database/tests/kingswell_patrol_observations_contacts.sql` exercised both commands through `game.execute_text_command`, validated parser payloads, person/organisation/property links, intelligence totals, immutable observation/contact records and unchanged fictional time. Test ran in a transaction ending in ROLLBACK; no fixtures persist.

Documentation: `docs/operations/PATROL-ACTIVITY-SESSIONS.md` and `docs/operations/PATROL-COMMAND-INTERFACE.md`.


## Searchable patrol intelligence and repeat-concern reporting — 2026-11-20

**Implemented and rollback-only end-to-end tested.** Migrations:
- `database/migrations/20261120125000_searchable_patrol_intelligence.sql`
- `database/migrations/20261120125100_refine_patrol_intelligence_search.sql`

- Added `game.search_patrol_intelligence(...)`, a unified read-only search over the original immutable patrol observation and contact records.
- Search supports free-text matching, optional beat, access-point, person, organisation and incident references, fictional-time windows, and a bounded result limit (1–500).
- Results retain source record type/reference, recorded game time, category/contact type, narrative/outcome, notes, beat, access point, location and linked entity references.
- Repeat-concern summaries group repeated records by source type, category/contact type and location, showing count and first/last recorded times.
- Results are explicitly labelled as recorded reports only; repeat counts do not establish criminality, corroboration, risk, identity or guilt.
- Player command: `search patrol intelligence [for WORDS]`. The current concise text command exposes free-text search; the secured database function also accepts structured filters and a selected fictional-time window.
- Search is read-only, uses the existing idempotent command ledger, does not modify source records and does not advance fictional time.
- Function/parser execution remains service_role-only in the private `game` schema.

**PASS:** `database/tests/kingswell_searchable_patrol_intelligence.sql` creates temporary patrol/officer/session fixtures, records two traffic observations at the same access point, searches through the real text command, verifies both source records and the repeat-location count, checks help registration and confirms unchanged fictional time. Test ends in ROLLBACK; no fixtures persist.

Live database verification after investigation-link work: 90 tables, 281 foreign keys, 453 indexes, 81 migrations; RLS enabled on all 90 game tables; no persistent link or test-person/unit rows; fictional clock remains uninitialized.


## Patrol intelligence investigation links and history — 2026-11-20

**Implemented and rollback-only end-to-end tested.** Migrations:
- `database/migrations/20261120130000_patrol_intelligence_investigation_links.sql`
- `database/migrations/20261120131000_patrol_intelligence_link_history_lookup.sql`
- `database/migrations/20261120132000_index_patrol_intelligence_link_foreign_keys.sql`

- Added `game.patrol_intelligence_links` as a separate append-only linkage record. It links exactly one existing patrol observation or contact to exactly one existing incident or case.
- Each link records its unique reference, source and target, reason, fictional link time, active officer attribution, originating command and an immutable `game_events` event.
- Source patrol records and target incident/case records are not modified. No new incident or case is created by linking.
- Duplicate source-target links return the existing link and do not create another record/event. Different targets can be linked separately.
- Foreign keys restrict deletion of referenced source/target/actor/command records. All linkage foreign keys are indexed. Link updates and deletes are rejected.
- Player command: `link patrol record RECORD_REF to incident INCIDENT_REF because REASON` or `link patrol record RECORD_REF to case CASE_REF because REASON`.
- Link history command: `patrol intelligence links` or `patrol intelligence links for RECORD_REF` (also accepts a link, incident or case reference).
- Link creation requires an initialized fictional clock and an active police personnel actor. Linking and lookup do not advance fictional time.
- Repeat linkage is an investigative association only, not proof, corroboration, or a finding about the truth of the source record.

**PASS:** `database/tests/kingswell_patrol_intelligence_links.sql` verifies parser and command help, creates a temporary patrol observation, links it to an existing test incident and case, confirms duplicate protection, verifies two immutable audit events, confirms the source observation is unchanged, checks link-history lookup and unchanged fictional time. Transaction ends in ROLLBACK; no test fixtures persist.

Live database verification: 90 tables, 281 foreign keys, 453 indexes, 81 migrations; all 90 game tables RLS-enabled; no link/test-person/test-unit rows remain; fictional clock remains uninitialized.



## Investigative leads and enquiry records — 2026-11-20

**Implemented and rollback-only end-to-end regression-tested.** Migration: `database/migrations/20261120130735_case_investigative_leads_and_enquiries.sql`.

- Added `game.case_leads` with stable lead references, case link, source type/reference, description, assigned investigator, status, priority, confidence, assessment rationale and fictional timestamps.
- Added append-only `game.case_lead_events` for creation, assignment, reassignment and assessment/status history.
- Added append-only `game.case_enquiries` and `game.case_enquiry_events` for the conducting officer, recording officer, method, action, result, outcome, source reference and fictional time.
- Commands: `case lead create`, `case lead assign`, `case lead assess`, `case enquiry record`, `case leads` and `case enquiries`. All are integrated into the text parser, command ledger, idempotency and help response.
- Enquiry officers must own the lead or hold an active assignment to its case. Only active or seconded personnel may be assigned or attributed.
- Investigative records do not advance fictional time. Private schema, RLS and service-role-only access are retained.

**PASS:** `database/tests/kingswell_case_investigative_leads.sql` passed through the actual parser/executor and verified creation, assignment, enquiry, assessment, list retrieval, idempotency, append-only protections, help and unchanged fictional time. Transaction ended in ROLLBACK.

Documentation: `docs/operations/CASE-INVESTIGATIVE-LEADS.md` and updated `docs/operations/PATROL-COMMAND-INTERFACE.md`.


## Typed links from investigative leads to existing entities — 2026-11-20

**Implemented and rollback-only tested.** Migration: `database/migrations/20261120131153_case_lead_entity_links.sql`.

- Added append-only `game.case_lead_entity_links` with a strict one-entity-type constraint and real foreign keys to existing persons, organisations, properties, evidence items and incidents.
- Player commands: `case lead link LEAD_REF entity TYPE ENTITY_REF because "REASON" by ACTOR_REF` and `case lead links LEAD_REF`.
- Links preserve reason, officer, command and fictional timestamp. Evidence links cannot cross-link evidence already attached to a different case.
- Duplicate source-to-lead links are recognised without creating duplicates. Linking does not modify source entities or advance fictional time.
- RLS, private schema, service-role-only access and append-only enforcement are retained.

**PASS:** `database/tests/kingswell_case_lead_entity_links.sql` verifies typed person linking through parser/executor, retrieval, duplicate protection, append-only enforcement and unchanged fictional time in a rolled-back transaction.


## Case interviews and witness statements — 2026-11-20

**Implemented and rollback-only end-to-end tested.** Migrations:
- `database/migrations/20261120131748_case_interviews_and_witness_statements.sql`
- `database/migrations/20261120131811_link_witness_statements_to_interviews.sql`

- Added immutable interview records, interview event history, numbered question-and-answer turns, witness statement records and statement adoption/signature event history.
- Player commands open interviews, record each Q&A turn, attach a witness statement to the same witness and case, record adoption/non-adoption/refusal to sign, conclude or interrupt interviews, and retrieve case interview lists, transcripts and statements.
- Supplementary statements reference the earlier statement; original text is never overwritten. A statement is explicitly a draft until its separate adoption event is recorded.
- Interviewer and recording officer must be active/seconded and assigned to the case or be its case lead. Only the recorded interviewer can add transcript turns or conclude/interrupt that interview.
- All write actions use command idempotency and actor attribution. They use the current fictional clock without advancing it. All five tables have RLS enabled, private-schema access and service-role-only grants.

**PASS:** `database/tests/kingswell_case_interviews_witness_statements.sql` verified parser/executor integration, interview creation, chronological Q&A, interview-linked witness statement, adoption event, conclusion, transcript/list retrieval, rejection of post-conclusion turns and unchanged fictional time. Transaction rolled back with no persistent fixtures.

Operations guide: `docs/operations/CASE-INTERVIEWS-WITNESS-STATEMENTS.md`.


## Suspect interviews and response assessments — 2026-11-20

**Implemented and rollback-only end-to-end tested.** Migrations:
- `database/migrations/20261120132555_case_suspect_interview_records_and_assessments.sql`
- `database/migrations/20261120132622_suspect_interview_player_commands.sql`
- `database/migrations/20261120132728_suspect_interview_help_and_case_state_guard.sql`

- Reuses existing case interviews and transcripts; suspect capacity is a separate append-only classification linked to the same interview, case and person.
- Adds append-only per-turn response assessments: admission, denial, no comment, qualified response, correction or other. Multiple assessments can be recorded without rewriting the transcript or prior assessments.
- Classification requires an open case/interview and the recorded interviewer. Assessments must point to a turn in that suspect interview and be recorded by its interviewer.
- Classification adds the existing person to the existing case-person relationship as suspect when needed. It does not create a new person record and does not imply guilt.
- New commands are registered in runtime help. Writes use the command ledger/idempotency and actor attribution; no action advances fictional time.
- Both new tables have RLS enabled, private-schema access and service-role-only grants; updates and deletes are rejected.

**PASS:** `database/tests/kingswell_suspect_interviews.sql` verifies parser/executor, classification, idempotent replay, chronological Q&A, response assessment, review retrieval, append-only enforcement, help registration and unchanged fictional time. Test transaction rolls back without persistent fixtures.

Operations guide: `docs/operations/SUSPECT-INTERVIEWS.md`.


## Case account comparison and discrepancy analysis — 2026-11-20

**Implemented and rollback-only end-to-end tested.** Migrations:
- `database/migrations/20261120133310_case_account_comparison_and_discrepancy_records.sql`
- `database/migrations/20261120133333_case_account_comparison_player_commands.sql`

- Compares two existing same-case sources: witness statements and chronological interview turns. Original accounts are never rewritten.
- Records discrepancy categories and the investigator's description.
- Appends assessments (unresolved, explained, partially explained, not a conflict) with full history.
- Links existing case evidence without changing custody or forensic records.
- Retrieval returns both source accounts, discrepancy, assessment history and linked evidence.
- Officer must be case lead or actively assigned; case must remain open. Commands use idempotency and actor attribution and do not advance fictional time.
- Three new tables are RLS-enabled, private-schema/service-role-only and append-only.

**PASS:** `database/tests/kingswell_case_account_comparisons.sql` tests parser/executor, source resolution, idempotency, assessments, evidence links, retrieval, help, append-only protection and unchanged fictional time. Transaction rolls back without persistent fixtures.

Operations guide: `docs/operations/CASE-ACCOUNT-COMPARISONS.md`.


## Unified investigative case review dossier — 2026-11-20

**Implemented and rollback-only tested.** Migration: `database/migrations/20261120133851_case_review_dossier_and_player_command.sql`.

- Added read-only `game.get_case_review_dossier(case_ref)` and player command `case review CASE_REF`.
- Consolidates case metadata, assignment history, leads, lead-entity links, enquiries, tasks, witness and suspect interviews, chronological turns, witness statements, suspect-turn assessments, account comparisons and assessments, evidence register and transfer history, forensic requests, examinations, findings, report versions, and linked incidents.
- Dossier is a live projection over existing authoritative records; it creates no duplicate evidence, statements or investigative conclusions.
- Does not infer credibility, deception, guilt, identify a culprit or auto-close leads. Existing case play secrecy rules remain unchanged.
- Read-only, idempotent command; does not advance fictional time. Unknown case references are rejected. Private schema/service-role-only execution.

**PASS:** `database/tests/kingswell_case_review_dossier.sql` verifies parser/executor, complete empty-case section shape, idempotent replay, missing-case rejection and help registration. Transaction rolls back without persistent fixtures.

Operations guide: `docs/operations/CASE-REVIEW-DOSSIER.md`.


### Case review dossier access-control refinement — 2026-11-20

Follow-up migration: `database/migrations/20261120133944_case_review_dossier_and_player_command.sql`.

The player command now requires `case review CASE_REF by OFFICER_REF`. The named officer must match the command actor and be the recorded case lead or have an active case assignment. This prevents unassigned personnel from retrieving a case dossier through the player command. The underlying dossier function remains private/service-role-only.

The rollback-only regression now verifies actor attribution and case access alongside dossier aggregation, idempotent replay, missing-case rejection and help registration.


### Case review help registration deduplication — 2026-11-20

Migration: `database/migrations/20261120134240_deduplicate_case_review_help_command.sql`. The help wrapper now checks whether `get_case_review_dossier` is already present before appending it, so the command appears exactly once. The rollback-only case review test asserts unique help registration, assigned-officer access and successful dossier retrieval.


### Case review dossier active-personnel safeguard — 2026-11-20

Migration: `database/migrations/20261120134345_case_review_require_active_personnel.sql`.

The case review command now rejects personnel who are neither active nor seconded, even if a stale lead or assignment reference remains. Case lead/active assignment access and actor matching remain enforced.

### Case review dossier completeness refinement — 2026-11-20

Migration: `database/migrations/20261120134455_case_review_dossier_tasks_and_linked_evidence.sql`.

The read-only dossier now includes the case task register and includes evidence associated through case account comparisons, investigative lead links and forensic requests, even where the evidence item's primary case_id is not populated. Original evidence records remain authoritative.


## Supervisory case review and status governance — 2026-11-20

**Implemented and live-tested.** Applied migration: `database/migrations/20261120135028_case_supervisory_review_and_status_governance.sql`.

- Added append-only `game.case_supervisory_reviews` and `game.case_status_events` records.
- Added supervisor review outcomes: continue investigation, further enquiries, recommend submission, suspension, closure or reopening. Recommendations do not automatically alter case status.
- Added controlled status transitions across open, under investigation, suspended, submitted, closed and reopened. Invalid transitions are rejected.
- Status changes require an active/seconded officer holding an active `supervisor` assignment on that case, a reason, and an initialized fictional clock.
- Closure records the current fictional close time; reopening clears the active close timestamp while retaining immutable closure history.
- Added idempotent player commands and history retrieval; no command advances fictional time.
- Tables remain private, RLS-enabled and service_role-only. Review and status histories reject update/delete.

Rollback-only regression: `database/tests/kingswell_case_governance.sql`.
Operations guide: `docs/operations/CASE-GOVERNANCE.md`.


The case review dossier now includes supervisory reviews and case status transition history. The governance foreign-key indexes were added after advisor review.


**Dossier supervisory history:** `database/migrations/20261120135234_case_dossier_supervisory_history.sql` adds the supervisory review and status history arrays to the consolidated dossier. 

**Governance indexes:** `database/migrations/20261120135332_case_governance_foreign_key_indexes.sql` adds covering indexes for reviewer, actor and command foreign keys identified by the database advisor.


## Independent prosecutor review and formal charges — 2026-11-20

**Implemented, deployed and rollback-only regression verified.** Migrations:
- `database/migrations/20261120151654_independent_prosecutor_review_and_formal_charges.sql`
- `database/migrations/20261120151723_integrate_independent_prosecutor_with_existing_runtime.sql`
- `database/migrations/20261120151757_index_prosecution_review_command_reference.sql`

Adds distinct prosecutor profiles, independent referral reviews, append-only review history, formal charge records and append-only charge history. Police submit referrals and appoint prosecutor profiles; only active prosecutors can accept, return or decline referrals. Charges require an accepted referral and are recorded by count.

Commands: `prosecutor appoint`, `prosecutor review`, `prosecution charge file`, `prosecution charges`. All use idempotency and preserve fictional time. A charge remains an allegation, not a finding of guilt.

**PASS:** `database/tests/kingswell_prosecutor_charges.sql` tests referral, appointment, review, charge filing, retrieval and clock preservation. Fixtures roll back.

Guide: `docs/operations/PROSECUTOR-CHARGES.md`.


## NPC disclosure and defence materials — 2026-11-20

**Implemented, deployed, regression-tested and synced to GitHub main.**

Migrations:
- `20261120152522_disclosure_packages_and_defence_materials.sql`
- `20261120152636_harden_disclosure_receipt_and_case_access.sql`
- `20261120152706_register_disclosure_commands_in_game_help.sql`
- `20261120152754_route_disclosure_commands_through_text_runtime.sql`
- `20261120152854_include_disclosure_history_in_case_dossier.sql`
- `20261120153046_scope_disclosure_retrieval_to_case_prosecutor.sql`

Six private, RLS-enabled tables record NPC defence counsel profiles/assignments, prosecution and defence packages, package items, immutable disclosure events and service receipts. Prosecution disclosure requires an accepted referral and filed charge. Defence disclosure requires assigned NPC counsel. Evidence items must belong to the same case. Items can be disclosed, redacted or withheld with reasons. Packages are served to the opposite NPC side and acknowledged only by the intended recipient.

Commands are registered in the text runtime and help. The case dossier now includes disclosure history. All actions use the idempotency ledger and current fictional time without advancing it.

**PASS:** rollback-only test `database/tests/kingswell_disclosure_workflow.sql` covers both directions, item classification, service, acknowledgement, package retrieval, dossier integration and unchanged clock. All test fixtures roll back.


## NPC court registry, docket and hearing management — 2026-11-20

**Implemented, deployed and rollback-only regression-tested.**

Adds seven RLS-enabled private tables:
- `game.courts`
- `game.court_official_profiles`
- `game.court_cases`
- `game.court_hearings`
- `game.court_hearing_attendance`
- `game.court_orders`
- `game.court_hearing_events`

Features: court creation, NPC judicial/clerk appointments, case registration following a filed charge, judge assignment, hearing scheduling, attendance, adjournment, conclusion, judicial orders, case docket retrieval and case dossier integration. Court orders and event history are append-only. Case docket access is restricted to linked case actors. Commands use the shared idempotency ledger and do not advance fictional time.

Commands: `court create`, `court official appoint`, `court case register`, `court case assign judge`, `court hearing schedule`, `court hearing attendance`, `court hearing adjourn`, `court hearing conclude`, `court order issue`, `court docket`, `court hearing`.

**PASS:** `database/tests/kingswell_court_registry_and_hearings.sql` verifies full NPC-to-NPC court workflow, access denial, court event history, docket, case dossier, help and clock preservation. All fixtures roll back.

Operations guide: `docs/operations/COURT-REGISTRY-HEARINGS.md`.


## NPC trial proceedings foundation — 2026-11-20

**Deployed and parser/runtime regression-tested.** Added four private, RLS-enabled tables: `game.trial_pleas`, `game.trial_proceedings`, `game.trial_evidence_tenders` and `game.trial_proceeding_events`. Each plea, proceeding and event history is append-only. Evidence tenders are linked to existing same-case evidence; judicial admissibility rulings are recorded without altering the original evidence item or its chain of custody.

Commands: `court plea record`, `court trial record`, `court trial tender` and `court trial rule`. Help registration includes all four commands. The command runtime retains the existing court, prosecution and earlier command fallbacks, uses the shared idempotency ledger, and does not advance fictional time.

Plea records are per individual filed charge. Trial proceedings can record openings, witness examination/cross-examination/re-examination, accused testimony, submissions, objections, judicial rulings, closing submissions and jury directions. Only the assigned active judge can record proceedings or rule on a tender. Prosecutors and assigned defence counsel tender evidence on their respective sides.

**PASS:** parser checks for all four trial commands, existing court command parsing, existing prosecution command parsing, help registration and the trial handler's clock guard. The help-command test record was removed after verification. Full end-to-end NPC trial fixtures are not yet possible because the game currently has no seeded people, prosecutors, defence counsel, evidence or court officials. `database/tests/kingswell_trial_proceedings.sql` contains rollback-only parser/schema regression checks.

Migrations:
- `20261120155118_trial_proceedings_foundation.sql`
- `20261120155132_trial_runtime_fixes.sql`
- `20261120155244_trial_help_registration.sql`

Operations guide: `docs/operations/TRIAL-PROCEEDINGS.md`.

Current database total: **162 `game` tables**. The fictional clock remains uninitialized; no trial NPCs or records have been seeded.


## Per-charge verdicts and sentencing — 2026-11-20

**Deployed and regression-tested.** Added three private, RLS-enabled tables: `game.trial_verdicts`, `game.trial_sentences` and `game.trial_outcome_events`. Verdict, sentence and outcome history records are append-only.

- A judge records a separate `guilty` or `not_guilty` verdict for each filed charge, with written reasons.
- Verdicts require a matching active court case, scheduled trial hearing, assigned active judge, an already recorded plea, and no unresolved evidence tenders.
- One first-instance verdict is permitted per charge. Later appeal decisions will be separate appellate records, not edits to the original.
- Sentencing requires a guilty verdict, a concluded trial hearing, and a due sentencing hearing under the assigned active judge.
- Sentence types: custodial, fine, community service, probation, conditional discharge, absolute discharge, other.
- Custodial terms require positive fictional game days; fine sentences require a positive fictional currency amount.
- Trial record retrieval now includes case-wide verdicts and sentences.

Commands: `court verdict record` and `court sentence impose`. Both are registered in game help, routed through the shared idempotency ledger, and do not advance fictional time.

**PASS:** rollback-only parser tests for guilty/not-guilty verdicts and custodial/fine sentences; regression checks for existing plea, court and prosecution parsers; help registration; command routing reaches the trial executor; no test ledger rows remain. Full seeded end-to-end NPC outcome tests are deferred because the game clock and NPC/court population are still uninitialized.

Current database total: **165 `game` tables**, all **165/165 RLS-enabled**. Fictional clock remains NULL. No verdicts, sentences or outcome events were seeded.

Migrations:
- `20261120155709_charge_verdicts_and_sentencing.sql`

Test:
- `database/tests/kingswell_charge_verdicts_sentencing.sql`

Guide:
- `docs/operations/CHARGE-VERDICTS-SENTENCING.md`


## Correctional foundation and sentence administration — 2026-11-20

**Database foundation implemented and schema regression passed; player commands are not yet wired.**

Applied the correctional foundation migration to the live private `game` schema and mirrored it to GitHub `main`.

Six new RLS-enabled tables:
- `game.correctional_facilities`: fictional facility register and capacity/status metadata.
- `game.prisoner_admissions`: persistent admissions linked to existing NPC person identities and facilities; one active admission per person.
- `game.prisoner_sentence_terms`: links existing imposed custodial sentences to an admission, with sequence and first/concurrent/consecutive commencement mode.
- `game.sentence_credit_events`: append-only pre-sentence custody, appeal and administrative credit records.
- `game.correctional_events`: append-only prisoner and facility event history.
- `game.prisoner_placements`: unit/cell placement history with one current placement per admission.

Added `game.get_correctional_record(admission_ref)`, a read projection of admission, person, facility, placement history, sentence terms, credits, remaining days per term and correctional events. No duplicate person or sentence identities are created.

**PASS:** live rollback-only schema test confirmed all six tables, RLS on all six, both append-only triggers and the read projection. Live database now has **171 tables, all 171 RLS-enabled**. No fictional correctional facilities, prisoners, admissions, placements or sentence terms have been seeded.

**Not yet implemented:** runtime parser/executor commands for admissions, sentence commencement, credit entry, transfer, release and record retrieval; cumulative release-date calculation for consecutive/concurrent terms; prison staffing/capacity enforcement; daily routines, visits, communications, work/education, welfare, incidents, discipline, rehabilitation, parole and autonomous NPC processing. The fictional clock remains uninitialized.

Migration: `database/migrations/20261120161000_correctional_foundation_and_sentence_administration.sql`

Test: `database/tests/kingswell_correctional_foundation.sql`

Guide: `docs/operations/CORRECTIONAL-FOUNDATION.md`


### Correctional foreign-key index refinement — 2026-11-20

Added 18 covering indexes for correctional admission, sentence-term, credit-event, correctional-event and placement foreign keys. The correctional foundation regression test now asserts these indexes exist.

Migration: `database/migrations/20261120162000_correctional_foreign_key_indexes.sql`.


## Correctional command/runtime integration — 2026-11-20

**Implemented and regression-tested.**

The correctional parser and runtime now integrate with the existing Kingswell command chain. Existing interpreter/executor implementations were preserved as fallback functions rather than replaced. New correctional commands use the shared `game.game_commands` idempotency ledger and manual fictional clock.

Commands now supported:
- `prison facility create`: create a fictional facility with type, capacity and location description.
- `prison admit`: admit an existing NPC person to remand, sentenced custody or transfer-in; remand requires an existing court-case link; sentenced admission requires an existing custodial sentence, guilty verdict and matching accused identity.
- `prison sentence add`: attach additional custodial sentences to an active admission with ordered first/concurrent/consecutive term mode, matching person and matching court case.
- `prison place`: assign or change a unit/cell placement; occupied cells are rejected.
- `prison record`: retrieve the correctional record.
- `prison facilities`: list facility status, capacity and occupancy.

All commands require active/seconded police personnel identity at this stage. No correctional NPC/staff profile or autonomous prison workflow is yet implemented. No commands advance fictional time.

**PASS:** rollback-only tests covered all six parser routes, an existing court-verdict parser regression, and executor dispatch rejection for an unknown actor. Test ledger rows were rolled back. Live state remains **171 game tables, 171 RLS-enabled**, zero correctional facilities/admissions, and uninitialized fictional clock.

Follow-up migration corrected sentence-to-court-case matching for additional sentence terms.

Migrations:
- `database/migrations/20261120170000_correctional_command_runtime_integration.sql`
- `database/migrations/20261120170500_correctional_sentence_case_link_validation.sql`

Test: `database/tests/kingswell_correctional_runtime.sql`

Guide: `docs/operations/CORRECTIONAL-RUNTIME.md`


### Correctional read-only access before game start — 2026-11-20

**Implemented and regression-tested.** Corrected the correctional executor's blanket clock guard. The `prison record` and `prison facilities` commands are read-only and can now be used while the fictional clock remains uninitialized. Facility creation, admission, sentence-term changes and prisoner placement still require the initialized game clock.

This allows inspection and preparation without choosing a start date or starting the simulation. The change does not initialize, reset or advance the clock.

**PASS:** rollback-only test verifies both parser routes, the executor's narrow read-only exemption and that `game.simulation_state.current_game_time` remains NULL. No game records were created or changed. End-to-end record retrieval remains untested because there are no seeded correctional facility/admission/personnel records.

Migration: `database/migrations/20261120161200_correctional_read_only_queries_without_clock.sql`

Test: `database/tests/correctional_read_only_without_clock.sql`

Guide: `docs/operations/CORRECTIONAL-RUNTIME.md`


## Correctional NPC staff profiles and directory — 2026-11-20

**Implemented and regression-tested.** Added a persistent correctional staff profile linked to existing NPC person identities, with facility assignment, role, employment status, appointment game time and appointing actor. A person can have one correctional staff profile. Appointment history is stored in a separate append-only event table.

Initial role catalogue: facility governor, deputy governor, custody supervisor, correctional officer, escort officer, healthcare professional, psychologist, educator, probation officer, social worker, administrator and specialist. These roles do not confer police authority.

Commands:
- `prison staff appoint PERSON_REF to FACILITY_REF role ROLE by PERSONNEL_REF`
- `prison staff list FACILITY_REF by PERSONNEL_REF`

Appointments require the initialized manual game clock, an existing NPC and an active facility. Staff directory queries are read-only and available before game start. Commands use the shared idempotency ledger. No time advances automatically.

**PASS:** rollback-only parser tests for both new commands; regression tests for existing correctional facility and court-verdict parsers; runtime actor-dispatch rejection; RLS enabled on both new tables; staff event history append-only. Fictional clock remains NULL. No staff, facilities or NPC records were seeded.

Migration: `database/migrations/20261120173500_correctional_staff_profiles_and_commands.sql`

Test: `database/tests/kingswell_correctional_staff.sql`

Guide: `docs/operations/CORRECTIONAL-RUNTIME.md`


### Correctional staff authority boundary refinement — 2026-11-20

The initial staff-profile migration briefly exposed an appointment command attributed to a police personnel actor. That conflicted with BP-29's separation between police and correctional authority. The player-facing appointment command has therefore been removed. Correctional NPC appointments and staff lifecycle decisions must be made by the correctional institution's own NPC command structure when that system is implemented. Police can inspect the read-only staff directory but cannot appoint, supervise or manage correctional staff through police authority.

The staff profile/event tables remain as the persistent foundation. The supported command is:

- `prison staff list FACILITY_REF by PERSONNEL_REF`

**PASS:** rollback-only test confirms staff listing remains parsed, the appointment command is no longer accepted or included in runtime help/allow-lists, existing facilities and court commands still parse, RLS remains enabled, and the fictional clock remains uninitialized.

Migration: `database/migrations/20261120174500_correctional_staff_directory_authority_boundary.sql`

Test: `database/tests/kingswell_correctional_staff_authority.sql`


## BP-02 — Country, city and geographical architecture — completed 2026-11-20

### Canonical geography delivered
- One fictional country: Republic of Asterfell (AST).
- Eight national administrative regions; Kingswell Capital Region is the single capital region.
- One detailed primary city: Kingswell (KNG), linked to the capital region and the country's capital-city reference.
- City baseline: 100,000 permanent residents; 20,000 m × 16,000 m north-up local metre grid; southern coast; north-eastern river corridor terminating at the south-eastern harbour.
- Twelve stable district codes and 24 stable neighbourhood codes (two neighbourhoods per district).
- Twelve district planning envelopes, corrected in place from millimetre-scaled values to the documented metre grid. All 12 now fit x=0–20,000 m and y=0–16,000 m. Envelopes remain planning extents, not exact exclusive cadastral polygons.
- 51 named roads, 118 junctions, 151 road segments and three explicit 1,000 m river bridges; the routable graph is connected.
- Twenty-four named landmarks are linked to the existing BP-04 property/building/access records.
- Existing BP-04 property/building/address/access inventory and BP-05/BP-10 police facility/sector/beat layers are referenced, not duplicated.
- Weighted fastest/shortest road routing and live dispatch route/ETA snapshots are implemented against the canonical road network.

### Database extension
Applied:
- `20261120162026_bp02_complete_national_geography_and_correct_city_grid`
- `20261120162040_bp02_finish_all_district_envelope_coordinate_corrections`

The existing `world_countries`, `regions` and `cities` tables were extended; no duplicate geography tables were created. Existing district map-envelope rows were corrected in place. The country now records its geographic profile and capital city; regions record order, relative position and geographic description; the city records its local-grid dimensions and map conventions.

### Passed rollback-only regression suites
- `database/tests/kingswell_geography_seed.sql` — country/region/capital hierarchy, grid metadata, districts/neighbourhoods, corrected envelopes, road topology/connectivity, bridges, landmarks and RLS.
- `database/tests/kingswell_properties_buildings_addresses.sql` — existing property/building/unit/address/access/landmark inventory and hierarchy.
- `database/tests/kingswell_police_facilities_patrol_geography.sql` — existing police facilities, district sectors, neighbourhood beats and road-segment coverage.
- `database/tests/kingswell_weighted_road_routing.sql` — fastest/shortest paths, distance/time reconciliation, access restrictions, directionality and route security.
- `database/tests/kingswell_live_dispatch_route_integration.sql` — route-history protections, dispatch integration guards, ETA-related indexes and no persistent route writes during readiness checks.

All five suites executed successfully against the live Supabase project and rolled back. Post-test verification: 173 tables, 595 foreign keys, 846 indexes, RLS on all 173 tables; zero persons, police personnel, police units, cases, evidence, incidents, dispatch calls, route calculations or route-history records; fictional clock remains NULL/uninitialised.

### Remaining deliberate limits
National regions are jurisdictional references, not surveyed polygons. Kingswell district extents are planning envelopes, not exact exclusive polygons. Outside Kingswell there is no detailed street/property map. Live traffic, calibrated response-time simulation, exact cadastral boundaries and detailed building interiors remain later refinements under their owning divisions.


## BP-03 — Population and Individual Simulation — foundation delivered 2026-11-20

### Design decision
Resolved the open processing-model choice: every person has one persistent canonical identity; simulation effort varies by activity and police relevance. The levels are background, active, police_relevant and full. Promotion is monotonic and cannot be reversed.

### Existing records extended
- `game.persons` remains the sole person identity store; it was extended with birth location, death date, preferred language, personality/behaviour profiles and simulation-level metadata.
- Existing `person_addresses` now has current-primary address integrity and requires explicit effective dates rather than a real database date default.
- Existing `person_relationships` has date-order and duplicate-current-link protection.
- Existing `organisation_personnel` employment links have valid-date checks.
- Existing police personnel continue to reference the same person identity.

### New life/population records
- `households` and `household_memberships`.
- `person_population_memberships` for overlapping dated categories and city association.
- `person_life_events` for append-only life milestones; death closes current addresses, household/population memberships, employment and routines.
- `person_routines` for recurring weekly schedules, including overnight schedules.
- `person_activity_events` for append-only actual activity, guarded by fictional game time.
- `person_simulation_promotions` for append-only promotion provenance.
- `game.get_population_summary(city_code)` counts distinct people and distinct category memberships without double-counting overlapping groups.
- Case, incident-party, dispatch-caller and incident-property resident links automatically promote relevant people to full simulation.

### Regression
`database/tests/kingswell_population_life_foundation.sql` passed as a rollback-only live Supabase test. It verifies identity, addresses, households, overlapping categories, distinct population counts, relationships, routines, birth/death life events, death-related membership closure, append-only history, monotonic promotions, police-relevance auto-promotion, activity clock guards, RLS and the uninitialised clock. Post-test counts remain zero for persons, households, memberships, routines, life events, activity events and promotions.

### Applied migrations
- `20261120162714_bp03_persistent_population_households_routines_and_life`
- `20261120162748_bp03_population_summary_and_person_provenance_hardening`
- `20261120162835_bp03_population_summary_requires_current_household_members`
- `20261120163022_bp03_end_current_memberships_on_person_death`

### Deliberate dependency; no premature population seed
BP-04 now provides 24,512 units classified as residential across the 656-property city inventory. This supports the 100,000-person baseline at approximately 4.08 residents per dwelling. The former housing-capacity blocker is cleared; the next BP-03 task is the 100,000-person seed and household/address allocation using only canonical BP-04 property, building, unit and address references. No duplicate properties, buildings, units or addresses will be created under BP-03. Routine execution is owned by the runtime scheduling work in BP-35; this foundation does not advance fictional time.

### Live structural/health snapshot
180 private `game` tables; 619 foreign keys; 889 indexes; RLS enabled on all 180 tables; Supabase health advisors returned no findings. No persistent test population was created. Fictional clock remains NULL/uninitialised.


## BP-04 — Primate-city properties, businesses and neighbourhood maps — delivered 2026-11-20

### Canonical expansion
The BP-02 base inventory remains intact: the original 480 properties, 480 buildings, 712 units, 480 addresses and 480 access points are preserved. BP-04 extends those canonical records to 656 properties, 656 buildings, 26,888 units/premises, 656 primary addresses and 656 primary road-linked access points.

The 176 added parcels are 96 residential towers and 80 multi-tenant commercial centres. The towers have 32 floors each; their existing 256 unit records include two ground-floor retail units and 254 residential units. The 80 commercial centres provide 1,600 separately addressable commercial/industrial/transport units. A further 160 existing Riverside mixed-use units are occupied by neighbourhood businesses. The 192 tower podium retail units and 160 Riverside mixed-use units add 352 neighbourhood businesses.

### Detailed property and occupancy records
One-to-one detail profiles now exist for all 656 properties, all 656 buildings and all 26,888 building units. Property profiles include cadastral/title identifiers, zoning/permitted uses, tenure, heritage/flood/contamination, fictional valuation/charges/insurance, utilities, security, fire safety, accessibility, local-grid parcel outline, map label and planning notes. Building profiles include architecture, structure, materials, floor directory, gross floor area, estimated height, condition, lifts, fire compartments, alarms, sprinklers, backup power, CCTV, access control, loading bays/docks, parking, service yard, footprint and systems. Unit profiles include floor/suite, use, area, occupancy capacity, bedrooms/bathrooms, meters, access, security zone and condition.

Property interests distinguish registered owners, landlords and property managers. All 656 properties have one current registered-owner record. Twelve property holding groups and relevant public estate authorities support the fictional title/management register. Organisation site records extend the existing `organisation_locations` identity with exact building-unit, occupancy, lease, operating-hours and site-detail information.

### Primate-city business and public institution register
The city now has 1,452 businesses across financial services (150), import/export (130), logistics/warehousing (170), transport (100), manufacturing (100), wholesale (100), retail (100), hospitality/entertainment (80), professional services (60), technology/media (50), construction/property (40), property management (20) and neighbourhood services (352). The business register estimates 43,412 employee positions; these are not person/NPC records. Twenty-five public/institutional headquarters have current site records, including Parliament, the Presidency, ministries, Central Bank, financial regulator, revenue/customs authorities, City Authority, Port/Airport/Rail authorities, transit operator, hospital, university, emergency service, archives and trade/public media institutions. Total organisation count is 1,490; current business/institution sites are 1,477.

### Map and player interface
City property-map layer is KNG-MAP-0.2; the underlying KNG-MAP-0.1 local-metre coordinate system and BP-02 road/district/neighbourhood identities are unchanged. All properties have a primary address and access point connected to a real seeded road segment and nearest endpoint junction. Parcel/building outlines are local-grid schematic geometry, not surveyed legal boundaries.

Read-only query functions and text commands:
- `property record PROPERTY_REF by PERSONNEL_REF`
- `property map NEIGHBOURHOOD_CODE by PERSONNEL_REF`
- `property summary by PERSONNEL_REF`
- `business record BUSINESS_NUMBER by PERSONNEL_REF`
- `business directory by PERSONNEL_REF`
- `business directory sector SECTOR by PERSONNEL_REF`
- `business directory district DISTRICT_CODE by PERSONNEL_REF`
- `business directory search "TEXT" by PERSONNEL_REF`

### Regression and health
`database/tests/kingswell_primate_city_property_business_foundation.sql` passed as a rollback-only live Supabase test. It checks baseline preservation, property/building/unit counts, full dossier coverage, addresses/access/road junction links, local-grid bounds and non-colliding property centres, registered ownership, business and public-site counts, unique unit occupancy, map and directory queries, property/business text commands, idempotency, help and preservation of existing correctional command parsing. New-property route calculations to police headquarters also passed. BP-02 geography/property/patrol/routing suites and BP-03 individual-life suite passed again after BP-04.

Live structural snapshot: 185 tables, 627 foreign keys, 912 indexes; RLS enabled on all 185 tables; no Supabase health-advisor findings. No persistent persons, households, cases, incidents, dispatch calls or route calculations were created by the regression tests. The fictional clock remains uninitialised.

### BP-03 dependency cleared
24,512 residential units now provide planning capacity for the 100,000-person baseline at about 4.08 residents per unit. BP-03 population and household allocation can proceed next. BP-05 must wait until BP-03's population seed is complete, preserving blueprint order.
