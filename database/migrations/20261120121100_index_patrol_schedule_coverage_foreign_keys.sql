create index if not exists patrol_schedules_beat_fk_idx on game.patrol_schedules(beat_id);
create index if not exists patrol_schedules_roster_fk_idx on game.patrol_schedules(roster_id) where roster_id is not null;
create index if not exists patrol_coverage_events_unit_fk_idx on game.patrol_coverage_events(unit_id);
create index if not exists patrol_coverage_events_schedule_fk_idx on game.patrol_coverage_events(schedule_id) where schedule_id is not null;