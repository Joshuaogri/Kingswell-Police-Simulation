-- BP-04 property-interest recording, closure and append-only history regression.
begin;
do $test$
declare
 v_actor_person_id uuid; v_actor_ref text:='KNG-CI-BP04-0001';
 v_holder_person_id uuid; v_holder_ref text; v_property_ref text;
 v_property_id uuid; v_interest_id uuid; v_command text;
 v_parsed jsonb; v_result jsonb; v_repeat jsonb; v_history jsonb;
begin
 select p.id into v_actor_person_id
 from game.persons p
 where not exists(select 1 from game.police_personnel pp where pp.person_id=p.id)
 order by p.person_ref limit 1;
 if v_actor_person_id is null then raise exception 'A deterministic actor person is required'; end if;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status,joined_on)
 values(v_actor_ref,v_actor_person_id,v_actor_ref,'active',date '2020-01-01')
 on conflict do nothing;

 select property_ref,id into v_property_ref,v_property_id
 from game.properties order by property_ref limit 1;
 select p.id,p.person_ref into v_holder_person_id,v_holder_ref
 from game.persons p
 where p.id<>v_actor_person_id
   and not exists(select 1 from game.property_interest_records i
    where i.property_id=v_property_id and i.holder_person_id=p.id
      and i.interest_type='landlord' and i.valid_to is null)
 order by p.person_ref limit 1;
 if v_property_ref is null or v_holder_person_id is null then
  raise exception 'Deterministic property and unused canonical interest holder are required';
 end if;

 v_command:='property interest record '||v_property_ref||
  ' landlord person '||v_holder_ref||
  ' unknown 2026-01-01 unknown TIT-CI-INTEREST-01 SRC-CI-INTEREST-01 '||
  '"Fictional CI landlord interest source" "Rollback-only property interest test" by '||v_actor_ref;
 v_parsed:=game.interpret_bp04_property_interest_command(v_command);
 if v_parsed->>'command_type'<>'property_interest_record'
  or v_parsed#>>'{payload,holder_ref}'<>v_holder_ref
  or v_parsed#>>'{payload,interest_type}<>'landlord' then
  raise exception 'Property-interest command parser returned incorrect fields: %',v_parsed;
 end if;

 v_result:=game.execute_text_command(v_command,'bp04-property-interest-record-01',null,null);
 if coalesce((v_result->>'ok')::boolean,false) is not true then
  raise exception 'Property-interest record command failed: %',v_result;
 end if;
 v_interest_id:=(v_result#>>'{record,id}')::uuid;
 if v_interest_id is null then raise exception 'Property-interest command returned no canonical record id'; end if;
 if not exists(select 1 from game.property_interest_records
  where id=v_interest_id and property_id=v_property_id
   and holder_person_id=v_holder_person_id and interest_type='landlord'
   and source_reference='SRC-CI-INTEREST-01'
   and recorded_by_personnel_id=(select id from game.police_personnel where personnel_ref=v_actor_ref)
 ) then raise exception 'Property-interest record did not preserve canonical holder, source and actor'; end if;
 if not exists(select 1 from game.property_interest_events
  where property_interest_id=v_interest_id and event_type='recorded'
   and source_reference='SRC-CI-INTEREST-01') then
  raise exception 'Property-interest creation event was not recorded';
 end if;

 v_repeat:=game.execute_text_command(v_command,'bp04-property-interest-record-02',null,null);
 if coalesce((v_repeat->>'ok')::boolean,false) is not true
  or coalesce((v_repeat->>'duplicate')::boolean,false) is not true then
  raise exception 'Identical property-interest record was not idempotent: %',v_repeat;
 end if;

 v_command:='property interest end '||v_property_ref||
  ' landlord person '||v_holder_ref||
  ' 2026-11-20 "Fictional landlord interest ended" SRC-CI-INTEREST-END '||
  '"Fictional CI interest closure source" by '||v_actor_ref;
 v_result:=game.execute_text_command(v_command,'bp04-property-interest-end-01',null,null);
 if coalesce((v_result->>'ok')::boolean,false) is not true then
  raise exception 'Property-interest closure command failed: %',v_result;
 end if;
 if not exists(select 1 from game.property_interest_records
  where id=v_interest_id and valid_to=date '2026-11-20') then
  raise exception 'Property-interest closure did not close the effective interval';
 end if;
 if not exists(select 1 from game.property_interest_events
  where property_interest_id=v_interest_id and event_type='ended'
   and occurred_on=date '2026-11-20') then
  raise exception 'Property-interest closure event was not preserved';
 end if;

 v_history:=game.get_property_interest_history(v_property_ref);
 if coalesce((v_history->>'interest_count')::integer,0)<1
  or not exists(select 1 from game.property_interest_events where property_interest_id=v_interest_id) then
  raise exception 'Property-interest history query did not expose the recorded timeline';
 end if;
 v_command:='property interest history '||v_property_ref||' by '||v_actor_ref;
 v_result:=game.execute_text_command(v_command,'bp04-property-interest-history-01',null,null);
 if coalesce((v_result->>'ok')::boolean,false) is not true
  or v_result->>'record_type'<>'property_interest_history' then
  raise exception 'Player-facing property-interest history command failed: %',v_result;
 end if;

 v_command:='property interest record '||v_property_ref||
  ' landlord person KNG-NONEXISTENT-PERSON unknown unknown unknown unknown unknown '||
  '"Invalid holder source" "" by '||v_actor_ref;
 v_result:=game.execute_text_command(v_command,'bp04-property-interest-invalid-holder',null,null);
 if v_result->>'code'<>'interest_holder_not_found' then
  raise exception 'Unknown property-interest holder was not rejected: %',v_result;
 end if;

 begin
  update game.property_interest_events set source_description='attempted rewrite'
  where property_interest_id=v_interest_id;
  raise exception 'Append-only property-interest event update unexpectedly succeeded';
 exception when others then
  if sqlerrm='Append-only property-interest event update unexpectedly succeeded' then raise; end if;
 end;

 if has_table_privilege('anon','game.property_interest_records','SELECT')
  or has_table_privilege('authenticated','game.property_interest_records','SELECT')
  or has_table_privilege('anon','game.property_interest_events','SELECT')
  or has_table_privilege('authenticated','game.property_interest_events','SELECT') then
  raise exception 'Private property-interest records are exposed to client roles';
 end if;
 if has_function_privilege('anon','game.record_property_interest(uuid,jsonb,uuid)','EXECUTE')
  or has_function_privilege('authenticated','game.record_property_interest(uuid,jsonb,uuid)','EXECUTE') then
  raise exception 'Property-interest write function is exposed to client roles';
 end if;
end;
$test$;
rollback;
