begin;

do $$
declare
  parsed jsonb;
  malformed jsonb;
  routed jsonb;
begin
  parsed:=game.interpret_text_command(
    'asset register PROP-TEST-0001 BLD-TEST-0001 UNIT-TEST-0001 KWASSET-TEST-0001 cctv operational good "Rear loading bay camera" "Fixed camera covering the rear loading bay" "ASSET-SRC-01" "Facilities inventory extract" by KNG-TEST-0001'
  );
  if parsed->>'command_type'<>'property_asset_register'
     or parsed#>>'{payload,property_ref}'<>'PROP-TEST-0001'
     or parsed#>>'{payload,building_ref}'<>'BLD-TEST-0001'
     or parsed#>>'{payload,unit_ref}'<>'UNIT-TEST-0001'
     or parsed#>>'{payload,asset_ref}'<>'KWASSET-TEST-0001'
     or parsed#>>'{payload,asset_category}'<>'cctv'
     or parsed#>>'{payload,asset_status}'<>'operational'
     or parsed#>>'{payload,condition_grade}'<>'good' then
    raise exception 'Physical asset parser returned incorrect fields: %',parsed;
  end if;

  parsed:=game.interpret_text_command(
    'asset register PROP-TEST-0001 unknown unknown auto other unknown unknown "Unclassified item" "" "" "" by KNG-TEST-0001'
  );
  if parsed->>'command_type'<>'property_asset_register'
     or parsed#>'{payload,building_ref}' is distinct from 'null'::jsonb
     or parsed#>'{payload,unit_ref}' is distinct from 'null'::jsonb
     or parsed#>'{payload,asset_ref}' is distinct from 'null'::jsonb then
    raise exception 'Unknown location or generated asset reference was not preserved: %',parsed;
  end if;

  malformed:=game.interpret_text_command(
    'asset register PROP-TEST-0001 unknown unknown auto invented unknown unknown "Invalid item" "" "" "" by KNG-TEST-0001'
  );
  if malformed->>'command_type'='property_asset_register' then
    raise exception 'Unsupported physical asset category should not parse.';
  end if;

  parsed:=game.interpret_text_command(
    'asset maintenance KWASSET-TEST-0001 KWMAINT-TEST-0001 inspection completed normal 2026-11-20T10:00:00Z unknown 2026-11-20T10:30:00Z "Quarterly camera inspection" "Image clear; housing secure" "Cleaned lens and tested recording" "" "MAINT-SRC-01" "Inspection sheet" by KNG-TEST-0001'
  );
  if parsed->>'command_type'<>'asset_maintenance_record'
     or parsed#>>'{payload,asset_ref}'<>'KWASSET-TEST-0001'
     or parsed#>>'{payload,event_ref}'<>'KWMAINT-TEST-0001'
     or parsed#>>'{payload,event_type}'<>'inspection'
     or parsed#>>'{payload,event_status}'<>'completed'
     or parsed#>>'{payload,priority}'<>'normal'
     or parsed#>>'{payload,occurred_at}'<>'2026-11-20T10:00:00Z'
     or parsed#>'{payload,scheduled_for}' is distinct from 'null'::jsonb then
    raise exception 'Asset maintenance parser returned incorrect fields: %',parsed;
  end if;

  parsed:=game.interpret_text_command(
    'asset maintenance KWASSET-TEST-0001 auto fault_report reported urgent unknown unknown unknown "Unexplained power loss" "" "" "Await electrician report" "" "" by KNG-TEST-0001'
  );
  if parsed->>'command_type'<>'asset_maintenance_record'
     or parsed#>'{payload,event_ref}' is distinct from 'null'::jsonb
     or parsed#>'{payload,occurred_at}' is distinct from 'null'::jsonb then
    raise exception 'Unknown maintenance facts or generated event reference were not preserved: %',parsed;
  end if;

  malformed:=game.interpret_text_command(
    'asset maintenance KWASSET-TEST-0001 KWMAINT-TEST-0002 invented completed normal unknown unknown unknown "Invalid event" "" "" "" "" "" by KNG-TEST-0001'
  );
  if malformed->>'command_type'='asset_maintenance_record' then
    raise exception 'Unsupported maintenance event type should not parse.';
  end if;

  parsed:=game.interpret_text_command('asset record KWASSET-TEST-0001 by KNG-TEST-0001');
  if parsed->>'command_type'<>'property_asset_get_record'
     or parsed#>>'{payload,asset_ref}'<>'KWASSET-TEST-0001' then
    raise exception 'Asset record query was not recognised: %',parsed;
  end if;

  routed:=game.execute_text_command(
    'asset register PROP-TEST-0001 unknown unknown auto other unknown unknown "Test asset" "" "" "" by KNG-NONEXISTENT',
    'bp04-asset-route-test-01',null,null
  );
  if routed->>'code'<>'actor_mismatch' then
    raise exception 'Asset registration did not route through actor validation: %',routed;
  end if;

  routed:=game.execute_text_command(
    'asset maintenance KWASSET-TEST-0001 auto inspection recorded unknown unknown unknown unknown "Test inspection" "" "" "" "" "" by KNG-NONEXISTENT',
    'bp04-maintenance-route-test-01',null,null
  );
  if routed->>'code'<>'actor_mismatch' then
    raise exception 'Asset maintenance did not route through actor validation: %',routed;
  end if;
end;
$$;

rollback;
