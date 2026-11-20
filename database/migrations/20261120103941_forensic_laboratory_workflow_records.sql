-- Kingswell forensic laboratory records. Reconstructed from the applied live migration.

create table game.forensic_examinations (
  id uuid default gen_random_uuid() not null,
  examination_ref text not null,
  request_id uuid not null,
  submission_id uuid not null,
  method_id uuid not null,
  examiner_personnel_id uuid not null,
  assigned_by_personnel_id uuid not null,
  method_version_snapshot text not null,
  examination_question text not null,
  scope text not null,
  propositions text not null,
  status text not null,
  assigned_at timestamptz not null,
  started_at timestamptz,
  completed_at timestamptz,
  source_command_id uuid,
  created_at timestamptz default now() not null,
  constraint forensic_examinations_assigned_by_personnel_id_fkey FOREIGN KEY (assigned_by_personnel_id) REFERENCES game.police_personnel(id),
  constraint forensic_examinations_examination_ref_key UNIQUE (examination_ref),
  constraint forensic_examinations_examiner_personnel_id_fkey FOREIGN KEY (examiner_personnel_id) REFERENCES game.police_personnel(id),
  constraint forensic_examinations_method_id_fkey FOREIGN KEY (method_id) REFERENCES game.forensic_methods(id),
  constraint forensic_examinations_pkey PRIMARY KEY (id),
  constraint forensic_examinations_request_id_fkey FOREIGN KEY (request_id) REFERENCES game.forensic_requests(id),
  constraint forensic_examinations_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id),
  constraint forensic_examinations_status_check CHECK ((status = ANY (ARRAY['assigned'::text, 'in_progress'::text, 'completed'::text, 'cancelled'::text]))),
  constraint forensic_examinations_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES game.forensic_lab_submissions(id)
);

create table game.forensic_findings (
  id uuid default gen_random_uuid() not null,
  finding_ref text not null,
  examination_id uuid not null,
  version_number integer not null,
  recorded_by_personnel_id uuid not null,
  observations text not null,
  interpretation text not null,
  propositions text not null,
  limitations text not null,
  outcome text not null,
  recorded_at timestamptz not null,
  source_command_id uuid,
  created_at timestamptz default now() not null,
  constraint forensic_findings_examination_id_fkey FOREIGN KEY (examination_id) REFERENCES game.forensic_examinations(id),
  constraint forensic_findings_examination_id_version_number_key UNIQUE (examination_id, version_number),
  constraint forensic_findings_finding_ref_key UNIQUE (finding_ref),
  constraint forensic_findings_outcome_check CHECK ((outcome = ANY (ARRAY['supports'::text, 'contradicts'::text, 'inconclusive'::text, 'no_result'::text, 'neutral'::text]))),
  constraint forensic_findings_pkey PRIMARY KEY (id),
  constraint forensic_findings_recorded_by_personnel_id_fkey FOREIGN KEY (recorded_by_personnel_id) REFERENCES game.police_personnel(id),
  constraint forensic_findings_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id),
  constraint forensic_findings_version_number_check CHECK ((version_number > 0))
);

