## NPC court registry, docket and hearing management — 2026-11-20

**Implemented, deployed and rollback-only regression-tested.**

Adds seven RLS-enabled private tables:
- `game.courts`
- `game.court_official_profiles`
- `game.court_cases`
- `game.court_hearings`
- `game.court_hearing_attendance`
- `game.court_orders`
- `game.court_hearing_events`

Features: court creation, NPC judicial/clerk appointments, case registration following a filed charge, judge assignment, hearing scheduling, attendance, adjournment, conclusion, judicial orders, case docket retrieval and case dossier integration. Court orders and event history are append-only. Case docket access is restricted to linked case actors. Commands use the shared idempotency ledger and do not advance fictional time.

Commands: `court create`, `court official appoint`, `court case register`, `court case assign judge`, `court hearing schedule`, `court hearing attendance`, `court hearing adjourn`, `court hearing conclude`, `court order issue`, `court docket`, `court hearing`.

**PASS:** `database/tests/kingswell_court_registry_and_hearings.sql` verifies full NPC-to-NPC court workflow, access denial, court event history, docket, case dossier, help and clock preservation. All fixtures roll back.

Operations guide: `docs/operations/COURT-REGISTRY-HEARINGS.md`.
