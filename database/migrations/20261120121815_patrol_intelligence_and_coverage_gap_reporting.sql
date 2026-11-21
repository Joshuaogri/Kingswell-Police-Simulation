create index if not exists patrol_movement_beat_arrival_idx on game.patrol_movement_events(beat_id,arrived_at_game_time desc);
create index if not exists patrol_movement_segment_arrival_idx on game.patrol_movement_events(road_segment_id,arrived_at_game_time desc);
create or replace function game.get_patrol_intelligence(p_since timestamptz default null,p_until timestamptz default null)
returns jsonb language plpgsql stable set search_path to ''
as $function$
declare v_now timestamptz; v_from timestamptz; v_to timestamptz; result jsonb;
begin
 select current_game_time into v_now from game.simulation_state where id=1;
 if v_now is null then raise exception 'Patrol intelligence requires an initialized fictional clock'; end if;
 v_to:=coalesce(p_until,v_now); v_from:=coalesce(p_since,'-infinity'::timestamptz);
 if v_from>=v_to then raise exception 'Patrol intelligence window must have a start before its end'; end if;
 if v_to>v_now then raise exception 'Patrol intelligence cannot include future fictional time'; end if;
 with beat_stats as (
  select b.id,b.beat_ref,b.beat_name,b.district_id,b.neighbourhood_id,
   count(distinct e.road_segment_id) filter(where e.id is not null)::integer visited_segments,
   count(e.id)::integer movement_legs,
   coalesce(sum(e.distance_m),0)::bigint distance_m,
   coalesce(sum(e.duration_seconds),0)::bigint movement_seconds,
   max(e.arrived_at_game_time) last_patrolled_at,
   count(distinct date_trunc('day',e.departed_at_game_time))::integer active_patrol_days
  from game.patrol_beats b
  left join game.patrol_movement_events e on e.beat_id=b.id and e.within_assigned_beat and e.departed_at_game_time>=v_from and e.arrived_at_game_time<=v_to
  where b.status='active' group by b.id
 ), segment_stats as (
  select br.beat_id,rs.id segment_id,rs.segment_code,r.name road_name,rs.segment_length_m,
   count(e.id)::integer traversals,max(e.arrived_at_game_time) last_traversed_at,
   coalesce(sum(e.duration_seconds),0)::bigint movement_seconds
  from game.patrol_beat_road_segments br join game.road_segments rs on rs.id=br.road_segment_id
  join game.roads r on r.id=rs.road_id
  left join game.patrol_movement_events e on e.road_segment_id=rs.id and e.beat_id=br.beat_id and e.within_assigned_beat and e.departed_at_game_time>=v_from and e.arrived_at_game_time<=v_to
  group by br.beat_id,rs.id,rs.segment_code,r.name,rs.segment_length_m
 ), beat_segments as (
  select beat_id,count(*)::integer total_segments from game.patrol_beat_road_segments group by beat_id
 ), unit_stats as (
  select u.unit_ref,u.unit_name,count(e.id)::integer movement_legs,
   count(distinct e.road_segment_id)::integer distinct_segments,
   coalesce(sum(e.distance_m),0)::bigint distance_m,
   coalesce(sum(e.duration_seconds),0)::bigint movement_seconds,
   max(e.arrived_at_game_time) last_movement_at
  from game.police_units u left join game.patrol_movement_events e on e.unit_id=u.id and e.departed_at_game_time>=v_from and e.arrived_at_game_time<=v_to
  group by u.id,u.unit_ref,u.unit_name
 )
 select jsonb_build_object(
  'window',jsonb_build_object('from',case when v_from='-infinity'::timestamptz then null else v_from end,'to',v_to,'scope',case when v_from='-infinity'::timestamptz then 'all_recorded_history' else 'selected_period' end),
  'beats',coalesce((select jsonb_agg(jsonb_build_object(
   'beat_ref',bs.beat_ref,'beat_name',bs.beat_name,'visited_road_segments',bs.visited_segments,
   'total_road_segments',coalesce(sg.total_segments,0),
   'coverage_percent',case when coalesce(sg.total_segments,0)=0 then 0 else round(bs.visited_segments*100.0/sg.total_segments,1) end,
   'movement_legs',bs.movement_legs,'distance_m',bs.distance_m,'movement_minutes',round(bs.movement_seconds/60.0,1),
   'active_patrol_days',bs.active_patrol_days,'last_patrolled_at',bs.last_patrolled_at,
   'gap_hours',case when bs.last_patrolled_at is null then null else round(extract(epoch from (v_to-bs.last_patrolled_at))/3600.0,1) end,
   'coverage_gap',case when bs.visited_segments=0 then 'never_visited_in_window' when bs.visited_segments<coalesce(sg.total_segments,0) then 'partially_visited' else 'all_segments_visited' end
  ) order by case when bs.visited_segments=0 then 0 when bs.visited_segments<coalesce(sg.total_segments,0) then 1 else 2 end,bs.beat_ref)
  from beat_stats bs left join beat_segments sg on sg.beat_id=bs.id),'[]'::jsonb),
  'least_visited_roads',coalesce((select jsonb_agg(jsonb_build_object('beat_ref',b.beat_ref,'segment_code',ss.segment_code,'road_name',ss.road_name,'traversals',ss.traversals,'last_traversed_at',ss.last_traversed_at,'movement_minutes',round(ss.movement_seconds/60.0,1)) order by ss.traversals,ss.last_traversed_at nulls first,ss.road_name,ss.segment_code) from segment_stats ss join game.patrol_beats b on b.id=ss.beat_id),'[]'::jsonb),
  'unit_activity',coalesce((select jsonb_agg(jsonb_build_object('unit_ref',us.unit_ref,'unit_name',us.unit_name,'movement_legs',us.movement_legs,'distinct_road_segments',us.distinct_segments,'distance_m',us.distance_m,'movement_minutes',round(us.movement_seconds/60.0,1),'last_movement_at',us.last_movement_at) order by us.movement_seconds desc,us.unit_ref) from unit_stats us where us.movement_legs>0),'[]'::jsonb),
  'totals',jsonb_build_object(
   'beats_assessed',(select count(*) from beat_stats),
   'beats_never_visited',(select count(*) from beat_stats where visited_segments=0),
   'beats_partially_visited',(select count(*) from beat_stats bs join beat_segments sg on sg.beat_id=bs.id where bs.visited_segments>0 and bs.visited_segments<sg.total_segments),
   'beats_all_segments_visited',(select count(*) from beat_stats bs join beat_segments sg on sg.beat_id=bs.id where bs.visited_segments=sg.total_segments and sg.total_segments>0),
   'distinct_road_segments_visited',(select count(distinct e.road_segment_id) from game.patrol_movement_events e where e.within_assigned_beat and e.departed_at_game_time>=v_from and e.arrived_at_game_time<=v_to),
   'patrol_distance_m',(select coalesce(sum(e.distance_m),0) from game.patrol_movement_events e where e.within_assigned_beat and e.departed_at_game_time>=v_from and e.arrived_at_game_time<=v_to),
   'patrol_movement_minutes',(select round(coalesce(sum(e.duration_seconds),0)/60.0,1) from game.patrol_movement_events e where e.within_assigned_beat and e.departed_at_game_time>=v_from and e.arrived_at_game_time<=v_to)
  )
 ) into result;
 return result;
