update game.property_access_points ap
set nearest_junction_id=case
 when ((jf.x_m-p.x_m)::bigint*(jf.x_m-p.x_m)::bigint+(jf.y_m-p.y_m)::bigint*(jf.y_m-p.y_m)::bigint)
  <=((jt.x_m-p.x_m)::bigint*(jt.x_m-p.x_m)::bigint+(jt.y_m-p.y_m)::bigint*(jt.y_m-p.y_m)::bigint)
 then jf.id else jt.id end
from game.properties p
join game.road_segments rs on rs.id=p.frontage_segment_id
join game.road_junctions jf on jf.id=rs.from_junction_id
join game.road_junctions jt on jt.id=rs.to_junction_id
where ap.property_id=p.id and (p.property_ref like 'KNG-P-RH%' or p.property_ref like 'KNG-P-CM%');
