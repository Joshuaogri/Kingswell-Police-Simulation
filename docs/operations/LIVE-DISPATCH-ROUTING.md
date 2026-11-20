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
