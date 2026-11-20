-- Rollback-only end-to-end account comparison regression.
begin;
do $$
declare op uuid;w1 uuid;w2 uuid;officer uuid;c uuid;i uuid;stmt uuid;turnid uuid;source_cmd uuid;r jsonb;comp text;cmd text;bt timestamptz;
begin
 update game.simulation_state set current_game_time='2026-02-04 12:00:00+00',time_paused=true where id=1; select current_game_time into bt from game.simulation_state where id=1;
 insert into game.persons(person_ref,given_name,family_name) values('TEST-CMP-OFFICER','Comparison','Officer') returning id into op;
 insert into game.persons(person_ref,given_name,family_name) values('TEST-CMP-WITNESS-1','Witness','One') returning id into w1;
 insert into game.persons(person_ref,given_name,family_name) values('TEST-CMP-WITNESS-2','Witness','Two') returning id into w2;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status) values('TEST-CMP-OFFICER',op,'TEST-CMP-SVC','active') returning id into officer;
 insert into game.cases(case_ref,case_title,status,lead_personnel_id,opened_at,case_data) values('TEST-CMP-CASE','Account comparison regression','under_investigation',officer,bt,'{}') returning id into c;
 insert into game.game_commands(idempotency_key,command_text,command_type,payload,status) values('test-cmp-source-001','test fixture source','test_fixture','{}','completed') returning id into source_cmd;
 insert into game.case_interviews(interview_ref,case_id,interviewee_person_id,interviewer_personnel_id,method,purpose,location_description,started_at_game_time,source_command_id) values('TEST-CMP-INTERVIEW',c,w2,officer,'face_to_face','Record the account of the second witness.','Room 2',bt,source_cmd) returning id into i;
 insert into game.case_interview_turns(interview_id,case_id,turn_number,question_text,answer_text,recorded_by_personnel_id,recorded_at_game_time,source_command_id) values(i,c,1,'Where were you at 20:00?','I was at the north entrance at 20:00.',officer,bt,source_cmd) returning id into turnid;
 insert into game.case_witness_statements(case_id,interview_id,witness_person_id,statement_form,statement_text,recorded_by_personnel_id,recorded_at_game_time,source_command_id) values(c,null,w1,'written_signed','I saw the delivery vehicle arrive at the south entrance at 20:00.',officer,bt,source_cmd) returning id into stmt;
 insert into game.evidence_items(evidence_ref,case_id,collected_by_personnel_id,evidence_type,description,collected_at) values('TEST-CMP-EVIDENCE',c,officer,'cctv','CCTV extract showing the vehicle at the north entrance.',bt);
 cmd:='case compare accounts TEST-CMP-CASE first witness_statement '||(select statement_ref from game.case_witness_statements where id=stmt)||' second interview_turn '||(select turn_ref from game.case_interview_turns where id=turnid)||' category location_conflict because "One account places the delivery vehicle at the south entrance while the other places the witness at the north entrance; confirm whether these descriptions refer to the same event." by TEST-CMP-OFFICER';
 r:=game.interpret_text_command(cmd); if r->>'command_type'<>'record_case_account_comparison' then raise exception 'parser failed: %',r; end if;
 r:=game.execute_text_command(cmd,'test-cmp-record-001',null,officer); if not coalesce((r->>'ok')::boolean,false) then raise exception 'record failed: %',r; end if; comp:=r->>'comparison_ref';
 r:=game.execute_text_command(cmd,'test-cmp-record-001',null,officer); if not coalesce((r->>'duplicate')::boolean,false) then raise exception 'record idempotency failed: %',r; end if;
 cmd:='case account comparison assess '||comp||' as unresolved because "The accounts have not yet been reconciled against the complete CCTV timeline." by TEST-CMP-OFFICER';
 r:=game.interpret_text_command(cmd); if r->>'command_type'<>'assess_case_account_comparison' then raise exception 'assessment parser failed: %',r; end if;
 r:=game.execute_text_command(cmd,'test-cmp-assess-001',null,officer); if not coalesce((r->>'ok')::boolean,false) then raise exception 'assessment failed: %',r; end if;
 r:=game.execute_text_command(cmd,'test-cmp-assess-001',null,officer); if not coalesce((r->>'duplicate')::boolean,false) then raise exception 'assessment idempotency failed: %',r; end if;
 cmd:='case account comparison link evidence '||comp||' TEST-CMP-EVIDENCE because "CCTV extract may establish the vehicle location at the relevant time." by TEST-CMP-OFFICER';
 r:=game.interpret_text_command(cmd); if r->>'command_type'<>'link_case_account_comparison_evidence' then raise exception 'evidence parser failed: %',r; end if;
 r:=game.execute_text_command(cmd,'test-cmp-evidence-001',null,officer); if not coalesce((r->>'ok')::boolean,false) then raise exception 'evidence link failed: %',r; end if;
 r:=game.execute_text_command(cmd,'test-cmp-evidence-001',null,officer); if not coalesce((r->>'duplicate')::boolean,false) then raise exception 'evidence idempotency failed: %',r; end if;
 r:=game.execute_text_command('case account comparisons TEST-CMP-CASE','test-cmp-list-001',null,officer);
 if not coalesce((r->>'ok')::boolean,false) or (r->>'comparison_count')::int<>1 or r#>>'{comparisons,0,latest_assessment,disposition}'<>'unresolved' or jsonb_array_length(r#>'{comparisons,0,linked_evidence}')<>1 then raise exception 'retrieval failed: %',r; end if;
 r:=game.execute_text_command('help','test-cmp-help-001',null,officer); if not (r->'available_commands' @> '["record_case_account_comparison","assess_case_account_comparison","link_case_account_comparison_evidence","get_case_account_comparisons"]'::jsonb) then raise exception 'help failed: %',r; end if;
 begin update game.case_account_comparisons set discrepancy_description='tampered' where comparison_ref=comp; raise exception 'comparison mutation unexpectedly succeeded'; exception when others then if sqlerrm='comparison mutation unexpectedly succeeded' then raise; end if; end;
 begin delete from game.case_account_comparison_assessments where comparison_id=(select id from game.case_account_comparisons where comparison_ref=comp); raise exception 'assessment deletion unexpectedly succeeded'; exception when others then if sqlerrm='assessment deletion unexpectedly succeeded' then raise; end if; end;
 if (select current_game_time from game.simulation_state where id=1)<>bt then raise exception 'clock advanced'; end if;
 raise notice 'PASS: source matching, idempotency, assessments, evidence links, retrieval, help, immutability and unchanged fictional time';
end $$;
rollback;
