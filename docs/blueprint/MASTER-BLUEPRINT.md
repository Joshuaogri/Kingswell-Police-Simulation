# Kingswell Master Blueprint

**Status:** Working draft — not yet approved  
**Version:** 0.1  
**Setting:** Fictional sovereign country; capital city of Kingswell  
**Rule:** This document defines the intended game. It is separate from the implementation register and technical architecture.

## BP-01 — Game Identity, Foundations and Governing Rules

### Purpose
Define the game, its boundaries and the rules that keep the simulation coherent.

### Core identity
Kingswell is a comprehensive, persistent, text-first fictional police simulation. The player experiences policing through an individual character while the game also models the department, its operations and the surrounding world sufficiently to create believable police work.

### Four experience layers
1. **Personal:** the player's character, career, qualifications, duties, relationships and day-to-day experience.
2. **Operational:** patrol, calls, incidents, response, investigations and field decisions.
3. **Institutional:** department structure, supervision, command, administration, resources and accountability.
4. **World:** people, organisations, places, routines and events that create the circumstances police encounter.

### Governing principles
- The setting, people, laws, agencies, events and procedures are fictional.
- The simulation is persistent: records and consequences carry forward.
- Text is the primary interface; graphical features may be added later but are not required for play.
- Police work is the primary deep simulation. Other institutions are modelled to the depth needed to support the game.
- The design is modular, but additions must remain coherent and must not create uncontrolled scope.
- The game distinguishes what a character may do, what requires supervisory direction, what requires an in-game legal authority, and what falls outside their role.
- Important events, decisions, changes and outcomes receive traceable records.
- Time advances through deliberate game actions and defined simulation rules; the game does not silently progress while the player is away.

### Time and player agency
The game needs a consistent date/time, shift schedules, appointments, incident and case timelines, and controlled advancement. Exact advancement rules are to be specified in the dedicated time division. Player choices drive the character; the simulation controls the world and other characters within the agreed rules.

### Scope control
A proposed addition is recorded with its purpose, boundaries, dependencies and effects on existing systems. It is incorporated into the blueprint in a controlled revision rather than silently expanding the project.

### Acceptance conditions
The game can explain its identity and boundaries; preserve continuity; distinguish player authority from organisational authority; maintain consistent time; and record consequential actions.

## BP-02 — Country, City and Geographical Architecture

### Confirmed setting
- One entirely fictional sovereign country.
- Kingswell is the political and economic capital.
- Kingswell is the country's principal commercial, financial, business, transport, logistics, industrial, trading and administrative centre.
- The city begins with **100,000 permanent residents**.
- There is no fixed population ceiling. Population may rise or fall through believable births, deaths and movement.
- Kingswell is the primary playable environment.
- The wider country exists to support national institutions, jurisdiction and cross-jurisdiction policing. Other cities do not need to be fully playable by default.

### City character
Kingswell contains specialised districts with distinct identities and functions. A provisional district-function list is:
- Government and civic administration
- Central business and finance
- Port and maritime activity
- Logistics and freight
- Passenger transport
- Industrial and manufacturing
- Wholesale and trading
- General commercial activity
- Residential communities
- Education, health and other institutions
- Airport and aviation
- Mixed development

This is a list of functions, not an approved count, final set of names or boundary map.

### Geographic hierarchy
Country → administrative region → city → district → neighbourhood → street/road → property/building → building section/unit → specific internal or external location.

Every place must have a stable identity and a clear relationship to its parent location. An incident or case location must be traceable through this hierarchy.

### What geography must support
Navigation, dispatch, patrol areas, response planning, investigations, crime analysis, property records, surveillance, deployment and future mapping.

### Wider country
National institutions, regional commands and cross-jurisdiction links are represented sufficiently for believable policing. Locations outside Kingswell are not automatically developed to the same detail as the capital.

### Still to be designed
City footprint and dimensions; district names, number and boundaries; neighbourhood layout; road network; port and airport placement; national administrative divisions; and travel-time model.

## BP-03 — Population and Individual Simulation Architecture

### Purpose
Create a believable population whose members can become relevant to police activity and whose lives persist over time.

### Population groups
Permanent residents, temporary residents, commuters, domestic visitors, international visitors, government personnel, commercial workers, transport workers and institutional workers. These are overlapping descriptions, not mutually exclusive headcounts. One person must never be counted twice merely because they fit several categories.

### Individual records
The proposed person record includes a unique identity, legal name, date of birth, nationality, residence status, address, occupation, employer, qualifications, household, relationships, routines, relevant history, current status and dated historical changes. Access to sensitive details is restricted within the fictional game.

### Life and activity
The world may model births and registration, childhood and education, adult life, employment, household changes, movement, migration, retirement and death. Historical records remain available where needed for continuity and cases.

### Everyday behaviour
People may work, travel, attend appointments, visit businesses, take part in public events, change jobs, move home, form or end relationships, offend, report crimes, and become victims or witnesses. Behaviour should follow routines, circumstances and plausible probabilities rather than arbitrary randomness.

### Processing intensity
A complete identity record does not require every person to be calculated continuously. The proposed model varies how actively a person is simulated according to schedules, current activity and police relevance. A person connected to an incident or case can receive more detailed attention without creating a duplicate identity.

### Open design choice
The preferred working direction is persistent individual records for everyone, with simulation effort varying by relevance and activity. This is a proposal, not yet a user-approved final rule. The alternatives are records only for active/police-relevant people, or continuous full-detail simulation of everyone.

### Acceptance conditions
People have unique identities; overlapping population categories do not cause double counting; changes are historically traceable; routines create believable activity; and police links attach to the correct person.

## BP-04 — Buildings, Properties, Businesses and Organisations

### Physical places
The property model may include land parcels, properties, buildings, building sections, units, rooms and internal spaces, external areas and access points. The level of detail depends on its use in play.

### Businesses
Business types include finance, logistics, transport, manufacturing, retail, wholesale, hospitality, professional services, construction and technology, with room for additional types when justified.

### Distinct roles
The game must distinguish property owner, landlord, tenant, business owner, director, manager, employee, contractor, security provider, supplier and customer. These are different relationships and must not be collapsed into one generic ownership field.

### Flexible occupancy
One business may operate at multiple properties. One property may contain multiple businesses or organisations. Occupancy, tenancy, ownership, employment and service relationships must be traceable over time.

### Public institutions
The wider world includes government offices, parliament, ministries, departments, police facilities, courts, prosecution, corrections, customs/immigration, hospitals, fire/rescue, education, transport authorities and regulators. These bodies are represented deeply enough to support policing, without turning the project into a full government or society simulator.

### Police uses
Locations and organisations support incident recording, occupancy enquiries, employee identification, ownership checks, CCTV and security enquiries, access records, commercial relationships, lawful in-game records requests and property-related processes.

### Acceptance conditions
The game can establish who owns, occupies, operates, manages and works at a place, including historical dates; it can represent shared premises and multi-site organisations; and it can connect relevant people and places to incidents and cases.

## BP-05 — Police Architecture

### Confirmed organisational model
**One national police service**, with a central headquarters and regional/city commands. Kingswell has a city command within that national service.

### Proposed structure
1. **National Police Service:** the single country-wide policing organisation.
2. **National Headquarters:** sets service-wide policy, standards, priorities, budgets, national coordination and specialist capability.
3. **Regional Commands:** coordinate policing across defined regions, support city commands and handle matters spanning local boundaries.
4. **Kingswell City Command:** leads day-to-day policing throughout Kingswell and is accountable within the national command structure.
5. **Local operational areas:** divide Kingswell into manageable patrol and response areas.
6. **Stations and operational bases:** provide local supervision, deployment, public access and operational support.

### Proposed functional responsibilities
- Uniformed operations and response
- Patrol and neighbourhood policing
- Emergency communications and dispatch
- Criminal investigations
- Intelligence and analysis
- Specialist operations and support
- Crime-scene and forensic services
- Arrest, transport and custody functions
- Roads and traffic policing
- Public order and major events
- Professional standards and internal investigations
- Training and development
- Personnel and welfare administration
- Finance, procurement, property and logistics
- Records, information management and technology

These are proposed responsibilities. The final division names, reporting lines and whether some functions are combined remain to be designed.

### Command and authority
The design must distinguish:
- **Rank:** the officer's place in the service hierarchy.
- **Appointment/position:** the job the person currently holds.
- **Authority:** the decisions and directions the person is entitled to make in that role.
- **Grade:** the employment or pay level, if used.
- **Clearance:** which information or facilities the person may access.

Rank alone must not automatically grant every operational, legal or information-access power.

### Coordination and accountability
The service needs clear supervision, escalation, incident command, cross-region coordination, national specialist support, resource allocation, records ownership and review of decisions. Police responsibilities must remain distinct from courts, prosecution, corrections, health, fire/rescue and other public bodies.

### Staffing principles
Staffing grows with workload, geography, population and service responsibilities. Every employee has an individual record, defined role, supervisor, posting, qualifications, training and employment history.

### Still to be designed
Final national and regional map; exact rank structure; headquarters departments; Kingswell command chart; station and patrol-area layout; staffing establishment; appointment powers; and detailed reporting lines.


## BP-06 — Police Personnel

### Purpose
Define every person employed by the National Police Service as an individual, persistent member of the organisation. Personnel records support recruitment, training, deployment, supervision, performance, discipline, promotion, transfer, leave, retirement and workforce planning.

### Personnel identity
Each employee has one permanent service identity number. Their record contains:
- Legal and preferred name, date of birth and identity details needed by the fictional service.
- Employment status and service history.
- Current rank, grade (if used), appointment, position and assigned unit.
- Current posting, duty location, supervisor and command chain.
- Qualifications, specialist skills and training history.
- Operational authorisations and information-access permissions.
- Duty availability, shift pattern, leave and temporary absence.
- Performance history, commendations, development needs and formal disciplinary outcomes.
- Relevant employment documents and dated changes.

A person keeps the same service identity when promoted, transferred or assigned to a new role. Changes are recorded as history rather than overwriting the past.

### Employment lifecycle
The personnel system covers recruitment application and eligibility checks; selection and assessment; appointment and entry into service; initial training and probation; posting and operational deployment; continuing training and qualification renewal; promotion, transfer, specialist selection and temporary assignment; leave, absence, welfare support and return to duty; performance review, commendation and disciplinary processes; resignation, dismissal, retirement, death in service or other exit; and historical service records after departure.

### Employment status
The service distinguishes applicants, recruits, probationary employees, active employees, employees on leave, suspended employees, restricted-duty employees, seconded employees, employees under notice and former employees. A status change has an effective date and an authorised in-game record.

### Rank, role and permission
Personnel records keep separate fields for:
- **Rank:** seniority within the service hierarchy.
- **Appointment:** the post or office currently held.
- **Position:** the actual job and duties assigned.
- **Grade:** employment/pay band where the service uses one.
- **Authority:** decisions and directions permitted by fictional law and service rules.
- **Clearance:** access to protected records, locations or equipment.
- **Qualification:** demonstrated training or competence.
- **Posting:** the organisational unit and location to which the employee is assigned.

A promotion does not automatically confer every specialist qualification, appointment or clearance. A temporary assignment does not permanently change rank.

### Supervision and accountability
Every active employee has a defined supervisor and organisational reporting line. Supervisors handle work allocation, welfare, attendance, coaching, review and escalation. Commanders are responsible for people and resources assigned to their command. Acting appointments and temporary supervisory arrangements have start and end dates.

### Training and competence
Training is recorded by course, date, result, instructor/provider, qualification awarded and renewal requirement. The game can identify whether an employee is currently qualified for a particular duty. Expired or missing qualifications can restrict assignment to duties that require them.

### Duty availability
Personnel availability is calculated from rostered duty, leave, absence, training, suspension, restricted duty, secondment and other recorded commitments. A person cannot be assigned simultaneously to incompatible duties or locations.

### Fair employment processes
Recruitment, promotion, commendation and discipline use recorded criteria and outcomes. Formal discipline includes an allegation, evidence, notice, response, decision-maker, finding, sanction (if any), review or appeal route, and final outcome. An allegation alone is not a finding of misconduct.

### Personnel privacy
Personnel information is available only to roles that need it for their duties. Operational users see information required for deployment and safety; authorised personnel and professional-standards staff may access additional employment records. Access to sensitive records is traceable.

### Workforce planning
The service monitors vacancies, staffing by rank and function, workload, skills shortages, training capacity, leave, retention and retirement forecasts. Recruitment and promotion respond to organisational needs rather than arbitrary unlimited hiring.

### Acceptance conditions
- Every employee has one stable personnel identity.
- Current and historical rank, appointment, position, unit and supervisor can be reconstructed for any date.
- The system prevents incompatible simultaneous assignments.
- Required qualifications and authorisations can be checked before deployment.
- Employment status and availability affect rostering correctly.
- Formal disciplinary records distinguish allegations from proven findings.
- Access to confidential personnel information is controlled and auditable.

---
**Draft status:** BP-01 to BP-06 contain the current working decisions and proposals. Unresolved items remain explicitly open. This document is not declared final or approved.


## BP-07 — Career System

### Purpose
Define how the player and other police employees enter the service, build a career, gain experience, qualify for roles, progress, move between assignments and eventually leave the service. The career system turns personnel records into a meaningful long-term working life.

### Career identity and service record
Each employee has one continuous service history linked to their permanent personnel identity. The career record tracks entry route, appointment date, probation, postings, duties, ranks, promotions, acting appointments, specialist assignments, qualifications, commendations, performance reviews, disciplinary outcomes, leave and absence that affect service, and exit from the service. Historical entries remain visible after a person changes role or leaves.

### Entry and recruitment
The service recruits against actual or planned vacancies. Recruitment routes may include new recruit entry and, where the service later defines them, specialist or experienced-entry routes. Each campaign records the vacancy, eligibility requirements, application, assessment stages, decision and appointment. Applicants are not police employees until formally appointed in the game.

### Initial career and probation
New recruits complete the required entry training and any probationary period. During this period, duties and supervision reflect their current competence and authorisations. Successful completion changes their employment status and eligibility for ordinary assignments; unsuccessful completion may lead to extension, reassignment or exit under the fictional service rules.

### Rank progression
Rank is the employee's position in the formal service hierarchy. Promotion depends on eligibility, service need, vacancies, required experience, performance, conduct, qualifications, assessment and completion of required training. Time served alone does not guarantee promotion. The game records eligibility, application or nomination, assessment, selection, effective date and any acting period separately.

### Appointments and postings
A career is not a straight ladder. Employees can move between stations, commands, divisions and specialist functions without necessarily changing rank. Appointments and postings are based on organisational need, competence, vacancies, operational demand and employee suitability. A person may be assigned temporarily to an acting or project role with a defined start and end date.

### Specialist careers
Specialist duties require the relevant selection, training, qualification and authorisation. Examples may include detective work, forensic services, intelligence, traffic, public order, firearms or other specialist capabilities if those functions are included in the approved police architecture. A rank promotion does not automatically grant specialist competence.

### Performance and development
Career reviews consider work quality, reliability, judgement, conduct, teamwork, leadership where relevant, training and role-specific results. Performance records should be balanced and contextual: workload, available resources, assignment difficulty and verified outcomes matter. A single unsubstantiated complaint or allegation must not automatically determine a career outcome.

### Discipline and career effects
Formal findings may affect eligibility for promotion, specialist selection or certain appointments according to the seriousness and relevance of the outcome. Allegations, investigations and findings remain distinct. Career consequences must follow recorded procedures and must not be applied as automatic punishment before a finding.

### Transfers and organisational need
The service may transfer or reassign employees to meet operational needs. The system records the reason, authorising role, effective date, receiving unit, handover and any effect on current duties. Employee preferences may be considered but do not override service requirements. Emergency or temporary deployments are recorded separately from permanent postings.

