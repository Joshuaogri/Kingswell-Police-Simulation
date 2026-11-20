-- Kingswell end-to-end forensic laboratory regression.
-- Seeded fictional personnel, evidence, qualifications and records are rolled back.
begin;
do $test$
declare
 p1 uuid; p2 uuid; p3 uuid; p4 uuid;
 pp1 uuid; pp2 uuid; pp3 uuid; pp4 uuid; unit_id uuid;
 case_id uuid; evidence_id uuid;
 r jsonb; method_ref text := 'KW-TEST-METHOD-DNA'; v_request_ref text;
 v_submission_ref text; v_examination_ref text; v_finding_ref text; v_report_ref text;
begin
 r:=game.submit_command('Initialize forensic laboratory test clock','initialize_clock',
   '{"start_at":"2036-05-12T09:00:00Z"}'::jsonb,'forensic-lab-clock-test-0001',null,null);
 if r->>'ok'<>'true' then raise exception 'Clock initialization failed: %',r; end if;

 insert into game.persons(person_ref,given_name,family_name)
 values ('FL-PERSON-001','Request','Officer') returning id into p1;
 insert into game.persons(person_ref,given_name,family_name)
 values ('FL-PERSON-002','Laboratory','Receiver') returning id into p2;
 insert into game.persons(person_ref,given_name,family_name)
 values ('FL-PERSON-003','Qualified','Examiner') returning id into p3;
 insert into game.persons(person_ref,given_name,family_name)
 values ('FL-PERSON-004','Independent','Reviewer') returning id into p4;
 insert into game.police_units(unit_ref,unit_name,unit_type,status)
 values ('FL-TEST-UNIT','Forensic Laboratory Test Unit','specialist','active')
 returning id into unit_id;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status)
 values ('FL-PP-001',p1,'FL-SN-001',unit_id,'active') returning id into pp1;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status)
 values ('FL-PP-002',p2,'FL-SN-002',unit_id,'active') returning id into pp2;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status)
 values ('FL-PP-003',p3,'FL-SN-003',unit_id,'active') returning id into pp3;
 insert into game.police_personnel(personnel_ref,person_id,service_number,current_unit_id,employment_status)
 values ('FL-PP-004',p4,'FL-SN-004',unit_id,'active') returning id into pp4;

 insert into game.personnel_qualifications(personnel_id,qualification_code,qualification_name,awarded_on,expires_on,status)
 values (pp3,'DNA','DNA','2035-01-01','2037-01-01','valid'),
        (pp4,'DNA','DNA','2035-01-01','2037-01-01','valid');

 insert into game.cases(case_ref,case_title,case_type,status,lead_personnel_id,opened_at,summary,case_data)
 values ('KW-CASE-FL-TEST','Forensic Laboratory Regression','test','open',pp1,
         '2036-05-12T09:00:00Z','Temporary end-to-end laboratory test','{}'::jsonb)
 returning id into case_id;

 insert into game.evidence_items(evidence_ref,case_id,collected_by_personnel_id,evidence_type,
   description,collected_at,collection_location,current_status,storage_location,metadata)
 values ('KW-EVID-FL-TEST',case_id,pp1,'biological_sample','Sealed fictional reference swab',
   '2036-05-12T09:00:00Z','Test scene','in_storage','Evidence locker A','{"test_fixture":true}'::jsonb)
 returning id into evidence_id;

 r:=game.execute_forensic_action(null,'register_forensic_method',
   jsonb_build_object('personnel_ref','FL-PP-001','method_ref',method_ref,'discipline','DNA',
   'method_name','Validated DNA screening','method_version','1.0',
   'validation_status','verification_pending','authorised_scope','Test reference swabs only',
   'known_limitations','Synthetic test material only'),pp1);
 if r->>'ok'<>'true' then raise exception 'Method registration failed: %',r; end if;

 r:=game.execute_forensic_action(null,'validate_forensic_method',
   jsonb_build_object('personnel_ref','FL-PP-004','method_ref',method_ref,
   'decision','validated','notes','Independent qualification-backed validation for regression fixture.'),pp4);
 if r->>'ok'<>'true' then raise exception 'Method validation failed: %',r; end if;

 r:=game.execute_forensic_action(null,'submit_forensic_request',
   jsonb_build_object('personnel_ref','FL-PP-001','case_ref','KW-CASE-FL-TEST',
   'evidence_ref','KW-EVID-FL-TEST','discipline','DNA',
   'question','Is a DNA profile recoverable from the submitted test material?',
   'scope','Examine the submitted swab only.','legal_basis','Fictional test authority',
   'priority',2,'context','Synthetic regression evidence.'),pp1);
 if r->>'ok'<>'true' then raise exception 'Forensic request failed: %',r; end if;
 v_request_ref:=r->>'request_ref';

 r:=game.execute_forensic_action(null,'triage_forensic_request',
   jsonb_build_object('personnel_ref','FL-PP-001','request_ref',v_request_ref,
   'decision','accept','notes','Accepted for test workflow.'),pp1);
 if r->>'ok'<>'true' then raise exception 'Request triage failed: %',r; end if;

 r:=game.execute_forensic_action(null,'receive_forensic_submission',
   jsonb_build_object('personnel_ref','FL-PP-001','request_ref',v_request_ref,
   'evidence_ref','KW-EVID-FL-TEST','receiver_ref','FL-PP-002',
   'from_location','Evidence locker A','lab_location','Test laboratory intake',
   'condition','Packaging intact','seal_condition','intact','discrepancy','none'),pp1);
 if r->>'ok'<>'true' then raise exception 'Laboratory receipt failed: %',r; end if;
 v_submission_ref:=r->>'submission_ref';

 r:=game.execute_forensic_action(null,'assign_forensic_examiner',
   jsonb_build_object('personnel_ref','FL-PP-001','request_ref',v_request_ref,
   'submission_ref',v_submission_ref,'method_ref',method_ref,'examiner_ref','FL-PP-003',
   'propositions','The material may or may not yield a usable profile.'),pp1);
 if r->>'ok'<>'true' then raise exception 'Examiner assignment failed: %',r; end if;
 v_examination_ref:=r->>'examination_ref';

 r:=game.execute_forensic_action(null,'start_forensic_examination',
   jsonb_build_object('personnel_ref','FL-PP-003','examination_ref',v_examination_ref),pp3);
 if r->>'ok'<>'true' then raise exception 'Examination start failed: %',r; end if;

 r:=game.execute_forensic_action(null,'record_forensic_findings',
   jsonb_build_object('personnel_ref','FL-PP-003','examination_ref',v_examination_ref,
   'observations','A synthetic test profile was detected.',
   'interpretation','The test material yielded a profile suitable for the exercise.',
   'propositions','Profile recovery is possible from this synthetic material.',
   'limitations','No comparison sample is supplied; no source attribution is possible.',
   'outcome','inconclusive'),pp3);
 if r->>'ok'<>'true' then raise exception 'Finding record failed: %',r; end if;
 v_finding_ref:=r->>'finding_ref';

 r:=game.execute_forensic_action(null,'review_forensic_findings',
   jsonb_build_object('personnel_ref','FL-PP-003','finding_ref',v_finding_ref,
   'review_type','technical','decision','approved','notes','Self-review must not be permitted.'),pp3);
 if r->>'code'<>'review_invalid' then raise exception 'Examiner self-review was not rejected: %',r; end if;

 r:=game.execute_forensic_action(null,'review_forensic_findings',
   jsonb_build_object('personnel_ref','FL-PP-004','finding_ref',v_finding_ref,
   'review_type','independent','decision','approved',
   'notes','Independent qualified review completed; limitations retained.'),pp4);
 if r->>'ok'<>'true' then raise exception 'Independent review failed: %',r; end if;

 r:=game.execute_forensic_action(null,'issue_forensic_report',
   jsonb_build_object('personnel_ref','FL-PP-001','request_ref',v_request_ref,
   'summary','Synthetic test report issued.',
   'report_body','Findings are inconclusive and limited to the synthetic material; no legal conclusion is drawn.'),pp1);
 if r->>'ok'<>'true' then raise exception 'Report issue failed: %',r; end if;
 v_report_ref:=r->>'report_ref';

 if (select fr.status from game.forensic_requests fr where fr.v_request_ref=v_request_ref)<>'reported' then
   raise exception 'Request did not reach reported state';
 end if;
 if (select fs.status from game.forensic_lab_submissions fs where fs.v_submission_ref=v_submission_ref)<>'received' then
   raise exception 'Submission did not reach received state';
 end if;
 if (select fe.status from game.forensic_examinations fe where fe.v_examination_ref=v_examination_ref)<>'completed' then
   raise exception 'Examination did not reach completed state';
 end if;
 if (select frp.status from game.forensic_reports frp where frp.v_report_ref=v_report_ref)<>'issued' then
   raise exception 'Report was not issued';
 end if;
 if not exists(select 1 from game.evidence_transfers et where et.evidence_id=evidence_id
               and et.from_personnel_id=pp1 and to_personnel_id=pp2) then
   raise exception 'Laboratory custody transfer missing';
 end if;
end;
$test$;
rollback;