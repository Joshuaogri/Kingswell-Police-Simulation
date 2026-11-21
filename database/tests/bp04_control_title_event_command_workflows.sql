begin;

do $$
declare
  parsed jsonb;
  malformed jsonb;
  routed jsonb;
begin
  parsed:=game.interpret_text_command(
    'organisation control ORG-TEST-0001 person PER-TEST-0001 shareholder 25 20 2020-01-01 unknown "SRC-CTRL-1" "Company register extract" by KNG-TEST-0001'
  );
  if parsed->>'command_type'<>'organisation_control_record' then
    raise exception 'Organisation control command was not recognised: %',parsed;
  end if;
  if parsed#>>'{payload,organisation_ref}'<>'ORG-TEST-0001'
     or parsed#>>'{payload,holder_type}'<>'person'
     or parsed#>>'{payload,holder_ref}'<>'PER-TEST-0001'
     or parsed#>>'{payload,control_type}'<>'shareholder'
     or parsed#>>'{payload,ownership_share_pct}'<>'25'
     or parsed#>>'{payload,voting_share_pct}'<>'20'
     or parsed#>'{payload,valid_to}' is distinct from 'null'::jsonb then
    raise exception 'Organisation control parser returned incorrect fields: %',parsed;
  end if;

  parsed:=game.interpret_text_command(
    'organisation control ORG-TEST-0001 organisation ORG-TEST-0002 beneficial_owner unknown unknown unknown unknown "" "" by KNG-TEST-0001'
  );
  if parsed->>'command_type'<>'organisation_control_record'
     or parsed#>'{payload,ownership_share_pct}' is distinct from 'null'::jsonb
     or parsed#>'{payload,valid_from}' is distinct from 'null'::jsonb then
    raise exception 'Unknown control values were not preserved: %',parsed;
  end if;

  malformed:=game.interpret_text_command(
    'organisation control ORG-TEST-0001 person PER-TEST-0001 invented 25 20 unknown unknown "" "" by KNG-TEST-0001'
  );
  if malformed->>'command_type'='organisation_control_record' then
    raise exception 'Unsupported control type should not parse.';
  end if;

  parsed:=game.interpret_text_command(
    'property title event PROP-TEST-0001 EVT-TEST-0001 transfer 2026-11-20 2026-11-21 recorded organisation ORG-TEST-0001 person PER-TEST-0001 freehold 50 "TITLE-OLD" "TITLE-NEW" "Transfer deed" "INST-TEST-1" "SRC-TITLE-1" "Register extract" by KNG-TEST-0001'
  );
  if parsed->>'command_type'<>'property_title_event_record' then
    raise exception 'Property title event command was not recognised: %',parsed;
  end if;
  if parsed#>>'{payload,property_ref}'<>'PROP-TEST-0001'
     or parsed#>>'{payload,event_ref}'<>'EVT-TEST-0001'
     or parsed#>>'{payload,event_type}'<>'transfer'
     or parsed#>>'{payload,transferor_type}'<>'organisation'
     or parsed#>>'{payload,transferor_ref}'<>'ORG-TEST-0001'
     or parsed#>>'{payload,transferee_type}'<>'person'
     or parsed#>>'{payload,transferee_ref}'<>'PER-TEST-0001'
     or parsed#>>'{payload,share_transferred_pct}'<>'50'
     or parsed#>>'{payload,registration_status}'<>'recorded' then
    raise exception 'Property title event parser returned incorrect fields: %',parsed;
  end if;

  parsed:=game.interpret_text_command(
    'property title event PROP-TEST-0001 EVT-TEST-0002 other unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown "" "" "" "" "" "" by KNG-TEST-0001'
  );
  if parsed->>'command_type'<>'property_title_event_record'
     or parsed#>'{payload,occurred_on}' is distinct from 'null'::jsonb
     or parsed#>'{payload,share_transferred_pct}' is distinct from 'null'::jsonb then
    raise exception 'Unknown title-event facts were not preserved: %',parsed;
  end if;

  malformed:=game.interpret_text_command(
    'property title event PROP-TEST-0001 EVT-TEST-0003 impossible unknown unknown recorded unknown unknown unknown unknown unknown unknown "" "" "" "" "" "" by KNG-TEST-0001'
  );
  if malformed->>'command_type'='property_title_event_record' then
    raise exception 'Unsupported title event type should not parse.';
  end if;

  routed:=game.execute_text_command(
    'organisation control ORG-TEST-0001 person PER-TEST-0001 shareholder 25 20 unknown unknown "" "" by KNG-NONEXISTENT',
    'bp04-control-route-test-01',null,null
  );
  if routed->>'code'<>'actor_mismatch' then
    raise exception 'Organisation control command did not route through the existing actor-validated runtime: %',routed;
  end if;

  routed:=game.execute_text_command(
    'property title event PROP-TEST-0001 EVT-TEST-0004 other unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown "" "" "" "" "" "" by KNG-NONEXISTENT',
    'bp04-title-route-test-01',null,null
  );
  if routed->>'code'<>'actor_mismatch' then
    raise exception 'Property title event command did not route through the existing actor-validated runtime: %',routed;
  end if;
end;
$$;

rollback;
