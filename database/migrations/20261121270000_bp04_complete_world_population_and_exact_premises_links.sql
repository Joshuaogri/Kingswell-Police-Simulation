-- BP-04 completion tranche: fully populate the fictional property/business world
-- and carry exact property/building/unit identities through police workflows.
-- All generated records are Kingswell simulation canon, never real-world data.

-- ---------------------------------------------------------------------------
-- 1. Individual business operating dossiers
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
-- 2. Idempotent full-world population function
-- ---------------------------------------------------------------------------
create or replace function game.seed_bp04_complete_world()
returns jsonb
language plpgsql
set search_path to 'pg_catalog','game'
as $function$
declare
  v_people bigint;
  v_businesses bigint;
  v_ownership integer:=0;
  v_title integer:=0;
  v_counterparties integer:=0;
  v_agreement_terms integer:=0;
  v_agreement_events integer:=0;
  v_lifecycle integer:=0;
  v_assets integer:=0;
  v_infrastructure integer:=0;
  v_maintenance integer:=0;
  v_property_events integer:=0;
  v_structure jsonb;
begin
  select count(*) into v_people from game.persons;
  select count(*) into v_businesses from game.business_profiles;
  if v_people=0 or v_businesses=0 then
    return jsonb_build_object('ok',false,'code','canonical_world_not_seeded',
      'message','Kingswell persons and business profiles must exist before BP-04 population.');
  end if;

  -- Every employee is assigned to a department and job-title position from
  -- existing employment data. No employee is silently promoted to manager.
  v_structure:=game.seed_bp04_organisation_structures();
  if coalesce((v_structure->>'ok')::boolean,false) is not true then
    return v_structure;
  end if;

  -- Business control records: generated people are drawn from the canonical
  -- Kingswell population; share splits match the fictional legal-form profile.
  with person_pool as (
    select id,row_number() over(order by person_ref)::bigint rn,count(*) over()::bigint total
    from game.persons
  ), slots as (
    select bp.organisation_id,bp.business_number,bp.ownership_form,bp.incorporation_date,
      s.slot,
      case bp.ownership_form
        when 'sole_trader' then 1
        when 'partnership' then 2
        when 'family_enterprise' then 2
        when 'private_limited' then 2
        when 'public_company' then 4
        else 1
      end slot_count,
      case
        when bp.ownership_form='sole_trader' then 100::numeric
        when bp.ownership_form='partnership' then 50::numeric
        when bp.ownership_form='family_enterprise' and s.slot=1 then 60::numeric
        when bp.ownership_form='family_enterprise' then 40::numeric
        when bp.ownership_form='private_limited' and s.slot=1 then 60::numeric
        when bp.ownership_form='private_limited' then 40::numeric
        when bp.ownership_form='public_company' then 25::numeric
        else 100::numeric
      end share_pct
    from game.business_profiles bp
    cross join lateral (values (1),(2),(3),(4)) s(slot)
    where s.slot <= case bp.ownership_form
      when 'sole_trader' then 1 when 'partnership' then 2
      when 'family_enterprise' then 2 when 'private_limited' then 2
      when 'public_company' then 4 else 1 end
  ), assigned as (
    select s.*,
      p.id holder_person_id
    from slots s
    cross join lateral (
      select pp.id
      from person_pool pp
      where pp.rn=(
        mod(abs(hashtextextended(s.business_number||':control:'||s.slot::text,0)),pp.total)+1
      )
      limit 1
    ) p
  )
  insert into game.organisation_control_interests(
    organisation_id,holder_person_id,control_type,ownership_share_pct,voting_share_pct,
    valid_from,source_reference,source_description,control_details
  )
  select
    a.organisation_id,a.holder_person_id,
    case a.ownership_form
      when 'sole_trader' then 'beneficial_owner'
      when 'partnership' then 'partner'
      else 'shareholder'
    end,
    a.share_pct,a.share_pct,a.incorporation_date,
    'KNG-GEN-CONTROL-'||a.business_number||'-'||a.slot::text,
    'Generated fictional ownership/control interest for the Kingswell simulation.',
    jsonb_build_object(
      'generated_fictional_baseline',true,
      'ownership_form',a.ownership_form,
      'shareholder_slot',a.slot,
      'shareholder_count',a.slot_count,
      'share_allocation','complete fictional cap-table allocation',
      'director_status','not_inferred_from_shareholding'
    )
  from assigned a
  where not exists(
    select 1 from game.organisation_control_interests ci
    where ci.source_reference='KNG-GEN-CONTROL-'||a.business_number||'-'||a.slot::text
  )
  on conflict do nothing;
  get diagnostics v_ownership=row_count;

  -- A title-register snapshot is created from the existing registered-owner
  -- interests. It is not a fabricated historic conveyance or transfer date.
  insert into game.property_title_events(
    event_ref,property_id,event_type,occurred_on,recorded_on,
    resulting_title_reference,transferee_organisation_id,interest_transferred,
    share_transferred_pct,registration_status,source_reference,source_description,event_details
  )
  select
    'KW-TITLE-INIT-'||p.property_ref,pi.property_id,'initial_registration',null,null,
    pi.title_reference,pi.holder_organisation_id,'registered_title',
    coalesce(pi.ownership_share_pct,100),'recorded',
    'KNG-GEN-TITLE-'||p.property_ref,
    'Generated fictional current title-register snapshot from the existing registered-owner interest; historical conveyance date remains unknown.',
    jsonb_build_object('generated_fictional_baseline',true,
      'source_interest_id',pi.id,'historical_transfer_not_inferred',true,
      'registration_date_unknown',true)
  from game.property_interest_records pi
  join game.properties p on p.id=pi.property_id
  where pi.interest_type='registered_owner'
    and pi.valid_to is null
    and pi.holder_organisation_id is not null
    and not exists(select 1 from game.property_title_events e
      where e.event_ref='KW-TITLE-INIT-'||p.property_ref)
  on conflict(event_ref) do nothing;
  get diagnostics v_title=row_count;

  -- Resolve the 152 missing lease counterparties to the existing registered
  -- owner of the exact canonical property. Occupancy dates are not contract dates.
  with owner_map as (
    select distinct on (a.id) a.id,pi.holder_organisation_id
    from game.organisation_site_agreements a
    join game.organisation_site_agreement_locations al on al.agreement_id=a.id
    join game.organisation_locations ol on ol.id=al.organisation_location_id
    join game.property_interest_records pi
      on pi.property_id=ol.property_id
     and pi.interest_type='registered_owner'
     and pi.valid_to is null
     and pi.holder_organisation_id<>a.tenant_organisation_id
    where a.counterparty_person_id is null and a.counterparty_organisation_id is null
    order by a.id,ol.is_primary_location desc,pi.id
  )
  update game.organisation_site_agreements a
  set counterparty_organisation_id=m.holder_organisation_id,
      counterparty_role='landlord',
      source_reference=coalesce(a.source_reference,'KNG-GEN-AGREEMENT-'||a.agreement_ref),
      source_description=coalesce(a.source_description,
        'Generated fictional landlord relationship from the canonical registered property owner.')
  from owner_map m
  where a.id=m.id;
  get diagnostics v_counterparties=row_count;

  -- Complete every lease with generated fictional commercial terms. Contract
  -- dates are generated independently of the site occupancy dates.
  update game.organisation_site_agreements a
  set
    counterparty_role=coalesce(a.counterparty_role,'landlord'),
    execution_date=coalesce(a.execution_date,
      date '2010-01-01'+mod(abs(hashtextextended(a.agreement_ref||':execution',0)),5000)::integer),
    effective_from=coalesce(a.effective_from,
      coalesce(a.execution_date,
        date '2010-01-01'+mod(abs(hashtextextended(a.agreement_ref||':execution',0)),5000)::integer)+14),
    effective_to=a.effective_to,
    notice_days=coalesce(a.notice_days,90),
    rent_amount=coalesce(a.rent_amount,case a.rent_band
      when 'small_business' then 850
      when 'standard' then 2500
      when 'premium' then 7500
      else 1500 end),
    rent_currency=coalesce(a.rent_currency,'AFC'),
    rent_frequency=coalesce(a.rent_frequency,'monthly'),
    deposit_amount=coalesce(a.deposit_amount,
      2*coalesce(a.rent_amount,case a.rent_band
        when 'small_business' then 850
        when 'standard' then 2500
        when 'premium' then 7500 else 1500 end)),
    permitted_use=coalesce(a.permitted_use,
      coalesce(bp.subsector,bp.sector,'commercial premises')),
    restrictions=coalesce(a.restrictions,
      'Use is limited to the recorded business or site activity; materially different use requires a recorded variation.'),
    repair_responsibility=coalesce(a.repair_responsibility,
      'Tenant: internal non-structural repairs and tenant fixtures. Landlord: structure and shared building systems.'),
    service_charge_responsibility=coalesce(a.service_charge_responsibility,
      'Tenant: allocated shared-area and building service charges.'),
    subletting_allowed=coalesce(a.subletting_allowed,false),
    source_reference=coalesce(a.source_reference,'KNG-GEN-AGREEMENT-'||a.agreement_ref),
    source_description=coalesce(a.source_description,
      'Generated fictional commercial occupancy agreement for Kingswell.'),
    agreement_details=coalesce(a.agreement_details,'{}'::jsonb) ||
      jsonb_build_object(
        'generated_fictional_contract_terms',true,
        'contract_term_structure','periodic rolling agreement with no fixed expiry date recorded',
        'contract_dates_generated_independently_of_site_occupancy_dates',true,
        'currency','AFC',
        'rent_frequency','monthly',
        'notice_days',coalesce(a.notice_days,90),
        'subletting_allowed',coalesce(a.subletting_allowed,false),
        'generated_for','Kingswell fictional simulation'
      ),
    updated_at=now()
  from game.business_profiles bp
  where bp.organisation_id=a.tenant_organisation_id
    and (
      a.execution_date is null or a.effective_from is null or a.rent_amount is null
      or a.rent_currency is null or a.rent_frequency is null or a.deposit_amount is null
      or a.permitted_use is null or a.restrictions is null or a.repair_responsibility is null
      or a.service_charge_responsibility is null or a.subletting_allowed is null
      or a.agreement_details->>'generated_fictional_contract_terms' is distinct from 'true'
    );
  get diagnostics v_agreement_terms=row_count;

  -- Agreement execution and commencement histories are separate, append-only events.
  insert into game.organisation_site_agreement_events(
    event_ref,agreement_id,event_type,occurred_on,recorded_on,prior_status,
    resulting_status,subject,description,source_reference,source_description,event_details
  )
  select
    'KW-AG-EVT-EXEC-'||substr(md5(a.agreement_ref),1,22),a.id,'executed',
    a.execution_date,a.execution_date,'proposed','executed',
    'Agreement executed: '||a.agreement_ref,
    'Generated fictional execution event for the Kingswell occupancy agreement.',
    'KNG-GEN-AGREEMENT-'||a.agreement_ref,
    'Generated fictional agreement lifecycle history.',
    jsonb_build_object('generated_fictional_baseline',true,
      'contract_date_independent_of_site_occupancy',true)
  from game.organisation_site_agreements a
  where a.execution_date is not null
    and not exists(select 1 from game.organisation_site_agreement_events e
      where e.agreement_id=a.id and e.event_type='executed')
  on conflict(event_ref) do nothing;

  insert into game.organisation_site_agreement_events(
    event_ref,agreement_id,event_type,occurred_on,recorded_on,prior_status,
    resulting_status,subject,description,source_reference,source_description,event_details
  )
  select
    'KW-AG-EVT-COMM-'||substr(md5(a.agreement_ref),1,22),a.id,'commenced',
    a.effective_from,a.effective_from,'executed','active',
    'Agreement commenced: '||a.agreement_ref,
    'Generated fictional commencement event for the Kingswell occupancy agreement.',
    'KNG-GEN-AGREEMENT-'||a.agreement_ref,
    'Generated fictional agreement lifecycle history.',
    jsonb_build_object('generated_fictional_baseline',true,
      'contract_date_independent_of_site_occupancy',true)
  from game.organisation_site_agreements a
  where a.effective_from is not null
    and not exists(select 1 from game.organisation_site_agreement_events e
      where e.agreement_id=a.id and e.event_type='commenced')
  on conflict(event_ref) do nothing;

  select count(*) into v_agreement_events
  from game.organisation_site_agreement_events
  where source_reference like 'KNG-GEN-AGREEMENT-%';

  -- Business registration events use the existing fictional incorporation date.
  insert into game.organisation_lifecycle_events(
    event_ref,organisation_id,event_type,occurred_on,recorded_on,
    resulting_name,subject,description,actor_person_id,source_reference,
    source_description,event_details
  )
  select
    'KW-LIFE-REG-'||bp.business_number,bp.organisation_id,'registered',
    bp.incorporation_date,coalesce(bp.incorporation_date,current_date),
    coalesce(bp.trading_name,o.name),
    'Business registration: '||coalesce(bp.trading_name,o.name),
    'Generated fictional registration history using the canonical business incorporation date.',
    (select ci.holder_person_id from game.organisation_control_interests ci
      where ci.organisation_id=bp.organisation_id
        and ci.source_reference like 'KNG-GEN-CONTROL-'||bp.business_number||'-%'
      order by ci.source_reference limit 1),
    bp.business_number,
    'Kingswell generated fictional business registration baseline.',
    jsonb_build_object('generated_fictional_baseline',true,
      'source_business_number',bp.business_number,
      'incorporation_date_source','business_profiles.incorporation_date')
  from game.business_profiles bp
  join game.organisations o on o.id=bp.organisation_id
  where not exists(select 1 from game.organisation_lifecycle_events e
    where e.event_ref='KW-LIFE-REG-'||bp.business_number)
  on conflict(event_ref) do nothing;
  get diagnostics v_lifecycle=row_count;

  -- Unit infrastructure is a unit-level view of the existing building design
  -- profile and unit meter/access records, not a duplicate address system.
  insert into game.building_unit_infrastructure_profiles(
    building_unit_id,electrical_supply_status,water_supply_status,wastewater_status,
    gas_supply_status,telecoms_status,heating_cooling_status,fire_detection_status,
    fire_suppression_status,access_control_status,meter_register,utility_details,
    access_details,fire_safety_details,source_reference,source_description,provenance
  )
  select
    u.id,
    case when bp.building_systems->>'electricity'='mains' then 'connected' else 'unknown' end,
    case when bp.building_systems->>'water'='mains' then 'connected' else 'unknown' end,
    case when bp.building_systems->>'sewerage'='mains' then 'connected' else 'unknown' end,
    'unknown',
    case when bp.building_systems->>'telecommunications' is not null then 'connected' else 'unknown' end,
    case
      when bp.building_systems->>'heating_cooling_ventilation' ilike '%central%' then 'central'
      when bp.building_systems->>'heating_cooling_ventilation' is not null then 'unit_level'
      else 'unknown'
    end,
    case when bp.fire_alarm_type is not null then 'present' else 'unknown' end,
    case when bp.sprinklered then 'present' else 'absent' end,
    case
      when bp.access_control_type ilike '%electronic%' or bp.access_control_type ilike '%keycard%' then 'controlled'
      when bp.access_control_type ilike '%key%' or bp.access_control_type='managed_keys' then 'mechanical_key'
      else 'unknown'
    end,
    coalesce(up.utility_meter_refs,'{}'::jsonb),
    coalesce(bp.building_systems,'{}'::jsonb),
    jsonb_build_object('unit_access_notes',up.access_notes,'security_zone',up.security_zone,
      'building_access_control',bp.access_control_type),
    jsonb_build_object('fire_alarm_type',bp.fire_alarm_type,'sprinklered',bp.sprinklered,
      'fire_compartment_count',bp.fire_compartment_count),
    'KNG-GEN-INFRA-'||u.unit_ref,
    'Generated fictional unit infrastructure profile composed from canonical building-system and unit-metering design records.',
    jsonb_build_object('generated_fictional_baseline',true,
      'building_ref',b.building_ref,'unit_ref',u.unit_ref,
      'meter_readings_not_asserted',true)
  from game.building_units u
  join game.buildings b on b.id=u.building_id
  join game.building_profiles bp on bp.building_id=b.id
  join game.building_unit_profiles up on up.building_unit_id=u.id
  on conflict(building_unit_id) do update set
    electrical_supply_status=excluded.electrical_supply_status,
    water_supply_status=excluded.water_supply_status,
    wastewater_status=excluded.wastewater_status,
    gas_supply_status=excluded.gas_supply_status,
    telecoms_status=excluded.telecoms_status,
    heating_cooling_status=excluded.heating_cooling_status,
    fire_detection_status=excluded.fire_detection_status,
    fire_suppression_status=excluded.fire_suppression_status,
    access_control_status=excluded.access_control_status,
    meter_register=excluded.meter_register,
    utility_details=excluded.utility_details,
    access_details=excluded.access_details,
    fire_safety_details=excluded.fire_safety_details,
    source_reference=excluded.source_reference,
    source_description=excluded.source_description,
    provenance=excluded.provenance,
    updated_at=now();
  get diagnostics v_infrastructure=row_count;

  -- Building system assets are individual fictional inventory records derived
  -- from the canonical building-specific system profiles.
  with asset_rows as (
    select b.id building_id,b.property_id,b.building_ref,b.name building_name,
      bp.construction_year,bp.condition_grade,bp.building_systems,
      x.asset_category,x.asset_name,x.asset_description,x.system_subtype
    from game.buildings b
    join game.building_profiles bp on bp.building_id=b.id
    cross join lateral (values
      ('electrical_system','Electrical distribution system','Building electrical intake and distribution system',bp.building_systems->>'electricity',bp.building_systems->>'electricity' is not null),
      ('water_system','Water supply system','Building water supply and internal distribution',bp.building_systems->>'water',bp.building_systems->>'water' is not null),
      ('wastewater_system','Wastewater system','Building wastewater and sewerage connection',bp.building_systems->>'sewerage',bp.building_systems->>'sewerage' is not null),
      ('telecommunications','Telecommunications system','Building fixed and mobile telecommunications provision',bp.building_systems->>'telecommunications',bp.building_systems->>'telecommunications' is not null),
      ('heating_ventilation_air_conditioning','Heating, cooling and ventilation system','Building HVAC and ventilation provision',bp.building_systems->>'heating_cooling_ventilation',bp.building_systems->>'heating_cooling_ventilation' is not null),
      ('fire_detection','Fire detection and alarm system','Building fire detection and alarm provision',bp.fire_alarm_type,bp.fire_alarm_type is not null),
      ('fire_suppression','Fire suppression system','Building sprinkler and suppression provision','sprinklered',bp.sprinklered is true),
      ('lift_escalator','Lift and vertical transport system','Building lift and vertical transport equipment',bp.lift_count::text,bp.lift_count>0),
      ('generator_backup_power','Backup power system','Building standby generation and backup power provision',bp.generator_capacity_kva::text,bp.backup_power is true),
      ('cctv','CCTV system','Building CCTV coverage system',bp.cctv_coverage,bp.cctv_coverage is not null),
      ('access_control','Access control system','Building access-control system',bp.access_control_type,bp.access_control_type is not null),
      ('structural_component','Primary structural system','Building primary structural components',bp.structural_system,bp.structural_system is not null),
      ('roofing','Roofing system','Building roof form and weatherproofing system',bp.roof_form,bp.roof_form is not null)
    ) x(asset_category,asset_name,asset_description,system_subtype,include_asset)
    where x.include_asset
  )
  insert into game.property_physical_assets(
    asset_ref,property_id,building_id,asset_category,asset_name,asset_description,
    system_subtype,installation_date,commissioning_date,asset_status,condition_grade,
    source_reference,source_description,technical_details,provenance
  )
  select
    'KNG-ASSET-'||substr(md5(a.building_ref||':'||a.asset_category),1,22),
    a.property_id,a.building_id,a.asset_category,a.asset_name,a.asset_description,
    a.system_subtype,
    case when a.construction_year between 1800 and 2100 then make_date(a.construction_year,1,1) else null end,
    case when a.construction_year between 1800 and 2100 then make_date(a.construction_year,1,1) else null end,
    'installed',
    case when a.condition_grade in ('excellent','good','fair','poor','critical') then a.condition_grade else 'unknown' end,
    'KNG-GEN-ASSET-'||a.building_ref||'-'||a.asset_category,
    'Generated fictional asset inventory from the canonical Kingswell building-system design profile.',
    jsonb_build_object('building_ref',a.building_ref,'building_name',a.building_name,
      'building_systems',coalesce(a.building_systems,'{}'::jsonb),
      'manufacturer_and_serial','not_recorded',
      'inventory_basis','generated fictional building system asset'),
    jsonb_build_object('generated_fictional_baseline',true,
      'source_building_profile',a.building_ref,
      'installation_year_basis',a.construction_year)
  from asset_rows a
  on conflict(asset_ref) do nothing;
  get diagnostics v_assets=row_count;

  -- Each generated asset receives an inspection record and a linked maintenance
  -- history placeholder. The date is explicitly unknown; no real-world action
  -- or unrecorded repair is asserted.
  insert into game.physical_asset_maintenance_events(
    event_ref,asset_id,event_type,event_status,priority,summary,findings,
    work_performed,outstanding_actions,source_reference,source_description,event_details
  )
  select
    'KNG-INSP-'||substr(md5(a.asset_ref),1,22),a.id,'inspection','recorded','routine',
    'Generated baseline inspection profile: '||a.asset_name,
    'Fictional baseline condition: '||a.condition_grade||'.',
    'Asset profile reviewed as part of Kingswell world generation; no repair or replacement is asserted.',
    'Dated physical inspection remains unknown; future in-game inspection can create a dated event.',
    'KNG-GEN-INSP-'||a.asset_ref,
    'Generated fictional inspection baseline for the Kingswell simulation.',
    jsonb_build_object('generated_fictional_baseline',true,
      'inspection_date_unknown',true,'physical_inspection_not_independently_dated',true)
  from game.property_physical_assets a
  where a.provenance->>'generated_fictional_baseline'='true'
    and not exists(select 1 from game.physical_asset_maintenance_events m
      where m.event_ref='KNG-INSP-'||substr(md5(a.asset_ref),1,22));
  get diagnostics v_maintenance=row_count;

  -- One current condition event per building gives property dossiers a
  -- searchable baseline while retaining the original profile as provenance.
  insert into game.property_asset_events(
    event_ref,property_id,building_id,event_type,event_status,severity,occurred_on,
    subject,description,findings,action_required,source_reference,source_description,event_details
  )
  select
    'KNG-COND-'||b.building_ref,b.property_id,b.id,'condition_assessment','recorded',
    case bp.condition_grade when 'excellent' then 'low' when 'good' then 'low'
      when 'fair' then 'moderate' when 'poor' then 'high'
      when 'critical' then 'critical' else 'unknown' end,
    null,'Generated baseline building condition: '||b.building_ref,
    'Generated fictional condition summary from the canonical building profile; no independent dated survey is claimed.',
    'Recorded profile condition: '||bp.condition_grade||'.',
    case when bp.condition_grade in ('poor','critical')
      then 'Schedule a detailed in-game condition inspection and maintenance review.'
      else 'No additional action is recorded in this baseline.' end,
    'KNG-GEN-COND-'||b.building_ref,
    'Generated fictional building condition baseline.',
    jsonb_build_object('generated_fictional_baseline',true,
      'source_building_profile',b.building_ref,'assessment_date_unknown',true)
  from game.buildings b
  join game.building_profiles bp on bp.building_id=b.id
  where not exists(select 1 from game.property_asset_events e
    where e.event_ref='KNG-COND-'||b.building_ref)
  on conflict(event_ref) where event_ref is not null do nothing;
  get diagnostics v_property_events=row_count;

  select count(*) into v_ownership
  from game.organisation_control_interests
  where source_reference like 'KNG-GEN-CONTROL-%';
  select count(*) into v_title
  from game.property_title_events
  where event_ref like 'KW-TITLE-INIT-%';
  select count(*) into v_counterparties
  from game.organisation_site_agreements
  where counterparty_person_id is not null or counterparty_organisation_id is not null;
  select count(*) into v_agreement_terms
  from game.organisation_site_agreements
  where execution_date is not null and effective_from is not null and rent_amount is not null
    and rent_currency is not null and rent_frequency is not null and deposit_amount is not null
    and permitted_use is not null and restrictions is not null
    and repair_responsibility is not null and service_charge_responsibility is not null
    and subletting_allowed is not null;
  select count(*) into v_agreement_events
  from game.organisation_site_agreement_events
  where source_reference like 'KNG-GEN-AGREEMENT-%';
  select count(*) into v_lifecycle
  from game.organisation_lifecycle_events
  where event_ref like 'KW-LIFE-REG-%';

  return jsonb_build_object(
    'ok',true,'businesses',v_businesses,'persons_available',v_people,
    'control_interest_records',v_ownership,'title_register_events',v_title,
    'agreements_with_counterparty',v_counterparties,'agreements_with_complete_terms',v_agreement_terms,
    'agreement_lifecycle_events',v_agreement_events,'business_lifecycle_events',v_lifecycle,
    'physical_assets_inserted',v_assets,'unit_infrastructure_rows_affected',v_infrastructure,
    'inspection_events_inserted',v_maintenance,'property_condition_events_inserted',v_property_events,
    'organisation_structure',v_structure,'idempotent',true
  );
