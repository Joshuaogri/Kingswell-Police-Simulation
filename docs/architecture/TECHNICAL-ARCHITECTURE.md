# Kingswell Technical Architecture

**Status:** Initial working outline  
**Version:** 0.1  
**Implementation:** Not started

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

The database should be designed from the approved game requirements, not invented ahead of them. Records will need stable unique identifiers, clear relationships, timestamps where history matters, and rules that prevent duplicate or contradictory information.

Sensitive or administrative data must not be exposed publicly. Database access controls will be designed before any game tables are made available through public-facing interfaces.

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
- `database/migrations/` — future database change scripts.
- `src/` — future application and simulation code.
- `tests/` — future automated and manual verification.
- `config/` — future non-secret configuration examples.

Folders for future work do not mean that code or database structures already exist.

## 7. Branch rule

The project uses **main only**. All work and commits go directly to `main`. Do not create, switch to, or propose feature branches, development branches or other branches.

## 8. Current limitations

The Supabase project is connected and healthy, but it currently has no Kingswell game schema, tables, migrations, authentication setup or game data. The GitHub repository has its initial project documentation. No playable application has been built yet.
