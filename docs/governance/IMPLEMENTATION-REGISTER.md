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
| Database schema | Runtime foundation implemented | Private `game` schema; 42 tables, 80 foreign keys and 147 indexes; seven migrations applied; one paused, unconfigured clock row; no fictional world/personnel data seeded |
| Application/gameplay code | In progress | Database-backed text command interpreter, controlled clock and initial emergency-call/incident intake implemented; full domain handlers remain outstanding |
| Runtime regression tests | Implemented; transaction smoke-tested | `database/tests/runtime_foundation.sql` and `database/tests/text_interpreter_dispatch.sql` cover command parsing, idempotency, clock guards, emergency-call/incident creation and event history; test data rolls back |

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
| BP-08 | Units and Deployment | Approved; detailed rules remain open for refinement |
| BP-09 | Police Resources | Approved; details to refine with later operational divisions |
| BP-10 | Patrol Operations | Approved; links to dispatch and incident design to refine |
| BP-11 | Emergency Communications | Approved; initial text-based call intake, call ledger and dispatch event creation implemented; full call-taking and dispatch workflow remains outstanding |
| BP-12 | Incident Management | Approved; initial incident creation from dispatch calls implemented; full incident lifecycle remains outstanding |
| BP-13 | Crime Architecture | Approved; detailed fictional offence catalogue to populate |
| BP-14 | Crime Generation | Approved; frequency and behaviour tuning to follow |
| BP-15 | Case Management | Approved; investigative methods and legal review to refine |
| BP-16 | Investigation | Approved; specialist procedures and legal powers to refine |
| BP-17 | Victims and Witnesses | Approved; specialist safeguarding and legal procedures to refine |
| BP-18 | Suspects and Offenders | Approved; legal-status interfaces and specialist procedures to refine |
| BP-19 | Interviews and Interrogations | Approved; legal safeguards and specialist procedures to refine |
| BP-20 | Surveillance | Approved; statutory definitions, authorisations and oversight to refine |
| BP-21 | Intelligence | Approved; statutory powers, source handling and governance to refine |
| BP-22 | Crime Scenes | Approved; legal powers and specialist standards to refine |
| BP-23 | Evidence Management | Approved; evidential rules, retention and professional standards to refine |
| BP-24 | Forensics | Approved; design only; no forensic software or service implemented |
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
| BP-35 | Simulation Engine | Approved; typed command intake, limited text interpreter, idempotency and transactional event emission implemented; broader domain handlers, scheduler and NPC processing outstanding |
| BP-36 | Relationships and Social Context | Approved; design only; no relationship or social-context system implemented |
| BP-37 | Time and Scheduling | Approved; paused singleton clock, explicit initialization/advancement and clock history implemented; fictional calendar configuration and scheduler outstanding |
| BP-38 | Records and Databases | Approved; 42-table private schema and seven migrations implemented; command and clock-history records added; full domain coverage incomplete |
| BP-39 | Persistence and Recovery | Approved; design only; no backup or restore process implemented |
| BP-40 | Interface | Approved; ChatGPT remains the intended text interface; limited explicit text command grammar exists; live ChatGPT-to-runtime connection remains outstanding |
| BP-41 | Notifications and Reporting | Approved; design only; no notification or reporting service implemented |
| BP-42 | Security and Permissions | Approved; RLS enabled on all 42 tables; private schema remains unexposed; player authentication and fictional authority enforcement outstanding |
| BP-43 | Testing and Quality Assurance | Approved; runtime and text/dispatch SQL regression scripts passed inside rolled-back transactions; CI and broader domain tests outstanding |
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

- 40 tables covering world geography, organisations, properties/buildings, people and relationships, police commands/stations/ranks/units/positions/personnel, personnel history and qualifications, duty rosters/assignments/resources, simulation clock state, incident types, incidents, dispatch calls/events/deployments, cases, case people/assignments, evidence items/transfers and game event history.
- 78 foreign-key relationships connect the records.
- Supporting indexes are present, including indexes for foreign-key lookups.
- Row-level security is enabled on all 40 tables. The schema is not exposed to the public API; access is reserved for the server-side service role while the game access layer is built.
- No fictional game content has been seeded yet. The database foundation is structure only.

Migration files in `database/migrations/`:
- `20261119220423_kingswell_core_game_database.sql`
- `20261119220538_index_game_foreign_keys.sql`
- `20261120010000_runtime_foundation_commands_clock.sql`
- `20261120020000_harden_runtime_command_validation.sql`
- `20261120030000_text_interpreter_dispatch_intake.sql`
- `20261120040000_fix_dispatch_call_event_type.sql`
- `20261120050000_validate_optional_dispatch_call_fields.sql`

The original two migrations established the base schema. The current live schema has 42 tables, 80 foreign keys, 147 indexes and RLS enabled on all 42 tables. Seven migrations are recorded in Supabase.

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

The 42-table schema is a useful relational foundation, not a completed implementation of the 44 divisions. Coverage is partial across BP-02 to BP-18, BP-23, BP-32 to BP-38 and BP-42 to BP-43. BP-19 to BP-22, BP-24 to BP-31, BP-34, BP-39, BP-41 and BP-44 have no substantive dedicated implementation yet. The detailed division-by-division mapping and gaps are in the audit report.

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

Implemented a limited explicit text grammar through `game.interpret_text_command` and `game.execute_text_command`. Initial BP-11/BP-12 call intake creates a linked incident, dispatch call, `call_received` dispatch event and game event using the configured fictional clock. It does not dispatch a unit. Invalid or unrecognised commands are rejected; retries remain idempotent.

Supported forms include `help`, `status`, `advance time N minutes`, and `911/call/report/radio [report] at [location]`. The parser does not turn questions into actions.

Regression test: `database/tests/text_interpreter_dispatch.sql`; passed in a transaction with rollback. Live verification: 42 tables, 80 foreign keys, 147 indexes, all 42 tables with RLS, seven migration records, three runtime functions; zero command, call, incident or dispatch-event records; fictional clock still unset.
