## Independent prosecutor review and formal charges — 2026-11-20

**Implemented, deployed and rollback-only regression verified.** Migrations:
- `database/migrations/20261120151654_independent_prosecutor_review_and_formal_charges.sql`
- `database/migrations/20261120151723_integrate_independent_prosecutor_with_existing_runtime.sql`
- `database/migrations/20261120151757_index_prosecution_review_command_reference.sql`

Adds distinct prosecutor profiles, independent referral reviews, append-only review history, formal charge records and append-only charge history. Police submit referrals and appoint prosecutor profiles; only active prosecutors can accept, return or decline referrals. Charges require an accepted referral and are recorded by count.

Commands: `prosecutor appoint`, `prosecutor review`, `prosecution charge file`, `prosecution charges`. All use idempotency and preserve fictional time. A charge remains an allegation, not a finding of guilt.

**PASS:** `database/tests/kingswell_prosecutor_charges.sql` tests referral, appointment, review, charge filing, retrieval and clock preservation. Fixtures roll back.

Guide: `docs/operations/PROSECUTOR-CHARGES.md`.
