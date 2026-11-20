-- Index the remaining supervisory governance foreign keys.
create index case_supervisory_reviews_reviewer_idx on game.case_supervisory_reviews(reviewed_by_personnel_id);
create index case_supervisory_reviews_command_idx on game.case_supervisory_reviews(source_command_id);
create index case_status_events_actor_idx on game.case_status_events(changed_by_personnel_id);
create index case_status_events_command_idx on game.case_status_events(source_command_id);
