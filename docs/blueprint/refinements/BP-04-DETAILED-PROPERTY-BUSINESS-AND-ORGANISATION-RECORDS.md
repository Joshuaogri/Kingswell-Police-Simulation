# BP-04 Refinement Addendum — Detailed Property, Building, Premises, Business and Organisation Records

**Project:** Kingswell Police Simulation  
**Division:** BP-04 — Buildings, Properties, Businesses and Organisations  
**Prepared:** 2026-11-20  
**Purpose:** Extend the approved BP-04 specification with a more complete operational record model without replacing its existing design, duplicating canonical entities, or moving responsibilities from other divisions.

## 1. Status and governing approach

The approved BP-04 baseline is already implemented and regression-tested in Supabase. The live foundation currently contains 656 properties, 656 buildings, 26,888 building units, 1,452 business profiles, 25 public institutional site records, 1,477 current organisation locations and 1,608 current property-interest records. Every property, building and unit has exactly one corresponding detailed profile. All 1,452 businesses have a profile and current site. The current 43,412 organisation-personnel links reconcile to the sum of the business workforce estimates.

This addendum is a **detail refinement**, not a second BP-04 or a replacement for the approved master blueprint. It preserves the canonical records and extends their intended content and lifecycle. Existing rows and identities must be enriched in place. A new table is justified only where it represents a genuinely distinct record or history that does not already exist.

The current database foundation is not to be described as containing every item in this addendum. Items are classified as:
- **Existing foundation:** already represented by canonical tables, columns, profiles, relationships, functions or seeded data.
- **Further detail required:** a specification requirement that needs a verified implementation or data-coverage check.
- **Future integration:** behaviour that depends on the simulation runtime or another owning division.

No in-game date, valuation date, lease date, inspection date, opening date or other fictional date may be fabricated from the real database clock. Dates must be authored as fictional canon, supplied by a valid in-game event, or remain unknown.

## 2. Canonical ownership and boundaries

BP-04 owns the identity and descriptive records for physical property, buildings, building units/premises, business entities, non-police organisations, organisation sites, property interests and premises occupancy agreements.

The following existing canonical records remain authoritative:
- `game.properties` — parcel/property identity.
- `game.property_profiles` — detailed property and site profile.
- `game.property_addresses` — property address records.
- `game.property_access_points` — physical access points.
- `game.buildings` — building identity and principal physical facts.
- `game.building_profiles` — building systems and detailed building profile.
- `game.building_units` — unit/premises identity and hierarchy.
- `game.building_unit_profiles` — detailed unit/premises profile.
- `game.organisations` — organisation identity and parent-organisation relationships.
- `game.business_profiles` — business-specific profile.
- `game.organisation_locations` — organisation/site occupancy and location history.
- `game.property_interest_records` — ownership, title and other property interests.
- `game.organisation_personnel` — existing links between organisations and canonical people.

Do not create a second parcel, building, unit, address, road, person, business identity, organisation identity or employee identity to represent information that belongs to one of these records.

### Explicit division boundaries

| Subject | Owner | BP-04 responsibility |
|---|---|---|
| Country, city, district, neighbourhood, road, junction and map topology | BP-02 | Store references to canonical geography; do not create competing geography |
| Person identity, household, relationships, personal life history and individual employment link | BP-03 | Reference the existing person and employment records; describe the workplace and employer |
| Police stations, police facilities and police organisational structure | BP-05 and relevant police divisions | Provide the underlying property/building/unit reference where a police facility occupies a site |
| Police employee HR, recruitment, attendance and service history | BP-06/BP-33 | Do not create a second personnel or HR record |
| Finance and procurement workflows | BP-34 | Keep property/business descriptive values and references; do not build a parallel accounting ledger |
| Scene-specific zones, scene control and examination activity | BP-22/BP-24 | Supply canonical physical location references; scene systems own scene records |
| Runtime events, activity execution and time advancement | BP-35/BP-37 | Supply property/business state and schedules for the runtime to process |
| General record governance, audit, persistence and recovery | BP-38/BP-39 | Preserve BP-04 provenance and history using the shared record rules |
| Text commands and browser/game interface | BP-40 | Supply BP-04 queries and actions through the common interface |

