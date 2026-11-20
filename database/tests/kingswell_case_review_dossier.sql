-- Rollback-only case review dossier integration test.
begin;
do $$
declare pp uuid;officer uuid;outsider_person uuid;outsider uuid;r jsonb;parsed jsonb;n int;
begin
 insert into game.persons(person_ref,given_name,family_name) values('TEST-REVIEW-OFFICER','Review','Officer') returning id into pp;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status) values('TEST-REVIEW-OFFICER',pp,'TEST-REV-SVC','active') returning id into officer;
 insert into game.persons(person_ref,given_name,family_name) values('TEST-REVIEW-OUTSIDER','Outside','Officer') returning id into outsider_person;
 insert into game.police_personnel(personnel_ref,person_id,service_number,employment_status) values('TEST-REVIEW-OUTSIDER',outsider_person,'TEST-REV-OUT','active') returning id into outsider;
 insert into game.cases(case_ref,case_title,status,lead_personnel_id,opened_at,case_data) values('TEST-REVIEW-CASE','Dossier regression','under_investigation',officer,now(),'{}');
 parsed:=game.interpret_text_command('case review TEST-REVIEW-CASE by TEST-REVIEW-OFFICER');
 if parsed->>'command_type'<>'get_case_review_dossier' or parsed#>>'{payload,actor_ref}'<>'TEST-REVIEW-OFFICER' then raise exception 'parser failure %',parsed; end if;
 r:=game.execute_text_command('case review TEST-REVIEW-CASE by TEST-REVIEW-OFFICER','test-review-dossier-001',null,officer);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'dossier command failed: %',r; end if;
 if r#>>'{case,case_ref}'<>'TEST-REVIEW-CASE' then raise exception 'case identity absent'; end if;
 if jsonb_typeof(r->'leads') is null or jsonb_typeof(r->'evidence') is null or jsonb_typeof(r->'forensic_requests') is null or jsonb_typeof(r->'interviews') is null then raise exception 'dossier sections absent: %',r; end if;
 if not coalesce((game.execute_text_command('case review TEST-REVIEW-CASE by TEST-REVIEW-OFFICER','test-review-dossier-001',null,officer)->>'duplicate')::boolean,false) then raise exception 'idempotency replay failed'; end if;
 r:=game.execute_text_command('case review TEST-REVIEW-CASE by TEST-REVIEW-OUTSIDER','test-review-outsider-001',null,outsider);
 if coalesce((r->>'ok')::boolean,true) or r->>'code'<>'case_access_denied' then raise exception 'unassigned officer access should be rejected: %',r; end if;
 r:=game.execute_text_command('case review NOT-A-CASE by TEST-REVIEW-OFFICER','test-review-missing-001',null,officer);
 if coalesce((r->>'ok')::boolean,true) or r->>'code'<>'case_not_found' then raise exception 'missing case should be rejected: %',r; end if;
 r:=game.execute_text_command('help','test-review-help-001',null,officer);
 select count(*) into n from jsonb_array_elements_text(r->'available_commands') x(value) where value='get_case_review_dossier';
 if n<>1 then raise exception 'help should list dossier command once, found %',n; end if;
 raise notice 'PASS: dossier aggregation, assigned-officer access, actor attribution, idempotency, missing-case handling and unique help registration';
end $$;
rollback;
