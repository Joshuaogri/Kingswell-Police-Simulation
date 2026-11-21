# Kingswell Playable Web Interface — first delivery

**Date:** 21 November 2026  
**Surface:** GitHub Pages internal development interface  
**Status:** First functional browser workspace published; further blueprint domains remain in staged implementation.

## Purpose

The website is the internal browser interface for the fictional Kingswell Police Simulation. It is not a marketing landing page. The playable interface is built around a persistent city atlas and record navigation, with the approved BP-01–BP-44 master blueprint remaining the design authority.

## Delivered in this increment

### 1. Canonical city map

The browser renders a cartographic canvas from the Kingswell local metric grid and the current KNG-MAP-0.3 records.

- 12 district planning envelopes.
- 24 neighbourhood names positioned from the centroids of their registered properties.
- 75 named roads and all 229 connected road-segment geometries.
- 157 junctions.
- 1,136 primary and secondary property entrances.
- 24 named landmarks linked to their property/building/access records.
- 282 active turn-control records associated with mapped junctions.
- All 229 road segments linked to patrol-beat coverage.
- 656 individually rendered building footprints.
- Building positions, width, depth and footprint area from BP-04 records.
- Distinct land-use styling for residential, commercial, industrial, civic/public, transport, mixed-use and other properties.
- River and harbour context, north indicator, scale indicator and a map legend.
- Layer controls for buildings, district areas, neighbourhood labels, primary/secondary/local/service roads, junctions, property entrances, landmarks, turn controls and patrol-beat coverage.
- Mouse/touch pan, wheel zoom, zoom buttons, fit-to-city and reset.
- Search across building/property references, addresses, business names, roads and neighbourhoods.
- Click a building footprint to open its property/building record; at close zoom the unique building reference is printed on the footprint.
- Click a road segment to inspect its road and segment record, including speed limit, lanes, direction, surface, width, condition, footway, cycle lane, lighting, parking, routability and access profile.
- Click a junction to inspect signal/control, pedestrian/tactile crossing and linked turn restrictions. Toggle entrance, landmark, turn-control and patrol-beat overlays independently.

### 2. BP-04 map-linked property browser

The published data snapshot carries all 656 canonical property/building map records and connects each mapped property to the available BP-04 summaries:

- Property and building IDs/references, address, district and neighbourhood IDs, land use, property type and status.
- Building type, name, floors, local-grid position, footprint dimensions/area, construction type and occupancy status.
- Unit counts and counts by unit type.
- On-demand individual unit directory for all 26,888 units, split into 24 neighbourhood data files and loaded only when a building's Units tab is opened.
- Unit reference/name/type/floor/parent, floor number/suite, use class, internal area, capacity, bedrooms/bathrooms, security zone, condition grade and nine infrastructure status fields.
- Organisation site references, site names, location roles and occupancy statuses.
- Linked business profiles with business number, trading name, sector/subsector, size and estimated employee count.

The Units tab now loads the individual unit records for the selected building on demand from its neighbourhood snapshot. The directory includes unit identity, floor/use/area/capacity/condition and infrastructure status. The full utility-meter registers and detailed utility/access/fire-safety JSON payloads are intentionally not duplicated into the static snapshot. Full organisation, workforce, agreement, title, asset and property-level infrastructure dossiers remain in the authoritative BP-04 database and will be surfaced in subsequent workspace increments.

### 3. Browser structure

- The root GitHub Pages URL opens the map-first simulation workspace.
- `play.html` is the named operations/workspace entry point; the root `index.html` mirrors it.
- `city-map.html` is the dedicated full-screen geographic intelligence view, with district/type filters and building/road inspection.
- `geography.html` redirects to the root playable workspace.
- The map data snapshot is stored at `data/kingswell-map-data.json`, with provenance/counts in `data/kingswell-map-data-manifest.json`.
- Individual BP-04 unit snapshots are stored in `data/units/` (24 neighbourhood files, 26,888 unit records) with a manifest and a reproducible export query.
- The repeatable read-only export query is stored at `scripts/export-kingswell-map-data.sql`.
- The UI uses a local vector/canvas renderer; it does not require third-party map tiles or expose Supabase credentials.

