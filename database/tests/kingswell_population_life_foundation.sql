-- BP-03 population, household, routine and persistent individual-life regression.
-- Every fixture is fictional and rolled back. This test must not initialise the game clock.
begin;
do $$
declare
  v_city uuid;
  v_property uuid;
  v_person1 uuid;
  v_person2 uuid;
  v_person3 uuid;
  v_person4 uuid;
  v_household1 uuid;
  v_household2 uuid;
  v_routine uuid;
  v_life_event uuid;
  v_case uuid;
  v_incident uuid;
  v_call uuid;
  v_summary record;
  v_count integer;
  v_rejected boolean;
  v_clock timestamptz;
begin
  select current_game_time into v_clock from game.simulation_state where id=1;
  if v_clock is not null then raise exception 'BP-03 regression requires an uninitialised fictional clock'; end if;

  select id into v_city from game.cities where code='KNG';
  select id into v_property from game.properties
    where city_id=v_city and land_use='residential' order by property_ref limit 1;
  if v_city is null or v_property is null then raise exception 'Kingswell or its existing residential property seed is missing'; end if;

  insert into game.persons(person_ref,given_name,family_name,date_of_birth,nationality,person_status,birth_city_id)
  values
    ('KW-BP03-TEST-001','Mara','Testwell','1990-01-01','Asterfell','active',v_city),
    ('KW-BP03-TEST-002','Jon','Testwell','2005-01-01','Asterfell','active',v_city),
    ('KW-BP03-TEST-003','Iris','Testwell','1988-06-15','Asterfell','active',v_city),
    ('KW-BP03-TEST-004','Noah','Testwell','1995-09-20','Asterfell','active',v_city)
  ;

  select id into v_person1 from game.persons where person_ref='KW-BP03-TEST-001';
  select id into v_person2 from game.persons where person_ref='KW-BP03-TEST-002';
  select id into v_person3 from game.persons where person_ref='KW-BP03-TEST-003';
  select id into v_person4 from game.persons where person_ref='KW-BP03-TEST-004';

  if game.calculate_person_age(v_person1) is not null then
    raise exception 'Living person age must remain unresolved while the game clock is uninitialised';
  end if;

  insert into game.person_addresses(person_id,property_id,address_role,valid_from,is_current,is_primary)
  values
    (v_person1,v_property,'residence','2020-01-01',true,true),
    (v_person2,v_property,'residence','2020-01-01',true,true);

  v_rejected:=false;
  begin
    insert into game.person_addresses(person_id,property_id,address_role,valid_from,is_current,is_primary)
    values(v_person1,v_property,'residence','2021-01-01',true,false);
  exception when unique_violation then v_rejected:=true;
  end;
  if not v_rejected then raise exception 'Duplicate current address role was accepted'; end if;

  insert into game.households(household_type,primary_property_id,formed_on)
  values('family',v_property,'2020-01-01') returning id into v_household1;
  insert into game.households(household_type,primary_property_id,formed_on)
  values('shared',v_property,'2022-01-01') returning id into v_household2;
  insert into game.household_memberships(household_id,person_id,household_role,is_primary,valid_from)
  values
    (v_household1,v_person1,'head',true,'2020-01-01'),
    (v_household1,v_person2,'child',true,'2020-01-01');

  v_rejected:=false;
  begin
    insert into game.household_memberships(household_id,person_id,household_role,is_primary,valid_from)
    values(v_household2,v_person1,'housemate',true,'2022-01-01');
  exception when unique_violation then v_rejected:=true;
  end;
  if not v_rejected then raise exception 'Person was allowed two current primary households'; end if;

  insert into game.person_population_memberships(person_id,city_id,population_category,valid_from)
  values
    (v_person1,v_city,'permanent_resident','2020-01-01'),
    (v_person1,v_city,'government_worker','2021-01-01'),
    (v_person2,v_city,'permanent_resident','2020-01-01'),
    (v_person2,v_city,'student','2022-01-01');

  select * into v_summary from game.get_population_summary('KNG');
  if v_summary.unique_people<>2 or v_summary.permanent_residents<>2
    or v_summary.government_workers<>1 or v_summary.current_households<>1 then
    raise exception 'Population summary double-counted or missed overlapping memberships: %',row_to_json(v_summary);
  end if;

  insert into game.person_relationships(person_id,related_person_id,relationship_type,valid_from)
  values(v_person1,v_person2,'parent','2005-01-01');
  v_rejected:=false;
  begin
    insert into game.person_relationships(person_id,related_person_id,relationship_type,valid_from)
    values(v_person1,v_person2,'parent','2005-01-01');
  exception when unique_violation then v_rejected:=true;
  end;
  if not v_rejected then raise exception 'Duplicate current person relationship was accepted'; end if;

  insert into game.person_routines(
    person_id,routine_category,activity_type,day_of_week,start_time,end_time,location_property_id
  ) values(v_person1,'work','office work',1,'09:00','17:00',v_property)
  returning id into v_routine;
  insert into game.person_routines(
    person_id,routine_category,activity_type,day_of_week,start_time,end_time,crosses_midnight
  ) values(v_person1,'sleep','sleep',1,'22:00','06:00',true);

  insert into game.person_life_events(person_id,event_type,effective_on,details)
  values(v_person1,'birth','1990-01-01','{"source":"fictional test"}'::jsonb)
  returning id into v_life_event;
  insert into game.person_life_events(person_id,event_type,effective_on,details)
  values(v_person2,'death','2024-01-01','{"source":"fictional test"}'::jsonb);

  if not exists(select 1 from game.persons where id=v_person2 and person_status='deceased' and date_of_death='2024-01-01') then
    raise exception 'Death life event did not update the canonical person status';
  end if;
  if exists(select 1 from game.person_addresses where person_id=v_person2 and is_current)
    or exists(select 1 from game.household_memberships where person_id=v_person2 and valid_to is null)
    or exists(select 1 from game.person_population_memberships where person_id=v_person2 and valid_to is null) then
    raise exception 'Death event did not close current address, household and population memberships';
  end if;
  select * into v_summary from game.get_population_summary('KNG');
  if v_summary.unique_people<>1 or v_summary.permanent_residents<>1 or v_summary.current_households<>1 then
    raise exception 'Deceased person was still counted in current population or household totals';
  end if;
  if game.calculate_person_age(v_person2)<>19 then
    raise exception 'Deceased person age-at-death calculation is incorrect';
  end if;

  v_rejected:=false;
  begin
    update game.person_life_events set details='{}'::jsonb where id=v_life_event;
  exception when others then
    if sqlerrm like 'Person history is append-only:%' then v_rejected:=true; else raise; end if;
  end;
  if not v_rejected then raise exception 'Person life event history allowed mutation'; end if;

  if not game.promote_person_simulation(v_person1,'active','Routine profile requires active simulation','routine',v_routine) then
    raise exception 'Initial simulation promotion failed';
  end if;
  if not exists(select 1 from game.person_simulation_promotions
    where person_id=v_person1 and from_level='background' and to_level='active' and source_entity_type='routine') then
    raise exception 'Simulation promotion history missing or provenance incorrect';
  end if;

  insert into game.cases(case_ref,case_title,summary)
  values('KW-BP03-TEST-CASE','BP-03 test case','Rollback-only fictional case')
  returning id into v_case;
  insert into game.case_persons(case_id,person_id,case_role)
  values(v_case,v_person2,'witness');
  if not exists(select 1 from game.persons where id=v_person2 and simulation_level='full') then
    raise exception 'Case-linked person was not automatically promoted to full simulation';
  end if;
  if not exists(select 1 from game.person_simulation_promotions
    where person_id=v_person2 and source_entity_type='case_person' and source_entity_id=v_case and to_level='full') then
    raise exception 'Case promotion provenance was not retained';
  end if;

  insert into game.incidents(incident_ref,summary,location_property_id)
  values('KW-BP03-TEST-INCIDENT','Rollback-only fictional incident',v_property)
  returning id into v_incident;
  if not exists(select 1 from game.persons where id=v_person1 and simulation_level='full') then
    raise exception 'Resident at incident property was not automatically promoted';
  end if;
  if not exists(select 1 from game.person_simulation_promotions
    where person_id=v_person1 and source_entity_type='incident_location_resident' and source_entity_id=v_incident) then
    raise exception 'Incident-location promotion provenance missing';
  end if;

  insert into game.incident_parties(incident_id,person_id,party_role)
  values(v_incident,v_person3,'witness');
  if not exists(select 1 from game.persons where id=v_person3 and simulation_level='full') then
    raise exception 'Incident-linked person was not automatically promoted';
  end if;

  insert into game.dispatch_calls(call_ref,incident_id,caller_person_id,call_summary)
  values('KW-BP03-TEST-CALL',v_incident,v_person4,'Rollback-only caller')
  returning id into v_call;
  if not exists(select 1 from game.persons where id=v_person4 and simulation_level='full') then
    raise exception 'Dispatch caller was not automatically promoted';
  end if;
  if not exists(select 1 from game.person_simulation_promotions
    where person_id=v_person4 and source_entity_type='dispatch_call' and source_entity_id=v_call) then
    raise exception 'Dispatch caller promotion provenance missing';
  end if;

  v_rejected:=false;
  begin
    update game.persons set simulation_level='active' where id=v_person1;
  exception when others then
    if sqlerrm like 'Person simulation detail cannot be downgraded%' then v_rejected:=true; else raise; end if;
  end;
  if not v_rejected then raise exception 'Simulation detail downgrade was accepted'; end if;

  v_rejected:=false;
  begin
    update game.person_simulation_promotions set promotion_reason='tampered' where person_id=v_person1;
  exception when others then
    if sqlerrm like 'Person history is append-only:%' then v_rejected:=true; else raise; end if;
  end;
  if not v_rejected then raise exception 'Simulation promotion history allowed mutation'; end if;

  v_rejected:=false;
  begin
    insert into game.person_activity_events(
      person_id,routine_id,activity_type,activity_status,started_at_game_time,ended_at_game_time
    ) values(v_person1,v_routine,'commute','completed','2026-11-20 08:00:00+00','2026-11-20 08:30:00+00');
  exception when others then
    if sqlerrm='Fictional game clock is not initialized' then v_rejected:=true; else raise; end if;
  end;
  if not v_rejected then raise exception 'Person activity was recorded while fictional clock was uninitialised'; end if;

  select count(*) into v_count from pg_tables where schemaname='game'
    and tablename in ('households','household_memberships','person_population_memberships',
      'person_life_events','person_routines','person_activity_events','person_simulation_promotions')
    and rowsecurity;
  if v_count<>7 then raise exception 'RLS missing from one or more BP-03 tables'; end if;
  if has_schema_privilege('anon','game','USAGE') or has_schema_privilege('authenticated','game','USAGE') then
    raise exception 'Private game schema unexpectedly exposed to API roles';
  end if;
  if (select column_default from information_schema.columns
      where table_schema='game' and table_name='person_addresses' and column_name='valid_from') is not null then
    raise exception 'Person address valid_from still defaults to real database date';
  end if;

  select current_game_time into v_clock from game.simulation_state where id=1;
  if v_clock is not null then raise exception 'BP-03 regression initialised or advanced fictional time'; end if;
end $$;
rollback;