end;$function$;
revoke all on function game.get_patrol_intelligence(timestamptz,timestamptz) from public,anon,authenticated;
grant execute on function game.get_patrol_intelligence(timestamptz,timestamptz) to service_role;
alter function game.interpret_text_command(text) rename to interpret_text_command_before_intelligence;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game'
as $function$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 if lower(t) in ('patrol intelligence','patrol gaps','patrol analysis') then
  return jsonb_build_object('recognized',true,'command_type','patrol_intelligence','payload','{}'::jsonb);
 end if;
 m:=regexp_match(t,'^patrol[[:space:]]+move[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+to[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+because[[:space:]]+(.+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','patrol_move','payload',jsonb_build_object('unit_ref',m[1],'destination_access_ref',m[2],'reason',btrim(m[3]))); end if;
 return game.interpret_text_command_before_intelligence(p_command_text);
end;$function$;
do $patch$
declare def text; marker text; injected text; help_old text; help_new text;
begin
 def:=pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure);
 marker:=$marker$  elsif v_type='patrol_move' then
    v_result:=game.move_patrol_unit(v_command.id,p_payload->>'unit_ref',p_payload->>'destination_access_ref',p_payload->>'reason') || jsonb_build_object('ok',true,'status','completed','command_id',v_command.id);
$marker$;
 injected:=$inject$  elsif v_type='patrol_intelligence' then
    v_result:=jsonb_build_object('ok',true,'status','completed','command_id',v_command.id,'intelligence',game.get_patrol_intelligence());
$inject$;
 if position(marker in def)=0 then raise exception 'Could not locate patrol movement dispatcher branch'; end if;
 def:=replace(def,marker,marker||injected);
 help_old:=$ho$'patrol_coverage','patrol_move'),'note','Forensic laboratory workflow commands are available.')$ho$;
 help_new:=$hn$'patrol_coverage','patrol_move','patrol_intelligence'),'note','Patrol intelligence and forensic laboratory commands are available.')$hn$;
 if position(help_old in def)=0 then raise exception 'Could not locate help command list'; end if;
 def:=replace(def,help_old,help_new);
 execute def;
end;$patch$;
revoke all on function game.interpret_text_command(text) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text) to service_role;
