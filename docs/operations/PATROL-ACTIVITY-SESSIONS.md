# Patrol activity sessions

Patrol activity is recorded separately from vehicle road movement. A session has one assigned unit, one active officer, one active patrol schedule, one beat and one registered access-point location.

## Player commands

Start an activity at the unit's currently recorded location:

`start patrol activity UNIT_REF by PERSONNEL_REF at ACCESS_REF type TYPE because REASON`

Supported types:

- `foot_patrol`
- `stationary_observation`
- `community_engagement`
- `business_visit`
- `area_check`
- `vehicle_patrol_stop`
- `other`

Complete a session and explicitly record its duration:

`end patrol activity SESSION_REF after 15 minutes because REASON`

The start command records the current fictional time and does not advance it. The end command advances the fictional clock by the explicitly supplied duration, subject to the active patrol schedule. Duration must be 1–720 minutes. No elapsed time or location is inferred.

An officer must be active and assigned to the named unit. The unit must be active and on patrol, have an active schedule, and be recorded at the selected access point inside its assigned beat. Only one activity may be active for a unit or officer. A unit cannot move or end patrol while an activity is active.

## Records and intelligence

- `patrol_activity_sessions` stores the activity, officer, unit, beat, schedule, location, start/end game time and reasons.
- `patrol_activity_events` is append-only and records the start/completion timeline.
- `patrol intelligence` now reports activity sessions and minutes by type and unit separately from vehicle movement.

Open sessions are counted as zero elapsed activity minutes until an explicit completion duration is recorded. These records describe logged activity, not continuous GPS tracking or proof of every action performed.

Regression: `database/tests/kingswell_patrol_activity.sql`.
