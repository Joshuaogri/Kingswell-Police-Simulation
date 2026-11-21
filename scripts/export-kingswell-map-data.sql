-- Kingswell browser-map snapshot export
-- Run against the authoritative Supabase project using a role permitted to read game.*
-- This is a read-only SELECT. It does not change the live database.
-- Save the single map_data JSON value as data/kingswell-map-data.json.

select jsonb_build_object(
  'version','KNG-MAP-0.3',
  'snapshot_date','2026-11-21',
  'city',(select jsonb_build_object('name',name,'code',code,'population',population,'width',grid_width_m,'height',grid_height_m,'orientation',map_orientation) from game.cities limit 1),
  'districts',(select jsonb_agg(jsonb_build_object('id',d.id,'code',d.code,'name',d.name,'type',d.district_type,'bounds',case when a.id is null then null else jsonb_build_array(a.min_x_m,a.min_y_m,a.max_x_m,a.max_y_m) end)) from game.districts d left join game.district_map_areas a on a.district_id=d.id),
  'neighbourhoods',(select jsonb_agg(jsonb_build_object('id',n.id,'code',n.code,'name',n.name,'district_id',n.district_id)) from game.neighbourhoods n),
  'roads',(select jsonb_agg(jsonb_build_object('id',r.id,'code',r.code,'name',r.name,'official_name',r.official_name,'type',r.road_type,'district_id',r.district_id,'maintenance',r.maintenance_class,'name_origin',r.name_origin)) from game.roads r),
  'segments',(select jsonb_agg(jsonb_build_object('id',s.id,'code',s.segment_code,'road_id',s.road_id,'length',s.segment_length_m,'class',s.road_class,'lanes',s.lanes_each_direction,'speed_kph',s.speed_limit_kph,'direction',s.directionality,'surface',s.surface_type,'access',s.access_profile,'routable',s.is_routable,'width',s.carriageway_width_m,'marking',s.lane_marking,'median',s.median_type,'sidewalk',s.has_sidewalk,'cycle_lane',s.has_cycle_lane,'lighting',s.has_street_lighting,'parking',s.has_on_street_parking,'condition',s.road_condition,'elevation_change',s.elevation_change_m,'geometry_source',s.geometry_source,'geometry',s.geometry_local_m)) from game.road_segments s),
  'junctions',(select jsonb_agg(jsonb_build_object('id',j.id,'code',j.junction_code,'name',j.junction_name,'x',j.x_m,'y',j.y_m,'type',j.junction_type,'access',j.access_profile,'control',j.control_type,'signal_cycle',j.signal_cycle_seconds,'pedestrian',j.pedestrian_crossing,'tactile',j.tactile_crossing,'lighting',j.lighting_standard,'grade',j.grade_separation_m)) from game.road_junctions j),
  'access_points',(select jsonb_agg(jsonb_build_object('id',a.id,'ref',a.access_ref,'property_id',a.property_id,'building_id',a.building_id,'segment_id',a.road_segment_id,'junction_id',a.nearest_junction_id,'type',a.access_type,'x',a.x_m,'y',a.y_m,'profile',a.access_profile,'primary',a.is_primary)) from game.property_access_points a),
  'landmarks',(select jsonb_agg(jsonb_build_object('id',l.id,'ref',l.landmark_ref,'name',l.name,'type',l.landmark_type,'property_id',l.property_id,'building_id',l.building_id,'access_id',l.access_point_id,'x',l.x_m,'y',l.y_m,'public_access',l.public_access,'significance',l.significance)) from game.city_landmarks l),
  'turn_restrictions',(select jsonb_agg(jsonb_build_object('id',t.id,'ref',t.restriction_ref,'junction_id',t.via_junction_id,'kind',t.restriction_kind,'turn',t.turn_type,'vehicles',t.vehicle_profiles,'active',t.active,'reason',t.reason)) from game.road_turn_restrictions t),
  'patrol_coverage',(select jsonb_agg(jsonb_build_object('segment_id',prs.road_segment_id,'beat_ref',pb.beat_ref,'beat_name',pb.beat_name,'beat_type',pb.beat_type,'beat_status',pb.status,'coverage_order',prs.coverage_order,'role',prs.coverage_role)) from game.patrol_beat_road_segments prs join game.patrol_beats pb on pb.id=prs.beat_id),
  'properties',(select jsonb_agg(jsonb_build_object(
    'id',p.id,'ref',p.property_ref,'address',p.address_line,'number',p.street_number,'road_id',p.road_id,'district_id',p.district_id,'neighbourhood_id',p.neighbourhood_id,'type',p.property_type,'land_use',p.land_use,'status',p.status,'x',p.x_m,'y',p.y_m,'area',p.parcel_area_sqm,'frontage',p.frontage_width_m,'postal',p.postal_code,
    'building',jsonb_build_object('id',b.id,'ref',b.building_ref,'name',b.name,'type',b.building_type,'floors',b.floors,'x',b.x_m,'y',b.y_m,'width',b.footprint_width_m,'depth',b.footprint_depth_m,'area',b.footprint_area_sqm,'construction',b.construction_type,'occupancy',b.occupancy_status),
    'unit_count',(select count(*) from game.building_units u where u.building_id=b.id),
    'unit_mix',(select coalesce(jsonb_object_agg(unit_type,n), '{}'::jsonb) from (select unit_type,count(*) n from game.building_units u where u.building_id=b.id group by unit_type) z),
    'sites',(select jsonb_agg(jsonb_build_object('id',ol.id,'ref',ol.site_ref,'name',ol.site_name,'role',ol.location_role,'status',ol.occupancy_status,'organisation_id',ol.organisation_id)) from game.organisation_locations ol where ol.property_id=p.id),
    'businesses',(select jsonb_agg(jsonb_build_object('organisation_id',bp.organisation_id,'number',bp.business_number,'name',bp.trading_name,'sector',bp.sector,'subsector',bp.subsector,'size',bp.business_size,'employees',bp.estimated_employee_count)) from game.organisation_locations ol join game.business_profiles bp on bp.organisation_id=ol.organisation_id where ol.property_id=p.id)
  )) from game.properties p join game.buildings b on b.property_id=p.id)
) as map_data;
