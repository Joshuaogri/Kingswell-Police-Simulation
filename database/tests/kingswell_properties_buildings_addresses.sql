-- Kingswell BP-02 property/building/address/landmark regression.
begin;
do $$
declare v_city uuid; v_n integer; v_bad integer;
begin
 select id into v_city from game.cities where code='KNG';
 if v_city is null then raise exception 'Kingswell city missing'; end if;
 select count(*) into v_n from game.properties where city_id=v_city and property_ref not like 'KNG-P-RH%' and property_ref not like 'KNG-P-CM%';
 if v_n<>480 then raise exception 'Expected 480 properties; found %',v_n; end if;
 select count(*) into v_n from game.buildings b join game.properties p on p.id=b.property_id where p.city_id=v_city and p.property_ref not like 'KNG-P-RH%' and p.property_ref not like 'KNG-P-CM%';
 if v_n<>480 then raise exception 'Expected 480 baseline buildings; found %',v_n; end if;
 select count(*) into v_n from game.building_units u join game.buildings b on b.id=u.building_id join game.properties p on p.id=b.property_id where p.city_id=v_city and p.property_ref not like 'KNG-P-RH%' and p.property_ref not like 'KNG-P-CM%';
 if v_n<>712 then raise exception 'Expected 712 baseline building units; found %',v_n; end if;
 select count(*) into v_n from game.property_addresses a join game.properties p on p.id=a.property_id where p.city_id=v_city and p.property_ref not like 'KNG-P-RH%' and p.property_ref not like 'KNG-P-CM%';
 if v_n<>480 then raise exception 'Expected 480 baseline addresses; found %',v_n; end if;
 select count(*) into v_n from game.property_access_points a join game.properties p on p.id=a.property_id where p.city_id=v_city and p.property_ref not like 'KNG-P-RH%' and p.property_ref not like 'KNG-P-CM%' and a.is_primary;
 if v_n<>480 then raise exception 'Expected 480 baseline primary access points; found %',v_n; end if;
 select count(*) into v_bad from game.properties where city_id=v_city
 and (x_m<0 or x_m>20000 or y_m<0 or y_m>16000);
 if v_bad<>0 then raise exception 'Properties outside the canonical Kingswell local grid: %',v_bad; end if;
 select count(*) into v_bad from game.property_access_points a
 join game.properties p on p.id=a.property_id where p.city_id=v_city
 and (a.x_m<0 or a.x_m>20000 or a.y_m<0 or a.y_m>16000);
 if v_bad<>0 then raise exception 'Property access points outside the canonical Kingswell local grid: %',v_bad; end if;
 select count(*) into v_n from game.city_landmarks where city_id=v_city;
 if v_n<>24 then raise exception 'Expected 24 landmarks; found %',v_n; end if;
 select count(*) into v_bad from game.properties p left join game.road_segments s on s.id=p.frontage_segment_id
 left join game.roads r on r.id=p.road_id left join game.districts d on d.id=p.district_id
 left join game.neighbourhoods n on n.id=p.neighbourhood_id
 where p.city_id=v_city and (p.x_m is null or p.y_m is null or p.parcel_area_sqm is null
 or p.frontage_segment_id is null or s.id is null or r.id is null or s.road_id<>r.id or d.city_id<>v_city or n.district_id<>d.id);
 if v_bad<>0 then raise exception 'Invalid property/road/district references: %',v_bad; end if;
 select count(*) into v_bad from game.properties p where p.city_id=v_city and (
 not exists(select 1 from game.buildings b where b.property_id=p.id and b.footprint_area_sqm>0)
 or not exists(select 1 from game.property_addresses a where a.property_id=p.id and a.is_primary)
 or not exists(select 1 from game.property_access_points a where a.property_id=p.id and a.is_primary));
 if v_bad<>0 then raise exception 'Property missing building/address/access: %',v_bad; end if;
 select count(*) into v_bad from game.city_landmarks l left join game.properties p on p.id=l.property_id
 left join game.buildings b on b.id=l.building_id left join game.property_access_points a on a.id=l.access_point_id
 where l.city_id=v_city and (p.city_id<>v_city or b.property_id<>p.id or a.property_id<>p.id
 or l.neighbourhood_id<>p.neighbourhood_id or l.district_id<>p.district_id);
 if v_bad<>0 then raise exception 'Landmark links invalid: %',v_bad; end if;
 select count(*) into v_bad from game.property_access_points a
 join game.properties p on p.id=a.property_id join game.road_segments s on s.id=a.road_segment_id
 join game.road_junctions jf on jf.id=s.from_junction_id join game.road_junctions jt on jt.id=s.to_junction_id
 join game.road_junctions chosen on chosen.id=a.nearest_junction_id
 where p.city_id=v_city and
 ((chosen.id=jf.id and ((jt.x_m-p.x_m)::bigint*(jt.x_m-p.x_m)::bigint+(jt.y_m-p.y_m)::bigint*(jt.y_m-p.y_m)::bigint)
 < ((jf.x_m-p.x_m)::bigint*(jf.x_m-p.x_m)::bigint+(jf.y_m-p.y_m)::bigint*(jf.y_m-p.y_m)::bigint))
 or (chosen.id=jt.id and ((jf.x_m-p.x_m)::bigint*(jf.x_m-p.x_m)::bigint+(jf.y_m-p.y_m)::bigint*(jf.y_m-p.y_m)::bigint)
 < ((jt.x_m-p.x_m)::bigint*(jt.x_m-p.x_m)::bigint+(jt.y_m-p.y_m)::bigint*(jt.y_m-p.y_m)::bigint)));
 if v_bad<>0 then raise exception 'Access points do not resolve to the nearest frontage junction: %',v_bad; end if;
 select count(*) into v_n from game.neighbourhoods n join game.districts d on d.id=n.district_id
 where d.city_id=v_city and (select count(*) from game.properties p where p.neighbourhood_id=n.id and p.property_ref not like 'KNG-P-RH%' and p.property_ref not like 'KNG-P-CM%')<>20;
 if v_n<>0 then raise exception 'Neighbourhoods not holding exactly 20 parcels: %',v_n; end if;
 select count(*) into v_n from pg_tables where schemaname='game'
 and tablename in ('properties','buildings','building_units','property_addresses','property_access_points','city_landmarks') and rowsecurity;
 if v_n<>6 then raise exception 'RLS missing from property/location tables'; end if;
end $$;
rollback;