### Leave, absence and career continuity
Leave, sickness absence, training periods, suspension, restricted duties and secondment affect availability and may affect particular experience or eligibility calculations according to rules defined by the service. The system must not treat every absence as misconduct or automatically erase service history.

### Career exit
Career exit may occur through resignation, retirement, dismissal, death in service, contract end or another defined route. The system records the effective date, reason category, outstanding property or access matters, final status and retained historical record. Former employees remain identifiable in historical incidents, investigations and personnel records.

### Player career experience
The player experiences the career through available vacancies, training opportunities, postings, supervisors, performance reviews, promotion processes and the consequences of their decisions. The game should show the requirements and current eligibility for an opportunity, but should not guarantee an outcome merely because the player requests it.

### Career information and permissions
Employees can view their own career information and relevant opportunities. Supervisors can view information needed to manage their staff. Promotion boards, personnel administrators and professional-standards roles receive only the access required for their functions. Career decisions and changes are recorded with the responsible decision-maker and effective date.

### Acceptance conditions
- Every employee's career is linked to one stable personnel identity.
- The full career timeline can be reconstructed for any date.
- Rank, appointment, posting, qualification and authority remain distinct.
- Recruitment is linked to actual or planned vacancies.
- Promotion requires defined eligibility and a recorded decision.
- Temporary acting assignments do not overwrite substantive rank or posting history.
- Specialist roles require the appropriate qualification and authorisation.
- Performance, allegations, findings and career consequences are separately recorded.
- Availability and career status correctly affect deployment eligibility.
- Former employees remain traceable in historical records.


## BP-08 — Units and Deployment

### Purpose
Define how the police service is divided into working units and how people, vehicles, equipment and other resources are assigned to actual duties. This division connects the organisation chart to day-to-day operations.

### What counts as a unit
A unit is a recognised part of the service with a defined purpose, supervisor or commander, staffing, responsibilities and place in the organisational structure. Units may be permanent or temporary, geographic or specialist, operational or support. A unit is not the same thing as an individual employee's rank or appointment.

### Unit types
- **Command units:** national, regional and city commands that hold management responsibility for a defined area or function.
- **Geographic units:** districts, areas, stations, neighbourhood teams and patrol sectors responsible for policing a defined location.
- **Functional units:** teams responsible for a particular kind of work, such as investigations, intelligence, traffic, custody or training.
- **Specialist units:** teams with additional selection, training, equipment or authorisation for specialist tasks.
- **Temporary units:** task forces, major-incident teams, event teams or joint groups created for a defined purpose and period.
- **Support units:** teams providing communications, fleet, logistics, records, facilities, technology or administrative support.

### Unit identity and records
Each unit has a stable identifier, official name, unit type, parent command, purpose, responsibilities, geographic or functional remit, supervisor, authorised staffing level, current staffing, operating status, base location and history. Changes to name, remit, parent command, location or status are dated and retained.

### Organisational hierarchy
Units sit within a clear parent-child structure. Each employee has one substantive home unit at a time, while temporary attachments and cross-unit duties are separately recorded. The system must be able to reconstruct which unit was responsible for a person, function or area on any historical date.

### Geographic responsibility
Geographic units have defined areas of responsibility using the city geography. Boundaries should be clear enough to determine which unit normally handles a call, incident, patrol assignment or local enquiry. Overlapping specialist responsibilities are recorded separately from geographic ownership.

### Staffing establishment
Each unit has an authorised staffing establishment by role, rank or skill where appropriate. Actual staffing is calculated from current personnel records and postings. Vacancies, temporary attachments, leave, training and restricted duty must be visible so a unit's apparent headcount is not mistaken for its available operational strength.

### Deployment types
- **Substantive posting:** the employee's normal organisational home.
- **Rostered duty:** the scheduled shift or work period.
- **Operational assignment:** the specific task, area, vehicle, team or incident to which the employee is assigned for a period.
- **Temporary attachment:** a time-limited assignment to another unit while retaining the substantive posting unless formally changed.
- **Acting appointment:** temporary performance of a defined higher or different position, with explicit limits.
- **Mutual aid or cross-command support:** a recorded deployment outside the employee's usual command, with clear command and reporting arrangements.

### Deployment decision factors
Assignments consider operational demand, location, workload, staff availability, rank and supervisory needs, qualifications, authorisations, equipment, fatigue and safety. A person must not be assigned to duties for which they lack required competence or authority. The system should show why a deployment is unavailable rather than silently assigning an unsuitable employee.

### Command during deployment
Every deployment has a responsible supervisor or incident commander. When staff from different units work together, the record identifies who directs the task, who retains personnel responsibility, how information is shared and when command returns to the normal structure. Temporary command arrangements have start and end conditions.

### Resource deployment
Vehicles, radios, specialist equipment, facilities and other resources can be assigned to units and duties. Each resource has an identity, status, location, availability and any required operator qualification. The system prevents a resource from being committed to incompatible assignments at the same time.

### Unit operating status
A unit may be active, forming, temporarily reinforced, reduced, suspended, reorganised or disbanded. The reason, authorising command, effective dates, staff movements and transfer of open work are recorded. Disbanding a unit does not erase its historical cases, actions or accountability.

### Work allocation and continuity
Work can be allocated to a unit, then assigned to a team or individual. The record shows the current owner, responsible supervisor, status, due dates where relevant and handover history. Transfers between units preserve the work history and prevent cases or incidents from becoming ownerless.

### Player interaction
The player can view their home unit, supervisors, team, current duty, available assignments and relevant deployment instructions. The player may express preferences where the service allows, but operational requirements and eligibility determine the final assignment. The game communicates the reason for significant changes in deployment.

### Permissions and records
Unit commanders can manage work and staffing within their authority. Personnel administrators manage formal postings. Dispatchers and operational supervisors can view live availability and make permitted operational assignments. Resource managers control equipment status. All significant changes record who made them and when.

### Acceptance conditions
- Every unit has a stable identity, purpose, parent and responsible supervisor.
- Unit structure and responsibility can be reconstructed for any historical date.
- Geographic responsibilities can be used to route work to the correct command or unit.
- Authorised establishment is distinct from actual and available staffing.
- Substantive posting, rostered duty, operational assignment and temporary attachment are distinct.
- Deployments respect availability, competence, authority and resource constraints.
- Cross-unit deployments have clear command and reporting arrangements.
- Vehicles and equipment cannot be double-booked for incompatible tasks.
- Unit reorganisation preserves historical records and transfers open work.
- Every significant assignment and handover is traceable.

## BP-09 — Police Resources

### Purpose
Ensure the National Police Service has the vehicles, equipment, communications devices, facilities, supplies and specialist assets needed to perform its work. Resources must be identifiable, available when required, assigned to the right people and units, maintained, replaced and accounted for throughout their working life.

### Scope
This division covers the service's physical and operational resources and their day-to-day availability. It connects resource ownership and condition to units, personnel, rosters, deployments, incidents and specialist work.

It does not own:
- Employee identity, staffing or qualifications, which belong to BP-06 and BP-07.
- Unit structure and deployment authority, which belong to BP-08.
- The design of buildings, land and business premises, which belongs to BP-04.
- Budget policy, purchasing rules and financial accounting, which belong to BP-34.
- The detailed operation of dispatch, patrol or investigations, which belong to their respective divisions.

### Resource groups
The service may hold and manage the following resource groups:

1. **Vehicles:** patrol cars, response vehicles, motorcycles, vans, transport vehicles, traffic vehicles, command vehicles, specialist vehicles and trailers.
2. **Personal issue equipment:** uniforms, protective clothing, identification, duty belts, safety equipment and role-specific items.
3. **Operational equipment:** torches, barriers, scene equipment, search tools, measuring devices, recording equipment and other task-specific tools.
4. **Communications:** radios, mobile devices, headsets, chargers, repeaters and related accessories.
5. **Technology:** computers, tablets, printers, body-worn devices, cameras, storage devices and approved software equipment.
6. **Specialist assets:** equipment held for forensic work, public-order operations, roads policing, search, rescue support, surveillance and other specialist functions.
7. **Facilities and bases:** stations, offices, briefing rooms, garages, stores, interview rooms, custody-related facilities and other police-controlled premises. Their physical identity remains part of the property system.
8. **Consumables and supplies:** fuel, stationery, batteries, medical supplies, protective disposables, evidence packaging and routine operational stock.

These categories are expandable where a genuine policing need exists. They do not require every possible item to be individually modelled from the beginning.

### Resource identity and record
Every managed asset receives a stable unique identifier appropriate to its type. Its record may include:
- Official name, category, description and identifying number.
- Owning service or external provider.
- Responsible unit and normal storage or base location.
- Current custodian or assigned user, where applicable.
- Current condition and operational status.
- Purchase, receipt, issue or commissioning date.
- Manufacturer, model and serial number where relevant.
- Required operator qualification or authorisation.
- Inspection, servicing, calibration and renewal history.
- Damage, loss, repair, restriction and retirement history.
- Linked documents and inventory checks.

Consumables may be tracked by stock item, quantity, location, batch or expiry date where that level of detail is useful. They do not each need a permanent individual identity.

### Availability and condition
A resource has a clear current state. Typical states include available, assigned, in use, reserved, under inspection, under repair, damaged, missing, restricted, out of service and retired. The exact states depend on the resource type.

Availability is not the same as existence. A vehicle that is under repair, a radio with a fault or a device assigned to another team must not appear as freely available. Condition and restrictions affect what the resource can be used for.

### Assignment and custody
Resources can be assigned to a service, command, unit, team, vehicle, employee, location, incident or specific task as appropriate. The record distinguishes:
- Ownership by the service.
- Responsibility for the asset.
- Physical custody.
- Temporary issue to a user or team.
- Operational assignment for a particular duty.
- Return, transfer or handover.

A resource can have only one incompatible active assignment at a time. Temporary issue and return are dated. Handover records identify the outgoing and incoming custodian where that matters.

### Vehicles and fleet
Vehicle records include registration or fleet identifier, type, make/model, operational role, home base, assigned unit, status, mileage or usage readings, fuel or energy status where modelled, inspection dates, service history, damage, faults and availability.

Vehicle assignment must account for:
- Whether it is available and roadworthy in the fictional game.
- Whether the intended driver is authorised and suitably qualified.
- Whether the vehicle is suitable for the task and operating area.
- Whether required equipment is present.
- Whether it is already committed to another duty.

Vehicle use can generate records such as allocation, crew, start/end readings, refuelling, defect reports, collision/damage reports and return-to-base. A vehicle is not silently teleported between locations; its movement follows the game's time and travel rules.

### Equipment issue and compatibility
Some duties require particular equipment, and some equipment may only be used by suitably trained or authorised personnel. The system checks requirements when an assignment is made and can identify missing, expired, incompatible or unserviceable items.

Standard issue lists may be defined by role, unit or duty type. They are baselines rather than proof that an item is physically present. Actual issue, return, replacement and loss are recorded.

### Maintenance and inspection
Assets that require maintenance have service intervals, inspection schedules or condition checks. The system can generate due and overdue work, record inspection outcomes, identify defects and restrict unsafe or unserviceable assets. Repair history remains attached to the asset.

A resource returns to available status only when the required repair, inspection or check has been recorded as complete. A user cannot clear a defect merely by changing the displayed status without the required record.

### Stock and replenishment
Stores track quantities received, issued, transferred, reserved, consumed, damaged, expired and written off. Minimum stock levels can trigger replenishment notices. Stock movements identify the item, quantity, source, destination, date and responsible person or unit.

The procurement and financial process is handled by BP-34. This division supplies the operational need and records receipt, storage and issue.

### Loss, damage and misuse
Lost, damaged, stolen, contaminated, misused or unaccounted-for resources create a traceable report. The record may link to an incident, employee, unit, vehicle, location or investigation. A report does not itself establish fault; any employment or misconduct finding belongs to the relevant personnel and professional-standards processes.

### Resource planning
Commanders can view resource holdings, current assignments, availability, shortages, maintenance needs and demand by unit or function. Resource planning considers workload, geographic coverage, specialist capability, shift patterns and expected demand. A unit's inventory total must not be mistaken for the number of assets currently serviceable and available.

### Connections to other divisions
- **BP-04:** facilities, bases, stores and physical locations.
- **BP-06:** personnel identity, issue responsibility and employee records.
- **BP-07:** qualifications and role eligibility for resource use.
- **BP-08:** unit ownership, staffing and operational deployment.
- **BP-10 to BP-12:** patrol, dispatch and incident-related resource allocation.
- **BP-16 to BP-24:** investigation, scene, surveillance and forensic equipment.
- **BP-30 to BP-34:** governance, training, workforce and procurement responsibilities.
- **BP-37 to BP-39:** schedules, asset history, records and persistence.
- **BP-42 and BP-43:** access control, audit and verification.

### Player interaction
The player can see resources issued to them, the condition and availability of assigned equipment, the vehicle or team resources allocated to a duty, and any return or defect-reporting requirements. The player can report a fault, request an item, record a return or identify a shortage through the relevant in-game interaction. The game communicates when missing or unserviceable resources affect an assignment.

### Permissions and accountability
- Employees can view and report on resources relevant to their duties.
- Custodians can record issue, return and condition changes within their responsibility.
- Unit supervisors can view and manage unit holdings within their authority.
- Fleet, stores and specialist resource staff manage maintenance and inventory records for their areas.
- Procurement and finance staff handle purchasing and financial records under BP-34.
- Significant issue, transfer, repair, write-off and retirement actions retain who, what and when information.

### Exceptions and edge cases
The design must handle shared equipment, pooled vehicles, temporary loans, inter-unit transfers, emergency allocation, external hire, equipment attached to a vehicle, missing serial numbers, consumable batches, expired stock, damaged returns, staff leaving while holding issued property, assets moved between bases, and resources temporarily unavailable during an incident. Historical records must remain intact when an asset is replaced, renamed, transferred or retired.

### Acceptance conditions
- Every managed asset can be uniquely identified and its current status established.
- Ownership, responsibility, custody and operational assignment are distinguishable.
- An unavailable or unserviceable asset cannot be allocated as if it were ready for use.
- Vehicle assignment checks driver eligibility, vehicle suitability and conflicting commitments.
- Equipment requirements can be linked to roles, qualifications and duties.
- Issue, return, transfer, maintenance, inspection, loss and retirement are traceable.
- Consumable stock movements reconcile quantities over time.
- Unit commanders can distinguish total holdings from serviceable available resources.
- Resource shortages and faults can affect deployment and are visible to the relevant users.
- Historical resource records remain available after transfer, replacement or retirement.

**Draft status:** BP-09 is a working design. Resource categories and operational rules can be refined as later divisions define their requirements. It is not a claim that any resource-management software has been implemented.

## BP-10 — Patrol Operations

### Purpose
Define how uniformed officers and patrol teams provide the everyday visible police presence across Kingswell. Patrol is the service's main front line: it responds to calls, prevents and detects crime, assists the public, identifies emerging problems and creates the first police record of many events.

### Scope
This division covers routine and directed patrol, neighbourhood presence, officer activity while on duty, field observations, public contact, patrol task completion and shift handover. It connects personnel, units, resources, dispatch and incident management.

Emergency call intake and dispatch control are defined in BP-11. Formal incident ownership and progression are defined in BP-12. Investigative casework is defined in BP-15 and BP-16.

### Patrol organisation
Patrol is organised through Kingswell's geographic areas, districts, neighbourhoods and stations. Each patrol area has a defined location boundary and a responsible command or unit. The number and names of areas remain part of the city-design process.

