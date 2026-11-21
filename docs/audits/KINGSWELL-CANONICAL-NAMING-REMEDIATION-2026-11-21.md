# Kingswell Canonical Naming Standard and Remediation

**Date:** 21 November 2026  
**Project:** Kingswell Police Simulation  
**Database:** `gdbzkgejyfwfackyuorl`  
**Status:** Partial implementation; canonical place and business names live. Family-aware resident surname migration is prepared in GitHub but has not been applied because the database entered read-only mode after a disk-capacity error.

## Permanent naming principles

1. A canonical entity has one stable identity and one current display name.
2. Names must be natural, believable and appropriate to the entity.
3. Canonical names are unique within their identity domain after normalisation.
4. Punctuation, whitespace, case, Unicode lookalikes and abbreviations must not be used to evade duplicate detection.
5. Similar names are flagged for review; similarity alone does not automatically rename legitimate entities.
6. Names are never used as database identity. UUIDs, references and foreign keys remain authoritative.
7. Former names and corrections remain traceable. Retired names are not silently reassigned.
8. Aliases are searchable but do not replace canonical names.
9. Historical event, case, contract and transaction snapshots retain the name that applied when the event occurred.
10. Every future insert or canonical-name update must pass the same database controls as existing records.

## Domain rules

### People and families
- Complete personal display names are unique across Kingswell.
- Given names and middle names may naturally recur.
- Members of one family share its family surname.
- Housemates are not automatically treated as relatives.
- Marriage, adoption, divorce, name changes and family moves must be represented through family identity records, not inferred from surname alone.
- A person retains a stable person UUID and person reference through all name changes.
- Shared-household members have separate family identities unless an explicit family relationship exists.
- Future household membership changes must assign or retain the appropriate family identity automatically.

### Businesses and organisations
- Every business has a distinct trading name.
- Every legal organisation has a distinct legal name.
- Trading identity and legal identity are related but not identical.
- Different companies must not receive mechanically generated serial-number names.
- Branch/site names combine the organisation identity with the actual premises identity.
- Parent, subsidiary, franchise and branch relationships remain explicit.

### Roads and places
- Every road has a unique official gazetteer name.
- Bridges, streets, avenues, roads, boulevards, crescents, drives, lanes and service ways use natural naming conventions.
- Road segments retain the identity of their parent road.
- Junctions, landmarks, districts, neighbourhoods and regions have unique names in their own domains.
- Addresses, map labels and dossiers must use the same current official road and property names.

### Properties and buildings
- Each property has a distinct canonical name.
- Each building has a distinct canonical name.
- Where a property has no established named development, its street address is the public property identity.
- Building labels combine the real address with a use-appropriate descriptor.
- Unit numbers remain unit identifiers, not substitutes for building or property names.

## Implemented and live-verified on 21 November 2026

Migration: `database/migrations/20261121350000_kingswell_natural_entity_naming.sql`

| Domain | Records | Distinct canonical names | Result |
|---|---:|---:|---|
| Roads | 75 | 75 | Pass |
| Businesses | 1,452 | 1,452 | Pass |
| Organisations | 1,490 | 1,490 | Pass |
| Properties | 656 | 656 | Pass |
| Buildings | 656 | 656 | Pass |
| Operating sites | 1,477 | 1,477 | Pass |
| Property address records | 656 | 656 | Pass |

Examples of the new natural names:
- Roads: **Ford Street**, **Bellview Bridge**, **Carter Bridge**, **Millbrook Bridge**.
- Businesses: **Adams Capital**, **Adams Freight**, **Adams Books**, **Adams Kitchen**.
- Properties: address-based identities such as **501 Ford Street**.
- Buildings: address plus use, such as **501 Ford Street Terminal**.

The 38 non-business public, civic and institutional organisations retain their existing institutionally appropriate names.

The migration refreshed current property address projections, property map labels, site display names and current site dossier addresses/building labels. Historical case/event/contract snapshots were intentionally not rewritten. The live record Edge Function was advanced to version 11 and now exposes canonical property names in property list/detail responses plus a read-only `map_names` feed for all roads, properties and buildings. The 2D map and 3D atlas now overlay these live canonical names on the published geometry snapshot; the live name overlay is being checked by the current GitHub Pages browser workflow.

The following database protections remain enabled:
- Normalised unique indexes for people, businesses, organisations, properties, buildings and roads.
- Cross-domain exact-name separation triggers for the canonical identity domains.
- Append-only correction history.
- Required/nonblank constraints on property names and official road names.

A set-wise cross-domain check across people, businesses, organisations, properties, buildings and roads returned **zero exact normalised collisions**. All five cross-domain triggers were confirmed enabled after the migration.

## Resident family-name audit

The live population currently contains 100,000 people, 24,512 active households and 309,760 person-relationship records. Every family household has one surname among its active members; shared households contain housemate relationships rather than family relationships.

The existing seed used only 25 family surnames across the entire 100,000-person population. That is not consistent with the requested rule that unrelated families must not share a surname.

A family-aware migration is prepared at:

`database/migrations/20261121351000_kingswell_family_identity_naming.sql`

It is designed to:
- create one family identity per family household;
- give each shared-household resident an individual family identity unless explicit kinship is recorded;
- allocate distinct double-barrelled surnames from a large reserve of real surname components;
- add `family_id` to persons and household membership history;
- preserve person UUIDs, person references, given names, middle names, dates of birth, relationships, employment, addresses and all other linked records;
- enforce surname consistency through database triggers;
- allocate new family surnames automatically for future household memberships;
- reserve former family surnames permanently;
- verify every person has one family identity, every family has a unique surname, and every complete personal name remains unique.

**Not yet applied:** the attempt to apply the family migration encountered a database storage exhaustion error (`No space left on device`). The database then reported `default_transaction_read_only=on` and `transaction_read_only=on`. The Supabase project itself reports `ACTIVE_HEALTHY`, but the database is currently read-only. The migration must not be represented as live until the database is writable and all final checks pass.

## Known remaining work

1. Resolve the database storage/read-only condition without deleting canonical game records or audit history.
2. Apply and verify the family identity migration.
3. Review person given/middle-name diversity and correct any artificial patterns without breaking family identity.
4. Audit junction labels, building-unit names, institutional facilities, courts, police facilities, departments, positions and other named records for placeholders and confusing similarities.
5. Complete the GitHub Pages browser test of the live map-name overlay; the map geometry remains a published snapshot while road, property and building names are overlaid live from Supabase.
6. Deploy GitHub Pages and verify the directories, dossiers, addresses, maps and 3D atlas against live canonical records.
7. Add regression tests for duplicate, near-duplicate, Unicode, punctuation, concurrency, alias, historical-name and family-membership cases.

## Important distinction

Names that are expected to recur as vocabulary are not entity identity duplicates. For example, ranks, job titles, unit types, street suffixes, floor labels and generic service descriptions may recur in their proper scope. The uniqueness requirement applies to canonical identities, not every descriptive word in the simulation.
