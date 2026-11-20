-- BP-02 detailed street atlas v0.3 regression. All fixture writes roll back.
begin;
do $$
declare
 v_city uuid;v_origin uuid;v_dest uuid;v_base uuid;v_peak uuid;v_closed_route uuid;v_closed_seg uuid;
 v_in uuid;v_via uuid;v_out1 uuid;v_out2 uuid;v_ref text;v_now timestamptz:=now();
 v_base_seconds integer;v_peak_seconds integer;v_count integer;v_clock timestamptz;
begin
 select id into v_city from game.cities where code='KNG';
 if (select count(*) from game.roads where city_id=v_city)<>75 then raise exception 'Expected 75 named roads';end if;
 if (select count(distinct name) from game.roads where city_id=v_city)<>75 then raise exception 'Road names must be unique';end if;
 if exists(select 1 from game.roads r where r.city_id=v_city and not exists(select 1 from game.road_segments s where s.road_id=r.id)) then raise exception 'A named road has no road segment';end if;
 if (select count(*) from game.road_junctions where city_id=v_city)<>157 then raise exception 'Expected 157 junctions';end if;
 if exists(select 1 from game.road_junctions where city_id=v_city and (x_m<0 or x_m>20000 or y_m<0 or y_m>16000)) then raise exception 'Junction outside city grid';end if;
 if (select count(*) from game.road_segments where city_id=v_city)<>229 then raise exception 'Expected 229 road segments';end if;
 if exists(select 1 from game.road_segments where city_id=v_city and (geometry_local_m is null or jsonb_array_length(geometry_local_m)<>4 or carriageway_width_m is null)) then raise exception 'Road geometry or carriageway profile missing';end if;
 if exists(select 1 from game.road_segments s join game.road_junctions a on a.id=s.from_junction_id join game.road_junctions b on b.id=s.to_junction_id
  where s.city_id=v_city and ((s.geometry_local_m->0->>0)::integer<>a.x_m or (s.geometry_local_m->0->>1)::integer<>a.y_m
   or (s.geometry_local_m->3->>0)::integer<>b.x_m or (s.geometry_local_m->3->>1)::integer<>b.y_m)) then raise exception 'Road geometry endpoints do not match graph junctions';end if;
 if (select count(*) from game.road_segments where city_id=v_city and directionality='one_way_forward' and segment_code like 'N-%')<>96 then raise exception 'Expected 96 one-way neighbourhood loop segments';end if;
 if (select count(*) from game.roads where city_id=v_city and road_type='service')<>24 then raise exception 'Expected 24 named rear service lanes';end if;
 if (select count(*) from game.road_segments where city_id=v_city and road_class='service_lane')<>48 then raise exception 'Expected 48 service-lane segments';end if;
 if (select count(*) from game.road_segments where city_id=v_city and crossing_type='bridge')<>3 then raise exception 'Expected three mapped bridge deck segments';end if;
 if (select count(*) from game.property_access_points where access_ref like '%-SEC')<>480 then raise exception 'Expected 480 secondary property entrances';end if;
 if (select count(*) from game.property_access_points ap join game.properties p on p.id=ap.property_id where p.city_id=v_city)<>1136 then raise exception 'Expected 1,136 primary and secondary entrances';end if;
 if (select count(*) from game.road_segment_traffic_profiles where road_segment_id in(select id from game.road_segments where city_id=v_city))<>458 then raise exception 'Traffic profiles missing from road segments';end if;
 if (select count(*) from game.road_turn_restrictions where restriction_ref like 'KNG-NOUTURN-%')<>266 then raise exception 'No-U-turn controls incomplete';end if;
 if (select count(*) from game.road_turn_restrictions where restriction_ref like 'KNG-TURN-%')<>16 then raise exception 'Signalised no-left/no-right movement bans incomplete';end if;
 if (select count(*) from game.road_turn_restrictions where restriction_ref like 'KNG-TURN-%' and turn_type in ('no_left','no_right') and vehicle_profiles=array['public']::text[])<>16 then raise exception 'Signalised turn-ban profiles are invalid';end if;
 if exists(select 1 from game.road_segments s where s.city_id=v_city and not exists(select 1 from game.patrol_beat_road_segments b where b.road_segment_id=s.id)) then raise exception 'Road segment omitted from patrol beat coverage';end if;
 if exists(select 1 from game.road_segments where city_id=v_city and not is_routable) then raise exception 'Unexpected non-routable segment in baseline street atlas';end if;
 with recursive reachable(id) as (
  select id from game.road_junctions where city_id=v_city and junction_code='J001'
  union
  select case when s.from_junction_id=r.id then s.to_junction_id else s.from_junction_id end
  from game.road_segments s join reachable r on s.from_junction_id=r.id or s.to_junction_id=r.id
  where s.city_id=v_city and s.is_routable
 ) select count(*) into v_count from reachable;
 if v_count<>157 then raise exception 'Undirected street graph not connected: % of 157 junctions',v_count;end if;
 if (select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='game' and c.relname in ('road_turn_restrictions','road_segment_traffic_profiles','road_segment_conditions') and c.relrowsecurity)<>3 then raise exception 'RLS missing on road operations tables';end if;

 -- Turn prohibitions and "only" restrictions must be vehicle-aware.
 select s.id,s.to_junction_id into v_in,v_via from game.road_segments s where s.city_id=v_city limit 1;
 select id into v_out1 from game.road_segments where city_id=v_city and id<>v_in and (from_junction_id=v_via or to_junction_id=v_via) order by segment_code limit 1;
 select id into v_out2 from game.road_segments where city_id=v_city and id not in(v_in,v_out1) and (from_junction_id=v_via or to_junction_id=v_via) order by segment_code limit 1;
 if v_out1 is not null then
  insert into game.road_turn_restrictions(restriction_ref,city_id,incoming_segment_id,via_junction_id,outgoing_segment_id,restriction_kind,turn_type,vehicle_profiles,reason)
  values('TEST-TURN-PROHIBIT-'||replace(gen_random_uuid()::text,'-',''),v_city,v_in,v_via,v_out1,'prohibited','no_left',array['public']::text[],'Rollback-only turn test');
  if game.road_turn_is_permitted(v_in,v_via,v_out1,'public',v_now) then raise exception 'Prohibited turn was permitted';end if;
  if not game.road_turn_is_permitted(v_in,v_via,v_out1,'emergency',v_now) then raise exception 'Vehicle-specific restriction leaked to emergency';end if;
 end if;
 delete from game.road_turn_restrictions where restriction_ref like 'TEST-TURN-PROHIBIT-%';
 if v_out1 is not null and v_out2 is not null then
  insert into game.road_turn_restrictions(restriction_ref,city_id,incoming_segment_id,via_junction_id,outgoing_segment_id,restriction_kind,turn_type,vehicle_profiles,reason)
  values('TEST-TURN-ONLY-'||replace(gen_random_uuid()::text,'-',''),v_city,v_in,v_via,v_out1,'only','only_straight',array['public']::text[],'Rollback-only only-turn test');
  if not game.road_turn_is_permitted(v_in,v_via,v_out1,'public',v_now) then raise exception 'Permitted only-turn was blocked';end if;
  if game.road_turn_is_permitted(v_in,v_via,v_out2,'public',v_now) then raise exception 'Non-permitted alternative turn was allowed';end if;
 end if;
 if game.road_turn_is_permitted(v_in,v_via,v_in,'public',v_now) then raise exception 'Immediate U-turn was permitted';end if;

 -- The same route must account for scheduled peak traffic, temporary closures and directionality.
 select access_point_id into v_origin from game.police_facilities where facility_ref='KNG-PF-HQ';
 select access_point_id into v_dest from game.police_facilities where facility_ref='KNG-PF-KDW';
 v_base:=game.calculate_road_route(v_origin,v_dest,'police','fastest');
 if not exists(select 1 from game.road_route_calculations where id=v_base and route_status='calculated' and algorithm_version='kng-turn-traffic-dijkstra-2.0') then raise exception 'Baseline police route failed';end if;
 select estimated_duration_seconds into v_base_seconds from game.road_route_calculations where id=v_base;
 v_peak:=game.calculate_road_route(v_origin,v_dest,'police','fastest',timestamptz '2026-11-23 08:00:00+00');
 select estimated_duration_seconds into v_peak_seconds from game.road_route_calculations where id=v_peak;
 if not exists(select 1 from game.road_route_calculations where id=v_peak and route_status='calculated') then raise exception 'Peak-hour route failed';end if;
 if v_peak_seconds<=v_base_seconds then raise exception 'Peak-hour traffic did not increase travel duration';end if;
 select road_segment_id into v_closed_seg from game.road_route_legs where route_id=v_base order by leg_order limit 1;
 insert into game.road_segment_conditions(condition_ref,road_segment_id,condition_type,severity,description,starts_at,ends_at,is_closed,closed_to_profiles)
 values('TEST-CLOSURE-'||replace(gen_random_uuid()::text,'-',''),v_closed_seg,'roadworks','high','Rollback-only closure test',v_now-interval '1 minute',v_now+interval '1 hour',true,array['police']::text[]);
 v_closed_route:=game.calculate_road_route(v_origin,v_dest,'police','fastest',v_now);
 if exists(select 1 from game.road_route_legs where route_id=v_closed_route and road_segment_id=v_closed_seg) then raise exception 'Routing ignored active closure';end if;
 if exists(select 1 from game.road_route_legs l join game.road_segments s on s.id=l.road_segment_id where l.route_id=v_base
  and ((s.directionality='one_way_forward' and (l.from_junction_id<>s.from_junction_id or l.to_junction_id<>s.to_junction_id))
   or (s.directionality='one_way_reverse' and (l.from_junction_id<>s.to_junction_id or l.to_junction_id<>s.from_junction_id)))) then raise exception 'Route violated one-way direction';end if;

 -- Directed reachability, coordinate bounds and measured-length reconciliation.
 with recursive directed_reachable(id) as (
  select id from game.road_junctions where city_id=v_city and junction_code='J001'
  union
  select case when s.from_junction_id=dr.id then s.to_junction_id else s.from_junction_id end
  from game.road_segments s join directed_reachable dr
   on ((s.from_junction_id=dr.id and s.directionality in ('two_way','one_way_forward'))
    or (s.to_junction_id=dr.id and s.directionality in ('two_way','one_way_reverse')))
  where s.city_id=v_city and s.is_routable
 ) select count(*) into v_count from directed_reachable;
 if v_count<>157 then raise exception 'Directed network cannot reach all junctions: % of 157',v_count;end if;
 if exists(select 1 from game.road_segments s cross join lateral jsonb_array_elements(s.geometry_local_m) p
  where s.city_id=v_city and ((p.value->>0)::integer<0 or (p.value->>0)::integer>20000 or (p.value->>1)::integer<0 or (p.value->>1)::integer>16000)) then
  raise exception 'A road geometry vertex falls outside the city grid';end if;
 with vertices as (
  select s.id,(p.value->>0)::numeric x,(p.value->>1)::numeric y,
   lag((p.value->>0)::numeric) over(partition by s.id order by p.ord) px,
   lag((p.value->>1)::numeric) over(partition by s.id order by p.ord) py
  from game.road_segments s cross join lateral jsonb_array_elements(s.geometry_local_m) with ordinality p(value,ord)
  where s.city_id=v_city
 ), measured as(select id,sum(sqrt((x-px)^2+(y-py)^2)) metres from vertices where px is not null group by id)
 if exists(select 1 from measured m join game.road_segments s on s.id=m.id where abs(round(m.metres)::integer-s.segment_length_m)>1) then
  raise exception 'Stored road-segment length does not reconcile to its line geometry';end if;

 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is not null then raise exception 'Geography regression must not initialise the fictional clock';end if;
end $$;
rollback;