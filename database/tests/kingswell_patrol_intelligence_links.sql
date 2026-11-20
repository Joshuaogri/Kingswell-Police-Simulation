-- Patrol intelligence incident/case linking regression. All fixtures roll back.
begin;
do $test$
declare
 c timestamptz:='2026-11-20 18:00:00+00'; b game.patrol_beats%rowtype; facility_id uuid;
 access_id uuid; access_ref text; person_id uuid; person_ref text; officer_id uuid; officer_ref text;
 roster_id uuid; unit_id uuid; unit_ref text; session_ref text; obs jsonb; linked_incident jsonb; linked_case jsonb; duplicate_link jsonb;
 parsed jsonb; help_result jsonb; incident_ref text:='KNG-LINK-INC-'||substr(gen_random_uuid()::text,1,8);
 case_ref text:='KNG-LINK-CASE-'||substr(gen_random_uuid()::text,1,8);
 observation_ref text; original_description text; link_count integer; event_count integer; after_time timestamptz;
begin
 update game.simulation_state set current_game_time=c,time_paused=true where id=1;
 select * into b from game.patrol_beats where status='active' order by beat_ref limit 1;
 select pf.id into facility_id from game.police_facilities pf where pf.status='active' and pf.access_point_id is not null order by pf.facility_ref limit 1;
 select x.id,x.access_ref into access_id,access_ref from game.property_access_points x
 join game.patrol_beat_road_segments br on br.road_segment_id=x.road_segment_id
 where br.beat_id=b.id and x.is_primary order by x.access_ref limit 1;
 if b.id is null or facility_id is null or access_id is null then raise exception 'Patrol geography fixtures missing'; end if;
 insert into game.persons(person_ref,given_name,family_name,person_status)
 values('KNG-LINK-PER-'||substr(gen_random_uuid()::text,1,8),'Link','Officer','active')
 returning id,game.persons.person_ref into person_id,person_ref;
 insert into game.police_units(unit_ref,unit_name,unit_type,status,base_facility_id,assigned_beat_id,current_access_point_id,current_location_updated_at)
 values('KNG-LINK-UNIT-'||substr(gen_random_uuid()::text,1,8),'Link test unit','patrol','active',facility_id,b.id,access_id,c)
 returning id,game.police_units.unit_ref into unit_id,unit_ref;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status,joined_on)
 values('KNG-LINK-OFF-'||substr(gen_random_uuid()::text,1,8),person_id,'KNG-LINK-SVC-'||substr(gen_random_uuid()::text,1,8),unit_id,'active',current_date)
 returning id,game.police_personnel.personnel_ref into officer_id,officer_ref;
 insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status)
 values('KNG-LINK-ROS-'||substr(gen_random_uuid()::text,1,8),unit_id,'Link test shift',c-interval '1 hour',c+interval '8 hours','active') returning id into roster_id;
 insert into game.patrol_schedules(schedule_ref,unit_id,beat_id,roster_id,starts_at,ends_at,status)
 values('KNG-LINK-SCH-'||substr(gen_random_uuid()::text,1,8),unit_id,b.id,roster_id,c-interval '30 minutes',c+interval '7 hours','scheduled');
 perform game.start_unit_patrol(unit_ref,'Begin intelligence-link test');
 obs:=game.execute_text_command('start patrol activity '||unit_ref||' by '||officer_ref||' at '||access_ref||' type foot_patrol because link regression','link-start-'||gen_random_uuid()::text,null,officer_id);
 if not coalesce((obs->>'ok')::boolean,false) then raise exception 'Activity start failed: %',obs; end if;
 session_ref:=obs->>'session_ref';
 obs:=game.execute_text_command('record patrol observation '||session_ref||' category community_concern at '||access_ref||' because Test observation for linking','link-observation-'||gen_random_uuid()::text,null,officer_id);
 if not coalesce((obs->>'ok')::boolean,false) then raise exception 'Observation failed: %',obs; end if;
 observation_ref:=obs->>'observation_ref';
 select description into original_description from game.patrol_observations where observation_ref=observation_ref;
 insert into game.incidents(incident_ref,summary,status,reported_at,details)
 values(incident_ref,'Test incident for patrol linkage','new',c,'{}');
 insert into game.cases(case_ref,case_title,status,opened_at,case_data)
 values(case_ref,'Test case for patrol linkage','open',c,'{}');
 parsed:=game.interpret_text_command('link patrol record '||observation_ref||' to incident '||incident_ref||' because Same location and matching time window');
 if parsed->>'command_type'<>'link_patrol_record' or parsed->'payload'->>'target_type'<>'incident' then raise exception 'Incident link parser failed: %',parsed; end if;
 linked_incident:=game.execute_text_command('link patrol record '||observation_ref||' to incident '||incident_ref||' because Same location and matching time window','link-incident-'||gen_random_uuid()::text,null,officer_id);
 if not coalesce((linked_incident->>'ok')::boolean,false) or linked_incident->>'link_ref' is null then raise exception 'Incident link failed: %',linked_incident; end if;
 linked_case:=game.execute_text_command('link patrol record '||observation_ref||' to case '||case_ref||' because Context may assist the existing investigation','link-case-'||gen_random_uuid()::text,null,officer_id);
 if not coalesce((linked_case->>'ok')::boolean,false) or linked_case->>'link_ref' is null then raise exception 'Case link failed: %',linked_case; end if;
 duplicate_link:=game.execute_text_command('link patrol record '||observation_ref||' to incident '||incident_ref||' because Duplicate should not create a second link','link-duplicate-'||gen_random_uuid()::text,null,officer_id);
 if not coalesce((duplicate_link->>'duplicate')::boolean,false) then raise exception 'Duplicate link was not handled safely: %',duplicate_link; end if;
 select count(*) into link_count from game.patrol_intelligence_links where source_observation_id=(select id from game.patrol_observations where observation_ref=observation_ref);
 select count(*) into event_count from game.game_events where event_key='patrol_intelligence.record_linked' and event_data->>'source_ref'=observation_ref;
 if link_count<>2 or event_count<>2 then raise exception 'Expected two distinct links and events, got links %, events %',link_count,event_count; end if;
 if (select description from game.patrol_observations where observation_ref=observation_ref) is distinct from original_description then raise exception 'Original observation was modified'; end if;
 begin
  update game.patrol_intelligence_links set reason='tampered' where link_ref=linked_incident->>'link_ref';
  raise exception 'Immutable link unexpectedly allowed update';
 exception when others then
  if sqlerrm='Immutable link unexpectedly allowed update' then raise; end if;
 end;
 help_result:=game.execute_text_command('help','link-help-'||gen_random_uuid()::text,null,officer_id);
 if not (help_result->'available_commands' ? 'link_patrol_record') then raise exception 'Link command missing from help'; end if;
 select current_game_time into after_time from game.simulation_state where id=1;
 if after_time is distinct from c then raise exception 'Linking must not advance fictional time'; end if;
end;$test$;
rollback;
