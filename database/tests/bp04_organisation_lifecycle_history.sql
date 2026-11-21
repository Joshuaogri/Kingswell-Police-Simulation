-- BP-04 organisation/business lifecycle history regression checks.
-- This test is rollback-only and creates no persistent game facts.
begin;

do $$
declare
 parsed jsonb;
 malformed jsonb;
 missing_history jsonb;
 result jsonb;
begin
 parsed:=game.interpret_text_command(
  'organisation lifecycle event ORG-TEST-01 EVT-TEST-01 name_changed unknown "Registered name changed" "The filed record confirms the organisation changed its registered name." "REGISTRY-TEST-01" "Fictional registry extract" by KNG-TEST-0001'
 );
 if parsed->>'command_type'<>'organisation_lifecycle_event_record'
  or parsed#>>'{payload,organisation_ref}'<>'ORG-TEST-01'
  or parsed#>>'{payload,event_type}'<>'name_changed'
  or parsed#>>'{payload,occurred_on}' is not null
  or parsed#>>'{payload,source_reference}'<>'REGISTRY-TEST-01' then
  raise exception 'Organisation lifecycle event parser returned incorrect fields: %',parsed;
 end if;

 parsed:=game.interpret_text_command(
  'organisation lifecycle event ORG-TEST-01 EVT-TEST-02 merged 2026-11-20 "Merger recorded" "The registry records a merger." "" "" by KNG-TEST-0001'
 );
 if parsed->>'command_type'<>'organisation_lifecycle_event_record'
  or parsed#>>'{payload,event_type}'<>'merged'
  or parsed#>>'{payload,occurred_on}'<>'2026-11-20' then
  raise exception 'Known lifecycle event date was not parsed: %',parsed;
 end if;

 malformed:=game.interpret_text_command(
  'organisation lifecycle event ORG-TEST-01 EVT-TEST-03 fake_event unknown "Bad event" "Invalid event type." "" "" by KNG-TEST-0001'
 );
 if malformed->>'command_type'='organisation_lifecycle_event_record' then
  raise exception 'Invalid lifecycle event type was accepted: %',malformed;
 end if;

 missing_history:=game.get_organisation_lifecycle_history('ORG-DOES-NOT-EXIST');
 if missing_history is not null then
  raise exception 'Unknown organisation unexpectedly returned lifecycle history: %',missing_history;
 end if;

 result:=game.execute_text_command(
  'organisation lifecycle event ORG-DOES-NOT-EXIST EVT-TEST-04 formed unknown "Formation" "Test event." "" "" by KNG-NONEXISTENT',
  'bp04-organisation-lifecycle-actor-01',null,null
 );
 if result->>'code'<>'actor_mismatch' then
  raise exception 'Lifecycle event capture bypassed actor validation: %',result;
 end if;

 if not exists(
  select 1 from pg_trigger
  where tgrelid='game.organisation_lifecycle_events'::regclass
   and tgname='organisation_lifecycle_events_append_only'
   and not tgisinternal
 ) then
  raise exception 'Append-only lifecycle history trigger is missing.';
 end if;
end;
$$;

rollback;