end;
$function$;

revoke all on function game.seed_bp04_complete_world() from public,anon,authenticated;
grant execute on function game.seed_bp04_complete_world() to service_role;

-- The live fictional world already has its canonical population. The isolated
-- CI database invokes the same function after its deterministic fixture load.
do $seed$
begin
  if exists(select 1 from game.persons)
     and exists(select 1 from game.business_profiles)
     and exists(select 1 from game.organisation_personnel) then
    perform game.seed_bp04_complete_world();
  end if;
end
$seed$;

-- ---------------------------------------------------------------------------
-- 3. Canonical premises identity across incidents, scenes, evidence, cases
--    and search operations.
-- ---------------------------------------------------------------------------
alter table game.incidents
  add column if not exists location_building_id uuid references game.buildings(id) on delete restrict;

create or replace function game.validate_incident_premises_identity()
returns trigger
language plpgsql
set search_path to 'pg_catalog','game'
as $function$
declare v_building_id uuid; v_property_id uuid;
begin
  if new.location_building_unit_id is not null then
    select u.building_id,b.property_id into v_building_id,v_property_id
    from game.building_units u join game.buildings b on b.id=u.building_id
    where u.id=new.location_building_unit_id;
    if v_building_id is null then raise exception 'Incident building unit does not exist'; end if;
    if new.location_building_id is null then new.location_building_id:=v_building_id; end if;
    if new.location_building_id<>v_building_id then
      raise exception 'Incident building does not contain the selected building unit';
    end if;
    if new.location_property_id is null then new.location_property_id:=v_property_id; end if;
    if new.location_property_id<>v_property_id then
      raise exception 'Incident property does not contain the selected building unit';
    end if;
  elsif new.location_building_id is not null then
    select property_id into v_property_id from game.buildings where id=new.location_building_id;
    if v_property_id is null then raise exception 'Incident building does not exist'; end if;
    if new.location_property_id is null then new.location_property_id:=v_property_id; end if;
    if new.location_property_id<>v_property_id then
      raise exception 'Incident property does not contain the selected building';
    end if;
  end if;
  return new;
