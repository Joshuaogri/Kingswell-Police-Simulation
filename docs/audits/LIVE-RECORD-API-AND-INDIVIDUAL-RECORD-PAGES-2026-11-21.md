# Live Record API and Individual Record Pages — 21 November 2026

**Project:** Kingswell Police Simulation (entirely fictional)  
**Blueprint:** BP-01–BP-44 remains approved and unchanged.  
**Interface refinement:** BP-40.

## Delivered

- Deployed Supabase Edge Function `kingswell-records` (version 6).
- Added source control copy at `supabase/functions/kingswell-records/index.ts`.
- Added live searchable, paginated directories for:
  - 100,000 people;
  - 1,452 business profiles;
  - 1,490 organisations;
  - 656 properties.
- Directory page `records.html` now queries the live API, returns 25 records per page, supports further pages and search, and opens individual dossiers.
- Added `record.html` as a dedicated individual record page, with direct canonical-ID URLs and links back to the directory and city atlas.
- The API includes controlled record details and relationship links for people, businesses, organisations, properties, buildings, units and premises.
- The API only accepts GET and OPTIONS. Database reads run inside read-only transactions. Query fields and record types are allowlisted, page size is capped at 50, and results are not bulk-exported.
- The browser only contains the publishable API key. Database credentials remain in the Supabase Edge Function environment.
- The game schema is not exposed through the public REST schema list and no broad RLS policies were added. The Edge Function uses the server-side database connection and returns only the fields explicitly selected by its queries.
- No simulation clock changes occur when browsing these pages.

## Verification

GitHub Actions run **#36** passed:
- Existing city map still renders 656 buildings and map JSON loads.
- Existing property unit dossier loads.
- Static geography directory selection and search work.
- Live people, business, organisation and property directories each return records.
- Each live directory opens an individual dossier.
- Live people search by canonical reference returns the record.
- Pages build and deployment completed successfully.

GitHub Actions run: https://github.com/Joshuaogri/Kingswell-Police-Simulation/actions/runs/44925414846

GitHub Actions run **#40** passed Chromium checks for the dedicated `record.html` person record route. Run **#45** then passed the full end-to-end navigation checks: selecting a property on the map opens its live individual record, and the record page links back to the same highlighted property on the map. The Pages build and deployment completed successfully.\n\nGitHub Actions run #40: https://github.com/Joshuaogri/Kingswell-Police-Simulation/actions/runs/44925628935\n\nGitHub Actions run #45: https://github.com/Joshuaogri/Kingswell-Police-Simulation/actions/runs/44925951765

## Explicit remaining work

- Continue building dedicated full-page detail routes for the remaining game domains: police personnel, units, dispatch, incidents, cases, investigations, evidence, forensics, custody and justice.
- Extend record relationship navigation so users can move between people, businesses, organisations, properties, sites and their related records.
- Add map-to-record and record-to-highlighted-map navigation.
- Add query-driven atlas layers and progressive detail without putting every person or business label on the default map.
- Continue expanding Chromium checks across all record routes, search, pagination, navigation and responsive layouts.


## Atlas overlays and search

- Added an optional **24-landmark layer**, with individual landmark inspection and search.
- Added an optional **property entrance/access-point layer** (more than 1,000 canonical entrances), with access-point inspection, connected property/building context and links to the full property record.
- Kept both layers off by default to preserve a clear base map.
- Added landmark and entrance symbols to the map legend and included their counts in map status.
- Map search now recognises landmark names/references and entrance references as well as properties.
- GitHub Actions run **#55** passed Chromium verification of landmark and entrance layer toggles, search and individual inspection, alongside all existing map, record and live-directory checks.
- Run #55: https://github.com/Joshuaogri/Kingswell-Police-Simulation/actions/runs/44926500905
