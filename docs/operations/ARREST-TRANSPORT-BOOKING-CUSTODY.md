# Arrest, suspect transport, booking and custody

Kingswell's fictional arrest and custody workflow connects the existing case and person register to a chronological police arrest record, transport, booking, custody inventory, welfare checks, custody events and final release/transfer.

## Execute an arrest

```text
arrest execute CASE_REF person PERSON_REF by PERSONNEL_REF basis grounds location "Market Street" grounds "Recorded grounds and case basis" force "none" injuries "none" warnings "Caution/warnings delivered and recorded"
```

Optional fields may follow the required fields:
- `authority "Warrant or authority reference"` (required when basis is `warrant`)
- `witnesses "Witness details"`
- `body_camera "BWC reference"`
- `incident INCIDENT_REF`

Basis values: `warrant`, `grounds`, `other`. The person must already exist and be linked to the open case as `suspect` or `person_of_interest`. The arresting officer must be the case lead or actively assigned to the case. The record captures arrest time, location, basis, grounds, force used, injury/complaint information, warnings/rights record, witnesses and body-camera reference. This is an arrest execution record, not a finding of guilt.

## Transport to custody

```text
arrest transport ARREST_REF by PERSONNEL_REF to "Kingswell Custody Suite" vehicle "Marked police vehicle KW-12" handover "Transport completed; detainee condition recorded" duration 12 minutes
```

Duration is mandatory (1–240 minutes). The transport leg records departure and arrival times and advances the fictional clock by the explicit duration, adding a clock-history entry. Transport requires an existing arrest that has not already been transported.

## Book into custody

```text
custody book ARREST_REF by PERSONNEL_REF identity "Identity check completed" risk "Initial risk assessment" health "Health and welfare screening" cell "Cell A-03" medication "Medication disclosure" safeguarding "Safeguarding notes"
```

Identity check, risk assessment, health/welfare screening and cell allocation are required. Medication and safeguarding details are optional. Booking can occur only after a transport record has been completed. One custody episode is created per arrest.

## Record detainee property

```text
custody property CUSTODY_REF by PERSONNEL_REF item "Wallet and keys" condition "Intact" disposition stored storage "Property Locker 04"
```

Disposition values: `stored`, `retained_as_evidence`, `returned`, `transferred`. For `retained_as_evidence`, the system creates an item in the existing case evidence register and returns its evidence ID. It does not create a parallel evidence register.

## Welfare checks and custody events

```text
custody check CUSTODY_REF by PERSONNEL_REF type welfare observation "Detainee responsive; no immediate concern" escalation "None"
custody event CUSTODY_REF by PERSONNEL_REF type meal details "Meal offered and accepted"
```

Check types: `welfare`, `health`, `risk`, `observation`.

Event types: `risk_review`, `health_review`, `medication_disclosure`, `cell_change`, `meal`, `rest_period`, `interview_access`, `legal_counsel`, `visitor`, `use_of_force`, `incident`, `supervisor_review`, `handover`, `other`.

These entries are attributable and append-only. The game records the stated screening and observations; it does not invent clinical diagnoses or automatically decide medical care.

## Release or transfer

```text
custody release CUSTODY_REF by PERSONNEL_REF outcome released because "Release decision and reason recorded"
custody transfer CUSTODY_REF by PERSONNEL_REF to "Receiving custody facility" because "Transfer reason and receiving destination recorded"
```

A custody episode can have one final transition from `in_custody` to `released` or `transferred`. The linked arrest status is updated and both custody and arrest event histories record the outcome.

## Retrieve arrest and custody history

```text
case arrests CASE_REF by PERSONNEL_REF
case review CASE_REF by PERSONNEL_REF
```

The case arrest retrieval and consolidated dossier show arrest details, officer, transport legs, booking, property inventory, welfare checks, custody events and final outcome.

## Controls and simulation time

- Private `game` schema; RLS enabled; no `anon` or `authenticated` table access; service-role runtime only.
- All player commands use the idempotent command ledger and active personnel attribution.
- Arrest event, transport, property, custody event and welfare-check histories are append-only.
- The main arrest/custody state records only the current state; consequential transitions are retained in their event histories.
- The clock advances only for an explicitly entered transport duration. Other record-writing and retrieval commands use the current fictional time without advancing it.
- All actions are fictional game records; arrest is not conviction, and booking is not a charging or court decision.

## Verification

A rollback-only end-to-end test uses two temporary assigned officers, one temporary suspect, a temporary case and a temporary clock. It verifies arrest execution and idempotent replay, transport duration and clock history, booking, property inventory, evidence-register integration, welfare checks, custody events, case retrieval, dossier integration, release, append-only protection, help registration and no additional time advancement. All temporary records and clock changes are rolled back.