create table game.forensic_lab_submissions (
  id uuid default gen_random_uuid() not null,
  submission_ref text not null,
  request_id uuid not null,
  evidence_id uuid not null,
  submitted_by_personnel_id uuid not null,
  received_by_personnel_id uuid not null,
  custody_transfer_id uuid not null,
  received_at timestamptz not null,
  received_condition text not null,
  seal_condition text not null,
  discrepancy text,
  laboratory_location text not null,
  status text not null,
  source_command_id uuid,
  created_at timestamptz default now() not null,
  constraint forensic_lab_submissions_custody_transfer_id_fkey FOREIGN KEY (custody_transfer_id) REFERENCES game.evidence_transfers(id),
  constraint forensic_lab_submissions_evidence_id_fkey FOREIGN KEY (evidence_id) REFERENCES game.evidence_items(id),
  constraint forensic_lab_submissions_pkey PRIMARY KEY (id),
  constraint forensic_lab_submissions_received_by_personnel_id_fkey FOREIGN KEY (received_by_personnel_id) REFERENCES game.police_personnel(id),
  constraint forensic_lab_submissions_request_id_evidence_id_key UNIQUE (request_id, evidence_id),
  constraint forensic_lab_submissions_request_id_fkey FOREIGN KEY (request_id) REFERENCES game.forensic_requests(id),
  constraint forensic_lab_submissions_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id),
  constraint forensic_lab_submissions_status_check CHECK ((status = ANY (ARRAY['received'::text, 'quarantined'::text, 'accepted'::text, 'rejected'::text, 'returned'::text]))),
  constraint forensic_lab_submissions_submission_ref_key UNIQUE (submission_ref),
  constraint forensic_lab_submissions_submitted_by_personnel_id_fkey FOREIGN KEY (submitted_by_personnel_id) REFERENCES game.police_personnel(id)
);

create table game.forensic_methods (
  id uuid default gen_random_uuid() not null,
  method_ref text not null,
  discipline text not null,
  method_name text not null,
  method_version text not null,
  validation_status text not null,
  authorised_scope text not null,
  known_limitations text not null,
  active boolean default true not null,
  registered_by_personnel_id uuid not null,
  registered_at timestamptz not null,
  source_command_id uuid,
  created_at timestamptz default now() not null,
  constraint forensic_methods_method_ref_key UNIQUE (method_ref),
  constraint forensic_methods_pkey PRIMARY KEY (id),
  constraint forensic_methods_registered_by_personnel_id_fkey FOREIGN KEY (registered_by_personnel_id) REFERENCES game.police_personnel(id),
  constraint forensic_methods_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id),
  constraint forensic_methods_validation_status_check CHECK ((validation_status = ANY (ARRAY['validated'::text, 'verification_pending'::text, 'suspended'::text, 'retired'::text])))
);

create table game.forensic_reports (
  id uuid default gen_random_uuid() not null,
  report_ref text not null,
  request_id uuid not null,
  version_number integer not null,
  authored_by_personnel_id uuid not null,
  report_summary text not null,
  report_body text not null,
  status text not null,
  issued_at timestamptz not null,
  source_command_id uuid,
  created_at timestamptz default now() not null,
  constraint forensic_reports_authored_by_personnel_id_fkey FOREIGN KEY (authored_by_personnel_id) REFERENCES game.police_personnel(id),
  constraint forensic_reports_pkey PRIMARY KEY (id),
  constraint forensic_reports_report_ref_key UNIQUE (report_ref),
  constraint forensic_reports_request_id_fkey FOREIGN KEY (request_id) REFERENCES game.forensic_requests(id),
  constraint forensic_reports_request_id_version_number_key UNIQUE (request_id, version_number),
  constraint forensic_reports_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id),
  constraint forensic_reports_status_check CHECK ((status = ANY (ARRAY['issued'::text, 'superseded'::text, 'withdrawn'::text]))),
  constraint forensic_reports_version_number_check CHECK ((version_number > 0))
);

create table game.forensic_request_items (
  id uuid default gen_random_uuid() not null,
  request_id uuid not null,
  evidence_id uuid not null,
  requested_context text default ''::text not null,
  created_at timestamptz default now() not null,
  constraint forensic_request_items_evidence_id_fkey FOREIGN KEY (evidence_id) REFERENCES game.evidence_items(id),
  constraint forensic_request_items_pkey PRIMARY KEY (id),
  constraint forensic_request_items_request_id_evidence_id_key UNIQUE (request_id, evidence_id),
  constraint forensic_request_items_request_id_fkey FOREIGN KEY (request_id) REFERENCES game.forensic_requests(id)
);