BP-04 must not become a full national property market, commercial accounting package, city-government simulator or continuous business-management game. It models enough physical, commercial and institutional detail to make Kingswell coherent and to support policing, investigation, dispatch, public interaction and persistent consequences.

## 3. Property and parcel master record

Every property must have one stable property reference and one canonical parcel identity. A property is the land/site record; a building is a structure on that property; a unit is a separately identifiable part of a building or premises. They are not interchangeable.

The property master dossier should provide the following sections.

### 3.1 Identity and classification
- Stable property reference and any historical references.
- Official/site name and commonly used name.
- Property type: residential, mixed-use, commercial, office, retail, industrial, logistics, warehouse, transport, port, aviation, civic, educational, healthcare, emergency-service, recreational, vacant land, redevelopment or other defined type.
- Land-use classification and permitted secondary uses.
- Current property status: active, vacant, partially occupied, under construction, under renovation, temporarily closed, restricted, derelict, demolished or archived.
- Date/status provenance and the event or record that established the current state.
- Whether the site is privately held, public, institutional, jointly held or otherwise classified.

### 3.2 Cadastral and parcel particulars
- Cadastral parcel number, title reference and cadastral block.
- Parcel area, frontage width, parcel centre and schematic outline.
- Plot shape and adjoining parcel references where recorded.
- Frontage road and road-segment reference.
- Primary and secondary access-point references.
- Boundary description, boundary markers and any recorded boundary dispute.
- Survey/plan source, plan reference, preparation date, revision and confidence.
- Distinguish schematic game-map geometry from surveyed or legally authoritative geometry. Do not describe planning-level coordinates as survey-grade boundaries.

### 3.3 Address and location
- Official primary address and any secondary, postal, entrance or historic address.
- Address validity/history and known aliases.
- District, neighbourhood, road and postal-code references from BP-02.
- Building and unit address ranges where applicable.
- Main public entrance, service entrance, loading entrance, emergency access and controlled/restricted entrances through the existing access-point identities.
- Access restrictions and access profile.
- Map label, site description and local-grid coordinates.

Addresses and access points remain in their existing canonical tables. This section defines the dossier's expected completeness; it does not authorise a second address or access-point table.

### 3.4 Planning, zoning and development
- Current zoning and permitted-use list.
- Development-intensity/height profile and any recorded site constraints.
- Planning application/reference, proposal description, decision/status and relevant dates.
- Approved development description, conditions and permitted phases.
- Construction, extension, conversion, refurbishment and demolition history.
- Developer, principal contractor and relevant professional organisations where known.
- Building completion/occupation status and handover record.
- Heritage designation, conservation status and protected features.
- Flood, river, coastal, ground, contamination, subsidence and other site exposure information.
- Recorded easements, rights of way, shared access, service corridors and restrictive interests where known.

Planning and development entries describe the fictional site's history and current recorded state. They do not create a second legal-process or government decision engine.

### 3.5 Ownership, title and property interests
Property ownership must be represented as dated interests, not a single generic owner string. The dossier must distinguish:
- Registered legal owner.
- Beneficial owner where known.
- Freeholder or equivalent superior title holder.
- Leaseholder/long-term tenant.
- Landlord.
- Mortgagee or secured lender.
- Property manager or managing agent.
- Receiver, administrator or other temporary controller.
- Easement, access, utility or other recorded interest holder.
- Joint ownership and each holder's share where recorded.

Each interest record should identify the property, holder (one person or one organisation), interest type, share where relevant, effective dates, title/registry reference, source/provenance and supporting notes. Joint shares should reconcile where a complete share breakdown is recorded. A person and an organisation must not both be set as the holder of one interest row.

