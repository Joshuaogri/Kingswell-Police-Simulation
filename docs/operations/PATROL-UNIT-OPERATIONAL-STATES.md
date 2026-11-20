# Patrol unit operational states

**Implemented and verified:** 2026-11-20.

Each patrol unit now has a current operational state:
- `at_station`
- `on_patrol`
- `responding`
- `on_scene`
- `returning`
- `out_of_service`

Dispatch automatically sets `responding`; arrival sets `on_scene`; ending the last active deployment sets `returning`. If other active deployments remain, the state reflects whether any officer is on scene or still responding.

The service-role function `game.set_unit_operational_state(unit_ref, state, reason)` supports explicit transitions to `at_station`, `on_patrol`, `returning` and `out_of_service`. The database prevents a unit with active deployments from being marked at station, on patrol or out of service. Returning to station moves its current map position to the registered base-facility access point. Dispatch inserts/updates are rejected for units in `out_of_service`.

Every state change is appended to private RLS-enabled `game.unit_operational_state_history`, with game time, previous/new state, source, reason and deployment reference. The ledger is append-only for service_role.

This layer supplies authoritative unit state and guards; a natural-language player command for state changes and a dedicated patrol assignment/schedule workflow remain future integration work. No automatic fictional-time progression occurs.
