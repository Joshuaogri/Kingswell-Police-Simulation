-- Kingswell scene control, command transfer, activity, access, field report and resource request regression.
-- All fictional records are rolled back.
begin;
do $test$
declare v_p1 uuid; v_p2 uuid; v_pp1 uuid; v_pp2 uuid; v_unit uuid; v_roster uuid; v_incident uuid; r jsonb; v_scene uuid;
begin
 r:=game.submit_command('Initialize scene test clock','initialize_clock','{"start_at":"2036-04-18T14:00:00Z"}'::jsonb,'scene-layer-clock-test-0001');
 if r->>'ok'<>'true' then raise exception 'Clock init failed: %',r; end if;
 insert into game.persons(person_ref,given_name,family_name) values('SCENE-PERSON-001','Scene','One') returning id into v_p1;
 insert into game.persons(person_ref,given_name,family_name) values('SCENE-PERSON-002','Scene','Two') returning id into v_p2;
 insert into game.police_units(unit_ref,unit_name,unit_type,status) values('SCENE-TEST-UNIT','Scene Test Unit','patrol','active') returning id into v_unit;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status) values('SCENE-PP-001',v_p1,'SCENE-SN-001',v_unit,'active') returning id into v_pp1;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status) values('SCENE-PP-002',v_p2,'SCENE-SN-002',v_unit,'active') returning id into v_pp2;
 insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status) values('SCENE-ROSTER-001',v_unit,'Scene Test Shift','2036-04-18T13:00:00Z','2036-04-18T23:00:00Z','active') returning id into v_roster;
 insert into game.duty_assignments(roster_id,personnel_id,assignment_role,starts_at,ends_at,status) values
 (v_roster,v_pp1,'response officer','2036-04-18T13:00:00Z','2036-04-18T23:00:00Z','assigned'),
 (v_roster,v_pp2,'response officer','2036-04-18T13:00:00Z','2036-04-18T23:00:00Z','assigned');
 insert into game.incidents(incident_ref,reported_at,location_description,priority,status,summary) values('KW-INC-SCENE-TEST','2036-04-18T14:00:00Z','18 Foundry Road',2,'new','Scene workflow test') returning id into v_incident;
 r:=game.execute_text_command('help','scene-layer-help-test-0001');
 if not (r->'available_commands' ? 'establish_scene') or not (r->'available_commands' ? 'submit_field_report') then raise exception 'Help missing commands: %',r; end if;
 r:=game.execute_text_command('dispatch SCENE-TEST-UNIT to KW-INC-SCENE-TEST','scene-layer-dispatch-test-0001');
 if r->>'ok'<>'true' or r->>'personnel_count'<>'2' then raise exception 'Dispatch failed: %',r; end if;
 r:=game.execute_text_command('acknowledge SCENE-PP-001 for KW-INC-SCENE-TEST','scene-layer-ack1-test-0001'); if r->>'ok'<>'true' then raise exception 'Ack1 failed: %',r; end if;
 r:=game.execute_text_command('arrive SCENE-PP-001 at KW-INC-SCENE-TEST','scene-layer-arrive1-test-0001'); if r->>'ok'<>'true' then raise exception 'Arrive1 failed: %',r; end if;
 r:=game.execute_text_command('acknowledge SCENE-PP-002 for KW-INC-SCENE-TEST','scene-layer-ack2-test-0001'); if r->>'ok'<>'true' then raise exception 'Ack2 failed: %',r; end if;
 r:=game.execute_text_command('arrive SCENE-PP-002 at KW-INC-SCENE-TEST','scene-layer-arrive2-test-0001'); if r->>'ok'<>'true' then raise exception 'Arrive2 failed: %',r; end if;
 r:=game.interpret_text_command('establish scene KW-SCENE-TEST at KW-INC-SCENE-TEST by SCENE-PP-001 because suspected forced entry reported by caller');
 if r->>'command_type'<>'establish_scene' or r#>>'{payload,reason}' not like 'suspected forced entry%' then raise exception 'Establish parser failed: %',r; end if;
 r:=game.execute_text_command('establish scene KW-SCENE-TEST at KW-INC-SCENE-TEST by SCENE-PP-001 because suspected forced entry reported by caller','scene-layer-establish-test-0001');
 if r->>'ok'<>'true' or r->>'scene_status'<>'controlled' then raise exception 'Establish failed: %',r; end if;
 select id into v_scene from game.incident_scenes where scene_ref='KW-SCENE-TEST';
 if not exists(select 1 from game.incident_scenes where id=v_scene and scene_manager_personnel_id=v_pp1 and control_started_at='2036-04-18T14:00:00Z'::timestamptz) then raise exception 'Scene manager/time missing'; end if;
 r:=game.execute_text_command('take command SCENE-PP-002 of KW-SCENE-TEST','scene-layer-command-transfer-test-0001');
 if r->>'ok'<>'true' or (select scene_manager_personnel_id from game.incident_scenes where id=v_scene)<>v_pp2 then raise exception 'Command transfer failed: %',r; end if;
 r:=game.interpret_text_command('scene update SCENE-PP-002 for KW-SCENE-TEST: Occupants accounted for; no immediate hazards observed');
 if r->>'command_type'<>'scene_update' then raise exception 'Scene update parser failed: %',r; end if;
 r:=game.execute_text_command('scene update SCENE-PP-002 for KW-SCENE-TEST: Occupants accounted for; no immediate hazards observed','scene-layer-update-test-0001');
 if r->>'ok'<>'true' then raise exception 'Scene update failed: %',r; end if;
 r:=game.interpret_text_command('field report SCENE-PP-002 for KW-INC-SCENE-TEST at KW-SCENE-TEST: On arrival I observed the front entrance unsecured. This is an observation, not a conclusion.');
 if r->>'command_type'<>'submit_field_report' then raise exception 'Report parser failed: %',r; end if;
 r:=game.execute_text_command('field report SCENE-PP-002 for KW-INC-SCENE-TEST at KW-SCENE-TEST: On arrival I observed the front entrance unsecured. This is an observation, not a conclusion.','scene-layer-report-test-0001');
 if r->>'ok'<>'true' then raise exception 'Report failed: %',r; end if;
 if not exists(select 1 from game.incident_field_reports where report_ref=r->>'report_ref' and incident_id=v_incident and scene_id=v_scene and personnel_id=v_pp2) then raise exception 'Report link missing'; end if;
 r:=game.interpret_text_command('request resource SCENE-PP-002 for KW-SCENE-TEST: scenes-of-crime officer | preserve and document potential material');
 if r->>'command_type'<>'request_scene_resource' then raise exception 'Resource parser failed: %',r; end if;
 r:=game.execute_text_command('request resource SCENE-PP-002 for KW-SCENE-TEST: scenes-of-crime officer | preserve and document potential material','scene-layer-resource-test-0001');
 if r->>'ok'<>'true' or r->>'request_status'<>'requested' then raise exception 'Resource request failed: %',r; end if;
 if not exists(select 1 from game.incident_resource_requests where request_ref=r->>'request_ref' and status='requested' and scene_id=v_scene) then raise exception 'Resource request not persisted'; end if;
 r:=game.submit_command('Bad resource quantity test','request_scene_resource',jsonb_build_object('personnel_ref','SCENE-PP-002','scene_ref','KW-SCENE-TEST','resource_type','test','reason','test','quantity','many'),'scene-layer-bad-quantity-test-0001');
 if r->>'code'<>'invalid_resource_quantity' then raise exception 'Bad quantity not rejected: %',r; end if;
 r:=game.interpret_text_command('scene entry SCENE-PP-002 into KW-SCENE-TEST for initial scene assessment');
 if r->>'command_type'<>'scene_entry' then raise exception 'Entry parser failed: %',r; end if;
 r:=game.execute_text_command('scene entry SCENE-PP-002 into KW-SCENE-TEST for initial scene assessment','scene-layer-entry-test-0001');
 if r->>'ok'<>'true' then raise exception 'Entry failed: %',r; end if;
 r:=game.execute_text_command('scene entry SCENE-PP-002 into KW-SCENE-TEST for duplicate entry','scene-layer-entry-duplicate-test-0001');
 if r->>'code'<>'already_inside_scene_zone' then raise exception 'Duplicate entry not rejected: %',r; end if;
 r:=game.execute_text_command('scene exit SCENE-PP-002 from KW-SCENE-TEST for end of assessment','scene-layer-exit-test-0001');
 if r->>'ok'<>'true' then raise exception 'Exit failed: %',r; end if;
 r:=game.execute_text_command('scene exit SCENE-PP-002 from KW-SCENE-TEST for duplicate exit','scene-layer-exit-duplicate-test-0001');
 if r->>'code'<>'no_open_scene_entry' then raise exception 'Unmatched exit not rejected: %',r; end if;
 if (select count(*) from game.incident_field_reports where incident_id=v_incident)<>1 then raise exception 'Field report count wrong'; end if;
 if (select count(*) from game.scene_access_events where scene_id=v_scene)<>2 then raise exception 'Scene access count wrong'; end if;
 if (select count(*) from game.scene_activity_logs where scene_id=v_scene)<6 then raise exception 'Activity log incomplete'; end if;
end;
$test$;
rollback;
