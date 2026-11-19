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

## BP-19 — Interviews and Interrogations

### Purpose
Define the lawful, fair and auditable process by which police obtain accounts and ask questions of victims, witnesses, suspects and other relevant people. The division governs preparation, authority, safeguards, questioning, recording, review and the evidential handling of interviews. It ensures that accounts are not manufactured, distorted, coerced or detached from the circumstances in which they were obtained.

### Scope and terminology
An **interview** is a structured interaction in which personnel seek information relevant to an incident, investigation or other lawful police purpose. **Questioning** is the act of asking questions during an interview or other contact. **Interrogation** is a term used for a formal or intensive suspect-questioning process where the fictional law or procedure expressly uses it; it does not authorise coercion or remove procedural rights.

The division covers:
- Witness and victim interviews.
- Voluntary suspect interviews.
- Interviews under arrest or other lawful detention.
- Interviews involving juveniles or people requiring additional safeguards.
- Specialist and remotely conducted interviews.
- Interview planning, disclosure, recording and review.
- Admissions, denials, explanations and significant statements.
- Breaks, interruptions, termination and re-interview.
- Interview integrity, disclosure and audit.

Arrest, detention, access to legal representation and custody safeguards are governed by BP-25 to BP-27 and the fictional legal framework. Victim and witness welfare and case roles are governed by BP-17. Interview outputs become case material under BP-15, investigation under BP-16 and evidence/disclosure governance under BP-23 and BP-27.

### Fundamental safeguards
Every interview must be conducted within the interviewer's authority and competence. Personnel must:
- Treat the interviewee with dignity and respect.
- Explain the purpose and relevant process in language the person can understand.
- Give all cautions, rights and procedural explanations required by fictional law.
- Avoid threats, violence, intimidation, oppression, inducements or improper promises.
- Avoid leading or suggestive questioning where it may contaminate recollection.
- Never fabricate evidence, misrepresent a person's account or claim that unverified material is established fact.
- Record questions and answers accurately, including relevant context and interruptions.
- Preserve significant statements and material that may support or undermine a case.
- Allow required legal advice, support, interpretation and appropriate breaks.
- Stop or suspend an interview when a legal or welfare safeguard requires it.
- Distinguish an interviewee's words from an investigator's interpretation.
- Record irregularities rather than conceal or retrospectively repair them.

No confession, admission or denial is automatically true or reliable because it was made during a formal interview.

### Interview categories and legal status
The system distinguishes the purpose and legal status of each interview:
- **Witness interview:** seeks information from a person not being questioned as a suspect in that interview.
- **Victim interview:** obtains an account from a person affected by the event, with appropriate trauma-informed safeguards.
- **Voluntary suspect interview:** questions a suspect who is not detained, under the safeguards and conditions required by fictional law.
- **Detained suspect interview:** questions a person in lawful custody, subject to applicable rights and time limits.
- **Specialist interview:** uses additional procedures for a child, vulnerable person, protected witness or other defined circumstance.
- **Follow-up interview:** clarifies or supplements an earlier account.
- **Clarification contact:** limited contact to confirm a specific point; it must not be used to disguise a substantive interview.

The interview record identifies the category, legal basis, status of the interviewee, applicable safeguards and any change in status. If a witness becomes a suspect during contact, questioning must pause while the appropriate legal status, caution, rights and safeguards are addressed. A change in status must not be backdated.

### Authority and eligibility
Before beginning, the interviewer confirms:
- Their identity, role, authority and competence.
- The interviewee's identity or provisional identity.
- The interview's purpose and connection to the case.
- The legal basis and whether participation is voluntary or compulsory.
- Required caution, rights and procedural notices.
- Access to legal advice or representation where required.
- Appropriate adult, guardian, intermediary, interpreter or other support where required.
- Recording equipment, location, safety and privacy arrangements.
- Any restrictions on questioning, disclosure or use of material.

If a required safeguard or authority is unavailable, the interview must be postponed, limited or stopped as the law and circumstances require. The system records the reason and any action taken to remedy the issue.

### Interview planning
An interview plan defines the objectives and topics without scripting a desired answer. It may include:
- Questions the investigation needs to resolve.
- Relevant chronology and known points of uncertainty.
- The interviewee's role and relevant background.
- Material already available and what may properly be disclosed.
- Topics requiring clarification or corroboration.
- Possible alternative explanations.
- Communication, accessibility, language and welfare needs.
- Legal safeguards and any restrictions.
- Interviewer, second interviewer, note-taker and support roles.
- Recording method, location, expected duration and break arrangements.
- Risks, contingency arrangements and supervisory approval where required.

Plans are proportionate and may be revised as the interview develops. The original plan and material changes remain auditable.

### Preparation and disclosure to interviewee
The interviewer reviews relevant case material and identifies what information can lawfully and fairly be put to the interviewee. Disclosure before or during an interview follows fictional law and applicable policy.

The record distinguishes material disclosed, material withheld, the basis for withholding, the person authorising the decision and the time of disclosure. Investigators must not imply that undisclosed or unverified information is proven. Disclosure must not unnecessarily reveal protected witness identities, sensitive operational methods or another person's confidential data.

### Interview environment and participants
Interviews should take place in an appropriate environment that protects safety, privacy, accessibility and recording integrity. The record identifies everyone present or participating remotely, their role, arrival and departure times, and any period when the interviewee was left with others.

Participants may include the interviewer, second interviewer, note-taker, legal representative, appropriate adult, interpreter, intermediary, support person or specialist adviser. Their roles and any interventions are recorded. A support person must not answer for or coach the interviewee.

Remote interviews record the platform or method, identity checks, connection participants, recording arrangements, interruptions and any limitations on privacy or communication. Remote participation must not be used where safeguards cannot be met.

### Cautions, rights and procedural explanations
The exact caution, rights, notices, access-to-advice rules, silence provisions and consequences of answers are determined by the fictional legal framework. This blueprint does not invent final statutory wording.

The interview record must capture the wording or approved version used, the time given, the interviewee's response, any request for clarification and how understanding was assessed. Where an interpreter is used, the language, interpreter identity and any relevant qualification or authorisation are recorded.

If the interviewee does not understand, declines to acknowledge or disputes the explanation, the interviewer records the circumstances and follows the applicable procedure. A checkbox alone is not sufficient proof that a person understood.

### Questioning method
Questioning should be clear, fair, relevant and adapted to the interviewee's needs. Interviewers should ordinarily begin with open invitations that allow an account in the person's own words, then use focused questions to clarify relevant detail.

The system supports recording:
- Open questions and uninterrupted free accounts.
- Clarifying questions about time, place, sequence and identity.
- Questions testing inconsistencies or alternative explanations.
- Questions about the source of a person's knowledge.
- Questions distinguishing direct observation from assumption or later information.
- Questions about uncertainty, memory and confidence.
- Questions putting relevant material fairly for response.
- Requests for correction or clarification.

Interviewers must avoid repeated pressure, compound or confusing questions, threats, improper inducements, unsupported assertions and suggestive techniques that risk contaminating an account. Silence, distress, hesitation, anger, calmness or confusion must not be treated as proof of guilt or dishonesty.

### Witness and victim interviews
Witness and victim interviews should be planned with consideration of welfare, trauma, communication needs, memory, safety and the risk of repeated retelling. The interviewee should be given a reasonable opportunity to describe events in their own words.

Where appropriate, the interviewer records:
- What the person directly perceived.
- The circumstances of perception.
- What they remember clearly and what they do not.
- Any prior discussion or exposure to other accounts.
- Any uncertainty or later recollection.
- Relevant relationship or interest in the matter.
- Whether the account is spontaneous, prompted or reconstructed.

A victim's emotional response or decision not to continue does not determine whether the allegation is true. Interviewers must not pressure victims or witnesses to adopt a particular account.

### Suspect interviews
Suspect interviews require particular attention to legal status, caution, legal advice, custody safeguards and the fair presentation of relevant material. The interview plan should address the suspected offence and its elements, the information linking the suspect to the matter, relevant inconsistencies and reasonable alternative explanations.

The suspect must have a fair opportunity to respond to significant matters put to them. The interviewer records admissions, denials, explanations, qualifications, refusals to answer and requests for clarification accurately. An admission must not be isolated from the question, context or qualification that accompanied it.

No adverse conclusion is automatically drawn from silence or a refusal to answer; any permitted inference and its conditions are determined by fictional law and must be recorded accurately.

### Children and people requiring additional safeguards
Where an interviewee is a child or requires additional safeguards because of age, disability, health, trauma, communication or other circumstances, specialist procedures apply. These may require an appropriate adult, guardian, advocate, intermediary, specialist interviewer, adapted language, shorter sessions, additional breaks or a recorded capacity/needs assessment.

The precise eligibility thresholds and procedural requirements are reserved for the fictional legal framework and specialist policy. An interviewer must not proceed merely because a support person is physically present; the person's suitability, role and any conflict must be assessed and recorded.

### Interpreters and communication assistance
An interpreter or communication assistant must be identified and their role recorded. The interview record includes language or communication method, any relevant credentials or authorisation, conflict checks, interpretation method and any difficulty or interruption.

Questions and answers should be interpreted faithfully without summarising, coaching or adding content. If interpretation accuracy is challenged or communication breaks down, the issue is recorded and the interview paused or repeated where appropriate. The original language record, where available and lawfully retained, is linked to the translated record.

### Recording and record integrity
Interviews are recorded by an approved method consistent with fictional law and policy. The record identifies:
- Recording reference and format.
- Start, pause, restart and end times.
- Date, location and equipment or platform.
- Participants and role changes.
- Caution and rights explanations.
- Questions and answers or the approved recording reference.
- Breaks, interruptions and off-record periods.
- Technical failures, missing sections or loss of connection.
- Exhibits or documents shown and when.
- Any interviewee review, corrections or confirmation.
- Storage location, access history and continuity reference.

Where audio or video recording is unavailable or not required, the reason and approved alternative method are recorded. Notes must distinguish contemporaneous notes from later summaries. A recording is not edited to remove an awkward or unfavourable portion; any authorised working copy preserves an unchanged master and an audit trail.

### Exhibits and material put during interview
Each document, image, recording, object or other item shown or referred to is identified by its evidence or material reference, version, source and time of use. The record notes what was actually shown, whether the interviewee could inspect it, any explanation given and their response.

The interviewer must not imply that an exhibit proves more than it does. If material is later found to be inaccurate, incomplete or misidentified, the case and interview records are updated through an auditable supplement.

### Breaks, interruption and termination
The interview record captures breaks, requests for breaks, reasons, duration, participants present and any relevant conversation or event during the interruption. The interviewee's welfare and legal rights take priority over completion.

An interview may be paused or terminated because of fatigue, distress, illness, legal advice, need for an interpreter, loss of recording, safeguarding concerns, changed legal status, expiry of authority or other relevant reason. The decision-maker and rationale are recorded. Resumption requires confirmation that the necessary conditions and safeguards remain satisfied.

### Admissions, denials and significant statements
An admission, denial, explanation or significant unsolicited statement is recorded with its exact words where possible, surrounding question or circumstances, time, participants and recording reference. The record must include qualifications, retractions, corrections and context.

The system distinguishes an interviewee's statement from an investigator's interpretation. A statement made outside a formal interview is not retrospectively represented as an interview answer. Any legal issue about admissibility or evidential use is referred to the appropriate process.

### Re-interviews and changing accounts
A follow-up interview identifies its purpose and relationship to earlier interviews. The interviewer records what new information, inconsistency, clarification or procedural need justifies the further contact.

Earlier recordings and statements remain preserved. Differences between accounts are documented without automatically labelling the interviewee dishonest. The interviewee should be given a fair opportunity to explain relevant changes where appropriate.

### Review, supervision and quality assurance
A supervisor or authorised reviewer may assess whether:
- The interview was lawful and within authority.
- Required rights, cautions and safeguards were applied.
- The interviewer was competent for the interview type.
- The recording is complete and properly stored.
- The questions were fair, relevant and understandable.
- Significant statements and exhibits are accurately indexed.
- Any irregularity or complaint was addressed.
- The resulting account is correctly represented in the case.

Review findings, required actions, approval and any referral are recorded. Supervisory approval does not convert an unreliable account into reliable evidence.

### Irregularities, complaints and disclosure
Any allegation of coercion, mistreatment, improper questioning, recording manipulation, interpreter misconduct, rights violation or other irregularity is recorded and referred under BP-30 and BP-31. Original recordings and related material are preserved.

Interview records, recordings, notes, plans and associated material are indexed for disclosure and legal review under BP-23 and BP-27. Material that may undermine the prosecution case or assist another party must not be concealed or discarded. Access and disclosure decisions are auditable.

### Player experience
The player can plan and conduct authorised interviews, select suitable participants and support, record cautions and rights, ask questions, put material fairly, preserve answers and exhibits, pause or end interviews, and submit records for review.

The simulation must not auto-generate a confession, force an interviewee to answer, or reveal hidden facts through an interview prompt. Interviewees respond according to their knowledge, memory, motives, circumstances and the information legitimately available to them. They may be mistaken, evasive, truthful, deceptive, uncertain, silent or unwilling, without the system exposing which is the case unless evidence establishes it.

### Connections to other divisions
- **BP-06 to BP-08:** interviewer competence, assignment and supervision.
- **BP-11 and BP-12:** incident and initial contact records.
- **BP-15 and BP-16:** case plans, investigative objectives and leads.
- **BP-17:** victim and witness roles, welfare and safeguarding.
- **BP-18:** suspect status and legal-status distinction.
- **BP-20 and BP-21:** surveillance and intelligence material.
- **BP-22 to BP-24:** scene material, exhibits, continuity and forensic findings.
- **BP-25 and BP-26:** arrest, detention and custody safeguards.
- **BP-27 and BP-28:** legal review, disclosure, court proceedings and evidential use.
- **BP-30 and BP-31:** governance, complaints and professional standards.
- **BP-37 to BP-43:** time, records, persistence, interface, notifications, security and testing.

### Exceptions and edge cases
The system must handle a person who changes from witness to suspect, a suspect who becomes a witness in another matter, an interviewee who withdraws consent to a voluntary interview, a request for legal advice, refusal to answer, an interpreter error, an unsuitable support person, distress or illness, an interrupted recording, missing or corrupted media, disputed caution, a statement made off-record, a retracted admission, multiple interviewers, remote disconnection, mistaken identity, an interview conducted in another jurisdiction, and later discovery that material put to the interviewee was inaccurate.

### Acceptance conditions
- Every interview has a defined purpose, category, legal basis and responsible personnel.
- Interviewee status and any change of status are time-stamped and auditable.
- Required cautions, rights, legal advice and support safeguards are recorded.
- Interview plans identify relevant objectives without scripting desired answers.
- Questions, answers, exhibits, breaks and interruptions are accurately represented.
- Original recordings and notes are preserved with integrity and access history.
- Admissions and denials retain their context and qualifications.
- Interpreters and support participants have recorded identities and roles.
- Re-interviews preserve earlier accounts and explain the reason for further contact.
- Irregularities and complaints are escalated and original material preserved.
- Interview material is indexed for disclosure and legal review.
- Interviewees are not coerced and no response is treated as automatic proof.
- The player controls questioning and the simulation does not reveal hidden case solutions.

**Draft status:** BP-19 is a working design. Exact cautions, legal rights, detention interview limits, admissibility rules, youth procedures and specialist interview standards must be defined by the fictional legal framework and subsequent detailed policies. It is not a claim that interview software has been implemented.

## BP-20 — Surveillance

### Purpose
Define how the police service plans, authorises, conducts, records, supervises and reviews surveillance operations for legitimate policing purposes. Surveillance may help establish movements, associations, patterns, locations, activities or events that are relevant to an investigation. It must be necessary, proportionate, time-limited, properly authorised and subject to safeguards for privacy, safety, operational integrity and evidential reliability.

### Scope
This division governs the surveillance operation lifecycle, including:
- Surveillance objectives, proposals and operational plans.
- Legal authority, authorisation and renewal.
- Operational risk and proportionality assessment.
- Personnel, specialist teams, equipment and deployment.
- Static, mobile, physical and technical observation categories.
- Recording, logs, exhibits and continuity.
- Communications, supervision and operational control.
- Safety, contingency, abort and emergency procedures.
- Review, closure, retention, disclosure and audit.

Detailed intelligence assessment and source handling are governed by BP-21. Investigative purpose and case coordination are governed by BP-15 and BP-16. Evidence continuity and forensic treatment are governed by BP-23 and BP-24. Arrest, entry, search and other coercive powers are governed by BP-25 and BP-27 and the fictional legal framework.

This division is a governance and simulation specification, not a real-world operational manual for covert techniques. It does not supply tactical instructions for evading detection, defeating security systems or conducting unlawful surveillance.

### Fundamental principles
Every surveillance operation must:
- Have a defined and legitimate policing purpose.
- Be connected to a specific incident, case, threat or authorised intelligence objective.
- Be necessary and proportionate to that purpose.
- Use the least intrusive lawful method reasonably available.
- Have the correct authority before activity begins, except for a narrowly defined lawful emergency exception.
- Operate within the scope, conditions, duration and geographic limits of the authority.
- Protect people not relevant to the operation and minimise unnecessary collection.
- Be conducted by personnel with appropriate training, competence and supervision.
- Preserve accurate records of observations, decisions, recordings and interruptions.
- Be stopped, narrowed or reviewed when its justification no longer exists.
- Be subject to independent or external oversight where fictional law requires it.

The existence of an operation does not imply that a target is guilty or that surveillance will produce useful evidence.

### Surveillance categories
The system can classify operations by broad lawful activity type:
- **Overt observation:** visible police observation or monitoring where the nature of the activity is apparent.
- **Directed observation:** planned observation of a defined person, place or activity under the relevant authority.
- **Covert surveillance:** surveillance carried out in circumstances where the subject is unaware, subject to the specific fictional legal definition and authorisation regime.
- **Static observation:** observation associated with a fixed location or defined area.
- **Mobile observation:** observation involving movement between locations.
- **Technical surveillance:** use of authorised equipment or systems to observe, capture or record information.
- **Communications-related surveillance:** separately regulated activity involving communications data or content, where fictional law permits it.
- **Urgent protective observation:** time-critical observation to address a specific serious risk, subject to strict emergency rules and prompt review.

These are administrative categories. The exact statutory definitions, thresholds and permitted methods must be established by the fictional legal framework. A category does not itself grant authority.

### Operation identity and records
Every operation receives a unique surveillance operation identifier. The record links to the relevant case, incident, intelligence requirement or other authorised purpose.

The core record includes:
- Operation identifier and title.
- Purpose, objectives and scope.
- Requesting unit and responsible command.
- Lead officer and supervising officer.
- Persons, places, vehicles or activity of interest, where identified.
- Legal category and authorisation reference.
- Start date, expiry and review dates.
- Geographic and temporal scope.
- Risk, proportionality and collateral-intrusion assessment.
- Personnel and specialist support.
- Equipment and resource references.
- Operational status and significant decisions.
- Observation logs and recording references.
- Results, limitations and outcome.
- Closure, retention and review decision.

Restricted operational details are protected through BP-42. The system must support compartmented access without preventing authorised oversight or lawful disclosure.

### Application and justification
A proposal must explain the policing purpose and why surveillance is being considered. It identifies the question the operation is intended to answer, the expected value, the proposed category, duration, scope, affected people and places, foreseeable intrusion, alternatives considered and reasons those alternatives are insufficient or unsuitable.

The proposal must distinguish confirmed facts from intelligence, assumptions and unknowns. A vague request to monitor a person without a defined purpose is insufficient.

The application includes a necessity and proportionality assessment, including likely impact on family members, neighbours, employees, visitors, bystanders and other people who may be incidentally observed. It identifies measures to minimise collection unrelated to the objective.

### Authorisation and legal control
The fictional legal framework determines which authority is required, who may grant it, the applicable threshold, duration, renewal process, emergency provisions and oversight route.

The system records:
- Application and supporting rationale.
- Applicant identity and authority.
- Authorising officer or external authority.
- Decision and reasons.
- Conditions, limits and safeguards.
- Effective date, expiry and review dates.
- Any refusal, amendment or additional condition.
- Renewal applications and decisions.
- Revocation, suspension or early termination.

An application is not an authorisation. An expired, refused or revoked authority cannot be treated as active. A change in purpose, target, method, scope or intrusion level triggers a review and, where required, fresh authorisation.

