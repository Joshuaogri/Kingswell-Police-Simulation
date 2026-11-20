-- Rollback-only NPC court registry, docket and hearing workflow test.
begin;
do $$
declare officer_person uuid:=gen_random_uuid(); accused_person uuid:=gen_random_uuid(); prosecutor_person uuid:=gen_random_uuid(); judge_person uuid:=gen_random_uuid(); clerk_person uuid:=gen_random_uuid();
officer_id uuid:=gen_random_uuid(); case_id uuid:=gen_random_uuid(); arrest_id uuid:=gen_random_uuid(); referral_id uuid:=gen_random_uuid(); prosecutor_id uuid:=gen_random_uuid(); seed_id uuid:=gen_random_uuid(); charge_id uuid:=gen_random_uuid();
r jsonb; courtref text; judgeref text; clerkref text; ccref text; hearingref text; secondhearing text; orderref text; clk timestamptz; dossier jsonb;
begin
update game.simulation_state set current_game_time='2026-11-20 12:00:00+00',time_paused=true,updated_at=now() where id=1; select current_game_time into clk from game.simulation_state where id=1;
insert into game.persons(id,person_ref,given_name,family_name,occupation) values
(officer_person,'P-COURT-T001','Test','Officer','Police'),(accused_person,'P-COURT-T002','Test','Accused','Resident'),(prosecutor_person,'P-COURT-T003','Test','Prosecutor','Prosecutor'),(judge_person,'P-COURT-T004','Test','Judge','Judge'),(clerk_person,'P-COURT-T005','Test','Clerk','Court clerk');
insert into game.police_personnel(id,personnel_ref,person_id,service_number,employment_status,joined_on) values(officer_id,'KWP-COURT-T001',officer_person,'COURT-T001','active','2020-01-01');
insert into game.cases(id,case_ref,case_title,case_type,status,lead_personnel_id,summary) values(case_id,'CASE-COURT-T001','Court test','fictional_test','open',officer_id,'Rollback-only NPC court test');
insert into game.case_assignments(case_id,personnel_id,assignment_role,status) values(case_id,officer_id,'lead_investigator','active');
insert into game.game_commands(id,idempotency_key,command_text,command_type,payload,status) values(seed_id,'kng-court-seed-001','test fixture','test_fixture','{}','completed');
insert into game.prosecutor_profiles(id,prosecutor_ref,person_id,role,status,appointed_by_personnel_id,appointed_at_game_time) values(prosecutor_id,'KWP-COURT-T001',prosecutor_person,'prosecutor','active',officer_id,clk);
insert into game.arrests(id,arrest_ref,case_id,person_id,arresting_personnel_id,arrest_basis,grounds_description,arrest_location,arrested_at_game_time,warnings_or_rights_record,status,source_command_id) values(arrest_id,'KWA-COURT-T001',case_id,accused_person,officer_id,'grounds','Test grounds','Test location',clk,'Recorded','booked',seed_id);
insert into game.prosecution_referrals(id,referral_ref,case_id,arrest_id,person_id,submitted_by_personnel_id,submitted_at_game_time,summary,proposed_charges,evidence_summary,status,source_command_id) values(referral_id,'KWPREF-COURT-T001',case_id,arrest_id,accused_person,officer_id,clk,'Test referral','Test charge','Test evidence','accepted',seed_id);
insert into game.prosecution_reviews(referral_id,prosecutor_id,decision,reason,reviewed_at_game_time,source_command_id) values(referral_id,prosecutor_id,'accepted','Test independent NPC decision',clk,seed_id);
insert into game.formal_charges(id,charge_ref,referral_id,case_id,person_id,prosecutor_id,count_number,offence_code,charge_title,particulars,status,filed_at_game_time,source_command_id) values(charge_id,'KWCHG-COURT-T001',referral_id,case_id,accused_person,prosecutor_id,1,'TEST-01','Test charge','Fictional allegation','filed',clk,seed_id);
r:=game.execute_text_command('court create by KWP-COURT-T001 name "Kingswell Central Court" level district','kng-court-create-001',null,null); if not coalesce((r->>'ok')::boolean,false) then raise exception 'Court creation failed: %',r;end if; courtref:=r->>'court_ref';
r:=game.execute_text_command('court official appoint P-COURT-T004 role judge by KWP-COURT-T001','kng-court-judge-001',null,null); if not coalesce((r->>'ok')::boolean,false) then raise exception 'Judge appointment failed: %',r;end if; judgeref:=r->>'official_ref';
r:=game.execute_text_command('court official appoint P-COURT-T005 role clerk by KWP-COURT-T001','kng-court-clerk-001',null,null); if not coalesce((r->>'ok')::boolean,false) then raise exception 'Clerk appointment failed: %',r;end if; clerkref:=r->>'official_ref';
r:=game.execute_text_command('court case register CASE-COURT-T001 at '||courtref||' by KWP-COURT-T001','kng-court-register-001',null,null); if not coalesce((r->>'ok')::boolean,false) then raise exception 'Court registration failed: %',r;end if; ccref:=r->>'court_case_ref';
r:=game.execute_text_command('court case assign judge '||ccref||' '||judgeref||' by KWP-COURT-T001','kng-court-assign-001',null,null); if not coalesce((r->>'ok')::boolean,false) then raise exception 'Judge assignment failed: %',r;end if;
r:=game.execute_text_command('court hearing schedule '||ccref||' type initial_appearance at "'||clk::text||'" by '||judgeref,'kng-court-schedule-001',null,null); if not coalesce((r->>'ok')::boolean,false) then raise exception 'Hearing schedule failed: %',r;end if; hearingref:=r->>'hearing_ref';
r:=game.execute_text_command('court hearing attendance '||hearingref||' person P-COURT-T002 role accused status present by '||clerkref,'kng-court-attend-001',null,null); if not coalesce((r->>'ok')::boolean,false) then raise exception 'Attendance failed: %',r;end if;
r:=game.execute_text_command('court order issue '||hearingref||' type bail_granted details "NPC court order for test only" by '||judgeref,'kng-court-order-001',null,null); if not coalesce((r->>'ok')::boolean,false) then raise exception 'Court order failed: %',r;end if; orderref:=r->>'order_ref';
r:=game.execute_text_command('court hearing conclude '||hearingref||' outcome "Initial appearance completed" notes "Test hearing concluded" by '||judgeref,'kng-court-conclude-001',null,null); if not coalesce((r->>'ok')::boolean,false) then raise exception 'Hearing conclusion failed: %',r;end if;
r:=game.execute_text_command('court hearing schedule '||ccref||' type case_management at "'||(clk+interval '2 hours')::text||'" by '||judgeref,'kng-court-schedule-002',null,null); if not coalesce((r->>'ok')::boolean,false) then raise exception 'Second hearing schedule failed: %',r;end if; secondhearing:=r->>'hearing_ref';
r:=game.execute_text_command('court hearing adjourn '||secondhearing||' because "NPC witness unavailable" by '||judgeref,'kng-court-adjourn-001',null,null); if not coalesce((r->>'ok')::boolean,false) then raise exception 'Adjournment failed: %',r;end if;
r:=game.execute_text_command('court docket CASE-COURT-T001 by KWP-COURT-T001','kng-court-docket-001',null,null); if not coalesce((r->>'ok')::boolean,false) or jsonb_array_length(r->'court_cases')<>1 then raise exception 'Docket retrieval failed: %',r;end if;
r:=game.execute_text_command('court hearing '||hearingref||' by KWP-COURT-T001','kng-court-hearing-001',null,null); if not coalesce((r->>'ok')::boolean,false) or jsonb_array_length(r#>'{hearing,attendance}')<>1 then raise exception 'Hearing retrieval failed: %',r;end if;
r:=game.execute_text_command('court docket CASE-COURT-T001 by KWP-NOT-ACTOR','kng-court-denied-001',null,null); if coalesce((r->>'ok')::boolean,true) or r->>'code'<>'case_access_required' then raise exception 'Unauthorised docket access was not rejected: %',r;end if;
dossier:=game.get_case_review_dossier('CASE-COURT-T001'); if not coalesce((dossier->>'ok')::boolean,false) or jsonb_array_length(dossier#>'{court,court_cases}')<>1 then raise exception 'Court dossier integration failed';end if;
if not exists(select 1 from game.court_orders where order_ref=orderref) then raise exception 'Court order was not persisted';end if;
if not exists(select 1 from game.court_hearing_events where event_type='court_created' and court_id=(select id from game.courts where court_ref=courtref)) then raise exception 'Court creation event missing';end if;
if (select count(*) from game.court_hearing_events where event_type='official_appointed')<>2 then raise exception 'Official appointment events missing';end if;
if (select current_game_time from game.simulation_state where id=1)<>clk then raise exception 'Fictional clock advanced unexpectedly';end if;
if not (game.execute_text_command('help','kng-court-help-001',null,null)->'available_commands' ? 'create_court') then raise exception 'Court commands missing from help';end if;
begin
 update game.court_orders set order_text='tampered' where order_ref=orderref;
 raise exception 'Court order history unexpectedly allowed mutation';
exception when others then
 if sqlerrm not like 'Court order and hearing event history is append-only%' then raise;end if;
end;
begin
 update game.court_hearing_events set details='{}'::jsonb where court_id=(select id from game.courts where court_ref=courtref);
 raise exception 'Court event history unexpectedly allowed mutation';
exception when others then
 if sqlerrm not like 'Court order and hearing event history is append-only%' then raise;end if;
end;
end $$;
rollback;
