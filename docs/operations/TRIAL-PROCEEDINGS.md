# NPC trial proceedings

All trial participants are fictional NPCs. The player remains the only player. Trial actions use the explicit fictional game clock and do not advance it.

## Pleas by charge

`court plea record CHARGE_REF by PERSON_REF as guilty|not_guilty|no_plea`

Optional note:

`court plea record CHARGE_REF by PERSON_REF as not_guilty notes "Accused denies the allegation"`

The person must be the accused named on the filed charge, and the case must be registered with a court. Each plea is a separate immutable record, so later changes do not erase the earlier plea.

## Proceedings and examination

`court trial record HEARING_REF by JUDGE_REF type EVENT_TYPE speaker PERSON_REF details "Proceeding details"`

Supported event types: `prosecution_opening`, `defence_opening`, `witness_examination`, `witness_cross_examination`, `re_examination`, `accused_testimony`, `submission`, `objection`, `judicial_ruling`, `closing_submission`, `jury_direction`, `verdict_announcement`, `other`.

The hearing must be a scheduled trial hearing and the named official must be its assigned judge. The speaker is linked to an existing person record. The details field records the event as reported; it does not create an automatic finding or reveal hidden case solutions.

## Evidence tender and ruling

`court trial tender HEARING_REF evidence EVIDENCE_REF by ACTOR_REF side prosecution|defence purpose "Why the evidence is tendered"`

The prosecution actor must be an active prosecutor connected to the case; the defence actor must be assigned active counsel. Evidence must already exist and belong to the same case.

`court trial rule TENDER_REF by JUDGE_REF ruling admitted|excluded|limited because "Reason"`

Only the assigned active judge can rule on a pending tender. The evidence's original record and chain of custody are unchanged. A ruling is a trial admissibility decision, not a finding that the evidence proves guilt.

## Read the current trial record

`select game.get_trial_record('HEARING_REF');`

The record groups pleas for the case, proceedings for the hearing, and evidence tenders/rulings for the hearing. It is a service-role database helper pending a player-facing retrieval command.

## Current scope

This foundation records pleas, trial chronology, examination stages, submissions, objections and evidence admissibility. It does not yet record verdicts as authoritative per-count findings, sentencing, jury deliberations or appeals. Those are subsequent systems.