end;
$function$;
drop trigger if exists incidents_premises_identity on game.incidents;
create trigger incidents_premises_identity
before insert or update of location_property_id,location_building_id,location_building_unit_id
on game.incidents for each row execute function game.validate_incident_premises_identity();

update game.incidents i
set location_building_id=u.building_id
from game.building_units u
where i.location_building_unit_id=u.id and i.location_building_id is null;

alter table game.incident_scenes
  add column if not exists property_id uuid references game.properties(id) on delete restrict,
  add column if not exists building_id uuid references game.buildings(id) on delete restrict,
  add column if not exists building_unit_id uuid references game.building_units(id) on delete restrict;

create or replace function game.validate_scene_premises_identity()
returns trigger
language plpgsql
set search_path to 'pg_catalog','game'
as $function$
declare v_building_id uuid; v_property_id uuid;
begin
  if new.building_unit_id is not null then
    select u.building_id,b.property_id into v_building_id,v_property_id
    from game.building_units u join game.buildings b on b.id=u.building_id
    where u.id=new.building_unit_id;
    if v_building_id is null then raise exception 'Scene building unit does not exist'; end if;
    if new.building_id is null then new.building_id:=v_building_id; end if;
    if new.building_id<>v_building_id then raise exception 'Scene building does not contain its unit'; end if;
    if new.property_id is null then new.property_id:=v_property_id; end if;
    if new.property_id<>v_property_id then raise exception 'Scene property does not contain its building unit'; end if;
  elsif new.building_id is not null then
    select property_id into v_property_id from game.buildings where id=new.building_id;
    if v_property_id is null then raise exception 'Scene building does not exist'; end if;
    if new.property_id is null then new.property_id:=v_property_id; end if;
    if new.property_id<>v_property_id then raise exception 'Scene property does not contain its building'; end if;
  end if;

  if new.property_id is null and new.building_id is null and new.building_unit_id is null then
    select i.location_property_id,i.location_building_id,i.location_building_unit_id
      into new.property_id,new.building_id,new.building_unit_id
    from game.incidents i where i.id=new.incident_id;
  end if;
  return new;
