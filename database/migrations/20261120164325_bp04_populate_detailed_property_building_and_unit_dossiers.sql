
insert into game.property_profiles(
 property_id,parcel_number,title_number,cadastral_block,zoning_code,permitted_uses,development_intensity,
 tenure_type,heritage_status,flood_exposure,contamination_status,assessed_land_value,assessed_improvement_value,
 assessed_currency,annual_property_charge,insurance_value,utility_connections,security_profile,fire_safety_profile,
 accessibility_profile,parcel_outline,map_label,site_description,planning_notes,last_assessed_on
)
select p.id,'KNG-CAD-'||replace(p.property_ref,'KNG-P-',''),'KNG-TITLE-'||replace(p.property_ref,'KNG-P-',''),
 d.code||'-'||n.code,
 case p.land_use when 'residential' then case when p.property_type='residential_highrise' then 'R-HIGH' else 'R-URB' end
  when 'commercial' then 'C-BUS' when 'civic_and_public' then 'CIV-PUB' when 'education_and_health' then 'INST-EH'
  when 'industrial' then 'IND-EMP' when 'logistics' then 'LOG-FRT' when 'retail_and_wholesale' then 'COM-MKT'
  when 'transport_and_commercial' then 'TRANS-MIX' when 'mixed_use' then 'MIX-URB'
  when 'aviation' then 'AIR-OPS' when 'port_and_maritime' then 'PORT-MAR' else 'MIX-GEN' end,
 case p.land_use when 'residential' then array['residential','community_facility','ground_floor_retail']
  when 'commercial' then array['office','finance','professional_services','retail']
  when 'civic_and_public' then array['government','civic','public_service']
  when 'education_and_health' then array['education','healthcare','research']
  when 'industrial' then array['manufacturing','workshop','industrial_service']
  when 'logistics' then array['warehousing','distribution','freight_forwarding']
  when 'retail_and_wholesale' then array['retail','wholesale','market','food_trade']
  when 'transport_and_commercial' then array['transport','passenger_services','commercial']
  when 'mixed_use' then array['residential','retail','office','hospitality']
  when 'aviation' then array['aviation','cargo','airport_services']
  when 'port_and_maritime' then array['port','maritime','cargo','customs_support']
  else array['general_commercial'] end,
 case when p.land_use='residential' and b.floors>=20 then 'high_density_vertical'
  when p.land_use in ('industrial','logistics','port_and_maritime','aviation') then 'large_footprint_specialist'
  when b.floors>=8 then 'high_density' when b.floors>=4 then 'medium_density' else 'low_to_medium_density' end,
 'freehold',case when exists(select 1 from game.city_landmarks lm where lm.property_id=p.id) then 'landmark' else 'none' end,
 case when d.code in ('KMX','KPT') then 'moderate' else 'low' end,
 case when p.land_use in ('industrial','logistics') then 'requires_site_history' else 'not_assessed' end,
 round(p.parcel_area_sqm::numeric*case p.land_use when 'commercial' then 1250 when 'civic_and_public' then 650
  when 'education_and_health' then 700 when 'industrial' then 320 when 'logistics' then 450
  when 'retail_and_wholesale' then 900 when 'transport_and_commercial' then 800 when 'mixed_use' then 1000
  when 'aviation' then 550 when 'port_and_maritime' then 600 when 'residential' then 500 else 400 end,2),
 round(coalesce(b.footprint_area_sqm,0)*greatest(coalesce(b.floors,1),1)*850,2),'AFC',
 round(p.parcel_area_sqm::numeric*case p.land_use when 'commercial' then 1250 when 'civic_and_public' then 650
  when 'education_and_health' then 700 when 'industrial' then 320 when 'logistics' then 450
  when 'retail_and_wholesale' then 900 when 'transport_and_commercial' then 800 when 'mixed_use' then 1000
  when 'aviation' then 550 when 'port_and_maritime' then 600 when 'residential' then 500 else 400 end*0.009,2),
 round(coalesce(b.footprint_area_sqm,0)*greatest(coalesce(b.floors,1),1)*850,2),
 jsonb_build_object('electricity','connected','water','connected','sewerage','connected','telecommunications','fibre_or_fixed',
  'stormwater','city_network','gas',case when p.land_use in ('industrial','commercial') then 'available' else 'not_recorded' end),
 jsonb_build_object('perimeter','site_specific','cctv',case when p.land_use in ('commercial','logistics','industrial','aviation','port_and_maritime') then 'multi_zone' else 'building_common_areas' end,
  'access_control',case when p.land_use in ('aviation','port_and_maritime','logistics','industrial') then 'controlled_service_and_operational_zones' else 'managed_entrances' end,
  'guarding','varies_by_occupier','alarm','building_specific'),
 jsonb_build_object('fire_service_access','road_frontage','alarm','building_specific',
  'sprinklers',case when b.floors>=8 or p.land_use in ('logistics','industrial','port_and_maritime') then 'expected' else 'building_specific' end,
  'hydrant_access','street_network'),
 jsonb_build_object('step_free_main_access','planned','lift_access',b.floors>=4,'accessible_parking','site_specific',
  'public_access',case when p.land_use in ('civic_and_public','retail_and_wholesale','commercial','mixed_use') then 'public_or_customer' else 'controlled_or_appointment' end),
 jsonb_build_object('coordinate_system','KNG-MAP-0.1','unit','metres','centre',jsonb_build_array(p.x_m,p.y_m),
  'ring',jsonb_build_array(
   jsonb_build_array(p.x_m-coalesce(p.frontage_width_m,30)/2,p.y_m-coalesce(p.parcel_area_sqm::numeric/greatest(p.frontage_width_m,1),30)/2),
   jsonb_build_array(p.x_m+coalesce(p.frontage_width_m,30)/2,p.y_m-coalesce(p.parcel_area_sqm::numeric/greatest(p.frontage_width_m,1),30)/2),
   jsonb_build_array(p.x_m+coalesce(p.frontage_width_m,30)/2,p.y_m+coalesce(p.parcel_area_sqm::numeric/greatest(p.frontage_width_m,1),30)/2),
   jsonb_build_array(p.x_m-coalesce(p.frontage_width_m,30)/2,p.y_m+coalesce(p.parcel_area_sqm::numeric/greatest(p.frontage_width_m,1),30)/2))),
 p.property_ref||' · '||coalesce(pa.formatted_address,p.address_line),
 'A '||coalesce(p.land_use,'mixed-use')||' site in '||n.name||', '||d.name||' with a mapped parcel, building, postal address and road-linked access point.',
 'Fictional local-grid parcel record. Title, occupier and building systems are held in linked property and building records.',
 date '2026-01-01'
