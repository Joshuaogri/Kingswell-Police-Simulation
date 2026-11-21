-- BP-04: individualise property planning/site dossiers and building system design profiles.
-- Existing canonical records are updated in place. No event, inspection, approval or ownership is fabricated.

with property_context as (
  select
    p.id,
    p.property_ref,
    p.property_type,
    p.land_use,
    p.parcel_area_sqm,
    p.frontage_width_m,
    p.status,
    p.address_line,
    pp.zoning_code,
    pp.permitted_uses,
    pp.development_intensity,
    count(distinct b.id)::int as building_count,
    count(distinct bu.id)::int as premises_count
  from game.properties p
  join game.property_profiles pp on pp.property_id = p.id
  left join game.buildings b on b.property_id = p.id
  left join game.building_units bu on bu.building_id = b.id
  group by p.id, pp.property_id
)
update game.property_profiles pp
set
  site_description = format(
    '%s (%s) is a %s site with a recorded parcel area of %s sqm and approximately %s m of road frontage. The linked property directory contains %s building(s) and %s separately identified premises. Current site status: %s. The parcel and access geometry are schematic Kingswell map records; this description is a seeded site summary, not a survey or inspection report.',
    coalesce(nullif(pc.address_line, ''), pc.property_ref),
    pc.property_ref,
    replace(coalesce(pc.property_type, 'classified'), '_', ' '),
    pc.parcel_area_sqm,
    round(coalesce(pc.frontage_width_m, 0)::numeric, 1),
    pc.building_count,
    pc.premises_count,
    replace(coalesce(pc.status, 'status not recorded'), '_', ' ')
  ),
  planning_notes = format(
    'Planning profile for %s. Recorded zoning: %s. Permitted-use classifications: %s. Development-intensity classification: %s. Land-use classification: %s. This is a summary of the current seeded property profile only. No planning application, decision notice, condition discharge, completion certificate, enforcement action or dated development history is asserted by this record; those remain unrecorded until separately authored as fictional canon.',
    pc.property_ref,
    coalesce(pc.zoning_code, 'not recorded'),
    coalesce(array_to_string(pc.permitted_uses, ', '), 'not recorded'),
    coalesce(pc.development_intensity, 'not recorded'),
    coalesce(pc.land_use, 'not recorded')
  ),
  profile_version = pp.profile_version + 1,
  updated_at = now()
from property_context pc
where pp.property_id = pc.id;

update game.building_profiles bp
set building_systems =
  coalesce(bp.building_systems, '{}'::jsonb)
  || jsonb_build_object(
    'system_design_profile', jsonb_build_object(
      'profile_basis', 'fictional_seeded_design_profile',
      'profile_scope', 'building_level_system_summary',
      'inspection_status', 'not_recorded',
      'asset_level_inventory', 'not_seeded',
      'electrical_distribution', case mod(abs(hashtext(b.building_ref)::bigint), 4)
        when 0 then 'central_main_switchboard_with_floor_distribution'
        when 1 then 'main_switchboard_with_zoned_subpanels'
        when 2 then 'metered_service_with_local_distribution_boards'
        else 'dedicated_building_supply_with_subdistribution'
      end,
      'heating_cooling_ventilation', case mod(abs(hashtext(b.building_ref)::bigint), 5)
        when 0 then 'central_mechanical_ventilation_and_conditioned_air'
        when 1 then 'zoned_mechanical_ventilation_and_cooling'
        when 2 then 'mixed_mechanical_and_local_conditioning'
        when 3 then 'local_conditioning_with_extract_ventilation'
        else 'natural_ventilation_with_local_conditioning_where_required'
      end,
      'water_distribution', case mod(abs(hashtext(b.building_ref)::bigint), 3)
        when 0 then 'mains_supply_with_building_distribution'
        when 1 then 'mains_supply_with_zoned_internal_distribution'
        else 'mains_supply_with_localised_boosting_or_storage_design'
      end,
      'fire_protection_summary', jsonb_build_object(
        'alarm_type', bp.fire_alarm_type,
        'sprinklered', bp.sprinklered,
        'compartment_count', bp.fire_compartment_count,
        'inspection_status', 'not_recorded'
      ),
      'vertical_transport_summary', jsonb_build_object(
        'floor_count', b.floors,
        'lift_count', bp.lift_count,
        'stairwell_count', bp.stairwell_count,
        'design_note', case when coalesce(bp.lift_count, 0) > 0
          then 'Lift and stair provision recorded in the building profile'
          else 'Stair provision recorded; no lift count recorded'
        end
      ),
      'backup_power_summary', jsonb_build_object(
        'backup_power_recorded', bp.backup_power,
        'generator_capacity_kva', bp.generator_capacity_kva,
        'equipment_inventory_status', 'not_recorded'
      ),
      'security_and_access_summary', jsonb_build_object(
        'cctv_coverage_profile', bp.cctv_coverage,
        'access_control_profile', bp.access_control_type,
        'camera_device_inventory', 'not_seeded',
        'access_event_history', 'not_recorded'
      ),
      'building_use_classification', replace(b.building_type, '_', ' ')
    ),
    'profile_provenance', jsonb_build_object(
      'source', 'Kingswell fictional seeded building and profile fields',
      'method', 'deterministic classification from existing building reference and recorded profile attributes',
      'not_evidence_of', jsonb_build_array('physical inspection', 'installed device inventory', 'maintenance completion', 'live system operation')
    )
  ),
  updated_at = now()
from game.buildings b
where b.id = bp.building_id;

-- Fail the migration if canonical profile coverage or the new provenance is incomplete.
do $$
begin
  if (select count(*) from game.property_profiles) <> 656 then
    raise exception 'BP-04 property profile population changed unexpectedly';
  end if;
  if exists (
    select 1 from game.property_profiles
    where site_description is null or planning_notes is null
  ) then
    raise exception 'BP-04 property dossier enrichment left blank descriptions or planning summaries';
  end if;
  if (select count(*) from game.building_profiles) <> 656 then
    raise exception 'BP-04 building profile population changed unexpectedly';
  end if;
  if exists (
    select 1 from game.building_profiles
    where not (building_systems ? 'system_design_profile')
       or not (building_systems ? 'profile_provenance')
       or building_systems #>> '{system_design_profile,inspection_status}' <> 'not_recorded'
       or building_systems #>> '{system_design_profile,asset_level_inventory}' <> 'not_seeded'
  ) then
    raise exception 'BP-04 building systems provenance or scope validation failed';
  end if;
end $$;
