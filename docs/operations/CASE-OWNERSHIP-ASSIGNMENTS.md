# Case ownership and investigator assignments

The assignment workflow extends the existing `game.cases`, `game.case_assignments` and `game.police_personnel` records. It does not create a second case or personnel registry.

## Player commands

Assign an investigator:
```text
case assign CASE_REF to PERSONNEL_REF role ROLE by ACTOR_REF
```

Supported roles:
- `lead_investigator` — the case's single accountable lead.
- `investigator` — supporting investigator; multiple active investigators are allowed.
- `supervisor` — supervisory case assignment.
- `specialist` — specialist support assignment.

Release a specific role:
```text
case unassign CASE_REF PERSONNEL_REF role ROLE because "REASON" by ACTOR_REF
```

View current and previous assignments:
```text
case assignments CASE_REF
```

## Ownership rules

- A case can have only one active lead investigator.
- Assigning a replacement lead automatically releases the previous lead and records a `lead_transferred` event.
- The case's existing `lead_personnel_id` field is synchronized with the active lead assignment.
- Multiple supporting investigators may be assigned concurrently.
- The same person cannot hold duplicate active assignments in the same role on one case.
- Assignments require active or seconded police personnel and an initialized fictional clock.
- Closed cases cannot receive new assignments.
- Release commands specify the role so that releasing one role does not accidentally release another role held by the same officer.
- Assignment and release commands do not advance fictional time.

## History and data integrity

- `game.case_assignment_events` records assignment, release and lead-transfer events, the acting officer, fictional timestamp, reason/context and source command.
- Assignment event history is append-only; updates and deletes are rejected.
- The existing `case_assignments` rows retain active/released state and assignment timestamps.
- All commands use the shared idempotency ledger and explicit actor attribution.
- Tables remain in the private `game` schema, with RLS enabled and service-role-only access.

## Database functions

- `game.assign_case_investigator(case_ref, personnel_ref, assignment_role, actor_personnel_ref, source_command_id)`
- `game.release_case_investigator(case_ref, personnel_ref, assignment_role, reason, actor_personnel_ref, source_command_id)`
- `game.get_case_assignments(case_ref, personnel_ref, include_history)`

## Verification

`database/tests/kingswell_case_assignment_commands.sql` runs as a rollback-only transaction. It exercises parser and player command execution, lead assignment and transfer, multiple supporting investigators, role-specific release, assignment history, append-only protection, idempotency, help registration and unchanged fictional time.
