-- Patrol intelligence report regression. All fixtures roll back.
begin;
do $test$
declare c timestamptz:='2026-11-20 15:00:00+00'; f uuid; origin uuid; b game.patrol_beats%rowtype;
 destref text; u uuid; roster_id uuid; ref text; sched text; j jsonb; candidate record; vroute uuid; found_route boolean:=false;
 v_end_time timestamptz; person_id uuid; actor_id uuid; intelligence jsonb; help_result jsonb;
begin
 update game.simulation_state set current_game_time=c,time_paused=true where id=1;
 select id,access_point_id into f,origin from game.police_facilities where status='active' and access_point_id is not null order by facility_ref limit 1;
 select * into b from game.patrol_beats where status='active' order by beat_ref limit 1;
 if f is null or origin is null or b.id is null then raise exception 'Required patrol geography missing'; end if;
 for candidate in select ap.id,ap.access_ref from game.property_access_points ap join game.patrol_beat_road_segments br on br.road_segment_id=ap.road_segment_id and br.beat_id=b.id where ap.is_primary and ap.id<>origin order by ap.access_ref loop
  vroute:=game.calculate_road_route(origin,candidate.id,'police','fastest');
  if exists(select 1 from game.road_route_calculations rc where rc.id=vroute and rc.route_status='calculated') then destref:=candidate.access_ref; found_route:=true; exit; end if;
 end loop;
 if not found_route then raise exception 'No routable beat destination found'; end if;
 insert into game.persons(person_ref,given_name,family_name,person_status) values('KNG-INTEL-PERSON-'||substr(gen_random_uuid()::text,1,8),'Patrol','Analyst','active') returning id into person_id;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status,joined_on) values('KNG-INTEL-OFFICER-'||substr(gen_random_uuid()::text,1,8),person_id,'KNG-INTEL-SVC-'||substr(gen_random_uuid()::text,1,8),'active',current_date) returning id into actor_id;
 ref:='KNG-INTEL-'||substr(gen_random_uuid()::text,1,8); sched:='KNG-INTEL-SCH-'||substr(gen_random_uuid()::text,1,8);
 insert into game.police_units(unit_ref,unit_name,unit_type,status,base_facility_id,assigned_beat_id,current_access_point_id) values(ref,'Patrol intelligence regression','patrol','active',f,b.id,origin) returning id into u;
 insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status) values('KNG-INTEL-ROSTER-'||substr(gen_random_uuid()::text,1,8),u,'Intelligence test shift',c-interval '1 hour',c+interval '8 hours','active') returning id into roster_id;
 insert into game.patrol_schedules(schedule_ref,unit_id,beat_id,roster_id,starts_at,ends_at,status) values(sched,u,b.id,roster_id,c-interval '30 minutes',c+interval '7 hours','scheduled');
 j:=game.start_unit_patrol(ref,'Begin patrol intelligence regression');
 j:=game.execute_text_command('patrol move '||ref||' to '||destref||' because patrol intelligence regression','intel-move-'||gen_random_uuid()::text,null,actor_id);
 if coalesce((j->>'ok')::boolean,false)=false then raise exception 'Movement command failed: %',j; end if;
 select current_game_time into v_end_time from game.simulation_state where id=1;
 intelligence:=game.get_patrol_intelligence(c-interval '1 second',v_end_time);
 if coalesce((intelligence->'totals'->>'distinct_road_segments_visited')::integer,0)<1 then raise exception 'Intelligence report missed traversed road segments: %',intelligence; end if;
 if coalesce((intelligence->'totals'->>'patrol_movement_minutes')::numeric,0)<=0 then raise exception 'Movement minutes were not calculated: %',intelligence; end if;
 if not exists(select 1 from jsonb_array_elements(intelligence->'beats') x where x->>'beat_ref'=b.beat_ref and (x->>'visited_road_segments')::integer>0) then raise exception 'Beat visit statistics missing: %',intelligence; end if;
 j:=game.execute_text_command('patrol intelligence','intel-command-'||gen_random_uuid()::text,null,actor_id);
 if coalesce((j->>'ok')::boolean,false)=false or not (j ? 'intelligence') then raise exception 'Patrol intelligence command failed: %',j; end if;
 help_result:=game.execute_text_command('help','intel-help-'||gen_random_uuid()::text,null,actor_id);
 if not (help_result->'available_commands' ? 'patrol_intelligence') then raise exception 'Patrol intelligence missing from help: %',help_result; end if;
 if (select current_game_time from game.simulation_state where id=1) is distinct from v_end_time then raise exception 'Intelligence reporting changed fictional time'; end if;
end;$test$;
rollback;