Patrol coverage may include:
- General response patrol.
- Neighbourhood and community patrol.
- Commercial, business and financial district patrol.
- Residential area patrol.
- Port, freight, industrial and transport-area patrol.
- Traffic and road-focused patrol.
- Directed patrol around recurring problems or specific events.
- Foot, vehicle, cycle or other suitable patrol methods.

A specialist unit may patrol or operate in an area for a functional purpose without replacing the geographic unit's overall responsibility.

### Duty and shift
Each patrol officer works from a rostered duty period with a defined start, finish, home unit, supervisor and expected availability. The duty record connects the officer to their team, vehicle or other transport, equipment and assigned area.

A shift includes briefing, readiness checks, deployment, operational work, breaks or other recorded unavailability, return or reassignment, reporting and handover. Training, leave, sickness, restrictions and other commitments affect whether an officer is available for patrol.

The game must not assign an officer to two incompatible duties at once. Late starts, early finishes, overtime, extensions, missed breaks and unexpected absences are recorded as changes to the shift.

### Patrol assignment
A patrol assignment identifies:
- The officer or team.
- The responsible supervisor.
- The geographic area or specific task.
- The duty period and expected coverage.
- Assigned vehicle and equipment, if applicable.
- Any task-specific instructions or restrictions.
- Current status and handover information.

Assignments can be routine, directed, event-based, temporary reinforcement or incident-related. A patrol area can be rebalanced during a shift when demand changes. The reason and responsible supervisor are recorded.

### Patrol activity
Patrol activity may include:
- Visible presence and movement through assigned areas.
- Responding to dispatched calls.
- Checking on vulnerable people or places where appropriate.
- Speaking with residents, workers, visitors and business representatives.
- Conducting traffic and road-safety activity.
- Attending public events and local disturbances.
- Following up on local concerns and recurring problems.
- Observing and recording suspicious, unusual or relevant circumstances.
- Conducting lawful fictional-game checks and enquiries within the character's role.
- Supporting other units and assisting at incidents.
- Completing directed tasks and returning to normal patrol.

The simulation should create believable opportunities for both reactive and self-initiated work. It should not make every patrol minute produce a crime or major event.

### Patrol presence and movement
Patrol movement is tied to the city map, road network, travel mode, current location and game time. The system records enough movement to establish where an officer or vehicle was when a significant event occurred. Routine movement can be summarised rather than generating an excessive record for every minor step.

Travel time depends on distance, route, transport type, traffic conditions where modelled, road restrictions and the urgency or nature of the assignment. The player should be able to understand why a patrol unit is near, far from or delayed in reaching an event.

### Public contact
Patrol officers may encounter members of the public through calls, conversations, requests for assistance, reports, complaints, community activity and chance contact. A contact can be brief and informational or may create a formal incident, safeguarding action, intelligence item or follow-up task.

The system distinguishes:
- A casual interaction that requires no formal record.
- A recorded police contact.
- A request for assistance.
- A reported concern or suspected offence.
- A formal incident requiring ownership and follow-up.
- A contact that generates a separate intelligence or investigative record.

People encountered retain their existing identity; the system must not create duplicate people because the same person is met by different officers.

### Observation and field notes
Officers can record relevant observations such as time, location, persons present, vehicles, conditions, statements volunteered, actions taken and other circumstances. A field note is not automatically proof of an offence or a formal witness statement. The system records who made the note, when it was entered, the event time if different, and any later correction or addition.

Observations may be linked to a person, property, vehicle, incident, task or case. The system preserves the original context and does not silently convert an uncertain observation into an established fact.

### Patrol task and incident creation
A patrol officer may identify an event that requires formal handling. The event can be passed to dispatch or incident management, depending on how it arises. The patrol record links to the resulting incident rather than creating an unrelated duplicate.

A patrol task may be completed, partially completed, deferred, reassigned or escalated. The record states what was done and what remains outstanding. An officer must not close a task merely because the shift has ended; unfinished work is handed over to a named person or unit.

### Supervisor oversight
Patrol supervisors monitor staffing, coverage, availability, tasking, workload, incidents, welfare and performance. They may redirect patrols, assign tasks, provide support, request specialist assistance and escalate significant events. Their directions and material changes are recorded.

Supervisors can see whether an area is uncovered, a unit is committed elsewhere, an officer is unavailable or a task has been delayed. A nominal patrol allocation is not treated as actual coverage when the assigned team is unavailable.

### Player experience
The player can see their current duty, assigned area, team, supervisor, vehicle and issued equipment, active tasks, current location where relevant, dispatch messages, outstanding reports and handover requirements.

The player can choose how to carry out ordinary patrol within the game, subject to duty instructions and the character's role. The simulation should respond to choices through believable people, events, workload, travel and consequences rather than offering a single scripted route.

### Records and reporting
The patrol system records shifts, assignments, significant movements, tasks, public contacts requiring records, field notes, attendance at incidents, actions taken, delays, handovers and supervisor directions. Records use consistent timestamps and location references.

Routine activity should be summarised at a useful level. Significant events must remain individually traceable. Reports can be linked to the relevant incident, case, person, vehicle, property or unit.

### Connections to other divisions
- **BP-02 and BP-04:** city geography, streets, properties and public locations.
- **BP-06 and BP-07:** personnel, duty status, competence and career records.
- **BP-08:** patrol units, areas, assignments and command.
- **BP-09:** vehicles, radios, equipment and facilities.
- **BP-11:** emergency intake, dispatch and communications.
- **BP-12:** formal incident creation, ownership and management.
- **BP-13 and BP-14:** crime categories and the generation of events.
- **BP-15 to BP-24:** case referrals, investigation, witnesses, scenes and evidence.
- **BP-30 to BP-33:** governance, standards, training and workforce management.
- **BP-37 to BP-43:** time, records, persistence, interface, permissions and testing.

### Exceptions and edge cases
The design must handle an officer working alone, team members separating temporarily, vehicle failure, radio failure, unavailable equipment, a sudden demand surge, overlapping incidents, a patrol area left uncovered, a change of supervisor, a shift ending during an incident, an officer becoming a witness or victim, a task spanning multiple shifts, and an event discovered outside the officer's assigned area.

The system must preserve the distinction between where an officer was assigned, where they actually went, and where a significant event occurred.

### Acceptance conditions
- Patrol areas connect to the approved city geography and have clear responsibility.
- Every patrol shift links to personnel, unit, supervisor and duty availability.
- Patrol assignments account for staff, qualifications, vehicles and equipment.
- The simulation supports both dispatched and self-initiated patrol activity.
- Travel and movement are consistent with game time and geography.
- Public contacts can be recorded without duplicating person identities.
- Field observations preserve uncertainty, authorship, time and location.
- Patrol activity can create or link to formal incidents without duplication.
- Unfinished tasks and incidents are handed over rather than silently abandoned.
- Supervisors can see real coverage, availability, demand and outstanding work.
- Significant patrol decisions and actions can be reconstructed from records.

**Draft status:** BP-10 is a working design. Patrol-area boundaries, shift patterns, response standards and detailed field procedures will be refined alongside geography, dispatch and incident management. It is not a claim that patrol software has been implemented.

## BP-11 — Emergency Communications

### Purpose
Provide the communication centre that receives requests for police assistance, records what is reported, assesses urgency, creates or updates incidents and sends suitable police resources. It is the link between the public, patrol officers, supervisors and other parts of the service.

### Scope
This division covers public contact channels, call-taking, initial assessment, incident notification, dispatch, radio and operational communications, resource tracking and communication-centre supervision.

It does not define the full incident lifecycle, which belongs to BP-12, or the detailed investigation of reported crime, which belongs to BP-15 and BP-16.

### Communication centre
The National Police Service operates a central communications capability with local responsibility for Kingswell. The detailed national and regional arrangement remains to be designed. Calls and events can be routed to the appropriate geographic command while allowing cross-area coordination and national support.

The centre has defined operating roles such as call-taker, dispatcher, communications supervisor and system support staff. These are job assignments, not separate police ranks. Staff records, training and permissions connect to the personnel system.

### Contact channels
The public may contact the service through fictional in-game channels such as emergency telephone, non-emergency telephone, in-person reporting, digital report, alarm or referral from another institution. Additional channels can be introduced where they add useful gameplay.

Each contact receives a unique contact reference. Where a contact concerns an existing event, it is linked to the existing incident rather than creating an unnecessary duplicate.

### Call intake
A call-taker records the information needed to understand and route the request:
- Caller identity and reliable contact details, if known and relevant.
- Whether the caller is directly involved, reporting for someone else or anonymous.
- The reported event, concern or request.
- Location and any location uncertainty.
- Time of event, time reported and whether it is ongoing.
- Immediate risks, injuries, hazards or urgent needs reported.
- Persons, vehicles, property or other details supplied.
- Whether police or another service has already been contacted.
- Any immediate change or additional information during the contact.

The system distinguishes what the caller says from what has been independently confirmed. Information can be corrected or supplemented without erasing the original report.

### Initial assessment and priority
The call-taker assesses the request using the fictional service's priority framework. Factors may include immediate danger, threat to life, violence in progress, vulnerability, ongoing risk, likelihood of evidence being lost, public impact, location and availability of resources.

Priority is a dispatch decision, not a finding that a crime has occurred. A report may be urgent without ultimately proving an offence, and a report that initially appears minor may become urgent when new information arrives.

The priority framework, labels and response targets are to be defined in the relevant service standards. The system records the reason for a priority decision and any later change.

### Location handling
The communications system resolves a reported location against Kingswell's geography: district, neighbourhood, road, property, building, unit or other identifiable place. It preserves uncertainty when a caller cannot provide an exact location.

It should support landmarks, business names, intersections, public transport locations, access points and location updates. A location correction is dated and retained. The system must not silently substitute a nearby address as if it were confirmed.

### Incident creation and duplicate control
A new report may create a new incident, add information to an existing incident, or be recorded as a contact that does not require a formal incident. The call-taker or dispatcher can search for matching events by time, place, type and known reference.

Possible duplicates are flagged for review. Separate events at the same location remain separate when the facts indicate that they are not the same occurrence. Merging records preserves the source contacts and audit history.

### Dispatch
The dispatcher selects and assigns resources according to incident priority, location, unit responsibility, staff availability, skills, equipment, travel time and current commitments. A suitable nearby unit may be selected even if it is not the normal geographic owner, with command responsibility made clear.

A dispatch record identifies:
- The incident or task.
- Assigned unit, vehicle and officers.
- Time assigned and acknowledgement.
- Destination and any special information.
- En-route, arrival, on-scene, available or other status changes.
- Reassignment, cancellation, delay or escalation and the reason.
- The person who made material dispatch decisions.

The system prevents a unit from being assigned to incompatible simultaneous tasks unless the game explicitly records a split team or changed assignment.

### Live resource status
Dispatch can view the operational status and location of relevant units and resources. Statuses may include available, assigned, responding, on scene, transporting, committed, delayed, out of service and returned to availability. The exact set is defined consistently with patrol and resource records.

A status update should reflect an actual communication or system event. The dispatcher must be able to identify stale or missing status information rather than treating it as current certainty.

### Radio and operational communications
The system records relevant communications between dispatch, patrol units, supervisors and other authorised participants. It can include channel, sender, recipient or unit, timestamp, message type and message content or a reference to a recording.

Routine radio traffic may be summarised. Material instructions, acknowledgements, priority changes, emergency transmissions, requests for assistance and significant status changes remain individually traceable.

Radio communications can refer to an incident, unit, location, vehicle or person. A communication log does not replace a formal incident report or witness statement.

### Updates and escalation
Callers may provide new information while a unit is being assigned or responding. Officers may request additional resources, report a change in circumstances or advise that another service is needed. Dispatch updates the incident and notifies relevant units.

A change in threat, injury, location, offender presence, hazard or resource requirement can change priority and response. The system records who received the update and when. If a unit cannot respond, the dispatcher selects an alternative, escalates or records the delay.

### Other services and cross-command support
The communications centre may coordinate with fictional fire, medical, rescue, transport, public utility or other public services. It records requests, acknowledgements, arrival or handover where relevant. These agencies remain distinct institutions with their own responsibilities.

Events spanning multiple city areas or regions can be coordinated through the appropriate command. The record identifies the lead command, supporting units and any transfer of responsibility.

### Communications supervision
A communications supervisor monitors call queues, staffing, workload, priority incidents, dispatch coverage, unresolved contacts and system outages. They can reassign work, escalate resource shortages and coordinate major demand periods. Significant supervisory decisions are recorded.

### Player experience
The player may receive dispatch messages, radio traffic, updates, tasking and requests for assistance according to their role and equipment. They can acknowledge assignments, report status, request assistance, provide updates and communicate relevant observations.

The information shown to the player reflects what has actually been transmitted or made available to them. The player should not automatically know details held only by a caller, another unit or a restricted record.

### Records and audit
The system preserves contact records, call-taker notes, incident links, priority decisions, dispatch assignments, resource status changes, radio traffic, updates, escalations, referrals and handovers. Each record distinguishes event time from entry time where they differ.

Corrections and additions are appended or versioned. The original report and decision history remain reconstructable.

### Connections to other divisions
- **BP-02 and BP-04:** geographic locations, addresses, properties and institutions.
- **BP-06 and BP-07:** call-taker, dispatcher and officer identity, training and duty status.
- **BP-08 and BP-09:** units, deployment, vehicles, radios and other resources.
- **BP-10:** patrol activity, status reporting and response.
- **BP-12:** incident creation, ownership, classification and progression.
- **BP-13 and BP-14:** offence categories and generated events.
- **BP-15 to BP-24:** referrals and investigative or specialist follow-up.
- **BP-30 to BP-34:** service standards, training, staffing and costs.
- **BP-37 to BP-43:** time, records, persistence, interface, permissions and testing.

### Exceptions and edge cases
The system must handle anonymous callers, callers unable to speak, abandoned calls, accidental calls, repeat callers, malicious or false reports, simultaneous reports of one event, conflicting locations, incomplete information, language or communication difficulties within the fictional setting, call surges, communications outages, radio dead zones, failed acknowledgements, units becoming unavailable after assignment, incidents crossing boundaries and requests better handled by another service.

A false or malicious report is not assumed merely because a report is unsubstantiated. The source and evidence must be assessed separately.

### Acceptance conditions
- Every contact receives a traceable identity and timestamp.
- Caller statements remain distinguishable from verified facts.
- Locations can be resolved to the city geography while retaining uncertainty.
- Contacts can be linked to existing incidents and potential duplicates reviewed.
- Priority decisions have recorded reasons and can change when facts change.
- Dispatch assignments respect availability, suitability, location and conflicting commitments.
- Unit status and communication history are traceable.
- Material updates reach the relevant assigned resources.
- Cross-area and multi-service coordination has a clear lead and recorded handover.
- The system handles incomplete, duplicate, abandoned and malicious contacts without corrupting incident records.
- The player only receives information actually communicated or accessible to their role.

**Draft status:** BP-11 is a working design. Exact call priorities, service targets, communication-centre staffing and detailed radio conventions will be refined with BP-12 and later operational divisions. It is not a claim that dispatch software has been implemented.

## BP-12 — Incident Management

### Purpose
Give every event requiring formal police attention one clear, traceable record from first report through assessment, response, ownership, follow-up and closure. Incident management prevents events from being lost between call-taking, patrol, supervisors and specialist teams.

### Scope
This division governs the police incident record and its lifecycle. It connects incoming contacts and patrol discoveries to police ownership, response, referrals, linked events, decisions and final disposition.

An incident is not automatically a criminal offence, an investigation case, or proof that anyone has done something wrong. Crime classification is defined in BP-13; case creation and investigative ownership are defined in BP-15.

