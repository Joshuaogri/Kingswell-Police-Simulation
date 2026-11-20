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


## Case investigative leads and enquiries

- `case lead create CASE_REF "TITLE" "DESCRIPTION" source SOURCE_TYPE by ACTOR_REF`
- `case lead assign LEAD_REF to PERSONNEL_REF by ACTOR_REF`
- `case lead assess LEAD_REF status STATUS priority PRIORITY confidence CONFIDENCE because "REASON" by ACTOR_REF`
- `case enquiry record LEAD_REF by PERSONNEL_REF method METHOD action "ACTION" result "RESULT" outcome OUTCOME recorded_by ACTOR_REF`
- `case leads CASE_REF`
- `case enquiries LEAD_REF`

Lead and enquiry records are linked to existing cases and personnel. Assignment, assessment and enquiry history is retained; enquiry records and history are append-only. These commands use the current fictional clock without advancing it. See `docs/operations/CASE-INVESTIGATIVE-LEADS.md` and `database/tests/kingswell_case_investigative_leads.sql`.


## Linking leads to existing game entities

- `case lead link LEAD_REF entity person PERSON_REF because "REASON" by ACTOR_REF`
- Replace `person` with `organisation`, `property`, `evidence` or `incident` and supply that entity's existing reference.
- `case lead links LEAD_REF` lists the lead's entity associations.

Links use typed foreign keys to the existing entity registries. Evidence links are restricted to evidence already attached to the same case or not yet case-assigned. Duplicate links are idempotently recognised; link records are append-only and do not advance fictional time. The acting officer must own the lead or hold an active assignment to its case.


## Case interviews and witness statements

See `docs/operations/CASE-INTERVIEWS-WITNESS-STATEMENTS.md` for interview, transcript, witness statement, adoption and retrieval commands.


## Case interviews and witness statements

See `docs/operations/CASE-INTERVIEWS-WITNESS-STATEMENTS.md` for interview, transcript, witness statement, adoption and retrieval commands.


## Suspect interviews

See `docs/operations/SUSPECT-INTERVIEWS.md` for suspect classification, per-turn response assessments and review commands.


## Case account comparisons

See `docs/operations/CASE-ACCOUNT-COMPARISONS.md` for comparing witness statements and interview turns, recording discrepancy assessments, linking existing evidence and retrieving comparison history.


## Investigative case review dossier

`case review CASE_REF` returns a unified, read-only case dossier containing assignments, leads, enquiries, tasks, interviews, statements, suspect interview assessments, account comparisons, evidence and custody history, forensic examinations/findings/reports and linked incidents. See `docs/operations/CASE-REVIEW-DOSSIER.md`.


## Investigative case review dossier

`case review CASE_REF by OFFICER_REF` returns a unified, read-only case dossier containing assignments, leads, enquiries, tasks, interviews, statements, suspect interview assessments, account comparisons, evidence and custody history, forensic examinations/findings/reports and linked incidents. The named officer must be the recorded case lead or hold an active case assignment. See `docs/operations/CASE-REVIEW-DOSSIER.md`.


The dossier also includes case task assignments and evidence linked to the case through comparison, lead or forensic-request relationships, not only evidence whose primary case_id is set.
