-- ETA-ranked dispatch, explicit unit position updates, and route recalculation.
create or replace function game.get_dispatch_candidates_ranked(p_incident_ref text)
returns table (
  unit_ref text, unit_name text, base_facility text,
  eligible_personnel_count integer, personnel_refs text[],
  route_status text, route_ref text, distance_m integer,
  estimated_duration_seconds integer, estimated_arrival_at timestamptz,
  route_basis text
)
language sql volatile set search_path = ''
as $function$
  select c.unit_ref,c.unit_name,c.base_facility,c.eligible_personnel_count,
         c.personnel_refs,c.route_status,c.route_ref,c.distance_m,
         c.estimated_duration_seconds,c.estimated_arrival_at,c.route_basis
  from game.get_dispatch_candidates(p_incident_ref) c
  order by c.estimated_arrival_at asc nulls last,
           c.estimated_duration_seconds asc nulls last,
           c.distance_m asc nulls last, c.unit_ref asc
$function$;

create or replace function game.recalculate_deployment_route(
  p_deployment_id uuid, p_reason text, p_event_type text default 'route_recalculated'
)
returns jsonb language plpgsql volatile set search_path = ''
as $function$
declare
  v_deployment game.incident_deployments%rowtype;
  v_clock timestamptz; v_origin uuid; v_destination uuid; v_route uuid;
  v_status text := 'location_unresolved'; v_distance integer; v_seconds integer;
  v_eta timestamptz; v_basis text; v_history_type text;
begin
  if p_reason is null or length(btrim(p_reason))=0 then raise exception 'A route recalculation reason is required'; end if;
  if p_event_type not in ('route_recalculated','route_unavailable') then raise exception 'Unsupported route history event type'; end if;
  select * into v_deployment from game.incident_deployments where id=p_deployment_id for update;
  if not found then raise exception 'Deployment not found'; end if;
  if v_deployment.cleared_at is not null or v_deployment.status in ('cleared','cancelled','completed') then
    raise exception 'Cannot recalculate route for an inactive deployment';
  end if;
  select s.current_game_time into v_clock from game.simulation_state s where s.id=1;
  if v_clock is null then raise exception 'The fictional game clock is not initialized'; end if;
  select coalesce(u.current_access_point_id,pf.access_point_id) into v_origin
  from game.police_units u left join game.police_facilities pf on pf.id=u.base_facility_id
  where u.id=v_deployment.unit_id;
  select ap.id into v_destination from game.incidents i
  join game.property_access_points ap on ap.property_id=i.location_property_id and ap.is_primary
  join game.road_segments rs on rs.id=ap.road_segment_id and rs.is_routable
  where i.id=v_deployment.incident_id order by ap.created_at limit 1;
  if v_origin is not null and v_destination is not null then
    begin
      v_route:=game.calculate_road_route(v_origin,v_destination,'police','fastest');
      select r.route_status,r.distance_m,r.estimated_duration_seconds into v_status,v_distance,v_seconds
      from game.road_route_calculations r where r.id=v_route;
      if v_status='calculated' then
        v_eta:=v_clock+make_interval(secs=>v_seconds);
        v_basis:='Baseline posted-speed estimate; no live traffic, siren uplift or turn-delay model.';
        v_history_type:='route_recalculated';
      else
        v_basis:='No connected route exists in the current routable road graph.';
        v_history_type:='route_unavailable';
      end if;
    exception when others then
      v_route:=null; v_status:='location_unresolved';
      v_basis:='Route calculation unavailable: '||sqlerrm; v_history_type:='route_unavailable';
    end;
  else
    v_basis:='A current unit position/base access point or incident access point is unavailable.';
    v_history_type:='route_unavailable';
  end if;
  update game.incident_deployments set route_calculation_id=v_route,
    route_origin_access_point_id=v_origin,route_destination_access_point_id=v_destination,
    route_status=v_status,route_distance_m=v_distance,route_estimated_seconds=v_seconds,
    estimated_arrival_at=v_eta,route_basis=v_basis,route_computed_at=v_clock
  where id=p_deployment_id;
  insert into game.deployment_route_history(
    deployment_id,route_calculation_id,event_type,origin_access_point_id,
    destination_access_point_id,route_status,distance_m,estimated_duration_seconds,
    estimated_arrival_at,basis,details
  ) values (
    p_deployment_id,v_route,v_history_type,v_origin,v_destination,v_status,
    v_distance,v_seconds,v_eta,v_basis,
    jsonb_build_object('reason',p_reason,'recorded_game_time',v_clock,
      'unit_id',v_deployment.unit_id,'incident_id',v_deployment.incident_id)
  );
  return jsonb_build_object('deployment_id',p_deployment_id,'route_status',v_status,
    'route_calculation_id',v_route,'distance_m',v_distance,
    'estimated_duration_seconds',v_seconds,'estimated_arrival_at',v_eta,'history_event',v_history_type);
