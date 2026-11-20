# Kingswell Master Blueprint — Division Register

**Status:** All 44 divisions BP-01 to BP-44 are approved as the Kingswell design baseline on 2026-11-20. This register records design approval, not software implementation or closure of every refinement note.

Each division is designed with its purpose, scope, responsibilities, components, required information, inputs, outputs, dependencies, connections, operating rules, permissions, exceptions, tests and acceptance conditions.

| ID | Division | Current status |
|---|---|---|
| BP-01 | Game Identity, Foundations and Governing Rules | Approved |
| BP-02 | Country, City and Geographical Architecture | Complete and verified at KNG-MAP-0.3; Asterfell's eight-region hierarchy, Kingswell city grid, 12 districts/24 neighbourhoods, 75 uniquely named connected roads/157 junctions/229 geometry-backed segments/3 bridges/24 rear service lanes/24 landmarks, 480 secondary entrances, 96 one-way neighbourhood-loop segments, 266 no-U-turn controls, 16 signalised turn bans, 458 weekday traffic profiles, dynamic road-condition/closure support, full patrol-beat coverage and simulation-clock-aware dispatch routing; directed reachability and all 18 targeted geography/operations regressions pass |
| BP-03 | Population and Individual Simulation Architecture | Complete static foundation and live-seeded: 100,000 unique NPCs, 24,512 households, 100,000 exact residential addresses and memberships, 309,760 relationships, 100,000 birth events, 700,000 sleep routines, 43,412 business employees and 217,060 weekday work routines; dwelling capacities and business headcounts reconcile; live acceptance checks pass; actual activity execution awaits BP-35/BP-37; fictional clock remains uninitialised |
| BP-04 | Buildings, Properties, Businesses and Organisations | Baseline implemented and regression-tested: 656 properties/buildings, 26,888 units, 1,452 businesses, 25 public institutional sites. Detailed audit completed; KNG-MAP-0.3 geometry metadata aligned, 656 valuation snapshots and 1,232 formal tenant-site agreements added, property/business dossier outputs extended, and asset-event plus organisation-control registers created. All 1,452 business operational/security/access profiles and current business-site dossiers enriched. Property/building/unit tranche: 656/656 individually differentiated property site/planning summaries; 656/656 uniquely referenced building system-design dossiers; 26,888/26,888 individually differentiated unit access summaries and unit-referenced metering profiles. Agreement lifecycle tranche: append-only dated event register and dedicated agreement dossier query added; history starts empty rather than inventing renewals, variations, notices, expiry or disputes; immutable event regression passes. Lease tranche: all 1,232 agreements have field-by-field term-coverage registers; occupancy dates are not treated as contract dates; 1,080 counterparties linked, 152 remain unknown despite registered-owner records (no owner-to-landlord assumption). Ownership-control register has exact-holder/date/share constraints, duplicate-current-role prevention and timeline indexes; remains empty because no source-supported owner/director identities are present in current personnel/organisation records. Organisation tranche: 1,490/1,490 organisation and institution dossiers added, with linked business/site/property/control/agreement context and a unified organisation dossier query; legal identity, governance, regulators, directors and parent links remain unknown unless supported by canonical records. Workforce tranche: 13 job-role catalogue entries and 43,412/43,412 existing employment dossiers; organisation and person employment queries added. Departments, supervisors, physical site assignment, schedules and access authority remain unknown pending authoritative in-game records. Site dossier tranche: 1,477/1,477 existing organisation sites have grounded site dossiers. Added department, position/reporting-line and employment-assignment framework with query functions; these structures remain empty until recorded in-game. Property-interest tranche: 1,608/1,608 existing registered-owner, landlord and property-manager interests now have holder-resolved dossiers. 1,232/1,232 occupancy agreements have field-level review dossiers; 152 counterparties remain explicitly unresolved and missing contract terms remain unknown. Added property-interest and agreement-review queries. Remaining: source-backed title/transfer history, beneficial-owner/mortgage records where established, landlord/counterparty resolution, actual contract terms, genuine planning/asset histories, physical device inventories, workforce assignment workflows, event-capture/write/runtime workflows and browser interfaces. BP-04 remains in progress. See `docs/audits/BP-04-INDIVIDUAL-BUSINESS-PROFILES-2026-11-20.md` and `docs/audits/BP-04-DETAILED-COVERAGE-AUDIT-2026-11-20.md` |
| BP-05 | Police Architecture | Approved; detailed structure open |
| BP-06 | Police Personnel | Approved |
| BP-07 | Career System | Approved; detailed rules remain open for refinement |
| BP-08 | Units and Deployment | Approved; roster-validated deployment, individual acknowledgement and on-scene arrival implemented; resource, qualification, command and remaining deployment lifecycle remain outstanding |
| BP-09 | Police Resources | Approved; details to refine with later operational divisions |
| BP-10 | Patrol Operations | Approved; roster-validated patrol dispatch, individual acknowledgement and arrival state implemented; patrol presence and wider field-response workflows remain outstanding |
| BP-11 | Emergency Communications | Approved; text call intake, linked incident creation, roster-validated dispatch and individual acknowledgement/arrival events implemented; radio integration and live dispatch-console workflows remain outstanding |
| BP-12 | Incident Management | Approved; incident intake, dispatch, attendance, linked scene records, field reports and resource requests implemented; ownership transfer, full incident lifecycle and closure remain outstanding |
| BP-13 | Crime Architecture | Approved; detailed fictional offence catalogue to populate |
| BP-14 | Crime Generation | Approved; frequency and behaviour tuning to follow |
| BP-15 | Case Management | Approved; investigative methods and legal review to refine |
| BP-16 | Investigation | Approved; specialist procedures and legal powers to refine |
| BP-17 | Victims and Witnesses | Approved; specialist safeguarding and legal procedures to refine |
| BP-18 | Suspects and Offenders | Approved; legal-status interfaces and specialist procedures to refine |
| BP-19 | Interviews and Interrogations | Approved; legal safeguards and specialist procedures to refine |
| BP-20 | Surveillance | Approved; statutory definitions, authorisations and oversight to refine |
| BP-21 | Intelligence | Approved; statutory powers, source handling and governance to refine |
| BP-22 | Crime Scenes | Approved; scene designation/control, manager transfer, activity/access/safety/boundary histories, resource responses, release/reopening, qualified specialist attendance, manager-authorised examination plans, examiner start/completion/cancellation and examination result records implemented; detailed zones, multi-agency command, specialist hazard response, contamination, evidence handover and review remain outstanding |
| BP-23 | Evidence Management | Approved; evidential rules, retention and professional standards to refine |
| BP-24 | Forensics | Approved; scene examination/recovery and first laboratory workflow implemented: case-linked requests and triage, laboratory intake through canonical custody transfer, method registry with independent qualified validation review, qualified examiner assignment, structured findings, independent qualified technical review and versioned reports. Service capability catalogue, external-provider routing, full method-validation evidence, QA/proficiency, raw data/derivatives, disclosure/court interfaces and seeded end-to-end tests remain outstanding |
| BP-25 | Arrests and Warrants | Approved; legal thresholds, warrant types and procedures remain open |
| BP-26 | Custody Management | Approved; detention law, facility standards and safeguards remain open |
| BP-27 | Legal Processes | Approved; legal framework, charging model and procedural rules remain open |
| BP-28 | Courts and Outcomes | Approved; court hierarchy, jurisdiction and judicial rules remain open |
| BP-29 | Corrections | Approved; correctional law, sentence rules and institutional model remain open |
| BP-30 | Department Governance | Approved; statutory mandate, oversight and delegation framework remain open |
| BP-31 | Professional Standards | Approved; conduct code, complaints jurisdiction and disciplinary framework remain open |
| BP-32 | Training and Development | Approved; competency catalogue, statutory requirements and qualification rules remain open |
| BP-33 | Human Resources | Approved; employment law, terms, entitlements and workforce rules remain open |
| BP-34 | Finance and Procurement | Approved; legal and financial framework remains open |
| BP-35 | Simulation Engine | Approved; typed command intake, limited text interpreter, idempotency, roster-validated dispatch, individual acknowledgement/arrival, scene control, safety, boundary, resource response, specialist attendance and examination lifecycle handlers implemented; broader runtime and NPC processing remain outstanding |
| BP-36 | Relationships and Social Context | Approved; legal and social-context rules remain open |
| BP-37 | Time and Scheduling | Approved; calendar and legal timing rules remain open |
| BP-38 | Records and Databases | Approved; 55-table private schema, 26 migrations, scene/access/field-report/resource/specialist/examination records and RLS on all tables implemented; wider domain coverage remains open |
| BP-39 | Persistence and Recovery | Approved; recovery targets and backup controls remain open |
| BP-40 | Interface | Approved; command and presentation specifications remain open |
| BP-41 | Notifications and Reporting | Approved; alert and reporting catalogue remains open |
| BP-42 | Security and Permissions | Approved; identity and access policies remain open |
| BP-43 | Testing and Quality Assurance | Approved; eight runtime, dispatch, acknowledgement/arrival, scene/field, safety/boundary, resource/lifecycle and specialist/examination SQL regression suites pass in rolled-back transactions; CI and broader quality gates remain open |
| BP-44 | Configuration and Expansion | Approved; configuration and change-control details remain open |

## Design approval and implementation status

Approval applies to the complete master blueprint as the accepted design baseline. Existing refinement notes in the division rows remain visible and are not reasons to restart or reapprove divisions. Software implementation is tracked separately in the Implementation Register.

## Proposed delivery stages
0. Master blueprint
1. Foundation
2. Department
3. Operations
4. Incidents and crime
5. Investigations
6. Evidence and forensics
7. Justice
8. Advanced policing
9. Living simulation
10. Comprehensive integration

Design status and software implementation status are separate. A drafted division is not a built feature.