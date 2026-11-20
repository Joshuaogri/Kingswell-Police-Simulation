-- Rollback-only end-to-end investigative lead and enquiry regression.
begin;
do $$
declare p1 uuid;p2 uuid;p3 uuid;pp1 uuid;pp2 uuid;pp3 uuid;c uuid;r jsonb;dup jsonb;cmd text;lr text;er text;before_time timestamptz;
begin
 update game.simulation_state set current_game_time='2026-01-01 09:00:00+00',time_paused=true where id=1;
 select current_game_time into before_time from game.simulation_state where id=1;
 insert into game.persons(person_ref,given_name,family_name) values('TEST-KWLE-P1','Lead','Owner'),('TEST-KWLE-P2','Enquiry','Officer'),('TEST-KWLE-P3','Supervisor','Actor');
 select id into p1 from game.persons where person_ref='TEST-KWLE-P1'; select id into p2 from game.persons where person_ref='TEST-KWLE-P2'; select id into p3 from game.persons where person_ref='TEST-KWLE-P3';
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status) values('TEST-KWLE-O1',p1,'TEST-KWLE-S1','active') returning id into pp1;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status) values('TEST-KWLE-O2',p2,'TEST-KWLE-S2','active') returning id into pp2;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status) values('TEST-KWLE-O3',p3,'TEST-KWLE-S3','active') returning id into pp3;
 insert into game.cases(case_ref,case_title,status,opened_at,case_data) values('TEST-KWLE-CASE','Lead and enquiry test','under_investigation',before_time,'{}') returning id into c;
 cmd:='case lead create TEST-KWLE-CASE "Test witness lead" "A witness reports a vehicle leaving the area shortly after the incident." source witness_information by TEST-KWLE-O3';
 r:=game.interpret_text_command(cmd); if r->>'command_type'<>'create_case_lead' then raise exception 'lead parser: %',r; end if;
 r:=game.execute_text_command(cmd,'kwle-create-0001',null,pp3); if not coalesce((r->>'ok')::boolean,false) then raise exception 'lead create: %',r; end if; lr:=r->>'lead_ref';
 dup:=game.execute_text_command(cmd,'kwle-create-0001',null,pp3); if not coalesce((dup->>'duplicate')::boolean,false) then raise exception 'idempotent replay: %',dup; end if;
 cmd:='case lead assign '||lr||' to TEST-KWLE-O2 by TEST-KWLE-O3'; r:=game.execute_text_command(cmd,'kwle-assign-0001',null,pp3); if not coalesce((r->>'ok')::boolean,false) then raise exception 'lead assign: %',r; end if;
 cmd:='case enquiry record '||lr||' by TEST-KWLE-O2 method interview action "Interviewed the reporting witness about vehicle direction and timing." result "Witness recalls a dark estate car travelling east; description requires corroboration." outcome information_obtained recorded_by TEST-KWLE-O3';
 r:=game.interpret_text_command(cmd); if r->>'command_type'<>'record_case_enquiry' then raise exception 'enquiry parser: %',r; end if;
 r:=game.execute_text_command(cmd,'kwle-enquiry-0001',null,pp3); if not coalesce((r->>'ok')::boolean,false) then raise exception 'enquiry record: %',r; end if; er:=r->>'enquiry_ref';
 r:=game.execute_text_command('case leads TEST-KWLE-CASE','kwle-list-0001',null,pp3); if not coalesce((r->>'ok')::boolean,false) or (r->>'count')::int<>1 then raise exception 'lead list: %',r; end if;
 r:=game.execute_text_command('case enquiries '||lr,'kwle-enq-list-0001',null,pp3); if not coalesce((r->>'ok')::boolean,false) or (r->>'count')::int<>1 then raise exception 'enquiry list: %',r; end if;
 cmd:='case lead assess '||lr||' status under_enquiry priority high confidence moderate because "Witness account is specific but not yet independently corroborated." by TEST-KWLE-O3';
 r:=game.execute_text_command(cmd,'kwle-assess-0001',null,pp3); if not coalesce((r->>'ok')::boolean,false) then raise exception 'lead assessment: %',r; end if;
 if (select current_game_time from game.simulation_state where id=1)<>before_time then raise exception 'investigative records advanced fictional time'; end if;
 begin update game.case_enquiries set result='changed' where enquiry_ref=er; raise exception 'enquiry update unexpectedly succeeded'; exception when others then if sqlerrm='enquiry update unexpectedly succeeded' then raise; end if; end;
 begin delete from game.case_lead_events where lead_id=(select id from game.case_leads where lead_ref=lr); raise exception 'lead event delete unexpectedly succeeded'; exception when others then if sqlerrm='lead event delete unexpectedly succeeded' then raise; end if; end;
 r:=game.execute_text_command('help','kwle-help-0001',null,pp3); if not (r->'available_commands' ? 'create_case_lead') then raise exception 'help registration: %',r; end if;
 raise notice 'PASS: lead creation, assignment, enquiry, assessment, history, listings, append-only, idempotency, help and fixed clock';
end $$;
rollback;