The dossier must distinguish confirmed registered title from beneficial ownership, management, occupation and unverified claims. A landlord is not automatically the owner; a tenant is not automatically the leaseholder; a managing agent is not automatically either.

Historical interests must remain available after transfer, expiry or termination. Corrections must preserve the earlier record and explain the correction rather than silently erase the previous holder.

### 3.6 Valuation, rates and property charges
- Assessed land value and improvement value, total assessed value and fictional currency.
- Valuation method/category, valuation date, valuation source and confidence.
- Previous assessments and reason for reassessment.
- Annual property charge/rate category and assessed liability.
- Insurance/reinstatement value and valuation date.
- Exemptions, relief classifications or disputed assessment status where applicable.

BP-04 stores property assessment facts and current descriptive summaries. BP-34 owns payment transactions, budgets, accounting entries, arrears collection workflows and procurement. Do not duplicate financial ledgers in BP-04.

### 3.7 Utilities and site services
For each utility/service, record provider identity where known, service type, connection status, supply point/meter reference, service capacity or class, account/site reference where appropriate, connection date, disconnection date and current availability:
- Electricity and backup supply.
- Potable water and non-potable water.
- Sewerage and drainage.
- Gas or other fuel supply.
- Telecommunications, fixed data and mobile coverage.
- Waste collection and specialist waste services.
- District cooling/heating or other site systems where relevant.

A property-level utility profile describes the service available to the site. A unit-level meter reference belongs in the unit profile. Actual outages and restoration events are runtime/world events, not silently overwritten profile values.

### 3.8 Safety, security and accessibility
- Perimeter type and condition.
- Gates, barriers, fences, shutters and controlled access.
- Alarm types, coverage and monitoring arrangements.
- CCTV system description, coverage summary, retention profile and operator/provider where known.
- Guarding/security provider and operating arrangements where known.
- Lighting and emergency lighting.
- Fire detection, alarm, suppression, hydrants, appliance access and evacuation information.
- Known hazardous materials or site hazards, with location and status where appropriate.
- Accessibility: step-free routes, lifts, ramps, accessible entrances, sanitary facilities and other relevant features.
- Public, customer, resident, staff, contractor and restricted-access classifications.

Do not store passwords, secret alarm codes or other credentials in a descriptive property dossier. Security details available to the player must follow BP-42 permissions and the character's in-game access.

### 3.9 Condition, inspection and maintenance
The property dossier should show current condition and dated history for:
- Structural condition and visible defects.
- Roof, drainage, façade, boundary and external works.
- Grounds, parking, yards and landscaping.
- Utility infrastructure and service availability.
- Fire-safety and security-system condition.
- Accessibility condition.
- Inspection type, date, inspecting organisation/person reference, findings and follow-up status.
- Defect severity, affected location, temporary controls and repair status.
- Maintenance request/work-order reference, contractor, work description, start/completion dates and outcome.

Current condition is a summary derived from the latest valid information; historical inspections and repairs must remain traceable. BP-34 owns procurement and payment. BP-04 owns the physical asset, defect and maintenance context.

## 4. Building master record

A property may contain zero, one or many buildings. Each building has its own stable reference and belongs to exactly one property unless a future, explicitly modelled shared-structure arrangement is required.

### 4.1 Building identity and physical form
- Building reference, official name, common name and former names.
- Building type/use and relationship to its property.
- Architectural style, structural system, construction type and principal materials.
- Building footprint, position, dimensions, footprint area and estimated height.
- Floor count above and below ground; basement levels.
- Gross floor area and, where known, net usable/leasable area.
- Roof form, exterior finish, façade description and significant features.
- Construction year, extension/conversion dates, major renovation history and current condition.
- Current occupancy/operational status.

### 4.2 Floor and internal arrangement
- Floor numbering convention, including mezzanines, split levels and basements.
- Floor directory and floor-use summary.
- Lobby, reception, corridors, stairwells, lifts, plant rooms and service areas.
- Fire compartments and principal evacuation routes.
- Loading areas, dock doors, goods lifts, service yards and delivery circulation.
- Parking levels and capacity.
- Shared facilities and common areas.
- Building-to-building links, skybridges or shared podiums where they physically exist.

