-- Rollback-only typed lead entity-link regression.
begin;
do $$
declare p1 uuid;p2 uuid;pp1 uuid;pp2 uuid;c uuid;r jsonb;cmd text;lr text;before_time timestamptz;link_count int;
begin
 update game.simulation_state set current_game_time='2026-01-02 09:00:00+00',time_paused=true where id=1;
 select current_game_time into before_time from game.simulation_state where id=1;
 insert into game.persons(person_ref,given_name,family_name) values('TEST-KWLL-P1','Lead','Owner') returning id into p1;
 insert into game.persons(person_ref,given_name,family_name) values('TEST-KWLL-P2','Linked','Witness') returning id into p2;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status) values('TEST-KWLL-O1',p1,'TEST-KWLL-S1','active') returning id into pp1;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status) values('TEST-KWLL-O2',p2,'TEST-KWLL-S2','active') returning id into pp2;
 insert into game.cases(case_ref,case_title,status,opened_at,case_data) values('TEST-KWLL-CASE','Lead entity link test','under_investigation',before_time,'{}') returning id into c;
 r:=game.execute_text_command('case lead create TEST-KWLL-CASE "Witness statement" "A named witness has information relevant to the incident." source witness_information by TEST-KWLL-O1','kwll-create-0001',null,pp1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'lead create: %',r; end if; lr:=r->>'lead_ref';
 r:=game.execute_text_command('case lead assign '||lr||' to TEST-KWLL-O1 by TEST-KWLL-O1','kwll-assign-0001',null,pp1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'lead assign: %',r; end if;
 cmd:='case lead link '||lr||' entity person TEST-KWLL-P2 because "Witness is the source of the account recorded in this lead." by TEST-KWLL-O1';
 r:=game.interpret_text_command(cmd); if r->>'command_type'<>'link_case_lead_entity' then raise exception 'link parser: %',r; end if;
 r:=game.execute_text_command(cmd,'kwll-link-0001',null,pp1); if not coalesce((r->>'ok')::boolean,false) then raise exception 'entity link: %',r; end if;
 r:=game.execute_text_command('case lead links '||lr,'kwll-list-0001',null,pp1); if not coalesce((r->>'ok')::boolean,false) or (r->>'count')::int<>1 then raise exception 'link list: %',r; end if;
 r:=game.execute_text_command(cmd,'kwll-link-0002',null,pp1); if not coalesce((r->>'duplicate')::boolean,false) then raise exception 'duplicate link: %',r; end if;
 select count(*) into link_count from game.case_lead_entity_links where lead_id=(select id from game.case_leads where lead_ref=lr);
 if link_count<>1 then raise exception 'duplicate entity link persisted'; end if;
 begin update game.case_lead_entity_links set reason='changed' where lead_id=(select id from game.case_leads where lead_ref=lr); raise exception 'link update unexpectedly succeeded'; exception when others then if sqlerrm='link update unexpectedly succeeded' then raise; end if; end;
 if (select current_game_time from game.simulation_state where id=1)<>before_time then raise exception 'entity linking advanced fictional time'; end if;
 raise notice 'PASS: typed entity linking, parser/executor, listing, duplicate protection, append-only guard and fixed fictional clock';
end $$;
rollback;