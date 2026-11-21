-- Connect the 15 previously named-but-unsegmented secondary/local roads to the live graph.
do $$
declare r record; a record; b record; v_mid uuid; v_x integer; v_y integer; v_len integer; v_class text; v_speed smallint; v_beat uuid; v_order integer; v_code text;
begin
 for r in
  select rd.*,d.id district_id,ma.min_x_m,ma.max_x_m,ma.min_y_m,ma.max_y_m
  from game.roads rd join game.districts d on d.id=rd.district_id
  left join game.district_map_areas ma on ma.district_id=d.id
  where rd.city_id=(select id from game.cities where code='KNG')
   and not exists(select 1 from game.road_segments s where s.road_id=rd.id)
  order by rd.code
 loop
  select j.id,j.x_m,j.y_m into a from game.road_junctions j
  where j.city_id=r.city_id and j.x_m between coalesce(r.min_x_m,0) and coalesce(r.max_x_m,20000)
   and j.y_m between coalesce(r.min_y_m,0) and coalesce(r.max_y_m,16000)
  order by j.junction_code limit 1;
  select j.id,j.x_m,j.y_m into b from game.road_junctions j
  where j.city_id=r.city_id and j.id<>a.id and j.x_m between coalesce(r.min_x_m,0) and coalesce(r.max_x_m,20000)
   and j.y_m between coalesce(r.min_y_m,0) and coalesce(r.max_y_m,16000)
  order by ((j.x_m-a.x_m)::bigint*(j.x_m-a.x_m)::bigint+(j.y_m-a.y_m)::bigint*(j.y_m-a.y_m)::bigint) desc limit 1;
  if a.id is null or b.id is null then raise exception 'Cannot connect named road %: district has insufficient junctions',r.code; end if;
  v_x:=round((a.x_m+b.x_m)/2.0)::integer;
  v_y:=round((a.y_m+b.y_m)/2.0)::integer;
  insert into game.road_junctions(city_id,junction_code,junction_name,x_m,y_m,junction_type,access_profile,control_type,pedestrian_crossing,tactile_crossing,lighting_standard,map_version)
  values(r.city_id,r.code||'-MID',r.name||' Midpoint Junction',v_x,v_y,'at_grade','public','priority_or_uncontrolled',true,true,'LED_standard','KNG-MAP-0.3')
  on conflict(city_id,junction_code) do update set junction_name=excluded.junction_name
  returning id into v_mid;
  v_class:=case when r.road_type='secondary' then 'local_collector' else 'local' end;
  v_speed:=case when r.road_type='secondary' then 35 else 25 end;
  v_len:=greatest(1,round(sqrt((a.x_m-v_x)::numeric^2+(a.y_m-v_y)::numeric^2))::integer);
  insert into game.road_segments(city_id,road_id,segment_code,from_junction_id,to_junction_id,segment_length_m,road_class,lanes_each_direction,speed_limit_kph,directionality,surface_type,crossing_type,access_profile)
  values(r.city_id,r.id,r.code||'-A',a.id,v_mid,v_len,v_class,1,v_speed,'two_way','sealed','at_grade','public');
  v_len:=greatest(1,round(sqrt((b.x_m-v_x)::numeric^2+(b.y_m-v_y)::numeric^2))::integer);
  insert into game.road_segments(city_id,road_id,segment_code,from_junction_id,to_junction_id,segment_length_m,road_class,lanes_each_direction,speed_limit_kph,directionality,surface_type,crossing_type,access_profile)
  values(r.city_id,r.id,r.code||'-B',v_mid,b.id,v_len,v_class,1,v_speed,'two_way','sealed','at_grade','public');
  select id into v_beat from game.patrol_beats where district_id=r.district_id order by beat_ref limit 1;
  if v_beat is not null then
   select coalesce(max(coverage_order),0) into v_order from game.patrol_beat_road_segments where beat_id=v_beat;
   insert into game.patrol_beat_road_segments(beat_id,road_segment_id,coverage_order,coverage_role)
   select v_beat,s.id,v_order+row_number() over(order by s.segment_code)::integer,'secondary_road'
   from game.road_segments s where s.road_id=r.id;
  end if;
 end loop;
end $$;

