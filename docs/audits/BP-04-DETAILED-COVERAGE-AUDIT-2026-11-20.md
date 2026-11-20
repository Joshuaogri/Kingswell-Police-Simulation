# BP-04 Detailed Coverage Audit — 2026-11-20

**Division:** BP-04 — Buildings, Properties, Businesses and Organisations  
**Database:** Kingswell Supabase project  
**Audit type:** Read-only coverage/integrity audit followed by additive schema and query refinement  
**Result:** Core baseline is populated and structurally consistent. Detailed historical, control and agreement capabilities have been extended. BP-04 remains in progress; this audit does not certify the entire division complete.

## 1. Canonical inventory verified

| Record | Live count |
|---|---:|
| Properties | 656 |
| Property profiles | 656 |
| Buildings | 656 |
| Building profiles | 656 |
| Building units/premises | 26,888 |
| Unit profiles | 26,888 |
| Primary structured addresses | 656 |
| Primary property access points | 656 |
| Organisations | 1,490 |
| Business profiles | 1,452 |
| Current organisation sites | 1,477 |
| Property-interest records | 1,608 |
| Current organisation-personnel links | 43,412 |

The 1,490 organisations comprise 1,452 businesses and 38 non-business institutions/organisations.

## 2. Field coverage findings

### 2.1 Property profiles

All 656 properties have exactly one profile. The audited baseline has no missing title number, weak/unknown zoning code, empty permitted-use list, missing assessed land or improvement value, missing assessment date, empty utility/security/fire/accessibility JSON profile or empty parcel outline.

The current profile includes parcel/title identifiers, cadastral block, zoning and permitted uses, development intensity, tenure, heritage and exposure fields, assessments, utilities, security, fire safety, accessibility, geometry and site description.

**Initial quality limitation (now refined):** the first audit found 30 site-description texts and one shared planning-notes text. The latest enrichment now gives all 656 properties individually differentiated site summaries and planning-profile summaries. These are descriptive summaries of existing seeded fields, not planning histories; applications, decisions, conditions, enforcement actions and dated development history remain unrecorded unless separately authored.

### 2.2 Buildings

All 656 buildings have exactly one building profile. The audited fields are populated for architectural style, structural system, roof, materials, gross floor area, height, construction year, fire alarm, CCTV/access-control summary, floor directory and building-systems JSON.

Every building's floor count equals the length of its floor directory; all floor directories begin at ground floor index 0 and end at floors minus 1. No floor-directory mismatch was found.

**Initial quality limitation (now refined):** the first audit found only three distinct building-systems JSON profiles. The latest enrichment now gives all 656 buildings a uniquely referenced system-design dossier with differentiated electrical, HVAC and water-distribution design classifications, plus fire, vertical-transport, backup-power and security/access summaries drawn from existing profile attributes. These remain seeded design summaries, not physical inspections or device-level inventories; inspection status remains not recorded and asset-level inventory remains not seeded.

A preliminary comparison of buildings.floors to the maximum building_unit_profiles.floor_number produced 544 apparent differences. This was a flawed comparison: floor numbers are zero-based, and a single unit can represent a whole multi-floor building. The corrected test compares the declared floor count with the actual floor-directory length and returns zero exceptions. Do not reintroduce the flawed comparison as a defect.

### 2.3 Units and premises

All 26,888 units have one unit profile, a floor, suite code, use class, internal area, occupancy capacity, utility-meter object, access notes, security zone, description and condition.

The 24,512 dwelling units all have bedroom and bathroom counts. The remaining missing bedroom/bathroom values occur in non-residential premises where those attributes are inapplicable; they are not missing dwelling details.

### 2.4 Businesses

All 1,452 businesses have a unique business number, trading name, sector/subsector, size, ownership form, incorporation date, employee estimate, turnover band, goods/services, business hours, cash-handling profile, security JSON, trade JSON, fictional website domain and profile notes.

The audit found 1,452 distinct fictional website domains, 28 distinct service descriptions and 20 distinct trade profiles.

