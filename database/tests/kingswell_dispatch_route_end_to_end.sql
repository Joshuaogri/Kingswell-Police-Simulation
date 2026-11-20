begin;
do $test$
declare
  v_clock timestamptz := '2026-11-20 12:00:00+00';
  v_facility_id uuid; v_origin_access uuid; v_destination_property uuid; v_destination_access uuid;
  v_station_id uuid; v_person_id uuid; v_personnel_id uuid; v_unit_id uuid; v_roster_id uuid; v_incident_id uuid;
  v_candidate record; v_result jsonb; v_repeat jsonb; v_deployment_count integer; v_history_count integer;
  v_route_status text; v_route_id uuid; v_eta timestamptz; v_distance integer; v_seconds integer;
begin
  if exists(select 1 from game.police_units) or exists(select 1 from game.incidents) then raise exception 'End-to-end fixture requires empty unit and incident baseline'; end if;
  update game.simulation_state set current_game_time=v_clock,time_paused=true where id=1;
  select pf.id,pf.access_point_id into v_facility_id,v_origin_access from game.police_facilities pf where pf.status='active' order by pf.facility_ref limit 1;
  if v_facility_id is null then raise exception 'No active police facility fixture origin'; end if;
  select ps.id into v_station_id from game.police_stations ps where ps.station_ref='KNG-STA-HQ';
  select p.id,ap.id into v_destination_property,v_destination_access from game.properties p
  join game.property_access_points ap on ap.property_id=p.id and ap.is_primary
  join game.road_segments rs on rs.id=ap.road_segment_id and rs.is_routable
  where p.status='active' and p.id<>(select property_id from game.police_facilities where id=v_facility_id)
  order by p.property_ref limit 1;
  if v_destination_property is null or v_destination_access is null then raise exception 'No routable destination fixture'; end if;
  insert into game.persons(person_ref,given_name,family_name,person_status,occupation)
  values('KNG-TEST-PERSON-ROUTE-01','Regression','Officer','active','Police officer') returning id into v_person_id;
  insert into game.police_units(unit_ref,unit_name,unit_type,status,base_facility_id,station_id)
  values('KNG-TEST-UNIT-ROUTE-01','Regression Patrol Unit','patrol','active',v_facility_id,v_station_id) returning id into v_unit_id;
  insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,current_station_id,employment_status,joined_on)
  values('KNG-TEST-OFFICER-ROUTE-01',v_person_id,'KNG-TEST-SN-ROUTE-01',v_unit_id,v_station_id,'active','2024-01-01') returning id into v_personnel_id;
  insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status)
  values('KNG-TEST-ROSTER-ROUTE-01',v_unit_id,'Regression day shift',v_clock-interval '1 hour',v_clock+interval '8 hours','active') returning id into v_roster_id;
  insert into game.duty_assignments(roster_id,personnel_id,assignment_role,assigned_station_id,starts_at,ends_at,status)
  values(v_roster_id,v_personnel_id,'patrol officer',v_station_id,v_clock-interval '1 hour',v_clock+interval '8 hours','on_duty');
  insert into game.incidents(incident_ref,reported_at,location_property_id,location_description,priority,status,summary,details)
  values('KNG-TEST-INCIDENT-ROUTE-01',v_clock,v_destination_property,'Regression test property',3,'new','Temporary route integration test incident','{"fixture":true}')
  returning id into v_incident_id;
  select * into v_candidate from game.get_dispatch_candidates('KNG-TEST-INCIDENT-ROUTE-01');
  if v_candidate.unit_ref is distinct from 'KNG-TEST-UNIT-ROUTE-01' or v_candidate.eligible_personnel_count<>1
     or not ('KNG-TEST-OFFICER-ROUTE-01'=any(v_candidate.personnel_refs)) or v_candidate.route_status<>'calculated'
     or v_candidate.distance_m is null or v_candidate.distance_m<=0 or v_candidate.estimated_duration_seconds is null
     or v_candidate.estimated_arrival_at is distinct from v_clock+make_interval(secs=>v_candidate.estimated_duration_seconds) then
    raise exception 'Candidate route/eligibility assertion failed: %',row_to_json(v_candidate);
  end if;
  v_result:=game.submit_command('dispatch KNG-TEST-UNIT-ROUTE-01 to KNG-TEST-INCIDENT-ROUTE-01',
    'dispatch_unit',jsonb_build_object('unit_ref','KNG-TEST-UNIT-ROUTE-01','incident_ref','KNG-TEST-INCIDENT-ROUTE-01'),
    'KNG-TEST-DISPATCH-ROUTE-KEY-01',null,null);
  if coalesce((v_result->>'ok')::boolean,false) is not true then raise exception 'Dispatch command failed: %',v_result; end if;
  select count(*) into v_deployment_count from game.incident_deployments where incident_id=v_incident_id and unit_id=v_unit_id;
  select route_status,route_calculation_id,estimated_arrival_at,route_distance_m,route_estimated_seconds into v_route_status,v_route_id,v_eta,v_distance,v_seconds
  from game.incident_deployments where incident_id=v_incident_id and unit_id=v_unit_id limit 1;
  if v_deployment_count<>1 or v_route_status<>'calculated' or v_route_id is null or v_eta is distinct from v_clock+make_interval(secs=>v_seconds)
     or v_distance is null or v_distance<=0 then raise exception 'Deployment route snapshot assertion failed'; end if;
  select count(*) into v_history_count from game.deployment_route_history where deployment_id in (select id from game.incident_deployments where incident_id=v_incident_id);
  if v_history_count<>1 then raise exception 'Expected one initial route history row, got %',v_history_count; end if;
  v_repeat:=game.submit_command('dispatch KNG-TEST-UNIT-ROUTE-01 to KNG-TEST-INCIDENT-ROUTE-01',
    'dispatch_unit',jsonb_build_object('unit_ref','KNG-TEST-UNIT-ROUTE-01','incident_ref','KNG-TEST-INCIDENT-ROUTE-01'),
    'KNG-TEST-DISPATCH-ROUTE-KEY-01',null,null);
  if coalesce((v_repeat->>'ok')::boolean,false) is not true or v_repeat->>'command_id' is distinct from v_result->>'command_id'
    then raise exception 'Idempotent replay did not return original command: first %, replay %',v_result,v_repeat; end if;
  select count(*) into v_deployment_count from game.incident_deployments where incident_id=v_incident_id;
  if v_deployment_count<>1 then raise exception 'Idempotent replay created duplicate deployments'; end if;
  if (select status from game.incidents where id=v_incident_id)<>'dispatched' then raise exception 'Incident status not dispatched'; end if;
  if not exists(select 1 from game.dispatch_events where incident_id=v_incident_id and event_type='unit_dispatched') then raise exception 'Dispatch event missing'; end if;
  if (select current_game_time from game.simulation_state where id=1) is distinct from v_clock then raise exception 'Fictional clock unexpectedly advanced'; end if;
end
$test$;
rollback;