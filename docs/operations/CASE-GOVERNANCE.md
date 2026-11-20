# Supervisory case review and status governance

This system provides supervisor-led review records and controlled case status changes. Reviews and status events are append-only; original investigative source records are not rewritten.

## Commands

Record a supervisory review:
```text
case supervisory review CASE_REF outcome OUTCOME because "REASON" by SUPERVISOR_REF
```

Allowed outcomes:
- `continue_investigation`
- `further_enquiries`
- `recommend_submission`
- `recommend_suspension`
- `recommend_closure`
- `recommend_reopening`

Change case status:
```text
case status CASE_REF set STATUS because "REASON" by SUPERVISOR_REF
```

Supported statuses: `open`, `under_investigation`, `suspended`, `submitted`, `closed`, `reopened`.

Allowed transitions:
- open -> under_investigation, suspended, submitted, closed
- under_investigation -> suspended, submitted, closed
- suspended -> reopened, under_investigation, closed
- submitted -> reopened, closed
- closed -> reopened
- reopened -> under_investigation, suspended, submitted, closed

Retrieve review and status history:
```text
case governance CASE_REF by SUPERVISOR_REF
```

## Authority and record handling

The named officer must be active or seconded, and must hold an active `supervisor` assignment on that case. If the runtime supplies an actor personnel ID, it must match the named officer. Every write command uses the command idempotency ledger and stores its source command ID.

Supervisory recommendations do not themselves change case status. A separate status command records the actual decision and reason. Closing a case sets its close time to the current fictional time; reopening clears that active close timestamp while retaining the historical closure event. No command advances fictional time.

Reviews and status history are immutable. The commands do not alter statements, interviews, evidence, custody, forensic findings, leads or enquiries.

## Regression

`database/tests/kingswell_case_governance.sql` runs a rollback-only end-to-end test through the parser and executor, including supervisory access, review idempotency, valid and invalid status transitions, closure/reopening, history retrieval, help registration and unchanged fictional time.
