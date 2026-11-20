# Investigative task dependencies and workload

## New capabilities
- Immutable prerequisite relationships between existing tasks on the same case.
- Circular dependencies, self-dependencies, cross-case dependencies, and dependencies added after a task starts are rejected.
- A task cannot transition to `in_progress` or `completed` while any prerequisite is not completed.
- Overdue status is calculated against the current fictional clock at query time. No background timer or automatic clock advancement is used.
- Workload output groups assigned officers and reports active, overdue and urgent task counts.
- Task output includes due time, overdue minutes and incomplete prerequisites.

## Database operations
Add a dependency:
```sql
select game.add_case_task_dependency('TASK_REF','PREREQUISITE_TASK_REF','OFFICER_REF',null);
```
Retrieve workload:
```sql
select game.get_case_task_workload('CASE_REF',null,500);
select game.get_case_task_workload(null,'OFFICER_REF',500);
select game.get_case_task_workload(null,null,500);
```

## Rules
- Both tasks must exist and belong to the same case.
- The actor must be active or seconded.
- Dependencies are immutable and recorded in the task event history.
- Only `completed` prerequisites satisfy a dependency; cancelled prerequisites remain blockers and require supervisory resolution rather than silently counting as successful.
- Overdue calculations use strict fictional-time comparison and exclude completed/cancelled tasks.
- Workload reports describe recorded assignments and deadlines; they are not performance ratings.
- All records remain in private `game` schema with RLS enabled and service-role access only.

## Verification
The migration was applied live. Rollback-only checks confirmed dependency table RLS, privilege restrictions, and availability of the dependency/workload functions. Full personnel-backed dependency transition tests require seeded tasks and an initialized fictional clock.
