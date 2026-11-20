-- Player-facing case task dependency/workload command regression.
begin;
do $$
declare v jsonb;
begin
 v:=game.interpret_text_command('case task dependency TASK-A requires TASK-B by OFF-1');
 if coalesce((v->>'recognized')::boolean,false) is not true or v->>'command_type'<>'add_case_task_dependency' or v#>>'{payload,task_ref}'<>'TASK-A' or v#>>'{payload,prerequisite_ref}'<>'TASK-B' then raise exception 'Dependency parser failed: %',v;end if;
 v:=game.interpret_text_command('case task workload case CASE-1 by OFF-1');
 if v->>'command_type'<>'get_case_task_workload' or v#>>'{payload,case_ref}'<>'CASE-1' then raise exception 'Case workload parser failed: %',v;end if;
 v:=game.interpret_text_command('case task workload officer OFF-2 by OFF-1');
 if v->>'command_type'<>'get_case_task_workload' or v#>>'{payload,personnel_ref}'<>'OFF-2' then raise exception 'Officer workload parser failed: %',v;end if;
 v:=game.interpret_text_command('case task workload by OFF-1');
 if v->>'command_type'<>'get_case_task_workload' then raise exception 'Department workload parser failed: %',v;end if;
 v:=game.interpret_text_command('case tasks CASE-1 by OFF-1');
 if v->>'command_type'<>'get_case_tasks' then raise exception 'Case tasks parser failed: %',v;end if;
 if not (select relrowsecurity from pg_class where oid='game.case_task_dependencies'::regclass) then raise exception 'Dependency RLS missing';end if;
 if has_table_privilege('anon','game.case_task_dependencies','select') or has_table_privilege('authenticated','game.case_task_dependencies','select') then raise exception 'Public role access is enabled';end if;
 if not has_table_privilege('service_role','game.case_task_dependencies','select') or not has_table_privilege('service_role','game.case_task_dependencies','insert') then raise exception 'Service role privileges missing';end if;
end $$;
select game.execute_text_command('help','kng-task-help-test-0001',null,null);
rollback;
