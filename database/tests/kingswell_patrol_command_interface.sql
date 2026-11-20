-- End-to-end parser, command-ledger and beat-coverage test; all fixtures roll back.
begin;
do $test$
declare c timestamptz:='2026-11-20 14:00:00+00'; f uuid; b game.patrol_beats%rowtype; u uuid; r uuid; ref text; sched text; j jsonb; st text; cov jsonb;
begin
 update game.simulation_state set current_game_time=c,time_paused=true where id=1;
 select id into f from game.police_facilities where status='active' order by facility_ref limit 1;
 select * into b from game.patrol_beats where status='active' order by beat_ref limit 1;
 ref:='KNG-CMD-PATROL-'||substr(gen_random_uuid()::text,1,8); sched:='KNG-CMD-SCHEDULE-'||substr(gen_random_uuid()::text,1,8);
 insert into game.police_units(unit_ref,unit_name,unit_type,status,base_facility_id,assigned_beat_id) values(ref,'Patrol command test','patrol','active',f,b.id) returning id into u;
 insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status) values('KNG-CMD-ROSTER-'||substr(gen_random_uuid()::text,1,8),u,'Test shift',c-interval '1 hour',c+interval '7 hours','active') returning id into r;
 j:=game.execute_text_command('assign beat '||ref||' to '||b.beat_ref||' because regression test','assign-'||gen_random_uuid()::text);
 if coalesce((j->>'ok')::boolean,false)=false then raise exception 'Beat assignment failed: %',j; end if;
 j:=game.execute_text_command('schedule patrol '||sched||' '||ref||' in '||b.beat_ref||' from 2026-11-20T13:30:00+00:00 to 2026-11-20T16:00:00+00:00','schedule-'||gen_random_uuid()::text);
 if coalesce((j->>'ok')::boolean,false)=false then raise exception 'Schedule failed: %',j; end if;
 j:=game.execute_text_command('start patrol '||ref||' because regression start','start-'||gen_random_uuid()::text);
 if coalesce((j->>'ok')::boolean,false)=false then raise exception 'Start failed: %',j; end if;
 j:=game.execute_text_command('patrol status','coverage-'||gen_random_uuid()::text); cov:=j->'coverage';
 if coalesce((j->>'ok')::boolean,false)=false or (cov->'totals'->>'covered_beats')::integer<1 then raise exception 'Coverage failed: %',j; end if;
 j:=game.execute_text_command('end patrol '||ref||' because regression end','end-'||gen_random_uuid()::text);
 if coalesce((j->>'ok')::boolean,false)=false then raise exception 'End failed: %',j; end if;
 select operational_state into st from game.police_units where id=u;
 if st<>'at_station' then raise exception 'Expected at_station, got %',st; end if;
 if (select current_game_time from game.simulation_state where id=1) is distinct from c then raise exception 'Fictional clock changed'; end if;
end;$test$;
rollback;