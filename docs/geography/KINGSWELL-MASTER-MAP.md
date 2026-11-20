# Kingswell Master Geographic Map

**Status:** BP-02 geographic design baseline completed; national regions and Kingswell's city grid are recorded. City district extents remain planning-level envelopes, not surveyed cadastral boundaries.  
**Use:** Canonical design reference for the city geography and road-network build.  
**Fiction:** Kingswell and all mapped places are entirely fictional. This is an authored vector schematic, not an image-generation output and not a real-world map.

## Country and national administrative geography

Asterfell is a wholly fictional sovereign country. Its national geography is represented at regional-reference level; Kingswell is the only city with a detailed street, property-access and routable-road map.

| Order | Code | Administrative region | Relative geography and character |
|---:|---|---|---|
| 1 | CAP | Kingswell Capital Region | South-central coast; contains Kingswell and the harbour near the eastern river mouth |
| 2 | NTH | Northreach Region | Northern uplands, highland settlements and upper headwater country |
| 3 | WST | Westmere Region | Western lake districts, agricultural plains and market towns |
| 4 | CTR | Highplain Region | Central plateau, inland farming basins and the principal east-west overland corridor |
| 5 | EST | Eastmarch Region | Eastern river basin, borderland crossings and regional transport corridors |
| 6 | IRV | Ironvale Region | North-eastern uplands, mineral workings and industrial towns |
| 7 | SCO | South Coast Region | Southern coastal arc west of the capital region, with fishing towns and maritime settlements |
| 8 | OIS | Outer Isles Region | Offshore island groups, smaller ports and maritime communities beyond the southern and eastern coast |

The regional descriptions establish national orientation and jurisdictional context, not surveyed region boundaries. Other regions do not receive a second, duplicate city-road database or detailed routable street networks in this division. Additional cities and their local geography may be introduced later when a gameplay requirement calls for them.

## Map conventions

- Kingswell city footprint: 20 km east–west by 16 km north–south, represented on a local metric grid (x=0–20,000 m; y=0–16,000 m).
- Coordinates are integer metres, with north at the top and east to the right. They are fictional local-grid coordinates, not latitude/longitude.
- The city is coastal on its southern edge. A navigable river enters from the north-east and reaches the harbour basin in the south-east.
- The city property-map layer is version KNG-MAP-0.2. Its underlying coordinate system remains KNG-MAP-0.1 on the same local metre grid used by district envelopes, road junctions, landmarks, properties, buildings, parcel outlines and access points.
- District map records are rectangular planning envelopes. They may overlap and must not be treated as exact exclusive polygons. Administrative membership is record-based: canonical district/neighbourhood references on properties and other relevant location records are authoritative. No system may infer or change jurisdiction from a planning envelope alone.
- Primary roads connect the districts to the central network and the principal city gateways.
- The city begins with the BP-02 baseline of 100,000 permanent residents and has no fixed population ceiling. Population growth, decline, movement and district population distribution belong to BP-03, not the geography layer.

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

The twelve district names, codes and planning envelopes are the canonical initial Kingswell geography. Codes are stable identifiers; a later name refinement must preserve the code and record the change rather than create a duplicate district.

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

Each district is subdivided into two neighbourhoods (24 total). Every neighbourhood has a dedicated named local street and a connected five-segment access pattern in the road graph. The BP-02 baseline seeded 20 parcels in each neighbourhood (480 total). BP-04 preserves that baseline and adds 96 residential towers and 80 multi-tenant commercial centres. The current layer contains 656 properties, 656 buildings, 26,888 building units, 656 structured postal addresses and 656 road-linked primary access points. Twenty-four named geographic landmarks remain linked to their existing property, building and access-point records. BP-02 references these records; it does not create a second property, building, unit, address or entrance system.

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
9. Integrate routing with live dispatch and retain route/ETA snapshots — implemented and regression-tested.

## Police facilities and patrol geography

The police operational geography is now seeded against the existing property and road network. The city has 18 linked police facilities: headquarters, one district police station in each of the 12 districts, and five specialist/support sites (central custody, operations and communications, forensic services, training, and fleet/workshop). Each facility is attached to an actual property, building, structured postal address and primary road access point.

