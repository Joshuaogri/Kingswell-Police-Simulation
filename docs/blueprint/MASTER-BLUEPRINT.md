# Kingswell Master Blueprint

**Status:** Working draft — not yet approved  
**Version:** 0.1  
**Setting:** Fictional sovereign country; capital city of Kingswell  
**Rule:** This document defines the intended game. It is separate from the implementation register and technical architecture.

## BP-01 — Game Identity, Foundations and Governing Rules

### 1. Purpose and authority
BP-01 is the foundational charter for Kingswell. It defines what the game is, what experience it must deliver, the boundaries of the simulation and the principles that every later division and implementation must respect.

BP-01 governs the overall experience. It does not replace the detailed rules owned by later divisions. Where a later division defines a specific subsystem, that division supplies the operational detail while remaining consistent with BP-01. A genuine conflict must be recorded and resolved through a controlled blueprint revision; it must not be silently interpreted differently by separate systems.

### 2. Game identity
Kingswell is a comprehensive, persistent, text-first fictional police simulation set in an entirely fictional sovereign country whose capital city is Kingswell.

The player inhabits one individual police character and experiences the world primarily through that character's work, knowledge, authority, decisions and career. The simulation also models the police service, its institutions and the surrounding population and world deeply enough to produce coherent, varied and consequential policing.

The game is fictional. Its people, places, organisations, laws, offences, procedures, records and events are game-world content. Real-world organisations, people or events are not implicitly part of the setting.

### 3. Primary experience and four layers
The police experience is the central purpose of the game. The four layers below are connected views of one persistent simulation, not separate games.

1. **Personal layer:** the player's identity, employment, rank, appointment, position, qualifications, authority, duties, working relationships, career history and day-to-day experience.
2. **Operational layer:** calls, dispatch, patrol, deployments, incidents, scene activity, decisions, reports, investigations and operational outcomes.
3. **Institutional layer:** police command, supervision, units, staffing, training, resources, administration, performance, accountability and organisational change.
4. **World layer:** people, households, businesses, properties, organisations, places, routines, events and relationships that create the circumstances in which policing occurs.

An event in one layer may affect the others. For example, an operational decision may change an incident record, affect a person's life, create an investigative lead, require supervisory review and influence the player's career.

### 4. Core governing principles
The following principles are mandatory across the design:

- **Fictional canon:** the game world is internally defined. Its facts and rules come from the Kingswell blueprint and persistent game records.
- **Single coherent world:** all divisions operate on the same world state. A person, place, organisation, incident or item must not acquire conflicting identities merely because it appears in multiple systems.
- **Persistent continuity:** consequential actions and world changes carry forward. Records must preserve enough history to explain how the current state arose.
- **Individual identity:** people and other persistent entities have stable identities. Changes to names, roles, relationships, locations or status do not silently create a new identity or erase relevant history.
- **Player agency:** the player chooses what their character attempts within the character's knowledge, capability, role and authority. The simulation determines the outcome from the established world state and rules; it must not silently choose the player's decisions.
- **Consequential simulation:** actions may succeed, fail, be delayed, produce incomplete results or create unintended consequences. Outcomes must follow the situation and applicable game rules rather than being guaranteed by the player's request.
- **Consistent authority:** rank, appointment, position, authority, qualification, clearance and assignment are distinct concepts. A character may only exercise powers and access granted by the relevant game-world rules and current role.
- **Traceability:** important actions, decisions, state changes and outcomes must be attributable to an actor or system process and associated with an appropriate time and record.
- **Controlled time:** simulation time advances only through defined game actions or explicitly defined simulation processes. It does not silently advance merely because the player is away or has stopped interacting.
- **Text-first operation:** text and conversational commands are sufficient for the complete core game. Graphics, maps, diagrams and other visual features may supplement play but must never be required to understand or operate essential gameplay.
- **Bounded depth:** police work receives the deepest simulation. Other institutions, businesses and world systems are developed to the depth needed to support credible policing and persistent consequences, not as an unrelated full simulation of every aspect of society.
- **Modular coherence:** divisions may own distinct systems, but their identities, records, rules and state transitions must integrate into one game.
- **No silent canon changes:** a change to an established rule, setting fact or accepted design decision must be recorded and reflected in the relevant blueprint material.

### 5. Player role and point of view
The player controls one police character at a time. The character has an individual identity and a current employment and assignment state.

The player may issue commands, ask questions, make decisions, request information and attempt actions. The game must distinguish:
- what the character knows;
- what the character can reasonably discover;
- what the character is authorised to do;
- what the character is capable of doing;
- what the character has actually attempted;
- what the simulation has confirmed as completed.

The interface must not treat a question as an action, an intention as a completed action, or a requested outcome as proof that the outcome occurred.

The player receives information through the character's available channels and permissions. The game may maintain additional world or case facts that the character does not know. The interface must preserve that distinction and must not disclose hidden information merely because it exists in the underlying simulation.

### 6. Core gameplay cycle
The exact command syntax and subsystem workflows are defined in BP-40 and the relevant operational divisions. At the foundational level, the game must support this recurring cycle:

1. **Establish state:** identify the character's current date and time, duty status, assignment, location, available resources and relevant known information.
2. **Receive or select work:** present duties, calls, incidents, tasks, instructions or other opportunities that are available to the character.
3. **Understand the situation:** provide information the character is entitled and reasonably able to access.
4. **Choose an action:** allow the player to issue a clear instruction or attempt an available action.
5. **Resolve the action:** validate the character's role, authority, capability, resources, location and the current world state; then determine the outcome.
6. **Record consequences:** update the relevant operational and world records, preserve history and create any resulting tasks, notifications or reviews.
7. **Continue play:** present the resulting state and allow the player to decide what to do next.

This is a conceptual gameplay cycle, not a requirement that every command must pass through seven visible screens or steps.

### 7. Time and continuity
The simulation maintains one authoritative in-game date and time. The clock is used consistently by personnel schedules, duty rosters, appointments, travel, incidents, dispatch, investigations, evidence timelines and other time-dependent systems.

Time advancement is controlled by the rules in BP-37. BP-01 establishes these governing constraints:
- The game must make the current in-game date and time available to the player.
- Time-dependent events must use the same authoritative clock.
- A completed action may consume time where its defined rules require it.
- The simulation must not advance time simply because the player closes the conversation, leaves the game or is inactive.
- Any deliberate time-advance command or action must have a defined and understandable effect.
- Historical events must retain their original timestamps when later records are corrected or supplemented; corrections must not rewrite history invisibly.

### 8. Persistence and records
The game must preserve the state needed to continue from the point at which play was last saved. Persistence is not limited to the player's character: it includes relevant world, organisational, operational and historical state.

The game must be able to distinguish:
- current state from historical state;
- confirmed facts from allegations, estimates, hypotheses and unknowns;
- attempted actions from completed actions;
- an original record from a later correction, supplement or review;
- player-visible information from information not available to the character.

BP-38 defines record structures and ownership. BP-39 defines saving, persistence, backup and recovery. BP-01 requires these systems to preserve continuity and prevent silent loss or unexplained alteration of consequential state.

### 9. World and non-player characters
The world must feel active and coherent rather than existing only when the player directly asks about it. People, organisations and locations have identities, relationships, schedules, activities and changing circumstances as defined by their owning divisions.

The simulation may vary the amount of processing devoted to different people and world elements. Such variation is an implementation strategy; it must not create duplicate identities, contradictory facts or arbitrary changes to established history.

The world must not be simulated at the expense of player agency. Non-player characters and background processes may act within their defined rules, but their actions and effects must remain consistent with the shared world state and controlled simulation time.

### 10. Consequences, uncertainty and fairness
The game must preserve meaningful uncertainty. The player is not automatically told every fact, hidden motive, cause or outcome. Information may be incomplete, mistaken, delayed, disputed or unavailable.

The simulation must not confuse an allegation with a finding, a suspicion with proof, a lead with a conclusion, or a possibility with an established fact. Later divisions define the detailed treatment of evidence, investigations and outcomes.

Consequences must be coherent and proportionate to the established events and rules. The game must not arbitrarily punish the player, guarantee success, or change facts merely to force a preferred narrative.

### 11. Institutional and world boundaries
The National Police Service is the principal deeply simulated institution. Other public bodies, private organisations, businesses and community structures exist to make the world credible and to support police activity.

Those external institutions must have enough defined identity, function, personnel, locations and records to support interactions with the police. They do not automatically receive the same operational depth as the police service.

The wider country exists as part of the setting and may support national institutions, jurisdiction and events. BP-02 defines the geographical scope and the level of detail required outside Kingswell.

### 12. Scope and change control
A proposed feature or system addition must identify:
- the gameplay purpose it serves;
- the division responsible for its rules and records;
- the boundaries of what it will and will not simulate;
- its dependencies and affected divisions;
- any new entities, state changes, commands or records it requires;
- how it will be tested against existing rules.

A proposal is not an implemented feature merely because it appears in the blueprint. A drafted design is not approved until its status is explicitly changed through the project's decision process. A software feature is not complete merely because its design has been written.

### 13. Division ownership and cross-system consistency
The following divisions own the detailed rules for their respective areas:
- BP-02: country, city and geographical architecture.
- BP-03: population and individual simulation architecture.
- BP-04: buildings, properties, businesses and organisations.
- BP-05 to BP-34: police organisation, operations, crime, investigations, justice and institutional functions.
- BP-35: simulation engine and runtime coordination.
- BP-36: relationships and social context.
- BP-37: time and scheduling.
- BP-38: records and databases.
- BP-39: persistence and recovery.
- BP-40: interface and command interaction.
- BP-41: notifications and reporting.
- BP-42: security and permissions.
- BP-43: testing and quality assurance.
- BP-44: configuration and controlled expansion.

BP-35 coordinates runtime behaviour but does not take ownership of the substantive rules belonging to domain divisions. Technical implementation must preserve the division of responsibility established by the blueprint.

### 14. Acceptance conditions
BP-01 is ready for approval when all of the following can be demonstrated at the design level:

1. The game's fictional identity, setting premise, primary player experience and boundaries are unambiguous.
2. The four experience layers are defined and their relationship is understood.
3. The player controls one individual character and retains meaningful agency over that character's decisions.
4. The game distinguishes character knowledge from hidden or otherwise unavailable world information.
5. Questions, intentions, attempted actions and completed actions are not conflated.
6. Rank, appointment, position, authority, qualification, clearance and assignment remain distinct.
7. One coherent world state and stable identities are shared across divisions.
8. Consequential actions and changes are historically traceable.
9. Time-dependent systems use one authoritative clock and time does not advance merely because the player is absent.
10. Text alone supports the complete core gameplay experience.
11. Police systems receive the intended depth while other world systems remain bounded by their supporting purpose.
12. Uncertainty, incomplete information and consequential outcomes are handled consistently.
13. Domain ownership and cross-system dependencies are clear.
14. Design approval, software implementation and tested completion remain distinct statuses.
15. New scope and changes are recorded rather than silently introduced.

### 15. Status and unresolved detail
This revision strengthens the foundational rules and makes their implications testable. It does not by itself approve BP-01, settle every detailed subsystem rule or declare any software feature implemented.

Detailed command syntax, calendar mechanics, simulation processing, record schemas, persistence controls, permissions and test procedures remain owned by their respective divisions and must be completed there.

**Draft status:** BP-01 remains a working draft pending review and explicit approval.

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

## BP-29 — Corrections

### Purpose and scope
Define the institutional and operational architecture for the lawful, safe, humane and accountable administration of sentences and other court-authorised correctional measures after a legally effective judicial or statutory decision. This division covers correctional institutions, community-based sanctions, reception, sentence calculation, custody within correctional facilities, rehabilitation, healthcare interfaces, family contact, security, release preparation, supervision, recall, post-release support and correctional records.

BP-29 is the authoritative design for correctional administration and execution. It does not replace:
- BP-25 for police arrest and warrant execution.
- BP-26 for police custody, pre-trial detention and remand administration before transfer to a correctional authority.
- BP-27 for legal process, charging, procedural deadlines and formal legal instruments.
- BP-28 for judicial proceedings, verdicts, sentence decisions, appeals and court orders.
- BP-23 for evidential material and its chain of custody.
- BP-30 and BP-31 for institutional governance, professional standards and independent oversight.

A correctional authority may execute only a valid order or other legal authority within its scope. Police, prosecutors, correctional personnel and courts have distinct responsibilities. A sentence is not proof of additional uncharged conduct, and correctional staff cannot alter a judicial sentence except through a legally authorised process.

The fictional country's corrections statute, prison regulations, probation legislation, parole framework, sentence calculation rules, inspection regime and exact rights standards remain to be defined. The design must not invent binding sentence lengths, release dates, eligibility thresholds or coercive powers before the relevant law is established.

### Correctional system and institutional architecture
The national correctional system may include:
- National corrections headquarters and regional commands.
- Adult custodial institutions.
- Remand facilities, where legally assigned to the correctional service.
- Youth or juvenile institutions with distinct safeguards.
- Women's facilities and appropriate gender-specific arrangements.
- Open, minimum, medium and high-security facilities where legally and operationally justified.
- Specialist healthcare, treatment or secure therapeutic facilities.
- Probation and community supervision offices.
- Community service and other non-custodial programme providers.
- Reintegration, resettlement and post-release support services.
- Transport, escort and court attendance functions.
- Inspection, complaints and independent monitoring bodies.

Each institution has a persistent identity, legal designation, location, jurisdiction, capacity, security classification, approved population, staffing, healthcare provision, accessibility, operating status and inspection history.

The system distinguishes a correctional institution from a police custody suite, court holding area, hospital, immigration detention facility or private accommodation. Transfer between them requires the appropriate legal authority, acceptance and documented handover. A person is not considered received into a facility merely because a transport task has been dispatched.

### Governance, independence and accountability
Correctional administration operates under law, public accountability and defined institutional command. The design records:
- Statutory mandate and limits of correctional powers.
- National policy and operational command.
- Facility governors or equivalent accountable heads.
- Regional and specialist management.
- Professional, healthcare and safeguarding responsibilities.
- Independent inspection and monitoring.
- Complaints, investigations and external review.
- Judicial oversight and court-directed remedies.
- Emergency command and continuity arrangements.

Correctional management may allocate staff and resources and enforce lawful facility rules. It cannot amend a sentence, determine guilt, obstruct legal access or retaliate against a person for exercising a right or making a complaint.

Independent inspectors and oversight bodies have defined access, reporting, referral and confidentiality powers. Their findings and recommendations are recorded separately from internal management responses. The institution cannot suppress or rewrite independent findings.

### Correctional population and legal status
Each person in the correctional system has a persistent correctional record linked to the authoritative person identity and relevant BP-28 judicial order or BP-27 legal process. The record distinguishes:
- Sentenced prisoner.
- Remand detainee.
- Person held under another lawful detention authority.
- Person serving a non-custodial order.
- Person under probation or community supervision.
- Person temporarily transferred or held elsewhere.
- Person released, discharged, deceased or otherwise no longer under correctional jurisdiction.

Legal statuses are not inferred from location, uniform, institutional label or a prior record. A person may have multiple matters with different legal statuses and overlapping orders. The system records which authority supports each period of detention or supervision.

Remand and sentenced populations must remain distinguishable. A remand detainee is not treated as convicted or assigned a sentence merely because they are housed in a correctional institution. Where a conviction is appealed, stayed, quashed or varied, the current legal effect is verified and reflected without deleting historical events.

### Reception, identity and admission
Correctional admission follows verification of a valid legal authority and formal acceptance by the receiving institution. The workflow records:
- Person identity and any uncertainty or alias.
- Sending authority and responsible officers.
- Court, case and order identifiers.
- Legal status, offence/count references and sentence or detention terms.
- Date/time of order and legal commencement.
- Date/time of dispatch, arrival, presentation and formal acceptance.
- Required documents and verification checks.
- Property and medication handover.
- Initial health, safety and vulnerability screening.
- Immediate risks, safeguarding concerns and separation requirements.
- Admission decision, responsible receiving officer and any refusal or escalation.

A defective, expired, ambiguous or mismatched order is escalated to the competent authority. Staff do not create a substitute legal basis or extend detention to resolve an administrative problem. Refusal, delay or inability to accept a person is documented with the legal and operational reasons and a safe, lawful interim plan.

Identity uncertainty is preserved. Biometrics or other identification procedures may be used only under lawful authority and appropriate safeguards. A correction to identity must update linked records through an auditable process rather than silently merging different people.

### Sentence calculation and legal time
The system calculates correctional dates only from verified legal instruments and approved rules. It distinguishes:
- Sentence imposed date.
- Sentence effective or commencement date.
- Time spent in police custody or remand.
- Credited time, where legally authorised.
- Concurrent and consecutive sentences.
- Multiple convictions and aggregate terms.
- Suspended or deferred sentences.
- Statutory remission or earned credits, if authorised.
- Eligibility dates for temporary release, parole or other review.
- Conditional and unconditional release dates.
- Licence or supervision end dates.
- Sentence expiry and legal discharge.

Every calculation records its rule version, source order, inputs, exclusions, credits, author or system process, verification and correction history. Concurrent and consecutive terms must not be confused. A later sentence or appeal may require recalculation while preserving the original calculation and the reason for change.

A calculated eligibility date is not an automatic release authorisation. Release requires confirmation of all active orders, detainers, warrants and lawful holds. Conversely, an administrative error or missing notification cannot justify detention beyond lawful authority.

### Classification, placement and accommodation
Placement decisions consider lawful status, security requirements, individual risk, vulnerability, age, gender-related needs, health, disability, family ties, proximity to court, rehabilitation needs and available capacity, subject to applicable law and safeguards.

The system distinguishes:
- Security classification.
- Individual risk assessment.
- Safeguarding or vulnerability assessment.
- Healthcare needs.
- Behavioural or support needs.
- Accommodation compatibility.
- Temporary separation or protective placement.
- Facility and unit capacity.

No single score automatically determines placement, privileges, discipline or release. Assessments identify their author, method, evidence, uncertainty, review date and any contested information. A person may challenge a decision through the defined process.

Placement changes record the decision-maker, reasons, legal basis, receiving location, transfer arrangements, notification and review. Segregation or restrictive accommodation is exceptional, legally governed, time-limited and subject to frequent independent review and healthcare monitoring where required.

### Daily custody, dignity and basic conditions
Correctional institutions provide safe and humane accommodation, food, drinking water, sanitation, clothing, bedding, exercise, religious or cultural accommodation where legally protected, access to communication, education and other basic services.

The simulation models:
- Cell and unit occupancy.
- Daily routines and movement.
- Meals and dietary needs.
- Hygiene, laundry and sanitation.
- Exercise and outdoor access.
- Education, work and purposeful activity.
- Visits and communications.
- Access to legal representatives and courts.
- Accessibility and reasonable adjustments.
- Environmental conditions and facility maintenance.
- Staff and resident interactions.
- Safety incidents and service interruptions.

Capacity is based on approved safe occupancy rather than a simple game statistic. Overcrowding generates operational and safeguarding consequences and must not be resolved by silently exceeding legal or safety limits. Essential services cannot be withdrawn as informal punishment.

### Health, welfare and safeguarding
Correctional healthcare must be clinically independent in decisions about diagnosis and treatment, while coordinating safely with institutional operations. The system supports initial screening, routine care, urgent response, mental health, disability support, medication, specialist referral, hospital transfer, continuity of treatment and discharge planning.

Healthcare records are held with strict confidentiality and role-based access. Correctional staff receive only the information necessary for lawful safety and care functions. Medical diagnoses or disclosures must not be used as punishment, informal intelligence or a substitute for a proper risk assessment.

Safeguarding includes self-harm risk, suicide prevention, violence, exploitation, bullying, abuse, trafficking, coercion, vulnerability, age-related protection and risks arising from separation or placement. Staff record concerns, referrals, observations, interventions and reviews. A risk flag is not a finding of misconduct or guilt.

Serious injury, death, suspected abuse or other critical events trigger immediate safety measures, emergency healthcare and independent notification or investigation as required. Records preserve contemporaneous observations and must not be altered to protect institutional reputation.

### Use of force, restraints and restrictive measures
Any force or restraint is governed by the fictional law, necessity, proportionality, last-resort principles, competence, reporting and independent review. The system records the legal basis, circumstances, alternatives considered, authorising or supervising staff, type and duration, injuries, healthcare assessment, witnesses, recordings, notification and review.

Restraints, separation, restricted movement, searches and other intrusive measures have distinct legal bases and approval requirements. A measure cannot be justified solely by convenience, staff shortage, punishment or a person's complaint.

Every restrictive measure has a start time, responsible authority, reason, review schedule and termination event. Extensions require fresh lawful justification. The system must not automate force decisions or provide coercive action as a game shortcut.

### Security, searches and contraband
Facility security includes perimeter controls, controlled movement, access management, visitor procedures, prohibited-item controls, fire safety, emergency planning and incident response. Searches of persons, cells, property or visitors require the appropriate legal authority, policy, proportionality and safeguards.

Search records identify the subject or area, authorising role, grounds, scope, method, participants, date/time, results, items seized, property handling, complaints and review. Searches must respect privacy, dignity, protected characteristics and legal professional privilege as required by law.

Contraband is recorded with a unique property/evidence identifier and clear status. Items suspected to be evidence of a crime are transferred to the relevant investigative authority under BP-23 chain-of-custody rules. Correctional discovery does not automatically prove ownership, possession or guilt.

Security incidents include escape or attempted escape, violence, threats, prohibited items, property damage, fire, disorder, external attack, corruption, staff misconduct and system disruption. Each incident has its own record, command response, safeguarding measures, investigation and oversight route.

### Staff, professional competence and conduct
Correctional personnel include custodial officers, supervisors, managers, healthcare professionals, psychologists, educators, probation staff, social workers, chaplains or equivalent support roles, administrators, escorts and specialist response staff.

Personnel records distinguish rank, position, authority, qualification, clearance, training, assignment and supervision. Mandatory competence requirements apply to searches, restraint, emergency response, safeguarding, healthcare-related procedures, sentence calculation, case records and other regulated activities.

Staff conduct, conflicts of interest, corruption, inappropriate relationships, abuse, discrimination, retaliation, negligence and use of force are subject to reporting and independent investigation. Staff shortages affect safe capacity and operations but do not authorise unlawful shortcuts.

### Visits, communication and legal access
The system supports family and social visits, legal visits, professional visits, official visits, approved calls, correspondence and other communication permitted by law. Each category has distinct access rules, privacy protections, restrictions and recording requirements.

Legal communications receive special confidentiality protections. Monitoring, interception, restriction or suspension requires a specific legal basis and authorised decision; ordinary facility convenience is not sufficient. Restrictions are recorded with scope, reasons, duration, notice and review route.

Visit scheduling records visitor identity and authorisation, relationship or professional role where relevant, accessibility needs, location, duration, attendance and any incident. A visit restriction must not be imposed as an unrecorded or indefinite punishment.

### Family, dependants and external relationships
Where lawful and appropriate, correctional services support maintenance of family and community relationships, including child contact, parental responsibilities, dependent-care planning and notification of significant changes.

Information about family members and third parties is collected only for a defined lawful purpose and protected by access controls. Family relationships do not automatically establish risk, complicity or privileged status. Safeguarding concerns are referred through appropriate procedures without assuming guilt by association.

### Education, work and rehabilitation
Correctional plans may include literacy, education, vocational training, employment, behavioural programmes, substance-use treatment, mental-health support, restorative programmes and other evidence-informed services permitted by law.

Each programme records eligibility criteria, referral, consent where required, assessment, provider, attendance, progress, outcome and review. Participation is not represented as proof of remorse, guilt or rehabilitation, and refusal cannot trigger arbitrary punishment or automatic release consequences.

Work assignments must be safe, lawful and non-exploitative. Remuneration, deductions, training and workplace protections follow the applicable law. Educational and programme records are shared only where authorised and necessary.

### Individual sentence and resettlement planning
Each sentenced person may have a structured correctional plan linked to the judicial sentence and assessed needs. It identifies lawful objectives, responsible staff, programmes, health and support requirements, review dates and progress.

Plans must be individualised and distinguish court-imposed requirements from discretionary services. Staff cannot add punitive conditions or change sentence terms through a correctional plan.

Resettlement planning begins sufficiently before anticipated release, subject to legal and operational rules. It may address accommodation, identity documents, employment, education, healthcare continuity, family contact, benefits or lawful public support, supervision requirements and risk management.

### Discipline and internal adjudication
Alleged breaches of lawful institutional rules are handled through a fair, proportionate and reviewable disciplinary process. The system records the rule, alleged conduct, evidence, notice, opportunity to respond, representation or support where required, decision-maker, findings, reasons, sanction and appeal.

Disciplinary allegations are distinct from criminal offences and judicial convictions. A disciplinary finding does not automatically prove a criminal offence. Serious suspected criminal conduct is referred to the competent investigative authority while preserving independent evidence and the person's rights.

Sanctions must be lawful, defined, proportionate and time-limited. Collective punishment, retaliation, degrading treatment, arbitrary deprivation of essentials and unrecorded sanctions are prohibited by the design. Decision-makers must be impartial and conflicts declared.

### Temporary release, parole and conditional liberty
Where the legal framework permits temporary release, home leave, parole, conditional release or other early-release mechanisms, BP-29 manages eligibility checks and operational administration while preserving the independence of the competent decision-maker.

The workflow records:
- Legal basis and eligibility rule version.
- Sentence and time calculation.
- Risk, safeguarding and relevant reports.
- Victim or other statutory notification where required.
- Application and supporting material.
- Decision authority and reasons.
- Conditions, monitoring and responsible supervisor.
- Effective date, review and expiry.
- Variation, suspension, breach or revocation.

Eligibility does not create an entitlement unless the law provides it. A risk assessment is not a substitute for a lawful decision. Release conditions cannot exceed the authority granted by law or court order.

### Probation and community corrections
Community corrections may administer probation, community service, supervision, treatment requirements, electronic monitoring or other legally recognised non-custodial measures.

Each order records the issuing authority, legal basis, person, duration, requirements, reporting frequency, geographic or contact restrictions, responsible officer, provider and review route. The system distinguishes a court-imposed condition from a supervisory recommendation or voluntary support plan.

Supervision records include appointments, compliance, support, barriers, alleged breaches, verification, referrals and review. Non-compliance is assessed fairly and contextually; missed contact or technical failure is not automatically a deliberate breach. Any enforcement or return to court follows the legally prescribed process.

### Transfer, escort and external attendance
Transfers between facilities, hospitals, courts or other lawful destinations require a verified authority, sending and receiving institutions, risk assessment, transport plan, property and medication handover, escort assignment, departure/arrival times and acceptance.

The system records temporary transfer separately from change of legal custody or institutional responsibility. A receiving institution must acknowledge acceptance. Failed, diverted or interrupted transfers trigger a safe contingency and legal-status review.

Court attendance and hospital treatment must not cause the person to disappear from the authoritative correctional population or sentence calculation. The location, responsible authority and current legal status remain traceable.

### Release, discharge and recall
Release is authorised only after verifying the legal basis and all relevant active orders, warrants, detainers, sentences and restrictions. The release workflow records:
- Person and identity verification.
- Authorising instrument and competent decision-maker.
- Sentence calculation and release basis.
- Other active legal holds and their independent authority.
- Release date/time and responsible staff.
- Conditions, licence or supervision terms.
- Property, medication and documentation returned.
- Destination and safe transport where arranged.
- Notifications to authorised agencies and the person.
- Acknowledgement and post-release referrals.

A person must not be held beyond lawful authority because of administrative delay. Equally, a person must not be released in error where a separate valid legal authority applies. Conflicts are escalated immediately to the competent authority; the correctional service cannot invent or extend a hold.

Recall or return to custody requires a defined statutory or judicial basis, proper decision authority, notice and review. Alleged breach, new arrest or risk information does not automatically authorise recall. The record links the recall to the relevant order and preserves the previous release history.

### Death, serious harm and critical incidents
Deaths, life-threatening injuries, serious assaults, fires, escapes, major disorder, allegations of torture or abuse, and other critical events trigger emergency response and independent review as required.

The system records immediate notifications, scene preservation, healthcare response, witnesses, recordings, responsible staff, external agencies, family notification under lawful rules, coroner or equivalent referral, investigation and findings. The institution cannot control or rewrite an independent investigation.

A deceased person's correctional record is closed for operational purposes but retained under lawful records policy. Sentence status, legal proceedings and property disposition are updated by competent authorities.

### Complaints, rights and independent inspection
People in correctional care must have accessible routes to complain about treatment, safety, healthcare, discrimination, staff conduct, discipline, conditions and access to legal rights. Complaints may be internal or external, confidential where required, and protected from retaliation.

Each complaint has a reference, issue, date, recipient, confidentiality status, safeguarding assessment, investigator, response deadline, findings, remedy, appeal or referral and closure. Urgent risk is addressed immediately rather than waiting for the ordinary complaint process.

Independent inspections assess legality, safety, dignity, healthcare, conditions, use of force, segregation, access, records and outcomes. Reports, recommendations, management responses and implementation evidence remain separately attributable.

### Data, privacy and information sharing
Correctional records include legal status, sentence calculations, accommodation, health and welfare, visits, communications, programmes, incidents, discipline, supervision, release and complaints. Each data category has a lawful purpose, owner, access class, retention period and disclosure rule.

Health, legal communications, child-related information, victim data, protected witnesses and intelligence receive enhanced restrictions. Information sharing with police, prosecutors, courts, healthcare providers, probation and other agencies requires a lawful purpose and minimum necessary scope.

A correctional record is not an unrestricted intelligence source. Requests for information are logged, reviewed and disclosed through the authorised process. Corrections preserve provenance and prior versions. Records are retained or disposed of under approved schedules and legal holds.

### Player experience and authority
The player may interact with correctional systems only through their current role and legal authority. As a police officer, the player may verify custody transfer, provide lawful information, attend an authorised interview or court process, execute a valid warrant or coordinate a case-related request. The player does not control prison placement, internal discipline, sentence calculation, parole or release decisions.

If a separately defined career path later allows the player to serve in corrections, it requires its own recruitment, training, command, conflict, permissions and progression rules. Police rank does not confer correctional authority.

The interface displays legal status, authoritative orders, institution, admission and transfer events, sentence calculation status, welfare alerts subject to access rights, approved programmes, hearings, review dates, release eligibility, outstanding legal holds and handover confirmations. It distinguishes a projected date from an authorised release decision.

### Connections to other divisions
- **BP-05 to BP-09:** institutional structure, personnel, career, deployment and resources.
- **BP-11 and BP-12:** emergency communications and incident records.
- **BP-13 to BP-18:** offence, crime events, case, investigation, victims, witnesses and accused persons.
- **BP-19 to BP-24:** interviews, surveillance, intelligence, scenes, evidence and forensics.
- **BP-25:** arrest and warrants.
- **BP-26:** police custody, detention, welfare and pre-trial remand interfaces.
- **BP-27:** legal process, charging, disclosure, orders and procedural deadlines.
- **BP-28:** court decisions, verdicts, sentences, appeals and release-related orders.
- **BP-30 and BP-31:** governance, professional standards, complaints and independent oversight.
- **BP-32 to BP-34:** training, human resources, finance and procurement.
- **BP-35 to BP-37:** simulation processing, social relationships, time and scheduling.
- **BP-38 to BP-44:** authoritative records, persistence, interface, notifications, security, testing and configuration.

### Exceptions and edge cases
The design must handle defective or ambiguous order, wrong identity, multiple active orders, overlapping sentences, concurrent/consecutive calculation, appeal or stay, sentence quashed or varied, time-credit dispute, remand-to-sentence transition, transfer refusal, facility overcrowding, medical emergency, pregnancy or disability accommodation, child safeguarding, incompatible placement, protective separation, segregation review, missing medication, healthcare confidentiality, use-of-force complaint, death in custody, escape, attempted escape, contraband discovery, suspected crime by staff or resident, visitor restriction, legal visit confidentiality, interpreter failure, programme unavailability, disciplinary conflict, false allegation, missed probation appointment, technical monitoring failure, temporary release breach allegation, recall challenge, release calculation error, separate active warrant, missing property, cross-border transfer, data breach, records corruption and institutional emergency.

### Acceptance conditions
- Every admission and period of correctional control is supported by a verified legal authority.
- Remand, sentenced custody, other detention and community supervision remain distinct statuses.
- Sending and receiving authorities record formal handover and acceptance.
- Sentence calculations preserve source orders, rule versions, inputs, credits and correction history.
- Eligibility dates are not treated as automatic release authorisations.
- Placement and risk decisions are reasoned, reviewable and not determined by a single score.
- Basic conditions, healthcare, safeguarding, legal access and complaint routes are modelled.
- Health and privileged communications receive appropriate confidentiality.
- Searches, restraints, force, segregation and restrictive measures have distinct legal bases and audit trails.
- Staff competence, conduct and conflicts are recorded.
- Visits and communication restrictions are authorised, scoped and reviewable.
- Education, work and rehabilitation plans do not silently change judicial sentences.
- Discipline is fair, separate from criminal guilt and subject to review.
- Parole, temporary release and probation follow defined legal authority and decision roles.
- Transfers preserve location, legal status, property, medication and responsibility.
- Release verifies all active legal authorities and records formal discharge.
- Recall requires lawful authority and a reviewable decision.
- Deaths, serious harm, complaints and critical incidents trigger appropriate independent oversight.
- Data access, sharing, correction, retention and disposal are controlled and auditable.
- Police users cannot direct correctional decisions without specific lawful authority.
- No administrative error can lawfully extend detention or silently create a new legal basis.

**Draft status:** BP-29 is a working design. The correctional statute, institutional hierarchy, facility standards, remand arrangements, sentence calculation rules, prison regime, healthcare model, discipline code, use-of-force framework, parole and probation law, release/recall rules, independent inspectorate and retention periods remain open. No correctional institution, probation service or sentence-execution software has been implemented by this design document.

## BP-30 — Department Governance

### Purpose and scope
Define the governance architecture through which the national police service is lawfully directed, administered, held accountable and continuously improved. This division covers institutional mandate, command authority, decision rights, policy control, strategic planning, operational governance, risk management, internal assurance, performance oversight, audit, public accountability, inter-agency coordination and controlled institutional change.

BP-30 governs the police institution as a whole. It does not replace:
- BP-05 for police institutional structure, jurisdiction and command architecture.
- BP-06 to BP-09 for personnel, careers, units, deployment and resources.
- The linked specialist divisions BP-31 to BP-34 for professional standards, training, human resources and finance.
- BP-38 to BP-44 for authoritative records, persistence, interface, notifications, security, testing and configuration.
- BP-27 and BP-28 for independent legal and judicial authority.

Governance is not merely a hierarchy chart. Every material power, decision, policy, delegation, review and accountability relationship must have a defined owner, legal or organisational basis, scope, limits, record and route for challenge. Rank alone does not confer every decision right.

The fictional country's constitution, police statute, public-sector framework, oversight institutions and exact legal mandates remain to be specified. This document establishes design requirements, not binding law or implemented software.

### Governance principles
The police service operates under the following governing principles:
- Legality: every police power and institutional action has a lawful basis and remains within its scope.
- Public service: policing is directed toward public safety, prevention, lawful enforcement and protection of rights.
- Accountability: decisions and outcomes can be attributed, explained and reviewed.
- Integrity: conflicts, corruption, dishonesty, abuse and improper influence are not tolerated.
- Independence of professional judgment: operational decisions are not manipulated to achieve political, financial or personal objectives.
- Proportionality and necessity: interventions are appropriate to the lawful purpose and circumstances.
- Fairness and equality: policies and decisions must not discriminate unlawfully or produce unjustified unequal treatment.
- Transparency: institutional information is published where lawful, with justified protection for confidential material.
- Evidence-led management: policy and resource decisions use reliable information, uncertainty and limitations.
- Subsidiarity: decisions are taken at the lowest competent level unless risk, scale or law requires escalation.
- Separation of duties: incompatible powers and approval functions are appropriately separated.
- Continuous improvement: findings, incidents, audits and public feedback produce accountable corrective action.

### Governance instruments and hierarchy
The service maintains a controlled hierarchy of institutional instruments, subject to the country's legal framework:
- Constitution and applicable law.
- Statutory instruments and binding external directions.
- National policing strategy and approved institutional objectives.
- Governance charters and command delegations.
- Regulations, policies and formal standards.
- Operational doctrine and procedures.
- Local orders, instructions and approved plans.
- Training guidance, forms and reference material.

Each instrument has a unique identifier, title, owner, legal basis, approving authority, scope, version, effective date, review date, status, affected roles, dependencies and supersession history.

A lower-level instrument cannot override a higher-level law or policy. Conflicts are flagged and referred for competent legal and governance review. Informal custom, verbal direction or historical practice cannot silently amend a controlled instrument.

### Institutional mandate and strategic direction
The police service's mandate is derived from the fictional constitution and police statute. It must define:
- National and territorial jurisdiction.
- Core public protection and law-enforcement functions.
- Powers, duties and restrictions.
- Relationship with ministers, elected authorities and civil administration.
- Operational independence and lawful policy direction.
- National and regional command responsibilities.
- Cooperation with other public bodies.
- Public reporting and accountability obligations.
- Prohibited political, private or commercial uses of police authority.

A national strategy translates the mandate into time-bound priorities, outcomes, capabilities and resource assumptions. Strategic priorities are approved by the legally competent authority and reviewed at defined intervals. A change in government or leadership does not erase institutional records or automatically invalidate lawful ongoing operations.

The service must distinguish government policy direction from operational command. Political or administrative authorities cannot direct individual investigations, dictate arrests, suppress evidence or interfere with judicial decisions unless an express legal power permits a narrowly defined action.

### Governance bodies and decision forums
The institutional model may include:
- National Police Board or equivalent governing body.
- Police Commissioner/Chief and executive command group.
- National operational command forum.
- Regional and city command review forums.
- Specialist capability and policy boards.
- Risk and assurance committee.
- Finance, procurement and resource governance committee.
- Information governance and security board.
- Professional standards and integrity oversight forum.
- Training and workforce governance forum.
- Change-control and architecture board.

For each body, the design records its legal or administrative foundation, purpose, membership, chair, quorum, decision powers, advisory role, meeting frequency, records, conflicts process, escalation and reporting route.

A committee's existence does not confer statutory authority. It may advise, coordinate or approve only matters delegated to it. Decisions reserved to a chief officer, independent oversight body, minister, prosecutor or court remain with that authority.

### Command accountability and decision rights
Every significant institutional decision is associated with:
- Accountable decision owner.
- Relevant delegated authority and source.
- Scope and limits.
- Required consultation or approval.
- Decision deadline and urgency.
- Evidence and information considered.
- Risks, alternatives and proportionality.
- Decision, rationale and conditions.
- Implementation owner.
- Review or appeal route.
- Audit and retention requirements.

The system distinguishes command responsibility, line management, professional advice, operational tasking, statutory authorisation, financial approval and judicial authority. One person may hold several roles, but incompatible functions require safeguards and explicit separation.

Delegations identify the delegator, recipient, permitted decisions, restrictions, effective period, geographic or functional scope, sub-delegation rules, revocation and handover. A delegation cannot exceed the delegator's own authority. Absence or vacancy does not automatically transfer powers beyond a documented succession rule.

### Policy lifecycle and controlled publication
Every policy follows a managed lifecycle:
1. Need or issue identified.
2. Owner and sponsor assigned.
3. Legal, operational, human-rights, equality, privacy, security and resource impact assessed as relevant.
4. Stakeholders consulted where required.
5. Draft developed and versioned.
6. Competent authority approves or rejects.
7. Effective date and transition arrangements established.
8. Personnel and affected systems notified.
9. Training and implementation completed where necessary.
10. Compliance and outcome monitored.
11. Review, amendment, suspension or withdrawal recorded.

Policies must be accessible to the roles that need them, with controlled publication for restricted operational material. Drafts are not treated as effective policy. Emergency temporary instructions require a defined authority, scope, expiry, review and subsequent formalisation or cancellation.

### Risk management and institutional resilience
The service maintains an enterprise risk framework covering strategic, operational, legal, financial, workforce, safeguarding, integrity, information, technology, supplier, infrastructure and reputational risks.

Each risk record includes:
- Unique identity, category and owner.
- Cause, event and potential consequence.
- Affected objectives, people, locations and systems.
- Inherent and residual assessment method.
- Existing controls and control owner.
- Risk tolerance or escalation threshold.
- Treatment plan, deadline and resources.
- Monitoring indicators and review date.
- Acceptance authority and rationale.
- Incident, audit or assurance links.

Risk scores support prioritisation but do not replace professional judgment or statutory duties. A risk cannot be marked accepted by a person without the required authority. Critical risks and overdue controls are escalated through defined command and governance routes.

Business continuity plans cover loss of facilities, communications, personnel, vehicles, utilities, data, suppliers, cyber incidents, major emergencies and other disruptions. Plans identify essential functions, minimum safe staffing, alternate arrangements, command succession, recovery priorities, external dependencies, communication and testing. Continuity arrangements cannot suspend fundamental rights or create powers absent from law.

### Operational governance and command review
Operational activity is governed through the structures and procedures in BP-08 to BP-12 and other relevant divisions. BP-30 defines the institutional oversight requirements:
- Clear ownership and command for significant operations.
- Approval and review thresholds based on lawful authority and risk.
- Written objectives, scope, resources and constraints where required.
- Recording of key decisions, briefings and changes.
- Escalation of serious harm, critical incidents and cross-jurisdiction matters.
- Independent review where conflicts or exceptional powers arise.
- Post-operation debrief, learning and corrective action.

Operational command does not authorise unlawful investigative methods, searches, surveillance, detention or disclosure. The operational commander must verify that specialist statutory approvals and judicial orders are separately obtained where required.

### Performance management and public value
The service maintains a balanced performance framework covering public safety, response, service quality, investigation quality, case timeliness, victim and witness experience, safeguarding, workforce wellbeing, integrity, legality, training, resource stewardship and public confidence.

Indicators must have clear definitions, data sources, owners, calculation rules, limitations and review periods. Measures are interpreted in context and may be disaggregated where lawful and statistically responsible.

The framework must not reward arrest or charge volume as a proxy for success, encourage unlawful enforcement, pressure investigators to secure convictions, penalise lawful acquittals or suppress complaints. Targets must not distort professional judgment, under-reporting or public service.

Performance reviews distinguish activity, output, outcome, quality and long-term impact. Data quality and missingness are visible. Changes to definitions preserve historical comparability or explicitly document the break in series.

### Internal control and assurance
The service maintains a control framework for legal compliance, operational quality, financial stewardship, personnel administration, information security, evidence integrity, safeguarding, procurement and records.

Assurance may include:
- Management self-assessment.
- Supervisory review and sampling.
- Specialist professional inspection.
- Internal audit.
- Legal compliance review.
- Data and system controls testing.
- Independent external inspection.
- Public or legislative scrutiny where provided by law.

Each control has an owner, purpose, risk addressed, operating frequency, evidence, failure threshold, escalation and remediation route. Assurance reports identify scope, methodology, limitations, findings, severity, responsible owner and due dates.

A control is not deemed effective merely because a policy exists. Evidence of operation and outcome is required. Repeated failures trigger root-cause analysis and senior review.

### Audit, findings and corrective action
Audit and inspection findings are recorded with a persistent identifier, source, scope, evidence, classification, affected process, risk, responsible owner, management response, action plan, due date and verification method.

Corrective actions progress through assigned, in progress, blocked, implemented, independently verified and closed states. The owner cannot self-certify a high-risk corrective action where independent verification is required.

Overdue actions are escalated. Repeated or systemic failures are linked to institutional risk, policy review, training, staffing, procurement or technical remediation. Closure requires evidence that the control is effective, not merely that an action was performed.

### Public accountability and external oversight
The police service is subject to the legally established mechanisms of democratic and public accountability. These may include:
- Ministerial or parliamentary scrutiny within lawful limits.
- Independent police inspectorate.
- Police complaints and conduct authority.
- Ombudsman or public complaints commissioner.
- Human-rights or equality commission.
- Data protection and information regulator.
- Auditor-General or public accounts body.
- Coroner or equivalent death investigation authority.
- Courts and statutory tribunals.
- Community consultation and published performance reporting.

Each external body has a defined mandate, access powers, referral routes, independence safeguards and reporting relationship. The police service must cooperate with lawful oversight while protecting confidential, privileged and operationally sensitive information through the appropriate legal process.

Public reports distinguish verified findings, allegations, ongoing matters, statistical estimates and limitations. Personal information is not published without lawful authority. Transparency obligations cannot be used to expose protected victims, witnesses, informants or ongoing investigations improperly.

### Complaints, feedback and institutional learning
Public complaints, service concerns, commendations, staff concerns, whistleblowing and community feedback are captured through the appropriate specialist processes. BP-31 remains authoritative for professional misconduct and standards investigations; BP-30 ensures institutional themes and lessons are reviewed.

Feedback is categorised by issue, location, service, affected group and urgency. Serious allegations are referred immediately to the independent or specialist authority required by law. A complaint is not treated as proof of misconduct, and complaint volume alone is not treated as proof of poor performance.

Learning reviews examine system conditions, decision processes, supervision, training, resources, policy clarity and organisational culture. The aim is to correct failures and prevent recurrence while preserving individual accountability where justified.

### Inter-agency governance and partnerships
The service coordinates with prosecutors, courts, correctional institutions, emergency services, health services, local authorities, regulators, customs, immigration and other lawful partners.

Every partnership or information-sharing arrangement identifies:
- Legal basis and purpose.
- Parties and accountable senior owners.
- Scope of functions and decision boundaries.
- Information categories and permitted use.
- Security, confidentiality and retention.
- Financial and resource responsibilities.
- Service expectations and escalation.
- Dispute resolution and termination.
- Review date and performance measures.

Partnership agreements do not transfer statutory powers unless law expressly permits. Police remain accountable for their own decisions and records. External organisations remain accountable for decisions within their own mandates.

### Conflicts of interest, gifts and improper influence
The governance framework requires declaration and management of actual, potential and perceived conflicts affecting decisions, procurement, recruitment, investigations, promotion, discipline, external relationships and access to confidential information.

Records include the person, interest, affected matter, declaration date, assessment, mitigation, recusal or reassignment, approving authority and review. Gifts, hospitality, outside employment, political activity, financial interests and post-employment restrictions follow controlled policy and applicable law.

Attempts to influence an investigation, procurement, appointment, promotion, disciplinary matter or court process are recorded and referred through the appropriate integrity channel. Seniority, political office, commercial influence or personal relationships do not legitimise improper direction.

### Financial and resource governance
BP-34 is authoritative for budgets, accounting, procurement and financial controls. BP-30 sets the governance principles:
- Approved budget and delegated spending authority.
- Separation of request, approval, receipt and payment.
- Transparent procurement and conflict management.
- Asset ownership and lifecycle accountability.
- Emergency expenditure controls and retrospective review.
- Contract management and supplier risk.
- Fraud reporting and investigation.
- Audit trails and public reporting.

Operational urgency may justify a lawful emergency procurement route only where defined conditions are met. It does not authorise personal benefit, undocumented spending or bypass of required safeguards.

### Information, records and decision integrity
Governance decisions and policies are preserved in authoritative, versioned records under BP-38 and BP-39. Each record identifies its owner, source, author, approving authority, effective date, access class, retention and audit history.

Records include board and committee minutes, decisions, delegations, policies, risk registers, assurance reports, performance data, complaints themes, external recommendations and corrective actions.

Confidentiality and security controls must not be used to hide misconduct, evade audit or obstruct lawful oversight. Corrections are attributable and preserve prior versions. A governance decision cannot be silently rewritten after implementation.

### Emergency governance and exceptional authority
The framework defines how command and decision rights operate during major incidents, disasters, infrastructure failure, communications outage, cyber incident, public disorder or other emergency.

Emergency delegations must specify trigger, decision owner, permitted actions, geographic and functional scope, duration, notification, review and termination. Any exceptional legal power must be separately grounded in law and must not be created by a governance policy.

Where normal approval routes are unavailable, the system records the necessity, attempted contact, decision, alternatives, immediate safeguards and subsequent independent review. Emergency status cannot become a permanent route around ordinary controls.

### Governance of organisational change
Structural, policy, technology, service, jurisdictional and resource changes follow a controlled process. A change proposal records:
- Problem, purpose and expected benefit.
- Sponsor and accountable owner.
- Scope and affected divisions.
- Legal, operational, equality, privacy, safeguarding, security and financial impact.
- Dependencies and risks.
- Consultation and approvals.
- Implementation and transition plan.
- Training and communications.
- Testing and acceptance.
- Rollback or contingency plan.
- Post-implementation review and closure.

Changes to command authority, statutory powers, personnel rights, record definitions or legal procedures require heightened review and approval. No change may silently alter historical records or weaken an existing legal safeguard.

### Player experience and authority
The player experiences governance through lawful command instructions, policies, approvals, supervision, performance reviews, audits, risk controls, complaints and institutional decisions relevant to their role.

The player may propose improvements, report risks, declare conflicts, respond to audit findings and exercise delegated authority. The player cannot bypass policy approval, suppress oversight, change legal powers, direct independent investigations improperly or approve their own action where separation of duties is required.

The interface identifies current policies and versions, decision owners, delegations, approvals, risk status, required reviews, audit findings, corrective actions and escalation routes. It distinguishes mandatory rules from guidance and current policy from superseded drafts.

### Connections to other divisions
- **BP-01 to BP-05:** governing foundations, world, population, institutions and police mandate.
- **BP-06 to BP-09:** personnel, career, deployment, units and resources.
- **BP-10 to BP-16:** patrol, communications, incidents, crime, cases and investigations.
- **BP-17 to BP-24:** victims, suspects, interviews, surveillance, intelligence, scenes, evidence and forensics.
- **BP-25 to BP-29:** arrest, custody, legal process, courts and corrections.
- **BP-31:** professional standards, complaints, misconduct and integrity.
- **BP-32:** training and organisational competence.
- **BP-33:** human resources and workforce governance.
- **BP-34:** finance, procurement and resource stewardship.
- **BP-35 to BP-37:** simulation engine, social context, time and scheduling.
- **BP-38 to BP-44:** records, persistence, interface, notifications, security, quality assurance and configuration.

### Exceptions and edge cases
The design must handle conflicting legal and policy instruments, expired delegations, absent commander, vacancy, command succession, dual-role conflicts, emergency approval, political interference, improper operational direction, committee without quorum, disputed decision authority, urgent policy, policy withdrawal, unrecorded verbal instruction, critical risk escalation, inaccurate performance data, perverse incentives, audit obstruction, repeated overdue actions, independent oversight request, privileged material, data breach, public disclosure dispute, whistleblower retaliation, procurement conflict, emergency expenditure, partner agency refusal, inter-jurisdiction dispute, institutional restructuring, system outage, record corruption and retrospective policy correction.

### Acceptance conditions
- Every governance body, decision right and delegation has a defined legal or organisational basis.
- Rank, position, command responsibility, statutory authority and financial approval remain distinct.
- Delegations are scoped, time-bound, revocable and auditable.
- Policy instruments have owners, versions, approval, effective dates and review history.
- Strategic direction does not permit improper interference in individual investigations or judicial decisions.
- Enterprise risks have accountable owners, controls, treatment and escalation.
- Performance measures do not reward unlawful enforcement or penalise lawful outcomes.
- Assurance tests whether controls operate, not merely whether policy documents exist.
- Audit findings and corrective actions are tracked to independent verification where required.
- Public and independent oversight functions remain institutionally protected.
- Complaints, feedback and whistleblowing are handled through proper specialist routes.
- Inter-agency agreements do not silently transfer statutory powers.
- Conflicts, gifts and improper influence are declared, assessed and managed.
- Financial and procurement controls preserve separation of duties.
- Governance records are authoritative, versioned, access-controlled and auditable.
- Emergency delegations are lawful, limited, time-bound and reviewed.
- Organisational changes receive impact assessment, approval, testing and post-implementation review.
- The player cannot exercise powers beyond their role or bypass required approval and oversight.

**Draft status:** BP-30 is a working design. The police statute, executive and board model, oversight institutions, ministerial relationship, delegation schedule, public reporting obligations, audit mandates, risk appetite, policy hierarchy and exact governance authorities remain open. No governance board, audit, policy-control or performance-management software has been implemented by this design document.

## BP-31 — Professional Standards

### Purpose and scope
Define the professional conduct, integrity, ethics, complaint-handling, misconduct, discipline, intervention, accountability and learning framework for the national police service. This division establishes the standards expected of every person exercising police authority or performing police service functions, the mechanisms for identifying and addressing conduct concerns, and the safeguards that ensure fair, independent and proportionate handling.

BP-31 covers:
- Professional values, ethics and conduct obligations.
- Standards of behaviour and service.
- Misconduct, serious misconduct and criminal conduct distinctions.
- Complaints from the public and internal reporting.
- Whistleblowing and protection against retaliation.
- Early intervention and supervisory concern management.
- Professional standards investigations and evidence.
- Suspension, restriction, reassignment and other interim safeguards.
- Disciplinary proceedings, outcomes, review and appeal.
- Corruption, abuse of authority, discrimination, harassment and improper relationships.
- Use-of-force conduct review and serious incident referrals.
- Independent oversight, transparency, learning and record governance.

BP-31 does not replace:
- BP-05 for police structure, command and institutional jurisdiction.
- BP-06 and BP-07 for personnel identity, employment and career administration.
- BP-19 for the conduct and recording of investigative interviews.
- BP-25 and BP-26 for arrest, warrants and custody processes.
- BP-27 and BP-28 for legal proceedings and judicial outcomes.
- BP-30 for institutional governance, audit and enterprise accountability.
- BP-32 for training and professional development.
- BP-33 for human resources and employment administration.
- BP-38 and BP-39 for authoritative records and persistence.

Professional standards must not be reduced to a simple misconduct score or an automatic disciplinary engine. Allegations are not findings. Complaints are not proof. A criminal investigation, employment process and professional standards investigation may overlap, but each has its own legal purpose, decision-maker, safeguards and outcome.

The fictional country's police statute, employment law, criminal law, human-rights framework, independent complaints authority, disciplinary code and exact appeal rights remain to be defined. This division sets the architecture and design requirements, not binding legal thresholds or implemented procedures.

### Foundational professional principles
Every police employee and person exercising police functions is expected to:
- Act lawfully and within the authority of their role.
- Protect life, safety, dignity and fundamental rights.
- Exercise powers only for legitimate policing purposes.
- Treat people fairly, respectfully and without unlawful discrimination.
- Be honest, truthful and accurate in statements, records and testimony.
- Preserve evidence and disclose relevant material through lawful processes.
- Respect confidentiality, privacy and information security.
- Avoid corruption, bribery, favouritism and personal benefit from office.
- Declare and manage conflicts of interest.
- Use force and intrusive powers only when lawful, necessary and proportionate.
- Follow valid policy and lawful orders, while refusing or reporting unlawful instructions.
- Cooperate with lawful scrutiny, audit and investigations.
- Take responsibility for decisions, omissions and professional conduct.
- Intervene or report when witnessing serious misconduct or risk of harm.
- Maintain competence and seek guidance where authority or knowledge is insufficient.

These principles apply on duty, in professional dealings and in relevant off-duty conduct where a genuine connection to police integrity, public trust, safety or fitness for role exists. Off-duty scrutiny must remain lawful, proportionate and respectful of private life.

### Scope of persons covered
The standards framework applies, as appropriate to their status and legal authority, to:
- Sworn police officers of every rank and appointment.
- Recruits, probationers and trainees.
- Civilian police employees.
- Temporary, seconded and contract personnel performing police functions.
- Specialist personnel exercising delegated police powers.
- Volunteers or auxiliary personnel where formally authorised.
- Former employees in relation to conduct during service or continuing legal obligations.

Different employment and legal regimes may require distinct procedures. The system records each person's status, applicable code, authority, supervisor, service dates and procedural protections. A contractor is not treated as a sworn officer merely because they work in a police facility. A former employee remains subject to lawful investigation of conduct during service where jurisdiction persists.

### Standards instruments and conduct framework
The service maintains a controlled professional standards framework comprising:
- Code of ethics and professional values.
- Standards of professional behaviour.
- Rules on honesty, integrity and disclosure.
- Rules on use of police powers and authority.
- Respect, equality, dignity and non-discrimination standards.
- Confidentiality, privacy and information-handling rules.
- Conflicts, gifts, hospitality and outside interests policy.
- Rules on relationships, contact and boundaries.
- Social media, public communication and political activity standards.
- Appearance, attendance, readiness and fitness-for-duty requirements.
- Duty to report, intervene and preserve information.
- Standards for supervisory conduct and command responsibility.
- Misconduct and disciplinary procedures.
- Complaint, whistleblowing and investigation procedures.

Each instrument has a unique identifier, owner, approving authority, version, effective date, review date, affected roles, legal basis, training requirements and supersession history. Draft guidance is not treated as binding policy. No local instruction may weaken a statutory right or contradict the higher-level code.

### Categories of conduct concern
The system distinguishes concerns by nature and seriousness, without treating initial classification as a finding. Categories may include:
- Service or performance concern.
- Minor conduct concern.
- Misconduct.
- Serious misconduct or gross misconduct.
- Criminal allegation.
- Corruption or abuse of public office.
- Discrimination, harassment or victimisation.
- Sexual misconduct or inappropriate relationship.
- Abuse of authority or unlawful exercise of powers.
- Dishonesty, falsification or misleading statements.
- Evidence interference, concealment or disclosure failure.
- Confidentiality or data misuse.
- Neglect of duty or failure to intervene.
- Unprofessional treatment of the public, victims, witnesses or colleagues.
- Unsafe practice or reckless disregard of risk.
- Breach of financial, procurement or asset controls.
- Supervisory or command failure.
- Retaliation against complainants, witnesses or whistleblowers.

A concern may involve more than one category and may change as reliable facts emerge. Classification determines routing and safeguards, not guilt or a predetermined outcome.

### Complaints and concern intake
Complaints may be received from:
- Members of the public.
- Victims, witnesses, suspects, detainees and their representatives.
- Family members or other affected persons where permitted.
- Police employees and supervisors.
- Partner agencies and professional bodies.
- Courts, prosecutors, inspectors and statutory authorities.
- Anonymous or confidential sources.
- Whistleblowers acting internally or externally.

Intake channels may include in-person reporting, telephone, written correspondence, secure digital submission, formal referral and legally required notification. Access must be reasonable for people with disabilities, language needs, limited literacy or restricted access to digital services.

Every complaint or concern receives a persistent reference and records:
- Date/time and method received.
- Complainant identity and safe contact preferences, where provided.
- Whether anonymity or confidentiality is requested.
- Person or unit complained about, if known.
- Description of alleged conduct and relevant period/location.
- Immediate safety, safeguarding or retaliation risks.
- Supporting material and potential witnesses.
- Consent and legal restrictions relevant to contact or disclosure.
- Intake officer and receiving authority.
- Initial classification and reasons.
- Referral, acknowledgement and next communication date.

Anonymous reports are assessed on their information and risk; anonymity does not automatically invalidate or substantiate an allegation. A complainant's request for confidentiality is respected as far as lawful, but absolute secrecy must not be promised where fair process or legal duties require disclosure.

### Triage, referral and jurisdiction
Each incoming matter is triaged by an appropriately authorised person or body. Triage considers:
- Immediate danger or ongoing harm.
- Alleged criminality, corruption or serious abuse.
- Vulnerability of complainant, affected person or witness.
- Risk of evidence loss, interference or retaliation.
- Conflict of interest or seniority of the subject.
- Need for independent investigation.
- Relevant limitation periods and procedural deadlines.
- Employment, criminal, civil, regulatory or safeguarding jurisdiction.
- Related cases, complaints or previous findings.

Possible routes include service recovery, management action, early intervention, formal professional standards investigation, criminal investigation, independent complaints authority, safeguarding referral, employment process or external regulator.

Referral does not imply that an allegation is true. A matter may have parallel routes where lawful, with separate records, authority, evidence access and decision-making. The receiving body must acknowledge acceptance or explain refusal and identify the correct alternative route. No complaint may be silently closed because it is inconvenient or involves a senior officer.

### Independence, conflicts and external referral
Professional standards investigations must be impartial and protected from improper influence. Independence safeguards apply where:
- The subject is senior to the proposed investigator or decision-maker.
- The allegation concerns a command team or specialist unit.
- The investigator has a personal, financial, professional or operational conflict.
- The allegation concerns corruption, serious violence, death, sexual misconduct or serious rights violations.
- A complainant or witness has a reasonable concern about local handling.
- Law or oversight rules require external investigation.

The system records conflict declarations, assessment, recusal, investigator appointment, oversight conditions and any transfer of jurisdiction. A commander cannot select an investigator to guarantee a preferred outcome. A subject's rank, influence, reputation or performance history cannot justify a lower standard of scrutiny.

Independent bodies retain their own statutory decision rights. Internal police staff must not direct their findings, restrict lawful access or pre-approve their conclusions. Where the police retain a parallel internal process, safeguards prevent interference with external investigations.

### Early intervention and supervisory action
Not every concern requires formal discipline. A proportionate early-intervention framework may address emerging patterns, support needs, minor performance issues, training gaps, workload, wellbeing or policy misunderstanding.

Possible measures include:
- Private supervisory discussion.
- Clarification of policy or role expectations.
- Coaching and mentoring.
- Refresher or remedial training.
- Additional supervision or quality checks.
- Workload or deployment review.
- Occupational health or wellbeing referral where appropriate.
- Voluntary service improvement plan.
- Formal referral where facts indicate a more serious matter.

Early intervention is not a hidden disciplinary finding. The system records its purpose, factual basis, support offered, employee response, agreed actions and review date, with appropriate privacy and retention limits. Repeated concerns may justify formal review, but pattern analysis must consider context, source reliability and whether previous reports were substantiated.

A serious allegation cannot be diverted to informal coaching merely to avoid statutory notification or independent scrutiny. Support for an employee does not replace protection for affected members of the public.

### Professional standards investigation
A formal investigation is opened only by a competent authority and records:
- Case identifier and jurisdiction.
- Allegation or allegations, separately stated.
- Applicable standards and potential breaches.
- Subject and affected persons, with identity uncertainty preserved.
- Investigating authority and assigned investigator.
- Independence and conflict assessment.
- Investigation plan, scope and proportionality.
- Potential criminal, employment and external proceedings.
- Legal advice and procedural safeguards.
- Evidence preservation and disclosure responsibilities.
- Expected review dates and procedural deadlines.

The investigation tests the allegation fairly. It gathers inculpatory, exculpatory and contextual material, including evidence that may undermine the allegation or support the subject's account. It must not begin with a predetermined conclusion.

Investigators may obtain relevant records, policies, duty rosters, dispatch records, body-worn video, custody logs, communications, financial records, training records and witness accounts only through lawful authority and appropriate access. Evidence is handled under BP-23 and forensic work under BP-24. Criminal investigative techniques and intrusive powers remain governed by the relevant specialist divisions and legal framework.

### Evidence, disclosure and investigative integrity
Professional standards evidence may include:
- Original complaints and contemporaneous notes.
- Witness and subject accounts.
- Duty, deployment and supervision records.
- Communications and dispatch material.
- Body-worn video and other recordings.
- Policies, training and competence records.
- Relevant case, custody and evidence records.
- Financial, procurement or access logs.
- Digital records and system audit trails.
- Expert or specialist reports.
- Material supporting or contradicting the allegation.

Originals, copies, extracts and working notes are distinguished. Provenance, collection authority, date/time, handling, access and integrity are recorded. The investigator must not edit, selectively omit or misrepresent source material.

Potentially exculpatory, contradictory, unused or credibility-relevant material is identified and retained under the applicable rules. Disclosure obligations are assessed separately for criminal proceedings, disciplinary hearings, civil claims and external oversight. The system records disclosure decisions, reasons, recipients, redactions, restrictions and review.

A subject must have a fair opportunity to understand and answer the case, subject to lawful restrictions protecting witnesses, ongoing investigations, security and privacy. Confidentiality cannot be used as a blanket reason to withhold material required for a fair hearing.

### Subject rights and procedural fairness
The person subject to an allegation is treated fairly and without presumption of guilt. Depending on the applicable legal and employment framework, safeguards may include:
- Clear notice of the allegation and applicable standard.
- Information about the process and potential outcomes.
- Access to representation, advice or a staff association.
- Reasonable opportunity to respond and provide material.
- Interpretation or accessibility support.
- Impartial investigator and decision-maker.
- Protection against unnecessary public identification.
- Reasonable time to prepare.
- Access to relevant material subject to lawful restrictions.
- A reasoned decision and applicable review or appeal.
- Protection against retaliation for exercising procedural rights.

The system distinguishes a person being named in a complaint, notified as a subject, formally investigated, charged with a criminal offence, subject to a disciplinary allegation, found to have breached a standard and convicted by a court. These statuses are not interchangeable.

A subject's silence, request for representation or exercise of a legal right is not automatically evidence of misconduct. No confession or admission is presumed. Any interview is conducted under the applicable legal and procedural rules and recorded accurately.

### Interim safeguards and duty status
Where necessary to protect people, evidence, operations or the integrity of an investigation, the competent authority may consider interim measures under applicable law and employment rules. These may include:
- Temporary reassignment.
- Restriction from a particular duty or system.
- Change of reporting line.
- Additional supervision.
- Temporary removal from public-facing or sensitive functions.
- Suspension where legally justified.
- Preservation of access logs and relevant records.
- Contact or non-interference directions where authorised.

An interim measure is precautionary, not a finding or punishment. The record identifies the risk, legal basis, alternatives, decision-maker, scope, pay or employment consequences where relevant, start date, review date and conditions for ending or varying the measure.

Measures must be necessary, proportionate, time-limited and reviewed. They must not be used to punish a complainant or subject before a finding. Suspension is not automatic when an allegation is serious. The subject's welfare, reputation, livelihood and fair-trial interests are considered alongside public protection and evidence integrity.

### Criminal investigations and parallel proceedings
Where conduct may constitute a criminal offence, the matter is referred to the competent criminal investigative authority and prosecutor under the applicable law. The professional standards process remains distinct.

Parallel proceedings require a coordination protocol addressing:
- Which authority leads each process.
- Evidence ownership and access.
- Interview sequencing and legal cautions.
- Disclosure and privilege.
- Risk of prejudice to criminal proceedings.
- Suspension, continuation or sequencing of disciplinary steps.
- Limitation periods and statutory deadlines.
- Communications to the subject and complainant.
- Independent oversight and review.

A criminal investigation does not automatically establish professional misconduct. A criminal acquittal does not necessarily resolve a distinct employment standard, but the disciplinary decision must respect the facts and legal findings that are binding or relevant under the law. A criminal conviction may be relevant but does not remove the need for a lawful employment decision and proper process.

No internal investigator may obstruct a criminal investigation, pressure a prosecutor, alter evidence or promise a particular charging outcome. No criminal investigator may use the professional standards process as an informal route around legal safeguards.

### Interviews, statements and witness protection
Interviews of complainants, witnesses and subjects are planned and conducted under the appropriate legal and procedural rules. Records identify interviewer, participants, date/time, location or medium, purpose, rights and notices given, recording method, breaks, exhibits and outcome.

Witnesses receive appropriate safeguarding and protection from intimidation or retaliation. Their identities and contact details are restricted where lawful. Anonymous or protected evidence is handled under applicable fairness and disclosure rules; it is not treated as automatically reliable.

Subject interviews must not be coercive or misleading. Any admission is assessed in context and corroborated where appropriate. Interview records preserve the questions, answers, interruptions, corrections and any material deviation from procedure.

### Disciplinary decision and standard of proof
A disciplinary matter is determined by an impartial person or panel with authority under the applicable code. The decision-maker must not have investigated the allegation or have a material conflict, except where law expressly provides otherwise with safeguards.

The process records:
- Formal allegation and applicable standard.
- Notice and service of documents.
- Hearing date, participants and representation.
- Admitted, disputed and excluded material.
- Procedural applications and rulings.
- Findings on each allegation.
- Applicable standard of proof as defined by law or policy.
- Reasons and treatment of conflicting evidence.
- Mitigating and aggravating factors where relevant.
- Outcome and sanction, if any.
- Appeal or review rights and deadlines.

Each allegation is decided separately. Findings may include substantiated, not substantiated, unfounded, unable to determine, withdrawn, outside jurisdiction or referred elsewhere, subject to the approved legal vocabulary. A not-substantiated outcome does not automatically mean the complainant acted dishonestly. A malicious complaint finding requires its own evidence and process.

### Disciplinary outcomes and proportionality
Where a breach is established, possible outcomes may include:
- No disciplinary action or formal exoneration.
- Advice or management instruction.
- Formal warning.
- Written reprimand.
- Required training or supervised practice.
- Restriction of specified duties or authority.
- Demotion or change of appointment where lawfully available.
- Financial or employment sanction where authorised.
- Dismissal or removal from service.
- Referral to a professional regulator or other competent body.

The available outcomes and thresholds depend on the fictional legal and employment framework. Decisions consider seriousness, harm, culpability, intent, recklessness, repetition, role, training, context, mitigation, consistency and relevant prior substantiated findings.

Prior complaints that were unsubstantiated or unrelated cannot be treated as proof of propensity. A sanction must not exceed the decision-maker's authority. Reasons must explain why the outcome is lawful and proportionate. A disciplinary sanction does not automatically determine criminal liability, civil liability or a court's view of evidence.

### Review, appeal and correction
The framework provides appropriate routes to challenge:
- Intake or jurisdiction decisions where review is available.
- Interim measures.
- Procedural rulings.
- Findings and sanctions.
- Delays or failure to follow required process.
- Record accuracy and disclosure decisions.
- Conflicts or alleged bias.

The review authority, grounds, filing period, available remedies and whether the original decision is stayed must be defined by law or policy. Reviewers must be sufficiently independent and must not simply repeat the original decision without examining the stated grounds.

Possible remedies include confirming, varying, setting aside or remitting a decision, ordering further investigation, correcting a record, changing an interim measure or referring a matter to another authority. Historical records remain intact and show the correction, reason and reviewing authority.

### Corruption, abuse and integrity threats
The professional standards framework must identify and respond to risks including:
- Bribery, extortion and improper payments.
- Theft, fraud and misuse of public assets.
- Favouritism, nepotism and improper influence.
- Protection of criminal activity or organised groups.
- Unauthorised disclosure or sale of information.
- Evidence tampering, fabrication or concealment.
- Abuse of arrest, search, detention or force powers.
- Misuse of surveillance or intelligence access.
- Improper relationships with suspects, witnesses or regulated businesses.
- Retaliation, intimidation and witness interference.
- Procurement and recruitment corruption.
- Unexplained conflicts or undisclosed financial interests.

Reports are routed to specialist or independent investigators according to risk and jurisdiction. Sensitive integrity information is restricted and protected from unauthorised access. The system must not expose confidential sources or whistleblowers through ordinary personnel screens.

### Discrimination, harassment and inappropriate conduct
The framework addresses unlawful discrimination, harassment, bullying, sexual harassment, victimisation, degrading treatment and inappropriate relationships involving colleagues or members of the public.

It records the alleged behaviour, context, affected persons, power imbalance, safeguarding needs, relevant policy and evidence. Reports are handled sensitively and without retaliation. Informal resolution is not imposed where serious misconduct, safety risk or legal duties require formal action.

The system distinguishes protected characteristics and relevant legal concepts from stereotypes or assumptions. Demographic data is collected and used only for lawful equality monitoring or other defined purposes with appropriate controls. It must not be used to infer misconduct or risk.

### Use of force and serious incident conduct review
Where an incident involves death, serious injury, firearm discharge, serious force, restraint, alleged assault, unlawful detention or other significant rights concern, the relevant operational and independent review requirements apply.

BP-31 ensures professional conduct concerns are identified and routed, but does not replace:
- Immediate medical response and incident command.
- Independent criminal investigation where required.
- Scene and evidence preservation.
- Judicial or coroner processes.
- Specialist use-of-force review.
- Employment and disciplinary safeguards.

The record distinguishes tactical or operational review, criminal investigation, professional standards investigation and final disciplinary finding. An officer's involvement in a serious incident does not itself establish misconduct. Equally, an operational debrief cannot substitute for an independent investigation where one is required.

### Supervisory and command responsibility
Professional standards apply to supervisors and commanders as well as individual officers. Potential concerns include:
- Failure to supervise or intervene.
- Improper orders or pressure.
- Suppression of complaints or evidence.
- Failure to report serious incidents.
- Retaliation or discriminatory treatment.
- Misuse of performance targets.
- Conflicts of interest.
- Neglect of staff welfare or competence.
- Repeated failure to implement known corrective actions.

Command responsibility is assessed using the actual authority, knowledge, duties, opportunity to act and relevant legal standard. A commander is not automatically liable for every subordinate act, and cannot avoid responsibility merely by delegating a task. The system records the chain of command, actual decisions, warnings, available resources and actions taken.

### Whistleblowing and protected disclosures
Employees and other eligible persons may report suspected wrongdoing, danger, legal breach, corruption, abuse or serious institutional failure through protected channels.

The system supports:
- Confidential or anonymous reporting where permitted.
- Direct reporting outside the subject's command chain.
- Referral to independent authorities.
- Safe contact preferences.
- Restricted identity and source information.
- Risk assessment for retaliation.
- Secure preservation of supporting material.
- Acknowledgement and progress updates where safe and lawful.
- Review of alleged retaliatory acts.

The organisation must not penalise, threaten, isolate, disadvantage or improperly investigate a person for making a protected disclosure. Knowingly false or malicious allegations may be addressed only through a separate fair process; inability to substantiate a report is not proof of bad faith.

### Public communication and transparency
The service provides clear information about complaint routes, expected stages, available support and independent review. Public statements about an individual matter require authorised review, legal basis and consideration of privacy, fair-trial rights, witness safety and ongoing proceedings.

Published statistics may include complaint volumes, categories, timeliness, outcomes, sanctions and systemic themes, subject to data quality and privacy protections. Definitions and reporting periods must be transparent. Figures must distinguish allegations, investigations, findings and criminal convictions.

Transparency reporting must not expose protected identities or imply guilt before a finding. Suppression of unfavourable statistics, misleading presentation or manipulation of categories is itself a governance concern.

### Professional learning and organisational improvement
Findings, complaints themes, audit results, serious incident reviews and external recommendations inform policy, supervision, training and institutional change.

Learning records identify:
- Source and verified finding.
- Systemic issue or individual competence gap.
- Affected roles and processes.
- Recommended action and accountable owner.
- Training or policy changes.
- Implementation deadline.
- Evidence of effectiveness.
- Review and closure authority.

Learning reviews do not replace individual accountability. Conversely, individual discipline alone is not a sufficient response to a systemic policy, staffing, training or technology failure.

### Records, confidentiality and retention
BP-31 maintains authoritative records for complaints, concerns, referrals, investigations, interim measures, interviews, evidence links, hearings, findings, sanctions, appeals, external oversight and learning.

Records distinguish:
- Raw allegation.
- Initial assessment.
- Investigation hypothesis.
- Evidence and source.
- Interim risk decision.
- Formal finding.
- Disciplinary outcome.
- Criminal or judicial outcome.
- Appeal or correction.
- Published or disclosed information.

Access is role-based and purpose-limited. Complainant, witness, whistleblower and subject information receive safeguards appropriate to their status. Sensitive allegations must not become unrestricted personnel gossip or informal intelligence.

Retention, review, deletion, legal holds and disclosure periods are governed by law and approved schedules. A correction never erases the original allegation or finding history. Access and changes are logged. Records cannot be destroyed to avoid accountability, nor retained indefinitely without lawful purpose.

### Player experience and authority
The player may be a complainant, witness, subject, supervisor, investigator, decision-maker or recipient of a professional standards direction only where their role and permissions permit. These roles must be separated when impartiality or law requires.

As an ordinary officer, the player can receive a complaint, preserve relevant material, report a concern, comply with a lawful request, respond to an allegation and participate in required training. The player cannot decide their own complaint, alter an investigation record, intimidate a witness, suppress a referral or access confidential files without a legitimate purpose.

If the player later holds an authorised professional standards role, that role requires defined appointment, training, independence, access, investigative authority, supervision and conflict controls. Rank alone does not grant access to every professional standards case.

The interface distinguishes allegation, triage, formal investigation, interim measure, hearing, finding, sanction, appeal and final status. It displays the responsible authority, next procedural milestone, permitted actions and access restrictions without exposing protected identities or prejudicing an outcome.

### Connections to other divisions
- **BP-01 to BP-05:** foundational rules, population, institutions, police structure and jurisdiction.
- **BP-06 and BP-07:** personnel records, employment status, career and service history.
- **BP-08 and BP-09:** units, deployment, supervision and resources.
- **BP-10 to BP-12:** patrol, communications and incident records.
- **BP-13 to BP-18:** offences, crime generation, cases, investigation, victims, witnesses, suspects and offenders.
- **BP-19 to BP-24:** interviews, surveillance, intelligence, crime scenes, evidence and forensics.
- **BP-25 and BP-26:** arrest, warrants and custody.
- **BP-27 and BP-28:** legal process, prosecution, courts and judicial outcomes.
- **BP-29:** correctional interfaces and post-conviction status.
- **BP-30:** institutional governance, risk, audit, public accountability and corrective action.
- **BP-32:** ethics, conduct, legal compliance and specialist professional training.
- **BP-33:** employment procedures, employee support and personnel administration.
- **BP-34:** financial integrity, procurement and asset controls.
- **BP-35 to BP-37:** simulation processing, relationships and time.
- **BP-38 to BP-44:** authoritative records, persistence, interface, notifications, security, testing and configuration.

### Exceptions and edge cases
The design must handle anonymous or maliciously fabricated reports, mistaken identity, duplicate complaints, conflicting accounts, unavailable witnesses, complainant withdrawal, vulnerable complainants, protected disclosures, retaliation, senior subject, investigator conflict, external jurisdiction, parallel criminal proceedings, limitation deadlines, subject retirement or resignation, death of a subject or complainant, disputed employment status, anonymous evidence, unreliable recording, missing or altered source material, disclosure disputes, legal privilege, interim suspension challenge, pay or welfare consequences, inconsistent prior outcomes, repeat unsubstantiated complaints, substantiated complaint without disciplinary breach, criminal acquittal with separate employment question, conviction subject to appeal, whistleblower identity exposure, data breach, media disclosure, public interest request, external inspector demand, command interference, emergency reassignment, policy change during investigation, and records correction after final decision.

### Acceptance conditions
- Every person covered by the framework has an identifiable applicable code and procedural status.
- Complaints and concerns receive persistent references, triage, ownership and traceable routing.
- Allegations are not treated as findings or proof of guilt.
- Serious, criminal, corrupt or conflicted matters are referred to competent independent authorities where required.
- Early intervention cannot conceal a matter requiring formal or external investigation.
- Investigations preserve inculpatory, exculpatory and contextual material.
- Evidence provenance, lawful access, disclosure and chain of custody are maintained.
- Subjects receive fair notice, opportunity to respond, impartial decision-making and applicable review rights.
- Interim measures are precautionary, lawful, proportionate, time-limited and reviewed.
- Parallel criminal and disciplinary proceedings remain distinct and coordinated without improper interference.
- Disciplinary findings are reasoned, allegation-specific and made under the defined standard.
- Sanctions are within authority, proportionate and appealable where provided.
- Complaints, whistleblowing and witnesses are protected from retaliation.
- Conflicts, corruption, discrimination, harassment and abuse are covered by explicit controls.
- Serious force and harm incidents receive the correct independent and specialist reviews.
- Supervisory responsibility is based on actual authority, duties, knowledge and conduct.
- Public reporting distinguishes allegations, findings, disciplinary outcomes and criminal convictions.
- Learning actions have owners, deadlines and evidence of effectiveness.
- Sensitive records are access-controlled, versioned, retained and disclosed lawfully.
- The player cannot investigate, decide or access a matter where role conflict or lack of authority prohibits it.

**Draft status:** BP-31 is a working design. The police code of ethics, conduct standards, misconduct definitions, complaints authority, independent investigation mandate, disciplinary standard of proof, hearing and appeal structure, employment-law interface, whistleblower protections, disclosure rules, retention periods and statutory deadlines remain open. No complaints authority, professional standards unit, disciplinary hearing system or conduct-investigation software has been implemented by this design document.

## BP-32 — Training and Development

### Purpose and scope
Define the national police service's learning, training, assessment, professional development, accreditation, competence assurance and training-governance architecture. The division ensures that every person is prepared and authorised for the duties they perform, maintains competence as law, policy, equipment and operational risks change, and provides fair, traceable routes for learning, reassessment and career development.

BP-32 covers:
- Training governance, strategy, standards and quality assurance.
- Recruit, probationary and initial professional training.
- Role-specific, unit-specific and specialist training.
- Mandatory, refresher and continuing professional development.
- Legal, ethical, human-rights and safeguarding education.
- Operational skills and safety-critical competence.
- Assessment, examination, practical evaluation and accreditation.
- Instructor, assessor and training-provider standards.
- Learning records, qualifications and competence status.
- Remedial learning, reassessment and return-to-duty requirements.
- Career development, mentoring and leadership preparation.
- Training needs analysis, evaluation and organisational learning.
- Training resources, facilities, equipment and scheduling.

BP-32 defines learning and competence controls; it does not itself appoint people, promote them, confer police powers or replace operational command. BP-06 and BP-07 retain personnel and career authority; BP-08 controls unit assignment and deployment; BP-30 controls institutional governance; BP-31 governs conduct and professional standards; BP-33 governs employment administration.

### Governing principles
The training system must be:
- Competency-based: successful attendance alone does not establish competence.
- Role-relevant: learning objectives match actual duties, authority and risk.
- Legally grounded: training reflects applicable law, policy and human-rights obligations.
- Evidence-led: methods and content are reviewed against operational experience and reliable evidence.
- Fair and accessible: reasonable adjustments and equitable access are provided.
- Proportionate: training burden reflects risk, complexity and role requirements.
- Traceable: completion, assessment, expiry and authorisation are recorded.
- Continuous: competence is maintained, refreshed and reassessed when required.
- Safe: practical exercises use controlled risk, qualified supervision and appropriate equipment.
- Independent where necessary: assessment decisions must not be improperly influenced by command, personal relationships or operational pressure.
- Adaptable: changes to law, policy, technology, tactics and identified risks trigger review.
- Honest: qualifications and competence status must never be fabricated, backdated or misrepresented.

No person is considered competent merely because they hold a rank, have served for a long period, attended a course or previously performed a task. Competence is specific to the defined skill, authority, environment and current validity period.

### Training governance and accountability
The service establishes a training governance structure with:
- A national training strategy and policy owner.
- A designated training authority responsible for standards and oversight.
- Training institutions, academies or approved providers.
- Specialist training schools or accredited partner providers where needed.
- Divisional and unit training coordinators.
- Qualified instructors, coaches, mentors and assessors.
- Independent quality assurance and moderation.
- A process for approving, reviewing, suspending and withdrawing courses or qualifications.

Each course or programme has a controlled specification: identifier, title, owner, purpose, target roles, prerequisites, learning outcomes, curriculum, duration, delivery mode, legal/policy references, instructor requirements, assessment method, pass criteria, reassessment rules, accessibility arrangements, safety plan, version, approval authority and review date.

A commander may identify a training need and release staff for learning, but cannot waive a statutory qualification or declare a person competent outside their authority. Training providers cannot grant operational powers unless the governing law and formal authorisation process permit it.

### Training lifecycle
The training lifecycle is:
1. Identify role, legal authority and required competency profile.
2. Assess existing qualifications, experience and current competence.
3. Identify gaps and prerequisites.
4. Assign an approved learning pathway.
5. Schedule and resource the learning.
6. Deliver instruction and supervised practice.
7. Assess knowledge, practical performance and judgement.
8. Record results and any limitations.
9. Authorise or withhold role-specific activity through the competent authority.
10. Monitor performance and maintain competence.
11. Refresh, reassess or suspend competence when required.
12. Review programme effectiveness and update content.

A course may be completed while a required assessment remains outstanding. A person who fails an assessment may have attended and completed instruction but must not be recorded as competent. Where only part of a course is passed, the record identifies each completed and outstanding module.

### Competency framework
The service maintains a competency framework linking roles and duties to:
- Knowledge: law, policy, procedures, systems and subject matter.
- Practical skills: safe and correct execution of tasks.
- Decision-making: judgement, proportionality, prioritisation and escalation.
- Communication: public interaction, teamwork, reporting and documentation.
- Professional behaviour: ethics, impartiality, respect and accountability.
- Risk awareness: safety, safeguarding, operational hazards and uncertainty.
- Supervision: oversight, coaching, review and intervention where relevant.

Competency statements use observable outcomes and defined performance standards. They specify whether a competency is introductory, supervised, independent, advanced, instructional or assessor-level. These levels describe competence, not police rank or statutory authority.

Competencies are mapped to positions, units, operational tasks, specialist appointments and system permissions. The map identifies mandatory requirements, desirable development, prerequisites, renewal periods and any restrictions when a competency is absent or expired.

### Recruit and initial training
Recruit training provides the foundation for lawful and professional police service. The programme includes, as applicable:
- Police mandate, institutional structure and accountability.
- Law, powers, limits, procedure and legal duties.
- Ethics, integrity, equality and human rights.
- Public service, communication and conflict management.
- Community engagement and cultural awareness.
- Safeguarding children and vulnerable people.
- Victim, witness and suspect rights.
- Crime reporting, incident recording and case fundamentals.
- Evidence preservation, continuity and disclosure.
- Interview principles and procedural safeguards.
- Patrol, observation, situational awareness and officer safety.
- Emergency response and communications.
- First aid and emergency care within approved scope.
- Arrest, search, detention and custody safeguards.
- Use-of-force law, de-escalation and practical safety.
- Information security, records and digital systems.
- Report writing, statement taking and court responsibilities.
- Professional standards, complaints and whistleblowing.
- Fitness and wellbeing requirements appropriate to the role.

The recruit pathway defines classroom learning, practical exercises, supervised field exposure, assessment gates, remedial options and final authorisation. Recruits do not exercise powers beyond those lawfully granted to their status. A recruit's access to operational systems and deployment is limited by training, supervision and permissions.

### Probation and field training
After initial academy learning, recruits may undertake a supervised field-training programme. It specifies:
- Approved field-training officers and supervisors.
- Minimum and maximum supervised exposure as defined by policy.
- Required operational experiences and learning objectives.
- Structured observation and coaching.
- Daily or periodic performance records.
- Safety and escalation rules.
- Assessment checkpoints and final recommendation.
- Remediation, extension or termination routes.
- Independence and moderation of final decisions.

A field-training officer records observed conduct and performance, not unsupported impressions. The recruit has an opportunity to comment on assessments and raise concerns about training quality or unfair treatment. A favourable field assessment does not override an unmet statutory or specialist requirement.

### Core and mandatory continuing training
The service defines mandatory training by role and risk. Possible subjects include:
- Legal and policy updates.
- Ethics and professional standards.
- Human rights and equality obligations.
- Safeguarding and victim care.
- Use of force, de-escalation and restraint.
- Firearms or other specialist equipment where authorised.
- First aid and emergency response.
- Arrest, search, custody and detainee welfare.
- Evidence, disclosure and case-file quality.
- Information governance and cybersecurity.
- Health, safety and operational risk.
- Emergency planning and incident command.
- Supervisor responsibilities and staff welfare.
- Anti-corruption and reporting obligations.

Each requirement defines its target population, trigger, delivery format, completion deadline, pass criteria, renewal or expiry rule, exemptions if legally permitted and consequences of non-completion. Mandatory training must be scheduled realistically and supported by staffing plans; operational demand cannot silently erase required training.

### Specialist and role-based pathways
Specialist pathways are designed around the actual functions and risks of the role. Examples may include:
- Criminal investigation and major crime.
- Forensic scene management and evidence handling.
- Intelligence analysis and source management.
- Surveillance and covert operations.
- Interviewing and specialist interviewing.
- Child protection and vulnerable-person investigations.
- Public order and crowd safety.
- Firearms and other high-risk operational roles.
- Roads policing and collision investigation.
- Marine, port, airport or border-related policing.
- Cybercrime and digital evidence.
- Financial investigation and asset recovery.
- Negotiation, crisis response and incident command.
- Custody, detention and detainee safeguarding.
- Professional standards investigation.
- Training instruction and assessment.
- Leadership, strategic command and organisational governance.

Specialist training has explicit prerequisites, legal authority, selection criteria, practical assessment, supervision, periodic revalidation and withdrawal conditions. Course completion does not itself appoint a person to a specialist unit or confer powers. Appointment, equipment issue and operational deployment remain separate decisions under the relevant divisions.

### Legal, ethical and procedural learning
All training pathways incorporate the law and safeguards relevant to their duties. The curriculum must address:
- Lawful authority and limits of police powers.
- Necessity, proportionality and reasonableness.
- Human dignity, equality and non-discrimination.
- Procedural fairness and rights of affected persons.
- Safeguarding and duty of care.
- Evidence integrity, disclosure and accurate records.
- Privacy, confidentiality and lawful information access.
- Conflicts of interest, gifts and improper influence.
- Duty to report misconduct and protect whistleblowers.
- Judicial independence and prosecution independence.
- Accountability, review and complaint mechanisms.

Legal content must identify its jurisdiction, source, effective date and approved interpretation. Where law changes, the training authority assesses which roles and existing qualifications are affected and issues an update or transitional requirement. Outdated materials must be withdrawn or clearly marked as superseded.

### Operational practical training and safety
Practical training is designed and delivered by competent instructors using approved lesson plans, risk assessments, safe facilities and appropriate equipment. It may include scenario-based exercises, role play, simulations, controlled tactical practice and supervised field demonstrations.

Safety controls include:
- Pre-exercise risk assessment and briefing.
- Participant suitability and reasonable adjustments.
- Qualified instructor-to-participant ratios.
- Equipment inspection and safe configuration.
- Medical and emergency arrangements.
- Clear stop-work and incident reporting procedures.
- Controlled scenario boundaries and safe training environments.
- Debriefing and support after distressing exercises.
- Recording of injuries, near misses and safety concerns.

Training scenarios must not normalise unlawful conduct, discriminatory assumptions, unnecessary force or disregard for rights. High-risk exercises require enhanced controls and authorisation. Training equipment and simulated weapons must be clearly distinguished from operational equipment and controlled to prevent unauthorised use.

### Assessment and qualification
Assessment methods are selected to match the competency. They may include:
- Written or online knowledge tests.
- Oral examination.
- Practical demonstration.
- Scenario-based decision exercises.
- Observed workplace performance.
- Case-file or report review.
- Portfolio or reflective evidence.
- Structured professional discussion.
- Simulation-based evaluation.

Each assessment defines learning outcomes, marking criteria, pass thresholds, critical errors, permitted assistance, assessor qualifications, moderation and record requirements. Safety-critical, rights-critical or legally mandated tasks may include non-compensable critical criteria: a candidate cannot offset a serious failure in a critical safeguard by scoring highly elsewhere.

Assessment outcomes distinguish:
- Not yet assessed.
- In progress.
- Passed.
- Passed with defined limitations, where policy permits.
- Failed.
- Deferred for an authorised reason.
- Withdrawn.
- Expired or lapsed.
- Suspended pending review.
- Revoked following a competent decision.

A qualification records its scope and limitations. It must not be represented as broader than the assessment supports. Assessment evidence and decision reasons are retained for audit and appeal.

### Failure, remediation and reassessment
A failed assessment triggers a documented process that identifies:
- Competency or module not achieved.
- Evidence and assessment criteria.
- Critical safety or legal concerns.
- Feedback provided.
- Candidate response or appeal.
- Remedial learning plan.
- Supervision or duty restrictions pending reassessment.
- Reassessment timing, method and assessor.
- Final outcome and any further route.

Remediation is designed to address the identified gap. Repeated failure may lead to further training, reassignment, delayed appointment, removal from a specialist function or employment review under the relevant authority. These consequences are not automatic and must follow fair procedures.

A failed assessment is not automatically misconduct. Deliberate dishonesty, refusal to comply with a lawful training requirement or falsification of results may be referred under BP-31, but poor performance alone must not be relabelled as misconduct to bypass capability processes.

### Competence currency and authorisation
The service distinguishes:
- Course attendance.
- Course completion.
- Qualification awarded.
- Competency currently valid.
- Role appointment.
- Operational authorisation.
- Permission to use a system, power or item of equipment.

A person may hold a qualification that has expired, be competent but not appointed, be appointed but temporarily restricted, or be authorised only under supervision. These states must be separately represented.

Competence currency rules specify renewal period, refresher requirements, evidence of practice, reassessment triggers and any grace period permitted by law. Where a required qualification expires or is suspended, the relevant operational activity is restricted until the competent authority confirms restoration. An emergency exception is permitted only if explicitly grounded in law and policy, with recorded justification and review; it must not become routine.

### Career development and leadership
Training supports career development without guaranteeing promotion or appointment. Development pathways may include:
- Individual development plans.
- Mentoring and coaching.
- Acting-role preparation.
- Supervisory and management programmes.
- Strategic leadership and command education.
- Specialist technical development.
- Cross-unit exposure and attachments.
- Accredited external study.
- Research, professional qualifications and secondments.

Development plans record aspirations, identified competencies, opportunities, agreed actions, support, progress and review dates. Access to development should be fair and transparent, subject to operational requirements and selection criteria. Completion of leadership training does not create a right to promotion or command authority.

### Instructor, assessor and provider quality
Instructors and assessors must hold appropriate subject competence, instructional preparation and any required accreditation. The framework defines:
- Selection and appointment criteria.
- Scope of instructional authority.
- Continuing instructor development.
- Assessment and moderation standards.
- Conflicts of interest and recusal.
- Performance review and learner feedback.
- Observation and quality assurance.
- Complaints and appeal handling.
- Suspension or withdrawal of instructor status.

A person should not assess their own work or make a final high-stakes decision where a conflict undermines impartiality. External providers must be approved, monitored and subject to contractual, security, data-protection and quality requirements. Outsourcing delivery does not transfer the police service's accountability for standards.

### Training needs analysis and organisational learning
Training needs are identified through:
- Role and competency changes.
- New legislation, policy or court decisions.
- Operational incidents and debriefs.
- Case-file quality and disclosure failures.
- Complaints and professional standards findings.
- Audit, inspection and external recommendations.
- Safety incidents and near misses.
- Technology, equipment and system changes.
- Workforce planning and succession needs.
- Community feedback and emerging crime patterns.

The training authority distinguishes an individual skill gap from a systemic failure caused by policy, resources, supervision, staffing, equipment or unclear authority. Training is not used as the default remedy for every organisational problem.

Each identified need records evidence, affected roles, risk, priority, proposed intervention, accountable owner, funding, delivery deadline and evaluation method. High-risk gaps may require immediate operational restrictions or temporary safeguards while learning is arranged.

### Evaluation and effectiveness
Training evaluation examines more than attendance and pass rates. It may assess:
- Knowledge retention.
- Practical competence and safe performance.
- Decision quality under realistic conditions.
- Consistency across instructors and cohorts.
- Transfer of learning to the workplace.
- Operational outcomes and avoidable errors.
- Public-facing service quality.
- Complaints, safety events and procedural failures.
- Cost, accessibility and delivery efficiency.

Evaluation must avoid simplistic causal claims. Changes in complaints or crime outcomes may have multiple causes. Findings are used to improve course design, delivery, assessment, supervision, policy or resources. Programmes with unsafe or ineffective outcomes may be paused, revised or withdrawn.

### Learning records and qualifications register
The authoritative training record links to the person's personnel record and contains:
- Person and employee identifier.
- Course, module and competency identifiers.
- Provider and delivery location or mode.
- Enrolment and attendance dates.
- Instructor and assessor identities.
- Assessment attempts and results.
- Evidence references and feedback.
- Qualification scope, conditions and expiry.
- Remedial actions and reassessment.
- Recognition of prior learning decisions.
- Exemptions and their legal or policy basis.
- Suspensions, restrictions and revocations.
- Appeals, corrections and audit history.

The record distinguishes a course certificate from the underlying evidence and current competence status. Corrections preserve provenance and prior versions. Access to sensitive assessment or welfare information is restricted by role and purpose.

### Recognition of prior learning and external qualifications
Prior service, civilian qualifications, military or emergency-service experience, professional credentials and external courses may be considered through a controlled recognition process.

Recognition requires:
- Identity and authenticity verification.
- Relevance to the required competency.
- Currency and evidence of recent practice.
- Comparison with the service's standards.
- Assessment of any gaps.
- Decision by an authorised reviewer.
- Recorded scope, limitations and expiry.

Recognition is not automatic based on title, rank, reputation or length of service. A foreign or external qualification may require local legal and policy modules, practical assessment or supervised practice. Statutory requirements cannot be waived by an informal equivalence decision.

### Scheduling, attendance and operational continuity
Training schedules must coordinate employee availability, shifts, leave, operational coverage, facilities, instructors, equipment and mandatory deadlines. The system supports cohorts, individual bookings, waitlists, cancellations, rescheduling and make-up sessions.

Attendance records distinguish present, late, partial attendance, excused absence, unexcused absence, withdrawal and provider cancellation. Attendance does not imply passing. A cancelled session does not count as a failure by the learner.

Operational commanders may request deferral only under an authorised process. Deferrals record reason, risk assessment, approving authority, revised deadline and any interim restrictions. Critical training cannot be indefinitely deferred through repeated operational exceptions.

### Accessibility, fairness and learner welfare
Training access and assessment consider disability, language, literacy, neurodiversity, religious or other lawful accommodation needs, pregnancy, caring responsibilities and other relevant circumstances. Reasonable adjustments preserve essential competency and safety requirements while changing the method or conditions where possible.

Learners must have access to clear materials, timely feedback, appropriate support and a safe route to raise concerns about discrimination, harassment, instructor conduct, unsafe exercises or unfair assessment. Confidential welfare information is not shared beyond a legitimate need.

The service monitors access, completion and outcomes for unjustified disparities, using lawful and appropriately protected data. Equality monitoring must not become profiling or a substitute for individual assessment.

### Training conduct and integrity
Training environments are governed by professional standards. Prohibited conduct includes:
- Cheating, plagiarism or impersonation.
- Fabricating attendance, assessment evidence or qualifications.
- Improper assistance or leaking examination materials.
- Bullying, harassment, discrimination or retaliation.
- Unsafe instruction or deliberate exposure to prohibited risk.
- Falsifying learner or instructor records.
- Undisclosed conflicts of interest.
- Misuse of training equipment or facilities.
- Pressuring assessors to pass an unqualified candidate.

Concerns are routed under BP-31 where appropriate. Learners and instructors receive fair treatment and an opportunity to respond. A disputed result remains clearly marked as under review and is not silently altered.

### Training resources and facilities
Training planning accounts for:
- Academy and classroom capacity.
- Practical training grounds and specialist facilities.
- Secure training systems and realistic simulation environments.
- Approved equipment, vehicles and protective equipment.
- Instructor and assessor capacity.
- Learning materials and accessibility formats.
- External provider contracts.
- Maintenance, safety inspections and emergency provision.
- Budget, procurement and asset controls.

Training resources are not assumed available merely because a course exists in the catalogue. The schedule must reflect actual capacity. Training facilities and equipment are governed under BP-09 and BP-34, with safety and access controls.

### Player experience and authority
The player can view assigned training, prerequisites, deadlines, results, current qualifications and development plans according to role. Depending on appointment, the player may enrol, attend, complete modules, take assessments, request feedback, submit evidence of prior learning, request review or provide training as an authorised instructor.

The player cannot self-certify competence, edit official results, bypass prerequisites, grant their own operational authorisation or use a specialist power solely because they completed a course. The interface must clearly show the difference between training progress, competence status, appointment and operational permission.

Training requirements should have meaningful gameplay consequences: unavailable specialist duties, supervised deployment, renewal deadlines, temporary restrictions, career opportunities and improved capability. These consequences must be transparent, consistent and tied to documented requirements rather than arbitrary hidden penalties.

### Connections to other divisions
- **BP-01 to BP-05:** governing rules, geography, population, organisations and police architecture.
- **BP-06 and BP-07:** personnel, service history, career pathways and promotion.
- **BP-08 and BP-09:** appointments, unit requirements, equipment and training resources.
- **BP-10 to BP-12:** patrol, dispatch, incident response and operational learning.
- **BP-13 to BP-24:** crime, investigation, victim care, interviewing, surveillance, intelligence, scenes, evidence and forensics.
- **BP-25 to BP-29:** powers, custody, legal process, courts and corrections.
- **BP-30 and BP-31:** governance, conduct standards, complaints and integrity findings.
- **BP-33:** employee administration, capability and welfare processes.
- **BP-34:** budgets, procurement and provider contracts.
- **BP-35 to BP-37:** simulation processing, social context and scheduling.
- **BP-38 to BP-44:** training records, persistence, interface, notifications, permissions, testing and configuration.

### Exceptions and edge cases
The design must handle recruit failure, partial course completion, assessment appeal, disputed assessor impartiality, instructor misconduct, expired qualification during an active shift, emergency operational demand, long-term absence, disability accommodation, language support, injury during practical training, course cancellation, provider failure, lost records, duplicate identities, external qualification fraud, unverifiable prior learning, law changing mid-course, urgent policy change, specialist skill decay, extended absence from specialist duties, temporary restriction, reassessment failure, staff transfer between units, promotion without required course, acting appointment, secondment, leave, retirement, resignation, death, training system outage, assessment misconduct, confidentiality breach, unfair access to development, and systemic training failure.

### Acceptance conditions
- Every role and operational task has an explicit competency and training profile.
- Every course has an approved specification, owner, version, outcomes and assessment rules.
- Recruit, probationary, core, specialist and leadership pathways are defined.
- Attendance, completion, assessment and competence are distinct states.
- Critical legal and safety requirements cannot be offset by unrelated assessment scores.
- Failed assessments trigger documented feedback, remediation and fair reassessment.
- Competence expiry or suspension can restrict relevant operational activity.
- Training completion does not itself confer rank, appointment, police powers or system permissions.
- Instructors, assessors and external providers are qualified, monitored and auditable.
- Prior learning and external qualifications require verification and authorised equivalence decisions.
- Mandatory training is scheduled and deferrals are controlled and reviewed.
- Training needs are linked to evidence and systemic causes are not mislabelled as individual failures.
- Training effectiveness is evaluated beyond attendance and pass rates.
- Learners receive reasonable adjustments, fair assessment and safe complaint channels.
- Training records are authoritative, access-controlled, versioned and auditable.
- Training misconduct and falsification are referred through fair professional standards procedures.
- Player access and actions respect role, competence, appointment and permission boundaries.

**Draft status:** BP-32 is a working design. The fictional police academy structure, statutory training requirements, competency catalogue, recruit duration, probation standards, assessment thresholds, specialist qualification rules, renewal periods, instructor accreditation, external provider standards, fitness requirements, reasonable-adjustment rules, training budget and formal authorisation matrix remain open. No academy, course catalogue, learning management system, assessment engine or operational competence registry has been implemented by this design document.

## BP-33 — Human Resources

### Purpose and scope
Define the police service's workforce administration and employee lifecycle framework. BP-33 governs how the organisation plans its workforce, recruits and appoints personnel, administers employment relationships, manages attendance and leave, supports employee welfare, handles capability and workplace matters, maintains employment records, and administers separation from service.

The division ensures that the service has the right people, lawful employment arrangements, clear responsibilities, consistent employee administration and reliable workforce information. It supports operational readiness without allowing staffing pressure to override employment rights, safety, due process or statutory requirements.

BP-33 covers:
- Workforce establishment, headcount and workforce planning.
- Recruitment administration and pre-employment checks.
- Appointment, onboarding and employment documentation.
- Employment status, terms, conditions and service history.
- Attendance, working time, shifts, overtime and rest.
- Leave, absence, sickness and return-to-work administration.
- Pay, allowances, benefits and employee entitlements interfaces.
- Employee relations, grievances and workplace dispute processes.
- Capability, performance support and improvement processes.
- Employee welfare, occupational health and workplace adjustments.
- Transfers, secondments, temporary assignments and acting arrangements.
- Promotion and appointment administration interfaces.
- Resignation, retirement, dismissal, death and other separation.
- Workforce records, reporting, confidentiality and audit.

BP-33 does not replace:
- BP-05 for institutional structure, command and organisational authority.
- BP-06 for authoritative personnel identity and personnel-record architecture.
- BP-07 for rank, grade, position, appointment and career progression rules.
- BP-08 for operational unit assignment and deployment authority.
- BP-30 for institutional governance and delegations.
- BP-31 for misconduct, professional standards and disciplinary findings.
- BP-32 for training, assessment and competence.
- BP-34 for budgets, payroll funding, procurement and financial controls.
- BP-38 and BP-39 for records governance, databases, persistence and recovery.

Employment administration, professional discipline, operational command and training competence are separate concepts. A personnel administrator cannot grant police powers, a commander cannot change an employee's contractual terms outside delegated authority, and an HR decision cannot rewrite an independent disciplinary or judicial finding.

### Foundational principles
The workforce framework is governed by:
- Lawful employment and respect for applicable labour and police-service law.
- Fairness, consistency, transparency and non-discrimination.
- Clear separation of employment status, rank, grade, position, appointment, authority and competence.
- Accurate and timely employee records.
- Proportionate use of personal information and restricted access.
- Documented decisions, delegated authority and auditability.
- Employee voice, representation and fair process.
- Health, safety, welfare and reasonable workplace adjustments.
- Operational resilience balanced with employee rights and wellbeing.
- Protection against retaliation, harassment and arbitrary treatment.
- Separation of allegations, capability concerns, disciplinary findings and criminal convictions.
- Continuity of employment administration when personnel transfer between units or locations.

No employee is treated as an interchangeable resource. Workforce planning must account for skills, experience, availability, welfare, lawful working-time limits, training commitments and operational risk.

### Workforce establishment and planning
The service maintains an approved establishment describing authorised organisational capacity. It identifies:
- Organisational unit and reporting structure.
- Approved positions and role profiles.
- Required rank, grade or employment classification.
- Required qualifications and competencies.
- Authorised headcount or funded full-time-equivalent capacity.
- Location and jurisdiction.
- Funding source and cost centre.
- Vacancy, occupied, temporarily filled or frozen status.
- Approval authority and review date.

Workforce planning considers service demand, population and geographic coverage, incident patterns, leave, sickness, training, retirements, turnover, specialist capability, succession, diversity, recruitment lead times and budget.

The system distinguishes authorised establishment, actual headcount, active employees, temporary staff, vacancies, funded posts and people currently available for deployment. A person on leave, training, suspension or secondment remains part of the relevant workforce count but may not be operationally available.

Changes to establishment require approval under BP-30 and funding validation under BP-34. An operational commander may identify a staffing need but cannot unilaterally create a permanent post or bypass establishment controls.

### Recruitment administration and selection
Recruitment is conducted against an approved vacancy and role profile. The process may include:
- Vacancy justification and authorisation.
- Public or internal advertisement.
- Candidate application and identity verification.
- Eligibility and qualification checks.
- Structured interviews and job-related assessment.
- Physical, medical or psychological suitability assessment where lawful and relevant.
- Integrity and background vetting under applicable law.
- Reference and employment-history checks.
- Conflict-of-interest declarations.
- Accessibility and reasonable adjustments.
- Selection decision, reasons and candidate notification.
- Offer, acceptance and pre-employment conditions.

Selection criteria must be relevant, documented and consistently applied. Protected characteristics must not be used unlawfully in selection. Equality monitoring is kept distinct from selection decisions and subject to privacy safeguards.

Vetting is a risk and suitability process, not a finding of criminal guilt. An adverse or incomplete check requires appropriate review, verification and an opportunity to address material discrepancies where law provides. A candidate must not be rejected solely on an unverified allegation or mistaken identity.

Recruitment records identify panel members, conflicts, assessment evidence, scores or reasons, approvals, exceptions and review routes. A hiring manager cannot bypass a mandatory check or appoint beyond delegated authority.

### Appointment, onboarding and employment terms
Appointment begins only when required approvals and conditions are satisfied. The employee record links:
- Verified identity and employee identifier.
- Appointment and employment status.
- Employer entity and service jurisdiction.
- Position, rank or grade where applicable.
- Reporting manager and organisational unit.
- Work location and expected duties.
- Start date and any probation period.
- Employment type and contract terms.
- Pay scale, allowances and benefits references.
- Required qualifications and training.
- Vetting and authorisation status.
- Policy acknowledgements and declarations.
- Review dates and outstanding conditions.

Onboarding includes explanation of role, command and reporting arrangements, policies, conduct standards, information security, health and safety, payroll administration, employee support and required training.

The employee receives the applicable written terms and a record of amendments. Oral assurances do not silently alter the official contract. Changes to terms require lawful authority, consultation or agreement where required, notice and a versioned record.

### Employment categories and status
The system supports distinct employment relationships, such as:
- Permanent or continuing employee.
- Fixed-term employee.
- Probationary employee.
- Recruit or trainee.
- Part-time employee.
- Temporary or casual employee.
- Seconded employee.
- Contracted service provider.
- Volunteer or auxiliary role where legally recognised.
- Suspended employee.
- Employee on authorised leave.
- Employee serving notice.
- Former employee.

These are not interchangeable labels. A contractor is not automatically an employee or sworn officer. A recruit may have limited powers and a special training status. A seconded employee may remain employed by a home organisation while serving under a host arrangement.

Status changes record effective dates, authority, reason, contractual basis and impacts on access, pay, benefits, training, supervision and deployment. Historical status is retained so that past decisions can be evaluated under the rules then in force.

### Employment conditions and policy administration
The service maintains controlled references for:
- Working hours and shift arrangements.
- Rest periods and maximum working time.
- Overtime, call-out and on-call arrangements.
- Pay grades, increments and allowances.
- Leave and public holidays.
- Sickness and absence.
- Pension and retirement arrangements.
- Insurance and other benefits.
- Uniform, equipment and expense entitlements.
- Relocation, travel and duty-related expenses.
- Flexible working and workplace adjustments.
- Grievance, representation and consultation rights.

Exact rates, thresholds, eligibility rules, statutory minima, collective agreements and pension provisions remain to be defined by the fictional country's law and approved employment instruments. BP-33 records authoritative references and employee-specific applicability; it does not invent contractual entitlements.

### Attendance, working time and availability
Attendance administration records scheduled and actual duty, approved changes, overtime, rest, absence and relevant exceptions. It integrates with BP-08 deployment and BP-37 scheduling without confusing an employee's contractual hours with current operational availability.

Records may include:
- Published roster and assigned shift.
- Clock-in or attendance confirmation where used.
- Late arrival, early departure and authorised absence.
- Overtime and call-out.
- Rest periods and compensatory time.
- Training and other approved duty.
- Remote or alternative work arrangements where permitted.
- Manager approval and reason for adjustment.

The system detects potential working-time and fatigue risks, including repeated overtime, missed rest, excessive consecutive duty and conflicts with mandatory training. Alerts prompt review; they do not automatically establish misconduct.

A commander may request additional duty only within legal and delegated limits. Emergency exceptions must have a legal basis, documented necessity, duration, review and compensatory arrangements where required. Staffing shortages do not justify silently erasing recorded hours or denying statutory rest.

### Leave administration
Leave types may include annual leave, public holidays, sickness absence, parental leave, maternity or paternity leave, adoption leave, bereavement leave, compassionate leave, carers' leave, study leave, special leave, unpaid leave and other statutory or approved categories.

Each leave category defines:
- Eligibility and accrual.
- Entitlement and calculation method.
- Application and approval authority.
- Notice and evidence requirements.
- Carry-over or forfeiture rules.
- Interaction with shift rosters and operational continuity.
- Pay and benefit treatment.
- Confidentiality and record access.
- Return-to-work requirements where applicable.

Leave decisions must be consistent, timely and reasoned. Operational requirements may affect scheduling only within applicable law and policy. Leave is not denied arbitrarily or used as punishment. Sensitive reasons are restricted; supervisors see only the information necessary to plan duty and manage safety.

### Sickness absence and return to work
Sickness absence is handled as an employment and welfare matter, with appropriate medical confidentiality. Records distinguish employee self-report, medical certification, occupational-health advice, fitness restrictions and management decisions.

The process may include:
- Notification and recording of absence.
- Applicable certification and review points.
- Welfare contact proportionate to circumstances.
- Occupational-health referral where appropriate.
- Fitness-for-duty assessment where lawfully required.
- Workplace adjustments or phased return.
- Return-to-work discussion.
- Review of recurring or prolonged absence.
- Capability referral only where appropriate and fair.

Managers do not diagnose employees or access full medical records without lawful basis. Health information is held separately with tightly controlled access. A medical condition is not evidence of poor character or misconduct.

Return to work may be full, phased, restricted or deferred based on competent advice and role risk. Any restriction records scope, review date, responsible authority and route to reassessment.

### Pay, allowances and benefits interface
BP-33 maintains the employment facts required for accurate remuneration, while BP-34 governs financial authorisation, funding and payment controls.

Relevant data may include:
- Contractual salary or pay scale.
- Grade or increment eligibility.
- Approved allowances and premiums.
- Overtime and call-out records.
- Leave and absence adjustments.
- Deductions and benefit references.
- Effective dates and authorising officer.
- Payroll queries, corrections and audit trail.

No user or manager may directly edit a paid amount without an authorised and traceable change. Payroll corrections preserve original entries, reason, approval and payment impact. Disputes are acknowledged and investigated promptly. Exact pay rates and tax or pension rules remain external legal and financial configuration, not invented simulation constants.

### Employee relations and representation
The framework provides lawful routes for consultation, representation and collective employee relations. It may support:
- Employee representatives and recognised associations.
- Staff consultation and negotiation.
- Workplace policy consultation.
- Employee feedback and engagement.
- Formal grievances.
- Workplace mediation where voluntary and appropriate.
- Dispute escalation and independent review.
- Representation during relevant employment processes.

Employees may raise concerns without retaliation. Representation rights and collective arrangements are determined by the fictional legal framework. Managers must not interfere with lawful association or pressure employees to waive rights.

### Grievances and workplace disputes
A grievance may concern management decisions, workplace treatment, conditions, discrimination, harassment, working arrangements, pay administration, safety, unfair treatment or other employment matters.

The grievance process records:
- Employee and grievance reference.
- Issue and requested resolution.
- Date and receiving channel.
- Immediate safety or retaliation concerns.
- Informal resolution attempts where appropriate.
- Assigned impartial handler.
- Evidence and response.
- Meetings and representation.
- Findings, reasons and proposed remedy.
- Review or appeal route.
- Completion and follow-up.

A grievance is not automatically a misconduct complaint, though allegations of misconduct must be referred to BP-31 where required. The employee must not be forced into informal resolution for serious harassment, violence, discrimination or safeguarding matters. The person complained about should not control the grievance investigation or decision.

### Capability and performance management
Capability processes address an employee's ability to meet defined role requirements, including performance, knowledge, skill, health-related capability and sustained work standards. They are distinct from disciplinary processes.

The framework may include:
- Clear role expectations and measurable standards.
- Regular supervision and feedback.
- Documented performance reviews.
- Early support and coaching.
- Identification of resources or training needs.
- Improvement plans with reasonable objectives and timescales.
- Adjustments and occupational-health input where appropriate.
- Progress reviews and employee response.
- Alternative duties or role adjustment where available.
- Formal capability decision and appeal where applicable.

Capability concerns must be based on evidence and account for workload, supervision, training, equipment, policy clarity, reasonable adjustments and operational context. A person should not be blamed for systemic failures beyond their control.

Deliberate dishonesty, wilful refusal or other alleged misconduct is referred to BP-31 rather than disguised as a capability issue. A single event may involve both performance and conduct questions, but each route must have a clear basis and fair process. Capability action is not a criminal finding and must not be recorded as one.

### Workplace conduct and employee relations interfaces
BP-33 administers employment processes where workplace behaviour affects working relationships, but BP-31 retains professional standards investigation and disciplinary jurisdiction for police conduct matters.

The system identifies the correct route for:
- Interpersonal disagreement.
- Bullying or harassment allegations.
- Discrimination and victimisation.
- Workplace violence or threats.
- Insubordination or alleged refusal of lawful instruction.
- Attendance or punctuality concerns.
- Confidentiality and data misuse.
- Conflicts of interest.
- Criminal allegations.
- Fitness-for-duty concerns.

Triage considers whether the matter is a grievance, capability issue, professional standards allegation, criminal matter, safety concern or a combination. No administrator may downgrade a serious conduct allegation solely to avoid formal process. Parallel processes are coordinated without sharing confidential material unnecessarily.

### Employee welfare and occupational health
The service supports physical and psychological welfare, safe working conditions and access to appropriate assistance. Measures may include:
- Occupational-health services.
- Confidential counselling and employee assistance.
- Critical-incident support.
- Fatigue and workload management.
- Injury reporting and rehabilitation.
- Peer support with appropriate boundaries.
- Workplace risk assessment.
- Reasonable adjustments.
- Return-to-work planning.
- Referral to external healthcare where appropriate.

Support is not conditional on an employee admitting fault or waiving rights. Welfare information is not used as informal intelligence or disclosed to commanders beyond what is necessary for safety, accommodation and lawful employment decisions.

The framework recognises exposure to traumatic events, shift work, public scrutiny and operational stress without assuming that every employee experiences or responds to them in the same way. The service must not stigmatise help-seeking.

### Equality, dignity and workplace adjustments
Employment decisions must comply with applicable equality and anti-discrimination law. The service provides accessible recruitment, training, facilities, communications and workplace arrangements where required.

Reasonable adjustment requests are considered individually and documented with:
- Requested adjustment and employee needs as lawfully disclosed.
- Relevant functional requirements of the role.
- Evidence or specialist advice where appropriate.
- Alternatives considered.
- Decision and reasons.
- Review date and appeal route.

Medical or disability information is limited to those with a legitimate role. Adjustments do not automatically remove essential role requirements, but the service must assess whether the requirement can be met through a reasonable change in method, equipment, schedule or allocation.

### Transfers, secondments and temporary assignments
A transfer or temporary assignment records:
- Sending and receiving units or organisations.
- Employee's substantive post and temporary role.
- Effective start and end dates.
- Reporting and supervision arrangements.
- Duties, authority and geographic jurisdiction.
- Required qualifications and training.
- Pay, expenses and accommodation implications.
- Access and security changes.
- Return or extension arrangements.
- Approval and review authority.

A temporary assignment does not automatically change substantive rank, grade, employment contract or statutory authority. A secondment agreement identifies the home employer, host responsibilities, liability, information-sharing rules and return arrangements.

Operational redeployment under BP-08 is distinguished from a formal HR transfer. The former changes current assignment; the latter changes the employee's administrative employment placement or terms.

### Promotion, acting appointments and career administration
BP-33 supports the administrative consequences of decisions made under BP-07. It records approved changes to grade, pay, position, reporting line, terms and effective date, but does not determine promotion criteria or confer rank.

Acting appointments and temporary higher duties require:
- Defined authority and duration.
- Eligibility and competency checks.
- Approval under the delegation schedule.
- Pay and allowance treatment.
- Reporting and accountability arrangements.
- End date, review or extension.
- Clear distinction from substantive appointment.

A successful course, performance review or acting appointment does not automatically guarantee promotion. Decisions must follow the approved career framework and applicable fairness rules.

### Employee concerns, whistleblowing and retaliation
Employees may raise concerns about safety, corruption, illegality, discrimination, misconduct, policy failure or workplace treatment through the appropriate protected route.

BP-33 provides employment support and records relevant workplace actions, while BP-31 controls protected disclosure and professional standards processes. No employee may be penalised for a protected report, lawful participation in an investigation, representation, grievance or exercise of employment rights.

Any alleged retaliation is assessed independently and promptly. Confidentiality is preserved to the extent lawful. An employee who makes a report in good faith is not treated as dishonest merely because the concern cannot be substantiated.

### Separation from service
Separation may occur through:
- Resignation.
- Retirement.
- Expiry of fixed-term employment.
- Completion of secondment or temporary appointment.
- Dismissal following lawful process.
- Redundancy or organisational restructuring where permitted.
- Medical or capability-related separation under applicable law.
- Death in service.
- Other legally recognised termination.

The process records reason, authority, notice, effective date, outstanding pay and benefits, leave balances, pension interface, property return, access revocation, record preservation, exit interview where appropriate and post-employment obligations.

A resignation does not automatically terminate an investigation or erase a complaint. Where jurisdiction permits, matters may continue after separation. The record distinguishes resignation, retirement, dismissal, contract expiry and death; these outcomes must never be collapsed into a generic inactive status.

Dismissal for misconduct requires the applicable BP-31 process. Criminal conviction, disciplinary finding and employment termination remain separate statuses. A person leaving service is not presumed guilty because an investigation remains open.

### Retirement, service limits and pension interface
Retirement administration follows the governing law, service regulations and approved career framework. It records eligibility, notice, service calculation, approval, effective date, pension or benefit referrals and any permitted extension.

BP-33 administers the employment event; BP-07 defines career and service rules. Pension calculations and financial obligations are handled through the authorised financial and pension framework. The system must not invent retirement age, service duration or benefit formulas before those rules are approved.

### Workforce reporting and analytics
Authorised workforce reports may cover:
- Establishment and vacancy rates.
- Headcount and employment categories.
- Recruitment pipeline and time to fill.
- Turnover, retirement and retention.
- Attendance, overtime and absence.
- Leave and training release.
- Skills and workforce capability.
- Employee welfare and workplace safety trends.
- Grievances and capability processes in appropriately aggregated form.
- Equality and access monitoring where lawful.
- Succession and workforce risk.

Reports distinguish actual people from posts and full-time equivalents. They use clear definitions, reporting periods and data-quality checks. Sensitive health, grievance, disciplinary and whistleblowing information is not exposed through ordinary management dashboards.

Analytics must not be used to infer individual misconduct or make high-impact employment decisions without lawful, explainable and reviewable human assessment. Small-group reporting must account for re-identification risk.

### Employment records and confidentiality
BP-33 maintains or references authoritative records for:
- Recruitment and selection.
- Appointment and contract terms.
- Employment status and service history.
- Attendance, shifts and leave.
- Pay and benefits interfaces.
- Grievances and employee relations.
- Capability and performance.
- Welfare and occupational-health restrictions.
- Transfers and secondments.
- Promotion and acting appointments.
- Separation and post-employment obligations.

Access is role-based and purpose-limited. Medical, grievance, whistleblowing, vetting and disciplinary records receive additional restrictions. Supervisors see only the information required for legitimate management and deployment. Employees may access and correct their own records through defined procedures, subject to lawful limits.

Every material change records actor, timestamp, reason, authority, source and previous value. Records follow approved retention schedules, legal holds and disclosure rules. The system preserves historical accuracy and does not silently overwrite employment decisions.

### Player experience and authority
The player may interact with HR according to their status and permissions. An ordinary officer can review relevant employment information, submit leave requests, report absence, raise a grievance, request an adjustment, review training requirements, submit a transfer preference or receive formal employment notices.

A supervisor may approve routine matters only within delegated authority. HR personnel may administer employment records and processes but cannot alter operational command, grant statutory powers, decide professional standards findings or make judicial determinations.

The player must be able to distinguish:
- Substantive post from current deployment.
- Rank from grade and salary scale.
- Employment status from duty status.
- Leave approval from operational availability.
- Capability action from misconduct discipline.
- Interim restriction from final sanction.
- Resignation from dismissal.
- Employment termination from criminal conviction.

The interface shows pending requests, decision authority, reasons, deadlines, appeal routes and status changes without exposing confidential records to unauthorised users.

### Connections to other divisions
- **BP-01 to BP-05:** foundational governance, world, population, institutions and police architecture.
- **BP-06 and BP-07:** authoritative personnel records, rank, grade, position, appointment and career rules.
- **BP-08 and BP-09:** deployment, staffing, equipment and operational resources.
- **BP-10 to BP-12:** patrol, communications, incident response, attendance and rostering.
- **BP-13 to BP-29:** specialist roles, operational demands and legal consequences that affect workforce requirements.
- **BP-30:** governance, delegations, establishment approval and organisational accountability.
- **BP-31:** conduct investigations, disciplinary findings, protected disclosures and integrity.
- **BP-32:** training, competence, qualification and development.
- **BP-34:** payroll funding, budgets, benefits, procurement and financial control.
- **BP-35 to BP-37:** simulation processing, relationships, time and scheduling.
- **BP-38 to BP-44:** records, persistence, interface, notifications, permissions, testing and configuration.

### Exceptions and edge cases
The design must handle duplicate identity, incomplete application, false credentials, adverse vetting, disputed qualification, recruitment appeal, candidate withdrawal, delayed start date, probation extension, contract amendment, retroactive pay correction, missed attendance record, shift change, excessive overtime, fatigue risk, overlapping leave, emergency recall, sickness during leave, long-term absence, occupational-health restriction, disability adjustment, pregnancy-related adjustment, workplace injury, grievance against a senior manager, grievance involving HR staff, harassment report, protected disclosure, retaliation, employee suspension, criminal investigation, disciplinary process, capability process, disputed performance evidence, temporary reassignment, secondment extension, acting appointment, promotion reversal where lawful, transfer between jurisdictions, loss of payroll data, employee death, resignation during investigation, retirement while a matter is pending, dismissal appeal, post-employment disclosure, legal hold, privacy request, record correction, system outage and organisational restructuring.

### Acceptance conditions
- Every post is linked to an approved establishment and funding authority.
- Recruitment and appointment decisions are traceable, fair and based on approved role criteria.
- Employment status, rank, grade, position, appointment and operational authority remain distinct.
- Contract terms and changes have authorised, versioned records.
- Attendance, shifts, overtime, rest and leave are accurately administered.
- Working-time and fatigue risks can be identified and reviewed.
- Sickness and medical information receive appropriate confidentiality.
- Pay and benefits changes require authorised, auditable controls.
- Employees have accessible grievance, representation and workplace concern routes.
- Capability is distinct from professional misconduct and criminal proceedings.
- Welfare, occupational health and reasonable adjustments are handled fairly.
- Transfers, secondments and acting appointments have clear authority, scope and duration.
- Promotion administration does not replace BP-07 selection and appointment decisions.
- Separation reasons and effective dates are accurately distinguished.
- Open investigations and legal holds are not erased by resignation or retirement.
- Workforce analytics use defined measures and protect sensitive information.
- Employee records are access-controlled, historically accurate and auditable.
- HR users cannot grant police powers, decide disciplinary cases outside authority or override operational command.
- The player can see and act only on employment matters permitted by their role.

**Draft status:** BP-33 is a working design. The fictional labour statute, police employment regulations, collective bargaining arrangements, employment categories, recruitment and vetting standards, contract forms, working-time limits, pay scales, leave entitlements, sickness rules, pension and retirement law, grievance and capability procedures, medical confidentiality rules, redundancy framework and retention schedules remain open. No HR information system, payroll engine, recruitment platform, workforce establishment database or employee self-service portal has been implemented by this design document.



---

## BP-34 — Finance and Procurement

### Purpose and scope
Define the financial management, budgeting, accounting, procurement, purchasing, payment, supplier, contract and financial-assurance framework for the National Police Service. BP-34 ensures that public funds and organisational resources are planned, authorised, committed, received, paid, recorded, monitored and audited lawfully and transparently.

BP-34 is the authoritative design for police financial administration and procurement. It covers:
- Financial governance, delegated financial authority and separation of duties.
- Strategic and operational financial planning.
- Budget preparation, approval, allocation, monitoring and revision.
- Financial forecasts, commitments, expenditure and variance control.
- Accounting structure, journals, ledgers and reconciliations.
- Procurement planning, sourcing, evaluation, award and purchasing.
- Supplier registration, due diligence, performance and risk.
- Contract creation, variation, monitoring, renewal and closure.
- Purchase orders, goods receipt, invoice validation and payment.
- Payroll funding and payment-control interfaces.
- Staff expenses, allowances and reimbursement interfaces.
- Financial assets, capital expenditure and lifecycle accounting.
- Grants, donations, external funding and inter-agency financial arrangements.
- Fraud prevention, financial misconduct referrals and financial investigation support.
- Financial reporting, audit, assurance, retention and public accountability.

BP-34 does not replace:
- BP-09 for operational resource requirements, asset identity, assignment, condition, maintenance and inventory.
- BP-30 for institutional governance, risk appetite, delegations, audit oversight and accountability.
- BP-33 for employment facts, contractual pay entitlements, attendance, approved overtime, leave and employee-specific remuneration inputs.
- BP-38 and BP-39 for authoritative record architecture, persistence, recovery and retention controls.
- BP-42 and BP-43 for access control, security, testing and quality assurance.

Financial approval does not itself confer operational command, legal authority, procurement competence or ownership of an asset. A budget allocation does not prove that a purchase is necessary, a supplier is suitable, goods were received or an invoice is valid. A purchase order does not prove delivery. An invoice does not prove liability. A payment does not prove that the underlying transaction was lawful or correctly authorised.

The fictional country's public finance law, procurement statute, tax rules, accounting standards, audit mandate, public-sector employment framework and exact financial thresholds remain to be defined. BP-34 establishes the required control architecture; it must not invent binding thresholds, tax rates, accounting treatments or statutory procedures before the governing framework is approved.

### Financial governance and principles
Financial administration is governed by:
- Legality: every receipt, commitment, purchase, payment, write-off and financial decision has an authorised basis.
- Public stewardship: funds are used for approved policing purposes and demonstrable public value.
- Budget discipline: expenditure is controlled against approved budgets and valid delegations.
- Transparency: material financial decisions and procurement outcomes are traceable and reviewable.
- Competition and fairness: procurement follows the applicable lawful method and treats suppliers consistently.
- Value for money: cost, quality, suitability, lifecycle cost, delivery risk and public benefit are considered together.
- Integrity: bribery, fraud, collusion, favouritism, kickbacks, undisclosed conflicts and personal benefit are prohibited.
- Separation of duties: incompatible request, approval, ordering, receipt, invoice-validation, payment and reconciliation functions are separated or subject to documented compensating controls.
- Accuracy: transactions are supported by evidence and recorded in the correct period, account, fund and cost centre.
- Completeness: commitments, liabilities, assets, receipts and payments are not omitted or duplicated.
- Proportionality: controls reflect transaction value, risk, urgency, complexity and legal requirements.
- Auditability: each material action has an attributable actor, authority, date, source evidence and history.
- Continuity: financial records and essential payment controls remain recoverable during system or service disruption.

No officer or manager may divide, disguise, misclassify or route a transaction through another unit to evade a financial limit, procurement method, approval or audit control. Emergency conditions may activate a defined exceptional route but do not remove the obligation to record, justify, review and disclose the transaction as required.

### Financial authority and delegation
Financial authority is assigned through the BP-30 governance and delegation framework. BP-34 maintains the operational financial-authority schedule and validates it when a financial action is requested.

A financial delegation records:
- Unique delegation identifier.
- Delegator and recipient identities.
- The legal, policy or organisational source of authority.
- Permitted transaction types and decision categories.
- Maximum value, currency and aggregation rules, where applicable.
- Budget, fund, programme, cost-centre or geographic scope.
- Conditions, exclusions and required supporting evidence.
- Whether the authority may be sub-delegated.
- Effective date, expiry date and review date.
- Suspension, revocation and replacement history.
- Required independent approvals or additional controls.

A recipient cannot delegate authority they do not hold. A temporary acting appointment does not automatically confer financial authority. Absence, vacancy, promotion or transfer does not silently change an approval limit. A delegation is checked at the time of the decision and again before execution where the authority may have expired, been suspended or been revoked.

The system distinguishes:
- Budget ownership and responsibility for monitoring an allocation.
- Authority to approve a business need.
- Authority to select or approve a procurement route.
- Authority to award or vary a contract.
- Authority to place an order.
- Authority to confirm receipt or service completion.
- Authority to validate an invoice.
- Authority to release a payment.
- Authority to reconcile an account.
- Authority to write off, dispose of or impair an asset.
- Independent assurance and audit authority.

The same person must not perform incompatible stages of a transaction merely because they hold a senior rank. Where staffing constraints make full separation impracticable, the exception requires a recorded risk assessment, independent review and compensating controls. No person approves their own expenses, supplier interest, contract benefit or unsupported payment.

### Financial structure and records
The service maintains a controlled financial structure that may include:
- Legal entity and reporting entity.
- Financial year and accounting period.
- Chart of accounts.
- Funds and funding streams.
- Budgets and budget versions.
- Programmes, services and projects.
- Departments, units and cost centres.
- Capital and operating expenditure categories.
- Commitments, purchase orders and contracts.
- Accounts payable and receivable where applicable.
- General ledger and subsidiary ledgers.
- Bank, cash and payment accounts.
- Financial assets and liabilities.
- Grants, restricted funds and externally funded activities.

Each financial object has a stable identifier, owner, status, effective dates, source, relationships, access classification and audit history. Codes and account definitions are versioned. A change to the chart of accounts or reporting structure must preserve historical interpretation; it must not rewrite prior-period transactions.

The transaction record identifies, as appropriate:
- Transaction identifier and type.
- Transaction and posting dates.
- Financial period.
- Currency and exchange-rate source where applicable.
- Gross, net, tax and other component amounts where legally relevant.
- Account, fund, programme and cost centre.
- Supplier, employee, customer or other counterparty.
- Contract, purchase order, receipt and invoice references.
- Requesting unit and responsible budget holder.
- Approval chain and delegation references.
- Supporting documents and evidence.
- Status, reason, exception and correction history.

Amounts must use an exact decimal or integer minor-unit representation appropriate to the currency, never imprecise binary floating-point arithmetic as the authoritative financial value. Currency, rounding, tax treatment and exchange-rate rules are explicit configuration, not hidden assumptions.

### Financial planning and budget cycle
The financial planning cycle includes:
1. Establish strategic priorities, service requirements and planning assumptions.
2. Collect budget proposals from authorised units and programmes.
3. Assess operational need, affordability, legal obligations and lifecycle costs.
4. Identify recurring commitments, contracts, staffing costs and capital requirements.
5. Prepare forecasts and risk scenarios.
6. Challenge and reconcile proposals against the available funding envelope.
7. Submit the proposed budget to the competent approval authority.
8. Record the approved budget and any conditions.
9. Allocate authorised budgets to responsible owners and cost centres.
10. Monitor actual expenditure, commitments, forecast outturn and performance.
11. Record authorised virements, supplementary allocations or reductions.
12. Close the financial period and prepare required accounts and reports.
13. Review outcomes and feed lessons into the next planning cycle.

A budget proposal, draft allocation or forecast is not an approved spending authority. The system distinguishes requested, proposed, reviewed, approved, allocated, frozen, revised, exhausted, closed and cancelled budget states. A transaction cannot rely on a draft budget as though it were approved.

Budget owners can view approved allocations, actual expenditure, outstanding commitments, available balance, forecast expenditure and relevant restrictions. The available balance calculation accounts for approved commitments and pending obligations according to the configured accounting policy. It must not treat a purchase order, invoice, payment or accrual as interchangeable events.

### Budget monitoring and financial control
Budget monitoring identifies:
- Original approved budget.
- Approved revisions and transfers.
- Actual posted expenditure and receipts.
- Open commitments and contractual obligations.
- Accrued liabilities where the accounting framework requires them.
- Forecast expenditure and expected income.
- Remaining available budget.
- Variances, trends and forecast overspend or underspend.
- Restricted funds and purpose limitations.
- Unusual, duplicate or out-of-pattern transactions.

A budget transfer or virement requires a defined authority, reason, source and destination, value, date, impact assessment and audit trail. Transfers cannot be used to conceal overspending, defeat a restricted grant condition or avoid a procurement threshold. A budget owner cannot approve an increase to their own authority unless the delegation expressly permits it.

When a budget is exhausted, frozen or restricted, the system blocks or escalates new commitments according to the applicable rules. It must not silently permit an overrun. An exception requires a recorded lawful basis, authorised decision, amount, duration, risk and subsequent review. Critical policing need does not automatically create financial authority.

### Procurement planning and sourcing
Procurement begins with a documented requirement from an operational or corporate owner. The requirement identifies:
- The service need and intended outcome.
- Requesting unit and accountable sponsor.
- Operational specification and minimum requirements.
- Quantity, quality, compatibility and delivery expectations.
- Estimated total lifecycle cost.
- Funding source and budget availability.
- Market and supplier considerations.
- Dependencies, security and information risks.
- Maintenance, support, training and disposal needs.
- Procurement timetable and urgency.
- Conflicts of interest and any restrictions.
- Approval to commence procurement.

The procurement process must consider whether an existing contract, framework, stock holding, internal capability or lawful shared-service arrangement can meet the need. Requirements must not be written to favour a named supplier without a documented lawful and defensible reason.

Procurement routes may include open competition, restricted competition, quotations, approved frameworks, direct award where legally permitted, collaborative procurement, emergency procurement and other methods established by the fictional procurement law. Thresholds, advertising rules, minimum competition, permitted exceptions, standstill periods and review rights remain open until the legal framework is defined.

The estimated procurement value is calculated using the applicable aggregation and contract-duration rules. Related lots, options, extensions, recurring purchases and linked requirements must not be artificially split to avoid a threshold or approval. A procurement route is selected and justified before supplier selection.

### Supplier registration and due diligence
Supplier records distinguish legal identity, trading name, beneficial ownership where lawfully collected, registration status, addresses, authorised representatives, tax or regulatory details where applicable, payment details, service categories, insurance, licences, certifications, financial standing, conflicts, sanctions or exclusion checks where legally required, and performance history.

Due diligence is proportionate to value, sensitivity, criticality and risk. It may consider:
- Identity and legal existence.
- Ownership and control.
- Financial stability and insolvency risk.
- Relevant experience and technical capability.
- Regulatory status, licences and certifications.
- Insurance and liability coverage.
- Employment, labour and modern-slavery risks where applicable.
- Environmental and sustainability requirements where applicable.
- Cybersecurity and information-handling controls.
- Data protection and confidentiality commitments.
- Subcontracting and supply-chain dependencies.
- Conflicts of interest, collusion or improper influence.
- Delivery capacity and business continuity.
- Prior contract performance and unresolved failures.

Registration does not guarantee eligibility for every procurement. A supplier may be approved for one category or risk level and restricted for another. Supplier records preserve the evidence, checks, decision, reviewer, date, conditions, expiry and reassessment outcome. False information, changed ownership, insolvency, serious performance failure or new legal restrictions trigger review.

Bank or payment-detail changes require independent verification through an approved channel. A change request alone is not sufficient evidence. The person who changes supplier payment details must not be the sole approver of the resulting payment.

### Tender evaluation and contract award
Evaluation criteria and weightings are approved before bids are assessed and communicated as required by the applicable procurement route. Criteria may include price, whole-life cost, quality, technical suitability, delivery, resilience, security, accessibility, sustainability and service support.

The evaluation record includes:
- Procurement identifier and approved route.
- Published specification and evaluation criteria.
- Invited or responding suppliers.
- Submission receipt time and integrity.
- Evaluator identities and declarations.
- Individual assessments and moderated result.
- Clarification requests and responses.
- Conflict management and recusals.
- Due-diligence results.
- Value-for-money assessment.
- Award recommendation and approval.
- Required notifications, review or challenge periods.
- Contract and purchase-order references.

Evaluators must not alter criteria after seeing bids to favour a preferred outcome. A clarification must not become an undisclosed opportunity to rewrite a bid or give one supplier an unfair advantage. A sole-source or direct-award decision requires the applicable legal ground, evidence, approval and publication or reporting where required.

The award decision and contract signature are distinct from the operational confirmation that goods or services have been delivered. No supplier is entitled to payment merely because it was selected or a contract was signed.

### Contract lifecycle and management
Each contract has a stable identifier and records:
- Contracting parties and authorised signatories.
- Procurement and award references.
- Scope, specification and deliverables.
- Contract value, currency and payment model.
- Start date, end date, renewal and extension options.
- Milestones, service levels and acceptance criteria.
- Price adjustment and variation mechanisms.
- Insurance, warranties and liability terms.
- Confidentiality, privacy and information-security requirements.
- Subcontracting and supply-chain conditions.
- Audit, inspection and access rights.
- Dispute, termination and exit provisions.
- Business continuity and transition arrangements.
- Asset, data and intellectual-property ownership where relevant.
- Contract manager, budget owner and review schedule.

Contract changes require a documented need, legal and procurement review where required, financial assessment, available budget and approval by the proper authority. A variation cannot be used to make a material change that would have required a different procurement route unless the applicable law permits it. Extensions, renewals, price changes and scope changes are recorded as dated events; the original contract remains reconstructable.

Contract managers monitor delivery, milestones, service levels, expenditure, risks, supplier performance, complaints, variations, insurance, security obligations and renewal dates. Poor performance produces a recorded corrective plan, escalation, remedy or termination decision where appropriate. Contract closure records final delivery, outstanding liabilities, disputes, asset and data return, access revocation, final payment and lessons learned.

### Purchasing, ordering and commitment control
A purchase request records the business need, specification, estimated cost, funding source, procurement route, requester and required approval. Approval creates permission to proceed within the approved scope; it does not itself create a supplier order unless the authorised workflow explicitly does so.

A purchase order records supplier, items or services, quantities, prices, taxes where applicable, delivery location, delivery dates, contract reference, cost centre, budget, authorisation and terms. Purchase orders are issued only by authorised personnel and are uniquely identifiable.

The system distinguishes:
- Purchase request.
- Procurement approval.
- Tender or quotation.
- Award decision.
- Contract.
- Purchase order.
- Goods or service receipt.
- Supplier invoice.
- Invoice validation.
- Payment instruction.
- Bank settlement.
- Ledger posting and reconciliation.

A commitment is recorded at the correct point under the approved accounting policy. Amendments, cancellations and closure preserve the original order and all subsequent changes. Retrospective orders are exceptional, flagged and reviewed; they are not used as a routine substitute for prior approval.

### Receipt, invoice validation and payment
Receipt of goods or services is confirmed by a person with appropriate knowledge and authority, independent of the requester and payment releaser where practicable. The receipt record includes date, location, quantity, condition, serial or batch information where relevant, service acceptance, defects, partial delivery and supporting evidence.

Invoice validation checks supplier identity, contract and purchase-order references, agreed prices, quantities, tax treatment where applicable, receipt or service acceptance, arithmetic, duplicate risk, credit notes, payment terms and approval. The system supports matching the purchase order, receipt and invoice, with controlled exceptions for services, staged payments, subscriptions, utilities, emergencies and other approved cases.

A discrepancy places the invoice into a defined hold or query state. A partial delivery may support only the corresponding authorised partial payment. Duplicate invoices, changed bank details, unusual payment patterns, split invoices and unexplained price changes trigger additional review.

Payment release requires:
- A valid underlying liability.
- Completed invoice validation or an approved alternative control.
- Available funding and correct accounting allocation.
- Confirmation of the authorised payee and payment details.
- Approval within current financial delegation.
- Separation from incompatible request, receipt and reconciliation functions.
- A traceable payment instruction and settlement result.

Payment states distinguish prepared, pending approval, approved, transmitted, settled, rejected, returned, cancelled, reversed and disputed. A failed payment does not erase the liability. A reversal or refund is a new traceable transaction linked to the original; records are never deleted to conceal a correction.

### Payroll, expenses and employee payments
BP-33 is authoritative for employment status, contract terms, approved salary or pay scale, attendance, overtime, leave, allowances and other employee-specific entitlement facts. BP-34 is authoritative for funding, financial calculation controls, payroll processing, payment execution, accounting and reconciliation.

The payroll interface receives only approved and effective employment inputs. It validates identity, pay period, authorised changes, funding, duplicate payment risk and applicable configuration. It returns payment and exception status to authorised HR and finance users without granting finance authority to alter employment terms or HR authority to release payments.

Payroll records distinguish gross pay, deductions, employer costs, net pay, adjustments, arrears, overpayments, recoveries and payment status as required by the fictional legal framework. Tax, pension, social contribution, benefit and deduction formulas remain configurable and must be grounded in approved law and policy. No rates or entitlements are invented by the simulation.

Expenses and reimbursements require a defined purpose, eligible category, evidence, date, amount, business connection, applicable limit and approval. A claimant cannot approve their own claim. Duplicate claims, altered receipts, personal expenditure, split claims and unsupported mileage or subsistence are flagged. Emergency operational expenditure has a controlled route and post-event review.

### Financial assets and capital expenditure
BP-09 owns operational asset identity and management: what an asset is, where it is, who holds it, whether it is serviceable, its maintenance and its operational availability. BP-34 owns the financial treatment: acquisition cost, funding, capital or operating classification, depreciation or other approved accounting treatment, impairment, disposal proceeds and financial reconciliation.

The financial asset record links to the BP-09 operational asset identifier where one exists. It may include acquisition date, supplier, cost, funding source, useful-life assumption, accounting category, depreciation method, impairment events, valuation evidence, disposal date and proceeds. The applicable accounting policy determines recognition thresholds and treatment; these are not invented in advance.

Capital projects require an approved business case, budget, project owner, procurement route, milestones, cost forecast, change control, delivery acceptance and post-implementation review. Project cost includes relevant acquisition, installation, training, maintenance, support and disposal considerations where the approved accounting and planning rules require them.

Asset disposal requires an authorised decision, condition and ownership check, valuation or disposal method where applicable, conflict screening, proceeds recording, removal from operational availability and preservation of financial history. Lost, stolen, damaged, transferred or written-off assets require coordination between BP-09, BP-34 and the appropriate incident, investigation or insurance process.

### Grants, donations and external funding
External funding is recorded with its source, legal basis, amount, currency, purpose, conditions, eligible expenditure, reporting requirements, period, restrictions, matching obligations, repayment or clawback provisions and accountable owner.

Restricted funds cannot be used for unrelated expenditure. Grant claims must be supported by eligible costs and required evidence. Donations, gifts, sponsorship and in-kind contributions are assessed under BP-30 conflict-of-interest and integrity controls and the applicable law. No donor or supplier may purchase influence over policing priorities, investigations, appointments or operational decisions.

Inter-agency cost sharing, service agreements, reimbursements and joint procurement arrangements record each party's responsibilities, contributions, liabilities, asset ownership, audit rights, data handling, payment schedule and dispute route. A partner's funding does not transfer police powers or command authority.

### Financial misconduct, fraud and irregularity
The framework identifies and routes suspected:
- Fraud, theft, embezzlement and false accounting.
- Bribery, kickbacks, collusion and bid manipulation.
- Conflicts of interest and undisclosed beneficial interests.
- Procurement favouritism or deliberate specification manipulation.
- False invoices, duplicate payments and fictitious suppliers.
- Payroll fraud, ghost employees and unauthorised pay changes.
- Expense fraud and misuse of public funds.
- Unauthorised commitments, budget manipulation and concealment of overspend.
- Supplier impersonation and payment redirection.
- Asset theft, deliberate damage or improper disposal.
- Unauthorised access, alteration or deletion of financial records.

Financial anomalies are risk indicators, not automatic proof of misconduct. The system preserves source records and routes concerns to the competent finance, internal audit, professional standards, law-enforcement or external authority under defined referral rules. BP-31 governs police employee conduct and disciplinary processes; criminal investigation and prosecution remain within their proper legal jurisdictions.

Staff involved in reporting or reviewing an irregularity must be protected from retaliation. A person implicated in a transaction cannot control the investigation, suppress records or approve corrective entries relating to their own conduct. Evidence is preserved with appropriate access restrictions and chain-of-custody controls where it becomes evidential material.

### Reconciliation, reporting and audit
The service performs reconciliations at defined intervals for bank and cash accounts, supplier statements, payroll control accounts, purchase orders, receipts, invoices, payments, grants, asset registers, general-ledger balances and other relevant subsidiary records.

A reconciliation identifies preparer, reviewer, period, source balances, differences, explanation, correcting action, approval and completion date. Unresolved differences are aged, risk-rated and escalated. A reconciliation cannot be marked complete merely because a balancing entry was posted; the underlying cause must be assessed.

Financial reports may include:
- Approved budget and revisions.
- Actual expenditure and receipts.
- Commitments and forecast outturn.
- Budget variance and available balance.
- Procurement pipeline and contract exposure.
- Supplier concentration and performance risk.
- Payment ageing and overdue liabilities.
- Payroll totals and exception trends.
- Capital projects and asset financial position.
- Restricted funding and grant compliance.
- Emergency expenditure and retrospective approvals.
- Fraud, irregularity and control findings.
- Audit recommendations and remediation status.

Reports distinguish cash movement, accounting expenditure, commitments, accruals and forecast values. Definitions, periods, source systems and known limitations are visible. Sensitive supplier, employee, investigation and whistleblowing information is limited to authorised users. Public reporting uses lawful disclosure and aggregation rules.

Internal audit and external auditors receive access under their legal mandate, with read-only or otherwise controlled access as appropriate. Management cannot alter audit evidence or suppress findings. Financial control failures are linked to BP-30 risk registers, assurance actions and corrective-action tracking. Audit closure requires evidence of effective remediation where the finding concerns a control weakness.

### Records, privacy and retention
BP-34 maintains or references authoritative records for:
- Financial delegations and approval authorities.
- Budgets, forecasts, revisions and allocations.
- Chart of accounts, funds and cost centres.
- Purchase requests, procurement plans and tender records.
- Supplier identity, due diligence and performance.
- Award decisions, contracts, variations and renewals.
- Purchase orders, receipts, invoices and credit notes.
- Payment instructions, settlement and reconciliation.
- Payroll funding, processing, payment and exceptions.
- Expenses, reimbursements and employee payments.
- Capital projects, financial assets and disposals.
- Grants, donations and inter-agency agreements.
- Financial reports, audit findings and corrective actions.
- Suspected irregularities and referrals, with restricted access.

Access is role-based and purpose-limited. Requesters, budget holders, procurement staff, contract managers, receipt officers, invoice validators, payment releasers, accountants, auditors and system administrators have distinct permissions. Supplier bank details, employee pay data, commercially sensitive bids and suspected fraud records receive additional protection.

Every material change records actor, timestamp, reason, authority, source, previous value and resulting value. Financial corrections are append-only or otherwise preserve the complete history. Retention follows approved schedules, legal holds, audit requirements and applicable disclosure law. No transaction, approval, supplier record or audit finding is silently deleted to make a report appear balanced.

### Player experience and authority
The player interacts with finance and procurement only to the extent permitted by their role. An ordinary officer may submit an operational purchase request, report a damaged or missing asset, claim an eligible expense, view relevant approved guidance or confirm receipt where formally assigned.

A supervisor may validate operational need and recommend expenditure within their remit but cannot exceed delegated financial authority. A budget holder can monitor allocations and approve permitted commitments. Procurement staff manage sourcing and supplier processes within their competence. Finance staff validate accounts and payments under assigned controls. Auditors and oversight bodies review records independently within their mandate.

The interface displays the request or transaction status, responsible owner, required evidence, budget position, approval route, outstanding action, deadline, supplier or contract reference and reason for any hold or rejection. It distinguishes a request from approval, approval from order, order from receipt, receipt from invoice validation and invoice validation from payment.

No player is permitted to bypass required controls merely to keep an operational activity moving. Where urgent need exists, the interface explains the lawful exceptional route and the required retrospective review without implying that urgency itself is approval.

### Connections to other divisions
- **BP-01 to BP-05:** governing foundations, country institutions, geography, organisations and police architecture.
- **BP-06 to BP-08:** personnel, career, unit structure, deployment and delegated operational responsibilities.
- **BP-09:** operational resource requirements, asset identity, inventory, maintenance, issue and disposal coordination.
- **BP-10 to BP-29:** operational demand, incidents, investigations, specialist capability, legal obligations and correctional interfaces that create financial requirements.
- **BP-30:** institutional governance, financial delegations, risk, audit oversight, public accountability and corrective action.
- **BP-31:** employee misconduct, corruption, complaints, integrity investigations and disciplinary outcomes.
- **BP-32:** training requirements, competence, qualification and training-provider arrangements.
- **BP-33:** employment facts, payroll inputs, allowances, expenses, workforce establishment and employee entitlements.
- **BP-35 to BP-37:** simulation processing, relationships, time, accounting periods and scheduled financial events.
- **BP-38 and BP-39:** authoritative financial records, data integrity, persistence, backup and recovery.
- **BP-40 and BP-41:** finance interfaces, alerts, statements, reports and notifications.
- **BP-42 and BP-43:** financial permissions, audit logging, control testing and quality assurance.
- **BP-44:** configurable currencies, financial periods, accounting policies, legal thresholds and approved simulation settings.

### Exceptions and edge cases
The design must handle an urgent purchase during a major incident; unavailable approver; expired or revoked delegation; disputed authority; budget freeze; restricted grant; overspend discovered after commitment; delayed invoice; partial delivery; defective goods; supplier insolvency; supplier identity fraud; bank-detail redirection; duplicate invoice; duplicate payment; credit note after payment; returned or rejected payment; foreign-currency purchase; exchange-rate change; tax or accounting rule change; contract extension; disputed variation; failed service level; supplier subcontracting without approval; collusive bids; single-supplier market; procurement challenge; confidential tender leak; evaluator conflict; emergency direct award; retrospective purchase order; split purchase; missing receipt; invoice without purchase order; payroll overpayment; payroll underpayment; employee status correction; retroactive pay adjustment; disputed expense; fraudulent receipt; lost corporate card; cash discrepancy; unreconciled bank item; grant clawback; donor conflict; asset loss; asset impairment; disposal dispute; capital-project overrun; accounting-period closure; late journal; prior-period correction; suspected insider fraud; whistleblower retaliation; audit obstruction; legal hold; data breach; supplier data correction; system outage; unavailable banking service; failed backup; corrupted ledger; duplicate transaction after recovery; and financial continuity during emergency command.

Every exception has a defined status, owner, authority, evidence requirement, escalation route and audit history. An exception must not erase the original transaction or silently convert an unauthorised action into an authorised one.

### Acceptance conditions
- Every financial decision and transaction is linked to a valid authority, purpose and accountable owner.
- Financial delegations are scoped, current, revocable and checked at the point of decision.
- Budgets distinguish proposed, approved, allocated, committed, spent, forecast and available amounts.
- Budget changes and exceptions are authorised and traceable.
- Procurement routes follow the applicable legal framework and cannot be evaded by artificial transaction splitting.
- Supplier identity, ownership, eligibility, conflicts and payment details receive proportionate verification.
- Tender criteria are fixed before evaluation and award decisions are evidenced.
- Contracts have controlled versions, authorised variations, accountable managers and closure records.
- Purchase requests, orders, receipts, invoices and payments remain distinct linked events.
- Goods and services are independently confirmed as received or accepted before payment, subject to approved exceptions.
- Duplicate, discrepant, unsupported or suspicious invoices and payments are held or escalated.
- Payroll uses authorised BP-33 employment inputs and preserves separation between HR entitlement decisions and finance payment controls.
- Expense claims cannot be approved by the claimant.
- Operational asset records in BP-09 link to financial acquisition, valuation and disposal records without duplicating ownership of operational status.
- Restricted grants and external funds are used only for authorised purposes.
- Financial anomalies trigger review and are not treated as automatic proof of misconduct.
- Financial records are accurate, historically traceable, access-controlled and recoverable.
- Reconciliations identify unresolved differences and require independent review where appropriate.
- Audit findings and control weaknesses are tracked to evidenced remediation.
- The player can perform only the financial actions permitted by their current role and delegation.

**Draft status:** BP-34 is a working design. The fictional public finance and procurement laws, accounting framework, chart of accounts, financial year, currencies, tax rules, approval thresholds, procurement thresholds, tender and challenge procedures, audit mandate, banking arrangements, payroll rules, expense limits, asset accounting policy, grant framework, retention periods and exact delegation schedule remain open. No budgeting system, accounting ledger, procurement platform, supplier register, contract-management system, payroll engine, payment integration or financial reporting software has been implemented by this design document.


---

## BP-35 — Simulation Engine

### Purpose and scope
Define the runtime architecture that turns the approved blueprint, persistent records, player commands, schedules, world conditions and non-player behaviour into a coherent, causally consistent and persistent police simulation. BP-35 governs how the game interprets actions, evaluates conditions, advances simulation processes, generates and resolves events, updates state, coordinates systems and produces responses.

The simulation engine is the execution layer of the game. It does not replace the domain rules owned by the other blueprint divisions. It provides the controlled mechanisms through which those rules operate.

BP-35 covers:
- Simulation runtime and orchestration.
- Command intake, validation, execution and response.
- Simulation state, transactions and controlled state transitions.
- Event creation, ordering, processing and consequences.
- Scheduled and triggered processing.
- Non-player character activity and decision execution.
- Relevance-based simulation intensity and persistent activation.
- Causal consistency, deterministic resolution and controlled uncertainty.
- Inter-system coordination and dependency handling.
- Simulation rules, configuration and version compatibility.
- Error handling, degraded operation and recovery coordination.
- Runtime monitoring, diagnostics and performance control.
- Prevention of duplicate, contradictory, impossible or unauthorised outcomes.

BP-35 does not replace:
- BP-01 for the game's governing principles, scope and player-agency rules.
- BP-03 and BP-04 for population, person, property, business and organisation identities.
- BP-05 to BP-34 for the substantive rules of police, operational, investigative, legal, institutional and financial domains.
- BP-36 for relationship and social-context models.
- BP-37 for authoritative game time, calendars, schedules and time advancement rules.
- BP-38 for authoritative record definitions and database architecture.
- BP-39 for persistence, backups, recovery and continuity.
- BP-40 and BP-41 for player interface, notifications and reporting.
- BP-42 for identity, permissions and security.
- BP-43 for test strategy, quality assurance and verification.
- BP-44 for approved configuration and controlled expansion.

The engine may execute a rule owned by another division but must not silently redefine that rule. Domain systems remain responsible for their own legal, operational and institutional decisions. The engine coordinates them and enforces their declared constraints.

### Runtime architecture and orchestration
The runtime is composed of cooperating services or logical modules with explicit responsibilities and interfaces. The implementation may use a modular monolith or another architecture justified by scale and reliability; the blueprint does not require microservices or distributed infrastructure merely for appearance.

The runtime includes, at minimum:
- Session and player-command coordinator.
- Identity and permission validation interface.
- Command parser and intent normalisation.
- Domain command handlers.
- Simulation state and transaction coordinator.
- Event registry and event-processing queue.
- Time and scheduling interface.
- Non-player activity scheduler.
- Relevance and simulation-intensity manager.
- Rule and configuration resolver.
- Persistence and record interface.
- Notification and response composer.
- Audit, diagnostics and runtime-health monitor.
- Recovery and consistency-check interface.

Each module has a defined purpose, input contract, output contract, authority boundary, error behaviour, dependencies and version. Modules communicate through documented interfaces rather than relying on hidden shared state or undocumented side effects.

A command or event may involve multiple domain modules. The engine identifies the required participants, checks preconditions, coordinates the operation and records the resulting state changes. A failed downstream operation must not leave an unexplained partial outcome. Where a genuinely distributed or long-running process cannot be atomic, it uses an explicit workflow with pending, completed, failed, compensated or cancelled states.

### Simulation state and authoritative truth
The engine operates on authoritative state obtained from BP-38 records and maintained through BP-39 persistence controls. It must distinguish:
- Current authoritative state.
- Historical state at a specified time.
- Proposed or pending state.
- Temporary working state during an operation.
- Derived or cached state.
- Inferred information with an uncertainty level.
- Player-visible information permitted by role and knowledge.
- Simulation-only internal information not yet known to the player.

A cached or calculated value is not a separate source of truth. If a cache conflicts with an authoritative record, the system follows the declared reconciliation rule and records the discrepancy. Derived values identify their source records, calculation rule and effective time where material.

The engine must never convert a possibility, suspicion, estimate, forecast or unverified report into a confirmed fact without the domain process required to establish it. It preserves distinctions between reported, observed, alleged, inferred, assessed, verified, authorised, completed and adjudicated states.

State transitions are explicit. Each transition identifies:
- The entity and current state.
- The requested new state.
- Preconditions and applicable domain rules.
- Actor or system process initiating the change.
- Required authority and permissions.
- Evidence or supporting records.
- Effective time and processing time.
- Result, reason and any rejected conditions.
- Related events and downstream consequences.

An invalid transition is rejected with a meaningful reason and without silently changing the authoritative state.

### Player command lifecycle
Every player command follows a controlled lifecycle:
1. Receive the command and associate it with the active player identity and session.
2. Preserve the original command text or structured input as required for audit and interpretation.
3. Parse the command and identify the intended action, target and supplied parameters.
4. Resolve ambiguous references using available context without inventing missing facts.
5. Check the player's current identity, status, role, rank, appointment, authority, qualification and permissions as relevant.
6. Identify applicable domain rules, legal constraints, prerequisites and approval requirements.
7. Validate the target entity, current state, location, time and resource conditions.
8. Present a clarification or confirmation request where an essential decision cannot safely be inferred.
9. Execute the authorised action or create a pending request for the competent decision-maker.
10. Apply the resulting state transitions through the transaction coordinator.
11. Emit linked events and required audit records.
12. Trigger eligible downstream processes and notifications.
13. Return a response that distinguishes completed action, pending action, rejected action, unavailable information and system failure.

A command is not successful merely because it was understood or acknowledged. The response must reflect the actual persisted outcome. If an action requires approval, the engine reports it as submitted or pending rather than approved. If a process fails, the engine must not claim that the requested state change occurred.

The player may use natural language, structured commands or interface controls as defined by BP-40. Different input forms that represent the same authorised action must resolve to the same domain operation and validation rules.

### Command identity, idempotency and duplicate prevention
Each executable command receives a unique command identifier. The engine uses idempotency controls so that repeated delivery of the same command does not unintentionally create duplicate arrests, reports, payments, evidence exhibits, appointments, purchases, messages or other consequential records.

A repeated command is assessed against its identity, payload and prior outcome. The engine distinguishes:
- A transport retry of the same command.
- A player deliberately submitting a new command.
- A repeated request that is legally or operationally permitted.
- A duplicate action that would create an invalid second outcome.
- A correction or reversal that must be recorded as a new linked action.

Idempotency keys have defined scope and retention. They do not prevent a legitimate new action merely because its wording resembles an earlier command. Where the engine cannot determine whether a request is a retry or a new action, it requests clarification or presents the existing result.

### Event model and event lifecycle
Events represent meaningful occurrences, decisions, observations, state changes, scheduled triggers and system outcomes. Each event has a unique identifier and, as applicable:
- Event type and schema version.
- Source and initiating actor.
- Affected entities and relationships.
- Event time and processing time.
- Location and jurisdiction.
- Preconditions and triggering condition.
- Evidence, source references and confidence.
- Visibility and access classification.
- Causal parent, correlation and related event identifiers.
- Processing status and retry information.
- Resulting state changes.
- Audit and provenance information.

Events may be:
- Player-initiated.
- NPC-initiated.
- Scheduled.
- Environment or world-generated.
- Triggered by a preceding event.
- Received from an authorised external or institutional interface.
- Generated by a system process.

An event is not automatically a confirmed occurrence merely because it exists in the event store. Event status and evidential meaning are determined by the relevant domain rules. A report that a crime occurred is distinct from a verified incident, an allegation is distinct from a finding, and a simulated possibility is distinct from a realised event.

Events move through defined states such as created, validated, queued, processing, completed, rejected, failed, retrying, cancelled or superseded. Invalid events are quarantined or rejected with a reason; they are not silently discarded. Event handlers record completion so that retries do not duplicate effects.

### Event ordering and causal consistency
The engine preserves causal relationships. If event B depends on event A, B cannot be treated as having occurred before A has reached the required state. The system records event time separately from processing time so that late reports, delayed imports, corrections and retrospective entries do not rewrite the actual sequence.

Where several events occur at the same simulated time, the engine uses a documented deterministic ordering rule based on dependency, event priority, source sequence and stable identifiers. It must not rely on arbitrary database retrieval order or nondeterministic race conditions.

The system handles:
- Simultaneous calls and competing response tasks.
- Multiple officers acting on the same incident.
- Conflicting updates to one person or property.
- Concurrent evidence submissions.
- Time-sensitive warrants, orders and authorisations.
- Competing resource allocations.
- Delayed communications and late-arriving information.
- A player action that becomes invalid while awaiting approval.
- Events that are valid individually but incompatible together.

Conflicting operations are serialised, rejected, merged under an explicit domain rule or referred for competent review. The engine must not silently choose one outcome without recording why.

### Simulation time and processing cycles
BP-37 is authoritative for the game clock, calendar, time zones, time advancement, shift schedules and scheduled commitments. BP-35 requests or coordinates processing for an authorised time interval but cannot invent a different clock or independently advance time outside BP-37 rules.

The engine supports distinct processing concepts:
- Real interaction time: when a player submits or receives a command.
- Simulation event time: when an in-world event occurs.
- Processing time: when the engine calculates or records the event.
- Effective time: when a state or authority legally or operationally takes effect.
- Historical time: the time represented by a retrospective record.

The engine supports controlled processing cycles, event-triggered execution and scheduled jobs. The exact tick length, batch size, frequency and time-advancement model remain configurable under BP-37 and BP-44.

No background process may silently advance the in-world clock merely because real time has passed. Offline or unattended progression is permitted only if a future approved rule explicitly defines its scope, consequences, player notice and recovery behaviour. Until then, the engine processes only time advancement authorised through the game rules and player/session lifecycle.

A scheduled event is not automatically executed merely because its nominal time has arrived. The engine checks whether time has validly advanced, the event remains active, prerequisites are met, the responsible actor or service is available and the action remains lawful.

### Non-player character simulation
The engine coordinates non-player character activity using the authoritative person identities and life, employment, relationship, location and schedule information owned by the relevant divisions.

An NPC may have:
- A current activity and location.
- A routine or planned schedule.
- Needs, goals or commitments represented by approved domain rules.
- Relationships and social context from BP-36.
- Knowledge, beliefs and information limitations.
- Available resources and constraints.
- Employment, legal, health or other status relevant to the current action.
- A decision process appropriate to the simulation detail required.

NPC behaviour must be plausible, context-sensitive and bounded by what the individual could know, access, afford, physically do and lawfully do. A character must not act on information they have not received or inferred through a defined process. The engine must not give every NPC omniscient knowledge of the player's actions, hidden case facts or events outside their awareness.

NPCs are not random action generators. Their behaviour should reflect established routines, immediate circumstances, relationships, incentives, obligations, risks and prior events. Randomness may introduce uncertainty but must not override established facts or create arbitrary contradictions.

The engine supports different activity-processing levels according to relevance, current activity and required detail. Lower processing intensity does not erase identity, history, relationships or obligations. When an NPC becomes relevant to a police incident, case, decision or other defined trigger, the engine can increase processing detail while retaining the same persistent identity and historical record.

### Relevance and simulation-intensity management
Simulation intensity is a processing decision, not a change in a person's existence or record status. The engine may use levels such as:
- **Background:** persistent identity and essential state retained; routine changes processed in aggregate or through scheduled summaries where safe.
- **Active:** detailed activity, location, availability and relevant interactions processed for a current context.
- **Focused:** high-detail processing for a person, location, organisation or event directly involved in an active police or institutional process.
- **Critical:** tightly controlled high-frequency processing for time-sensitive, safety-critical or multi-actor situations.

The exact levels, triggers and processing budgets are configuration decisions. A person or entity must not be downgraded in a way that loses material history, evidence, obligations, relationships or case relevance. A change in processing level does not itself change legal status or factual certainty.

Relevance triggers may include:
- Direct involvement in an incident or case.
- Presence at or near a relevant location during a material period.
- A witness, victim, suspect, officer or other documented connection.
- A relationship or organisational link relevant to an active enquiry.
- A scheduled duty, emergency, safeguarding or legal obligation.
- A direct player interaction or authorised institutional action.
- A credible lead or event requiring further resolution.

The engine records why an entity's processing level changed, who or what triggered it, when it changed and which processes are affected. Relevance must not be used to expose restricted information or to presume wrongdoing.

### NPC decision-making, knowledge and uncertainty
NPC decisions use a bounded information model. Each character's knowledge is based on direct observation, communication, authorised access, memory and plausible inference. The engine distinguishes:
- What actually happened in the simulated world.
- What a character observed.
- What a character was told.
- What a character believes.
- What a character remembers.
- What a character reports.
- What an institution has verified.
- What the player is currently authorised to know.

An NPC may be mistaken, deceptive, uncertain, forgetful or incomplete, but these behaviours must arise from defined circumstances rather than arbitrary narrative convenience. The engine records the source and basis for important knowledge claims when they affect a case, decision or consequential outcome.

Uncertainty is represented explicitly where material. The system must not invent precise confidence percentages unless a calibrated model and approved interpretation exist. Qualitative confidence levels may be used where the relevant domain defines them.

### Crime and incident generation interfaces
BP-13 and BP-14 define crime categories and crime-generation rules. BP-35 executes those rules and coordinates resulting incidents; it does not create a separate uncontrolled crime system.

Generated crime and incident events must respect:
- The established population and geographic model.
- Time, location, access and physical constraints.
- Person capabilities, routines and knowledge.
- Business and institutional opening or operating conditions.
- Applicable legal and domain rules.
- Existing case facts and historical continuity.
- Victim, witness, suspect and offender identity consistency.
- Plausible cause, opportunity, action and consequence relationships.

A generated event receives the records required by its domain. It must not automatically create a known offender, prove an offence, reveal a hidden culprit to the player or force a predetermined investigative outcome. The engine preserves the distinction between the underlying simulated truth and what police can establish through lawful investigation.

### Resource and action coordination
When an action requires an officer, vehicle, facility, equipment, specialist, budget, authorisation or other resource, the engine checks the authoritative availability and assignment rules owned by the relevant division.

A resource cannot be allocated to incompatible simultaneous tasks unless a domain rule permits shared use. A person cannot be in two locations at once. A vehicle cannot be both available and assigned to an active deployment. An expired qualification, revoked authority, unavailable facility or unserviceable asset must be considered before the action proceeds.

Where a task requires multiple resources, the engine records reservations, assignments, release and failure. Temporary reservations have expiry and cancellation rules. A failed operation releases or reconciles reserved resources so that they do not remain indefinitely unavailable.

### Rules, configuration and version control
The engine executes approved rules and configuration versions. Each consequential operation can identify the rule set and configuration version applied. A configuration change has an owner, approval, effective date, scope, reason, test evidence and rollback or supersession plan.

The engine must not silently change legal thresholds, offence definitions, staffing rules, financial limits, qualification requirements, time rules or other domain constants. Such values belong to the relevant domain and approved configuration process.

Where a rule changes, historical events remain interpretable under the rule version applicable at the time unless an authorised retrospective correction is explicitly required. The engine records the old and new versions and any migration or recalculation.

### Failure handling and degraded operation
The engine must detect and handle:
- Invalid command or event payload.
- Missing or inconsistent authoritative records.
- Unavailable domain module or database.
- Failed transaction or partial workflow.
- Duplicate event delivery.
- Dependency timeout or unavailable external service.
- Conflicting concurrent updates.
- Expired permissions or authority during processing.
- Invalid configuration or schema version.
- Queue backlog or repeated processing failure.
- Corrupted or incomplete derived data.
- Clock or scheduling inconsistency.
- Recovery from a prior interrupted operation.

Errors are classified by severity, scope, retryability and user impact. Safe retries are bounded and idempotent. Non-retryable failures are quarantined for review. A failed action reports its actual status and does not imply success.

During degraded operation, the engine may permit only functions that can be performed safely with available authoritative data and permissions. It must block high-impact actions where current authority, identity, evidence integrity or state cannot be verified. Any permitted manual or emergency workaround is recorded and reconciled after service restoration.

### Runtime monitoring and performance
The engine monitors:
- Command volume and response time.
- Event queue depth and processing delay.
- Failed, retried and quarantined events.
- Transaction conflicts and rollback frequency.
- NPC processing load by intensity level.
- Scheduled task backlog.
- Database latency and persistence failures.
- Cache consistency and invalidation.
- Resource reservations and stale assignments.
- Rule or configuration errors.
- Runtime exceptions and recovery outcomes.

Performance optimisation must not change domain outcomes, erase history or reduce the detail required for an active case. Background processing may be batched or deferred only where doing so preserves time, causal and operational correctness.

The engine uses defined resource limits and back-pressure. When capacity is reached, it prioritises safety-critical and time-sensitive work under an approved priority model, while preserving lower-priority work for later processing. It must not silently drop events or commands to remain responsive.

### Player agency, information boundaries and fairness
The engine supports player decisions without predetermining every outcome. It enforces the player's actual authority and presents consequences based on the established world state, applicable rules and actions taken.

The engine must not:
- Reveal hidden offender or accomplice identities outside the approved game rule.
- Present investigative suggestions as established case facts.
- Alter evidence or witness accounts to force a desired result.
- Give the player information their character could not lawfully or plausibly access.
- Resolve an action before required approvals or procedures are complete.
- Penalise a player through arbitrary hidden rule changes.
- Treat a failed action as completed.
- Allow NPCs or systems to bypass the same material constraints applied to the player.

The response layer distinguishes fact, report, inference, uncertainty, pending process and system limitation. The player may request records or take investigative actions, but the engine does not reveal a case solution merely because an internal simulation process knows the underlying truth.

### Connections to other divisions
- **BP-01 to BP-04:** governing rules, geography, population, identity, properties, businesses and organisations.
- **BP-05 to BP-09:** police structure, personnel, career, deployment and resources.
- **BP-10 to BP-12:** patrol, communications, dispatch and incident execution.
- **BP-13 to BP-29:** crime, cases, investigation, evidence, justice and correctional domain rules executed by the engine.
- **BP-30 to BP-34:** governance, professional standards, training, HR, finance and procurement controls.
- **BP-36:** relationship, social-context and interpersonal state.
- **BP-37:** authoritative clock, calendars, time advancement, schedules and event timing.
- **BP-38:** authoritative schemas, identifiers, records, relationships and data validation.
- **BP-39:** persistence, transaction durability, backup, recovery and continuity.
- **BP-40 and BP-41:** player commands, interface responses, notifications and reports.
- **BP-42:** identity, authentication, authorisation, access restrictions and audit security.
- **BP-43:** unit, integration, simulation, performance, regression and acceptance testing.
- **BP-44:** configuration, scenario settings, controlled extensions and version compatibility.

### Exceptions and edge cases
The design must handle ambiguous commands; duplicate submissions; interrupted player sessions; simultaneous player and NPC actions; event arriving late; two events with the same nominal time; conflicting identity matches; an NPC becoming relevant during a background cycle; a person whose record is incomplete; a person whose identity is uncertain; a person with multiple legal or employment statuses; unavailable or expired authority; a warrant or order changing during processing; a resource being allocated elsewhere; an incident generated during a major event; a crime report later found false or mistaken; a witness changing an account; a correction to a historical record; an event requiring multiple domain systems; a downstream module failing after an earlier step; partial payment or delivery; a scheduled action whose prerequisites fail; a time advancement request that conflicts with a pending critical event; a long-running simulation process; a queue backlog; database outage; corrupted cache; stale configuration; incompatible schema version; restoration from backup; duplicate replay after recovery; loss of external service; NPC knowledge leakage; hidden case truth exposed through a notification; high-volume public event; mass-casualty incident; simultaneous emergencies; and a player action that is valid when submitted but no longer valid when execution begins.

Each exception has a defined owner, safe response, retry or review route, state-preservation rule and audit record. The engine must preserve enough context to explain what happened and why.

### Acceptance conditions
- Every player command is identified, validated, authorised, executed and reported through a controlled lifecycle.
- Acknowledgement is never confused with successful completion.
- Domain rules remain owned by their designated blueprint divisions.
- Authoritative state is distinct from cache, inference, pending change and historical state.
- Invalid state transitions are rejected with an explainable reason.
- Consequential events have unique identities, schemas, provenance, timing and causal links.
- Event ordering is deterministic where dependencies or simultaneous actions require it.
- Duplicate delivery and retry do not create duplicate consequential outcomes.
- NPC behaviour respects identity, knowledge, capability, location, schedule and established facts.
- Processing intensity can change without deleting identity, history or relevance.
- A relevant entity can receive increased processing detail while retaining the same persistent identity.
- No background process silently advances game time outside BP-37 rules.
- Resources and authorities are checked before consequential actions proceed.
- Failed or partial workflows have explicit states and reconciliation rules.
- Rule and configuration versions are traceable for consequential outcomes.
- Degraded operation blocks actions that cannot be safely validated.
- Runtime monitoring detects backlogs, failures, conflicts and persistence problems.
- Player-visible information respects character knowledge, role permissions and case-information boundaries.
- Performance optimisation preserves material simulation correctness and historical continuity.
- The engine can be tested reproducibly against defined scenarios and acceptance criteria.

**Draft status:** BP-35 is a working design. The exact runtime architecture, command grammar, event catalogue, state-transition contracts, simulation-intensity thresholds, NPC decision model, randomisation and reproducibility policy, processing-cycle size, priority model, concurrency strategy, queue technology, error taxonomy, performance targets and implementation language remain open. No simulation engine, command processor, event queue, NPC runtime, scheduler, game API or playable application has been implemented by this design document.


---

## BP-36 — Relationships and Social Context

### Purpose and scope
Define the persistent relationship, household, family, social-network and community-context models that make people and organisations part of a believable living world. BP-36 records how people are connected, how those connections change, what each person knows about them and how social context may affect activity, welfare, opportunity, vulnerability and police-relevant events.

BP-36 covers:
- Personal, family, household and domestic relationships.
- Friendship, acquaintance, neighbour, colleague and professional relationships.
- Relationship formation, change, separation, dispute and termination.
- Household membership, shared residence and domestic arrangements.
- Social groups, clubs, associations, communities and informal networks.
- Organisational and community affiliations where relevant.
- Contact history and interaction context where lawfully and appropriately recorded.
- Relationship knowledge, uncertainty, disagreement and source provenance.
- Social context relevant to routines, support, safeguarding and police activity.
- Relationship privacy, access restrictions and sensitive-information safeguards.
- Relationship history, event linkage and continuity.

BP-36 does not replace:
- BP-03 for person identity, population status and individual life records.
- BP-04 for property occupancy, business ownership, employment and organisational identity.
- BP-06 and BP-33 for authoritative police personnel and employment records.
- BP-17 and BP-18 for victim, witness, suspect and offender legal or case status.
- BP-21 for intelligence records, source handling and intelligence assessment.
- BP-31 for police employee conduct, conflicts, inappropriate relationships and professional standards.
- BP-35 for runtime execution and NPC decision processing.
- BP-37 for time, schedules and event timing.
- BP-38 and BP-39 for authoritative records, persistence, access and recovery.
- BP-42 for permissions and security.

A relationship is not proof of knowledge, agreement, assistance, responsibility, criminal involvement or shared belief. Association with a suspect, victim, witness, employee, business or organisation must never by itself establish suspicion or justify adverse treatment. Social context may inform a lawful and proportionate enquiry but cannot replace evidence or the applicable legal threshold.

The exact fictional family law, marriage and civil-status rules, data-protection framework, safeguarding law, social-service arrangements and disclosure rules remain to be defined. BP-36 establishes the data and simulation requirements without inventing legal status or rights.

### Relationship model and identity
Every relationship links existing persistent person or organisation identities. It does not create duplicate people or use names alone as identity keys. The relationship record has its own stable identifier and identifies:
- The linked person or organisation identities.
- Relationship category and any defined subtype.
- Directionality or reciprocity.
- Current status and historical status.
- Start date, end date and date first known where available.
- Source, basis and verification status.
- Confidence or uncertainty representation where appropriate.
- Whether each involved person knows or acknowledges the relationship.
- Relevant scope, context and limitations.
- Privacy and access classification.
- Related events, cases or supporting records where authorised.
- Creation, review and change history.

Relationships may be reciprocal, one-way, asymmetric, disputed, unknown to one party or different in meaning to each participant. A person may regard another as a friend while the other regards them only as an acquaintance. The system must not force false reciprocity.

The relationship model distinguishes the real-world relationship from the record about it. A relationship may exist without being known to police; a record may be incomplete or mistaken; a person may dispute the description; and the relationship may have ended before the record was created. These conditions are represented explicitly.

### Relationship categories
The configurable relationship catalogue may include:
- Parent, child, guardian and dependent.
- Spouse, civil partner or other legally recognised partner.
- Former spouse or former partner.
- Sibling, grandparent, grandchild, aunt, uncle, cousin and other family relationship.
- Foster, adoptive, step-family and other care relationships.
- Household member, co-resident, lodger and former co-resident.
- Friend, close friend, acquaintance and social contact.
- Neighbour and local community contact.
- Colleague, supervisor, subordinate and professional contact.
- Employer, employee, contractor and business associate.
- Client, customer, supplier and service-provider relationship.
- Club, association, faith or community group affiliation where lawfully represented.
- Advocate, carer, support worker, mentor and other support relationship.
- Creditor, debtor, landlord, tenant and other civil or commercial relationship.
- Witness-to-event, reporting-person-to-incident and other event-specific connections.

The catalogue is extensible under BP-44 but changes must preserve historic meanings. Legal relationships and informal social descriptions remain distinct. For example, a biological parent, legal guardian, adoptive parent and person acting as a carer are not automatically interchangeable.

Relationship categories must be neutral and precise. The system does not use vague labels such as "known criminal", "bad associate" or "person of interest" as social relationships. Case roles and intelligence assessments remain in their designated domains.

### Household and domestic context
A household is a time-bounded domestic arrangement, not simply a list of people with the same postal address. The model may represent:
- People who usually live together.
- Temporary or seasonal residents.
- Children and dependants.
- Shared-care arrangements.
- Lodgers and subtenants.
- People who share facilities but maintain separate households.
- People who are away temporarily but retain a household connection.
- People who have moved out but remain connected through family or care responsibilities.
- Multiple households within one property or unit.
- A person with more than one relevant residence or household connection.

Household membership has effective dates, role or relationship description, source and confidence. The system distinguishes registered address, usual residence, temporary address, mailing address, place of stay and household membership. A shared address does not prove a relationship, and a relationship does not prove that people live together.

Household composition can change through birth, death, separation, marriage, care arrangements, relocation, temporary absence, eviction, institutional residence or other events. Historical household membership remains available where relevant; current membership is not retroactively imposed on earlier dates.

### Family, care and dependency relationships
Family and care records distinguish legal responsibility, biological or adoptive relationship, social relationship and actual care activity. The system may record:
- Parentage and legal guardianship where lawfully established.
- Parental responsibility or equivalent legal status.
- Shared or supervised care arrangements.
- Foster, adoption and kinship-care arrangements.
- Adult or child dependants.
- Informal carers and support networks.
- Emergency contacts and nominated support persons.
- Relevant care restrictions or safeguarding arrangements.

A family relationship does not automatically confer legal authority to make decisions, access records, receive confidential information or act for another person. The relevant legal status and scope must be separately verified. A nominated emergency contact is not automatically a guardian or decision-maker.

Children and vulnerable persons receive additional safeguards. Information is limited to the purpose and role that justify access. A family member may be a source of support, a witness, a person of concern or a subject of an allegation; the system must not presume that family status guarantees safety or trustworthiness.

### Social groups and community affiliations
The model may represent formal and informal groups such as sports clubs, neighbourhood associations, charities, educational groups, professional bodies, cultural organisations, community networks and other relevant associations.

A group record identifies its stable identity, type, purpose, operating area, status, relevant contact points and history. Membership or affiliation records link people to the group with dates, role, source, status and applicable privacy classification.

Membership alone is not evidence of misconduct, shared intent, knowledge of another member's actions or responsibility for an event. The system must not infer a person's beliefs, conduct or risk solely from group membership. Lawful association and ordinary community activity must not be treated as suspicious.

Political, religious, trade-union, health-related or other particularly sensitive affiliations must not be collected or exposed merely because the system can model relationships. Any exceptional recording requires a defined lawful in-game purpose, necessity, proportionality, access restriction and review under the applicable rules.

### Relationship lifecycle and historical change
A relationship may be proposed, recorded, verified, disputed, corrected, suspended for a defined purpose, ended or superseded. The lifecycle records:
- Initial report or source.
- Date the relationship is said to have begun.
- Date the service learned of it.
- Verification steps and result.
- Acknowledgement or dispute by involved parties where known.
- Changes in category, scope or status.
- End date and reason where known and appropriate.
- Correction or retraction history.
- Review date and responsible record owner.

A relationship record is not silently overwritten when new information arrives. If an earlier record was wrong, the correction preserves the original assertion, the reason for correction, the source of the new information and the effective date of the corrected fact.

The system distinguishes a relationship ending from a record being deleted. Historic relationships may remain relevant to an event, case, safeguarding decision or legal process. Retention and access follow BP-38, BP-39 and BP-42.

### Knowledge, awareness and information flow
The system distinguishes:
- The underlying relationship, if known to the simulation.
- Each participant's awareness of the relationship.
- Each participant's description or understanding.
- What another person has disclosed.
- What an institution has recorded.
- What is verified or disputed.
- What the player is permitted to know.

An NPC cannot automatically know every relationship in the database. Knowledge may arise from personal experience, observation, conversation, public information or another defined source. A person's knowledge may be incomplete, outdated or mistaken.

A disclosure or introduction creates an information event only for the participants and recipients who could plausibly receive it. The engine must not propagate private relationship information to unrelated people or institutions without a defined communication or lawful access route.

Where a relationship is relevant to a case, the record identifies whether it is established fact, self-report, third-party report, inference or unverified lead. A case connection does not automatically convert the social relationship into a verified fact.

### Social context and simulation behaviour
BP-35 uses relationship and social-context records to support plausible NPC activity. Social context may influence:
- Household routines and shared responsibilities.
- Visits, meetings and ordinary social activity.
- Support, care and assistance.
- Communication and information flow.
- Employment and professional interaction.
- Disputes, separation and changing social arrangements.
- Witness availability and familiarity with a person or place.
- Safeguarding needs and possible sources of support.
- Opportunity, access and familiarity where relevant to an incident.
- Community participation and local events.

These factors influence behaviour probabilistically or through explicit scenario rules; they do not determine it. A relationship does not guarantee contact, cooperation, loyalty, conflict or shared knowledge. People may act independently of family, friends or group expectations.

Social context must not become a deterministic suspicion score. The engine may use relationships to identify possible lines of enquiry or relevant context only where the applicable domain rules permit it. Any consequential decision must be supported by the evidence and legal standard required by that domain.

### Police and case relevance
Relationship information may become relevant where it helps establish:
- A victim's support network or safeguarding needs.
- A witness's familiarity with a person, location or event.
- A suspect's documented connection to a location or person.
- A conflict, motive allegation or prior relationship requiring investigation.
- A household or care arrangement relevant to welfare.
- A professional or financial connection relevant to an integrity enquiry.
- A contact or association that may explain a communication or meeting.
- A relationship that creates a conflict of interest for an officer or decision-maker.

Relevance is specific to the matter and time period. A current relationship cannot automatically be projected backwards. A historic relationship cannot automatically be treated as current. A connection to one case does not make every connected person relevant to every other case.

The system records why a relationship is relevant, who established the connection, which case or process uses it, the date range and any limitations. Access to relationship information is purpose-limited and subject to lawful authority.

### Disputes, coercion and safeguarding
Relationships may involve conflict, coercion, dependency, abuse, exploitation, intimidation, estrangement or safety concerns. These are not assumed from relationship type. They are recorded through appropriate safeguarding, incident, intelligence, investigative or legal processes with their own evidence and access controls.

The system supports:
- A person disputing a recorded relationship.
- A relationship described differently by different participants.
- Separation where one party continues unwanted contact.
- Protective or non-contact arrangements where lawfully imposed.
- A person whose location or contact details require heightened restriction.
- Domestic or family safeguarding concerns.
- Child or adult safeguarding referrals.
- A support person who may also be a witness or subject of an enquiry.
- Conflicting accounts of care, residence or responsibility.
- A relationship that changes during an active case.
- A person at risk from another person who shares a household or social network.

Protective restrictions must be linked to the correct legal or safeguarding authority. The relationship system does not create restraining orders, custody powers or contact prohibitions. Those remain within the appropriate legal and operational domains.

### Privacy, access and correction
Relationship information can reveal sensitive personal circumstances. Access is restricted by purpose, role and legal authority. Users see only the relationship detail necessary for their assigned task.

The system supports:
- Restricted or sealed relationship records where authorised.
- Protection of child, victim, witness and safeguarding information.
- Limited disclosure of sensitive affiliations.
- Separation of personal social records from police intelligence and case allegations.
- Access logging and review.
- Correction requests and disputed-record flags.
- Retention and legal-hold controls.
- Safe handling of records where disclosure could create a risk of harm.

A person may be able to request access or correction under the fictional legal framework, subject to lawful exemptions and third-party rights. A correction must preserve provenance and must not expose another person's protected information without authority.

### Player experience and authority
The player may view or record relationship information only where their role, purpose and permissions allow it. A player may record a reported family connection, identify a witness's stated familiarity with a person, update an authorised household enquiry, submit a correction request or refer a safeguarding concern.

The interface distinguishes:
- Verified relationship from reported or inferred relationship.
- Current relationship from historical relationship.
- Legal status from informal description.
- Household membership from shared address.
- Relationship existence from knowledge of that relationship.
- Social association from case involvement.
- A safeguarding concern from a proven allegation.
- A relationship record from a legal order or authority.

The player cannot create a legal guardianship, change civil status, impose a contact restriction, access protected records or make an adverse decision solely because a relationship exists. Where the record is disputed or uncertain, that limitation is visible.

### Connections to other divisions
- **BP-01 to BP-04:** governing principles, population, person identity, property, household location and organisations.
- **BP-05 to BP-09:** police roles, personnel, employment, deployment and operational resources.
- **BP-10 to BP-18:** incidents, crime, cases, investigation, victims, witnesses, suspects and offenders.
- **BP-19 to BP-24:** interviews, surveillance, intelligence, scenes, evidence and forensic processes.
- **BP-25 to BP-29:** arrest, custody, legal proceedings, court orders and correctional status.
- **BP-30 to BP-34:** governance, professional standards, training, employment and financial relationships.
- **BP-35:** NPC knowledge, behaviour, relevance and event execution.
- **BP-37:** time-bounded relationship changes, household routines and scheduled contact.
- **BP-38 and BP-39:** authoritative relationship records, history, retention, persistence and recovery.
- **BP-40 and BP-41:** authorised relationship views, notices, reports and safeguarding alerts.
- **BP-42:** access permissions, sensitive-data restrictions and audit.
- **BP-43:** relationship consistency, privacy, identity-linkage and simulation testing.
- **BP-44:** controlled relationship categories, group types and configuration.

### Exceptions and edge cases
The design must handle uncertain identity; duplicate person records; a relationship reported by one party and denied by another; one-sided or unacknowledged relationships; a person using different relationship descriptions; a relationship that began before either party's current identity record; unknown start or end dates; a relationship ending while a case remains active; a relationship changing during an incident; multiple households at one address; multiple residences for one person; temporary absence; shared custody; disputed parentage; guardianship expiring or changing; informal care without legal authority; a nominated contact who is not a legal representative; a family member who is also a witness or suspect; a support person who creates a conflict; a group membership with uncertain dates; a person leaving or joining a group; a group dissolving; an affiliation recorded in error; sensitive affiliation accidentally exposed; an abusive or coercive relationship; a person at risk from someone in the same household; a protective order with a defined scope; a contact restriction that expires; a deceased person with continuing family links; a missing person whose household details are incomplete; a person whose relationship information is legally restricted; a safeguarding referral with limited disclosure; a relationship graph containing contradictory dates; a correction affecting several linked records; and recovery from a duplicate or corrupted relationship update.

The system must preserve the original and corrected assertions, avoid inferring guilt or legal authority from association, and maintain safe access restrictions during correction or recovery.

### Acceptance conditions
- Every relationship links stable existing person or organisation identities.
- Relationship records have their own identifiers, provenance, status and history.
- Reciprocal, one-way, disputed and differently understood relationships can be represented.
- Legal, biological, household, care, employment and informal social relationships remain distinct.
- Household membership is time-bounded and is not inferred solely from a shared address.
- Current and historical relationships can be reconstructed for a specified date.
- A relationship record distinguishes the underlying relationship from what each person or institution knows.
- NPCs receive relationship knowledge only through plausible and recorded information routes.
- Relationship data supports social simulation without deterministic or arbitrary behaviour.
- Association alone never proves guilt, knowledge, assistance or shared intent.
- Case relevance is specific, time-bounded, sourced and access-controlled.
- Safeguarding, child and vulnerable-person information receives appropriate protection.
- Legal authority and protective restrictions are not created by the relationship system.
- Disputed or corrected relationships preserve provenance and prior assertions.
- Sensitive affiliations are not collected or exposed without a defined lawful purpose and safeguards.
- The player sees the certainty, source, date and limits of relationship information.
- Relationship processing integrates with BP-35 without duplicating identity or authoritative domain records.

**Draft status:** BP-36 is a working design. The fictional civil-status and family-law framework, household definitions, relationship taxonomy, safeguarding law, data-protection rules, social-service interfaces, sensitive-data restrictions, access and correction rights, retention schedules and exact NPC social-behaviour model remain open. No relationship graph, household-management system, social-network engine or dedicated relationship database has been implemented by this design document.


---

## BP-37 — Time and Scheduling

### Purpose and scope
Define the authoritative game calendar, clock, time zones, time advancement, schedules, shifts, appointments, deadlines, recurring events and temporal coordination rules. BP-37 ensures that every event, person, organisation, duty, legal process and simulation action can be placed on a consistent timeline and that time advances only through authorised game rules.

BP-37 covers:
- The authoritative fictional calendar and date representation.
- Game clock, time zones and local-time conversion.
- Simulation-time advancement and pause rules.
- Time intervals, durations, deadlines and effective dates.
- Person, household, business and institutional schedules.
- Police shifts, duty rosters, appointments and availability interfaces.
- Recurring schedules and calendar events.
- Scheduled simulation tasks and event triggers.
- Temporal ordering, overlapping events and conflict resolution.
- Time-sensitive legal, operational, employment and financial obligations.
- Historical and future-dated records.
- Schedule changes, cancellations, exceptions and notifications.
- Time integrity, audit, recovery and testing.

BP-37 is the authoritative owner of in-world time and scheduling semantics. It does not replace:
- BP-10 to BP-12 for operational command, dispatch and incident management.
- BP-06 to BP-09 and BP-33 for personnel status, deployment, resources, attendance and employment facts.
- BP-27 to BP-29 for legal deadlines, court events, sentence calculations and correctional schedules.
- BP-32 for training attendance and course scheduling.
- BP-34 for financial periods, payment schedules and contractual dates.
- BP-35 for runtime processing and event execution.
- BP-36 for social relationships and routine context.
- BP-38 and BP-39 for authoritative storage, persistence, backup and recovery.
- BP-40 and BP-41 for time display, calendars, alerts and notifications.
- BP-44 for approved calendar, time-scale and scheduling configuration.

Domain divisions own the meaning and authority of their deadlines and appointments. BP-37 owns how their dates, times, intervals, recurrence and conflicts are represented and calculated. The simulation engine may execute an authorised time advancement or scheduled event, but it cannot create an independent clock or advance time outside BP-37 rules.

The fictional country's calendar conventions, legal time zone, daylight-saving policy, public holidays, working-time law and exact simulation time scale remain to be approved. BP-37 must not silently assume a real-world jurisdiction's rules.

### Authoritative calendar and clock
The game maintains one authoritative simulation date and time. It is the reference for:
- Incident and event timelines.
- Patrol, dispatch and response activity.
- Person and NPC location and activity.
- Business and institutional operating hours.
- Police shifts, duty rosters and appointments.
- Investigative actions and evidence chronology.
- Warrants, court orders and legal deadlines.
- Training, leave, attendance and employment events.
- Financial periods, invoices, contracts and payment schedules.
- Relationship, household and social events.
- Scheduled world and simulation processes.

The authoritative clock is separate from the user's device clock and real-world elapsed time. A user's local time may be displayed as interface metadata but cannot silently change the fictional game date or time.

The clock record includes:
- Current simulation date and time.
- Calendar and time-zone configuration version.
- Current simulation session or timeline identifier.
- Last authorised advancement operation.
- Previous and resulting clock values.
- Initiating player or authorised system process.
- Advancement amount and reason.
- Related events processed or deferred.
- Integrity and audit status.

There is one authoritative timeline for the game world unless a future approved configuration explicitly introduces a separate scenario or isolated test timeline. Parallel timelines must never be created accidentally through separate sessions or stale cached clocks.

### Calendar and date representation
The calendar configuration defines:
- Calendar system and epoch or starting date.
- Year, month, day and leap-year rules.
- Week structure and first day of the week.
- Date display and parsing conventions.
- Valid date ranges.
- Time-zone identifiers and local-time rules.
- Daylight-saving or seasonal clock changes if applicable.
- Public holidays and institution-specific non-working days.
- Calendar version and effective dates.

Dates are stored and exchanged in an unambiguous machine-readable form. User-facing date formats may follow the configured locale but must not make an ambiguous date appear certain. Where a player enters a date such as 03/04/2027 and the format is not known, the interface requests clarification rather than guessing.

The system distinguishes date-only values from exact instants and local wall-clock times. A court date, leave period, financial period and incident timestamp may have different precision and timezone requirements. A date-only event must not be silently converted into an arbitrary midnight timestamp.

### Time zones and local time
The country and its locations use approved time-zone configuration. Every exact timestamp is stored or normalised using an unambiguous instant representation, with the relevant time-zone identifier retained where local civil time matters.

The system distinguishes:
- Absolute instant on the simulation timeline.
- Local date and time at a location.
- Time-zone offset applicable at that instant.
- Display time for the player.
- Date-only or floating local-time commitments.
- Historical time-zone rule version.

A location's local time is derived from its configured time zone and the applicable calendar rules. The player must not be able to create a different local clock for the same location merely by changing device settings.

If the fictional country uses one national time zone, that is configured explicitly. If future regional time zones or daylight-saving changes are introduced, they require controlled configuration and historical interpretation. The system must correctly handle ambiguous or nonexistent local times during a clock change, using an explicit disambiguation rule.

### Simulation-time advancement
Time advances only through an authorised game operation. The player may request a defined advancement, wait for a stated duration, complete an action that has a defined duration or accept a domain process that advances time under approved rules.

Each advancement records:
- Starting simulation time.
- Requested duration or target time.
- Initiating player or process.
- Reason or command.
- Applicable time-advancement rule.
- Events and schedules eligible for processing.
- Events completed, deferred, cancelled or failed.
- Ending simulation time.
- Any blocked or unresolved condition.

The engine must not advance the clock before validating the request and its consequences. Where a critical event, pending decision, active emergency or unresolved action should interrupt or prevent a requested wait, the relevant domain rule determines whether time advancement is paused, shortened, rejected or continued with a notification.

Time advancement is not the same as completing every scheduled event. Events are processed according to their prerequisites, priorities, availability and domain rules. A task that cannot lawfully or practically occur remains pending, fails or is rescheduled with a recorded reason.

### Pause and unattended operation
The default rule is that simulation time does not advance merely because real time passes or the player closes the game, leaves a conversation, disconnects or is inactive. No NPC schedule, shift, court deadline, business opening, crime event or other in-world event silently progresses during an unattended period.

The clock remains at the last authorised simulation time until a valid advancement operation occurs. On return, the player resumes from the recorded state and is not presented with consequences from unapproved offline progression.

Any future offline-progression feature requires an explicit approved blueprint change defining:
- Which processes may continue.
- Which entities and events are eligible.
- How legal, safety-critical and player-controlled decisions are handled.
- Maximum elapsed simulation time.
- Player notice and consent.
- Resource and performance limits.
- Audit and recovery behaviour.
- How the feature can be paused, disabled or reversed where appropriate.

A background server process may perform technical maintenance, backups or consistency checks without advancing the fictional clock. Technical timestamps must not be confused with in-world time.

### Time advancement and interruption rules
A time-advancement request is evaluated against active conditions. These may include:
- Emergency calls or incidents requiring player attention.
- A player-controlled action that has not completed.
- A pending approval or decision with a time-critical consequence.
- A scheduled duty, appointment or hearing.
- An expiring authorisation or legal instrument.
- A person or resource whose availability changes during the requested interval.
- A scheduled event whose outcome may materially affect the player's current task.
- A safety or continuity condition defined by the relevant domain.

The engine uses the declared priority and interruption rules rather than inventing dramatic interruptions. If time advancement is stopped early, the player receives the actual ending time and the reason. If an event is processed during a permitted wait, the event time and result are recorded before the engine reports the final time.

The system distinguishes a player's deliberate decision to wait from an automatic delay caused by a long-running action. The player is not assumed to have consented to a long wait merely because an operation is pending.

### Time intervals, duration and deadlines
The system supports exact instants, date ranges, durations, recurring periods and deadlines. It distinguishes:
- Start and end instants.
- Inclusive and exclusive date boundaries.
- Calendar days from elapsed 24-hour periods.
- Business days from calendar days.
- Working hours from elapsed time.
- Local civil dates from absolute time.
- Deadline calculation from reminder or notification time.
- Effective date from record-entry date.
- Event occurrence time from report or discovery time.

Deadline rules are owned by the relevant domain. BP-37 provides reliable date arithmetic and calendar services; it does not decide the legal effect of a deadline. Where a legal deadline depends on service, receipt, custody, court order, holiday or other legal event, the domain rule defines the trigger and calculation.

A deadline record includes the source authority, triggering event, calculation rule, start point, duration or target, calendar basis, timezone, due time, responsible actor, status, extensions, suspensions, completion evidence and audit history.

The system must not assume that every deadline expires at midnight. Exact due time, grace period, holiday treatment and extension rules are explicit. If a deadline rule is unresolved, the system marks the calculation as provisional or requests an authorised decision rather than inventing a binding result.

### Effective time and historical records
The system distinguishes:
- **Occurrence time:** when an event actually happened in the simulated world.
- **Effective time:** when a status, appointment, authority or rule takes effect.
- **Recorded time:** when the system received or saved the information.
- **Discovery time:** when an event or fact became known to a person or institution.
- **Processing time:** when the runtime processed the event.
- **Notification time:** when a person or system was informed.

A late report or retrospective correction must not overwrite the original chronology. The record preserves the actual or asserted occurrence time, the time it was entered, the source and any uncertainty.

A retroactive effective date is permitted only where the relevant domain allows it and the authority is recorded. The system preserves both the date the change is said to take effect and the date the decision was made or recorded.

### Scheduling model
A schedule is a structured representation of planned activity. It may apply to a person, unit, vehicle, facility, business, institution, service, event or recurring process.

A schedule record includes:
- Schedule identifier and owner.
- Scheduled entity or resource.
- Activity or commitment type.
- Start and end time or duration.
- Location or service area where relevant.
- Recurrence rule and exceptions.
- Required participants and resources.
- Availability and eligibility conditions.
- Priority and interruption behaviour.
- Responsible organiser or authority.
- Status, version and change history.
- Source and relationship to related records.

The system distinguishes a plan from a confirmed appointment, an assigned duty from actual attendance, an opening-hours rule from an exceptional closure and a scheduled task from a completed action.

Schedules may be tentative, proposed, confirmed, active, completed, cancelled, superseded, missed or disputed. A change creates a dated history entry and does not erase the previous arrangement.

### Person and NPC routines
Person schedules support work, education, care responsibilities, appointments, travel, household routines, social activity, rest and other ordinary activities. A routine is a pattern or expectation, not proof that a person was present at a specific place at a specific time.

The simulation may represent:
- Regular work and shift patterns.
- Variable or flexible working hours.
- School, study and training.
- Household and care commitments.
- Appointments and planned visits.
- Travel and commuting.
- Recurring social activity.
- Rest, sleep and personal time.
- Leave, sickness, absence and temporary changes.

Routine schedules may include uncertainty or variation where the underlying behaviour is not fixed. The engine must not treat a general routine as a verified alibi, attendance record or location fact. Actual presence requires an appropriate event, observation, access record or other source.

A person's schedule is private unless the viewer has a legitimate role and purpose. NPCs know their own commitments and relevant shared arrangements, not every other person's schedule.

### Police duty, shifts and availability
Police duty rosters and employee availability are owned by BP-06, BP-08, BP-10 and BP-33 as applicable. BP-37 provides the time and scheduling framework used by those systems.

A duty schedule distinguishes:
- Planned roster.
- Published or confirmed roster.
- Actual attendance.
- Assignment or deployment.
- Training or other commitment.
- Leave and absence.
- Overtime and additional duty.
- Rest period and availability.
- Temporary change or emergency recall.

A rostered shift does not prove that an employee attended or was available throughout it. Actual attendance and duty status are recorded through the relevant personnel and operational processes. A person cannot be assigned to incompatible simultaneous duties or locations unless an explicitly permitted shared or remote function applies.

Shift changes, overtime, emergency recall, rest and working-time limits are governed by the applicable BP-33 and operational rules. BP-37 calculates overlap and timing but does not invent labour-law limits or grant operational authority.

### Unit, resource and facility schedules
Schedules may be attached to units, vehicles, equipment, stations, custody facilities, courts, training venues, hospitals, businesses and other institutions.

They support:
- Planned service hours.
- Staffing and coverage windows.
- Vehicle or equipment reservations.
- Maintenance and inspection windows.
- Facility occupancy and availability.
- Training sessions and course capacity.
- Court hearings and other institutional appointments.
- Planned closures and emergency restrictions.
- Delivery, collection and service appointments.

A schedule does not override the authoritative operational status of a resource. A vehicle scheduled for use may be unserviceable; a facility scheduled to open may be closed by an emergency; a unit rostered for duty may have insufficient available staff. The engine checks current state and records the resulting exception.

### Recurrence and calendar rules
Recurring schedules support daily, weekly, monthly, annual and rule-based patterns, with explicit start, end, interval, selected days, occurrence count and exception dates.

The system supports:
- A recurring event with a defined end date.
- A recurring event with a maximum number of occurrences.
- Excluded dates and one-off exceptions.
- Changed individual occurrences.
- Public holidays and institution-specific closure rules.
- Different local times across time zones.
- Recurrence changes that preserve previous occurrences.
- Cancellation of future occurrences without deleting past events.

Recurrence is expanded or calculated under controlled rules. It must not create an unbounded number of records without limits. A schedule change identifies whether it changes only future occurrences or also corrects historical entries.

### Conflicts, overlaps and capacity
The scheduling service detects:
- A person assigned to two incompatible activities.
- A vehicle or equipment item reserved for multiple exclusive tasks.
- A room or facility double-booked beyond capacity.
- A required participant who is unavailable.
- An appointment outside operating hours.
- A duty that conflicts with leave, sickness or training.
- Insufficient rest or prohibited working-time overlap under approved rules.
- A schedule that conflicts with a legal deadline or court order.
- A recurring event whose occurrence falls on an excluded date.
- A time-zone or daylight-saving ambiguity.
- A resource reservation that remains active after cancellation or failure.

A conflict is not always automatically resolved. The system identifies the conflict, affected records, priority, rule and competent decision-maker. Resolution may involve rescheduling, reassignment, cancellation, authorised override or escalation. The original schedule and decision history remain available.

Capacity rules are owned by the relevant domain. BP-37 can calculate the number of overlapping reservations or available time slots but cannot decide that an operational unit has sufficient staffing, a court has legal jurisdiction or a facility meets safety standards.

### Appointments, reminders and notifications
An appointment record identifies the organiser, participants, purpose, location, time, duration, required preparation, status and authority. Invitations, acknowledgements and attendance are distinct events.

Reminders and notifications are generated through BP-41 using schedule data. A notification does not change the underlying appointment or deadline. Delivery failure does not automatically cancel the event or extend a deadline.

The system supports:
- Advance reminders.
- Changes and cancellations.
- Overdue or missed appointment notices.
- Conflict alerts.
- Deadline warnings.
- Required attendance or preparation notices.
- Escalation to a supervisor or responsible institution where authorised.

The reminder schedule is configurable and must not be confused with the actual due time. Sensitive appointment details are limited to recipients with a legitimate need to know.

### Domain-specific temporal interfaces
BP-37 provides common timing services while each domain defines its own event and deadline rules.

Examples include:
- **Police operations:** shift start and end, patrol activity, response timing, appointments and operational task windows.
- **Emergency communications:** call receipt, dispatch, arrival, updates and closure timestamps.
- **Investigations:** incident occurrence, report, interview, surveillance period, warrant validity and evidential chronology.
- **Legal processes:** filing, service, hearing, custody and statutory deadlines.
- **Corrections:** sentence start, credit periods, eligibility dates and release scheduling under BP-29 rules.
- **Training:** course dates, attendance, assessment and qualification expiry.
- **Human resources:** working time, leave, sickness, contract effective dates and retirement administration.
- **Finance:** accounting periods, budget cycles, contract milestones, invoice due dates and payment schedules.
- **Relationships and social context:** household changes, visits, appointments and time-bounded affiliations.

Where two divisions use the same date or time, they use the same authoritative representation and record the applicable domain meaning. A timestamp alone does not establish legal validity, attendance, service or completion.

### Player experience and authority
The player can inspect the current simulation date and time, view permitted calendars and schedules, request time advancement, wait for an action, create or change an appointment where authorised, review deadlines and receive conflict or reminder notices.

The interface must display:
- Current simulation date and time.
- Applicable local time zone.
- Whether time is paused or advancing.
- Requested and actual advancement interval.
- Events that interrupted or limited advancement.
- Appointment and schedule status.
- Deadline source and calculation basis where relevant.
- Whether a time is planned, actual, estimated or provisional.
- Any ambiguity or unresolved calendar rule.

The player cannot alter the authoritative clock directly, backdate an event to evade a rule, silently extend a legal deadline or create a schedule that overrides another division's authority. A correction or exception follows the relevant approval and audit process.

### Connections to other divisions
- **BP-01 to BP-04:** game foundations, geography, population, people, properties and organisations.
- **BP-05 to BP-09:** police structure, personnel, careers, units, deployment and resources.
- **BP-10 to BP-12:** patrol, communications, dispatch and incident timelines.
- **BP-13 to BP-29:** crime, investigations, legal deadlines, court events, sentences and correctional schedules.
- **BP-30 to BP-34:** governance, training, employment, finance, contracts and reporting periods.
- **BP-35:** runtime processing, event ordering, NPC activity and authorised time advancement.
- **BP-36:** household, relationship, social and community routines.
- **BP-38 and BP-39:** timestamp storage, temporal history, persistence, backup and recovery.
- **BP-40 and BP-41:** clock display, calendars, reminders, alerts and reports.
- **BP-42:** authority to view or change schedules and protected calendar information.
- **BP-43:** date arithmetic, recurrence, time-zone, interruption and schedule-conflict tests.
- **BP-44:** calendar, time zone, holiday, time-scale and scheduling configuration.

### Exceptions and edge cases
The design must handle ambiguous date input; invalid dates; leap days; calendar-version change; local-time ambiguity; nonexistent time during a clock change; multiple time zones; a date-only record with no exact time; a late report; a retrospective correction; a time advancement request during an emergency; an interruption halfway through a wait; an action whose duration is uncertain; a deadline whose legal trigger is disputed; a deadline falling on a public holiday; a deadline with an unknown extension rule; an expired warrant or authorisation; an appointment changed after notification; a missed appointment; a person scheduled for two locations; an officer recalled during leave; sickness beginning during a shift; training overlapping duty; a vehicle reserved during maintenance; a facility closed unexpectedly; a recurring schedule with an exception; a schedule changed after some occurrences have completed; a schedule with no end date; an event scheduled before its prerequisites are met; a time-zone rule changed retrospectively; a corrupted clock value; a duplicate time-advancement command; a disconnected player; a server restart; a restored database with a stale clock; a notification delivered late; and a long period of inactivity.

The system must preserve the authoritative clock, record every valid advancement, prevent unapproved offline progression and make unresolved temporal conflicts visible.

### Acceptance conditions
- One authoritative simulation clock governs the game timeline.
- The clock is independent of real-world elapsed time and device settings.
- Simulation time advances only through authorised game rules.
- The game does not silently progress while the player is away.
- Calendar, time-zone and date-parsing rules are explicit and versioned.
- Exact instants, local times, date-only values and durations remain distinct.
- Occurrence, effective, recorded, discovery, processing and notification times are separately represented where needed.
- Historical and retrospective records preserve the original chronology.
- Deadline calculation uses the applicable domain rule and does not invent legal consequences.
- Schedules distinguish proposed, confirmed, actual, cancelled and completed states.
- Recurrence and exceptions are controlled, bounded and historically traceable.
- Person routines are not treated as proof of attendance or location.
- Police rosters distinguish planned duty from actual attendance and availability.
- Resource and facility schedules are checked against current operational status.
- Conflicts are detected and resolved by the competent domain authority.
- Reminders and notifications do not alter the underlying event or deadline.
- Time advancement is auditable and can be interrupted or rejected under defined rules.
- The engine can recover the last valid clock state without replaying time advancement twice.
- The player can identify whether a time is actual, planned, estimated or provisional.

**Draft status:** BP-37 is a working design. The fictional calendar, starting date, time zone, daylight-saving policy, simulation time scale, advancement increments, interruption priorities, public holidays, legal deadline rules, working-time law, shift standards, recurrence syntax, reminder defaults, financial period conventions and exact scheduling conflict rules remain open. No authoritative game clock, calendar service, schedule engine, roster scheduler, deadline calculator or time-advancement software has been implemented by this design document.


---

## BP-38 — Records and Databases

### Purpose and scope
Define the authoritative information architecture, record standards, identifiers, database design, relationships, data validation, provenance, audit history, query interfaces and data-governance controls for the simulation. BP-38 ensures that every important person, place, organisation, event, case, item of evidence, decision, resource and institutional process can be represented consistently, linked correctly, retrieved when authorised and preserved as reliable historical information.

BP-38 covers:
- Record architecture and authoritative-source designation.
- Entity identity, unique identifiers and reference conventions.
- Data domains, schemas, relationships and constraints.
- Database organisation and logical data modelling.
- Record lifecycle, versioning and historical state.
- Provenance, source attribution and confidence.
- Data validation, integrity and quality controls.
- Duplicate detection, identity resolution and merge safeguards.
- Query, search, reporting and controlled data access interfaces.
- Audit records and change history.
- Data classification, retention metadata and legal holds.
- Database migrations, schema versioning and compatibility.
- Data import, export, correction and reconciliation.
- Data ownership, stewardship and quality accountability.
- Data dictionaries, schema documentation and interface contracts.

BP-38 is the authoritative design for record structure and database architecture. It does not replace:
- BP-03 and BP-04 for population, person, property, business and organisation domain meaning.
- BP-05 to BP-37 for the substantive records and rules owned by each domain.
- BP-39 for persistence, backups, recovery and continuity operations.
- BP-42 for authentication, authorisation, secrets and security enforcement.
- BP-43 for test strategy, data-quality testing and verification.
- BP-44 for approved configuration and controlled schema or feature expansion.

A database row is not automatically a verified fact. The record must preserve its source, status, effective period, uncertainty and authority. A user interface, cache, report, search index or model-generated summary is not an independent source of truth. The authoritative record and its history remain identifiable.

The implementation must be designed from approved requirements and controlled domain models. It must not create speculative game tables or expose incomplete schemas merely because the Supabase project is available.

### Data-governance principles
The record architecture follows:
- One authoritative identity per real simulated entity within its defined identity domain.
- Clear ownership of each data domain and field.
- Explicit relationships rather than duplicated or denormalised assertions without control.
- Stable identifiers that do not depend on mutable names, addresses or status.
- Preservation of historical facts and prior versions.
- Provenance and source attribution for material assertions.
- Separation of fact, report, allegation, inference, estimate and decision.
- Data minimisation and purpose-limited access.
- Validation at defined system boundaries.
- Referential integrity and controlled lifecycle transitions.
- Traceable corrections rather than silent overwrites.
- Documented schemas and interface contracts.
- Controlled migrations and backward compatibility.
- Recoverability and testability.
- No secret credentials or unrestricted sensitive data in source-controlled files.

The same person, property, business, organisation, case, incident, item or asset must not acquire a second identity merely because a different division or interface creates a new record. Domain-specific records may reference the canonical identity while retaining their own identifiers and lifecycle.

### Data domains and authoritative ownership
The simulation is divided into governed data domains. Each domain has an accountable owner, authoritative record types, permitted consumers, validation rules and change process.

Examples include:
- Population and person identity.
- Geography, addresses, properties and buildings.
- Businesses, organisations and institutional bodies.
- Police personnel, roles, careers and deployment.
- Police resources and operational assets.
- Calls, incidents and dispatch activity.
- Crime events, cases and investigations.
- Victims, witnesses, suspects and offender statuses.
- Interviews, surveillance and intelligence.
- Scenes, evidence and forensic examinations.
- Arrests, warrants, custody and legal proceedings.
- Courts, judgments, sentences and corrections.
- Governance, professional standards and audit.
- Training, qualifications and competence.
- Human resources and employment.
- Finance, procurement, suppliers and contracts.
- Relationships, households and social context.
- Time, schedules and simulation events.
- Runtime commands, event processing and notifications.

A domain owner defines the meaning and lifecycle of its records. BP-38 defines common structural standards and cross-domain linking rules. Where a record has several consumers, only one domain is authoritative for the underlying fact; other domains hold references or clearly labelled derived information.

The domain register identifies:
- Domain identifier and name.
- Accountable design owner.
- Authoritative entities and record types.
- Canonical identifiers.
- Source-of-truth designation.
- Upstream dependencies and downstream consumers.
- Sensitive-data classification.
- Validation and retention rules.
- Schema version and status.
- Approval and review history.

A change to a domain's meaning or authoritative ownership requires impact assessment and approval. Two divisions cannot silently claim conflicting ownership of the same field or status.

### Entity identity and unique identifiers
Every persistent entity has a stable identifier within its identity domain. Identifiers are immutable, unique, non-semantic where practicable and never reassigned to another entity.

The design distinguishes:
- Canonical person identity.
- Police employee or service identity.
- Property, building, unit and location identity.
- Business and organisation identity.
- Incident and call identity.
- Case identity.
- Evidence item and exhibit identity.
- Asset and resource identity.
- Contract, supplier and procurement identity.
- Court matter, order and sentence identity.
- Event and command identity.
- Relationship and household identity.
- Financial transaction and accounting identity.

A person may hold multiple roles or domain records while retaining one canonical person identity. For example, a person may be a police employee, a witness in one case, a victim in another and a household member without becoming four different people.

Domain identifiers may be human-readable for operational use, but the database primary key remains stable and is not derived solely from a name, address, date of birth or mutable classification. Identifier formats, prefixes, check digits and allocation rules are centrally documented and validated.

Identifiers are never reused after deletion, closure, death, retirement, dissolution or archival. A merged duplicate identity retains an auditable redirect or alias history so that old references can be resolved without changing historical records.

### Record structure and common metadata
Where appropriate, records share a controlled set of metadata:
- Stable record identifier.
- Domain and record type.
- Schema version.
- Current status.
- Creation timestamp and creating actor or process.
- Last update timestamp and updating actor or process.
- Effective start and end times.
- Source and provenance references.
- Data classification and access policy.
- Record owner or responsible unit.
- Verification or review status.
- Related entity and event references.
- Retention category and legal-hold status.
- Supersession, correction or merge references.

Not every field is appropriate for every record. Common metadata is applied consistently without forcing irrelevant columns into every table. Domain-specific records retain the fields required by their own purpose.

The system distinguishes a record's current value from its historical versions and from the event that caused the change. A record may have one current state but many historical states and related events.

### Relational data model and integrity
The database uses explicit primary keys, foreign keys, unique constraints, check constraints and appropriate transactional controls to preserve integrity.

Relationships are modelled according to their actual cardinality:
- One-to-one.
- One-to-many.
- Many-to-many through an explicit linking record.
- Time-bounded or effective-dated relationships.
- Optional or uncertain relationships where the domain permits them.

A relationship is not represented by copying a person's name, address or status into multiple unrelated tables as the only link. Where a snapshot is required for historical or legal reasons, the snapshot is clearly identified, dated and linked to the authoritative source.

Referential integrity rules define whether a linked record must exist, whether a link may be absent, how closure or deletion is handled and what happens when a referenced entity is merged or corrected. Cascading deletion is prohibited for consequential police, legal, evidential, financial and personnel records unless a specifically approved lawful rule permits a narrowly scoped operation.

The database must prevent impossible combinations such as:
- An evidence item linked to a nonexistent case or scene where the domain requires that link.
- An employee assigned to a nonexistent unit.
- A payment linked to no identifiable transaction or liability.
- A relationship linking a person to themselves where the category prohibits it.
- An end date earlier than a required start date.
- Two current authoritative identities for the same unique service identifier.
- An invalid status transition or duplicate active exclusive assignment.
- A record whose source or authority is mandatory but missing.

Where integrity depends on complex domain logic, the relevant service validates it within a transaction and records the outcome. Database constraints remain the final protection against invalid writes where the rule can be expressed safely at the database layer.

### Fact, report, allegation, inference and decision
The data model must preserve epistemic distinctions. A material assertion includes an appropriate status such as:
- Reported.
- Observed.
- Recorded.
- Unverified.
- Corroborated.
- Verified.
- Disputed.
- Inferred.
- Assessed.
- Authorised.
- Rejected.
- Superseded.
- Corrected.

The exact vocabulary is domain-specific and controlled. These labels are not a universal linear progression; for example, an inference may remain an inference even when supported by several sources.

A report is linked to its reporter or source where known. An observation identifies the observer, method, time and conditions. A forensic result identifies the method, examiner, quality controls and limitations. A decision identifies the competent decision-maker, authority, reasons and review route.

The system must not allow a model-generated narrative, automatic classification or user-entered allegation to become a verified fact without the domain process required to establish it.

### Provenance and source attribution
Every consequential assertion must be traceable to its source. Provenance may include:
- Direct observation.
- First-party report.
- Third-party report.
- Official document.
- System-generated event.
- Physical or digital evidence.
- Interview or statement.
- External institutional response.
- Authorised import.
- Inference or analytical assessment.
- Correction or retrospective entry.

The provenance record identifies source type, source identity where lawful, acquisition method, date and time, collector or importing process, reliability limitations, linked original artefact and any transformation or redaction.

Imported information preserves the original source reference and import event. A transformed or summarised record links to its source rather than replacing it. Where source material is unavailable, that limitation is recorded.

A source's reliability and the credibility of a particular assertion are separate assessments. A generally reliable source may be mistaken on a specific point; an unverified source may provide information later corroborated. The system does not turn a source rating into automatic truth.

### Temporal and historical records
The record architecture supports effective-dated and event-based history. It distinguishes:
- When a fact was true in the simulated world.
- When the system learned or recorded it.
- When a decision was made.
- When a change became effective.
- When a correction was applied.
- Which schema or rule version governed the record.

Historical queries must be able to reconstruct the relevant state at a specified simulation time and, where required, what the institution knew at that time.

Corrections preserve the previous value, reason, actor, source and effective date. A record is not silently rewritten to make the current version appear as though it had always existed.

For high-consequence domains, event history and record versioning must be sufficient to reconstruct the sequence of decisions and changes. The exact approach may use temporal tables, append-only events, version rows or another documented design, but it must satisfy the acceptance conditions.

### Data quality and validation
Data validation occurs at input, domain-service and database boundaries as appropriate. Validation rules include:
- Required fields and permitted omissions.
- Data type, format, length and range.
- Identifier format and uniqueness.
- Referential integrity.
- Valid enumerated values.
- Date and time consistency.
- Status-transition legality.
- Cross-field and cross-record rules.
- Source and authority requirements.
- Duplicate detection.
- Schema version compatibility.
- Business-rule and legal-rule validation.

Validation errors are specific and actionable. The system distinguishes invalid data, incomplete data, uncertain data and temporarily unavailable data. An incomplete record may be permitted where the domain allows it, but missing mandatory information cannot be hidden by a default or fabricated value.

Data-quality monitoring may identify duplicates, orphan references, invalid dates, missing provenance, stale records, inconsistent statuses and failed synchronisation. Findings have severity, owner, remediation status and evidence of correction.

Quality scores or completeness measures must not be treated as proof that a record is true. A record can be complete and wrong, or incomplete but accurate within its stated limitations.

### Duplicate detection and identity resolution
The system may identify possible duplicate people, properties, businesses, cases, incidents, suppliers or other entities using approved matching rules. A possible match is not automatically a confirmed duplicate.

Identity resolution records:
- Candidate records and matching basis.
- Matching method and confidence or reason.
- Conflicting attributes.
- Reviewer or authorised decision-maker.
- Decision and supporting evidence.
- Canonical surviving identity where a merge is approved.
- Alias and redirect history.
- Records, references and links migrated or retained.
- Date and audit trail.

Automatic merging of consequential identities is prohibited unless a narrowly defined, tested and approved rule makes it safe. Police personnel, victims, witnesses, suspects, offenders, evidence, cases, suppliers and financial identities require appropriate human review when a mistaken merge could cause harm or corrupt legal history.

A merge must preserve the source records and historical references. A mistaken merge must have a controlled reversal or remediation process.

### Search, retrieval and query interfaces
Search and query services provide authorised access to records without bypassing domain permissions. They support:
- Exact identifier lookup.
- Name and alias search where authorised.
- Address, property and organisation search.
- Time-bounded and location-bounded queries.
- Relationship and cross-reference search.
- Case, incident and evidence retrieval.
- Status and workflow search.
- Historical and as-of-time queries.
- Audit and provenance retrieval.
- Structured reporting and export.

Search results must distinguish exact matches, possible matches and no match. A search result does not establish identity or legal status. Sensitive fields may be masked or omitted according to the user's permissions.

Query interfaces use documented request and response schemas, pagination, filtering, sorting and bounded result sizes. Expensive queries are controlled and monitored. Search indexes and caches are derived services; they must be refreshed or reconciled against authoritative data and must not become the only copy of a record.

The system records material access and exports where required by the domain's audit policy. Bulk retrieval of sensitive records requires explicit permission and purpose.

### Data classification and access metadata
BP-38 defines the information classification metadata required by records; BP-42 enforces the security policy.

Classification may distinguish public, internal, confidential, highly restricted, legally privileged, evidentially sensitive, personnel-sensitive, safeguarding-sensitive, commercially sensitive and other approved categories. The final classification scheme is configured under the applicable fictional legal framework.

Classification is assigned according to content, context, source and risk, not merely the table in which the record is stored. A record may contain fields with different sensitivity. Where field-level protection is necessary, the data model supports it without exposing protected values through ordinary queries, logs or exports.

A user's permission to access one record does not automatically grant access to every linked record. Relationship traversal and search results apply the access rules of each referenced domain.

### Database architecture and schema design
The initial implementation is expected to use the connected Supabase PostgreSQL project as the authoritative database, subject to approved technical design and security review.

Schema design considers:
- Clear separation of domain schemas or namespaces where useful.
- Stable primary keys and documented identifier allocation.
- Foreign keys and appropriate referential actions.
- Normalisation for authoritative transactional data.
- Explicit join tables for many-to-many relationships.
- Effective-dated records for changing facts.
- Append-only or versioned audit history for consequential changes.
- Appropriate indexes for expected queries.
- Constraints and transactional functions for critical invariants.
- Row-level security and role design under BP-42.
- Restricted views or controlled functions for safe application access.
- Separation of development, test and production data where supported and approved.
- Migration scripts and schema documentation in GitHub.

JSON or semi-structured fields may be used for genuinely variable or source-preserving data, but must not become an uncontrolled substitute for relational constraints, queryable domain fields or documented schemas. Core identities, statuses, legal references, financial amounts and critical relationships require structured representation.

The project must not expose unrestricted database credentials to the player interface or place service-role keys in public code. Direct database access is limited to trusted server-side processes and approved administrative roles.

### Schema versioning and migrations
Every database change is delivered through a version-controlled migration or another explicitly approved deployment mechanism. A migration records:
- Unique version or sequence.
- Purpose and affected domains.
- Schema objects created, changed or retired.
- Dependencies and ordering.
- Data transformation or backfill.
- Preconditions and postconditions.
- Compatibility and deployment strategy.
- Rollback or forward-repair plan.
- Test evidence and approval.
- Release and deployment result.

Migrations are applied in a controlled order and are not silently edited after release. A correction to an applied migration is delivered as a new migration or controlled repair. The database's migration history is reconciled with the GitHub migration directory.

Destructive changes require explicit impact assessment, backup and recovery validation, data-retention review and approval. A column or table is not dropped merely because a newer interface no longer displays it.

Application and database versions must be compatible. During a staged release, the schema must not break the active application or corrupt records. Where a change requires a coordinated transition, the migration plan defines the order, compatibility window and recovery route.

### Data import, export and interoperability
Imports use a defined mapping, source validation, duplicate strategy, error report and approval. The system preserves the original source file or artefact where lawful and records its provenance, import time, operator and transformation.

Imports are staged and validated before authoritative records are changed. Failed rows are reported without silently discarding them. Partial import is allowed only where the process explicitly defines how successful and failed records are separated and reconciled.

Exports are purpose-limited, access-controlled and recorded where required. They identify export time, requester, scope, format, filters, redactions and any transformations. Sensitive data is not exported merely because a user can view a summary.

Interoperability interfaces use versioned contracts and defined authentication, authorisation, data minimisation, error handling, retry and audit rules. External systems do not become trusted sources solely because an integration is connected.

### Record correction, retention and legal holds
A correction identifies the original record, incorrect assertion, corrected value, source, reason, requesting party, reviewer, authority, effective date and processing date. The system preserves the original value and correction history.

Retention categories define the approved period, trigger, responsible owner, review date, disposition method and exceptions. BP-39 coordinates backup and recovery; BP-42 enforces access; BP-38 ensures the record carries the necessary retention and legal-hold metadata.

A legal hold suspends routine disposition for the affected records and linked material within its defined scope. The hold records authority, matter, owner, start date, review date, affected records and release decision. Releasing a hold does not itself authorise deletion; the retention rule is then reassessed.

The system distinguishes archive, restricted retention, anonymisation, deletion, correction and supersession. A record must not be deleted merely because its subject is deceased, retired, acquitted, released, dismissed, dissolved or no longer active. The applicable legal and retention rules determine disposition.

### Data ownership and stewardship
Every authoritative data domain has an accountable owner and designated stewards. Responsibilities include:
- Approving definitions and permitted values.
- Maintaining the data dictionary.
- Reviewing data quality.
- Resolving cross-domain ownership disputes.
- Approving schema changes within delegated authority.
- Ensuring provenance and retention requirements are met.
- Coordinating corrections and identity resolution.
- Reviewing access and disclosure requirements.
- Monitoring integration and migration quality.

System administrators maintain technical infrastructure but do not automatically own the meaning or accuracy of police, legal, personnel, evidential or financial records. A technical ability to edit data is not a domain decision authority.

### Player experience and authority
The player searches, views and submits records through authorised interfaces. The player may request a correction, report an apparent duplicate, add a permitted record, attach source material or review a record's history where their role allows it.

The interface identifies:
- Record identity and domain.
- Current status and effective date.
- Source and verification state.
- Last update and responsible owner where disclosable.
- Related records and accessible history.
- Known uncertainty, dispute or correction.
- Access restrictions and reasons for unavailable information.
- Whether a value is authoritative, derived, cached or provisional.

The player cannot directly alter protected database records, change an identifier, erase history, bypass domain approval or use a search result as proof of identity. A correction request is not treated as an approved correction until the responsible authority completes the process.

### Connections to other divisions
- **BP-01 to BP-37:** all domain divisions that create, consume or change persistent game records.
- **BP-39:** durable persistence, backups, recovery, continuity and disaster-recovery procedures.
- **BP-40 and BP-41:** user-facing record views, search, reports, notifications and exports.
- **BP-42:** authentication, authorisation, row-level security, secrets and access audit.
- **BP-43:** schema, migration, data integrity, performance, security and recovery testing.
- **BP-44:** controlled domain configuration, schema extension, feature settings and compatibility.

### Exceptions and edge cases
The design must handle duplicate identities; mistaken identity; merged records; merge reversal; missing mandatory data; conflicting source records; uncertain or disputed facts; late-arriving evidence; retrospective correction; an entity whose legal status changes; a record linked to a closed or deleted entity; orphan references; a failed transaction; partial import; duplicate import; malformed source data; schema-version mismatch; migration failure; interrupted migration; incompatible application release; a destructive migration proposed without backup; stale cache; search index divergence; inaccessible linked record; an overbroad export; accidental disclosure; missing provenance; incorrect retention category; legal hold applied after deletion was scheduled; legal hold release; corrupted audit history; database outage; recovery from backup; duplicate replay after recovery; an administrator changing domain data without authority; conflicting domain ownership; a privacy or correction request; an external integration sending invalid data; and a record that must be preserved after the associated person or organisation becomes inactive.

The system must preserve source material, identify affected records, prevent silent data loss, route decisions to the accountable domain owner and record all remediation.

### Acceptance conditions
- Every persistent entity has a stable, unique and non-reusable identifier.
- Domain ownership and authoritative source are documented.
- Cross-domain records reference canonical identities rather than creating duplicates.
- Record schemas, relationships and constraints are versioned and documented.
- Referential integrity prevents orphaned or invalid relationships.
- Historical and effective-dated facts can be reconstructed.
- Material assertions preserve source, provenance, uncertainty and verification status.
- Reports, inferences and allegations cannot silently become verified facts.
- Data corrections preserve prior values and identify the responsible authority.
- Duplicate detection does not automatically merge high-consequence identities without approved safeguards.
- Search and query services enforce permissions on both records and linked data.
- Sensitive data is classified and protected at the appropriate level.
- Database migrations are version-controlled, ordered, tested and recoverable.
- Destructive changes require approval and validated recovery arrangements.
- Imports and exports preserve provenance, mapping, scope and audit history.
- Retention and legal-hold metadata is available to the relevant governance controls.
- Domain stewards and technical administrators have distinct responsibilities.
- The Supabase database can be built incrementally from approved requirements without exposing unrestricted credentials.
- The player can distinguish authoritative records from derived, cached, provisional or inaccessible information.

**Draft status:** BP-38 is a working design. The final domain register, entity catalogue, identifier formats, schema boundaries, PostgreSQL schemas and table definitions, row-level security policies, data classification scheme, audit implementation, retention schedule, legal-hold rules, migration framework, query contracts, integration standards and deployment environments remain open. The connected Supabase project currently has no Kingswell game tables or migrations. No authoritative game database schema or data-access application has been implemented by this design document.


---

## BP-39 — Persistence and Recovery

### Purpose and scope
Define how the simulation's authoritative state survives sessions, deployments, failures, accidental changes, data corruption and infrastructure disruption. BP-39 ensures that consequential records are durably saved, recoverable to a known point, protected against unauthorised loss or alteration, and restored in a way that preserves identity, chronology, evidence, legal status and player continuity.

BP-39 covers:
- Durable persistence of authoritative game state.
- Transaction durability and commit confirmation.
- Backup strategy, scope, frequency and retention.
- Recovery objectives and restoration priorities.
- Point-in-time and logical recovery approaches where supported.
- Disaster recovery and continuity arrangements.
- Backup protection, encryption and access controls.
- Restore testing and recovery exercises.
- Recovery-point selection and reconciliation.
- Migration and release recovery.
- Data corruption detection and repair.
- Recovery of event queues, scheduled jobs and in-progress workflows.
- Session continuity and safe resumption.
- Operational monitoring, incident response and recovery governance.

BP-39 does not replace:
- BP-35 for runtime execution, event processing and transaction coordination.
- BP-37 for authoritative simulation time and time advancement.
- BP-38 for record definitions, data integrity, schema ownership and audit structure.
- BP-42 for security, authentication, permissions and secrets management.
- BP-43 for testing, verification and quality assurance.
- BP-44 for approved recovery and infrastructure configuration.

A successful database connection is not proof that data is safely backed up. A backup job reporting success is not proof that the backup can be restored. A restored database is not automatically safe to use until integrity, chronology, access controls, application compatibility and critical workflows have been checked.

The connected Supabase project is the intended authoritative database platform, but the actual backup, point-in-time recovery, retention and regional recovery capabilities available to the project must be verified against its current configuration and plan. BP-39 must not claim that a capability is enabled merely because the platform may support it.

### Persistence principles
Persistence follows:
- Durability: a confirmed consequential change survives ordinary session termination and expected service restart.
- Consistency: committed records satisfy the applicable database and domain integrity rules.
- Atomicity: related changes either complete together or enter an explicitly managed workflow state.
- Isolation: concurrent operations cannot silently corrupt shared state.
- Recoverability: authoritative data can be restored to a known valid point.
- Traceability: recovery actions and restored state are documented.
- Least privilege: backup and recovery access is restricted.
- Separation: backup copies are protected from the same failure or unauthorised change that affects the primary data.
- Verification: restore capability is tested, not assumed.
- Continuity: recovery preserves player identity, simulation time, open cases and other critical state.
- Honesty: the system reports what was saved, what was recovered and what remains uncertain.

A user-facing response must not claim that an action is permanently saved until the authoritative persistence layer confirms the required commit. A pending or failed write must be reported as pending or failed, not as a completed game action.

### Authoritative persistence model
Supabase PostgreSQL is the intended authoritative store for live game records. Other copies may exist for backup, testing, analytics, cache, export or development, but none may silently become a competing source of truth.

The architecture distinguishes:
- Primary authoritative database.
- Transactional event and audit records.
- Backup copies.
- Point-in-time recovery logs or provider-managed recovery resources where enabled.
- Logical exports and archival copies.
- Derived caches and search indexes.
- Test and development databases.
- Temporary processing state and queues.
- User-facing session or conversation context.

The authoritative database owns committed game state. A cache may accelerate reads but must be rebuildable or reconcilable. A local or conversation copy is not an authoritative backup. A spreadsheet or exported JSON file is not a valid replacement for relational constraints and audit history unless an approved recovery procedure explicitly uses it.

The database architecture identifies which records must be transactionally committed together. Critical operations such as case creation, evidence registration, arrest processing, custody admission, court-order execution, personnel status change, financial payment and simulation-time advancement must not produce unexplained partial state.

### Transaction durability and confirmation
Consequential operations use database transactions or explicit workflow controls. The system confirms completion only after the authoritative write is committed and the result is available for verification.

A transaction record may include:
- Unique operation and transaction identifiers.
- Initiating command or event.
- Participating domain records.
- Starting and resulting state.
- Commit or rollback status.
- Database and application version.
- Processing and commit timestamps.
- Idempotency key where applicable.
- Error or retry information.
- Related audit and event identifiers.

If the connection fails during a write, the engine must determine whether the transaction committed before retrying. It must not blindly repeat a payment, arrest, evidence registration, appointment, time advancement or other consequential action.

For long-running or multi-system workflows, the system uses explicit states and compensating actions where appropriate. A compensating action does not erase the original event; it creates a linked correction, reversal or cancellation record.

### Persistence requirements by data class
Different records have different recovery criticality. The data classification and recovery register identifies the required protection for:
- Canonical identities and person records.
- Police personnel and authority records.
- Incidents, cases and investigation history.
- Evidence, exhibits, chain of custody and forensic results.
- Arrests, warrants, custody and legal orders.
- Court decisions, sentences and correctional status.
- Governance, complaints and disciplinary records.
- Training, qualification and employment history.
- Financial transactions, approvals, suppliers and contracts.
- Relationships, households and social context.
- Simulation clock and time-advancement history.
- NPC state and relevant world activity.
- Commands, events, queues and in-progress workflows.
- Configuration, schema and migration history.
- Access-control, security and audit records.

The recovery register identifies which records are critical, how they are backed up, their retention requirements, their acceptable recovery point, their restore dependencies and how integrity is verified.

Derived data such as caches, search indexes and non-authoritative summaries may be rebuilt only if their source records are safely preserved and the rebuild process is tested. Critical case or evidential material must not be treated as disposable derived data.

### Backup strategy
The backup strategy uses complementary mechanisms appropriate to the platform and approved risk level. These may include:
- Provider-managed automated backups.
- Point-in-time recovery where enabled and suitable.
- Scheduled logical database exports.
- Separate copies of schema and migration history.
- Encrypted archival copies of critical configuration and documentation.
- Independent copies of essential operational records where justified.
- Tested export of application and integration configuration without secrets.

The final combination, frequency and retention periods are configuration decisions based on actual platform capabilities, data volume, cost, legal requirements and recovery objectives.

Backups must cover the data and metadata necessary to restore a coherent system. A database-only backup may be insufficient if recovery also requires schema migrations, storage objects, edge-function code, configuration, access policies, external integration settings or encryption keys.

Backup procedures identify:
- Scope and excluded data.
- Source project and environment.
- Backup type and method.
- Start and completion time.
- Consistency point.
- Encryption and key management.
- Destination and geographic separation.
- Retention and expiry.
- Access restrictions.
- Integrity checksum or verification method.
- Result, errors and operator or automated process.
- Restore test history.

A backup is not considered valid merely because a file exists or a provider reports a successful operation. The system verifies that the copy is complete, readable, consistent and restorable.

### Backup isolation and protection
Backup copies are protected against:
- Accidental deletion.
- Malicious alteration or ransomware.
- Compromised application credentials.
- Compromised database credentials.
- Unauthorised staff access.
- Primary-region or provider disruption.
- Corruption propagated from the live database.
- Retention expiry caused by incorrect configuration.

Where supported, backup storage uses separate access controls and credentials from the primary application. Administrative deletion or retention changes require restricted authority and audit. At least one recovery copy should be protected from ordinary application write permissions.

Encryption is used in transit and at rest according to the platform and approved security design. Key access, rotation, recovery and loss procedures are documented. Encryption keys and recovery credentials are not stored in the same unprotected location as the backup they secure.

Secrets, service-role keys, database passwords and recovery tokens must never be committed to GitHub or placed in ordinary project documentation. A recovery procedure must explain how authorised operators regain access without exposing credentials.

### Recovery objectives and priorities
The project defines recovery objectives for each critical service and data class:
- **Recovery Point Objective (RPO):** the maximum acceptable amount of committed data loss measured in time.
- **Recovery Time Objective (RTO):** the target time to restore a service to an agreed operational state.
- **Maximum Tolerable Downtime:** the longest disruption that can be accepted before a different continuity response is required.
- **Recovery priority:** the order in which services and records are restored.
- **Integrity requirement:** the checks required before a restored service is trusted.

Exact numerical targets remain open until the expected workload, platform capability, budget and legal requirements are known. The project must not claim a one-minute RPO, one-hour RTO or any other target without an approved and tested basis.

Recovery priorities consider:
1. Identity, access control and security configuration.
2. Authoritative database and schema integrity.
3. Simulation clock and timeline consistency.
4. Critical police, incident, case, evidence and legal records.
5. Personnel authority, qualifications and operational availability.
6. Financial and contractual records.
7. Active event queues and in-progress workflows.
8. NPC, relationship and world state.
9. Notifications, reporting, caches and other rebuildable services.

The exact order may change during an incident according to safety, legal and operational requirements. Restoration must not make a lower-priority service appear operational while its required authoritative dependencies are unavailable.

### Recovery scenarios
Recovery planning covers:
- Accidental record deletion or incorrect bulk update.
- Failed or corrupted database migration.
- Database corruption or integrity failure.
- Compromised credentials or unauthorised data modification.
- Provider or regional service outage.
- Loss of database connectivity.
- Failed deployment or incompatible application release.
- Damaged or unavailable backup copy.
- Storage or integration failure.
- Interrupted transaction or workflow.
- Event queue duplication or loss.
- Incorrect simulation-time advancement.
- Loss of configuration or access policy.
- Human error during administration.
- Cyber incident or malicious destruction.
- Recovery to a point before an erroneous action.
- Full project restoration after catastrophic loss.

Each scenario identifies detection, containment, decision authority, recovery source, restoration steps, validation checks, communication, return-to-service criteria and post-incident review.

### Point-in-time and logical recovery
Where the platform supports point-in-time recovery, the procedure defines how a target recovery instant is selected, how the restored environment is isolated, how the resulting state is validated and how any missing later transactions are reconciled.

Logical recovery may be used to restore selected records or schemas where a full database restore would unnecessarily remove valid later activity. It requires a clear understanding of dependencies and referential integrity.

A recovery operation must not overwrite the live database until:
- The target restore point is approved.
- The restored environment is isolated from ordinary writes.
- Schema and migration state are checked.
- Critical record counts and relationships are validated.
- Evidence and audit history are checked.
- Simulation time and event chronology are reconciled.
- Application and access-control compatibility are verified.
- The recovery decision and expected data loss are approved.

If valid activity occurred after the chosen recovery point, it is not silently discarded. The recovery plan identifies whether those transactions can be safely replayed, reconstructed, imported or must be recorded as lost. Replay is idempotent and must not duplicate consequential outcomes.

### Simulation time and continuity
The authoritative simulation clock is stored and recovered as part of the game state. Restoring data must not cause the clock to move forward or backward without an authorised recovery decision.

The system reconciles:
- Last committed simulation time.
- Last authorised time-advancement operation.
- Events processed during that advancement.
- Scheduled tasks completed or pending.
- In-progress actions and approvals.
- NPC and resource state affected by the interval.
- Player commands received before interruption.

If the database is restored to an earlier point, later simulation events cannot remain as unexplained facts. They must be replayed from preserved event records, reconstructed through an approved process or explicitly marked as not recovered.

The default pause rule in BP-37 remains in force during outage and player absence. Real-world elapsed downtime does not automatically become simulated time.

### Event queues and in-progress workflows
Recovery includes the state of queued, processing, completed, failed and quarantined events. Each event has a stable identifier and processing status so that recovery can distinguish work that must be retried from work already committed.

A workflow recovery record identifies:
- Workflow and operation identifiers.
- Last completed step.
- Pending step and prerequisites.
- Committed domain changes.
- External side effects already performed.
- Idempotency and retry state.
- Compensating or reconciliation action.
- Responsible recovery owner.

External side effects such as email, payment instructions or third-party requests require reconciliation against the external service before replay. A database rollback does not automatically reverse an external payment or notification.

### Migration and deployment recovery
Every schema or application release has a recovery plan. It identifies:
- Release identifier and versions.
- Database migration dependencies.
- Pre-deployment backup or recovery point.
- Compatibility requirements.
- Data transformations and backfills.
- Health checks and acceptance tests.
- Rollback, forward-fix or restore strategy.
- Decision authority and deployment record.

A migration that cannot safely be rolled back must have a forward-repair or restore strategy approved before deployment. A migration is not considered complete until post-deployment validation succeeds.

The project must preserve the migration files and application source in GitHub, but GitHub history is not a substitute for a database backup. Conversely, a database backup is not a substitute for version-controlled source, migration scripts and configuration.

### Restore testing and recovery exercises
Recovery procedures are tested on an isolated environment using representative data or approved synthetic fixtures. Tests cover:
- Backup discovery and access.
- Integrity and checksum verification.
- Restore execution.
- Schema and migration reconciliation.
- Record counts and critical relationships.
- Identity and foreign-key integrity.
- Case and evidence history.
- Financial transaction consistency.
- Simulation clock and event chronology.
- Access-control and row-level security behaviour.
- Application compatibility.
- Queue and workflow resumption.
- Recovery timing and operator steps.
- Documentation and evidence of completion.

A successful backup job is not a restore test. A restore test must demonstrate that the system can be brought to a usable, validated state.

Exercises are recorded with scope, date, participants, recovery source, elapsed time, issues, corrective actions, evidence and approval. Failed exercises create tracked remediation rather than being reported as successful.

### Session continuity and player resumption
The player can resume from the last confirmed authoritative state. The system identifies the last committed command, event, simulation time and relevant workflow state.

On resumption, the player receives an accurate account of:
- Last confirmed saved state.
- Any command or operation whose outcome is uncertain.
- Pending approvals or workflows.
- Records restored or unavailable.
- Any recovery limitation affecting play.
- Whether the simulation clock changed through an authorised process.

The system must not present a partially saved action as completed. Where the outcome of a transaction cannot be established, it is held for reconciliation before a duplicate action is permitted.

### Recovery governance and incident management
A recovery action has a designated decision-maker and recorded authority. The incident record includes:
- Incident identifier and severity.
- Detection and notification time.
- Affected services and data.
- Suspected cause and scope.
- Containment actions.
- Recovery point and source selected.
- Expected data loss and operational impact.
- Approval and execution history.
- Validation results.
- Return-to-service decision.
- Outstanding risks and workarounds.
- Post-incident review and corrective actions.

A person who caused or is implicated in an unauthorised change must not have sole authority to approve the recovery or certify the resulting integrity. Independent review is required according to risk.

### Player experience and authority
The player should not need to manage technical backups during ordinary gameplay. The interface may report service availability, saved-state confirmation and any material recovery interruption.

Only authorised administrators and recovery roles may initiate backup, restore, migration rollback or disaster-recovery actions. A player cannot rewind the authoritative game world to avoid consequences, erase evidence, reverse a disciplinary outcome or restore an earlier financial state for personal advantage.

A legitimate simulation reset, scenario restart or test restore is a separate controlled operation under BP-44 and must not overwrite the live authoritative game without explicit approval and preservation of required history.

### Connections to other divisions
- **BP-01 to BP-38:** all blueprint domains whose authoritative records, state and history require persistence.
- **BP-35:** transaction, event, command and workflow recovery.
- **BP-37:** authoritative clock, time advancement, schedule state and temporal consistency.
- **BP-38:** record schemas, identifiers, provenance, audit, migrations and data integrity.
- **BP-40 and BP-41:** player session resumption, status display and recovery notifications.
- **BP-42:** backup permissions, credential protection, encryption and recovery access.
- **BP-43:** backup, restore, migration, integrity and disaster-recovery tests.
- **BP-44:** environment configuration, approved resets and controlled recovery settings.

### Exceptions and edge cases
The design must handle a backup that reports success but cannot be restored; a backup with missing storage objects or configuration; a recovery copy encrypted with an unavailable key; accidental deletion discovered after a retention period; corruption copied into several backups; an incorrect recovery point; valid transactions after the recovery point; a failed restore; a migration partially applied; a provider outage during recovery; loss of both primary and backup credentials; a compromised administrator account; a duplicate event replay; a payment made externally before database rollback; a notification delivered before recovery; a restored clock inconsistent with event history; an event queue containing unknown processing status; a workflow with an unrecorded external side effect; a backup taken during an inconsistent export; an expired legal hold; a restore that violates access policies; an incompatible application version; a missing migration file; a test restore accidentally connected to production integrations; a recovery exercise using live personal data without approval; a failed reconciliation; and a prolonged outage requiring controlled manual records.

The system must isolate uncertain data, prevent unsafe replay, preserve audit evidence, identify the actual recovery point and require validation before normal operation resumes.

### Acceptance conditions
- Every confirmed consequential change is durably persisted before success is reported.
- Critical operations use atomic transactions or explicit recoverable workflows.
- The authoritative database is distinguished from caches, exports and test copies.
- Backup scope, frequency, destination, retention and access are documented.
- Backup copies are protected against common primary-system failures and unauthorised alteration.
- Actual provider backup and point-in-time capabilities are verified rather than assumed.
- RPO, RTO and recovery priorities are approved and tested before being claimed.
- Restore procedures validate schema, identity, references, evidence, financial data and audit history.
- The simulation clock and event chronology remain coherent after recovery.
- Event queues and in-progress workflows can be safely reconciled without duplicate outcomes.
- External side effects are checked before a workflow is replayed.
- Database and application releases have documented recovery strategies.
- Restore exercises demonstrate usable recovery and produce evidence.
- Player resumption identifies the last confirmed state and any uncertain operation.
- Recovery actions are authorised, auditable and independently reviewed where required.
- Technical backups do not silently advance or rewind simulation time.
- The project can recover without relying on undocumented manual knowledge or a single operator.

**Draft status:** BP-39 is a working design. The actual Supabase backup and point-in-time recovery configuration, independent backup destination, backup frequency, retention periods, RPO, RTO, maximum tolerable downtime, encryption and key-management design, restore authority, recovery environment, restore-test schedule and disaster-recovery procedures remain open. No backup policy, automated backup job, restore exercise or disaster-recovery process has been implemented or verified for the Kingswell game database.


---

## BP-40 — Interface

### Purpose and scope
Define how the player interacts with the simulation, issues commands, receives information, reviews records, makes decisions and understands the current state of the game. BP-40 establishes a consistent, accessible, text-first interface that exposes the capabilities of the simulation without weakening domain rules, hiding uncertainty or overwhelming the player with unnecessary information.

The permanent primary interface is conversational text through ChatGPT. The player experiences the game through an individual character and interacts by issuing natural-language or structured commands and receiving in-world responses, records, dispatches, decisions and status information.

BP-40 covers:
- Primary conversational interface and command interaction.
- Command interpretation, clarification and confirmation presentation.
- Response structure and status communication.
- Navigation between operational and administrative contexts.
- Record review, search and contextual display.
- Player identity, role and current-character context.
- Operational dashboards and concise status summaries.
- Forms, structured choices and decision prompts where necessary.
- Error, warning, pending and completion messages.
- Accessibility, usability and information hierarchy.
- Optional future visual and graphical interface extensions.
- Interface consistency, help and discoverability.

BP-40 does not replace:
- BP-35 for command execution, simulation state and runtime orchestration.
- BP-37 for authoritative time and scheduling.
- BP-38 for authoritative records, schemas and query contracts.
- BP-41 for notification delivery, reporting and alert rules.
- BP-42 for authentication, authorisation and security.
- BP-43 for usability, accessibility and interface testing.
- BP-44 for configurable interface options and controlled expansion.

The interface displays the outcome produced by authoritative domain systems. It does not create police powers, change records outside the approved workflow, determine legal status or invent facts to make a response appear complete.

### Primary interface principles
The interface is:
- Text-first: all essential gameplay can be completed through text.
- Conversational: the player can describe an intended action naturally.
- Command-capable: stable structured commands are available for repeatable operations.
- Context-aware: responses use the player's current character, role, location, assignment and permitted context.
- Honest: it distinguishes completed, pending, rejected, unavailable and uncertain outcomes.
- Concise by default: routine responses prioritise the information needed for the current decision.
- Detailed on demand: the player can request full records, timelines, documents and explanations.
- Consistent: the same action and record use consistent terms, identifiers and status labels.
- Accessible: information does not depend on colour, graphics, sound or a particular input device.
- Safe: the interface does not reveal restricted information or bypass domain permissions.
- Recoverable: the player can understand what was last saved and what remains pending.
- Extensible: optional visual features may supplement text but never become mandatory for core play.

The interface must not require the player to learn a large command language before starting. Natural-language input remains available, while structured commands improve speed, precision and repeatability.

### Player identity and active character context
The interface identifies the active player character and displays relevant current context, such as:
- Character name and stable identity.
- Rank, appointment, position and unit.
- Current posting or duty assignment.
- Duty and availability status.
- Current location where known and permitted.
- Current simulation date and time.
- Current operational or administrative context.
- Relevant authority, qualification or access limitations.
- Outstanding tasks, approvals or urgent matters.

The interface must not confuse the user's ChatGPT account identity with the fictional character's identity. It must not assume that the player is acting as a chief officer, supervisor, investigator or other role unless the character's current appointment and authority establish that capability.

A player may have multiple saved characters or scenarios only if the approved configuration supports them. Switching characters is an explicit action and must not silently transfer authority, records, possessions or ongoing duties between characters.

### Natural-language commands and structured commands
The player can issue commands in ordinary language. The command interface identifies the intended action and maps it to a documented domain operation.

Structured commands may be provided for common activities, such as:
- View current status.
- Review duty or assignment.
- Receive or acknowledge a dispatch.
- Open an incident or case record.
- Search an authorised record.
- Submit a report or request.
- Record an observation or action.
- Request approval.
- Review evidence or a timeline.
- Check a schedule or deadline.
- Request time advancement.
- Review a pending task or decision.

Exact command syntax remains configurable and is not required to be the only input method. Command aliases and natural-language variants must resolve to the same underlying operation and permissions.

The interface distinguishes a request to view information from a request to change it. A question about whether an action is possible must not be interpreted as authorisation to perform it.

### Ambiguity, clarification and confirmation
If an essential command detail is missing or ambiguous, the interface asks a concise clarification question. It does not invent a person, location, case, time, legal authority or target.

Clarification is required where ambiguity could:
- Affect the wrong person or record.
- Cause an irreversible or high-impact action.
- Change legal status or authority.
- Create or disclose sensitive information.
- Commit expenditure or issue a payment.
- Affect evidence, custody, employment or discipline.
- Advance simulation time or skip a critical event.
- Cause a resource to be assigned or released incorrectly.

A confirmation prompt is used for consequential actions where the player must understand the effect before execution. The prompt states the action, target, relevant consequences and any required authority. Confirmation does not override a missing legal power or permission.

The interface avoids unnecessary forms. It uses conversational clarification for a single missing detail and structured controls only where several independent inputs must be collected or a controlled choice is required.

### Command outcome and status presentation
Every action response uses clear status language. It distinguishes:
- Completed and persisted.
- Accepted for processing.
- Submitted for approval.
- Pending another actor or process.
- Partially completed.
- Rejected by a domain rule.
- Blocked by missing authority or permission.
- Unavailable because a dependency is offline.
- Failed without a state change.
- Outcome uncertain and requiring reconciliation.

The interface never describes an action as completed when it is merely parsed, submitted, queued or acknowledged. Where a process is pending, it identifies the responsible decision-maker or next status where that information is permitted.

For a failed or rejected action, the interface explains the reason at a level that helps the player correct the request without disclosing protected control details or sensitive security information.

### Response structure and information hierarchy
Responses prioritise:
1. The immediate result or answer.
2. The key facts needed for the current decision.
3. Any limitation, uncertainty, authority requirement or pending state.
4. Relevant record identifiers and references.
5. Further detail available on request.

Operational responses may include concise headers such as:
- Current status.
- Incident or task reference.
- Location and time.
- Assigned personnel or resources.
- Required action or decision.
- Authority or approval status.
- Important risk or safety information.

Administrative and investigative responses may use structured records, timelines, evidence lists, decision logs or document extracts. The format should fit the task rather than forcing every response into the same template.

Long records may be displayed in sections or retrieved on request. The interface should not omit a material fact merely to remain brief; it should clearly indicate when a summary is not the complete record.

### Navigation and working contexts
The interface provides predictable navigation between:
- Personal status and career.
- Current duty and deployment.
- Dispatch and active incidents.
- Patrol and field activity.
- Investigations and cases.
- Victims, witnesses and suspects.
- Evidence, scenes and forensic results.
- Arrest, custody and legal processes.
- Courts and correctional matters.
- Department governance and professional standards.
- Training and qualifications.
- Human resources and finance.
- People, properties, businesses and organisations.
- Relationships and social context.
- Time, calendars and schedules.
- Records, reports and notifications.

Navigation does not grant access. A user may see that a category exists while being denied access to a specific record because of role, purpose or legal restriction.

The interface preserves context where safe, such as the active case or incident, but it must not assume that every later command relates to the same record. When context is ambiguous, the player is asked to identify the target.

### Record views and information display
A record view uses a consistent layout appropriate to the domain. It may include:
- Stable identifier and title.
- Current status and effective date.
- Key parties and linked entities.
- Relevant location and time.
- Source and verification status.
- Current owner or responsible unit.
- Important history and recent changes.
- Related records the player may access.
- Pending actions and deadlines.
- Access restrictions or redactions where appropriate.

A summary is clearly labelled as a summary. A complete record can be requested where the player's permissions allow it. The interface distinguishes missing information from information that exists but is restricted.

The player can request chronological views, relationship views, document lists, evidence inventories, decision histories and other domain-defined representations. These are views of authoritative records, not independent sources of truth.

### Operational status and dashboards
A dashboard is a role-appropriate summary of current responsibilities and actionable information. It may display:
- Current duty and assignment.
- Active task or incident.
- Pending dispatch or acknowledgement.
- Available or assigned resources.
- Outstanding reports and approvals.
- Upcoming appointments or deadlines.
- Relevant notifications and alerts.
- Training or qualification warnings.
- Current restrictions or temporary limitations.

Dashboards are tailored to the user's role and current context. A patrol officer should not receive the same default view as a dispatcher, investigator, HR officer, finance officer or commander.

A dashboard must not become a substitute for the authoritative record. It identifies when data was last updated and whether a value is current, estimated, provisional or unavailable.

### Structured choices and forms
Structured controls are used where they materially reduce error or are required by the domain process. Examples include:
- Selecting an identified person, incident or case.
- Choosing a permitted status transition.
- Entering several required fields for a formal request.
- Confirming a high-impact action.
- Recording a controlled classification.
- Selecting a date or time from an unambiguous calendar.
- Reviewing and approving a documented decision.

Forms identify required and optional fields, validation rules, source requirements and the decision authority. A form submission is not equivalent to approval or completion. Partial submissions are allowed where the domain permits them and are clearly marked incomplete.

The interface must not use decorative or inert controls that imply an action is available when it is not connected to an authoritative process.

### Search and contextual retrieval
Search is available through natural language and structured filters where permitted. The player may search by identifier, name, location, date range, case reference, status or other approved field.

Search results distinguish exact and possible matches. They show enough information to identify the result without exposing restricted data. Search does not establish that a person is the same individual, that an allegation is true or that a record is current.

The interface supports follow-up queries against the active result, but it must confirm the target when more than one record could match. A search with no results does not prove that no record exists; the system may explain that the record is unavailable or outside the user's access.

### Help, guidance and discoverability
The interface provides concise help for:
- Available commands and actions.
- Current character authority and restrictions.
- Record terminology and status meanings.
- How to search and open records.
- How to submit reports and requests.
- How approval and escalation work.
- How time advancement operates.
- How to resume after interruption.
- How to request more detailed output.

Help is contextual and does not reveal restricted system configuration, hidden case solutions or information outside the player's role.

The player can ask what actions are available in the current context. The response lists permitted options and identifies actions that require approval or another role without implying that unavailable actions can be forced through.

### Error handling and feedback
The interface distinguishes user input errors, domain-rule rejection, permission denial, unavailable information, dependency failure and persistence failure.

Error messages:
- Identify the affected command or record.
- Explain the actionable reason where safe.
- State whether any change occurred.
- Identify whether retry is safe.
- Provide a correction or escalation route where appropriate.
- Avoid exposing secrets, internal security configuration or protected records.

If a write outcome is uncertain, the interface advises reconciliation rather than inviting an unsafe duplicate submission. A retry must use the command and idempotency controls defined by BP-35.

### Accessibility and usability
The text interface is usable without colour, animation, sound, maps or images. It supports clear headings, plain language, predictable terminology, readable lists and tables, and keyboard-accessible interaction through the host platform.

The design considers:
- Screen readers and semantic structure.
- Clear labels and meaningful control names.
- Non-colour status indicators.
- Consistent date, time and number formats.
- Manageable information density.
- Clear distinction between warning, error and routine status.
- Avoidance of unnecessary repetition.
- User control over detail level where safe.
- Accessible alternatives to graphical or spatial information.
- Plain-language explanation of complex legal or administrative states.

A graphical enhancement must have an equivalent text representation for every essential fact and action.

### Optional visual and graphical extensions
Future versions may add maps, diagrams, floor plans, vehicle or evidence illustrations, timelines, dashboards and other visual representations. These are optional aids, not a replacement for the text-first interface.

Every visual feature must:
- Use authoritative records and current permissions.
- Display source, time and uncertainty where relevant.
- Provide a text equivalent.
- Avoid implying precision beyond the underlying data.
- Preserve the same action and authority rules as the text interface.
- Remain optional for core gameplay.
- Avoid revealing hidden information or case solutions.

A map pin, diagram or image is not itself proof of location, identity or evidential interpretation. Visual annotations must be traceable to their source record.

### Player control and game continuity
The interface makes the current simulation state understandable without taking control away from the player. It does not automatically make discretionary decisions on the player's behalf unless the player has expressly authorised a defined routine action and the relevant domain permits it.

The interface supports:
- Clear start and resume behaviour.
- Identification of the active character and scenario.
- Retrieval of the last confirmed state.
- Review of pending actions.
- Explicit time advancement.
- Safe interruption and return.
- Correction requests and audit review.
- Distinction between in-world actions and project-development actions.

Project administration, blueprint editing and software implementation are not silently treated as in-world gameplay. The player can clearly distinguish playing the officer from changing the game design.

### Connections to other divisions
- **BP-01 to BP-39:** all domain systems and authoritative records exposed through the player interface.
- **BP-35:** command interpretation, execution status and runtime response.
- **BP-37:** current time, schedules, calendars and time advancement.
- **BP-38:** record retrieval, schema contracts, provenance and data status.
- **BP-39:** save confirmation, recovery status and session continuity.
- **BP-41:** notifications, alerts, reporting and delivery status.
- **BP-42:** identity, permissions, restricted information and secure interaction.
- **BP-43:** usability, accessibility, workflow and interface testing.
- **BP-44:** display preferences, command aliases and controlled interface configuration.

### Exceptions and edge cases
The design must handle an ambiguous command; multiple matching records; an action submitted in the wrong context; an unavailable or expired authority; a user with several roles; a character whose employment or duty status changes; a pending action interrupted by session loss; a response generated before persistence confirmation; a failed or uncertain write; a duplicate command; a long record that cannot be displayed in one response; restricted information within an otherwise accessible record; a stale dashboard value; conflicting timestamps; a form with incomplete required fields; a control unavailable to the current role; a user misunderstanding a warning; a high-impact action requiring confirmation; a notification that arrives after the underlying status changes; a visual feature unavailable; an accessibility setting that changes layout; a player switching characters; a resumed session with unresolved operations; and a system error that prevents authoritative data retrieval.

The interface must communicate the actual state, preserve context where safe and avoid implying that a user action succeeded when it did not.

### Acceptance conditions
- All essential gameplay can be completed through text.
- Natural-language and structured commands use the same domain rules and permissions.
- The active character and current role are clear.
- The interface distinguishes questions, requests, approvals and completed actions.
- Ambiguous high-impact commands require clarification.
- Consequential actions receive appropriate confirmation and status feedback.
- Responses distinguish completed, pending, rejected, failed and uncertain outcomes.
- Record views identify authoritative status, source, time and uncertainty.
- Search respects permissions and distinguishes exact from possible matches.
- Dashboards are role-appropriate and do not replace authoritative records.
- Forms and controls are connected to real domain actions and display validation.
- Error messages are actionable without disclosing protected information.
- The interface remains usable without graphics, sound or colour.
- Optional visual features have equivalent text representations.
- The player retains control over discretionary actions and simulation time.
- Session resumption accurately identifies the last confirmed state.
- Development administration is distinguishable from in-world gameplay.

**Draft status:** BP-40 is a working design. The final command catalogue, response templates, dashboard layouts, navigation model, accessibility standards, record-view specifications, interaction confirmation thresholds, visual feature scope and host-platform integration details remain open. The intended ChatGPT conversational interface is available as the project interaction concept, but no dedicated game interface, command application, dashboard or player portal has been implemented.


---

## BP-41 — Notifications and Reporting

### Purpose and scope
Define how the simulation communicates alerts, reminders, status changes, operational updates, reports, summaries and formal information products to the player and authorised institutional users. BP-41 ensures that important information reaches the right recipient at the right time, with an accurate priority, source, status and level of detail.

BP-41 covers:
- Notification architecture and delivery channels.
- Event-triggered alerts and status updates.
- Operational, investigative, legal and administrative notifications.
- Reminders, deadlines and appointment alerts.
- Escalation and acknowledgement rules.
- Notification preferences and delivery controls.
- Report definitions, generation and publication.
- Operational summaries, dashboards and management reporting.
- Scheduled and event-driven reports.
- Delivery history, retries, failure handling and audit.
- Information classification, redaction and recipient validation.
- Reporting accuracy, provenance and data-quality indicators.

BP-41 does not replace:
- BP-11 for emergency communications, call-taking, radio, dispatch and operational communications.
- BP-30 for governance reporting, oversight and public accountability.
- BP-35 for event generation and processing.
- BP-37 for authoritative timing, schedules and deadlines.
- BP-38 for authoritative records, report data sources and query contracts.
- BP-40 for the player interface and presentation.
- BP-42 for identity, permissions and security.

A notification is not an operational command, legal order, approval or proof that the recipient has read or acted on the information. A report is a representation of source records, not an independent authority to change those records.

### Notification principles
Notifications are:
- Relevant: sent only to recipients with a legitimate role or purpose.
- Accurate: based on authoritative or clearly labelled provisional information.
- Timely: delivered according to urgency and the event's actual timing.
- Proportionate: frequency and detail reflect risk and operational need.
- Actionable: where a response is required, the action and deadline are clear.
- Traceable: generation, routing, delivery, acknowledgement and failure are recorded.
- Secure: sensitive content is protected and recipients are validated.
- Non-duplicative: retries and repeated events do not create uncontrolled duplicate alerts.
- Honest: delivery is distinguished from reading, acknowledgement and completion.
- Configurable: preferences may control non-critical notices but cannot suppress mandatory safety or legal alerts.

The notification system must avoid alert fatigue. Routine status changes should not be presented with the same urgency as an immediate threat to life, a custody deadline or a critical operational instruction.

### Notification categories and priority
Notification categories may include:
- Critical safety or emergency alert.
- Immediate operational task or dispatch-related update.
- Time-sensitive legal or custody deadline.
- Security, safeguarding or integrity alert.
- Investigation or case update.
- Approval request or decision outcome.
- Duty, roster and availability change.
- Training, qualification or competency notice.
- HR, leave and employment update.
- Finance, procurement and contract notice.
- Appointment and calendar reminder.
- Record correction or data-quality notice.
- System availability, persistence or recovery notice.
- Routine informational update.
- Scheduled report or management summary.

Each category has a defined owner, eligible recipients, priority, delivery expectation, acknowledgement requirement, escalation route, confidentiality level and retention policy.

Priority levels and service expectations are configurable. A low-priority notification may be grouped into a digest; a critical alert may require immediate delivery and acknowledgement. A user's preference cannot disable a mandatory alert where the domain rules require delivery.

### Notification lifecycle
A notification follows a controlled lifecycle:
1. A domain event or scheduled rule triggers a notification request.
2. The source and event are validated.
3. The notification category and priority are resolved.
4. Recipient eligibility and permissions are checked.
5. Sensitive content is minimised and redacted as required.
6. The message is generated from an approved template or defined content rule.
7. The notification is queued and assigned a unique identifier.
8. Delivery is attempted through an available authorised channel.
9. Delivery result is recorded.
10. Acknowledgement is recorded where required.
11. Escalation or retry occurs under the defined policy.
12. The notification is closed, expired, cancelled or superseded as appropriate.

The lifecycle distinguishes created, queued, attempted, delivered, failed, retried, acknowledged, declined where supported, expired, cancelled and superseded. A notification can be delivered without being read. An acknowledgement can confirm receipt without confirming agreement or completion of the requested action.

### Recipient selection and routing
Recipient selection is based on current role, assignment, responsibility, jurisdiction, case involvement, authority and the source domain's routing rules.

Recipients may include:
- The player character.
- Assigned officers and supervisors.
- Dispatch and incident command roles.
- Investigators and case owners.
- Authorised specialist units.
- Custody and legal-process staff.
- Court or correctional interfaces where authorised.
- HR, training, finance or procurement personnel.
- Governance, audit or oversight roles.
- Other approved institutional contacts.

A recipient list is resolved at the time of the event according to the applicable rule. Historical delivery records preserve who was eligible and who actually received the notification at that time.

A notification must not be routed merely because a person is senior, works in the same organisation or is linked socially to the subject. Need-to-know and purpose limitation apply. A transfer, shift change or role change may require rerouting or escalation, but must not expose the content to an unauthorised former recipient.

### Content, source and certainty
Each notification records:
- Notification identifier.
- Triggering event and source record.
- Category and priority.
- Recipient or recipient group.
- Generated and delivery timestamps.
- Message template and version.
- Content classification.
- Required action and due time, if any.
- Delivery channel and result.
- Acknowledgement status.
- Retry, escalation and closure history.

The content distinguishes verified facts, reports, allegations, estimates, warnings, pending decisions and system-generated predictions. It identifies uncertainty where material and does not overstate the source.

A notification may contain a concise summary and a link or reference to the authoritative record. The recipient's permission is checked again when the record is opened; receiving a notification does not automatically grant access to the linked record.

### Acknowledgement and escalation
Some notifications require acknowledgement. The acknowledgement rule identifies:
- Who must acknowledge.
- What constitutes acknowledgement.
- The allowed time.
- Whether acknowledgement is individual or by an assigned role.
- What happens if no acknowledgement is received.
- Who receives escalation.
- Whether a secondary channel is required.

Acknowledgement confirms receipt or awareness only. It does not prove that an instruction was followed, a task was completed or the recipient agreed with the content.

If a critical notification is not acknowledged within its required period, the system escalates according to the domain rule. Escalation does not silently transfer legal authority or operational command. The responsible domain defines whether another person must take over.

A notification may be cancelled or superseded when the underlying event changes. The recipient should be informed when an earlier message is materially corrected, withdrawn or replaced.

### Delivery channels and preferences
The primary player-facing delivery channel is the conversational interface. Other channels may be added where technically supported and approved, such as in-application alerts, email, SMS or external institutional integrations.

Each channel has documented capabilities, security limitations, delivery confirmation semantics, retry behaviour and cost implications. The system does not claim that an external message was delivered or read without a valid provider response.

User preferences may control non-critical digests, grouping, quiet periods and display choices where permitted. Preferences cannot suppress mandatory safety, legal, security or operational alerts. Quiet periods do not change the underlying deadline or event time.

Sensitive notifications use minimal content and direct the recipient to an authorised record view. Protected case, personnel, health, witness or financial information must not be placed in an insecure channel merely for convenience.

### Notification preferences and alert fatigue
Preferences may include:
- Category subscriptions.
- Digest frequency.
- Display grouping.
- Reminder lead time.
- Non-critical quiet periods.
- Preferred supported channel.
- Accessibility and presentation settings.

Preferences are versioned and linked to the user or role. Mandatory routing rules take precedence. A role change may reset or adjust preferences where the new responsibilities require it.

The system monitors duplicate, repeated, stale and low-value alerts. Notification volume may be reduced through grouping or digesting only when this does not delay a critical action or hide a material update.

### Reporting architecture
Reports are defined products generated from authorised source records. Each report specification includes:
- Report identifier and title.
- Purpose and intended audience.
- Data owner and accountable approver.
- Source domains and query definition.
- Filters, period and scope.
- Definitions of measures and status categories.
- Calculation and aggregation rules.
- Refresh frequency or trigger.
- Data-quality limitations.
- Access and classification.
- Redaction and disclosure rules.
- Version and effective date.
- Retention and publication status.

Reports may be:
- Operational: current activity, incidents, deployment and workload.
- Investigative: case status, actions, evidence and timelines.
- Legal: custody, warrant, hearing and deadline status.
- Personnel: staffing, attendance, training and workforce information.
- Financial: budget, expenditure, procurement and contract position.
- Governance: risk, audit, performance and corrective action.
- Public accountability: approved aggregate statistics and published information.
- Personal: information the player may access about their own character or requests.

A report must state its reporting period, generation time, source and definitions. A snapshot report preserves the values and source version used at generation; a live report indicates that values may change as records are updated.

### Reporting accuracy and interpretation
Reports distinguish:
- Counts of records from counts of unique people or entities.
- Allegations from verified incidents and adjudicated outcomes.
- Open cases from proven offences.
- Planned duty from actual attendance.
- Headcount from available staff and funded posts.
- Budget allocation from commitments, expenditure and forecast.
- Notifications sent from acknowledged actions.
- Events occurring in a period from events recorded during that period.
- Current status from historical status at the reporting date.

Every measure has a documented definition. The same term must not be calculated differently across reports without an explicit distinction.

Reports identify missing data, incomplete periods, delayed updates, excluded records, sampling limitations and known quality issues. A report cannot imply certainty beyond its source data.

### Operational summaries and dashboards
Operational summaries provide a concise view of current activity for an authorised role. They may include:
- Active calls and incidents.
- Pending dispatch or acknowledgement.
- Unit and officer availability.
- Response and task status.
- Critical deadlines.
- Outstanding approvals.
- Case and evidence workflow status.
- Resource shortages.
- Safety and safeguarding alerts.

Management summaries may include workload, staffing, service performance, risk, training, finance and resource trends. They must not expose individual sensitive information to users who only need aggregate reporting.

A dashboard is a view, not an independent record. It displays the data freshness and identifies any unavailable source. Cached values are marked as such where their age could affect a decision.

### Scheduled reports and publication
Scheduled reports use BP-37 for timing and BP-38 for source data. A report schedule defines frequency, period, recipients, approval, generation time and failure handling.

Public or external reports require approval under BP-30 and the relevant legal disclosure rules. The reporting system does not automatically publish a report merely because a schedule has run.

Publication records include the approved version, approver, date, audience, redactions, publication channel and correction history. If a published report contains an error, the correction is traceable and the previous version is preserved where required.

### Delivery failure, retries and reconciliation
The system handles:
- Recipient unavailable or no longer eligible.
- Invalid or outdated contact route.
- Channel outage.
- Provider rejection or rate limit.
- Duplicate trigger.
- Notification generated from stale source data.
- Delivery confirmed but acknowledgement absent.
- Acknowledgement recorded against the wrong notification.
- A notification superseded during delivery.
- Partial delivery to a recipient group.
- Report generation failure.
- Incomplete source data.
- Report output that exceeds a safe limit.
- External integration unavailable.

Retries are bounded and idempotent. The system records each attempt and avoids duplicate notifications where possible. A failed notification does not change the underlying task, deadline or legal obligation. Critical failures are escalated through an alternative approved route.

### Privacy, security and audit
Notifications and reports are subject to BP-38 classification and BP-42 access controls. The system applies least privilege, recipient validation, data minimisation, retention and audit.

Audit records include generation, routing, access, delivery, acknowledgement, escalation, report generation, approval, export and publication where required. Audit logging must not expose protected message content to users who are not authorised to view it.

Bulk reports and exports require appropriate purpose and authority. Small-group or rare-event statistics are reviewed for re-identification risk before wider publication. Confidentiality is not used to conceal misconduct or obstruct lawful oversight.

### Player experience and authority
The player can review current notifications, acknowledge those requiring it, open permitted linked records, inspect relevant deadlines, view reports within their role and manage non-critical preferences.

The interface distinguishes:
- New from previously viewed notifications.
- Delivered from acknowledged.
- Acknowledged from action completed.
- Mandatory from informational.
- Current from superseded.
- Verified from reported or provisional.
- Live data from a generated snapshot.
- Internal report from approved public publication.

The player cannot suppress mandatory alerts, falsify acknowledgement, change source records through a notification or publish a report without the required authority.

### Connections to other divisions
- **BP-01 to BP-40:** all domains that generate, consume or display alerts and reports.
- **BP-11:** operational communications, dispatch and radio messages.
- **BP-30:** governance, oversight, performance and public reporting approval.
- **BP-35:** event triggers, queue processing, retries and notification generation.
- **BP-37:** reminders, deadlines, schedules and report timing.
- **BP-38:** source records, data definitions, provenance, classification and query interfaces.
- **BP-39:** delivery and report history persistence, recovery and reconciliation.
- **BP-40:** notification display, user navigation and report presentation.
- **BP-42:** recipient permissions, channel security and access audit.
- **BP-43:** delivery, routing, accuracy, privacy and report-calculation tests.
- **BP-44:** configurable categories, priorities, templates, preferences and channel settings.

### Exceptions and edge cases
The design must handle a critical alert with no acknowledgement; a recipient changing roles during delivery; a notification sent to a former assignee; a confidential message delivered to an unauthorised channel; a notification generated from a record that changes immediately afterward; a duplicated event; a delayed or out-of-order notification; a failed external provider; an incorrect recipient; a user with several active roles; an expired deadline; a notification cancelled after delivery; a superseded warning; a delivery receipt without proof of reading; a false acknowledgement; a report generated from stale data; a report whose source records change during generation; a reporting-period boundary; a retrospective correction; a missing data source; an inconsistent metric definition; a small-group privacy risk; an unapproved public release; a report correction after publication; a bulk export request; an unavailable reporting service; a notification queue backlog; a system outage during an emergency; and a restored system replaying notifications already sent.

The system must preserve delivery history, prevent uncontrolled duplicates, distinguish actual delivery from user action and route critical failures through approved alternatives.

### Acceptance conditions
- Notifications originate from validated events or approved schedules.
- Each notification has a unique identifier, source, priority, recipient rule and lifecycle.
- Recipient eligibility and permissions are checked before delivery.
- Delivery, reading, acknowledgement and task completion remain distinct.
- Mandatory alerts cannot be suppressed by ordinary user preferences.
- Critical unacknowledged alerts follow defined escalation rules.
- Sensitive content is minimised and protected across channels.
- Retries do not create uncontrolled duplicate notifications.
- Corrections and superseded messages are clearly identified.
- Reports have approved definitions, sources, periods and owners.
- Reports distinguish records, people, allegations, verified outcomes and other material categories.
- Data freshness and known limitations are visible.
- Public reporting requires the appropriate approval and disclosure review.
- Report and notification access, delivery, acknowledgement and publication are auditable.
- The player can review and act on permitted notifications without changing source records through the alert itself.
- Delivery and report failures are visible and recoverable.

**Draft status:** BP-41 is a working design. The final notification catalogue, priority levels, acknowledgement times, escalation matrix, channel providers, delivery service targets, reminder defaults, report catalogue, metric definitions, publication rules, retention periods and external communication integrations remain open. No dedicated notification service, reporting engine, external message integration or automated report publication system has been implemented.


---

## BP-42 — Security and Permissions

### Purpose and scope
Define how the simulation protects identities, records, services, commands, data, infrastructure and institutional capabilities against unauthorised access, misuse, disclosure, alteration and disruption. BP-42 establishes authentication, authorisation, permission models, role and attribute controls, security boundaries, secrets management, audit, privileged access and security incident response.

BP-42 covers:
- User, service and system identity.
- Authentication and session security.
- Role-based and attribute-based authorisation.
- Domain, record, field and action permissions.
- Fictional character authority and separation from platform identity.
- Database and application access controls.
- Row-level and other data-access enforcement.
- Privileged and administrative access.
- Secrets, keys and credential management.
- Secure integration and service-to-service access.
- Security logging, monitoring and access review.
- Break-glass and emergency access.
- Data protection and confidentiality controls.
- Security incident detection, containment and recovery interfaces.
- Permission lifecycle, revocation and periodic review.

BP-42 does not replace:
- BP-30 for institutional governance, decision rights, risk ownership and oversight.
- BP-31 for professional standards, misconduct and disciplinary processes.
- BP-38 for record classification, schema, provenance and data ownership.
- BP-39 for backup, recovery and continuity.
- BP-40 for interface presentation of permitted and denied actions.
- BP-41 for notification routing and report access.
- BP-43 for security testing and verification.
- BP-44 for approved security configuration and environment settings.

A technical permission does not create a fictional police power. A fictional rank or appointment does not automatically grant access to every database record. A person may be authenticated but unauthorised for a particular action. A player may have a valid ChatGPT account but still lack the fictional character authority or game permission required for an in-world action.

The security architecture must be based on the actual platform capabilities and a documented threat model. It must not assume that a connected service, private repository, authenticated user or hidden interface automatically makes all data secure.

### Security principles
The security model follows:
- Least privilege: each identity receives only the access required for its defined purpose.
- Default deny: access is denied unless an explicit policy permits it.
- Separation of duties: incompatible powers and approvals are separated.
- Defence in depth: no single interface or application check is the only protection for sensitive data.
- Explicit identity: every user, service and privileged process is attributable.
- Purpose limitation: access is justified by a defined operational or administrative purpose.
- Data minimisation: only required information is exposed.
- Secure by design: security controls are part of architecture, schema and workflow design.
- Fail secure: uncertainty or unavailable authorisation results in denial of high-impact access or action.
- Revocation: access can be promptly withdrawn when roles, assignments or risks change.
- Accountability: material access and privileged changes are logged and reviewable.
- Resilience: security controls remain effective during failure, recovery and emergency operation.
- Confidentiality with oversight: protection must not be used to obstruct lawful audit or independent review.

No user, administrator, developer, model or service process may bypass the security model merely because it can technically reach the database or repository.

### Identity domains and separation
The system distinguishes:
- The real ChatGPT account or platform identity.
- The authenticated project user, if a separate application identity is introduced.
- The fictional player identity.
- The fictional police employee identity.
- The fictional NPC identity.
- A service or integration identity.
- A database administrator or infrastructure identity.
- A project developer or repository maintainer identity.

These identities are not interchangeable. The real user's platform identity does not become a fictional police identity automatically. A fictional officer cannot authenticate to Supabase merely because their personnel record exists. A developer's repository access does not grant in-world command authority.

Where the application uses an external identity provider, the identity mapping is explicit, unique and auditable. A single authenticated project user may control a player character only through an approved association. Character switching is explicit and cannot transfer one character's permissions to another.

Service identities are separate from human users, have defined purposes, use restricted credentials and cannot be used as shared human logins. Administrative and emergency accounts are individually attributable.

### Authentication and session security
Authentication verifies the identity of a real user or service. It is distinct from authorisation and fictional character authority.

The design considers:
- Approved identity provider and authentication method.
- Strong credential and password policy where applicable.
- Multi-factor authentication for privileged or sensitive access where supported.
- Session lifetime, refresh and revocation.
- Device and token handling.
- Failed login and suspicious activity controls.
- Account recovery and identity verification.
- Service-to-service authentication.
- Secure logout and credential rotation.
- Session invalidation after role or access changes.

The actual application authentication design remains open. The project must not expose Supabase service-role credentials, database passwords, provider secrets or privileged tokens in client-side code, prompts, public repositories or ordinary logs.

A session is not trusted indefinitely. Sensitive actions may require renewed authentication or an additional approval step under the security policy.

### Authorisation model
Authorisation determines whether an authenticated identity may perform a particular action on a particular resource in a particular context.

The model may combine:
- Role-based access control (RBAC).
- Attribute-based access control (ABAC).
- Relationship- or context-based access rules.
- Explicit delegated authority.
- Purpose-of-use restrictions.
- Time-bounded and case-bounded permissions.

A permission decision considers, as relevant:
- User or service identity.
- Active fictional character.
- Rank, appointment, position and unit.
- Current posting and duty status.
- Assigned case, incident or task.
- Legal authority and scope.
- Required qualification or clearance.
- Record classification.
- Geographic or institutional jurisdiction.
- Purpose and necessity.
- Time, expiry and revocation.
- Conflict of interest or restriction.
- Approval or supervisory requirement.

Roles provide reusable permission groupings but do not replace contextual checks. A user who can read one case does not automatically read all cases. A supervisor may see deployment information but not every confidential personnel, medical or disciplinary record. A finance officer may process payments but cannot alter evidence or direct investigations.

### Fictional authority and technical permission
The system separately validates:
- Whether the player is authenticated to the platform.
- Whether the player may access the game.
- Which fictional character is active.
- Whether the character is authorised for the requested action.
- Whether the character has the required qualification, clearance or appointment.
- Whether a legal power or warrant is required and valid.
- Whether supervisory or institutional approval is required.
- Whether the database policy permits the underlying record operation.

All required checks must pass. Technical access cannot substitute for a missing legal authority. A valid legal authority cannot be executed by a character who lacks the required operational role or qualification unless the applicable rules expressly permit it.

Rank, appointment, position, grade, clearance, qualification, legal power and delegated authority remain distinct. A higher rank does not automatically bypass record confidentiality or specialist controls.

### Permission catalogue and policy ownership
The service maintains a versioned permission catalogue. Each permission identifies:
- Unique permission identifier.
- Resource or domain.
- Action allowed.
- Scope and constraints.
- Eligible roles or attributes.
- Required purpose or relationship.
- Required approval or legal basis.
- Applicable record classification.
- Effective date and expiry.
- Policy owner and approving authority.
- Audit and review requirements.

Actions may include view, search, create, update, submit, approve, assign, export, disclose, delete where legally permitted, correct, archive, administer or audit.

Domain owners define the legitimate business purpose and decision authority. BP-42 defines how those rules are enforced consistently across the application and database.

Permissions are not granted by broad wildcard access where a narrower policy is practical. Sensitive domains use explicit access policies and review.

### Record, field and action-level protection
Access is evaluated at the appropriate granularity:
- Domain or schema.
- Table or record type.
- Individual record.
- Field or data element.
- Action or state transition.
- Relationship traversal.
- Export or bulk query.
- Administrative function.

A user may be allowed to see that a record exists but not its protected contents. The interface may show a redacted or restricted status without exposing the hidden fields.

A user who can access a case record does not automatically gain access to linked medical, personnel, intelligence, whistleblowing or privileged legal material. Each linked domain applies its own policy.

Bulk access and export are treated as higher-risk actions than ordinary single-record viewing. The system records purpose, scope, filters, volume and approval where required.

### Database security and row-level enforcement
The database enforces access rules independently of the user interface. The intended Supabase/PostgreSQL design uses appropriate roles, grants, row-level security (RLS), secure views, controlled functions and server-side access patterns as approved.

The final policies must ensure:
- Public or anonymous access cannot read or alter private game records.
- Authenticated users see only records permitted by their identity and purpose.
- Users cannot forge their own fictional rank, unit, case assignment or permission attributes.
- Service-role access is restricted to trusted server-side processes.
- RLS is enabled and tested on exposed tables where required.
- Views and functions do not accidentally bypass intended restrictions.
- Security-definer functions have a controlled owner, search path and privilege scope.
- Direct database access cannot bypass domain validation for consequential actions.
- Cross-domain joins preserve access restrictions on every referenced record.
- Sensitive data is not exposed through error messages, logs or public API schemas.

The exact RLS policy structure must be derived from the approved identity model and tested against positive and negative access cases before any game data is introduced.

### Privileged and administrative access
Privileged access includes database administration, schema migration, policy configuration, secret management, repository administration, production deployment and recovery.

Privileged access is:
- Granted to named identities.
- Limited to the required environment and task.
- Protected by stronger authentication where available.
- Time-bounded where practicable.
- Logged and reviewed.
- Revoked when no longer required.
- Separated from ordinary gameplay and service identities.

No shared administrator account is used for routine human actions. A developer may modify code but cannot silently alter authoritative game facts. A database administrator may manage infrastructure but cannot make an unsupported domain decision. Where a technical repair requires changing domain data, the action is approved and recorded by the accountable domain owner.

### Secrets, keys and credential management
Secrets include database passwords, service-role keys, access tokens, signing keys, encryption keys, webhook secrets and third-party credentials.

Secrets must:
- Be stored in an approved secret-management facility.
- Be absent from GitHub source, documentation, commits and client bundles.
- Be restricted to the smallest required service or operator set.
- Be rotated according to risk and policy.
- Be revocable and replaceable.
- Be excluded from ordinary application logs and error reports.
- Have a documented owner and recovery route.
- Be handled safely during local development and deployment.

Public client configuration and public anonymous keys are not treated as secrets, but they do not provide security by themselves. Their safe use depends on correctly enforced database and API policies. Service-role credentials are privileged and must never be exposed to a browser or player-controlled environment.

A suspected credential leak triggers containment, revocation or rotation, scope assessment, audit review and incident handling. Removing a secret from the latest file does not erase it from repository history or prior exposure; the credential must be treated as compromised.

### Secure integration and service access
Each integration has a defined identity, purpose, data scope, authentication method, permission set, owner and failure behaviour.

Service-to-service access uses restricted credentials and documented contracts. An integration is not trusted merely because it is connected or belongs to a recognised provider.

Inbound data is validated and treated as untrusted until the relevant domain process accepts it. Outbound data is minimised and approved. Webhooks and asynchronous callbacks verify authenticity, prevent replay where appropriate and record delivery or failure.

Third-party tools receive no general access to the game database unless specifically required and approved. External access is revoked when the integration is disabled or its purpose ends.

### Audit, monitoring and access review
Security-relevant events are recorded, including:
- Authentication and session events.
- Permission grants, changes and revocations.
- Denied access attempts.
- Sensitive record views and exports where required.
- Privileged administrative actions.
- RLS and policy changes.
- Secret creation, rotation and revocation.
- Integration configuration and access.
- Break-glass activation.
- Security incidents and remediation.
- Changes to fictional character authority or role mappings.

Logs record actor, target, action, time, source, result, purpose and relevant policy version. They must not expose credentials or unnecessary sensitive content.

Access reviews verify that users and services still require their permissions. Reviews occur at defined intervals and after material changes such as transfer, promotion, departure, contract end, role change, case closure or suspected compromise.

Security monitoring detects unusual access volume, repeated denied requests, privilege escalation, suspicious exports, unexpected service identities and changes outside approved release processes.

### Break-glass and emergency access
Emergency access may be necessary to protect life, preserve evidence, maintain critical service or respond to a serious incident. It is exceptional, not a routine shortcut.

A break-glass process defines:
- Qualifying emergency conditions.
- Permitted identity and role.
- Exact data or action scope.
- Duration and automatic expiry.
- Required reason and incident reference.
- Immediate logging and notification.
- Independent post-event review.
- Revocation and remediation.
- Prohibited actions and legal limits.

Emergency access does not create statutory powers, override a court order or authorise an otherwise unlawful action. Where possible, the system uses a second approver. If immediate action cannot wait, the action is recorded and independently reviewed promptly afterward.

### Security incident response
A security incident may involve credential compromise, unauthorised access, data disclosure, malicious alteration, data loss, service disruption, privilege escalation, insecure integration or abuse of administrative access.

The response process includes:
1. Detect and record the incident.
2. Assess severity, affected identities, records and systems.
3. Contain access or isolate affected services.
4. Preserve logs and relevant evidence.
5. Revoke or rotate compromised credentials.
6. Assess data exposure, alteration and integrity.
7. Notify the responsible security and governance authorities.
8. Recover using BP-39 where required.
9. Validate permissions and authoritative state.
10. Review root cause and implement corrective action.
11. Complete required notifications under the applicable law.
12. Close only when evidence supports safe resolution.

Security incident response is distinct from a fictional police incident or criminal investigation, although the events may be linked. Any internal or criminal investigation follows its own authority, evidence and confidentiality rules.

### Player experience and authority
The interface displays only actions and records permitted to the current user and character. Where access is denied, it provides a safe explanation without revealing the existence or content of protected records beyond what policy allows.

The player can review their own authorised roles and current fictional character authority, request access through the proper route, report suspected security issues and use emergency access only when explicitly authorised.

The player cannot:
- Grant themselves a rank, appointment, clearance or qualification.
- Change their case assignment to gain access.
- Bypass database security through natural-language commands.
- Obtain another user's credentials.
- Expose secrets or administrative configuration.
- Use break-glass access for convenience.
- Treat a technical error as permission.
- Use an administrative development capability as an in-world police power.

### Connections to other divisions
- **BP-01 to BP-41:** all domain records, actions, commands, notifications and reports subject to security controls.
- **BP-30:** governance, risk ownership, delegation, audit and oversight.
- **BP-31:** misconduct, corruption, unauthorised access and disciplinary referral.
- **BP-35:** runtime identity and permission checks during command and event processing.
- **BP-38:** record classification, schema, data ownership, provenance and access metadata.
- **BP-39:** backup access, credential recovery, incident containment and restoration.
- **BP-40 and BP-41:** interface restrictions, notification routing and report disclosure.
- **BP-43:** authentication, authorisation, RLS, secret scanning and penetration/security tests.
- **BP-44:** approved security settings, environments and controlled configuration.

### Exceptions and edge cases
The design must handle an authenticated user without a fictional character; a character with no current appointment; a role change during an active session; a transfer while a case remains assigned; an expired qualification; a revoked warrant or authority; a user with conflicting roles; a supervisor seeking access to a subordinate's confidential record; an investigator with a personal conflict; a former employee retaining a session; a compromised account; leaked service-role key; leaked repository secret; an RLS policy error; a security-definer function bypass; a public view exposing protected fields; a bulk export beyond purpose; an integration using excessive permissions; a delayed revocation; an unavailable identity provider; a failed second factor; an emergency break-glass request; a break-glass session that exceeds its duration; an administrator modifying authoritative data; an unauthorised permission grant; a denied access attempt that reveals protected record existence; a backup restore that reopens old permissions; a development environment connected to production data; and a security incident during a service outage.

The system must fail securely, preserve audit evidence, revoke access promptly and require independent review where the risk or domain warrants it.

### Acceptance conditions
- Platform identity, project identity, fictional character and service identities are distinct.
- Authentication and authorisation are separate controls.
- Default access is denied unless an explicit policy permits it.
- Permissions are based on role, attributes, purpose, scope and current authority as required.
- Fictional rank or appointment alone does not grant unrestricted database access.
- Technical access cannot substitute for legal authority or qualification.
- Record, field, action and export permissions are enforced at the appropriate layer.
- Database access controls protect records independently of the interface.
- RLS and privileged functions are tested against unauthorised as well as authorised cases.
- Service-role keys and other privileged secrets are never exposed in client code or source control.
- Privileged actions are attributable, restricted and reviewed.
- Permission changes and revocations take effect within defined security expectations.
- Break-glass access is limited, logged, time-bounded and independently reviewed.
- Integrations use scoped identities and validated data contracts.
- Security events and sensitive access are auditable without leaking secrets.
- Security incidents have a defined containment, recovery and review process.
- The player cannot elevate fictional authority or bypass controls through commands.

**Draft status:** BP-42 is a working design. The final identity provider, authentication methods, role and attribute catalogue, character-to-user mapping, data-classification policy, RLS policy set, privileged access model, secret manager, encryption and key-management configuration, security monitoring, break-glass conditions, access-review frequency and incident-response obligations remain open. No game authentication, authorisation policies, RLS-protected game tables or security operations process has been implemented.


---

## BP-43 — Testing and Quality Assurance

### Purpose and scope
Define the verification, validation, testing, quality-assurance and release-readiness framework for the simulation. BP-43 ensures that the design is complete enough to implement, software behaves as specified, data remains accurate, permissions are enforced, simulation outcomes are coherent and changes do not silently break previously working systems.

BP-43 covers:
- Requirements traceability and acceptance criteria.
- Test strategy, planning and governance.
- Unit, integration, contract and end-to-end testing.
- Database schema, migration and data-integrity testing.
- Simulation, event, NPC and time-system testing.
- Police workflow and domain acceptance testing.
- Security, privacy and permission testing.
- Performance, capacity and reliability testing.
- Recovery, backup and disaster-recovery testing.
- Usability, accessibility and player-experience testing.
- Regression testing and release gates.
- Test data, fixtures and scenario management.
- Defect classification, triage and remediation.
- Test evidence, results and quality reporting.

BP-43 does not replace:
- BP-30 for institutional governance and approval authority.
- BP-35 for runtime behaviour and simulation execution.
- BP-38 for record definitions, schemas and data integrity rules.
- BP-39 for persistence, backup and recovery design.
- BP-40 for interface and accessibility requirements.
- BP-42 for security architecture and access policies.
- BP-44 for configuration and release settings.

A test passing does not prove that an entire division is implemented or that the overall simulation is complete. Verification claims must identify the tested scope, version, environment, test evidence, known limitations and approval status.

### Quality principles
Quality assurance follows:
- Requirement traceability: each material requirement maps to one or more tests or an explicit reason why it cannot be automated.
- Risk-based priority: testing effort reflects legal, safety, evidential, financial, privacy and operational impact.
- Repeatability: test inputs, environment and expected outcomes are documented.
- Independence: high-impact outcomes receive review independent of the person who implemented the change where practicable.
- Realism: simulation tests reflect plausible operational and institutional conditions.
- Adversarial testing: invalid, malicious, contradictory and boundary inputs are tested.
- Evidence: results are retained and attributable.
- Regression protection: fixes and changes do not reintroduce known failures.
- Fail-safe behaviour: uncertain or failed checks do not produce unsafe success.
- Continuous quality: tests run throughout design, implementation and maintenance.
- Honest status: drafted, implemented, tested and verified remain distinct states.

Testing is not postponed until the entire game is built. Each approved component has tests proportionate to its risk before it is relied upon by dependent systems.

### Requirements and traceability
Requirements are assigned stable identifiers and linked to:
- Blueprint division and section.
- Requirement statement.
- Dependency and affected domain.
- Risk and criticality.
- Acceptance criterion.
- Test case or verification method.
- Test data and environment.
- Result and evidence.
- Defect or exception.
- Approval and release reference.

The traceability model supports forward and backward review. Every implemented requirement can be traced to its source; every approved requirement can be traced to an implementation status or an explicit outstanding gap.

A requirement without a test may be covered by documented inspection, review, simulation exercise or other justified verification. The reason and approving authority are recorded. A generic statement that a system was "checked" is not sufficient evidence.

### Test levels and types
The test strategy may include:
- **Static review:** requirements, schemas, source code, configuration and documentation inspected without executing the system.
- **Unit tests:** individual functions, rules, validators and calculations.
- **Component tests:** a bounded domain module tested with controlled dependencies.
- **Integration tests:** connected modules, database operations and external interfaces tested together.
- **Contract tests:** request, response, event and schema contracts verified between components.
- **End-to-end tests:** complete player workflows exercised through the supported interface.
- **Simulation tests:** time, event, NPC and world behaviour assessed over controlled scenarios.
- **Data tests:** identity, referential integrity, provenance, temporal history and migration outcomes validated.
- **Security tests:** authentication, authorisation, RLS, privilege boundaries and sensitive-data exposure assessed.
- **Performance tests:** response time, throughput, queue behaviour, database load and capacity measured.
- **Resilience tests:** failure, retry, outage, recovery and degraded operation examined.
- **Usability and accessibility tests:** player interaction, clarity, keyboard access and non-visual usability assessed.
- **Acceptance tests:** requirements evaluated against agreed player and project outcomes.
- **Regression tests:** previously verified behaviour retested after changes.

The test plan identifies which levels are required for each component. High-risk changes require broader testing than low-impact wording or presentation changes.

### Test case design and coverage
A test case defines:
- Unique test identifier.
- Requirement or risk covered.
- Purpose and scope.
- Preconditions and required permissions.
- Environment and version.
- Test data and fixture references.
- Steps or executable procedure.
- Expected result and invariant.
- Actual result.
- Pass, fail, blocked or not-run status.
- Evidence and logs.
- Tester and date.
- Defect reference and retest result.

Test coverage is measured against requirements, critical workflows, domain states, permissions, exception cases and failure modes. Code coverage may support analysis but does not replace requirement or risk coverage.

The project maintains coverage for:
- Normal and successful paths.
- Boundary and limit conditions.
- Invalid and incomplete inputs.
- Missing, duplicated or conflicting records.
- Concurrent and out-of-order actions.
- Permission denial and authority failure.
- Time and scheduling edge cases.
- Failure, retry and recovery.
- Privacy, security and disclosure boundaries.
- Historical and retrospective changes.
- Player interruption and resumption.

A high percentage of passing tests cannot compensate for a missing critical test. Coverage reports identify untested high-risk requirements.

### Test data and scenario management
Test data is controlled, reproducible and separated from live authoritative game data. It may use synthetic people, properties, businesses, cases, incidents, evidence and organisations created for testing.

Test fixtures identify:
- Dataset or scenario identifier.
- Purpose and requirements covered.
- Data-generation method.
- Version and creation date.
- Dependencies and expected relationships.
- Known limitations.
- Reset and cleanup procedure.
- Whether data is synthetic or approved anonymised material.

Real personal, personnel, financial, evidential or sensitive information is not copied into a test environment without a lawful and approved basis. Test data must not leak into live gameplay or be mistaken for canon.

Scenarios may include routine patrol, emergency response, complex investigation, evidence handling, custody, court process, HR decisions, procurement, system outage, concurrent incidents and other representative workflows. The same scenario can be replayed against a new release to identify regression.

### Domain and workflow testing
Each domain division defines tests for its own substantive rules. Cross-domain tests verify that the interfaces do not create contradictory or unauthorised outcomes.

Examples include:
- A dispatch task cannot assign an unavailable or unqualified officer.
- An incident can progress into a case without duplicating person or location identity.
- Evidence preserves continuity and links to the correct case and exhibit.
- An arrest requires the appropriate authority and records its basis.
- Custody safeguards and time limits use the correct legal rule.
- A court order is executed only by the competent institution.
- A sentence calculation uses the approved order and applicable rule version.
- A disciplinary allegation is not treated as a finding.
- Training attendance alone does not confer competence.
- HR employment status does not independently grant police powers.
- Procurement approval, receipt, invoice validation and payment remain separate stages.
- A relationship does not create suspicion by association.
- Time does not advance while the game is unattended.
- A failed write does not appear as a completed action.

The examples are illustrative test expectations; the final test catalogue is derived from approved requirements and legal configuration.

### Simulation and NPC testing
Simulation tests assess whether the world behaves consistently over controlled time intervals and under defined event sequences.

They include:
- Person identity continuity.
- Location and travel consistency.
- Schedule and availability constraints.
- NPC knowledge boundaries.
- Relationship and social-context effects.
- Event ordering and causal dependencies.
- Crime and incident generation constraints.
- Relevance and processing-intensity transitions.
- Resource allocation and release.
- Simultaneous incidents and competing priorities.
- Player action and NPC action conflicts.
- Repeatability under controlled random seeds or recorded inputs.
- No silent progression during inactivity.
- Recovery from interrupted simulation cycles.

A simulation may contain uncertainty and varied outcomes, but a repeated test must be explainable in terms of inputs, configuration, randomisation and rule version. The project records when stochastic variation is intentional and what outcomes remain within acceptable bounds.

### Data, database and migration testing
Database tests verify:
- Primary and foreign-key constraints.
- Identifier uniqueness and non-reuse.
- Valid status transitions.
- Effective-dated history.
- Provenance and audit completeness.
- Duplicate detection and merge safeguards.
- Transaction atomicity.
- Idempotency and retry behaviour.
- Query correctness and pagination.
- RLS and view/function restrictions.
- Schema migration order and compatibility.
- Data backfill and transformation.
- Rollback or forward-repair behaviour.
- Retention and legal-hold metadata.
- Backup and restore integrity.

Migration tests run against an isolated environment with representative data. Destructive migrations require evidence that the recovery strategy works. A migration is not accepted merely because it executes without an error; postconditions and data integrity must also be checked.

### Security and privacy testing
Security tests validate:
- Authentication and session handling.
- Role and attribute assignment.
- Character-to-user mapping.
- Default-deny behaviour.
- Record and field access.
- Row-level security.
- Privileged function boundaries.
- Service-role and secret exposure.
- Bulk export restrictions.
- Cross-domain relationship traversal.
- Access revocation.
- Break-glass expiry and audit.
- Integration authentication and replay protection.
- Sensitive information in logs, notifications and reports.
- Development and test environment separation.

Negative tests are mandatory. The test plan must prove that unauthorised identities cannot read or alter protected records, not merely that authorised users can complete normal workflows.

Security tests do not use uncontrolled destructive actions against the live project. Any penetration or load testing against a connected service requires approval, scope and safe limits.

### Performance and capacity testing
Performance testing establishes whether the system meets approved targets under realistic and peak workloads. It may measure:
- Command response time.
- Database query latency.
- Event-processing throughput.
- Queue depth and processing delay.
- NPC processing cost by intensity.
- Search and report performance.
- Concurrent player or system actions.
- Transaction contention.
- Storage growth and retention impact.
- Recovery and restore duration.

Targets are defined only after expected scale, hosting limits and user experience requirements are established. The test report records environment, workload, dataset size, configuration, measurements and limitations.

Performance improvements must preserve authoritative outcomes, audit history, permissions and simulation fidelity. A faster result is not accepted if it silently drops events or skips required validation.

### Reliability and failure testing
The system is tested against:
- Database or network interruption.
- Failed transaction.
- Partial workflow completion.
- Duplicate command or event.
- Queue backlog.
- External provider failure.
- Invalid or stale configuration.
- Application restart.
- Migration failure.
- Cache divergence.
- Backup failure.
- Restore failure.
- Loss of credentials.
- Corrupted data.
- Recovery from an earlier point.
- Interrupted player session.

Tests verify that failures are visible, state remains consistent, retries are safe and recovery does not duplicate consequential actions.

### Usability and accessibility testing
Interface testing verifies:
- Natural-language command interpretation.
- Clarification of ambiguous requests.
- Clear distinction between pending and completed actions.
- Accurate display of authority and restrictions.
- Readability of records and timelines.
- Search and navigation.
- Error and warning comprehension.
- Text-only completion of essential tasks.
- Keyboard and assistive-technology compatibility where supported.
- Non-colour status communication.
- Appropriate information density.
- Session resumption and continuity.

Testing includes representative users or structured player walkthroughs where feasible. Feedback is recorded with the affected requirement and severity. An interface is not considered usable merely because a developer can operate it.

### Defect classification and management
Defects are recorded with:
- Unique defect identifier.
- Affected requirement, component and version.
- Reproduction steps.
- Expected and actual result.
- Severity and priority.
- Safety, legal, evidential, financial, privacy and operational impact.
- Environment and supporting evidence.
- Workaround where safe.
- Owner and target resolution.
- Root cause where established.
- Fix reference.
- Retest and regression result.
- Closure authority.

Severity distinguishes critical integrity or safety failure, high-impact domain failure, material functional defect, moderate usability or data issue and minor presentation issue. Exact labels and response targets are configured.

A defect is not closed merely because code changed. It requires a successful retest and appropriate regression evidence. A known limitation may be accepted only by an authorised owner with documented risk, scope, mitigation and review date.

### Release gates and verification status
A release or component is not marked verified until its required tests pass and evidence is reviewed. Release gates may require:
- Requirements and design review complete.
- No unresolved critical defects.
- High-risk defects resolved or formally accepted.
- Required automated tests passing.
- Required manual and domain acceptance tests complete.
- Database migration validated.
- Security and permission checks passed.
- Recovery and rollback arrangements approved.
- Performance and reliability targets met where applicable.
- Documentation and implementation registers updated.
- Release authority approval recorded.

The project distinguishes:
- Drafted: a design exists.
- Implemented: the feature has been built.
- Tested: specified tests have been run.
- Verified: acceptance evidence has been reviewed and the feature is confirmed against its requirements.
- Blocked: a documented issue prevents progress.

A passing unit test does not make a division verified. A feature may be implemented but not verified. A division may be partially implemented, and the register must show the actual scope.

### Test automation and continuous integration
Automated tests run through the approved repository workflow and deployment process. The test pipeline records:
- Commit and branch.
- Source and dependency versions.
- Environment and configuration.
- Test suite and version.
- Results and failure logs.
- Coverage and quality checks.
- Build and deployment status.

The pipeline must not use production secrets or write to live game data during ordinary tests. Test jobs use isolated fixtures and restricted credentials. Failed critical checks block release according to the approved policy.

Manual test evidence remains necessary for aspects that cannot be reliably automated, such as realistic player experience, legal interpretation, complex operational judgement and certain recovery exercises.

### Test reporting and evidence retention
A test report summarises:
- Scope and requirements covered.
- Version and environment.
- Tests planned, run, passed, failed, blocked and not run.
- Critical gaps and known limitations.
- Defects opened, resolved and accepted.
- Security and data-integrity results.
- Performance and recovery measurements where relevant.
- Evidence references.
- Reviewer and approval status.

Evidence is stored in the approved project record system with links to commits, migrations, build outputs and test artefacts. Test evidence must be reproducible where practicable and retained according to the project's records and audit requirements.

### Player experience and authority
The player should experience a stable and fair simulation, not be exposed to test controls or unfinished test data during ordinary play. Test and development functions are restricted to authorised project roles.

The player may report an apparent defect or inconsistent outcome through a defined route. A reported issue is recorded for review but does not automatically alter the authoritative game state.

Testers may use controlled scenarios and reset data in isolated environments. They cannot use test privileges to alter live case outcomes, erase consequences or grant fictional authority.

### Connections to other divisions
- **BP-01 to BP-42:** all requirements, domain workflows, records, runtime, interface and security controls requiring verification.
- **BP-30:** governance, risk acceptance, audit and release authority.
- **BP-35:** command, event, simulation, NPC, concurrency and runtime testing.
- **BP-37:** calendar, time advancement, deadline, recurrence and scheduling tests.
- **BP-38:** schema, record integrity, provenance, migration and query tests.
- **BP-39:** backup, restore, continuity and recovery exercises.
- **BP-40 and BP-41:** interface, accessibility, notification, report and delivery tests.
- **BP-42:** authentication, authorisation, RLS, secrets and security testing.
- **BP-44:** configuration validation, compatibility and release controls.

### Exceptions and edge cases
The design must handle an untestable requirement; an acceptance criterion with no measurable result; missing test data; unreliable test environment; flaky test; test passing only under a particular order; nondeterministic simulation result; false-positive security alert; false-negative permission test; incomplete migration coverage; destructive test affecting live data; unavailable external dependency; test credentials with excessive access; a defect that cannot be reproduced; a defect with no safe workaround; a critical issue discovered after release; a test result tied to an obsolete commit; an undocumented manual change; conflicting test evidence; a release with accepted known defects; a test suite that passes while an important requirement is untested; and a restore test that cannot meet the approved recovery target.

The project must record the limitation, risk, owner, decision and next verification step. Missing evidence cannot be represented as a pass.

### Acceptance conditions
- Every approved requirement has traceable verification coverage or an approved alternative.
- Test plans are risk-based and include positive, negative, boundary and failure cases.
- Test cases record inputs, expected results, actual results, environment and evidence.
- Test data is controlled and separated from live game records.
- Domain and cross-domain workflows are tested.
- Simulation time, NPC knowledge, event ordering and relevance processing are tested.
- Database constraints, migrations, provenance and historical integrity are tested.
- Security tests include unauthorised access and privilege-boundary cases.
- Performance and reliability targets are measured against documented workloads.
- Backup and restore procedures are tested rather than assumed.
- Accessibility and text-only gameplay are verified.
- Defects have severity, owner, evidence, remediation and retest.
- Release gates prevent unverified high-risk changes from being treated as complete.
- Automated tests are linked to source commits and run with restricted credentials.
- Test reports identify untested scope, known limitations and approval status.
- Implementation and verification status are kept separate in the project registers.

**Draft status:** BP-43 is a working design. The detailed requirement-to-test matrix, test catalogue, automated test framework, CI pipeline, test environments, synthetic data library, performance targets, security testing scope, accessibility standards, defect severity policy, release gates, evidence-retention rules and independent review arrangements remain open. No automated test suite, quality-assurance pipeline or verified gameplay test environment has been implemented.


---

## BP-44 — Configuration and Expansion

### Purpose and scope
Define how the simulation is configured, customised, versioned and extended without corrupting established canon, weakening controls, creating uncontrolled scope or breaking existing records and systems. BP-44 provides the controlled mechanism for changing approved settings, adding capabilities, introducing new content and managing future expansion.

BP-44 covers:
- Configuration architecture and ownership.
- Separation of code, environment settings, game rules and world canon.
- Defaults, permitted values and configuration validation.
- Scenario and game-start configuration.
- Feature flags and controlled feature activation.
- Versioning, approval, effective dates and change history.
- Configuration deployment and rollback.
- Extension and integration approval.
- New domain, entity and content proposals.
- Compatibility and migration requirements.
- Scope control and dependency impact assessment.
- Controlled reset, restart and test scenarios.
- Configuration audit and governance.

BP-44 does not replace:
- BP-01 for the game's identity, scope and governing rules.
- BP-30 for institutional governance, approval authority and change control.
- BP-35 for runtime execution of approved configuration.
- BP-37 for calendar and time configuration semantics.
- BP-38 for schema and data-domain governance.
- BP-39 for persistence, backup, recovery and controlled reset.
- BP-42 for security and secrets.
- BP-43 for testing and release verification.

Configuration changes how an approved system operates within its defined rules. It does not silently amend the fundamental identity, legal framework, authority model, data ownership or scope of the game. A configuration value cannot create a statutory power, remove a legal safeguard, turn a draft design into an implemented feature or override an approved blueprint requirement.

### Configuration principles
Configuration is:
- Explicit: every setting has a defined name, purpose, type and permitted value.
- Owned: each setting has an accountable domain or technical owner.
- Versioned: changes preserve prior values and effective periods.
- Validated: invalid or contradictory settings are rejected.
- Controlled: material changes require approval and testing.
- Traceable: changes record actor, reason, source and result.
- Environment-aware: development, test and live settings remain distinct.
- Secure: secrets and privileged values are not stored in ordinary configuration files.
- Reproducible: a scenario or release can identify the configuration used.
- Compatible: changes do not silently invalidate existing records or interfaces.
- Reversible where possible: rollback or forward-repair is planned before deployment.
- Scope-limited: additions require a documented purpose and impact assessment.

A default value is not automatically an approved law or permanent canon. Unresolved settings remain explicitly provisional or unset until approved.

### Configuration categories
The configuration catalogue distinguishes:
- **Project configuration:** repository, environments, build settings and approved development conventions.
- **Technical configuration:** database connections, service endpoints, logging levels and runtime limits.
- **Security configuration:** authentication, permissions, secrets references, access policies and encryption settings.
- **Simulation configuration:** processing intervals, event priorities, NPC intensity and runtime limits.
- **Time configuration:** calendar, time zone, advancement and scheduling parameters owned by BP-37.
- **World configuration:** approved country, city, population, geography, institution and scenario settings.
- **Domain configuration:** controlled offence categories, rank structures, legal rules, qualifications, financial thresholds and other domain-owned values.
- **Interface configuration:** command aliases, display preferences, output density and accessibility options.
- **Notification configuration:** categories, priorities, templates and routing rules.
- **Test configuration:** isolated test fixtures, deterministic seeds, test limits and synthetic data.
- **Scenario configuration:** approved starting conditions, player entry point and scenario-specific settings.

Each category has a defined owner and approval route. Technical settings do not override domain policy. Domain settings do not expose secrets. Scenario settings do not silently change persistent canon.

### Configuration catalogue and schema
Every setting has:
- Stable configuration identifier.
- Name and description.
- Category and domain owner.
- Data type and permitted format.
- Default value where approved.
- Allowed range, options or validation rule.
- Whether the value is required, optional or unset.
- Current value and version.
- Effective start and end.
- Source and approval authority.
- Dependencies and conflicting settings.
- Environment or scenario scope.
- Security classification.
- Change history and rollback information.

Configuration is stored in a controlled schema or configuration service appropriate to its sensitivity and use. Critical settings are not scattered across source files, database rows and undocumented prompt instructions with no single authoritative owner.

The system distinguishes configuration values from operational data. A patrol officer's current assignment is a game record, not a global configuration setting. A statutory deadline is a domain rule or approved legal configuration, not a user preference. A user's display density is an interface preference, not a change to simulation truth.

### Defaults, validation and precedence
Configuration precedence is explicitly defined. A lower-level override cannot silently supersede a higher-authority rule.

The configuration hierarchy may include:
1. Fundamental blueprint and governing constraints.
2. Approved legal and institutional domain rules.
3. Approved project-wide configuration.
4. Environment-specific technical configuration.
5. Scenario-specific settings.
6. Permitted user interface preferences.

The exact hierarchy and permitted override relationships are documented for each category. A setting cannot override a higher-level rule unless the governing requirement expressly permits that kind of variation.

Validation checks type, range, permitted values, required dependencies, conflicts, effective dates, security and compatibility. A configuration set that fails validation is not activated.

Where a setting is unresolved, the system does not invent a value merely to continue. It either uses an explicitly approved safe default or marks the dependent feature as unavailable pending a decision.

### Environment separation
Development, test, staging and live environments have separate configuration and access controls where those environments are used.

The environment catalogue identifies:
- Environment purpose and owner.
- Connected repository branch or release.
- Database project and schema.
- Authentication and permission configuration.
- External integrations.
- Test or live data classification.
- Secrets references.
- Backup and recovery settings.
- Deployment and access permissions.
- Current application and schema versions.

Development and test environments must not write to the live game database accidentally. Test fixtures and reset operations are restricted to isolated environments. A production release cannot inherit permissive test credentials or disabled security controls.

The current project uses the documented main-only GitHub branch convention. Environment or release procedures must respect the approved repository workflow and must not create additional branches without an explicit change to that governing rule.

### Scenario and game-start configuration
A scenario configuration defines the initial conditions under which a game begins or a controlled test is run. It may identify:
- Scenario identifier and version.
- Starting simulation date and time.
- Starting location and jurisdiction.
- Player entry route and initial character options.
- Initial organisational and operational state.
- Enabled and disabled optional features.
- Relevant world and domain configuration versions.
- Scenario-specific events or constraints.
- Required test or acceptance conditions.
- Whether the scenario is a live persistent game, isolated test or demonstration.

A scenario does not automatically create a second authoritative world or permit arbitrary changes to existing canon. The rules for multiple characters, separate campaigns, test worlds or scenario resets must be explicitly approved.

The system distinguishes a new game, a new character within an existing game, a scenario reload, a test reset and restoration from backup. These operations have different effects on persistent records and must not be presented as interchangeable.

### Feature flags and staged activation
Feature flags may control whether an implemented capability is available in a particular environment, scenario or user context.

A feature flag records:
- Feature identifier and owner.
- Purpose and affected components.
- Current state.
- Allowed scope and eligible users.
- Dependencies and prerequisites.
- Start, review and expiry dates.
- Test and acceptance evidence.
- Approval and rollback route.

A feature flag does not prove that a feature is implemented or verified. An unavailable or disabled feature must not be represented as operational merely because its flag exists.

High-impact features, such as legal powers, financial transactions, sensitive data access, evidence handling and simulation-time progression, require appropriate domain and security approval before activation.

### World canon and domain configuration
The simulation distinguishes:
- Established world facts and canon.
- Approved domain rules.
- Provisional design assumptions.
- Scenario-specific starting conditions.
- Dynamic game state.
- User preferences.
- Technical environment settings.

A change to a permanent world fact or domain rule requires a documented change proposal and impact assessment. The proposal identifies the existing rule, requested change, reason, affected records, dependencies, historical implications, migration needs, player impact and approval authority.

A configuration change must not silently rewrite the past. If a new rule affects historical interpretation, the change records whether it applies prospectively, retrospectively or only to a new scenario and why that treatment is authorised.

A proposed setting is not treated as confirmed canon until the required approval is recorded. The interface and project registers identify provisional values so that they are not mistaken for settled decisions.

### Controlled expansion and scope management
An expansion proposal may introduce a new feature, domain, entity type, institution, workflow, interface capability or external integration. It must identify:
- Problem or player need being addressed.
- Intended outcome and user.
- Scope and explicit exclusions.
- Existing blueprint divisions affected.
- New data and identifiers required.
- Legal, operational and security implications.
- Dependencies and external services.
- Resource, performance and cost implications.
- Maintenance and support burden.
- Test and acceptance requirements.
- Migration and recovery implications.
- Risks of duplication or scope overlap.
- Whether the change requires a blueprint revision.

Expansion is accepted only when it strengthens the agreed game rather than creating uncontrolled parallel systems. Existing domain ownership is respected. A new capability should extend or refine an existing division where appropriate instead of duplicating its responsibilities.

A proposal that changes a governing rule, creates a new major domain or alters a permanent boundary requires an explicit blueprint revision. The change is not implemented merely because it is technically possible.

### Change control and approval
A configuration or expansion change follows a controlled lifecycle:
1. Submit a proposal with purpose, scope and owner.
2. Identify the affected settings, requirements and divisions.
3. Assess legal, operational, data, security, privacy, financial and performance impact.
4. Identify dependencies, conflicts and migration needs.
5. Define acceptance tests and rollback or forward-repair.
6. Obtain approval from the competent owner or governance authority.
7. Implement the change in the appropriate environment.
8. Run required tests and review evidence.
9. Deploy or activate the approved version.
10. Monitor the outcome and record any issue.
11. Close, revise or roll back through an auditable decision.

Emergency configuration changes may use an expedited route only where the applicable governance policy permits it. They remain time-bounded, recorded, reviewed and subject to subsequent approval or reversal as required.

### Configuration versioning and compatibility
Configuration versions are immutable once released. A new value creates a new version or dated change record. The system can identify which configuration applied to a particular event, record, scenario or release.

Compatibility rules identify:
- Minimum and maximum supported application version.
- Database schema compatibility.
- Required domain rule versions.
- Deprecated settings and replacement values.
- Migration or conversion requirements.
- Incompatible combinations.
- Rollback constraints.

A setting that is no longer supported is deprecated through a documented process. It is not removed while active records still depend on its meaning. Historical records remain interpretable under the configuration version that governed them.

### Configuration deployment and rollback
Deployment identifies the source version, target environment, approver, operator, validation result and effective time. Sensitive configuration is injected through approved secret-management or environment mechanisms rather than committed as plaintext.

Before activation, the deployment checks:
- Configuration schema validity.
- Required dependencies.
- Security policy and permission compatibility.
- Database and application version compatibility.
- Scenario and domain constraints.
- Required test evidence.
- Backup or recovery readiness where material.

Rollback restores a prior approved configuration where safe. If a change has already created consequential data or external side effects, a simple configuration rollback may be insufficient. The recovery plan defines whether data migration, compensating actions or a forward correction is required.

### Controlled reset and restart
A reset or restart is a high-impact operation. It must identify:
- Target environment and scenario.
- Records and state affected.
- Whether the operation is a technical restart, scenario reset or full game reset.
- Authority and approval.
- Backup or preservation requirements.
- Expected data loss or state change.
- Effect on player characters, cases, evidence, legal records and simulation time.
- Recovery and verification method.

A technical restart does not erase game state. A scenario reset does not automatically delete shared canonical records. A full reset cannot be used to remove evidence, evade consequences or bypass record-retention obligations.

The default is preservation of authoritative history. Any deletion or reset must have a lawful, documented basis and appropriate recovery or archival treatment.

### Configuration audit and governance
The configuration register records all material settings, owners, versions, approvals, changes, deployment results, exceptions and review dates.

Audits may examine:
- Settings changed without approval.
- Expired or unused feature flags.
- Conflicting values.
- Environment drift.
- Secrets stored in the wrong location.
- Test settings active in a live environment.
- Deprecated configuration still in use.
- Features enabled without implementation or verification.
- Scenario changes that contradict canon.
- Repeated emergency overrides.
- Unreviewed expansion proposals.

The audit record identifies findings, risk, owner, action, due date and verification. Configuration governance is linked to BP-30 risk and change control.

### Player experience and authority
The player may use approved preferences and scenario options that are exposed to their role. The player cannot change fundamental canon, legal rules, simulation authority, security policy or persistent game history through ordinary gameplay settings.

The interface identifies which options are:
- Personal display preferences.
- Scenario choices.
- Approved game rules.
- Provisional settings.
- Technical or administrative controls unavailable to ordinary players.

A setting change explains its scope and whether it affects only presentation, a new scenario or the persistent game world. The player is not led to believe that a visual preference changes authoritative simulation state.

### Connections to other divisions
- **BP-01 to BP-43:** all divisions whose rules, data, runtime, interfaces, security and tests may be configured or extended.
- **BP-30:** institutional governance, change approval, risk and scope control.
- **BP-35:** runtime configuration loading, feature activation and execution.
- **BP-37:** calendar, time-zone, scheduling and time-advancement configuration.
- **BP-38:** configuration schemas, identifiers, records and version history.
- **BP-39:** backup, restore, reset and recovery planning.
- **BP-40 and BP-41:** interface preferences, notification settings and report configuration.
- **BP-42:** security settings, identity, permissions, secrets and environment boundaries.
- **BP-43:** configuration validation, compatibility, regression and release testing.

### Exceptions and edge cases
The design must handle an invalid setting; missing required value; conflicting overrides; expired configuration; feature flag enabled before implementation; feature flag enabled without verification; configuration changed during an active operation; a new rule incompatible with historical records; an environment accidentally connected to live data; a secret committed to GitHub; an emergency override without a clear expiry; a reset requested while a case is active; a scenario reset that would erase shared identities; a failed configuration deployment; a rollback after external side effects; a migration requiring a new schema; a deprecated value still used by old records; an expansion proposal duplicating an existing domain; a change with no accountable owner; an unapproved canon change; a test-only setting active in live play; a configuration backup that cannot be restored; and a release whose configuration differs from the tested version.

The system must reject invalid activation, preserve prior versions, identify the scope of impact and route exceptions to the correct approval authority.

### Acceptance conditions
- Every configuration value has a type, owner, permitted range, version and approval basis.
- Configuration categories and precedence are explicit.
- Environment, scenario, domain, technical and user-preference settings remain distinct.
- Invalid or conflicting configuration cannot be activated.
- Unresolved settings remain explicitly provisional or unset.
- Feature flags do not imply implementation or verification.
- World canon and domain-rule changes follow controlled blueprint revision.
- Expansion proposals include scope, dependencies, risk, cost, security and test impact.
- Configuration changes are versioned, approved, auditable and reproducible.
- Releases identify the configuration used during testing and deployment.
- Rollback and forward-repair are planned for material changes.
- Resets distinguish technical restart, scenario reset and full game reset.
- Authoritative history is not deleted by ordinary reset or configuration change.
- Secrets remain outside ordinary source-controlled configuration.
- Security and environment boundaries are preserved during deployment.
- The player can distinguish preferences, scenario choices and authoritative game rules.
- Configuration and expansion changes can be traced to requirements and test evidence.

**Draft status:** BP-44 is a working design. The final configuration schema, environment model, scenario catalogue, feature-flag system, change-approval matrix, versioning strategy, deployment process, rollback rules, reset authority, extension policy and configuration audit schedule remain open. No configuration service, feature-flag platform, scenario manager or controlled expansion framework has been implemented.
