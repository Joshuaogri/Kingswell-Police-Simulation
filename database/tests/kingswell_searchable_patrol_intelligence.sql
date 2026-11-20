-- Searchable patrol intelligence regression. All fixtures roll back.
begin;
do $test$
declare c timestamptz:='2026-11-20 18:00:00+00'; b game.patrol_beats%rowtype; f uuid; access_id uuid; access_ref text;
 person_id uuid; person_ref text; officer_id uuid; roster_id uuid; unit_id uuid; v_unit_ref text; v_officer_ref text;
 start_result jsonb; obs1 jsonb; obs2 jsonb; search_result jsonb; help_result jsonb; parsed jsonb; after_time timestamptz;
begin
 update game.simulation_state set current_game_time=c,time_paused=true where id=1;
 select * into b from game.patrol_beats where status='active' order by beat_ref limit 1;
 select pf.id into f from game.police_facilities pf where pf.status='active' and pf.access_point_id is not null order by pf.facility_ref limit 1;
 if b.id is null or f is null then raise exception 'Required patrol fixtures missing'; end if;
 select x.id,x.access_ref into access_id,access_ref
 from game.property_access_points x join game.patrol_beat_road_segments br on br.road_segment_id=x.road_segment_id
 where br.beat_id=b.id and x.is_primary order by x.access_ref limit 1;
 if access_id is null then raise exception 'No beat access point found'; end if;
 insert into game.persons(person_ref,given_name,family_name,person_status)
 values('KNG-SEARCH-PERSON-'||substr(gen_random_uuid()::text,1,8),'Search','Officer','active')
 returning id,game.persons.person_ref into person_id,person_ref;
 insert into game.police_units(unit_ref,unit_name,unit_type,status,base_facility_id,assigned_beat_id,current_access_point_id,current_location_updated_at)
 values('KNG-SEARCH-UNIT-'||substr(gen_random_uuid()::text,1,8),'Search test unit','patrol','active',f,b.id,access_id,c)
 returning id,game.police_units.unit_ref into unit_id,v_unit_ref;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status,joined_on)
 values('KNG-SEARCH-OFFICER-'||substr(gen_random_uuid()::text,1,8),person_id,'KNG-SEARCH-SVC-'||substr(gen_random_uuid()::text,1,8),unit_id,'active',current_date)
 returning id,game.police_personnel.personnel_ref into officer_id,v_officer_ref;
 insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status)
 values('KNG-SEARCH-ROSTER-'||substr(gen_random_uuid()::text,1,8),unit_id,'Search test shift',c-interval '1 hour',c+interval '8 hours','active') returning id into roster_id;
 insert into game.patrol_schedules(schedule_ref,unit_id,beat_id,roster_id,starts_at,ends_at,status)
 values('KNG-SEARCH-SCH-'||substr(gen_random_uuid()::text,1,8),unit_id,b.id,roster_id,c-interval '30 minutes',c+interval '7 hours','scheduled');
 perform game.start_unit_patrol(v_unit_ref,'Begin patrol intelligence search test');
 start_result:=game.execute_text_command('start patrol activity '||v_unit_ref||' by '||v_officer_ref||' at '||access_ref||' type foot_patrol because search regression','search-start-'||gen_random_uuid()::text,null,officer_id);
 if coalesce((start_result->>'ok')::boolean,false)=false then raise exception 'Start activity failed: %',start_result; end if;
 obs1:=game.execute_text_command('record patrol observation '||(start_result->>'session_ref')||' category traffic at '||access_ref||' because Repeated obstruction of the pedestrian crossing','search-obs1-'||gen_random_uuid()::text,null,officer_id);
 obs2:=game.execute_text_command('record patrol observation '||(start_result->>'session_ref')||' category traffic at '||access_ref||' because Another vehicle obstructed the pedestrian crossing','search-obs2-'||gen_random_uuid()::text,null,officer_id);
 if coalesce((obs1->>'ok')::boolean,false)=false or coalesce((obs2->>'ok')::boolean,false)=false then raise exception 'Observation setup failed: %, %',obs1,obs2; end if;
 parsed:=game.interpret_text_command('search patrol intelligence for traffic');
 if parsed->>'command_type'<>'search_patrol_intelligence' or parsed->'payload'->>'query'<>'traffic' then raise exception 'Search parser failed: %',parsed; end if;
 search_result:=game.execute_text_command('search patrol intelligence for traffic','search-run-'||gen_random_uuid()::text,null,officer_id);
 if coalesce((search_result->>'ok')::boolean,false)=false then raise exception 'Search command failed: %',search_result; end if;
 if (search_result->>'records_match_count')::integer<>2 or jsonb_array_length(search_result->'records')<>2 then raise exception 'Search did not return both source records: %',search_result; end if;
 if jsonb_array_length(search_result->'repeat_concerns')<>1 or (search_result->'repeat_concerns'->0->>'record_count')::integer<>2 then raise exception 'Repeat-location summary incorrect: %',search_result; end if;
 if position('do not establish criminality' in search_result->>'interpretation')=0 then raise exception 'Interpretation safeguard missing'; end if;
 help_result:=game.execute_text_command('help','search-help-'||gen_random_uuid()::text,null,officer_id);
 if not (help_result->'available_commands' ? 'search_patrol_intelligence') then raise exception 'Search command missing from help'; end if;
 select current_game_time into after_time from game.simulation_state where id=1;
 if after_time is distinct from c then raise exception 'Search must not advance fictional time'; end if;
end;$test$;
rollback;
