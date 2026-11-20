CREATE OR REPLACE FUNCTION game.road_turn_is_permitted(p_incoming_segment_id uuid, p_via_junction_id uuid, p_outgoing_segment_id uuid, p_vehicle_profile text, p_departure_at timestamp with time zone)
 RETURNS boolean
 LANGUAGE sql
 STABLE
 SET search_path TO ''
AS $function$
 select
  p_incoming_segment_id is distinct from p_outgoing_segment_id
  and not exists(
   select 1 from game.road_turn_restrictions r
   where r.incoming_segment_id=p_incoming_segment_id and r.via_junction_id=p_via_junction_id
    and r.outgoing_segment_id=p_outgoing_segment_id and r.active
    and p_vehicle_profile=any(r.vehicle_profiles) and r.restriction_kind='prohibited'
    and (r.valid_from is null or (p_departure_at is not null and p_departure_at>=r.valid_from))
    and (r.valid_until is null or (p_departure_at is not null and p_departure_at<r.valid_until))
  )
  and not exists(
   select 1 from game.road_turn_restrictions only_rule
   where only_rule.incoming_segment_id=p_incoming_segment_id and only_rule.via_junction_id=p_via_junction_id
    and only_rule.active and only_rule.restriction_kind='only'
    and p_vehicle_profile=any(only_rule.vehicle_profiles)
    and (only_rule.valid_from is null or (p_departure_at is not null and p_departure_at>=only_rule.valid_from))
    and (only_rule.valid_until is null or (p_departure_at is not null and p_departure_at<only_rule.valid_until))
    and not exists(
      select 1 from game.road_turn_restrictions allowed
      where allowed.incoming_segment_id=only_rule.incoming_segment_id
       and allowed.via_junction_id=only_rule.via_junction_id
       and allowed.outgoing_segment_id=p_outgoing_segment_id
       and allowed.active and allowed.restriction_kind='only'
       and p_vehicle_profile=any(allowed.vehicle_profiles)
       and (allowed.valid_from is null or (p_departure_at is not null and p_departure_at>=allowed.valid_from))
       and (allowed.valid_until is null or (p_departure_at is not null and p_departure_at<allowed.valid_until))
    )
  );
$function$;

CREATE OR REPLACE FUNCTION game.calculate_road_route(p_origin_access_point_id uuid, p_destination_access_point_id uuid, p_vehicle_profile text, p_optimisation text, p_departure_at timestamp with time zone)
 RETURNS uuid
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
declare
 v_nodes uuid[]; v_seg uuid[]; v_from uuid[]; v_to uuid[];
 v_len integer[]; v_speed integer[]; v_factor double precision[]; v_delay integer[];
 v_n integer; v_start uuid; v_finish uuid; v_origin_profile text; v_dest_profile text;
 v_dist double precision[]; v_prev integer[]; v_seen boolean[];
 v_current integer; v_best double precision; v_candidate double precision;
 v_weight double precision; v_i integer; v_j integer; v_end_state integer:=0;
 v_path integer[]:=array[]::integer[]; v_cursor integer; v_k integer;
 v_route_id uuid; v_total_distance integer:=0; v_total_seconds integer:=0;
 v_duration integer; v_status text;
