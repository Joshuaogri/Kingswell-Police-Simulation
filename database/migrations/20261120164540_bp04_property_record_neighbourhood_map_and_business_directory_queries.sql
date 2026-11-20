create or replace function game.get_property_record(p_property_ref text)
returns jsonb language sql stable as $$
 select jsonb_build_object(
  'property',to_jsonb(p),
  'district',jsonb_build_object('code',d.code,'name',d.name,'type',d.district_type),
  'neighbourhood',jsonb_build_object('code',n.code,'name',n.name),
  'road',jsonb_build_object('name',r.name,'type',r.road_type),
  'profile',to_jsonb(pp),
  'addresses',coalesce((select jsonb_agg(to_jsonb(a) order by a.is_primary desc,a.address_ref) from game.property_addresses a where a.property_id=p.id),'[]'::jsonb),
  'access_points',coalesce((select jsonb_agg(jsonb_build_object('access',to_jsonb(ap),'road_segment',to_jsonb(rs),
    'nearest_junction',jsonb_build_object('code',j.junction_code,'name',j.junction_name,'x_m',j.x_m,'y_m',j.y_m))
    order by ap.is_primary desc,ap.access_ref)
    from game.property_access_points ap join game.road_segments rs on rs.id=ap.road_segment_id
    join game.road_junctions j on j.id=ap.nearest_junction_id where ap.property_id=p.id),'[]'::jsonb),
  'interests',coalesce((select jsonb_agg(jsonb_build_object('interest',to_jsonb(pi),'holder',to_jsonb(o)) order by pi.interest_type,pi.valid_from)
    from game.property_interest_records pi left join game.organisations o on o.id=pi.holder_organisation_id where pi.property_id=p.id),'[]'::jsonb),
  'buildings',coalesce((select jsonb_agg(jsonb_build_object('building',to_jsonb(b),'profile',to_jsonb(bp),
    'units',(select coalesce(jsonb_agg(jsonb_build_object('unit',to_jsonb(u),'profile',to_jsonb(up),
      'occupiers',(select coalesce(jsonb_agg(jsonb_build_object('organisation',to_jsonb(oo),'business',to_jsonb(biz),'site',to_jsonb(ol))),'[]'::jsonb)
       from game.organisation_locations ol join game.organisations oo on oo.id=ol.organisation_id
       left join game.business_profiles biz on biz.organisation_id=oo.id
       where ol.building_unit_id=u.id and ol.valid_to is null))
      order by up.floor_number,u.unit_ref),'[]'::jsonb)
     from game.building_units u left join game.building_unit_profiles up on up.building_unit_id=u.id where u.building_id=b.id))
    order by b.building_ref) from game.buildings b left join game.building_profiles bp on bp.building_id=b.id where b.property_id=p.id),'[]'::jsonb)
 )
 from game.properties p join game.districts d on d.id=p.district_id
 join game.neighbourhoods n on n.id=p.neighbourhood_id
 left join game.roads r on r.id=p.road_id left join game.property_profiles pp on pp.property_id=p.id
 where p.property_ref=p_property_ref;
$$;

create or replace function game.get_neighbourhood_property_map(p_neighbourhood_code text)
returns jsonb language sql stable as $$
 select jsonb_build_object(
  'map_version',c.map_version,'coordinate_system','KNG-MAP-0.1','units','metres','orientation','north_up',
  'city',jsonb_build_object('code',c.code,'name',c.name,'grid_width_m',c.grid_width_m,'grid_height_m',c.grid_height_m),
  'district',jsonb_build_object('code',d.code,'name',d.name,'district_type',d.district_type),
  'neighbourhood',jsonb_build_object('code',n.code,'name',n.name),
  'property_count',(select count(*) from game.properties x where x.neighbourhood_id=n.id),
  'building_count',(select count(*) from game.buildings b join game.properties x on x.id=b.property_id where x.neighbourhood_id=n.id),
  'unit_count',(select count(*) from game.building_units u join game.buildings b on b.id=u.building_id join game.properties x on x.id=b.property_id where x.neighbourhood_id=n.id),
  'properties',coalesce((select jsonb_agg(jsonb_build_object(
   'property_ref',p.property_ref,'property_type',p.property_type,'land_use',p.land_use,'centre',jsonb_build_array(p.x_m,p.y_m),
   'parcel_area_sqm',p.parcel_area_sqm,'frontage_width_m',p.frontage_width_m,'parcel_outline',pp.parcel_outline,
   'map_label',pp.map_label,'site_description',pp.site_description,'address',pa.formatted_address,'road',r.name,
   'access_points',(select coalesce(jsonb_agg(jsonb_build_object('access_ref',ap.access_ref,'type',ap.access_type,'x_m',ap.x_m,'y_m',ap.y_m,'access_profile',ap.access_profile) order by ap.is_primary desc,ap.access_ref),'[]'::jsonb)
    from game.property_access_points ap where ap.property_id=p.id),
   'buildings',(select coalesce(jsonb_agg(jsonb_build_object('building_ref',b.building_ref,'name',b.name,'type',b.building_type,
    'floors',b.floors,'footprint_area_sqm',b.footprint_area_sqm,'height_m',bp.estimated_height_m,
    'footprint_outline',bp.footprint_outline,'condition',bp.condition_grade,
    'units',(select count(*) from game.building_units u where u.building_id=b.id),
    'businesses',(select count(*) from game.organisation_locations ol where ol.property_id=p.id and ol.building_unit_id in
      (select u.id from game.building_units u where u.building_id=b.id) and ol.valid_to is null)
   ) order by b.building_ref),'[]'::jsonb) from game.buildings b left join game.building_profiles bp on bp.building_id=b.id where b.property_id=p.id),
   'primary_occupiers',(select coalesce(jsonb_agg(jsonb_build_object('name',o.name,'role',ol.location_role,'unit_ref',u.unit_ref,'sector',biz.sector) order by o.name),'[]'::jsonb)
    from game.organisation_locations ol join game.organisations o on o.id=ol.organisation_id
    left join game.business_profiles biz on biz.organisation_id=o.id
    left join game.building_units u on u.id=ol.building_unit_id
    where ol.property_id=p.id and ol.valid_to is null)
  ) order by p.property_ref)
  from game.properties p left join game.property_profiles pp on pp.property_id=p.id
  left join game.property_addresses pa on pa.property_id=p.id and pa.is_primary
  left join game.roads r on r.id=p.road_id where p.neighbourhood_id=n.id),'[]'::jsonb)
 )
 from game.neighbourhoods n join game.districts d on d.id=n.district_id
 join game.cities c on c.id=d.city_id where n.code=p_neighbourhood_code;
