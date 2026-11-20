begin;
do $test$
declare
 v_clock timestamptz:='2026-11-20 13:00:00+00';
 v_facility uuid; v_station uuid; v_property uuid; v_destination uuid;
 v_person1 uuid; v_person2 uuid; v_unit1 uuid; v_unit2 uuid;
 v_pp1 uuid; v_pp2 uuid; v_roster1 uuid; v_roster2 uuid; v_incident uuid;
 v_options jsonb; v_dispatch jsonb; v_reassign jsonb;
 v_old_deployment uuid; v_new_deployment uuid; v_old_history integer; v_new_history integer;
 v_name text; v_clock_after timestamptz;
begin
 if exists(select 1 from game.police_units) or exists(select 1 from game.incidents) then
   raise exception 'Dispatch UI regression requires empty live units and incidents';
 end if;
 update game.simulation_state set current_game_time=v_clock,time_paused=true where id=1;
 select id into v_facility from game.police_facilities where status='active' order by facility_ref limit 1;
 select id into v_station from game.police_stations where station_ref='KNG-STA-HQ';
 select p.id,ap.id into v_property,v_destination
 from game.properties p join game.property_access_points ap on ap.property_id=p.id and ap.is_primary
 join game.road_segments rs on rs.id=ap.road_segment_id and rs.is_routable
 where p.status='active' and p.id<>(select property_id from game.police_facilities where id=v_facility)
 order by p.property_ref limit 1;
 insert into game.persons(person_ref,given_name,family_name,person_status,occupation) values
 ('KNG-TEST-DOPT-PERSON-01','Dispatch','Alpha','active','Police officer'),
 ('KNG-TEST-DOPT-PERSON-02','Dispatch','Bravo','active','Police officer');
 select id into v_person1 from game.persons where person_ref='KNG-TEST-DOPT-PERSON-01';
 select id into v_person2 from game.persons where person_ref='KNG-TEST-DOPT-PERSON-02';
 insert into game.police_units(unit_ref,unit_name,unit_type,status,base_facility_id,station_id)
 values('KNG-TEST-DOPT-UNIT-01','Initial Patrol','patrol','active',v_facility,v_station) returning id into v_unit1;
 insert into game.police_units(unit_ref,unit_name,unit_type,status,base_facility_id,station_id,current_access_point_id)
 values('KNG-TEST-DOPT-UNIT-02','Replacement Patrol','patrol','active',v_facility,v_station,v_destination) returning id into v_unit2;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,current_station_id,employment_status,joined_on)
 values('KNG-TEST-DOPT-OFFICER-01',v_person1,'KNG-TEST-DOPT-SN-01',v_unit1,v_station,'active','2024-01-01') returning id into v_pp1;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,current_station_id,employment_status,joined_on)
 values('KNG-TEST-DOPT-OFFICER-02',v_person2,'KNG-TEST-DOPT-SN-02',v_unit2,v_station,'active','2024-01-01') returning id into v_pp2;
 insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status) values
 ('KNG-TEST-DOPT-ROSTER-01',v_unit1,'Dispatch UI test',v_clock-interval '1 hour',v_clock+interval '8 hours','active'),
 ('KNG-TEST-DOPT-ROSTER-02',v_unit2,'Dispatch UI test',v_clock-interval '1 hour',v_clock+interval '8 hours','active');
 select id into v_roster1 from game.duty_rosters where roster_ref='KNG-TEST-DOPT-ROSTER-01';
 select id into v_roster2 from game.duty_rosters where roster_ref='KNG-TEST-DOPT-ROSTER-02';
 insert into game.duty_assignments(roster_id,personnel_id,assignment_role,assigned_station_id,starts_at,ends_at,status) values
 (v_roster1,v_pp1,'patrol officer',v_station,v_clock-interval '1 hour',v_clock+interval '8 hours','on_duty'),
 (v_roster2,v_pp2,'patrol officer',v_station,v_clock-interval '1 hour',v_clock+interval '8 hours','on_duty');
 insert into game.incidents(incident_ref,reported_at,location_property_id,location_description,priority,status,summary,details)
 values('KNG-TEST-DOPT-INCIDENT-01',v_clock,v_property,'Dispatch options test location',2,'new','Dispatch options regression','{"fixture":true}')
 returning id into v_incident;

 v_options:=game.execute_text_command('dispatch options for KNG-TEST-DOPT-INCIDENT-01','KNG-TEST-DOPT-OPTIONS-01',null,null);
 if coalesce((v_options->>'ok')::boolean,false) is not true then raise exception 'Dispatch options command failed: %',v_options; end if;
 if (v_options->>'candidate_count')::integer<>2 then raise exception 'Expected two ranked candidates: %',v_options; end if;
 if v_options->'candidates'->0->>'unit_ref'<>'KNG-TEST-DOPT-UNIT-02' then raise exception 'ETA ranking not reflected in player options: %',v_options; end if;
 select v_options->'candidates'->1->'officers'->0->>'name' into v_name;
 if v_name is null or v_name not ilike '%Alpha%' then raise exception 'Named available officer missing from options: %',v_options; end if;

 v_dispatch:=game.execute_text_command('dispatch KNG-TEST-DOPT-UNIT-01 to KNG-TEST-DOPT-INCIDENT-01','KNG-TEST-DOPT-DISPATCH-01',null,null);
 if coalesce((v_dispatch->>'ok')::boolean,false) is not true then raise exception 'Initial dispatch failed: %',v_dispatch; end if;
 select id into v_old_deployment from game.incident_deployments where incident_id=v_incident and unit_id=v_unit1;
 if v_old_deployment is null then raise exception 'Initial deployment missing'; end if;
 select count(*) into v_old_history from game.deployment_route_history where deployment_id=v_old_deployment;
 if v_old_history<>1 then raise exception 'Initial deployment route snapshot/history missing: %',v_old_history; end if;

 v_reassign:=game.execute_text_command('reassign KNG-TEST-DOPT-UNIT-02 to KNG-TEST-DOPT-INCIDENT-01 because Supervisor requested a closer patrol unit','KNG-TEST-DOPT-REASSIGN-01',null,null);
 if coalesce((v_reassign->>'ok')::boolean,false) is not true then raise exception 'Reassignment command failed: %',v_reassign; end if;
 if v_reassign->>'from_unit_ref'<>'KNG-TEST-DOPT-UNIT-01' or v_reassign->>'to_unit_ref'<>'KNG-TEST-DOPT-UNIT-02' then raise exception 'Reassignment references incorrect: %',v_reassign; end if;
 if (select status from game.incident_deployments where id=v_old_deployment)<>'cancelled'
    or (select cleared_at from game.incident_deployments where id=v_old_deployment) is distinct from v_clock then
   raise exception 'Previous deployment not preserved as cancelled with game-time closure';
 end if;
 select id into v_new_deployment from game.incident_deployments where incident_id=v_incident and unit_id=v_unit2 and cleared_at is null;
 if v_new_deployment is null then raise exception 'Replacement deployment missing'; end if;
 select count(*) into v_new_history from game.deployment_route_history where deployment_id=v_new_deployment;
 if v_new_history<>1 then raise exception 'Replacement deployment route snapshot missing: %',v_new_history; end if;
 if not exists(select 1 from game.dispatch_events where incident_id=v_incident and event_type='unit_reassigned'
   and details->>'direction'='outgoing' and details->>'reason'='Supervisor requested a closer patrol unit') then
   raise exception 'Outgoing reassignment audit event missing';
 end if;
 if not exists(select 1 from game.dispatch_events where incident_id=v_incident and event_type='unit_reassigned'
   and details->>'direction'='incoming' and unit_id=v_unit2) then raise exception 'Incoming reassignment audit event missing'; end if;
 if not exists(select 1 from game.game_events where event_key='dispatch.unit.reassigned.'||replace((v_reassign->>'command_id')::text,'-','')) then
   -- execute_text_command wraps command id in result, so use the recorded command id from result
   if not exists(select 1 from game.game_events where entity_id=v_incident and event_data->>'to_unit_ref'='KNG-TEST-DOPT-UNIT-02') then
     raise exception 'Reassignment game event missing';
   end if;
 end if;
 select current_game_time into v_clock_after from game.simulation_state where id=1;
 if v_clock_after is distinct from v_clock then raise exception 'Reassignment advanced fictional time'; end if;
end
$test$;
rollback;