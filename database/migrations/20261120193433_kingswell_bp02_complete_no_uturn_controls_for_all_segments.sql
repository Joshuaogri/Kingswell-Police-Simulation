insert into game.road_turn_restrictions(restriction_ref,city_id,incoming_segment_id,via_junction_id,outgoing_segment_id,restriction_kind,turn_type,vehicle_profiles,reason)
select 'KNG-NOUTURN-'||s.segment_code||'-'||side.side,s.city_id,s.id,j.id,s.id,'prohibited','no_u_turn',
 array['public','police','emergency']::text[],'Standard no-immediate-U-turn control at a connected junction.'
from game.road_segments s
cross join lateral (values ('FROM',s.from_junction_id),('TO',s.to_junction_id)) side(side,junction_id)
join game.road_junctions j on j.id=side.junction_id
where s.city_id=(select id from game.cities where code='KNG') and s.directionality='two_way'
and not exists(select 1 from game.road_turn_restrictions r where r.restriction_ref='KNG-NOUTURN-'||s.segment_code||'-'||side.side);
