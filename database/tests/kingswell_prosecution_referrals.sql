-- Rollback-only end-to-end prosecution referral and decision regression.
begin;
do $$
declare
 p1 uuid:=gen_random_uuid(); p2 uuid:=gen_random_uuid(); n1 uuid:=gen_random_uuid(); c uuid:=gen_random_uuid(); a uuid:=gen_random_uuid();
 r jsonb; ref text; h jsonb; seedcmd uuid;
begin
 insert into game.persons(id,person_ref,given_name,family_name,occupation) values
 (p1,'P-PR-T301','Test','Officer','Police'),(p2,'P-PR-T302','Test','Suspect','Resident');
 insert into game.police_personnel(id,personnel_ref,person_id,service_number,employment_status,joined_on)
 values(n1,'KWP-PR-T301',p1,'PR-T301','active','2020-01-01');
 insert into game.cases(id,case_ref,case_title,case_type,status,lead_personnel_id,summary)
 values(c,'CASE-PR-T301','Prosecution referral test','test','open',n1,'Temporary rollback test');
 insert into game.case_assignments(case_id,personnel_id,assignment_role,status) values(c,n1,'lead_investigator','active');
 insert into game.case_persons(case_id,person_id,case_role) values(c,p2,'suspect');
 update game.simulation_state set current_game_time='2026-11-20 11:00:00+00',time_paused=true,updated_at=now() where id=1;
 h:=game.execute_text_command('help','kng-pros-seed-301',null,null); seedcmd:=(h->>'command_id')::uuid;
 insert into game.arrests(id,arrest_ref,case_id,person_id,arresting_personnel_id,arrest_basis,grounds_description,arrest_location,arrested_at_game_time,warnings_or_rights_record,status,source_command_id)
 values(a,'KWA-PR-T301',c,p2,n1,'grounds','Test grounds','Test location','2026-11-20 10:00:00+00','Recorded','booked',seedcmd);
 r:=game.execute_text_command('prosecution refer CASE-PR-T301 arrest KWA-PR-T301 by KWP-PR-T301 summary "Test referral summary" charges "Test proposed charge" evidence "Test evidence schedule"','kng-pros-ref-test-301',null,n1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Referral failed: %',r; end if;
 ref:=r->>'referral_ref';
 r:=game.execute_text_command('prosecution decision '||ref||' set returned by KWP-PR-T301 because "Additional enquiries required"','kng-pros-dec-test-301',null,n1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Decision failed: %',r; end if;
 r:=game.execute_text_command('prosecution referrals CASE-PR-T301 by KWP-PR-T301','kng-pros-get-test-301',null,n1);
 if not coalesce((r->>'ok')::boolean,false) or jsonb_array_length(r->'referrals')<>1 or r#>>'{referrals,0,status}'<>'returned' then raise exception 'Retrieval failed: %',r; end if;
 h:=game.execute_text_command('help','kng-pros-help-test-301',null,null);
 if not (h->'available_commands' ? 'submit_prosecution_referral') or not (h->'available_commands' ? 'decide_prosecution_referral') then raise exception 'Help registration failed: %',h; end if;
 if (select current_game_time from game.simulation_state where id=1)<>'2026-11-20 11:00:00+00'::timestamptz then raise exception 'Prosecution workflow unexpectedly advanced clock'; end if;
end $$;
rollback;