The floor directory may be stored in the existing building profile. Where individual rooms or spaces later require stable identity, add them as a distinct spatial hierarchy under the building/unit model rather than overloading free-text descriptions. Scene zones remain BP-22 records.

### 4.3 Building systems and services
- Electrical intake, distribution, backup generator and capacity.
- Water storage, pumps, drainage and treatment.
- HVAC, ventilation and cooling.
- Lifts and escalators, including count and service status.
- Fire alarms, sprinklers, smoke control and emergency power.
- CCTV, access control, intercom and building management systems.
- Telecommunications and structured cabling.
- Waste rooms, plant rooms and service infrastructure.
- System status, last known inspection/maintenance reference and outage state.

### 4.4 Occupancy and access
- Owner-occupied, single-tenant, multi-tenant, mixed-use or vacant status.
- Residential/commercial/public/industrial occupancy profile.
- Shared entrances and common-area arrangements.
- Public opening/access profile versus tenant/staff-only access.
- Loading, delivery and contractor access arrangements.
- Building manager or facilities operator reference.
- Current and historical occupancy summaries derived from the unit/site relationships.

## 5. Building unit and premises master record

A building may contain many separately identifiable units. A unit may also be a parent premises containing subordinate units where the physical layout requires it. Each unit keeps one stable unit reference.

### 5.1 Unit identity and use
- Unit reference, unit name/number, suite identifier and former identifiers.
- Parent building and optional parent unit.
- Floor/level, wing, block, entrance and location description.
- Unit type/use class: dwelling, office, retail, restaurant, clinic, classroom, laboratory, workshop, warehouse bay, factory unit, transport facility, storage, plant room, public service premises or other defined use.
- Internal area and measurement basis.
- Current condition and occupancy status.
- Fit-out/partitioning and permitted use summary.

### 5.2 Residential unit details
Where the unit is a dwelling:
- Bedroom and bathroom count.
- Kitchen/living arrangement and dwelling type.
- Maximum/planning occupancy capacity.
- Accessibility features.
- Utility meter references.
- Furnished/unfurnished or broad fit-out profile where useful.
- Current occupancy count should be derived from BP-03 household/address memberships, not duplicated as a second resident list.
- Vacancy/occupancy status should reconcile with BP-03 current dwelling allocation.

BP-04 describes the dwelling; BP-03 owns the people, households, residential membership and personal address history.

### 5.3 Commercial and institutional unit details
Where relevant:
- Suite/retail frontage and customer entrance.
- Reception/customer area and back-of-house area.
- Storage, stockroom, cold room, secure room or loading access.
- Office/workstation or operational capacity.
- Specialist equipment and fixed installations.
- Service-counter or public-facing arrangement.
- Restricted rooms and access classifications.
- Unit-specific security, alarm and utility-meter references.

### 5.4 Unit occupancy and agreements
The unit dossier should identify the current occupier organisation/person reference where appropriate, the nature of occupation, site/occupancy role, effective dates and the linked agreement reference. Historical occupiers must remain visible as history. A unit can be vacant while the wider building or property remains occupied.

The canonical site relationship in `game.organisation_locations` remains the organisation-to-property/unit link. Its existing lease fields and JSON details are extended consistently; do not create a second organisation-site relationship table.

## 6. Occupancy, leases, licences and site agreements

Property ownership and occupation are separate. A property may have an owner, a landlord, a managing agent, several tenants and multiple operating businesses at the same time.

