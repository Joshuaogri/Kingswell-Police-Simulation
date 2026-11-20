-- Rollback-only weighted road routing regression.
begin;
do $$
declare
 v_origin uuid;
 v_destination uuid;
 v_public_origin uuid;
 v_public_destination uuid;
 v_fast uuid;
 v_short uuid;
 v_public uuid;
 v_fast_distance integer;
 v_short_distance integer;
 v_fast_seconds integer;
begin
 select access_point_id into v_origin from game.police_facilities where facility_ref='KNG-PF-HQ';
 select access_point_id into v_destination from game.police_facilities where facility_ref='KNG-PF-KDW';
 v_fast:=game.calculate_road_route(v_origin,v_destination,'police','fastest');
 v_short:=game.calculate_road_route(v_origin,v_destination,'police','shortest');
 select distance_m,estimated_duration_seconds into v_fast_distance,v_fast_seconds
 from game.road_route_calculations where id=v_fast and route_status='calculated';
 if v_fast_distance is null or v_fast_seconds is null then raise exception 'Police fastest route missing'; end if;
 select distance_m into v_short_distance from game.road_route_calculations where id=v_short and route_status='calculated';
 if v_short_distance is null or v_short_distance>v_fast_distance then raise exception 'Shortest route distance is not minimal'; end if;
 if not exists(select 1 from game.road_route_legs where route_id=v_fast) then raise exception 'Route leg sequence missing'; end if;
 if (select sum(distance_m) from game.road_route_legs where route_id=v_fast)<>v_fast_distance then raise exception 'Route distance does not reconcile'; end if;
 if (select sum(estimated_duration_seconds) from game.road_route_legs where route_id=v_fast)<>v_fast_seconds then raise exception 'Route time does not reconcile'; end if;

 select id into v_public_origin from game.property_access_points where access_profile='public' order by access_ref limit 1;
 select id into v_public_destination from game.property_access_points where access_profile='public' order by access_ref desc limit 1;
 v_public:=game.calculate_road_route(v_public_origin,v_public_destination,'public','fastest');
 if not exists(select 1 from game.road_route_calculations where id=v_public and route_status='calculated') then raise exception 'Public route missing'; end if;
 if exists(select 1 from game.road_route_legs l join game.road_segments s on s.id=l.road_segment_id where l.route_id=v_public and s.access_profile<>'public') then raise exception 'Public route used a restricted road'; end if;

 if exists(select 1 from game.road_route_legs l join game.road_segments s on s.id=l.road_segment_id
   where l.route_id=v_fast and s.directionality<>'two_way'
     and not ((s.directionality='one_way_forward' and l.from_junction_id=s.from_junction_id and l.to_junction_id=s.to_junction_id)
       or (s.directionality='one_way_reverse' and l.from_junction_id=s.to_junction_id and l.to_junction_id=s.from_junction_id)))
 then raise exception 'Route violates a one-way segment'; end if;

 if not exists(select 1 from pg_proc p join pg_namespace n on n.oid=p.pronamespace
   where n.nspname='game' and p.proname='calculate_road_route' and not p.prosecdef)
 then raise exception 'Route function must remain SECURITY INVOKER'; end if;
 if exists(select 1 from (values ('road_route_calculations'),('road_route_legs')) t(name)
   where not (select c.relrowsecurity from pg_class c join pg_namespace ns on ns.oid=c.relnamespace
     where ns.nspname='game' and c.relname=t.name))
 then raise exception 'RLS missing on route records'; end if;
end $$;
rollback;