### Emergency and urgent activity
If fictional law provides an emergency route, it must be narrowly defined by the seriousness and immediacy of the risk, the persons authorised to invoke it, the permitted scope and the required post-event review.

The system records the reason ordinary prior authorisation could not be obtained, the exact time activity began, the person authorising the emergency action, its limits, notification requirements and the decision of the competent authority on continuation. Emergency status is not a general exemption from safeguards.

If approval is refused or not obtained within the required period, the activity must stop as required by law, and material already obtained must be handled under the applicable legal and disclosure rules.

### Operational planning and deployment
An approved operational plan translates the authority into a controlled deployment. It identifies the objective, command structure, authorised personnel, broad activity boundaries, communications arrangements, resource requirements, safety considerations, contingencies, reporting intervals and stop conditions.

The plan must be consistent with the authority. Personnel must be briefed on scope, limitations, roles, safeguarding, recording requirements and how to report unexpected events. A plan cannot enlarge legal powers or permit activity excluded by the authorisation.

Personnel deployment and specialist capability are governed by BP-06 to BP-08 and BP-32. Resource allocation and equipment management are governed by BP-09.

### Operational risk and safeguards
Risk assessment considers risks to the public, subjects, officers, staff, vulnerable people, confidential sources, property, traffic, public services and the integrity of the operation. It also considers the risk of mistaken identity, unintended observation, disclosure, equipment failure and unexpected encounters.

The record identifies risk, likelihood, severity, mitigation, responsible person, residual risk and review triggers. Any serious incident, unexpected intrusion, threat to safety or material departure from the plan must be reported promptly and may require suspension.

### Conduct and operational control
The operation has a named operational lead and supervisory command. Personnel act only within their assigned role and approved scope. Significant changes, unexpected events, safety concerns, possible offences, contact with subjects or third parties, and potential legal breaches are reported through the designated command arrangements.

The simulation tracks operation status such as proposed, submitted, authorised, scheduled, active, suspended, under review, expired, revoked, completed or closed. Status changes include actor, time, reason and authority.

No operation should continue merely because resources have been deployed or time has been invested. The operational lead must stop or seek review when the objective is met, the authority expires, the purpose ceases, the risk becomes unacceptable or the activity moves outside authorised scope.

### Observation logs
An observation log records relevant events and the circumstances in which they were observed. Each entry identifies:
- Operation and log entry identifiers.
- Observer or recording source.
- Date and time, including any clock uncertainty.
- Location or area, with precision appropriate to the source.
- What was directly observed.
- What was heard or otherwise recorded, if authorised.
- Whether the entry is contemporaneous or reconstructed.
- Conditions affecting observation.
- Any uncertainty, interruption or limitation.
- Related recording or exhibit reference.

Logs distinguish direct observation from inference, interpretation and information received from another person. Entries must not state that an individual performed an act when the observer only saw an ambiguous movement or association.

### Recordings and technical material
Any recording or technical material is created, accessed and retained only within the operation's authority and applicable law. The system records the source device or system, operator, configuration reference, start and end times, clock settings, collection method, file identity, integrity verification, storage location, access history and any transformation or export.

Original material is preserved. Working copies and redacted copies are separately identified and linked to the unchanged source. Missing, corrupted, interrupted or inaccessible recordings are documented; the system must not invent missing content or imply continuous coverage where none exists.

### Incidental and collateral information
Surveillance may capture information about people, places or activities outside the main objective. The operation records the nature of incidental collection, why it occurred, whether it is relevant, and how it was minimised, restricted, segregated, retained or deleted under fictional law.

Material involving privileged, confidential, sensitive or protected relationships is escalated for specialist legal review. The system must not treat incidental collection as automatically authorised for every later purpose.

### Communications and command reporting
The operation uses approved communications and reporting channels. Significant instructions, changes, safety incidents, contact, deviations and decisions are logged with sender, recipient, time and acknowledgement where relevant.

Operational reporting should be concise, factual and distinguish observation from assessment. The command record supports later reconstruction of who knew what, when, and what decision followed.

### Results and investigative value
The operation's result is assessed against its original objectives. Outcomes may include:
- Objective achieved in whole or in part.
- No relevant activity observed.
- Observation inconclusive or incomplete.
- A new investigative lead identified.
- Information contradicting the current hypothesis.
- A safety or safeguarding concern identified.
- Operation suspended, refused, curtailed or terminated.
- No further action justified.

A lack of observed activity does not prove that activity did not occur. An apparent association does not establish criminal involvement. Results are passed to the lead investigator or intelligence owner with source, limitations and restrictions preserved.

### Review, renewal and closure
Operations are reviewed at defined intervals and when significant circumstances change. Review considers continuing necessity, proportionality, progress, collateral intrusion, risk, compliance, resource use, alternative methods and whether the objective remains achievable.

Renewal requires a current justification, not merely repetition of the original application. Closure records the reason, end time, final status, outstanding actions, material collected, retention and disclosure requirements, equipment return, personnel debrief and lessons identified.

### Complaints, errors and breaches
Complaints, unauthorised access, mistaken targeting, activity outside authority, excessive collection, lost material, disclosure failures, equipment misuse and other irregularities are recorded and escalated under BP-30 and BP-31.

The operation's original records and material are preserved. The system supports immediate suspension, notification to the competent authority, independent review, remedial action and disciplinary or legal referral where appropriate. A breach must not be concealed by editing the operational log.

### Evidence, disclosure and legal review
Surveillance material that may be evidential is transferred into the evidence management process under BP-23 with full continuity. The record includes the relationship between operational logs, original recordings, working copies, analyst products and exhibits.

Material that may undermine a case or assist another party is preserved and made available for disclosure review under BP-27. Restrictions on sensitive techniques or sources are handled through lawful review rather than omission or destruction. The fact that material is sensitive does not itself remove disclosure obligations.

### Player experience
The player may propose a surveillance requirement, prepare the justification, submit it to the appropriate authority, plan an authorised operation, take an assigned role, record observations, report unexpected events, request variation or renewal, and complete the operation with a result and debrief.

The player cannot bypass authorisation by simply issuing an operational command. The simulation must enforce role, competence, legal scope and expiry. It must not disclose hidden offender identities through operational prompts or guarantee that surveillance will observe a relevant event.

### Connections to other divisions
- **BP-02 to BP-04:** geography, people, properties and organisations.
- **BP-06 to BP-09:** personnel competence, units, deployment and resources.
- **BP-13 to BP-16:** offence context, event records, case management and investigative objectives.
- **BP-17 and BP-18:** victim, witness and suspect roles and safeguards.
- **BP-19:** interviews and interview-derived information.
- **BP-21:** intelligence requirements, source handling and assessment.
- **BP-22 to BP-24:** scenes, evidence continuity and forensic examination.
- **BP-25 to BP-29:** legal powers, court processes and outcomes.
- **BP-30 and BP-31:** governance, oversight and professional standards.
- **BP-37 to BP-43:** time, records, persistence, interface, notifications, security and testing.

### Exceptions and edge cases
The system must handle refused or expired authority, emergency activity, mistaken identity, multiple subjects, incidental observation of unrelated people, unexpected entry into a protected or sensitive location, a subject moving outside the authorised area, equipment failure, clock drift, recording gaps, lost communications, an officer becoming unavailable, a new serious risk, an operation producing no useful result, a source or method requiring restricted access, cross-jurisdiction activity, a complaint, a legal challenge and material later found to have been obtained outside authority.

### Acceptance conditions
- Every operation has a defined purpose, owner, authority and unique identifier.
- Application, authorisation, refusal, renewal, variation and revocation are distinct auditable events.
- Operations cannot exceed authorised scope or continue beyond expiry without valid authority.
- Necessity, proportionality, alternatives, collateral intrusion and risk are documented.
- Personnel and equipment are assigned with competence and accountability.
- Observation logs distinguish direct observation, inference and uncertainty.
- Recordings preserve originals, integrity, continuity and access history.
- Incidental information is handled under defined minimisation and retention rules.
- Unexpected events, breaches and complaints are escalated and preserved.
- Results are assessed against objectives without overstating what was observed.
- Material is transferred to evidence and disclosure processes with provenance.
- The player cannot bypass authority and receives no automatic solution disclosure.

**Draft status:** BP-20 is a working design. Exact surveillance definitions, authorising roles, thresholds, emergency powers, duration limits, oversight and disclosure protections must be established by the fictional legal framework. It is not a claim that surveillance capability has been implemented.

## BP-21 — Intelligence

### Purpose
Define the police service's intelligence function: how information is received, collected, recorded, evaluated, analysed, developed, disseminated, reviewed and retained to support prevention, safeguarding, threat assessment, resource planning and investigations.

The intelligence system must help decision-makers understand what is known, how it is known, how reliable the information may be, what remains uncertain and what action is legally justified. It must not convert unverified information into fact, treat association as proof of offending, or replace evidence and due process.

### Scope
This division governs:
- Intelligence requirements and priorities.
- Information intake from police and authorised external sources.
- Source registration, handling and protection.
- Information records, provenance and access controls.
- Assessment of source reliability and information credibility.
- Analysis, corroboration, confidence and uncertainty.
- Intelligence products, briefings, alerts and referrals.
- Threat, harm, vulnerability and pattern assessment.
- Intelligence development and review.
- Sharing, dissemination, retention and deletion.
- Governance, audit, complaints and correction.

Investigative case strategy is governed by BP-15 and BP-16. Interviews are governed by BP-19. Surveillance operations and authorisations are governed by BP-20. Evidence continuity and forensic examination are governed by BP-23 and BP-24. Legal powers and disclosure are governed by BP-25 to BP-27. This division defines the information-intelligence lifecycle and its interfaces with those systems.

This is a fictional governance and simulation design. It does not provide instructions for infiltrating groups, covertly recruiting sources, evading oversight, targeting protected communities or conducting intrusive collection unlawfully.

### Fundamental principles
The intelligence function must:
- Have a legitimate policing purpose and a defined requirement.
- Collect only information that is necessary and proportionate.
- Distinguish fact, allegation, observation, inference, opinion and unknown information.
- Preserve the original source, context, date, method and chain of handling.
- Assess source reliability separately from the credibility of each item supplied.
- Record uncertainty, contradictions, alternative explanations and gaps.
- Avoid discriminatory profiling and unsupported generalisations.
- Treat association, presence, reputation and prior contact as context, not proof of guilt.
- Protect sources, witnesses, victims and other vulnerable people.
- Restrict access according to lawful purpose, role and need.
- Share information only through authorised channels and with handling conditions.
- Correct inaccurate records while preserving an audit history.
- Keep intelligence distinct from admissible evidence and formal findings of guilt.
- Ensure that intelligence never automatically determines arrest, charge, employment, immigration or other coercive outcomes.

### Intelligence governance and command
The police service maintains a defined intelligence function with accountable command, trained personnel, specialist analytical support and clear referral routes to operational units. The structure identifies:
- National intelligence leadership and policy responsibility.
- Regional and city intelligence functions.
- Intelligence officers and analysts.
- Source-management responsibility where permitted by fictional law.
- Specialist analytical and safeguarding support.
- Authorising and reviewing roles.
- Independent oversight and complaint routes.

The exact rank, appointment, clearance and statutory powers of each role are defined by BP-05, BP-06, BP-08, BP-30 and BP-42. An intelligence role does not automatically confer investigative, surveillance, search, arrest or disclosure authority.

### Intelligence requirements and priorities
Intelligence work begins with a defined requirement. Requirements may arise from:
- A specific investigation or incident.
- A credible threat to life, safety or public order.
- A pattern of serious or repeat offending.
- Safeguarding and vulnerability concerns.
- Organised criminal activity.
- A geographic or thematic problem.
- Operational planning and resource allocation.
- A lawful request from an authorised partner agency.

Each requirement records its owner, purpose, scope, priority, decision-maker, review date and intended use. It should identify the question to be answered rather than request unrestricted information about a person or community.

Priorities are assessed using seriousness, likelihood, potential harm, vulnerability, urgency, confidence in the available information, legal constraints and available resources. Priority scores support human judgement; they do not replace it.

### Information intake
Information may be received from:
- Police officers and staff.
- Victims, witnesses and members of the public.
- Other police units and authorised agencies.
- Publicly available material where lawful and relevant.
- Case records, incident reports and evidence systems.
- Authorised partner organisations.
- Sources handled under the fictional legal framework.

Every intake is recorded with a unique identifier, date and time received, receiving person or system, origin, method, original wording or material where practicable, stated purpose, handling restrictions and initial assessment.

Anonymous, indirect, second-hand, translated, incomplete or potentially manipulated information is explicitly labelled. The system must not fabricate an identifiable source where none is known. A report that cannot be verified remains an unverified report.

### Source records and source protection
Where fictional law permits human or confidential sources, source information is managed through restricted records separated from general intelligence products. The source record may include:
- Unique source reference.
- Responsible handler and supervisor.
- Lawful basis and authorisation references.
- Date of registration and review.
- Contact and handling history.
- Known risks, vulnerabilities and safeguarding requirements.
- Restrictions on use and dissemination.
- Payments, benefits or other declared arrangements, where lawful.
- Reliability assessment history.
- Complaints, concerns or adverse information.
- Closure or inactive status and retention decision.

Identity details are accessible only to specifically authorised personnel. General users may receive a protected source reference and an appropriately sanitised assessment. The system must not expose a source's identity through ordinary search, reports, notifications, exports or linked case screens.

No source may be pressured, promised immunity, directed to commit offences or exposed to avoidable danger through an automated game mechanic. Any permitted source activity must be controlled by fictional law and recorded for review.

### Source reliability and information credibility
The system assesses two separate questions:

1. **Source reliability:** What is known about the origin's history, access, opportunity to know, possible motive, accuracy and limitations?
2. **Information credibility:** Is this particular account internally coherent, specific, plausible in context, independently corroborated, contradicted or otherwise supported?

A source with a strong historical record may provide inaccurate information. A new or anonymous source may provide accurate information. Neither status settles the truth of an individual report.

Assessments use a configurable, documented framework established by police policy. The system records the reasoning and evidence behind an assessment, not merely a letter or numerical score. Unknown reliability remains unknown; it must not be silently converted to a neutral or positive rating.

### Information evaluation and provenance
Each intelligence item retains:
- Unique intelligence reference.
- Original source reference and provenance.
- Date received and date the underlying event allegedly occurred.
- Location and persons or entities referenced, with identity confidence.
- Original content or preserved source artefact.
- Receiving officer and recording time.
- Source reliability assessment.
- Item credibility assessment.
- Corroboration and contradiction.
- Relevance to the intelligence requirement.
- Handling and dissemination restrictions.
- Review date and current status.
- Links to related items, incidents, cases and products.

The system distinguishes the date an event allegedly occurred from the date information was received and the date it was entered. Late entry and retrospective reconstruction are visibly marked.

### Identity resolution and entity matching
Intelligence may refer to a person, organisation, property, vehicle, account, device, event or location. The system must not merge records solely because names, descriptions or identifiers are similar.

Entity matching records the identifiers compared, match rationale, confidence, reviewer and any unresolved ambiguity. Possible matches remain separate until properly resolved. Aliases and known identity changes are linked with provenance and access restrictions.

Incorrect links must be reversible. A correction updates downstream views and alerts relevant users while preserving the original link, correction reason and audit history.

### Analysis and assessment
Analysis may identify patterns, connections, chronology, geographic concentration, recurring methods, emerging risks, information gaps and competing explanations.

Analytical work records:
- The intelligence requirement addressed.
- Information included and excluded.
- Analytical method at an appropriate descriptive level.
- Assumptions and limitations.
- Corroborating and contradictory material.
- Alternative hypotheses.
- Confidence and uncertainty.
- Analyst identity, reviewer and date.
- Conclusions and recommended decision points.

The system distinguishes a descriptive pattern from a causal explanation. Correlation, proximity, association or repeated appearance in records does not by itself establish coordination or criminality.

Analytical conclusions are reviewable and must be updated when material new information arrives. The system must preserve prior versions so that a decision can be reconstructed as it appeared at the time.

### Threat, harm and vulnerability assessment
Intelligence may support assessment of threats to individuals, groups, locations, infrastructure or public safety. The assessment records the nature of the potential harm, affected parties, likelihood, impact, urgency, information confidence, protective factors, uncertainty, mitigation and review trigger.

Vulnerability is not an indicator of criminality. Protected characteristics, lawful beliefs, peaceful association, occupation, nationality or residence must not be treated as risk factors without a specific lawful and evidence-based justification.

A threat assessment is not a finding that the person identified intends or will commit an offence. The system must present the basis, confidence and limitations alongside any risk category.

### Intelligence products
Permitted products include:
- Intelligence briefing.
- Threat or harm assessment.
- Pattern and trend report.
- Entity or network assessment.
- Geographic problem profile.
- Case-support intelligence summary.
- Operational briefing.
- Information gap and collection requirement.
- Strategic assessment.
- Safeguarding referral.
- Intelligence alert or advisory.

Each product has a unique reference, author, reviewer, intended audience, purpose, date, source references, confidence statement, restrictions, expiry or review date and version history.

Products must be clear about what is established, alleged, assessed or unknown. They should not reveal protected source identities or restricted details unless the recipient is specifically authorised and disclosure is necessary.

### Dissemination and information sharing
Before dissemination, the system checks the recipient's role, purpose, legal basis, need to know, security clearance and any source or handling restrictions. Sharing records the sender, recipient, time, information supplied, purpose, authority, conditions and acknowledgement where required.

External sharing follows the fictional country's data-sharing framework and any applicable agreement. A request from another agency does not automatically authorise disclosure. The system supports partial disclosure, sanitisation, refusal, escalation and recorded review.

Recipients must be able to report inaccuracies or newly discovered contradictions. Restrictions travel with the information through exports and linked systems where technically supported.

### Intelligence and evidence separation
Intelligence is information used to guide understanding and decisions. Evidence is material gathered and handled under the applicable evidential and legal rules. The same underlying information may later become evidence, but its status does not change automatically.

When intelligence generates an investigative lead:
- The lead is transferred with provenance and limitations.
- Investigators determine what lawful enquiries are required.
- Evidence is collected and recorded under BP-23 and BP-24.
- The original intelligence record is preserved.
- Any restrictions, source-protection issues and disclosure obligations are referred for legal review.

An intelligence assessment must not be presented as a witness statement, forensic result, admission, conviction or proven fact. Intelligence grades do not establish guilt and cannot alone satisfy the requirements for arrest or charge.

### Case and operational referrals
Intelligence may be referred to an investigation, incident, patrol unit, safeguarding team, surveillance proposal or another authorised function. The referral records:
- Sending and receiving units.
- Requirement and purpose.
- Relevant intelligence references.
- Confidence and limitations.
- Restrictions and source-protection conditions.
- Requested decision or action.
- Acceptance, rejection or clarification.
- Outcome and feedback.

A referral does not direct the receiving officer to take an unlawful action. Surveillance must separately meet BP-20 authorisation requirements. Investigative decisions remain under BP-15 and BP-16.

### Review, correction and challenge
Intelligence records are reviewed according to relevance, reliability, age, legal basis, risk and retention policy. Review may confirm, downgrade, qualify, correct, restrict, archive or delete information where authorised.

A person or agency may challenge information through the applicable complaint or correction process. The system records the challenge, decision-maker, evidence considered, outcome, reasons and any downstream notification.

Corrections must not silently overwrite history. Where information is found to be false or materially misleading, linked products and recipients are flagged for reassessment. The system must not continue to display a discredited assessment as current.

### Retention, archival and deletion
Retention is governed by lawful purpose, necessity, sensitivity, source protection, evidential value, review outcomes and statutory requirements. Each record has a retention category, review date, responsible owner and disposition history.

Deletion is authorised, recorded and applied to linked systems as required. Where preservation is required for an investigation, legal proceedings, complaint or audit, a lawful hold prevents routine deletion. The system distinguishes active intelligence from archived material and records any access to retained historical information.

### Security, access and audit
Access is role-based and purpose-limited. Sensitive source identities, protected intelligence, analytical products and general intelligence records may have different access levels. Users must not browse intelligence records without a legitimate work purpose.

Audit records include search, view, create, edit, link, unlink, export, print, share, correction, retention, deletion and permission changes. Alerts may identify unusual or unauthorised access for review, but automated alerts are not themselves findings of misconduct.

