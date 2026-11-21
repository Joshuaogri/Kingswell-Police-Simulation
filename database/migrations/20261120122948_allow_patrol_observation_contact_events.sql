alter table game.patrol_activity_events drop constraint patrol_activity_events_event_type_check;
alter table game.patrol_activity_events add constraint patrol_activity_events_event_type_check
 check (event_type in ('activity_started','activity_completed','observation_recorded','contact_recorded'));