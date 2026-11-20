# Investigative leads and enquiries

The lead/enquiry workflow is attached to existing Kingswell case and police-personnel records. It does not create duplicate cases, people, organisations or evidence.

## Player commands

Create a lead:
```text
case lead create CASE_REF "TITLE" "DESCRIPTION" source SOURCE_TYPE by ACTOR_REF
```
Sources: `officer_observation`, `witness_information`, `patrol_intelligence`, `evidence`, `forensic_result`, `interview`, `surveillance`, `document`, `other`.

Assign responsibility:
```text
case lead assign LEAD_REF to PERSONNEL_REF by ACTOR_REF
```

Assess or update a lead:
```text
case lead assess LEAD_REF status STATUS priority PRIORITY confidence CONFIDENCE because "REASON" by ACTOR_REF
```
Statuses: `open`, `under_enquiry`, `resolved`, `closed`, `disproved`. Priorities: `low`, `normal`, `high`, `urgent`. Confidence: `unassessed`, `low`, `moderate`, `high`.

Record an enquiry:
```text
case enquiry record LEAD_REF by PERSONNEL_REF method METHOD action "ACTION" result "RESULT" outcome OUTCOME recorded_by ACTOR_REF
```
Outcomes: `information_obtained`, `no_information`, `corroborated`, `contradicted`, `inconclusive`, `unable_to_complete`, `referral_required`.

List case leads and history:
```text
case leads CASE_REF
```
List enquiries for a lead:
```text
case enquiries LEAD_REF
```

## Behaviour and integrity

- Each lead has a stable `KNG-LD-#######` reference and belongs to one existing case.
- Lead source type/reference, owner, status, priority, confidence and assessment reason are retained.
- Each assignment, reassignment, assessment and status change produces an append-only event.
- Enquiries record the officer conducting the action separately from the officer recording it.
- Enquiry actions, results, outcomes and source references are retained in append-only records with a separate event trail.
- The conducting officer must own the lead or hold an active assignment to its case.
- Only active or seconded personnel can be assigned or attributed as actors.
- Closed/archived cases cannot receive new leads. Terminal leads cannot receive new enquiries or be reassigned.
- All actions use the shared command idempotency ledger and explicit actor attribution.
- Investigative record creation does not advance fictional time; it uses the current initialized game clock.
- Tables remain in private `game` schema, RLS-enabled, service-role-only.

## Database functions

- `game.create_case_lead(...)`
- `game.assign_case_lead(...)`
- `game.assess_case_lead(...)`
- `game.record_case_enquiry(...)`
- `game.get_case_leads(...)`
- `game.get_case_enquiries(...)`

## Verification

`database/tests/kingswell_case_investigative_leads.sql` is a rollback-only end-to-end test covering parsing, creation, assignment, enquiry recording, assessment, listing, idempotent replay, append-only protections, help registration and unchanged fictional time.


## Linking leads to existing game entities

- `case lead link LEAD_REF entity person PERSON_REF because "REASON" by ACTOR_REF`
- Replace `person` with `organisation`, `property`, `evidence` or `incident` and supply that entity's existing reference.
- `case lead links LEAD_REF` lists the lead's entity associations.

Links use typed foreign keys to the existing entity registries. Evidence links are restricted to evidence already attached to the same case or not yet case-assigned. Duplicate links are idempotently recognised; link records are append-only and do not advance fictional time. The acting officer must own the lead or hold an active assignment to its case.