The operational patrol hierarchy is distinct from the administrative district boundaries:
- 12 district patrol sectors, one per district.
- 24 neighbourhood beats, one per neighbourhood, each attached to its district sector.
- All 151 currently routable road segments are attributed to a beat for geographic coverage. This association is a coverage index, not a turn-by-turn route or ordered patrol path.
- Police unit records can reference a base facility and assigned beat when units are later created.

The facility and beat coordinates inherit the current fictional local-metre planning grid and should not be treated as surveyed locations. A weighted Dijkstra route engine now calculates fastest and shortest paths between property access points, including police facility access points. It stores ordered road-segment legs and estimates baseline travel duration from posted speed limits. Public routes cannot use controlled access points or restricted freight/emergency segments; police/emergency routes may use the two public_emergency_freight segments. One-way directionality and non-routable segments are respected. Regression: database/tests/kingswell_weighted_road_routing.sql.

This is a baseline route engine, not live traffic or calibrated response-time simulation. It calculates fastest and shortest paths using segment lengths and posted speed limits, respects directionality, routability and access profiles, and records ordered route legs. Dispatch route snapshots and ETA ranking are integrated. Live congestion, calibrated emergency response times, turn penalties, dynamic road closures, emergency driving behaviour and full patrol-route optimisation remain future refinements. Regressions: `database/tests/kingswell_weighted_road_routing.sql` and `database/tests/kingswell_live_dispatch_route_integration.sql`.

## Explicitly not yet represented

Exact surveyed cadastral polygons, precise architectural building footprints and heights, secondary and service entrances for every building, detailed turn restrictions, live traffic simulation and calibrated travel times remain later layers. The routing engine currently respects segment directionality, but the seeded network presently has all 151 segments marked two-way. The current property and building coordinates are deterministic fictional planning points tied to the connected road network, not survey-grade geometry.


## Property, building, address and landmark foundation

The original city inventory is seeded across all 24 neighbourhoods, with 20 BP-02 baseline parcels per neighbourhood (40 per district): 480 property records and 480 associated buildings. BP-04 adds 176 further parcels/buildings, bringing the live property/building register to 656 each. The current building-unit register contains 26,888 units/premises, including 24,512 units classified as residential and the balance in commercial, industrial, logistics, transport and mixed-use premises. Property records carry district/neighbourhood references, street and road links, fictional local-grid coordinates, parcel area, frontage width, land-use classification, frontage road segment and postal code. Buildings carry their own position, footprint dimensions/area, type, floor count, construction type, occupancy state and a detailed building-systems profile.

Every property has one structured primary postal address (656 total) and one primary access point (656 total). Access points resolve to an actual routable road segment and the nearest endpoint junction, providing a usable destination layer for dispatch and navigation. Every property, building and unit now has a one-to-one detailed profile, including local-grid parcel/building outlines, utility/security/fire/accessibility information, floor directories and unit-level use/occupancy attributes. The address format is: street number, named local street, neighbourhood, district, Kingswell, Asterfell and neighbourhood postal code. Twenty-four named landmarks—one per neighbourhood—resolve to their property, building and access point, rather than existing as unlinked map labels.

These are fictional planning records, not real-world addresses or surveyed property boundaries. The expanded inventory supports address lookup, incident location, business/institution placement and BP-03 household allocation. Parcel and building outlines are schematic local-grid footprints, not surveyed cadastral geometry; precise legal boundaries, architectural floor plans, multiple entrances and dynamic occupancy remain later refinements. Regression: `database/tests/kingswell_properties_buildings_addresses.sql`.


## BP-02 ownership boundaries and completion

- BP-02 owns the fictional country/region/city hierarchy, district and neighbourhood geography, city map conventions, road/junction/segment topology, landmarks and the geographic reference system.
- BP-03 owns people, households, population counts and population movement. The 100,000 resident figure is a starting city baseline, not a geography-layer population engine.
- BP-04 owns properties, buildings, units, addresses, access-point records and business/organisation premises. BP-02 uses those existing location references and must not duplicate them.
- BP-05 and BP-10 own police facilities, patrol sectors, beats and their operational use. Their geography is linked to the city map, not recreated as administrative districts.
- BP-35 owns runtime coordination. The route calculation and dispatch integration use the existing geography records.
- National regions are reference-level only. No detailed road network, property inventory or city simulation is implied outside Kingswell.

