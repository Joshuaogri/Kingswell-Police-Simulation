begin;

do $$
declare
  parsed jsonb;
  malformed jsonb;
begin
  parsed:=game.interpret_text_command(
    'agreement event AGR-TEST-0001 EVT-TEST-0001 varied 2026-11-20 "Rent review agreed" "The parties signed a documented variation." by KNG-TEST-0001'
  );
  if parsed->>'command_type'<>'agreement_event_record' then
    raise exception 'Agreement event command was not recognised: %',parsed;
  end if;
  if parsed#>>'{payload,agreement_ref}'<>'AGR-TEST-0001'
     or parsed#>>'{payload,event_ref}'<>'EVT-TEST-0001'
     or parsed#>>'{payload,event_type}'<>'varied'
     or parsed#>>'{payload,occurred_on}'<>'2026-11-20'
     or parsed#>>'{payload,actor_ref}'<>'KNG-TEST-0001' then
    raise exception 'Agreement event parser returned incorrect fields: %',parsed;
  end if;

  parsed:=game.interpret_text_command(
    'agreement event AGR-TEST-0002 EVT-TEST-0002 proposed unknown "Proposal received" "Date not established." by KNG-TEST-0001'
  );
  if parsed->>'command_type'<>'agreement_event_record'
     or parsed#>'{payload,occurred_on}' is distinct from 'null'::jsonb then
    raise exception 'Unknown event date was not preserved as unknown: %',parsed;
  end if;

  malformed:=game.interpret_text_command(
    'agreement event AGR-TEST-0001 EVT-TEST-0003 invented 2026-11-20 "Bad type" "Should not parse." by KNG-TEST-0001'
  );
  if malformed->>'command_type'='agreement_event_record' then
    raise exception 'Unsupported event type should not parse.';
  end if;
end;
$$;

rollback;
