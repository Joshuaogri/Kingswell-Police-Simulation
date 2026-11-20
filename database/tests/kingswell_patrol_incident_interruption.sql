-- Rollback-only test: a deployment-driven unit state transition interrupts patrol coverage.
begin;
do $test$
declare c timestamptz:='2026-11-20 14:00:00+00'; f uuid; b game.patrol_beats%rowtype; u uuid; sid uuid; ref text; sched text; status_value text; ev integer;
begin
 update game.simulation_state set current_game_time=c,time_paused=true where id=1;
 select id into f from game.police_facilities where status='active' order by facility_ref limit 1;
 select * into b from game.patrol_beats where status='active' order by beat_ref limit 1;
 ref:='KNG-INTERRUPT-'||substr(gen_random_uuid()::text,1,8); sched:='KNG-INTERRUPT-SCH-'||substr(gen_random_uuid()::text,1,8);
 insert into game.police_units(unit_ref,unit_name,unit_type,status,base_facility_id,assigned_beat_id,operational_state)
 values(ref,'Patrol interruption test','patrol','active',f,b.id,'on_patrol') returning id into u;
 insert into game.patrol_schedules(schedule_ref,unit_id,beat_id,starts_at,ends_at,status)
 values(sched,u,b.id,c-interval '30 minutes',c+interval '2 hours','active') returning id into sid;
 update game.police_units set operational_state='responding',operational_state_updated_at=c where id=u;
 select status into status_value from game.patrol_schedules where id=sid;
 if status_value<>'suspended' then raise exception 'Patrol schedule was not suspended: %',status_value; end if;
 select count(*) into ev from game.patrol_coverage_events where unit_id=u and event_type='coverage_interrupted';
 if ev<>1 then raise exception 'Expected one coverage interruption event, got %',ev; end if;
 if (select current_game_time from game.simulation_state where id=1) is distinct from c then raise exception 'Fictional clock changed'; end if;
end;$test$;
rollback;