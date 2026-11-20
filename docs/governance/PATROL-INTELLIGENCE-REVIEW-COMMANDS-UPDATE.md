# Kingswell implementation update — patrol intelligence review commands

**Date:** 2026-11-20  
**Branch:** `main`

## Delivered

The patrol intelligence review-history layer is now integrated with the player-facing text command path.

### Commands

- `review patrol intelligence LINK_REF disposition relevant because REASON`
- Supported dispositions: `relevant`, `further_enquiries`, `insufficient_information`, `not_relevant`.
- `patrol intelligence reviews`
- `patrol intelligence reviews for REFERENCE`

### Runtime behaviour

- Both commands are parsed by `game.interpret_text_command` and executed by `game.execute_text_command`.
- Review submission uses the existing `game.game_commands` ledger and idempotency-key conflict/replay behaviour.
- A review requires an active officer attribution and an initialized fictional clock.
- A review is a separate immutable record and emits a game event. It never changes the linked patrol record or incident/case.
- Review lookup is read-only and does not advance fictional time.
- Both commands appear in the player `help` response.
- Command parser and executor remain service_role-only.

### Regression

`database/tests/kingswell_patrol_intelligence_review_commands.sql` verifies parser payloads, both player commands, missing-officer rejection, idempotent replay, help registration and no persistent review rows. The test runs in a transaction ending in ROLLBACK.

### Files

- Migration: `database/migrations/20261120135000_patrol_intelligence_review_player_commands.sql`
- Test: `database/tests/kingswell_patrol_intelligence_review_commands.sql`
- Command guide: `docs/operations/PATROL-COMMAND-INTERFACE.md`
- Review guide: `docs/operations/PATROL-INTELLIGENCE-REVIEWS.md`

The live Supabase database was queried after deployment; the fictional clock remains uninitialized and the review table contains no persistent review fixtures.