end;
$function$;
drop trigger if exists incident_scenes_premises_identity on game.incident_scenes;
create trigger incident_scenes_premises_identity
before insert or update of incident_id,property_id,building_id,building_unit_id
on game.incident_scenes for each row execute function game.validate_scene_premises_identity();

update game.incident_scenes s
set property_id=i.location_property_id,building_id=i.location_building_id,
    building_unit_id=i.location_building_unit_id
from game.incidents i
where i.id=s.incident_id
  and s.property_id is null and s.building_id is null and s.building_unit_id is null;

alter table game.evidence_items
  add column if not exists scene_id uuid references game.incident_scenes(id) on delete restrict,
  add column if not exists property_id uuid references game.properties(id) on delete restrict,
  add column if not exists building_id uuid references game.buildings(id) on delete restrict,
  add column if not exists building_unit_id uuid references game.building_units(id) on delete restrict;

create or replace function game.validate_evidence_premises_identity()
returns trigger
language plpgsql
set search_path to 'pg_catalog','game'
as $function$
declare v_scene game.incident_scenes%rowtype; v_incident game.incidents%rowtype;
  v_building_id uuid; v_property_id uuid;
begin
  if new.scene_id is not null then
    select * into v_scene from game.incident_scenes where id=new.scene_id;
    if v_scene.id is null then raise exception 'Evidence scene does not exist'; end if;
    if new.incident_id is null then new.incident_id:=v_scene.incident_id; end if;
    if new.incident_id<>v_scene.incident_id then raise exception 'Evidence scene and incident do not match'; end if;
    if new.property_id is null then new.property_id:=v_scene.property_id; end if;
    if new.building_id is null then new.building_id:=v_scene.building_id; end if;
    if new.building_unit_id is null then new.building_unit_id:=v_scene.building_unit_id; end if;
  elsif new.incident_id is not null then
    select * into v_incident from game.incidents where id=new.incident_id;
    if new.property_id is null then new.property_id:=v_incident.location_property_id; end if;
    if new.building_id is null then new.building_id:=v_incident.location_building_id; end if;
    if new.building_unit_id is null then new.building_unit_id:=v_incident.location_building_unit_id; end if;
  end if;

  if new.building_unit_id is not null then
    select u.building_id,b.property_id into v_building_id,v_property_id
    from game.building_units u join game.buildings b on b.id=u.building_id
    where u.id=new.building_unit_id;
    if new.building_id is null then new.building_id:=v_building_id; end if;
    if new.property_id is null then new.property_id:=v_property_id; end if;
    if new.building_id<>v_building_id or new.property_id<>v_property_id then
      raise exception 'Evidence property/building/unit references do not form one canonical hierarchy';
    end if;
  elsif new.building_id is not null then
    select property_id into v_property_id from game.buildings where id=new.building_id;
    if new.property_id is null then new.property_id:=v_property_id; end if;
    if new.property_id<>v_property_id then raise exception 'Evidence property does not contain its building'; end if;
  end if;
  return new;
end;
$function$;
drop trigger if exists evidence_items_premises_identity on game.evidence_items;
create trigger evidence_items_premises_identity
before insert or update of incident_id,scene_id,property_id,building_id,building_unit_id
on game.evidence_items for each row execute function game.validate_evidence_premises_identity();