**Quality limitation:** Some business/site detail remains templated rather than individually specified:
- Only two distinct business profile-note values exist.
- Only five distinct business-hours profiles exist.
- Only three distinct security-arrangement profiles exist.
- 1,100 business records use security_provider=not_seeded and a generic cctv=business_specific label.

The values are not structurally missing, but security-provider, camera coverage, cash controls, delivery/stock arrangements and individual operating practices need further fictional-world enrichment. Do not invent a real-world security provider or assert a specific camera layout without adding it as explicit fictional canon.

### 2.5 Ownership and property interests

All 656 properties have one current registered-owner interest. There are 476 current landlord interests and 476 current property-manager interests. No current beneficial-owner or mortgagee interests are recorded.

The database correctly distinguishes registered owner, landlord and property manager. However, beneficial ownership, lender/security interests, joint title holders, easements and other encumbrances are not yet populated. Their absence is a data-coverage gap, not proof that none exist in the fictional world.

### 2.6 Site occupancy and agreements

There are 1,232 current tenant sites with 1,232 unique lease references. All have lease type and non-empty lease detail JSON and all are attached to a valid building unit. There are also 220 current business owner-occupier sites; these correctly have no tenant lease.

A landlord interest is not recorded for 152 of the 1,232 tenant sites. The new agreement records preserve the landlord as unknown for those sites rather than incorrectly assigning the registered owner as landlord. Existing site occupancy dates are retained as provenance but are not misrepresented as lease execution or commencement dates.

## 3. BP-04 changes applied

The following additive changes were applied to Supabase and version-controlled in GitHub:

1. **Map-version alignment:** all 656 parcel outlines and 656 building footprints now identify the current authoritative KNG-MAP-0.3 coordinate/map version. The neighbourhood property-map query now reports the city's current map_version as its coordinate_system, rather than a hard-coded stale KNG-MAP-0.1.
2. **Property valuation history:** added game.property_valuation_records and backfilled 656 dated snapshots from the already-recorded property-profile assessments. Each is explicitly labelled as an estimated fictional planning assessment, not an independent appraisal.
3. **Property/building/unit asset event history:** added game.property_asset_events for inspections, condition assessments, defects, maintenance, repairs, alterations, safety reviews, utility events and damage. It is intentionally empty until real fictional events are recorded; no inspections or repairs were fabricated. A trigger validates that a referenced building and unit belong to the selected property.
4. **Business ownership/control register:** added game.organisation_control_interests for beneficial owners, shareholders, directors, partners, controlling persons and franchise operators. It is intentionally empty because no canonical named ownership/director relationships were present in the existing data. The existing organisations.parent_organisation_id remains the parent-company hierarchy; the new table does not duplicate it. The register has exactly-one-holder, date-range, share-range and control-type constraints, plus partial unique indexes preventing duplicate current holder/control rows and lookup indexes for organisation and holder timelines. Current audit found no existing personnel job titles explicitly identifying directors, owners, proprietors, partners, shareholders or chief executives, and no parent-organisation links; job titles are not being used to infer ownership.
5. **Formal site agreement records:** added game.organisation_site_agreements and its site-link table. Backfilled all 1,232 existing tenant lease references, with 1,232 valid site links. Unknown contract dates, actual rent amounts, deposits and 152 unrecorded landlord counterparties remain unknown.
7. **Dossier outputs:** extended get_property_record with valuation history, asset events and site agreements; extended get_business_record with ownership/control interests and site agreements. Existing canonical property/business/site identities and command names are preserved.\n8. **Individual property dossiers:** all 656 property profiles now have individually differentiated site descriptions and planning-profile summaries derived from their own address, property reference, type, parcel area, frontage, status, linked building/premises counts, zoning and permitted-use fields. The summaries explicitly state that they are not planning application/decision histories.\n9. **Individual building system dossiers:** all 656 building profiles now carry a uniquely referenced seeded system-design summary. Existing recorded fire, lift/stair, backup-power, CCTV and access-control attributes are surfaced; design classifications are differentiated deterministically by canonical building reference. The record explicitly marks physical inspection as not recorded and device-level inventory as not seeded.\n10. **Individual unit/premises dossiers:** all 26,888 unit profiles now have individually differentiated access summaries tied to canonical unit, suite and floor references, with route classifications appropriate to residential, industrial/storage, retail and other use classes. Existing building-level access-control classifications are referenced without inventing keys, credentials, access events or surveyed routes.\n11. **Unit utility metering profiles:** all 26,888 unit profiles now retain their original utility-meter profile fields and include a unit-referenced metering-design summary for electricity, water and telecommunications. Meter serial numbers, account references, readings and service-status events remain explicitly unrecorded.

