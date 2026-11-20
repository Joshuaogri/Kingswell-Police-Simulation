# Kingswell Master Geographic Map

**Status:** Approved country setting (Asterfell); Kingswell geographic layout and district envelopes remain planning-level map data.  
**Use:** Canonical design reference for the city geography and road-network build.  
**Fiction:** Kingswell and all mapped places are entirely fictional. This is an authored vector schematic, not an image-generation output and not a real-world map.

## Map conventions

- City footprint: 20 km east–west by 16 km north–south, represented on a local metric grid (x=0–20,000 m; y=0–16,000 m).
- North is at the top; east is right.
- Districts are contiguous planning zones. Their initial extents are rectangular planning envelopes, not surveyed cadastral boundaries.
- The city is coastal on its southern edge. A navigable river enters from the north-east and reaches the harbour basin in the south-east.
- Primary roads connect every district to the central ring and at least one external gateway.
- All map coordinates are fictional local coordinates. They are not latitude/longitude.
- Population baseline remains the BP-02 figure of 100,000 permanent residents. No district population allocations are asserted yet.

## City structure

| Code | District | Primary function | Approximate map area (x min–max km; y min–max km) |
|---|---|---|---|
| KDW | Westhaven | Established residential and mixed use | 0–5; 7–13 |
| KNA | Northgate | Northern residential and neighbourhood services | 5–10; 11–16 |
| KCI | Civic Quarter | Government, courts and civic administration | 7–12; 7–11 |
| KCB | Central Exchange | Central business, finance and commerce | 10–15; 7–12 |
| KED | University Heights | Education, health and institutions | 2–7; 12–16 |
| KST | Kingswell Central Terminal | Passenger rail, bus and interchange | 8–12; 4–7 |
| KMA | Market Ward | General commercial and wholesale trading | 12–17; 5–9 |
| KIN | Foundry Park | Industrial and manufacturing | 14–20; 9–14 |
| KLG | East Logistics | Freight, distribution and warehousing | 15–20; 5–9 |
| KPT | South Harbour | Port, maritime and port-support activity | 12–20; 0–5 |
| KAS | Aerodrome | Airport and aviation support | 0–6; 0–5 |
| KMX | Riverside | Mixed-use riverfront and residential | 5–12; 0–5 |

The twelve district names and envelopes are the proposed first map layout. They can be refined as the detailed street grid is developed; stable district codes should be retained if names change.

## Major road hierarchy

### Primary orbital and radial roads
- Kingswell Outer Ring Road (KORR): perimeter distributor linking the principal gateways and district approaches.
- Inner Civic Loop (ICL): central loop around Civic Quarter and Central Exchange.
- Northgate Avenue: northern gateway through Northgate to Civic Quarter.
- University Road: western institutional corridor to the civic core.
- Foundry Boulevard: eastern industrial corridor connecting Foundry Park, East Logistics and South Harbour.
- Harbour Parkway: southern waterfront distributor linking Aerodrome, Riverside, Market Ward and South Harbour.
- Terminal Way: passenger terminal and central interchange approach.
- Airport Expressway: dedicated airport connection to the western and central network.
- Port Access Road: controlled freight route between East Logistics and South Harbour.

### Secondary and local streets
Each of the 24 neighbourhoods now has a named local street loop, four local intersections and a collector tie into the arterial graph. Local streets are represented as explicit routable segments, not drawn-only map decoration. The live network contains 51 named roads, 118 junctions and 151 segments. Road names are unique within the city; road segments, not names alone, define connectivity.

### River crossings
Three explicit bridge crossings are recorded as bridge segments with separate west/east bank junctions and approach links: East River Bridge North, Riverside Bridge and Harbour River Bridge. Their bank coordinates span x=16,400 m to x=17,400 m, crossing the mapped eastern river corridor. Each bridge is represented as a distinct 1,000 m bridge segment with connected approaches. Bridge segments are tagged `crossing_type=bridge`; their approaches remain distinct connected road segments. No false at-grade junction is created at the river crossing.

## Neighbourhood framework

Each district is subdivided into two neighbourhoods (24 total). Every neighbourhood has a dedicated named local street and a connected five-segment access pattern in the road graph. Each neighbourhood now contains 20 seeded property parcels, each with one building, a structured postal address and a road-linked access point. The initial city inventory therefore contains 480 properties, 480 buildings, 712 building units and 480 property entrances. Twenty-four named landmarks are linked to their actual property, building and access-point records.

## Network modelling rules

