begin;
do $$
declare v jsonb;
begin
 v:=game.interpret_text_command('surveillance plan create CASE-1 by OFF-1 method static_observation at "Northgate roofline" objective "Observe the loading bay during the stated period" subject "Unknown dark saloon vehicle and occupants"');
 if v->>'command_type'<>'create_surveillance_operation' or v#>>'{payload,case_ref}'<>'CASE-1' or v#>>'{payload,method}'<>'static_observation' then raise exception 'Plan parser failed: %',v;end if;
 v:=game.interpret_text_command('surveillance team add KWS-123 OFF-2 role observer by OFF-1');
 if v->>'command_type'<>'add_surveillance_team' then raise exception 'Team parser failed: %',v;end if;
 v:=game.interpret_text_command('surveillance deploy KWS-123 by OFF-1');
 if v->>'command_type'<>'start_surveillance_operation' then raise exception 'Deploy parser failed: %',v;end if;
 v:=game.interpret_text_command('surveillance log KWS-123 by OFF-2 type vehicle_movement at "Market Lane junction" details "Dark saloon travelled eastbound" subject "Unknown driver" movement "Eastbound, then turned south" vehicle "Dark four-door saloon"');
 if v->>'command_type'<>'record_surveillance_observation' or v#>>'{payload,entry_type}'<>'vehicle_movement' then raise exception 'Observation parser failed: %',v;end if;
 v:=game.interpret_text_command('surveillance link KWO-123 evidence EVD-1 by OFF-2 because "Image capture supports vehicle description"');
 if v->>'command_type'<>'link_surveillance_observation' then raise exception 'Link parser failed: %',v;end if;
 v:=game.interpret_text_command('surveillance close KWS-123 by OFF-1 because "Deployment concluded"');
 if v->>'command_type'<>'close_surveillance_operation' then raise exception 'Close parser failed: %',v;end if;
 v:=game.interpret_text_command('surveillance cancel KWS-123 by OFF-1 because "Plan no longer required"');
 if v->>'command_type'<>'cancel_surveillance_operation' then raise exception 'Cancel parser failed: %',v;end if;
 v:=game.interpret_text_command('surveillance operations CASE-1 by OFF-1');
 if v->>'command_type'<>'get_surveillance_operations' then raise exception 'List parser failed: %',v;end if;
 if not (select relrowsecurity from pg_class where oid='game.surveillance_operations'::regclass) or not (select relrowsecurity from pg_class where oid='game.surveillance_operation_team'::regclass) or not (select relrowsecurity from pg_class where oid='game.surveillance_observations'::regclass) or not (select relrowsecurity from pg_class where oid='game.surveillance_observation_links'::regclass) or not (select relrowsecurity from pg_class where oid='game.surveillance_operation_events'::regclass) then raise exception 'RLS missing';end if;
 if has_table_privilege('anon','game.surveillance_operations','select') or has_table_privilege('authenticated','game.surveillance_operations','select') then raise exception 'Public role access unexpectedly granted';end if;
 if not has_table_privilege('service_role','game.surveillance_operations','select') then raise exception 'Service role access missing';end if;
 if exists(select 1 from pg_constraint con join pg_class c on c.oid=con.conrelid join pg_namespace n on n.oid=c.relnamespace where n.nspname='game' and c.relname like 'surveillance_%' and con.contype='f' and not exists(select 1 from pg_index i where i.indrelid=con.conrelid and i.indisvalid and i.indkey[0:cardinality(con.conkey)-1]::int2[]=con.conkey)) then raise exception 'Surveillance foreign key is not indexed';end if;
 if position('surveillance_operations' in pg_get_functiondef('game.get_case_review_dossier_before_disclosure(text)'::regprocedure))=0 then raise exception 'Dossier integration missing';end if;
 if not exists(select 1 from pg_indexes where schemaname='game' and indexname='surveillance_operation_single_team_lead_idx') then raise exception 'Single team-lead guard index missing';end if;
 if position('team_lead_required' in pg_get_functiondef('game.start_surveillance_operation(text,text,uuid)'::regprocedure))=0 then raise exception 'Team-lead deployment guard missing';end if;
end $$;
select game.execute_text_command('help','kng-surveillance-help-0001',null,null);
rollback;


-- Personnel-backed end-to-end workflow. All fixtures, clock state and command
-- ledger entries are temporary and are removed by the final ROLLBACK.
begin;
do $$
declare
 p1 uuid:=gen_random_uuid();p2 uuid:=gen_random_uuid();n1 uuid:=gen_random_uuid();n2 uuid:=gen_random_uuid();c uuid:=gen_random_uuid();
 r jsonb;op text;entry text;clock_before timestamptz;
