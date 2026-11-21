-- BP-04 comprehensive business dossier regression.
begin;
do $$
declare
 v_business_number text;
 v_org_id uuid;
 v_record jsonb;
 v_site_count integer;
 v_dossier_count integer;
begin
 select bp.business_number,bp.organisation_id
 into v_business_number,v_org_id
 from game.business_profiles bp
 order by bp.business_number
 limit 1;

 if v_business_number is null then
  raise exception 'BP04: no canonical business fixture is available';
 end if;

 v_record:=game.get_business_record(v_business_number);
 if v_record is null then
  raise exception 'BP04: comprehensive business dossier returned null';
 end if;

 if not (
  v_record ? 'organisation'
  and v_record ? 'business'
  and v_record ? 'organisation_profile'
  and v_record ? 'workforce'
  and v_record ? 'organisation_structure'
  and v_record ? 'control_interests'
  and v_record ? 'property_interests'
  and v_record ? 'sites'
  and v_record ? 'site_dossiers'
  and v_record ? 'site_agreements'
  and v_record ? 'physical_assets'
  and v_record ? 'asset_maintenance_events'
  and v_record ? 'property_asset_events'
  and v_record ? 'record_coverage'
 ) then
  raise exception 'BP04: comprehensive business dossier is missing a required section';
 end if;

 if v_record#>>'{workforce,workforce_summary,total_links}' is null
  or not (v_record#>'{workforce,employees}' is not null)
  or not (v_record#>'{organisation_structure,departments}' is not null)
 then
  raise exception 'BP04: workforce or organisation structure section is incomplete';
 end if;

 select count(*) into v_site_count
 from game.organisation_locations ol where ol.organisation_id=v_org_id;
 select count(*) into v_dossier_count
 from game.organisation_site_dossiers sd where sd.organisation_id=v_org_id;

 if jsonb_array_length(v_record->'sites')<>v_site_count then
  raise exception 'BP04: business site list does not match canonical site links';
 end if;
 if jsonb_array_length(v_record->'site_dossiers')<>v_dossier_count then
  raise exception 'BP04: business site dossier list does not match canonical site dossiers';
 end if;

 if v_record#>>'{record_coverage,unknown_values_are_not_inferred}'<>'true'
  or v_record#>>'{record_coverage,unrecorded_assets_are_not_assumed_absent}'<>'true'
  or v_record#>>'{record_coverage,seeded_operational_profiles_are_not_live_activity}'<>'true'
 then
  raise exception 'BP04: business dossier data-quality boundaries are missing';
 end if;

 if has_function_privilege('anon','game.get_business_record(text)','execute')
  or has_function_privilege('authenticated','game.get_business_record(text)','execute')
  or not has_function_privilege('service_role','game.get_business_record(text)','execute')
 then
  raise exception 'BP04: business dossier execution grants are incorrect';
 end if;

 -- The current empty asset/event registers are valid: the dossier must return
 -- empty arrays, not infer absent equipment or invent activity.
 if (select count(*) from game.property_physical_assets)=0
  and jsonb_array_length(v_record->'physical_assets')<>0 then
  raise exception 'BP04: empty physical asset register returned invented assets';
 end if;
 if (select count(*) from game.physical_asset_maintenance_events)=0
  and jsonb_array_length(v_record->'asset_maintenance_events')<>0 then
  raise exception 'BP04: empty maintenance register returned invented events';
 end if;
 if (select count(*) from game.property_asset_events)=0
  and jsonb_array_length(v_record->'property_asset_events')<>0 then
  raise exception 'BP04: empty property event register returned invented events';
 end if;
end $$;
rollback;
