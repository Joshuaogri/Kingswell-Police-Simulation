
create table game.road_route_calculations (
 id uuid primary key default gen_random_uuid(),
 route_ref text not null unique,
 origin_access_point_id uuid not null references game.property_access_points(id),
 destination_access_point_id uuid not null references game.property_access_points(id),
 origin_junction_id uuid not null references game.road_junctions(id),
 destination_junction_id uuid not null references game.road_junctions(id),
 vehicle_profile text not null check (vehicle_profile in ('public','police','emergency')),
 optimisation text not null check (optimisation in ('fastest','shortest')),
 route_status text not null check (route_status in ('calculated','unreachable')),
 distance_m integer,
 estimated_duration_seconds integer,
 algorithm_version text not null default 'kng-dijkstra-1.0',
 computed_at timestamptz not null default now(),
 check ((route_status='calculated' and distance_m is not null and estimated_duration_seconds is not null) or route_status='unreachable')
);
create table game.road_route_legs (
 id uuid primary key default gen_random_uuid(),
 route_id uuid not null references game.road_route_calculations(id) on delete cascade,
 leg_order integer not null check (leg_order > 0),
 road_segment_id uuid not null references game.road_segments(id),
 from_junction_id uuid not null references game.road_junctions(id),
 to_junction_id uuid not null references game.road_junctions(id),
 distance_m integer not null check (distance_m > 0),
 estimated_duration_seconds integer not null check (estimated_duration_seconds >= 0),
 created_at timestamptz not null default now(),
 unique(route_id,leg_order)
);
create index road_route_calculations_origin_idx on game.road_route_calculations(origin_access_point_id);
create index road_route_calculations_destination_idx on game.road_route_calculations(destination_access_point_id);
create index road_route_legs_segment_idx on game.road_route_legs(road_segment_id);
create index road_route_legs_from_junction_idx on game.road_route_legs(from_junction_id);
create index road_route_legs_to_junction_idx on game.road_route_legs(to_junction_id);
alter table game.road_route_calculations enable row level security;
alter table game.road_route_legs enable row level security;
revoke all on game.road_route_calculations,game.road_route_legs from public,anon,authenticated;
grant all on game.road_route_calculations,game.road_route_legs to service_role;

create or replace function game.calculate_road_route(
 p_origin_access_point_id uuid,
 p_destination_access_point_id uuid,
 p_vehicle_profile text default 'police',
 p_optimisation text default 'fastest'
) returns uuid
language plpgsql
security invoker
set search_path = ''
as $$
declare
 v_nodes uuid[];
 v_dist double precision[];
 v_prev_node integer[];
 v_prev_edge uuid[];
 v_visited boolean[];
 v_n integer;
 v_start integer;
 v_finish integer;
 v_current integer;
 v_neighbour integer;
 v_best double precision;
 v_weight double precision;
 v_candidate double precision;
 v_edge record;
 v_i integer;
 v_j integer;
 v_cursor integer;
 v_rev_edges uuid[] := array[]::uuid[];
 v_route_id uuid;
 v_origin_junction uuid;
 v_destination_junction uuid;
 v_origin_access_profile text;
 v_destination_access_profile text;
 v_distance integer := 0;
 v_duration integer := 0;
 v_leg_order integer := 0;
 v_segment record;
