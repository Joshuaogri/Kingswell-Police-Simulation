begin;
do $test$
declare
 v_clock timestamptz:='2026-11-20 12:00:00+00';
 v_facility uuid; v_origin uuid; v_destination_property uuid; v_destination uuid; v_second_position uuid;
 v_station uuid; v_person uuid; v_personnel uuid; v_unit uuid; v_roster uuid; v_incident uuid;
 v_candidate record; v_dispatch jsonb; v_position jsonb; v_deployment uuid;
 v_history integer; v_route uuid; v_segment uuid; v_status text;
begin
 if exists(select 1 from game.police_units) or exists(select 1 from game.incidents) then raise exception 'Regression requires empty live units and incidents'; end if;
 update game.simulation_state set current_game_time=v_clock,time_paused=true where id=1;
 select id,access_point_id into v_facility,v_origin from game.police_facilities where status='active' order by facility_ref limit 1;
 select id from game.police_stations where station_ref='KNG-STA-HQ' into v_station;
 select p.id,ap.id into v_destination_property,v_destination from game.properties p
 join game.property_access_points ap on ap.property_id=p.id and ap.is_primary
 join game.road_segments rs on rs.id=ap.road_segment_id and rs.is_routable
 where p.status='active' and p.id<>(select property_id from game.police_facilities where id=v_facility)
 order by p.property_ref limit 1;
 -- Pick a position with a verified police route to the destination. A merely
 -- routable access point may be on a disconnected road component and produce no legs.
 for v_candidate in
  select ap.id
  from game.property_access_points ap
  join game.road_segments rs on rs.id=ap.road_segment_id and rs.is_routable
  where ap.id not in (v_origin,v_destination)
  order by ap.id
 loop
  v_route:=game.calculate_road_route(v_candidate.id,v_destination,'police','fastest',v_clock);
  if exists(select 1 from game.road_route_legs where route_id=v_route) then
   v_second_position:=v_candidate.id;
   exit;
  end if;
 end loop;
 if v_origin is null or v_destination is null or v_second_position is null then raise exception 'Missing route test access points'; end if;
 insert into game.persons(person_ref,given_name,family_name,person_status,occupation)
 values('KNG-TEST-PERSON-POS-01','Position','Test','active','Police officer') returning id into v_person;
 insert into game.police_units(unit_ref,unit_name,unit_type,status,base_facility_id,station_id)
 values('KNG-TEST-UNIT-POS-01','Position Test Patrol','patrol','active',v_facility,v_station) returning id into v_unit;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,current_station_id,employment_status,joined_on)
 values('KNG-TEST-OFFICER-POS-01',v_person,'KNG-TEST-SN-POS-01',v_unit,v_station,'active','2024-01-01') returning id into v_personnel;
 insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status)
 values('KNG-TEST-ROSTER-POS-01',v_unit,'Position test',v_clock-interval '1 hour',v_clock+interval '8 hours','active') returning id into v_roster;
 insert into game.duty_assignments(roster_id,personnel_id,assignment_role,assigned_station_id,starts_at,ends_at,status)
 values(v_roster,v_personnel,'patrol officer',v_station,v_clock-interval '1 hour',v_clock+interval '8 hours','on_duty');
 insert into game.incidents(incident_ref,reported_at,location_property_id,location_description,priority,status,summary,details)
 values('KNG-TEST-INCIDENT-POS-01',v_clock,v_destination_property,'Position test property',3,'new','Position route test','{"fixture":true}') returning id into v_incident;
 select * into v_candidate from game.get_dispatch_candidates_ranked('KNG-TEST-INCIDENT-POS-01');
 if v_candidate.unit_ref<>'KNG-TEST-UNIT-POS-01' or v_candidate.route_status<>'calculated' or v_candidate.estimated_arrival_at is null then
   raise exception 'ETA-ranked candidate failed: %',row_to_json(v_candidate); end if;
 v_dispatch:=game.submit_command('dispatch KNG-TEST-UNIT-POS-01 to KNG-TEST-INCIDENT-POS-01',
  'dispatch_unit',jsonb_build_object('unit_ref','KNG-TEST-UNIT-POS-01','incident_ref','KNG-TEST-INCIDENT-POS-01'),
  'KNG-TEST-DISPATCH-POS-01',null,null);
 if coalesce((v_dispatch->>'ok')::boolean,false) is not true then raise exception 'Dispatch failed: %',v_dispatch; end if;
 select id,route_calculation_id into v_deployment,v_route from game.incident_deployments where incident_id=v_incident and unit_id=v_unit;
 if v_deployment is null or v_route is null then raise exception 'Initial route snapshot missing'; end if;
 v_position:=game.execute_text_command('position unit KNG-TEST-UNIT-POS-01 at '||v_second_position::text||' because Regression movement update','KNG-TEST-POS-COMMAND-01',null,null);
 if (v_position->>'active_deployments_recalculated')::integer<>1 then raise exception 'Position update did not recalculate deployment: %',v_position; end if;
 if (select current_access_point_id from game.police_units where id=v_unit) is distinct from v_second_position then raise exception 'Unit position not stored'; end if;
 select count(*) into v_history from game.deployment_route_history where deployment_id=v_deployment;
 if v_history<>2 then raise exception 'Expected initial plus position history, got %',v_history; end if;
 select l.road_segment_id into v_segment from game.road_route_legs l
 where l.route_id=(select route_calculation_id from game.incident_deployments where id=v_deployment)
 order by l.leg_order limit 1;
 if v_segment is null then raise exception 'No route segment for closure test'; end if;
 update game.road_segments set is_routable=false where id=v_segment;
 select count(*) into v_history from game.deployment_route_history where deployment_id=v_deployment;
 if v_history<>3 then raise exception 'Road closure did not append route history, got %',v_history; end if;
 select route_status into v_status from game.incident_deployments where id=v_deployment;
 if v_status not in ('calculated','unreachable','location_unresolved') then raise exception 'Unexpected post-closure status %',v_status; end if;
 update game.road_segments set is_routable=true where id=v_segment;
 select count(*) into v_history from game.deployment_route_history where deployment_id=v_deployment;
 if v_history<>4 then raise exception 'Road reopening did not append route history, got %',v_history; end if;
 if (select current_game_time from game.simulation_state where id=1) is distinct from v_clock then raise exception 'Route operations advanced fictional time'; end if;
end
$test$;
rollback;