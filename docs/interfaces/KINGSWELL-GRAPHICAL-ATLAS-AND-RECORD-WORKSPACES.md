# Kingswell Graphical City Atlas and Dedicated Record Workspaces

**Decision recorded:** 21 November 2026  
**Project:** Kingswell Police Simulation — entirely fictional game  
**Status:** Approved interface direction; implementation is staged and must not be represented as already delivered  
**Design authority:** Existing approved master blueprint BP-01–BP-44. This document refines delivery and presentation under BP-40; it does not replace, split, reopen or require reapproval of any blueprint division.

## 1. User-approved product direction

Kingswell must grow beyond a basic property map into a visually rich, searchable city simulation interface. The city atlas should aim for the clarity, visual quality and navigation experience associated with modern mapping products such as Google Maps, while remaining an original map of fictional Kingswell and using Kingswell's canonical geometry and records.

The map is one dedicated interface in a larger application. It must not become a single screen that tries to display every person, business, organisation, police record and simulation record simultaneously.

Every meaningful game entity must be discoverable through a suitable search/directory and open its own dedicated detail record. Records must be cross-linked where relationships exist, without duplicating authoritative data.

## 2. Graphical city atlas

### Visual quality and cartography
- Deliver a polished, high-resolution, responsive map with a coherent cartographic design system, legible typography, visual hierarchy, attractive land-use styling and clear symbols.
- Support smooth zoom, pan, fit-to-city, reset, scale indication, north orientation and useful map navigation.
- At appropriate zoom levels, show citywide districts and neighbourhoods; street networks and labels; then individual properties, building footprints, entrances and units.
- Progressively reveal detail by zoom level to avoid clutter and preserve performance.
- Where canonical geometry supports it, add richer building forms, height/extrusion or isometric/3D presentation. Do not imply survey-grade geometry where only schematic footprints exist.
- Render terrain/landscape context, rivers, harbour/waterfront, parks/open space, bridges, transport corridors, landmarks and civic places from canonical records. Do not invent geographic precision or claim real satellite coverage.
- Maintain accessible contrast, clear selected/hover states, readable labels and a useful legend.

### Map layers and overlays
Provide independently switchable layers, including:
- districts and neighbourhoods;
- named roads, road classes, segments, junctions, bridges and turn controls;
- properties, building footprints, entrances and (at close zoom) unit access/context;
- parks, waterways, landmarks and transport infrastructure;
- businesses and organisation sites;
- police facilities, patrol sectors/beats and operational assets;
- optional operational overlays for active calls, incidents, closures, deployments and case-linked locations when those systems are connected and authorised.

The default city view must not display 100,000 resident symbols or thousands of business labels at once. People are searchable in the people directory. Map person markers should be optional, query-driven, permission-aware and limited to a selected result or small relevant set. The map must remain visually useful and uncluttered.

### Search and selection
A unified search entry may route a query to the right domain, but results must retain entity type and open the correct dedicated workspace. Search should support relevant identifiers, names, addresses, aliases and relationships across the game. Examples include:
- person name or person reference;
- business trading name or business reference;
- organisation name or organisation reference;
- property/building/unit reference or postal address;
- road, junction, neighbourhood, district or landmark;
- police facility, personnel, unit, incident or case reference where access permits.

Selecting a map feature opens a concise preview and an explicit route to its full record. It must not embed an entire dossier in a map popup. A full record may include a map-location action that returns to and highlights the corresponding map feature.

## 3. Dedicated searchable workspaces

Create distinct navigation destinations and record pages. These are separate views over shared canonical records, not duplicate databases.

1. **People** — searchable directory for the 100,000-person Kingswell population; unique person identity, profile, addresses and address history, household, relationships, life events, routines/activity where implemented, employment, organisation/business links and relevant police links. Respect simulation detail levels and access rules. Population records are already represented as seeded game data in the project division register; the current public map snapshot does not yet expose a complete people directory.
2. **Businesses** — directory and individual business dossiers, including identifiers, trading names, sector, status, premises/sites, branches, ownership/control where known, workforce, operating details, assets and linked records.
3. **Organisations** — directory and individual organisation dossiers, including type, purpose, status, structure, departments, sites, office holders, personnel, relationships and history.
4. **Properties and buildings** — property, building, floor, unit, address, occupancy, site, access, infrastructure, asset and lifecycle records, with parent/child navigation.
5. **Geography and transport** — road, segment, junction, access point, route, district, neighbourhood, landmark, transport and infrastructure records.
6. **Police department** — separate department overview, structure, divisions, units, facilities, personnel, ranks, positions, grades, qualifications, rosters, career and resource workspaces.
7. **Operations and dispatch** — dedicated consoles and record views for patrol, calls, dispatch, deployments, unit/personnel availability and incident lifecycle.
8. **Crime and investigations** — crime catalogue, incidents, cases, investigative actions, victims, witnesses, suspects, interviews, intelligence, surveillance and linked locations.
9. **Scenes, evidence and forensics** — scene records, access/activity histories, exhibits, continuity/custody, examinations, laboratory requests, findings and reports.
10. **Justice and institutions** — arrests, warrants, custody, legal process, courts, outcomes, corrections and institutional records as implemented.
11. **Simulation and administration** — game clock, event history, commands, schedules, notifications, reports, configuration, permissions, audit and system status.

