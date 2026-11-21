-- BP-04 full-world population and exact premises identity regression.
begin;
do $test$
declare
 r jsonb;
 v_businesses bigint;
 v_units bigint;
 v_employment bigint;
 v_assets bigint;
 v_infrastructure bigint;
 v_agreements bigint;
 v_properties bigint;
 v_buildings bigint;
 v_actor uuid;
 v_actor_ref text;
 v_incident_type uuid;
 v_property uuid;
 v_building uuid;
 v_unit uuid;
 v_incident uuid;
 v_scene uuid;
 v_evidence uuid;
 v_case_ref text;
begin
 r:=game.seed_bp04_complete_world();
 if coalesce((r->>'ok')::boolean,false) is not true then
  raise exception 'BP-04 world population failed: %',r;
 end if;

 select count(*) into v_businesses from game.business_profiles;
 if (select count(*) from game.business_profiles
     where operational_profile ? 'product_service_lines'
       and operational_profile ? 'stock_and_inventory_operations'
       and operational_profile ? 'supplier_and_delivery_operations'
       and operational_profile ? 'commercial_and_payment_operations'
       and operational_profile ? 'staffing_and_workforce_operations')<>v_businesses then
  raise exception 'Business operational profiles are incomplete';
 end if;

 if (select count(distinct organisation_id) from game.organisation_control_interests
     where source_reference like 'KNG-GEN-CONTROL-%')<>v_businesses then
  raise exception 'Every business must have generated fictional ownership/control records';
 end if;

 select count(*) into v_properties from game.property_interest_records
 where interest_type='registered_owner' and valid_to is null;
 if (select count(*) from game.property_title_events where event_ref like 'KW-TITLE-INIT-%')<>v_properties then
  raise exception 'Title register snapshots do not reconcile to current registered-owner interests';
 end if;

 select count(*) into v_agreements from game.organisation_site_agreements;
 if (select count(*) from game.organisation_site_agreements
     where counterparty_person_id is null and counterparty_organisation_id is null)<>0 then
  raise exception 'At least one occupancy agreement remains without a counterparty';
 end if;
 if (select count(*) from game.organisation_site_agreements
     where execution_date is null or effective_from is null or rent_amount is null
       or rent_currency is null or rent_frequency is null or deposit_amount is null
       or permitted_use is null or restrictions is null or repair_responsibility is null
       or service_charge_responsibility is null or subletting_allowed is null)<>0 then
  raise exception 'At least one occupancy agreement has incomplete fictional terms';
 end if;
 if exists(
  select 1 from game.organisation_site_agreements a
  where not exists(select 1 from game.organisation_site_agreement_events e
    where e.agreement_id=a.id and e.event_type='executed')
     or not exists(select 1 from game.organisation_site_agreement_events e
    where e.agreement_id=a.id and e.event_type='commenced')
 ) then raise exception 'Every agreement requires executed and commenced lifecycle events'; end if;

 select count(*) into v_units from game.building_units;
 select count(*) into v_infrastructure from game.building_unit_infrastructure_profiles;
 if v_infrastructure<>v_units then
  raise exception 'Unit infrastructure coverage %, expected %',v_infrastructure,v_units;
 end if;

 select count(*) into v_assets from game.property_physical_assets;
 if v_assets=0 then raise exception 'No physical assets were generated'; end if;
 if (select count(*) from game.physical_asset_maintenance_events
     where event_ref like 'KNG-INSP-%') < v_assets then
  raise exception 'Generated assets lack baseline inspection records';
 end if;

 select count(*) into v_buildings from game.buildings;
 if (select count(*) from game.property_asset_events where event_ref like 'KNG-COND-%')<>v_buildings then
  raise exception 'Building condition history does not reconcile to buildings';
 end if;

 select count(*) into v_employment from game.organisation_personnel;
 if (select count(*) from game.organisation_department_assignments)<>v_employment then
  raise exception 'Organisation structure assignments do not reconcile to employment records';
 end if;

 if exists(
  select 1 from game.property_physical_assets a
  left join game.properties p on p.id=a.property_id
  left join game.buildings b on b.id=a.building_id
  where p.id is null or b.id is null or b.property_id<>a.property_id
 ) then raise exception 'Physical asset property/building identity is inconsistent'; end if;

 if exists(
  select 1 from game.building_unit_infrastructure_profiles i
  left join game.building_units u on u.id=i.building_unit_id
  where u.id is null
 ) then raise exception 'Infrastructure profile contains an unresolved unit'; end if;

 -- Verify incident -> scene -> evidence exact premises propagation.
 select pp.id,pp.personnel_ref into v_actor,v_actor_ref from game.police_personnel pp
 where pp.employment_status in ('active','seconded') order by pp.personnel_ref limit 1;
 select id into v_incident_type from game.incident_types where is_active order by type_code limit 1;
 select p.id,b.id,u.id into v_property,v_building,v_unit
 from game.properties p join game.buildings b on b.property_id=p.id
 join game.building_units u on u.building_id=b.id
 order by p.property_ref,b.building_ref,u.unit_ref limit 1;

 if v_actor is null or v_property is null or v_building is null or v_unit is null then
  raise exception 'Premises regression fixture lacks actor or canonical property/building/unit';
 end if;

 insert into game.incidents(
  incident_ref,incident_type_id,location_property_id,location_building_unit_id,
  summary,details
 ) values(
  'KNG-TEST-BP04-PREMISES-INCIDENT',v_incident_type,v_property,v_unit,
  'BP-04 exact premises identity regression fixture','{}'::jsonb
 ) returning id into v_incident;

 if (select location_building_id from game.incidents where id=v_incident)<>v_building then
  raise exception 'Incident did not derive its canonical building from the unit';
 end if;

 insert into game.incident_scenes(
  scene_ref,incident_id,designation_reason,control_basis,created_by_personnel_id
 ) values(
  'KNG-TEST-BP04-PREMISES-SCENE',v_incident,
  'Regression fixture for exact premises propagation','incident-location baseline',v_actor
 ) returning id into v_scene;

 if not exists(select 1 from game.incident_scenes
   where id=v_scene and property_id=v_property and building_id=v_building and building_unit_id=v_unit) then
  raise exception 'Scene did not inherit exact incident property/building/unit identity';
 end if;

 insert into game.evidence_items(
  evidence_ref,incident_id,scene_id,evidence_type,description
 ) values(
  'KNG-TEST-BP04-PREMISES-EVIDENCE',v_incident,v_scene,
  'physical','BP-04 exact premises evidence regression fixture'
 ) returning id into v_evidence;

 if not exists(select 1 from game.evidence_items
   where id=v_evidence and property_id=v_property and building_id=v_building
     and building_unit_id=v_unit and scene_id=v_scene) then
  raise exception 'Evidence did not inherit exact scene premises identity';
 end if;

 if not exists(select 1 from pg_trigger where tgname='case_lead_entity_links_premises_identity' and not tgisinternal)
   or not exists(select 1 from pg_trigger where tgname='search_premises_identity' and not tgisinternal)
   or not exists(select 1 from pg_trigger where tgname='incident_site_associations_exact_premises' and not tgisinternal) then
  raise exception 'Case, search and incident-site exact premises validation triggers are missing';
 end if;

 update game.simulation_state set current_game_time='2026-11-21 08:00:00+00'::timestamptz where id=1;
 v_command:=game.execute_text_command(
  'scene premises set KNG-TEST-BP04-PREMISES-SCENE '||
  (select property_ref from game.properties where id=v_property)||' '||
  (select building_ref from game.buildings where id=v_building)||' '||
  (select unit_ref from game.building_units where id=v_unit)||
  ' because "Exact premises command regression" by '||v_actor_ref,
  'bp04-scene-premises-command-test',null,v_actor
 );
 if coalesce((v_command->>'ok')::boolean,false) is not true then
  raise exception 'Player-facing scene premises command failed: %',v_command;
 end if;
 if (select current_game_time from game.simulation_state where id=1)
    <> '2026-11-21 08:00:00+00'::timestamptz then
  raise exception 'Recording premises must not advance the simulation clock';
 end if;
 update game.simulation_state set current_game_time=null where id=1;
 v_command:=game.record_scene_premises(
  'KNG-TEST-BP04-PREMISES-SCENE',
  (select property_ref from game.properties where id=v_property),
  (select building_ref from game.buildings where id=v_building),
  (select unit_ref from game.building_units where id=v_unit),
  'Clock guard regression',v_actor_ref,null
 );
 if v_command->>'code'<>'clock_not_initialized' then
  raise exception 'Scene premises history must require the initialized simulation clock: %',v_command;
 end if;

 if (game.get_scene_response_record('KNG-TEST-BP04-PREMISES-SCENE')->'exact_premises'->'current'->>'unit_ref')
    is null then
  raise exception 'Scene response dossier does not expose exact unit identity';
 end if;

 -- Idempotency: running the complete seed a second time must not duplicate assets,
 -- title snapshots, agreement events, control interests or inspection histories.
 perform game.seed_bp04_complete_world();
 if (select count(*) from game.property_physical_assets)<>v_assets then
  raise exception 'BP-04 complete-world seed is not idempotent for physical assets';
 end if;
 if (select count(*) from game.property_title_events where event_ref like 'KW-TITLE-INIT-%')<>v_properties then
  raise exception 'BP-04 complete-world seed is not idempotent for title snapshots';
 end if;
end;
$test$;
rollback;
