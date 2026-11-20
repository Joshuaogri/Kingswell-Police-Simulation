-- Rollback-only patrol beat scheduling and coverage regression.
begin;
do $test$
declare
 c timestamptz:='2026-11-20 14:00:00+00'; f uuid; b game.patrol_beats%rowtype; u uuid; r uuid; ref text; sched text; j jsonb; st text; ev integer;
begin
 update game.simulation_state set current_game_time=c,time_paused=true where id=1;
 select id into f from game.police_facilities where status='active' order by facility_ref limit 1;
 select * into b from game.patrol_beats where status='active' order by beat_ref limit 1;
 if f is null or b.id is null then raise exception 'Required geography fixture missing'; end if;
 ref:='KNG-TEST-PATROL-'||substr(gen_random_uuid()::text,1,8); sched:='KNG-TEST-SCHEDULE-'||substr(gen_random_uuid()::text,1,8);
 insert into game.police_units(unit_ref,unit_name,unit_type,status,base_facility_id,assigned_beat_id) values(ref,'Patrol lifecycle test','patrol','active',f,b.id) returning id into u;
 insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status) values('KNG-TEST-ROSTER-'||substr(gen_random_uuid()::text,1,8),u,'Test shift',c-interval '1 hour',c+interval '7 hours','active') returning id into r;
 j:=game.schedule_unit_patrol(sched,ref,b.beat_ref,c-interval '30 minutes',c+interval '2 hours',(select roster_ref from game.duty_rosters where id=r));
 j:=game.start_unit_patrol(ref,'Begin scheduled beat patrol');
 select operational_state into st from game.police_units where id=u;
 if st<>'on_patrol' then raise exception 'Start patrol state mismatch: %',st; end if;
 j:=game.end_unit_patrol(ref,'End scheduled patrol');
 select operational_state into st from game.police_units where id=u;
 if st<>'at_station' then raise exception 'End patrol state mismatch: %',st; end if;
 select count(*) into ev from game.patrol_coverage_events where unit_id=u;
 if ev<>2 then raise exception 'Expected start and end coverage events, got %',ev; end if;
 if (select current_game_time from game.simulation_state where id=1) is distinct from c then raise exception 'Fictional clock changed'; end if;
end;$test$;
rollback;
