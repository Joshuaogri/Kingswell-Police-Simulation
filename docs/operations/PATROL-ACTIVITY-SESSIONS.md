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
- `patrol_activity_events` is append-only and records the start/completion timeline. Completed activity sessions are immutable; an active session permits only one completion transition.
- `patrol intelligence` now reports activity sessions and minutes by type and unit separately from vehicle movement.

Open sessions are counted as zero elapsed activity minutes until an explicit completion duration is recorded. These records describe logged activity, not continuous GPS tracking or proof of every action performed.

Regression: `database/tests/kingswell_patrol_activity.sql`.

## Patrol observations and civilian/business contacts

All records are tied to an active patrol activity session and the assigned officer. They use the session's registered access-point location and current fictional game time. Recording an observation or contact does not advance the clock.

### Record an observation

`record patrol observation SESSION_REF category CATEGORY at ACCESS_REF because DESCRIPTION`

Categories: `suspicious_activity`, `traffic`, `property_condition`, `vulnerable_person`, `public_order`, `environmental_hazard`, `community_concern`, `wanted_vehicle`, `other`.

The optional `at ACCESS_REF` must identify the same registered access point as the activity session. Observation records are append-only.

### Record a contact

`record patrol contact SESSION_REF type TYPE [person PERSON_REF] [organisation ORG_REF] [property PROPERTY_REF] [incident INCIDENT_REF] outcome OUTCOME [notes NOTES]`

Types: `person_spoken_to`, `business_visit`, `community_contact`, `welfare_check`, `witness_contact`, `other`.

Person, organisation, property and incident links are optional individually; ordinary person/business/welfare/witness contacts must link at least one existing record. `community_contact` and `other` may be recorded without an entity link. All supplied references must resolve to existing records. Organisation references may identify a business or another organisation.

Observations and contacts are immutable, append-only records linked to the activity, officer, unit, beat, location and source command. These entries record what the officer entered; they do not independently establish the truth of an allegation or observation.

`patrol intelligence` includes observation totals by category and contact totals by type, including linked-entity counts.

Regression: `database/tests/kingswell_patrol_observations_contacts.sql`.