### BP-02 verification

The rollback-only BP-02 geography regression verifies the Asterfell country and eight-region register, capital-city link, Kingswell local-grid metadata, 12 districts, 24 neighbourhoods, 12 in-grid planning envelopes, 51 named roads, 118 in-grid junctions, 151 connected road segments, three explicit 1,000 m bridge segments, 24 in-grid landmarks, foreign-key consistency and RLS. Separate rollback-only regressions verify the existing property/building/address/landmark layer, police facilities and patrol geography, weighted route calculation and dispatch route integration. The fictional clock is required to remain uninitialised during these tests.


## BP-04 primate-city property and business map layer — KNG-MAP-0.2

Kingswell is Asterfell's primate city: the dominant political, financial, commercial, entertainment, logistics, transport and international-trade centre. The property map reflects that national role. The central city contains banking, capital markets, corporate headquarters, ministries, regulators and professional services; Market Ward provides wholesale and retail exchange; Foundry Park supports manufacturing; East Logistics and South Harbour concentrate freight, warehousing, import/export, customs and maritime trade; Central Terminal and Aerodrome serve passenger and cargo movement; Westhaven, Northgate, University Heights and Riverside provide high-density housing and daily neighbourhood services.

### Current inventory by district

| District | Properties/buildings | Units | Businesses | Character |
|---|---:|---:|---:|---|
| KDW — Westhaven | 64 | 6,240 | 48 | High-density housing, Old Westhaven and Willow Park local services |
| KNA — Northgate | 64 | 6,240 | 48 | Northern residential towers and neighbourhood retail |
| KED — University Heights | 64 | 6,184 | 48 | University, hospital, student/staff housing and local services |
| KMX — Riverside | 64 | 6,304 | 208 | Riverfront housing, 160 mixed-use premises, retail and hospitality |
| KCI — Civic Quarter | 50 | 240 | 130 | Parliament, Presidency, ministries, regulators and professional offices |
| KCB — Central Exchange | 50 | 240 | 180 | Banking, insurance, investment, corporate and technology firms |
| KST — Central Terminal | 50 | 240 | 80 | Passenger interchange, rail/bus and transport businesses |
| KMA — Market Ward | 50 | 240 | 190 | Grand Market, wholesale, retail, food trade and hospitality |
| KIN — Foundry Park | 50 | 240 | 140 | Manufacturing, engineering and industrial services |
| KLG — East Logistics | 50 | 240 | 190 | Freight forwarding, distribution and warehousing |
| KPT — South Harbour | 50 | 240 | 140 | Port, maritime trade, customs support and import/export |
| KAS — Aerodrome | 50 | 240 | 50 | Airport campus, aviation and cargo support |

The 96 residential towers are distributed 12 per neighbourhood across KDW-01/02, KNA-01/02, KED-01/02 and KMX-01/02. The 80 commercial centres are distributed five per neighbourhood across the 16 other neighbourhoods. The 192 residential-tower podium shops and 160 existing Riverside mixed-use premises support 352 additional neighbourhood-scale businesses. The business directory contains 1,452 businesses and 43,412 estimated employee positions; employee estimates are business profile data, not yet individual NPC employee identities.

### Neighbourhood map commands and geometry

The live database provides `game.get_neighbourhood_property_map(neighbourhood_code)`, returning the district/neighbourhood identity, property count, building count, unit count, property centres, parcel outline rings, addresses, road names, access-point coordinates, building footprints/heights, unit totals and current occupiers.

The text-first game commands are:
- `property map KDW-01 by PERSONNEL_REF`
- `property record KNG-P-RH0001 by PERSONNEL_REF`
- `property summary by PERSONNEL_REF`
- `business directory sector logistics_warehousing by PERSONNEL_REF`
- `business record AF-BIZ-000281 by PERSONNEL_REF`

The detailed narrative and 24-neighbourhood inventory is maintained in `docs/geography/KINGSWELL-NEIGHBOURHOOD-ATLAS.md`. All added properties remain on the existing local-metre grid and use existing district, neighbourhood, road and junction identities. No duplicate geographic hierarchy has been introduced.