The security model, classification scheme, encryption, authentication, permissions and audit controls are defined with BP-38, BP-39 and BP-42. Data access must remain available to authorised oversight and lawful disclosure processes.

### Bias, fairness and protected information
Intelligence processes must guard against confirmation bias, stereotyping, circular reporting, source manipulation, mistaken identity and over-reliance on historical police contact.

The system must:
- Require a specific lawful purpose for collecting sensitive information.
- Record the evidential or intelligence basis for sensitive inferences.
- Distinguish an individual's conduct from the conduct of associates or groups.
- Avoid treating protected characteristics or lawful activity as proxies for suspicion.
- Include exculpatory, contradictory and alternative information.
- Flag low-confidence or stale assessments.
- Support independent review of consequential intelligence decisions.

### Player experience
The player may receive an intelligence briefing, submit information, assess a report, review provenance, identify gaps, request lawful analysis, compare competing explanations, prepare an intelligence product, disseminate it to an authorised recipient and refer a lead for investigation.

The interface must show the distinction between established facts, reports, assessments and unknowns. It must not reveal hidden offender identities, silently resolve uncertainty or provide automatic solution hints. The player decides how to investigate and what conclusions the available material supports.

### Connections to other divisions
- **BP-02 to BP-04:** geography, population, properties and organisations.
- **BP-05 to BP-09:** police structure, personnel, career, units and resources.
- **BP-10 to BP-12:** patrol, emergency communications and incidents.
- **BP-13 to BP-16:** offences, crime generation, cases and investigations.
- **BP-17 to BP-19:** victims, witnesses, suspects and interviews.
- **BP-20:** surveillance proposals, authority and operational results.
- **BP-22 to BP-24:** scenes, evidence and forensic material.
- **BP-25 to BP-29:** legal powers, custody, prosecution, courts and corrections.
- **BP-30 to BP-34:** governance, standards, training, HR and resources.
- **BP-35 to BP-37:** simulation, social context and time.
- **BP-38 to BP-44:** records, persistence, interface, reporting, security, testing and configuration.

### Exceptions and edge cases
The system must handle anonymous and malicious reports, deliberate misinformation, conflicting accounts, source deception, uncertain identity, duplicate reports, stale information, incorrect entity links, source compromise, source safety concerns, accidental disclosure, unauthorised access, protected or privileged information, cross-jurisdiction requests, emergency threat referrals, contradictory or exculpatory material, a change in legal basis, retention holds, deletion requests, corrections after dissemination and intelligence later used as an evidential lead.

### Acceptance conditions
- Every intelligence requirement and item has a unique reference, purpose, owner and provenance.
- Source reliability and item credibility are assessed separately and transparently.
- Original information and later assessments remain distinguishable and auditable.
- Facts, allegations, inferences, opinions and unknowns are clearly labelled.
- Contradictions, alternative explanations, confidence and uncertainty are retained.
- Entity matching cannot silently merge uncertain identities.
- Intelligence products identify sources, limitations, audience, restrictions and review dates.
- Dissemination is purpose-limited, authorised and recorded.
- Intelligence referrals do not bypass surveillance, investigative or evidential authority.
- Intelligence is not automatically treated as evidence or proof of guilt.
- Corrections, retention, deletion and legal holds preserve an audit trail.
- Sensitive sources and information receive appropriate access controls and oversight.
- Bias safeguards and exculpatory information are supported.
- The player receives useful intelligence without hidden-solution disclosure or automatic investigative conclusions.

**Draft status:** BP-21 is a working design. Exact intelligence powers, source-handling rules, classification standards, retention periods, sharing authorities, oversight and legal disclosure requirements remain to be defined by the fictional legal and governance frameworks. No intelligence software or operational capability is claimed to have been implemented.

## BP-22 — Crime Scenes

### Purpose
Define how the police service identifies, assesses, protects, manages, examines, documents and releases locations or environments that may contain material relevant to an incident or investigation. The division provides a controlled framework for preserving scene integrity, protecting people, coordinating specialist attendance and ensuring that material is recorded and transferred into the evidence system.

A crime scene is not limited to a building or a place where an offence is believed to have occurred. It may include a vehicle, outdoor area, digital or administrative environment, temporary location, multiple connected locations, or a place where evidence is found or transferred. Scene status is an investigative classification, not proof that a crime occurred or that any person is responsible.

### Scope
This division governs:
- Scene identification, classification and creation.
- Initial response, safety assessment and preservation.
- Scene boundaries, access control and entry records.
- Scene command, responsibilities and coordination.
- Scene documentation and condition records.
- Search planning and examination coordination at a governance level.
- Specialist attendance and scene services.
- Material recognition, recording, collection referral and transfer.
- Contamination prevention and incident recording.
- Multiple, linked, transient and changing scenes.
- Scene review, release, reopening and closure.
- Public, property-owner and occupant considerations.
- Audit, legal review and quality assurance.

Physical evidence registration, continuity, storage and disclosure are governed by BP-23. Forensic methods and examinations are governed by BP-24. Investigative objectives and case strategy are governed by BP-15 and BP-16. Emergency response and incident command interfaces are governed by BP-10 to BP-12.

This is a fictional policing-system design. It describes governance, accountability and simulation behaviour rather than providing detailed forensic or tactical instructions that could compromise real crime-scene security or investigations.

### Fundamental principles
Every scene response must:
- Prioritise life safety, medical care and prevention of further harm.
- Establish a lawful basis for police presence, access, search and continued control.
- Preserve the scene as found as far as reasonably practicable.
- Recognise that necessary rescue, medical treatment, fire suppression and hazard control may alter a scene.
- Record unavoidable disturbance and the reasons for it.
- Use proportionate boundaries and access restrictions.
- Limit access to authorised personnel with a recorded operational purpose.
- Maintain a contemporaneous record of significant decisions, entries, exits and changes.
- Protect the rights, property, dignity and privacy of victims, occupants, witnesses and other affected people.
- Distinguish observed conditions from interpretation and hypothesis.
- Ensure that scene findings do not automatically establish offence, identity, intent or guilt.
- Preserve material and records in a manner that supports later review and disclosure.

### What constitutes a scene
A scene may be designated where there is a reasonable operational basis to believe that a location or environment:
- Is where an incident or suspected offence occurred.
- Contains, may contain or previously contained relevant material.
- Is connected to the movement, storage or transfer of relevant material.
- Is a secondary, linked or related location.
- Requires controlled examination to resolve an investigative question.
- Must be preserved to protect life, prevent loss or comply with lawful authority.

Scene designation records the reason and responsible decision-maker. A scene may be designated as confirmed, suspected, potential, secondary, linked, transient, virtual/digital, or subsequently excluded. These labels describe operational status and confidence; they do not decide the legal character of an event.

### Scene identification and creation
A scene record is created from an incident, investigative decision or authorised referral. It receives a unique scene identifier and links to the originating incident and any related cases.

The record includes:
- Scene identifier and scene type.
- Address or geographic description and precise sub-location where appropriate.
- Date and time discovered, reported and attended.
- Reporting person and source of the information.
- Incident and case references.
- Reason for designation and current confidence.
- Initial attending personnel and responsible supervisor.
- Initial safety and preservation decisions.
- Known occupants, victims, witnesses and other affected persons, subject to access controls.
- Legal basis and scope of police control or examination.
- Scene status and review information.

If one incident involves several locations, each scene has its own record and identifier, linked through a common incident or case. One scene record must not be used to obscure distinct locations, access histories or evidential provenance.

### Initial response and life safety
The first responding personnel assess immediate threats to life and safety, arrange emergency assistance and take reasonable steps to prevent further harm. Medical treatment, rescue, fire and other emergency services take priority where necessary.

The first responder records, as far as practicable:
- Arrival and departure times.
- Conditions observed on arrival.
- People present and their roles.
- Emergency actions and services requested.
- Persons entering or leaving before formal scene control.
- Changes caused by rescue, treatment, hazard management or other necessity.
- Initial preservation actions and any limitations.

The system must never penalise or treat as misconduct a necessary and reasonable life-saving action solely because it altered potential evidence. The resulting disturbance should be documented for later assessment.

### Scene safety and hazard management
The scene risk assessment considers hazards to the public, occupants, police, emergency personnel and specialists. Relevant categories may include structural instability, fire, electrical or chemical hazards, biological exposure, traffic, environmental conditions, animals, weapons, unsafe equipment and other location-specific risks.

The scene record identifies:
- Hazard description and source.
- Persons potentially exposed.
- Immediate controls and responsible service.
- Access restrictions and required competence.
- Residual risk and review trigger.
- Any incident, exposure or injury.

Police personnel must not be assigned work beyond their training, equipment or legal authority. Specialist agencies may be required before examination can safely proceed.

### Scene boundaries and access control
The scene manager defines boundaries proportionate to the known facts, likely material, safety risks and lawful powers. Boundaries may be revised as information develops. The system records the basis, time, author and effect of each significant change.

Access controls identify:
- Controlled area or zone.
- Entry and exit point references.
- Authorised categories of personnel.
- Access conditions and restrictions.
- Scene manager or delegated controller.
- Start and end time of restrictions.
- Public access, occupant access and property arrangements.

A boundary is an operational control, not a declaration of ownership or a substitute for lawful authority. Control of a location must not exceed the powers and duration permitted by the fictional legal framework.

### Scene command and responsibilities
Each managed scene has an identified scene manager or responsible officer appropriate to its scale and complexity. Larger or multi-agency scenes may have a documented command structure and designated specialist leads.

Responsibilities may include:
- Scene preservation and access control.
- Safety coordination.
- Scene documentation.
- Examination coordination.
- Liaison with investigators and specialists.
- Victim, witness and occupant considerations.
- Resource and attendance coordination.
- Decision logging and escalation.
- Review and release recommendations.

The scene manager coordinates activity but does not automatically become the lead investigator, forensic examiner, legal authoriser or owner of every item of evidence. Roles, competence, delegation and supervision are separately recorded.

### Scene status and lifecycle
A scene follows a controlled lifecycle. Suggested statuses include:
- Reported or potential.
- Identified.
- Assessed.
- Designated.
- Secured or controlled.
- Awaiting specialist assessment.
- Under examination.
- Partially released.
- Released.
- Reopened.
- Closed or archived.

Status changes record actor, time, reason, authority and supporting record. A scene may be partially released where distinct areas can safely and lawfully be returned without compromising remaining work. Scene closure does not automatically close the incident or investigation.

### Scene condition and documentation
The system maintains a scene condition record, including relevant observations before, during and after examination. Documentation may include written notes, sketches, plans, photographs, video, measurements, environmental conditions and specialist records, where lawfully obtained.

Each record identifies:
- Creator and role.
- Date and time created.
- Location or subject represented.
- Method and source device where relevant.
- Whether it is contemporaneous, copied, enhanced, annotated or reconstructed.
- Original file or record reference.
- Any limitation, obstruction, uncertainty or alteration.
- Storage and access history.

Original records are preserved. Annotated, enhanced, cropped, converted or otherwise derived versions are separately identified and linked to the original. The system must not present a reconstruction as an original contemporaneous record.

### Scene entry and activity log
Every controlled entry and exit is recorded, including personnel identity, organisation, role, time, purpose, authorising or approving person where required, and relevant area accessed. Emergency access and unavoidable unrecorded entry are documented as soon as practicable with an explanation.

The scene activity log records significant actions, decisions, changes in conditions, handovers, interruptions, equipment issues, incidents and departures from the plan. Entries preserve the actual sequence and distinguish contemporaneous records from later additions.

Corrections are appended or versioned; original entries are not silently overwritten. The system records who made each correction, when and why.

### Examination planning and coordination
Examination begins with a defined purpose, lawful basis, appropriate competence and a documented plan proportionate to the scene. The plan identifies:
- Investigative questions and examination objectives.
- Areas or items requiring attention.
- Relevant specialist disciplines.
- Priority and dependencies.
- Access and safety requirements.
- Responsibilities and expected records.
- Known limitations and potential conflicts.
- Review and completion criteria.

The system coordinates work and records decisions but does not automatically select a forensic conclusion. Examiners retain responsibility for their professional methods and findings under BP-24.

### Search and examination governance
The scene record tracks approved examination areas, responsible personnel, start and completion times, scope, status and reports. Any expansion beyond the original scope must be justified and authorised under the applicable law and procedure.

The system records whether an area was examined, not examined, inaccessible, unsafe, disturbed, unavailable or outside scope. It must not imply that an unexamined area was clear or that the absence of a recorded finding proves absence of material.

Detailed search methodology is maintained by approved professional procedures and BP-24, not improvised by the simulation.

### Material recognition and evidence handover
Potentially relevant material is recorded at the scene with a provisional reference and linked to its precise recovery context. The scene system coordinates the handover to BP-23, where formal evidence identifiers, packaging, continuity, storage and disclosure are managed.

The handover record includes:
- Scene and case references.
- Provisional material reference.
- Description and condition as observed.
- Exact recovery location and context.
- Discovering and collecting personnel.
- Date and time.
- Relevant authorisation and examination reference.
- Any disturbance, limitation or special handling requirement.
- Transfer recipient, time and acknowledgement.

The system must prevent a provisional scene reference from being mistaken for a final evidence identifier. Uncollected, abandoned, consumed, damaged or unavailable material is documented with the reason and decision.

### Contamination and integrity management
The scene manager records known or suspected contamination risks and any event that may affect interpretation or evidential value. This includes unauthorised access, uncontrolled movement, overlapping personnel, environmental exposure, packaging or handling issues, scene disturbance, cross-contamination concerns and documentation gaps.

The system records the event, persons and material potentially affected, time discovered, immediate response, notifications, assessment owner and resulting limitations. It must not automatically declare evidence invalid; that is a matter for competent forensic and legal assessment.

### Victims, witnesses, occupants and property
Scene management must account for the needs and rights of people affected by police activity. Records may include:
- Safe access to medical care and support.
- Identification and safeguarding needs.
- Property access and essential belongings.
- Occupant and owner contact details under access controls.
- Explanation of restrictions and expected review.
- Arrangements for alternative accommodation or practical support where applicable.
- Return of property and keys.
- Complaints or concerns about scene control.

The simulation distinguishes a property owner, occupier, tenant, employee, visitor and person with another lawful interest. None is automatically a suspect because of their relationship to the scene.

### Multi-agency and specialist coordination
The scene may require coordination with emergency medical services, fire and rescue, public authorities, forensic specialists, technical experts, property managers or other agencies. Each agency's attendance, role, authority, activity and handover are recorded.

Information sharing is purpose-limited and subject to the relevant legal and security controls. Police scene management does not confer police powers on partner agencies, nor does another agency's attendance expand police authority.

### Multiple, linked and changing scenes
The system supports multiple scenes arising from one event, scenes connected across cases, scenes discovered later, and scenes that change due to weather, public access, emergency works or other external factors.

Each scene retains its own chronology, access log, condition record, authority and evidence references. A common case link must not collapse the separate provenance of material recovered at different locations.

Transient scenes and rapidly changing environments require a recorded decision about what can reasonably be preserved and what limitations remain. A scene may be lost or altered; the system records this honestly rather than generating a fictional complete record.

### Digital and non-physical scene interfaces
Where an incident involves a digital environment, account, network, device or virtual location, BP-22 may hold a scene-like coordination record for authority, preservation status, responsible personnel and handover. The technical acquisition, forensic handling and analysis of digital material remain governed by BP-23 and BP-24 and the fictional legal framework.

The record must distinguish a physical location, a device, an account, a service and a data source. Access to one does not automatically authorise access to the others.

### Scene release and reopening
Release requires a documented review of:
- Whether the scene objectives have been completed or can be completed elsewhere.
- Whether remaining areas or material need continued control.
- Whether all necessary records and transfers are complete.
- Whether safety hazards remain.
- Whether lawful authority continues to support restrictions.
- Whether victims, occupants and property interests have been considered.
- Who is responsible for the release decision.

The release record includes date and time, areas released, areas retained, decision-maker, reasons, outstanding actions, property arrangements and notification to relevant people.

A scene may be reopened where new information, a legal decision or a justified examination need requires it. Reopening requires a new recorded basis, authority check, risk review and updated access controls.

### Review, quality assurance and complaints
Supervisors review compliance with preservation, access, documentation, authority, safety and handover requirements. Significant incidents, unexplained access, missing logs, material disturbance, complaints or potential breaches are escalated under BP-30 and BP-31.

Quality review identifies missing records, inconsistent timelines, unsupported statements, gaps in handover and unresolved contamination concerns. It must not alter original records to make a scene appear more complete or compliant than it was.

### Player experience
The player may attend a scene, assess immediate needs, request support, establish proportionate control, record initial conditions, coordinate authorised personnel, maintain access and activity logs, request specialist examination, document findings, transfer potential material, review outstanding work and recommend release.

The player must make decisions within role, competence and lawful authority. The simulation presents the scene as it is known at the time, including uncertainty, gaps and possible disturbance. It must not reveal a hidden offender, supply automatic solution hints or guarantee that every scene contains recoverable evidence.

### Connections to other divisions
- **BP-02 to BP-04:** geography, people, properties and organisations.
- **BP-05 to BP-09:** police architecture, personnel, units, deployment and resources.
- **BP-10 to BP-12:** patrol, emergency communications and incident management.
- **BP-13 to BP-16:** offence classification, crime generation, case management and investigation.
- **BP-17 to BP-19:** victims, witnesses, suspects and interviews.
- **BP-20 and BP-21:** surveillance records and intelligence context.
- **BP-23 and BP-24:** evidence management and forensic examination.
- **BP-25 to BP-29:** warrants, custody, legal processes, courts and corrections.
- **BP-30 to BP-34:** governance, standards, training, HR and procurement.
- **BP-35 to BP-37:** simulation engine, social context and time.
- **BP-38 to BP-44:** records, persistence, interface, notifications, security, testing and configuration.

### Exceptions and edge cases
The system must handle life-saving disturbance, emergency-service access before police arrival, multiple responding agencies, uncertain scene boundaries, an occupied property, public or shared spaces, weather damage, scene contamination, unauthorised entry, missing or inaccurate access logs, a specialist unavailable, unsafe or inaccessible areas, multiple linked scenes, changing legal authority, partial release, disputed ownership or occupation, digital evidence interfaces, lost or damaged material, delayed scene discovery, a scene reopened after release and a complaint or legal challenge to police control.

### Acceptance conditions
- Every scene has a unique identity, location, originating incident or case and accountable owner.
- Scene designation and status do not imply that an offence or guilt has been established.
- Life safety and emergency response take priority, with resulting disturbance recorded.
- Scene control has a documented lawful basis, scope, boundaries and review.
- Entry, exit, attendance, activity and significant decisions are auditable.
- Original scene records are preserved and derived records are separately identified.
- Examination plans identify purpose, authority, competence, scope and limitations.
- Unexamined or inaccessible areas are not represented as clear.
- Potential material is handed over with location, context, provenance and acknowledgement.
- Contamination and disturbance are recorded for competent assessment.
- Victim, occupant, owner and other property interests are considered.
- Multiple scenes retain separate records and evidential provenance.
- Partial release, full release and reopening are controlled and auditable.
- Complaints, errors and breaches are escalated without rewriting history.
- The player operates within role, competence and authority and receives no hidden-solution disclosure.

**Draft status:** BP-22 is a working design. Exact scene-entry powers, search authority, retention, property access, disclosure and review requirements remain subject to the fictional legal framework and professional standards. This document does not claim that crime-scene systems or operational capabilities have been implemented.

## BP-23 — Evidence Management

### Purpose
Define the authoritative lifecycle for identifying, recording, collecting, receiving, preserving, packaging, transferring, storing, examining, disclosing, presenting, retaining and disposing of material that may be relevant to a police matter or legal proceeding.

The evidence system must preserve what an item or information source is, where it came from, who handled it, what was done to it, where it has been, what condition it was in and what limitations apply. It must support reliable reconstruction and fair legal proceedings without overstating evidential value.

Evidence management is an auditable custody and information-control function. It does not decide guilt, prove an allegation merely because an item exists, or replace the professional assessment of investigators, forensic examiners, prosecutors or courts.

### Scope
This division governs:
- Evidence and material classification.
- Unique identifiers and item registration.
- Recovery, seizure, receipt and acquisition records.
- Packaging, labelling and preservation requirements.
- Chain of custody and transfer control.
- Storage, location and environmental monitoring.
- Access, handling, movement and audit.
- Examination requests and specialist handovers.
- Digital and documentary material management.
- Continuity exceptions, loss, damage and contamination.
- Disclosure, retention, legal holds and disposal.
- Property return and lawful release.
- Evidence reporting, court production and post-case outcomes.
- Quality assurance, security and system governance.

