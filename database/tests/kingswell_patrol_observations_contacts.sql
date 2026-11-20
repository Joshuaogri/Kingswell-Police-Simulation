-- Patrol observation and contact regression. All fixtures roll back.
begin;
do $test$
declare c timestamptz:='2026-11-20 17:00:00+00'; b game.patrol_beats%rowtype; f uuid; access_id uuid; access_ref text; property_ref text;
 u uuid; person_id uuid; officer_id uuid; roster_id uuid; org_id uuid; org_ref text; person_ref text; unit_ref text; officer_ref text;
 start_result jsonb; obs_result jsonb; contact_result jsonb; intel jsonb; help_result jsonb; after_time timestamptz;
 obs_rejected boolean:=false; contact_rejected boolean:=false; obs_ref text; contact_ref text; parsed jsonb;
begin
 update game.simulation_state set current_game_time=c,time_paused=true where id=1;
 select * into b from game.patrol_beats where status='active' order by beat_ref limit 1;
 select pf.id into f from game.police_facilities pf where pf.status='active' and pf.access_point_id is not null order by pf.facility_ref limit 1;
 if b.id is null or f is null then raise exception 'Required patrol fixtures missing'; end if;
 select x.id,x.access_ref,p.property_ref into access_id,access_ref,property_ref
 from game.property_access_points x join game.patrol_beat_road_segments br on br.road_segment_id=x.road_segment_id
 join game.properties p on p.id=x.property_id where br.beat_id=b.id and x.is_primary order by x.access_ref limit 1;
 if access_id is null then raise exception 'No beat access point found'; end if;
 insert into game.persons(person_ref,given_name,family_name,person_status)
 values('KNG-OBS-PERSON-'||substr(gen_random_uuid()::text,1,8),'Patrol','Contact','active') returning id,person_ref into person_id,person_ref;
 insert into game.organisations(organisation_ref,name,organisation_type,status)
 values('KNG-OBS-ORG-'||substr(gen_random_uuid()::text,1,8),'Patrol Contact Business','business','active') returning id,organisation_ref into org_id,org_ref;
 insert into game.police_units(unit_ref,unit_name,unit_type,status,base_facility_id,assigned_beat_id,current_access_point_id,current_location_updated_at)
 values('KNG-OBS-UNIT-'||substr(gen_random_uuid()::text,1,8),'Patrol observation regression','patrol','active',f,b.id,access_id,c) returning id,unit_ref into u,unit_ref;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status,joined_on)
 values('KNG-OBS-OFFICER-'||substr(gen_random_uuid()::text,1,8),person_id,'KNG-OBS-SVC-'||substr(gen_random_uuid()::text,1,8),u,'active',current_date) returning id,personnel_ref into officer_id,officer_ref;
 insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status)
 values('KNG-OBS-ROSTER-'||substr(gen_random_uuid()::text,1,8),u,'Observation test shift',c-interval '1 hour',c+interval '8 hours','active') returning id into roster_id;
 insert into game.patrol_schedules(schedule_ref,unit_id,beat_id,roster_id,starts_at,ends_at,status)
 values('KNG-OBS-SCH-'||substr(gen_random_uuid()::text,1,8),u,b.id,roster_id,c-interval '30 minutes',c+interval '7 hours','scheduled');
 perform game.start_unit_patrol(unit_ref,'Begin patrol observation regression');
 start_result:=game.execute_text_command('start patrol activity '||unit_ref||' by '||officer_ref||' at '||access_ref||' type foot_patrol because observation regression','obs-start-'||gen_random_uuid()::text,null,officer_id);
 if coalesce((start_result->>'ok')::boolean,false)=false then raise exception 'Start activity failed: %',start_result; end if;
 parsed:=game.interpret_text_command('record patrol observation '|| (start_result->>'session_ref') ||' category traffic at '||access_ref||' because Vehicle parked across the marked pedestrian crossing');
 if parsed->>'command_type'<>'record_patrol_observation' or parsed->'payload'->>'category'<>'traffic' then raise exception 'Observation parser failed: %',parsed; end if;
 obs_result:=game.execute_text_command('record patrol observation '||(start_result->>'session_ref')||' category traffic at '||access_ref||' because Vehicle parked across the marked pedestrian crossing','obs-record-'||gen_random_uuid()::text,null,officer_id);
 if coalesce((obs_result->>'ok')::boolean,false)=false then raise exception 'Observation command failed: %',obs_result; end if;
 obs_ref:=obs_result->>'observation_ref';
 parsed:=game.interpret_text_command('record patrol contact '||(start_result->>'session_ref')||' type business_visit person '||person_ref||' organisation '||org_ref||' property '||property_ref||' outcome Spoke with the site manager notes Manager requested a follow-up visit');
 if parsed->>'command_type'<>'record_patrol_contact' or parsed->'payload'->>'person_ref'<>person_ref or parsed->'payload'->>'organisation_ref'<>org_ref then raise exception 'Contact parser failed: %',parsed; end if;
 contact_result:=game.execute_text_command('record patrol contact '||(start_result->>'session_ref')||' type business_visit person '||person_ref||' organisation '||org_ref||' property '||property_ref||' outcome Spoke with the site manager notes Manager requested a follow-up visit','contact-record-'||gen_random_uuid()::text,null,officer_id);
 if coalesce((contact_result->>'ok')::boolean,false)=false then raise exception 'Contact command failed: %',contact_result; end if;
 contact_ref:=contact_result->>'contact_ref';
 select current_game_time into after_time from game.simulation_state where id=1;
 if after_time<>c then raise exception 'Observation/contact logging must not advance fictional time'; end if;
 if not exists(select 1 from game.patrol_contacts where contact_ref=contact_ref and person_id is not null and organisation_id is not null and property_id is not null) then raise exception 'Contact links were not persisted'; end if;
 begin update game.patrol_observations set description='tampered' where observation_ref=obs_ref; exception when others then obs_rejected:=true; end;
 if not obs_rejected then raise exception 'Observation record was mutable'; end if;
 begin delete from game.patrol_contacts where contact_ref=contact_ref; exception when others then contact_rejected:=true; end;
 if not contact_rejected then raise exception 'Contact record was deletable'; end if;
 intel:=game.get_patrol_intelligence(c-interval '1 second',c);
 if (intel->'totals'->>'patrol_observations')::integer<>1 or (intel->'totals'->>'patrol_contacts')::integer<>1 then raise exception 'Patrol intelligence totals missing records: %',intel; end if;
 if not exists(select 1 from jsonb_array_elements(intel->'observation_by_category') x where x->>'category'='traffic' and (x->>'records')::integer=1) then raise exception 'Observation category intelligence missing'; end if;
 if not exists(select 1 from jsonb_array_elements(intel->'contact_by_type') x where x->>'contact_type'='business_visit' and (x->>'records')::integer=1 and (x->>'linked_people')::integer=1 and (x->>'linked_organisations')::integer=1 and (x->>'linked_properties')::integer=1) then raise exception 'Contact intelligence links missing'; end if;
 help_result:=game.execute_text_command('help','obs-help-'||gen_random_uuid()::text,null,officer_id);
 if not (help_result->'available_commands' ? 'record_patrol_observation') or not (help_result->'available_commands' ? 'record_patrol_contact') then raise exception 'New commands missing from help: %',help_result; end if;
end;$test$;
rollback;
