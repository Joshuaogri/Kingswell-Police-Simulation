# Kingswell Police Simulation

A fictional, persistent, text-first police simulation set in the fictional sovereign country of **Asterfell**, centred on its capital city, Kingswell.

## Project status

The **44-division master blueprint (BP-01 to BP-44) was approved on 2026-11-20**. The project is in Stage 2: simulation runtime and world foundation.

The repository contains the approved blueprint, project records, technical architecture, versioned database migrations, regression tests and the authored Kingswell geographic map. The connected Supabase project contains the private `game` schema, including the initial command/runtime, police operations, scene/evidence/forensics and geographic foundations. See the [Implementation Register](docs/governance/IMPLEMENTATION-REGISTER.md) for verified current status.

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
- [Kingswell Master Geographic Map](docs/geography/KINGSWELL-MASTER-MAP.md)
- [Kingswell City Map (SVG)](docs/geography/kingswell-city-map.svg)

## Connected services

- **GitHub:** `Joshuaogri/Kingswell-Police-Simulation`, working branch `main`.
- **Supabase:** `Kingswell-Police-Simulation`, project ref `gdbzkgejyfwfackyuorl`, region `eu-west-1`, PostgreSQL 17.
- **ChatGPT:** design partner and text-based game interface.

## Current setting

Asterfell is the approved fictional sovereign country. Kingswell is its capital and principal commercial, financial, business, transport, logistics, industrial, trading and administrative centre. The city begins with 100,000 permanent residents and may grow or decline through realistic population change.

## Geographic foundation

Kingswell's approved BP-02 geographic foundation uses a fictional 20 km × 16 km local coordinate grid. The current connected road network has 51 named roads, 118 junctions and 151 routable segments, including three explicit East River bridge crossings. All 118 junctions are connected, and all 24 neighbourhoods have dedicated local street connections. See the geographic map specification and regression test for exact modelling limits.

## Immediate implementation direction

Continue the world foundation with properties, buildings, address ranges and landmarks. Then connect police facilities and patrol sectors to the road graph and implement network-based dispatch routing and response-time calculations.