Scene management and initial scene context are governed by BP-22. Forensic examination and technical interpretation are governed by BP-24. Case and investigative strategy are governed by BP-15 and BP-16. Legal powers, disclosure obligations and court proceedings are governed by BP-25 to BP-28. This division owns the authoritative evidence register and custody history.

This is a fictional evidence-governance and simulation specification. It does not provide practical instructions for defeating forensic examination, concealing evidence, contaminating material or obstructing investigations.

### Fundamental principles
Evidence management must:
- Assign a unique, persistent identity to every registered item or material unit.
- Preserve the original source and context.
- Maintain an auditable chain of custody from acquisition to final disposition.
- Record every transfer, access, examination, alteration, opening, resealing and movement.
- Distinguish original material from copies, extracts, derivatives and analytical products.
- Record condition, limitations, damage, contamination and uncertainty honestly.
- Preserve potentially relevant material, including material that may undermine an allegation or assist a person under investigation.
- Prevent unauthorised access, substitution, destruction or undocumented handling.
- Use appropriate packaging, storage and specialist controls as determined by approved professional standards.
- Separate custody facts from opinions about evidential significance.
- Retain records and material for the legally required period.
- Support lawful disclosure, challenge, independent review and court scrutiny.
- Never infer authenticity, admissibility, reliability or guilt from registration alone.

### Evidence and material categories
The system supports a broad and configurable catalogue, including:
- Physical objects and trace material.
- Biological material and samples.
- Documents, records and printed material.
- Photographs, audio and video.
- Digital devices and digital data.
- Communications and account-related records lawfully obtained.
- Financial, business and administrative records.
- Scene samples and environmental material.
- Reference, comparison and control material.
- Demonstrative exhibits and presentation copies.
- Intelligence-derived leads later acquired as evidence.
- Material received from another agency or external provider.

Categories support workflow and specialist handling. They do not predetermine evidential weight or legal admissibility. A single exhibit may contain multiple components; separately packaged or separately examined components must have traceable subordinate identifiers.

### Evidence identity and registration
Every item formally accepted into evidence management receives a unique evidence identifier that is never reused. Identifiers remain stable across cases, transfers, examinations and court proceedings.

The core record includes:
- Evidence identifier and item version where applicable.
- Item description, category and quantity or extent.
- Condition at the point of receipt or recovery.
- Originating case, incident and scene references.
- Recovery, seizure, receipt or acquisition basis.
- Exact source location or source system, where known.
- Date and time of acquisition and registration.
- Collecting or submitting person and organisation.
- Receiving custodian and receiving time.
- Packaging, seal and label references.
- Photographic or documentary record references.
- Initial storage location and handling requirements.
- Legal authority and restrictions.
- Current status, custodian and location.
- Review, retention and disclosure classifications.

The record distinguishes the date material was created, the date it was obtained, the date it was submitted and the date it was registered. Late registration and reconstructed details are explicitly marked.

### Acquisition and acceptance
Material may enter the system through a scene recovery, lawful seizure, voluntary submission, digital acquisition, external agency transfer, medical or specialist service, court direction or another lawful route.

The acquisition record identifies the authority or basis, scope, person responsible, circumstances, source, date and time, and any restrictions or conditions. The system records whether the material was collected by police, received from another person, copied from a source, exported from a system or generated through an examination.

On receipt, a custodian checks the submission against the accompanying record, identifies apparent discrepancies and records the condition of the item and its packaging. Acceptance, conditional acceptance, quarantine or refusal are separate outcomes with reasons. A registration entry does not retrospectively legalise an unlawful acquisition.

### Provisional references and formal evidence IDs
Scene or operational systems may assign provisional references before formal evidence submission. The evidence register records the relationship between each provisional reference and its formal evidence identifier.

The mapping is explicit and auditable. A provisional identifier cannot be mistaken for a formal evidence record, and a formal evidence identifier cannot silently replace the source reference in scene logs, photographs or witness accounts.

If one provisional reference is found to represent multiple distinct items, the system creates separately identifiable records while preserving the original mapping and correction history.

### Chain of custody
Chain of custody is a chronological record of control and handling. Every custody event records:
- Evidence identifier.
- Event type and purpose.
- Releasing person or custodian.
- Receiving person or custodian.
- Date and time, including time-zone or clock uncertainty where relevant.
- Origin and destination.
- Authority or approval where required.
- Condition and packaging status.
- Seal identifiers and recorded seal condition.
- Reason for movement or access.
- Acknowledgement by the receiving custodian.
- Any discrepancy, interruption or exception.

The chain includes acquisition, initial receipt, storage, retrieval, transport, examination, return, court production, transfer to another agency and final disposition. System-generated events and human attestations are distinguishable.

A transfer is not complete merely because a dispatch or handover was initiated. The receiving custodian must acknowledge receipt or the record must show the unresolved status and escalation.

### Packaging, labels and seals
The system records packaging type, packaging reference, label version, seal identifiers, sealing and resealing events, and the person responsible. Requirements for packaging and preservation are determined by the relevant professional discipline and approved standards.

Where packaging is opened for an authorised purpose, the record captures the authority, reason, person, date and time, condition on opening, examination or handling performed, new packaging and seal details, and return to custody.

The system must not assume that a seal is intact merely because no breach was recorded. Seal condition is an observation recorded at each relevant custody event. Damaged, missing, mismatched or unexplained seals trigger a discrepancy and review.

### Storage and location control
Evidence storage supports approved locations, secure cabinets, controlled rooms, specialist facilities, digital repositories and authorised external storage. Each location has a unique reference, custodian, access policy, capacity and relevant environmental or security controls.

The evidence record tracks:
- Current and historical location.
- Storage condition requirements.
- Access permissions.
- Environmental monitoring where applicable.
- Retrieval and return events.
- Temporary storage and transport status.
- Quarantine or restricted status.
- Inventory checks and discrepancies.

Storage requirements are material-specific and defined by approved standards. The system alerts responsible personnel to review dates, environmental exceptions, overdue returns and unresolved location discrepancies.

### Access, handling and audit
Every access to registered material is recorded, including viewing, opening, handling, copying, sampling, testing, transfer, export and return. The record identifies the user, role, purpose, time, authority and resulting action.

Access is role-based and limited to a legitimate purpose. A user may be permitted to view a record without being permitted to retrieve or handle the physical item. Sensitive, privileged, protected or highly restricted material has additional controls.

Audit history is append-only for ordinary users. Corrections and annotations are separately recorded with author, time and reason. Unauthorised access, unexplained movement, attempted alteration and missing acknowledgements are escalated.

### Examination requests and specialist handovers
An examination request links the evidence item to an authorised investigative question and the relevant specialist discipline. It identifies:
- Requesting investigator and case.
- Evidence identifiers and requested scope.
- Purpose and specific questions.
- Legal authority and any restrictions.
- Relevant background information, with provenance.
- Priority and requested completion date.
- Known risks, handling constraints and disclosure considerations.
- Approving or reviewing person where required.

The receiving examiner acknowledges the items and condition, records any discrepancy, performs work within competence and authorised scope, and returns the material or transfers it under a new recorded custody event.

The request must not dictate a desired result. Examiners record findings, limitations and uncertainty independently. Detailed methods, validation and interpretation are governed by BP-24.

### Sampling, consumption and alteration
Where an authorised examination consumes, depletes, alters, separates or otherwise changes material, the system records the authority, purpose, amount or extent where measurable, pre- and post-examination condition, examiner, method reference, resulting sub-items, retained portions and any limitation on future testing.

Destructive or limited-sample work requires the approvals and safeguards set by law and professional standards. Where feasible and lawful, the system records whether another party may need an opportunity for independent examination. The system must not imply that consumed material remains available for retesting.

### Digital and electronic evidence
Digital material includes devices, storage media, extracted data, files, logs, images, audio, video, account records and data obtained from external services. The evidence record distinguishes:
- Original physical device or medium.
- Forensic or working copy.
- Logical or selective export.
- Individual file or data object.
- Report, transcript or analytical derivative.
- Cloud or third-party source record.

The system stores acquisition authority, source, acquisition date and time, responsible person, tool or process reference, integrity-verification information, scope, completeness, known gaps, transformations, storage and access history.

Original data and forensic masters are protected from ordinary modification. Working copies and derived outputs have separate identifiers and links to their source. The system records any conversion, extraction, redaction, enhancement, transcription or other processing. It must not claim that a copy is bit-for-bit identical unless a documented verification supports that claim.

Access to a device does not automatically authorise access to every account, service or remote data source associated with it. Legal authority and scope are recorded separately.

### Documentary, audio and video material
Documents and recordings retain their source, original format where available, acquisition method, creator or originating system if known, date and time context, completeness, metadata status and any conversion or transcription.

A transcript is a derivative, not the original recording. A translation, summary, enhancement or edited extract is separately identified and linked to the unaltered source. Any uncertainty, missing segment, inaudible content, time offset or editing limitation is recorded.

### External and third-party material
Material received from another police service, public authority, business, service provider, laboratory, medical organisation or private individual records the provider, acquisition route, legal basis, terms of receipt, source system, transfer method, completeness and any restrictions.

The system distinguishes the provider's assertions from independently verified facts. Where the original source remains with another organisation, that limitation and the route for obtaining or challenging the original are recorded.

### Continuity exceptions and discrepancies
The system supports a formal discrepancy record for:
- Missing or delayed custody events.
- Unacknowledged transfers.
- Damaged, missing or mismatched seals.
- Unexplained access or movement.
- Incorrect or incomplete labels.
- Storage-location mismatch.
- Damaged, degraded or lost material.
- Possible contamination or substitution.
- Inconsistent timestamps or identity references.
- Incomplete digital acquisition or integrity verification.
- Unauthorised handling or access.

Each discrepancy records when and how it was identified, the reporter, affected material, known facts, immediate preservation action, persons notified, review owner, investigation, impact assessment and resolution. The original chain remains visible. No user may silently repair a gap by inserting an event as if it had been contemporaneously recorded.

A continuity issue does not automatically make material inadmissible or worthless. Its significance is assessed by competent investigators, specialists, prosecutors and courts.

### Evidence status and evidential neutrality
The system separates custody status from legal and investigative assessment. Suggested custody statuses include submitted, received, quarantined, accepted, stored, in transit, under examination, returned, transferred, court-produced, retained, released, disposed or missing under investigation.

Separate assessment fields may record relevance, authenticity concerns, reliability limitations, disclosure category and legal status. These are attributed opinions or decisions, not intrinsic properties automatically inferred from the item's presence.

Material may support, contradict or be neutral to an allegation. The system must retain exculpatory and alternative material and prevent the evidence register from displaying only prosecution-supporting items.

### Disclosure and unused material
The evidence system supports disclosure review by linking material to the relevant case, issues, statements, forensic reports, unused material schedules and legal decisions. It records:
- Whether material has been reviewed for disclosure.
- Reviewing person and date.
- Relevance and disclosure assessment with reasons.
- Potential to undermine the prosecution case or assist another party.
- Sensitivity, privilege or lawful restriction requiring review.
- Redaction or sanitisation history.
- Disclosure decision and recipient.
- Version supplied and date.
- Any subsequent reassessment.

The system must not automatically withhold material because it is sensitive, inconvenient or adverse to the prosecution. Disclosure rules and judicial directions are governed by BP-27 and BP-28. A disclosure decision must be attributable and reviewable.

### Court production and legal proceedings
When material is prepared for court, the record identifies the case, court, hearing or proceeding, requested exhibits, responsible custodian, transfer or production details, condition, receipt and return or onward disposition.

Copies, demonstratives and presentation versions are distinguished from original exhibits. The system records any court order, restriction, challenge, agreed fact, ruling or direction affecting the material. Court production does not end custody responsibility unless a formal transfer or lawful disposition is recorded.

### Retention, legal holds and disposal
Retention is based on legal requirements, case status, appeal periods, potential further proceedings, safeguarding, disclosure duties, material type and authorised policy. Each item has a retention category, responsible owner and review date.

Legal holds prevent routine disposal where proceedings, appeal, complaint, inquiry, review or other lawful requirement remains active. Holds identify the authority, scope, owner, start date and release decision.

Disposal requires documented authority, confirmation that no retention or disclosure obligation remains, method, date, responsible person and witness or verification where required. The system records destruction or deletion certificates and retains the audit metadata required by law. No material is disposed of merely because a case is closed.

### Return and release of property
Property that is not required to be retained may be returned to its lawful owner or released under an authorised process. The record identifies the person claiming the property, proof or basis of entitlement, decision-maker, legal restrictions, condition, date, recipient acknowledgement and any unresolved dispute.

Where ownership is uncertain, property is jointly claimed, subject to court order or potentially relevant to another case, the system records the restriction and review route. Return of property does not delete its historical evidence record.

### Quality assurance, complaints and misconduct
Supervisors and authorised auditors review inventory accuracy, custody completeness, access, storage, examination handovers, disclosure status and retention. Complaints, suspected misconduct, tampering, loss, unexplained access or deliberate record alteration are referred under BP-30 and BP-31.

The system preserves relevant records and audit logs during an investigation. It supports independent review and corrective action without changing the historical record. Evidence-system administrators cannot use technical privileges to conceal custody events.

### Player experience
The player may register material, review its provenance, submit it to custody, arrange lawful transfer, request an examination, track storage and status, document discrepancies, review results, prepare disclosure material, arrange court production and recommend lawful return or disposal.

The interface makes clear which actions require a custodian, supervisor, specialist or legal authority. The player cannot silently alter chain-of-custody history, erase inconvenient material, bypass retention holds or turn an intelligence lead into evidence without a documented acquisition process. The system does not reveal hidden offender identities or supply automatic investigative solutions.

### Connections to other divisions
- **BP-02 to BP-04:** locations, people, properties and organisations.
- **BP-05 to BP-09:** police structure, personnel, units, resources and storage facilities.
- **BP-10 to BP-12:** patrol, communications and incident records.
- **BP-13 to BP-16:** offence, crime event, case and investigation records.
- **BP-17 to BP-19:** victim, witness, suspect and interview material.
- **BP-20 and BP-21:** surveillance outputs and intelligence provenance.
- **BP-22:** scene recovery, location context and provisional material references.
- **BP-24:** forensic examination, findings and specialist reports.
- **BP-25 to BP-29:** lawful seizure, custody, legal process, courts and corrections.
- **BP-30 to BP-34:** governance, standards, training, HR and procurement.
- **BP-35 to BP-37:** simulation, social context and time.
- **BP-38 to BP-44:** records, persistence, interface, reporting, security, testing and configuration.

### Exceptions and edge cases
The system must handle unknown ownership, unidentified material, multiple components, duplicate submissions, incorrect provisional mapping, delayed registration, emergency acquisition, disputed authority, third-party restrictions, incomplete source records, damaged packaging, seal discrepancy, custody gap, unacknowledged transfer, temporary storage, environmental failure, contamination concern, destructive examination, split samples, digital acquisition gaps, corrupted files, changing metadata, external laboratory transfer, disclosure dispute, court retention order, appeal, legal hold, property claim, return refusal, disposal error and recovery after database or storage failure.

### Acceptance conditions
- Every evidence item has a unique persistent identity and complete source context.
- Acquisition basis, authority, provenance, condition and receiving record are explicit.
- Every custody transfer and material access is attributable and timestamped.
- Chain-of-custody history is append-only for ordinary users and corrections remain visible.
- Packaging, seals, storage, movement and examination events are recorded.
- Original material is distinguishable from copies, derivatives and presentation exhibits.
- Sampling, consumption, alteration and sub-item creation are documented.
- Digital evidence records source, acquisition scope, integrity checks and transformations.
- Discrepancies trigger preservation, escalation and review without rewriting history.
- Exculpatory, contradictory and unused material can be retained and disclosed.
- Disclosure decisions, versions and recipients are auditable.
- Retention holds prevent unauthorised disposal and releases are authorised.
- Property return and final disposal are recorded and verifiable.
- Evidence status does not automatically establish truth, admissibility or guilt.
- The player cannot bypass lawful authority or erase evidential history.

**Draft status:** BP-23 is a working design. Exact seizure powers, evidential rules, retention periods, disclosure thresholds, storage standards, forensic handling requirements and court procedures remain subject to the fictional legal framework and professional standards. This document does not claim that evidence-management software or operational capability has been implemented.

## BP-24 — Forensics

### Purpose and scope
Define the forensic-science service that supports investigations through the scientifically disciplined examination, interpretation and reporting of material. The division covers forensic capability, requests, triage, allocation, examination governance, findings, expert reporting, quality assurance and the interface between scientific work and police decision-making.

Forensics is a specialist service, not an investigative shortcut. It does not determine guilt, replace lawful investigation or decide legal admissibility. Its work must be impartial, reproducible to the extent appropriate to the method, transparent about uncertainty and capable of independent scrutiny.

### Forensic service architecture
The service may include internal laboratories, scene-based specialists, digital-forensic capability and accredited external providers. The final organisational structure, disciplines, locations and staffing model remain to be designed against workload and competence requirements.

Each service capability has a persistent record describing:
- Discipline and examination types within its authorised scope.
- Responsible unit, service lead and accountable manager.
- Available facilities, validated equipment and approved methods.
- Staff identities, qualifications, training, competence and authorisation.
- Capacity, operating hours, workload and service constraints.
- Quality-management arrangements, proficiency testing and audit history.
- External accreditation or certification status, scope and validity where applicable.
- Referral routes, limitations and dependencies on other specialist services.

A laboratory or examiner may only undertake work within their current competence, authorisation, facility capability and approved method scope. A title or general forensic qualification does not imply competence in every discipline.

### Forensic disciplines
The design must support distinct disciplines without assuming that every discipline is available in-house. The catalogue may include:
- Biology and DNA-related examinations.
- Fingerprint and other friction-ridge examinations.
- Trace materials, fibres, glass, paint and particulate comparisons.
- Firearms, toolmarks and related comparison disciplines.
- Toxicology, drugs and chemical analysis.
- Pathology and medical forensic interfaces.
- Questioned documents, handwriting and printing examinations.
- Digital devices, data and multimedia examination.
- Audio, video and image analysis.
- Collision, engineering and other specialist reconstruction.
- Anthropology, odontology and other identification support where justified.

Each discipline has its own method-specific requirements, limits, competence criteria, validation status, reporting conventions and quality controls. The list is a capability framework, not a claim that all services are staffed or operational.

### Request, triage and allocation
A forensic request is a formal, traceable record linked to a case, investigation and one or more evidence identifiers from BP-23. It records:
- Request identity, requesting officer and responsible investigator.
- Case and incident references and the question to be addressed.
- Relevant material identifiers, packaging and custody status.
- Legal authority, consent or other applicable basis and any scope restriction.
- Known case context necessary for the examination, with controls against unnecessary contextual bias.
- Requested discipline, urgency, deadlines and reason for priority.
- Potentially relevant alternative propositions or comparison material.
- Risks, safeguarding, contamination concerns and handling constraints.
- Triage decision, allocation, reviewer and decision rationale.

Triage considers evidential value, urgency, risk of degradation, safeguarding, legal deadlines, investigative importance, laboratory capacity and fairness to all parties. Priority must not be determined solely by seniority, publicity or whether a result is expected to support a preferred theory.

Requests may be clarified, declined, redirected, deferred or partially accepted. Every decision and any change in scope is recorded. The requester must be told about material limitations, unmet requests and expected delays. A request must not silently expand beyond its authorised question or the legal scope governing the material.

### Independence, competence and conflicts
Examiners are responsible for objective scientific work. They must report findings that support, contradict or do not resolve a proposition. They must not be instructed to obtain a desired result, suppress an inconvenient finding or overstate the strength of an association.

The system records examiner identity, competence for the method, authorisation, relevant training, supervision and any conflict or independence concern. Where a conflict exists, reassignment or independent review is considered and documented.

Investigative context is disclosed to an examiner only to the extent necessary for the scientific question and safe handling. The design supports sequential disclosure or other bias-reduction controls where appropriate to the discipline. It records what information was available to the examiner and when, so later reviewers can understand the context in which an interpretation was made.