from game.properties p join game.districts d on d.id=p.district_id
join game.neighbourhoods n on n.id=p.neighbourhood_id
left join game.buildings b on b.property_id=p.id
left join game.property_addresses pa on pa.property_id=p.id and pa.is_primary
where not exists(select 1 from game.property_profiles pp where pp.property_id=p.id);

insert into game.building_profiles(
 building_id,architectural_style,structural_system,roof_form,exterior_materials,basement_levels,
 gross_floor_area_sqm,estimated_height_m,construction_year,last_major_renovation_year,condition_grade,
 lift_count,stairwell_count,fire_compartment_count,sprinklered,fire_alarm_type,backup_power,generator_capacity_kva,
 cctv_coverage,access_control_type,loading_bay_count,dock_door_count,parking_capacity,service_yard_area_sqm,
 floor_directory,footprint_outline,building_description,building_systems
)
select b.id,
 case when b.building_type='residential_tower' then 'contemporary metropolitan residential tower'
  when b.building_type like '%office%' then 'modern commercial office'
  when b.building_type like '%logistics%' or b.building_type like '%port%' then 'industrial logistics and trade structure'
  when b.building_type like '%market%' then 'urban market and retail complex'
  when b.building_type like '%transport%' then 'transport interchange commercial structure'
  else 'functional urban institutional or commercial architecture' end,
 case when b.construction_type='reinforced_concrete' then 'reinforced_concrete_frame'
  when b.construction_type like '%steel%' then 'steel_portal_or_composite_frame' else 'masonry_or_concrete_load_bearing' end,
 case when b.building_type like '%warehouse%' or b.building_type like '%logistics%' then 'long_span_metal_roof' else 'flat_or_low_pitch_roof' end,
 case when b.construction_type='reinforced_concrete' then array['reinforced_concrete','glass','aluminium']
  when b.construction_type like '%steel%' then array['steel','concrete','metal_cladding'] else array['masonry','concrete','render'] end,
 case when b.floors>=20 then 2 when b.floors>=8 then 1 else 0 end,
 coalesce(b.footprint_area_sqm,1000)*greatest(coalesce(b.floors,1),1),greatest(coalesce(b.floors,1),1)*3.4,
 case when b.floors>=20 then 2018 else 1995 end,case when b.floors>=20 then 2024 else null end,'good',
 case when b.floors>=20 then 4 when b.floors>=8 then 2 else 0 end,
 case when b.floors>=20 then 4 when b.floors>=8 then 3 else 2 end,
 case when b.floors>=20 then 32 when b.floors>=8 then 12 else 4 end,
 (b.floors>=8 or b.building_type like '%warehouse%' or b.building_type like '%logistics%'),
 case when b.floors>=8 then 'addressable_automatic_detection' else 'conventional_or_addressable_detection' end,
 (b.floors>=8 or b.building_type like '%logistics%' or b.building_type like '%port%'),
 case when b.floors>=20 then 1500 when b.floors>=8 then 600 else 0 end,
 case when b.building_type like '%office%' or b.building_type like '%tower%' or b.building_type like '%logistics%' then 'multi_zone' else 'common_area_or_site_specific' end,
 case when b.floors>=8 then 'electronic_keycard_and_lift_control' else 'managed_keys_or_site_control' end,
 case when b.building_type like '%logistics%' or b.building_type like '%port%' then 6 when b.building_type like '%industrial%' then 3 else 0 end,
 case when b.building_type like '%logistics%' or b.building_type like '%port%' then 12 else 0 end,
 case when b.floors>=20 then 120 when b.building_type like '%commercial%' then 80 else 20 end,
 case when b.building_type like '%logistics%' or b.building_type like '%port%' then 2500 else 0 end,
 (select coalesce(jsonb_agg(jsonb_build_object('floor',g,'label',case when g=0 then 'Ground' else 'Level '||lpad(g::text,2,'0') end,
   'primary_use',case when b.building_type='residential_tower' then case when g=0 then 'lobby_and_resident_services' else 'residential' end
    when b.building_type like '%market%' then 'retail_and_market'
    when b.building_type like '%logistics%' or b.building_type like '%port%' then 'trade_and_warehouse'
    when b.building_type like '%transport%' then 'passenger_and_transport_commercial' else 'office_or_commercial' end)
   ),'[]'::jsonb) from generate_series(0,greatest(coalesce(b.floors,1)-1,0)) as floors(g)),
 jsonb_build_object('coordinate_system','KNG-MAP-0.1','unit','metres','centre',jsonb_build_array(b.x_m,b.y_m),
  'width_m',b.footprint_width_m,'depth_m',b.footprint_depth_m),
 coalesce(b.name,b.building_ref)||' is a '||coalesce(b.building_type,'building')||' with '||
 coalesce(b.floors,1)::text||' floors and a mapped building footprint, floor directory and linked premises.',
 jsonb_build_object('electricity','mains','water','mains','sewerage','mains','telecommunications','fixed_and_mobile',
  'vertical_transport',case when b.floors>=4 then 'lifts_and_stairs' else 'stairs' end,
  'fire_systems',case when b.floors>=8 then 'automatic_detection_and_suppression' else 'building_specific' end,
  'backup_power',b.floors>=8)
