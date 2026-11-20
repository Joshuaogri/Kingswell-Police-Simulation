# Case investigative task management — implementation update

**Date:** 2026-11-20  
**Blueprint alignment:** BP-15 Case Management, BP-16 Investigation, BP-35 Simulation Engine, BP-38 Records and Databases, BP-43 Testing and Quality Assurance.

## Delivered

The first case-workflow implementation extends the existing case and police-personnel registries.

- Added private `game.case_tasks` records for investigative tasks, priority, status, investigator assignment, due time, completion and outcome.
- Added `game.case_task_events` for task creation, assignment and progression history.
- Added service-role-only functions `game.create_case_task`, `game.update_case_task` and `game.get_case_tasks`.
- Added player-facing command integration through the existing `game.interpret_text_command` and `game.execute_text_command` path.
- Commands support task creation, status changes, reassignment, case task lists and individual task history.
- Task commands use the shared idempotency ledger and explicit officer attribution.
- Requires an initialized fictional clock and active or seconded police personnel attribution.
- Closed cases cannot receive new tasks. Completed/cancelled tasks cannot be reopened.
- Uses fictional game timestamps and does not advance the clock.
- Added indexes for case/status, assignee/status and task-event chronology.
- RLS is enabled; the schema remains private and the tables/functions are service-role restricted.

## Player commands

- `case task create CASE_REF type TASK_TYPE priority PRIORITY assign PERSONNEL_REF title "TITLE" because "DESCRIPTION" by ACTOR_REF`
- `case task update TASK_REF STATUS by ACTOR_REF`
- `case task update TASK_REF completed by ACTOR_REF outcome "RESULT"`
- `case task assign TASK_REF to PERSONNEL_REF by ACTOR_REF`
- `case tasks CASE_REF`
- `case task TASK_REF`

Use `assign none` when creating an unassigned task.

## Verification

**PASS:** A live Supabase rollback-only transaction created temporary case/personnel fixtures and exercised the complete text-command path: parser recognition, task creation, idempotent replay, in-progress status, reassignment, case task listing, individual task retrieval, completion and unchanged fictional time. The database-level regression separately verified event history and final-state protection. All fixtures and clock changes rolled back.

The first command regression attempt caught a missing actor field in the create grammar; explicit actor attribution was added and the complete corrected regression passed.

Regression scripts:
- `database/tests/kingswell_case_task_management.sql`
- `database/tests/kingswell_case_task_commands.sql`

Migrations:
- `database/migrations/20261120140000_case_investigative_task_management.sql`
- `database/migrations/20261120140100_case_task_player_commands.sql`
- `database/migrations/20261120140200_case_task_create_command_actor_attribution.sql`

Operations guide: `docs/operations/CASE-INVESTIGATIVE-TASKS.md`

## Remaining in this workflow

Case ownership/assignment history, lead/enquiry management, investigative review, and case progression/closure remain subsequent slices. Do not mark the wider BP-15/BP-16 divisions complete.
