-- Kingswell case task workflow regression.
-- Run against the connected test database. Every fixture and clock change rolls back.
begin;
do $$
declare v_person uuid; v_personnel uuid; v_supervisor_person uuid; v_supervisor_personnel uuid; v_case uuid; v_create jsonb; v_update jsonb; v_read jsonb; v_ref text; v_submission jsonb; v_review jsonb;
begin
 update game.simulation_state set current_game_time='2026-01-01 09:00:00+00',time_paused=true where id=1;
 insert into game.persons(person_ref,given_name,family_name) values('TEST-KWT-PERSON','Test','Investigator') returning id into v_person;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status) values('TEST-KWT-OFFICER',v_person,'TEST-KWT-SN','active') returning id into v_personnel;
 insert into game.persons(person_ref,given_name,family_name) values('TEST-KWT-SUPERVISOR-PERSON','Test','Supervisor') returning id into v_supervisor_person;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status) values('TEST-KWT-SUPERVISOR',v_supervisor_person,'TEST-KWT-SUPERVISOR-SN','active') returning id into v_supervisor_personnel;
 insert into game.cases(case_ref,case_title,status,opened_at,case_data) values('TEST-KWT-CASE','Task workflow test','under_investigation','2026-01-01 08:00:00+00','{}') returning id into v_case;
 insert into game.case_assignments(case_id,personnel_id,assignment_role,status) values(v_case,v_supervisor_personnel,'supervisor','active');
 v_create:=game.create_case_task('TEST-KWT-CASE','witness_enquiry','Interview identified witness','Confirm account and availability','high','TEST-KWT-OFFICER','TEST-KWT-OFFICER','2026-01-02 09:00:00+00',null);
 if not coalesce((v_create->>'ok')::boolean,false) then raise exception 'Create task failed: %',v_create; end if;
 v_ref:=v_create->>'task_ref';
 v_update:=game.update_case_task(v_ref,'in_progress',null,null,'TEST-KWT-OFFICER',null);
 if not coalesce((v_update->>'ok')::boolean,false) or v_update->>'status'<>'in_progress' then raise exception 'Task update failed: %',v_update; end if;
 v_submission:=game.submit_case_task(v_ref,'TEST-KWT-OFFICER','Interview completed; statement recorded.',null);
 if not coalesce((v_submission->>'ok')::boolean,false) then raise exception 'Task completion submission failed: %',v_submission; end if;
 v_review:=game.review_case_task_submission(v_submission->>'submission_ref','accepted','Supervisor reviewed the submitted completion record.','TEST-KWT-SUPERVISOR',null);
 if not coalesce((v_review->>'ok')::boolean,false) or v_review#>>'{task_result,status}'<>'completed' then raise exception 'Supervisor review failed: %',v_review; end if;
 v_read:=game.get_case_tasks('TEST-KWT-CASE',null,10);
 if (v_read->>'count')::int<>1 or jsonb_array_length(v_read->'tasks'->0->'history')<4 then raise exception 'Task history mismatch: %',v_read; end if;
 v_update:=game.update_case_task(v_ref,'planned',null,null,'TEST-KWT-OFFICER',null);
 if coalesce((v_update->>'ok')::boolean,true) or v_update->>'code'<>'task_final' then raise exception 'Completed task unexpectedly reopened: %',v_update; end if;
 if (select current_game_time from game.simulation_state where id=1) <> '2026-01-01 09:00:00+00'::timestamptz then raise exception 'Task workflow changed fictional time'; end if;
 raise notice 'PASS: create, assign, progress, submit, supervisor review, immutable final state, event history, and no clock advancement';
end $$;
rollback;
