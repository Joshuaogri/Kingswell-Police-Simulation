-- Rollback-only NPC-to-NPC prosecution/defence disclosure integration test.
begin;
do $$
declare
 officer_person uuid:=gen_random_uuid(); suspect_person uuid:=gen_random_uuid(); prosecutor_person uuid:=gen_random_uuid(); counsel_person uuid:=gen_random_uuid();
 officer_id uuid:=gen_random_uuid(); case_id uuid:=gen_random_uuid(); arrest_id uuid:=gen_random_uuid(); referral_id uuid:=gen_random_uuid(); prosecutor_id uuid:=gen_random_uuid();
 seed_id uuid:=gen_random_uuid(); charge_id uuid:=gen_random_uuid();
 r jsonb; counsel_ref text; pro_pkg text; def_pkg text; pro_item text; def_item text; clk timestamptz; dossier_result jsonb;
begin
 update game.simulation_state set current_game_time='2026-11-20 12:00:00+00',time_paused=true,updated_at=now() where id=1;
 select current_game_time into clk from game.simulation_state where id=1;
 insert into game.persons(id,person_ref,given_name,family_name,occupation) values
 (officer_person,'P-DISC-T001','Test','Officer','Police'),(suspect_person,'P-DISC-T002','Test','Suspect','Resident'),
 (prosecutor_person,'P-DISC-T003','Test','Prosecutor','Prosecutor'),(counsel_person,'P-DISC-T004','Test','Counsel','Defence counsel');
 insert into game.police_personnel(id,personnel_ref,person_id,service_number,employment_status,joined_on) values(officer_id,'KWP-DISC-T001',officer_person,'DISC-T001','active','2020-01-01');
 insert into game.cases(id,case_ref,case_title,case_type,status,lead_personnel_id,summary) values(case_id,'CASE-DISC-T001','Disclosure test','fictional_test','open',officer_id,'Rollback-only NPC disclosure test');
 insert into game.case_assignments(case_id,personnel_id,assignment_role,status) values(case_id,officer_id,'lead_investigator','active');
 insert into game.game_commands(id,idempotency_key,command_text,command_type,payload,status) values(seed_id,'kng-disclosure-seed-001','test fixture','test_fixture','{}','completed');
 insert into game.prosecutor_profiles(id,prosecutor_ref,person_id,role,status,appointed_by_personnel_id,appointed_at_game_time) values(prosecutor_id,'KWP-DISC-T001',prosecutor_person,'prosecutor','active',officer_id,clk);
 insert into game.arrests(id,arrest_ref,case_id,person_id,arresting_personnel_id,arrest_basis,grounds_description,arrest_location,arrested_at_game_time,warnings_or_rights_record,status,source_command_id) values(arrest_id,'KWA-DISC-T001',case_id,suspect_person,officer_id,'grounds','Test grounds','Test location',clk,'Recorded','booked',seed_id);
 insert into game.prosecution_referrals(id,referral_ref,case_id,arrest_id,person_id,submitted_by_personnel_id,submitted_at_game_time,summary,proposed_charges,evidence_summary,status,source_command_id) values(referral_id,'KWPREF-DISC-T001',case_id,arrest_id,suspect_person,officer_id,clk,'Test referral','Test charge','Test evidence','accepted',seed_id);
 insert into game.prosecution_reviews(referral_id,prosecutor_id,decision,reason,reviewed_at_game_time,source_command_id) values(referral_id,prosecutor_id,'accepted','Test independent NPC decision',clk,seed_id);
 insert into game.formal_charges(id,charge_ref,referral_id,case_id,person_id,prosecutor_id,count_number,offence_code,charge_title,particulars,status,filed_at_game_time,source_command_id) values(charge_id,'KWCHG-DISC-T001',referral_id,case_id,suspect_person,prosecutor_id,1,'TEST-01','Test charge','Fictional allegation','filed',clk,seed_id);
 r:=game.execute_text_command('defence counsel assign CASE-DISC-T001 person P-DISC-T004 by KWP-DISC-T001','kng-disclosure-counsel-001',null,null);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Counsel assignment failed: %',r;end if; counsel_ref:=r->>'counsel_ref';
 r:=game.execute_text_command('disclosure prosecution create KWPREF-DISC-T001 by KWP-DISC-T001 title "Initial prosecution disclosure"','kng-disclosure-prosecution-001',null,null);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Prosecution package failed: %',r;end if; pro_pkg:=r->>'package_ref';
 r:=game.execute_text_command('disclosure defence create CASE-DISC-T001 by '||counsel_ref||' title "Defence disclosure"','kng-disclosure-defence-001',null,null);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Defence package failed: %',r;end if; def_pkg:=r->>'package_ref';
 r:=game.execute_text_command('disclosure item add '||pro_pkg||' category other source SOURCE-001 title "Fictional case record" notes "NPC-generated material" by KWP-DISC-T001','kng-disclosure-item-pro-001',null,null);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Prosecution item failed: %',r;end if; pro_item:=r->>'item_ref';
 r:=game.execute_text_command('disclosure item add '||def_pkg||' category other source SOURCE-002 title "Defence account" notes "NPC defence material" by '||counsel_ref,'kng-disclosure-item-def-001',null,null);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Defence item failed: %',r;end if; def_item:=r->>'item_ref';
 r:=game.execute_text_command('disclosure item set '||def_item||' treatment redacted because "NPC identity detail removed" by '||counsel_ref,'kng-disclosure-redact-001',null,null);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Redaction failed: %',r;end if;
 r:=game.execute_text_command('disclosure item set '||pro_item||' treatment withheld because "NPC-generated material pending in-game review" by KWP-DISC-T001','kng-disclosure-withhold-001',null,null);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Withholding failed: %',r;end if;
 r:=game.execute_text_command('disclosure serve '||pro_pkg||' to P-DISC-T004 by KWP-DISC-T001','kng-disclosure-serve-pro-001',null,null);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Prosecution service failed: %',r;end if;
 r:=game.execute_text_command('disclosure acknowledge '||pro_pkg||' by KWDC-NOT-RECIPIENT','kng-disclosure-wrong-recipient-001',null,null);
 if coalesce((r->>'ok')::boolean,true) or r->>'code'<>'intended_defence_recipient_required' then raise exception 'Wrong recipient was not rejected: %',r;end if;
 r:=game.execute_text_command('disclosure acknowledge '||pro_pkg||' by '||counsel_ref,'kng-disclosure-ack-pro-001',null,null);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Prosecution receipt failed: %',r;end if;
 r:=game.execute_text_command('disclosure serve '||def_pkg||' to P-DISC-T003 by '||counsel_ref,'kng-disclosure-serve-def-001',null,null);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Defence service failed: %',r;end if;
 r:=game.execute_text_command('disclosure acknowledge '||def_pkg||' by KWP-DISC-T001','kng-disclosure-ack-def-001',null,null);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Defence receipt failed: %',r;end if;
 r:=game.execute_text_command('disclosure packages CASE-DISC-T001 by '||counsel_ref,'kng-disclosure-list-001',null,null);
 if not coalesce((r->>'ok')::boolean,false) or jsonb_array_length(r->'packages')<>2 then raise exception 'Package listing failed: %',r;end if;
 r:=game.execute_text_command('disclosure packages CASE-DISC-T001 by KWP-DISC-T001','kng-disclosure-list-prosecutor-001',null,null);
 if not coalesce((r->>'ok')::boolean,false) or jsonb_array_length(r->'packages')<>2 then raise exception 'Case-linked prosecutor listing failed: %',r;end if;
 r:=game.execute_text_command('disclosure package '||pro_pkg||' by KWP-DISC-T001','kng-disclosure-view-prosecutor-001',null,null);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Case-linked prosecutor package view failed: %',r;end if;
 r:=game.execute_text_command('disclosure package '||pro_pkg||' by '||counsel_ref,'kng-disclosure-view-001',null,null);
 if not coalesce((r->>'ok')::boolean,false) or jsonb_array_length(r#>'{package,items}')<>1 then raise exception 'Package view failed: %',r;end if;
 dossier_result:=game.get_case_review_dossier('CASE-DISC-T001');
 if not coalesce((dossier_result->>'ok')::boolean,false) or jsonb_array_length(dossier_result#>'{disclosure,packages}')<>2 then raise exception 'Dossier disclosure integration failed';end if;
 if not exists(select 1 from game.disclosure_receipts where package_id=(select id from game.disclosure_packages where package_ref=pro_pkg) and acknowledged_at_game_time is not null) then raise exception 'Prosecution acknowledgement missing';end if;
 if not exists(select 1 from game.disclosure_items where item_ref=def_item and treatment='redacted') then raise exception 'Redaction treatment missing';end if;
 if not exists(select 1 from game.disclosure_items where item_ref=pro_item and treatment='withheld') then raise exception 'Withholding treatment missing';end if;
 if (select current_game_time from game.simulation_state where id=1)<>clk then raise exception 'Fictional clock advanced unexpectedly';end if;
end $$;
rollback;
