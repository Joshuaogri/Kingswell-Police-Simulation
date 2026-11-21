-- BP-04: complete the business dossier read model by composing existing canonical organisation,
-- workforce, site, agreement, property and physical-asset records. No facts are seeded here.

create or replace function game.get_business_record(p_business_number text)
returns jsonb
language sql
stable
set search_path to 'pg_catalog','game'
as $$
 select jsonb_build_object(
  'organisation',to_jsonb(o),
  'business',to_jsonb(bp),
  'organisation_profile',to_jsonb(op),
  'workforce',game.get_organisation_workforce_record(o.organisation_ref),
  'organisation_structure',game.get_organisation_structure_record(o.organisation_ref),
  'control_interests',coalesce((
   select jsonb_agg(jsonb_build_object(
    'interest',to_jsonb(ci),
    'holder_person_id',ci.holder_person_id,
    'holder_organisation',to_jsonb(holder_org)
   ) order by ci.control_type,ci.valid_from)
   from game.organisation_control_interests ci
   left join game.organisations holder_org on holder_org.id=ci.holder_organisation_id
   where ci.organisation_id=o.id
  ),'[]'::jsonb),
  'property_interests',coalesce((
   select jsonb_agg(to_jsonb(pi) order by pi.interest_type,pi.valid_from)
   from game.property_interest_records pi
   where pi.holder_organisation_id=o.id
  ),'[]'::jsonb),
  'sites',coalesce((
   select jsonb_agg(jsonb_build_object(
    'site',to_jsonb(ol),
    'site_dossier',to_jsonb(sd),
    'property',to_jsonb(p),
    'property_profile',to_jsonb(pp),
    'address',to_jsonb(pa),
    'district',jsonb_build_object('code',d.code,'name',d.name),
    'neighbourhood',jsonb_build_object('code',n.code,'name',n.name),
    'building',to_jsonb(b),
    'unit',to_jsonb(u),
    'unit_profile',to_jsonb(up),
    'unit_infrastructure',to_jsonb(ui)
   ) order by ol.is_primary_location desc,p.property_ref,ol.site_ref)
   from game.organisation_locations ol
   join game.properties p on p.id=ol.property_id
   join game.districts d on d.id=p.district_id
   join game.neighbourhoods n on n.id=p.neighbourhood_id
   left join game.organisation_site_dossiers sd on sd.organisation_location_id=ol.id
   left join game.property_profiles pp on pp.property_id=p.id
   left join game.property_addresses pa on pa.property_id=p.id and pa.is_primary
   left join game.building_units u on u.id=ol.building_unit_id
   left join game.buildings b on b.id=u.building_id
   left join game.building_unit_profiles up on up.building_unit_id=u.id
   left join game.building_unit_infrastructure_profiles ui on ui.building_unit_id=u.id
   where ol.organisation_id=o.id
  ),'[]'::jsonb),
  'site_dossiers',coalesce((
   select jsonb_agg(to_jsonb(sd) order by sd.site_class,sd.site_ref)
   from game.organisation_site_dossiers sd
   where sd.organisation_id=o.id
  ),'[]'::jsonb),
  'site_agreements',coalesce((
   select jsonb_agg(jsonb_build_object(
    'agreement',to_jsonb(a),
    'site',to_jsonb(ol),
    'counterparty_organisation',to_jsonb(cp),
    'lifecycle_events',coalesce((
     select jsonb_agg(to_jsonb(e) order by e.occurred_on,e.recorded_on,e.created_at)
     from game.organisation_site_agreement_events e
     where e.agreement_id=a.id
    ),'[]'::jsonb)
   ) order by a.agreement_ref)
   from game.organisation_site_agreement_locations al
   join game.organisation_site_agreements a on a.id=al.agreement_id
   join game.organisation_locations ol on ol.id=al.organisation_location_id
   left join game.organisations cp on cp.id=a.counterparty_organisation_id
   where a.tenant_organisation_id=o.id
  ),'[]'::jsonb),
  'physical_assets',coalesce((
   select jsonb_agg(to_jsonb(a) order by a.asset_category,a.asset_ref)
   from game.property_physical_assets a
   where exists(
    select 1 from game.organisation_locations ol
    left join game.building_units u on u.id=ol.building_unit_id
    where ol.organisation_id=o.id
      and a.property_id=ol.property_id
      and (
       a.building_unit_id=ol.building_unit_id
       or (a.building_unit_id is null and
        (a.building_id is null or a.building_id=u.building_id))
      )
   )
  ),'[]'::jsonb),
  'asset_maintenance_events',coalesce((
   select jsonb_agg(jsonb_build_object(
    'event',to_jsonb(me),'asset_ref',a.asset_ref,'asset_name',a.asset_name
   ) order by me.occurred_at nulls last,me.created_at)
   from game.physical_asset_maintenance_events me
   join game.property_physical_assets a on a.id=me.asset_id
   where exists(
    select 1 from game.organisation_locations ol
    left join game.building_units u on u.id=ol.building_unit_id
    where ol.organisation_id=o.id
      and a.property_id=ol.property_id
      and (
       a.building_unit_id=ol.building_unit_id
       or (a.building_unit_id is null and
        (a.building_id is null or a.building_id=u.building_id))
      )
   )
  ),'[]'::jsonb),
  'property_asset_events',coalesce((
   select jsonb_agg(to_jsonb(e) order by e.occurred_on nulls last,e.created_at)
   from game.property_asset_events e
   where exists(
    select 1 from game.organisation_locations ol
    left join game.building_units u on u.id=ol.building_unit_id
    where ol.organisation_id=o.id
      and e.property_id=ol.property_id
      and (
       e.building_unit_id=ol.building_unit_id
       or (e.building_unit_id is null and
        (e.building_id is null or e.building_id=u.building_id))
      )
   )
  ),'[]'::jsonb),
  'record_coverage',jsonb_build_object(
   'organisation_profile','canonical_record',
   'workforce','canonical_employment_and_role_dossiers',
   'department_structure','recorded_structure_only',
   'site_dossiers','canonical_site_records',
   'ownership_and_control','recorded_interests_only',
   'physical_assets','recorded_assets_only',
   'maintenance_and_inspection','recorded_events_only',
   'agreement_history','recorded_lifecycle_events_only',
   'unknown_values_are_not_inferred',true,
   'unrecorded_assets_are_not_assumed_absent',true,
   'seeded_operational_profiles_are_not_live_activity',true
  )
 )
 from game.business_profiles bp
 join game.organisations o on o.id=bp.organisation_id
 left join game.organisation_profiles op on op.organisation_id=o.id
 where bp.business_number=p_business_number;
$$;

revoke all on function game.get_business_record(text) from public,anon,authenticated;
grant execute on function game.get_business_record(text) to service_role;