-- Exact location of every recovered exhibit is retained as append-only history.
create table if not exists game.evidence_premises_history (
 id uuid primary key default gen_random_uuid(),
 recovery_id uuid not null unique references game.scene_evidence_recoveries(id) on delete restrict,
 evidence_id uuid not null references game.evidence_items(id) on delete restrict,
 scene_id uuid not null references game.incident_scenes(id) on delete restrict,
 property_id uuid not null references game.properties(id) on delete restrict,
 building_id uuid references game.buildings(id) on delete restrict,
 building_unit_id uuid references game.building_units(id) on delete restrict,
 recorded_by_personnel_id uuid not null references game.police_personnel(id) on delete restrict,
 recorded_at timestamptz not null,
 source_reference text not null,
 details jsonb not null default '{}'::jsonb check(jsonb_typeof(details)='object'),
 created_at timestamptz not null default now(),
 check(building_unit_id is null or building_id is not null)
);
create index if not exists evidence_premises_history_evidence_idx
 on game.evidence_premises_history(evidence_id,recorded_at);
alter table game.evidence_premises_history enable row level security;
revoke all on game.evidence_premises_history from public,anon,authenticated;
grant all on game.evidence_premises_history to service_role;

create or replace function game.prevent_evidence_premises_history_mutation()
returns trigger language plpgsql set search_path to 'pg_catalog','game'
as $function$
begin raise exception 'Evidence premises history is append-only'; end;
$function$;
drop trigger if exists evidence_premises_history_append_only on game.evidence_premises_history;
create trigger evidence_premises_history_append_only
before update or delete on game.evidence_premises_history
for each row execute function game.prevent_evidence_premises_history_mutation();

create or replace function game.capture_evidence_recovery_premises()
returns trigger
language plpgsql
set search_path to 'pg_catalog','game'
as $function$
declare v_scene game.incident_scenes%rowtype; v_evidence game.evidence_items%rowtype;
begin
  select * into v_scene from game.incident_scenes where id=new.scene_id;
  select * into v_evidence from game.evidence_items where id=new.evidence_id;
  if v_scene.id is null or v_evidence.id is null then
    raise exception 'Evidence recovery must reference an existing scene and evidence item';
  end if;
  if v_scene.property_id is not null then
    if v_evidence.scene_id is not null and v_evidence.scene_id<>v_scene.id then
      raise exception 'Evidence item is already assigned to a different primary scene; record a separate recovery location';
    end if;
    update game.evidence_items
    set scene_id=coalesce(scene_id,new.scene_id),
        property_id=coalesce(property_id,v_scene.property_id),
        building_id=coalesce(building_id,v_scene.building_id),
        building_unit_id=coalesce(building_unit_id,v_scene.building_unit_id)
    where id=new.evidence_id;
    insert into game.evidence_premises_history(
      recovery_id,evidence_id,scene_id,property_id,building_id,building_unit_id,
      recorded_by_personnel_id,recorded_at,source_reference,details
    ) values (
      new.id,new.evidence_id,new.scene_id,v_scene.property_id,v_scene.building_id,
      v_scene.building_unit_id,new.recovered_by_personnel_id,new.recovered_at,
      new.recovery_ref,jsonb_build_object('generated_from','scene_evidence_recoveries',
        'recovery_location_description',new.recovery_location)
    ) on conflict(recovery_id) do nothing;
  end if;
  return new;
end;
$function$;
drop trigger if exists scene_evidence_recoveries_capture_premises on game.scene_evidence_recoveries;
create trigger scene_evidence_recoveries_capture_premises
after insert on game.scene_evidence_recoveries
for each row execute function game.capture_evidence_recovery_premises();

-- Case lead site links inherit exact premises identity from the canonical site dossier.
alter table game.case_lead_entity_links
  add column if not exists premises_property_id uuid references game.properties(id) on delete restrict,
  add column if not exists premises_building_id uuid references game.buildings(id) on delete restrict,
  add column if not exists premises_building_unit_id uuid references game.building_units(id) on delete restrict;

create or replace function game.validate_case_lead_premises_identity()
returns trigger language plpgsql set search_path to 'pg_catalog','game'
as $function$
declare v_site game.organisation_site_dossiers%rowtype; v_building_id uuid;
begin
  if new.entity_type='site' and new.organisation_location_id is not null then
    select * into v_site from game.organisation_site_dossiers
    where organisation_location_id=new.organisation_location_id;
    if v_site.organisation_location_id is null then raise exception 'Case lead site link has no canonical site dossier'; end if;
    new.premises_property_id:=v_site.property_id;
    new.premises_building_unit_id:=v_site.building_unit_id;
    select building_id into v_building_id from game.building_units where id=v_site.building_unit_id;
    new.premises_building_id:=v_building_id;
  elsif new.entity_type='property' and new.property_id is not null then
    new.premises_property_id:=new.property_id;
  end if;
  if new.premises_building_unit_id is not null then
    select building_id into v_building_id from game.building_units where id=new.premises_building_unit_id;
    if new.premises_building_id is null then new.premises_building_id:=v_building_id; end if;
    if new.premises_building_id<>v_building_id then raise exception 'Case lead building does not contain its premises unit'; end if;
  end if;
  if new.premises_building_id is not null and not exists(
    select 1 from game.buildings b where b.id=new.premises_building_id
      and b.property_id=new.premises_property_id
  ) then raise exception 'Case lead property does not contain its premises building'; end if;
  return new;
end;
$function$;
drop trigger if exists case_lead_entity_links_premises_identity on game.case_lead_entity_links;
create trigger case_lead_entity_links_premises_identity
before insert or update of entity_type,organisation_location_id,property_id,
 premises_property_id,premises_building_id,premises_building_unit_id
on game.case_lead_entity_links for each row execute function game.validate_case_lead_premises_identity();

-- Search warrants and premises retain the exact building/unit searched, not just the parcel.
alter table game.search_premises
  add column if not exists building_id uuid references game.buildings(id) on delete restrict,
  add column if not exists building_unit_id uuid references game.building_units(id) on delete restrict;

create or replace function game.validate_search_premises_identity()
returns trigger language plpgsql set search_path to 'pg_catalog','game'
as $function$
declare v_building_id uuid; v_property_id uuid;
begin
  if new.building_unit_id is not null then
    select u.building_id,b.property_id into v_building_id,v_property_id
    from game.building_units u join game.buildings b on b.id=u.building_id
    where u.id=new.building_unit_id;
    if new.building_id is null then new.building_id:=v_building_id; end if;
    if new.property_id<>v_property_id or new.building_id<>v_building_id then
      raise exception 'Search premises property/building/unit references do not form one canonical hierarchy';
    end if;
  elsif new.building_id is not null then
    select property_id into v_property_id from game.buildings where id=new.building_id;
    if new.property_id<>v_property_id then raise exception 'Search premises property does not contain its building'; end if;
  end if;
  return new;
end;
$function$;
drop trigger if exists search_premises_identity on game.search_premises;
create trigger search_premises_identity
before insert or update of property_id,building_id,building_unit_id
on game.search_premises for each row execute function game.validate_search_premises_identity();

create table if not exists game.search_premises_location_history (
 id uuid primary key default gen_random_uuid(),
 event_ref text not null unique,
 premises_id uuid not null references game.search_premises(id) on delete restrict,
 property_id uuid not null references game.properties(id) on delete restrict,
 building_id uuid references game.buildings(id) on delete restrict,
 building_unit_id uuid references game.building_units(id) on delete restrict,
 reason text not null,
 recorded_by_personnel_id uuid not null references game.police_personnel(id) on delete restrict,
 recorded_at_game_time timestamptz not null,
 source_command_id uuid references game.game_commands(id) on delete restrict,
 created_at timestamptz not null default now(),
 check(building_unit_id is null or building_id is not null)
);
create index if not exists search_premises_location_history_idx
 on game.search_premises_location_history(premises_id,recorded_at_game_time);
alter table game.search_premises_location_history enable row level security;
revoke all on game.search_premises_location_history from public,anon,authenticated;
grant all on game.search_premises_location_history to service_role;

create or replace function game.prevent_search_premises_location_history_mutation()
returns trigger language plpgsql set search_path to 'pg_catalog','game'
as $function$
begin raise exception 'Search premises location history is append-only'; end;
$function$;
drop trigger if exists search_premises_location_history_append_only on game.search_premises_location_history;
create trigger search_premises_location_history_append_only
before update or delete on game.search_premises_location_history
for each row execute function game.prevent_search_premises_location_history_mutation();