end;
$function$;

create or replace function game.record_unit_position(p_unit_ref text,p_access_point_id uuid,p_reason text)
returns jsonb language plpgsql volatile set search_path = ''
as $function$
declare
  v_unit_id uuid; v_clock timestamptz; v_deployment_id uuid;
  v_updates integer:=0; v_recalculations jsonb:='[]'::jsonb; v_result jsonb;
begin
  if p_reason is null or length(btrim(p_reason))=0 then raise exception 'A position update reason is required'; end if;
  select s.current_game_time into v_clock from game.simulation_state s where s.id=1;
  if v_clock is null then raise exception 'The fictional game clock is not initialized'; end if;
  if not exists(select 1 from game.property_access_points ap
    join game.road_segments rs on rs.id=ap.road_segment_id and rs.is_routable where ap.id=p_access_point_id) then
    raise exception 'Position must resolve to a registered access point on a routable road';
  end if;
  update game.police_units set current_access_point_id=p_access_point_id,current_location_updated_at=v_clock
  where unit_ref=p_unit_ref and status='active' returning id into v_unit_id;
  if v_unit_id is null then raise exception 'Active police unit not found'; end if;
  for v_deployment_id in select d.id from game.incident_deployments d
    where d.unit_id=v_unit_id and d.cleared_at is null
      and d.status not in ('cleared','cancelled','completed') order by d.dispatched_at,d.id
  loop
    v_result:=game.recalculate_deployment_route(v_deployment_id,
      'Unit position updated: '||btrim(p_reason),'route_recalculated');
    v_recalculations:=v_recalculations||jsonb_build_array(v_result); v_updates:=v_updates+1;
  end loop;
  return jsonb_build_object('unit_ref',p_unit_ref,'current_access_point_id',p_access_point_id,
    'recorded_at_game_time',v_clock,'active_deployments_recalculated',v_updates,'recalculations',v_recalculations);
end;
$function$;

create or replace function game.recalculate_routes_after_road_change()
returns trigger language plpgsql volatile set search_path = ''
as $function$
declare v_deployment_id uuid;
begin
  for v_deployment_id in select d.id from game.incident_deployments d
    where d.cleared_at is null and d.status not in ('cleared','cancelled','completed')
    order by d.id
  loop
    perform game.recalculate_deployment_route(v_deployment_id,
      'Road segment '||new.segment_code||case when new.is_routable then ' reopened' else ' closed' end,
      'route_recalculated');
  end loop;
  return new;
end;
$function$;

drop trigger if exists road_segment_route_recalculation on game.road_segments;
create trigger road_segment_route_recalculation
after update of is_routable on game.road_segments
for each row when (old.is_routable is distinct from new.is_routable)
execute function game.recalculate_routes_after_road_change();

revoke all on function game.get_dispatch_candidates_ranked(text) from public,anon,authenticated;
grant execute on function game.get_dispatch_candidates_ranked(text) to service_role;
revoke all on function game.recalculate_deployment_route(uuid,text,text) from public,anon,authenticated;
grant execute on function game.recalculate_deployment_route(uuid,text,text) to service_role;
revoke all on function game.record_unit_position(text,uuid,text) from public,anon,authenticated;
grant execute on function game.record_unit_position(text,uuid,text) to service_role;
revoke all on function game.recalculate_routes_after_road_change() from public,anon,authenticated,service_role;
