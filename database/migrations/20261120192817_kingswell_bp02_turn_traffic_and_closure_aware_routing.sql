-- BP-02 turn-aware, time-aware routing engine v2.
create or replace function game.road_turn_is_permitted(
 p_incoming_segment_id uuid,p_via_junction_id uuid,p_outgoing_segment_id uuid,
 p_vehicle_profile text,p_departure_at timestamptz
) returns boolean
language sql stable security invoker set search_path=''
as $$
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
$$;
revoke all on function game.road_turn_is_permitted(uuid,uuid,uuid,text,timestamptz) from public,anon,authenticated;
grant execute on function game.road_turn_is_permitted(uuid,uuid,uuid,text,timestamptz) to service_role;

create or replace function game.calculate_road_route(
 p_origin_access_point_id uuid,p_destination_access_point_id uuid,
 p_vehicle_profile text,p_optimisation text,p_departure_at timestamptz
) returns uuid
language plpgsql security invoker set search_path=''
as $$
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
$$;

-- Preserve the established four-argument gameplay interface; it uses baseline conditions until
-- the simulation clock is supplied by the runtime.
create or replace function game.calculate_road_route(
 p_origin_access_point_id uuid,p_destination_access_point_id uuid,
 p_vehicle_profile text default 'police',p_optimisation text default 'fastest'
) returns uuid
language sql security invoker set search_path=''
as $$ select game.calculate_road_route(p_origin_access_point_id,p_destination_access_point_id,p_vehicle_profile,p_optimisation,null::timestamptz); $$;

revoke all on function game.calculate_road_route(uuid,uuid,text,text,timestamptz) from public,anon,authenticated;
revoke all on function game.calculate_road_route(uuid,uuid,text,text) from public,anon,authenticated;
grant execute on function game.calculate_road_route(uuid,uuid,text,text,timestamptz) to service_role;
grant execute on function game.calculate_road_route(uuid,uuid,text,text) to service_role;
