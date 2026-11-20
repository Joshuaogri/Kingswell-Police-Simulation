# Charge verdicts and sentencing

All participants and proceedings are fictional NPC game content. The player remains the only player. The system uses the explicit fictional clock and never advances it automatically.

## Verdict per charge

`court verdict record CHARGE_REF at TRIAL_HEARING_REF by JUDGE_REF as guilty|not_guilty because "Reasons"`

Requirements:
- The charge must still be filed.
- The trial hearing must be scheduled and due.
- The hearing must belong to the same active court case as the charge.
- The named active judge must be assigned to that court case.
- A plea must already be recorded for the accused on that charge.
- All evidence tenders for that trial hearing must have a ruling.
- Only one first-instance verdict can be recorded for each charge. A future appeal process will create a separate appellate outcome rather than overwrite this record.

Each verdict contains its own written reasons and links to the exact charge, trial hearing and judge. One charge's verdict does not determine another charge's outcome.

## Sentence per guilty charge

`court sentence impose CHARGE_REF at SENTENCING_HEARING_REF by JUDGE_REF type TYPE duration_days N fine_amount AMOUNT details "Sentence details"`

Types: `custodial`, `fine`, `community_service`, `probation`, `conditional_discharge`, `absolute_discharge`, `other`.

Requirements:
- The charge must have a recorded guilty verdict.
- The case must have a concluded trial hearing.
- The sentencing hearing must be scheduled and due.
- The named active judge must be assigned to the case.
- Custodial sentences require a positive `duration_days`; fine sentences require a positive `fine_amount`. Use zero for the inapplicable field.
- A sentence can be imposed only once for each guilty verdict.

The current amount is a fictional game-currency value. Custodial duration is measured in fictional game days. This stage records the sentence; it does not yet manage prison placement, sentence time served, release, probation supervision or correctional activities.

## Retrieval

`select game.get_trial_record('TRIAL_OR_SENTENCING_HEARING_REF');`

The trial record now includes case-wide charge verdicts and sentences alongside pleas, proceedings and evidence tenders.

## Current scope

Implemented: per-charge first-instance verdicts, written reasons, sentencing hearings, custodial/fine/community service/probation/discharge/other sentence types, append-only outcome history and case-linked retrieval.

Next: corrections and sentence administration, appeals, appellate hearings and appeal outcomes. Original trial verdicts and sentences remain immutable historical records.
