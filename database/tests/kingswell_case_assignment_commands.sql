-- Case ownership and investigator assignment player-command regression.
-- All synthetic persons, personnel, case and command rows roll back.
begin;
do $$
declare p1 uuid;p2 uuid;p3 uuid;pp1 uuid;pp2 uuid;pp3 uuid;c uuid;r jsonb;cmd text;dup jsonb;ass jsonb;event_count integer;
begin
 update game.simulation_state set current_game_time='2026-01-01 09:00:00+00',time_paused=true where id=1;
 insert into game.persons(person_ref,given_name,family_name) values('TEST-KWCA-P1','Case','Lead') returning id into p1;
 insert into game.persons(person_ref,given_name,family_name) values('TEST-KWCA-P2','Case','Second') returning id into p2;
 insert into game.persons(person_ref,given_name,family_name) values('TEST-KWCA-P3','Case','Supervisor') returning id into p3;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status) values('TEST-KWCA-O1',p1,'TEST-KWCA-S1','active') returning id into pp1;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status) values('TEST-KWCA-O2',p2,'TEST-KWCA-S2','active') returning id into pp2;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status) values('TEST-KWCA-O3',p3,'TEST-KWCA-S3','active') returning id into pp3;
 insert into game.cases(case_ref,case_title,status,opened_at,case_data) values('TEST-KWCA-CASE','Assignment command test','under_investigation','2026-01-01 08:00:00+00','{}') returning id into c;
 cmd:='case assign TEST-KWCA-CASE to TEST-KWCA-O1 role lead_investigator by TEST-KWCA-O3';
 r:=game.interpret_text_command(cmd); if r->>'command_type'<>'assign_case_investigator' then raise exception 'assign parser: %',r; end if;
 r:=game.execute_text_command(cmd,'kwca-assign-0001',null,pp3); if not coalesce((r->>'ok')::boolean,false) then raise exception 'lead assign: %',r; end if;
 dup:=game.execute_text_command(cmd,'kwca-assign-0001',null,pp3); if not coalesce((dup->>'duplicate')::boolean,false) then raise exception 'idempotent replay: %',dup; end if;
 cmd:='case assign TEST-KWCA-CASE to TEST-KWCA-O2 role investigator by TEST-KWCA-O3';
 r:=game.execute_text_command(cmd,'kwca-assign-0002',null,pp3); if not coalesce((r->>'ok')::boolean,false) then raise exception 'support assign: %',r; end if;
 cmd:='case assign TEST-KWCA-CASE to TEST-KWCA-O3 role investigator by TEST-KWCA-O3';
 r:=game.execute_text_command(cmd,'kwca-assign-0003',null,pp3); if not coalesce((r->>'ok')::boolean,false) then raise exception 'second support investigator assign: %',r; end if;
 cmd:='case assign TEST-KWCA-CASE to TEST-KWCA-O2 role lead_investigator by TEST-KWCA-O3';
 r:=game.execute_text_command(cmd,'kwca-assign-0004',null,pp3); if not coalesce((r->>'ok')::boolean,false) then raise exception 'lead transfer: %',r; end if;
 if (select lead_personnel_id from game.cases where id=c)<>pp2 then raise exception 'case lead pointer not synchronized'; end if;
 ass:=game.get_case_assignments('TEST-KWCA-CASE',null,true);
 if (ass->>'count')::int<>4 then raise exception 'assignment history count: %',ass; end if;
 if not exists(select 1 from game.case_assignment_events e join game.case_assignments a on a.id=e.assignment_id where a.case_id=c and e.event_type='lead_transferred') then raise exception 'lead transfer event missing'; end if;
 cmd:='case unassign TEST-KWCA-CASE TEST-KWCA-O2 role investigator because "Reassigned to another investigation" by TEST-KWCA-O3';
 r:=game.execute_text_command(cmd,'kwca-release-0001',null,pp3); if not coalesce((r->>'ok')::boolean,false) then raise exception 'role-specific release: %',r; end if;
 if not exists(select 1 from game.case_assignments where case_id=c and personnel_id=pp2 and assignment_role='lead_investigator' and status='active') then raise exception 'release removed the wrong role'; end if;
 r:=game.execute_text_command('case assignments TEST-KWCA-CASE','kwca-list-0001',null,pp3); if (r->>'count')::int<>4 then raise exception 'list command: %',r; end if;
 r:=game.execute_text_command('help','kwca-help-0001',null,pp3); if not (r->'available_commands' ? 'assign_case_investigator') then raise exception 'help command list: %',r; end if;
 select count(*) into event_count from game.case_assignment_events where case_id=c;
 if event_count<6 then raise exception 'assignment event history incomplete: %',event_count; end if;
 begin update game.case_assignment_events set event_data='{}' where case_id=c; raise exception 'append-only update unexpectedly succeeded';
 exception when others then if sqlerrm='append-only update unexpectedly succeeded' then raise; end if; end;
 if (select current_game_time from game.simulation_state where id=1)<>'2026-01-01 09:00:00+00'::timestamptz then raise exception 'assignment commands advanced clock'; end if;
 raise notice 'PASS: parser, assignment, multiple investigators, lead transfer, role-specific release, history, append-only protection, idempotency, help and fixed game time';
end $$;
rollback;
