-- BP-04 site-agreement lifecycle regression checks.
-- Run after bp04_site_agreement_lifecycle_event_history migration.
do $$
declare
 v_ref text;
 v_agreement_id uuid;
 v_json jsonb;
 v_immutable boolean:=false;
begin
 if to_regclass('game.organisation_site_agreement_events') is null then
  raise exception 'BP04: agreement lifecycle event table missing';
 end if;
 if not exists(
  select 1 from game.organisation_site_agreement_events
  where event_details->>'generated_fictional_baseline'='true'
 ) then
  raise exception 'BP04: generated agreement lifecycle baseline is missing';
 end if;
 if exists(
  select 1 from game.organisation_site_agreement_events
  where coalesce(event_details->>'generated_fictional_baseline','false')<>'true'
 ) then
  raise exception 'BP04: unexpected non-baseline agreement lifecycle rows in clean fixture';
 end if;
 select agreement_ref,id into v_ref,v_agreement_id
 from game.organisation_site_agreements order by agreement_ref limit 1;
 v_json:=game.get_site_agreement_record(v_ref);
 if v_json is null
  or not (v_json?'agreement' and v_json?'tenant' and v_json?'sites'
    and v_json?'lifecycle_events' and v_json?'term_coverage' and v_json?'provenance')
 then raise exception 'BP04: agreement dossier is incomplete'; end if;
 if jsonb_typeof(v_json->'lifecycle_events')<>'array'
  or jsonb_array_length(v_json->'lifecycle_events')=0
 then raise exception 'BP04: agreement dossier omitted generated lifecycle events'; end if;
 if v_json#>>'{provenance,occupancy_dates_are_contract_dates}'<>'false'
 then raise exception 'BP04: agreement dossier conflates occupancy and contract dates'; end if;
 if v_json#>>'{term_coverage,execution_date}'<>'not_recorded'
 then raise exception 'BP04: missing execution date is not preserved as unknown'; end if;

 begin
  insert into game.organisation_site_agreement_events(
   event_ref,agreement_id,event_type,recorded_on,subject,description,source_description
  ) values(
   'BP04-REGRESSION-TRANSIENT',v_agreement_id,'other',current_date,
   'Regression-only transient event','Must never persist','Regression test only'
  );
  update game.organisation_site_agreement_events
   set description='This update must be rejected'
   where event_ref='BP04-REGRESSION-TRANSIENT';
  raise exception 'BP04: immutable event update unexpectedly succeeded';
 exception when others then
  if sqlerrm='BP04: immutable event update unexpectedly succeeded' then raise; end if;
  if sqlerrm not like 'BP-04 agreement lifecycle events are immutable%' then raise; end if;
  v_immutable:=true;
 end;
 if not v_immutable then raise exception 'BP04: immutable event trigger did not fire'; end if;
 if exists(select 1 from game.organisation_site_agreement_events where event_ref='BP04-REGRESSION-TRANSIENT')
 then raise exception 'BP04: transient regression event was not rolled back'; end if;

 if has_table_privilege('anon','game.organisation_site_agreement_events','select')
  or has_table_privilege('authenticated','game.organisation_site_agreement_events','select')
 then raise exception 'BP04: private agreement lifecycle history exposed to client roles'; end if;
end $$;