# Investigative activity records

Kingswell has a chronological activity register for case work that does not belong exclusively in a specialised workflow. Existing structured interviews, enquiries, forensic examinations, arrest/custody and evidence records remain authoritative; activity entries supplement those records and link to them rather than replacing them.

## Record an activity
```text
case activity record CASE_REF type ACTIVITY_TYPE by PERSONNEL_REF method "METHOD" outcome OUTCOME because "What was done and why" result "What happened"
```

Types: `surveillance`, `search`, `interview_activity`, `suspect_contact`, `arrest`, `warrant_execution`, `forensic_examination`, `scene_visit`, `document_review`, `digital_enquiry`, `phone_enquiry`, `briefing`, `liaison`, `intelligence_development`, `other`.

Outcomes: `information_obtained`, `no_information`, `corroborated`, `contradicted`, `inconclusive`, `unable_to_complete`, `arrest_made`, `evidence_recovered`, `referral_required`, `other`.

## Link an existing case record
```text
case activity link ACTIVITY_REF ENTITY_TYPE ENTITY_REF by PERSONNEL_REF because "Why this record is connected"
```
Entity types: `person`, `lead`, `enquiry`, `task`, `evidence`, `interview`, `witness_statement`, `incident`. The reference must already exist in the same case. Source records are not duplicated or modified.

## View the case chronology
```text
case activity history CASE_REF by PERSONNEL_REF
```
Alias: `case activity list`.

## Controls
- Conducting and recording officer must be active/seconded and assigned to the case or be its recorded lead.
- Closed/archived cases reject new activity records.
- Records and links are append-only and attributed to a source command.
- The explicit fictional clock supplies timestamps; recording does not advance it.
- Commands use the existing idempotency ledger.
- The case review dossier includes the latest 500 activity records under `activities`.
- Tables are private-schema, RLS-enabled and service-role-only.

## Verification
Parser, help registration, RLS/privilege checks, dossier integration and empty-state checks passed. Personnel-backed activity creation and link validation require seeded case/personnel fixtures and an initialized fictional clock; these have not been created in the live world.