begin
 select current_game_time into clock_before from game.simulation_state where id=1;
 if clock_before is not null then raise exception 'Expected uninitialized baseline clock, got %',clock_before;end if;
 insert into game.persons(id,person_ref,given_name,family_name,occupation) values
 (p1,'P-TEST-SURV-001','Test','Lead','Police Officer'),(p2,'P-TEST-SURV-002','Test','Observer','Police Officer');
 insert into game.police_personnel(id,personnel_ref,person_id,service_number,employment_status,joined_on) values
 (n1,'KWP-TEST-001',p1,'TEST-001','active','2020-01-01'),(n2,'KWP-TEST-002',p2,'TEST-002','active','2021-01-01');
 insert into game.cases(id,case_ref,case_title,case_type,status,lead_personnel_id,summary)
 values(c,'CASE-TEST-SURV-001','Surveillance E2E Test','test','open',n1,'Temporary rollback-only surveillance workflow fixture');
 insert into game.case_assignments(case_id,personnel_id,assignment_role,status)
 values(c,n1,'lead_investigator','active'),(c,n2,'investigator','active');
 update game.simulation_state set current_game_time='2026-11-20 08:00:00+00',time_paused=true,updated_at=now() where id=1;
 r:=game.execute_text_command('surveillance plan create CASE-TEST-SURV-001 by KWP-TEST-001 method static_observation at "Test Observation Point" objective "Verify end-to-end surveillance operation creation" subject "Temporary test vehicle"','kng-e2e-surv-plan-0001',null,n1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Plan failed: %',r;end if;
 op:=r->>'operation_ref';
 r:=game.execute_text_command('surveillance team add '||op||' KWP-TEST-002 role observer by KWP-TEST-001','kng-e2e-surv-team2-0001',null,n1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Observer assignment failed: %',r;end if;
 r:=game.execute_text_command('surveillance deploy '||op||' by KWP-TEST-002','kng-e2e-surv-no-lead-0001',null,n2);
 if coalesce((r->>'ok')::boolean,false) or r->>'code'<>'team_lead_required' then raise exception 'Deployment without a team lead was not rejected: %',r;end if;
 r:=game.execute_text_command('surveillance team add '||op||' KWP-TEST-001 role team_lead by KWP-TEST-001','kng-e2e-surv-team1-0001',null,n1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Team lead assignment failed: %',r;end if;
 r:=game.execute_text_command('surveillance deploy '||op||' by KWP-TEST-001','kng-e2e-surv-deploy-0001',null,n1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Deployment failed: %',r;end if;
 if (select status from game.surveillance_operations where operation_ref=op)<>'deployed' then raise exception 'Operation did not transition to deployed: %',r;end if;
 r:=game.execute_text_command('surveillance log '||op||' by KWP-TEST-002 type vehicle_movement at "Test Observation Point" details "Temporary test vehicle travelled eastbound" subject "Temporary test driver" movement "Eastbound" vehicle "Dark four-door saloon"','kng-e2e-surv-log-0001',null,n2);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Observation failed: %',r;end if;
 entry:=r->>'entry_ref';
 r:=game.execute_text_command('surveillance operations CASE-TEST-SURV-001 by KWP-TEST-001','kng-e2e-surv-list-0001',null,n1);
 if not coalesce((r->>'ok')::boolean,false) or jsonb_array_length(r->'operations')<>1 then raise exception 'Operation retrieval failed: %',r;end if;
 if jsonb_array_length(r#>'{operations,0,observations}')<>1 then raise exception 'Observation missing from retrieval: %',r;end if;
 r:=game.execute_text_command('surveillance close '||op||' by KWP-TEST-001 because "End-to-end workflow completed"','kng-e2e-surv-close-0001',null,n1);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'Closure command failed: %',r;end if;
 if (select status from game.surveillance_operations where operation_ref=op)<>'completed' then raise exception 'Operation did not close: %',r;end if;
 if (select count(*) from game.surveillance_observations where entry_ref=entry)<>1 then raise exception 'Observation row missing';end if;
 if (select count(*) from game.surveillance_operation_events e join game.surveillance_operations o on o.id=e.operation_id where o.operation_ref=op)<5 then raise exception 'Expected operation event history missing';end if;
 if (select current_game_time from game.simulation_state where id=1)<>'2026-11-20 08:00:00+00'::timestamptz then raise exception 'Surveillance workflow unexpectedly advanced time';end if;
end $$;
rollback;