### Examination workflow
A forensic examination has a controlled lifecycle:
1. Request received and checked for completeness, authority and scope.
2. Material identity and custody reconciled with BP-23.
3. Triage and acceptance decision recorded.
4. Examiner and any reviewer assigned according to competence and independence.
5. Examination plan, method and relevant propositions documented.
6. Material received, condition and seals checked, and discrepancies escalated.
7. Examination activity, observations, measurements and method deviations recorded.
8. Results reviewed, interpreted and assessed against limitations.
9. Technical or peer review completed where required.
10. Report authorised, issued and linked to the case and evidence record.
11. Material returned, transferred, retained or otherwise disposed of under BP-23 authority.
12. Any later correction, supplementary examination or challenge linked to the original record.

The record captures dates, participants, equipment and method versions, environmental or operating conditions where relevant, controls, reference materials, observations, calculations, software versions where applicable, deviations, failed or inconclusive stages and reasons for stopping. The level of detail is appropriate to the discipline and sufficient for competent review.

### Material handling and scientific continuity
BP-23 remains the authoritative evidence-custody system. BP-24 does not create a competing chain of custody. Forensic receipt, internal movement, access, sampling, consumption, alteration, sub-item creation, return and external transfer are recorded through linked custody events.

Before examination, the examiner verifies material identity, packaging, seals, condition and accompanying documentation. Any discrepancy is preserved and referred for assessment; the examiner does not repair or conceal a custody gap. Sampling and destructive or partially destructive work require recorded justification, authority, scope, quantity or portion affected, method, remaining material and any limitation on future testing.

Where a sample is divided, extracted, consumed or transformed, each derivative receives a traceable identity linked to its source. A derivative is not represented as the original item. Remaining material and retained extracts are accounted for.

### Findings, interpretation and propositions
The forensic record distinguishes three levels:
- **Observation or measurement:** what was directly seen, measured, detected or recorded under the method.
- **Interpretation:** the scientific meaning of those observations, including the propositions considered, assumptions, limitations and degree of support where the discipline permits.
- **Legal or investigative conclusion:** decisions about what happened, who is responsible, guilt, admissibility or case outcome. These are not decisions for the forensic examiner merely by virtue of their scientific role.

Where appropriate, reports consider competing propositions rather than presenting a conclusion in isolation. The examiner identifies the source of propositions, relevant assumptions, the level at which an interpretation is made and whether the available data can discriminate between alternatives.

The system must not generate automatic identity matches, source conclusions or numerical strength statements without a valid method, suitable data and authorised competent interpretation. It must not convert a database candidate, investigative lead or algorithmic similarity into a confirmed identification. Any search or candidate-generation system is recorded as such, with its limitations and the independent verification required.

### Uncertainty, limitations and inconclusive outcomes
Reports must state relevant uncertainty and limitations in language appropriate to the discipline. These may include sample quality or quantity, degradation, contamination risk, environmental effects, incomplete reference material, method sensitivity or specificity, measurement uncertainty, population or database limitations, assumptions, competing explanations, validation boundaries and the effect of missing information.

An inconclusive result is a valid outcome and must not be treated as proof for either side. Absence of a detected feature is not automatically proof that the feature was never present. A failure to obtain a result is recorded with the method, stage, known reason if any and any implications for further work.

The system must prevent unsupported certainty, misleading categorical language and the conflation of a source-level proposition with an activity-level or offence-level proposition. Where the discipline cannot support a reliable conclusion, that limitation is stated plainly.

### Reports and expert evidence
A report is a versioned, attributable scientific document. It identifies:
- Case, request, evidence and report identifiers.
- Examiner and relevant reviewer identities and competence.
- Instructions, scope and questions addressed.
- Material examined and its condition on receipt.
- Methods, validated status and material deviations.
- Relevant observations, results and interpretation.
- Propositions considered and assumptions relied upon.
- Uncertainty, limitations and inconclusive aspects.
- Conclusions expressed only to the level supported by the method and data.
- References, appendices, images, charts, calculations or supporting records.
- Authorisation, issue date, recipients and version history.

Reports distinguish factual observations from expert opinion. They identify work performed by others and any reliance on external reports or data. The examiner's duty is to assist the decision-maker impartially, including by identifying findings adverse to the prosecution theory and explaining limitations that may assist another party.

The service supports expert conferences, clarification questions, supplementary reports, court attendance, challenges to methods or conclusions and disclosure of relevant underlying material. Court processes and admissibility decisions remain within BP-27 and BP-28.

### Review, quality and accreditation
Quality controls may include method validation and verification, equipment calibration and maintenance, reagent and control checks, environmental monitoring, staff competency assessment, proficiency testing, technical review, peer review, audit, corrective and preventive action, non-conformance reporting and external assessment.

The record distinguishes:
- A method being scientifically published from being validated for the laboratory's intended use.
- A laboratory holding accreditation from a particular method or activity being within its accredited scope.
- An examiner being employed by a laboratory from being currently competent and authorised for a particular task.
- A technical review from an independent scientific review or a legal assessment.

Quality incidents, contamination events, equipment failures, proficiency-test concerns, data-integrity problems and systemic errors are recorded, assessed for affected cases and escalated. The service supports retrospective notification and review where a quality issue may affect previously issued results. Corrective action does not erase the original result or its history.

### Disclosure, retention and challenges
Forensic records are linked to BP-23 evidence and BP-27 disclosure processes. The record preserves relevant notes, bench records, raw data, images, calculations, instrument outputs, method versions, validation references, quality records, communications, draft and final reports where required, review comments, deviations and supplementary work.

Relevant material is not withheld merely because it is preliminary, inconclusive, adverse, sensitive or embarrassing. Disclosure decisions are made under the applicable fictional legal framework and are attributable, reviewable and versioned. Sensitive information is handled through lawful restrictions and appropriate review, not silent deletion.

A challenge, complaint, request for independent examination, second opinion or re-analysis is separately recorded and linked to the original work. The original result remains available. Differences between examiners are documented and assessed rather than resolved by overwriting one opinion with another.

Retention of samples, extracts, digital working copies, raw data and records follows BP-23 retention rules and any applicable legal hold. Disposal or return requires documented authority and confirmation that no outstanding testing, disclosure, appeal or other lawful obligation remains.

### Player experience and authority
The player may identify a forensic question, submit a properly authorised request, review its status, provide relevant context, receive reports, ask clarification questions, arrange lawful further examination and disclose material through the proper process.

The player cannot select an examiner to secure a preferred conclusion, dictate scientific findings, bypass triage, alter raw results, suppress an adverse report, claim a candidate match is confirmed, or treat a forensic result as proof of guilt. Requests, approvals, access, decisions and communications are auditable. The interface makes clear which actions require a qualified examiner, laboratory manager, independent reviewer, evidence custodian, supervisor or legal authority.

No forensic workflow automatically reveals a hidden offender, resolves the case or supplies the player with investigative solution hints. The player must interpret the available material and make their own investigative decisions.

### Connections to other divisions
- **BP-05 to BP-09:** service structure, personnel, qualifications, units and specialist resources.
- **BP-13 to BP-16:** offence context, crime events, case questions and investigative direction.
- **BP-17 to BP-19:** victim, witness and suspect material, statements and interview-related comparisons.
- **BP-20 and BP-21:** surveillance material and intelligence leads, with provenance and evidential conversion kept explicit.
- **BP-22:** scene examination, recovery context and specialist attendance.
- **BP-23:** authoritative evidence identity, custody, sampling, transfers, retention and disclosure links.
- **BP-25 to BP-29:** arrest decisions, legal process, court presentation, outcomes and corrections interfaces.
- **BP-30 to BP-34:** governance, professional standards, training, staffing, procurement and quality resources.
- **BP-35 to BP-37:** simulation processing, social context and consistent timelines.
- **BP-38 to BP-44:** authoritative records, persistence, interface, reporting, security, testing and controlled expansion.

### Exceptions and edge cases
The design must handle insufficient material, mixed or degraded samples, contamination concern, uncertain provenance, seal discrepancy, custody gap, wrong or incomplete request, disputed authority, scope overreach, duplicate requests, conflicting priorities, unavailable discipline, external-provider delay, examiner conflict, expired competence, unvalidated method, equipment failure, failed controls, inconclusive result, competing interpretations, unexpected or exculpatory finding, candidate-generation false positive, database limitation, destructive testing, insufficient remaining sample, derivative identity error, data corruption, software or method-version change, retrospective quality alert, report correction, reviewer disagreement, disclosure challenge, independent re-examination, court challenge, retention hold, appeal, and laboratory or records-system outage.

### Acceptance conditions
- Every forensic request is uniquely identified, scoped, authorised and linked to the relevant case and evidence.
- Every discipline, method, facility and examiner has a defined and current competence/authorisation scope.
- Triage, allocation, priority changes, refusals and delays are reasoned and auditable.
- Examiner independence and conflicts are addressed and recorded.
- The material's authoritative identity and custody remain governed by BP-23.
- Examination activity, methods, observations, deviations and derivatives are traceable.
- Observations, scientific interpretations and legal conclusions are clearly separated.
- Competing propositions, uncertainty, limitations and inconclusive results can be reported.
- No unsupported automatic match, categorical identification or certainty claim is generated.
- Reports are attributable, versioned, reviewed where required and linked to their supporting records.
- Quality incidents trigger impact assessment and preservation of the original record.
- Exculpatory, contradictory and unused forensic material remains available for proper review and disclosure.
- Independent review, challenge, supplementary work and court scrutiny are supported.
- Retention, transfer, return and disposal follow BP-23 authority and legal holds.
- The player cannot manipulate scientific conclusions or receive automatic hidden-solution disclosure.

**Draft status:** BP-24 is a working design. The fictional legal framework, forensic service structure, discipline availability, method catalogue, accreditation scope, staffing, service standards, reporting conventions and retention requirements remain to be specified. This division does not claim that forensic laboratories, forensic software or operational forensic capability have been implemented.

## BP-25 — Arrests and Warrants

### Purpose and scope
Define the lawful, accountable arrest and warrant system used by the National Police Service. This division governs arrest authority, grounds, necessity, warrant applications and execution, arrest decisions, use of alternatives, person and location identity checks, operational recording, rights notification, post-arrest handover and review.

Arrest is a significant interference with liberty. It is not a finding of guilt, a punishment, or a substitute for investigation. The system must distinguish suspicion, arrest, charge, remand, conviction and sentence as separate legal states. The exact fictional offences, statutory powers, thresholds, time limits, rights and authorising roles are established by the country's legal framework and remain open until designed.

### Core legal principles
Every arrest-related action must be grounded in an identifiable legal power and the facts known to the decision-maker at the time. The record must distinguish:
- The legal power relied upon.
- The factual grounds and source of each material fact.
- The officer's reasonable belief or other applicable statutory test.
- The purpose and necessity of arrest.
- Any required proportionality, urgency or public-interest assessment.
- Available alternatives considered and reasons they were unsuitable.
- Any conditions, limits or safeguards attached to the power.
- The person who made the decision and the person who carried it out.

The simulation must not assume that an arrest is lawful merely because a person is suspected, identified by a witness, linked to intelligence, present at a scene, or subject to an investigative lead. A warrant does not authorise actions outside its terms. A procedural error or disputed authority is preserved for review and must not be silently cured.

### Arrest grounds and decision record
An arrest decision is a versioned, attributable record linked to the person, incident, case and relevant offence or offences. It captures:
- Identity of the person, including uncertainty or disputed identity.
- Date, time and location of the decision and any later execution.
- Decision-maker, arresting officer and their current role and authority.
- Alleged offence or legal basis, including applicable version of the law.
- Facts supporting the grounds, with source and time known.
- Relevant contradictory, exculpatory or uncertainty information known.
- Required statutory test and how the known facts satisfy or fail it.
- Necessity and proportionality assessment where required.
- Alternatives considered, including voluntary attendance or other lawful options.
- Risk, vulnerability, health, safeguarding, communication or accessibility needs.
- Any warrant, authorisation, restriction or condition relied upon.
- Decision, reasons, review and subsequent change of circumstances.

The record distinguishes facts directly observed by the officer, information supplied by others, intelligence, evidence, inference and unverified allegation. The decision-maker must not present an inference as an observed fact or omit known information that materially undermines the grounds.

A decision not to arrest is also recordable where relevant. It may include reasons, alternative action, supervisory consultation, outstanding risks and the conditions that would prompt reassessment. This supports accountable judgment rather than rewarding arrest volume.

### Warrant architecture
A warrant is a formal legal instrument issued by the competent fictional judicial or other legally authorised body. It is not an internal police permission and cannot be created by an officer simply entering an approval in the system.

The warrant record includes:
- Unique warrant identity and issuing authority.
- Applicant, responsible officer and authorising judicial or statutory officer.
- Person, premises, property or other subject precisely identified.
- Legal power, alleged offence or purpose, and supporting grounds.
- Scope, permitted actions and any explicit exclusions.
- Date and time issued, effective date, expiry and territorial validity.
- Execution conditions, reporting requirements and safeguards.
- Service or notification requirements, where applicable.
- Status: prepared, submitted, granted, refused, varied, suspended, expired, executed, partly executed, withdrawn, quashed or otherwise discharged.
- Linked applications, decisions, reasons, returns and court directions.

Applications retain the original submission, supporting material, amendments, judicial questions, decision and reasons. A refused or withdrawn application remains part of the audit history. A materially changed application is not silently substituted for the original.

### Warrant categories and interfaces
The fictional legal catalogue may support distinct instruments for:
- Arrest of a named person.
- Entry to a specified premises to locate and arrest a person, if law permits.
- Search or seizure powers governed by their own legal process.
- Production or attendance before a court or other competent body.
- Other narrowly defined instruments created by statute.

These instruments are not interchangeable. BP-25 covers arrest-related warrants and their interface with other instruments. Search and seizure scope must be defined by the relevant legal framework and BP-23; an arrest warrant alone must not be treated as a general search authority.

Each warrant type defines eligibility, issuing authority, application content, threshold, permitted scope, duration, execution rules, reporting, challenge and remedy. No category becomes available merely because it is convenient for gameplay.

### Warrant review and validity
Before execution, an authorised officer verifies the instrument's identity, authenticity, current status, subject, scope, territorial and temporal validity, and any conditions. The record captures the source used for verification and the time of the check.

A warrant may be varied, renewed, suspended, withdrawn, expired or quashed only through the route permitted by law. Changes are versioned, and the officer must be able to determine which version was valid at the relevant time. The system prevents execution against an expired, withdrawn, suspended or otherwise invalid instrument unless a separate lawful power applies.

Where identity is uncertain or multiple people share similar identifiers, the system records the verification steps and uncertainty. A warrant for one person must not automatically attach to a relative, associate, occupant or person with a similar name.

### Execution and operational record
Execution records identify the warrant or other legal power, the executing personnel, supervisor or commander where applicable, date/time/location, subject and outcome. The record captures:
- Pre-execution validity and scope checks.
- Relevant briefing and allocation of responsibilities.
- Any required notification, identification or explanation.
- Whether the named person was located and how identity was confirmed.
- Arrest, attempted arrest, non-execution or partial execution outcome.
- Any delay, obstruction, unexpected condition or change in circumstances.
- Any action taken beyond the initial plan and its separate legal basis.
- Persons present and relevant safeguarding or welfare concerns.
- Property, material or records affected and their separate authority.
- Any injury, complaint, force report or other incident requiring referral.
- Completion, return, supervisory review and any court reporting.

The simulation records the fact and governance of operational decisions without providing real-world tactical instruction for forced entry, restraint, evasion or overcoming security. Operational methods remain governed by fictional law, training and professional standards.

### Arrest event and status lifecycle
An arrest event has its own stable identity and is linked to the person and relevant case. It records the decision, execution, location, officers, grounds, time, legal power, rights process, transport and handover to custody.

Person and case statuses must remain distinct. A person may be recorded as wanted, subject to an active warrant, arrested, released, charged, bailed, remanded, acquitted, convicted or otherwise subject to a legal outcome. These are not a single linear field: multiple matters may coexist, and a person may have different statuses in different cases.

An arrest does not automatically:
- Create a charge or establish that an offence occurred.
- Confirm identity where identity remains disputed.
- Prove the factual grounds or the truth of an allegation.
- Authorise a search beyond a separate legal power.
- Establish guilt or determine a court outcome.
- Close the investigation or remove the need to preserve alternative lines of enquiry.

Arrest events can be corrected, challenged or reviewed, but their original records and audit history remain preserved.

### Rights, communication and safeguarding
The arrested person must receive the rights, explanations and procedural safeguards required by the fictional legal framework, in a form they can understand. The exact rights, timing, prescribed wording and exceptions are reserved for the legal framework and BP-26 custody rules.

The arrest record supports:
- Explanation of the fact and legal basis of arrest.
- Communication of applicable rights and safeguards.
- Access to legal advice or representation as required.
- Notification of a nominated person or other permitted contact.
- Interpreter, translation or communication assistance.
- Disability, age, vulnerability, health and safeguarding needs.
- Appropriate handling of children and other protected persons.
- Recording of requests, responses, delays, refusals and reasons.
- Complaints, allegations of mistreatment and requests for medical attention.

A rights notification is not treated as complete merely because a checkbox is selected. The system records who provided the explanation, when, in what form, the person's understanding or any communication barrier, and any follow-up required. The detailed detention, welfare, interview and review procedures are handled through BP-26 and BP-19.

### Force, injury and exceptional circumstances
Any use of force or injury associated with an arrest is recorded as a separate reportable event under the applicable fictional law and professional standards. The record includes personnel, time, circumstances, stated grounds, level and duration as defined by the rules, injuries or medical attention, witnesses, available recordings, notifications and review status.

The system does not reward force, presume that force was necessary, or treat an officer's report as conclusive. Allegations, injuries, disputed accounts and potential misconduct are preserved for independent review under BP-30 and BP-31. Medical needs take priority and are referred through the appropriate service interface.

Exceptional powers, urgent action without a warrant, cross-jurisdiction execution, or action in rapidly changing circumstances must have an explicit legal basis, narrow conditions, time limits and post-event scrutiny. Emergency circumstances do not create an unlimited power.

### Alternatives, release and failed execution
The system supports lawful alternatives where appropriate, including voluntary attendance, summons or other process, appointment for interview, referral, safeguarding action or continued investigation without arrest. Availability depends on the fictional law and case circumstances.

It records when an arrest is not made, when a warrant cannot be executed, when a person is not located, when identity cannot be confirmed, when a warrant is found invalid, and when a person is released without charge or under another lawful arrangement. Reasons, conditions, responsible decision-maker, notifications and follow-up are captured.

A failed attempt does not automatically justify a new or broader warrant. A fresh application or separate legal power must satisfy its own requirements. A release decision does not erase the arrest event or automatically resolve the investigation.

### Supervisory and judicial oversight
Supervisors review decisions and execution records according to risk, law and service policy. Review checks include legal basis, grounds, necessity, proportionality, identity, warrant validity, scope, rights, safeguarding, force or injury, recording completeness and any departure from conditions.

Judicial oversight includes warrant applications, execution returns, challenges, variations, complaints or other processes required by law. The system records the decision-maker, material considered, outcome, reasons, directions, deadlines and responsible person.

Reviewers must be able to identify the law and facts applicable at the time, not merely the current status. A later legal change, new evidence or changed circumstances is recorded as a later event and does not rewrite the original decision.

### Records, disclosure and privacy
Arrest and warrant records are linked to:
- BP-12 incident records and BP-15 case files.
- BP-16 investigative grounds and enquiries.
- BP-18 person and suspect status history.
- BP-19 interviews and rights-related records.
- BP-20 surveillance and other authorised operational material.
- BP-22 scene records and BP-23 evidence custody.
- BP-24 forensic material and reports.
- BP-26 custody, BP-27 legal process and BP-28 court outcomes.
- BP-30 governance, BP-31 professional standards and BP-38 authoritative records.

Access to warrant applications, sensitive grounds, protected identities and operational information is limited by role and legal need. Access, amendment, export and disclosure are audited. The system supports disclosure of relevant material, including information that challenges the grounds or legality of an arrest. Privacy controls must not be used to conceal material that is lawfully disclosable.

### Player experience and authority
The player may assess whether the facts and applicable legal power support an arrest, record reasons, seek required supervision or legal authorisation, submit a warrant application through the proper channel, verify an instrument, execute an authorised decision, document the event and hand the person to custody.

