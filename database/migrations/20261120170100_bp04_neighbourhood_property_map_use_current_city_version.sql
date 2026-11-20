-- BP-04 map query must report the same version as the authoritative BP-02 city record.
create or replace function game.get_neighbourhood_property_map(p_neighbourhood_code text)
returns jsonb language sql stable as $$
 select jsonb_build_object(
  'map_version',c.map_version,'coordinate_system',c.map_version,'units','metres','orientation','north_up',
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
   'access_points',(select coalesce(jsonb_agg(jsonb_build_object('access_ref',ap.access_ref,'type',ap.access_type,'x_m',ap.x_m,'y_m',ap.y_m,'access_profile',ap.access_profile) order by ap.is_primary desc,ap.access_ref),'[]'::jsonb) from game.property_access_points ap where ap.property_id=p.id),
   'buildings',(select coalesce(jsonb_agg(jsonb_build_object('building_ref',b.building_ref,'name',b.name,'type',b.building_type,
    'floors',b.floors,'footprint_area_sqm',b.footprint_area_sqm,'height_m',bp.estimated_height_m,'footprint_outline',bp.footprint_outline,
    'condition',bp.condition_grade,'units',(select count(*) from game.building_units u where u.building_id=b.id),
    'businesses',(select count(*) from game.organisation_locations ol where ol.property_id=p.id and ol.building_unit_id in
      (select u.id from game.building_units u where u.building_id=b.id) and ol.valid_to is null)
   ) order by b.building_ref),'[]'::jsonb) from game.buildings b left join game.building_profiles bp on bp.building_id=b.id where b.property_id=p.id),
   'primary_occupiers',(select coalesce(jsonb_agg(jsonb_build_object('name',o.name,'role',ol.location_role,'unit_ref',u.unit_ref,'sector',biz.sector) order by o.name),'[]'::jsonb)
    from game.organisation_locations ol join game.organisations o on o.id=ol.organisation_id left join game.business_profiles biz on biz.organisation_id=o.id
    left join game.building_units u on u.id=ol.building_unit_id where ol.property_id=p.id and ol.valid_to is null)
  ) order by p.property_ref) from game.properties p left join game.property_profiles pp on pp.property_id=p.id
   left join game.property_addresses pa on pa.property_id=p.id and pa.is_primary left join game.roads r on r.id=p.road_id
   where p.neighbourhood_id=n.id),'[]'::jsonb)
 )
 from game.neighbourhoods n join game.districts d on d.id=n.district_id join game.cities c on c.id=d.city_id
 where n.code=p_neighbourhood_code;
$$;
