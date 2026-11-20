# Patrol intelligence review history

An officer can record a structured assessment of an existing patrol-intelligence link without changing the original observation/contact or the incident/case. Each assessment is a separate immutable history entry.

## Player commands

- `review patrol intelligence LINK_REF disposition relevant because REASON`
- Dispositions: `relevant`, `further_enquiries`, `insufficient_information`, `not_relevant`.
- `patrol intelligence reviews` retrieves the latest review history.
- `patrol intelligence reviews for REFERENCE` retrieves history by review, link, source-record or target reference.

The commands run through `game.execute_text_command`, use the command ledger and idempotency keys, and are registered in `help`. Review submission requires an active officer attribution and an initialized fictional clock. Review lookup is read-only and does not advance fictional time.

A disposition is an officer's assessment, not a finding that the source report is true, corroborated, or proof of wrongdoing. Reviews are append-only and preserve officer, originating command, reason, fictional timestamp and game-event history.

## Database interface

- `game.record_patrol_intelligence_review(command_id, link_ref, disposition, note, actor_personnel_id)`
- `game.get_patrol_intelligence_reviews(reference, limit)`

Notes are required and limited to 3,000 characters. Results are limited to 1–500. The private `game` schema is RLS-enabled; functions are restricted to `service_role`.

Regression: `database/tests/kingswell_patrol_intelligence_reviews.sql` and `database/tests/kingswell_patrol_intelligence_review_commands.sql`.
