# Independent prosecutor review and formal charges

Appoint a distinct prosecutor profile: `prosecutor appoint PERSON_REF role prosecutor by PERSONNEL_REF`. Roles: `prosecutor`, `senior_prosecutor`, `chief_prosecutor`.

Review a pending referral: `prosecutor review REFERRAL_REF set accepted|returned|declined by PROSECUTOR_REF because "Reason"`. Only an active prosecutor can decide. Each referral has one independent review with prosecutor identity, decision, reason, game time and source command.

File a charge only after acceptance: `prosecution charge file REFERRAL_REF by PROSECUTOR_REF count 1 offence OFFENCE-CODE title "Charge title" particulars "Alleged particulars"`. Retrieve charges with `prosecution charges REFERRAL_REF by PROSECUTOR_REF`.

Each count has a stable reference and links to the person, case, referral and prosecutor. Duplicate count numbers are rejected. A filed charge is an allegation for court determination, not a finding of guilt.

The five new tables are private, RLS-enabled and service-role-only. Review and charge event histories are append-only. Commands use idempotency and current fictional time without advancing it. Regression: `database/tests/kingswell_prosecutor_charges.sql`.
