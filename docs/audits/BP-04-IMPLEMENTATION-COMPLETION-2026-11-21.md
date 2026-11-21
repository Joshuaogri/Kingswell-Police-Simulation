# BP-04 Implementation Completion Record — 21 November 2026

## Scope

This implementation completes the BP-04 property, building, unit, business and organisation systems for the fictional Kingswell police simulation. The approved BP-01–BP-44 blueprint is unchanged.

All generated business ownership, contract terms, asset inventories, infrastructure baselines and operational profiles are fictional Kingswell game data. They are not representations of real people, businesses, properties or transactions.

## Implemented

### Business and organisation records
- Individual business operational profiles now expose product/service lines, inventory and stock controls, supplier and delivery operations, commercial/payment operations, staffing, customer/visitor access, security context and record controls.
- Organisation structures are generated from canonical employment records and existing job titles.
- Each employee receives an organisation, department and position assignment.
- Department-lead positions are explicitly vacant. No employee is silently promoted and no supervisor is inferred.
- Organisation and business dossiers expose the new operational and structural sections.

### Ownership, title, agreements and occupancy
- Fictional control-interest/shareholder records are generated for every business using canonical Kingswell people and the business legal-form share model.
- Current registered-owner interests receive initial title-register snapshots. Historic conveyance dates and transferors are not invented.
- Missing lease counterparties are linked to the canonical registered owner of the premises.
- All lease agreements receive a generated execution/effective date, rent, currency, frequency, deposit, permitted use, restrictions, repair/service-charge responsibilities, subletting status and notice period.
- Each agreement receives executed and commenced lifecycle events.
- Existing occupancy/site records remain the canonical site and occupancy register; contract dates are stored separately and are not copied from occupancy dates.
- Business registration lifecycle events use the canonical incorporation dates.

### Property assets, infrastructure and maintenance
- Every building-system profile produces individual asset inventory records for its applicable systems.
- Every building unit receives a unit-level infrastructure profile for utilities, telecoms, heating/cooling, fire systems, access control and metering.
- Each generated asset receives a baseline inspection record with the inspection date explicitly unknown.
- Each building receives a condition-assessment event derived from its existing fictional building profile.
- Existing property-development/planning event capture and history commands remain in the canonical property dossier and are now composed with asset and maintenance history.

### Exact premises identity across police workflows
- Incidents now retain property, building and unit identity with hierarchy validation.
- Scenes inherit the incident's canonical premises when no separate scene premises are specified; explicit scene premises can be recorded and corrected with append-only history.
- Evidence items carry exact property/building/unit references. Scene evidence recovery records append the precise recovery premises.
- Case-lead site links inherit the exact property/building/unit from the canonical site dossier.
- Search premises now carry optional building/unit identity with hierarchy validation and append-only location history.
- Incident-location site associations must match the incident's recorded property and, where known, building and unit.
- Scene response, case review, incident, business, organisation, site and property dossiers expose the relevant exact premises, asset, infrastructure, agreement and evidence context.

## New player commands

- `scene premises set <scene_ref> <property_ref> <building_ref|unknown> <unit_ref|unknown> because "<reason>" by <personnel_ref>
- `scene premises get <scene_ref> by <personnel_ref>
- `search premises set <premises_ref> <building_ref|unknown> <unit_ref|unknown> because "<reason>" by <personnel_ref>
- `search premises get <premises_ref> by <personnel_ref>

All commands use the existing command audit and idempotency chain.

## Regression coverage added

- Business operational profile completeness.
- Organisation department/position/assignment reconciliation and cross-organisation/site consistency.
- Ownership/control population for every business.
- Title snapshots reconciled to current registered-owner interests.
- Agreement counterparty and contract-term completeness, plus executed/commenced event history.
- One infrastructure profile per canonical unit.
- Asset inventory, inspection and building condition event coverage.
- Seed idempotency.
- Incident-to-scene-to-evidence property/building/unit propagation.
- Scene premises command and scene response dossier.
- Business, organisation and site dossier composition.
- Existing case lead and evidence premises consistency.

## Verification state

The complete isolated PostgreSQL migration-chain and gameplay regression workflow is the acceptance gate. Do not mark BP-04 complete until the latest workflow for the final commit reports success.

The live Supabase project is separate from the isolated CI database. This record does not claim that a live deployment or live population has occurred.
