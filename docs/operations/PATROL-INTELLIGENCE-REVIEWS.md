# Patrol intelligence review history

## Purpose

An officer can record a structured assessment of an existing patrol-intelligence link without changing the original observation/contact or the incident/case. Each assessment is a separate immutable history entry; later assessments do not overwrite earlier ones.

## Dispositions

- `relevant` — the linked patrol record is considered relevant to the target for the reason recorded.
- `further_enquiries` — additional enquiries are considered appropriate.
- `insufficient_information` — the available material is insufficient to assess the link.
- `not_relevant` — the reviewer does not consider the linked record relevant to the target.

A disposition is an officer's recorded assessment, not a finding that the source report is true, corroborated, or proof of wrongdoing.

## Database interface

- `game.record_patrol_intelligence_review(command_id, link_ref, disposition, note, actor_personnel_id)` records a review.
- `game.get_patrol_intelligence_reviews(reference, limit)` retrieves review history by review, link, source-record, or target reference. A null reference retrieves the latest review history.
- Notes are required and limited to 3,000 characters. Results are limited to 1–500.
- The fictional clock must be initialized; the reviewing officer must be active.
- Every entry records the officer, originating command and fictional review time, and emits a permanent game event.
- Review rows are append-only and protected by RLS in the private `game` schema. Functions are executable only by `service_role`.
- Recording and retrieving reviews do not advance fictional time.

## Current integration boundary

This is the database review/history layer. It is not yet registered as a player-facing natural-language command in `game.execute_text_command`. That parser/dispatcher integration and full fixture-based end-to-end command test are the next implementation step.

Regression smoke test: `database/tests/kingswell_patrol_intelligence_reviews.sql`.
