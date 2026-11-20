# Kingswell prosecution referral workflow — implementation update

**Status: deployed and rollback-only regression verified.**

The live private `game` schema now includes:

- `prosecution_referrals`: one referral per arrest, linked to the existing case, arrest, person and submitting officer.
- `prosecution_referral_events`: append-only submission and prosecutor-decision history.
- Player commands: `prosecution refer`, `prosecution decision`, and `prosecution referrals`.
- Decisions: `accepted`, `returned`, or `declined`.
- Case-lead/active-assignee access checks, active-personnel attribution, command idempotency, current fictional-time timestamps and no clock advancement.
- Private-schema RLS and service-role-only access.

The rollback-only regression exercises referral submission, returned decision, retrieval, help registration and unchanged fictional time.

This is the first prosecution layer. Disclosure packages, court scheduling, bail, hearings, judicial outcomes and appeal workflows remain future implementation work.

See `docs/operations/PROSECUTION-REFERRALS.md` and `database/tests/kingswell_prosecution_referrals.sql`.
