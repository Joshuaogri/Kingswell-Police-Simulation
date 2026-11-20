-- End-to-end patrol road movement through the text command dispatcher.
-- All generated routes, command records, location changes and fixtures roll back.
begin;
do $test$
declare
 c timestamptz:='2026-11-20 14:00:00+00'; f uuid; origin uuid; b game.patrol_beats%rowtype;
 destref text; u uuid; roster_id uuid; ref text; sched text; j jsonb; candidate record; vroute uuid; ok_dest boolean:=false;
 v_end_time timestamptz; v_count integer; help_result jsonb;
begin
 update game.simulation_state set current_game_time=c,time_paused=true where id=1;
 select id,access_point_id into f,origin from game.police_facilities where status='active' and access_point_id is not null order by facility_ref limit 1;
 select * into b from game.patrol_beats where status='active' order by beat_ref limit 1;
 if f is null or origin is null or b.id is null then raise exception 'Required patrol geography missing'; end if;
 for candidate in
  select ap.id,ap.access_ref from game.property_access_points ap
  join game.patrol_beat_road_segments br on br.road_segment_id=ap.road_segment_id and br.beat_id=b.id
  where ap.is_primary and ap.id<>origin order by ap.access_ref
 loop
  vroute:=game.calculate_road_route(origin,candidate.id,'police','fastest');
  if exists(select 1 from game.road_route_calculations rc where rc.id=vroute and rc.route_status='calculated') then
   destref:=candidate.access_ref; ok_dest:=true; exit;
  end if;
 end loop;
 if not ok_dest then raise exception 'No routable beat destination found'; end if;
 ref:='KNG-MOVE-'||substr(gen_random_uuid()::text,1,8); sched:='KNG-MOVE-SCH-'||substr(gen_random_uuid()::text,1,8);
 insert into game.police_units(unit_ref,unit_name,unit_type,status,base_facility_id,assigned_beat_id,current_access_point_id)
 values(ref,'Patrol movement regression','patrol','active',f,b.id,origin) returning id into u;
 insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status)
 values('KNG-MOVE-ROSTER-'||substr(gen_random_uuid()::text,1,8),u,'Movement test shift',c-interval '1 hour',c+interval '8 hours','active') returning id into roster_id;
 insert into game.patrol_schedules(schedule_ref,unit_id,beat_id,roster_id,starts_at,ends_at,status)
 values(sched,u,b.id,roster_id,c-interval '30 minutes',c+interval '7 hours','scheduled');
 j:=game.start_unit_patrol(ref,'Begin road movement regression');
 if coalesce((j->>'state')::text,'')<>'on_patrol' then raise exception 'Patrol start failed: %',j; end if;
 j:=game.execute_text_command('patrol move '||ref||' to '||destref||' because regression road traversal','move-'||gen_random_uuid()::text);
 if coalesce((j->>'ok')::boolean,false)=false then raise exception 'Movement command failed: %',j; end if;
 if coalesce((j->>'road_segments_traversed')::integer,0)<1 then raise exception 'No road segment movement recorded: %',j; end if;
 if (select current_access_point_id from game.police_units where id=u) is distinct from (select id from game.property_access_points where access_ref=destref) then raise exception 'Unit location did not update'; end if;
 select current_game_time into v_end_time from game.simulation_state where id=1;
 if v_end_time<=c then raise exception 'Fictional clock did not advance'; end if;
 select count(*) into v_count from game.patrol_movement_events where unit_id=u;
 if v_count<>(j->>'road_segments_traversed')::integer then raise exception 'Movement event count mismatch'; end if;
 if not exists(select 1 from game.patrol_movement_events e where e.unit_id=u and e.within_assigned_beat) then raise exception 'No within-beat movement segment recorded'; end if;
 if exists(select 1 from game.patrol_movement_events e where e.unit_id=u and e.arrived_at_game_time<=e.departed_at_game_time) then raise exception 'Invalid movement leg time interval'; end if;
 j:=game.execute_text_command('patrol status','movement-coverage-'||gen_random_uuid()::text);
 if coalesce((j->'coverage'->'totals'->>'visited_road_segments')::integer,0)<1 then raise exception 'Coverage report omitted visited road segments: %',j; end if;
 help_result:=game.execute_text_command('help','movement-help-'||gen_random_uuid()::text);
 if not (help_result->'available_commands' ? 'patrol_move') then raise exception 'Patrol movement missing from help command list'; end if;
 if (select current_game_time from game.simulation_state where id=1) is distinct from v_end_time then raise exception 'Coverage/help query changed game clock'; end if;
end;$test$;
rollback;