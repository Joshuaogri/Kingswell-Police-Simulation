create or replace function game.move_patrol_unit(p_command_id uuid,p_unit_ref text,p_destination_access_ref text,p_reason text)
returns jsonb language plpgsql set search_path to ''
as $function$
declare
 u game.police_units%rowtype; s game.patrol_schedules%rowtype; b game.patrol_beats%rowtype;
 clk game.simulation_state%rowtype; dest uuid; v_route uuid; v_route_status text;
 v_dist integer; v_secs integer; leg record; n integer:=0; t timestamptz; t2 timestamptz;
begin
 if p_command_id is null then raise exception 'Command identifier is required'; end if;
 if length(btrim(coalesce(p_reason,'')))=0 then raise exception 'Movement reason is required'; end if;
 select * into clk from game.simulation_state where id=1 for update;
 if clk.current_game_time is null then raise exception 'Fictional clock is not initialized'; end if;
 select * into u from game.police_units where unit_ref=p_unit_ref and status='active' for update;
 if not found or u.operational_state<>'on_patrol' then raise exception 'Unit must be active and on patrol'; end if;
 select * into s from game.patrol_schedules where unit_id=u.id and status='active' order by starts_at desc limit 1 for update;
 if not found then raise exception 'Unit has no active patrol schedule'; end if;
 select * into b from game.patrol_beats where id=s.beat_id and status='active';
 if not found then raise exception 'Patrol beat is not active'; end if;
 if u.current_access_point_id is null then
  update game.police_units set current_access_point_id=(select pf.access_point_id from game.police_facilities pf where pf.id=u.base_facility_id),current_location_updated_at=clk.current_game_time where id=u.id returning * into u;
 end if;
 if u.current_access_point_id is null then raise exception 'Unit has no known starting access point'; end if;
 select id into dest from game.property_access_points where access_ref=p_destination_access_ref and is_primary;
 if dest is null then raise exception 'Destination access point not found'; end if;
 if not exists(select 1 from game.patrol_beat_road_segments brs join game.property_access_points ap on ap.road_segment_id=brs.road_segment_id where brs.beat_id=b.id and ap.id=dest) then raise exception 'Destination access point is not on the unit assigned beat'; end if;
 v_route:=game.calculate_road_route(u.current_access_point_id,dest,'police','fastest');
 select r.route_status,r.distance_m,r.estimated_duration_seconds into v_route_status,v_dist,v_secs from game.road_route_calculations r where r.id=v_route;
 if v_route_status<>'calculated' or coalesce(v_secs,0)<=0 then raise exception 'No traversable patrol route exists to the destination'; end if;
 if exists(select 1 from game.road_route_legs l where l.route_id=v_route and not exists(select 1 from game.patrol_beat_road_segments brs where brs.beat_id=b.id and brs.road_segment_id=l.road_segment_id)) then raise exception 'Calculated route leaves the assigned patrol beat; movement rejected'; end if;
 if clk.current_game_time+make_interval(secs=>v_secs)>s.ends_at then raise exception 'Journey would exceed the active patrol schedule; extend or replace the schedule first'; end if;
 t:=clk.current_game_time;
 for leg in select l.*,rs.segment_code,r.name road_name from game.road_route_legs l join game.road_segments rs on rs.id=l.road_segment_id join game.roads r on r.id=rs.road_id where l.route_id=v_route order by l.leg_order loop
  n:=n+1; t2:=t+make_interval(secs=>leg.estimated_duration_seconds);
  insert into game.patrol_movement_events(unit_id,beat_id,schedule_id,route_id,route_leg_id,movement_order,road_segment_id,from_junction_id,to_junction_id,departed_at_game_time,arrived_at_game_time,distance_m,duration_seconds,reason)
  values(u.id,b.id,s.id,v_route,leg.id,n,leg.road_segment_id,leg.from_junction_id,leg.to_junction_id,t,t2,leg.distance_m,leg.estimated_duration_seconds,btrim(p_reason));
  t:=t2;
 end loop;
 if n=0 then raise exception 'Route contains no road segments; movement was not recorded'; end if;
 update game.police_units set current_access_point_id=dest,current_location_updated_at=t where id=u.id;
 update game.simulation_state set current_game_time=t,updated_at=now() where id=1;
 insert into game.game_clock_history(command_id,previous_game_time,resulting_game_time,advancement_minutes,reason)
 values(p_command_id,clk.current_game_time,t,ceil(extract(epoch from (t-clk.current_game_time))/60.0)::integer,'Patrol road movement: '||btrim(p_reason));
 insert into game.game_events(event_key,game_time,entity_type,entity_id,event_data)
 values('patrol.movement.'||replace(p_command_id::text,'-',''),t,'police_unit',u.id,jsonb_build_object('command_id',p_command_id,'unit_ref',u.unit_ref,'beat_ref',b.beat_ref,'route_id',v_route,'origin_access_point_id',u.current_access_point_id,'destination_access_point_id',dest,'distance_m',v_dist,'duration_seconds',v_secs,'road_segments_traversed',n,'reason',btrim(p_reason)));
 return jsonb_build_object('unit_ref',u.unit_ref,'beat_ref',b.beat_ref,'route_id',v_route,'origin_access_point_id',u.current_access_point_id,'destination_access_point_id',dest,'distance_m',v_dist,'duration_seconds',v_secs,'road_segments_traversed',n,'departed_at',clk.current_game_time,'arrived_at',t,'game_time',t,'state','on_patrol');
end;$function$;
