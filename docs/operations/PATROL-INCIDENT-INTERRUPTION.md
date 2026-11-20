# Patrol interruption by incident deployment

An active patrol schedule is automatically suspended whenever its unit changes from `on_patrol` to `responding`, `on_scene`, `returning` or `out_of_service`. This connects dispatch/deployment state changes to beat coverage without inventing patrol movement or advancing the fictional clock.

The trigger marks the schedule `suspended` and appends a `coverage_interrupted` event containing the previous and new unit states. The coverage report immediately stops counting that unit as covering the beat. Suspended schedules are not silently resumed when an incident clears; the unit must be explicitly returned to patrol through a fresh schedule/start workflow.

Regression: `database/tests/kingswell_patrol_incident_interruption.sql` uses a temporary unit and schedule, forces the responding transition, verifies suspension and one interruption event, confirms the clock is unchanged, and rolls back all fixtures.
