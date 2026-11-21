-- Add authored turn bans at the eight signalised central junctions.
with signal as (
 select id,junction_code,x_m,y_m from game.road_junctions
 where city_id=(select id from game.cities where code='KNG') and control_type='signalised'
), incoming as (
 select j.id jid,j.junction_code,j.x_m jx,j.y_m jy,s.id sid,other.x_m ox,other.y_m oy
 from signal j join game.road_segments s on
  ((s.to_junction_id=j.id and s.directionality in ('two_way','one_way_forward')) or
   (s.from_junction_id=j.id and s.directionality in ('two_way','one_way_reverse')))
 join game.road_junctions other on other.id=case when s.to_junction_id=j.id then s.from_junction_id else s.to_junction_id end
), outgoing as (
 select j.id jid,s.id sid,other.x_m ox,other.y_m oy
 from signal j join game.road_segments s on
  ((s.from_junction_id=j.id and s.directionality in ('two_way','one_way_forward')) or
   (s.to_junction_id=j.id and s.directionality in ('two_way','one_way_reverse')))
 join game.road_junctions other on other.id=case when s.from_junction_id=j.id then s.to_junction_id else s.from_junction_id end
), pairs as (
 select i.jid,i.junction_code,i.sid incoming_id,o.sid outgoing_id,
  (i.jx-i.ox)*(o.oy-i.jy)-(i.jy-i.oy)*(o.ox-i.jx) as turn_cross
 from incoming i join outgoing o on o.jid=i.jid where i.sid<>o.sid
), ranked as (
 select *,row_number() over(partition by junction_code,case when turn_cross>0 then 'no_left' else 'no_right' end order by abs(turn_cross) desc,incoming_id,outgoing_id) rn
 from pairs where turn_cross<>0
), selected as (
 select *,case when turn_cross>0 then 'no_left' else 'no_right' end turn_type from ranked where rn=1
)
insert into game.road_turn_restrictions(restriction_ref,city_id,incoming_segment_id,via_junction_id,outgoing_segment_id,
 restriction_kind,turn_type,vehicle_profiles,reason)
select 'KNG-TURN-'||junction_code||'-'||upper(turn_type),
 (select id from game.cities where code='KNG'),incoming_id,jid,outgoing_id,'prohibited',turn_type,
 array['public']::text[],'Authored city traffic order at a signalised junction; police and emergency vehicles are exempt.'
from selected
on conflict(restriction_ref) do nothing;
