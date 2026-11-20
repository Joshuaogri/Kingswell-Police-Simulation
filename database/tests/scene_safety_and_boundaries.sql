-- Kingswell scene safety assessment and scene boundary revision regression.
-- All fictional records are rolled back.
begin;
do $test$
declare v_p1 uuid; v_p2 uuid; v_pp1 uuid; v_pp2 uuid; v_unit uuid; v_roster uuid; v_incident uuid; r jsonb; v_scene uuid; v_first_boundary text; v_second_boundary text;
begin
 r:=game.submit_command('Initialize safety boundary test clock','initialize_clock','{"start_at":"2036-04-19T10:00:00Z"}'::jsonb,'scene-safety-clock-test-0001');
 if r->>'ok'<>'true' then raise exception 'Clock init failed: %',r; end if;
 insert into game.persons(person_ref,given_name,family_name) values('SAFE-PERSON-001','Safe','One') returning id into v_p1;
 insert into game.persons(person_ref,given_name,family_name) values('SAFE-PERSON-002','Safe','Two') returning id into v_p2;
 insert into game.police_units(unit_ref,unit_name,unit_type,status) values('SAFE-TEST-UNIT','Safety Test Unit','patrol','active') returning id into v_unit;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status) values('SAFE-PP-001',v_p1,'SAFE-SN-001',v_unit,'active') returning id into v_pp1;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status) values('SAFE-PP-002',v_p2,'SAFE-SN-002',v_unit,'active') returning id into v_pp2;
 insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status) values('SAFE-ROSTER-001',v_unit,'Safety Test Shift','2036-04-19T09:00:00Z','2036-04-19T19:00:00Z','active') returning id into v_roster;
 insert into game.duty_assignments(roster_id,personnel_id,assignment_role,starts_at,ends_at,status) values
 (v_roster,v_pp1,'response officer','2036-04-19T09:00:00Z','2036-04-19T19:00:00Z','assigned'),
 (v_roster,v_pp2,'response officer','2036-04-19T09:00:00Z','2036-04-19T19:00:00Z','assigned');
 insert into game.incidents(incident_ref,reported_at,location_description,priority,status,summary) values('KW-INC-SAFE-TEST','2036-04-19T10:00:00Z','4 Mill Road',2,'new','Scene safety test') returning id into v_incident;
 r:=game.execute_text_command('help','scene-safety-help-test-0001');
 if not (r->'available_commands' ? 'record_scene_safety') or not (r->'available_commands' ? 'set_scene_boundary') then raise exception 'Help missing scene safety commands: %',r; end if;
 r:=game.execute_text_command('dispatch SAFE-TEST-UNIT to KW-INC-SAFE-TEST','scene-safety-dispatch-test-0001'); if r->>'ok'<>'true' then raise exception 'Dispatch failed: %',r; end if;
 r:=game.execute_text_command('acknowledge SAFE-PP-001 for KW-INC-SAFE-TEST','scene-safety-ack1-test-0001'); if r->>'ok'<>'true' then raise exception 'Ack1 failed: %',r; end if;
 r:=game.execute_text_command('arrive SAFE-PP-001 at KW-INC-SAFE-TEST','scene-safety-arrive1-test-0001'); if r->>'ok'<>'true' then raise exception 'Arrive1 failed: %',r; end if;
 r:=game.execute_text_command('acknowledge SAFE-PP-002 for KW-INC-SAFE-TEST','scene-safety-ack2-test-0001'); if r->>'ok'<>'true' then raise exception 'Ack2 failed: %',r; end if;
 r:=game.execute_text_command('arrive SAFE-PP-002 at KW-INC-SAFE-TEST','scene-safety-arrive2-test-0001'); if r->>'ok'<>'true' then raise exception 'Arrive2 failed: %',r; end if;
 r:=game.execute_text_command('establish scene KW-SCENE-SAFE at KW-INC-SAFE-TEST by SAFE-PP-001 because suspected hazardous spill reported','scene-safety-establish-test-0001');
 if r->>'ok'<>'true' then raise exception 'Establish failed: %',r; end if;
 select id into v_scene from game.incident_scenes where scene_ref='KW-SCENE-SAFE';
 r:=game.interpret_text_command('scene safety SAFE-PP-002 for KW-SCENE-SAFE: suspected chemical odour near rear store | restrict access and request specialist assessment | residual risk uncertain pending specialist attendance');
 if r->>'command_type'<>'record_scene_safety' then raise exception 'Safety parser failed: %',r; end if;
 r:=game.execute_text_command('scene safety SAFE-PP-002 for KW-SCENE-SAFE: suspected chemical odour near rear store | restrict access and request specialist assessment | residual risk uncertain pending specialist attendance','scene-safety-assess-test-0001');
 if r->>'ok'<>'true' or r->>'safety_status'<>'assessed' then raise exception 'Safety assessment failed: %',r; end if;
 if (select safety_status from game.incident_scenes where id=v_scene)<>'assessed' then raise exception 'Safety status not updated'; end if;
 r:=game.interpret_text_command('set boundary SAFE-PP-001 for KW-SCENE-SAFE: rear storage area and adjoining corridor | initial hazard exclusion pending specialist review');
 if r->>'command_type'<>'set_scene_boundary' then raise exception 'Boundary parser failed: %',r; end if;
 r:=game.execute_text_command('set boundary SAFE-PP-001 for KW-SCENE-SAFE: rear storage area and adjoining corridor | initial hazard exclusion pending specialist review','scene-safety-boundary1-test-0001');
 if r->>'ok'<>'true' then raise exception 'Boundary set failed: %',r; end if;
 v_first_boundary:=r->>'boundary_ref';
 r:=game.execute_text_command('set boundary SAFE-PP-002 for KW-SCENE-SAFE: wider rear yard | officer two attempts unauthorised boundary change','scene-safety-boundary-unauthorised-test-0001');
 if r->>'code'<>'scene_command_required' then raise exception 'Non-manager boundary change not rejected: %',r; end if;
 r:=game.execute_text_command('set boundary SAFE-PP-001 for KW-SCENE-SAFE: rear yard and loading entrance | expanded after updated scene assessment','scene-safety-boundary2-test-0001');
 if r->>'ok'<>'true' then raise exception 'Boundary revision failed: %',r; end if;
 v_second_boundary:=r->>'boundary_ref';
 if (select count(*) from game.scene_boundary_revisions where scene_id=v_scene and status='active')<>1 then raise exception 'Expected exactly one active boundary'; end if;
 if not exists(select 1 from game.scene_boundary_revisions where boundary_ref=v_first_boundary and status='superseded') then raise exception 'Prior boundary not superseded'; end if;
 if not exists(select 1 from game.scene_boundary_revisions where boundary_ref=v_second_boundary and status='active') then raise exception 'Current boundary not active'; end if;
 if (select boundary_description from game.incident_scenes where id=v_scene)<>'rear yard and loading entrance' then raise exception 'Current boundary description not updated'; end if;
 if (select count(*) from game.scene_safety_assessments where scene_id=v_scene)<>1 then raise exception 'Safety assessment history missing'; end if;
end;
$test$;
rollback;
