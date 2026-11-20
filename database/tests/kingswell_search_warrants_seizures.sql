-- Personnel-backed end-to-end search warrant, premises, recovery, seizure and custody regression.
-- Every fixture, command, evidence item and temporary clock setting is rolled back.
begin;
do $$
declare
 p1 uuid:=gen_random_uuid();p2 uuid:=gen_random_uuid();n1 uuid:=gen_random_uuid();n2 uuid:=gen_random_uuid();c uuid:=gen_random_uuid();
 r jsonb;w text;o text;pr text;rec text;ev text;sei text;h jsonb;d jsonb;before_clock timestamptz;
begin
 select current_game_time into before_clock from game.simulation_state where id=1;
 if before_clock is not null then raise exception 'Expected NULL baseline clock';end if;
 insert into game.persons(id,person_ref,given_name,family_name,occupation) values
 (p1,'P-TEST-SEARCH-001','Search','Lead','Police Officer'),(p2,'P-TEST-SEARCH-002','Search','Evidence','Police Officer');
 insert into game.police_personnel(id,personnel_ref,person_id,service_number,employment_status,joined_on) values
 (n1,'KWP-SEARCH-001',p1,'SEARCH-001','active','2020-01-01'),(n2,'KWP-SEARCH-002',p2,'SEARCH-002','active','2021-01-01');
 insert into game.cases(id,case_ref,case_title,case_type,status,lead_personnel_id,summary)
 values(c,'CASE-TEST-SEARCH-001','Search workflow E2E','test','open',n1,'Temporary search and seizure workflow fixture');
 insert into game.case_assignments(case_id,personnel_id,assignment_role,status)
 values(c,n1,'lead_investigator','active'),(c,n2,'investigator','active');
 update game.simulation_state set current_game_time='2026-11-20 09:00:00+00',time_paused=true,updated_at=now() where id=1;

 r:=game.execute_text_command('warrant create CASE-TEST-SEARCH-001 by KWP-SEARCH-001 authority "Kingswell Central Court" scope "Search of listed premises for stolen electronic equipment" valid_for 48 hours','kng-search-e2e-warrant-01',null,n1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Warrant creation failed: %',r;end if;w:=r->>'warrant_ref';
 r:=game.execute_text_command('warrant create CASE-TEST-SEARCH-001 by KWP-SEARCH-001 authority "Kingswell Central Court" scope "Search of listed premises for stolen electronic equipment" valid_for 48 hours','kng-search-e2e-warrant-01',null,n1);
 if not coalesce((r->>'duplicate')::boolean,false) or r->>'warrant_ref'<>w then raise exception 'Warrant idempotency replay failed: %',r;end if;
 r:=game.execute_text_command('search plan create CASE-TEST-SEARCH-001 warrant '||w||' by KWP-SEARCH-001 method premises_search objective "Locate and document stolen electronic equipment"','kng-search-e2e-plan-01',null,n1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Plan creation failed: %',r;end if;o:=r->>'operation_ref';
 r:=game.execute_text_command('search team add '||o||' KWP-SEARCH-002 role evidence_officer by KWP-SEARCH-001','kng-search-e2e-team-01',null,n1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Team member assignment failed: %',r;end if;
 r:=game.execute_text_command('search premises add '||o||' property KNG-P-KAS01001 by KWP-SEARCH-002 description "Rear storage unit and adjoining office"','kng-search-e2e-prem-01',null,n2);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Premises registration failed: %',r;end if;pr:=r->>'premises_ref';
 r:=game.execute_text_command('search execute '||o||' by KWP-SEARCH-002','kng-search-e2e-no-lead-01',null,n2);
 if coalesce((r->>'ok')::boolean,false) or r->>'code'<>'team_lead_required' then raise exception 'Missing team lead not blocked: %',r;end if;
 r:=game.execute_text_command('search team add '||o||' KWP-SEARCH-001 role team_lead by KWP-SEARCH-001','kng-search-e2e-team-02',null,n1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Team lead assignment failed: %',r;end if;
 r:=game.execute_text_command('search execute '||o||' by KWP-SEARCH-001','kng-search-e2e-exec-01',null,n1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Execution failed: %',r;end if;
 r:=game.execute_text_command('search log '||o||' premises '||pr||' by KWP-SEARCH-001 type entry at "Rear loading entrance" narrative "Team entered the storage unit and commenced a systematic search."','kng-search-e2e-log-01',null,n1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Search log failed: %',r;end if;
 begin update game.search_logs set narrative='tampered' where operation_id=(select id from game.search_operations where operation_ref=o);raise exception 'Search log update unexpectedly succeeded';
 exception when others then if sqlerrm not like 'Search operation history is append-only%' then raise;end if;end;

 r:=game.execute_text_command('search recover '||o||' premises '||pr||' by KWP-SEARCH-002 category "electronic_device" description "Black tablet computer with cracked corner" at "Steel cabinet, upper shelf" condition "Screen cracked; powered off"','kng-search-e2e-recover-01',null,n2);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Property recovery failed: %',r;end if;rec:=r->>'recovery_ref';
 r:=game.execute_text_command('search seize '||rec||' by KWP-SEARCH-002 reason "Item matches property description in case file" packaging "Anti-static evidence bag" seal "KW-SEAL-TEST-001" storage "Evidence Store Shelf A" evidence_type electronic_device','kng-search-e2e-seize-01',null,n2);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Seizure failed: %',r;end if;ev:=r->>'evidence_ref';sei:=r->>'seizure_ref';
 if not exists(select 1 from game.evidence_items where evidence_ref=ev and case_id=c and metadata->>'source'='search_seizure') then raise exception 'Shared evidence item not created';end if;
 if not exists(select 1 from game.search_seizures where seizure_ref=sei and evidence_id=(select id from game.evidence_items where evidence_ref=ev)) then raise exception 'Seizure/evidence link missing';end if;
 r:=game.execute_text_command('search evidence transfer '||ev||' to KWP-SEARCH-001 by KWP-SEARCH-002 from "Evidence Officer" at "Central Evidence Store" because "Secure transfer to evidence custodian"','kng-search-e2e-transfer-01',null,n2);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Evidence custody transfer failed: %',r;end if;
 if not exists(select 1 from game.evidence_transfers et join game.evidence_items ei on ei.id=et.evidence_id where ei.evidence_ref=ev and et.from_personnel_id=n2 and et.to_personnel_id=n1) then raise exception 'Shared evidence transfer record missing';end if;
 r:=game.execute_text_command('search operations CASE-TEST-SEARCH-001 by KWP-SEARCH-001','kng-search-e2e-list-01',null,n1);
 if not coalesce((r->>'ok')::boolean,false) or jsonb_array_length(r->'operations')<>1 then raise exception 'Search retrieval failed: %',r;end if;
 r:=game.execute_text_command('search close '||o||' by KWP-SEARCH-001 because "Search completed and premises documented"','kng-search-e2e-close-blocked-01',null,n1);
 if coalesce((r->>'ok')::boolean,false) or r->>'code'<>'premises_outcomes_incomplete' then raise exception 'Close without premise outcome was not blocked: %',r;end if;
 r:=game.execute_text_command('search premises status '||pr||' set searched because "Storage unit and office systematically searched; item recovered from steel cabinet" by KWP-SEARCH-002','kng-search-e2e-prem-status-01',null,n2);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Premises status failed: %',r;end if;
 r:=game.execute_text_command('search close '||o||' by KWP-SEARCH-001 because "Search completed and premises documented"','kng-search-e2e-close-01',null,n1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Search close failed: %',r;end if;
 if (select status from game.search_operations where operation_ref=o)<>'completed' or (select status from game.search_warrants where warrant_ref=w)<>'executed' then raise exception 'Final state mismatch';end if;
 if (select count(*) from game.search_seizures where seizure_ref=sei)<>1 then raise exception 'Seizure record missing';end if;
 d:=game.get_case_review_dossier('CASE-TEST-SEARCH-001');
 if jsonb_array_length(d->'search_operations')<>1 then raise exception 'Case dossier missing search operation';end if;
 h:=game.execute_text_command('help','kng-search-e2e-help-01',null,null);
 if not (h->'available_commands' ? 'create_search_warrant') or not (h->'available_commands' ? 'transfer_search_evidence') or not (h->'available_commands' ? 'set_search_premises_status') then raise exception 'Search commands missing from help';end if;
 if (select current_game_time from game.simulation_state where id=1)<>'2026-11-20 09:00:00+00'::timestamptz then raise exception 'Search workflow advanced fictional time';end if;
end $$;
rollback;
