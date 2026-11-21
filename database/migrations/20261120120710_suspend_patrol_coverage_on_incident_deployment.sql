alter table game.patrol_schedules drop constraint patrol_schedules_status_check;
alter table game.patrol_schedules add constraint patrol_schedules_status_check check(status in ('scheduled','active','suspended','completed','cancelled'));
create or replace function game.interrupt_patrol_schedule_on_unit_state()
returns trigger language plpgsql set search_path to ''
as $function$
declare c timestamptz; s record;
begin
 if new.operational_state is distinct from old.operational_state
    and new.operational_state in ('responding','on_scene','returning','out_of_service') then
  select current_game_time into c from game.simulation_state where id=1;
  if c is not null then
   for s in select id,beat_id from game.patrol_schedules where unit_id=new.id and status='active' for update loop
    update game.patrol_schedules set status='suspended' where id=s.id;
    insert into game.patrol_coverage_events(unit_id,beat_id,schedule_id,event_type,event_time,reason,details)
    values(new.id,s.beat_id,s.id,'coverage_interrupted',c,
      'Patrol suspended by unit operational-state transition',
      jsonb_build_object('previous_state',old.operational_state,'new_state',new.operational_state));
   end loop;
  end if;
 end if;
 return new;
end;$function$;
drop trigger if exists patrol_schedule_unit_state_interruption on game.police_units;
create trigger patrol_schedule_unit_state_interruption
after update of operational_state on game.police_units
for each row execute function game.interrupt_patrol_schedule_on_unit_state();
revoke all on function game.interrupt_patrol_schedule_on_unit_state() from public,anon,authenticated;
grant execute on function game.interrupt_patrol_schedule_on_unit_state() to service_role;
