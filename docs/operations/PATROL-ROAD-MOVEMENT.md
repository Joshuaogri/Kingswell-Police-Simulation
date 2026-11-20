# Patrol road movement and geographic coverage

Patrol units can move to registered access points on their assigned beat using the actual Kingswell road graph.

## Player command

`patrol move UNIT_REF to ACCESS_REF because REASON`

The destination is a registered primary property access-point reference. It must lie on a road segment assigned to the unit's active patrol beat. The unit must be active, on patrol and have an active patrol schedule.

The runtime calculates the fastest police route from the unit's current access point using the existing weighted road-routing engine. It records one immutable movement event for every route leg, including the road segment, junction pair, route order, distance, estimated duration and fictional departure/arrival times. It updates the unit's current access point and location timestamp.

The movement command explicitly consumes the calculated route duration from the fictional game clock. The command ledger and game-clock history record the action. No real-world clock or automatic background progression is used. The movement is rejected if it would exceed the active patrol schedule.

A patrol may travel from its station to its assigned beat. Every route leg is recorded, and each leg is marked `within_assigned_beat` according to the beat's road-segment register. Transit outside the beat is not counted as beat patrol coverage. The destination itself must be on the assigned beat.

## Coverage report

`patrol status` now includes per-beat visited road-segment count, patrol distance and latest recorded movement, plus citywide totals. Only route legs marked within the assigned beat contribute to patrol coverage totals.

The event table `game.patrol_movement_events` is append-only for the runtime service role. It links to canonical route calculations and route legs; no road segment or travel duration is invented.

## Regression

`database/tests/kingswell_patrol_road_movement.sql` creates a temporary patrol unit, roster and schedule, starts patrol, issues the movement through the text command dispatcher, verifies per-leg records, position update, clock advancement, beat coverage and help registration, then rolls back all fixtures.