For each recorded agreement, the linked site/occupancy record should preserve:
- Unique agreement/reference number.
- Property and exact unit/premises where applicable.
- Parties and their roles: landlord, tenant, licensee, operator, guarantor or managing agent.
- Agreement type: lease, sublease, licence to occupy, concession, management agreement, service occupancy or other defined type.
- Execution date, commencement date, expiry date and any break/renewal dates, when known.
- Term, renewal options and notice arrangements in structured form.
- Rent band or agreed rent summary, deposit/security summary, review basis and payment frequency where appropriate.
- Permitted use, restrictions, repair/maintenance responsibility and service-charge responsibility.
- Subletting/assignment permissions and any linked consent.
- Current status: proposed, executed, active, expired, terminated, surrendered, disputed or unknown.
- Supporting document reference and provenance.
- Handover, keys/access credentials reference (never the secret credential itself), inspection and condition schedule references.

An agreement may cover multiple units or a whole property. If one site record cannot represent the scope without ambiguity, use a distinct agreement record and link the relevant existing site/location records to it. Do not duplicate the property, organisation or site identity.

Changes, renewals, surrender, termination and disputes must be dated and historically traceable. Do not infer that a lease renewed because a tenant remains in occupation. Do not infer that the registered owner is the landlord or that the current occupier has a valid lease.

## 7. Business register and business dossier

A business is an organisation with a business profile, not a building, unit, employee or site. The existing `game.organisations` row is the canonical identity; `game.business_profiles` is the business-specific extension.

### 7.1 Identity and registration
- Stable organisation reference and unique business number.
- Legal registered name, trading name and former names.
- Organisation/business type and legal/ownership form.
- Registration/incorporation reference and date, where known.
- Current operating status: proposed, active, temporarily closed, dormant, insolvent, in administration, dissolved or otherwise defined.
- Sector and detailed subsector.
- Parent, subsidiary, holding-company, franchise or associated-entity relationships.
- Registered office and principal place of business as distinct site roles.
- Business website domain and public contact channels where fictional details exist.
- Record source and confidence.

### 7.2 Ownership and control
- Sole owner, partnership, private company, public company, cooperative, state-owned entity, public corporation, charity/non-profit, franchise or other ownership form.
- Owners/shareholders/partners and ownership shares where the game records them.
- Directors, senior officers and controlling-person references where useful.
- Parent/holding-company links and beneficial-control summary where known.
- Effective dates and historical changes.
- Distinguish legal ownership, beneficial ownership, management and day-to-day control.

People referenced here must resolve to BP-03 canonical persons. Do not create duplicate director, owner or employee identities. Do not turn BP-04 into a full personal biography or HR file.

### 7.3 Commercial profile
- Main products and services.
- Principal goods categories and service description.
- Customer/business market: household, public sector, wholesale, industrial, business-to-business, export, passenger or other.
- Business size and turnover band.
- Estimated employee count and broad workforce profile.
- Import/export activity, origin/destination markets and broad trade channels.
- Supplier/customer categories where relevant to the business's fictional operations.
- Cash-handling and payment profile.
- Stock/storage profile and high-level inventory type where relevant.
- Operating model: walk-in, appointment, online, delivery, wholesale, contract, manufacturing, logistics, mobile or mixed.
- Seasonal and peak operating patterns.
- Trading hours, holiday/exception schedule and temporary closure information.

The employee count on the business profile is an estimate. Actual individual employees and employment histories are BP-03 records linked through the existing organisation-personnel relationship. The estimate must not silently create NPCs or be summed with person records as if both were separate workers.

### 7.4 Sites, branches and premises
A business may have one or many sites. Site roles include:
- Registered office.
- Headquarters.
- Main trading premises.
- Branch.
- Retail outlet.
- Factory or production plant.
- Warehouse or distribution centre.
- Depot, yard or fleet base.
- Port/airport/rail terminal operation.
- Service centre, clinic, studio or workshop.
- Storage-only or administrative site.

Every site must resolve to one existing property and, where applicable, one exact building unit. A business may share a building with other organisations only where the physical premises are distinct or a genuinely shared facility is recorded. A single unit must not be assigned to two unrelated current occupiers unless the record explicitly represents a legitimate shared/concession arrangement.

