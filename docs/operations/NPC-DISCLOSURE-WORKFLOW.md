# NPC disclosure and defence materials

All prosecution and defence actors are fictional NPCs. The player remains the only player. Disclosure commands are game mechanics and do not invoke real-world services.

## Assign NPC defence counsel
`defence counsel assign CASE_REF person PERSON_REF by PROSECUTOR_REF`
An active prosecutor NPC registers/assigns an existing person as defence counsel for the case. The returned `KWDC-...` reference is used for defence commands.

## Create packages
- Prosecution: `disclosure prosecution create REFERRAL_REF by PROSECUTOR_REF title "Initial disclosure"`
- Defence: `disclosure defence create CASE_REF by COUNSEL_REF title "Defence disclosure"`

A prosecution package requires an accepted referral and at least one filed formal charge. Defence packages require an active counsel assignment to the case.

## Add and classify material
`disclosure item add PACKAGE_REF category evidence source EVIDENCE_REF title "CCTV export" notes "Original export" by ACTOR_REF`

Categories: `evidence`, `witness_statement`, `interview`, `forensic_report`, `surveillance_record`, `search_record`, `custody_record`, `case_document`, `other`. Evidence references must resolve to evidence belonging to the same case. Other categories retain the source reference as a typed game record link.

Set a material's treatment while the package is a draft:
`disclosure item set ITEM_REF treatment disclosed|redacted|withheld because "Reason" by ACTOR_REF`
Redacted and withheld material requires a reason. The original case source is never modified.

## Serve and acknowledge
`disclosure serve PACKAGE_REF to PERSON_REF by ACTOR_REF`
`disclosure acknowledge PACKAGE_REF by ACTOR_REF`

Prosecution packages are served to the case's assigned NPC defence counsel; defence packages are served to an NPC prosecutor who reviewed that case. Only the intended recipient can acknowledge receipt. Service and acknowledgement are recorded with fictional timestamps and command history.

## Retrieve
- `disclosure packages CASE_REF by ACTOR_REF`
- `disclosure package PACKAGE_REF by ACTOR_REF`

The consolidated case dossier also includes counsel assignments, disclosure packages, items, treatment reasons and service receipts.

## Simulation rules
- Package contents can only be changed while the package is a draft.
- A package must contain at least one item before service.
- Receipts can be acknowledged once and cannot be deleted.
- Disclosure events are append-only.
- Commands use idempotency and current fictional time; they do not advance the clock.
- The entire workflow is NPC-to-NPC. No real people or external legal process are involved.

Regression: `database/tests/kingswell_disclosure_workflow.sql` is rollback-only and tests both directions, redaction, withholding, service, acknowledgement, dossier integration and clock preservation.