## Source data and accuracy

The snapshot was exported from the live Supabase `game` schema on 21 November 2026. A live coverage query verified:

| Layer | Verified records |
|---|---:|
| Districts | 12 |
| Neighbourhoods | 24 |
| Named roads | 75 |
| Road segments with geometry | 229 / 229 |
| Junctions with local-grid positions | 157 / 157 |
| Property access points | 1,136 |
| Named landmarks | 24 |
| Active turn controls | 282 |
| Patrol-beat segment coverage | 229 / 229 |
| Properties with local-grid positions and road/neighbourhood links | 656 / 656 |
| Buildings with local-grid positions and footprint dimensions | 656 / 656 |
| Building units | 26,888 |

The fictional local grid is 20,000 m × 16,000 m, north-up. The coordinates and building footprints are authored fictional simulation geometry, not real-world latitude/longitude, cadastral surveys or architectural drawings.

District map areas are planning envelopes. The current neighbourhood table stores named neighbourhoods and their district relationships, but no formal neighbourhood polygon geometry; the interface therefore labels neighbourhoods using the centroid of their registered properties rather than drawing fabricated boundaries.

The snapshot is static. Supabase remains authoritative. A future authenticated application data service is required for live-changing data, write actions and full dossier retrieval. No Supabase schema, migration or seed data was changed for this web delivery.

## Known limits

- This is a static read-only map and BP-04 browser snapshot, not yet a live Supabase-connected operational console.
- Formal neighbourhood polygons are not yet present in the canonical geography records.
- Building outlines are schematic footprints, not survey-grade cadastral or architectural geometry.
- The map now renders primary/secondary entrances, landmarks, active turn restrictions and patrol-beat road coverage as optional layers. Dynamic traffic states, individual patrol positions, active incidents, case overlays and live unit positions are not yet connected.
- The map is citywide and building-identifiable; very dense clusters require zooming in for reliable individual selection.
- Unit records are available in the on-demand building directory, but detailed meter registers and utility/access/fire-safety JSON payloads remain database-only until the live dossier service is connected.
- Police, dispatch, incidents, cases, people, evidence, forensics, justice and simulation-clock workspaces are not represented as functional pages yet. The navigation is a development shell, not a claim that those pages are complete.

## Next interface increments

1. **BP-04 dossier browser:** paginated property/building/unit, organisation/site, business, workforce, agreement, ownership/control, asset, infrastructure and lifecycle dossiers; map-to-record navigation both ways.
2. **Geography detail layers:** dynamic traffic states, individual patrol positions, police facilities, active closures and case/incident overlays.
3. **BP-05–BP-12 department and operations:** police structure, personnel, career, units/resources, patrol, emergency calls, dispatch and incident consoles.
4. **BP-13–BP-24 crime and investigation:** crime catalogue, cases, investigative work, victims/witnesses, suspects, interviews, surveillance, intelligence, scenes, evidence and forensic laboratory.
5. **BP-25–BP-34 justice and institution:** arrest, custody, legal process, courts, corrections, governance, standards, training, HR and finance.
6. **BP-35–BP-44 living runtime and assurance:** simulation engine, social context, clock/scheduling, records, persistence, interface, notifications, permissions, testing and configuration.
7. **Live application connection:** authenticated read/write service integrated with the authoritative Supabase runtime, with no browser exposure of service-role credentials.

## Governing rules

- Preserve the approved BP-01–BP-44 blueprint.
- Supabase remains authoritative; GitHub stores source and static browser assets.
- The fictional simulation clock must not advance merely because the browser is opened or the player exits.
- Do not invent missing property, occupancy, ownership, people, event or legal facts.
- Do not label a static snapshot as live data.
- No live Supabase migrations or seed data are part of this delivery.
