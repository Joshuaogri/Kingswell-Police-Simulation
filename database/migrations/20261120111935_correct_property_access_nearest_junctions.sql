-- Recalculate each property access point's nearest endpoint on its frontage road segment.
update game.property_access_points a
set nearest_junction_id = case
 when ((jf.x_m-p.x_m)::bigint*(jf.x_m-p.x_m)::bigint + (jf.y_m-p.y_m)::bigint*(jf.y_m-p.y_m)::bigint)
   <= ((jt.x_m-p.x_m)::bigint*(jt.x_m-p.x_m)::bigint + (jt.y_m-p.y_m)::bigint*(jt.y_m-p.y_m)::bigint)
 then jf.id else jt.id end
from game.properties p,game.road_segments s,game.road_junctions jf,game.road_junctions jt
where a.property_id=p.id and a.road_segment_id=s.id
 and s.from_junction_id=jf.id and s.to_junction_id=jt.id
 and p.city_id=(select id from game.cities where code='KNG');
