-- Rollback-only test: state transitions and out-of-service dispatch guard.
begin;
do $test$
declare
 v_clock timestamptz:='2026-11-20 13:00:00+00';
 v_facility uuid; v_property uuid; v_unit uuid; v_incident uuid; v_deployment uuid;
 v_state text; v_history integer; v_access uuid; v_rejected boolean:=false;
begin
 update game.simulation_state set current_game_time=v_clock,time_paused=true where id=1;
 select pf.id into v_facility from game.police_facilities pf where pf.status='active' order by pf.facility_ref limit 1;
 select p.id,ap.id into v_property,v_access from game.properties p
 join game.property_access_points ap on ap.property_id=p.id and ap.is_primary
 join game.road_segments rs on rs.id=ap.road_segment_id and rs.is_routable
 where p.status='active' order by p.property_ref limit 1;
 insert into game.police_units(unit_ref,unit_name,unit_type,status,base_facility_id)
 values('KNG-TEST-STATE-'||substr(gen_random_uuid()::text,1,8),'Operational state test','patrol','active',v_facility)
 returning id into v_unit;
 select operational_state into v_state from game.police_units where id=v_unit;
 if v_state<>'at_station' then raise exception 'Unexpected initial state %',v_state; end if;
 perform game.set_unit_operational_state((select unit_ref from game.police_units where id=v_unit),'on_patrol','Begin test patrol');
 insert into game.incidents(incident_ref,reported_at,location_property_id,location_description,priority,status,summary)
 values('KNG-TEST-STATE-'||substr(gen_random_uuid()::text,1,8),v_clock,v_property,'State lifecycle test',3,'attending','Operational state lifecycle test')
 returning id into v_incident;
 insert into game.incident_deployments(incident_id,unit_id,dispatched_at,status)
 values(v_incident,v_unit,v_clock,'responding') returning id into v_deployment;
 select operational_state into v_state from game.police_units where id=v_unit;
 if v_state<>'responding' then raise exception 'Dispatch did not set responding state: %',v_state; end if;
 update game.incident_deployments set arrived_at=v_clock,status='on_scene' where id=v_deployment;
 select operational_state into v_state from game.police_units where id=v_unit;
 if v_state<>'on_scene' then raise exception 'Arrival did not set on_scene state: %',v_state; end if;
 update game.incident_deployments set cleared_at=v_clock,status='cleared' where id=v_deployment;
 select operational_state into v_state from game.police_units where id=v_unit;
 if v_state<>'returning' then raise exception 'Clear did not set returning state: %',v_state; end if;
 perform game.set_unit_operational_state((select unit_ref from game.police_units where id=v_unit),'at_station','Returned to base after incident');
 perform game.set_unit_operational_state((select unit_ref from game.police_units where id=v_unit),'out_of_service','Temporary vehicle maintenance');
 begin
   insert into game.incidents(incident_ref,reported_at,location_property_id,location_description,priority,status,summary)
   values('KNG-TEST-GUARD-'||substr(gen_random_uuid()::text,1,8),v_clock,v_property,'Guard test',3,'new','Out-of-service guard')
   returning id into v_incident;
   insert into game.incident_deployments(incident_id,unit_id,dispatched_at,status)
   values(v_incident,v_unit,v_clock,'responding');
 exception when others then
   if sqlerrm not like '%out of service%' then raise; end if;
   v_rejected:=true;
 end;
 if not v_rejected then raise exception 'Out-of-service unit accepted deployment'; end if;
 select count(*) into v_history from game.unit_operational_state_history where unit_id=v_unit;
 if v_history<5 then raise exception 'Expected at least five state history records, got %',v_history; end if;
 if (select current_game_time from game.simulation_state where id=1) is distinct from v_clock then raise exception 'Fictional clock unexpectedly advanced'; end if;
end
$test$;
rollback;