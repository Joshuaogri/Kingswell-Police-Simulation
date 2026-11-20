-- Kingswell BP-02 complete road-network integrity regression.
begin;
do $$
declare v_city uuid; v_total integer; v_reached integer; v_bad integer;
begin
 select id into v_city from game.cities where code='KNG';
 if v_city is null then raise exception 'Kingswell city missing'; end if;
 select count(*) into v_total from game.districts where city_id=v_city;
 if v_total<>12 then raise exception 'Expected 12 districts; found %',v_total; end if;
 select count(*) into v_total from game.neighbourhoods n join game.districts d on d.id=n.district_id where d.city_id=v_city;
 if v_total<>24 then raise exception 'Expected 24 neighbourhoods; found %',v_total; end if;
 select count(*) into v_total from game.roads where city_id=v_city;
 if v_total<>51 then raise exception 'Expected 51 named roads; found %',v_total; end if;
 select count(*) into v_total from game.road_junctions where city_id=v_city;
 if v_total<>118 then raise exception 'Expected 118 junctions; found %',v_total; end if;
 select count(*) into v_total from game.road_segments where city_id=v_city;
 if v_total<>151 then raise exception 'Expected 151 road segments; found %',v_total; end if;
 select count(*) into v_total from game.road_segments where city_id=v_city and crossing_type='bridge';
 if v_total<>3 then raise exception 'Expected 3 explicit river bridge segments; found %',v_total; end if;
 select count(*) into v_bad from game.road_junctions where city_id=v_city and junction_code in ('RB01-W','RB02-W','RB03-W') and x_m<>16400;
 if v_bad<>0 then raise exception 'West bridge bank coordinates do not span the mapped river corridor'; end if;
 select count(*) into v_bad from game.road_junctions where city_id=v_city and junction_code in ('RB01-E','RB02-E','RB03-E') and x_m<>17400;
 if v_bad<>0 then raise exception 'East bridge bank coordinates do not span the mapped river corridor'; end if;
 select count(*) into v_bad from game.road_segments s
 left join game.road_junctions f on f.id=s.from_junction_id
 left join game.road_junctions t on t.id=s.to_junction_id
 left join game.roads r on r.id=s.road_id
 where s.city_id=v_city and (f.id is null or t.id is null or r.id is null or f.city_id<>v_city or t.city_id<>v_city or r.city_id<>v_city);
 if v_bad<>0 then raise exception 'Invalid or cross-city segment references: %',v_bad; end if;
 select count(*) into v_bad from game.neighbourhoods n join game.districts d on d.id=n.district_id
 where d.city_id=v_city and not exists(
  select 1 from game.road_segments s join game.roads r on r.id=s.road_id
  where s.city_id=v_city and r.code='KNG-L-'||replace(n.code,'-',''));
 if v_bad<>0 then raise exception 'Neighbourhoods without a dedicated local street: %',v_bad; end if;
 with recursive reachable(id) as (
  select id from game.road_junctions where city_id=v_city and junction_code='J001'
  union
  select case when s.from_junction_id=reachable.id then s.to_junction_id else s.from_junction_id end
  from game.road_segments s join reachable on s.from_junction_id=reachable.id or s.to_junction_id=reachable.id
  where s.city_id=v_city and s.is_routable
 ) select count(*) into v_reached from reachable;
 select count(*) into v_total from game.road_junctions where city_id=v_city;
 if v_reached<>v_total then raise exception 'Disconnected road graph: % of % junctions reachable',v_reached,v_total; end if;
 select count(*) into v_total from pg_tables where schemaname='game'
 and tablename in ('district_map_areas','road_junctions','road_segments') and rowsecurity;
 if v_total<>3 then raise exception 'Geography RLS missing'; end if;
end $$;
rollback;