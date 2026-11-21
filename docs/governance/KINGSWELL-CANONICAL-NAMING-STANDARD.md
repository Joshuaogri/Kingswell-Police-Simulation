# Kingswell Canonical Naming Standard

**Status:** Permanent simulation rule  
**Scope:** All canonical people, families, businesses, organisations, roads, properties and buildings in Kingswell, plus their public-facing records and interfaces.

## 1. Core rules

1. Names must sound like believable names used by people, businesses and places in a real city.
2. Every canonical identity must have a unique name within its identity category.
3. A complete personal name must be unique across all living and deceased persons.
4. A family surname may be shared only by people explicitly assigned to the same recorded family-name group. A shared household, workplace, neighbourhood, nationality or surname is not proof of family.
5. Every business trading name and every organisation legal name must be unique.
6. Every road's official name must be unique, including after removing its road-type suffix. “Ford Street” and “Ford Road” are not sufficiently distinct.
7. Every property name and every building name must be unique in its own category.
8. Exact duplicate canonical names across different public-facing entity categories are rejected unless an explicit parent/child alias relationship explains the shared label.
9. IDs, refs, relationships, case links, ownership, employment, addresses, map geometry and historical events must never be replaced or lost when a name changes.
10. Old names remain in history and cannot silently be reassigned to an unrelated entity.

## 2. Personal names and family identity

- Given names and middle names may repeat naturally.
- Complete names may not repeat after Unicode, case, spacing and punctuation normalization.
- Family surnames may repeat only within one explicit family-name group.
- Family membership is not inferred from surname equality or household membership alone.
- Family links are based on recorded parent/child, sibling, partner and relative relationships. Housemates are not automatically family.
- A person can have relationships with people in another family-name group; marriage, adoption and name changes must be represented explicitly.
- A person changing surname must be assigned to an existing family-name group or a newly created group. Direct surname edits are rejected.
- Preferred names, aliases, former names and legal names are separate fields and must not overwrite one another.
- New residents, births, migration arrivals and NPC generation use the same rules.
- Deceased persons retain their canonical identity and name history.
- Name generation must preserve realistic cultural and linguistic variety and must not infer a person's culture from their surname.

## 3. Businesses and organisations

- Each business has a unique trading name and a unique linked legal organisation name.
- Trading names should sound like actual enterprises: examples include “Bennett Logistics”, “Ford and Sons Motors”, “Carter Building Supplies” and “Westbrook Haulage”.
- Names must be varied by sector and should not be generated from repetitive district labels, serial numbers or artificial first-middle-surname formulas.
- Legal suffixes such as Limited, Public Limited Company and Partnership are legal-form details, not a substitute for a distinct trading identity.
- A parent company, subsidiary, franchise, branch and brand are different concepts and must retain their correct relationships.
- Separate branches of one legal business may share the parent trading identity; separate legal businesses may not.
- Departments and internal teams may reuse generic role labels only within their proper parent organisation.
- Mergers, renaming, closure and succession preserve prior names and entity references.

## 4. Roads and transport places

- Each continuous road has one official canonical name, shared by all its geometry segments.
- Road names must be distinct after removing suffixes such as Street, Road, Avenue, Boulevard, Bridge, Close, Drive, Crescent, Lane, Mews, Yard, Way and Parkway.
- Changing only the suffix is not a new name.
- Avoid names that sound or look confusingly similar in the same city.
- Use natural names such as Ford Street, Carter Bridge, Bellview Avenue, Millbrook Road and Victoria Crescent.
- Use suffixes that fit the feature: Bridge for a bridge, Crescent for a crescent-shaped street, Close for a cul-de-sac, Square for a square, and Walk or Path for pedestrian routes.
- Avoid mechanical names such as “Airport Campus Rear Service Lane” as official street names.
- Functional names may be used where they genuinely describe a major transport route, such as an Airport Expressway, but should not dominate local street naming.
- Road aliases and historical names are searchable but are not additional canonical roads.
- Junctions, bridges, tunnels, pedestrian passages and service roads have their own distinct identities where separately named.
- Splitting a road into map segments never creates additional road identities.

## 5. Properties, buildings, addresses and units

