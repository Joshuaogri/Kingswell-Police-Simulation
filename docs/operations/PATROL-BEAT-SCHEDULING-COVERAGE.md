# Patrol beat assignment, scheduling and coverage

**Implemented and regression-tested:** 2026-11-20.

Patrol units can be assigned to one of Kingswell's existing active neighbourhood beats using `game.assign_unit_patrol_beat(unit_ref,beat_ref,reason)`. Beat changes are recorded as coverage events and are blocked while the unit is responding, on scene, returning or out of service.

Patrol shifts are recorded in `game.patrol_schedules`, optionally linked to an existing unit duty roster. A schedule must have a positive time window, reference an active unit and beat, fit inside its selected roster and not overlap another active/scheduled patrol window for the same unit.

A unit starts patrol through `game.start_unit_patrol(unit_ref,reason)`. Start requires an initialized fictional clock, an active duty roster covering the current game time, an assigned active beat, a current active schedule and no active incident deployment. The unit transitions to `on_patrol`; its schedule and coverage event are updated.

A unit ends patrol through `game.end_unit_patrol(unit_ref,reason)`. The schedule is completed, a coverage event is appended, and the unit returns to its registered base position/state where a base facility exists. If no base facility is configured, it transitions to `returning` and its location is not fabricated.

Tables: `game.patrol_schedules`, `game.patrol_coverage_events`. Coverage history is append-only for service_role. The schedule table is mutable by service_role to support lifecycle status changes.

All operations require the fictional clock and never advance it automatically. The current implementation provides the database workflow; natural-language command parser integration and automatic patrol schedule commencement remain future work.

Regression: `database/tests/kingswell_patrol_beat_scheduling_coverage.sql`. Rollback-only test creates a temporary unit, roster and schedule, starts/ends patrol, verifies states and coverage events, confirms unchanged fictional time, then rolls back all fixtures.
