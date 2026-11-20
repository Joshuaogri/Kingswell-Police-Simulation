# Search warrants, premises searches and seizures

Kingswell now has a dedicated case-linked search and seizure workflow. It is entirely fictional game content and uses the explicit fictional game clock.

## Issue a warrant

```text
warrant create CASE_REF by PERSONNEL_REF authority "Issuing authority" scope "Search scope" valid_for 72 hours
```

The fictional warrant records the issuing authority, case, scope, issuing officer, issue time and validity window. Validity is 1–720 fictional hours (72 by default). A warrant must be issued, unexpired and linked to the case before a search operation can be planned and executed. Deployment marks the warrant executed.

## Plan the search

```text
search plan create CASE_REF warrant WARRANT_REF by PERSONNEL_REF method premises_search objective "Search objective"
```

Methods: `premises_search`, `vehicle_search`, `storage_search`, `mixed`, `other`.

## Assign the team

```text
search team add OPERATION_REF PERSONNEL_REF role team_lead by PERSONNEL_REF
search team add OPERATION_REF PERSONNEL_REF role evidence_officer by PERSONNEL_REF
```

Roles: `team_lead`, `search_officer`, `evidence_officer`, `photographer`, `other`. Team members must be active/seconded and assigned to the case (or be its recorded case lead). One designated team leader is required before execution. Team roster freezes when execution starts.

## Register premises

```text
search premises add OPERATION_REF property PROPERTY_REF by PERSONNEL_REF description "Rear storage unit and adjoining office"
```

Premises must resolve to an existing Kingswell property. More than one premises can be linked to an operation.

## Execute the search

```text
search execute OPERATION_REF by PERSONNEL_REF
```

The executing officer must be on the assigned search team. The operation must have a team leader, at least one registered premises and an issued, in-date warrant.

## Record search activity

```text
search log OPERATION_REF premises PREMISES_REF by PERSONNEL_REF type entry at "Rear loading entrance" narrative "Team entered and commenced a systematic search."
```

Log types: `arrival`, `entry`, `area_examined`, `item_found`, `person_present`, `damage_or_condition`, `departure`, `other`. Logs are chronological, attributed and append-only.

## Record recovered property

```text
search recover OPERATION_REF premises PREMISES_REF by PERSONNEL_REF category "electronic_device" description "Black tablet computer with cracked corner" at "Steel cabinet, upper shelf" condition "Screen cracked; powered off"
```

Recovery creates a recovered-property record only. It does not automatically seize the item or treat it as evidence.

## Seize recovered property

```text
search seize RECOVERY_REF by PERSONNEL_REF reason "Item matches the case property description" packaging "Anti-static evidence bag" seal "KW-SEAL-0001" storage "Evidence Store Shelf A" evidence_type electronic_device
```

Seizure creates a seizure record and an item in the existing `game.evidence_items` register, preserving case link, collection time, location, condition, packaging, seal and storage details.

## Evidence custody transfer

```text
search evidence transfer EVIDENCE_REF to RECEIVING_PERSONNEL_REF by CURRENT_CUSTODIAN_REF from "Evidence Officer" at "Central Evidence Store" because "Secure transfer to evidence custodian"
```

Only the recorded current custodian can transfer seized evidence. Transfers are written to the shared `game.evidence_transfers` chain and update the evidence item's current storage/status. The new receiving officer becomes the current custodian.

## Record each premises outcome and close

```text
search premises status PREMISES_REF set searched because "All listed areas examined; findings recorded" by PERSONNEL_REF
search premises status PREMISES_REF set not_searched because "Premises could not be accessed; reason recorded" by PERSONNEL_REF
search close OPERATION_REF by TEAM_LEAD_REF because "Search completed and premises documented"
```

Every registered premises must receive an explicit `searched` or `not_searched` outcome and a reason before the operation can close. The operation cannot silently mark outstanding premises as searched.

## Retrieve the record

```text
search operations CASE_REF by PERSONNEL_REF
case review CASE_REF by PERSONNEL_REF
```

The search retrieval command returns warrants, operation status, team roster, premises, logs, recovered property, seizure references, evidence references and operation events. The consolidated case dossier also includes the search-operation chronology.

## System controls

- Private `game` schema; RLS enabled; no `anon` or `authenticated` table access; service-role runtime only.
- Command ledger and idempotency are used for all player writes.
- Search logs, team assignment history, seizure records and operation events are append-only.
- Search actions use current fictional game time and do not advance it.
- Search observations and recovered-property descriptions remain recorded game data, not automatic proof of ownership, guilt or offence.
- Evidence enters the existing evidence register and custody-transfer history; no parallel evidence chain is created.

## Verification

Rollback-only end-to-end test passed using two temporary assigned officers, an existing property fixture, a temporary case and a temporary clock. It verifies warrant issue, plan creation, team assignment, team-lead enforcement, premises registration, execution, search logging, recovery, seizure, evidence-register integration, custody transfer, explicit premises outcome enforcement, closure, case-dossier integration, help registration, append-only protection and no fictional time advancement. All fixtures and clock changes are rolled back; the live game remains unseeded and its clock remains uninitialized.
