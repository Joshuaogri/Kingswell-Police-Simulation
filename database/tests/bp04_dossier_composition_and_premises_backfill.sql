-- BP-04 completed dossier composition and backfill regression.
begin;
do $test$
declare
 v_business text;
 v_org text;
 v_site text;
 v_record jsonb;
begin
 select business_number into v_business from game.business_profiles order by business_number limit 1;
 select organisation_ref into v_org from game.organisations order by organisation_ref limit 1;
 select site_ref into v_site from game.organisation_site_dossiers order by site_ref limit 1;

 if v_business is null or v_org is null or v_site is null then
  raise exception 'BP-04 dossier regression fixture lacks canonical business, organisation or site';
 end if;

 v_record:=game.get_business_record(v_business);
 if v_record->'business_operational_profile' is null
    or v_record->'business_operational_profile'->'product_service_lines' is null then
  raise exception 'Business dossier does not expose the completed operational profile';
 end if;

 v_record:=game.get_organisation_record(v_org);
 if v_record->'organisation_structure' is null then
  raise exception 'Organisation dossier does not expose the department and workforce structure';
 end if;

 v_record:=game.get_organisation_site_record(v_site);
 if v_record->'exact_premises_identity'->>'unit_ref' is null
    or v_record->'unit_infrastructure_profile' is null
    or v_record->'building_asset_inventory' is null
    or v_record->'occupancy_agreements_and_history' is null
    or v_record->'property_development_history' is null then
  raise exception 'Organisation site dossier is missing its exact premises, infrastructure, asset, agreement or planning sections';
 end if;

 if exists(
  select 1 from game.case_lead_entity_links l
  join game.organisation_site_dossiers sd on sd.organisation_location_id=l.organisation_location_id
  where l.entity_type='site' and (
   l.premises_property_id is distinct from sd.property_id
   or l.premises_building_unit_id is distinct from sd.building_unit_id
  )
 ) then raise exception 'Existing case lead site links do not carry exact premises identity'; end if;

 if exists(
  select 1 from game.evidence_items e
  join game.incidents i on i.id=e.incident_id
  where e.property_id is not null and i.location_property_id is not null
    and e.property_id<>i.location_property_id
    and not exists(select 1 from game.evidence_premises_history h where h.evidence_id=e.id)
 ) then raise exception 'Evidence premises conflict with incident location without a recovery history explaining the difference'; end if;
end;
$test$;
rollback;
