# Case ownership and investigator assignments — implementation update

**Date:** 2026-11-20  
**Blueprint alignment:** BP-15 Case Management, BP-16 Investigation, BP-35 Simulation Engine, BP-38 Records and Databases, BP-43 Testing and Quality Assurance.

## Delivered

- Extended the existing `game.case_assignments` workflow rather than creating duplicate case/personnel tables.
- Added append-only `game.case_assignment_events` with actor, fictional timestamp, event context and source command.
- Added single-active-lead enforcement and duplicate active same-person/same-role prevention.
- Added accountable lead investigator, supporting investigator, supervisor and specialist roles.
- Synchronized the existing `game.cases.lead_personnel_id` field with the active lead assignment.
- Lead replacement automatically releases the former lead and records a transfer event.
- Supporting investigators can be assigned concurrently.
- Role-specific release prevents ambiguity when one officer holds more than one role on a case.
- Added player commands for assign, unassign and assignment-history lookup.
- Commands use the existing idempotency ledger and actor attribution.
- Closed cases cannot receive new assignments. All timestamps use the fictional clock and commands do not advance it.
- Private schema, RLS and service-role-only execution retained.

## Player commands

- `case assign CASE_REF to PERSONNEL_REF role ROLE by ACTOR_REF`
- `case unassign CASE_REF PERSONNEL_REF role ROLE because "REASON" by ACTOR_REF`
- `case assignments CASE_REF`

Roles: `lead_investigator`, `investigator`, `supervisor`, `specialist`.

## Verification

**PASS:** A live Supabase rollback-only transaction exercised the full player command path, including lead assignment, two concurrent supporting investigators, lead transfer, role-specific release, history retrieval, append-only enforcement, duplicate-command replay, help registration and unchanged fictional time. The first test exposed an overly broad release selector; the command now requires an explicit role, and the corrected regression passed.

Regression:
- `database/tests/kingswell_case_assignment_commands.sql`

Migrations:
- `database/migrations/20261120125918_case_ownership_and_investigator_assignment_history.sql`
- `database/migrations/20261120125942_case_assignment_player_commands.sql`
- `database/migrations/20261120125958_case_assignment_supporting_investigator_fix.sql`
- `database/migrations/20261120130042_case_assignment_role_specific_release.sql`
- `database/migrations/20261120130100_revoke_ambiguous_case_assignment_release.sql`

Operations guide: `docs/operations/CASE-OWNERSHIP-ASSIGNMENTS.md`

## Remaining in investigation management

Lead/enquiry records, investigative review, and case progression/closure remain subsequent implementation slices. This update does not mark the wider BP-15/BP-16 divisions complete.
