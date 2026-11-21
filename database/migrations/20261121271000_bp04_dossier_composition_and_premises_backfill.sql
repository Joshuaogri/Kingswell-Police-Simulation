-- BP-04: complete the business/organisation/site read models and backfill
-- exact premises identity onto all pre-existing investigative records.

-- Preserve evidence identity from the canonical incident location where no
-- scene-specific recovery record exists. Scene recovery history remains the
-- authority for a more precise recovery location.
update game.evidence_items e
set property_id=coalesce(e.property_id,i.location_property_id),
    building_id=coalesce(e.building_id,i.location_building_id),
    building_unit_id=coalesce(e.building_unit_id,i.location_building_unit_id)
from game.incidents i
where e.incident_id=i.id
  and (e.property_id is null or e.building_id is null or e.building_unit_id is null);

-- Existing site links receive the exact property/building/unit represented by
-- the canonical organisation site dossier.
update game.case_lead_entity_links l
set premises_property_id=sd.property_id,
    premises_building_unit_id=sd.building_unit_id,
    premises_building_id=bu.building_id
from game.organisation_site_dossiers sd
join game.building_units bu on bu.id=sd.building_unit_id
where l.entity_type='site'
  and l.organisation_location_id=sd.organisation_location_id
  and (l.premises_property_id is null or l.premises_building_id is null
       or l.premises_building_unit_id is null);

update game.case_lead_entity_links
set premises_property_id=property_id
where entity_type='property' and property_id is not null
  and premises_property_id is null;

-- The business record exposes the full operational profile as a named section,
-- not only as an opaque field inside the base profile row.
alter function game.get_business_record(text)
 rename to get_business_record_before_bp04_operational_profile;
create or replace function game.get_business_record(p_business_number text)
returns jsonb
language plpgsql stable
set search_path to 'pg_catalog','game'
as $function$
declare v_base jsonb; v_profile jsonb;
begin
  v_base:=game.get_business_record_before_bp04_operational_profile(p_business_number);
  if v_base is null then return null; end if;
  select operational_profile into v_profile
  from game.business_profiles where business_number=btrim(p_business_number);
  return v_base || jsonb_build_object(
    'business_operational_profile',coalesce(v_profile,'{}'::jsonb),
    'operational_profile_version',coalesce(v_profile->>'generated_fictional_detail_version','1')
  );
end;
$function$;

-- The organisation record composes the full generated department, position,
-- employment assignment and site hierarchy.
alter function game.get_organisation_record(text)
 rename to get_organisation_record_before_bp04_structure;
create or replace function game.get_organisation_record(p_organisation_ref text)
returns jsonb
language plpgsql stable
set search_path to 'pg_catalog','game'
as $function$
declare v_base jsonb;
begin
  v_base:=game.get_organisation_record_before_bp04_structure(p_organisation_ref);
  if v_base is null then return null; end if;
  return v_base || jsonb_build_object(
    'organisation_structure',game.get_organisation_structure_record(p_organisation_ref),
    'organisation_structure_status',coalesce(
      game.get_organisation_structure_record(p_organisation_ref)->>'structure_status',
      'not_yet_recorded')
  );
end;
$function$;

-- The site record now exposes exact unit infrastructure, building assets,
-- their inspection histories, occupancy contracts and property development history.
alter function game.get_organisation_site_record(text)
 rename to get_organisation_site_record_before_bp04_complete_dossier;
create or replace function game.get_organisation_site_record(p_site_ref text)
returns jsonb
language plpgsql stable
set search_path to 'pg_catalog','game'
as $function$
declare
  v_base jsonb;
  v_site game.organisation_site_dossiers%rowtype;
  v_building_id uuid;
  v_property_ref text;
  v_assets jsonb;
  v_agreements jsonb;
  v_infrastructure jsonb;
