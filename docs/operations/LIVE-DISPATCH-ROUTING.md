# Live dispatch routing integration

**Status:** Database integration implemented on 2026-11-20. Structural, security and clock-guard checks pass. A seeded dispatch-to-route scenario remains pending because the live world intentionally has no police units, personnel, duty rosters, incidents or initialized fictional clock.

## Delivered

- Police units can retain a current map access point; this overrides the base facility when present.
- Each new incident deployment receives a route snapshot: calculation, origin/destination access points, status, distance, baseline duration, estimated arrival timestamp, basis and computation time.
- The deployment trigger resolves incident destinations only through the structured incident property link and its primary routable access point. Free-text location descriptions are never guessed into map coordinates.
- Unit origin uses its current access point, falling back to its base facility access point.
- Each initial route outcome is preserved in deployment_route_history, including unreachable and unresolved cases.
- game.get_dispatch_candidates(incident_ref) returns only active units with at least one active, employed officer on a live roster and duty assignment, excluding personnel already in a conflicting deployment. It returns personnel refs/count, facility, route and ETA.
- ETA uses posted road speeds only. It is not live traffic, siren uplift, turn-delay modelling or a guarantee of arrival. It does not advance the fictional clock.
- Unresolved locations and disconnected routes do not receive fabricated distances or ETAs.
- Route history is private, RLS-enabled and service-role only. The candidate function is invoker-rights and service-role executable only.

## Existing command preserved

The explicit dispatch UNIT_REF to INCIDENT_REF command remains unchanged. Its idempotency, active-unit, dispatchable-incident, active roster, duty-assignment, active-employment and conflicting-deployment checks remain authoritative. The new deployment trigger adds route snapshotting without bypassing those checks.

## Remaining

- Seed temporary personnel, unit, roster and incident fixtures in a rollback-only end-to-end test and verify route/ETA snapshots.
- Add an explicit unit-position update workflow and route-recalculation event for reassignment or road closures.
- Rank candidate units by ETA in the dispatch presentation while retaining dispatcher/player choice.
- Recalculate only on explicit operational events; no automatic rerouting or clock advancement is enabled.


## Source-control and index follow-up

The deployment route history and dispatch route foreign-key index migrations are tracked in database/migrations. Five additional indexes cover route calculation and access-point references in route history and deployment snapshots. The follow-up migration is 20261120114600_index_dispatch_route_foreign_keys.sql. The regression script now asserts those five indexes and the candidate function's post-clock missing-incident guard.


## Route-history integrity

The deployment route history ledger is append-only for the runtime role. service_role may read and insert history records but cannot update or delete them. This is enforced by migration 20261120114700_enforce_deployment_route_history_append_only.sql and asserted by the regression script.

## Seeded dispatch-to-route end-to-end verification — 2026-11-20

**PASS:** `database/tests/kingswell_dispatch_route_end_to_end.sql` executed successfully against live Supabase inside a transaction ending in ROLLBACK.

The test temporarily creates:
- one fictional person and active police personnel record;
- one active patrol unit attached to an existing police facility;
- one active roster and on-duty assignment;
- one new incident at a different existing property with a primary routable access point.

It then verifies:
- candidate selection returns the eligible patrol unit and its on-duty officer;
- candidate routing resolves the correct facility origin and incident access point;
- route status is calculated and distance/duration are populated;
- estimated arrival equals the fixed test game time plus the posted-speed route duration;
- the real `game.submit_command(..., 'dispatch_unit', ...)` path dispatches the officer;
- the deployment trigger stores a calculated route, endpoints, distance, duration and ETA;
- exactly one initial route-history record is written for the deployment;
- replaying the same idempotency key returns the same command ID and does not duplicate deployment;
- incident status and dispatch event are updated;
- fictional game time does not advance.

All temporary persons, personnel, units, rosters, assignments, incidents, deployments, command-ledger rows, route calculations and route-history records are rolled back. The test leaves no fixture data in the live game.

Source: `database/tests/kingswell_dispatch_route_end_to_end.sql`.


## ETA-ranked candidates and unit movement

Candidate query: `game.get_dispatch_candidates_ranked(INCIDENT_REF)`. It applies existing eligibility checks and sorts by ETA ascending, placing unresolved ETAs last.

Player-facing position command:

`position unit UNIT_REF at ACCESS_POINT_UUID because REASON`

The access point must be registered and connected to a routable road. The fictional clock must be initialized. A successful position update records the unit's location/time, emits a game event and recalculates routes for its active deployments.

Road availability is controlled by `game.road_segments.is_routable`. Any change to that flag automatically recalculates routes for all active deployments against the changed graph. Recalculation updates the current deployment snapshot and appends a permanent route-history event; the prior history is never overwritten.

Verification:
- `database/tests/kingswell_eta_ranked_dispatch_candidates.sql`
- `database/tests/kingswell_unit_position_and_road_recalculation.sql`

Both are rollback-only and passed on the live Supabase project. Neither test leaves fixture records or changes the live fictional clock.


## Player-facing dispatch options

Use:

`dispatch options for INCIDENT_REF`

The result shows the incident and ETA-ranked eligible units. Each unit includes available officer names, personnel references and service numbers, base facility, route status, route distance, estimated duration and estimated arrival. The options command does not dispatch anyone.

## Reassigning an active response

Use:

`reassign UNIT_REF to INCIDENT_REF because REASON`

The replacement must be a different active unit with eligible on-duty personnel. The current incident response must have one active unit only, and no responding officer may already be on scene. On success:
- prior deployment rows are retained and marked cancelled at the current fictional game time;
- outgoing and incoming reassignment events are recorded;
- a game event records the reason and unit change;
- new deployment rows are created for the replacement unit's eligible officers;
- deployment route snapshots and append-only route history are created for the replacement response.

Both commands use the normal parser and idempotent command ledger. No automatic time progression occurs.

Regression: `database/tests/kingswell_player_dispatch_options_and_reassignment.sql` passed on Supabase in a transaction ending in ROLLBACK. The live world remains unseeded.
