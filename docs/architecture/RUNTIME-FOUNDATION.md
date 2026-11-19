# Runtime foundation

**Status:** Initial database-backed runtime foundation implemented and smoke-tested. This is not yet a complete playable simulation.

## Responsibilities

- ChatGPT is the player-facing text interface.
- Supabase's private `game` schema is authoritative for persisted game state.
- GitHub `main` holds the blueprint, migrations, implementation source and tests.
- All Kingswell content is fictional game-world data.

## Command intake

`game.game_commands` preserves the original command text, command type, JSON payload, optional session and fictional officer identity, idempotency key, result, rejection reason and timestamps. `game.submit_command(...)` is the initial controlled command entry point.

Registered foundation commands:
- `help` — returns currently registered command types.
- `status` — returns the authoritative clock configuration state.
- `initialize_clock` — accepts an explicit `start_at` timestamp once. No fictional start date is assumed by the software.
- `advance_time` — advances by an explicit whole-minute request from 1 to 1,440 minutes.

Unregistered command types are recorded as rejected. Re-delivery with the same idempotency key and payload returns the original result; reusing a key for a different payload is rejected as a conflict.

This is a typed command boundary, not yet a natural-language parser or police-domain command catalogue. Domain commands will call their owning division's rules rather than placing domain logic in the runtime engine.

## Clock and event history

The singleton `game.simulation_state` row is created paused, with its fictional time unset. The calendar/start date remains unconfigured until explicitly selected. An unconfigured clock cannot be advanced.

Manual time advancement is an explicit player action. The paused flag prevents autonomous progression; it does not block a deliberate `advance_time` command. Clock initialization and each advancement create a `game_clock_history` record and a linked `game_events` event in the same database transaction.

The engine does not use real-world elapsed time to move the fictional clock. Leaving ChatGPT does not advance game time.

## Current boundaries

- The command function is in the private schema and is not exposed through the public Data API.
- No public Edge Function has been deployed. Project authentication and the player/session identity mapping are not yet implemented, so exposing a privileged command endpoint now would be premature.
- The optional `actor_personnel_id` is a fictional police-personnel reference, not the user's ChatGPT identity.
- Domain authority, rank/position rules, dispatch, incidents, cases, NPC scheduling and event handlers remain to be implemented by their owning divisions.
- A future natural-language parser must map requests to typed commands; it must never treat a question as an action or claim success before the database confirms the result.

## Verification

The regression script in `database/tests/runtime_foundation.sql` exercises status, uninitialized-clock rejection, explicit clock initialization, idempotent retry, idempotency conflict, time advancement, range rejection, clock history and event creation inside a transaction that rolls back.


## Validation hardening

The command entry function validates minute values as integers before casting. Fractional and out-of-range values are returned as rejected commands and retained in the command ledger. This is applied by `database/migrations/20261120020000_harden_runtime_command_validation.sql`.
