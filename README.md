# Kingswell Police Simulation

A fictional, persistent, text-first police simulation set in the fictional sovereign country of Kingswell and centred on its capital city, Kingswell.

## Project status

The **44-division master blueprint has been drafted**. The project is now moving into software implementation.

The repository contains the game blueprint, project records, technical architecture and versioned database migrations. The connected Supabase project now has the initial private `game` schema: 40 tables, 78 foreign-key relationships and supporting indexes. All 40 tables have row-level security enabled. The schema currently contains no seeded game-world/personnel/incident data. A temporary end-to-end insert test across world, police, dispatch, case and evidence relationships passed and was rolled back cleanly. The simulation runtime and playable interface have not yet been implemented.

See the [Implementation Register](docs/governance/IMPLEMENTATION-REGISTER.md) for the current build status.

## Three-part project architecture

1. **ChatGPT — game interface:** the player issues commands, receives dispatches, reviews records and plays the simulation through conversation.
2. **Supabase — authoritative live game database:** stores persistent game state and records.
3. **GitHub — source code and project history:** stores the blueprint, documentation, application code, database migrations, configuration, tests and version history.

## Repository rules

- The only working branch is `main`.
- Do not create or switch to other branches.
- Keep the design understandable and build progressively.
- Do not introduce scope expansions without recording their purpose and impact.
- This is a fictional game; its country, institutions, laws, people, procedures and events are fictional.
- Prefer sensible implementation decisions and straightforward working methods. Avoid unnecessary approval steps and needless delays.
- Keep this README updated whenever the project's stage, architecture or implementation status materially changes.

## Project documents

- [Master Blueprint](docs/blueprint/MASTER-BLUEPRINT.md)
- [Blueprint Division Register](docs/blueprint/DIVISION-REGISTER.md)
- [Implementation Register](docs/governance/IMPLEMENTATION-REGISTER.md)
- [Project Decisions and Working Rules](docs/governance/PROJECT-DECISIONS.md)
- [Technical Architecture](docs/architecture/TECHNICAL-ARCHITECTURE.md)

## Connected services

- **GitHub:** `Joshuaogri/Kingswell-Police-Simulation`, working branch `main`.
- **Supabase:** `Kingswell-Police-Simulation`, project ref `gdbzkgejyfwfackyuorl`, region `eu-west-1`, PostgreSQL 17.
- **ChatGPT:** design partner and text-based game interface.

## Current setting

Kingswell is the political and economic capital of a fictional sovereign country. It is the country's principal commercial, financial, business, transport, logistics, industrial, trading and administrative centre. The city begins with 100,000 permanent residents and may grow or decline through realistic population change.

## Immediate implementation direction

Populate the fictional world and police foundations, then build the command/runtime layer and connect the first complete playable police workflow: personnel deployment, dispatch, incident response, reporting and saved game records.
