-- Case investigative task management.
-- Uses the existing cases and police_personnel records; all timestamps are fictional game time.

create table game.case_tasks (
  id uuid primary key default gen_random_uuid(),
  task_ref text not null unique,
  case_id uuid not null references game.cases(id),
  task_type text not null,
  title text not null,
  description text,
  priority text not null default 'normal' check (priority in ('low','normal','high','urgent')),
  status text not null default 'planned' check (status in ('planned','in_progress','blocked','completed','cancelled')),
  assigned_personnel_id uuid references game.police_personnel(id),
  created_by_personnel_id uuid not null references game.police_personnel(id),
  created_at_game_time timestamptz not null,
  due_at_game_time timestamptz,
  completed_at_game_time timestamptz,
  outcome text,
  updated_at_game_time timestamptz not null,
  updated_by_personnel_id uuid not null references game.police_personnel(id),
  check (due_at_game_time is null or due_at_game_time >= created_at_game_time),
  check ((status in ('completed','cancelled')) = (completed_at_game_time is not null))
);

create table game.case_task_events (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references game.case_tasks(id),
  event_type text not null check (event_type in ('created','assigned','reassigned','status_changed','completed','cancelled','updated')),
  actor_personnel_id uuid not null references game.police_personnel(id),
  event_at_game_time timestamptz not null,
  event_data jsonb not null default '{}'::jsonb,
  source_command_id uuid references game.game_commands(id),
  created_at timestamptz not null default now()
);

create index case_tasks_case_status_idx on game.case_tasks(case_id,status,priority);
create index case_tasks_assignee_status_idx on game.case_tasks(assigned_personnel_id,status) where assigned_personnel_id is not null;
create index case_task_events_task_time_idx on game.case_task_events(task_id,event_at_game_time desc);

alter table game.case_tasks enable row level security;
alter table game.case_task_events enable row level security;
revoke all on game.case_tasks, game.case_task_events from public, anon, authenticated;
grant all on game.case_tasks, game.case_task_events to service_role;

create or replace function game.create_case_task(
 p_case_ref text, p_task_type text, p_title text, p_description text default null,
 p_priority text default 'normal', p_assigned_personnel_ref text default null,
 p_actor_personnel_ref text default null, p_due_at_game_time timestamptz default null,
 p_source_command_id uuid default null
) returns jsonb
language plpgsql set search_path to 'pg_catalog','game'
as $$
declare v_case game.cases%rowtype; v_clock timestamptz; v_actor game.police_personnel%rowtype;
 v_assignee game.police_personnel%rowtype; v_task game.case_tasks%rowtype;