### What is an incident
An incident is a recorded event, report, concern or request that requires the service to assess, respond, document or make a decision. Examples include suspected crime, public disorder, missing-person reports, welfare concerns, traffic events, suspicious circumstances, property-related complaints, sudden deaths, requests for assistance and events referred by another institution.

One incident may involve several people, locations, vehicles, reports, police units and other services. One person or property may be linked to many incidents over time.

### Incident identity
Each incident receives a permanent unique reference. The record includes:
- Date and time reported, and event time or estimated time range.
- Source contact or discovery method.
- Reported location and any location uncertainty.
- Initial description and current summary.
- Incident type and current classification.
- Priority and reasons for any changes.
- People, organisations, vehicles and properties linked to the event.
- Assigned command, unit, supervisor and responsible officer where applicable.
- Response and attendance history.
- Actions, decisions, referrals and linked records.
- Current status, outcome and closure information.

The incident reference remains stable even when its classification, owner, location estimate or status changes.

### Incident lifecycle
A typical incident moves through these stages:
1. **Received:** a report, request or police discovery is recorded.
2. **Assessed:** the information is reviewed, classified provisionally and prioritised.
3. **Assigned:** responsibility is given to a command, unit or person.
4. **Response underway:** police or other services are responding or taking action.
5. **Active:** the incident is being dealt with and relevant information is being gathered.
6. **Follow-up:** further enquiries, referrals or actions remain outstanding.
7. **Resolved or concluded:** immediate police activity has ended and the outcome is recorded.
8. **Closed:** required records and handovers are complete, with no current action outstanding.

Not every incident uses every stage. A simple request may be resolved at first contact. A complex event may remain active, be linked to several cases or require a long follow-up. Reopening is possible when significant new information or activity arises.

### Classification and assessment
Classification describes the kind of event currently reported or established. It may change as information develops. The system distinguishes:
- Initial reported description.
- Provisional incident classification.
- Confirmed event facts.
- Criminal offence classification, where established under BP-13.
- Final administrative disposition.

A change of classification does not erase the earlier assessment. The record identifies who changed it, when and why.

### Priority and risk
Incident priority reflects the urgency and potential harm requiring police attention. It considers immediate threat, injury, vulnerability, ongoing activity, risk to the public, evidence at risk, location, available resources and other relevant circumstances.

Priority is separate from offence seriousness, investigative importance and eventual outcome. A non-crime welfare incident may be urgent; a serious historic allegation may require careful investigation but not an emergency response.

Priority changes are recorded with the reason, author and time. Supervisors can review incidents where urgency, risk or resource demand is disputed or changes significantly.

### Ownership and responsibility
Every active incident has a clearly identified responsible command or unit and, where appropriate, a named officer or supervisor. Ownership can transfer between units, stations, city commands or regional commands. The record shows:
- Previous owner and new owner.
- Effective date and time.
- Reason for transfer.
- Outstanding actions and risks.
- Documents, contacts and resources handed over.
- Person accepting responsibility.

An incident must never become ownerless during transfer. Shared support does not remove the need for one clearly accountable lead.

### Response and attendance
The incident record links dispatched resources, attending officers, arrival and departure times, actions taken, requests for assistance and any other service attendance. It distinguishes a unit being assigned from actually arriving or completing work.

Officers can submit updates and reports against the incident. A supervisor can review response delays, resource changes, unresolved risks and incomplete actions.

### People and entity links
The incident can link callers, victims, witnesses, persons of concern, suspects, officers, business representatives, organisations, vehicles, properties and other relevant entities. Each relationship has a role and source. A person is not labelled a suspect merely because they are present, named by a caller or linked to the location.

The system uses stable identities to prevent duplicate person, vehicle, property and organisation records. Uncertain identity matches remain provisional until resolved.

### Actions and decision log
Material actions and decisions are recorded with date/time, author, role, description, reason and outcome. Examples include classification changes, priority decisions, attendance, safeguarding actions, referrals, scene preservation, supervisory review, case creation, ownership transfer and closure.

The log is chronological and append-only in effect: corrections are recorded as corrections, not as silent rewriting of history.

### Linked incidents and related cases
Incidents can be linked when they appear connected by people, location, method, time, property, vehicle or other circumstances. A link records the relationship and why it was created. A link does not automatically prove that events share an offender or cause.

One incident may generate one or more investigative cases. A case may draw on multiple incidents. Case creation does not delete or replace the originating incident. Both records retain their own purpose and history.

### Referrals and other services
An incident may be referred to another police unit or external institution when it falls outside the current team's responsibility or requires specialist support. The record identifies the receiving body, information sent, date, acknowledgement and whether police retain any continuing responsibility.

Referral does not automatically mean closure. The incident remains open while police actions or follow-up obligations remain outstanding.

### Safeguarding and continuing risk
Where an incident identifies a person or group needing protection or assistance, the record can capture the concern, immediate steps, responsible team, referrals and follow-up date. Safeguarding information is handled with appropriate access limits and is not treated as proof of criminal conduct.

### Closure and reopening
Before closure, the responsible officer or supervisor records the outcome, actions completed, unresolved matters, referrals, linked cases, outstanding risks and reason no further immediate incident action is required. Required reports and handovers must be complete or explicitly assigned.

An incident can be reopened when new information, repeat activity, a failed referral or another relevant development requires further police action. The reopening reason and new owner are recorded; the previous closure remains in history.

### Player experience
The player can receive incident assignments, view the information available to their role, record attendance and actions, identify linked people or places, submit reports, request assistance and hand over work. The player sees the incident's current status and outstanding tasks without automatically seeing restricted information or investigative conclusions they have not been given.

### Reporting and performance
The service can report on incident volume, type, location, time, priority, response, ownership, transfers, outcomes, repeat locations, unresolved work and workload by command or unit. Performance measures must be interpreted fairly: raw closure counts or response times alone do not establish quality of service.

### Connections to other divisions
- **BP-02 and BP-04:** location, property, business and institutional records.
- **BP-06 to BP-09:** personnel, career, units, deployment and resources.
- **BP-10:** patrol discoveries, attendance and field reporting.
- **BP-11:** public contacts, call-taking, dispatch and communications.
- **BP-13 and BP-14:** offence classification and event generation.
- **BP-15 and BP-16:** case creation, investigative ownership and enquiries.
- **BP-17 to BP-24:** victims, witnesses, suspects, interviews, intelligence, scenes and evidence.
- **BP-25 to BP-29:** arrest, custody, legal process, courts and corrections.
- **BP-30 to BP-34:** governance, standards, training, staffing and resources.
- **BP-37 to BP-43:** time, records, persistence, interface, permissions and testing.

### Exceptions and edge cases
The system must handle one event reported many times, several unrelated events at one address, incidents spanning boundaries, conflicting accounts, uncertain event times, delayed reports, anonymous sources, events with no confirmed crime, events that change classification, repeated incidents involving the same people, mistaken identity, transfer between commands, multiple linked cases, external referrals, reopened incidents and closure while a separate investigation remains active.

### Acceptance conditions
- Every formal incident has one stable unique reference.
- Source reports and police observations remain distinguishable from established facts.
- Each active incident has clear ownership and a responsible lead.
- Lifecycle, priority and classification changes retain their history and reasons.
- Dispatch assignments and actual attendance are separately recorded.
- People and other entities link without duplicate identities or unsupported labels.
- Related incidents and cases can be linked without assuming they share a cause.
- Transfers preserve outstanding actions and never leave work ownerless.
- Referrals, closure and reopening are traceable.
- The system can report incident workload and outcomes without misleading performance measures.
- The player only sees information available to their role.

**Draft status:** BP-12 is a working design. The final incident categories, priority framework, response standards and closure rules will be refined alongside crime classification and case management. It is not a claim that incident-management software has been implemented.

## BP-13 — Crime Architecture

### Purpose
Define the complete fictional crime and offence system used by Kingswell's police service and justice institutions. This division establishes what offences exist in the fictional country's laws, how they are organised, what distinguishes one offence from another, and how reported conduct is classified consistently throughout the game.

Crime architecture is the common reference point for incident assessment, crime recording, investigation, intelligence, arrests, prosecution, court outcomes, statistics and the behaviour of the simulated world.

### Scope
This division defines the structure and reference information for criminal offences. It covers offence families, individual offence definitions, elements, seriousness, attempt and participation, relationships between offences, recording rules and links to legal outcomes.

It does not itself generate crimes or decide that a particular person committed an offence. Crime generation is BP-14. Incident records are BP-12. Investigation and case management are BP-15 and BP-16. Arrest, legal process and court decisions are handled by BP-25 to BP-29.

All laws, offence names, penalties and legal institutions belong to Kingswell's fictional sovereign country. They must not be copied mechanically from a real country's legal code.

### Core design principles
- Every offence has a stable identity and a clear fictional legal definition.
- Similar offences are distinguished by their required facts and elements, not just by their names.
- The system separates an allegation, an incident classification, an investigative hypothesis, a charge and a court finding.
- An offence definition can change over time without rewriting historical cases.
- The same offence reference is used consistently across police and justice records.
- The offence catalogue is broad enough to support varied ordinary, serious, organised and specialist crime.
- New offences are added in a controlled way, with links and consequences considered before they enter the active catalogue.

### Offence hierarchy
The crime catalogue is organised in levels:

1. **Crime domain:** a broad area such as offences against persons, property, public order, public safety, public administration or economic activity.
2. **Offence family:** a group of related offences sharing a broad subject or legal purpose.
3. **Offence type:** a distinct offence with its own legal definition.
4. **Variant or grade:** a legally meaningful variation, such as aggravated, attempted, completed or a different seriousness grade, where the fictional law provides for it.

This hierarchy supports navigation and reporting. It must not make two legally different offences interchangeable merely because they share a family.

### Crime domains and coverage
The catalogue is expected to cover, at minimum, the following broad domains. These are coverage areas, not a claim that every possible offence has already been fully specified.

- **Offences against persons:** homicide, assault, threats, unlawful restraint, abduction, harassment, stalking, exploitation and other unlawful harm.
- **Sexual offences:** non-consensual sexual conduct, exploitation, abuse, prohibited conduct involving protected persons and related offences, defined sensitively and according to fictional law.
- **Property offences:** theft, robbery, burglary, unlawful entry, criminal damage, arson, handling stolen property and related conduct.
- **Fraud and deception:** fraud, forgery, identity misuse, deception, financial abuse, false accounting and related offences.
- **Economic and commercial offences:** bribery, corruption, market abuse, unlawful trading, competition offences, tax or revenue offences and commercial misconduct where criminalised by fictional law.
- **Cyber and digital offences:** unauthorised access, interference, digital fraud, data theft, malicious disruption and misuse of communications or digital systems.
- **Public order offences:** disorder, unlawful threats to public peace, prohibited weapons conduct under fictional law, obstruction and offences affecting public gatherings.
- **Public administration and justice offences:** corruption in public office, obstruction of justice, perverting proceedings, perjury, evidence interference, escape and unlawful interference with public functions.
- **Organised and group criminality:** participation in criminal organisations, conspiracy, coordinated offending, trafficking networks and related offences as defined by fictional law.
- **Drug and controlled-substance offences:** unlawful production, supply, possession, trafficking and related conduct involving substances controlled by fictional law.
- **Weapons and dangerous materials:** unlawful possession, use, manufacture, supply or movement of items controlled by fictional law.
- **Transport and road offences:** dangerous or unlawful driving, vehicle-related offences, transport safety offences and offences affecting public transport, aviation, maritime or freight activity.
- **Environmental and public health offences:** unlawful pollution, dangerous waste, protected-resource offences, contamination and conduct threatening public health.
- **Immigration, border and customs offences:** unlawful entry or facilitation, document fraud, smuggling, prohibited imports and other offences established by the fictional country.
- **National security offences:** espionage, sabotage, serious threats to national institutions and other offences defined by the fictional legal system.
- **Regulatory and licensing offences:** serious breaches that fictional law makes criminal, distinguished from civil or administrative violations.
- **Other statutory offences:** additional offences created by the fictional legislature and assigned to the correct domain and family.

The catalogue should include common, uncommon and rare offences. Rarity affects how often offences occur in the living simulation, not whether the police system can record or investigate them.

### Individual offence definition
Each offence type has a structured definition containing, where applicable:
- Stable offence ID and official fictional title.
- Short plain-language description.
- Crime domain and offence family.
- Legal source, provision and effective date.
- Required elements that must be established.
- Conduct, circumstances or result required by the offence.
- Mental or fault requirement where the fictional law specifies one.
- Relevant exclusions, defences or lawful justifications as defined by the fictional law.
- Attempt, participation, assistance or group-liability rules where applicable.
- Available variants or grades.
- Seriousness classification and any statutory maximum or range.
- Whether the offence is ordinarily reportable, chargeable or subject to special procedure.
- Relevant specialist handling or investigative considerations.
- Related and commonly confused offences.
- Version, commencement, amendment and repeal history.

Definitions must be understandable to the player. Legal precision belongs in the structured definition, supported by a plain-language explanation.

### Offence elements
An offence may require several elements to be established. The system records these separately so that investigators and prosecutors can distinguish what is alleged, what is supported by evidence, what remains uncertain and what is disproved.

Elements can relate to:
- A person's conduct or omission.
- A particular result or harm.
- The circumstances in which the conduct occurred.
- A required mental state or knowledge.
- A relationship, status or duty.
- A location, object, value or protected category.
- A required connection between the conduct and an outcome.

Not every offence uses every element type. The offence definition states which elements apply. Evidence can support more than one element, and an element may require several independent pieces of evidence.

### Distinguishing related offences
The catalogue identifies offences that are similar in ordinary language but legally distinct. It records the key differences and the elements that separate them. This helps prevent an incident label or an investigator's initial theory from being treated as a final legal classification.

Where one set of conduct could potentially fit more than one offence, the system can preserve alternative classifications for assessment. It must not automatically select the most serious offence without considering its required elements.

### Attempts, assistance and group offending
The fictional law may recognise completed offences, attempts, aiding or assisting, incitement, conspiracy, joint participation, corporate liability or other forms of responsibility. Each form is defined by the fictional legal system and linked to the relevant principal offence.

The system distinguishes:
- The underlying offence.
- The person's alleged role.
- The legal basis for that role.
- The evidence supporting the alleged participation.
- Whether the conduct was completed, attempted or preparatory.
- Whether the legal requirements for group or organisational responsibility are met.

Association, friendship, presence, employment or communication with an offender does not by itself establish criminal participation.

### People and organisational responsibility
Offence definitions can specify whether responsibility may apply to an individual, an organisation, or both. Corporate or organisational liability is included only where fictional law establishes it. Records distinguish the organisation, its relevant officers or employees, and each person's alleged conduct.

The crime catalogue can also identify protected persons, vulnerable victims, public officials, regulated professionals or other legally relevant roles. These are legal circumstances, not assumptions that a person in a role has committed an offence.

### Seriousness and classification
Offences can be grouped by fictional legal seriousness and procedural consequences. The catalogue may define categories such as lower-level, standard, serious and exceptionally serious offences, but the final labels and thresholds must be consistent with the fictional country's legal system.

Seriousness is distinct from:
- Immediate incident priority.
- Risk to a victim or the public.
- Investigative complexity.
- Media or public attention.
- The eventual sentence or court outcome.

An offence's statutory seriousness does not decide the urgency of every incident involving it.

### Recording and classification stages
The system preserves the difference between:
1. Conduct reported by a caller or discovered by police.
2. Initial incident type used for response.
3. Provisional suspected offence.
4. Offence classification supported by developing evidence.
5. Offence or offences referred for legal review.
6. Formal charge or equivalent legal allegation.
7. Court finding, acquittal, dismissal or other final legal outcome.

