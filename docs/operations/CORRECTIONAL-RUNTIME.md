# Correctional command/runtime integration

**Status: command parser and runtime dispatch integrated; rollback-only regression passed.**

The correctional foundation now connects to the existing Kingswell text command engine. Existing interpreter and executor functions were retained under fallback names; the new correctional parser runs first and all unrelated commands continue through the prior implementation.

## Commands

Create a fictional facility:

`prison facility create by PERSONNEL_REF name "Kingswell Remand Centre" type remand capacity 120 location "North Kingswell"`

Admit an NPC to remand:

`prison admit person PERSON_REF to FACILITY_REF by PERSONNEL_REF type remand notes "Admission details" court_case COURT_CASE_REF`

Admit an NPC to begin a custodial sentence:

`prison admit person PERSON_REF to FACILITY_REF by PERSONNEL_REF type sentenced notes "Sentence admission" sentence SENTENCE_REF`

Add another custodial sentence to an active admission:

`prison sentence add ADMISSION_REF sentence SENTENCE_REF sequence 2 mode consecutive by PERSONNEL_REF notes "Second sentence"`

The sequence must be the next number. The first term uses `first`; later terms use `concurrent` or `consecutive`.

Place or move a prisoner within their assigned facility:

`prison place ADMISSION_REF facility FACILITY_REF unit "A Wing" cell "A-01" by PERSONNEL_REF reason "Initial placement"`

Retrieve a correctional record:

`prison record ADMISSION_REF by PERSONNEL_REF`

List facilities and occupancy:

`prison facilities by PERSONNEL_REF`

## Runtime rules

- Commands use the shared game-command idempotency ledger.
- All state-changing actions require an initialized fictional clock and active/seconded police personnel actor.
- No command advances fictional time; actions are recorded at the current manual game time.
- Admissions reject duplicate active custody, unknown people/facilities and full facilities.
- Sentenced admissions require an existing custodial sentence, a guilty verdict and a matching accused NPC identity.
- Additional sentence terms require an active admission, matching accused identity and a guilty verdict; sequence and commencement mode are checked.
- Cell occupancy is unique within a facility/unit/cell while a placement remains active.
- Existing court, police, custody and other command parsers remain on the fallback chain.

## Verification and limits

The rollback-only test covers all six new parser routes, an existing court verdict parser and live executor dispatch rejection for an unknown actor. It confirms no test command persists.

**Not yet implemented:** sentence credit command, cumulative concurrent/consecutive release calculation, sentence completion and release, prison transfers, staff profiles/rosters, daily routines, visits, communications, work/education, welfare, incidents, discipline, rehabilitation, parole and autonomous NPC activity. The command actor currently uses an active/seconded police personnel identity; a dedicated correctional staff/NPC role system remains future work.
