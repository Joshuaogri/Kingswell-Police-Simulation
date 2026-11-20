# Prosecution referral and prosecutor decision workflow

This first prosecution-stage workflow connects an existing Kingswell arrest to a formal fictional referral record. It does not treat arrest as guilt or automatically create a charge, conviction, or court result.

## Submit a referral

```text
prosecution refer CASE_REF arrest ARREST_REF by PERSONNEL_REF summary "Referral summary" charges "Proposed charges" evidence "Evidence schedule and disclosure status"
```

The arrest must belong to the specified case, and the arrested person must already be linked to that case as a suspect or person of interest. The submitting officer must be the case lead or an active case assignee. Summary, proposed charges and evidence summary are required. One referral is permitted per arrest.

## Record a prosecutor decision

```text
prosecution decision REFERRAL_REF set accepted by PERSONNEL_REF because "Reason"
prosecution decision REFERRAL_REF set returned by PERSONNEL_REF because "Further enquiries required"
prosecution decision REFERRAL_REF set declined by PERSONNEL_REF because "Reason"
```

A referral may receive one final decision from the available values: `accepted`, `returned`, or `declined`. The decision is recorded as an attributed event; the original referral remains intact. This is a fictional workflow decision, not a finding of guilt and not a court judgment.

## Retrieve referrals

```text
prosecution referrals CASE_REF by PERSONNEL_REF
```

Retrieval includes the arrest and person references, referral summary, proposed charges, evidence summary, current status and chronological decision history. The requesting officer must be the case lead or an active case assignee.

## Simulation and persistence

- Actions use the current fictional game time and do not advance it.
- Commands use the shared idempotency ledger.
- Referral event history is append-only.
- Tables are in the private `game` schema with RLS enabled and service-role-only access.
- The first implementation does not yet create disclosure packages, court listings, bail decisions or judicial outcomes; those are subsequent stages.

## Verification

The rollback-only regression creates temporary personnel, case, suspect and arrest records, submits a referral, records a returned decision, retrieves the event history, checks help registration and confirms that fictional time is unchanged. The transaction rolls back all fixtures.
