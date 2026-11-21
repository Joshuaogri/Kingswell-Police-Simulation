-- BP-04: complete individual business operational profiles and populate organisation structures
-- from the canonical employment/site records. All generated details are fictional Kingswell data.
-- The seed function is idempotent and may be run after the population/workforce seed.

alter table game.business_profiles
  add column if not exists operational_profile jsonb not null default '{}'::jsonb;

do $constraint$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid='game.business_profiles'::regclass
      and conname='business_profiles_operational_profile_object'
  ) then
    alter table game.business_profiles
      add constraint business_profiles_operational_profile_object
      check (jsonb_typeof(operational_profile)='object');
  end if;
end
$constraint$;

update game.business_profiles bp
set operational_profile=jsonb_build_object(
  'profile_basis','generated_fictional_business_operational_dossier',
  'operating_model',coalesce(bp.trade_profile->>'operating_model',bp.trade_profile->>'business_role','mixed_business'),
  'customer_access_model',coalesce(bp.trade_profile->>'customer_access_model','staff_and_booked_visitors'),
  'delivery_and_visitor_pattern',coalesce(bp.trade_profile->>'delivery_and_visitors','scheduled_supplier_and_customer_visits'),
  'stock_and_asset_handling',coalesce(bp.trade_profile->>'stock_and_asset_handling','business_equipment_and_records'),
  'cash_and_payment_controls',jsonb_build_object(
    'cash_exposure',bp.cash_handling_profile,
    'payment_profile',case
      when bp.cash_handling_profile='high' then 'cash_and_electronic_payments'
      when bp.cash_handling_profile='low' then 'predominantly_electronic_or_account_payments'
      else 'mixed_cash_and_electronic_payments' end,
    'cash_reconciliation','daily_or_shift_close_reconciliation'
  ),
  'visitor_management',jsonb_build_object(
    'access_model',coalesce(bp.trade_profile->>'customer_access_model','staff_and_booked_visitors'),
    'visitor_register',case when bp.trade_profile->>'customer_access_model' in ('staff_only','staff_and_booked_visitors') then 'managed_or_appointment_based' else 'transaction_or_reception_based' end,
    'restricted_areas','staff_only_or_authorised_personnel'
  ),
  'operational_schedule',jsonb_build_object(
    'business_hours',bp.business_hours,
    'schedule_status','fictional_seed_schedule_not_live_attendance',
    'workforce_rhythm',case
      when bp.business_hours::text ilike '%overnight%' or bp.business_hours::text ilike '%24_hour%' then 'shift_or_continuous'
      when bp.business_hours::text ilike '%closed%' then 'scheduled_daytime_or_weekly'
      else 'variable_by_business_site' end
  ),
  'sector_operations',case
    when bp.sector in ('logistics_transport','transport') then jsonb_build_object(
      'workflow','fleet_dispatch_loading_receiving_and_consignment_handling',
      'operational_controls','vehicle_movements_driver_handover_and_goods_reconciliation',
      'key_assets','fleet_vehicles_loading_equipment_tracking_and_storage')
    when bp.sector in ('retail_wholesale','wholesale_trade','retail_trade') then jsonb_build_object(
      'workflow','customer_trading_stock_receipt_storage_sales_and_returns',
      'operational_controls','till_reconciliation_stock_counts_and_delivery_checks',
      'key_assets','point_of_sale_stock_shelving_storage_and_delivery_equipment')
    when bp.sector in ('hospitality_food','hospitality_entertainment') then jsonb_build_object(
      'workflow','customer_service_food_or_guest_operations_and_supplier_deliveries',
      'operational_controls','cash_close_food_or_guest_safety_and_staff_handover',
      'key_assets','service_equipment_cold_storage_kitchen_or_guest_facilities')
    when bp.sector in ('construction_property','construction','property') then jsonb_build_object(
      'workflow','project_management_site_visits_contractor_coordination_and_materials',
      'operational_controls','contractor_access_plant_movement_and_materials_reconciliation',
      'key_assets','tools_plant_vehicles_project_records_and_building_equipment')
    when bp.sector in ('manufacturing','production') then jsonb_build_object(
      'workflow','materials_receipt_production_quality_checks_and_dispatch',
      'operational_controls','production_shift_handover_machine_safety_and_stock_reconciliation',
      'key_assets','production_machinery_tools_raw_materials_and_finished_goods')
    when bp.sector in ('healthcare','education','public_services') then jsonb_build_object(
      'workflow','scheduled_service_delivery_records_and_managed_public_access',
      'operational_controls','reception_access_records_staff_handover_and_service_continuity',
      'key_assets','specialist_equipment_records_and_service_facilities')
    else jsonb_build_object(
      'workflow','customer_or_client_service_supplier_contact_and_business_administration',
      'operational_controls','staff_handover_access_management_and_daily_reconciliation',
      'key_assets','business_equipment_records_and_operating_supplies')
  end,
  'emergency_and_security_interface',jsonb_build_object(
    'security_profile_reference',bp.security_arrangements,
    'site_specific_emergency_contacts','not_yet_recorded',
    'police_relevant_context','operational_profile_only_not_an_intelligence_assessment'
  ),
  'trade_profile_reference',bp.trade_profile,
  'source_reference',bp.business_number,
  'generated_for','Kingswell fictional simulation'
)
where bp.operational_profile='{}'::jsonb;