Site records include site name, site reference, site role, operating status, primary-site indicator, address/property/unit links, operating hours, site-specific details, occupancy basis and agreement reference. Site history remains after closure or relocation. Moving a business creates a new site relationship or ends/starts dated site relationships; it does not create a new business identity.

### 7.5 Operating, security and police-relevant context
- Opening hours and days of operation, including overnight trading.
- Public entrance, staff entrance, deliveries and service access.
- Cash-handling exposure and broad cash movement pattern.
- CCTV/alarm/access-control summary.
- Security provider and guarding arrangement where known.
- High-level stock, equipment or asset categories.
- Loading/delivery and vehicle access profile.
- Customer/visitor volume band and peak periods where useful.
- Known hazards and specialist operational features.
- Emergency contact role/channel where fictional records exist.

This information is a persistent business/site profile. It is not a crime-risk score, allegation or intelligence assessment. BP-21 owns intelligence assessments; BP-14 owns crime generation; BP-16/BP-22 own case and scene activity.

### 7.6 Business lifecycle
Record the dated history of:
- Formation/registration.
- Opening and commencement of trading.
- Name or ownership change.
- Change of business type, sector or operating model.
- Branch opening, relocation, temporary closure and reopening.
- Merger, acquisition, insolvency, administration, dissolution and cessation.
- Reinstatement or successor organisation where one is genuinely created.

A successor business is a new organisation only where the fictional event establishes a genuinely new legal/economic entity. A renamed or relocated business retains its existing organisation identity.

## 8. Public, civic and other non-police organisations

The organisation register includes public authorities, ministries, agencies, education and health institutions, transport operators, utilities, emergency services, cultural bodies, charities, private companies and community organisations.

For each organisation, record:
- Stable organisation reference, name, organisation type and status.
- Parent organisation and institutional hierarchy where applicable.
- Broad purpose, public/private/community status and service remit.
- Headquarters and other sites through the existing organisation-location relationships.
- Public-facing services and service hours where useful.
- Main contact/service channels where fictional records exist.
- Responsible authority or funding/ownership classification where known.
- Major operational dependencies and inter-agency relationships where useful.

Institutional sites may include campuses, hospitals, administrative complexes, depots, terminals, libraries, archives, fire/rescue facilities and public-service centres. A campus may occupy multiple properties and contain multiple buildings and units. One organisation may occupy many sites; one property may host several distinct organisations.

The National Police Service's command structure, police stations, internal departments, ranks, appointments, personnel and operational staffing remain owned by BP-05/BP-06 and other police divisions. BP-04 only provides the physical property/building/unit and generic organisation-site references needed to locate them.

## 9. Shared-site and mixed-use rules

The data model must support realistic combinations without inventing duplicate parcels or units:
- A tower may contain dwellings, retail premises, offices, plant rooms and shared facilities.
- A shopping centre may contain many independently operated businesses and shared common areas.
- A hospital/university campus may span multiple properties and buildings.
- A warehouse property may have one operator, multiple tenants, separate loading bays and storage units.
- A public building may host several departments of one parent organisation.
- A franchise network may have multiple sites under one brand/parent while retaining distinct operating entities where appropriate.
- A business may use a registered office different from its trading premises.
- A property may be partly occupied, with vacant units and active businesses at the same time.
- A single organisation may occupy several units under one agreement or several agreements.
- A shared reception, concourse, lobby or common area must not be misrepresented as an exclusively occupied tenant unit.

Where multiple organisations share one unit, the relationship must state why: concession, shared office, co-working, counter service, management operator, joint facility or another explicit arrangement. Avoid accidental many-to-one occupancy caused by incomplete data.

## 10. Record history, provenance and confidence

BP-04 records must distinguish current facts from historical facts and uncertain information.

Every consequential profile update should preserve:
- Entity reference and field/record changed.
- Previous and new value or a versioned snapshot.
- Effective in-game date/time where known.
- Recorded date/time only as system provenance, never as a substitute for fictional chronology.
- Actor or process responsible.
- Source/document/reference.
- Reason for change.
- Confidence/status: confirmed, recorded, reported, estimated, disputed, expired or unknown.

