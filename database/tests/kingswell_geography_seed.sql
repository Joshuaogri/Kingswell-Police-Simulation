-- Kingswell BP-02 geographic seed and network integrity regression.
begin;
do $$
declare
  v_city uuid;
  v_count integer;
  v_reachable integer;
begin
  select id into v_city from game.cities where code='KNG';
  if v_city is null then raise exception 'Kingswell city seed is missing'; end if;

  select count(*) into v_count from game.districts where city_id=v_city;
  if v_count <> 12 then raise exception 'Expected 12 districts, found %',v_count; end if;

  select count(*) into v_count
  from game.neighbourhoods n join game.districts d on d.id=n.district_id
  where d.city_id=v_city;
  if v_count <> 24 then raise exception 'Expected 24 neighbourhoods, found %',v_count; end if;

  select count(*) into v_count from game.district_map_areas a
  join game.districts d on d.id=a.district_id where d.city_id=v_city;
  if v_count <> 12 then raise exception 'Expected 12 district map envelopes, found %',v_count; end if;

  select count(*) into v_count from game.roads where city_id=v_city;
  if v_count <> 24 then raise exception 'Expected 24 named roads, found %',v_count; end if;

  select count(*) into v_count from game.road_junctions where city_id=v_city;
  if v_count <> 16 then raise exception 'Expected 16 junctions, found %',v_count; end if;

  select count(*) into v_count from game.road_segments where city_id=v_city;
  if v_count <> 22 then raise exception 'Expected 22 road segments, found %',v_count; end if;

  select count(*) into v_count
  from game.road_segments s
  left join game.road_junctions f on f.id=s.from_junction_id
  left join game.road_junctions t on t.id=s.to_junction_id
  left join game.roads r on r.id=s.road_id
  where s.city_id=v_city and (f.id is null or t.id is null or r.id is null
    or f.city_id<>v_city or t.city_id<>v_city or r.city_id<>v_city);
  if v_count <> 0 then raise exception 'Found % invalid/cross-city road segment references',v_count; end if;

  with recursive reachable(id) as (
    select id from game.road_junctions where city_id=v_city and junction_code='J001'
    union
    select case when s.from_junction_id=reachable.id then s.to_junction_id else s.from_junction_id end
    from game.road_segments s
    join reachable on s.from_junction_id=reachable.id or s.to_junction_id=reachable.id
    where s.city_id=v_city and s.is_routable
  )
  select count(*) into v_reachable from reachable;
  if v_reachable <> 16 then raise exception 'Road graph is disconnected: % of 16 junctions reachable',v_reachable; end if;

  select count(*) into v_count from pg_tables
  where schemaname='game' and tablename in ('district_map_areas','road_junctions','road_segments') and rowsecurity;
  if v_count <> 3 then raise exception 'RLS is not enabled on all three geography tables'; end if;
end $$;
rollback;
