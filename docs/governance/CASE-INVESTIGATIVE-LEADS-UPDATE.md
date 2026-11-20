# Kingswell implementation update — investigative leads and enquiries

Date: 2026-11-20  
Status: Implemented and verified on the live Supabase project and committed to `main`.

## Scope delivered

Added a persistent investigative lead register and enquiry-action record set, extending existing case and police-personnel records.

- `game.case_leads`: source, description, owner, status, priority, confidence, assessment rationale and fictional timestamps.
- `game.case_lead_events`: append-only creation, assignment, reassignment and assessment history.
- `game.case_enquiries`: conducted-by officer, recording officer, method, action, result, outcome, source reference and fictional timestamp.
- `game.case_enquiry_events`: append-only enquiry event history.
- Stable lead and enquiry references.
- Player command parser/executor integration, idempotency, actor attribution, help registration and read commands.
- Private schema, RLS, service-role-only access and append-only enforcement for enquiry/history records.

## Commands

- `case lead create CASE_REF "TITLE" "DESCRIPTION" source SOURCE_TYPE by ACTOR_REF`
- `case lead assign LEAD_REF to PERSONNEL_REF by ACTOR_REF`
- `case lead assess LEAD_REF status STATUS priority PRIORITY confidence CONFIDENCE because "REASON" by ACTOR_REF`
- `case enquiry record LEAD_REF by PERSONNEL_REF method METHOD action "ACTION" result "RESULT" outcome OUTCOME recorded_by ACTOR_REF`
- `case leads CASE_REF`
- `case enquiries LEAD_REF`

## Verification

The live rollback-only SQL test passed through `game.interpret_text_command` and `game.execute_text_command`. It verified creation, assignment, enquiry recording, assessment, list retrieval, idempotent replay, append-only update/delete rejection, help registration and no fictional clock advancement. All synthetic rows were rolled back.

## Design boundaries

This update records investigative leads and enquiry activity. It does not automatically declare a lead true, create suspects or cases, or change evidence. Enquiry outcomes are recorded as officer-entered information, not an automatic determination of truth.
