-- BP-04 organisation/business lifecycle history regression checks.
-- This test is rollback-only and creates no persistent game facts.
begin;

do $$
declare
 parsed jsonb;
 malformed jsonb;
 missing_history jsonb;
 result jsonb;
 v_org_id uuid;
 v_org_ref text;
 v_person_id uuid;
 v_event_ref text:='LIFECYCLE-CI-TEST-01';
 v_history jsonb;
 v_dossier jsonb;
begin
 parsed:=game.interpret_text_command(
  'organisation lifecycle event ORG-TEST-01 EVT-TEST-01 name_changed unknown unknown "Registered name changed" "The filed record confirms the organisation changed its registered name." "REGISTRY-TEST-01" "Fictional registry extract" by KNG-TEST-0001'
 );
 if parsed->>'command_type'<>'organisation_lifecycle_event_record'
  or parsed#>>'{payload,organisation_ref}'<>'ORG-TEST-01'
  or parsed#>>'{payload,event_type}'<>'name_changed'
  or parsed#>>'{payload,occurred_on}' is not null
  or parsed#>>'{payload,source_reference}'<>'REGISTRY-TEST-01' then
  raise exception 'Organisation lifecycle event parser returned incorrect fields: %',parsed;
 end if;

 parsed:=game.interpret_text_command(
  'organisation lifecycle event ORG-TEST-01 EVT-TEST-02 merged 2026-11-20 ORG-TEST-02 "Merger recorded" "The registry records a merger." "" "" by KNG-TEST-0001'
 );
 if parsed->>'command_type'<>'organisation_lifecycle_event_record'
  or parsed#>>'{payload,event_type}'<>'merged'
  or parsed#>>'{payload,occurred_on}'<>'2026-11-20' then
  raise exception 'Known lifecycle event date was not parsed: %',parsed;
 end if;

 malformed:=game.interpret_text_command(
  'organisation lifecycle event ORG-TEST-01 EVT-TEST-03 fake_event unknown unknown "Bad event" "Invalid event type." "" "" by KNG-TEST-0001'
 );
 if malformed->>'command_type'='organisation_lifecycle_event_record' then
  raise exception 'Invalid lifecycle event type was accepted: %',malformed;
 end if;

 missing_history:=game.get_organisation_lifecycle_history('ORG-DOES-NOT-EXIST');
 if missing_history is not null then
  raise exception 'Unknown organisation unexpectedly returned lifecycle history: %',missing_history;
 end if;

 result:=game.execute_text_command(
  'organisation lifecycle event ORG-DOES-NOT-EXIST EVT-TEST-04 formed unknown unknown "Formation" "Test event." "" "" by KNG-NONEXISTENT',
  'bp04-organisation-lifecycle-actor-01',null,null
 );
 if result->>'code'<>'actor_mismatch' then
  raise exception 'Lifecycle event capture bypassed actor validation: %',result;
 end if;

 select id,organisation_ref into v_org_id,v_org_ref
 from game.organisations order by organisation_ref limit 1;
 select id into v_person_id from game.persons order by id limit 1;
 if v_org_id is null or v_person_id is null then
  raise exception 'Deterministic organisation/person fixtures are required for lifecycle history tests.';
 end if;

 insert into game.organisation_lifecycle_events(
  event_ref,organisation_id,event_type,occurred_on,subject,description,
  actor_person_id,source_reference,source_description
 ) values(
  v_event_ref,v_org_id,'registered',null,'CI lifecycle event',
  'Rollback-only test of historical event storage and dossier retrieval.',
  v_person_id,'CI-LIFECYCLE-TEST','Deterministic regression fixture'
 );
 v_history:=game.get_organisation_lifecycle_history(v_org_ref);
 if (v_history->>'event_count')::integer<>1
  or v_history#>>'{events,0,event,event_ref}'<>v_event_ref
  or v_history#>'{events,0,event,occurred_on}' is distinct from 'null'::jsonb then
  raise exception 'Lifecycle history retrieval lost the event or unknown date: %',v_history;
 end if;

 v_dossier:=game.get_organisation_record(v_org_ref);
 if v_dossier#>>'{lifecycle_history,events,0,event,event_ref}'<>v_event_ref then
  raise exception 'Organisation dossier does not include lifecycle history: %',v_dossier;
 end if;

 begin
  update game.organisation_lifecycle_events
   set subject='Attempted rewrite' where event_ref=v_event_ref;
  raise exception 'Append-only lifecycle event update unexpectedly succeeded.';
 exception when others then
  if sqlerrm='Append-only lifecycle event update unexpectedly succeeded.' then raise; end if;
 end;

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
