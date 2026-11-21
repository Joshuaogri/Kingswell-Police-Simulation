# BP-04 Counterparty Data-Integrity Correction

**Date:** 2026-11-21  
**Status:** Corrected in GitHub source; isolated regression validation pending; not deployed to live Supabase.

## Finding

The BP-04 complete-world seed originally filled missing lease counterparties by assigning the current registered property owner as landlord. This conflated two distinct property-interest roles. A registered owner is not automatically the landlord, and a landlord may be a different person or organisation.

The prior live audit had identified 152 tenant-site agreements with no recorded landlord interest. The registered-owner records for those properties did not establish a landlord relationship.

## Correction

Migration `20261121270000_bp04_complete_world_population_and_exact_premises_links.sql` now resolves a missing lease counterparty only from a separate, current `property_interest_records` row whose `interest_type='landlord'` and whose holder matches the property.

The resolution supports either a canonical person holder or a canonical organisation holder. It does not infer landlord status from registered title, beneficial ownership, property management, tenancy or occupancy.

Where no explicit current landlord interest exists:
- `counterparty_person_id` and `counterparty_organisation_id` remain null.
- An existing recorded counterparty role is preserved; no landlord role is invented.
- The agreement and its other independently generated fictional contract fields remain available in the agreement dossier.
- The absence is exposed as unknown rather than silently completed with an unsupported identity.

## Regression coverage

`database/tests/bp04_complete_world_population_and_exact_premises_links.sql` no longer requires every agreement to have a named counterparty. It now rejects any agreement labelled as having a landlord where the same property has no matching current landlord-interest record.

This test runs in a transaction and rolls back. The full 96-test suite must pass before BP-04 is treated as regression-validated.

## Deployment boundary

This correction is committed to GitHub `main`. The live Supabase database was queried read-only during this audit. No migration, seed or data update was deployed to it.

## Completion status

This correction closes one data-integrity defect; it does not certify BP-04 complete. Remaining acceptance work includes full isolated regression success, complete cross-system integration checks, validated write/read command coverage, detailed record coverage and honest documentation of facts that remain unknown.
