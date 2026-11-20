-- Case task completion submission command and integrity regression.
begin;
do $$
declare v jsonb;
begin
 v:=game.interpret_text_command('case task submit TASK-1 by OFF-1 because "Completed interviews and documented outcome"');
 if v->>'command_type'<>'submit_case_task' or v#>>'{payload,task_ref}'<>'TASK-1' then raise exception 'Submit parser failed: %',v;end if;
 v:=game.interpret_text_command('case task submission evidence SUB-1 EVD-1 by OFF-1 because "Supports recorded result"');
 if v->>'command_type'<>'link_case_task_submission_evidence' or v#>>'{payload,evidence_ref}'<>'EVD-1' then raise exception 'Evidence parser failed: %',v;end if;
 v:=game.interpret_text_command('case task submission review SUB-1 set accepted by SUP-1 because "Work checked and accepted"');
 if v->>'command_type'<>'review_case_task_submission' or v#>>'{payload,disposition}'<>'accepted' then raise exception 'Review parser failed: %',v;end if;
 v:=game.interpret_text_command('case task submissions TASK-1 by OFF-1');
 if v->>'command_type'<>'get_case_task_submissions' then raise exception 'Submission retrieval parser failed: %',v;end if;
 if not (select relrowsecurity from pg_class where oid='game.case_task_submissions'::regclass)
 or not (select relrowsecurity from pg_class where oid='game.case_task_submission_evidence'::regclass)
 or not (select relrowsecurity from pg_class where oid='game.case_task_submission_reviews'::regclass) then raise exception 'RLS missing';end if;
 if has_table_privilege('anon','game.case_task_submissions','select') or has_table_privilege('authenticated','game.case_task_submissions','select') then raise exception 'Public read access unexpectedly granted';end if;
 if not exists(select 1 from pg_indexes where schemaname='game' and indexname='case_task_submission_reviews_one_final_idx') then raise exception 'Single-review guard index missing';end if;
 if not exists(select 1 from pg_trigger where tgname='case_task_completion_review_gate' and not tgisinternal) then raise exception 'Completion review gate missing';end if;
end $$;
select game.execute_text_command('help','kng-task-submit-help-0001',null,null);
rollback;