create table game.forensic_requests (
  id uuid default gen_random_uuid() not null,
  request_ref text not null,
  case_id uuid not null,
  requested_by_personnel_id uuid not null,
  discipline text not null,
  examination_question text not null,
  scope text not null,
  legal_basis text not null,
  priority smallint not null,
  status text not null,
  triage_decision text,
  triage_notes text,
  triaged_by_personnel_id uuid,
  triaged_at timestamptz,
  submitted_at timestamptz not null,
  source_command_id uuid,
  created_at timestamptz default now() not null,
  constraint forensic_requests_case_id_fkey FOREIGN KEY (case_id) REFERENCES game.cases(id),
  constraint forensic_requests_check CHECK ((((triage_decision IS NULL) AND (triaged_by_personnel_id IS NULL) AND (triaged_at IS NULL)) OR ((triage_decision IS NOT NULL) AND (triaged_by_personnel_id IS NOT NULL) AND (triaged_at IS NOT NULL)))),
  constraint forensic_requests_pkey PRIMARY KEY (id),
  constraint forensic_requests_priority_check CHECK (((priority >= 1) AND (priority <= 5))),
  constraint forensic_requests_request_ref_key UNIQUE (request_ref),
  constraint forensic_requests_requested_by_personnel_id_fkey FOREIGN KEY (requested_by_personnel_id) REFERENCES game.police_personnel(id),
  constraint forensic_requests_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id),
  constraint forensic_requests_status_check CHECK ((status = ANY (ARRAY['submitted'::text, 'accepted'::text, 'deferred'::text, 'declined'::text, 'in_progress'::text, 'reported'::text, 'closed'::text]))),
  constraint forensic_requests_triaged_by_personnel_id_fkey FOREIGN KEY (triaged_by_personnel_id) REFERENCES game.police_personnel(id)
);

create table game.forensic_reviews (
  id uuid default gen_random_uuid() not null,
  review_ref text not null,
  finding_id uuid not null,
  reviewer_personnel_id uuid not null,
  review_type text not null,
  decision text not null,
  review_notes text not null,
  reviewed_at timestamptz not null,
  source_command_id uuid,
  created_at timestamptz default now() not null,
  constraint forensic_reviews_decision_check CHECK ((decision = ANY (ARRAY['approved'::text, 'changes_required'::text, 'disputed'::text]))),
  constraint forensic_reviews_finding_id_fkey FOREIGN KEY (finding_id) REFERENCES game.forensic_findings(id),
  constraint forensic_reviews_pkey PRIMARY KEY (id),
  constraint forensic_reviews_review_ref_key UNIQUE (review_ref),
  constraint forensic_reviews_review_type_check CHECK ((review_type = ANY (ARRAY['technical'::text, 'peer'::text, 'independent'::text]))),
  constraint forensic_reviews_reviewer_personnel_id_fkey FOREIGN KEY (reviewer_personnel_id) REFERENCES game.police_personnel(id),
  constraint forensic_reviews_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id)
);

CREATE INDEX forensic_examinations_request_status_idx ON game.forensic_examinations USING btree (request_id, status);

CREATE INDEX forensic_findings_examination_idx ON game.forensic_findings USING btree (examination_id, version_number DESC);

CREATE INDEX forensic_reports_request_idx ON game.forensic_reports USING btree (request_id, version_number DESC);

CREATE INDEX forensic_request_items_evidence_idx ON game.forensic_request_items USING btree (evidence_id);

CREATE INDEX forensic_requests_case_status_idx ON game.forensic_requests USING btree (case_id, status);

CREATE INDEX forensic_reviews_finding_idx ON game.forensic_reviews USING btree (finding_id, reviewed_at DESC);

CREATE INDEX forensic_submissions_evidence_idx ON game.forensic_lab_submissions USING btree (evidence_id, received_at DESC);
alter table game.forensic_examinations enable row level security;
alter table game.forensic_findings enable row level security;
alter table game.forensic_lab_submissions enable row level security;
alter table game.forensic_methods enable row level security;
alter table game.forensic_reports enable row level security;
alter table game.forensic_request_items enable row level security;
alter table game.forensic_requests enable row level security;
alter table game.forensic_reviews enable row level security;
