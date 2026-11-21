# BP-03 / BP-04 Canonical Name Uniqueness Remediation

**Date:** 21 November 2026  
**Project:** Kingswell Police Simulation  
**Database:** Kingswell Supabase project `gdbzkgejyfwfackyuorl`  
**Status:** Implemented and live-verified

## Scope

This remediation corrects repeated fictional identities and overlapping names across the BP-03 population and BP-04 business, organisation and property records. BP-02 road records were included to ensure every road has an official unique name.

Canonical IDs, foreign keys, household membership, relationships, employment links, ownership interests, premises links, addresses' underlying road/property relationships and other record relationships were preserved.

## Findings before remediation

- BP-03 contained 100,000 person records but only 1,000 distinct full-name combinations. All 100,000 people had no middle name; the same full names were reused up to 126 times.
- BP-04 had 1,452 businesses and 1,490 organisations. Every business's trading name was identical to its linked organisation's legal name.
- Business trading names were generated from a small repeated set of base brands with serial suffixes.
- BP-04 contained 656 properties. 176 used one of two repeated generic address placeholders: `Residential tower parcel` or `Commercial development parcel`.
- All 75 road `name` values were already unique, but 51 records had no populated `official_name`.
- All 656 building names were already unique.

## Implemented corrections

### BP-03 people

- Assigned deterministic, distinct two-part middle names to all 100,000 people.
- Each person's complete display name is now unique.
- Preserved `person_ref`, UUID, given name, family name, date of birth, household, relationships, employment and all other linked records.
- Added a unique full-display-name index.
- Added an insert/update trigger that assigns an unused middle-name combination to future generated people when no middle name is supplied.
- Added a cross-domain guard to prevent an exact normalized person name from matching a business, organisation, property, building or road name.

### BP-04 businesses and organisations

- Rebuilt all 1,452 trading names using a deterministic, substantially larger fictional name space and sector-specific descriptors.
- Assigned distinct legal organisation names using the relevant legal-form suffix.
- Updated linked site display names to follow their business trading identity.
- Preserved business numbers, organisation references, UUIDs, staffing, ownership, site and contract relationships.
- Added normalized unique indexes and cross-domain name-separation triggers.

### BP-04 properties and buildings

- Added a required `property_name` to all 656 properties, generated from neighbourhood, property use and a local sequence.
- Replaced all 176 repeated generic address placeholders with their existing unique street number, road, neighbourhood, district, city, country and postal-code address.
- Exposed `property_name` in the canonical property dossier response.
- Added unique indexes and required/nonblank constraints for property names and address lines.
- Retained all 656 building names unchanged because they were already unique; added a uniqueness index and cross-domain guard.

### BP-02 roads

- Populated `official_name` for all 75 roads from each road's existing unique canonical `name`.
- Added city-level unique indexes for official road names and road names.
- Added required and nonblank constraints for official road names.
- Preserved road IDs, codes, segments, junctions, routing, property frontage and patrol references.

## Live verification

| Domain | Records | Unique names / values | Result |
|---|---:|---:|---|
| People | 100,000 | 100,000 full names | Pass |
| Businesses | 1,452 | 1,452 trading names | Pass |
| Organisations | 1,490 | 1,490 names | Pass |
| Properties | 656 | 656 property names | Pass |
| Property addresses | 656 | 656 address lines | Pass |
| Roads | 75 | 75 official names | Pass |
| Buildings | 656 | 656 building names | Pass |

Additional checks:

- Missing person middle names: **0**.
- Business/linked-organisation exact name matches: **0**.
- Remaining generic property address placeholders: **0**.
- Missing official road names: **0**.
- Exact normalized cross-domain name collisions across people, businesses, organisations, properties, roads and buildings: **0** across all tested domain pairs.
- A live property dossier query returned the newly assigned `property_name`.

## Correction provenance

An append-only `game.canonical_name_corrections` ledger records the prior and corrected display values, entity reference, reason and migration reference.

| Entity type | Correction records |
|---|---:|
| People | 100,000 |
| Businesses | 1,452 |
| Organisations | 1,452 |
| Business sites | 1,452 |
| Properties | 656 |
| Property addresses | 176 |
| Roads | 51 |
| **Total** | **105,239** |

The correction ledger denies update and delete operations.

## Migrations

1. `20261121340000_bp03_bp04_canonical_name_uniqueness.sql`
2. `20261121341000_bp03_bp04_required_unique_names.sql`

Both migrations were applied successfully to the Kingswell Supabase project. The uniqueness indexes, cross-domain guards and required-name constraints are now part of the live database schema.

## Important distinction

Name uniqueness is not the same as identity uniqueness. Every person already had a distinct canonical UUID and `person_ref`; this remediation also makes every full display name distinct. No person was merged, removed, or assigned another person's identity.
