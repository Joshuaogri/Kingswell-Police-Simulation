-- BP-04: enrich each existing business in place with sector-aware operational,
-- customer-access, stock, delivery, security and opening-profile variation.
-- No business/person/provider identities or historical events are created.

update game.business_profiles bp
set
  trade_profile = coalesce(bp.trade_profile,'{}'::jsonb) || jsonb_build_object(
    'operating_model', case bp.sector
      when 'logistics_warehousing' then (array['regional_distribution_hub','contract_warehousing','last_mile_fulfilment','cold_chain_and_general_storage','freight_forwarding_and_storage'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1]
      when 'financial_services' then (array['branch_and_advisory','business_services_office','payments_and_transaction_centre','investment_and_client_services','insurance_and_claims_office'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1]
      when 'import_export' then (array['import_consolidation','export_consolidation','customs_brokerage','commodity_trade_office','mixed_trade_and_storage'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1]
      when 'retail' then (array['street_retail','destination_retail','specialist_showroom','multi_department_store','trade_counter'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1]
      when 'manufacturing' then (array['batch_production','continuous_production','assembly_and_testing','fabrication_workshop','food_or_material_processing'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1]
      when 'wholesale_trade' then (array['bulk_trade_counter','business_to_business_distribution','cash_and_carry','specialist_wholesaler','warehouse_sales'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1]
      when 'transport_services' then (array['fleet_depot','passenger_service_base','freight_terminal','vehicle_hire_and_service','dispatch_and_control_centre'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1]
      when 'hospitality_entertainment' then (array['food_and_beverage_service','ticketed_venue','accommodation_service','late_evening_venue','events_and_functions'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1]
      when 'professional_services' then (array['appointment_led_practice','client_services_office','technical_consultancy','multi_discipline_practice','back_office_service_centre'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1]
      when 'technology_media' then (array['software_and_support','media_production','device_and_network_services','digital_content_operations','technology_sales_and_service'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1]
      when 'construction_property' then (array['project_management_office','building_trade_depot','property_sales_and_letting','maintenance_contracting','materials_and_equipment_yard'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1]
      when 'neighbourhood_services' then bp.subsector
      when 'property_management' then (array['residential_block_management','commercial_estate_management','facilities_and_maintenance','lettings_and_tenancy_services'])[((right(o.organisation_ref,6)::int - 1) % 4) + 1]
      else bp.subsector end,
    'customer_access_model', case
      when bp.sector in ('logistics_warehousing','manufacturing','construction_property') then (array['staff_and_booked_visitors','controlled_trade_counter','scheduled_contractors'])[((right(o.organisation_ref,6)::int - 1) % 3) + 1]
      when bp.sector in ('financial_services','professional_services') then (array['appointment_and_walk_in','appointment_led','public_reception_and_client_rooms'])[((right(o.organisation_ref,6)::int - 1) % 3) + 1]
      else (array['open_public_access','public_access_with_restricted_back_of_house','counter_service'])[((right(o.organisation_ref,6)::int - 1) % 3) + 1]
    end,
    'stock_and_asset_handling', case
      when bp.sector in ('logistics_warehousing','wholesale_trade','import_export') then (array['palletised_goods_and_inventory','mixed_carton_and_bulk_stock','high_value_or_controlled_goods','temperature_sensitive_stock'])[((right(o.organisation_ref,6)::int - 1) % 4) + 1]
      when bp.sector='manufacturing' then (array['raw_materials_work_in_progress_finished_goods','components_and_finished_products','materials_tools_and_equipment'])[((right(o.organisation_ref,6)::int - 1) % 3) + 1]
      when bp.sector='retail' or bp.sector='neighbourhood_services' then (array['display_stock_and_back_room','perishable_and_daily_replenishment','high_value_counter_stock','service_equipment_and_consumables'])[((right(o.organisation_ref,6)::int - 1) % 4) + 1]
      else 'primarily_records_equipment_and_business_assets' end,
    'delivery_and_visitors', case
      when bp.sector in ('logistics_warehousing','wholesale_trade','import_export','manufacturing') then (array['booked_goods_inbound_and_outbound','scheduled_supplier_and_customer_collections','mixed_dock_and_courier_activity','yard_managed_vehicle_movements'])[((right(o.organisation_ref,6)::int - 1) % 4) + 1]
      when bp.sector in ('retail','neighbourhood_services','hospitality_entertainment') then (array['supplier_deliveries_before_peak_hours','courier_and_supplier_access','scheduled_replenishment_and_customer_visits'])[((right(o.organisation_ref,6)::int - 1) % 3) + 1]
      else (array['booked_business_visitors','scheduled_client_and_supplier_visits','low_volume_routine_deliveries'])[((right(o.organisation_ref,6)::int - 1) % 3) + 1]
    end,
    'operational_variation', ((right(o.organisation_ref,6)::int - 1) % 7) + 1,
    'detail_basis','Fictional seeded operating profile; not an event log or evidence of a real-world provider.'
  ),
  security_arrangements = coalesce(bp.security_arrangements,'{}'::jsonb) || jsonb_build_object(
    'premises_access_control', (array['key_and_managed_entry','staff_badge_or_key_control','reception_controlled_entry','alarm_and_keyholder_control','zoned_staff_and_public_access'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1],
    'cctv_coverage_profile', (array['entrances_and_cash_or_service_points','public_frontage_and_rear_access','loading_and_goods_handling_areas','shared_access_and_internal_common_areas','site_specific_partial_coverage'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1],
    'intrusion_detection_profile', (array['perimeter_and_after_hours','principal_entrances_only','selected_restricted_rooms','site_alarm_status_unconfirmed','local_intrusion_alarm'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1],
    'out_of_hours_control', (array['keyholder_callout','manager_or_supervisor_lockup','security_patrol_or_check','automated_alarm_and_remote_notification','staff_closing_checklist'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1],
    'security_provider_status','provider_identity_not_yet_recorded',
    'security_detail_basis','Fictional seeded premises profile; named providers, device serials and recorded incidents are not asserted.'
  ),
  business_hours = coalesce(bp.business_hours,'{}'::jsonb) || jsonb_build_object(
    'schedule_variant', ((right(o.organisation_ref,6)::int - 1) % 5) + 1,
    'weekday_pattern', case
      when bp.sector in ('logistics_warehousing','manufacturing','transport_services') then (array['06:00-18:00','07:00-19:00','08:00-20:00','06:00-22:00','24_hour_shift_operation'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1]
      when bp.sector in ('hospitality_entertainment','neighbourhood_services') then (array['07:00-17:00','08:00-18:00','09:00-19:00','10:00-22:00','12:00-23:00'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1]
      else (array['08:00-17:00','08:00-18:00','09:00-17:30','09:00-18:00','07:30-16:30'])[((right(o.organisation_ref,6)::int - 1) % 5) + 1]
    end,
    'opening_schedule_status','seeded_simulation_schedule_not_runtime_attendance'
  ),
  updated_at = now()
from game.organisations o
where o.id=bp.organisation_id
  and o.organisation_ref like 'KWORG-BIZ-%'
  and (bp.trade_profile->>'detail_basis' is distinct from 'Fictional seeded operating profile; not an event log or evidence of a real-world provider.');