These stages may differ. A report can be genuine even when no offence is established. A case can be investigated under one suspected offence and later reclassified. A charge is an allegation, not a conviction.

### Multiple offences and one course of conduct
One incident or course of conduct may involve several possible offences. The system allows multiple offence links and records whether they relate to separate acts, alternative legal interpretations, a continuing course of conduct or different participants.

It also handles multiple incidents that together form evidence of a repeated pattern or continuing offence. The system must not duplicate the same offence merely because several people report it.

### Legal change and historical validity
Offence definitions have effective dates. When fictional law changes, the new version applies according to its commencement and transitional rules. Historical incidents, decisions and court outcomes retain the offence definition and legal version relevant to their date.

A repealed offence remains visible in historical records but is not offered as a current offence for new events after repeal, unless the fictional law expressly provides otherwise.

### Crime statistics and analysis
The catalogue supports consistent reporting by domain, family, offence type, seriousness, location, time, victim relationship, method and outcome. Statistical reporting must distinguish allegations, recorded offences, cases, charges and court findings. A change in classification rules must be visible in the data and must not silently distort historical comparisons.

### Connections to other divisions
- **BP-02 to BP-04:** geographic, population, property and organisational context.
- **BP-10 to BP-12:** patrol discoveries, public reports, dispatch and incident classification.
- **BP-14:** crime occurrence and generation using the offence catalogue.
- **BP-15 and BP-16:** case creation, investigative hypotheses and offence-element assessment.
- **BP-17 to BP-24:** victims, witnesses, suspects, interviews, intelligence, scenes and evidence.
- **BP-25 to BP-29:** arrest, custody, legal review, charges, courts and outcomes.
- **BP-30 to BP-34:** policy, training, staffing and institutional responsibilities.
- **BP-35 to BP-44:** simulation behaviour, records, time, persistence, interface, permissions and testing.

### Exceptions and edge cases
The design must handle uncertain or changing offence classifications, multiple possible offences, several offences arising from one event, a single offence spanning multiple events, attempts, group participation, organisational responsibility, offences with unknown victims, offences discovered long after they occurred, cross-jurisdiction conduct, changes in fictional law, repealed offences, mistaken allegations, insufficient evidence and conduct that is harmful or suspicious but not criminal under the fictional law.

### Acceptance conditions
- Every current offence has a stable unique identifier and a complete definition.
- Offences are organised into domains, families, types and legally meaningful variants.
- Required elements and distinctions between related offences are explicit.
- Allegations, incident classifications, investigative theories, charges and court findings remain distinct.
- Multiple and alternative offence classifications can be recorded without duplication.
- Attempt and participation rules link clearly to the underlying offence and fictional law.
- Offence seriousness is not confused with incident urgency or investigative priority.
- Legal changes preserve historical versions and effective dates.
- Crime statistics distinguish reports, recorded offences, charges and court outcomes.
- The catalogue supports all major crime areas needed by the living simulation.
- No real-world country's legal code is silently treated as Kingswell law.

**Draft status:** BP-13 is a working design. The detailed fictional offence catalogue, legal provisions, seriousness bands and procedural consequences will be populated and reconciled with later crime, investigation and justice divisions. It is not a claim that crime-classification software has been implemented.

## BP-14 — Crime Generation

### Purpose
Make Kingswell a living fictional city in which crimes and other police-relevant events can arise naturally from the people, organisations, places, opportunities, pressures and circumstances already present in the simulation. Crime generation creates believable events for police to discover and respond to, rather than relying only on pre-written cases or arbitrary random incidents.

### Scope
This division defines how criminal events originate, develop, occur, are reported or discovered, and enter the police system. It covers individual offending, repeated activity, groups and organised networks, victim and target selection, opportunity, event timing, event outcomes and the relationship between generated events and police records.

The offence definitions themselves belong to BP-13. Call intake and incident records belong to BP-11 and BP-12. Investigative casework belongs to BP-15 and BP-16.

### Core principles
- Events arise from the simulated world and its circumstances, not solely from a list of random prompts.
- Every generated event has a coherent internal history, even when the police initially know very little about it.
- The simulation does not guarantee that every crime is reported, witnessed, detected or solved.
- The same person, group, place or business can be involved in multiple events over time, with continuity and consequences.
- Crime frequency and type vary by district, time, activity, opportunity and other relevant circumstances.
- The system creates uncertainty for police while retaining consistent underlying facts for simulation logic.
- Generated events must be varied and plausible without forcing every citizen to be an offender or every patrol to encounter a crime.

### Sources of crime and other police events
Events may arise from several overlapping sources:
- Individual decisions, needs, pressures, conflicts, grievances, impulses or opportunities.
- Relationships, disputes, domestic or household circumstances, workplaces and social networks.
- Business activity, commercial disputes, fraud opportunities, theft targets and organisational misconduct.
- Group offending, criminal enterprises and coordinated activity.
- Public events, transport hubs, nightlife, markets, industrial activity and other concentrations of people.
- Environmental conditions, infrastructure failures, accidents and hazards that may create police work without being crimes.
- Repeat patterns, escalation, retaliation, imitation or changes in opportunity.
- Unplanned encounters and events that emerge from existing simulated activity.

These sources are influences, not automatic causes. A person experiencing hardship, belonging to a group or visiting a location is not automatically made criminal.

### Offender and group behaviour
Where an event involves an offender, the simulation identifies the responsible person or participants internally and determines their role according to the event's underlying facts. Roles may include principal actor, accomplice, organiser, facilitator, recruiter, supplier, lookout or other role defined by the fictional law and event model.

The simulation distinguishes:
- A person's intention or plan.
- Preparatory behaviour.
- Attempted conduct.
- Completed conduct.
- Assistance or participation by others.
- Events abandoned, interrupted or prevented.
- Conduct that occurs but does not meet the elements of a criminal offence.

An internal simulation identity is not automatically exposed to the player or police records. It becomes known only through information the police legitimately obtain in the course of play.

### Opportunity and circumstances
The event model may consider:
- Location type and access.
- Time of day, day of week and seasonal or event conditions.
- Presence, absence and movement of people.
- Security, guardianship and routine activity.
- Business opening patterns, staffing and deliveries.
- Property value, accessibility and attractiveness as a target.
- Transport and escape opportunities.
- Existing disputes, relationships or criminal connections.
- Prior events and local patterns.
- Police presence and other deterrent or disruptive circumstances.

The simulation should not use a single factor as a deterministic trigger. Opportunity can influence the likelihood or form of an event, while individual decisions and circumstances remain part of the model.

### Victims, targets and affected parties
An event can affect an individual, household, business, public institution, organisation, public space or the wider community. The simulation identifies the affected party or target and the nature of the impact.

Victim selection must arise from event circumstances and the offender's simulated behaviour. It must not rely on sensitive personal characteristics as a simplistic deterministic rule. Some offences may have no immediately identifiable victim, may affect multiple people, or may be discovered before the intended target is harmed.

### Event creation and internal record
Every generated event receives a unique event identity and an internal event record. Depending on the event, the record may contain:
- Offence type or possible offence types under BP-13.
- Event date, time or estimated time window.
- Exact or approximate location.
- Underlying sequence of actions and outcome.
- Persons and organisations involved and their internal roles.
- Victims, targets, witnesses and affected property.
- Method, tools, vehicles or other relevant objects.
- Damage, loss, injury or other consequences.
- Evidence traces or potential evidence sources.
- Whether the event was completed, attempted, interrupted or abandoned.
- Whether it was witnessed, reported, detected or remains undiscovered.
- Links to earlier or later events.

The event record is not the same as a police incident or investigative case. It represents what happened in the simulation, including facts not yet known to the police.

### Hidden facts and police knowledge
The simulation maintains a strict separation between underlying event facts and information available to the police. The event may have an internally known actor, method and timeline while the police have only a partial report or no report at all.

Information reaches the police through plausible routes such as:
- A victim or witness reporting.
- A third party contacting the service.
- Patrol or another officer observing something.
- An alarm, camera or other system producing information.
- A hospital, business or public institution making a referral.
- An investigation connecting previously separate information.
- A later discovery of damage, property, remains or other evidence.

The player must not be given hidden culprit identities or unrevealed event facts as hints. The player works from information obtained in the game. The simulation remains internally consistent if the player makes an incorrect assumption.

### Reporting and detection
Events can be:
- Reported immediately.
- Reported after a delay.
- Reported more than once.
- Discovered by police without a public report.
- Detected by a business, institution or automated system.
- Known to people who choose not to report.
- Never reported or detected during the current play period.

Reporting probability depends on context such as harm, trust, awareness, fear, relationship to the offender, access to police and perceived seriousness. These influences create variation, not certainty.

A report may be incomplete, mistaken, exaggerated, malicious or honestly inaccurate. The simulation stores the source's account separately from the underlying event facts and from later verified findings.

### Repeat events and patterns
The system can generate repeat activity by the same person or group, repeated targeting of a place or victim, copycat activity, escalating disputes, series offences and geographically or behaviourally linked events.

Patterns are not automatically obvious to police. The simulation may expose separate events through reports, records, evidence and intelligence over time. Links can be real, coincidental, misleading or uncertain. Investigators must assess them.

### Organised and coordinated crime
Groups and criminal organisations can generate events through plans, roles, resources, relationships and internal conflict. Their activity may include recruitment, supply, movement, concealment, intimidation, financial activity and attempts to avoid detection.

Organised activity should have continuity and constraints. Participants have individual motives, knowledge and reliability; they do not all know every detail. Arrests, disruptions, financial pressure, internal disputes and investigative activity can change a group's behaviour.

### Non-crime events
The living city also generates non-criminal events that require police attention, including accidents, missing-person concerns, welfare requests, disputes without an offence, public hazards, sudden deaths, lost property, noise complaints and assistance requests.

These events use the same world and incident systems but are not forced into a criminal offence classification. This prevents the simulation from treating every call as a crime.

### Frequency, distribution and balance
Crime occurrence is influenced by population, activity, geography, opportunity, individual behaviour, group activity, time and previous events. The game should support different levels of activity across districts and periods without making any district uniformly dangerous or safe.

The system uses adjustable parameters for event frequency and variation. Parameters are tuned through testing and can be configured for a desired game experience, but the underlying rules should remain coherent. The player should encounter quiet periods, routine work, isolated incidents and periods of increased demand.

### Consequences and world change
Generated events can change the world. Consequences may include injury, loss, property damage, fear, changed routines, business disruption, reduced trust, increased security, disputes, retaliation, further offending, public concern or changes in police deployment.

Consequences persist where relevant and can influence future behaviour. A crime does not disappear from the world merely because the police close an incident or the player leaves the session.

### Time and simulation processing
Events are generated against the game's controlled clock and relevant schedules. The system can process routine background activity in batches and increase detail when an event becomes active or police-relevant. It must respect the global rule that game time does not advance merely because the player exits, unless a different time rule is explicitly established in the blueprint.

Event times, discovery times, report times and police response times are distinct and preserved.

### Connections to other divisions
- **BP-02 to BP-04:** geography, population, properties, businesses and organisations.
- **BP-06 to BP-10:** personnel, deployment, resources and patrol presence.
- **BP-11 and BP-12:** reporting, call intake, dispatch and formal incident records.
- **BP-13:** offence definitions and classifications.
- **BP-15 and BP-16:** case creation and investigation.
- **BP-17 to BP-24:** victims, witnesses, suspects, interviews, intelligence, scenes and evidence.
- **BP-25 to BP-29:** arrest, custody and justice outcomes that may affect future activity.
- **BP-35 to BP-39:** simulation processing, relationships, time, records and persistence.
- **BP-40 to BP-44:** player interface, notifications, permissions, testing and configuration.

### Exceptions and edge cases
The system must handle attempted but unsuccessful offences, interrupted events, mistaken targets, multiple offenders with different knowledge, events with no direct victim, events with several victims, delayed discovery, false or duplicate reports, an event that produces several incidents, several events that appear linked, events crossing district or national boundaries, offender death or departure before discovery, and events that occur while the player is off duty.

### Acceptance conditions
- Events arise from persistent world conditions and simulated behaviour rather than only arbitrary random selection.
- Each event has a consistent internal record and unique identity.
- Underlying event facts remain separate from police knowledge and reports.
- Offence types link to the BP-13 catalogue.
- Reporting, discovery and detection are variable and not guaranteed.
- The simulation supports individual, repeat, group and organised offending.
- Non-criminal police work is generated alongside crime.
- Events can create lasting effects on people, places, organisations and police demand.
- Event timing respects the game clock and does not progress simply because the player exits.
- The player receives no automatic disclosure of hidden event facts or responsible identities.
- Event frequency and distribution can be tuned without breaking continuity or plausibility.

**Draft status:** BP-14 is a working design. The numerical behaviour model, event-frequency settings and detailed event catalogue will be tuned through later simulation testing. It is not a claim that crime-generation software has been implemented.

## BP-15 — Case Management

### Purpose
Provide the formal system for creating, assigning, supervising, progressing and concluding police investigations. Case management ensures that investigative work has a clear purpose, accountable owner, recorded plan, traceable actions, controlled information, linked evidence and a defensible outcome.

### Scope
This division governs the lifecycle and administration of an investigative case. It covers case creation, classification, ownership, assignment, plans, tasks, reviews, links, status, handover, closure and reopening.

The investigative methods used to carry out enquiries belong to BP-16. Victim and witness handling, suspect management, interviews, surveillance, intelligence, scenes, evidence and forensic examination are covered by BP-17 to BP-24.

### What is a case
A case is a managed body of police investigative work created to examine an allegation, suspected offence, series of events or other matter requiring structured enquiries. A case may originate from one incident, several linked incidents, a referral, intelligence or a newly discovered matter.

A case is distinct from:
- The underlying event in the living simulation.
- A public contact or call record.
- A formal incident record.
- An offence definition in the crime catalogue.
- A person or suspect record.
- A charge, court proceeding or final legal finding.

These records can be linked but must retain their separate identities and purposes.

### Case identity and record
Every case receives a permanent unique case reference. Its core record includes:
- Case reference and title or short description.
- Date opened and source of referral or creation.
- Lead command, owning unit and responsible investigator.
- Supervising officer and any specialist lead.
- Case type, priority and current status.
- Linked incidents, offence classifications and related cases.
- Known victims, witnesses, persons of interest and suspects, with their recorded roles and certainty.
- Investigative objectives and current working hypotheses.
- Tasks, actions, decisions, reviews and deadlines.
- Linked documents, statements, exhibits, forensic results and intelligence records.
- Risk, safeguarding and disclosure considerations.
- Outcome, closure decision and reopening history.

The case identity remains stable through transfers, reclassification, changes of investigator and later reopening.

### Case creation
A case may be created when an incident requires formal investigation, when several incidents appear connected, when a specialist referral is received, when intelligence identifies a matter requiring enquiries, or when a new offence is discovered.

The creation record identifies the source, reason, initial scope, suspected offence or issue, known facts, uncertainties and initial owner. A case should not be created merely to duplicate an incident record or to make an untested allegation appear established.

A single incident can generate more than one case where there are genuinely separate investigative objectives. Several incidents can be investigated under one case where a common investigative purpose exists. The relationship and rationale are recorded.

### Case classification and priority
Case classification describes the investigative subject and may include crime type, specialist area, complexity, geographic scope and risk. Priority reflects the need to allocate investigative attention and resources.

Priority is assessed separately from the seriousness of an offence, immediate incident response priority and public attention. Relevant factors may include risk to people, likelihood of further offending, vulnerability, loss or degradation of evidence, time-sensitive opportunities, complexity, public impact and available resources.

