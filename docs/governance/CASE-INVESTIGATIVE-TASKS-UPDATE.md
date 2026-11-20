# Case investigative task management — implementation update

**Date:** 2026-11-20  
**Blueprint alignment:** BP-15 Case Management, BP-16 Investigation, BP-35 Simulation Engine, BP-38 Records and Databases, BP-43 Testing and Quality Assurance.

## Delivered

The first case-workflow implementation extends the existing case and police-personnel registries.

- Added private `game.case_tasks` records for investigative tasks, priority, status, investigator assignment, due time, completion and outcome.
- Added `game.case_task_events` for task creation, assignment and progression history.
- Added service-role-only functions `game.create_case_task`, `game.update_case_task` and `game.get_case_tasks`.
- Requires an initialized fictional clock and active or seconded police personnel attribution.
- Closed cases cannot receive new tasks. Completed/cancelled tasks cannot be reopened.
- Uses fictional game timestamps and does not advance the clock.
- Added indexes for case/status, assignee/status and task-event chronology.
- RLS is enabled; the schema remains private and the tables/functions are service-role restricted.

## Verification

**PASS:** A live Supabase rollback-only transaction created a temporary case, officer and task; assigned the task; moved it to in-progress; completed it; retrieved all three history events; verified completed-task finality; and verified no fictional clock advancement. The first test attempt exposed a test-harness exception-handling mistake, not a database defect; the corrected regression transaction passed. All temporary fixtures and clock changes rolled back.

Regression script: `database/tests/kingswell_case_task_management.sql`  
Migration: `database/migrations/20261120140000_case_investigative_task_management.sql`  
Operations guide: `docs/operations/CASE-INVESTIGATIVE-TASKS.md`

## Remaining in this workflow

Player-facing text-command parsing and command-ledger integration are not yet connected. Case ownership/assignment history, lead/enquiry management, investigative review, and case progression/closure remain subsequent slices. Do not mark the wider BP-15/BP-16 divisions complete.