1. A road is a named route; a road segment is a routable piece between two junctions.
2. Junctions have stable IDs and local x/y coordinates.
3. Every segment has a start and end junction, parent road, length, directionality, road class, lane count, speed limit and access profile.
4. Intersections are explicit junction records. Grade-separated crossings must not create false at-grade connections.
5. Bridges and tunnels are explicit segment attributes.
6. Roads must form a connected graph, except for deliberately restricted or isolated facilities.
7. Addresses attach to properties, properties attach to neighbourhoods and districts, and properties may reference a road.
8. Patrol sectors and response-time calculations will be layered on top of this network; they are not district boundaries.
9. The local grid is the source of truth for the initial fictional map. Latitude/longitude can be added later if a gameplay feature requires it.

## Build sequence

1. Establish country, region and city records.
2. Establish the twelve district records and neighbourhood hierarchy.
3. Establish the city planning envelopes and named primary roads.
4. Create junctions and road segments with connectivity tests.
5. Add secondary/local roads and transport links.
6. Add properties, buildings, addresses and landmarks — implemented and regression-tested.
7. Add police facilities, district patrol sectors and neighbourhood beats — implemented and regression-tested.\n8. Implement weighted road-network routing — implemented and regression-tested.
9. Integrate routing with live dispatch and calculate operational response-time estimates.

## Police facilities and patrol geography

The police operational geography is now seeded against the existing property and road network. The city has 18 linked police facilities: headquarters, one district police station in each of the 12 districts, and five specialist/support sites (central custody, operations and communications, forensic services, training, and fleet/workshop). Each facility is attached to an actual property, building, structured postal address and primary road access point.

The operational patrol hierarchy is distinct from the administrative district boundaries:
- 12 district patrol sectors, one per district.
- 24 neighbourhood beats, one per neighbourhood, each attached to its district sector.
- All 151 currently routable road segments are attributed to a beat for geographic coverage. This association is a coverage index, not a turn-by-turn route or ordered patrol path.
- Police unit records can reference a base facility and assigned beat when units are later created.

The facility and beat coordinates inherit the current fictional local-metre planning grid and should not be treated as surveyed locations. A weighted Dijkstra route engine now calculates fastest and shortest paths between property access points, including police facility access points. It stores ordered road-segment legs and estimates baseline travel duration from posted speed limits. Public routes cannot use controlled access points or restricted freight/emergency segments; police/emergency routes may use the two public_emergency_freight segments. One-way directionality and non-routable segments are respected. Regression: database/tests/kingswell_weighted_road_routing.sql.

This is a baseline route engine, not live traffic or calibrated response-time simulation. Dispatch integration, incident-to-unit auto-routing, turn penalties, congestion, road closures, emergency driving profiles and patrol route optimisation remain future work. Regression: `database/tests/kingswell_police_facilities_patrol_geography.sql`.

## Explicitly not yet represented

Exact surveyed cadastral polygons, precise architectural building footprints and heights, secondary and service entrances for every building, detailed turn restrictions, live traffic simulation and calibrated travel times remain later layers. The routing engine currently respects segment directionality, but the seeded network presently has all 151 segments marked two-way. The current property and building coordinates are deterministic fictional planning points tied to the connected road network, not survey-grade geometry.


## Property, building, address and landmark foundation

The initial city inventory is seeded across all 24 neighbourhoods, with 20 parcels per neighbourhood (40 per district): 480 property records and 480 associated buildings. Property records carry district/neighbourhood ownership, street and road references, fictional local-grid coordinates, parcel area, frontage width, land-use classification, frontage road segment and postal code. Buildings carry their own local-grid position, footprint dimensions/area, building type, floor count, construction type and occupancy state. The current building-unit register contains 712 units/premises.

Every property has one structured primary postal address (480 total) and one primary access point (480 total). Access points resolve to an actual routable road segment and junction, providing a usable destination layer for future dispatch and navigation. The address format is: street number, named local street, neighbourhood, district, Kingswell, Asterfell and neighbourhood postal code. Twenty-four named landmarks—one per neighbourhood—resolve to their property, building and access point, rather than existing as unlinked map labels.

These are fictional planning records, not real-world addresses or surveyed property boundaries. The initial inventory is intentionally comprehensive enough to support address lookup, incident location, business/institution placement and future population occupancy; detailed cadastral shapes, building floor plans, multiple entrances and dynamic occupancy are later refinements. Regression: `database/tests/kingswell_properties_buildings_addresses.sql`.
