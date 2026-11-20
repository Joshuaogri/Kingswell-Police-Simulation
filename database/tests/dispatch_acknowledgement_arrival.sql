-- Kingswell dispatch acknowledgement and individual scene-arrival regression test.
-- All fictional test records are rolled back.
begin;
do $test$
declare
  v_person uuid; v_personnel uuid; v_unit uuid; v_roster uuid; v_incident uuid; v_personnel_ref text; r jsonb;
begin
  r:=game.submit_command('Initialize acknowledgement test clock','initialize_clock',
    '{"start_at":"2036-03-12T09:00:00Z"}'::jsonb,'dispatch-arrival-test-clock-0001');
  if r->>'ok'<>'true' then raise exception 'Clock initialization failed: %',r; end if;
  insert into game.persons(person_ref,given_name,family_name) values('TEST-PERSON-ARR-001','Arrival','Officer') returning id into v_person;
  insert into game.police_units(unit_ref,unit_name,unit_type,status) values('ARRIVAL-TEST-UNIT','Arrival Test Unit','patrol','active') returning id into v_unit;
  insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status)
    values('TEST-PP-ARR-001',v_person,'TEST-SN-ARR-001',v_unit,'active') returning id,personnel_ref into v_personnel,v_personnel_ref;
  insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status)
    values('TEST-ROSTER-ARR-001',v_unit,'Arrival Test Shift','2036-03-12T08:00:00Z','2036-03-12T18:00:00Z','active') returning id into v_roster;
  insert into game.duty_assignments(roster_id,personnel_id,assignment_role,starts_at,ends_at,status)
    values(v_roster,v_personnel,'response officer','2036-03-12T08:00:00Z','2036-03-12T18:00:00Z','assigned');
  insert into game.incidents(incident_ref,reported_at,location_description,priority,status,summary)
    values('KW-INC-ARR-TEST','2036-03-12T09:00:00Z','22 Station Road',2,'new','Arrival workflow test') returning id into v_incident;
  r:=game.execute_text_command('help','dispatch-arrival-test-help-0001');
  if not (r->'available_commands' ? 'acknowledge_dispatch') or not (r->'available_commands' ? 'arrive_scene') then
    raise exception 'Help catalogue is missing acknowledgement or arrival: %',r;
  end if;
  r:=game.execute_text_command('dispatch ARRIVAL-TEST-UNIT to KW-INC-ARR-TEST','dispatch-arrival-test-dispatch-0001');
  if r->>'ok'<>'true' or r->>'personnel_count'<>'1' then raise exception 'Dispatch failed: %',r; end if;
  r:=game.interpret_text_command('arrive TEST-PP-ARR-001 at KW-INC-ARR-TEST');
  if r->>'command_type'<>'arrive_scene' then raise exception 'Arrival parser failed: %',r; end if;
  r:=game.execute_text_command('arrive TEST-PP-ARR-001 at KW-INC-ARR-TEST','dispatch-arrival-test-early-arrival-0001');
  if r->>'code'<>'dispatch_not_acknowledged' then raise exception 'Arrival should require acknowledgement: %',r; end if;
  r:=game.interpret_text_command('acknowledge TEST-PP-ARR-001 for KW-INC-ARR-TEST');
  if r->>'command_type'<>'acknowledge_dispatch' then raise exception 'Acknowledgement parser failed: %',r; end if;
  r:=game.execute_text_command('acknowledge TEST-PP-ARR-001 for KW-INC-ARR-TEST','dispatch-arrival-test-ack-0001');
  if r->>'ok'<>'true' or r->>'deployment_status'<>'responding' then raise exception 'Acknowledgement failed: %',r; end if;
  if (select status from game.incident_deployments where incident_id=v_incident and personnel_id=v_personnel)<>'responding' then raise exception 'Deployment did not enter responding state'; end if;
  if (select count(*) from game.dispatch_events where incident_id=v_incident and event_type='dispatch_acknowledged')<>1 then raise exception 'Acknowledgement event missing'; end if;
  r:=game.execute_text_command('acknowledge TEST-PP-ARR-001 for KW-INC-ARR-TEST','dispatch-arrival-test-ack-0001');
  if r->>'duplicate'<>'true' then raise exception 'Acknowledgement idempotency failed: %',r; end if;
  r:=game.execute_text_command('arrive TEST-PP-ARR-001 at KW-INC-ARR-TEST','dispatch-arrival-test-arrive-0001');
  if r->>'ok'<>'true' or r->>'deployment_status'<>'on_scene' or r->>'incident_status'<>'attending' then raise exception 'Arrival failed: %',r; end if;
  if not exists(select 1 from game.incident_deployments where incident_id=v_incident and personnel_id=v_personnel and status='on_scene' and arrived_at='2036-03-12T09:00:00Z'::timestamptz) then raise exception 'Arrival time/status not persisted'; end if;
  if (select status from game.incidents where id=v_incident)<>'attending' then raise exception 'Incident did not enter attending state'; end if;
  if (select count(*) from game.dispatch_events where incident_id=v_incident and event_type='officer_arrived')<>1 then raise exception 'Arrival event missing'; end if;
  r:=game.execute_text_command('arrive TEST-PP-ARR-001 at KW-INC-ARR-TEST','dispatch-arrival-test-arrive-0001');
  if r->>'duplicate'<>'true' then raise exception 'Arrival idempotency failed: %',r; end if;
end;
$test$;
rollback;
