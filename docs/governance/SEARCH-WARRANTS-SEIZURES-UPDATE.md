# Search warrants and seizure workflow — implementation update

**Status:** Implemented, deployed and verified on 2026-11-20.

## Delivered

- Fictional case-linked warrant records with issuing authority, scope, issue time, validity and execution state.
- Search operation planning linked to a warrant.
- Case-assigned search teams with a unique designated team leader.
- Existing Kingswell property register used to identify searched premises.
- Per-premises chronological search logs.
- Recovered-property records separated from seizure decisions.
- Seizure records linked to the original recovery and the existing shared evidence register.
- Evidence custody transfer through the existing `game.evidence_transfers` chain.
- Explicit searched/not-searched outcome for every registered premises before operation closure.
- Search records included in the consolidated case review dossier.
- Idempotent player commands, actor attribution, private-schema access controls and append-only operational history. All foreign keys introduced by the workflow have supporting indexes.

## Live migrations

- `20261120143344_case_search_warrants_and_seizure_workflow`
- `20261120143546_add_search_operation_retrieval_helper`
- `20261120143630_include_search_operations_in_case_dossier`
- `20261120143810_require_explicit_search_premises_outcomes`
- `20261120144314_index_search_workflow_foreign_keys`

## Player commands

- `warrant create`
- `search plan create`
- `search team add`
- `search premises add`
- `search execute`
- `search log`
- `search recover`
- `search seize`
- `search evidence transfer`
- `search premises status`
- `search close`
- `search operations`

Full command syntax: [CASE-SEARCH-WARRANTS-SEIZURES.md](../operations/CASE-SEARCH-WARRANTS-SEIZURES.md).

## Regression verification

The rollback-only test `database/tests/kingswell_search_warrants_seizures.sql` executes the actual player command interface using temporary assigned personnel, a temporary case and temporary fictional time. It verifies warrant issue and execution, team-lead enforcement, premises registration, logs, recovery, seizure, shared evidence custody transfer, explicit premises outcomes, close guards, retrieval, dossier integration, help registration, append-only log protection and unchanged fictional time. All temporary rows and clock changes are rolled back.

Live verification: the regression test passed. The test transaction left no fixtures. The persistent world remains unseeded and the fictional clock remains `NULL`.

## Database controls

All eight new tables are in the private `game` schema with RLS enabled. No `anon` or `authenticated` table access is granted; service-role access is used by the runtime. Search log, team, seizure and operation-event records are append-only. Seized items use the existing evidence item and transfer tables; no parallel custody chain was introduced.