Classification and priority can change as facts develop. Each material change records the reason, author and time.

### Ownership and command
Every active case has one lead owner: a named investigator or responsible investigative team, under a defined supervisor and owning unit. Specialist teams may support the case without creating uncertainty about overall accountability.

Case ownership can transfer between investigators, units, commands or regions. A transfer records:
- Outgoing and incoming owner.
- Effective date and time.
- Reason for transfer.
- Current status and key developments.
- Outstanding tasks, deadlines and risks.
- Evidence and information requiring handover.
- Acceptance by the incoming owner.

The system must prevent a case from becoming ownerless during transfer. The outgoing owner remains responsible until the transfer is accepted or a supervisor formally assigns a new owner.

### Investigative objectives and plan
A case plan describes what the investigation is trying to establish and the work required to do so. It may include:
- The allegation or issue being examined.
- Relevant offence elements and alternative classifications.
- Established facts, reported information and unresolved questions.
- Working hypotheses and reasonable alternative explanations.
- Lines of enquiry and their purpose.
- Tasks, responsible people and target dates.
- Evidence and information sought.
- Risks, safeguarding needs and disclosure considerations.
- Specialist support required.
- Review points and decision milestones.

A plan is a working document, not a guarantee that a hypothesis is correct. It changes as evidence develops. Earlier versions and material changes remain available.

### Tasks and work allocation
Investigative work is divided into identifiable tasks. Each task has a purpose, owner, status, priority, due date where appropriate, dependencies and completion record. Tasks may cover interviews, records enquiries, scene work, forensic submissions, CCTV, digital material, surveillance, intelligence development, suspect enquiries, legal applications or other investigative actions.

Tasks can be assigned to a person, team or specialist unit. Delegation does not remove the lead investigator's responsibility to monitor the case. Completed tasks record what was done, the result, supporting records and any further work identified.

Overdue, blocked, rejected or incomplete tasks remain visible. A task cannot be marked complete merely because an attempt was made; the result and any outstanding limitations are recorded.

### Case reviews and supervision
A supervisor reviews the case at suitable points, taking account of seriousness, risk, complexity, elapsed time, major decisions and organisational standards. A review may assess:
- Whether the investigative objectives remain appropriate.
- Whether reasonable lines of enquiry are being pursued.
- Whether alternative explanations are considered.
- Whether victims and witnesses are being updated and supported.
- Whether suspect actions and legal decisions are properly recorded.
- Whether evidence is being managed and examined appropriately.
- Whether deadlines, disclosure and safeguarding needs are addressed.
- Whether resources and specialist support are adequate.
- Whether the case should continue, change scope, transfer or close.

Reviews record the reviewer, date, findings, directions and any follow-up tasks. The simulation should include routine reviews and event-triggered reviews.

### Related cases and series
Cases can be linked as related, potentially connected, part of a series, a joint investigation or a shared intelligence picture. Each link records its basis and confidence. A link does not prove common responsibility.

A lead case may coordinate several sub-cases or workstreams. The system preserves each case's own reference, owner, tasks, evidence and outcome while supporting shared oversight. If cases are merged administratively, the original identities and histories remain traceable.

### Information and document management
Case material may include reports, statements, interview records, plans, photographs, recordings, correspondence, exhibits, forensic submissions, intelligence reports, legal documents and review notes.

Each item links to its source, author or origin, creation time, version and relevant case role. The case record points to authoritative evidence and document records rather than making uncontrolled duplicate copies. Corrections, supplements and later versions preserve the history of what was originally recorded.

### Risk and safeguarding
The case can record risks relating to victims, witnesses, suspects, officers, the public, evidence, repeat offending and investigative activity. Each risk has a description, assessment, owner, mitigation and review date where appropriate.

Safeguarding concerns and restricted personal information are visible only to authorised roles. The existence of a safeguarding concern is not itself proof of an offence.

### Disclosure and case integrity
The case tracks material that may need to be considered for disclosure under the fictional legal system, including material that supports or undermines a prosecution theory. The system records where material came from, who reviewed it, decisions made and any unresolved disclosure issue.

The case plan and review process should encourage investigators to consider reasonable alternative explanations and relevant material that does not support the current hypothesis. Case management must not reward a predetermined outcome.

### Case status and lifecycle
A case may move through statuses such as:
- Proposed or awaiting assessment.
- Open and allocated.
- Active investigation.
- Awaiting a third-party response or specialist result.
- Under supervisory review.
- Submitted for legal or charging review.
- Suspended or dormant with a recorded reason.
- Concluded or closed.
- Reopened.

The exact status labels can be refined, but status must describe the actual position of the work. A case awaiting a forensic result is not treated as fully completed. A dormant case retains its outstanding opportunities and review date.

### Closure
A case can be closed when the investigative work has reached a recorded conclusion or when no further proportionate action is currently available. Closure records:
- Summary of the matter and investigative scope.
- Enquiries completed and their results.
- Enquiries not completed and why.
- Evidence obtained and material limitations.
- Suspect and victim positions as established.
- Legal referral or charging outcome, if applicable.
- Outstanding risks, safeguarding and disclosure matters.
- Property and exhibit status.
- Reason for closure and approving supervisor.
- Conditions or triggers for reopening.

Closure is an administrative case decision, not proof of guilt or innocence. A case can close without a charge, and a court outcome may occur later.

### Reopening and continuation
A closed or dormant case can be reopened when new evidence, a new witness, a linked event, a forensic result, a review finding or another material development justifies further work. Reopening creates a new period of activity while preserving the earlier closure decision and complete history.

### Player experience
The player can view cases assigned to them, understand their role and objectives, record investigative actions, create and complete tasks, link relevant records, submit material for review and see outstanding work. The player receives information according to their role and access, not the complete hidden simulation record.

The game should allow the player to pursue their own investigative reasoning. It must not automatically reveal the solution or tell the player which line of enquiry will identify the offender.

### Case workload and performance
Commanders can monitor active cases, age, risk, priority, ownership, overdue tasks, review status, resource demand, outcomes and unresolved work. Performance measures should consider quality, fairness, complexity and available resources rather than rewarding raw closure numbers or charges alone.

### Connections to other divisions
- **BP-02 to BP-04:** geography, people, properties, businesses and organisations.
- **BP-06 to BP-09:** personnel, careers, units, deployment and resources.
- **BP-11 and BP-12:** reports, incidents, referrals and incident history.
- **BP-13 and BP-14:** offence definitions and generated events.
- **BP-16:** investigative methods and operational enquiries.
- **BP-17 to BP-24:** victims, witnesses, suspects, interviews, surveillance, intelligence, scenes, evidence and forensics.
- **BP-25 to BP-29:** arrests, custody, legal review, court outcomes and corrections.
- **BP-30 to BP-34:** governance, standards, training, workforce and finance.
- **BP-37 to BP-43:** time, records, persistence, interface, notifications, permissions and testing.

### Exceptions and edge cases
The system must handle cases with unknown offenders, multiple suspects, multiple victims, no direct victim, several offences, several incidents, cross-region activity, joint investigations, specialist support, a lead investigator leaving, a case transfer rejected or delayed, a case with no immediate tasks, long-running forensic work, conflicting evidence, mistaken initial classification, related cases later found unrelated, legal referral without charge, and new evidence after closure.

### Acceptance conditions
- Every case has a stable unique reference and a clear investigative purpose.
- Incident, case, event, offence, person and court records remain distinct but linkable.
- Every active case has one accountable owner and supervisor.
- Case creation, classification, priority, ownership and status changes retain their history.
- Plans identify objectives, hypotheses, alternatives, tasks, risks and review points.
- Tasks have owners, results and visible outstanding work.
- Supervisory reviews record findings and directions.
- Related cases can be connected without assuming common responsibility.
- Case material retains provenance, version and access controls.
- Closure records the actual investigative position and unresolved limitations.
- Reopening preserves the original history and closure decision.
- The player can investigate without automatic solution hints or hidden culprit disclosure.

**Draft status:** BP-15 is a working design. Detailed case categories, review intervals, formal submission standards and the connection to legal review will be refined with BP-16 and the justice divisions. It is not a claim that case-management software has been implemented.

## BP-16 — Investigation

### Purpose
Define how police investigators turn reports, observations and available information into a disciplined, evidence-led understanding of an event. Investigation is the practical process of establishing what happened, identifying and testing possible explanations, locating relevant people and material, assessing reliability, and presenting findings for lawful decisions.

### Scope
This division governs the general investigative method and the coordination of enquiries from initial assessment through investigative conclusion. It covers investigative reasoning, lines of enquiry, lead management, information gathering, records enquiries, suspect and victim enquiries, corroboration, alternative hypotheses, investigative decisions and the assembly of findings.

Specialist procedures are designed in their dedicated divisions:
- Victim and witness support and management: BP-17.
- Suspect and offender records and management: BP-18.
- Interviews and interrogations: BP-19.
- Surveillance: BP-20.
- Intelligence: BP-21.
- Crime scenes: BP-22.
- Evidence continuity and exhibits: BP-23.
- Forensic examination: BP-24.

Case ownership, task allocation, review and closure remain governed by BP-15. This division describes the investigative work performed within that case framework.

### Investigative principles
Investigations must be purposeful, impartial, proportionate and traceable. They should:
- Start from what is actually reported or observed, not an assumed conclusion.
- Distinguish established facts, source accounts, inference, opinion and unknown matters.
- Identify what needs to be established and why each enquiry may help.
- Consider reasonable alternative explanations, including explanations that do not involve an offence.
- Pursue relevant lines of enquiry that support or undermine a working theory.
- Assess reliability, accuracy, completeness and possible bias in information.
- Preserve material that may be relevant, including material that does not support the current theory.
- Record decisions, actions, results, limitations and reasons for not pursuing an enquiry.
- Respect legal authority, role limits, privacy and procedural safeguards defined by Kingswell's fictional law.
- Avoid treating suspicion, association, presence or an unverified allegation as proof.

### Initial investigative assessment
At the start of an investigation, the investigator reviews the originating incident, available reports, immediate risks, known people and locations, potential offences and any material already secured.

The initial assessment identifies:
- What is alleged or known to have occurred.
- When and where it may have occurred, including uncertainty.
- Who may have been affected and who may have relevant information.
- Whether an immediate threat or continuing harm exists.
- What material may be lost, altered or become unavailable.
- Whether a scene, property, device or other item requires preservation.
- Whether urgent specialist support or legal authority may be required.
- What is known, what is disputed and what remains unknown.

This assessment is provisional. It is updated as new information is obtained and must not turn an early account into an unquestioned version of events.

### Investigative objectives and questions
The investigator translates the matter into clear questions. These may concern the event itself, the identity and actions of participants, intent, opportunity, chronology, location, method, harm, ownership, movement of property, relationships, communications or other relevant circumstances.

Each objective should be linked to:
- The fact or issue to be established.
- Why it matters to the suspected offence or the wider investigation.
- The information or material that may answer it.
- The enquiry or method proposed.
- The person responsible for carrying it out.
- Any authority, risk, dependency or deadline.
- The result and its effect on the investigation.

An enquiry should have a defined purpose. The system should discourage indiscriminate information gathering that has no reasonable connection to the matter.

### Lines of enquiry and lead management
A line of enquiry is a route by which an investigator seeks to establish or test a relevant fact. A lead is a specific piece of information or opportunity that may produce an enquiry.

Examples include:
- Establishing a reliable chronology.
- Identifying people present or in the vicinity.
- Checking access, attendance or occupancy records.
- Locating and reviewing relevant CCTV or other recordings.
- Establishing ownership, control or use of property and vehicles.
- Checking relevant business, employment or transaction records.
- Tracing the movement or disposal of property.
- Identifying witnesses and obtaining their accounts.
- Checking relevant communications or digital material where lawfully available.
- Examining physical, biological, trace or digital material.
- Comparing similar events for genuine links.
- Testing an alibi, explanation or other account.
- Establishing whether an apparent connection is coincidental.

Each lead has a source, date received, relevance, reliability assessment where possible, assigned owner, status, actions taken, result and any further leads created. Leads can be new, assessed, allocated, in progress, completed, blocked, disproved, duplicated or retained for later review. A completed lead records its outcome, not merely that an attempt was made.

### Investigative hypotheses and alternative explanations
Investigators may maintain one or more working hypotheses to organise their thinking. A hypothesis is a testable explanation, not a fact. The record identifies the information supporting it, the information that challenges it, the assumptions it depends on and what could disprove it.

The investigation should consider reasonable alternatives. For example, a person's presence may have an innocent explanation; an apparent sequence may have another interpretation; an item may have changed hands lawfully; or an event may not have been criminal. The system should make it possible to record and compare competing explanations without prematurely selecting one.

The investigator must not be rewarded simply for confirming an initial suspicion. Supervisory review should examine whether relevant contrary information and reasonable alternative explanations have been considered.

### Information gathering and records enquiries
Investigators may seek information from police records, public institutions, businesses, employers, property managers, service providers, witnesses and other lawful sources within the fictional setting.

A records enquiry identifies:
- The organisation or person holding the information.
- The specific information sought and its relevance.
- The period or scope of the request.
- The lawful basis or authority required under fictional law.
- The request, response and dates.
- The person who obtained and reviewed the material.
- Any gaps, limitations, refusal or retention issue.
- The original source and integrity of any returned material.

The system distinguishes information volunteered, publicly available, supplied under an applicable process, and obtained under a formal legal authority. A request does not itself establish that the information exists or will be supplied.

### Chronology and reconstruction
Investigators can construct a timeline from reports, observations, recordings, access records, communications, travel information and other material. Each timeline entry records its source, time precision, whether it is an event time or a record-entry time, and any uncertainty.

Conflicting timestamps are not silently reconciled. Clock differences, estimated times, delayed entries, missing intervals and contradictory accounts are recorded. A reconstructed chronology identifies which points are established, approximate, disputed or inferred.

The system can associate people, vehicles and objects with places and time intervals, while avoiding false precision. A person's presence at a location does not by itself establish what they did there.

### Person-focused enquiries
Investigators may establish identity, contact details, relevant background, relationships, employment, movements, access, opportunity, knowledge and accounts of people connected to the matter. The enquiry must be relevant and proportionate.

The same person may be a victim in one matter, a witness in another and a suspect in a third. Roles are case-specific and can change as information develops. A role change does not rewrite earlier records or imply guilt.

Information about a person is attributed to its source and assessed for reliability. Unverified claims, hearsay, mistaken identity and conflicting records remain visibly uncertain until properly resolved.

### Property, vehicle and organisation enquiries
Investigations may establish ownership, occupancy, control, access, use, movement, maintenance, transactions, employment relationships and organisational responsibilities. Records distinguish legal ownership from possession, custody, tenancy, operational control and practical access.

A business or property may have several relevant people and organisations connected to it. Investigators must establish the nature and time period of each relationship rather than assuming that an owner, director, tenant, employee or registered keeper personally carried out an act.

### Linking events and investigations
Investigators may compare incidents and cases by method, location, timing, victim, property, vehicle, communication, material traces or other relevant circumstances. A proposed link records its factual basis and confidence.

The system distinguishes confirmed links, probable links, possible links and rejected links. Similarity alone is not proof of common authorship. A link can be downgraded or removed from the active theory while preserving the history of why it was considered.

Where several teams contribute, the lead investigator coordinates the overall enquiry, while each team records its own actions, source material and findings.

### Assessing information and evidential value
Information is assessed according to its source, how it was obtained, whether it is first-hand, its accuracy, consistency, completeness, possible motive or bias, corroboration and any known limitation.

