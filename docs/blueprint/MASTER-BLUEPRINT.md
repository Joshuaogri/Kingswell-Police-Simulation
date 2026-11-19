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
