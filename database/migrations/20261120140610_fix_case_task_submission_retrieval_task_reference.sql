do $$
declare v_def text;v_old text:='select t.* into v_task from game.case_tasks t join game.case_task_submissions s on s.task_id=t.id where s.submission_ref=v_payload->>''task_ref'';';
v_new text:='select * into v_task from game.case_tasks where task_ref=v_payload->>''task_ref'';';
begin
 select pg_get_functiondef('game.execute_text_command(text,text,uuid,uuid)'::regprocedure) into v_def;
 if position(v_old in v_def)=0 then raise exception 'Expected task submission retrieval query not found in runtime executor';end if;
 execute replace(v_def,v_old,v_new);
end $$;