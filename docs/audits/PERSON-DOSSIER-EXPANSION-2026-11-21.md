# Kingswell Person Dossier Expansion — 21 November 2026

**Project:** Kingswell Police Simulation (fictional game)  
**Blueprint:** BP-01–BP-44 remains approved and unchanged.  
**Interface refinement:** BP-40 — individual entity record workspaces.

## Delivered

The `kingswell-records` Supabase Edge Function was upgraded to version 7. The person-detail response now includes:

- Canonical person identity and simulation profile fields.
- Current addresses and linked unit/property references.
- Household membership, household role/status, primary property/unit and current household member list.
- Weekly routine schedules, activity categories, time windows, routine status and linked origin/destination properties.
- Employment records linked to organisation and business profiles.
- Recorded life events with related person, organisation and property references where present.
- Population membership categories and city links.
- Existing person-to-person relationships.

The individual record page now renders dedicated sections for personal/simulation profile, addresses, households, household members, employment, weekly routines, life events, population memberships and relationships. Linked people, businesses and properties have navigable record links.

## Canonical data check

The authoritative Supabase database currently contains:

| Record set | Count |
|---|---:|
| Persons | 100,000 |
| Households | 24,512 |
| Household memberships | 100,000 |
| Person routines | 917,060 |
| Person life events | 143,412 |
| Organisation personnel records | 43,412 |

These are existing records. This delivery created no duplicate people, households, routines or life events.

## Verification

- Supabase Edge Function `kingswell-records`: active version **7**.
- GitHub Actions workflow **#58** completed successfully:
  - Existing 656-building map smoke test passed.
  - Published geographic data and property dossier checks passed.
  - Chromium opened the live person directory and individual person record.
  - Chromium verified all eight new person-dossier sections.
  - Household and routine canonical references were present in the selected dossier.
  - The existing map, property record and atlas-layer checks also passed.
- Workflow: https://github.com/Joshuaogri/Kingswell-Police-Simulation/actions/runs/44932475865

## Remaining work

- Improve display labels and human-readable weekday formatting for routine entries.
- Add richer relationship navigation and linked organisation/business detail.
- Extend the same full-dossier pattern to business, organisation, building and unit records.
- Continue dedicated police personnel, dispatch, incident, case, investigation, evidence, forensic, custody and justice workspaces.
- Continue atlas cartography and map-layer refinements independently of the record directories.

Opening, searching or browsing these read-only records does not advance the fictional simulation clock.