from game.buildings b
where not exists(select 1 from game.building_profiles bp where bp.building_id=b.id);

insert into game.building_unit_profiles(
 building_unit_id,floor_number,suite_code,use_class,internal_area_sqm,occupancy_capacity,bedroom_count,bathroom_count,
 utility_meter_refs,access_notes,security_zone,condition_grade,unit_description
)
select bu.id,
 case when bu.floor_label ~ '[0-9]+' then substring(bu.floor_label from '([0-9]+)')::smallint else 0 end,
 bu.unit_ref,
 case bu.unit_type when 'residential' then 'dwelling' when 'mixed_use' then 'mixed_commercial_or_residential'
  when 'whole_premises' then 'whole_building_or_primary_premises' when 'office_suite' then 'office'
  when 'warehouse_bay' then 'warehouse_and_freight' when 'industrial_unit' then 'industrial_business'
  when 'retail_unit' then 'retail' when 'transport_unit' then 'transport_services' else coalesce(bu.unit_type,'general_premises') end,
 case when bu.unit_type='residential' then 78 when bu.unit_type='office_suite' then 140
  when bu.unit_type='warehouse_bay' then 850 when bu.unit_type='industrial_unit' then 500
  when bu.unit_type='retail_unit' then 180 when bu.unit_type='transport_unit' then 220
  when bu.unit_type='mixed_use' then 160 else greatest(100,coalesce(b.footprint_area_sqm,400)) end,
 case when bu.unit_type='residential' then 4 when bu.unit_type='warehouse_bay' then 18
  when bu.unit_type='industrial_unit' then 25 when bu.unit_type='office_suite' then 35
  when bu.unit_type='retail_unit' then 25 else 40 end,
 case when bu.unit_type='residential' then 2 else null end,case when bu.unit_type='residential' then 2 else null end,
 jsonb_build_object('electricity','unit_meter','water','building_meter_or_submeter','telecom','building_distribution'),
 case when bu.unit_type='residential' then 'Resident entrance and common lift/stair core'
  when bu.unit_type='warehouse_bay' then 'Service yard and goods access' else 'Building reception or controlled shared access' end,
 case when bu.unit_type='residential' then 'residential' when bu.unit_type in ('warehouse_bay','industrial_unit') then 'operational' else 'commercial' end,
 'good',bu.unit_name||' in '||coalesce(b.name,b.building_ref)||', '||coalesce(bu.floor_label,'floor not specified')||
 '; linked to the canonical property, building, postal address and access point.'
from game.building_units bu join game.buildings b on b.id=bu.building_id
where not exists(select 1 from game.building_unit_profiles up where up.building_unit_id=bu.id);
