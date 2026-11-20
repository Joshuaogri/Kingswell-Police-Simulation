-- Kingswell BP-02 country, city-grid, district and road-network integrity regression.
-- All checks are read-only and the transaction is rolled back.
begin;
do $$
declare
  v_country uuid;
  v_city uuid;
  v_count integer;
  v_reached integer;
  v_bad integer;
  v_clock timestamptz;
begin
  select id into v_country from game.world_countries where code='AST' and is_fictional;
  if v_country is null then raise exception 'Fictional Republic of Asterfell record is missing'; end if;
  select count(*) into v_count from game.world_countries;
  if v_count<>1 then raise exception 'Expected one canonical fictional country; found %',v_count; end if;
  if not exists(select 1 from game.world_countries where id=v_country and geographic_profile is not null and capital_city_id is not null) then
    raise exception 'Country geographic profile or capital-city link is missing';
  end if;

  select count(*) into v_count from game.regions where country_id=v_country;
  if v_count<>8 then raise exception 'Expected eight national administrative regions; found %',v_count; end if;
  if (select count(*) from game.regions where country_id=v_country and is_capital_region)<>1 then
    raise exception 'Expected exactly one capital region';
  end if;
  if not exists(select 1 from game.regions where country_id=v_country and code='CAP'
    and is_capital_region and region_order=1 and geographic_description is not null
    and relative_position is not null) then raise exception 'Capital region profile is incomplete'; end if;
  if (select array_agg(code order by region_order) from game.regions where country_id=v_country)
    <> array['CAP','NTH','WST','CTR','EST','IRV','SCO','OIS']::text[] then
    raise exception 'National region register is incomplete or out of order';
  end if;

  select id into v_city from game.cities where code='KNG' and region_id in
    (select id from game.regions where country_id=v_country and code='CAP');
  if v_city is null then raise exception 'Kingswell is not linked to the Asterfell capital region'; end if;
  if (select count(*) from game.cities where is_primary_city)<>1 then raise exception 'Expected one primary city'; end if;
  if not exists(select 1 from game.world_countries where id=v_country and capital_city_id=v_city) then
    raise exception 'Country capital-city reference is incorrect';
  end if;
  if not exists(select 1 from game.cities where id=v_city and population=100000
    and grid_width_m=20000 and grid_height_m=16000 and map_orientation='north_up'
    and coastal_edge='south' and map_version='KNG-MAP-0.3'
    and major_waterway_description is not null) then
    raise exception 'Kingswell baseline or local-grid metadata is incomplete';
  end if;

  select count(*) into v_count from game.districts where city_id=v_city;
  if v_count<>12 then raise exception 'Expected 12 districts; found %',v_count; end if;
  select count(*) into v_count from game.neighbourhoods n join game.districts d on d.id=n.district_id where d.city_id=v_city;
  if v_count<>24 then raise exception 'Expected 24 neighbourhoods; found %',v_count; end if;
  select count(*) into v_bad from game.districts d
    where d.city_id=v_city and (select count(*) from game.neighbourhoods n where n.district_id=d.id)<>2;
  if v_bad<>0 then raise exception 'Every district must contain exactly two neighbourhoods'; end if;

  select count(*) into v_count from game.district_map_areas a join game.districts d on d.id=a.district_id where d.city_id=v_city;
  if v_count<>12 then raise exception 'Expected 12 district planning envelopes; found %',v_count; end if;
  select count(*) into v_bad from game.district_map_areas a join game.districts d on d.id=a.district_id
    where d.city_id=v_city and (a.min_x_m<0 or a.min_y_m<0 or a.max_x_m>20000 or a.max_y_m>16000
      or a.min_x_m>=a.max_x_m or a.min_y_m>=a.max_y_m or a.boundary_kind<>'planning_envelope'
      or a.map_version<>'KNG-MAP-0.3');
  if v_bad<>0 then raise exception 'District planning envelopes are outside or inconsistent with the Kingswell metre grid: %',v_bad; end if;

  select count(*) into v_count from game.roads where city_id=v_city;
  if v_count<>75 then raise exception 'Expected 75 named roads; found %',v_count; end if;
  if (select count(distinct name) from game.roads where city_id=v_city)<>75 then raise exception 'Duplicate road names exist'; end if;
  select count(*) into v_count from game.road_junctions where city_id=v_city;
  if v_count<>157 then raise exception 'Expected 157 junctions; found %',v_count; end if;
  select count(*) into v_bad from game.road_junctions where city_id=v_city
    and (x_m<0 or x_m>20000 or y_m<0 or y_m>16000);
  if v_bad<>0 then raise exception 'Road junctions fall outside the Kingswell local grid: %',v_bad; end if;
  select count(*) into v_count from game.road_segments where city_id=v_city;
  if v_count<>229 then raise exception 'Expected 229 road segments; found %',v_count; end if;
  select count(*) into v_count from game.road_segments where city_id=v_city and crossing_type='bridge' and segment_length_m=1000;
  if v_count<>3 then raise exception 'Expected three explicit 1,000 m river bridge segments; found %',v_count; end if;
  select count(*) into v_bad from game.road_junctions where city_id=v_city
    and junction_code in ('RB01-W','RB02-W','RB03-W') and x_m<>16400;
  if v_bad<>0 then raise exception 'West bridge bank coordinates do not span the mapped river corridor'; end if;
  select count(*) into v_bad from game.road_junctions where city_id=v_city
    and junction_code in ('RB01-E','RB02-E','RB03-E') and x_m<>17400;
  if v_bad<>0 then raise exception 'East bridge bank coordinates do not span the mapped river corridor'; end if;
  select count(*) into v_bad from game.road_segments s
    left join game.road_junctions f on f.id=s.from_junction_id
    left join game.road_junctions t on t.id=s.to_junction_id
    left join game.roads r on r.id=s.road_id
    where s.city_id=v_city and (f.id is null or t.id is null or r.id is null
      or f.city_id<>v_city or t.city_id<>v_city or r.city_id<>v_city);
  if v_bad<>0 then raise exception 'Invalid or cross-city road segment references: %',v_bad; end if;
  select count(*) into v_bad from game.neighbourhoods n join game.districts d on d.id=n.district_id
    where d.city_id=v_city and not exists(
      select 1 from game.road_segments s join game.roads r on r.id=s.road_id
      where s.city_id=v_city and r.code='KNG-L-'||replace(n.code,'-',''));
  if v_bad<>0 then raise exception 'Neighbourhoods without a dedicated local street: %',v_bad; end if;

  with recursive reachable(id) as (
    select id from game.road_junctions where city_id=v_city and junction_code='J001'
    union
    select case when s.from_junction_id=reachable.id then s.to_junction_id else s.from_junction_id end
    from game.road_segments s
    join reachable on s.from_junction_id=reachable.id or s.to_junction_id=reachable.id
    where s.city_id=v_city and s.is_routable
  )
  select count(*) into v_reached from reachable;
  if v_reached<>157 then raise exception 'Road graph is disconnected: % of 157 junctions reachable',v_reached; end if;

  select count(*) into v_count from game.city_landmarks where city_id=v_city;
  if v_count<>24 then raise exception 'Expected 24 named landmarks; found %',v_count; end if;
  select count(*) into v_bad from game.city_landmarks where city_id=v_city
    and (x_m<0 or x_m>20000 or y_m<0 or y_m>16000);
  if v_bad<>0 then raise exception 'Landmarks fall outside the Kingswell local grid: %',v_bad; end if;

  select count(*) into v_count from pg_tables where schemaname='game'
    and tablename in ('world_countries','regions','cities','districts','neighbourhoods',
      'district_map_areas','roads','road_junctions','road_segments','city_landmarks') and rowsecurity;
  if v_count<>10 then raise exception 'RLS missing from one or more BP-02 geography tables'; end if;

  select current_game_time into v_clock from game.simulation_state where id=1;
  if v_clock is not null then raise exception 'BP-02 regression must not initialise the fictional clock'; end if;
end $$;
rollback;
