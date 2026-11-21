-- BP-04 property asset-event history retrieval regression.
begin;
do $$
declare parsed jsonb; missing jsonb; routed jsonb;
begin
 parsed:=game.interpret_text_command('property event history PROP-TEST-01 by KNG-TEST-0001');
 if parsed->>'command_type'<>'property_asset_event_history_get'
  or parsed#>>'{payload,property_ref}'<>'PROP-TEST-01' then
  raise exception 'Property event history command was not recognised: %',parsed;
 end if;
 missing:=game.get_property_asset_history('PROP-DOES-NOT-EXIST');
 if missing is not null then
  raise exception 'Unknown property unexpectedly returned event history: %',missing;
 end if;
 routed:=game.execute_text_command(
  'property event history PROP-DOES-NOT-EXIST by KNG-NONEXISTENT',
  'bp04-property-event-history-actor-01',null,null
 );
 if routed->>'code'<>'actor_mismatch' then
  raise exception 'Property event history retrieval bypassed actor validation: %',routed;
 end if;
end;
$$;
rollback;
