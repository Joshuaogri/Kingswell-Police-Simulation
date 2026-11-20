-- BP-04: independently vary security profile dimensions to avoid a small
-- repeated set of identical security arrangements across business categories.
-- This does not assert named providers, actual incidents or device inventories.

update game.business_profiles bp
set security_arrangements = coalesce(bp.security_arrangements,'{}'::jsonb) || jsonb_build_object(
 'premises_access_control',(array['key_and_managed_entry','staff_badge_or_key_control','reception_controlled_entry','alarm_and_keyholder_control','zoned_staff_and_public_access'])[((right(o.organisation_ref,6)::int * 2 + 1) % 5) + 1],
 'cctv_coverage_profile',(array['entrances_and_cash_or_service_points','public_frontage_and_rear_access','loading_and_goods_handling_areas','shared_access_and_internal_common_areas','site_specific_partial_coverage'])[((right(o.organisation_ref,6)::int * 3 + 2) % 5) + 1],
 'intrusion_detection_profile',(array['perimeter_and_after_hours','principal_entrances_only','selected_restricted_rooms','site_alarm_status_unconfirmed','local_intrusion_alarm'])[((right(o.organisation_ref,6)::int * 4 + 3) % 5) + 1],
 'out_of_hours_control',(array['keyholder_callout','manager_or_supervisor_lockup','security_patrol_or_check','automated_alarm_and_remote_notification','staff_closing_checklist'])[((right(o.organisation_ref,6)::int * 2 + 4) % 5) + 1],
 'security_variation',((right(o.organisation_ref,6)::int * 7) % 13) + 1
),
updated_at=now()
from game.organisations o
where o.id=bp.organisation_id and o.organisation_ref like 'KWORG-BIZ-%';
