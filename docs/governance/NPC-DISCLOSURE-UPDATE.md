## NPC disclosure and defence materials — 2026-11-20

**Implemented, deployed, regression-tested and synced to GitHub main.**

Migrations:
- `20261120152522_disclosure_packages_and_defence_materials.sql`
- `20261120152636_harden_disclosure_receipt_and_case_access.sql`
- `20261120152706_register_disclosure_commands_in_game_help.sql`
- `20261120152754_route_disclosure_commands_through_text_runtime.sql`
- `20261120152854_include_disclosure_history_in_case_dossier.sql`
- `20261120153046_scope_disclosure_retrieval_to_case_prosecutor.sql`

Six private, RLS-enabled tables record NPC defence counsel profiles/assignments, prosecution and defence packages, package items, immutable disclosure events and service receipts. Prosecution disclosure requires an accepted referral and filed charge. Defence disclosure requires assigned NPC counsel. Evidence items must belong to the same case. Items can be disclosed, redacted or withheld with reasons. Packages are served to the opposite NPC side and acknowledged only by the intended recipient.

Commands are registered in the text runtime and help. The case dossier now includes disclosure history. All actions use the idempotency ledger and current fictional time without advancing it.

**PASS:** rollback-only test `database/tests/kingswell_disclosure_workflow.sql` covers both directions, item classification, service, acknowledgement, package retrieval, dossier integration and unchanged clock. All test fixtures roll back.