Available actions depend on the player's rank, appointment, training, authority, location, duty status and the fictional legal framework. A senior rank does not automatically supply judicial authority or a specialist power. The interface must state when the player lacks authority, when an application is pending, when an instrument is invalid or when a separate approval is required.

The player cannot manufacture grounds, backdate an application, change the scope of an issued warrant, conceal exculpatory facts, silently amend an execution record, treat arrest as guilt or bypass custody and rights safeguards. No arrest workflow reveals hidden offender identity or supplies automatic investigative solution hints.

### Exceptions and edge cases
The design must handle mistaken identity, aliases, incomplete identity data, similar names, multiple warrants, conflicting instruments, expired or suspended warrants, invalid service, unclear territorial authority, cross-jurisdiction requests, changed circumstances, new exculpatory information, disputed grounds, insufficient necessity, vulnerable persons, children, language barriers, urgent medical need, rights-notification failure, delay in legal advice, force allegation, injury, death or serious incident, missing recording, incomplete execution return, partial execution, person not located, refusal or obstruction, incorrect premises or subject details, warrant variation, judicial challenge, unlawful arrest finding, release, re-arrest under a genuinely separate lawful basis, database outage and retrospective record correction.

### Acceptance conditions
- Every arrest decision identifies a valid legal power and the facts known at the time.
- Grounds, necessity, proportionality and alternatives are recorded where required.
- Decisions to arrest and decisions not to arrest can be reviewed.
- Arrest warrants are issued only by the competent authority and retain their full application and decision history.
- Warrant identity, subject, scope, conditions, validity and status are checked before execution.
- Distinct legal instruments cannot be substituted for one another.
- Execution, non-execution, partial execution and return are attributable and auditable.
- Identity uncertainty and contradictory information are visible and preserved.
- Arrest, charge, custody, bail/remand, conviction and sentence remain distinct legal states.
- Rights, legal advice, communication, safeguarding and medical needs are recorded under the applicable rules.
- Force, injury, complaints and exceptional powers receive separate review.
- Lawful alternatives and release outcomes are supported and recorded.
- Supervisory and judicial oversight can reconstruct the facts and law applicable at the time.
- Relevant and exculpatory records remain available for disclosure and challenge.
- The player cannot exceed their authority, alter warrant scope or erase arrest history.
- Arrest does not automatically reveal guilt or resolve a case.

**Draft status:** BP-25 is a working design. Exact offences, arrest thresholds, necessity tests, warrant categories, issuing authorities, territorial rules, rights wording, time limits, exceptional powers, force standards, custody handover and judicial review procedures remain to be specified in the fictional legal framework. This division does not claim that arrest or warrant software has been implemented.

## BP-26 — Custody Management

### Purpose and scope
Define the safe, lawful, humane and accountable management of every person detained by the National Police Service. Custody begins when a person is accepted into police detention and continues through assessment, detention reviews, welfare, authorised procedures, release or transfer to another lawful authority.

Custody is a deprivation of liberty and must be independently accountable. It is not punishment and does not establish guilt. The custody system must distinguish the arrest decision, physical handover, acceptance into detention, each period of detention authority, review decisions, charge or other legal process, and final release or transfer.

The exact fictional detention powers, maximum periods, review intervals, rights, authorising roles, permitted exceptions and court procedures remain to be defined by the country's legal framework. No time limit or power is to be invented by gameplay logic.

### Custody facility architecture
The service may operate central custody suites, station-based detention facilities and specialist facilities where justified. Each facility has a persistent record containing:
- Facility identity, location, operating status and responsible command.
- Approved detention capacity and authorised categories of detainee.
- Custody rooms, interview rooms, consultation areas, healthcare access and welfare facilities.
- Staff establishment, duty roster, supervisors and required competencies.
- Security, fire safety, environmental and accessibility systems.
- Medical, interpretation, legal-advice and safeguarding referral arrangements.
- Approved equipment, inspection and maintenance records.
- Policies, local procedures, emergency arrangements and inspection history.

Each custody space or cell has an individual identity, operational status, suitability restrictions, occupancy history and inspection record. Capacity is not exceeded by default. An exceptional placement requires a lawful and documented decision, risk assessment and appropriate oversight; the system must not quietly allocate a person to an unsuitable space.

Facility availability accounts for staffing, maintenance, safety defects, specialist restrictions, occupancy and temporary closure. A nominally empty cell is not necessarily available for every detainee.

### Custody record and identity
Every accepted detainee receives a unique custody record linked to the arrest event, person identity, incident, case and relevant legal authority. The custody record captures:
- Custody reference and facility.
- Detainee's identity and any uncertainty, aliases or disputed details.
- Arresting and escorting personnel.
- Arrest grounds, legal power and warrant or authority relied upon.
- Arrest location, time, circumstances and recorded rights notifications.
- Arrival time, handover details and custody acceptance time.
- Custody officer and supervising officer.
- Property, medication information and immediate welfare needs.
- Risk assessment, vulnerability, safeguarding and healthcare referrals.
- Detention authority, legal clock and review deadlines.
- All significant events, decisions, contacts, reviews and status changes.
- Release, transfer or other final disposition and receiving acknowledgement.

The system preserves the distinction between arrest time, arrival time, acceptance time and any legally relevant detention commencement time. The applicable rule is defined by law and recorded explicitly; software must not silently choose whichever timestamp is most convenient.

If identity is unknown or disputed, the custody record may use a temporary custody identity linked to the person's existing or subsequently confirmed identity. Merging records requires verification and an auditable correction process; the original custody and identity history remains visible.

### Arrival, handover and acceptance
On arrival, custody staff conduct a formal handover and decide whether the facility can safely and lawfully accept the detainee. The handover includes:
- Arresting officer's identity and account of the arrest.
- Legal basis, grounds and any warrant or authorisation.
- Relevant known facts, risks, injuries and safeguarding concerns.
- Property and items accompanying the detainee.
- Rights already explained, requests made and assistance required.
- Medication, health information voluntarily or lawfully provided, and urgent concerns.
- Any force, restraint, complaint, incident or unusual circumstance.
- Outstanding actions, deadlines and relevant evidence or recording references.

The custody officer records acceptance, conditional acceptance where lawful, refusal and reason, or referral to a more suitable facility. Refusal does not erase the arrest or permit informal detention outside lawful authority. Responsibility during transport, handover and any delay is attributable and traceable.

Urgent medical needs take priority. The system records the time, decision, referral, receiving service and any continuing custody arrangements permitted by law. Police custody staff do not substitute for qualified clinical assessment.

### Custody authority and legal time control
Each detention period is linked to a specific legal authority. The record identifies the statutory or judicial basis, authorising person or body, start event, maximum permitted period, review requirements, conditions, expiry and any lawful extension or renewal.

A legal-clock service calculates deadlines from the correct legally defined event and applicable rule. It must:
- Use the law version in force at the relevant time.
- Preserve the source timestamps and any correction history.
- Distinguish elapsed time, suspended time and legally excluded periods only where the law expressly permits them.
- Generate advance warnings and overdue escalations.
- Prevent a routine administrative action from extending detention.
- Require the correct authority and recorded reasons for any extension.
- Record system outage or clock discrepancy and provide a controlled recovery procedure.

A deadline warning does not itself grant detention authority. A pending application does not automatically extend an expiring authority. If lawful detention authority expires, the system must require release or another independently valid legal basis; it must not keep a person detained merely because an investigation remains incomplete.

The exact maximum periods, review intervals, extension criteria, judicial involvement and exceptional powers are open legal-framework decisions.

### Custody assessment and continuing risk review
A competent custody officer conducts an initial assessment and repeats it when circumstances change or policy requires. Assessment covers:
- Physical health, injury, illness, intoxication or withdrawal concerns.
- Mental health distress, self-harm risk or risk to others.
- Age, disability, pregnancy or other relevant vulnerability.
- Communication, language, literacy and interpretation needs.
- Safeguarding, exploitation, trafficking or coercion concerns.
- Medication and urgent treatment requirements.
- Risk of violence, intimidation, victimisation or conflict with others.
- Risk arising from the detainee's circumstances, not merely the alleged offence.
- Appropriate observation, support, separation or specialist referral.

The record identifies the assessor, time, information relied upon, limitations, risk controls, review date and escalation. Risk classifications support care and allocation; they are not a diagnosis or a substitute for professional judgment. A person may be both vulnerable and a potential risk to others, and both dimensions must be considered fairly.

Risk assessments are dynamic. A change in behaviour, disclosure, medical condition, medication, incident, new information or change of environment triggers reassessment. The system must not retain an outdated risk rating as if it were current.

### Healthcare and welfare
Custody must support access to qualified healthcare, emergency treatment, medication review and appropriate specialist care. The record includes requests for medical assistance, symptoms or observations relevant to safety, referral decisions, attendance, clinical advice as appropriately shared, treatment arrangements and follow-up.

Clinical records remain governed by appropriate health confidentiality and role-based access. Police users receive only information needed for lawful custody and safety decisions. The system does not expose unnecessary clinical detail to investigators or use medical information as an investigative shortcut.

Welfare provisions include access to food, water, rest, sanitation, hygiene, suitable clothing, religious or other reasonable accommodation where required by law, and contact with appropriate support. The system records provision, refusal, inability to provide, reason, follow-up and any effect on wellbeing. A refusal must not automatically be interpreted as evidence of guilt, non-cooperation or absence of need.

### Rights, legal advice and communication
The custody process supports all rights and safeguards required by the fictional legal framework, including:
- Clear explanation of detention, reasons and applicable rights.
- Access to legal advice or representation.
- Notification of a permitted person or other authorised contact.
- Interpreter and communication support.
- Special safeguards for children and protected or vulnerable persons.
- Access to relevant information necessary to exercise rights.
- Complaint and request procedures.
- Recording of any lawful delay, restriction or exception and its authority.

Each rights event records what was explained or requested, who handled it, date/time, language and format, interpreter or assistance details, outcome, any refusal and reason, and next review. A tick-box alone is insufficient evidence that the person understood or was afforded the safeguard.

Investigative access to a detainee is kept separate from custody welfare decisions. Investigators cannot use custody controls to obstruct legal advice, punish a detainee or obtain access outside the law. Detailed interview conduct remains under BP-19.

### Property and personal belongings
Detainee property is recorded by item, description, condition, source, handling officer, secure storage location, receipt and return or other authorised disposition. Property held for safekeeping is distinguished from evidential material seized under a separate legal power.

The detainee receives an inventory or acknowledgement where required. Disputes, missing property, damage, prohibited items, medication, assistive devices and essential personal effects are recorded and reviewed. Access to property during detention is controlled by lawful safety requirements and individual needs, not arbitrary convenience.

Evidential items are registered and transferred under BP-23. The custody property register must not become an alternative evidence database or obscure the legal basis for seizure.

### Searches and safety procedures
Any search or safety-related procedure in custody must have a defined legal and policy basis, appropriate authorisation, necessity, proportionality, dignity and safeguards. The record identifies the type and scope of procedure, decision-maker, personnel, reason, time, outcome, any item found, any refusal or objection, and any complaint or injury.

More intrusive procedures require the stricter legal thresholds, qualified personnel, supervision and safeguards specified by the fictional law. The simulation will not provide real-world tactical instructions for conducting searches or defeating security. It models lawful authority, accountability, dignity, safety and records.

### Separation, accommodation and detainee interaction
Allocation considers age, vulnerability, safeguarding, conflict, intimidation, health, legal requirements and facility suitability. The system records the rationale for separation or shared accommodation and reviews it when circumstances change.

The system prevents incompatible allocations and records occupancy intervals. It supports accessible spaces and specialist arrangements where available. A shortage of space does not silently justify unsafe or unlawful accommodation. Any exceptional placement requires explicit authority, compensating safeguards and review.

### Interviews and investigative activity in custody
Interview requests are scheduled and recorded separately from custody decisions. The system checks legal authority, interview eligibility, rights status, legal-advice requirements, vulnerability safeguards, interpreter availability, interviewer competence and any applicable time restrictions.

Custody staff record arrival and departure from interview areas, responsible personnel, breaks, return to accommodation and any welfare concern. The interview record, recording and exhibits remain governed by BP-19 and BP-23. Custody staff do not decide the substance of questioning or interfere with an interview to secure a preferred outcome.

No interview may be used to bypass a legal safeguard or extend detention beyond its authority. A detainee's silence, request for advice, distress or refusal to answer must not be treated as automatic evidence of guilt.

### Visits, contacts and external services
The system records permitted legal representatives, nominated contacts, interpreters, healthcare professionals, appropriate support persons, inspectors and other authorised visitors. It captures identity verification, purpose, authority, arrival/departure, relevant restrictions, decision-maker and any refusal with reasons.

Communication restrictions, monitoring or delay are permitted only where the fictional law expressly authorises them and required safeguards are met. Legal consultation confidentiality is protected according to law. Visits and contact arrangements must not be restricted merely to make an investigation easier.

External service referrals record the receiving organisation, referral purpose, time, information lawfully shared, consent or other basis, response, outstanding action and responsible owner.

### Incidents, complaints and safeguarding referrals
Custody incidents include injury, illness, medical emergency, self-harm concern, violence, threat, intimidation, property dispute, facility defect, fire or evacuation, escape or attempted escape, death, allegation of mistreatment, rights failure and any other serious welfare or security event.

Each incident has a separate identity, time, location, persons involved, factual account, immediate safety response, medical or external referral, notifications, evidence and recording references, responsible supervisor, preservation requirements and review outcome.

Complaints are recorded regardless of whether they are initially substantiated. The system preserves the complainant's account, requested action, referral, investigation status and outcome. Serious allegations or deaths in custody trigger the independent notification and investigation routes required by the fictional law. Custody staff must not investigate or close complaints in which they have a material conflict.

### Reviews and supervision
Custody reviews are performed by the role and at the intervals required by law. Each review records:
- Current legal authority and remaining lawful period.
- Whether continued detention remains lawful and necessary.
- Investigative progress and outstanding actions, without treating delay alone as a reason to detain.
- Detainee's health, welfare, risk and safeguarding status.
- Access to legal advice, communication and other rights.
- Any new information, complaint or change in circumstances.
- Decision, reasons, reviewer identity, time and next deadline.
- Any direction to release, transfer, seek further authority or take another lawful action.

Reviewers must be sufficiently independent from the immediate investigative decision where required. A supervisor cannot authorise a power reserved to a court or other competent body. Missed, late, incomplete or disputed reviews are escalated and remain visible in the record.

### Release, transfer and final disposition
A custody record ends only through a recorded lawful disposition. Supported outcomes include release without charge, release on lawful conditions, bail or other attendance arrangement, charge and continued lawful detention, remand or transfer under court authority, transfer to another competent agency, transfer for healthcare, or other disposition created by law.

The final record identifies:
- Legal basis and decision-maker.
- Date/time of decision and actual departure or transfer.
- Person's identity and destination or receiving authority.
- Conditions, dates, reporting obligations or restrictions where applicable.
- Property returned and outstanding property arrangements.
- Rights, documents and information provided.
- Healthcare, safeguarding and welfare handover where necessary.
- Receiving person's or agency's acknowledgement.
- Outstanding investigation, court or notification actions.

Release is not a finding that the allegation was false, and continued detention is not a finding of guilt. A person may be released while an investigation continues. If a person is transferred, responsibility changes only at the recorded and acknowledged handover point defined by law.

### Death or serious medical emergency in custody
The system treats death or a life-threatening medical emergency as a critical event requiring immediate emergency response, preservation of records and independent oversight. It records notification times, responders, clinical decisions as appropriately shared, scene preservation, access logs, relevant recordings, custody records, medication and welfare history, witnesses, family or representative notification where lawful, and the competent independent investigative authority.

Records must be protected from alteration, deletion or routine retention expiry. Staff involved in the incident must not control the independent investigation or unilaterally determine its findings. The exact statutory notification and investigation process remains part of the fictional legal framework.

### Records, access and audit
Custody records are authoritative, append-only in their material history and linked to BP-38 and BP-39. Corrections are made through attributed amendments that preserve original values, reasons, time and authorisation. The system records access to sensitive health, rights, risk, complaint and detention information.

Role-based permissions distinguish custody officers, custody supervisors, healthcare professionals, investigators, legal representatives, inspectors, administrators and independent oversight bodies. Access is limited to lawful need. Investigators do not automatically receive the full custody or clinical record.

The system supports audit of detention duration, review timeliness, rights provision, healthcare access, complaints, incidents, release, transfers, facility capacity and disparities requiring scrutiny. Performance measures must not incentivise longer detention, unnecessary searches, denied rights or rushed release decisions.

### Player experience and authority
The player may deliver a detainee to custody, complete an arrest handover, review custody status within their authority, submit a lawful interview request, provide relevant information, respond to authorised enquiries, receive permitted notifications and participate in release or transfer arrangements.

Only appropriately qualified and appointed custody personnel perform custody acceptance, detention reviews and custody decisions. Investigators cannot override a custody officer's independent welfare or legality responsibilities. The player cannot alter the legal clock, extend detention without authority, suppress a complaint, falsify a welfare check, access protected clinical records without need, or keep a person detained because the case is unfinished.

The interface displays the current legal authority, relevant deadlines, responsible custody officer, outstanding rights and welfare actions, review status and any critical warning. It must distinguish an alert from a legal authorisation.

### Connections to other divisions
- **BP-05 to BP-09:** police structure, personnel, career competence, deployment, resources and facility assets.
- **BP-11 and BP-12:** communications, incident response and custody-related incident records.
- **BP-13 to BP-18:** offences, crime events, cases, investigations, victims, witnesses and person status.
- **BP-19:** interview scheduling, safeguards, recordings and interview records.
- **BP-20 and BP-21:** lawful operational information and intelligence, with access controls.
- **BP-22 to BP-24:** scene, evidence, forensic material and specialist reports.
- **BP-25:** arrest grounds, warrants, execution and formal handover.
- **BP-27 and BP-28:** legal process, court authority, bail/remand and outcomes.
- **BP-29:** corrections and post-conviction custody interfaces.
- **BP-30 to BP-34:** governance, professional standards, training, staffing and facilities procurement.
- **BP-35 to BP-37:** simulation events, social context, clocks and schedules.
- **BP-38 to BP-44:** records, persistence, interface, notifications, security, testing and configuration.

### Exceptions and edge cases
The design must handle unknown or disputed identity, duplicate custody records, arrest time versus legal detention start, late arrival, refusal of acceptance, facility closure, unsuitable cell, overcrowding, staffing shortage, vulnerability discovered late, changing medical condition, intoxication or withdrawal, medication uncertainty, language barrier, disability accommodation, child detainee, safeguarding concern, conflicting risk assessments, separation need, property discrepancy, evidential item mixed with personal property, disputed search authority, missed rights notification, delayed legal advice, contact restriction, interview deadline, detention clock error, pending extension, expired authority, late review, court direction, release delay, failed transfer, receiving-agency refusal, serious injury, death, complaint against custody staff, system outage, corrupted record and emergency evacuation.

### Acceptance conditions
- Every accepted detainee has a unique custody record linked to the arrest and legal authority.
- Arrest, arrival, acceptance and legal detention commencement times remain distinct and traceable.
- Facility, room and cell suitability, capacity and occupancy are checked.
- Handover, acceptance, refusal and responsibility changes are attributable.
- Every detention period has a valid legal basis, correct clock and review deadlines.
- Expiry or lack of authority triggers lawful release or another valid process, not automatic extension.
- Initial and continuing risk assessments cover health, vulnerability, safeguarding and safety.
- Healthcare, welfare, rights, legal advice, interpretation and contact requests are recorded and reviewed.
- Detainee property is distinguished from evidential material and fully accounted for.
- Searches, interviews, visits and restrictions have separate legal bases and records.
- Complaints, incidents, injury, force, serious harm and death receive appropriate escalation and independent scrutiny.
- Reviews are reasoned, timely, attributable and sufficiently independent where required.
- Release and transfer are lawful, documented and acknowledged.
- Sensitive custody and clinical information is protected through role-based access and audit.
- Historical records cannot be silently overwritten, and retention holds protect serious incident material.
- Custody decisions remain separate from investigative pressure and do not imply guilt.
- The player cannot bypass custody authority, legal clocks, rights or welfare safeguards.

