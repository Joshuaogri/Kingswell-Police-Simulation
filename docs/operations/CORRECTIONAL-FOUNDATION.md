# Correctional foundation and sentence administration

**Status: database foundation implemented; player command/runtime workflows not yet wired.**

This is a fictional Kingswell game subsystem. NPC prisoners, correctional staff, courts and officials are game entities only.

## Implemented records

- `game.correctional_facilities`: fictional remand/prison/open-prison/youth/mixed facilities, capacity and operational status.
- `game.prisoner_admissions`: persistent admission linked to an existing person, facility, optional court case and official.
- `game.prisoner_sentence_terms`: one term per existing imposed sentence, ordered within an admission and labelled first/concurrent/consecutive.
- `game.sentence_credit_events`: append-only credits for pre-sentence custody, appeal credit or adjustments.
- `game.correctional_events`: append-only operational history for admission, placement, transfer, visits, communication, work, education, welfare, incidents, discipline, review, release and escape/return.
- `game.prisoner_placements`: facility/unit/cell history with one current placement per admission.

All six tables have RLS enabled in the private `game` schema. Sentence-credit and correctional-event history reject updates and deletes. Foreign keys link to existing persons, imposed sentences, court cases, court officials and command-ledger entries; no duplicate identities or sentence records are created.

## Read projection

`game.get_correctional_record(admission_ref)` returns the admission, person reference, facility, placement history, linked sentence terms and credits, remaining days per term, and chronological correctional events.

## Sentence-term semantics

Each imposed custodial sentence is represented once. `sequence_number` orders terms. `commencement_mode` records whether a term is first, concurrent or consecutive. Credit is recorded as a separate immutable event and does not overwrite the original sentence. The current projection calculates remaining days per term as original duration less recorded credit.

**Important limitation:** cumulative release-date calculation across concurrent/consecutive terms, sentence commencement/review/release commands, admission workflows, prisoner routines, staffing/capacity enforcement and NPC automation are not yet implemented. Do not treat this foundation as a complete prison simulation.

## Verification

`database/tests/kingswell_correctional_foundation.sql` checks table presence, RLS, append-only triggers and read-projection registration in a transaction that rolls back. No fictional facilities, prisoners, admissions or sentence terms are seeded.
