-- BP-04 property/building/unit asset-event workflow regression.
begin;
do $$
declare parsed jsonb; routed jsonb; malformed jsonb;
 v_person_id uuid; v_actor_ref text; v_property_ref text;
begin
 parsed:=game.interpret_text_command(
  'property event PROP-TEST-0001 EVT-PROP-0001 inspection completed moderate 2026-11-20 unknown BLD-TEST-0001 UNIT-TEST-0001 "Annual premises inspection" "Inspection report records the observed condition." "Minor roof leak noted" "Arrange a documented repair" unknown unknown "INSPECT-REF-01" "Fictional inspection report" by KNG-TEST-0001'
 );
 if parsed->>'command_type'<>'property_asset_event_record'
  or parsed#>>'{payload,event_type}'<>'inspection'
  or parsed#>>'{payload,building_ref}'<>'BLD-TEST-0001'
  or parsed#>>'{payload,unit_ref}'<>'UNIT-TEST-0001'
  or parsed#>>'{payload,occurred_on}'<>'2026-11-20'
  or parsed#>'{payload,completed_on}' is distinct from 'null'::jsonb then
  raise exception 'Property asset event parser returned incorrect data: %',parsed;
 end if;
 parsed:=game.interpret_text_command(
  'property event PROP-TEST-0001 EVT-PROP-0002 defect open high unknown unknown unknown unknown "Unverified defect report" "A reported defect requires assessment." "" "" unknown unknown "" "" by KNG-TEST-0001'
 );
 if parsed->>'command_type'<>'property_asset_event_record'
  or parsed#>'{payload,occurred_on}' is distinct from 'null'::jsonb then
  raise exception 'Unknown property-event date was not preserved: %',parsed;
 end if;
 malformed:=game.interpret_text_command(
  'property event PROP-TEST-0001 EVT-PROP-0003 imaginary recorded low unknown unknown unknown unknown "Bad event" "Invalid type." "" "" unknown unknown "" "" by KNG-TEST-0001'
 );
 if malformed->>'command_type'='property_asset_event_record' then
  raise exception 'Unsupported property event type was accepted.';
 end if;
 routed:=game.execute_text_command(
  'property event PROP-NOT-FOUND EVT-PROP-0004 inspection recorded unknown unknown unknown unknown unknown unknown "Test event" "Actor validation test." "" "" unknown unknown "" "" by KNG-NONEXISTENT',
  'bp04-property-event-actor-01',null,null
 );
 if routed->>'code'<>'actor_mismatch' then
  raise exception 'Property event command bypassed actor validation: %',routed;
 end if;

 select p.id into v_person_id
 from game.persons p
 where not exists(select 1 from game.police_personnel pp where pp.person_id=p.id)
 order by p.person_ref limit 1;
 if v_person_id is null then raise exception 'A deterministic person fixture is required'; end if;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status,joined_on)
 values('KNG-CI-BP04-0001',v_person_id,'KNG-CI-BP04-0001','active',date '2020-01-01')
 on conflict do nothing;
 select personnel_ref into v_actor_ref from game.police_personnel
 where personnel_ref='KNG-CI-BP04-0001' and employment_status='active';
 select property_ref into v_property_ref from game.properties order by property_ref limit 1;
 if v_actor_ref is null or v_property_ref is null then
  raise exception 'Property event command fixture is incomplete';
 end if;
 routed:=game.execute_text_command(
  'property event '||v_property_ref||
  ' EVT-PROP-CI-0001 inspection recorded moderate unknown unknown unknown unknown '||
  '"Command event regression" "A rollback-only property event command." "" "" unknown unknown '||
  '"CI-PROPERTY-EVENT-01" "Fictional regression fixture" by '||v_actor_ref,
  'bp04-property-event-command-valid',null,null
 );
 if coalesce((routed->>'ok')::boolean,false) is not true then
  raise exception 'Property event command did not reach its executor: %',routed;
 end if;
 if not exists(select 1 from game.property_asset_events
  where event_ref='EVT-PROP-CI-0001' and property_id=(select id from game.properties where property_ref=v_property_ref)) then
  raise exception 'Property event command did not persist the canonical property event';
 end if;

 if not exists(select 1 from pg_trigger where tgrelid='game.property_asset_events'::regclass
  and tgname='property_asset_events_append_only' and not tgisinternal) then
  raise exception 'Property asset event append-only trigger is missing.';
 end if;
end;
$$;
rollback;