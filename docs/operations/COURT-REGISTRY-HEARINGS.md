# NPC court registry, docket and hearings

All courts and participants are fictional game entities. The user is the only player; prosecutors, judges, clerks, accused persons, defence counsel, witnesses and police are NPCs.

## Create a court and appoint officials
`court create by PROSECUTOR_REF name "Kingswell Central Court" level district`
Levels: `magistrates`, `district`, `high`, `appeal`.

`court official appoint PERSON_REF role judge|senior_judge|chief_judge|clerk|registrar by PROSECUTOR_REF`

Appointments create distinct NPC court-official profiles. A person can hold one court profile.

## Register a case and assign a judge
`court case register CASE_REF at COURT_REF by PROSECUTOR_REF`

The case must be open, the court active, and at least one formal charge filed. A case cannot be simultaneously registered in multiple active courts.

`court case assign judge COURTCASE_REF JUDGE_REF by PROSECUTOR_REF`

Only an active judge, senior judge or chief judge can be assigned.

## Hearings
`court hearing schedule COURTCASE_REF type initial_appearance|bail_hearing|case_management|trial|sentencing|appeal|other at "2026-11-21T09:00:00+00:00" by JUDGE_REF`

Scheduling uses the explicit fictional timestamp. A hearing cannot be scheduled in the past relative to the game clock. It does not advance the clock.

`court hearing attendance HEARING_REF person PERSON_REF role accused|prosecutor|defence_counsel|witness|police_officer|judge|clerk|other status present|absent|excused|not_required by OFFICIAL_REF`

`court hearing adjourn HEARING_REF because "NPC witness unavailable" by JUDGE_REF`

Adjournment preserves the original hearing record. Schedule a new hearing separately.

`court hearing conclude HEARING_REF outcome "Initial appearance completed" notes "..." by JUDGE_REF`

A hearing can only be concluded at or after its scheduled fictional time.

## Judicial orders
`court order issue HEARING_REF type bail_granted|bail_refused|remand|adjournment|disclosure_direction|attendance_direction|other details "Order text" by JUDGE_REF`

Orders and hearing events are append-only. Orders are fictional court records, not real-world decisions.

## Retrieve
- `court docket CASE_REF by ACTOR_REF`
- `court hearing HEARING_REF by ACTOR_REF`
- The consolidated `case review` dossier includes court registrations, judges, hearings, attendance and orders.

Docket retrieval is limited to the case's active police assignees, the case's reviewing prosecutor NPCs, assigned defence counsel NPCs and assigned judge NPCs.

## Regression
`database/tests/kingswell_court_registry_and_hearings.sql` is rollback-only. It tests court and official creation, registration, judge assignment, hearing scheduling, attendance, an order, adjournment, conclusion, docket access, dossier integration, help registration and unchanged fictional time.

## Migration replay note

The deployed database records the court feature's incremental correction migrations. For clean repository replay, the corrected final court schema and runtime definitions are consolidated in the initial court feature migration; the subsequent versioned files are compatibility notes documenting the corrections already included in that baseline.
