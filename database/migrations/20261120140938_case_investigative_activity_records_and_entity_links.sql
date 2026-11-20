create table game.case_activity_records(
 id uuid primary key default gen_random_uuid(), activity_ref text not null unique, case_id uuid not null references game.cases(id),
 activity_type text not null check(activity_type in ('surveillance','search','interview_activity','suspect_contact','arrest','warrant_execution','forensic_examination','scene_visit','document_review','digital_enquiry','phone_enquiry','briefing','liaison','intelligence_development','other')),
 method text not null check(char_length(btrim(method)) between 2 and 120), description text not null check(char_length(btrim(description)) between 3 and 8000), result text not null check(char_length(btrim(result)) between 2 and 8000),
 outcome text not null check(outcome in ('information_obtained','no_information','corroborated','contradicted','inconclusive','unable_to_complete','arrest_made','evidence_recovered','referral_required','other')),
 conducted_by_personnel_id uuid not null references game.police_personnel(id), recorded_by_personnel_id uuid not null references game.police_personnel(id),
 occurred_at_game_time timestamptz not null, source_command_id uuid not null references game.game_commands(id), created_at timestamptz not null default now());
create table game.case_activity_links(
 id uuid primary key default gen_random_uuid(), activity_id uuid not null references game.case_activity_records(id), case_id uuid not null references game.cases(id),
 entity_type text not null check(entity_type in ('person','lead','enquiry','task','evidence','interview','witness_statement','incident')), entity_ref text not null,
 reason text not null check(char_length(btrim(reason)) between 2 and 1000), linked_by_personnel_id uuid not null references game.police_personnel(id),
 linked_at_game_time timestamptz not null, source_command_id uuid not null references game.game_commands(id), created_at timestamptz not null default now(), unique(activity_id,entity_type,entity_ref));
create index case_activity_records_case_time_idx on game.case_activity_records(case_id,occurred_at_game_time desc);
create index case_activity_links_activity_idx on game.case_activity_links(activity_id);
create index case_activity_links_case_entity_idx on game.case_activity_links(case_id,entity_type,entity_ref);
alter table game.case_activity_records enable row level security; alter table game.case_activity_links enable row level security;
revoke all on game.case_activity_records,game.case_activity_links from public,anon,authenticated; grant select,insert on game.case_activity_records,game.case_activity_links to service_role;
create or replace function game.prevent_case_activity_mutation() returns trigger language plpgsql set search_path=pg_catalog,game as $$ begin raise exception 'Case activity records and links are append-only';end $$;
create trigger case_activity_records_immutable before update or delete on game.case_activity_records for each row execute function game.prevent_case_activity_mutation();
create trigger case_activity_links_immutable before update or delete on game.case_activity_links for each row execute function game.prevent_case_activity_mutation();