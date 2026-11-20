# Case task commands: dependencies and workload

## Commands

List tasks on a case:
```text
case tasks CASE_REF by PERSONNEL_REF
```

Add a prerequisite relationship (TASK_REF cannot start until PREREQUISITE_REF is completed):
```text
case task dependency TASK_REF requires PREREQUISITE_TASK_REF by PERSONNEL_REF
```

View case workload:
```text
case task workload case CASE_REF by PERSONNEL_REF
```

View your own assigned workload:
```text
case task workload officer PERSONNEL_REF by ACTOR_REF
```

View department-wide workload (active case supervisor assignment required):
```text
case task workload by SUPERVISOR_REF
```

## Access
- The named actor must be active or seconded and, where a case is selected, must hold an active assignment to that case or be its recorded lead.
- Officers can inspect their own workload. Inspecting another officer's workload requires an active supervisor assignment.
- Department-wide workload requires an active supervisor assignment.
- All commands use the command idempotency ledger.
- Read operations do not advance fictional time.

## Workload semantics
- Overdue is evaluated at query time against the explicit fictional clock.
- Completed and cancelled tasks are excluded from overdue counts.
- Only a completed prerequisite satisfies a dependency. A cancelled prerequisite remains an explicit blocker.
- Workload totals are descriptions of recorded task allocation, not staff performance scores.
- Results are capped at 500 tasks.

## Verification
Parser coverage includes dependency creation, case workload, officer workload, department workload and case task listing. The runtime help command was executed inside a rollback-only transaction and includes the new commands. Personnel-backed workflow tests require initialized fictional time and seeded case/personnel/task records.
