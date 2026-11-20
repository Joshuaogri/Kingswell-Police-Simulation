-- Require explicit officer attribution in the case-task create command grammar.
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game'
as $$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^case[[:space:]]+task[[:space:]]+create[[:space:]]+([^[:space:]]+)[[:space:]]+type[[:space:]]+([a-z_]+)[[:space:]]+priority[[:space:]]+(low|normal|high|urgent)[[:space:]]+assign[[:space:]]+([^[:space:]]+)[[:space:]]+title[[:space:]]+"([^"]+)"[[:space:]]+because[[:space:]]+"([^"]+)"[[:space:]]+by[[:space:]]+([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','create_case_task','payload',jsonb_build_object('case_ref',m[1],'task_type',lower(m[2]),'priority',lower(m[3]),'assignee_ref',case when lower(m[4])='none' then null else m[4] end,'title',m[5],'description',m[6],'actor_ref',m[7])); end if;
 m:=regexp_match(t,'^case[[:space:]]+task[[:space:]]+update[[:space:]]+([^[:space:]]+)[[:space:]]+(planned|in_progress|blocked|completed|cancelled)[[:space:]]+by[[:space:]]+([^[:space:]]+)(?:[[:space:]]+outcome[[:space:]]+"([^"]*)")?$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','update_case_task','payload',jsonb_build_object('task_ref',m[1],'status',lower(m[2]),'actor_ref',m[3],'outcome',nullif(m[4],''))); end if;
 m:=regexp_match(t,'^case[[:space:]]+task[[:space:]]+assign[[:space:]]+([^[:space:]]+)[[:space:]]+to[[:space:]]+([^[:space:]]+)[[:space:]]+by[[:space:]]+([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','assign_case_task','payload',jsonb_build_object('task_ref',m[1],'assignee_ref',m[2],'actor_ref',m[3])); end if;
 m:=regexp_match(t,'^case[[:space:]]+tasks[[:space:]]+([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','list_case_tasks','payload',jsonb_build_object('case_ref',m[1])); end if;
 m:=regexp_match(t,'^case[[:space:]]+task[[:space:]]+([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','get_case_task','payload',jsonb_build_object('task_ref',m[1])); end if;
 return game.interpret_text_command_before_case_tasks(p_command_text);
end;
$$;