The system distinguishes:
- Information that suggests a possible line of enquiry.
- An account given by a person.
- An observation recorded by an officer.
- Material recovered or obtained from a source.
- An expert or specialist opinion.
- An inference drawn from several facts.
- A fact independently established to the applicable standard.

No single label automatically determines admissibility, reliability or weight. Those questions are considered under the fictional legal and evidential framework.

### Negative and inconclusive results
An enquiry that produces no useful result is still recorded. The result may narrow a time window, exclude a location, show that a record does not exist, reveal a retention gap or establish that a proposed lead cannot currently be tested.

The system distinguishes a negative result from proof that an event did not happen. It also distinguishes an inconclusive result from a disproved hypothesis. Investigators can record whether a lead should be revisited if new information becomes available.

### Specialist support and investigative coordination
The lead investigator can request support from specialist units and services. A request states the purpose, urgency, information supplied, expected output and any authority or handling requirements.

Specialists return findings with their methods, limitations, source material and responsible personnel recorded. The lead investigator integrates those findings into the case without altering the specialist's original record.

Where multiple jurisdictions or commands are involved, the investigation identifies the lead command, supporting teams, information-sharing arrangements and responsibility for decisions and handovers.

### Legal authority and procedural safeguards
Some enquiries require consent, a warrant, an order, authorisation or another legal basis under Kingswell's fictional law. The system records the authority relied upon, its scope, issuing or approving role, validity period, conditions, execution and return where applicable.

An enquiry must not exceed its authority. If the required authority is absent, expired, refused or narrower than the proposed action, the system records the limitation and does not represent the action as lawfully completed. Emergency exceptions, if the fictional law provides them, are separately defined and recorded.

### Investigative decisions and audit
Material decisions record who made them, their role, date and time, information considered, options considered, reason, outcome and any review requirement. This includes decisions to pursue, defer, narrow, discontinue or reopen a line of enquiry; seek legal authority; request specialist assistance; change a working hypothesis; or recommend a case outcome.

Corrections and supplements preserve the original record. The investigation should be reconstructable from the records without relying on an investigator's memory alone.

### Findings and investigative conclusion
At the conclusion of a phase or the whole investigation, the investigator prepares a structured account of:
- The original allegation and scope.
- The work undertaken and significant results.
- Facts established and their supporting sources.
- Accounts and material that remain disputed.
- Reasonable alternative explanations considered.
- Evidence that supports or undermines each relevant hypothesis.
- Unresolved questions, limitations and outstanding opportunities.
- Relevant offence elements and how the available material relates to them.
- Any safeguarding, disclosure, property or continuing-risk matters.
- The recommended next step and its rationale.

Possible outcomes include further investigation, specialist referral, legal review, charge consideration, transfer, suspension, closure or reopening. An investigator's conclusion is not a court finding and must not be presented as one.

### Player experience
The player can review the information available to their role, identify and record leads, create investigative tasks through the case system, conduct authorised enquiries, compare accounts and timelines, link relevant records, record findings and submit work for supervision.

The player controls investigative choices. The simulation may make relevant people, records, places and material available through appropriate actions, but it must not reveal the hidden solution or automatically tell the player which lead identifies the offender.

### Connections to other divisions
- **BP-02 to BP-04:** geography, people, properties, businesses and organisations.
- **BP-06 to BP-09:** investigator roles, competence, units, deployment and resources.
- **BP-11 and BP-12:** reports, incidents, dispatch information and event records.
- **BP-13 and BP-14:** offence definitions and underlying generated events.
- **BP-15:** case identity, plans, tasks, supervision, handover and closure.
- **BP-17 to BP-24:** victim and witness handling, suspect records, interviews, surveillance, intelligence, scenes, evidence and forensics.
- **BP-25 to BP-29:** arrest, custody, legal process, courts and outcomes.
- **BP-30 to BP-34:** governance, professional standards, training, workforce and finance.
- **BP-37 to BP-43:** time, records, persistence, interface, notifications, permissions and testing.

### Exceptions and edge cases
The system must handle an investigation with no known suspect, several competing suspects, an initially misidentified person, conflicting or recanted accounts, unreliable records, missing or destroyed material, delayed reporting, events discovered long after occurrence, several investigators working separately, a lead investigator leaving, cross-command enquiries, a suspect also being a victim or witness, an innocent explanation emerging late, an offence classification changing, and a case where evidence supports no charge.

### Acceptance conditions
- Investigative objectives and leads have clear relevance, ownership and recorded outcomes.
- Established facts, allegations, accounts, inference and unknowns remain distinct.
- Investigators can record and test multiple hypotheses and reasonable alternatives.
- Enquiries are proportionate, traceable and linked to the information sought.
- Records enquiries preserve source, request scope, authority and response.
- Chronologies retain source, precision, uncertainty and conflicting times.
- Person, property, vehicle and organisation relationships are time-specific and not assumed.
- Event links retain their basis and confidence and can be revised.
- Negative and inconclusive results are preserved without being misrepresented.
- Specialist findings retain their original source, method and limitations.
- Legal authority and procedural restrictions are recorded and respected.
- Material decisions and investigative conclusions are auditable.
- The player retains control of investigative choices and receives no automatic solution disclosure.

**Draft status:** BP-16 is a working design. Detailed investigative procedures, formal legal powers, specialist workflows and evidential thresholds will be completed with the dedicated divisions and the fictional legal framework. It is not a claim that investigation software has been implemented.

## BP-17 — Victims and Witnesses

### Purpose
Define how the police service identifies, records, communicates with, supports and safeguards victims and witnesses, and how their information is handled throughout an incident, investigation and subsequent legal process. The division ensures that people are treated as individuals, their accounts are accurately recorded, their safety and welfare are considered, and their participation is never assumed or coerced.

### Scope and role distinctions
A person may be a victim, complainant, reporting person, witness, informant, next of kin, representative or other affected person. These are distinct roles and may overlap. A person can hold different roles in different incidents or cases, and a role can change as reliable information develops.

- **Victim:** a person who has suffered or may have suffered harm, loss or impact connected with an alleged event.
- **Complainant:** a person who makes a complaint or allegation; they may or may not be the victim.
- **Reporting person:** a person who brings information to police attention.
- **Witness:** a person who may have observed, heard, experienced or otherwise possess relevant information.
- **Informant:** a person who provides information, potentially under confidentiality arrangements governed by BP-21 and applicable fictional law.
- **Next of kin or representative:** a person with a relevant personal, family, legal or support relationship; this status does not automatically grant access to confidential case information.

These labels describe case roles, not credibility, guilt or legal status.

### Core principles
All victim and witness contact must be respectful, impartial, proportionate, accessible and properly recorded. Police personnel must:
- Treat people with dignity and avoid discrimination, intimidation, retaliation or unnecessary distress.
- Explain the officer's role, the purpose of contact and relevant process in understandable language.
- Distinguish a person's own words from summaries, interpretations and officer observations.
- Avoid leading, coaching, pressuring or promising a particular outcome.
- Record uncertainty, memory limitations, corrections and inconsistencies accurately.
- Consider the person's safety, welfare, accessibility, privacy and support needs.
- Explain that reporting or providing information does not guarantee prosecution or a particular result.
- Preserve a person's right to decline voluntary participation, subject to lawful duties or processes established by fictional law.
- Protect confidential information and disclose it only through authorised processes.
- Consider both information that supports and information that challenges an investigative theory.

### Victim and witness records
Each person receives a persistent person identity under BP-03 and a case-specific role record. The role record links the person to the incident and case without duplicating or overwriting their core identity.

The case-specific record may include:
- Person identifier and verified identity status.
- Role or roles and the basis for assigning them.
- Contact and safe-contact arrangements.
- Relationship to the event, location, people or property.
- Initial report or account references.
- Known injury, loss, harm or other impact, where relevant.
- Communication, language, accessibility and support requirements.
- Safeguarding assessment and review history.
- Contact attempts, appointments and outcomes.
- Consent, permissions, restrictions and lawful disclosure decisions.
- Statement and interview references.
- Relevant changes in availability, contact details or willingness to participate.
- Responsible officer, supervisor and handover history.

Sensitive personal information is restricted according to BP-42. Records retain provenance, access history and correction history. A person's role or account is not silently rewritten when new information emerges.

### Identification and verification
Personnel take reasonable steps to establish identity and distinguish people with similar names or incomplete details. Identity may be confirmed, provisional, disputed or unknown. The system must not merge records solely because names, addresses or dates of birth appear similar.

Where a person cannot or should not be identified immediately, an appropriately restricted provisional record can be created and reconciled later. Reconciliation preserves source records and requires an auditable reason.

### First contact and initial response
The first interaction should establish immediate safety and urgent needs before detailed evidential questioning where circumstances require. Personnel should:
- Determine whether urgent medical, fire, rescue or other assistance is required.
- Identify immediate threats, continuing harm or risk of retaliation.
- Establish whether the person can communicate safely and effectively.
- Arrange an appropriate interpreter or communication support where needed.
- Obtain essential information for immediate response and preservation of material.
- Explain what will happen next and how the person can contact the responsible police unit.
- Avoid unnecessary repeated retelling of distressing events.

The initial account is recorded with its context, time, author, method and any limitations. A later formal statement is a separate record linked to the initial account.

### Victim impact and needs assessment
The service records relevant physical, psychological, financial, property, social, occupational and other impacts when they are voluntarily disclosed or otherwise lawfully established. The assessment is proportionate and is not a clinical diagnosis.

Needs may include medical assistance, immediate protection, safe accommodation, specialist support, translation, disability access, communication adjustments, practical assistance or referral to another institution. The record identifies whether a need was reported, observed, assessed or confirmed by a qualified professional.

A person's needs and circumstances can change. Assessments are reviewed after significant developments, threats, changes in contact arrangements or changes in the case.

### Safeguarding and risk management
Safeguarding considers risks of further harm, intimidation, coercion, exploitation, retaliation, self-neglect, neglect by others and risks arising from contact with other case participants. Risk assessment considers the person's circumstances and the available information; it must not be based on stereotypes or unsupported assumptions.

The record captures:
- The risk or concern and its source.
- The person potentially at risk and any relevant other person.
- Severity, immediacy, likelihood and uncertainty.
- Protective factors and existing support.
- Actions taken, referrals and responsible personnel.
- Review date or triggering event.
- Reasons for accepting, escalating or reducing a risk assessment.

Immediate threats are escalated through operational command and relevant emergency procedures. Longer-term safeguarding is coordinated with authorised specialist units and appropriate public services. Police must not imply that a referral guarantees that another agency will provide a particular service.

### Vulnerability, capacity and additional support
A person's support needs are assessed individually and can arise from age, disability, health, trauma, language, dependency, coercion, isolation, unfamiliarity with the process or other circumstances. A label must not be treated as a complete assessment.

Where age or legal capacity affects the process, the applicable fictional law and specialist procedures govern. Appropriate safeguards may include a suitable adult, guardian, advocate, interpreter, specialist interviewer or other support person. Their role and any limits on participation must be recorded.

Support persons must not answer for the witness, influence their account or receive confidential information without an appropriate basis. Conflicts of interest and relationships with other case participants are assessed.

### Communication and updates
A responsible officer or designated contact point should be recorded for each victim or witness where practicable. Contact plans identify preferred safe methods, permitted times, language or accessibility needs, privacy risks and any restrictions.

Communications may cover:
- Acknowledgement of a report and reference details.
- The identity or contact route for the responsible unit.
- Requests for further information or attendance.
- Safety advice and changes to safeguarding arrangements.
- Procedural milestones that may lawfully be shared.
- Delays, transfer of responsibility or case closure.
- Available support and complaint routes.

Updates must be accurate and proportionate. Investigators must not disclose confidential investigative tactics, protected personal data, another person's private information or unapproved case material. If no update can be provided, the reason and next review point should be recorded where appropriate.

### Statements and accounts
A statement or account is a distinct source record. It should preserve the person's words as accurately as the recording method allows, identify the questions or prompts used where relevant, and distinguish direct recollection from inference, hearsay, later learning and uncertainty.

The record includes:
- Author, recorder, date, time, place and method.
- Whether the account was spontaneous, prompted, written, audio-recorded, video-recorded or otherwise obtained.
- Any interpreter, intermediary or support person and their role.
- Relevant cautions, explanations or procedural information given.
- The person's opportunity to review, correct or clarify the record.
- Amendments, additions, omissions and reasons.
- Signature, confirmation or reason confirmation was not possible.
- Any recording failure, interruption or limitation.

The original account is retained. Corrections are appended or versioned; they do not erase the original. A summary is not represented as a verbatim statement.

### Witness reliability and evidential assessment
Reliability is assessed by reference to the particular account and circumstances, not by a permanent credibility score attached to a person. Relevant considerations may include opportunity to perceive, distance, lighting, duration, stress, memory, time elapsed, intoxication or impairment where established, prior familiarity, consistency, contamination risk, possible motive, bias, suggestibility, communication barriers and corroboration.

The system must:
- Record the factual basis for any concern or assessment.
- Distinguish observed impairment from speculation.
- Preserve inconsistencies and changes of account.
- Record whether a witness has discussed the event with others or encountered media or other information.
- Avoid treating confidence, demeanour, emotion or lack of emotion as proof of accuracy.
- Allow an account to be both partly supported and partly disputed.
- Keep the investigator's assessment separate from the witness's own words.

No automated score should determine whether an account is true or whether a person is credible.

### Witness contact and identification procedures
Contact attempts, appointments, attendance, non-attendance and outcomes are recorded. The record distinguishes inability to contact, refusal, postponement, withdrawal, unavailability, fear, illness and other reasons where known.

Any identification procedure must follow a separate legally governed process, with safeguards against suggestion and contamination. The system records the procedure, participants, instructions, sequence, administrator, result and any irregularity. Informal recognition, a formal identification and an investigator's belief are not interchangeable.

### Intimidation, threats and witness protection
Threats, approaches, pressure, inducements, harassment or retaliation connected with a person's involvement are recorded as separate incidents or linked events where appropriate. Immediate danger is escalated without waiting for a routine case review.

Protective measures may include safe-contact protocols, risk-led patrol attention, referral to specialist protection, secure accommodation or other measures authorised by fictional law and available resources. Restricted identity or location information must be accessible only to personnel with a legitimate role. The system records the authority, scope, review and expiry of protective measures.

Protection must not be promised when it cannot be guaranteed. Any limitations and safe reporting channels should be explained appropriately.

### Withdrawal, reluctance and non-cooperation
A victim or witness may become reluctant, unavailable or unwilling to continue. The system records the person's stated reason where voluntarily provided, the circumstances of the contact, any apparent pressure or safety concern, support offered and steps taken to preserve existing material lawfully.

Withdrawal does not automatically invalidate an earlier account, prove that the allegation was false, or require the case to close. Equally, the service must not coerce participation or misrepresent the person's wishes. Whether an investigation can continue depends on the available material and applicable fictional law.

### Special categories and sensitive cases
Additional specialist procedures may apply to children, people with communication needs, survivors of sexual or domestic violence, trafficking or exploitation, bereaved families, protected witnesses, people at risk from organised groups and people whose identity or location must be restricted.

This division defines the shared record and coordination requirements. Detailed interviewing methods, specialist safeguarding thresholds, protective powers and referral protocols are defined in dedicated operational and legal specifications. Personnel must not improvise specialist procedures outside their competence.

### Disclosure, privacy and information sharing
Victim and witness information may be relevant to investigation, defence rights, court proceedings, safeguarding or lawful inter-agency work. Collection and sharing must have a defined purpose and legal basis under fictional law.

The system records what was shared, with whom, when, by whom, for what purpose, under what authority and subject to what restrictions. It supports disclosure review without allowing a witness to control whether relevant material is disclosed where law requires otherwise. Confidentiality is not absolute and must not be promised as such.

