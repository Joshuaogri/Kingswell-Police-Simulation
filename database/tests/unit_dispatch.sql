-- Unit dispatch and roster eligibility regression test.
-- All fictional test people, units, rosters, incidents and deployments are rolled back.
begin;
do $test$
declare
  v_person uuid;
  v_personnel uuid;
  v_attached_person uuid;
  v_attached_personnel uuid;
  v_home_unit uuid;
  v_unit uuid;
  v_roster uuid;
  v_incident uuid;
  r jsonb;
begin
  r:=game.submit_command('Initialize fictional dispatch test clock','initialize_clock',
    '{"start_at":"2036-02-10T08:00:00Z"}'::jsonb,'unit-dispatch-test-clock-0001');
  if r->>'ok'<>'true' then raise exception 'Clock initialization failed: %',r; end if;

  insert into game.persons(person_ref,given_name,family_name)
    values('TEST-PERSON-DSP-001','Test','Officer') returning id into v_person;
  insert into game.police_units(unit_ref,unit_name,unit_type,status)
    values('PATROL-TEST-01','Test Patrol Unit','patrol','active') returning id into v_unit;
  insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status)
    values('TEST-PP-DSP-001',v_person,'TEST-SN-DSP-001',v_unit,'active') returning id into v_personnel;

  insert into game.police_units(unit_ref,unit_name,unit_type,status)
    values('HOME-UNIT-TEST-02','Test Home Unit','patrol','active') returning id into v_home_unit;
  insert into game.persons(person_ref,given_name,family_name)
    values('TEST-PERSON-DSP-002','Attached','Officer') returning id into v_attached_person;
  insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status)
    values('TEST-PP-DSP-002',v_attached_person,'TEST-SN-DSP-002',v_home_unit,'active') returning id into v_attached_personnel;
  insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status)
    values('TEST-ROSTER-DSP-001',v_unit,'Test Day Shift','2036-02-10T07:00:00Z','2036-02-10T19:00:00Z','active')
    returning id into v_roster;
  insert into game.duty_assignments(roster_id,personnel_id,assignment_role,starts_at,ends_at,status)
    values(v_roster,v_personnel,'response officer','2036-02-10T07:00:00Z','2036-02-10T19:00:00Z','assigned');
  insert into game.duty_assignments(roster_id,personnel_id,assignment_role,starts_at,ends_at,status)
    values(v_roster,v_attached_personnel,'temporary attachment','2036-02-10T07:00:00Z','2036-02-10T19:00:00Z','assigned');

  insert into game.incidents(incident_ref,reported_at,location_description,priority,status,summary)
    values('KW-INC-TEST-01','2036-02-10T08:00:00Z','14 Market Lane',2,'new','Test burglary report')
    returning id into v_incident;
  insert into game.dispatch_calls(call_ref,incident_id,received_at,call_summary,status)
    values('KW-CALL-TEST-01',v_incident,'2036-02-10T08:00:00Z','Test burglary report','received');

  r:=game.execute_text_command('help','unit-dispatch-test-help-0001');
  if not (r->'available_commands' ? 'dispatch_unit') or not (r->'available_commands' ? 'receive_call') then
    raise exception 'Help command catalogue is incomplete: %',r;
  end if;

  r:=game.interpret_text_command('dispatch PATROL-TEST-01 to KW-INC-TEST-01');
  if r->>'command_type'<>'dispatch_unit' then raise exception 'Dispatch parser failed: %',r; end if;
  r:=game.execute_text_command('dispatch PATROL-TEST-01 to KW-INC-TEST-01','unit-dispatch-test-action-0001');
  if r->>'ok'<>'true' or r->>'personnel_count'<>'2' then raise exception 'Dispatch command failed: %',r; end if;
  if (select status from game.incidents where id=v_incident)<>'dispatched' then raise exception 'Incident state did not change'; end if;
  if (select status from game.dispatch_calls where incident_id=v_incident)<>'dispatched' then raise exception 'Call state did not change'; end if;
  if (select count(*) from game.incident_deployments where incident_id=v_incident and status='dispatched')<>2 then raise exception 'Deployment records missing for home-unit and attached personnel'; end if;
  if (select count(*) from game.dispatch_events where incident_id=v_incident and event_type='unit_dispatched')<>2 then raise exception 'Dispatch events missing'; end if;
  r:=game.execute_text_command('dispatch PATROL-TEST-01 to KW-INC-TEST-01','unit-dispatch-test-action-0001');
  if r->>'duplicate'<>'true' then raise exception 'Dispatch idempotency failed: %',r; end if;
end;
$test$;
rollback;
