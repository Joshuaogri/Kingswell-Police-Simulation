begin;
do $$
declare v jsonb;
begin
 v:=game.interpret_text_command('case activity record CASE-1 type surveillance by OFF-1 method "Static observation" outcome information_obtained because "Observed the rear entrance during the stated period" result "Two vehicles entered; no identification made"');
 if v->>'command_type'<>'record_case_activity' or v#>>'{payload,activity_type}'<>'surveillance' or v#>>'{payload,actor_ref}'<>'OFF-1' then raise exception 'Activity parser failed: %',v;end if;
 v:=game.interpret_text_command('case activity link KWA-123 person PER-1 by OFF-1 because "Person was present during the recorded observation"');
 if v->>'command_type'<>'link_case_activity' or v#>>'{payload,entity_type}'<>'person' then raise exception 'Activity link parser failed: %',v;end if;
 v:=game.interpret_text_command('case activity history CASE-1 by OFF-1');
 if v->>'command_type'<>'get_case_activity' or v#>>'{payload,case_ref}'<>'CASE-1' then raise exception 'Activity history parser failed: %',v;end if;
 if not (select relrowsecurity from pg_class where oid='game.case_activity_records'::regclass) or not (select relrowsecurity from pg_class where oid='game.case_activity_links'::regclass) then raise exception 'Activity RLS missing';end if;
 if has_table_privilege('anon','game.case_activity_records','select') or has_table_privilege('authenticated','game.case_activity_records','select') then raise exception 'Activity public read access unexpectedly granted';end if;
 if not has_table_privilege('service_role','game.case_activity_records','select') then raise exception 'Service role access missing';end if;
 if position('activities' in pg_get_functiondef('game.get_case_review_dossier_before_disclosure(text)'::regprocedure))=0 then raise exception 'Dossier integration missing';end if;
end $$;
select game.execute_text_command('help','kng-case-activity-help-0001',null,null);
rollback;