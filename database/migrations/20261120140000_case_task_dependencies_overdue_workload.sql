create table game.case_task_dependencies (
 id uuid primary key default gen_random_uuid(), dependency_ref text not null unique,
 task_id uuid not null references game.case_tasks(id), prerequisite_task_id uuid not null references game.case_tasks(id),
 created_by_personnel_id uuid not null references game.police_personnel(id), created_at_game_time timestamptz not null,
 source_command_id uuid references game.game_commands(id), check(task_id<>prerequisite_task_id), unique(task_id,prerequisite_task_id));
create index case_task_dependencies_task_idx on game.case_task_dependencies(task_id);
create index case_task_dependencies_prerequisite_idx on game.case_task_dependencies(prerequisite_task_id);
alter table game.case_task_dependencies enable row level security;
revoke all on game.case_task_dependencies from public,anon,authenticated;
grant select,insert on game.case_task_dependencies to service_role;
create or replace function game.prevent_case_task_dependency_mutation() returns trigger language plpgsql set search_path=pg_catalog,game as $$ begin raise exception 'Case task dependencies are immutable'; end $$;
create trigger case_task_dependencies_immutable before update or delete on game.case_task_dependencies for each row execute function game.prevent_case_task_dependency_mutation();
create or replace function game.add_case_task_dependency(p_task_ref text,p_prerequisite_ref text,p_actor_ref text,p_source_command_id uuid default null)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare v_task game.case_tasks%rowtype;v_pre game.case_tasks%rowtype;v_actor game.police_personnel%rowtype;v_clock timestamptz;v_ref text;
begin
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before changing task dependencies.');end if;
 select * into v_task from game.case_tasks where task_ref=btrim(p_task_ref) for update;
 select * into v_pre from game.case_tasks where task_ref=btrim(p_prerequisite_ref);
 if v_task.id is null or v_pre.id is null then return jsonb_build_object('ok',false,'code','task_not_found','message','Both task references must exist.');end if;
 if v_task.case_id<>v_pre.case_id then return jsonb_build_object('ok',false,'code','different_cases','message','A task dependency must belong to the same case.');end if;
 if v_task.id=v_pre.id then return jsonb_build_object('ok',false,'code','dependency_cycle','message','A task cannot depend on itself.');end if;
 if v_task.status in ('completed','cancelled','in_progress') then return jsonb_build_object('ok',false,'code','task_already_started','message','Dependencies must be recorded before a task starts or is completed.');end if;
 if exists(with recursive chain(id) as (select prerequisite_task_id from game.case_task_dependencies where task_id=v_pre.id union all select d.prerequisite_task_id from game.case_task_dependencies d join chain c on d.task_id=c.id) select 1 from chain where id=v_task.id) then return jsonb_build_object('ok',false,'code','dependency_cycle','message','This dependency would create a circular task chain.');end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref);
 if not found or v_actor.employment_status not in ('active','seconded') then return jsonb_build_object('ok',false,'code','invalid_actor','message','The recording officer must be active or seconded personnel.');end if;
 if exists(select 1 from game.case_task_dependencies where task_id=v_task.id and prerequisite_task_id=v_pre.id) then return jsonb_build_object('ok',true,'already_linked',true,'task_ref',v_task.task_ref,'prerequisite_ref',v_pre.task_ref);end if;
 v_ref:='KWD-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10));
 insert into game.case_task_dependencies(dependency_ref,task_id,prerequisite_task_id,created_by_personnel_id,created_at_game_time,source_command_id) values(v_ref,v_task.id,v_pre.id,v_actor.id,v_clock,p_source_command_id);
 insert into game.case_task_events(task_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(v_task.id,'dependency_added',v_actor.id,v_clock,jsonb_build_object('dependency_ref',v_ref,'prerequisite_task_ref',v_pre.task_ref),p_source_command_id);
 return jsonb_build_object('ok',true,'dependency_ref',v_ref,'task_ref',v_task.task_ref,'prerequisite_ref',v_pre.task_ref);
end $$;
create or replace function game.enforce_case_task_dependencies() returns trigger language plpgsql set search_path=pg_catalog,game as $$
declare v_blocked jsonb;
begin
 if new.status in ('in_progress','completed') and old.status is distinct from new.status then
  select coalesce(jsonb_agg(jsonb_build_object('task_ref',p.task_ref,'title',p.title,'status',p.status) order by p.task_ref),'[]'::jsonb) into v_blocked
  from game.case_task_dependencies d join game.case_tasks p on p.id=d.prerequisite_task_id where d.task_id=new.id and p.status<>'completed';
  if jsonb_array_length(v_blocked)>0 then raise exception 'Task cannot start or complete: prerequisite tasks remain incomplete: %',v_blocked;end if;
 end if;return new;
end $$;
create trigger case_tasks_dependency_gate before update of status on game.case_tasks for each row execute function game.enforce_case_task_dependencies();
create or replace function game.get_case_task_workload(p_case_ref text default null,p_personnel_ref text default null,p_limit integer default 500)
returns jsonb language plpgsql stable set search_path=pg_catalog,game as $$
declare v_clock timestamptz;v_tasks jsonb;v_people jsonb;
begin
 if p_limit not between 1 and 500 then raise exception 'Workload limit must be between 1 and 500';end if;
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before calculating overdue tasks.');end if;
 if p_case_ref is null and p_personnel_ref is null then
  select coalesce(jsonb_agg(jsonb_build_object('personnel_ref',p.personnel_ref,'name',p.full_name,'active_tasks',x.active_tasks,'overdue_tasks',x.overdue_tasks,'urgent_tasks',x.urgent_tasks) order by x.overdue_tasks desc,x.active_tasks desc,p.personnel_ref),'[]'::jsonb)
  into v_people from (select assigned_personnel_id,count(*) filter(where status not in ('completed','cancelled')) active_tasks,count(*) filter(where status not in ('completed','cancelled') and due_at_game_time<v_clock) overdue_tasks,count(*) filter(where status not in ('completed','cancelled') and priority='urgent') urgent_tasks from game.case_tasks group by assigned_personnel_id) x join game.police_personnel p on p.id=x.assigned_personnel_id;
 end if;
 select coalesce(jsonb_agg(jsonb_build_object('task_ref',t.task_ref,'case_ref',c.case_ref,'title',t.title,'task_type',t.task_type,'priority',t.priority,'status',t.status,'assigned_to',a.personnel_ref,'due_at_game_time',t.due_at_game_time,'overdue',t.status not in ('completed','cancelled') and t.due_at_game_time<v_clock,'minutes_overdue',case when t.status not in ('completed','cancelled') and t.due_at_game_time<v_clock then floor(extract(epoch from (v_clock-t.due_at_game_time))/60)::bigint else 0 end,'blocked_by',(select coalesce(jsonb_agg(jsonb_build_object('task_ref',pt.task_ref,'title',pt.title,'status',pt.status)),'[]'::jsonb) from game.case_task_dependencies d join game.case_tasks pt on pt.id=d.prerequisite_task_id where d.task_id=t.id and pt.status<>'completed')) order by case t.priority when 'urgent' then 1 when 'high' then 2 when 'normal' then 3 else 4 end,t.due_at_game_time nulls last,t.created_at_game_time),'[]'::jsonb)
 into v_tasks from game.case_tasks t join game.cases c on c.id=t.case_id left join game.police_personnel a on a.id=t.assigned_personnel_id
 where (p_case_ref is null or c.case_ref=btrim(p_case_ref)) and (p_personnel_ref is null or a.personnel_ref=btrim(p_personnel_ref)) and t.status not in ('completed','cancelled') limit p_limit;
 return jsonb_build_object('ok',true,'fictional_time',v_clock,'tasks',v_tasks,'count',jsonb_array_length(v_tasks),'personnel_workload',coalesce(v_people,'[]'::jsonb),'overdue_count',(select count(*) from game.case_tasks t join game.cases c on c.id=t.case_id left join game.police_personnel a on a.id=t.assigned_personnel_id where t.status not in ('completed','cancelled') and t.due_at_game_time<v_clock and (p_case_ref is null or c.case_ref=btrim(p_case_ref)) and (p_personnel_ref is null or a.personnel_ref=btrim(p_personnel_ref))));
end $$;
revoke all on function game.add_case_task_dependency(text,text,text,uuid),game.get_case_task_workload(text,text,integer),game.enforce_case_task_dependencies(),game.prevent_case_task_dependency_mutation() from public,anon,authenticated;
grant execute on function game.add_case_task_dependency(text,text,text,uuid),game.get_case_task_workload(text,text,integer) to service_role;