The navigation should expose only useful top-level workspaces, with sub-navigation inside each domain. It must not turn every table into a top-level menu item.

## 4. Record design and relationships

- Each entity has a stable canonical reference and one authoritative record.
- A record page presents its own fields, status, history, linked entities, documents/events and available actions appropriate to that record type.
- Related records link to each other in both directions where the relationship is meaningful: person ↔ household/property/employer; business ↔ organisation/site/property/personnel; organisation ↔ departments/sites/personnel; police record ↔ people/places/incidents/cases; case ↔ incidents/scenes/evidence/examinations.
- Search results, lists and tables are paginated or virtualised. Large histories are loaded on demand.
- The map is a spatial index and visual navigation tool, not the sole record browser.
- Do not duplicate or fabricate facts to make a page look complete. Display unknown, unrecorded or not-yet-implemented states honestly.
- Shared identity and foreign-key relationships must be used; do not create parallel civilian, business, organisation or property identity stores for presentation convenience.

## 5. Architecture and data handling

- Supabase remains the authoritative live game database.
- GitHub stores source code, migrations, tests, documentation and static assets.
- The browser must use a properly authenticated application data service for live queries and permitted actions. Never put Supabase service-role credentials in browser code or static GitHub Pages assets.
- Static exports may be used for public-safe map bootstrapping or read-only previews, but must be labelled as snapshots with export time/provenance. They must not be mistaken for live data.
- Query and load data by domain, page and selected record. Do not download the entire population and all dossiers into the browser at startup.
- Use indexes, pagination, server-side filtering, bounded related-record queries and lazy loading. Preserve stable references and provenance.
- Respect the game's fictional time rules: opening the interface, browsing the map or leaving the game must not advance the simulation clock.

## 6. Chromium development and browser verification standard

**Chromium is the designated primary browser for development and automated browser verification.** Continue using Chromium; do not substitute an untested browser or claim a UI is verified merely because a build succeeds.

- Use Chromium for manual visual inspection of the map and every major workspace.
- Use Playwright with Chromium for repeatable end-to-end and smoke tests in development/CI.
- Browser tests should verify that pages render without fatal console errors, core data requests succeed, search returns expected entity types, record navigation opens the correct record, map layers and selection work, and key map geometry is visibly rendered.
- Include representative tests for people, businesses, organisations, properties, roads and police/operational records as each workspace is delivered.
- Test responsive layouts, keyboard interaction, loading/error/empty states and large-result pagination.
- Run browser tests against the actual built application bundle. A successful database test or deployment alone is not proof that the user interface works.
- The existing GitHub Actions Chromium Playwright smoke test for the map is the starting baseline and must be preserved and expanded.

## 7. Delivery order

1. Establish a consistent application shell, global search, navigation and record-page conventions.
2. Improve the graphical city atlas using canonical geography and property geometry; add progressive detail, polished styling and map-to-record navigation.
3. Deliver dedicated property/building/unit, business and organisation directories and dossiers, connected to their existing BP-04 records.
4. Deliver the complete searchable people directory and individual person records using the canonical seeded population and BP-03 identity model.
5. Add police department, personnel, unit, patrol, dispatch and incident workspaces.
6. Add crime, case, investigation, scene, evidence, forensic, justice and remaining simulation workspaces in blueprint dependency order.
7. Connect all views to the authenticated live data service; retain clearly labelled static snapshots only where useful.
8. Expand Chromium/Playwright coverage with every workspace and its cross-record navigation.

This sequence is a delivery plan, not a change to BP-01–BP-44 or a reason to defer work already completed in Supabase.

## 8. Acceptance principles

The direction is satisfied only when:
- the map is visually rich, navigable and readable at city, district, street and property scales;
- map overlays are optional and do not overwhelm the default view;
- residents, businesses, organisations and other entities are searchable in their own directories;
- each selected entity opens its own dedicated, correctly linked record;
- the same canonical record is used across map, directories and operational workspaces;
- large data collections are paginated/lazy-loaded rather than dumped into one interface;
- the UI clearly distinguishes live data, static snapshots and not-yet-delivered features;
- Chromium/Playwright tests verify the built browser experience, not just backend functions.

## 9. Non-negotiable project constraints

- Kingswell and all its people, places, organisations, events and cases are fictional.
- Preserve the approved BP-01–BP-44 master blueprint. This document is an interface refinement under the existing design.
- Do not restart or seek reapproval of the approved blueprint.
- Supabase is authoritative; GitHub is the code/documentation/version-control repository.
- Chromium remains the primary browser for development and browser testing.
- Keep the city map separate from the dedicated people, business, organisation, property and police record workspaces.