Current profiles are convenient summaries. They must not be the only surviving record of title transfers, occupancy changes, building alterations, business relocations or closures. Use the shared BP-38 history/audit conventions where available; do not create a parallel general audit system.

## 11. Read and write operations

The existing read-only commands remain the baseline and must not be renamed or duplicated:
- `property record PROPERTY_REF by PERSONNEL_REF`
- `property map NEIGHBOURHOOD_CODE by PERSONNEL_REF`
- `property summary by PERSONNEL_REF`
- `business record BUSINESS_NUMBER by PERSONNEL_REF`
- `business directory by PERSONNEL_REF`
- `business directory sector SECTOR by PERSONNEL_REF`
- `business directory district DISTRICT_CODE by PERSONNEL_REF`
- `business directory search "TEXT" by PERSONNEL_REF`

The detailed dossier should be presented in readable sections and allow retrieval of linked records without dumping every nested record into one enormous response. Search and retrieval should support:
- Property reference, title/parcel number, official/common name and address.
- Owner/holder reference, interest type and validity.
- Current/former occupier and lease/agreement reference.
- Building and unit reference, floor, suite and use class.
- Business number, organisation reference, legal/trading/former name, sector and status.
- Site reference, site role, district/neighbourhood and current/historical occupancy.
- Public institution name, organisation type and site.

Future write commands may update or append property interests, occupancy agreements, inspections, maintenance, development records, business lifecycle events and organisation/site details. Each write must validate canonical references, preserve history, identify the actor, enforce BP-42 access and avoid silent overwrites. Do not introduce write commands until the relevant records and tests exist.

## 12. Cross-system outputs

BP-04 supplies stable, reusable information to:
- BP-03: dwelling stock, exact dwelling-unit references, workplace locations and employer organisation references.
- BP-05/BP-06: police facility site references and organisation identity.
- BP-08/BP-10/BP-11/BP-12: dispatchable addresses, access points, premises descriptions and site status.
- BP-13/BP-14: business/property categories for fictional offence and incident context.
- BP-15/BP-16/BP-17/BP-18/BP-19/BP-20/BP-21: canonical premises, occupier, organisation and relevant business/site context.
- BP-22/BP-23/BP-24: exact property/building/unit location references for scenes, evidence and examinations.
- BP-35/BP-37: opening schedules, occupancy patterns, service status and dated property/business events.
- BP-38/BP-39: stable records, provenance, versioning and persistence.
- BP-40/BP-41: property/business dossiers, directories, alerts and reports.

A downstream system must reference BP-04 identifiers. It must not copy a property, building, unit, organisation or business into a separate competing identity catalogue.

## 13. Required tests and acceptance criteria for the refinement

The baseline counts below are current observed values, not permanent limits. Any later legitimate addition or retirement must preserve identity and history and update the expected inventory through an explicit game-world change.

### Identity and completeness
1. Every property has exactly one stable identity and one property profile.
2. Every building belongs to one canonical property and has exactly one building profile.
3. Every unit belongs to one canonical building and has exactly one unit profile.
4. Property/building/unit references are unique and foreign-key relationships resolve.
5. Every primary address and primary access point is unique per property; all additional addresses/access points are explicitly typed.
6. Every organisation has one canonical identity; every business has one business profile and unique business number.
7. No business employee/person, owner/person, tenant/person or institutional employee creates a duplicate person identity.

### Title, occupancy and sites
8. Registered owner, beneficial owner, landlord, tenant, leaseholder, manager and mortgagee remain distinct interest/party roles.
9. Interest validity periods do not overlap impossibly for exclusive interests; joint ownership shares reconcile when complete.
10. Every active business site resolves to an existing property and, where applicable, a valid unit in a building on that property.
11. Current exclusive unit occupancy cannot be assigned to unrelated organisations simultaneously; explicit shared/concession arrangements are allowed and identified.
12. Lease/site agreement dates, status, parties and scope are internally consistent; expired or terminated agreements remain historical.
13. Business relocation closes or dates the former site relationship and establishes the new one without changing the business identity.
14. A property can be vacant, partially occupied or multi-occupied without contradicting its unit-level occupancy.