**Draft status:** BP-26 is a working design. Exact detention powers and time limits, custody facility standards, legal rights, review roles, healthcare arrangements, search powers, visit restrictions, release conditions, inspection rules and independent oversight routes remain to be specified in the fictional legal framework. This division does not claim that custody facilities or custody software have been implemented.

## BP-27 — Legal Processes

### Purpose and scope
Define the lawful procedural framework connecting police activity, investigation, custody, prosecutorial or other competent legal review, formal allegations, court applications and case progression. This division models the legal gateways, decisions, documents, deadlines, responsibilities, rights, review routes and procedural consequences that apply before, during and around court proceedings.

BP-27 is the procedural and legal-authority layer. It does not replace:
- BP-25 for arrest and warrant decisions and execution.
- BP-26 for custody, detention authority, welfare and release/transfer.
- BP-19 for interview conduct and safeguards.
- BP-23 for evidence continuity and material management.
- BP-28 for court hearings, judicial findings, trial, verdict and sentence.
- BP-29 for correctional execution and post-conviction administration.

A procedural action is valid only where the actor has the relevant legal power, the required facts and material are available, mandatory safeguards have been met, and the decision is properly recorded. A police record, suspicion, arrest, charge or referral does not establish guilt.

The fictional country's constitution, criminal procedure code, evidence law, prosecution statute, rights instruments, court rules and subordinate regulations are not yet fully specified. Exact powers, thresholds, forms, deadlines, limitation periods, review bodies and legal terminology remain open decisions and must not be invented by the simulation.

### Legal system and authority model
The legal architecture must define:
- Sources and hierarchy of law, including constitutional provisions, statutes, regulations, binding judicial decisions and procedural rules.
- Territorial and subject-matter jurisdiction of national, regional and local authorities.
- Police powers and their limits.
- Independent prosecutorial or other charging authority, where applicable.
- Judicial and tribunal powers, including warrants, orders, bail, remand and review.
- Defence rights, legal representation and access to relevant material.
- Specialist authorities for children, vulnerable persons, national security, corruption, financial crime and other legally distinct matters.
- Administrative, disciplinary, civil and criminal processes, which must remain distinct.
- Applicable law version and effective dates for each procedural event.

Each legal authority has a persistent identity, legal source, jurisdiction, permitted decision types, scope, conditions, effective period, delegation rules, review route and responsible institution. Authority cannot be inferred merely from rank, job title, seniority, possession of a document or access to a system.

### Jurisdiction and venue
Every matter is assessed for territorial, personal, subject-matter and temporal jurisdiction. The system records the locations and conduct relevant to jurisdiction, the applicable legal provisions, any cross-border or inter-regional element, and the authority responsible for deciding jurisdictional questions.

Where multiple agencies or jurisdictions may have authority, the record supports referral, consultation, transfer, joint handling or formal determination. It must preserve the original reporting and investigative history and identify who owns each outstanding action.

A jurisdictional dispute does not silently extinguish a case, suspend a legal deadline or authorise an otherwise unlawful action. Any pause, transfer or extension must have a defined legal basis and accountable decision-maker.

### Procedural status and legal event model
The system maintains distinct, time-stamped statuses rather than a single ambiguous case label. Depending on the law, a matter may be:
- Reported or detected.
- Under preliminary assessment.
- Under police investigation.
- Referred for legal or prosecutorial advice.
- Referred for a charging or prosecution decision.
- Returned for further enquiries.
- Approved, declined or deferred for formal proceedings.
- Subject to a filed allegation, charge, information or equivalent instrument.
- Subject to a summons, notice, warrant, bail or remand process.
- Before a court or competent tribunal.
- Stayed, discontinued, withdrawn, dismissed, acquitted, convicted or otherwise determined.
- Under appeal, review or other post-decision procedure.
- Closed for a defined legal or administrative reason.

These are not interchangeable. A referral is not a charge; a charge is not a conviction; discontinuance is not acquittal; dismissal on a procedural ground is not necessarily a finding on the underlying facts. The system preserves the exact legal event, its effective time, source, authority, affected parties and consequence.

### Legal advice and procedural consultation
Police investigators and supervisors may seek legal advice where permitted. Requests identify the issue, facts supplied, relevant documents, urgency, decision deadline, requesting officer and authorised recipient.

Advice records distinguish:
- The question asked and information supplied.
- Advice received, author and date.
- Assumptions, qualifications and missing information.
- Whether advice is binding, advisory or subject to formal approval under law.
- Decision actually taken and the person responsible.
- Any later change in facts or law requiring reconsideration.

Legal advice does not transfer the decision-maker's statutory responsibility unless the law expressly provides otherwise. Privileged or confidential legal communications receive restricted access and appropriate retention. The system does not assume every communication with a lawyer is privileged or disclose privileged material automatically.

### Investigation and legal sufficiency review
Before a matter proceeds through a formal legal gateway, the relevant decision-maker can review the available material and procedural history. The review may consider:
- Whether the alleged conduct is capable of constituting an offence under the applicable law.
- Whether the relevant legal elements are identified.
- Whether the available evidence is lawfully obtained and adequately documented.
- Whether material is reliable, relevant, sufficiently complete and capable of fair presentation.
- Exculpatory, contradictory, inconsistent or credibility-affecting material.
- Identification uncertainty and alternative explanations.
- Witness availability, safety and support needs.
- Forensic and expert limitations.
- Disclosure obligations and unused material.
- Jurisdiction, limitation, procedural bars and other legal impediments.
- Public-interest or other statutory criteria where the law requires them.
- Whether further proportionate enquiries are necessary and lawful.

The review must not treat an allegation, intelligence assessment, arrest, confession, forensic association or prior record as conclusive proof. It must distinguish established facts, disputed accounts, inferences, untested assertions and unknowns.

A request for further enquiries specifies the legal or factual issue to be addressed, the responsible owner, scope, deadline and authority. It must not become an indefinite or unauthorised investigation. Investigative decisions remain recorded under BP-15 and BP-16.

### Charging and prosecution decision architecture
The fictional legal system must define which authority may decide whether a formal criminal allegation is brought. Depending on that model, the decision may rest with an independent prosecutor, a legally authorised police charging officer, a court or another designated authority. The simulation must not assume that every police officer can charge a person.

A charging decision record contains:
- Person and alleged offence(s).
- Applicable law and offence version.
- Jurisdiction and competent decision-maker.
- Evidential and legal assessment required by the applicable standard.
- Relevant inculpatory and exculpatory material.
- Disclosure and procedural-readiness assessment.
- Any required consultation or approval.
- Decision, reasons, date/time and authorisation.
- Conditions, outstanding tasks and review or reconsideration route.

Possible decisions include approval, refusal, deferral pending specified enquiries, referral to another competent authority, or a legally defined alternative resolution. A decision may be reconsidered only through a lawful process with new material, changed circumstances, identified error or another recognised ground.

The system records each alleged offence separately. Multiple counts or alternative legal characterisations must not obscure the factual basis or permit duplicate punishment contrary to law. Decisions about one person or offence do not automatically determine the status of another person or offence.

### Formal charge or allegation instruments
Where formal proceedings require a charge sheet, information, complaint, indictment or equivalent instrument, the system records the legally prescribed document and its authoritative version. Required fields may include:
- Issuing authority and legal power.
- Accused person's verified identity and any uncertainty.
- Each offence, applicable provision and legal version.
- Factual particulars required by law.
- Relevant date range and jurisdiction.
- Court or venue where assigned.
- Filing, service and response deadlines.
- Required signatures, approvals and validation.
- Amendments, replacement instruments and service history.

A draft instrument is clearly distinguished from an approved, filed or served instrument. The system validates mandatory fields and warns about inconsistencies but does not invent missing facts or silently repair material allegations.

Amendments preserve prior versions, the reason, author, approval, date and legal effect. Material changes that require renewed approval, notice, adjournment or other safeguard must trigger the appropriate workflow.

### Alternative and diversionary processes
If the law provides warnings, cautions, diversion, restorative processes, administrative settlements or other alternatives to prosecution, each has a separate legal basis, eligibility criteria, decision authority, consent requirements, safeguards and record.

The system must distinguish a voluntary process from a compulsory one and record whether participation is informed and genuinely voluntary where required. A diversion outcome is not represented as a conviction unless the law explicitly gives it that effect. Breach, completion, withdrawal and re-entry into ordinary proceedings follow the defined legal rules.

No alternative process may be used to evade required judicial oversight, coerce an admission or bypass protections for children or vulnerable persons.

### Bail, attendance and pre-trial liberty interfaces
BP-27 records the legal process for attendance and pre-trial liberty, while BP-26 remains authoritative for the custody state and BP-28 for judicial proceedings. Depending on law, instruments may include summonses, attendance notices, police bail, court bail, recognisance, conditions, sureties or other arrangements.

Each instrument records:
- Legal basis and competent decision-maker.
- Person, matter and relevant court or authority.
- Conditions, duration and variation rules.
- Required appearance date, location and method.
- Service or notification and proof thereof.
- Review, surrender, breach or cancellation events.
- Consequences and available remedies.

A bail or attendance condition must be lawful, clear, proportionate and linked to an authorised purpose. The system must not treat a breach allegation as established fact without the required process. A missed appearance triggers the prescribed review and does not automatically authorise arrest unless a valid legal power or warrant exists.

### Applications, orders and legal instruments
The system manages applications to competent authorities for orders and directions required by law. Each application records:
- Applicant, target person or property, case and jurisdiction.
- Specific power sought and legal provision.
- Factual grounds and supporting material.
- Scope, limits, duration and conditions requested.
- Required notice, hearing or affected-party participation.
- Decision, reasons, issuing authority and effective time.
- Service, execution, return, expiry, variation or discharge.
- Challenge, appeal or review route.

Orders are verified against their authoritative source and current status before reliance. The system distinguishes draft, submitted, granted, refused, varied, suspended, expired, discharged and executed states. An order is not broadened by operational convenience, and one type of order cannot be substituted for another.

### Disclosure and fair-trial obligations
Disclosure is a continuing legal process, not a one-time document export. The system supports identification, preservation, review, scheduling, lawful redaction, service and tracking of material required to be disclosed to the defence, prosecutor, court or another authorised recipient.

Material categories include relied-upon evidence, unused material, exculpatory information, material affecting witness reliability, expert limitations, recordings, custody and interview records, continuity issues, relevant complaints and other material prescribed by law.

Each disclosure item records:
- Source and authoritative record.
- Relevance assessment and reviewer.
- Disclosure category and legal basis.
- Sensitivity, privilege or restriction concerns.
- Redaction decision and authority.
- Recipient, date, method and version disclosed.
- Any withheld or deferred decision, reasons and review.
- Subsequent discovery, correction or supplemental disclosure.

Disclosure decisions must be reviewable. The system prevents silent deletion, alteration or concealment of potentially relevant material. Access restrictions do not extinguish disclosure duties; conflicts are referred through the legally prescribed process.

### Limitation periods and procedural deadlines
The system tracks legally relevant time limits, including limitation periods, filing deadlines, service periods, response windows, application expiry, appeal periods, attendance dates and procedural review dates.

Every deadline has a legal source, triggering event, calculation rule, applicable calendar, responsible owner, warning schedule and consequence of expiry. The system preserves source dates and calculation history. Suspensions, extensions, tolling or exclusions apply only where the law authorises them and are individually documented.

An alert is not an extension or judicial order. A system-generated date is provisional until checked against the applicable law and triggering facts. Uncertain dates are flagged for authorised legal review rather than silently treated as compliant.

### Legal representation, participation and procedural safeguards
The system records access to representation, legal assistance, interpretation, disability accommodations, child-specific protections, appropriate adult or support-person arrangements where required, notice, participation and any lawful waiver or restriction.

A waiver is valid only where the applicable law's requirements are met and recorded. Silence, lack of objection, inability to understand, failure to attend or absence of a representative is not automatically a waiver.

Where a person's capacity, age, communication needs or vulnerability affects participation, the relevant safeguards are assessed and recorded before a procedural step proceeds. The system supports adjournment, alternative communication and other lawful accommodation.

### Victim and witness procedural interfaces
Victims and witnesses may have statutory rights to information, protection, participation, interpretation, support, notification or review. BP-17 remains authoritative for their person records and safeguarding; BP-27 manages the procedural events and legal entitlements.

The system records notices, requests, referrals, participation decisions, protection measures, reasons for restrictions, hearing notifications and relevant outcomes. It does not promise an outcome or give a witness control over an independent charging or judicial decision unless law expressly provides such a role.

### Review, challenge and appeal interfaces
Legal decisions may be subject to internal reconsideration, prosecutorial review, judicial review, appeal, complaint or another statutory remedy. Each route has its own standing, grounds, authority, deadline, filing requirements and effect.

The record links the challenged decision, applicant, grounds, supporting material, reviewer or tribunal, interim directions, outcome, reasons and implementation. A challenge does not automatically suspend the underlying decision unless the law or a competent authority so provides.

Where a decision is overturned or varied, dependent records and workflows are updated through attributed events. Historical decisions remain preserved, and downstream consequences are corrected where required.

### Legal holds, stays and discontinuance
The system supports legally authorised stays, suspensions, discontinuance, withdrawal, dismissal and other termination or pause mechanisms. Each action records the authority, legal basis, scope, effective date, reasons, affected counts and persons, outstanding obligations, review route and consequences.

A stay is not the same as a final termination. Discontinuance is not automatically an acquittal. A dismissed count does not necessarily terminate other counts or related proceedings. The system must preserve these distinctions and apply any statutory re-filing or limitation rules.

Legal holds protect relevant records and material from routine destruction. A hold identifies scope, authority, custodian, start date, review date and release conditions. Release of a hold requires an attributable decision.

### Inter-agency and cross-jurisdiction procedure
Where a case requires cooperation between police, prosecutors, courts, regulators or other competent bodies, the system records the requesting and receiving authorities, legal basis, purpose, scope, information shared, restrictions, acknowledgement and responsibility for follow-up.

Transfers preserve provenance, document versions, deadlines, custody status and accountability. The sending body remains responsible for actions not formally accepted by the receiving body. Information sharing is limited to lawful purpose and need.

Cross-jurisdiction requests must account for applicable territorial powers, mutual assistance requirements, data protection and any required central authority. No foreign or external authority is assumed to possess domestic powers merely because it requests assistance.

### Records, access and integrity
Legal process records are authoritative, versioned and auditable. Material decisions preserve the information available at the time, the applicable law, decision-maker, reasoning, consultation, approval and effective time.

Role-based access distinguishes police investigators, supervisors, legal advisers, prosecutors, courts, defence representatives, registry staff, victims or witnesses with relevant entitlements, oversight bodies and system administrators. Privileged, sealed, protected and sensitive material receives appropriate controls.

Corrections are made through traceable amendments. The system preserves original instruments, filing receipts, service records, acknowledgements, decisions and disclosure versions. No user may backdate, fabricate, silently replace or erase a legal event.

### Player experience and authority
The player can prepare and submit materials within their role, request legal advice, refer a file, respond to further-enquiry requests, track formal decisions, prepare authorised applications, record service and comply with court or prosecutor directions.

The player cannot make a charging decision, issue a judicial order, waive another person's rights, extend a legal deadline, determine guilt or alter a court outcome unless their expressly defined role and the fictional law authorise that action. System permissions must reflect actual authority and competence.

The interface displays procedural status, responsible authority, required documents, pending decisions, legal deadlines, service status, disclosure obligations and review routes. It distinguishes reminders from formal decisions and draft documents from legally effective instruments.

### Connections to other divisions
- **BP-05 to BP-09:** institutional authority, personnel competence, deployment and resources.
- **BP-11 and BP-12:** incident intake and formal incident records.
- **BP-13 to BP-18:** offences, generated events, cases, investigations, victims, witnesses and suspects.
- **BP-19 to BP-24:** interviews, surveillance, intelligence, scenes, evidence and forensic material.
- **BP-25 and BP-26:** arrest, warrants, detention, custody, bail and release interfaces.
- **BP-28:** hearings, judicial determinations, trial, verdict, sentence and court orders.
- **BP-29:** enforcement of post-conviction and correctional orders.
- **BP-30 to BP-34:** governance, standards, training, staffing and institutional resources.
- **BP-35 to BP-37:** simulation events, social context, legal time and deadlines.
- **BP-38 to BP-44:** records, persistence, interface, notifications, security, testing and configuration.

### Exceptions and edge cases
The design must handle disputed identity, multiple jurisdictions, uncertain offence dates, changing law, conflicting legal advice, missing evidence, exculpatory material discovered late, multiple offences or accused persons, duplicate counts, defective charge instruments, unapproved drafts, filing rejection, failed service, missed attendance, bail-condition dispute, application refused, order varied or expired, urgent application, legal deadline uncertainty, limitation expiry, disclosure dispute, privilege claim, protected witness, child or vulnerable accused, lack of representation, interpreter failure, procedural incapacity, conflict of interest, prosecutor withdrawal, judicial stay, discontinuance, appeal, overturned decision, cross-agency transfer, system outage, corrupted document and retrospective correction.

### Acceptance conditions
- Legal authority, jurisdiction and applicable law version are recorded for every material procedural decision.
- Police, prosecutorial, judicial and defence roles are distinct and permission-controlled.
- Investigation, referral, charging, filing, service, court determination and appeal remain separate procedural states.
- A charging decision records its legal basis, decision-maker, reasons and relevant inculpatory and exculpatory material.
- Draft, approved, filed, served, varied, withdrawn and superseded instruments are distinguishable.
- Applications and orders preserve scope, conditions, expiry, service and execution history.
- Bail and attendance conditions are traceable and do not create automatic arrest powers.
- Disclosure covers relevant relied-upon and unused material, including exculpatory information, with reviewable decisions.
- Deadlines are tied to legal sources and triggering events; alerts cannot extend legal authority.
- Rights, representation, interpretation and vulnerability safeguards are recorded before affected procedural steps.
- Legal stays, discontinuance, dismissal, acquittal, conviction and appeal are not conflated.
- Inter-agency transfers preserve provenance and accountability.
- Privileged and protected information is access-controlled without suppressing legal obligations.
- Legal decisions and documents cannot be silently overwritten or backdated.
- Player actions are limited to the legal authority and competence of the player's role.
- No procedural status or police action is represented as proof of guilt.

**Draft status:** BP-27 is a working design. The constitution, legal hierarchy, offence and charging standards, prosecutorial model, legal instruments, disclosure code, limitation rules, bail framework, rights, appeal routes, jurisdictional arrangements and procedural deadlines remain to be specified. No legal-process software or institution has been implemented by this design document.

## BP-28 — Courts and Outcomes

### Purpose and scope
Define the fictional country's court and tribunal architecture and the complete judicial lifecycle for criminal matters reaching a competent court. This division models court institutions, jurisdiction, case receipt, listings, hearings, parties, judicial decisions, trial, verdict, sentence, appeal interfaces, court orders, records and the consequences of judicial outcomes.

BP-28 is the authoritative design for judicial proceedings and outcomes. It does not replace:
- BP-25 for police arrest, warrant applications and execution records.
- BP-26 for custody, detention, remand reception and release/transfer administration.
- BP-27 for legal process before and around court proceedings, charging, filing, disclosure and procedural deadlines.
- BP-23 and BP-24 for evidence management and forensic examination.
- BP-29 for correctional sentence administration and post-conviction execution.

The court is institutionally independent of police and prosecution. Police may investigate, provide evidence, execute lawful directions and participate as witnesses or applicants where authorised. Prosecutors present or discontinue cases within their lawful authority. Judges and other competent judicial officers control judicial proceedings and make decisions assigned to them by law. No police or prosecutorial role may dictate a judicial outcome.

The fictional constitution, court hierarchy, procedural code, sentencing law, appeal system, judicial appointments and exact legal standards remain to be defined. The design must not invent binding legal rules, penalty ranges, hearing deadlines or judicial powers before those governing decisions are approved.

### Judicial independence and institutional architecture
The national court system must define:
- Constitutional and supreme-level courts.
- Appellate courts.
- Superior trial courts.
- General criminal trial courts.
- Lower or summary criminal courts, where legally established.
- Specialist courts or divisions, if the legal system requires them.
- Juvenile or child-justice courts and protected procedures.
- Judicial registries and administrative services.
- Tribunals with legally defined jurisdiction, kept distinct from criminal courts.
- Judicial oversight and complaint mechanisms that do not compromise lawful decisional independence.

