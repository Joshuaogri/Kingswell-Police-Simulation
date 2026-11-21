# Kingswell Police Simulation

A fictional, persistent, text-first police simulation set in the fictional sovereign country of **Asterfell**, centred on its capital city, **Kingswell**.

> **Current milestone — 21 November 2026:** BP-04 (Buildings, Properties, Businesses and Organisations) is **complete, deployed and verified**. Its 28 live migrations, detailed data coverage, 29 focused tests, 97-test full regression run and rollback-only active-officer integration test are documented below.

## Project status

The approved master blueprint contains **44 divisions (BP-01 to BP-44)**. All 44 divisions are approved as the design baseline. Software implementation is tracked separately in the [Implementation Register](docs/governance/IMPLEMENTATION-REGISTER.md).

The project is built around three connected parts:

1. **ChatGPT — game interface:** the player issues commands, receives dispatches, reviews records and plays the simulation through conversation.
2. **Supabase — authoritative live game database:** stores persistent fictional game state and records.
3. **GitHub — source code and project history:** stores the blueprint, documentation, code, database migrations, configuration, tests and version history.

## Latest verified delivery: BP-04

**COMPLETE · LIVE DEPLOYED · TESTED**

BP-04 delivers the detailed property, building, unit, business, organisation, site, workforce, asset, infrastructure and premises-context foundations. It is integrated with the wider police incident, dispatch, scene and case workflows.

### Live database snapshot

Counts below were verified against the live Supabase project after BP-04 deployment on 21 November 2026.

| Record type | Verified count |
|---|---:|
| Properties | **656** |
| Buildings | **656** |
| Building units / premises | **26,888** |
| Business profiles | **1,452** |
| Organisations (businesses and institutions) | **1,490** |
| Organisation sites | **1,477** |
| Employment records / dossiers | **43,412** |
| BP-04 migrations applied | **28 / 28** |

These figures are a dated database snapshot, not public live-updating counters.

### What BP-04 now contains

- Individual property, building and unit dossiers.
- Property valuation snapshots and map-version alignment.
- Property interests, title-history and property-development history structures.
- Physical asset inventories, maintenance history and unit infrastructure records.
- Property/building/unit event capture for inspections, defects, maintenance, repairs, alterations, safety reviews, utilities and damage.
- Individual business operational, security and access profiles.
- Organisation and institutional dossiers, lifecycle histories and site records.
- Workforce and job-role dossiers covering all 43,412 existing employment records.
- Organisation department, position, reporting-line and employment-assignment structures.
- Formal tenant-site agreement records, agreement review dossiers and append-only agreement lifecycle events.
- Property-interest recording, ending and history workflows.
- Premises context linked to case leads, incidents, dispatch, scene response and case review.
- Runtime command routing for organisation, site, structure, workforce and property-event workflows.

### Verification results

| Verification | Result |
|---|---:|
| BP-04 focused regression | **29 passed · 0 failed** |
| Full gameplay regression | **97 passed · 0 failed** |
| GitHub Actions run | **161 — success** |
| BP-04 live migrations | **28 applied · 28 exact version/name matches** |
| Active-officer property-event integration | **PASS** |
| Temporary records remaining after rollback | **0** |

The live active-officer test created a temporary officer marked `active`, executed a property-event command through the actual text-command runtime, checked event and audit attribution, and rolled the entire fixture back. A separate query confirmed that the temporary person, officer, property event and command audit record all returned to zero. No permanent police personnel were created; the live personnel table remains empty pending the police personnel division.

### Data integrity is intentional

Unknown fictional facts remain unknown rather than being invented. For example, 152 tenant agreements have no verified landlord counterparty; registered ownership is not assumed to prove landlord status. Contract dates, rent, deposits, title transfers, inspections and repairs are not fabricated where no supporting game record exists. Asset and title histories begin empty and are populated through their workflows.

**Read the full [BP-04 Completion and Live Verification Record](docs/audits/BP-04-COMPLETION-AND-LIVE-VERIFICATION-2026-11-21.md)** for all 28 migration filenames, live counts, delivered workflows, data-integrity safeguards, dossier checks, regression results and rollback evidence.

## Project rules

- The only working branch is `main`.
- The BP-01 to BP-44 master blueprint is approved; do not rewrite or reapprove it.
- Supabase is the authoritative live game database.
- GitHub stores source code, migrations, documentation, tests and version history.
- This is an entirely fictional game. Its country, institutions, laws, people, procedures, businesses and events are fictional.
- Preserve canonical identities and provenance. Do not invent missing facts to make records look complete.
- Update implementation status only when supported by actual code, database and test evidence.
- Do not deploy future live database migrations or seed data without the user's explicit authorization.

## Project documents

- [Master Blueprint](docs/blueprint/MASTER-BLUEPRINT.md)
- [Blueprint Division Register](docs/blueprint/DIVISION-REGISTER.md)
- [Implementation Register](docs/governance/IMPLEMENTATION-REGISTER.md)
- [Project Decisions and Working Rules](docs/governance/PROJECT-DECISIONS.md)
- [Technical Architecture](docs/architecture/TECHNICAL-ARCHITECTURE.md)
- [BP-04 Completion and Live Verification Record](docs/audits/BP-04-COMPLETION-AND-LIVE-VERIFICATION-2026-11-21.md)
- [Kingswell Master Geographic Map](docs/geography/KINGSWELL-MASTER-MAP.md)
- [Kingswell City Map (SVG)](docs/geography/kingswell-city-map.svg)

## Connected services

- **GitHub:** [Joshuaogri/Kingswell-Police-Simulation](https://github.com/Joshuaogri/Kingswell-Police-Simulation), branch `main`.
- **Supabase:** Kingswell-Police-Simulation, project ref `gdbzkgejyfwfackyuorl`, region EU West.
- **ChatGPT:** design partner and text-based game interface.

## GitHub Pages — Simulation Control Room

The [Kingswell Game Test Centre](https://joshuaogri.github.io/Kingswell-Police-Simulation/) is the browser home for published game interfaces. It currently publishes the geography workspace and a status overview of other systems. The BP-04 database foundation is deployed, but a dedicated property/business browser has not yet been published.

GitHub Pages currently displays a static, dated snapshot. Supabase remains authoritative; the public site is not yet connected to a live read-only data endpoint. It must not present static figures as live-changing data.

## Current setting

Asterfell is the approved fictional sovereign country. Kingswell is its capital and principal commercial, financial, business, transport, logistics, industrial, trading and administrative centre. The city's population foundation and world records are maintained in the live game database and documented in the blueprint and implementation registers.

## Continue development

The next blueprint division can proceed without reopening BP-04. See the [Implementation Register](docs/governance/IMPLEMENTATION-REGISTER.md) for the wider project state and the [Division Register](docs/blueprint/DIVISION-REGISTER.md) for all 44 approved divisions.
