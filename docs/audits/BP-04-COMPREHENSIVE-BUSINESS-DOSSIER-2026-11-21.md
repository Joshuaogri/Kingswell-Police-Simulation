# BP-04 Progress — Comprehensive Business Dossier

**Date:** 2026-11-21  
**Status:** Implemented in GitHub; isolated regression validation pending; not deployed to live Supabase.

## Purpose

The existing `game.get_business_record(text)` query returned the organisation and business profile, a basic site/property view, control interests and linked tenant agreements. BP-04 requires a single operational business dossier that brings the already-existing canonical records together without inventing missing facts.

## Implemented read-model extension

Migration: `database/migrations/20261121090000_bp04_comprehensive_business_dossiers.sql`

The existing business record command and function name are preserved. The response now composes:

- Canonical organisation and business profiles.
- Existing organisation workforce dossier, role breakdown and individual employment dossiers.
- Existing organisation department/position/assignment structure.
- Recorded ownership/control interests and property interests.
- Current and historical organisation site dossiers, with property, building, unit, unit profile and unit-infrastructure context.
- Site agreements with their recorded lifecycle event timelines.
- Recorded physical assets and append-only maintenance events at the business's linked premises.
- Recorded property/building/unit asset events for linked premises.
- An explicit record-coverage section describing which facts are recorded and which are not inferred.

The query composes existing canonical identities and helper functions. It does not create employees, directors, owners, assets, inspections, maintenance, title transfers, agreements or attendance events.

## Data-quality boundaries

- An empty physical-asset register does not mean a site has no physical equipment.
- Empty maintenance, inspection and asset-event histories do not prove that no such events occurred.
- Seeded business operational profiles are not live attendance, deliveries, CCTV events or stock movements.
- Workforce job titles do not establish ownership, directorship or supervision.
- Unknown contract dates, counterparties and terms remain unknown.
- Department and site assignments appear only when represented by canonical records.

## Regression

New test: `database/tests/bp04_comprehensive_business_dossier_regression.sql`

It checks all dossier sections, canonical site/dossier counts, workforce/structure integration, provenance boundaries, empty-history behaviour and service-role-only function execution. The test is transactionally rolled back.

GitHub Actions run: [Gameplay regression run 44887734961](https://github.com/Joshuaogri/Kingswell-Police-Simulation/actions/runs/44887734961).

## Live database status

This migration has **not** been applied to the live Supabase database. Live deployment remains a separate action. The existing live business dossier function remains in place until the migration is explicitly deployed.

## BP-04 remaining work

This tranche improves the unified business read model; it does not close BP-04. Remaining work includes validated record-entry commands for assets and their histories, business-specific operational history workflows, supported ownership/counterparty resolution, planning/title/maintenance event capture, and player-facing interfaces with full BP-04 integration regression.