begin
  v_base:=game.get_organisation_site_record_before_bp04_complete_dossier(p_site_ref);
  if v_base is null then return null; end if;
  select * into v_site from game.organisation_site_dossiers where site_ref=btrim(p_site_ref);
  select building_id into v_building_id from game.building_units where id=v_site.building_unit_id;
  select property_ref into v_property_ref from game.properties where id=v_site.property_id;

  select coalesce(jsonb_agg(jsonb_build_object(
    'asset',to_jsonb(a),'maintenance_history',coalesce((
      select jsonb_agg(to_jsonb(m) order by m.occurred_at desc nulls last,m.created_at desc)
      from game.physical_asset_maintenance_events m where m.asset_id=a.id
    ),'[]'::jsonb)
  ) order by a.asset_category,a.asset_ref),'[]'::jsonb)
  into v_assets
  from game.property_physical_assets a
  where a.building_id=v_building_id;

  select to_jsonb(i) into v_infrastructure
  from game.building_unit_infrastructure_profiles i
  where i.building_unit_id=v_site.building_unit_id;

  select coalesce(jsonb_agg(jsonb_build_object(
    'agreement',to_jsonb(a),
    'events',coalesce((
      select jsonb_agg(to_jsonb(e) order by e.occurred_on,e.created_at)
      from game.organisation_site_agreement_events e where e.agreement_id=a.id
    ),'[]'::jsonb)
  ) order by a.agreement_ref),'[]'::jsonb)
  into v_agreements
  from game.organisation_site_agreement_locations al
  join game.organisation_site_agreements a on a.id=al.agreement_id
  where al.organisation_location_id=v_site.organisation_location_id;

  return v_base || jsonb_build_object(
    'exact_premises_identity',jsonb_build_object(
      'property_id',v_site.property_id,'property_ref',v_property_ref,
      'building_id',v_building_id,'building_ref',v_site.building_ref,
      'building_unit_id',v_site.building_unit_id,'unit_ref',v_site.unit_ref
    ),
    'unit_infrastructure_profile',coalesce(v_infrastructure,'{}'::jsonb),
    'building_asset_inventory',v_assets,
    'occupancy_agreements_and_history',v_agreements,
    'property_development_history',game.get_property_development_history(v_property_ref),
    'bp04_site_coverage',jsonb_build_object(
      'canonical_property_building_unit',true,
      'unit_infrastructure_included',true,
      'building_asset_inventory_included',true,
      'maintenance_history_included',true,
      'occupancy_agreement_history_included',true,
      'planning_and_development_history_included',true)
  );
end;
$function$;

-- Incident context now includes exact property/building/unit references for
-- the incident itself and every explicitly associated organisation site.
alter function game.get_incident_site_context(text)
 rename to get_incident_site_context_before_bp04_exact_premises;
create or replace function game.get_incident_site_context(p_incident_ref text)
returns jsonb
language plpgsql stable
set search_path to 'pg_catalog','game'
as $function$
declare v_base jsonb; v_incident game.incidents%rowtype; v_exact jsonb;
begin
  v_base:=game.get_incident_site_context_before_bp04_exact_premises(p_incident_ref);
  if coalesce((v_base->>'ok')::boolean,false) is not true then return v_base; end if;
  select * into v_incident from game.incidents where incident_ref=btrim(p_incident_ref);
  select coalesce(jsonb_agg(jsonb_build_object(
    'association_ref',a.association_ref,'relation_type',a.relation_type,
    'site_ref',sd.site_ref,'organisation_ref',o.organisation_ref,
    'property_ref',p.property_ref,'building_ref',b.building_ref,'unit_ref',u.unit_ref,
    'reason',a.reason
  ) order by case a.relation_type when 'incident_location' then 0 else 1 end,a.created_at),'[]'::jsonb)
  into v_exact
  from game.incident_site_associations a
  join game.organisation_site_dossiers sd on sd.organisation_location_id=a.organisation_location_id
  join game.organisations o on o.id=sd.organisation_id
  join game.properties p on p.id=sd.property_id
  left join game.building_units u on u.id=sd.building_unit_id
  left join game.buildings b on b.id=u.building_id
  where a.incident_id=v_incident.id;
  return v_base || jsonb_build_object(
    'exact_incident_premises',jsonb_build_object(
      'property_ref',(select property_ref from game.properties where id=v_incident.location_property_id),
      'building_ref',(select building_ref from game.buildings where id=v_incident.location_building_id),
      'unit_ref',(select unit_ref from game.building_units where id=v_incident.location_building_unit_id),
      'property_id',v_incident.location_property_id,
      'building_id',v_incident.location_building_id,
      'building_unit_id',v_incident.location_building_unit_id
    ),
    'exact_associated_sites',v_exact
  );
end;
$function$;

revoke all on function game.get_business_record(text),
 game.get_organisation_record(text),game.get_organisation_site_record(text),
 game.get_incident_site_context(text)
from public,anon,authenticated;
grant execute on function game.get_business_record(text),
 game.get_organisation_record(text),game.get_organisation_site_record(text),
 game.get_incident_site_context(text)
to service_role;