### Physical and operational consistency
15. Building floors, units, floor labels and unit floor numbers reconcile where both are present.
16. Building footprint and property parcel geometry use the same BP-02 local coordinate reference and remain within the city map bounds.
17. Utility, fire, safety, access and security summaries are attached to the correct property/building/unit level.
18. Property/building condition summaries do not erase dated inspection, defect or repair history.
19. Business opening hours and site operating hours are distinguishable; a business may have multiple sites with different schedules.
20. Organisation hierarchy and site hierarchy do not create duplicate organisations or duplicate premises.

### Integration and access
21. BP-03 residential allocation and employment links resolve to BP-04 dwelling, workplace and organisation identities.
22. Police, dispatch, incident, case and scene references resolve to BP-04 locations without copying location identities.
23. Dossier commands return complete linked data in bounded, readable sections and preserve the existing command fallback chain.
24. Read-only queries do not initialise or advance fictional time.
25. Writes are actor-attributed, permission-checked, idempotent where appropriate and historically traceable.
26. Private game records remain inaccessible through unintended public access; BP-42 governs character-level access to sensitive property/business details.
27. Regression tests cover existing baseline records and all new detail without creating duplicate properties, buildings, units, addresses, organisations, businesses or people.
28. Test fixtures roll back and do not alter the live fictional world or clock.

## 14. Implementation sequence

1. **Preserve and verify baseline:** keep all current BP-04 identities, profiles, sites, interests, seeded data and commands.
2. **Detailed dossier coverage audit:** measure completeness of title, ownership, lease, unit occupancy, business identity, site, hours, utilities, safety and condition fields; report missing values rather than inventing them.
3. **Property interest and agreement refinement:** ensure owner/landlord/tenant/manager roles and agreement histories are independently retrievable.
4. **Business and institution refinement:** complete registration, ownership/control, lifecycle, site-role and organisation-hierarchy information without duplicating BP-03 people.
5. **Building/unit operational detail:** improve floor, access, utility, condition and occupancy descriptions, using existing profile records.
6. **History and provenance:** connect changes to shared BP-38 conventions and runtime timestamps from BP-35/BP-37.
7. **Dossier/query presentation:** extend existing commands in place; preserve names, parser fallback and idempotency.
8. **Regression and integration:** run the acceptance checks above and verify BP-02/BP-03/police/scene references.
9. **Update status honestly:** distinguish baseline implementation, detailed data coverage, live workflow and remaining runtime dependencies.

## 15. Current verified baseline snapshot

Live Supabase counts checked on 2026-11-20:
- 656 properties and 656 property profiles.
- 656 buildings and 656 building profiles.
- 26,888 building units and 26,888 unit profiles.
- 656 primary property addresses.
- 656 primary property access points.
- 1,490 total organisations, including 1,452 business profiles.
- 1,477 current organisation-location records.
- 1,608 current property-interest records.
- 43,412 current organisation-personnel links.

The following integrity checks returned zero exceptions:
- Properties without a profile or with multiple profiles.
- Buildings without a profile.
- Units without a profile.
- Business organisations without a business profile.
- Businesses without a current site.
- Properties without a current registered-owner interest.
- Properties without exactly one primary address or primary access point.
- Duplicate business numbers.
- Multiple unrelated current business occupiers assigned to the same unit.
- Difference between current organisation-personnel links and the sum of business employee estimates.

This is a focused integrity check of the listed invariants, not proof that every refinement requirement above has been implemented. A complete BP-04 detailed-coverage audit and acceptance suite is still required before the refined scope can be called complete.

**Fictional-world rule:** All Kingswell properties, titles, owners, businesses, organisations, agreements, valuations, dates, facilities and events are fictional game data.
