# Kingswell Master Geographic Map

**Status:** Initial working map, version 0.1 — proposed geography for the approved BP-02.  
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
Each neighbourhood will receive a connected local street grid, with named collectors, local streets, service lanes, pedestrian links and access restrictions. Road names are unique within the city; road segments, not names alone, define connectivity.

## Neighbourhood framework

Each district is subdivided into neighbourhoods recorded in the database. The initial neighbourhood list is in the seed register and will be expanded with local roads, properties and addresses in later passes.

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
6. Add properties, buildings, addresses and landmarks.
7. Add police stations, patrol sectors and response routing.

## Explicitly not yet represented

Exact cadastral polygons, terrain elevation, building footprints, individual property addresses, street-by-street local grid, real-world coordinates, traffic simulation and travel-time calibration. These are later map layers, not silently assumed facts.