begin
 if p_vehicle_profile not in ('public','police','emergency') then raise exception 'Unsupported vehicle profile: %',p_vehicle_profile; end if;
 if p_optimisation not in ('fastest','shortest') then raise exception 'Unsupported route optimisation: %',p_optimisation; end if;
 select ap.nearest_junction_id,ap.access_profile into v_start,v_origin_profile
 from game.property_access_points ap join game.road_segments rs on rs.id=ap.road_segment_id
 where ap.id=p_origin_access_point_id and rs.is_routable;
 if not found then raise exception 'Origin access point does not exist or has no routable road connection'; end if;
 select ap.nearest_junction_id,ap.access_profile into v_finish,v_dest_profile
 from game.property_access_points ap join game.road_segments rs on rs.id=ap.road_segment_id
 where ap.id=p_destination_access_point_id and rs.is_routable;
 if not found then raise exception 'Destination access point does not exist or has no routable road connection'; end if;
 if p_vehicle_profile='public' and (v_origin_profile<>'public' or v_dest_profile<>'public') then
  raise exception 'Public routing cannot use a controlled service access point';
 end if;

 with directed as (
  select rs.id seg_id,rs.from_junction_id f,rs.to_junction_id t,rs.segment_length_m metres,rs.speed_limit_kph speed,
   rs.access_profile,rs.segment_code||':F' state_code
  from game.road_segments rs
  where rs.is_routable and rs.directionality in ('two_way','one_way_forward')
  union all
  select rs.id,rs.to_junction_id,rs.from_junction_id,rs.segment_length_m,rs.speed_limit_kph,
   rs.access_profile,rs.segment_code||':R'
  from game.road_segments rs
  where rs.is_routable and rs.directionality in ('two_way','one_way_reverse')
 ), usable as (
  select d.*,
   case when p_departure_at is null then 1::double precision else coalesce((
    select exp(sum(ln(tp.speed_multiplier))) from game.road_segment_traffic_profiles tp
    where tp.road_segment_id=d.seg_id and tp.active and p_vehicle_profile=any(tp.applies_to)
     and extract(isodow from p_departure_at)::smallint=any(tp.day_of_week)
     and (p_departure_at::time>=tp.starts_at and p_departure_at::time<tp.ends_at)
   ),1)::double precision end traffic_factor,
   case when p_departure_at is null then 0 else
    coalesce((select sum(tp.fixed_delay_seconds)::integer from game.road_segment_traffic_profiles tp
     where tp.road_segment_id=d.seg_id and tp.active and p_vehicle_profile=any(tp.applies_to)
      and extract(isodow from p_departure_at)::smallint=any(tp.day_of_week)
      and p_departure_at::time>=tp.starts_at and p_departure_at::time<tp.ends_at),0)
    +coalesce((select sum(c.delay_seconds)::integer from game.road_segment_conditions c
     where c.road_segment_id=d.seg_id and c.active and p_departure_at>=c.starts_at
      and (c.ends_at is null or p_departure_at<c.ends_at)),0)
   end delay_s
  from directed d
  where (d.access_profile='public' or (p_vehicle_profile in ('police','emergency') and d.access_profile='public_emergency_freight'))
   and not exists(select 1 from game.road_segment_conditions c
    where c.road_segment_id=d.seg_id and c.active and c.is_closed and p_departure_at is not null
     and p_departure_at>=c.starts_at and (c.ends_at is null or p_departure_at<c.ends_at)
     and (cardinality(c.closed_to_profiles)=0 or p_vehicle_profile=any(c.closed_to_profiles))
     and not (c.emergency_override and p_vehicle_profile in ('police','emergency')))
 )
 select array_agg(seg_id order by state_code),array_agg(f order by state_code),array_agg(t order by state_code),
  array_agg(metres order by state_code),array_agg(speed order by state_code),
  array_agg(traffic_factor order by state_code),array_agg(delay_s order by state_code)
 into v_seg,v_from,v_to,v_len,v_speed,v_factor,v_delay from usable;

 v_n:=coalesce(array_length(v_seg,1),0);
 if v_n=0 then
  insert into game.road_route_calculations(route_ref,origin_access_point_id,destination_access_point_id,origin_junction_id,destination_junction_id,
   vehicle_profile,optimisation,route_status,algorithm_version)
  values('KNG-ROUTE-'||replace(gen_random_uuid()::text,'-',''),p_origin_access_point_id,p_destination_access_point_id,
   v_start,v_finish,p_vehicle_profile,p_optimisation,'unreachable','kng-turn-traffic-dijkstra-2.0') returning id into v_route_id;
  return v_route_id;
 end if;

 v_dist:=array_fill('Infinity'::double precision,array[v_n]);
 v_prev:=array_fill(0,array[v_n]); v_seen:=array_fill(false,array[v_n]);
 for v_i in 1..v_n loop
  if v_from[v_i]=v_start then
   v_weight:=case when p_optimisation='shortest' then v_len[v_i]::double precision
    else v_len[v_i]::double precision*3.6/(v_speed[v_i]*v_factor[v_i])+v_delay[v_i] end;
   v_dist[v_i]:=v_weight;
  end if;
 end loop;

 if v_start=v_finish then v_end_state:=0; else
  for v_i in 1..v_n loop
   v_current:=0;v_best:='Infinity'::double precision;
   for v_j in 1..v_n loop
    if not v_seen[v_j] and v_dist[v_j]<v_best then v_best:=v_dist[v_j];v_current:=v_j; end if;
   end loop;
   exit when v_current=0;
   if v_to[v_current]=v_finish then v_end_state:=v_current;exit;end if;
   v_seen[v_current]:=true;
   for v_j in 1..v_n loop
    if v_seen[v_j] or v_from[v_j]<>v_to[v_current] then continue;end if;
    if not game.road_turn_is_permitted(v_seg[v_current],v_to[v_current],v_seg[v_j],p_vehicle_profile,p_departure_at) then continue;end if;
    v_weight:=case when p_optimisation='shortest' then v_len[v_j]::double precision
     else v_len[v_j]::double precision*3.6/(v_speed[v_j]*v_factor[v_j])+v_delay[v_j] end;
    v_candidate:=v_dist[v_current]+v_weight;
    if v_candidate<v_dist[v_j] then v_dist[v_j]:=v_candidate;v_prev[v_j]:=v_current;end if;
   end loop;
  end loop;
 end if;

 if v_start<>v_finish and v_end_state=0 then
  insert into game.road_route_calculations(route_ref,origin_access_point_id,destination_access_point_id,origin_junction_id,destination_junction_id,
   vehicle_profile,optimisation,route_status,algorithm_version)
  values('KNG-ROUTE-'||replace(gen_random_uuid()::text,'-',''),p_origin_access_point_id,p_destination_access_point_id,
   v_start,v_finish,p_vehicle_profile,p_optimisation,'unreachable','kng-turn-traffic-dijkstra-2.0') returning id into v_route_id;
  return v_route_id;
 end if;

 if v_end_state>0 then
  v_cursor:=v_end_state;
  while v_cursor>0 loop v_path:=array_append(v_path,v_cursor);v_cursor:=v_prev[v_cursor];end loop;
 end if;

 insert into game.road_route_calculations(route_ref,origin_access_point_id,destination_access_point_id,origin_junction_id,destination_junction_id,
  vehicle_profile,optimisation,route_status,distance_m,estimated_duration_seconds,algorithm_version)
 values('KNG-ROUTE-'||replace(gen_random_uuid()::text,'-',''),p_origin_access_point_id,p_destination_access_point_id,
  v_start,v_finish,p_vehicle_profile,p_optimisation,'calculated',0,0,'kng-turn-traffic-dijkstra-2.0') returning id into v_route_id;

 for v_k in reverse coalesce(array_length(v_path,1),0)..1 loop
  v_i:=v_path[v_k];
  v_duration:=ceil(v_len[v_i]::numeric*3.6/(v_speed[v_i]*v_factor[v_i]))::integer+v_delay[v_i];
  insert into game.road_route_legs(route_id,leg_order,road_segment_id,from_junction_id,to_junction_id,distance_m,estimated_duration_seconds)
  values(v_route_id,coalesce(array_length(v_path,1),0)-v_k+1,v_seg[v_i],v_from[v_i],v_to[v_i],v_len[v_i],v_duration);
  v_total_distance:=v_total_distance+v_len[v_i];v_total_seconds:=v_total_seconds+v_duration;
 end loop;
 update game.road_route_calculations set distance_m=v_total_distance,estimated_duration_seconds=v_total_seconds where id=v_route_id;
 return v_route_id;
