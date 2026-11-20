# Case investigative task management

The case task layer extends the existing `game.cases` and `game.police_personnel` records. It does not create a parallel case or personnel registry.

## Records

- `game.case_tasks`: one durable investigative task linked to a case, with task type, title, description, priority, status, optional investigator, due time, completion time and outcome.
- `game.case_task_events`: append-only history of task creation, assignment, reassignment, status changes, completion and cancellation.
- Task references use the `KWT-` prefix and a generated unique suffix.

## Player-facing text commands

All commands use the existing idempotent `game.execute_text_command` path.

Create:
```text
case task create CASE_REF type TASK_TYPE priority PRIORITY assign PERSONNEL_REF title "TITLE" because "DESCRIPTION" by ACTOR_REF
```
Use `assign none` for an unassigned task.

Update status:
```text
case task update TASK_REF STATUS by ACTOR_REF
case task update TASK_REF completed by ACTOR_REF outcome "RESULT"
```

Reassign:
```text
case task assign TASK_REF to PERSONNEL_REF by ACTOR_REF
```

Read:
```text
case tasks CASE_REF
case task TASK_REF
```

Valid priorities: `low`, `normal`, `high`, `urgent`.

Valid statuses: `planned`, `in_progress`, `blocked`, `completed`, `cancelled`. Completed and cancelled tasks are final; further work requires a new task. Only active or seconded personnel can record or receive tasks. Closed cases cannot receive new tasks.

## Database operations

- `game.create_case_task(case_ref, task_type, title, description, priority, assigned_personnel_ref, actor_personnel_ref, due_at_game_time, source_command_id)`
- `game.update_case_task(task_ref, status, outcome, assigned_personnel_ref, actor_personnel_ref, source_command_id)`
- `game.get_case_tasks(case_ref, task_ref, limit)`

All task timestamps use the explicitly configured fictional game clock. Creating, updating or reading tasks never advances time. The task workflow refuses writes while the fictional clock is uninitialized.

## Access and integrity

The tables are in the private `game` schema, have RLS enabled, and are granted only to `service_role`. The task functions and player command functions are executable only by `service_role`. Event history is append-only by application design; no player-facing update/delete operation exists. Command writes use the shared idempotency ledger.

## Verification

- `database/tests/kingswell_case_task_management.sql` verifies database-level create/progress/complete, event history, final-state protection and unchanged fictional time.
- `database/tests/kingswell_case_task_commands.sql` verifies parser, command ledger, duplicate replay, status update, reassignment, list/get, completion and unchanged fictional time.

Both regression tests run in transactions that roll back all fixtures.
