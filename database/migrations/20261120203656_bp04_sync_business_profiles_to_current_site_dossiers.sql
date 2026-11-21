-- BP-04: synchronise current business site dossiers with their canonical
-- business profiles without changing site identity, lease or occupancy history.

update game.organisation_locations l
set
 operating_hours = bp.business_hours,
 site_details = coalesce(l.site_details,'{}'::jsonb) || jsonb_build_object(
   'operating_model',bp.trade_profile->>'operating_model',
   'customer_access_model',bp.trade_profile->>'customer_access_model',
   'stock_and_asset_handling',bp.trade_profile->>'stock_and_asset_handling',
   'delivery_and_visitors',bp.trade_profile->>'delivery_and_visitors',
   'premises_access_control',bp.security_arrangements->>'premises_access_control',
   'cctv_coverage_profile',bp.security_arrangements->>'cctv_coverage_profile',
   'intrusion_detection_profile',bp.security_arrangements->>'intrusion_detection_profile',
   'out_of_hours_control',bp.security_arrangements->>'out_of_hours_control',
   'site_profile_basis','Derived from the linked fictional business profile; not an attendance, delivery, CCTV event or named-provider record.'
 )
from game.business_profiles bp
where bp.organisation_id=l.organisation_id
  and l.valid_to is null
  and l.location_role in ('tenant','owner_occupier','headquarters','branch','operating_site')
  and (l.operating_hours is distinct from bp.business_hours
       or l.site_details->>'operating_model' is distinct from bp.trade_profile->>'operating_model');
