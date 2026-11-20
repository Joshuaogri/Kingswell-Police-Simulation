# Patrol unit arrival and location history

**Status:** Implemented and rollback-only integration-tested on 2026-11-20.

When an individual officer's deployment changes from a non-arrived state to a recorded arrival, the database now synchronizes the associated patrol unit's current access point to the incident's registered primary routable property access point.

The same transaction appends a row to `game.unit_location_history` with:
- patrol unit and exact access point;
- fictional game timestamp;
- source (`arrival`);
- deployment and arriving officer references;
- reason and contextual details.

The history table is private, RLS-enabled and append-only for the runtime role. service_role has SELECT and INSERT only; UPDATE and DELETE are revoked.

If the unit has other active deployments whose officers have not arrived, those deployment routes are recalculated from the unit's newly recorded position and new route-history entries are appended. The just-arrived deployment is excluded. The trigger rejects an arrival if the fictional clock is unset, if the arrival timestamp differs from the current fictional time, or if the incident has no registered routable property access point.

No automatic time advancement is performed. No personnel, units, incidents or deployments are persistently seeded.

Regression: `database/tests/kingswell_unit_arrival_position_sync.sql`. The test temporarily sets a fictional clock, creates a unit/incident/deployment against an existing map property, records arrival, verifies current unit position and exactly one history row, verifies unchanged fictional time, then rolls back the entire transaction.
