# Patrol command interface and beat coverage

Patrol operations are now available through the same natural-language command path as dispatch and scene operations. Commands are submitted through `game.execute_text_command` and retain the existing command ledger/idempotency behavior.

## Commands

- `assign beat UNIT_REF to BEAT_REF because REASON`
- `schedule patrol SCHEDULE_REF UNIT_REF in BEAT_REF from 2026-11-20T13:30:00+00:00 to 2026-11-20T16:00:00+00:00`
- `start patrol UNIT_REF because REASON`
- `end patrol UNIT_REF because REASON`
- `patrol status` (also `patrol coverage` or `beat coverage`)

Schedule timestamps must be ISO-8601 timestamps with timezone offsets. The current command grammar schedules a unit/beat time window; an optional roster reference remains available through the underlying database function but is not yet accepted by this concise command form.

The coverage report lists every active beat, active on-patrol units and schedule window, and covered/uncovered totals. A beat is counted covered only while a unit is actively on patrol on that beat; a scheduled but not commenced patrol does not count as coverage.

All commands use the established command ledger and idempotency keys. Patrol operations do not advance fictional time. The regression test uses temporary fixtures in a transaction ending in ROLLBACK.

Regression: `database/tests/kingswell_patrol_command_interface.sql`.


## Road movement

- `patrol move UNIT_REF to ACCESS_REF because REASON`

This command routes the on-patrol unit to a registered access point on its assigned beat, records every road segment traversed, updates its current location and advances fictional time by the route's estimated duration. Transit legs outside the beat are recorded but excluded from beat coverage. See `PATROL-ROAD-MOVEMENT.md` for the detailed movement model.


## Patrol intelligence

- `patrol intelligence` — reports road-segment coverage, patrol movement minutes, beat gaps, least-visited roads and unit activity through current fictional time.
- Aliases: `patrol gaps`, `patrol analysis`.
- Optional timestamp-window reporting is available through the database reporting function; the standard player command reports all recorded history.


## Foot patrol and officer activity

- `start patrol activity UNIT_REF by PERSONNEL_REF at ACCESS_REF type TYPE because REASON` starts a logged activity at the unit's current recorded location.
- `end patrol activity SESSION_REF after N minutes because REASON` completes the activity and advances fictional time by the explicitly stated duration.
- Activity types: `foot_patrol`, `stationary_observation`, `community_engagement`, `business_visit`, `area_check`, `vehicle_patrol_stop`, `other`.
- The unit must be active and on patrol with an active schedule; the officer must be active and assigned to that unit; the location must be the unit's recorded location inside its assigned beat.
- One activity at a time is allowed per unit/officer. Movement and patrol termination are blocked until the activity is completed.
- `patrol intelligence` now includes activity totals by type and unit separately from road movement. Open sessions do not accumulate elapsed minutes until completed with an explicit duration.

See `PATROL-ACTIVITY-SESSIONS.md` for the record model and constraints. Regression: `database/tests/kingswell_patrol_activity.sql`.



## Patrol observations and contacts

- `record patrol observation SESSION_REF category CATEGORY [at ACCESS_REF] because DESCRIPTION`
- `record patrol contact SESSION_REF type TYPE [person PERSON_REF] [organisation ORG_REF] [property PROPERTY_REF] [incident INCIDENT_REF] outcome OUTCOME [notes NOTES]`
- Observation categories: `suspicious_activity`, `traffic`, `property_condition`, `vulnerable_person`, `public_order`, `environmental_hazard`, `community_concern`, `wanted_vehicle`, `other`.
- Contact types: `person_spoken_to`, `business_visit`, `community_contact`, `welfare_check`, `witness_contact`, `other`.
- Both require an active patrol activity session and its assigned officer. Any supplied access point must match the session's registered location.
- Contact references resolve to existing person, organisation, property and/or incident records. Person/business/welfare/witness contacts require at least one linked entity; community_contact and other may be unlinked.
- Entries are append-only and immutable. Logging does not advance fictional time.
- `patrol intelligence` includes observation counts by category and contact counts by type, including linked people/organisations/properties/incidents.

See `PATROL-ACTIVITY-SESSIONS.md`. Regression: `database/tests/kingswell_patrol_observations_contacts.sql`.