begin
 if nullif(btrim(p_case_ref),'') is null or nullif(btrim(p_task_type),'') is null
   or nullif(btrim(p_title),'') is null or char_length(p_title)>240
   or char_length(coalesce(p_description,''))>4000 then
  return jsonb_build_object('ok',false,'code','invalid_task','message','Provide a case, task type and title (maximum 240 characters); description is limited to 4,000 characters.');
 end if;
 if lower(coalesce(p_priority,'normal')) not in ('low','normal','high','urgent') then
  return jsonb_build_object('ok',false,'code','invalid_priority','message','Priority must be low, normal, high or urgent.');
 end if;
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional game clock before creating investigative tasks.'); end if;
 select * into v_case from game.cases where case_ref=btrim(p_case_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference was not found.'); end if;
 if v_case.status='closed' then return jsonb_build_object('ok',false,'code','case_closed','message','A task cannot be created on a closed case. Reopen the case first.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_personnel_ref);
 if not found or v_actor.employment_status not in ('active','seconded') then
  return jsonb_build_object('ok',false,'code','invalid_actor','message','The recording officer must be active or seconded police personnel.');
 end if;
 if p_assigned_personnel_ref is not null then
  select * into v_assignee from game.police_personnel where personnel_ref=btrim(p_assigned_personnel_ref);
  if not found or v_assignee.employment_status not in ('active','seconded') then
   return jsonb_build_object('ok',false,'code','invalid_assignee','message','The assigned investigator must be active or seconded police personnel.');
  end if;
 end if;
 if p_due_at_game_time is not null and p_due_at_game_time<v_clock then
  return jsonb_build_object('ok',false,'code','invalid_due_time','message','A new task due time cannot be earlier than the current fictional time.');
 end if;
 insert into game.case_tasks(task_ref,case_id,task_type,title,description,priority,assigned_personnel_id,
  created_by_personnel_id,created_at_game_time,due_at_game_time,updated_at_game_time,updated_by_personnel_id)
 values('KWT-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),v_case.id,lower(btrim(p_task_type)),
  btrim(p_title),nullif(btrim(p_description),''),lower(coalesce(p_priority,'normal')),v_assignee.id,
  v_actor.id,v_clock,p_due_at_game_time,v_clock,v_actor.id)
 returning * into v_task;
 insert into game.case_task_events(task_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id)
 values(v_task.id,'created',v_actor.id,v_clock,jsonb_build_object('case_ref',v_case.case_ref,'task_type',v_task.task_type,
  'title',v_task.title,'priority',v_task.priority,'assigned_personnel_ref',v_assignee.personnel_ref),p_source_command_id);
 return jsonb_build_object('ok',true,'task_ref',v_task.task_ref,'case_ref',v_case.case_ref,'status',v_task.status,
  'priority',v_task.priority,'assigned_to',v_assignee.personnel_ref,'created_at_game_time',v_clock);
end;
$$;

create or replace function game.update_case_task(
 p_task_ref text, p_status text, p_outcome text default null,
 p_assigned_personnel_ref text default null, p_actor_personnel_ref text default null,
 p_source_command_id uuid default null
) returns jsonb
language plpgsql set search_path to 'pg_catalog','game'
as $$
declare v_task game.case_tasks%rowtype; v_actor game.police_personnel%rowtype;
 v_assignee game.police_personnel%rowtype; v_clock timestamptz; v_event text; v_old_status text; v_old_assignee text;
begin
 if nullif(btrim(p_task_ref),'') is null or lower(coalesce(p_status,'')) not in ('planned','in_progress','blocked','completed','cancelled') then
  return jsonb_build_object('ok',false,'code','invalid_task_update','message','Provide a task reference and valid status: planned, in_progress, blocked, completed or cancelled.');
 end if;
 if char_length(coalesce(p_outcome,''))>4000 then return jsonb_build_object('ok',false,'code','outcome_too_long','message','Task outcome is limited to 4,000 characters.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional game clock before updating investigative tasks.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_personnel_ref);
 if not found or v_actor.employment_status not in ('active','seconded') then
  return jsonb_build_object('ok',false,'code','invalid_actor','message','The recording officer must be active or seconded police personnel.');
 end if;
 select * into v_task from game.case_tasks where task_ref=btrim(p_task_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','task_not_found','message','Task reference was not found.'); end if;
 if v_task.status in ('completed','cancelled') then return jsonb_build_object('ok',false,'code','task_final','message','Completed or cancelled tasks are final; create a new task if further work is required.'); end if;
 if p_assigned_personnel_ref is not null then
  select * into v_assignee from game.police_personnel where personnel_ref=btrim(p_assigned_personnel_ref);
  if not found or v_assignee.employment_status not in ('active','seconded') then
   return jsonb_build_object('ok',false,'code','invalid_assignee','message','The assigned investigator must be active or seconded police personnel.');
  end if;
 end if;
 v_old_status:=v_task.status;
 select personnel_ref into v_old_assignee from game.police_personnel where id=v_task.assigned_personnel_id;
 update game.case_tasks set status=lower(p_status),
  assigned_personnel_id=case when p_assigned_personnel_ref is null then assigned_personnel_id else v_assignee.id end,
  outcome=coalesce(nullif(btrim(p_outcome),''),outcome),
  completed_at_game_time=case when lower(p_status) in ('completed','cancelled') then v_clock else null end,
  updated_at_game_time=v_clock,updated_by_personnel_id=v_actor.id
 where id=v_task.id returning * into v_task;
 v_event:=case when v_task.status='completed' then 'completed' when v_task.status='cancelled' then 'cancelled'
  when v_old_status<>v_task.status then 'status_changed'
  when p_assigned_personnel_ref is not null and v_old_assignee is distinct from v_assignee.personnel_ref then 'reassigned'
  else 'updated' end;
 insert into game.case_task_events(task_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id)
 values(v_task.id,v_event,v_actor.id,v_clock,jsonb_build_object('previous_status',v_old_status,'status',v_task.status,
  'previous_assignee',v_old_assignee,'assigned_to',coalesce(v_assignee.personnel_ref,v_old_assignee),
  'outcome',nullif(btrim(p_outcome),'')),p_source_command_id);
 return jsonb_build_object('ok',true,'task_ref',v_task.task_ref,'status',v_task.status,'assigned_to',coalesce(v_assignee.personnel_ref,v_old_assignee),
  'completed_at_game_time',v_task.completed_at_game_time);
end;
$$;

create or replace function game.get_case_tasks(p_case_ref text default null,p_task_ref text default null,p_limit integer default 100)
returns jsonb language plpgsql stable set search_path to 'pg_catalog','game'
as $$
declare v_tasks jsonb;
begin
 if p_limit is null or p_limit<1 or p_limit>500 then raise exception 'Task result limit must be between 1 and 500'; end if;
 if p_case_ref is null and p_task_ref is null then raise exception 'A case reference or task reference is required'; end if;
 select coalesce(jsonb_agg(to_jsonb(q) order by q.created_at_game_time desc),'[]'::jsonb) into v_tasks
 from (
  select t.task_ref,c.case_ref,t.task_type,t.title,t.description,t.priority,t.status,
   a.personnel_ref as assigned_to,cr.personnel_ref as created_by,t.created_at_game_time,t.due_at_game_time,
   t.completed_at_game_time,t.outcome,t.updated_at_game_time,
   (select coalesce(jsonb_agg(jsonb_build_object('event_type',e.event_type,'actor',ep.personnel_ref,
     'at_game_time',e.event_at_game_time,'data',e.event_data) order by e.event_at_game_time,e.created_at),'[]'::jsonb)
    from game.case_task_events e join game.police_personnel ep on ep.id=e.actor_personnel_id where e.task_id=t.id) as history
  from game.case_tasks t join game.cases c on c.id=t.case_id
  left join game.police_personnel a on a.id=t.assigned_personnel_id
  join game.police_personnel cr on cr.id=t.created_by_personnel_id
  where (p_case_ref is null or c.case_ref=btrim(p_case_ref)) and (p_task_ref is null or t.task_ref=btrim(p_task_ref))
  order by t.created_at_game_time desc limit p_limit
 ) q;
 return jsonb_build_object('ok',true,'tasks',v_tasks,'count',jsonb_array_length(v_tasks));
end;
$$;

revoke all on function game.create_case_task(text,text,text,text,text,text,text,timestamptz,uuid) from public,anon,authenticated;
revoke all on function game.update_case_task(text,text,text,text,text,uuid) from public,anon,authenticated;
revoke all on function game.get_case_tasks(text,text,integer) from public,anon,authenticated;
grant execute on function game.create_case_task(text,text,text,text,text,text,text,timestamptz,uuid) to service_role;
grant execute on function game.update_case_task(text,text,text,text,text,uuid) to service_role;
grant execute on function game.get_case_tasks(text,text,integer) to service_role;
