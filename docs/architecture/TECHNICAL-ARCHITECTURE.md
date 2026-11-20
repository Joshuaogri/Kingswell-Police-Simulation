# Kingswell Technical Architecture

**Status:** Initial technical architecture outline; implementation plan to be expanded from the approved blueprint  
**Version:** 0.1  
**Foundation:** Expanded private game schema; latest live integrity snapshot is 207 tables, 691 foreign keys and 999 indexes; migration-history reconciliation is in progress
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

The private schema covers geography, properties, organisations, people, police structure and personnel, duty deployment, simulation time, incidents, dispatch, cases, evidence and game-event history. It now also includes command intake and clock-history records. RLS is enabled on 202 of 207 game tables; five tables have RLS disabled and no RLS policies exist. The `game` schema denies USAGE to `anon` and `authenticated`, and there are no public-schema tables. Two SECURITY DEFINER functions still grant EXECUTE to client roles and require review before any schema exposure. No service-role key may be placed in GitHub or client-side code.

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

The Supabase project is connected and healthy. The private `game` schema has 207 tables, 691 foreign keys and 999 indexes. Supabase records 225 applied migrations while GitHub contains 212 SQL migration files; 72 same-name migrations have different version timestamps, 17 applied migration names have no same-name repository file, and three repository migration names have no same-name applied record. A confirmed version collision exists in the patrol migration sequence. Migration history is not yet reconciled, so database pushes and migration repairs remain disabled. The latest live data checks confirm 100,000 persons, 24,512 households, 100,000 primary residential memberships and addresses, 1,452 business profiles and 43,412 current employment links. There are six completed command-verification records; no live incidents, cases, evidence items, dispatch calls or game events exist. The fictional clock is paused and uninitialised. The runtime has expanded delegated command handlers for dispatch, patrol, case/investigation, property/business, court/trial and correctional slices; nine targeted rollback/read-only regression checks pass. The current runtime still lacks the complete player authentication/session boundary, full domain authority/qualification checks, complete incident progression and closure, scheduler/NPC processing, backup/restore verification, automated CI and full blueprint coverage. No live Edge Function or ChatGPT-to-runtime connection has been verified. See `docs/architecture/RUNTIME-FOUNDATION.md` and `docs/audits/2026-11-20-github-supabase-integrity-audit.md`.
