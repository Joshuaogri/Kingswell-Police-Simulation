-- Rollback-only end-to-end suspect interview regression.
begin;
do $$
declare p1 uuid;p2 uuid;officer uuid;c uuid;r jsonb;iref text;tref text;before_time timestamptz;cmd text;n integer;
begin
 update game.simulation_state set current_game_time='2026-02-04 11:00:00+00',time_paused=true where id=1;
 select current_game_time into before_time from game.simulation_state where id=1;
 insert into game.persons(person_ref,given_name,family_name) values('TEST-SUS-INT-OFFICER','Interview','Officer') returning id into p1;
 insert into game.persons(person_ref,given_name,family_name) values('TEST-SUS-INT-PERSON','Named','Suspect') returning id into p2;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status) values('TEST-SUS-INT-OFFICER',p1,'TEST-SUS-INT-SVC','active') returning id into officer;
 insert into game.cases(case_ref,case_title,status,opened_at,case_data,lead_personnel_id) values('TEST-SUS-INT-CASE','Suspect interview regression','under_investigation',before_time,'{}',officer) returning id into c;
 insert into game.case_persons(case_id,person_id,case_role,notes) values(c,p2,'suspect','Rollback test suspect fixture.');
 cmd:='case interview record TEST-SUS-INT-CASE with TEST-SUS-INT-PERSON by TEST-SUS-INT-OFFICER method face_to_face purpose "Record the suspect account of the reported event." location "Interview Room 3" notes "Regression fixture"';
 r:=game.execute_text_command(cmd,'test-sus-start-001',null,officer); if not coalesce((r->>'ok')::boolean,false) then raise exception 'interview start failed: %',r; end if; iref:=r->>'interview_ref';
 cmd:='case suspect interview classify '||iref||' because "Existing case enquiries identify this person as a suspect for investigative questioning." by TEST-SUS-INT-OFFICER';
 r:=game.interpret_text_command(cmd); if r->>'command_type'<>'classify_case_suspect_interview' then raise exception 'classify parser failed: %',r; end if;
 r:=game.execute_text_command(cmd,'test-sus-classify-001',null,officer); if not coalesce((r->>'ok')::boolean,false) then raise exception 'classify failed: %',r; end if;
 r:=game.execute_text_command(cmd,'test-sus-classify-001',null,officer); if not coalesce((r->>'duplicate')::boolean,false) then raise exception 'classification idempotency failed: %',r; end if;
 select count(*) into n from game.case_suspect_interview_records where interview_id=(select id from game.case_interviews where interview_ref=iref); if n<>1 then raise exception 'classification duplicate record'; end if;
 cmd:='case interview turn '||iref||' by TEST-SUS-INT-OFFICER question "Can you explain your presence near the loading entrance?" answer "I was there to collect a package, but I did not enter the warehouse."';
 r:=game.execute_text_command(cmd,'test-sus-turn-001',null,officer); if not coalesce((r->>'ok')::boolean,false) then raise exception 'turn failed: %',r; end if; tref:=r->>'turn_ref';
 cmd:='case suspect interview assess '||iref||' turn '||tref||' as qualified_response because "The answer accepts presence nearby but disputes entry into the warehouse; preserve the distinction without treating it as proof." by TEST-SUS-INT-OFFICER';
 r:=game.interpret_text_command(cmd); if r->>'command_type'<>'assess_case_suspect_interview_turn' then raise exception 'assessment parser failed: %',r; end if;
 r:=game.execute_text_command(cmd,'test-sus-assess-001',null,officer); if not coalesce((r->>'ok')::boolean,false) then raise exception 'assessment failed: %',r; end if;
 r:=game.execute_text_command(cmd,'test-sus-assess-001',null,officer); if not coalesce((r->>'duplicate')::boolean,false) then raise exception 'assessment idempotency failed: %',r; end if;
 r:=game.execute_text_command('case suspect interview review '||iref,'test-sus-review-001',null,officer); if not coalesce((r->>'ok')::boolean,false) or (r->>'turn_count')::int<>1 or r#>>'{turns,0,assessments,0,classification}'<>'qualified_response' then raise exception 'review failed: %',r; end if;
 begin update game.case_suspect_interview_assessments set assessment_reason='tampered' where interview_id=(select id from game.case_interviews where interview_ref=iref); raise exception 'assessment mutation unexpectedly succeeded'; exception when others then if sqlerrm='assessment mutation unexpectedly succeeded' then raise; end if; end;
 r:=game.execute_text_command('help','test-sus-help-001',null,officer); if not (r->'available_commands' @> '["classify_case_suspect_interview","assess_case_suspect_interview_turn","get_case_suspect_interview_review"]'::jsonb) then raise exception 'help registration failed: %',r; end if;
 if (select current_game_time from game.simulation_state where id=1)<>before_time then raise exception 'suspect interview actions advanced fictional time'; end if;
 raise notice 'PASS: parser/executor, suspect classification, idempotency, Q&A, response assessment, review, append-only history, help registration and unchanged fictional clock';
end $$;
rollback;
