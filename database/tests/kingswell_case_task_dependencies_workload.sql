-- Case task dependency and workload schema regression (read-only).
do $$
begin
 if not (select relrowsecurity from pg_class where oid='game.case_task_dependencies'::regclass) then raise exception 'Dependency RLS is not enabled';end if;
 if has_table_privilege('anon','game.case_task_dependencies','select') or has_table_privilege('authenticated','game.case_task_dependencies','select') then raise exception 'Public roles can read dependencies';end if;
 if not has_table_privilege('service_role','game.case_task_dependencies','select') or not has_table_privilege('service_role','game.case_task_dependencies','insert') then raise exception 'Service role privileges missing';end if;
 if to_regprocedure('game.add_case_task_dependency(text,text,text,uuid)') is null or to_regprocedure('game.get_case_task_workload(text,text,integer)') is null then raise exception 'Task dependency/workload functions missing';end if;
 if not exists(select 1 from pg_trigger where tgname='case_tasks_dependency_gate' and not tgisinternal) then raise exception 'Dependency transition gate missing';end if;
end $$;
