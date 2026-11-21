-- Read-only BP-04 individual building-unit export.
-- Run once per neighbourhood by changing the code in the final WHERE clause.
-- Save the returned unit_dossier JSON as data/units/<NEIGHBOURHOOD-CODE>.json.
-- The browser loads only the selected building's neighbourhood file on demand.
select jsonb_build_object(
 'neighbourhood_code',n.code,
 'neighbourhood_name',n.name,
 'units',jsonb_agg(jsonb_strip_nulls(jsonb_build_object(
  'ref',u.unit_ref,'building_ref',b.building_ref,'property_ref',p.property_ref,
  'name',u.unit_name,'type',u.unit_type,'floor',u.floor_label,'parent_ref',pu.unit_ref,
  'profile',case when up.building_unit_id is null then null else jsonb_strip_nulls(jsonb_build_object(
   'floor_number',up.floor_number,'suite_code',up.suite_code,'use_class',up.use_class,
   'area_sqm',up.internal_area_sqm,'capacity',up.occupancy_capacity,
   'bedrooms',up.bedroom_count,'bathrooms',up.bathroom_count,
   'security_zone',up.security_zone,'condition',up.condition_grade)) end,
  'infrastructure',case when ip.building_unit_id is null then null else jsonb_strip_nulls(jsonb_build_object(
   'electrical',ip.electrical_supply_status,'water',ip.water_supply_status,
   'wastewater',ip.wastewater_status,'gas',ip.gas_supply_status,
   'telecoms',ip.telecoms_status,'heating_cooling',ip.heating_cooling_status,
   'fire_detection',ip.fire_detection_status,'fire_suppression',ip.fire_suppression_status,
   'access_control',ip.access_control_status)) end
 )) order by u.unit_ref)
) as unit_dossier
from game.neighbourhoods n
join game.properties p on p.neighbourhood_id=n.id
join game.buildings b on b.property_id=p.id
join game.building_units u on u.building_id=b.id
left join game.building_units pu on pu.id=u.parent_unit_id
left join game.building_unit_profiles up on up.building_unit_id=u.id
left join game.building_unit_infrastructure_profiles ip on ip.building_unit_id=u.id
where n.code='KDW-01'
group by n.code,n.name;
