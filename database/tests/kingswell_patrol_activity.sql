-- Patrol activity session regression. All fixtures roll back.
begin;
do $test$
declare c timestamptz:='2026-11-20 16:00:00+00'; b game.patrol_beats%rowtype; ap record;
 f uuid; u uuid; person_id uuid; officer_id uuid; roster_id uuid; start_result jsonb; end_result jsonb; intel jsonb; help_result jsonb; session_ref text; after_time timestamptz; event_id uuid; rejected boolean:=false;
begin
 update game.simulation_state set current_game_time=c,time_paused=true where id=1;
 select * into b from game.patrol_beats where status='active' order by beat_ref limit 1;
 select pf.id,pf.access_point_id into f,ap from game.police_facilities pf where pf.status='active' and pf.access_point_id is not null order by pf.facility_ref limit 1;
 if b.id is null or f is null then raise exception 'Required patrol fixtures missing'; end if;
 select x.id,x.access_ref into ap from game.property_access_points x join game.patrol_beat_road_segments br on br.road_segment_id=x.road_segment_id where br.beat_id=b.id and x.is_primary order by x.access_ref limit 1;
 if ap.id is null then raise exception 'No beat access point found'; end if;
 insert into game.persons(person_ref,given_name,family_name,person_status)
 values('KNG-ACT-PERSON-'||substr(gen_random_uuid()::text,1,8),'Activity','Officer','active') returning id into person_id;
 insert into game.police_units(unit_ref,unit_name,unit_type,status,base_facility_id,assigned_beat_id,current_access_point_id,current_location_updated_at)
 values('KNG-ACT-UNIT-'||substr(gen_random_uuid()::text,1,8),'Patrol activity regression','patrol','active',f,b.id,ap.id,c) returning id into u;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status,joined_on)
 values('KNG-ACT-OFFICER-'||substr(gen_random_uuid()::text,1,8),person_id,'KNG-ACT-SVC-'||substr(gen_random_uuid()::text,1,8),u,'active',current_date) returning id into officer_id;
 insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status)
 values('KNG-ACT-ROSTER-'||substr(gen_random_uuid()::text,1,8),u,'Activity test shift',c-interval '1 hour',c+interval '8 hours','active') returning id into roster_id;
 insert into game.patrol_schedules(schedule_ref,unit_id,beat_id,roster_id,starts_at,ends_at,status)
 values('KNG-ACT-SCH-'||substr(gen_random_uuid()::text,1,8),u,b.id,roster_id,c-interval '30 minutes',c+interval '7 hours','scheduled');
 perform game.start_unit_patrol((select unit_ref from game.police_units where id=u),'Begin patrol activity regression');
 start_result:=game.execute_text_command(
  'start patrol activity '||(select unit_ref from game.police_units where id=u)||
  ' by '||(select personnel_ref from game.police_personnel where id=officer_id)||
  ' at '||ap.access_ref||' type foot_patrol because regression foot patrol',
  'activity-start-'||gen_random_uuid()::text,null,officer_id);
 if coalesce((start_result->>'ok')::boolean,false)=false then raise exception 'Start activity command failed: %',start_result; end if;
 session_ref:=start_result->>'session_ref';
 select id into event_id from game.patrol_activity_events where session_id=(select id from game.patrol_activity_sessions where session_ref=session_ref) and event_type='activity_started';
 if event_id is null then raise exception 'Activity start event missing'; end if;
 begin
  update game.patrol_activity_events set details='{}'::jsonb where id=event_id;
 exception when others then rejected:=true;
 end;
 if not rejected then raise exception 'Activity event history accepted an update'; end if;
 end_result:=game.execute_text_command('end patrol activity '||session_ref||' after 15 minutes because regression completed',
  'activity-end-'||gen_random_uuid()::text,null,officer_id);
 if coalesce((end_result->>'ok')::boolean,false)=false then raise exception 'End activity command failed: %',end_result; end if;
 if (end_result->>'duration_minutes')::integer<>15 then raise exception 'Recorded duration incorrect: %',end_result; end if;
 select current_game_time into after_time from game.simulation_state where id=1;
 if after_time<>c+interval '15 minutes' then raise exception 'Explicit activity duration did not advance fictional clock correctly'; end if;
 intel:=game.get_patrol_intelligence(c-interval '1 second',after_time);
 if (intel->'totals'->>'patrol_activity_sessions')::integer<>1 then raise exception 'Activity session missing from intelligence: %',intel; end if;
 if (intel->'totals'->>'patrol_activity_minutes')::numeric<>15 then raise exception 'Activity minutes missing from intelligence: %',intel; end if;
 if not exists(select 1 from jsonb_array_elements(intel->'activity_by_type') x where x->>'activity_type'='foot_patrol' and (x->>'activity_minutes')::numeric=15) then raise exception 'Foot patrol type not included in intelligence'; end if;
 help_result:=game.execute_text_command('help','activity-help-'||gen_random_uuid()::text,null,officer_id);
 if not (help_result->'available_commands' ? 'start_patrol_activity') or not (help_result->'available_commands' ? 'end_patrol_activity') then raise exception 'Activity commands missing from help: %',help_result; end if;
end;$test$;
rollback;
