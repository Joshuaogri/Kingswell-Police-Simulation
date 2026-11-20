# Case task completion submissions and supervisor review

## Player commands

Submit an in-progress task for review:
```text
case task submit TASK_REF by PERSONNEL_REF because "Work completed, actions taken and outcome"
```

Attach existing case evidence to the submission:
```text
case task submission evidence SUBMISSION_REF EVIDENCE_REF by PERSONNEL_REF because "How this evidence supports the completed work"
```

A linked evidence item must already belong to the same case. The evidence record, custody history and forensic findings are not changed.

Supervisor accepts or returns a submission:
```text
case task submission review SUBMISSION_REF set accepted by SUPERVISOR_REF because "Review findings and acceptance reason"
case task submission review SUBMISSION_REF set returned by SUPERVISOR_REF because "Specific work still required"
```

Retrieve submissions, evidence links and review history:
```text
case task submissions TASK_REF by PERSONNEL_REF
```

## Workflow
1. The assigned officer or an officer actively assigned to the case submits a completion note against an in-progress task.
2. Existing evidence from the same case may be linked before review.
3. A supervisor with an active supervisor assignment reviews the submission exactly once.
4. Acceptance records an immutable review and completes the task through the existing task lifecycle.
5. Return records the reason; the task remains open for further work. The officer can submit a new completion record after addressing the feedback.

## Integrity and access
- Task completion is blocked unless a submitted completion record has an accepted supervisor review.
- The completion update itself must be made by an active case supervisor.
- Submission, evidence-link and review records are append-only.
- Each submission has at most one final review; a returned submission is never overwritten.
- Evidence links reference existing same-case evidence and do not copy or alter evidence.
- Commands use the game command idempotency ledger and explicit fictional time; they do not advance time.
- Active/seconded personnel and case assignment checks are enforced.
- Tables remain in private schema `game`, with RLS enabled and service-role-only access.

## Current verification
- Parser tests passed for submit, evidence link, review and submission retrieval.
- Runtime help confirms all four commands.
- RLS, service-role grants, immutable review guard, completion approval trigger and unique final-review index verified.
- No personnel-backed end-to-end fixture test has yet been run because the live world has no seeded police personnel and its fictional clock is not initialized.
