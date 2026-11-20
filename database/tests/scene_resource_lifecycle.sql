-- Kingswell scene resource response and release/reopen lifecycle regression.
-- All fictional records are rolled back.
begin;
do $test$
declare v_p1 uuid; v_p2 uuid; v_pp1 uuid; v_pp2 uuid; v_unit uuid; v_roster uuid; v_incident uuid; r jsonb; v_scene uuid; v_request1 text; v_request2 text;
begin
 r:=game.submit_command('Initialize scene lifecycle test clock','initialize_clock','{"start_at":"2036-04-20T10:00:00Z"}'::jsonb,'scene-lifecycle-clock-test-0001'); if r->>'ok'<>'true' then raise exception 'Clock init failed: %',r; end if;
 insert into game.persons(person_ref,given_name,family_name) values('LIFE-PERSON-001','Life','One') returning id into v_p1;
 insert into game.persons(person_ref,given_name,family_name) values('LIFE-PERSON-002','Life','Two') returning id into v_p2;
 insert into game.police_units(unit_ref,unit_name,unit_type,status) values('LIFE-TEST-UNIT','Lifecycle Test Unit','patrol','active') returning id into v_unit;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status) values('LIFE-PP-001',v_p1,'LIFE-SN-001',v_unit,'active') returning id into v_pp1;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status) values('LIFE-PP-002',v_p2,'LIFE-SN-002',v_unit,'active') returning id into v_pp2;
 insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status) values('LIFE-ROSTER-001',v_unit,'Lifecycle Test Shift','2036-04-20T09:00:00Z','2036-04-20T19:00:00Z','active') returning id into v_roster;
 insert into game.duty_assignments(roster_id,personnel_id,assignment_role,starts_at,ends_at,status) values (v_roster,v_pp1,'response officer','2036-04-20T09:00:00Z','2036-04-20T19:00:00Z','assigned'),(v_roster,v_pp2,'response officer','2036-04-20T09:00:00Z','2036-04-20T19:00:00Z','assigned');
 insert into game.incidents(incident_ref,reported_at,location_description,priority,status,summary) values('KW-INC-LIFE-TEST','2036-04-20T10:00:00Z','20 Foundry Road',2,'new','Scene lifecycle test') returning id into v_incident;
 r:=game.execute_text_command('help','scene-lifecycle-help-test-0001'); if not (r->'available_commands' ? 'approve_scene_resource') or not (r->'available_commands' ? 'release_scene') or not (r->'available_commands' ? 'reopen_scene') then raise exception 'Help missing lifecycle commands: %',r; end if;
 r:=game.execute_text_command('dispatch LIFE-TEST-UNIT to KW-INC-LIFE-TEST','scene-lifecycle-dispatch-test-0001'); if r->>'ok'<>'true' then raise exception 'Dispatch failed: %',r; end if;
 r:=game.execute_text_command('acknowledge LIFE-PP-001 for KW-INC-LIFE-TEST','scene-lifecycle-ack1-test-0001'); if r->>'ok'<>'true' then raise exception 'Ack1 failed: %',r; end if;
 r:=game.execute_text_command('arrive LIFE-PP-001 at KW-INC-LIFE-TEST','scene-lifecycle-arrive1-test-0001'); if r->>'ok'<>'true' then raise exception 'Arrive1 failed: %',r; end if;
 r:=game.execute_text_command('acknowledge LIFE-PP-002 for KW-INC-LIFE-TEST','scene-lifecycle-ack2-test-0001'); if r->>'ok'<>'true' then raise exception 'Ack2 failed: %',r; end if;
 r:=game.execute_text_command('arrive LIFE-PP-002 at KW-INC-LIFE-TEST','scene-lifecycle-arrive2-test-0001'); if r->>'ok'<>'true' then raise exception 'Arrive2 failed: %',r; end if;
 r:=game.execute_text_command('establish scene KW-SCENE-LIFE at KW-INC-LIFE-TEST by LIFE-PP-001 because reported hazardous materials incident','scene-lifecycle-establish-test-0001'); if r->>'ok'<>'true' then raise exception 'Scene establish failed: %',r; end if;
 select id into v_scene from game.incident_scenes where scene_ref='KW-SCENE-LIFE';
 r:=game.execute_text_command('scene safety LIFE-PP-001 for KW-SCENE-LIFE: possible solvent spill in rear store | restrict access and request specialist review | residual risk remains pending specialist assessment','scene-lifecycle-safety-test-0001'); if r->>'ok'<>'true' then raise exception 'Safety assessment failed: %',r; end if;
 r:=game.execute_text_command('request resource LIFE-PP-002 for KW-SCENE-LIFE: hazardous materials specialist | suspected solvent spill requiring assessment','scene-lifecycle-resource1-test-0001'); if r->>'ok'<>'true' then raise exception 'Resource request failed: %',r; end if; v_request1:=r->>'request_ref';
 r:=game.execute_text_command('release scene LIFE-PP-001 KW-SCENE-LIFE because all examinations complete','scene-lifecycle-release-pending-test-0001'); if r->>'code'<>'resource_requests_outstanding' then raise exception 'Release did not block outstanding resource request: %',r; end if;
 r:=game.execute_text_command('resource approve LIFE-PP-002 '||v_request1||': specialist attendance approved','scene-lifecycle-approve-unauthorised-test-0001'); if r->>'code'<>'scene_command_required' then raise exception 'Non-manager approval was not rejected: %',r; end if;
 r:=game.execute_text_command('resource approve LIFE-PP-001 '||v_request1||': specialist attendance approved','scene-lifecycle-approve-test-0001'); if r->>'ok'<>'true' or r->>'request_status'<>'approved' then raise exception 'Resource approval failed: %',r; end if;
 r:=game.execute_text_command('resource fulfil LIFE-PP-002 '||v_request1||': specialist team attended and completed requested assessment','scene-lifecycle-fulfil-test-0001'); if r->>'ok'<>'true' or r->>'request_status'<>'fulfilled' then raise exception 'Resource fulfilment failed: %',r; end if;
 if (select count(*) from game.scene_resource_request_events where resource_request_id=(select id from game.incident_resource_requests where request_ref=v_request1))<>2 then raise exception 'Resource approval/fulfilment history incomplete'; end if;
 r:=game.execute_text_command('request resource LIFE-PP-002 for KW-SCENE-LIFE: scene lighting | supplementary lighting not required after daylight assessment','scene-lifecycle-resource2-test-0001'); if r->>'ok'<>'true' then raise exception 'Second request failed: %',r; end if; v_request2:=r->>'request_ref';
 r:=game.execute_text_command('resource cancel LIFE-PP-001 '||v_request2||': no longer required','scene-lifecycle-cancel-test-0001'); if r->>'ok'<>'true' or r->>'request_status'<>'cancelled' then raise exception 'Resource cancellation failed: %',r; end if;
 r:=game.execute_text_command('scene entry LIFE-PP-002 into KW-SCENE-LIFE for final controlled examination','scene-lifecycle-entry-test-0001'); if r->>'ok'<>'true' then raise exception 'Scene entry failed: %',r; end if;
 r:=game.execute_text_command('release scene LIFE-PP-001 KW-SCENE-LIFE because all examinations complete','scene-lifecycle-release-entry-test-0001'); if r->>'code'<>'personnel_still_inside_scene' then raise exception 'Release did not block unmatched entry: %',r; end if;
 r:=game.execute_text_command('scene exit LIFE-PP-002 from KW-SCENE-LIFE for final controlled examination complete','scene-lifecycle-exit-test-0001'); if r->>'ok'<>'true' then raise exception 'Scene exit failed: %',r; end if;
 r:=game.execute_text_command('release scene LIFE-PP-001 KW-SCENE-LIFE because examinations complete and outstanding requests resolved','scene-lifecycle-release-test-0001'); if r->>'ok'<>'true' or r->>'scene_status'<>'released' then raise exception 'Scene release failed: %',r; end if;
 r:=game.execute_text_command('reopen scene LIFE-PP-002 KW-SCENE-LIFE because new forensic information requires further examination','scene-lifecycle-reopen-test-0001'); if r->>'ok'<>'true' or r->>'scene_status'<>'reopened' then raise exception 'Scene reopen failed: %',r; end if;
 if (select status from game.incident_scenes where id=v_scene)<>'reopened' then raise exception 'Final scene status not reopened'; end if;
 if (select count(*) from game.scene_lifecycle_events where scene_id=v_scene)<>2 then raise exception 'Release/reopen lifecycle history incomplete'; end if;
 if exists(select 1 from game.incident_resource_requests where scene_id=v_scene and status in ('requested','acknowledged','approved')) then raise exception 'Outstanding resource request remains'; end if;
end;
$test$;
rollback;