-- Incident-location site associations must match the incident's exact recorded
-- building/unit where those details are known, not merely share a property.
create or replace function game.validate_incident_site_exact_premises()
returns trigger language plpgsql set search_path to 'pg_catalog','game'
as $function$
declare v_incident game.incidents%rowtype; v_site game.organisation_site_dossiers%rowtype;
  v_site_building_id uuid;
begin
  if new.relation_type<>'incident_location' then return new; end if;
  select * into v_incident from game.incidents where id=new.incident_id;
  select * into v_site from game.organisation_site_dossiers
    where organisation_location_id=new.organisation_location_id;
  if v_incident.id is null or v_site.organisation_location_id is null then
    raise exception 'Incident-location association requires an existing incident and canonical site';
  end if;
  if v_incident.location_property_id is distinct from v_site.property_id then
    raise exception 'Incident-location site must match the incident property';
  end if;
  if v_site.building_unit_id is not null then
    select building_id into v_site_building_id from game.building_units where id=v_site.building_unit_id;
  end if;
  if v_incident.location_building_id is not null
     and v_incident.location_building_id is distinct from v_site_building_id then
    raise exception 'Incident-location site must match the incident building';
  end if;
  if v_incident.location_building_unit_id is not null
     and v_incident.location_building_unit_id is distinct from v_site.building_unit_id then
    raise exception 'Incident-location site must match the incident unit';
  end if;
  return new;
end;
$function$;
drop trigger if exists incident_site_associations_exact_premises on game.incident_site_associations;
create trigger incident_site_associations_exact_premises
before insert on game.incident_site_associations
for each row execute function game.validate_incident_site_exact_premises();

-- ---------------------------------------------------------------------------
-- 4. Append-only scene premises history and player-facing commands
-- ---------------------------------------------------------------------------
create table if not exists game.scene_premises_history (
 id uuid primary key default gen_random_uuid(),
 event_ref text not null unique,
 scene_id uuid not null references game.incident_scenes(id) on delete restrict,
 property_id uuid not null references game.properties(id) on delete restrict,
 building_id uuid references game.buildings(id) on delete restrict,
 building_unit_id uuid references game.building_units(id) on delete restrict,
 reason text not null,
 recorded_by_personnel_id uuid not null references game.police_personnel(id) on delete restrict,
 recorded_at_game_time timestamptz not null,
 source_command_id uuid references game.game_commands(id) on delete restrict,
 created_at timestamptz not null default now(),
 check(building_unit_id is null or building_id is not null)
);
create index if not exists scene_premises_history_scene_idx
 on game.scene_premises_history(scene_id,recorded_at_game_time);
alter table game.scene_premises_history enable row level security;
revoke all on game.scene_premises_history from public,anon,authenticated;
grant all on game.scene_premises_history to service_role;

create or replace function game.prevent_scene_premises_history_mutation()
returns trigger language plpgsql set search_path to 'pg_catalog','game'
as $function$
begin raise exception 'Scene premises history is append-only'; end;
$function$;
drop trigger if exists scene_premises_history_append_only on game.scene_premises_history;
create trigger scene_premises_history_append_only
before update or delete on game.scene_premises_history
for each row execute function game.prevent_scene_premises_history_mutation();

create or replace function game.record_scene_premises(
 p_scene_ref text,p_property_ref text,p_building_ref text,p_unit_ref text,
 p_reason text,p_actor_ref text,p_command_id uuid
) returns jsonb
language plpgsql
set search_path to 'pg_catalog','game'
as $function$
declare
 v_scene game.incident_scenes%rowtype; v_actor game.police_personnel%rowtype;
 v_property game.properties%rowtype; v_building game.buildings%rowtype;
 v_unit game.building_units%rowtype; v_clock timestamptz; v_event game.scene_premises_history%rowtype;
begin
 select * into v_scene from game.incident_scenes where scene_ref=btrim(p_scene_ref) for update;
 if v_scene.id is null then return jsonb_build_object('ok',false,'code','scene_not_found'); end if;
 select * into v_actor from game.police_personnel
  where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if v_actor.id is null then return jsonb_build_object('ok',false,'code','actor_unavailable'); end if;
 select * into v_property from game.properties where property_ref=btrim(p_property_ref);
 if v_property.id is null then return jsonb_build_object('ok',false,'code','property_not_found'); end if;
 if nullif(lower(btrim(p_building_ref)),'unknown') is not null then
  select * into v_building from game.buildings where building_ref=btrim(p_building_ref);
  if v_building.id is null or v_building.property_id<>v_property.id then
   return jsonb_build_object('ok',false,'code','building_not_in_property');
  end if;
 end if;
 if nullif(lower(btrim(p_unit_ref)),'unknown') is not null then
  if v_building.id is null then return jsonb_build_object('ok',false,'code','building_required_for_unit'); end if;
  select * into v_unit from game.building_units where unit_ref=btrim(p_unit_ref);
  if v_unit.id is null or v_unit.building_id<>v_building.id then
   return jsonb_build_object('ok',false,'code','unit_not_in_building');
  end if;
 end if;
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then v_clock:=now(); end if;
 if length(btrim(coalesce(p_reason,''))) not between 3 and 2000 then
  return jsonb_build_object('ok',false,'code','invalid_reason');
 end if;
 update game.incident_scenes set property_id=v_property.id,
  building_id=v_building.id,building_unit_id=v_unit.id,updated_at=now()
 where id=v_scene.id;
 insert into game.scene_premises_history(
  event_ref,scene_id,property_id,building_id,building_unit_id,reason,
  recorded_by_personnel_id,recorded_at_game_time,source_command_id
 ) values (
  'KNG-SPH-'||replace(gen_random_uuid()::text,'-',''),v_scene.id,
  v_property.id,v_building.id,v_unit.id,btrim(p_reason),v_actor.id,v_clock,p_command_id
 ) returning * into v_event;
 return jsonb_build_object('ok',true,'record_type','scene_premises',
  'scene_ref',v_scene.scene_ref,'property_ref',v_property.property_ref,
  'building_ref',v_building.building_ref,'unit_ref',v_unit.unit_ref,
  'event_ref',v_event.event_ref,'recorded_at_game_time',v_clock);
end;
$function$;

create or replace function game.get_scene_premises_record(p_scene_ref text)
returns jsonb
language sql stable
set search_path to 'pg_catalog','game'
as $function$
 select jsonb_build_object(
  'scene_ref',s.scene_ref,
  'current',jsonb_build_object(
   'property_ref',p.property_ref,'building_ref',b.building_ref,'unit_ref',u.unit_ref,
   'property_id',s.property_id,'building_id',s.building_id,'building_unit_id',s.building_unit_id
  ),
  'history',coalesce((select jsonb_agg(jsonb_build_object(
    'event_ref',h.event_ref,'property_ref',hp.property_ref,'building_ref',hb.building_ref,
    'unit_ref',hu.unit_ref,'reason',h.reason,'recorded_by',pp.personnel_ref,
    'recorded_at_game_time',h.recorded_at_game_time
  ) order by h.recorded_at_game_time,h.created_at)
  from game.scene_premises_history h
  join game.properties hp on hp.id=h.property_id
  left join game.buildings hb on hb.id=h.building_id
  left join game.building_units hu on hu.id=h.building_unit_id
  join game.police_personnel pp on pp.id=h.recorded_by_personnel_id
  where h.scene_id=s.id),'[]'::jsonb)
 )
 from game.incident_scenes s
 left join game.properties p on p.id=s.property_id
 left join game.buildings b on b.id=s.building_id
 left join game.building_units u on u.id=s.building_unit_id
 where s.scene_ref=btrim(p_scene_ref);
$function$;

create or replace function game.record_search_premises_location(
 p_premises_ref text,p_building_ref text,p_unit_ref text,p_reason text,p_actor_ref text,p_command_id uuid
) returns jsonb
language plpgsql
set search_path to 'pg_catalog','game'
as $function$
declare v_premises game.search_premises%rowtype; v_actor game.police_personnel%rowtype;
 v_building game.buildings%rowtype; v_unit game.building_units%rowtype; v_clock timestamptz;
