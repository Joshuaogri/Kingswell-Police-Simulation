-- Rollback-only integration test for unit position synchronization on arrival.
begin;
do $test$
declare
  v_clock timestamptz := '2026-11-20 08:00:00+00';
  v_property uuid;
  v_unit uuid;
  v_incident uuid;
  v_deployment uuid;
  v_access uuid;
  v_history_count integer;
  v_current_access uuid;
begin
  update game.simulation_state set current_game_time=v_clock,time_paused=true where id=1;
  select p.id into v_property
  from game.properties p
  join game.property_access_points ap on ap.property_id=p.id and ap.is_primary
  join game.road_segments rs on rs.id=ap.road_segment_id and rs.is_routable
  limit 1;
  if v_property is null then raise exception 'No routable fixture property'; end if;
  select ap.id into v_access
  from game.property_access_points ap
  join game.road_segments rs on rs.id=ap.road_segment_id and rs.is_routable
  where ap.property_id=v_property and ap.is_primary;

  insert into game.police_units(unit_ref,unit_name,unit_type,status)
    values('TEST-ARRIVAL-'||substr(gen_random_uuid()::text,1,8),'Arrival trigger test unit','patrol','active')
    returning id into v_unit;
  insert into game.incidents(incident_ref,reported_at,location_property_id,location_description,priority,status,summary)
    values('TEST-ARRIVAL-'||substr(gen_random_uuid()::text,1,8),v_clock,v_property,'Rollback-only trigger test',3,'attending','Arrival trigger regression')
    returning id into v_incident;
  insert into game.incident_deployments(incident_id,unit_id,dispatched_at,status)
    values(v_incident,v_unit,v_clock,'responding') returning id into v_deployment;

  update game.incident_deployments
  set arrived_at=v_clock,status='on_scene'
  where id=v_deployment;

  select current_access_point_id into v_current_access
  from game.police_units where id=v_unit;
  select count(*) into v_history_count
  from game.unit_location_history
  where deployment_id=v_deployment and unit_id=v_unit and source='arrival';

  if v_current_access is distinct from v_access then
    raise exception 'Unit current position did not sync to incident access point';
  end if;
  if v_history_count<>1 then
    raise exception 'Expected exactly one arrival location-history entry, got %',v_history_count;
  end if;
  if (select current_game_time from game.simulation_state where id=1)<>v_clock then
    raise exception 'Fictional clock unexpectedly changed';
  end if;
end
$test$;
rollback;
