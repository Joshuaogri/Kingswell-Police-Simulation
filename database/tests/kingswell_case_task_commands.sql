-- Player-facing case task command regression; all fixtures roll back.
begin;
do $$
declare p1 uuid;p2 uuid;pp1 uuid;pp2 uuid;c uuid; r jsonb; ref text; dup jsonb; cmd text;
begin
 update game.simulation_state set current_game_time='2026-01-01 09:00:00+00',time_paused=true where id=1;
 insert into game.persons(person_ref,given_name,family_name) values('TEST-KWTC-P1','Test','One') returning id into p1;
 insert into game.persons(person_ref,given_name,family_name) values('TEST-KWTC-P2','Test','Two') returning id into p2;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status) values('TEST-KWTC-O1',p1,'TEST-KWTC-S1','active') returning id into pp1;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status) values('TEST-KWTC-O2',p2,'TEST-KWTC-S2','active') returning id into pp2;
 insert into game.cases(case_ref,case_title,status,opened_at,case_data) values('TEST-KWTC-CASE','Command task test','under_investigation','2026-01-01 08:00:00+00','{}') returning id into c;
 cmd:='case task create TEST-KWTC-CASE type witness_enquiry priority high assign TEST-KWTC-O1 title "Interview witness" because "Obtain a full account" by TEST-KWTC-O1';
 r:=game.interpret_text_command(cmd);
 if r->>'command_type'<>'create_case_task' then raise exception 'Parser create failed: %',r; end if;
 r:=game.execute_text_command(cmd,'kwtc-create-0001',null,pp1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Create command failed: %',r; end if;
 ref:=r->>'task_ref';
 dup:=game.execute_text_command(cmd,'kwtc-create-0001',null,pp1);
 if not coalesce((dup->>'duplicate')::boolean,false) then raise exception 'Idempotent replay failed: %',dup; end if;
 r:=game.execute_text_command('case task update '||ref||' in_progress by TEST-KWTC-O1','kwtc-update-0001',null,pp1);
 if r->>'status'<>'completed' then raise exception 'Update command failed: %',r; end if;
 r:=game.execute_text_command('case task assign '||ref||' to TEST-KWTC-O2 by TEST-KWTC-O1','kwtc-assign-0001',null,pp1);
 if not coalesce((r->>'ok')::boolean,false) or r->>'assigned_to'<>'TEST-KWTC-O2' then raise exception 'Assignment command failed: %',r; end if;
 r:=game.execute_text_command('case tasks TEST-KWTC-CASE','kwtc-list-0001',null,pp1);
 if (r->>'count')::int<>1 then raise exception 'List command failed: %',r; end if;
 r:=game.execute_text_command('case task '||ref,'kwtc-get-0001',null,pp1);
 if (r->>'count')::int<>1 then raise exception 'Get command failed: %',r; end if;
 r:=game.execute_text_command('case task update '||ref||' completed by TEST-KWTC-O1 outcome "Interview completed"','kwtc-complete-0001',null,pp1);
 if r->>'status'<>'completed' or not coalesce((r->>'ok')::boolean,false) then raise exception 'Complete command failed: %',r; end if;
 if (select current_game_time from game.simulation_state where id=1)<>'2026-01-01 09:00:00+00'::timestamptz then raise exception 'Task commands advanced time'; end if;
 raise notice 'PASS: parser, create, idempotency, status update, reassignment, list/get, completion and fixed fictional time';
end $$;
rollback;
