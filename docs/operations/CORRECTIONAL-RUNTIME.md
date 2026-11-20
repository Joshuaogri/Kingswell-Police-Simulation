# Correctional command/runtime integration

**Status: command parser and runtime dispatch integrated; read-only pre-start query fix deployed and regression-tested.**

The correctional foundation connects to the existing Kingswell text command engine. Existing interpreter and executor functions were retained under fallback names; the correctional parser runs first and unrelated commands continue through the prior implementation.

## Commands

- Create a facility: `prison facility create by PERSONNEL_REF name "Kingswell Remand Centre" type remand capacity 120 location "North Kingswell"`
- Admit to remand: `prison admit person PERSON_REF to FACILITY_REF by PERSONNEL_REF type remand notes "Admission details" court_case COURT_CASE_REF`
- Admit to begin a custodial sentence: `prison admit person PERSON_REF to FACILITY_REF by PERSONNEL_REF type sentenced notes "Sentence admission" sentence SENTENCE_REF`
- Add another custodial sentence: `prison sentence add ADMISSION_REF sentence SENTENCE_REF sequence 2 mode consecutive by PERSONNEL_REF notes "Second sentence"`
- Place/move a prisoner: `prison place ADMISSION_REF facility FACILITY_REF unit "A Wing" cell "A-01" by PERSONNEL_REF reason "Initial placement"`
- Retrieve a correctional record: `prison record ADMISSION_REF by PERSONNEL_REF`
- List facilities and occupancy: `prison facilities by PERSONNEL_REF`

Sentence terms must be sequential. The first uses `first`; later terms use `concurrent` or `consecutive`.

## Runtime rules

- Commands use the shared game-command idempotency ledger.
- State-changing actions require an initialized fictional clock and active/seconded police personnel actor.
- **Read-only `prison record` and `prison facilities` queries do not require the fictional clock to be initialized.** The player can inspect correctional records before choosing the game's start time.
- No command advances fictional time; state changes are recorded at the current manual game time.
- Admissions reject duplicate active custody, unknown people/facilities and full facilities.
- Sentenced admissions require an existing custodial sentence, guilty verdict and matching accused NPC identity.
- Additional sentence terms require an active admission, matching accused identity, guilty verdict, sequential numbering and valid commencement mode.
- Cell occupancy is unique within a facility/unit/cell while a placement remains active.
- Existing court, police, custody and other command parsers remain on the fallback chain.

## Verification and limits

**PASS:** rollback-only regression confirmed both read-only commands parse, the executor exempts only those two command types from the clock guard, and the fictional clock remains NULL. No game records were created or changed.

No end-to-end facility/prisoner query was run because there are no seeded correctional facilities, admissions or personnel records to use as a live fixture.

**Not yet implemented:** sentence-credit command, cumulative concurrent/consecutive release calculation, sentence completion and release, prison transfers, correctional staff profiles/rosters, daily routines, visits, communications, work/education, welfare, incidents, discipline, rehabilitation, parole and autonomous NPC activity. A dedicated correctional staff/NPC role system remains future work.

Migration: `database/migrations/20261120161200_correctional_read_only_queries_without_clock.sql`

Test: `database/tests/correctional_read_only_without_clock.sql`