-- Give newly connected roads the same full line geometry and traffic treatment as the existing map.
with e as (
 select s.id,s.segment_code,s.crossing_type,a.x_m x1,a.y_m y1,b.x_m x2,b.y_m y2
 from game.road_segments s join game.road_junctions a on a.id=s.from_junction_id join game.road_junctions b on b.id=s.to_junction_id
 where s.city_id=(select id from game.cities where code='KNG') and s.geometry_local_m is null
), q as (
 select *,greatest(1,sqrt((x2-x1)::numeric^2+(y2-y1)::numeric^2)) len,
  (mod(abs(hashtext(segment_code)),9)-4)*9::numeric off_m from e
), m as (
 select *, (x1+x2)/2.0+(-(y2-y1)/len)*off_m mx,(y1+y2)/2.0+((x2-x1)/len)*off_m my from q
)
update game.road_segments s set geometry_local_m=jsonb_build_array(jsonb_build_array(m.x1,m.y1),
 jsonb_build_array(round(m.x1+(m.mx-m.x1)/3.0)::integer,round(m.y1+(m.my-m.y1)/3.0)::integer),
 jsonb_build_array(round(m.x1+2*(m.mx-m.x1)/3.0)::integer,round(m.y1+2*(m.my-m.y1)/3.0)::integer),
 jsonb_build_array(m.x2,m.y2)),geometry_source='authored_fictional_local_grid',map_version='KNG-MAP-0.3'
from m where m.id=s.id;

with v as (
 select s.id,p.ord,(p.value->>0)::numeric x,(p.value->>1)::numeric y,
  lag((p.value->>0)::numeric) over(partition by s.id order by p.ord) px,
  lag((p.value->>1)::numeric) over(partition by s.id order by p.ord) py
 from game.road_segments s cross join lateral jsonb_array_elements(s.geometry_local_m) with ordinality p(value,ord)
), l as (select id,sum(sqrt((x-px)^2+(y-py)^2)) metres from v where px is not null group by id)
update game.road_segments s set segment_length_m=greatest(1,round(l.metres)::integer) from l where l.id=s.id;

update game.road_segments s set
 carriageway_width_m=case when s.road_class='primary' then greatest(12,s.lanes_each_direction*3.4*2) when s.road_class='local_collector' then 8.5 when s.road_class='service_lane' then 5.5 else 6.5 end,
 lane_marking=case when s.road_class='primary' then 'divided_centre_and_lane_lines' when s.road_class='local_collector' then 'centre_line' when s.road_class='service_lane' then 'shared_low_speed' else 'edge_markings' end,
 has_sidewalk=s.road_class<>'service_lane',has_cycle_lane=s.road_class in ('primary','local_collector') and s.segment_length_m>250,
 has_street_lighting=true,has_on_street_parking=s.road_class in ('local','service_lane'),road_condition='good',map_version='KNG-MAP-0.3'
where s.city_id=(select id from game.cities where code='KNG');

insert into game.road_segment_traffic_profiles(profile_ref,road_segment_id,profile_name,day_of_week,starts_at,ends_at,speed_multiplier,fixed_delay_seconds)
select 'KNG-TRAFFIC-AM-'||s.segment_code,s.id,'Weekday morning peak',array[1,2,3,4,5]::smallint[],time '07:00',time '09:30',
 case when s.road_class in ('primary','local_collector') then .58 else .72 end,case when s.road_class='primary' then 35 else 15 end
from game.road_segments s where s.city_id=(select id from game.cities where code='KNG') on conflict(profile_ref) do nothing;
insert into game.road_segment_traffic_profiles(profile_ref,road_segment_id,profile_name,day_of_week,starts_at,ends_at,speed_multiplier,fixed_delay_seconds)
select 'KNG-TRAFFIC-PM-'||s.segment_code,s.id,'Weekday evening peak',array[1,2,3,4,5]::smallint[],time '16:00',time '19:00',
 case when s.road_class in ('primary','local_collector') then .52 else .68 end,case when s.road_class='primary' then 45 else 18 end
from game.road_segments s where s.city_id=(select id from game.cities where code='KNG') on conflict(profile_ref) do nothing;

insert into game.patrol_beat_road_segments(beat_id,road_segment_id,coverage_order,coverage_role)
select b.id,s.id,coalesce((select max(x.coverage_order) from game.patrol_beat_road_segments x where x.beat_id=b.id),0)+1,'secondary_road'
from game.road_segments s join game.roads r on r.id=s.road_id join game.patrol_beats b on b.district_id=r.district_id
where s.city_id=(select id from game.cities where code='KNG')
 and r.code between 'KNG-R010' and 'KNG-R024'
 and not exists(select 1 from game.patrol_beat_road_segments x where x.road_segment_id=s.id);
