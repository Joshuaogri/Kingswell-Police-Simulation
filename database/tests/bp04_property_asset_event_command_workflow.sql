-- BP-04 property/building/unit asset-event workflow regression.
begin;
do $$
declare parsed jsonb; routed jsonb; malformed jsonb;
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
 if not exists(select 1 from pg_trigger where tgrelid='game.property_asset_events'::regclass
  and tgname='property_asset_events_append_only' and not tgisinternal) then
  raise exception 'Property asset event append-only trigger is missing.';
 end if;
end;
$$;
rollback;
