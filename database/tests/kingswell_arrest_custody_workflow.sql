-- Rollback-only personnel-backed arrest, transport, booking and custody regression.
begin;
do $$
declare
 p1 uuid:=gen_random_uuid(); p2 uuid:=gen_random_uuid(); p3 uuid:=gen_random_uuid();
 n1 uuid:=gen_random_uuid(); n2 uuid:=gen_random_uuid(); c uuid:=gen_random_uuid();
 r jsonb; a text; cu text; ev uuid; d jsonb; cmd text; h jsonb;
begin
 if (select current_game_time from game.simulation_state where id=1) is not null then raise exception 'Expected uninitialized clock baseline'; end if;
 insert into game.persons(id,person_ref,given_name,family_name,occupation) values
 (p1,'P-TAR-901','Temporary','Lead','Police'),(p2,'P-TAR-902','Temporary','Transport','Police'),(p3,'P-TAR-903','Test','Person','Resident');
 insert into game.police_personnel(id,personnel_ref,person_id,service_number,employment_status,joined_on) values
 (n1,'KWP-TAR-901',p1,'TAR-901','active','2020-01-01'),(n2,'KWP-TAR-902',p2,'TAR-902','active','2021-01-01');
 insert into game.cases(id,case_ref,case_title,case_type,status,lead_personnel_id,summary) values(c,'CASE-TAR-901','Arrest custody E2E','test','open',n1,'Temporary fixture');
 insert into game.case_assignments(case_id,personnel_id,assignment_role,status) values(c,n1,'lead_investigator','active'),(c,n2,'investigator','active');
 insert into game.case_persons(case_id,person_id,case_role) values(c,p3,'suspect');
 update game.simulation_state set current_game_time='2026-11-20 10:00:00+00',time_paused=true,updated_at=now() where id=1;

 cmd:='arrest '||'execute CASE-TAR-901 person P-TAR-903 by KWP-TAR-901 basis grounds location "Market Street" grounds "Case enquiry recorded in case file" force "none" injuries "none" warnings "Caution delivered and recorded"';
 r:=game.execute_text_command(cmd,'kng-tar-901',null,n1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Arrest execution failed: %',r; end if; a:=r->>'arrest_ref';
 r:=game.execute_text_command(cmd,'kng-tar-901',null,n1);
 if not coalesce((r->>'duplicate')::boolean,false) or r->>'arrest_ref'<>a then raise exception 'Arrest idempotency failed: %',r; end if;
 begin update game.arrest_events set event_data='{}'::jsonb where arrest_id=(select id from game.arrests where arrest_ref=a); raise exception 'Arrest event update unexpectedly succeeded';
 exception when others then if sqlerrm not like 'Arrest and custody history is append-only%' then raise; end if; end;

 r:=game.execute_text_command('arrest transport '||a||' by KWP-TAR-902 to "Kingswell Custody Suite" vehicle "Marked police vehicle KW-12" handover "No incident; condition unchanged" duration 12 minutes','kng-tar-902',null,n2);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Transport failed: %',r; end if;
 if (select current_game_time from game.simulation_state where id=1)<>'2026-11-20 10:12:00+00'::timestamptz then raise exception 'Transport duration did not advance fictional clock'; end if;
 if (select duration_minutes from game.arrest_transport_legs where arrest_id=(select id from game.arrests where arrest_ref=a))<>12 then raise exception 'Transport duration not retained'; end if;

 r:=game.execute_text_command('custody book '||a||' by KWP-TAR-902 identity "Identity checked against existing person record" risk "Routine monitoring; no immediate escalation recorded" health "No immediate health concern reported" cell "Cell A-03" medication "No medication disclosed" safeguarding "No additional concern recorded"','kng-tar-903',null,n2);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Booking failed: %',r; end if; cu:=r->>'custody_ref';
 r:=game.execute_text_command('custody property '||cu||' by KWP-TAR-902 item "Wallet and keys" condition "Intact" disposition stored storage "Locker 04"','kng-tar-904',null,n2);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Property inventory failed: %',r; end if;
 r:=game.execute_text_command('custody property '||cu||' by KWP-TAR-902 item "Folded note" condition "Paper note; edges worn" disposition retained_as_evidence storage "Evidence Store Shelf B"','kng-tar-905',null,n2);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Evidence retention failed: %',r; end if; ev:=(r->>'evidence_id')::uuid;
 if not exists(select 1 from game.evidence_items where id=ev and case_id=c and metadata->>'source'='custody_property') then raise exception 'Custody evidence integration missing'; end if;
 r:=game.execute_text_command('custody check '||cu||' by KWP-TAR-902 type welfare observation "Responsive; no immediate concern" escalation "None"','kng-tar-906',null,n2);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Welfare check failed: %',r; end if;
 begin update game.custody_welfare_checks set observation='tampered' where custody_episode_id=(select id from game.custody_episodes where custody_ref=cu); raise exception 'Welfare check update unexpectedly succeeded';
 exception when others then if sqlerrm not like 'Arrest and custody history is append-only%' then raise; end if; end;
 r:=game.execute_text_command('custody event '||cu||' by KWP-TAR-902 type meal details "Meal offered and accepted"','kng-tar-907',null,n2);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Custody event failed: %',r; end if;
 r:=game.execute_text_command('case arrests CASE-TAR-901 by KWP-TAR-901','kng-tar-908',null,n1);
 if not coalesce((r->>'ok')::boolean,false) or jsonb_array_length(r->'arrests')<>1 then raise exception 'Case arrest retrieval failed: %',r; end if;
 d:=game.get_case_review_dossier('CASE-TAR-901');
 if jsonb_array_length(d->'arrests')<>1 then raise exception 'Case dossier arrest integration failed'; end if;
 r:=game.execute_text_command('custody release '||cu||' by KWP-TAR-901 outcome released because "Case review completed; release decision recorded"','kng-tar-909',null,n1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Custody release failed: %',r; end if;
 if (select status from game.custody_episodes where custody_ref=cu)<>'released' then raise exception 'Custody status mismatch'; end if;
 if (select current_game_time from game.simulation_state where id=1)<>'2026-11-20 10:12:00+00'::timestamptz then raise exception 'Non-transport custody records advanced time'; end if;
 h:=game.execute_text_command('help','kng-tar-help-901',null,null);
 if not (h->'available_commands' ? 'execute_arrest') or not (h->'available_commands' ? 'book_custody') or not (h->'available_commands' ? 'get_case_arrests') then raise exception 'Help command registration failed'; end if;
end $$;
rollback;