create or replace function game.seed_bp04_organisation_structures()
returns jsonb
language plpgsql
set search_path to 'pg_catalog','game'
as $function$
declare
  v_departments integer:=0;
  v_positions integer:=0;
  v_assignments integer:=0;
  v_employment integer:=0;
begin
  select count(*) into v_employment from game.organisation_personnel;

  if v_employment=0 then
    return jsonb_build_object('ok',false,'code','workforce_seed_not_loaded',
      'message','Canonical organisation employment records must be loaded before structure generation.');
  end if;

  with role_rows as (
    select op.organisation_id,op.valid_from,op.job_title,
      case op.job_title
        when 'Financial Services Associate' then 'finance_administration'
        when 'Trade Operations Associate' then 'commercial_customer'
        when 'Wholesale Trade Associate' then 'commercial_customer'
        when 'Retail Associate' then 'commercial_customer'
        when 'Logistics and Warehouse Operative' then 'logistics_distribution'
        when 'Transport Operations Associate' then 'logistics_distribution'
        when 'Neighbourhood Services Associate' then 'community_services'
        when 'Hospitality and Entertainment Associate' then 'community_services'
        when 'Production Operative' then 'production_facilities'
        when 'Professional Services Associate' then 'professional_services'
        when 'Technology and Media Associate' then 'digital_technology'
        when 'Construction and Property Associate' then 'property_facilities'
        when 'Property Management Associate' then 'property_facilities'
        else 'general_operations'
      end as family
    from game.organisation_personnel op
  ), grouped as (
    select organisation_id,family,min(valid_from) as first_employment_date
    from role_rows group by organisation_id,family
  )
  insert into game.organisation_departments(
    department_ref,organisation_id,department_name,department_type,remit,
    department_status,base_organisation_location_id,valid_from,provenance
  )
  select
    'KWDEP-'||substr(md5(o.organisation_ref||':'||g.family),1,20),
    g.organisation_id,
    case g.family
      when 'finance_administration' then 'Finance and Administration'
      when 'commercial_customer' then 'Commercial and Customer Operations'
      when 'logistics_distribution' then 'Logistics and Distribution'
      when 'community_services' then 'Community and Customer Services'
      when 'production_facilities' then 'Production and Facilities'
      when 'professional_services' then 'Professional Services'
      when 'digital_technology' then 'Digital and Technology'
      when 'property_facilities' then 'Property and Facilities'
      else 'General Operations'
    end,
    g.family,
    case g.family
      when 'finance_administration' then 'Financial services, accounts, payment administration and business records'
      when 'commercial_customer' then 'Trade operations, wholesale and retail customer-facing activity'
      when 'logistics_distribution' then 'Warehousing, transport, dispatch, receiving and distribution'
      when 'community_services' then 'Neighbourhood, hospitality, entertainment and public-facing services'
      when 'production_facilities' then 'Production, manufacturing and facilities operations'
      when 'professional_services' then 'Professional and advisory service delivery'
      when 'digital_technology' then 'Technology, media and information operations'
      when 'property_facilities' then 'Construction, property, maintenance and site operations'
      else 'General business operations and support'
    end,
    'active',
    (select sd.organisation_location_id
     from game.organisation_site_dossiers sd
     join game.organisation_locations ol on ol.id=sd.organisation_location_id
     where sd.organisation_id=g.organisation_id
     order by ol.is_primary_location desc,sd.site_ref
     limit 1),
    g.first_employment_date,
    jsonb_build_object(
      'generated_fictional_structure',true,
      'basis','canonical organisation_personnel job titles grouped into operational families',
      'organisation_ref',o.organisation_ref,
      'site_assignment_is_separate',true,
      'manager_assignment','not_assumed'
    )
  from grouped g
  join game.organisations o on o.id=g.organisation_id
  on conflict(department_ref) do nothing;

  get diagnostics v_departments = row_count;

  -- Each department has an explicit vacant lead position; no employee is
  -- silently promoted or assigned supervisory authority.
  insert into game.organisation_department_positions(
    position_ref,department_id,position_title,position_description,
    position_status,authority_profile,provenance
  )
  select
    'KWPOS-MGR-'||substr(md5(d.department_ref),1,18),
    d.id,'Department Lead',
    'Vacant supervisory position in the generated fictional organisation structure.',
    'vacant',
    jsonb_build_object('supervisory_authority','not_assigned','requires_explicit_employment_assignment',true),
    jsonb_build_object('generated_fictional_structure',true,'basis','department framework')
  from game.organisation_departments d
  where d.provenance->>'generated_fictional_structure'='true'
  on conflict(position_ref) do nothing;

  with role_rows as (
    select distinct op.organisation_id,op.job_title,
      case op.job_title
        when 'Financial Services Associate' then 'finance_administration'
        when 'Trade Operations Associate' then 'commercial_customer'
        when 'Wholesale Trade Associate' then 'commercial_customer'
        when 'Retail Associate' then 'commercial_customer'
        when 'Logistics and Warehouse Operative' then 'logistics_distribution'
        when 'Transport Operations Associate' then 'logistics_distribution'
        when 'Neighbourhood Services Associate' then 'community_services'
        when 'Hospitality and Entertainment Associate' then 'community_services'
        when 'Production Operative' then 'production_facilities'
        when 'Professional Services Associate' then 'professional_services'
        when 'Technology and Media Associate' then 'digital_technology'
        when 'Construction and Property Associate' then 'property_facilities'
        when 'Property Management Associate' then 'property_facilities'
        else 'general_operations'
      end as family
    from game.organisation_personnel op
  )
  insert into game.organisation_department_positions(
    position_ref,department_id,position_title,reports_to_position_id,
    position_description,position_status,authority_profile,provenance
  )
  select
    'KWPOS-'||substr(md5(o.organisation_ref||':'||r.family||':'||r.job_title),1,22),
    d.id,r.job_title,lead.id,
    'Position mapped from the existing canonical employment job title.',
    'active',
    jsonb_build_object('authority_basis','job_title_only','supervisory_authority','not_assumed'),
    jsonb_build_object('generated_fictional_structure',true,'source','organisation_personnel.job_title')
  from role_rows r
  join game.organisations o on o.id=r.organisation_id
  join game.organisation_departments d on d.organisation_id=r.organisation_id
    and d.department_type=r.family
  join game.organisation_department_positions lead
    on lead.department_id=d.id and lead.position_title='Department Lead'
  on conflict(position_ref) do nothing;

  get diagnostics v_positions = row_count;

  with role_rows as (
    select op.*,
      case op.job_title
        when 'Financial Services Associate' then 'finance_administration'
        when 'Trade Operations Associate' then 'commercial_customer'
        when 'Wholesale Trade Associate' then 'commercial_customer'
        when 'Retail Associate' then 'commercial_customer'
        when 'Logistics and Warehouse Operative' then 'logistics_distribution'
        when 'Transport Operations Associate' then 'logistics_distribution'
        when 'Neighbourhood Services Associate' then 'community_services'
        when 'Hospitality and Entertainment Associate' then 'community_services'
        when 'Production Operative' then 'production_facilities'
        when 'Professional Services Associate' then 'professional_services'
        when 'Technology and Media Associate' then 'digital_technology'
        when 'Construction and Property Associate' then 'property_facilities'
        when 'Property Management Associate' then 'property_facilities'
        else 'general_operations'
      end as family
    from game.organisation_personnel op
  )
  insert into game.organisation_department_assignments(
    assignment_ref,organisation_personnel_id,department_id,position_id,
    site_dossier_id,valid_from,valid_to,assignment_status,assignment_basis,provenance
  )
  select
    'KWASN-'||substr(md5(r.id::text),1,22),
    r.id,d.id,pos.id,
    (select sd.organisation_location_id
     from game.organisation_site_dossiers sd
     join game.organisation_locations ol on ol.id=sd.organisation_location_id
     where sd.organisation_id=r.organisation_id
     order by ol.is_primary_location desc,sd.site_ref
     limit 1),
    r.valid_from,r.valid_to,
    case when r.is_current then 'current' else 'ended' end,
    'Generated from the existing canonical organisation-personnel employment and job-title record.',
    jsonb_build_object(
      'generated_fictional_structure',true,
      'employment_record_id',r.id,
      'job_title',r.job_title,
      'site_assignment_basis','primary recorded organisation site where available',
      'supervisor','not_assumed'
    )
  from role_rows r
  join game.organisation_departments d
    on d.organisation_id=r.organisation_id and d.department_type=r.family
  join game.organisation_department_positions pos
    on pos.department_id=d.id and pos.position_title=r.job_title
  on conflict(assignment_ref) do nothing;

  get diagnostics v_assignments = row_count;

  return jsonb_build_object(
    'ok',true,
    'departments_inserted',v_departments,
    'positions_inserted',v_positions,
    'assignments_inserted',v_assignments,
    'employment_records',v_employment,
    'idempotent',true,
    'supervisory_authority_invented',false
  );
end;
$function$;

revoke all on function game.seed_bp04_organisation_structures() from public,anon,authenticated;
grant execute on function game.seed_bp04_organisation_structures() to service_role;

-- On a populated live world, complete the structure immediately. Isolated CI
-- invokes the same function after its deterministic population fixture is loaded.
do $seed$
begin
  if exists(select 1 from game.organisation_personnel)
     and exists(select 1 from game.persons) then
    perform game.seed_bp04_organisation_structures();
  end if;
end
$seed$;
