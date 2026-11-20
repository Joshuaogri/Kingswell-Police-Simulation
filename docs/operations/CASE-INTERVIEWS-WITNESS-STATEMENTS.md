# Case interviews and witness statements

Kingswell records fictional interviews and witness statements against existing cases and existing person records. The interview transcript, witness statement text and event history are append-only; corrections are recorded as supplementary statements rather than editing prior accounts.

## Commands

Open an interview:
```text
case interview record CASE_REF with PERSON_REF by INTERVIEWER_REF method face_to_face purpose "Purpose of interview" location "Interview Room 1" notes "Optional notes"
```

Record each question and answer in chronological order:
```text
case interview turn INTERVIEW_REF by INTERVIEWER_REF question "Question asked" answer "Answer given"
```

Record a witness statement linked to that interview:
```text
case witness statement record CASE_REF for PERSON_REF form written_signed text "Full statement text" from INTERVIEW_REF by OFFICER_REF
```

A statement can also be recorded without an interview by omitting `from INTERVIEW_REF`. Forms: `written_signed`, `written_unsigned`, `officer_recorded`, `dictated`, `recorded_media`.

Record the witness's adoption/signature outcome:
```text
case witness statement status STATEMENT_REF set adopted because "Witness reviewed and confirmed the account." by OFFICER_REF
```
Other outcomes: `not_adopted`, `refused_to_sign`. The statement text is never changed by this status action.

Conclude or interrupt an interview:
```text
case interview status INTERVIEW_REF set concluded because "Reason" by INTERVIEWER_REF
```
Use `interrupted` where applicable.

Retrieve records:
```text
case interviews CASE_REF
case interview transcript INTERVIEW_REF
case witness statements CASE_REF
```

## Recorded data and behaviour

- Stable references: `KNG-INT-#######`, `KNG-ITR-#######`, `KNG-WS-#######`.
- Each interview links one existing person, one existing case and one responsible interviewer.
- Each question-and-answer pair is separately numbered and timestamped in fictional game time.
- The recorded interviewer owns the interview transcript; only that interviewer can add turns or conclude/interrupt it.
- A statement linked to an interview must identify the same witness and case as the interview.
- Statements record their form, complete text, witness, recording officer and optional parent statement for supplementary accounts.
- Adoption, non-adoption and refusal to sign are separate events; they never rewrite the original account.
- Interviewers/recording officers must be active or seconded and assigned to the case (or be its recorded case lead).
- Closed cases cannot receive new interviews or statements. Concluded/interrupted interviews cannot receive more question-and-answer turns.
- All write commands use the shared idempotency ledger and actor attribution. Interview records use current fictional time and do not advance it.
- Tables are in the private `game` schema, RLS-enabled and service-role-only.

## Verification

`database/tests/kingswell_case_interviews_witness_statements.sql` exercises the real parser/executor in a rollback-only transaction.
