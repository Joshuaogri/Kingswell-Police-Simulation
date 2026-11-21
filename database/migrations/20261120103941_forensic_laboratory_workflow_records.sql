
create table game.forensic_methods (
 id uuid primary key default gen_random_uuid(),
 method_ref text not null unique,
 discipline text not null,
 method_name text not null,
 method_version text not null,
 validation_status text not null check (validation_status in ('validated','verification_pending','suspended','retired')),
 authorised_scope text not null,
 known_limitations text not null,
 active boolean not null default true,
 registered_by_personnel_id uuid not null references game.police_personnel(id),
 registered_at timestamptz not null,
 source_command_id uuid references game.game_commands(id),
 created_at timestamptz not null default now()
);
create table game.forensic_requests (
 id uuid primary key default gen_random_uuid(),
 request_ref text not null unique,
 case_id uuid not null references game.cases(id),
 requested_by_personnel_id uuid not null references game.police_personnel(id),
 discipline text not null,
 examination_question text not null,
 scope text not null,
 legal_basis text not null,
 priority smallint not null check(priority between 1 and 5),
 status text not null check(status in ('submitted','accepted','deferred','declined','in_progress','reported','closed')),
 triage_decision text,
 triage_notes text,
 triaged_by_personnel_id uuid references game.police_personnel(id),
 triaged_at timestamptz,
 submitted_at timestamptz not null,
 source_command_id uuid references game.game_commands(id),
 created_at timestamptz not null default now(),
 check ((triage_decision is null and triaged_by_personnel_id is null and triaged_at is null) or (triage_decision is not null and triaged_by_personnel_id is not null and triaged_at is not null))
);
create table game.forensic_request_items (
 id uuid primary key default gen_random_uuid(),
 request_id uuid not null references game.forensic_requests(id),
 evidence_id uuid not null references game.evidence_items(id),
 requested_context text not null default '',
 created_at timestamptz not null default now(),
 unique(request_id,evidence_id)
);
create table game.forensic_lab_submissions (
 id uuid primary key default gen_random_uuid(),
 submission_ref text not null unique,
 request_id uuid not null references game.forensic_requests(id),
 evidence_id uuid not null references game.evidence_items(id),
 submitted_by_personnel_id uuid not null references game.police_personnel(id),
 received_by_personnel_id uuid not null references game.police_personnel(id),
 custody_transfer_id uuid not null references game.evidence_transfers(id),
 received_at timestamptz not null,
 received_condition text not null,
 seal_condition text not null,
 discrepancy text,
 laboratory_location text not null,
 status text not null check(status in ('received','quarantined','accepted','rejected','returned')),
 source_command_id uuid references game.game_commands(id),
 created_at timestamptz not null default now(),
 unique(request_id,evidence_id)
);
create table game.forensic_examinations (
 id uuid primary key default gen_random_uuid(),
 examination_ref text not null unique,
 request_id uuid not null references game.forensic_requests(id),
 submission_id uuid not null references game.forensic_lab_submissions(id),
 method_id uuid not null references game.forensic_methods(id),
 examiner_personnel_id uuid not null references game.police_personnel(id),
 assigned_by_personnel_id uuid not null references game.police_personnel(id),
 method_version_snapshot text not null,
 examination_question text not null,
 scope text not null,
 propositions text not null,
 status text not null check(status in ('assigned','in_progress','completed','cancelled')),
 assigned_at timestamptz not null,
 started_at timestamptz,
 completed_at timestamptz,
 source_command_id uuid references game.game_commands(id),
 created_at timestamptz not null default now()
);
create table game.forensic_findings (
 id uuid primary key default gen_random_uuid(),
 finding_ref text not null unique,
 examination_id uuid not null references game.forensic_examinations(id),
 version_number integer not null check(version_number>0),
 recorded_by_personnel_id uuid not null references game.police_personnel(id),
 observations text not null,
 interpretation text not null,
 propositions text not null,
 limitations text not null,
 outcome text not null check(outcome in ('supports','contradicts','inconclusive','no_result','neutral')),
 recorded_at timestamptz not null,
 source_command_id uuid references game.game_commands(id),
 created_at timestamptz not null default now(),
 unique(examination_id,version_number)
);
create table game.forensic_reviews (
 id uuid primary key default gen_random_uuid(),
 review_ref text not null unique,
 finding_id uuid not null references game.forensic_findings(id),
 reviewer_personnel_id uuid not null references game.police_personnel(id),
 review_type text not null check(review_type in ('technical','peer','independent')),
 decision text not null check(decision in ('approved','changes_required','disputed')),
 review_notes text not null,
 reviewed_at timestamptz not null,
 source_command_id uuid references game.game_commands(id),
 created_at timestamptz not null default now()
);
create table game.forensic_reports (
 id uuid primary key default gen_random_uuid(),
 report_ref text not null unique,
 request_id uuid not null references game.forensic_requests(id),
 version_number integer not null check(version_number>0),
 authored_by_personnel_id uuid not null references game.police_personnel(id),
 report_summary text not null,
 report_body text not null,
 status text not null check(status in ('issued','superseded','withdrawn')),
 issued_at timestamptz not null,
 source_command_id uuid references game.game_commands(id),
 created_at timestamptz not null default now(),
 unique(request_id,version_number)
);
create index forensic_requests_case_status_idx on game.forensic_requests(case_id,status);
create index forensic_request_items_evidence_idx on game.forensic_request_items(evidence_id);
create index forensic_submissions_evidence_idx on game.forensic_lab_submissions(evidence_id,received_at desc);
create index forensic_examinations_request_status_idx on game.forensic_examinations(request_id,status);
create index forensic_findings_examination_idx on game.forensic_findings(examination_id,version_number desc);
create index forensic_reviews_finding_idx on game.forensic_reviews(finding_id,reviewed_at desc);
create index forensic_reports_request_idx on game.forensic_reports(request_id,version_number desc);
alter table game.forensic_methods enable row level security;
alter table game.forensic_requests enable row level security;
alter table game.forensic_request_items enable row level security;
alter table game.forensic_lab_submissions enable row level security;
alter table game.forensic_examinations enable row level security;
alter table game.forensic_findings enable row level security;
alter table game.forensic_reviews enable row level security;
alter table game.forensic_reports enable row level security;
