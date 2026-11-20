# Surveillance operations

Dedicated surveillance plans and deployments now operate as a specialist case workflow. They supplement the general case activity register and preserve team, observation, linkage and operation-event history.

## Plan an operation
```text
surveillance plan create CASE_REF by PERSONNEL_REF method static_observation at "Northgate roofline" objective "Observe the loading bay during the stated period" subject "Unknown dark saloon vehicle and occupants"
```
Methods: `static_observation`, `mobile_observation`, `vehicle_observation`, `technical_observation`, `mixed`, `other`.

## Assign team members
```text
surveillance team add OPERATION_REF PERSONNEL_REF role observer by PERSONNEL_REF
```
Roles: `team_lead`, `observer`, `driver`, `technical_operator`, `relief`, `other`.

## Deploy
```text
surveillance deploy OPERATION_REF by PERSONNEL_REF
```
The deploying officer must be assigned to the team.

## Record an observation
```text
surveillance log OPERATION_REF by PERSONNEL_REF type vehicle_movement at "Market Lane junction" details "Dark saloon travelled eastbound" subject "Unknown driver" movement "Eastbound, then turned south" vehicle "Dark four-door saloon"
```
Types: `sighting`, `person_movement`, `vehicle_movement`, `arrival`, `departure`, `contact`, `location_change`, `observation`, `incident`, `evidence_recovered`, `other`.

## Link an observation to an existing case record
```text
surveillance link ENTRY_REF evidence EVIDENCE_REF by PERSONNEL_REF because "Image capture supports the vehicle description"
```
Link types: `person`, `evidence`, `incident`, `task`, `lead`. The target must already belong to the same case.

## Close or cancel
```text
surveillance close OPERATION_REF by PERSONNEL_REF because "Deployment concluded"
surveillance cancel OPERATION_REF by PERSONNEL_REF because "Plan no longer required"
```

## Retrieve operations
```text
surveillance operations CASE_REF by PERSONNEL_REF
```

## Controls and records
- The planner and assigned team members must be active/seconded and assigned to the case or be its recorded lead.
- Team assignment is frozen once deployment begins.
- Only assigned team members may deploy, record observations or link records.
- At least one team member and exactly one designated team lead are required before deployment.
- Observation, team, link and event history is append-only.
- Actions use the explicit fictional clock but do not advance it.
- Commands use the game command idempotency ledger.
- The case review dossier includes a `surveillance_operations` section with team, observations, links and event history.
- Linked entities must already exist in the same case; observations do not create people, vehicles, incidents or evidence.

## Verification
All seven command patterns were tested through the parser. A rollback-only personnel-backed end-to-end test now creates two temporary officers, assigns them to a temporary case, initializes a temporary fictional clock, creates and staffs an operation, verifies deployment is blocked without a team lead, deploys with a designated lead, records and retrieves an observation, closes the operation and confirms fictional time did not advance. All fixtures and clock changes are rolled back; the live world remains unseeded and its clock remains uninitialized. Help registration, RLS, service-role access and dossier integration are also verified.
