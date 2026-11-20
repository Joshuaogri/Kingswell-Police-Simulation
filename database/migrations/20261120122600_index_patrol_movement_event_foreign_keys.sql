create index if not exists patrol_movement_route_idx on game.patrol_movement_events(route_id);
create index if not exists patrol_movement_schedule_idx on game.patrol_movement_events(schedule_id);
create index if not exists patrol_movement_from_junction_idx on game.patrol_movement_events(from_junction_id);
create index if not exists patrol_movement_to_junction_idx on game.patrol_movement_events(to_junction_id);