For each court, the architecture records its legal foundation, territorial reach, subject-matter jurisdiction, monetary or offence limits where relevant, original and appellate powers, judicial officer roles, registry functions, filing rules, case allocation, sitting locations, authorised remote procedures and relationships with other courts.

Court administration may manage listings, filings, facilities and records. Administrative personnel cannot decide contested legal questions or alter judicial orders. Judicial officers exercise only powers conferred by law and remain subject to the applicable recusal, ethics, review and appeal framework.

### Judicial personnel and roles
The system distinguishes judges, magistrates or equivalent judicial officers, registrars, clerks, court administrators, interpreters, security personnel, appointed experts and other court staff. It also distinguishes judicial office, administrative employment, delegation, jurisdiction, seniority and access permissions.

Each judicial officer record contains identity, appointment and tenure information, authorised court and case types, jurisdiction, status, recusal/conflict declarations, permitted functions and relevant training or qualification requirements. Sensitive personnel information is restricted.

A judicial officer's assignment to a case is recorded with the legal basis and allocation event. Reassignment, recusal, unavailability or replacement preserves the prior assignment and procedural history. The system must not imply that administrative seniority alone permits one judicial officer to direct another's decision in a case.

### Court case receipt and registration
A court case may originate from a validly filed charge or indictment, an application, a statutory referral, an appeal or another legally recognised route. Receipt is not the same as acceptance, filing validation, service, arraignment or commencement of trial.

The registry workflow records:
- Source authority and originating instrument.
- Linked police incident, investigation and BP-27 legal process records.
- Parties, accused persons and alleged offences.
- Court and jurisdiction proposed.
- Filing date/time and method.
- Required documents, signatures and approvals.
- Registry checks, deficiencies and correction requests.
- Acceptance, rejection or transfer decision and authority.
- Court case identifier and any linked or consolidated proceedings.
- Service, notification and acknowledgement records.

A rejected or incomplete filing remains auditable and does not silently become an active prosecution. The system distinguishes administrative registry checks from judicial determinations. Defects that require judicial resolution are referred to the proper judicial officer.

Court identifiers are unique and persistent. Consolidation, severance, transfer, re-filing, appeal and related proceedings maintain explicit links without erasing original identifiers or creating false equivalence between separate cases.

### Parties and participation
A court record identifies the accused or defendant, prosecution or applicant, legal representatives, complainants where legally recognised, victims, witnesses, interpreters, experts and any other authorised participants. Each participant's legal role, representation, contact arrangements, participation rights, service status and access restrictions are recorded.

A person is not labelled guilty merely because they are accused, charged, arraigned, remanded or tried. Where identity is disputed or uncertain, the court record preserves that uncertainty and the judicial process used to resolve it.

The system supports multiple accused persons, multiple charges, jointly tried or separately tried defendants, corporate or organisational defendants where law permits, and cases involving minors or protected persons. A decision concerning one defendant or count does not automatically determine another's case.

### Case allocation, listing and scheduling
Court cases are allocated and listed under the applicable law and court rules. The system supports:
- Jurisdiction and venue checks.
- Judicial assignment and conflict checks.
- Case management conferences.
- Initial appearances and arraignment.
- Bail or remand hearings.
- Pre-trial applications and directions.
- Disclosure and evidential hearings.
- Trial dates and estimated duration.
- Sentencing hearings.
- Appeal and review listings.
- Adjournments, postponements and emergency listings.

Each listing records court, date/time, hearing type, assigned judicial officer, participants, attendance method, required documents, interpretation or accessibility needs, security requirements and notification status.

A listing is not proof that a hearing occurred. Actual commencement, appearances, non-attendance, adjournment, interruption and conclusion are separate events. Rescheduling preserves the original date and reason, the authority for the change and any legal consequences.

Calendar calculations use the applicable court calendar, holidays and procedural rules. The system flags conflicts, expired deadlines and unavailable participants, but does not silently extend legal time limits or decide contested applications.

### Service, notice and attendance
The system records formal service of charges, summonses, hearing notices, applications, orders and other court documents. A service record identifies the document version, recipient, authorised method, serving person or agency, date/time, location or delivery channel, proof and outcome.

Service states distinguish prepared, issued, dispatched, delivered, personally served, acknowledged, attempted, failed, disputed, substituted by judicial order and otherwise legally completed. A notification message or system alert is not automatically valid legal service.

Non-attendance is recorded factually, including whether notice was validly served, whether an explanation was offered, whether representation attended, and what the court decided. A failure to attend does not itself establish guilt or authorise arrest. Any warrant or coercive order must be issued by a competent authority under the applicable law and recorded as a separate judicial event.

### Pre-trial judicial proceedings
The court may conduct hearings and make directions before trial, as permitted by law. These may include:
- Initial appearance and confirmation of identity.
- Explanation of charges and plea procedure.
- Representation and legal assistance.
- Bail, remand and release-condition review.
- Jurisdictional and venue challenges.
- Disclosure disputes and protective orders.
- Admissibility or exclusion applications.
- Expert evidence and witness arrangements.
- Safeguarding and special measures.
- Joinder, severance and amendment applications.
- Case readiness, timetabling and trial management.
- Abuse-of-process or other procedural applications.
- Applications to stay, dismiss, discontinue or otherwise dispose of proceedings.

Each application records the applicant, relief sought, legal basis, supporting material, notice, response, hearing, judicial decision, reasons, order and review route. The system distinguishes an application filed from one granted and an interim direction from a final determination.

Judicial directions are assigned to responsible parties with scope and deadlines. Compliance, variation, non-compliance and consequences are separately recorded. A police agency receives only those directions that apply to it and may not assume powers beyond their wording or legal basis.

### Pleas and admissions
The system records the legally recognised plea or response for each defendant and each charge, including guilty, not guilty, no plea, plea not taken, plea deferred or other jurisdiction-specific states.

A plea is valid only when the applicable legal requirements are satisfied. The record identifies who entered it, whether the defendant was present or represented, any interpretation or capacity safeguards, the judicial officer accepting it and the legal effect.

A guilty plea is not interchangeable with an informal admission, interview statement or admission to one factual element. The system records its scope and any agreed or disputed factual basis. A plea may be changed or withdrawn only through the applicable lawful process and judicial decision where required.

A not-guilty plea does not imply factual innocence as a system-generated conclusion; it records the defendant's formal position and preserves the prosecution's burden and the presumption of innocence.

### Trial architecture
Where a matter proceeds to trial, the court workflow models the legally required stages, which may include:
- Confirmation of parties, charges and preliminary matters.
- Jury selection or appointment of a fact-finder where the legal system provides one.
- Opening statements or equivalent introductions.
- Prosecution presentation.
- Defence response and presentation.
- Witness testimony and examination.
- Expert evidence.
- Documentary, physical, audio/video and digital exhibits.
- Evidentiary objections and judicial rulings.
- Legal submissions and directions.
- Closing submissions.
- Deliberation where applicable.
- Verdict or other formal determination.

The system supports judge-only and jury or panel trials if authorised by the fictional legal framework. It records the fact-finder model, participants, proceedings, rulings, exhibits admitted or excluded, reasons where required, directions and the exact outcome for each count and defendant.

The court evaluates evidence under the applicable legal standards. The simulation must not convert a forensic result, witness account, intelligence report, arrest, prior conviction or police opinion into an automatic judicial finding. Evidence may be challenged, limited, excluded, contradicted or given different weight.

The court record preserves the distinction between evidence tendered, evidence admitted, evidence considered, judicial findings of fact and the final legal conclusion. The game must not reveal hidden world facts to the player merely because a case enters trial; only facts properly established or disclosed through the proceedings become available.

### Witnesses, victims and protected participation
The court may receive testimony from victims, eyewitnesses, expert witnesses, police officers, civilian witnesses and other competent persons. It must support lawful special measures for children, vulnerable witnesses, intimidated witnesses, protected identities, remote testimony or other needs defined by law.

The record tracks summons, attendance, oath or affirmation where required, interpretation, support arrangements, questioning, objections, judicial directions, breaks, safety concerns and any authorised restrictions on public access or disclosure.

A witness's non-attendance, inconsistency, memory limitation or refusal to answer is recorded without automatic credibility scoring. Judicial findings must remain attributable to the court and grounded in the proceedings.

Victims' participation and notification rights are represented accurately without granting control over prosecution decisions or judicial findings unless the law expressly provides it.

### Evidence, exhibits and judicial rulings
BP-23 remains the authoritative evidence register and chain of custody. BP-28 records the court-facing exhibit process, including:
- Exhibit identifier and originating evidence record.
- Tendering party and purpose.
- Authentication or foundation issues.
- Objections and responses.
- Admission, limitation, exclusion or withdrawal decision.
- Judicial reasons and applicable legal rule.
- Display, playback, inspection or handling at court.
- Return, storage, sealing or other post-hearing disposition.
- Links to transcript, order and verdict reasoning where appropriate.

Court exhibit labels do not replace authoritative evidence identifiers. A copy, demonstrative aid or derivative is distinguished from the original and linked to its source. Any discrepancy in continuity, integrity or provenance remains visible and cannot be silently resolved by the court interface.

### Public access, privacy and protected proceedings
The default openness or publicity of proceedings must follow the fictional constitution and court law. The system supports public hearings, restricted access, private or closed sessions, sealed documents, anonymity orders, publication restrictions and other lawful protections.

Every restriction records the issuing authority, legal basis, scope, affected persons or material, duration, review date and publication or access consequence. Restrictions are not inferred from a user's preference or applied globally without authority.

Public court information is separated from confidential, sealed, privileged, child-protection, witness-protection and otherwise restricted material. Redacted public copies retain links to the authoritative unredacted record and a record of who approved the redaction.

### Judicial decisions and orders
A judicial decision is a formal act by a competent judicial officer or court. The record includes:
- Court and case identifier.
- Judicial officer or panel.
- Parties and issues determined.
- Applicable law and jurisdiction.
- Procedural history and material considered.
- Decision and reasons, to the extent required.
- Operative orders and affected counts or persons.
- Date/time made and effective date.
- Publication, sealing and service status.
- Appeal or review rights and deadlines.
- Correction, clarification, variation, stay or enforcement history.

Decisions are classified by legal effect, such as procedural direction, interim order, evidentiary ruling, bail/remand order, dismissal, stay, verdict, sentence or appeal judgment. A written judgment may be issued later than an oral ruling; both events and their legal effect are recorded accurately.

Orders are not altered by administrative staff or police. Clerical correction, appeal, variation, suspension and discharge follow distinct authorised procedures. The system verifies current status before downstream agencies act.

### Verdicts and findings
The outcome is recorded separately for every defendant and every charge. Depending on law, possible outcomes may include:
- Guilty.
- Not guilty or acquitted.
- Charge dismissed.
- Proceedings stayed or discontinued.
- No verdict or mistrial.
- Count withdrawn or not proceeded with.
- Finding deferred or another legally recognised result.

The system distinguishes a verdict from a sentence, a dismissal from an acquittal, a stay from final disposal and a mistrial from a finding on guilt. It records whether a decision is final, subject to appeal, subject to retrial or otherwise qualified.

A conviction exists only when a competent court has entered the legally effective finding. A police or prosecution record cannot independently mark a person convicted. A finding on one count does not automatically establish guilt on another count.

Where the court makes factual findings, those findings are attributed to the judgment and distinguished from the simulation's hidden ground truth. A court may reach a legally valid outcome while some world facts remain uncertain or unproven.

### Sentencing and penalty decisions
Where a conviction or other lawful basis permits sentence, BP-28 models the judicial decision and formal sentence. BP-29 governs correctional administration and execution.

The sentencing process may include:
- Confirmation of the conviction and counts.
- Applicable statutory or guideline framework.
- Prosecution and defence submissions.
- Victim impact or other permitted information.
- Pre-sentence reports and assessments.
- Mitigating and aggravating factors.
- Relevant prior convictions where law permits.
- Credit for time in custody where required.
- Concurrent or consecutive sentence decisions.
- Financial penalties, compensation, restitution or other orders.
- Community-based sanctions, treatment or supervision.
- Custodial sentence and release-related terms.
- Reasons, appeal rights and effective date.

The court's authority, sentencing range and permitted sanctions depend on the law in force. No penalty is generated solely from a crime category, a severity score or a game-balance formula. Sentences must be legally valid, individualised where required and traceable to the judicial reasons and applicable law.

A sentence may be appealed, corrected, varied or stayed only through a lawful process. The system does not treat a sentence as executed merely because it has been entered; BP-29 records the receiving authority's acceptance and execution state.

### Court outcomes and downstream effects
Each outcome generates controlled, attributable events for relevant systems:
- BP-27 legal process status and appeal deadlines.
- BP-26 custody, release, remand and transfer status.
- BP-29 correctional intake, supervision or other sentence execution.
- BP-18 suspect/offender status, without overwriting historical status.
- BP-15 case closure, linked-case status and remaining investigative work.
- BP-23 evidence retention, return, legal hold and disposal review.
- BP-17 victim and witness notification or support obligations.
- BP-30 governance, oversight and performance records.
- BP-38 authoritative records and audit history.

Downstream updates occur only after the legally effective event is verified. An appeal or stay may alter the effect of a decision; the original judgment remains preserved and is marked with its current legal status. A case outcome does not automatically dispose of related cases, civil claims, disciplinary matters or separate charges.

### Appeals, reviews and retrials
BP-27 manages procedural filing and deadlines; BP-28 records appellate court proceedings and judgments. The system supports legally recognised appeal routes for conviction, acquittal where permitted, sentence, interlocutory decisions, procedural rulings and other reviewable matters.

Each appeal record identifies:
- Decision challenged and relevant counts/persons.
- Appellant and legal standing.
- Grounds and relief sought.
- Court with appellate jurisdiction.
- Filing date, time limit and any extension decision.
- Record and transcript required.
- Responses, submissions and hearings.
- Interim stay or bail status.
- Appellate decision and reasons.
- Further appeal or review rights.
- Directions for retrial, resentencing, variation or other action.

Possible outcomes include affirm, reverse, vary, quash, remit, order retrial, substitute a legally permitted decision, dismiss the appeal or another defined disposition. The exact powers remain dependent on the fictional legal framework.

An appeal does not automatically suspend every consequence of the original decision. The system records whether a stay or other interim order has been granted and its precise scope. A retrial is a new procedural phase linked to the prior proceedings, not a deletion or silent restart of the original case.

### Court administration and operational resources
Court operations require buildings, courtrooms, secure waiting areas, custody holding facilities, accessible rooms, recording systems, exhibit storage, secure document systems, interpretation and remote-hearing infrastructure where lawful.

Each resource has availability, capacity, access restrictions, maintenance, safety and incident records. Scheduling conflicts, security risks, unavailable interpreters, equipment failure or facility closure may require an adjournment or alternative arrangement by the competent authority.

Court security is institutionally separate from judicial decision-making. Security staff may enforce lawful courtroom directions but cannot interfere with evidence, deliberations, judicial independence or the rights of parties.

### Court records, transcripts and access
The court maintains authoritative records of filings, hearings, appearances, submissions, exhibits, rulings, orders, judgments, verdicts, sentences and appeals. The system distinguishes:
- Official court record.
- Audio/video recording.
- Transcript or approved minutes.
- Filed party documents.
- Judicial working material where legally protected.
- Public register and public judgment.
- Sealed or restricted record.
- Certified copies and extracts.

A transcript may be provisional, corrected, approved or certified. Corrections preserve the original record and identify the authority, reason and date. Recording failures, missing segments and disputed transcripts are logged and handled under court rules.

Access, copying, publication, retention and destruction follow applicable law and judicial directions. A police user does not receive unrestricted access to court records merely because a case originated from a police investigation.

### Complaints, recusal and judicial accountability
The system supports formal processes for judicial recusal, conflict declarations, complaints about court administration, misconduct referrals and independent oversight. These are distinct from appeal, which challenges a judicial decision through the legally prescribed route.

A complaint does not automatically invalidate a judgment or suspend a case. A recusal request is decided by the competent judicial authority under the applicable rules. Any reassignment preserves the procedural history and records the effect on existing orders.

Judicial performance information may support lawful administration and quality assurance but must not reward conviction rates, punish independent outcomes or create pressure to decide cases for institutional convenience.

### Player experience and authority
The player may appear as a police witness, provide records or exhibits through authorised channels, execute lawful court directions, respond to subpoenas or summonses, assist prosecutors where permitted and track case outcomes relevant to police duties.

The player cannot direct judges, access sealed records without authority, alter court transcripts, determine verdicts, impose sentences, change judicial orders or mark a person convicted. If the player later occupies a legally authorised judicial role in a separately defined career path, that role must have independent eligibility, appointment, conflict and permission rules; it cannot be assumed from police rank.

The interface shows court, case, parties, assigned judicial officer, hearing schedule, filings, service status, evidence/exhibit status, orders, outstanding directions, judgment, verdict, sentence, appeal status and downstream confirmations. It clearly distinguishes scheduled events from completed hearings and draft outcomes from signed or legally effective decisions.

### Connections to other divisions
- **BP-05 to BP-09:** institutional boundaries, personnel, deployment and court resources.
- **BP-11 and BP-12:** incidents and originating records.
- **BP-13 to BP-18:** offence law, crime events, case management, investigation, victims, witnesses and accused persons.
- **BP-19 to BP-24:** interviews, surveillance, intelligence, scenes, evidence and forensic reports.
- **BP-25 and BP-26:** warrants, arrest, custody, bail, remand and release.
- **BP-27:** legal process, charging, disclosure, filing, service, deadlines and procedural appeals.
- **BP-29:** correctional reception, sentence execution, supervision and release.
- **BP-30 to BP-34:** institutional governance, standards, training, staffing and finance.
- **BP-35 to BP-37:** simulation engine, social context, time and scheduling.
- **BP-38 to BP-44:** records, persistence, interface, notifications, security, testing and configuration.

### Exceptions and edge cases
The design must handle wrong court or jurisdiction, defective filing, disputed identity, multiple defendants and counts, corporate defendant, child defendant, unavailable judicial officer, recusal, judicial reassignment, conflict of interest, late or failed service, disputed attendance, non-attendance, interpreter failure, accessibility need, witness intimidation, protected identity, remote hearing failure, court closure, missing exhibit, evidence continuity challenge, inadmissible material, disclosure dispute, late disclosure, plea ambiguity, plea withdrawal, mistrial, hung jury or panel, inconsistent verdicts, partial conviction, partial acquittal, sentence error, overlapping sentences, time-served calculation dispute, order not served, order expired, appeal filed late, appeal extension, stay refused or granted, conviction quashed, retrial ordered, sentence varied, death of a party, corporate dissolution, court record corruption and retrospective correction.

### Acceptance conditions
- Court hierarchy, jurisdiction and judicial authority are explicit and legally grounded.
- Court administration is separate from judicial decision-making.
- Case receipt, registry validation, filing, service, hearing and determination are separate events.
- Each case and proceeding has a persistent identifier and auditable links to originating records.
- Parties, representation, participation rights and access restrictions are recorded.
- Listings distinguish scheduled, commenced, adjourned, interrupted and completed hearings.
- Service and attendance records preserve proof and legal status.
- Pre-trial applications, directions and judicial orders preserve scope, authority and reasons.
- Pleas are recorded per defendant and charge and are not conflated with informal admissions.
- Trial stages, participants, evidence and rulings are traceable.
- Court exhibits link to BP-23 evidence identifiers and preserve continuity.
- Public, private, sealed and protected proceedings follow recorded legal authority.
- Judicial decisions preserve reasons, effective time, operative terms and appeal routes.
- Verdicts are recorded separately for each person and count.
- Acquittal, dismissal, stay, discontinuance, mistrial and conviction are not conflated.
- Sentencing decisions cite the applicable law and do not use arbitrary game-balancing formulas.
- Downstream legal, custody and correctional updates occur only after verification of the legally effective order.
- Appeals preserve the original decision and record interim stays and appellate outcomes.
- Court records, transcripts and corrections are versioned, access-controlled and auditable.
- The player cannot direct judicial outcomes or alter court records without a specifically authorised role.
- No court outcome is treated as an omniscient statement of all hidden world facts.

**Draft status:** BP-28 is a working design. The constitutional court structure, judicial appointment model, court jurisdictions, trial modes, jury or panel arrangements, criminal procedure, evidentiary rules, sentencing framework, appeal rights, publication rules, court administration and exact legal deadlines remain open. No court, registry, case-management or judicial-outcome software has been implemented by this design document.

