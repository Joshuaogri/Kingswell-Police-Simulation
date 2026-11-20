create index if not exists patrol_activity_personnel_time_idx on game.patrol_activity_sessions(personnel_id,started_at_game_time desc);
create index if not exists patrol_activity_schedule_idx on game.patrol_activity_sessions(schedule_id);
create index if not exists patrol_activity_location_idx on game.patrol_activity_sessions(location_access_point_id);
create index if not exists patrol_activity_events_command_idx on game.patrol_activity_events(command_id);

create or replace function game.guard_patrol_activity_session_history()
returns trigger language plpgsql set search_path to ''
as $f$
begin
 if tg_op='DELETE' then raise exception 'Patrol activity session records cannot be deleted'; end if;
 if old.status<>'active' then raise exception 'Completed patrol activity sessions are immutable'; end if;
 if new.session_ref is distinct from old.session_ref
  or new.unit_id is distinct from old.unit_id
  or new.personnel_id is distinct from old.personnel_id
  or new.beat_id is distinct from old.beat_id
  or new.schedule_id is distinct from old.schedule_id
  or new.activity_type is distinct from old.activity_type
  or new.location_access_point_id is distinct from old.location_access_point_id
  or new.started_at_game_time is distinct from old.started_at_game_time
  or new.reason is distinct from old.reason
  or new.details is distinct from old.details
  or new.created_at is distinct from old.created_at
  or new.status<>'completed'
  or new.ended_at_game_time is null
  or new.end_reason is null then
  raise exception 'Patrol activity session history is immutable except for one completion transition';
 end if;
 return new;
end;$f$;
create trigger patrol_activity_sessions_immutable
before update or delete on game.patrol_activity_sessions
for each row execute function game.guard_patrol_activity_session_history();
