-- Rollback-only verification for Kingswell police facilities and patrol geography.
begin;
do $$
declare
 v_count integer;
begin
 select count(*) into v_count from game.police_facilities;
 if v_count <> 18 then raise exception 'Expected 18 police facilities, got %',v_count; end if;
 select count(*) into v_count from game.police_stations;
 if v_count <> 13 then raise exception 'Expected HQ plus 12 district stations, got %',v_count; end if;
 select count(*) into v_count from game.patrol_sectors;
 if v_count <> 12 then raise exception 'Expected 12 patrol sectors, got %',v_count; end if;
 select count(*) into v_count from game.patrol_beats;
 if v_count <> 24 then raise exception 'Expected 24 neighbourhood beats, got %',v_count; end if;
 select count(*) into v_count from game.patrol_beat_road_segments;
 if v_count <> 151 then raise exception 'Expected 151 road-segment coverage links, got %',v_count; end if;
 if exists(select 1 from game.police_facilities f
   left join game.properties p on p.id=f.property_id
   left join game.buildings b on b.id=f.building_id and b.property_id=f.property_id
   left join game.property_addresses a on a.id=f.address_id and a.property_id=f.property_id
   left join game.property_access_points ap on ap.id=f.access_point_id and ap.property_id=f.property_id
   where p.id is null or b.id is null or a.id is null or ap.id is null
      or f.district_id<>p.district_id or f.neighbourhood_id<>p.neighbourhood_id
      or f.x_m<>p.x_m or f.y_m<>p.y_m)
 then raise exception 'Facility property/building/address/access linkage invalid'; end if;
 if exists(select 1 from game.neighbourhoods n
   left join game.patrol_beats b on b.neighbourhood_id=n.id
   where b.id is null or b.district_id<>n.district_id)
 then raise exception 'Neighbourhood beat coverage incomplete or assigned to wrong district'; end if;
 if exists(select 1 from game.road_segments r where r.is_routable
   and not exists(select 1 from game.patrol_beat_road_segments x where x.road_segment_id=r.id))
 then raise exception 'A routable road segment has no beat coverage'; end if;
 if exists(select 1 from game.patrol_beat_road_segments x
   join game.patrol_beats b on b.id=x.beat_id
   join game.neighbourhoods n on n.id=b.neighbourhood_id
   join game.districts d on d.id=b.district_id
   where n.district_id<>d.id)
 then raise exception 'Beat/sector district hierarchy invalid'; end if;
 if exists(select 1 from (values
 ('police_facilities'),('patrol_sectors'),('patrol_beats'),('patrol_beat_road_segments')
 ) t(name) where not (select c.relrowsecurity from pg_class c join pg_namespace ns on ns.oid=c.relnamespace where ns.nspname='game' and c.relname=t.name))
 then raise exception 'RLS missing on a new private table'; end if;
 if exists(select 1 from game.police_stations s where s.facility_id is null)
 then raise exception 'A seeded station is not linked to a facility'; end if;
end $$;
rollback;
