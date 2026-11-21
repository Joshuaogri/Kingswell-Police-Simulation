# Record Directory First Delivery — 21 November 2026

**Project:** Kingswell Police Simulation (fictional game)  
**Blueprint authority:** BP-01–BP-44 remains approved and unchanged.  
**Interface refinement:** BP-40.

## Delivered

- Added `records.html`, a dedicated searchable record-directory workspace.
- Added navigation links from the main interface and the city atlas.
- The directory loads the existing canonical geographic snapshot from `data/kingswell-map-data.json`.
- Searchable snapshot-backed records include properties/buildings, premises-linked business profiles, organisation sites, roads/segments, districts and neighbourhoods.
- Selecting a result opens a dedicated record inspector with canonical identifiers, key attributes and related premises context.
- The People entry point accurately reports the canonical population count of 100,000 but does not pretend that a full personal-record search API is already connected.
- The map remains a separate spatial interface; the record directory is a separate workspace.

## Verification

- GitHub Pages build verified the required directory page is included in the published artifact.
- Chromium / Playwright workflow run **#27** passed:
  - existing map and map JSON load;
  - map canvas and property dossier checks;
  - record directory page loads;
  - geographic snapshot index loads;
  - property results can be selected into the individual record inspector;
  - canonical-reference search returns the selected record;
  - People directory entry point displays the 100,000-person population status.
- GitHub Pages deployment job completed successfully.
- Workflow run: https://github.com/Joshuaogri/Kingswell-Police-Simulation/actions/runs/44924415574
- Implementation commit at verification: `29c1e0f661e57c81d075168e0c8f090e5b64b286`.

## Explicit remaining work

This is the first usable directory framework, not completion of every approved workspace.

- The published static snapshot contains geography and premises-linked summaries, not the full canonical database.
- Full person search and individual person dossiers are not yet connected.
- Full business and organisation dossiers, and dedicated police, personnel, dispatch, incident, case, investigation, evidence, forensic, custody and justice workspaces remain to be connected to their canonical records.
- The Supabase `game` schema has RLS enabled across its tables; the current security advisor reports 214 tables with no RLS policies. Do not expose the `game` schema or a privileged key directly in browser code. Build a narrowly scoped, paginated server-side read interface and explicit access model before connecting private/live records.
- No simulation clock advancement is caused by opening, searching or browsing these read-only directory pages.

## Next implementation sequence

1. Build the restricted server-side, paginated read/search interface for canonical people, businesses, organisations and premises.
2. Add dedicated person, business and organisation detail routes with relationship navigation.
3. Add police and operational record workspaces using the same individual-record pattern.
4. Expand Chromium coverage for every new directory, record route, search path and responsive state.
5. Continue the graphical atlas upgrade independently; do not turn the map into a dump of all game records.
