# Kingswell Technical Architecture

**Status:** Initial technical architecture outline; implementation plan to be expanded from the approved blueprint  
**Version:** 0.1  
**Foundation:** Implemented and verified (42-table private schema and six migrations)  
**Simulation runtime:** Initial database-backed command and clock foundation implemented; domain runtime in progress

## 1. Purpose

Explain how the game will be built and how its information will be preserved. This is a separate document from the Master Blueprint: the blueprint describes the game; this document describes the software that will support it.

## 2. Three-part arrangement

### ChatGPT — game interface and design partner
The player interacts through conversation: issuing commands, receiving dispatches, reviewing records, making decisions and experiencing the simulation. ChatGPT also helps develop and maintain the design.

### Supabase — persistent game records
Supabase hosts the PostgreSQL database that will store the authoritative live game state: people, places, police personnel, incidents, cases, evidence, schedules, organisations and other approved records.

### GitHub — project source and history
GitHub stores the blueprint, implementation register, technical design, application source code, configuration, database migration files, tests and version history.

## 3. Initial service details

- GitHub repository: `Joshuaogri/Kingswell-Police-Simulation`
- Sole working branch: `main`
- Supabase project: `Kingswell-Police-Simulation`
- Supabase project ref: `gdbzkgejyfwfackyuorl`
- Supabase region: `eu-west-1`
- Database engine: PostgreSQL 17

Do not put passwords, secret keys, service-role keys or other credentials in GitHub documents or public client code.

## 4. Data design approach

The live database uses a dedicated private PostgreSQL schema named `game`. Records use stable UUID identities, readable unique references where needed, explicit foreign-key relationships, timestamps for historical changes, check constraints and JSONB for flexible supporting detail.

The private schema covers geography, properties, organisations, people, police structure and personnel, duty deployment, simulation time, incidents, dispatch, cases, evidence and game-event history. It now also includes command intake and clock-history records. All 42 tables have row-level security enabled. The schema is not exposed through the public Data API. No service-role key may be placed in GitHub or client-side code.

## 5. Build approach

1. Complete the master blueprint in manageable divisions.
2. Convert approved requirements into a clear data model.
3. Create the database structure and preserve each released change as a migration in GitHub.
4. Build the smallest working foundation.
5. Test each part against the blueprint.
6. Add game systems progressively, keeping the register accurate.
7. Verify backups and recovery before relying on the database for long-term game state.

## 6. Repository layout

- `README.md` — project overview and working rules.
- `docs/blueprint/` — master game design.
- `docs/governance/` — implementation status and project controls.
- `docs/architecture/` — software and data architecture.
- `database/migrations/` — versioned database change scripts.
- `database/tests/` — repeatable SQL regression scripts.
- `docs/architecture/RUNTIME-FOUNDATION.md` — command, clock and dispatch runtime design.
- `src/` — future application and simulation code.
- `tests/` — future automated and manual verification.
- `config/` — future non-secret configuration examples.

Folders for future work do not mean that code or database structures already exist.

## 7. Branch rule

The project uses **main only**. All work and commits go directly to `main`. Do not create, switch to, or propose feature branches, development branches or other branches.

## 8. Current implementation state

The Supabase project is connected and healthy. The private `game` schema has 42 tables, 80 foreign keys and 147 indexes, with six migrations recorded in Supabase and committed under `database/migrations/` on GitHub `main`. RLS is enabled on all 42 tables and the schema is not exposed through the public Data API. Three invoker-rights runtime functions are installed: typed command submission, text interpretation and text-command execution. The singleton clock row is paused and intentionally has no fictional start time yet. The command ledger, call ledger, incidents and dispatch-event history are empty; regression tests rolled back their temporary records. The SQL regression test passed in a transaction that rolled back its test records, including rejection of fractional and out-of-range time requests. No Edge Function is deployed: authentication and player/session mapping must be implemented before exposing a privileged endpoint. The limited text grammar supports help, status, explicit time advancement and initial emergency-call intake. Full natural-language understanding, fictional police identity/authority, unit dispatch/deployment, wider domain handlers, world seed data, event scheduling, NPC processing, backup/recovery and CI remain outstanding. See `docs/architecture/RUNTIME-FOUNDATION.md`.
