# Patrol intelligence and coverage-gap reporting

## Player command

`patrol intelligence`

Aliases: `patrol gaps`, `patrol analysis`.

The report assesses every active patrol beat against the beat's registered road-segment inventory. It includes:
- Distinct road segments visited and total registered segments.
- Percentage of the beat's registered road segments visited during the reporting window.
- Number of recorded movement legs, distance and movement minutes.
- Distinct fictional patrol days represented in the movement records.
- Last recorded patrol movement and elapsed fictional hours since that movement.
- Beat classification: never visited in the window, partially visited, or all registered segments visited.
- Least-visited road segments, including traversal count and last traversal.
- Unit-level recorded movement, distinct segments, distance, movement minutes and last movement.
- Citywide counts for never-visited, partially visited and fully visited beats.

## Reporting windows and interpretation

The database function `game.get_patrol_intelligence(p_since,p_until)` accepts optional fictional timestamps. With no arguments it reports all recorded movement history up to the current fictional game time. A supplied window cannot extend into the future or have an end before its start.

Movement minutes are calculated from recorded road-leg durations **inside assigned beats**. This is measured road-movement time, not total time physically present in a neighbourhood. Stationary observation, foot patrol, interviews, breaks and other non-road activity are not counted until separately recorded in future activity systems. The report measures recorded coverage, not the quality or effectiveness of policing, and a road not traversed in the reporting window is not automatically a risk hotspot.

## Verification

`database/tests/kingswell_patrol_intelligence.sql` starts a temporary patrol, records a real routed movement through the command interface, checks beat/road/time/unit statistics and command help registration, then rolls back all fixtures.
