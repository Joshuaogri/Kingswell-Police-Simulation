# Case lead handovers and continuity

## Commands
Transfer the lead:
```text
case transfer CASE_REF from OUTGOING_PERSONNEL_REF to INCOMING_PERSONNEL_REF because "Continuity note covering outstanding enquiries, evidence, deadlines and immediate priorities" by SUPERVISOR_REF
```
Retrieve handover history:
```text
case handovers CASE_REF by SUPERVISOR_REF
```

## Rules
- The named actor must match active or seconded personnel and hold an active supervisor assignment on the case.
- The outgoing officer must be the current lead; the incoming officer must be a different active or seconded officer.
- Closed cases cannot be transferred.
- A non-empty continuity note (maximum 4,000 characters) is mandatory.
- Existing assignment logic performs the transfer and synchronizes the case lead. Assignment history records the old lead's release and new lead's appointment.
- A separate immutable handover record preserves the outgoing/incoming identities, supervisor, continuity note and fictional timestamp.
- Commands use the idempotency ledger and do not advance fictional time.
- The dossier and assignment history remain authoritative for case records and assignment events.

## Regression
The parser and executor are integrated into the existing command chain. Parser/access/RLS checks are in `database/tests/kingswell_case_lead_handovers.sql`. A full personnel-backed transfer test remains to be run once the simulation clock and seeded personnel are available.