end;
$function$;

CREATE OR REPLACE FUNCTION game.calculate_road_route(p_origin_access_point_id uuid, p_destination_access_point_id uuid, p_vehicle_profile text DEFAULT 'police'::text, p_optimisation text DEFAULT 'fastest'::text)
 RETURNS uuid
 LANGUAGE sql
 SET search_path TO ''
AS $function$ select game.calculate_road_route(p_origin_access_point_id,p_destination_access_point_id,p_vehicle_profile,p_optimisation,null::timestamptz); $function$;

CREATE OR REPLACE FUNCTION game.snapshot_deployment_route()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
declare
  v_clock timestamptz;
  v_origin uuid;
  v_destination uuid;
  v_route uuid;
  v_status text := 'location_unresolved';
  v_distance integer;
  v_seconds integer;
  v_eta timestamptz;
  v_basis text := 'No routable origin or incident property access point is recorded.';
begin
  select s.current_game_time into v_clock
  from game.simulation_state s where s.id=1;

  select coalesce(u.current_access_point_id,pf.access_point_id)
    into v_origin
  from game.police_units u
  left join game.police_facilities pf on pf.id=u.base_facility_id
  where u.id=new.unit_id;

  select ap.id into v_destination
  from game.incidents i
  join game.property_access_points ap on ap.property_id=i.location_property_id and ap.is_primary
  join game.road_segments rs on rs.id=ap.road_segment_id and rs.is_routable
  where i.id=new.incident_id
  order by ap.created_at
  limit 1;

  if v_origin is not null and v_destination is not null then
    begin
      v_route:=game.calculate_road_route(v_origin,v_destination,'police','fastest',v_clock);
      select r.route_status,r.distance_m,r.estimated_duration_seconds
        into v_status,v_distance,v_seconds
      from game.road_route_calculations r where r.id=v_route;
      if v_status='calculated' then
        v_eta:=v_clock+make_interval(secs=>v_seconds);
        v_basis:='Fictional-clock route estimate using authored peak traffic, active road conditions, turn restrictions and access rules; no siren-speed uplift.';
      else
        v_basis:='No connected route exists in the current routable road graph.';
      end if;
    exception when others then
      v_route:=null;
      v_status:='location_unresolved';
      v_basis:='Route calculation unavailable: '||sqlerrm;
    end;
  end if;

  update game.incident_deployments
  set route_calculation_id=v_route,
      route_origin_access_point_id=v_origin,
      route_destination_access_point_id=v_destination,
      route_status=v_status,
      route_distance_m=v_distance,
      route_estimated_seconds=v_seconds,
      estimated_arrival_at=v_eta,
      route_basis=v_basis,
      route_computed_at=coalesce(v_clock,now())
  where id=new.id;

  insert into game.deployment_route_history(
    deployment_id,route_calculation_id,event_type,origin_access_point_id,
    destination_access_point_id,route_status,distance_m,
    estimated_duration_seconds,estimated_arrival_at,basis,details
  ) values (
    new.id,v_route,'initial_route',v_origin,v_destination,v_status,
    v_distance,v_seconds,v_eta,v_basis,
    jsonb_build_object('unit_id',new.unit_id,'incident_id',new.incident_id,
      'clock_time',v_clock,'origin_source',case when v_origin is null then 'missing'
        when exists(select 1 from game.police_units u where u.id=new.unit_id and u.current_access_point_id=v_origin)
        then 'unit_current_position' else 'unit_base_facility' end)
  );

  return null;
