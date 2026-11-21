-- Extend patrol geography coverage to every new service-lane segment.
with targets as (
 select s.id segment_id,b.id beat_id,
  row_number() over(partition by b.id order by s.segment_code) rn,
  coalesce((select max(x.coverage_order) from game.patrol_beat_road_segments x where x.beat_id=b.id),0) prior_max
 from game.road_segments s join game.roads r on r.id=s.road_id
 join game.neighbourhoods n on n.code=substring(s.segment_code from '^SL-([A-Z]{3}[0-9]{2})-') 
 join game.patrol_beats b on b.neighbourhood_id=n.id
 where s.segment_code like 'SL-%' and s.city_id=(select id from game.cities where code='KNG')
)
insert into game.patrol_beat_road_segments(beat_id,road_segment_id,coverage_order,coverage_role)
select beat_id,segment_id,prior_max+rn,'service_lane'
from targets t where not exists(select 1 from game.patrol_beat_road_segments x where x.road_segment_id=t.segment_id);
