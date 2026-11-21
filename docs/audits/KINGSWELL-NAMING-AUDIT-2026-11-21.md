# Kingswell Naming Audit — 21 November 2026

## Scope and baseline

This audit covers canonical person, family, business, organisation, road, property and building identities, plus live address/site/map copies. All counts below were read from the live Supabase database for project `gdbzkgejyfwfackyuorl`.

| Area | Live records | Baseline finding |
|---|---:|---|
| Persons | 100,000 | 100,000 complete display names are unique, but surnames are drawn from only 25 repeated values; middle-name combinations are heavily repetitive |
| Households | 24,512 | Household membership alone cannot establish family identity |
| Person relationships | 309,760 | Existing family relationship graph is suitable for deriving explicit family-name groups; housemate edges must be excluded |
| Businesses | 1,452 | Trading names are unique but follow mechanical generated patterns |
| Organisations | 1,490 | Legal names are unique but business-linked names follow repetitive generated patterns |
| Properties | 656 | Names are unique but are currently address-like labels rather than proper property names |
| Buildings | 656 | All 656 names match generic numbered-street building/terminal patterns |
| Roads | 75 | Exact names are mostly unique, but 14 road-root groups repeat with different suffixes (e.g. Market Lane/Market Street/Market Yard); service-road naming is repetitive |
| Organisation sites | 1,477 | 1,452 business-linked site names do not match their current business trading names |
| Property profiles | 656 | Map labels require synchronization with proper property names |

## Road-root collision groups found

- Market Lane / Market Street / Market Yard
- Assembly Avenue / Assembly Lane
- Briar Lane / Briar Close
- Civic Boulevard / Civic Lane
- Exchange Street / Exchange Mews
- Foundry Boulevard / Foundry Yard
- Freightway / Freight Yard
- Harbour Parkway / Harbour Mews
- Merchants Lane / Merchants Mews
- Orchard Way / Orchard Mews
- Railway Road / Railway Mews
- Riverside Drive / Riverside Mews
- Station Approach / Station Mews
- Terminal Way / Terminal Road

## Changes committed and applied

1. Permanent canonical naming standard committed at `docs/governance/KINGSWELL-CANONICAL-NAMING-STANDARD.md`.
2. Multinational surname reference vocabulary copied into `data/reference/name-sources/Surnames.txt`, with source attribution and MIT licence.
3. Database normalization now supports case, punctuation, spacing and accent normalization.
4. Database foundation added for explicit family-name identities, protected family assignment, surname catalogue, canonical-name history and similarity-review flags.
5. 43,975 distinct normalized surname references loaded into `game.surname_name_catalog`.
6. Family identity infrastructure added to `game.persons`; the `family_id` field is intentionally still unpopulated pending the bulk remediation step.

## Bulk remediation not yet applied

The next migration will:
- Derive family-name groups from explicit person relationships, excluding housemates and household-only association.
- Assign a distinct surname to each family-name group while preserving every person ID, person_ref, relationship and life record.
- Replace 1,452 business trading names and linked legal organisation names with natural sector-appropriate names.
- Give all 656 properties and 656 buildings proper distinct names, leaving postal addresses intact.
- Replace road names that differ only by suffix and other generic road labels.
- Synchronize site names, property map labels, road-based addresses and live site dossiers.
- Add normalized unique indexes, suffix-insensitive road uniqueness, historical-name protection and similarity review.

The bulk remediation has not been represented as complete. It requires the explicit data-change step to run successfully and pass its assertions before the audit can be marked complete.
