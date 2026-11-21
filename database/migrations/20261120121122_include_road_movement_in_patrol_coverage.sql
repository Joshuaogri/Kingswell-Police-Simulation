create or replace function game.get_patrol_coverage()
returns jsonb language plpgsql stable set search_path to ''
as $function$
declare c timestamptz; result jsonb;
begin
 select current_game_time into c from game.simulation_state where id=1;
 select jsonb_build_object(
  'game_time',c,
  'beats',coalesce((select jsonb_agg(jsonb_build_object(
    'beat_ref',b.beat_ref,'beat_name',b.beat_name,'district_id',b.district_id,'neighbourhood_id',b.neighbourhood_id,
    'active_units',coalesce(x.units,'[]'::jsonb),
    'coverage_status',case when jsonb_array_length(coalesce(x.units,'[]'::jsonb))>0 then 'covered' else 'uncovered' end,
    'movement',jsonb_build_object('visited_road_segments',coalesce(m.visited_segments,0),'distance_m',coalesce(m.distance_m,0),'last_movement_at',m.last_movement_at)
  ) order by b.beat_ref)
  from game.patrol_beats b
  left join lateral (
    select jsonb_agg(jsonb_build_object('unit_ref',u.unit_ref,'unit_name',u.unit_name,'state',u.operational_state,'schedule_ref',s.schedule_ref,'started_at',s.starts_at,'ends_at',s.ends_at)) units
    from game.police_units u join game.patrol_schedules s on s.unit_id=u.id and s.beat_id=b.id and s.status='active'
    where u.status='active' and u.operational_state='on_patrol'
  ) x on true
  left join lateral (
    select count(distinct e.road_segment_id)::integer visited_segments,coalesce(sum(e.distance_m),0)::integer distance_m,max(e.arrived_at_game_time) last_movement_at
    from game.patrol_movement_events e where e.beat_id=b.id and e.within_assigned_beat
  ) m on true where b.status='active'),'[]'::jsonb),
  'totals',jsonb_build_object(
   'active_beats',(select count(*) from game.patrol_beats where status='active'),
   'covered_beats',(select count(*) from game.patrol_beats b where b.status='active' and exists(select 1 from game.police_units u join game.patrol_schedules s on s.unit_id=u.id and s.beat_id=b.id and s.status='active' where u.status='active' and u.operational_state='on_patrol')),
   'uncovered_beats',(select count(*) from game.patrol_beats b where b.status='active' and not exists(select 1 from game.police_units u join game.patrol_schedules s on s.unit_id=u.id and s.beat_id=b.id and s.status='active' where u.status='active' and u.operational_state='on_patrol')),
   'visited_road_segments',(select count(distinct e.road_segment_id) from game.patrol_movement_events e where e.within_assigned_beat),
   'patrol_distance_m',(select coalesce(sum(e.distance_m),0) from game.patrol_movement_events e where e.within_assigned_beat)
  )
 ) into result;
 return result;
end;$function$;
revoke all on function game.get_patrol_coverage() from public,anon,authenticated;
grant execute on function game.get_patrol_coverage() to service_role;
