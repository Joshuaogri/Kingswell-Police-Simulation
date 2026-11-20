-- BP-04 detailed refinement regression checks.
-- Run against the Kingswell game schema after BP-04 migrations.
do $$
declare
 v_city_version text;
 v_neighbourhood_code text;
 v_property_ref text;
 v_business_number text;
 v_json jsonb;
 v_property_id uuid;
begin
 if exists(
  select 1 from game.properties p
  left join game.property_profiles pp on pp.property_id=p.id
  where pp.property_id is null
 ) then raise exception 'BP04: property profile missing'; end if;

 if exists(
  select 1 from game.buildings b
  left join game.building_profiles bp on bp.building_id=b.id
  where bp.building_id is null
 ) then raise exception 'BP04: building profile missing'; end if;

 if exists(
  select 1 from game.building_units u
  left join game.building_unit_profiles up on up.building_unit_id=u.id
  where up.building_unit_id is null
 ) then raise exception 'BP04: unit profile missing'; end if;

 if exists(
  select 1 from game.business_profiles bp
  left join game.organisation_site_agreements a on a.tenant_organisation_id=bp.organisation_id
  where exists(select 1 from game.organisation_locations l where l.organisation_id=bp.organisation_id and l.location_role='tenant' and l.valid_to is null)
    and a.id is null
 ) then raise exception 'BP04: tenant business has no agreement record'; end if;

 if exists(
  select 1 from game.organisation_locations l
  join game.organisation_site_agreement_locations al on al.organisation_location_id=l.id
  join game.organisation_site_agreements a on a.id=al.agreement_id
  where l.location_role='tenant'
   and (a.tenant_organisation_id<>l.organisation_id or a.agreement_ref<>l.lease_reference)
 ) then raise exception 'BP04: tenant agreement link mismatch'; end if;

 if exists(
  select 1 from game.properties p
  join game.property_profiles pp on pp.property_id=p.id
  join game.cities c on c.id=p.city_id
  where pp.parcel_outline->>'coordinate_system' is distinct from c.map_version
 ) then raise exception 'BP04: parcel map version is stale'; end if;

 if exists(
  select 1 from game.buildings b
  join game.building_profiles bp on bp.building_id=b.id
  join game.properties p on p.id=b.property_id
  join game.cities c on c.id=p.city_id
  where bp.footprint_outline->>'coordinate_system' is distinct from c.map_version
 ) then raise exception 'BP04: building footprint map version is stale'; end if;

 if exists(
  select 1 from game.buildings b
  join game.building_profiles bp on bp.building_id=b.id
  where b.floors<>jsonb_array_length(bp.floor_directory)
 ) then raise exception 'BP04: floor directory length does not match building floor count'; end if;

 if exists(
  select 1 from game.building_unit_profiles up
  join game.building_units u on u.id=up.building_unit_id
  where up.use_class='dwelling' and (up.bedroom_count is null or up.bathroom_count is null)
 ) then raise exception 'BP04: dwelling missing bedroom or bathroom count'; end if;

 select c.map_version,n.code into v_city_version,v_neighbourhood_code
 from game.cities c join game.districts d on d.city_id=c.id
 join game.neighbourhoods n on n.district_id=d.id order by n.code limit 1;
 v_json:=game.get_neighbourhood_property_map(v_neighbourhood_code);
 if v_json->>'map_version' is distinct from v_city_version
  or v_json->>'coordinate_system' is distinct from v_city_version
 then raise exception 'BP04: neighbourhood map output does not match current city map version'; end if;

 select property_ref into v_property_ref from game.properties order by property_ref limit 1;
 v_json:=game.get_property_record(v_property_ref);
 if not (v_json ? 'valuation_history' and v_json ? 'asset_events' and v_json ? 'site_agreements')
 then raise exception 'BP04: property dossier missing refined sections'; end if;

 select business_number into v_business_number from game.business_profiles order by business_number limit 1;
 v_json:=game.get_business_record(v_business_number);
 if not (v_json ? 'control_interests' and v_json ? 'site_agreements')
 then raise exception 'BP04: business dossier missing refined sections'; end if;


 -- All canonical businesses must have individualised operational detail and
 -- explicit provenance; do not treat these profile fields as actual events.
 if exists(
  select 1 from game.business_profiles bp
  where not (
   bp.trade_profile ? 'operating_model'
   and bp.trade_profile ? 'customer_access_model'
   and bp.trade_profile ? 'stock_and_asset_handling'
   and bp.trade_profile ? 'delivery_and_visitors'
   and bp.trade_profile ? 'detail_basis'
   and bp.security_arrangements ? 'premises_access_control'
   and bp.security_arrangements ? 'cctv_coverage_profile'
   and bp.security_arrangements ? 'out_of_hours_control'
   and bp.business_hours ? 'weekday_pattern'
   and bp.business_hours ? 'schedule_variant'
  )
 ) then raise exception 'BP04: one or more business profiles lack operational enrichment'; end if;

 if (select count(*) from game.business_profiles)<>1452 then
  raise exception 'BP04: canonical business profile population changed unexpectedly';
 end if;

 if exists(
  select 1 from game.business_profiles bp
  where bp.security_arrangements->>'security_provider_status'<>'provider_identity_not_yet_recorded'
 ) then raise exception 'BP04: seeded security profile incorrectly asserts provider identity'; end if;


 -- Each current business site must reflect its linked business schedule and
 -- operational access profile, while preserving the canonical site record.
 if exists(
  select 1 from game.organisation_locations l
  join game.business_profiles bp on bp.organisation_id=l.organisation_id
  where l.valid_to is null
    and l.location_role in ('tenant','owner_occupier','headquarters','branch','operating_site')
    and (
      l.operating_hours is distinct from bp.business_hours
      or not (l.site_details ? 'operating_model'
        and l.site_details ? 'customer_access_model'
        and l.site_details ? 'delivery_and_visitors'
        and l.site_details ? 'premises_access_control'
        and l.site_details ? 'site_profile_basis')
    )
 ) then raise exception 'BP04: current business site dossier is not aligned with business profile'; end if;

 -- Property dossiers must be individually described without fabricating dated planning history.
 if (select count(distinct site_description) from game.property_profiles)<>656
 then raise exception 'BP04: property site descriptions are not individually differentiated'; end if;
 if (select count(distinct planning_notes) from game.property_profiles)<>656
 then raise exception 'BP04: property planning summaries are not individually differentiated'; end if;
 if exists(
  select 1 from game.property_profiles
  where planning_notes not ilike '%not a planning application%'
     or planning_notes not ilike '%remain unrecorded%'
 ) then raise exception 'BP04: planning summary does not clearly distinguish missing planning history'; end if;

 -- Building system design profiles are unique to canonical buildings and
 -- explicitly distinguish seeded summaries from inspection/device inventories.
 if exists(
  select 1 from game.building_profiles bp
  join game.buildings b on b.id=bp.building_id
  where bp.building_systems #>> '{system_design_profile,profile_reference}' is distinct from b.building_ref
     or bp.building_systems #>> '{system_design_profile,inspection_status}'<>'not_recorded'
     or bp.building_systems #>> '{system_design_profile,asset_level_inventory}'<>'not_seeded'
     or bp.building_systems #>> '{profile_provenance,source}' is null
 ) then raise exception 'BP04: building system profile identity or provenance invalid'; end if;
 if (select count(distinct building_systems #>> '{system_design_profile,profile_reference}') from game.building_profiles)<>656
 then raise exception 'BP04: building system profile references are not unique'; end if;

 -- Confirm the event-location trigger rejects a building from another property.
 select id into v_property_id from game.properties order by property_ref limit 1;
 begin
  insert into game.property_asset_events(property_id,building_id,event_type,subject,description)
  select v_property_id,b.id,'inspection','BP04 regression validation','Must be rejected'
  from game.buildings b where b.property_id<>v_property_id order by b.building_ref limit 1;
  raise exception 'BP04: invalid cross-property event unexpectedly inserted';
 exception when others then
  if sqlerrm='BP04: invalid cross-property event unexpectedly inserted' then raise; end if;
 end;
end $$;
