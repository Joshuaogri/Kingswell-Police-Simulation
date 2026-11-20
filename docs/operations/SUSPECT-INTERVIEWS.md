# Suspect interviews and response assessments

Suspect interviews use the existing case interview record and chronological question-and-answer transcript. A separate immutable suspect classification records the interview's investigative capacity and the reason it was conducted as a suspect interview. This is an investigative designation, not a finding of guilt.

## Commands

First open the ordinary case interview and record its Q&A turns:

```text
case interview record CASE_REF with PERSON_REF by OFFICER_REF method face_to_face purpose "Purpose" location "Interview Room 1"
case interview turn INTERVIEW_REF by OFFICER_REF question "Question asked" answer "Answer given"
```

Classify the open interview as a suspect interview:

```text
case suspect interview classify INTERVIEW_REF because "Reason for treating the person as a suspect in this case" by OFFICER_REF
```

Assess a recorded answer without changing the transcript:

```text
case suspect interview assess INTERVIEW_REF turn TURN_REF as admission because "Reasoned assessment"
```

Supported assessment labels:
- `admission`
- `denial`
- `no_comment`
- `qualified_response`
- `correction`
- `other`

Retrieve the transcript together with its response assessments:

```text
case suspect interview review INTERVIEW_REF
```

The three command types are registered in `help`.

## Behaviour and safeguards

- Uses existing case, person, personnel, interview and interview-turn records; it does not create duplicate person or case registries.
- Suspect classification adds the existing person to the case's `case_persons` relationship as `suspect` when not already present.
- Classification is allowed only while the case and interview remain open and only by the recorded interviewer.
- Response assessments must reference a turn from that exact suspect interview and be recorded by its interviewer.
- Multiple assessments can be appended to a turn as the interpretation develops; none rewrites the question, answer or previous assessment.
- The categories describe the interviewee's response as recorded; they are not a judicial finding or proof that the response is true.
- Writes use the shared command idempotency ledger and actor attribution. All records use current fictional time and do not advance it.
- Both new tables have RLS enabled, private-schema access and service-role-only grants. Their records reject update and delete.
- A suspect interview cannot be newly classified after its interview has concluded or been interrupted, or after its case has closed.

## Verification

`database/tests/kingswell_suspect_interviews.sql` runs a rollback-only end-to-end regression through the actual parser and executor. It checks suspect classification, idempotency, question-and-answer linkage, response assessment, retrieval, append-only protection, help registration and unchanged fictional time.
