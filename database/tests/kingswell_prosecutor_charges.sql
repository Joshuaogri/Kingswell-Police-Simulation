-- Rollback-only independent prosecutor and formal charge regression.
begin;
do $$
declare op uuid:=gen_random_uuid(); sp uuid:=gen_random_uuid(); pp uuid:=gen_random_uuid(); oi uuid:=gen_random_uuid(); ci uuid:=gen_random_uuid(); ai uuid:=gen_random_uuid(); seed uuid; r jsonb; rr text; pr text; clk timestamptz;
begin
insert into game.persons(id,person_ref,given_name,family_name,occupation) values(op,'P-JUST-T101','Test','Officer','Police'),(sp,'P-JUST-T102','Test','Suspect','Resident'),(pp,'P-JUST-T103','Test','Prosecutor','Prosecutor');
insert into game.police_personnel(id,personnel_ref,person_id,service_number,employment_status,joined_on) values(oi,'KWP-JUST-T101',op,'JUST-T101','active','2020-01-01');
insert into game.cases(id,case_ref,case_title,case_type,status,lead_personnel_id,summary) values(ci,'CASE-JUST-T101','Justice workflow test','test','open',oi,'Rollback test');
insert into game.case_assignments(case_id,personnel_id,assignment_role,status) values(ci,oi,'lead_investigator','active'); insert into game.case_persons(case_id,person_id,case_role) values(ci,sp,'suspect');
update game.simulation_state set current_game_time='2026-11-20 12:00:00+00',time_paused=true,updated_at=now() where id=1; select current_game_time into clk from game.simulation_state where id=1;
r:=game.execute_text_command('help','kng-just-seed-101',null,null); seed:=(r->>'command_id')::uuid;
insert into game.arrests(id,arrest_ref,case_id,person_id,arresting_personnel_id,arrest_basis,grounds_description,arrest_location,arrested_at_game_time,warnings_or_rights_record,status,source_command_id) values(ai,'KWA-JUST-T101',ci,sp,oi,'grounds','Test grounds','Test location',clk,'Recorded','booked',seed);
r:=game.execute_text_command('prosecution refer CASE-JUST-T101 arrest KWA-JUST-T101 by KWP-JUST-T101 summary "Test referral" charges "Proposed offence" evidence "Evidence schedule"','kng-just-ref-101',null,oi); if not coalesce((r->>'ok')::boolean,false) then raise exception 'Referral: %',r; end if; rr:=r->>'referral_ref';
r:=game.execute_text_command('prosecutor appoint P-JUST-T103 role prosecutor by KWP-JUST-T101','kng-just-appoint-101',null,oi); if not coalesce((r->>'ok')::boolean,false) then raise exception 'Appointment: %',r; end if; pr:=r->>'prosecutor_ref';
r:=game.execute_text_command('prosecutor review '||rr||' set accepted by '||pr||' because "Evidence supports filing for court determination"','kng-just-review-101',null,null); if not coalesce((r->>'ok')::boolean,false) then raise exception 'Review: %',r; end if;
r:=game.execute_text_command('prosecution charge file '||rr||' by '||pr||' count 1 offence THEFT-01 title "Theft" particulars "Alleged taking of property belonging to another person."','kng-just-charge-101',null,null); if not coalesce((r->>'ok')::boolean,false) then raise exception 'Charge: %',r; end if;
r:=game.execute_text_command('prosecution charges '||rr||' by '||pr,'kng-just-list-101',null,null); if not coalesce((r->>'ok')::boolean,false) or jsonb_array_length(r->'charges')<>1 then raise exception 'Retrieval: %',r; end if;
if (select current_game_time from game.simulation_state where id=1)<>clk then raise exception 'Clock advanced'; end if;
end $;
rollback;