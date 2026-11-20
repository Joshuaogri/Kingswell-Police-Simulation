-- Kingswell specialist attendance and scene examination workflow regression.
-- All fictional records are rolled back.
begin;
do $test$
declare v_p1 uuid; v_p2 uuid; v_pp1 uuid; v_pp2 uuid; v_unit uuid; v_roster uuid; v_incident uuid; v_scene uuid; v_qual uuid; r jsonb; v_plan1 text; v_plan2 text; v_attendance text;
begin
 r:=game.submit_command('Initialize specialist examination test clock','initialize_clock','{"start_at":"2036-04-21T10:00:00Z"}'::jsonb,'scene-specialist-clock-test-0001');
 if r->>'ok'<>'true' then raise exception 'Clock init failed: %',r; end if;
 insert into game.persons(person_ref,given_name,family_name) values('SPEC-PERSON-001','Scene','Manager') returning id into v_p1;
 insert into game.persons(person_ref,given_name,family_name) values('SPEC-PERSON-002','Forensic','Examiner') returning id into v_p2;
 insert into game.police_units(unit_ref,unit_name,unit_type,status) values('SPEC-TEST-UNIT','Specialist Test Unit','specialist','active') returning id into v_unit;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status) values('SPEC-PP-001',v_p1,'SPEC-SN-001',v_unit,'active') returning id into v_pp1;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status) values('SPEC-PP-002',v_p2,'SPEC-SN-002',v_unit,'active') returning id into v_pp2;
 insert into game.personnel_qualifications(personnel_id,qualification_code,qualification_name,awarded_on,expires_on,status)
 values(v_pp2,'DNA','DNA Examination','2035-01-01','2037-01-01','valid') returning id into v_qual;
 insert into game.personnel_qualifications(personnel_id,qualification_code,qualification_name,awarded_on,expires_on,status) values(v_pp2,'FINGERPRINT','Fingerprint','2034-01-01','2036-04-20','valid');
 insert into game.duty_rosters(roster_ref,unit_id,shift_name,starts_at,ends_at,status) values('SPEC-ROSTER-001',v_unit,'Specialist Test Shift','2036-04-21T09:00:00Z','2036-04-21T19:00:00Z','active') returning id into v_roster;
 insert into game.duty_assignments(roster_id,personnel_id,assignment_role,starts_at,ends_at,status) values
 (v_roster,v_pp1,'scene manager','2036-04-21T09:00:00Z','2036-04-21T19:00:00Z','assigned'),
 (v_roster,v_pp2,'forensic examiner','2036-04-21T09:00:00Z','2036-04-21T19:00:00Z','assigned');
 insert into game.incidents(incident_ref,reported_at,location_description,priority,status,summary) values('KW-INC-SPEC-TEST','2036-04-21T10:00:00Z','12 Foundry Lane',2,'new','Specialist examination test') returning id into v_incident;
 r:=game.execute_text_command('help','scene-specialist-help-test-0001');
 if not (r->'available_commands' ? 'specialist_attend') or not (r->'available_commands' ? 'plan_scene_examination') or not (r->'available_commands' ? 'complete_scene_examination') then raise exception 'Help missing specialist commands: %',r; end if;
 r:=game.execute_text_command('dispatch SPEC-TEST-UNIT to KW-INC-SPEC-TEST','scene-specialist-dispatch-test-0001'); if r->>'ok'<>'true' then raise exception 'Dispatch failed: %',r; end if;
 r:=game.execute_text_command('acknowledge SPEC-PP-001 for KW-INC-SPEC-TEST','scene-specialist-ack1-test-0001'); if r->>'ok'<>'true' then raise exception 'Ack1 failed: %',r; end if;
 r:=game.execute_text_command('arrive SPEC-PP-001 at KW-INC-SPEC-TEST','scene-specialist-arrive1-test-0001'); if r->>'ok'<>'true' then raise exception 'Arrive1 failed: %',r; end if;
 r:=game.execute_text_command('acknowledge SPEC-PP-002 for KW-INC-SPEC-TEST','scene-specialist-ack2-test-0001'); if r->>'ok'<>'true' then raise exception 'Ack2 failed: %',r; end if;
 r:=game.execute_text_command('arrive SPEC-PP-002 at KW-INC-SPEC-TEST','scene-specialist-arrive2-test-0001'); if r->>'ok'<>'true' then raise exception 'Arrive2 failed: %',r; end if;
 r:=game.execute_text_command('establish scene KW-SCENE-SPEC at KW-INC-SPEC-TEST by SPEC-PP-001 because scene requires specialist examination','scene-specialist-establish-test-0001'); if r->>'ok'<>'true' then raise exception 'Scene establish failed: %',r; end if;
 select id into v_scene from game.incident_scenes where scene_ref='KW-SCENE-SPEC';
 r:=game.execute_text_command('scene safety SPEC-PP-001 for KW-SCENE-SPEC: no immediate hazard identified | maintain controlled access | residual risk assessed as low','scene-specialist-safety-early-test-0001'); if r->>'ok'<>'true' then raise exception 'Safety assessment failed: %',r; end if;
 r:=game.interpret_text_command('specialist attend SPEC-PP-002 at KW-SCENE-SPEC as DNA: assess submitted material'); if r->>'command_type'<>'specialist_attend' then raise exception 'Specialist parser failed: %',r; end if;
 r:=game.execute_text_command('specialist attend SPEC-PP-002 at KW-SCENE-SPEC as Fingerprint: expired qualification must be rejected','scene-specialist-expired-qual-test-0001'); if r->>'code'<>'specialist_qualification_not_current' then raise exception 'Expired qualification was accepted: %',r; end if;
 r:=game.execute_text_command('specialist attend SPEC-PP-002 at KW-SCENE-SPEC as Latent Print: no matching qualification exists','scene-specialist-invalid-qual-test-0001'); if r->>'code'<>'specialist_qualification_not_current' then raise exception 'Unmatched discipline qualification was accepted: %',r; end if;
 r:=game.execute_text_command('specialist attend SPEC-PP-002 at KW-SCENE-SPEC as DNA: assess submitted material','scene-specialist-attend-test-0001'); if r->>'ok'<>'true' or r->>'qualification_verified'<>'true' then raise exception 'Specialist attendance failed: %',r; end if;
 v_attendance:=r->>'attendance_ref';
 r:=game.execute_text_command('release scene SPEC-PP-001 KW-SCENE-SPEC because scene manager attempts release while specialist remains signed in','scene-specialist-release-attending-test-0001'); if r->>'code'<>'specialists_still_attending' then raise exception 'Scene release with active specialist attendance was accepted: %',r; end if;
 r:=game.execute_text_command('specialist attend SPEC-PP-002 at KW-SCENE-SPEC as DNA: duplicate sign-in','scene-specialist-duplicate-attend-test-0001'); if r->>'code'<>'specialist_already_attending' then raise exception 'Duplicate specialist attendance was accepted: %',r; end if;
 r:=game.execute_text_command('plan examination SPEC-PP-002 for KW-SCENE-SPEC by SPEC-PP-002 in DNA: determine whether submitted material contains a relevant biological profile | examine only the submitted reference material under the stated request | no comparison sample supplied and interpretation scope remains limited','scene-specialist-unauthorised-plan-test-0001'); if r->>'code'<>'scene_command_required' then raise exception 'Non-manager examination plan was accepted: %',r; end if;
 r:=game.execute_text_command('plan examination SPEC-PP-001 for KW-SCENE-SPEC by SPEC-PP-002 in DNA: determine whether submitted material contains a relevant biological profile | examine only the submitted reference material under the stated request | no comparison sample supplied and interpretation scope remains limited','scene-specialist-plan-test-0001'); if r->>'ok'<>'true' or r->>'plan_status'<>'planned' then raise exception 'Examination plan failed: %',r; end if; v_plan1:=r->>'plan_ref';
 r:=game.execute_text_command('specialist depart SPEC-PP-002 from KW-SCENE-SPEC because departure attempted before examination completion','scene-specialist-early-depart-test-0001'); if r->>'code'<>'specialist_examinations_outstanding' then raise exception 'Departure with outstanding examination was accepted: %',r; end if;
 r:=game.execute_text_command('start examination SPEC-PP-002 '||v_plan1||' because assigned examination commenced','scene-specialist-start-test-0001'); if r->>'ok'<>'true' or r->>'plan_status'<>'in_progress' then raise exception 'Examination start failed: %',r; end if;
 r:=game.execute_text_command('complete examination SPEC-PP-001 '||v_plan1||': manager attempting examiner action | unauthorised completion | none','scene-specialist-wrong-examiner-test-0001'); if r->>'code'<>'assigned_examiner_required' then raise exception 'Unassigned examiner completed examination: %',r; end if;
 r:=game.execute_text_command('complete examination SPEC-PP-002 '||v_plan1||': no interpretable profile observed in the examined material | result is inconclusive and does not support identification or exclusion | limited quantity and condition of submitted material constrain interpretation','scene-specialist-complete-test-0001'); if r->>'ok'<>'true' or r->>'plan_status'<>'completed' then raise exception 'Examination completion failed: %',r; end if;
 if (select count(*) from game.scene_examination_records where plan_id=(select id from game.scene_examination_plans where plan_ref=v_plan1))<>1 then raise exception 'Examination result record missing'; end if;
 r:=game.execute_text_command('specialist depart SPEC-PP-002 from KW-SCENE-SPEC because examination completed and specialist work concluded','scene-specialist-depart-test-0001'); if r->>'ok'<>'true' or r->>'attendance_status'<>'departed' then raise exception 'Specialist departure failed: %',r; end if;
 r:=game.execute_text_command('specialist attend SPEC-PP-002 at KW-SCENE-SPEC as DNA: attend for supplementary examination planning','scene-specialist-attend2-test-0001'); if r->>'ok'<>'true' then raise exception 'Second attendance failed: %',r; end if;
 r:=game.execute_text_command('plan examination SPEC-PP-001 for KW-SCENE-SPEC by SPEC-PP-002 in DNA: review additional material | review newly submitted material only | no comparison sample currently available','scene-specialist-plan2-test-0001'); if r->>'ok'<>'true' then raise exception 'Second examination plan failed: %',r; end if; v_plan2:=r->>'plan_ref';
 r:=game.execute_text_command('cancel examination SPEC-PP-001 '||v_plan2||' because new material not yet received','scene-specialist-cancel-plan-test-0001'); if r->>'ok'<>'true' or r->>'plan_status'<>'cancelled' then raise exception 'Examination cancellation failed: %',r; end if;
 r:=game.execute_text_command('specialist depart SPEC-PP-002 from KW-SCENE-SPEC because planned work cancelled','scene-specialist-depart2-test-0001'); if r->>'ok'<>'true' then raise exception 'Second specialist departure failed: %',r; end if;
 r:=game.execute_text_command('release scene SPEC-PP-001 KW-SCENE-SPEC because scene examination is complete and specialists have departed','scene-specialist-release-test-0001'); if r->>'ok'<>'true' or r->>'scene_status'<>'released' then raise exception 'Scene release failed: %',r; end if;
 if (select count(*) from game.scene_examination_events where plan_id in (select id from game.scene_examination_plans where scene_id=v_scene) )<>5 then raise exception 'Examination lifecycle event history incomplete'; end if;
 if (select count(*) from game.scene_specialist_attendances where scene_id=v_scene and status='departed')<>2 then raise exception 'Specialist attendance history incomplete'; end if;
 if exists(select 1 from game.scene_specialist_attendances where scene_id=v_scene and status='attending') then raise exception 'Specialist attendance remained open after departure'; end if;
end;
$test$;
rollback;