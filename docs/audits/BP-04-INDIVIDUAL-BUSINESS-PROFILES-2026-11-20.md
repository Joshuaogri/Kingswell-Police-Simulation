# BP-04 Implementation Progress — Individual Business Operational Profiles

**Date:** 2026-11-20  
**Status:** Implemented first enrichment tranche; BP-04 remains in progress.

## Scope

This change enriches the existing 1,452 canonical `game.business_profiles` rows in place. It does not create duplicate business identities, employee records, site records, suppliers, security companies, transactions or event histories.

## Live database changes

The existing `trade_profile`, `security_arrangements` and `business_hours` JSONB fields now carry additional operational detail:

- Operating model selected from sector-appropriate fictional operating patterns.
- Customer access model, including public, appointment, reception, controlled trade and staff/visitor arrangements.
- Stock and asset handling model, distinguishing warehousing, bulk trade, production, retail stock and service equipment.
- Delivery and visitor pattern, including scheduled goods movement, dock/yard activity, courier activity and booked business visits.
- Premises access-control pattern, CCTV coverage profile, intrusion-detection profile and out-of-hours control.
- Opening-schedule variation and weekday pattern.
- Explicit provenance labels distinguishing seeded fictional profile detail from live runtime attendance, recorded incidents or named external providers.

The variations are deterministically assigned from each existing organisation reference and sector. This gives each business a stable, reproducible operating profile without changing its identity or personnel links.

## Verification

Post-migration verification returned:

| Measure | Result |
|---|---:|
| Business profiles enriched | 1,452 / 1,452 |
| Distinct operational trade profiles | 1,407 |
| Distinct security profile combinations | 195 |
| Distinct opening-hours profiles | 35 |
| Profiles with operational provenance | 1,452 / 1,452 |
| Security-provider identities explicitly left unknown | 1,452 / 1,452 |

## Important limits

These are fictional baseline operating characteristics, not evidence that a particular CCTV device, named security contractor, real attendance event, delivery, customer visit, stock movement or incident occurred. Provider identities remain unknown. Opening schedules are profile data and do not advance the simulation clock or constitute actual attendance.

No owners or directors were assigned from the existing workforce because the current canonical personnel records contain generic operational job titles and no verified owner/director candidates. The control-interest register remains the authoritative place for such relationships once canonical person links can be supported.

## Next implementation tranche

1. Build a proper per-business operational dossier and history view, including individual premises use, stock/asset categories, delivery handling, public access, cash handling, staff areas and site-specific risks.
2. Reconcile ownership and directors only against supported canonical person or organisation records; never infer ownership from generic employment.
3. Extend property and building histories with planning, title/encumbrance, system inventory, inspections, defects and maintenance records. Do not fabricate past events or dates.
4. Add validated write actions and game commands for changes and history entries, then expose them through the browser interface.
5. Add regression tests for uniqueness, provenance, stable repeatability, history preservation and cross-entity references.

## Applied migrations

- `bp04_individual_business_operating_security_and_access_profiles`
- `bp04_individualise_business_security_profiles`

The source migration files and regression coverage must remain version-controlled with the repository. BP-04 is not complete.
