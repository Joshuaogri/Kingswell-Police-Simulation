# Investigative case review dossier

The read-only `case review CASE_REF` command assembles the current authoritative case record into one structured review. It is a retrieval and synthesis surface, not an automated investigative conclusion.

## Included sections

- Case identity, title, type, status, summary and recorded lead.
- Current and historical case assignments.
- Investigative leads and their linked people, organisations, properties, evidence and incidents.
- Enquiry actions, results and outcomes.
- Investigative tasks and their current status.
- Witness interviews with chronological question-and-answer turns.
- Suspect interview record and investigator assessments of individual turns.
- Witness statements.
- Account comparisons, discrepancy assessments and associated evidence.
- Evidence register, collection details, current status, storage location and transfer history.
- Forensic requests, requested evidence context, examinations, findings, limitations and issued report versions.
- Linked incidents and their relationship to the case.

The dossier references the existing records. It does not duplicate or rewrite them.

## Player command

```text
case review CASE_REF
```

The command is read-only, uses the normal command ledger/idempotency key, does not advance fictional time and returns a not-found response for an unknown case.

## Investigative control and safeguards

- The dossier does not score credibility, identify a culprit, infer guilt, recommend a suspect or automatically close leads.
- Contradictions and forensic limitations remain visible as recorded by investigators and examiners.
- Existing source records, evidence custody, report versions and interview histories remain authoritative.
- Suspect identities remain part of the private game record; the gameplay disclosure rule is unchanged.
- The command and underlying function are restricted to the private game runtime/service role.

## Verification

`database/tests/kingswell_case_review_dossier.sql` runs a rollback-only test through the real command parser and executor. It verifies dossier sections, idempotency, missing-case handling and help registration.
