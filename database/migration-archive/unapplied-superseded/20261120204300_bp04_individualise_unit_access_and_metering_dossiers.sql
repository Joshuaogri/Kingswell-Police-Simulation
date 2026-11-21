-- BP-04: individualise unit/premises access and utility metering dossiers.
-- Existing unit records are enriched in place. No meter IDs, credentials or events are fabricated.
update game.building_unit_profiles up
set
 access_notes=format(
  'Seeded access dossier for %s (%s), %s, %s. Route classification: %s. Building-level access-control classification: %s. Unit-specific keys, credentials, access events and physical route survey are not recorded in this profile.',
  u.unit_name,u.unit_ref,coalesce(up.suite_code,u.unit_ref),coalesce(u.floor_label,'floor not recorded'),
  case
   when up.use_class ilike '%dwelling%' or up.use_class ilike '%residential%' then
    case mod(abs(hashtext(u.unit_ref)::bigint),3)
     when 0 then 'shared residential entrance with common corridor'
     when 1 then 'residential lobby with lift or stair circulation'
     else 'residential stair or landing approach' end
   when up.use_class ilike '%industrial%' or up.use_class ilike '%warehouse%'
    or up.use_class ilike '%storage%' or u.unit_type ilike '%warehouse%' then
    case mod(abs(hashtext(u.unit_ref)::bigint),3)
     when 0 then 'service-side circulation with controlled premises boundary'
     when 1 then 'shared industrial circulation with loading/service approach'
     else 'internal service corridor and designated premises entrance' end
   when up.use_class ilike '%retail%' or up.use_class ilike '%shop%' or up.use_class ilike '%market%' then
    case mod(abs(hashtext(u.unit_ref)::bigint),3)
     when 0 then 'customer-facing shared commercial circulation'
     when 1 then 'shopfront or internal mall circulation'
     else 'commercial entrance with shared service circulation' end
   else case mod(abs(hashtext(u.unit_ref)::bigint),4)
    when 0 then 'shared reception and internal corridor'
    when 1 then 'controlled common entrance and floor circulation'
    when 2 then 'designated premises entrance from shared circulation'
    else 'service or staff circulation within the building' end
  end,coalesce(bp.access_control_type,'not recorded')
 ),
 utility_meter_refs=coalesce(up.utility_meter_refs,'{}'::jsonb)||jsonb_build_object(
  'unit_metering_profile',jsonb_build_object(
   'profile_reference',u.unit_ref,'profile_basis','fictional_seeded_unit_service_profile',
   'electricity_arrangement',case mod(abs(hashtext(u.unit_ref)::bigint),4)
    when 0 then 'unit_meter_recorded_in_baseline'
    when 1 then 'building_supply_with_unit_submeter_model'
    when 2 then 'shared_supply_with_allocated_unit_meter_model'
    else 'dedicated_unit_distribution_model' end,
   'water_arrangement',case mod(abs(hashtext(u.unit_ref)::bigint),3)
    when 0 then 'building_meter_or_submeter_model'
    when 1 then 'shared_riser_with_unit_submeter_model'
    else 'central_supply_with_unit_allocation_model' end,
   'telecommunications_arrangement',case mod(abs(hashtext(u.unit_ref)::bigint),3)
    when 0 then 'building_distribution'
    when 1 then 'shared_riser_or_floor_distribution'
    else 'dedicated_unit_termination_model' end,
   'meter_serial_numbers','not_recorded','utility_account_references','not_recorded',
   'meter_readings','not_recorded','service_status_events','not_recorded'
  )
 ),updated_at=now()
from game.building_units u
join game.buildings b on b.id=u.building_id
join game.building_profiles bp on bp.building_id=b.id
where u.id=up.building_unit_id;

do $$
begin
 if (select count(*) from game.building_unit_profiles)<>26888 then
  raise exception 'BP-04 unit profile population changed unexpectedly'; end if;
 if (select count(distinct access_notes) from game.building_unit_profiles)<>26888 then
  raise exception 'BP-04 unit access dossiers are not individually differentiated'; end if;
 if exists(select 1 from game.building_units u
  join game.building_unit_profiles up on up.building_unit_id=u.id
  where up.utility_meter_refs#>>'{unit_metering_profile,profile_reference}' is distinct from u.unit_ref
   or up.utility_meter_refs#>>'{unit_metering_profile,meter_serial_numbers}'<>'not_recorded'
   or up.utility_meter_refs#>>'{unit_metering_profile,meter_readings}'<>'not_recorded') then
  raise exception 'BP-04 unit metering provenance or identity validation failed'; end if;
end $$;