## 4. Post-migration verification

The following post-migration results were verified:
- 656/656 parcel outlines match the city's current map version.
- 656/656 building footprints match the city's current map version.
- 656 valuation-history snapshots exist.
- 1,232 site-agreement records and 1,232 agreement-to-site links exist.\n- 1,232/1,232 agreement dossiers have a clause coverage register derived from actual populated columns.\n- The organisation control register has current-row uniqueness and holder/timeline lookup indexes; its existing identity, date and share constraints remain in force. No ownership/directorship rows were invented from employee records.\n- The 152 missing landlord counterparties remain unassigned; all 152 have registered-owner records but no current landlord-interest record, so registered ownership is not conflated with landlord status.
- All 1,232 tenant locations resolve to the matching agreement, tenant organisation and lease reference.
- 220 owner-occupier sites remain without artificial tenant agreements.
- Neighbourhood map output returns KNG-MAP-0.3 for both map version and coordinate system.
- Property dossier returns valuation and agreement history.
- Business dossier returns site-agreement and control-interest sections.\n- 656/656 property site descriptions and planning summaries are individually differentiated.\n- 656/656 building system dossiers have a unique canonical building reference and explicit seeded-profile provenance.\n- Building-system dossiers do not claim physical inspections, device-level inventories or live system operation.\n- 26,888/26,888 unit access summaries are individually differentiated and tied to canonical unit/floor references.\n- 26,888/26,888 unit metering summaries have unique canonical unit references; actual meter serials, account references and readings remain unknown.
- Invalid cross-property building references are rejected by the asset-event validation trigger; the test inserted no persistent event.
- No property/building/unit/business/person/organisation identities were duplicated.

## 5. Remaining BP-04 work

BP-04 must remain open until the following are addressed and tested:

1. Populate canonical business ownership, beneficial ownership, directors and controlling-person records only when source-supported fictional facts identify actual BP-03 person/organisation identities and their roles. Existing personnel job titles and parent-company links do not currently establish those relationships; do not fabricate people or duplicate identities.
2. Enrich the 1,452 business dossiers beyond broad sector templates, especially security provider/coverage, operational model, products/services, stock, deliveries, customer access, cash controls and site-specific practices.
3. Resolve the 152 tenant-site landlord gaps where the fictional property records establish a landlord; leave genuinely unknown counterparties unknown.
4. Add lease execution/commencement/expiry/break/renewal/notice terms, rent amounts/frequency, deposits, permitted use, repair/service-charge obligations and supporting document references only when established by fictional records.
5. Add genuine property/building/unit inspection, condition, defect, maintenance and repair events through the new event register and future gameplay workflows.
6. Expand property development/planning history, valuation changes, easements, mortgages and other title interests where supported by the world records.
7. Continue from seeded unit access and metering summaries toward actual device-level utility, access, safety, accessibility and security inventories only when fictional asset records are established; preserve site/building/unit fact boundaries.
8. Add safe, permission-aware write workflows and browser/game interfaces for the new histories and records, then test integration with BP-02, BP-03, police, dispatch, incident, case and scene systems.
9. Run the complete BP-04 regression suite after the above data and workflows exist.

## 6. Completion decision

**BP-04 is not complete.**

The existing baseline is populated and its audited structural invariants pass. The map-version defect is corrected; valuation history and formal tenant agreement history are available; asset-event and business-control structures are now present. However, the asset-event and business-control registers are empty, several ownership/lease counterparties remain unknown, and property/business detail still needs more individualized fictional content and full write/runtime/UI integration.

All records remain entirely fictional Kingswell game data.
