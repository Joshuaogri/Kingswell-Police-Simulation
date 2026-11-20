# Case account comparison and discrepancy analysis

Compare two existing accounts in the same case, record the precise discrepancy, associate existing evidence, and preserve each investigator's assessment over time. A comparison is an investigative observation, not a determination that either account is false.

## Record a comparison

Sources can be an existing `witness_statement` or `interview_turn`. Both must belong to the same case.

```text
case compare accounts CASE_REF first witness_statement STATEMENT_REF second interview_turn TURN_REF category location_conflict because "Describe the exact inconsistency and why it matters." by OFFICER_REF
```

Categories: `timeline_conflict`, `location_conflict`, `sequence_conflict`, `action_conflict`, `identity_conflict`, `description_conflict`, `other`.

## Assess the discrepancy

```text
case account comparison assess COMPARISON_REF as unresolved because "Explain what remains untested." by OFFICER_REF
```

Dispositions: `unresolved`, `explained`, `partially_explained`, `not_a_conflict`. Assessments are append-only; later assessments do not overwrite earlier reasoning.

## Link existing evidence

```text
case account comparison link evidence COMPARISON_REF EVIDENCE_REF because "Explain how this item may help test the discrepancy." by OFFICER_REF
```

Only an existing evidence item with no case restriction or belonging to this case can be linked. The link does not alter evidence custody, status or forensic findings.

## Retrieve comparisons

```text
case account comparisons CASE_REF
```

Retrieval includes both source accounts, discrepancy description, assessment history and linked evidence.

## Safeguards

- Case must be open; officer must be case lead or actively assigned.
- Both sources must resolve to the same case.
- All new records are append-only, RLS-enabled, private-schema and service-role-only.
- Commands use idempotency and actor attribution. They do not advance fictional time.
- No automatic credibility, deception, guilt or case outcome decisions are made.

## Verification

`database/tests/kingswell_case_account_comparisons.sql` is a rollback-only end-to-end test through the real parser and executor.
