# Kingswell Project Decisions and Working Rules

**Status:** Living project record. Confirmed constraints are separated from open design matters.

## Fixed project rules
1. Kingswell is a fictional game, not a real-world police operation.
2. The country, city, laws, institutions, people, procedures and events are fictional.
3. Kingswell is the political and economic capital and the primary playable city.
4. The initial permanent resident population is 100,000. It can grow or decline realistically; there is no fixed ceiling.
5. The wider fictional country supports national institutions, jurisdiction and cross-jurisdiction activity. Other cities do not need full simulation by default.
6. Build the complete master blueprint progressively before deep implementation.
7. Keep the Master Blueprint, Implementation Register and Technical Architecture as separate project records.
8. The master blueprint remains a draft until explicitly approved as final.
9. Use plain English and practical explanations. Avoid unnecessary jargon, needless delays and routine approval loops.
10. Keep the scope coherent and record material design changes.
11. **GitHub branch rule: main is the only permitted working branch. Never create, switch to or commit to another branch.**

## Confirmed police model
One national police service with a central headquarters and regional/city commands.

## Open design matters
- Final city footprint, district count, district names and boundaries.
- National administrative divisions and regional boundaries.
- Detailed police headquarters, regional command and Kingswell city command structure.
- Population simulation processing model; persistent records for everyone with variable processing is the current recommended direction, not yet a final approved choice.
- Exact game-time advancement controls.
- Detailed software framework, database design, authentication and deployment arrangements.

## Working method
Use sensible defaults for routine design and implementation choices. Record proposals as proposals. Continue progressing without pausing for minor approvals. Stop only for a genuinely consequential choice that cannot be inferred safely. Never claim that an unverified action succeeded.