-- The migration-time update above runs before isolated fixtures are loaded.
-- This reusable function also populates newly loaded fictional businesses.
create or replace function game.seed_bp04_business_operational_profiles()
returns jsonb language plpgsql set search_path to 'pg_catalog','game'
as $function$
declare v_updated integer;
begin
update game.business_profiles bp
set operational_profile = coalesce(bp.operational_profile,'{}'::jsonb) || jsonb_build_object(
  'product_service_lines', jsonb_build_object(
    'sector',bp.sector,
    'subsector',bp.subsector,
    'principal_goods_categories',to_jsonb(bp.principal_goods_categories),
    'service_description',bp.service_description,
    'import_export_activity',bp.import_export_activity,
    'turnover_band',bp.annual_turnover_band
  ),
  'stock_and_inventory_operations', jsonb_build_object(
    'inventory_model',case
      when cardinality(bp.principal_goods_categories)>0 then 'category_based_stock_and_goods'
      when bp.sector in ('logistics_warehousing','transport_services') then 'consignment_and_custody_records'
      when bp.sector in ('manufacturing','construction_property') then 'materials_components_and_work_in_progress'
      else 'operating_supplies_and_equipment'
    end,
    'goods_categories',to_jsonb(bp.principal_goods_categories),
    'receipt_controls','supplier_delivery_reference_and_quantity_reconciliation',
    'storage_controls','designated_storage_and_restricted_stock_areas',
    'stock_adjustment','recorded_count_variance_and_authorised_adjustment'
  ),
  'supplier_and_delivery_operations',jsonb_build_object(
    'supplier_model',case
      when bp.import_export_activity in ('import','export','both','high') then 'domestic_and_international_supplier_network'
      when bp.sector in ('logistics_warehousing','transport_services') then 'fleet_fuel_maintenance_and_consignment_suppliers'
      when bp.sector in ('manufacturing','construction_property') then 'materials_components_and_plant_suppliers'
      else 'local_and_regional_trade_suppliers'
    end,
    'delivery_handling','scheduled_receipt_dispatch_and_delivery_records',
    'vehicle_access','managed_service_or_loading_access',
    'proof_of_delivery','delivery_note_and_recipient_reconciliation'
  ),
  'commercial_and_payment_operations',jsonb_build_object(
    'cash_handling_profile',bp.cash_handling_profile,
    'annual_turnover_band',bp.annual_turnover_band,
    'payment_channels',case
      when bp.cash_handling_profile='high' then jsonb_build_array('cash','card','bank_transfer')
      when bp.cash_handling_profile='low' then jsonb_build_array('bank_transfer','card','account')
      else jsonb_build_array('cash','card','bank_transfer','account')
    end,
    'reconciliation','daily_or_shift_close',
    'refunds_and_adjustments','recorded_against_original_transaction'
  ),
  'staffing_and_workforce_operations',jsonb_build_object(
    'estimated_employee_count',bp.estimated_employee_count,
    'business_size',bp.business_size,
    'workforce_schedule',bp.business_hours,
    'shift_handover','recorded_role_and_responsibility_handover',
    'employment_source','canonical_organisation_personnel_records'
  ),
  'customer_and_visitor_operations',jsonb_build_object(
    'access_model',coalesce(bp.trade_profile->>'customer_access_model','staff_and_booked_visitors'),
    'customer_interaction',case
      when bp.sector in ('retail','wholesale_trade','hospitality_entertainment') then 'walk_in_and_transactional'
      when bp.sector in ('financial_services','professional_services','property_management') then 'appointment_and_account_managed'
      when bp.sector in ('logistics_warehousing','transport_services') then 'booked_collection_delivery_and_business_visitors'
      else 'mixed_customer_client_and_supplier_contact'
    end,
    'visitor_record','reception_or_transactional_record_as_appropriate',
    'restricted_areas','staff_only_or_authorised_personnel'
  ),
  'security_and_incident_context',jsonb_build_object(
    'security_arrangements',bp.security_arrangements,
    'cash_handling_profile',bp.cash_handling_profile,
    'site_security_is_separate','true',
    'alarm_credentials','never_stored_in_operational_profile',
    'police_relevant_context','business_operating_context_not_an_intelligence_assessment'
  ),
  'business_record_controls',jsonb_build_object(
    'legal_identity','canonical_organisations_and_business_profiles',
    'sites','canonical_organisation_locations_and_site_dossiers',
    'employees','canonical_organisation_personnel',
    'ownership','canonical_organisation_control_interests',
    'contracts','canonical_organisation_site_agreements',
    'generated_fictional_profile',true
  ),
  'generated_fictional_detail_version',2
),
updated_at=now();
  get diagnostics v_updated=row_count;
  return jsonb_build_object('ok',true,'business_profiles_updated',v_updated);
end;
$function$;

revoke all on function game.seed_bp04_business_operational_profiles() from public,anon,authenticated;
grant execute on function game.seed_bp04_business_operational_profiles() to service_role;

alter function game.seed_bp04_complete_world()
 rename to seed_bp04_complete_world_before_operational_profile;
create or replace function game.seed_bp04_complete_world()
returns jsonb language plpgsql set search_path to 'pg_catalog','game'
as $function$
declare v_result jsonb; v_profile jsonb;
begin
  v_result:=game.seed_bp04_complete_world_before_operational_profile();
  if coalesce((v_result->>'ok')::boolean,false) then
    v_profile:=game.seed_bp04_business_operational_profiles();
    return v_result || jsonb_build_object('business_operational_profile_population',v_profile);
  end if;
  return v_result;
end;
$function$;

revoke all on function game.seed_bp04_complete_world() from public,anon,authenticated;
grant execute on function game.seed_bp04_complete_world() to service_role;

do $seed$
begin
  if exists(select 1 from game.business_profiles) then
    perform game.seed_bp04_business_operational_profiles();
  end if;
end
$seed$;