end;
$function$;

CREATE OR REPLACE FUNCTION game.get_dispatch_candidates(p_incident_ref text)
 RETURNS TABLE(unit_ref text, unit_name text, base_facility text, eligible_personnel_count integer, personnel_refs text[], route_status text, route_ref text, distance_m integer, estimated_duration_seconds integer, estimated_arrival_at timestamp with time zone, route_basis text)
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
declare
  v_clock timestamptz;
  v_incident_id uuid;
  v_destination uuid;
  v_unit record;
  v_origin uuid;
  v_route uuid;
  v_route_status text;
  v_distance integer;
  v_seconds integer;
  v_eta timestamptz;
  v_refs text[];
  v_count integer;
  v_facility text;
  v_basis text;
begin
  select s.current_game_time into v_clock from game.simulation_state s where s.id=1;
  if v_clock is null then raise exception 'The fictional game clock is not initialized.'; end if;

  select i.id into v_incident_id
  from game.incidents i
  where i.incident_ref=p_incident_ref and i.status in ('new','graded','queued');
  if v_incident_id is null then raise exception 'Incident not found or not dispatchable.'; end if;

  if exists(select 1 from game.incident_deployments d
    where d.incident_id=v_incident_id and d.cleared_at is null
      and d.status not in ('cleared','cancelled','completed')) then
    raise exception 'Incident already has an active deployment.';
  end if;

  select ap.id into v_destination
  from game.incidents i
  join game.property_access_points ap on ap.property_id=i.location_property_id and ap.is_primary
  join game.road_segments rs on rs.id=ap.road_segment_id and rs.is_routable
  where i.id=v_incident_id
  order by ap.created_at limit 1;

  for v_unit in
    select u.id,u.unit_ref,u.unit_name,u.base_facility_id,u.current_access_point_id,
      pf.access_point_id,pf.facility_name
    from game.police_units u
    left join game.police_facilities pf on pf.id=u.base_facility_id
    where u.status='active'
      and exists (
        select 1 from game.duty_rosters dr
        join game.duty_assignments da on da.roster_id=dr.id
        join game.police_personnel pp on pp.id=da.personnel_id
        where dr.unit_id=u.id and dr.status='active'
          and dr.starts_at<=v_clock and dr.ends_at>v_clock
          and da.status in ('assigned','on_duty')
          and da.starts_at<=v_clock and da.ends_at>v_clock
          and pp.employment_status='active'
          and not exists (
            select 1 from game.incident_deployments prior
            where prior.personnel_id=pp.id and prior.cleared_at is null
              and prior.status not in ('cleared','cancelled','completed')
          )
      )
    order by u.unit_ref
  loop
    select array_agg(q.personnel_ref order by q.personnel_ref),count(*)::integer
      into v_refs,v_count
    from (
      select distinct pp.personnel_ref
      from game.duty_rosters dr
      join game.duty_assignments da on da.roster_id=dr.id
      join game.police_personnel pp on pp.id=da.personnel_id
      where dr.unit_id=v_unit.id and dr.status='active'
        and dr.starts_at<=v_clock and dr.ends_at>v_clock
        and da.status in ('assigned','on_duty')
        and da.starts_at<=v_clock and da.ends_at>v_clock
        and pp.employment_status='active'
        and not exists (
          select 1 from game.incident_deployments prior
          where prior.personnel_id=pp.id and prior.cleared_at is null
            and prior.status not in ('cleared','cancelled','completed')
        )
    ) q;

    v_origin:=coalesce(v_unit.current_access_point_id,v_unit.access_point_id);
    v_route:=null; v_route_status:='location_unresolved';
    v_distance:=null; v_seconds:=null; v_eta:=null;
    v_basis:='No routable unit origin or incident property access point is recorded.';
    v_facility:=v_unit.facility_name;

    if v_origin is not null and v_destination is not null then
      begin
        v_route:=game.calculate_road_route(v_origin,v_destination,'police','fastest',v_clock);
        select r.route_status,r.distance_m,r.estimated_duration_seconds
          into v_route_status,v_distance,v_seconds
        from game.road_route_calculations r where r.id=v_route;
        if v_route_status='calculated' then
          v_eta:=v_clock+make_interval(secs=>v_seconds);
          v_basis:='Fictional-clock route estimate using authored peak traffic, active road conditions, turn restrictions and access rules; no siren-speed uplift.';
        else
          v_basis:='No connected route exists in the current routable road graph.';
        end if;
      exception when others then
        v_route:=null; v_route_status:='location_unresolved';
        v_basis:='Route calculation unavailable: '||sqlerrm;
      end;
    end if;

    unit_ref:=v_unit.unit_ref; unit_name:=v_unit.unit_name;
    base_facility:=v_facility; eligible_personnel_count:=v_count;
    personnel_refs:=v_refs; route_status:=v_route_status;
    select r.route_ref into route_ref from game.road_route_calculations r where r.id=v_route;
    distance_m:=v_distance; estimated_duration_seconds:=v_seconds;
    estimated_arrival_at:=v_eta; route_basis:=v_basis;
    return next;
  end loop;
end;
$function$;

revoke all on function game.road_turn_is_permitted(uuid,uuid,uuid,text,timestamptz) from public,anon,authenticated;
grant execute on function game.road_turn_is_permitted(uuid,uuid,uuid,text,timestamptz) to service_role;
revoke all on function game.calculate_road_route(uuid,uuid,text,text,timestamptz) from public,anon,authenticated;
revoke all on function game.calculate_road_route(uuid,uuid,text,text) from public,anon,authenticated;
grant execute on function game.calculate_road_route(uuid,uuid,text,text,timestamptz) to service_role;
grant execute on function game.calculate_road_route(uuid,uuid,text,text) to service_role;
revoke all on function game.snapshot_deployment_route() from public,anon,authenticated;
revoke all on function game.get_dispatch_candidates(text) from public,anon,authenticated;
grant execute on function game.get_dispatch_candidates(text) to service_role;