### Complaints, feedback and service quality
People can raise concerns about treatment, communication, delay, privacy, safety or the handling of their information. Complaints are recorded and routed under BP-30 and BP-31, with an auditable response and separation from the evidential assessment of the underlying case.

Service quality can be assessed through timeliness, contact reliability, accessibility, safeguarding review, complaint handling and compliance with procedure. Performance measures must not reward officers for pressuring people to make statements or remain involved.

### Player experience
The player can identify and register victim and witness roles, record initial accounts, arrange appropriate contact, assess and review safeguarding concerns, request support, document statements, record threats or reluctance, and maintain communication within their authority.

The player must see only information permitted by their role and clearance. The system should present practical prompts for required safeguards and missing record fields, but must not invent a person's account, determine credibility automatically or reveal hidden offender identities.

### Connections to other divisions
- **BP-03:** persistent person identity, life status and relationships.
- **BP-06 to BP-08:** personnel roles, competence, supervision and deployment.
- **BP-11 and BP-12:** first contact, emergency response and incident records.
- **BP-13 and BP-14:** offence categories and generated events.
- **BP-15 and BP-16:** case ownership, investigative tasks, leads and enquiries.
- **BP-18:** suspect and offender role records, including role overlap.
- **BP-19:** formal interviews and interrogations.
- **BP-20 and BP-21:** surveillance and intelligence safeguards.
- **BP-22 to BP-24:** scenes, evidence continuity and forensic material.
- **BP-25 to BP-29:** arrest, legal process, courts and outcomes.
- **BP-30 and BP-31:** governance, complaints and professional standards.
- **BP-37 to BP-43:** time, records, persistence, interface, notifications, security and testing.

### Exceptions and edge cases
The system must handle anonymous or unidentified victims, witnesses who cannot communicate conventionally, mistaken or duplicate identities, multiple victims in one event, a person who is both victim and witness, a witness who later becomes a suspect, conflicting accounts, recantation, memory changes, delayed disclosure, deceased or missing witnesses, minors, interpreter errors, unsafe contact methods, threats from associates, witness relocation, withdrawal, refusal to sign, inability to attend court, lost contact, confidentiality restrictions, and a case where a victim's account is not supported by other evidence.

### Acceptance conditions
- Person identity and case-specific roles are distinct and traceable.
- Role changes do not erase earlier roles or records.
- Initial reports, formal statements and later corrections remain distinct.
- Accounts preserve source, context, method, uncertainty and amendment history.
- Safeguarding risks have a documented basis, owner, action and review.
- Support needs are individualised and referrals are traceable.
- Safe-contact and privacy restrictions are respected.
- Reliability assessment is account-specific, reasoned and non-automated.
- Threats and intimidation trigger appropriate escalation and protection review.
- Reluctance or withdrawal is recorded without coercion or automatic case closure.
- Information sharing has a recorded purpose, recipient and authority.
- Complaints are routed independently of evidential conclusions.
- Player access follows role and clearance; no hidden solution or automatic credibility verdict is disclosed.

**Draft status:** BP-17 is a working design. Specialist safeguarding, interview procedures, witness protection powers, disclosure rules and detailed fictional legal standards will be refined in the relevant divisions. It is not a claim that victim or witness management software has been implemented.

## BP-18 — Suspects and Offenders

### Purpose
Define how the police service records, assesses, manages and reviews people who may be connected to offending, while preserving the distinction between suspicion, investigative status, legal status and proven responsibility. The division provides a reliable person-centred framework for identifying potential offenders, managing suspect-related information, recording associations and offending history, and reflecting legal outcomes accurately.

### Scope
This division governs suspect and offender identity records and their case-specific status. It covers:
- Identification and resolution of suspected persons.
- Person-of-interest and suspect status.
- Suspect assessment and case association.
- Offender identity and legally established offending history.
- Suspect contact, risk and management information.
- Multiple suspects, co-offending and organised groups.
- Status changes, mistaken identity and exonerating information.
- Cross-case links and historical record integrity.
- Access, correction, retention and disclosure controls.

Arrest, custody, interview, charging, prosecution, trial, sentence and correctional management are governed by BP-19 and BP-25 to BP-29. This division maintains the person and case links needed by those processes; it does not replace them.

### Foundational distinction: suspicion is not guilt
The system must never equate a police suspicion with a finding of guilt. It must distinguish:
- **Unidentified possible offender:** an event may involve an offender, but no person has been identified.
- **Person of interest:** a person whose possible connection is being assessed; this label alone does not imply formal suspicion.
- **Suspect:** a person against whom a defined suspicion is being investigated, with the basis and authorising decision recorded.
- **Arrested person:** a person arrested under the applicable fictional legal power; arrest is not proof of guilt.
- **Charged defendant:** a person formally charged under the fictional legal process.
- **Accused person:** a person subject to criminal proceedings, according to the applicable procedural stage.
- **Acquitted person:** a person found not guilty of the relevant charge or otherwise legally acquitted.
- **Convicted offender:** a person whose guilt has been established by a competent court or other legally recognised final process.
- **Sentenced person:** a convicted person for whom a sentence has been imposed.
- **Rehabilitated or record-restricted person:** a person whose record is subject to a legal restriction, spent status or other consequence defined by fictional law.

These are not necessarily a single linear sequence. A person may be arrested without charge, charged without conviction, acquitted on one charge and convicted on another, or have proceedings discontinued. The system must represent each charge and proceeding independently.

### Person identity and suspect identity
Every person is represented by the persistent identity system in BP-03. Suspect and offender records link to that identity rather than creating a separate person for every case.

Identity confidence is recorded as unverified, provisional, partially corroborated, verified or disputed, with the basis and source. Names, aliases, dates of birth, physical descriptions, addresses, photographs, biometric identifiers and other identifiers are recorded only where lawfully obtained and relevant. Similarity of name or appearance is not sufficient to merge records.

Where identity is uncertain, the system supports provisional identities and later reconciliation. Any merge or split is auditable, preserves source references and prevents one person's history from being silently attributed to another.

### Case-specific suspect status
A person's suspect status belongs to a specific case and, where necessary, a specific alleged offence. It does not become a permanent global label.

A case-specific status may include:
- Unassessed person of interest.
- Enquiry subject.
- Suspect under investigation.
- Suspect no longer actively pursued.
- Excluded from the current line of enquiry.
- Arrested.
- Released pending further action.
- Charged.
- Proceedings discontinued or charge withdrawn.
- Acquitted.
- Convicted.
- Other status defined by fictional law.

The status record includes the effective date and time, decision-maker, authority, case and offence scope, supporting information, rationale, review requirement and any conditions. A status change in one case must not automatically change another case's status.

### Basis for suspect designation
A suspect designation requires a recorded factual basis and a clear connection to an alleged offence or relevant investigative question. The record should identify:
- The allegation or offence being considered.
- The information linking the person to it.
- The source and date of that information.
- What is verified, unverified, disputed or inferred.
- Relevant information that supports or undermines the suspicion.
- The decision-maker and applicable threshold under fictional policy or law.
- Any review date or trigger.

The system must not permit a suspect label to be based solely on protected characteristics, lawful association, reputation, anonymous unsupported accusation or presence in a location without a relevant evidential connection. Any lawful intelligence-led basis must still be recorded and governed by BP-21 and BP-42.

### Suspect assessment and review
A suspect assessment is an evolving case-specific analysis, not a permanent score. It may consider opportunity, access, motive where evidentially relevant, capability, means, timeline, accounts, material links, corroboration, contradictions and alternative explanations.

The assessment records the basis and limitations of each consideration. Motive is not required for every offence and its absence does not establish innocence. An apparent opportunity or association does not establish participation.

Reviews should consider:
- Whether the factual basis for suspicion remains valid.
- Whether new information supports or undermines the suspicion.
- Whether an alternative person or explanation has emerged.
- Whether the person has been incorrectly identified.
- Whether the current status remains necessary and proportionate.
- Whether restrictions, alerts or investigative actions should be changed.

A suspect can be downgraded, excluded or cleared in one case while remaining a suspect in another, provided the separate basis is recorded.

### Suspect profile and relevant information
A case-linked suspect profile may contain relevant identity details, known contact routes, verified aliases, relevant addresses, employment or organisational links, vehicles, access, relationships, relevant history, known risks and investigative references.

Only information relevant to a defined policing purpose should be included. Unverified claims are labelled and attributed. Sensitive information is subject to role-based access, lawful purpose, retention limits and audit. A profile must not become an unrestricted collection of gossip, unrelated personal history or speculative character judgments.

### Aliases and identity variants
Aliases, nicknames, transliterations, former names, spelling variants, false identities and known identity documents are represented as separate identity attributes with source, validity period and confidence. An alias does not automatically establish deception or criminality. The system supports an alias shared by multiple people and a person using different names in different contexts.

### Offending history and prior records
The system distinguishes:
- Allegations and reports.
- Recorded police contacts.
- Investigative suspicions.
- Arrests.
- Charges.
- Court outcomes.
- Convictions.
- Sentences and correctional outcomes.
- Rehabilitated, spent, sealed or otherwise restricted records.

Only legally established outcomes are represented as convictions. A previous allegation, arrest or acquittal must not be presented as proof of current offending. Relevance of prior history is determined under fictional law and procedure, not automatically assumed by the simulation.

Historical records retain the date, jurisdiction, offence, procedural status, source authority and outcome. Corrections, appeals, overturned convictions, pardons and record restrictions are reflected through traceable updates without erasing the historical procedural record.

### Associations and co-offending
People may be connected through family, employment, friendship, business, shared property, communications, financial dealings, group membership, common events or suspected co-offending. The system records the nature, source, time period and confidence of each relationship.

Association is not guilt. A person's relationship with a suspect does not automatically make them a suspect or accomplice. Each alleged participant's conduct, knowledge, intent and relevant legal elements must be considered separately.

For group offending, records can represent:
- Alleged principal participants.
- Alleged assistance or encouragement.
- Organisers or coordinators.
- Facilitators and intermediaries.
- Receivers, handlers or disposers of property.
- Unknown or unidentified participants.
- People whose involvement is disproved or remains uncertain.

These are investigative descriptions unless and until the relevant legal status is established. Group links may be tentative and must not be presented as confirmed criminal membership without a lawful evidential basis.

### Risk and management information
Operational risk information may be recorded where it is relevant to lawful policing, officer safety, safeguarding or public protection. Examples include a specific threat, known weapon-related concern, escape risk, intimidation allegation, vulnerability, medical or communication need, or a documented history relevant to a particular operational decision.

Each item records source, date, confidence, context, review date, access restriction and the action it supports. The system distinguishes verified facts from unverified warnings. It must not create automatic dangerousness labels from offence category, background, identity or association alone.

Risk information is reviewed when circumstances change and must not be allowed to persist indefinitely without justification.

### Contact, availability and location information
Investigators may record known addresses, contact methods, last verified contact, relevant location information and lawful attempts to contact a suspect. Each entry identifies its source and the period for which it is considered current.

A last known address is not represented as a current residence without verification. A vehicle association does not establish who was driving. A device or account association does not establish who used it at a particular time. Location information must retain its source, precision, legal basis and limitations.

### Multiple cases and cross-jurisdiction records
A person may be connected to several incidents and cases. The system links those records while preserving each case's independent evidence, status, ownership and outcome.

Potential cross-case patterns are recorded as hypotheses until assessed. Similarity of method, geography, associates or timing is not by itself proof of common authorship. Cross-jurisdiction information is shared only under applicable authority and information governance rules.

### Mistaken identity, exclusion and exonerating material
The system must support mistaken identity and false attribution as ordinary possibilities. Where information excludes a person or undermines the case against them, that information is linked to the relevant case and made visible to authorised investigators and reviewers.

When a person is excluded:
- The basis and decision-maker are recorded.
- Case-specific suspect status is updated.
- Active alerts and investigative tasks are reviewed.
- Relevant recipients are notified where appropriate.
- Any continuing lawful reason to retain information is documented.
- Other case links are independently assessed rather than automatically deleted.

A person cleared in one case is not globally declared innocent of every unrelated allegation; equally, suspicion in another case must not contaminate the record of the case in which they were excluded.

### Arrest, charge and court outcome interfaces
This division receives authoritative status updates from the arrest, legal and court systems. It does not independently create an arrest, charge, conviction or sentence merely because an investigator records a recommendation.

The record must represent separate counts and charges, multiple defendants, partial verdicts, withdrawn charges, acquittals, convictions, appeals, retrials, overturned decisions and amended sentences. The originating authority, case reference and effective date are preserved.

### Record correction, retention and access
A person record may contain errors, disputed information or outdated details. Corrections are processed under BP-38 and BP-42 with provenance, author, reason, approval and audit history. The system supports restricted, sealed, spent or legally protected information without silently deleting required historical records.

Access is role- and purpose-based. Viewing, adding, changing, exporting or disclosing suspect information is logged. Personnel must not search records for curiosity or personal reasons. Retention and deletion follow the fictional records schedule and applicable legal orders.

### Player experience
The player can register a person of interest, develop a case-specific suspect record, document the basis for suspicion, link relevant evidence and enquiries, record aliases and relationships, review status, request supervisory decisions, and update records following authoritative legal outcomes.

The player must be able to record information that weakens or disproves suspicion. The system should never automatically identify a culprit, equate an arrest with guilt, or convert a generated hidden offender identity into police knowledge without an in-game evidential route.

### Connections to other divisions
- **BP-03:** persistent person identity and life history.
- **BP-13 and BP-14:** offence definitions and hidden event/offender facts.
- **BP-15 and BP-16:** case management, investigative leads and suspect assessment.
- **BP-17:** victim and witness roles, including role overlap.
- **BP-19:** suspect interviews and procedural safeguards.
- **BP-20 and BP-21:** surveillance and intelligence records.
- **BP-22 to BP-24:** scenes, evidence and forensic findings.
- **BP-25 and BP-26:** arrest, warrants and custody.
- **BP-27 to BP-29:** charges, court outcomes, sentencing and corrections.
- **BP-30 to BP-34:** governance, professional standards, training and personnel.
- **BP-37 to BP-43:** time, records, persistence, interface, notifications, security and testing.

### Exceptions and edge cases
The system must handle unknown offenders, unidentified or partially identified suspects, multiple people with similar identities, false aliases, mistaken identity, one person suspected in several cases, one case involving several suspects, a suspect who is also a victim or witness, a person arrested but never charged, a person charged and acquitted, mixed verdicts across several counts, withdrawn charges, appeals, overturned convictions, deceased suspects, juvenile suspects, extradition or cross-jurisdiction links, protected identities, sealed records, and later-discovered exonerating evidence.

### Acceptance conditions
- Person identity is persistent while suspect status remains case- and offence-specific.
- Suspicion, arrest, charge, conviction and sentence are distinct statuses.
- Every suspect designation has a recorded factual basis, source and decision-maker.
- Unverified information remains visibly unverified.
- Associations do not automatically imply criminal participation.
- Prior allegations and arrests are not presented as convictions.
- Risk information is sourced, contextual, reviewable and access-controlled.
- Aliases and identity reconciliation preserve provenance and history.
- Multiple cases and charges retain independent outcomes.
- Exonerating information can be recorded and surfaced to authorised reviewers.
- Authoritative legal outcomes update records without erasing procedural history.
- Corrections, access and disclosure are auditable.
- The player retains control of suspect assessment and receives no automatic culprit disclosure.

**Draft status:** BP-18 is a working design. Detailed arrest thresholds, interview rights, charging standards, court outcomes, youth procedures and records restrictions will be refined in the dedicated divisions and fictional legal framework. It is not a claim that suspect or offender management software has been implemented.