$$;

create or replace function game.list_business_directory(
 p_sector text default null,p_district_code text default null,p_search text default null,p_limit integer default 100
)
returns table(
 business_number text,organisation_ref text,business_name text,sector text,subsector text,business_size text,
 estimated_employee_count integer,import_export_activity text,property_ref text,unit_ref text,formatted_address text,
 district_code text,neighbourhood_code text,location_role text
)
language sql stable as $$
 select bp.business_number,o.organisation_ref,o.name,bp.sector,bp.subsector,bp.business_size,bp.estimated_employee_count,
  bp.import_export_activity,p.property_ref,u.unit_ref,pa.formatted_address,d.code,n.code,ol.location_role
 from game.business_profiles bp join game.organisations o on o.id=bp.organisation_id
 join game.organisation_locations ol on ol.organisation_id=o.id and ol.valid_to is null
 join game.properties p on p.id=ol.property_id join game.districts d on d.id=p.district_id
 join game.neighbourhoods n on n.id=p.neighbourhood_id left join game.building_units u on u.id=ol.building_unit_id
 left join game.property_addresses pa on pa.property_id=p.id and pa.is_primary
 where (p_sector is null or bp.sector=p_sector) and (p_district_code is null or d.code=p_district_code)
  and (p_search is null or o.name ilike '%'||p_search||'%' or bp.business_number ilike '%'||p_search||'%')
 order by bp.sector,o.name limit greatest(1,least(coalesce(p_limit,100),500));
$$;

create or replace function game.get_city_property_summary(p_city_code text)
returns jsonb language sql stable as $$
 select jsonb_build_object(
  'city',jsonb_build_object('code',c.code,'name',c.name,'baseline_population',c.population,
   'grid_width_m',c.grid_width_m,'grid_height_m',c.grid_height_m,'map_version',c.map_version),
  'totals',jsonb_build_object(
   'properties',(select count(*) from game.properties p where p.city_id=c.id),
   'buildings',(select count(*) from game.buildings b join game.properties p on p.id=b.property_id where p.city_id=c.id),
   'building_units',(select count(*) from game.building_units u join game.buildings b on b.id=u.building_id join game.properties p on p.id=b.property_id where p.city_id=c.id),
   'residential_units',(select count(*) from game.building_units u join game.buildings b on b.id=u.building_id join game.properties p on p.id=b.property_id where p.city_id=c.id and u.unit_type='residential'),
   'businesses',(select count(*) from game.business_profiles),'organisations',(select count(*) from game.organisations),
   'estimated_business_employees',(select coalesce(sum(estimated_employee_count),0) from game.business_profiles)),
  'districts',(select coalesce(jsonb_agg(jsonb_build_object('district_code',d.code,'district_name',d.name,
   'properties',(select count(*) from game.properties p where p.district_id=d.id),
   'buildings',(select count(*) from game.buildings b join game.properties p on p.id=b.property_id where p.district_id=d.id),
   'units',(select count(*) from game.building_units u join game.buildings b on b.id=u.building_id join game.properties p on p.id=b.property_id where p.district_id=d.id),
   'businesses',(select count(*) from game.business_profiles bp join game.organisation_locations ol on ol.organisation_id=bp.organisation_id and ol.valid_to is null join game.properties p on p.id=ol.property_id where p.district_id=d.id)
  ) order by d.code),'[]'::jsonb) from game.districts d where d.city_id=c.id),
  'land_use',(select coalesce(jsonb_agg(jsonb_build_object('land_use',q.land_use,'property_count',q.n) order by q.land_use),'[]'::jsonb)
   from (select p.land_use,count(*) n from game.properties p where p.city_id=c.id group by p.land_use) q),
  'business_sectors',(select coalesce(jsonb_agg(jsonb_build_object('sector',q.sector,'business_count',q.n) order by q.sector),'[]'::jsonb)
   from (select bp.sector,count(*) n from game.business_profiles bp group by bp.sector) q)
 ) from game.cities c where c.code=p_city_code;
$$;
revoke all on function game.get_property_record(text) from public,anon,authenticated;
revoke all on function game.get_neighbourhood_property_map(text) from public,anon,authenticated;
revoke all on function game.list_business_directory(text,text,text,integer) from public,anon,authenticated;
revoke all on function game.get_city_property_summary(text) from public,anon,authenticated;
grant execute on function game.get_property_record(text) to service_role;
grant execute on function game.get_neighbourhood_property_map(text) to service_role;
grant execute on function game.list_business_directory(text,text,text,integer) to service_role;
grant execute on function game.get_city_property_summary(text) to service_role;
