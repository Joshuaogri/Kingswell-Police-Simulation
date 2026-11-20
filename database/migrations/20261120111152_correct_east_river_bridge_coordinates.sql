-- Align the three bridge crossings with the mapped East River corridor.
update game.road_junctions
set x_m=case when junction_code like 'RB%-W' then 16400 when junction_code like 'RB%-E' then 17400 else x_m end
where city_id=(select id from game.cities where code='KNG')
and junction_code ~ '^RB0[1-3]-[WE]$';

update game.road_segments s
set segment_length_m=greatest(1,round(sqrt((a.x_m-b.x_m)::numeric^2+(a.y_m-b.y_m)::numeric^2))::integer)
from game.road_junctions a,game.road_junctions b
where s.from_junction_id=a.id and s.to_junction_id=b.id
and s.city_id=(select id from game.cities where code='KNG')
and s.segment_code like 'RIVER-RB0%';