begin
 if p_vehicle_profile not in ('public','police','emergency') then
   raise exception 'Unsupported vehicle profile: %',p_vehicle_profile;
 end if;
 if p_optimisation not in ('fastest','shortest') then
   raise exception 'Unsupported route optimisation: %',p_optimisation;
 end if;

 select ap.nearest_junction_id,ap.access_profile
 into v_origin_junction,v_origin_access_profile
 from game.property_access_points ap
 join game.road_segments rs on rs.id=ap.road_segment_id and rs.is_routable
 where ap.id=p_origin_access_point_id;
 if not found then raise exception 'Origin access point does not exist or has no routable road connection'; end if;

 select ap.nearest_junction_id,ap.access_profile
 into v_destination_junction,v_destination_access_profile
 from game.property_access_points ap
 join game.road_segments rs on rs.id=ap.road_segment_id and rs.is_routable
 where ap.id=p_destination_access_point_id;
 if not found then raise exception 'Destination access point does not exist or has no routable road connection'; end if;

 if p_vehicle_profile='public' and
    (v_origin_access_profile<>'public' or v_destination_access_profile<>'public') then
   raise exception 'Public routing cannot use a controlled service access point';
 end if;

 select array_agg(j.id order by j.junction_code) into v_nodes
 from game.road_junctions j;
 v_n := coalesce(array_length(v_nodes,1),0);
 v_start := array_position(v_nodes,v_origin_junction);
 v_finish := array_position(v_nodes,v_destination_junction);
 if v_start is null or v_finish is null then raise exception 'Route endpoint junction is not in the road graph'; end if;

 v_dist := array_fill('Infinity'::double precision,array[v_n]);
 v_prev_node := array_fill(0,array[v_n]);
 v_prev_edge := array_fill(null::uuid,array[v_n]);
 v_visited := array_fill(false,array[v_n]);
 v_dist[v_start] := 0;

 for v_i in 1..v_n loop
   v_current := 0;
   v_best := 'Infinity'::double precision;
   for v_j in 1..v_n loop
     if not v_visited[v_j] and v_dist[v_j]<v_best then
       v_best:=v_dist[v_j];
       v_current:=v_j;
     end if;
   end loop;
   exit when v_current=0 or v_current=v_finish;
   v_visited[v_current]:=true;

   for v_edge in
     select rs.id,rs.from_junction_id,rs.to_junction_id,rs.segment_length_m,rs.speed_limit_kph,rs.directionality
     from game.road_segments rs
     where rs.is_routable
       and (rs.access_profile='public' or (p_vehicle_profile in ('police','emergency') and rs.access_profile='public_emergency_freight'))
       and (
         rs.from_junction_id=v_nodes[v_current]
         or (rs.to_junction_id=v_nodes[v_current] and rs.directionality='two_way')
         or (rs.to_junction_id=v_nodes[v_current] and rs.directionality='one_way_reverse')
       )
   loop
     if v_edge.from_junction_id=v_nodes[v_current] then
       v_neighbour:=array_position(v_nodes,v_edge.to_junction_id);
     else
       v_neighbour:=array_position(v_nodes,v_edge.from_junction_id);
     end if;
     if v_neighbour is null or v_visited[v_neighbour] then continue; end if;
     if p_optimisation='shortest' then
       v_weight:=v_edge.segment_length_m;
     else
       v_weight:=v_edge.segment_length_m::double precision*3.6/v_edge.speed_limit_kph;
     end if;
     v_candidate:=v_dist[v_current]+v_weight;
     if v_candidate<v_dist[v_neighbour] then
       v_dist[v_neighbour]:=v_candidate;
       v_prev_node[v_neighbour]:=v_current;
       v_prev_edge[v_neighbour]:=v_edge.id;
     end if;
   end loop;
 end loop;

 if v_start<>v_finish and v_prev_node[v_finish]=0 then
   insert into game.road_route_calculations(route_ref,origin_access_point_id,destination_access_point_id,
     origin_junction_id,destination_junction_id,vehicle_profile,optimisation,route_status)
   values ('KNG-ROUTE-'||replace(gen_random_uuid()::text,'-',''),p_origin_access_point_id,p_destination_access_point_id,
     v_origin_junction,v_destination_junction,p_vehicle_profile,p_optimisation,'unreachable')
   returning id into v_route_id;
   return v_route_id;
 end if;

 v_cursor:=v_finish;
 while v_cursor<>v_start loop
   v_rev_edges:=array_append(v_rev_edges,v_prev_edge[v_cursor]);
   v_cursor:=v_prev_node[v_cursor];
   if v_cursor=0 then raise exception 'Route reconstruction failed'; end if;
 end loop;

 insert into game.road_route_calculations(route_ref,origin_access_point_id,destination_access_point_id,
   origin_junction_id,destination_junction_id,vehicle_profile,optimisation,route_status,distance_m,estimated_duration_seconds)
 values ('KNG-ROUTE-'||replace(gen_random_uuid()::text,'-',''),p_origin_access_point_id,p_destination_access_point_id,
   v_origin_junction,v_destination_junction,p_vehicle_profile,p_optimisation,'calculated',0,0)
 returning id into v_route_id;

 v_cursor:=v_start;
 if coalesce(array_length(v_rev_edges,1),0)>0 then
   for v_j in reverse array_length(v_rev_edges,1)..1 loop
     select rs.id,rs.from_junction_id,rs.to_junction_id,rs.segment_length_m,rs.speed_limit_kph
     into v_segment
     from game.road_segments rs where rs.id=v_rev_edges[v_j];
     if v_segment.from_junction_id=v_nodes[v_cursor] then
       v_neighbour:=array_position(v_nodes,v_segment.to_junction_id);
     else
       v_neighbour:=array_position(v_nodes,v_segment.from_junction_id);
     end if;
     v_leg_order:=v_leg_order+1;
     v_duration:=ceil(v_segment.segment_length_m::numeric*3.6/v_segment.speed_limit_kph)::integer;
     insert into game.road_route_legs(route_id,leg_order,road_segment_id,from_junction_id,to_junction_id,distance_m,estimated_duration_seconds)
     values(v_route_id,v_leg_order,v_segment.id,v_nodes[v_cursor],v_nodes[v_neighbour],v_segment.segment_length_m,v_duration);
     v_distance:=v_distance+v_segment.segment_length_m;
     v_duration:=v_duration;
     v_cursor:=v_neighbour;
   end loop;
 end if;

 update game.road_route_calculations
 set distance_m=v_distance,
     estimated_duration_seconds=(select coalesce(sum(l.estimated_duration_seconds),0)::integer from game.road_route_legs l where l.route_id=v_route_id)
 where id=v_route_id;
 return v_route_id;
end;
$$;

revoke all on function game.calculate_road_route(uuid,uuid,text,text) from public,anon,authenticated;
grant execute on function game.calculate_road_route(uuid,uuid,text,text) to service_role;