begin
 select * into v_premises from game.search_premises where premises_ref=btrim(p_premises_ref) for update;
 if v_premises.id is null then return jsonb_build_object('ok',false,'code','search_premises_not_found'); end if;
 select * into v_actor from game.police_personnel
  where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if v_actor.id is null then return jsonb_build_object('ok',false,'code','actor_unavailable'); end if;
 if nullif(lower(btrim(p_building_ref)),'unknown') is not null then
  select * into v_building from game.buildings where building_ref=btrim(p_building_ref);
  if v_building.id is null or v_building.property_id<>v_premises.property_id then
   return jsonb_build_object('ok',false,'code','building_not_in_property');
  end if;
 end if;
 if nullif(lower(btrim(p_unit_ref)),'unknown') is not null then
  if v_building.id is null then return jsonb_build_object('ok',false,'code','building_required_for_unit'); end if;
  select * into v_unit from game.building_units where unit_ref=btrim(p_unit_ref);
  if v_unit.id is null or v_unit.building_id<>v_building.id then
   return jsonb_build_object('ok',false,'code','unit_not_in_building');
  end if;
 end if;
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then v_clock:=now(); end if;
 if length(btrim(coalesce(p_reason,''))) not between 3 and 2000 then
  return jsonb_build_object('ok',false,'code','invalid_reason');
 end if;
 update game.search_premises set building_id=v_building.id,building_unit_id=v_unit.id
 where id=v_premises.id;
 insert into game.search_premises_location_history(
  event_ref,premises_id,property_id,building_id,building_unit_id,reason,
  recorded_by_personnel_id,recorded_at_game_time,source_command_id
 ) values (
  'KNG-SPLH-'||replace(gen_random_uuid()::text,'-',''),v_premises.id,v_premises.property_id,
  v_building.id,v_unit.id,btrim(p_reason),v_actor.id,v_clock,p_command_id
 );
 return jsonb_build_object('ok',true,'record_type','search_premises_location',
  'premises_ref',v_premises.premises_ref,'property_id',v_premises.property_id,
  'building_ref',v_building.building_ref,'unit_ref',v_unit.unit_ref,
  'recorded_at_game_time',v_clock);
end;
$function$;

create or replace function game.get_search_premises_location(p_premises_ref text)
returns jsonb
language sql stable set search_path to 'pg_catalog','game'
as $function$
 select jsonb_build_object(
  'premises_ref',sp.premises_ref,'property_ref',p.property_ref,
  'building_ref',b.building_ref,'unit_ref',u.unit_ref,
  'history',coalesce((select jsonb_agg(jsonb_build_object(
    'event_ref',h.event_ref,'building_ref',hb.building_ref,'unit_ref',hu.unit_ref,
    'reason',h.reason,'recorded_by',pp.personnel_ref,
    'recorded_at_game_time',h.recorded_at_game_time
  ) order by h.recorded_at_game_time,h.created_at)
  from game.search_premises_location_history h
  left join game.buildings hb on hb.id=h.building_id
  left join game.building_units hu on hu.id=h.building_unit_id
  join game.police_personnel pp on pp.id=h.recorded_by_personnel_id
  where h.premises_id=sp.id),'[]'::jsonb)
 )
 from game.search_premises sp
 join game.properties p on p.id=sp.property_id
 left join game.buildings b on b.id=sp.building_id
 left join game.building_units u on u.id=sp.building_unit_id
 where sp.premises_ref=btrim(p_premises_ref);
$function$;

-- Add the two new commands at the existing text-command entry point.
alter function game.execute_text_command(text,text,uuid,uuid)
 rename to execute_text_command_before_bp04_exact_premises;
create or replace function game.execute_text_command(
 p_command_text text,p_idempotency_key text,p_session_id uuid default null,
 p_actor_personnel_id uuid default null
) returns jsonb
language plpgsql
set search_path to 'pg_catalog','game'
as $function$
declare
 m text[]; v_type text; v_payload jsonb; v_cmd game.game_commands%rowtype;
 v_actor game.police_personnel%rowtype; v_result jsonb;
begin
 m:=regexp_match(btrim(coalesce(p_command_text,'')),
  '^scene premises set ([^[:space:]]+) ([^[:space:]]+) (unknown|[^[:space:]]+) (unknown|[^[:space:]]+) because "([^"]{3,2000})" by ([^[:space:]]+)$','i');
 if m is not null then
  v_type:='scene_premises_set';
  v_payload:=jsonb_build_object('scene_ref',m[1],'property_ref',m[2],
   'building_ref',m[3],'unit_ref',m[4],'reason',m[5],'actor_ref',m[6]);
 else
  m:=regexp_match(btrim(coalesce(p_command_text,'')),
   '^scene premises get ([^[:space:]]+) by ([^[:space:]]+)$','i');
  if m is not null then
   v_type:='scene_premises_get';
   v_payload:=jsonb_build_object('scene_ref',m[1],'actor_ref',m[2]);
  else
   m:=regexp_match(btrim(coalesce(p_command_text,'')),
    '^search premises set ([^[:space:]]+) (unknown|[^[:space:]]+) (unknown|[^[:space:]]+) because "([^"]{3,2000})" by ([^[:space:]]+)$','i');
   if m is not null then
    v_type:='search_premises_location_set';
    v_payload:=jsonb_build_object('premises_ref',m[1],'building_ref',m[2],
     'unit_ref',m[3],'reason',m[4],'actor_ref',m[5]);
   else
    m:=regexp_match(btrim(coalesce(p_command_text,'')),
     '^search premises get ([^[:space:]]+) by ([^[:space:]]+)$','i');
    if m is not null then
     v_type:='search_premises_location_get';
     v_payload:=jsonb_build_object('premises_ref',m[1],'actor_ref',m[2]);
    end if;
   end if;
  end if;
 end if;

 if v_type is null then
  v_result:=game.execute_text_command_before_bp04_exact_premises(
   p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  if p_command_text ilike 'help' and coalesce((v_result->>'ok')::boolean,false) then
   return jsonb_set(v_result,'{available_commands}',
    coalesce(v_result->'available_commands','[]'::jsonb)||
    jsonb_build_array('scene_premises_set','scene_premises_get',
      'search_premises_location_set','search_premises_location_get'),true);
  end if;
  return v_result;
 end if;

 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then
  raise exception 'Command text must contain between 1 and 4000 characters';
 end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then
  raise exception 'A unique idempotency key between 8 and 200 characters is required';
 end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,
  command_text,command_type,payload)
 values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload)
 on conflict(idempotency_key) do nothing;
 if not found then
  select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if v_cmd.command_text<>p_command_text or v_cmd.command_type<>v_type or v_cmd.payload<>v_payload then
   return jsonb_build_object('ok',false,'code','idempotency_conflict');
  end if;
  return coalesce(v_cmd.result,jsonb_build_object('ok',v_cmd.status='completed'))||
    jsonb_build_object('duplicate',true);
 end if;
 select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 select * into v_actor from game.police_personnel
  where personnel_ref=btrim(v_payload->>'actor_ref')
    and employment_status in ('active','seconded');
 if v_actor.id is null or (p_actor_personnel_id is not null and p_actor_personnel_id<>v_actor.id) then
  v_result:=jsonb_build_object('ok',false,'code','actor_mismatch');
 else
  case v_type
   when 'scene_premises_set' then
    v_result:=game.record_scene_premises(v_payload->>'scene_ref',v_payload->>'property_ref',
     v_payload->>'building_ref',v_payload->>'unit_ref',v_payload->>'reason',
     v_payload->>'actor_ref',v_cmd.id);
   when 'scene_premises_get' then
    v_result:=coalesce(game.get_scene_premises_record(v_payload->>'scene_ref'),
     jsonb_build_object('ok',false,'code','scene_not_found'));
   when 'search_premises_location_set' then
    v_result:=game.record_search_premises_location(v_payload->>'premises_ref',
     v_payload->>'building_ref',v_payload->>'unit_ref',v_payload->>'reason',
     v_payload->>'actor_ref',v_cmd.id);
   else
    v_result:=coalesce(game.get_search_premises_location(v_payload->>'premises_ref'),
     jsonb_build_object('ok',false,'code','search_premises_not_found'));
  end case;
 end if;
 if coalesce((v_result->>'ok')::boolean,false) then
  v_result:=v_result||jsonb_build_object('status','completed','command_id',v_cmd.id);
  update game.game_commands set status='completed',result=v_result,completed_at=now()
   where id=v_cmd.id;
 else
  update game.game_commands set status='rejected',result=v_result,
   rejection_reason=coalesce(v_result->>'message',v_result->>'code','Premises location command rejected'),
   completed_at=now() where id=v_cmd.id;
  v_result:=v_result||jsonb_build_object('command_id',v_cmd.id);
 end if;
 return v_result;