- Every property has a unique proper name independent of its postal address.
- Every building has a unique proper name.
- Names should be natural, for example “Willow Court”, “Kingsley House”, “Riverside Apartments”, “Carter Exchange” and “Westbrook Industrial Works”.
- Parcel numbers and internal IDs are not substitutes for proper names.
- Postal addresses remain separate from property names and must use the canonical road name.
- Street numbers must be valid and unique under the street's addressing scheme.
- Unit names and numbers must be unique within their parent building, not necessarily city-wide.
- Floor labels may repeat between different buildings.
- A property, building, site, unit and business occupying it are separate entities; their names must not be conflated.
- Redevelopment, subdivision, demolition, vacancy and ownership changes preserve the historical identity chain.

## 6. Normalization and duplicate detection

All canonical-name checks must account for:
- Uppercase/lowercase differences.
- Leading, trailing and repeated spaces.
- Punctuation, apostrophe and hyphen variations.
- Unicode normalization and accented-character variants.
- Abbreviations and common expanded forms.
- Singular/plural and word-order variations where they create confusion.
- Road suffix-only variations.
- Company legal suffixes and generic industry words.
- Phonetically similar and visually confusable names.
- Lookalike Unicode characters and mixed-script substitutions.
- Empty, placeholder, meaningless, serial-only and mechanically generated labels.

Exact and normalized duplicates are rejected automatically. Similarity checks produce review flags; they must not automatically rename legitimate people or reject legitimate names solely because they resemble another name.

## 7. Historical names and lifecycle

- Every canonical name change records the prior value, new value, entity ID, reason and timestamp.
- Previous names remain searchable as aliases or historical names.
- Retired names cannot be silently allocated to a different entity in the same category.
- Historical reports retain the name applicable at the time of the event.
- Current directories and dossiers show the current canonical name.
- A name correction never changes a person's, company's, property's or road's underlying ID or reference.

## 8. Database and runtime enforcement

- Database constraints and triggers enforce uniqueness and family-name allocation.
- Runtime commands, NPC generators, imports, bulk updates and administrative tools use the same validation.
- Concurrent creation must not bypass uniqueness.
- Every generated name is validated before commit.
- Family-name assignment requires an explicit family ID to reuse an existing surname.
- Direct family-name edits without a family reassignment are rejected.
- Similarity checks cover roads, businesses, organisations, properties and buildings.
- Failed attempts return a clear reason and do not partially create records.
- Periodic audits detect legacy violations and stale denormalized copies.

## 9. Interface consistency

Canonical names must agree across:
- People, business, organisation and property directories.
- Individual dossiers and linked records.
- Addresses and property/site records.
- 2D city map and 3D city atlas.
- Search, aliases and historical lookup.
- Reports, dispatch, case records and other current-facing displays.

Historical event snapshots may retain the old name when that was the correct name at the time. They must not be rewritten as if the new name had always existed.

## 10. Deliberate exceptions

The following are reusable labels, not unique entity identities: ranks, job titles, unit types, departments under different parent organisations, property-use categories, floor labels in different buildings, case titles, incident types, routine names and generic system labels. Their uniqueness scope is their parent entity or classification system, not the entire city.

## 11. Acceptance tests

A naming release is complete only when:
1. Every person has a unique normalized complete name.
2. Every shared surname is supported by one explicit family-name group.
3. No two family-name groups share a normalized surname.
4. Every business trading name and legal organisation name is unique.
5. No road shares a normalized base name after its suffix is removed.
6. No exact duplicate property or building names exist.
7. Address, site dossier, map label and canonical records agree.
8. Historical names and corrections are retained.
9. Concurrent and bulk creation cannot bypass the rules.
10. Similarity audit flags are reviewed and documented.
11. Regression tests pass without changing IDs, relationships, map geometry or case links.

## 12. Naming reference guidance

Kingswell uses natural, concise, locally distinctive street naming. The following public guidance informed the simulation rules:
- City of London, Street Naming and Numbering Guidelines: https://www.cityoflondon.gov.uk/services/planning/street-naming-and-numbering-guidelines
- Adur and Worthing, Street Naming and Numbering: https://www.adur-worthing.gov.uk/naming-and-numbering/
- Hinckley and Bosworth, Naming Conventions: https://www.hinckley-bosworth.gov.uk/info/513/street_naming_and_numbering/666/naming_conventions/2

These are inspiration for a fictional game standard, not real-world approvals or compliance requirements.
