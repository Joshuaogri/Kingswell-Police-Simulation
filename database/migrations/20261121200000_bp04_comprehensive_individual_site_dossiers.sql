-- BP-04: compose the individual premises dossier from canonical site, organisation,
-- property, unit infrastructure and agreement records. No inferred or seeded facts.
create or replace function game.get_organisation_site_record(p_site_ref text)
returns jsonb
language sql
stable
set search_path to 'pg_catalog','game'
as $function$
 select jsonb_build_object(
  'site',to_jsonb(sd),
  'organisation',jsonb_build_object(
   'id',o.id,'ref',o.organisation_ref,'name',o.name,
   'profile',to_jsonb(op),'business',to_jsonb(bp)
  ),
  'site_location',to_jsonb(ol),
  'property',to_jsonb(p),
  'property_record',game.get_property_record(p.property_ref),
  'building',to_jsonb(b),
  'unit',to_jsonb(u),
  'unit_profile',to_jsonb(up),
  'unit_infrastructure',to_jsonb(ui),
  'site_agreements',coalesce((
   select jsonb_agg(jsonb_build_object(
    'agreement',to_jsonb(a),
    'counterparty_organisation',to_jsonb(cp),
    'lifecycle_events',coalesce((
     select jsonb_agg(to_jsonb(e) order by e.occurred_on,e.recorded_on,e.created_at)
     from game.organisation_site_agreement_events e
     where e.agreement_id=a.id
    ),'[]'::jsonb)
   ) order by a.agreement_ref)
   from game.organisation_site_agreement_locations al
   join game.organisation_site_agreements a on a.id=al.agreement_id
   left join game.organisations cp on cp.id=a.counterparty_organisation_id
   where al.organisation_location_id=ol.id
  ),'[]'::jsonb),
  'recorded_department_assignments',coalesce((
   select jsonb_agg(jsonb_build_object(
    'assignment',to_jsonb(da),
    'department',to_jsonb(d),
    'position',to_jsonb(pos),
    'employment',to_jsonb(emp)
   ) order by d.department_name,pos.position_title,da.assignment_ref)
   from game.organisation_department_assignments da
   join game.organisation_departments d on d.id=da.department_id
   left join game.organisation_department_positions pos on pos.id=da.position_id
   join game.organisation_personnel emp on emp.id=da.organisation_personnel_id
   where da.site_dossier_id=sd.organisation_location_id
  ),'[]'::jsonb),
  'record_coverage',jsonb_build_object(
   'property_history','canonical_property_dossier',
   'site_agreements','recorded_site_agreements_and_events_only',
   'unit_infrastructure','recorded_unit_profile_only',
   'department_assignments','recorded_assignments_only',
   'unknown_values_are_not_inferred',true,
   'empty_event_arrays_do_not_prove_no_prior_events',true
  )
 )
 from game.organisation_site_dossiers sd
 join game.organisations o on o.id=sd.organisation_id
 join game.organisation_locations ol on ol.id=sd.organisation_location_id
 join game.properties p on p.id=sd.property_id
 left join game.organisation_profiles op on op.organisation_id=o.id
 left join game.business_profiles bp on bp.organisation_id=o.id
 left join game.building_units u on u.id=sd.building_unit_id
 left join game.buildings b on b.id=u.building_id
 left join game.building_unit_profiles up on up.building_unit_id=u.id
 left join game.building_unit_infrastructure_profiles ui on ui.building_unit_id=u.id
 where sd.site_ref=p_site_ref;
$function$;

revoke all on function game.get_organisation_site_record(text) from public,anon,authenticated;
grant execute on function game.get_organisation_site_record(text) to service_role;