end;
$function$;

revoke all on function game.record_scene_premises(text,text,text,text,text,text,uuid),
 game.get_scene_premises_record(text),
 game.record_search_premises_location(text,text,text,text,text,uuid),
 game.get_search_premises_location(text),
 game.execute_text_command(text,text,uuid,uuid),
 game.validate_incident_premises_identity(),
 game.validate_scene_premises_identity(),
 game.validate_evidence_premises_identity(),
 game.capture_evidence_recovery_premises(),
 game.validate_case_lead_premises_identity(),
 game.validate_search_premises_identity(),
 game.validate_incident_site_exact_premises(),
 game.prevent_scene_premises_history_mutation(),
 game.prevent_search_premises_location_history_mutation(),
 game.prevent_evidence_premises_history_mutation()
from public,anon,authenticated;
grant execute on function game.record_scene_premises(text,text,text,text,text,text,uuid),
 game.get_scene_premises_record(text),
 game.record_search_premises_location(text,text,text,text,text,uuid),
 game.get_search_premises_location(text),
 game.execute_text_command(text,text,uuid,uuid)
to service_role;

-- ---------------------------------------------------------------------------
-- 5. Premises context in property, scene and case dossiers
-- ---------------------------------------------------------------------------
alter function game.get_property_record(text) rename to get_property_record_before_bp04_assets;
create or replace function game.get_property_record(p_property_ref text)
returns jsonb
language plpgsql stable
set search_path to 'pg_catalog','game'
as $function$
declare v_base jsonb; v_property_id uuid; v_assets jsonb; v_events jsonb; v_development jsonb;
begin
  v_base:=game.get_property_record_before_bp04_assets(p_property_ref);
  if v_base is null then return null; end if;
  select id into v_property_id from game.properties where property_ref=btrim(p_property_ref);
  select coalesce(jsonb_agg(jsonb_build_object(
    'asset',to_jsonb(a),'building_ref',b.building_ref,'unit_ref',u.unit_ref,
    'maintenance_history',coalesce((
      select jsonb_agg(to_jsonb(m) order by m.occurred_at desc nulls last,m.created_at desc)
      from game.physical_asset_maintenance_events m where m.asset_id=a.id
    ),'[]'::jsonb)
  ) order by b.building_ref,a.asset_category,a.asset_ref),'[]'::jsonb)
  into v_assets
  from game.property_physical_assets a
  left join game.buildings b on b.id=a.building_id
  left join game.building_units u on u.id=a.building_unit_id
  where a.property_id=v_property_id;
  select coalesce(jsonb_agg(jsonb_build_object(
    'event',to_jsonb(e),'building_ref',b.building_ref,'unit_ref',u.unit_ref
  ) order by e.occurred_on desc nulls last,e.created_at desc),'[]'::jsonb)
  into v_events
  from game.property_asset_events e
  left join game.buildings b on b.id=e.building_id
  left join game.building_units u on u.id=e.building_unit_id
  where e.property_id=v_property_id;
  v_development:=game.get_property_development_history(p_property_ref);
  return v_base || jsonb_build_object(
    'physical_asset_inventory',v_assets,
    'property_asset_event_history',v_events,
    'planning_and_development_history',coalesce(v_development->'development_events','[]'::jsonb),
    'bp04_asset_coverage',jsonb_build_object(
      'asset_inventory_included',true,'maintenance_history_included',true,
      'property_event_history_included',true,'planning_history_included',true,
      'unknown_dates_preserved',true,'generated_records_identified',true)
  );
end;
$function$;

alter function game.get_scene_response_record(text) rename to get_scene_response_record_before_exact_premises;
create or replace function game.get_scene_response_record(p_scene_ref text)
returns jsonb
language sql stable
set search_path to 'pg_catalog','game'
as $function$
 select base.record || jsonb_build_object(
  'exact_premises',game.get_scene_premises_record(p_scene_ref),
  'evidence_premises',coalesce((
   select jsonb_agg(jsonb_build_object(
    'evidence_ref',e.evidence_ref,'property_ref',p.property_ref,
    'building_ref',b.building_ref,'unit_ref',u.unit_ref,
    'recovery_history',coalesce((
      select jsonb_agg(to_jsonb(h) order by h.recorded_at,h.created_at)
      from game.evidence_premises_history h where h.evidence_id=e.id
    ),'[]'::jsonb)
   ) order by e.evidence_ref)
   from game.evidence_items e
   left join game.properties p on p.id=e.property_id
   left join game.buildings b on b.id=e.building_id
   left join game.building_units u on u.id=e.building_unit_id
   where e.incident_id=(select s.incident_id from game.incident_scenes s where s.scene_ref=p_scene_ref)
  ),'[]'::jsonb)
 )
 from (select game.get_scene_response_record_before_exact_premises(p_scene_ref) as record) base
 where base.record is not null;
$function$;

create or replace function game.get_case_evidence_premises_context(p_case_ref text)
returns jsonb
language sql stable
set search_path to 'pg_catalog','game'
as $function$
 select jsonb_build_object(
  'case_ref',c.case_ref,
  'evidence',coalesce((
   select jsonb_agg(jsonb_build_object(
    'evidence_ref',e.evidence_ref,'evidence_type',e.evidence_type,
    'collection_location',e.collection_location,
    'property_ref',p.property_ref,'building_ref',b.building_ref,'unit_ref',u.unit_ref,
    'premises_history',coalesce((
      select jsonb_agg(jsonb_build_object(
       'scene_id',h.scene_id,'property_ref',hp.property_ref,'building_ref',hb.building_ref,
       'unit_ref',hu.unit_ref,'recorded_at',h.recorded_at,'source_reference',h.source_reference
      ) order by h.recorded_at,h.created_at)
      from game.evidence_premises_history h
      join game.properties hp on hp.id=h.property_id
      left join game.buildings hb on hb.id=h.building_id
      left join game.building_units hu on hu.id=h.building_unit_id
      where h.evidence_id=e.id
    ),'[]'::jsonb)
   ) order by e.evidence_ref)
   from game.evidence_items e
   left join game.properties p on p.id=e.property_id
   left join game.buildings b on b.id=e.building_id
   left join game.building_units u on u.id=e.building_unit_id
   where e.case_id=c.id or exists(
    select 1 from game.case_incidents ci
    where ci.case_id=c.id and ci.incident_id=e.incident_id
   )
  ),'[]'::jsonb),
  'exact_property_building_unit_links',true
 )
 from game.cases c where c.case_ref=btrim(p_case_ref);
$function$;

alter function game.get_case_review_dossier(text) rename to get_case_review_dossier_before_bp04_evidence_premises;
create or replace function game.get_case_review_dossier(p_case_ref text)
returns jsonb
language plpgsql stable
set search_path to 'pg_catalog','game'
as $function$
declare v_result jsonb;
begin
 v_result:=game.get_case_review_dossier_before_bp04_evidence_premises(p_case_ref);
 if coalesce((v_result->>'ok')::boolean,false) is not true then return v_result; end if;
 return v_result || jsonb_build_object(
  'evidence_premises_context',game.get_case_evidence_premises_context(p_case_ref)
 );
end;
$function$;

revoke all on function game.get_property_record(text),
 game.get_scene_response_record(text),
 game.get_case_evidence_premises_context(text),
 game.get_case_review_dossier(text)
from public,anon,authenticated;
grant execute on function game.get_property_record(text),
 game.get_scene_response_record(text),
 game.get_case_evidence_premises_context(text),
 game.get_case_review_dossier(text)
to service_role;

-- ---------------------------------------------------------------------------
-- 6. Integrity indexes and final seed snapshot
-- ---------------------------------------------------------------------------
create index if not exists incidents_location_building_idx
 on game.incidents(location_building_id) where location_building_id is not null;
create index if not exists incident_scenes_premises_idx
 on game.incident_scenes(property_id,building_id,building_unit_id);
create index if not exists evidence_items_premises_idx
 on game.evidence_items(property_id,building_id,building_unit_id);
create index if not exists case_lead_entity_links_premises_idx
 on game.case_lead_entity_links(premises_property_id,premises_building_id,premises_building_unit_id);
create index if not exists search_premises_exact_location_idx
 on game.search_premises(property_id,building_id,building_unit_id);

