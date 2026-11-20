# Kingswell Population and Individual-Life Model

**Division:** BP-03  
**Status:** Individual-life foundation implemented and regression-tested; full population seeding waits for BP-04 residential capacity and BP-35 runtime scheduling.  
**Fiction:** Every person and event in this model is fictional. The user is the only player; all other people are NPCs.

## Canonical person identity

The existing `game.persons` table remains the sole person identity store. Every person receives one stable unique `person_ref`. Police personnel, organisational personnel, case parties, incident parties, callers, witnesses, victims and suspects all reference that same person row. No parallel civilian/NPC/resident identity table is permitted.

The existing person record was extended with birth city/region, date of death, preferred language, personality and behaviour JSON profiles, simulation detail level and promotion metadata. Age is calculated from date of birth against fictional game time. It is unresolved for living people while the game clock is uninitialised; deceased people can be aged at their recorded death date.

## Existing records extended, not duplicated

- `persons`: canonical identity.
- `person_addresses`: existing address history; now supports one current primary address and one current address per role. `valid_from` must be explicitly supplied and no longer defaults to the real database date.
- `person_relationships`: existing relationship history; date ordering and duplicate current directed relationships are constrained.
- `organisation_personnel`: existing organisation employment links; valid employment dates are checked.
- `police_personnel`: remains linked one-to-one to the same canonical person record.
- `game_events` and `game_commands`: remain the shared game-wide event and command infrastructure.

## New BP-03 records

| Table | Purpose |
|---|---|
| `households` | Social/domestic household identity and optional primary property |
| `household_memberships` | Dated household membership, role and one current primary household per person |
| `person_population_memberships` | Dated, overlapping resident/visitor/worker/student/commuter categories, optionally linked to a city |
| `person_life_events` | Append-only birth, education, employment, address, relationship, migration, retirement and death history |
| `person_routines` | Recurring weekly routines, activity type, time window, overnight flag and existing property references |
| `person_activity_events` | Append-only actual activity history with game-time and origin/destination |
| `person_simulation_promotions` | Append-only record of increasing person simulation detail |

A household is not an address. A person may change address without changing family relationships. Multiple households may share a property. Population memberships overlap by design; population summaries count distinct people rather than summing category totals.

## Simulation intensity

Each person has one of four levels:

1. `background` — persistent identity and baseline profile
2. `active` — currently active in a routine or recorded activity
3. `police_relevant` — relevant to current police activity or an enquiry
4. `full` — detailed individual simulation and history

Promotions are monotonic; a person cannot be downgraded. Case links, incident-party links, dispatch caller links and current residence at an incident property automatically promote the person to full simulation. The reason and source entity are retained in promotion history.

## Time and routine rules

Routines are schedules, not automatic time progression. They are executed only by the simulation runtime when fictional time is explicitly advanced. No activity is processed while the game is paused or the player is away. Actual activity events are rejected until the fictional clock is initialised and cannot end after current fictional time. BP-03 does not initialise or advance the clock.

## Population summary

`game.get_population_summary(city_code)` returns unique people and distinct current membership counts for major population categories, plus current households with at least one living current member. A person belonging to several categories contributes once to the unique-person total and once to each applicable category count.

A death life event:
- sets the canonical person status to deceased and records the date of death;
- closes current addresses, household memberships, population memberships and organisational employment;
- ends active routines;
- preserves life-event, relationship and activity history.

Deceased people are excluded from current population and current-household counts.

## Residential-capacity dependency

Kingswell's current BP-04 inventory contains 80 residential properties, 64 detached houses, 16 apartment blocks, 128 units explicitly marked residential and 160 mixed-use units. That is not a credible housing base for 100,000 permanent residents at ordinary household densities.

BP-03 must not fabricate homes or pack implausible numbers of households into the existing inventory. The person/household/life/routine architecture can be built and tested independently, but the full 100,000-person seed and household/address allocation wait until BP-04 expands the existing property/building/unit system. No duplicate buildings, properties, units or addresses may be created under BP-03.

## Applied migrations

- `20261120162714_bp03_persistent_population_households_routines_and_life`
- `20261120162748_bp03_population_summary_and_person_provenance_hardening`
- `20261120162835_bp03_population_summary_requires_current_household_members`
- `20261120163022_bp03_end_current_memberships_on_person_death`

## Regression

`database/tests/kingswell_population_life_foundation.sql` runs in a transaction and rolls back. It verifies:
- canonical person identity and age behaviour with an uninitialised clock;
- primary address and household constraints;
- overlapping population memberships and distinct population counts;
- relationship history and weekly/overnight routines;
- birth/death life events and automatic closure of current memberships on death;
- append-only life and promotion history;
- monotonic simulation promotion and automatic full-detail promotion from case, incident, dispatch-caller and incident-location links;
- rejection of activity history before clock initialisation;
- private schema/RLS protection and no fictional clock initialisation.

The test leaves no persistent persons, households, memberships, routines, life events, activity events or promotion records.
