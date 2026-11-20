# Patrol command interface and beat coverage

Patrol operations are available through the natural-language command path. Commands use the command ledger and idempotency behavior.

## Commands

- `assign beat UNIT_REF to BEAT_REF because REASON`
- `schedule patrol SCHEDULE_REF UNIT_REF in BEAT_REF from 2026-11-20T13:30:00+00:00 to 2026-11-20T16:00:00+00:00`
- `start patrol UNIT_REF because REASON`
- `end patrol UNIT_REF because REASON`
- `patrol status` (also `patrol coverage` or `beat coverage`)

Schedule timestamps require ISO-8601 timezone offsets. Patrol coverage counts only active on-patrol units.

## Road movement

- `patrol move UNIT_REF to ACCESS_REF because REASON`

Records every road segment, updates unit location and advances fictional time by estimated route duration. Transit legs outside the assigned beat do not count toward beat coverage.

## Patrol intelligence and activity

- `patrol intelligence` — road-segment coverage, coverage gaps, least-visited roads and unit activity.
- `start patrol activity UNIT_REF by PERSONNEL_REF at ACCESS_REF type TYPE because REASON`
- `end patrol activity SESSION_REF after N minutes because REASON`
- Activity types: `foot_patrol`, `stationary_observation`, `community_engagement`, `business_visit`, `area_check`, `vehicle_patrol_stop`, `other`.

## Observations and contacts

- `record patrol observation SESSION_REF category CATEGORY [at ACCESS_REF] because DESCRIPTION`
- `record patrol contact SESSION_REF type TYPE [person PERSON_REF] [organisation ORG_REF] [property PROPERTY_REF] [incident INCIDENT_REF] outcome OUTCOME [notes NOTES]`

Both require an active patrol activity session and assigned officer. Source records are append-only and do not advance fictional time.

## Search and investigation links

- `search patrol intelligence [for WORDS]`
- `link patrol record RECORD_REF to incident INCIDENT_REF because REASON`
- `link patrol record RECORD_REF to case CASE_REF because REASON`
- `patrol intelligence links [for RECORD_REF]`

Search is read-only. Links are separate immutable associations; they do not alter source records or create incidents/cases.

## Officer review commands

- `review patrol intelligence LINK_REF disposition relevant because REASON`
- Replace `relevant` with `further_enquiries`, `insufficient_information` or `not_relevant` as appropriate.
- `patrol intelligence reviews` — latest review history.
- `patrol intelligence reviews for REFERENCE` — history for a review, link, source record or target.

Reviews require an active officer attribution and initialized fictional clock. Each review is a separate append-only assessment with originating command and fictional time. A review does not rewrite the patrol record or prove that its contents are true. Review-history lookup does not advance fictional time.

Regression: `database/tests/kingswell_patrol_intelligence_reviews.sql` and `database/tests/kingswell_patrol_intelligence_review_commands.sql`.
