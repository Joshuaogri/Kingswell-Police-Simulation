-- Read-only case handover parser and access regression.
do $$
declare v jsonb;
begin
 v:=game.interpret_text_command('case transfer CASE-TEST from OFF-OLD to OFF-NEW because "Outstanding enquiries and evidence review" by OFF-SUP');
 if coalesce((v->>'recognized')::boolean,false) is not true or v->>'command_type'<>'transfer_case_lead' or v#>>'{payload,from_ref}'<>'OFF-OLD' or v#>>'{payload,to_ref}'<>'OFF-NEW' then raise exception 'Transfer parser failed: %',v; end if;
 v:=game.interpret_text_command('case handovers CASE-TEST by OFF-SUP');
 if coalesce((v->>'recognized')::boolean,false) is not true or v->>'command_type'<>'get_case_handovers' then raise exception 'History parser failed: %',v; end if;
 if not (select relrowsecurity from pg_class where oid='game.case_handover_events'::regclass) then raise exception 'RLS is not enabled'; end if;
 if has_table_privilege('anon','game.case_handover_events','select') or has_table_privilege('authenticated','game.case_handover_events','select') then raise exception 'Public roles can read handovers'; end if;
 if not has_table_privilege('service_role','game.case_handover_events','select') or not has_table_privilege('service_role','game.case_handover_events','insert') then raise exception 'service_role privileges missing'; end if;
end $$;