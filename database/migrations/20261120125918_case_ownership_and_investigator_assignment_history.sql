-- Case ownership and investigator assignment history.
create table game.case_assignment_events (
 id uuid primary key default gen_random_uuid(),
 assignment_id uuid not null references game.case_assignments(id),
 case_id uuid not null references game.cases(id),
 event_type text not null check (event_type in ('assigned','released','lead_transferred')),
 actor_personnel_id uuid not null references game.police_personnel(id),
 event_at_game_time timestamptz not null,
 event_data jsonb not null default '{}'::jsonb,
 source_command_id uuid references game.game_commands(id),
 created_at timestamptz not null default now()
);
create index idx_case_assignment_events_case_time on game.case_assignment_events(case_id,event_at_game_time,created_at);
create index idx_case_assignment_events_assignment_time on game.case_assignment_events(assignment_id,event_at_game_time,created_at);
create unique index uq_case_assignments_active_case_role_lead
 on game.case_assignments(case_id) where status='active' and assignment_role='lead_investigator';
create unique index uq_case_assignments_active_person_role
 on game.case_assignments(case_id,personnel_id,assignment_role) where status='active';
alter table game.case_assignment_events enable row level security;
revoke all on game.case_assignment_events from public,anon,authenticated;
grant all on game.case_assignment_events to service_role;

create or replace function game.prevent_case_assignment_event_mutation()
returns trigger language plpgsql set search_path to 'pg_catalog','game'
as $$ begin raise exception 'Case assignment events are append-only'; end $$;
create trigger trg_case_assignment_events_append_only
 before update or delete on game.case_assignment_events
 for each row execute function game.prevent_case_assignment_event_mutation();

create or replace function game.assign_case_investigator(
 p_case_ref text,p_personnel_ref text,p_assignment_role text,p_actor_personnel_ref text,p_source_command_id uuid default null
) returns jsonb language plpgsql set search_path to 'pg_catalog','game'
as $$
declare v_case game.cases%rowtype; v_person game.police_personnel%rowtype; v_actor game.police_personnel%rowtype;
 v_clock timestamptz; v_old game.case_assignments%rowtype; v_new game.case_assignments%rowtype;
begin
 if nullif(btrim(p_case_ref),'') is null or nullif(btrim(p_personnel_ref),'') is null
   or lower(coalesce(p_assignment_role,'')) not in ('lead_investigator','investigator','supervisor','specialist') then
  return jsonb_build_object('ok',false,'code','invalid_assignment','message','Provide a case, personnel reference and role: lead_investigator, investigator, supervisor or specialist.');
 end if;
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional game clock before assigning investigators.'); end if;
 select * into v_case from game.cases where case_ref=btrim(p_case_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference was not found.'); end if;
 if v_case.status='closed' then return jsonb_build_object('ok',false,'code','case_closed','message','Investigators cannot be assigned to a closed case.'); end if;
 select * into v_person from game.police_personnel where personnel_ref=btrim(p_personnel_ref);
 if not found or v_person.employment_status not in ('active','seconded') then
  return jsonb_build_object('ok',false,'code','invalid_personnel','message','The investigator must be active or seconded police personnel.');
 end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_personnel_ref);
 if not found or v_actor.employment_status not in ('active','seconded') then
  return jsonb_build_object('ok',false,'code','invalid_actor','message','The recording officer must be active or seconded police personnel.');
 end if;
 select * into v_old from game.case_assignments where case_id=v_case.id and status='active'
  and assignment_role=lower(p_assignment_role) for update;
 if v_old.id is not null and v_old.personnel_id=v_person.id then
  return jsonb_build_object('ok',true,'already_assigned',true,'case_ref',v_case.case_ref,'personnel_ref',v_person.personnel_ref,'assignment_role',v_old.assignment_role);
 end if;
 if v_old.id is not null then
  update game.case_assignments set status='released',released_at=v_clock where id=v_old.id;
  insert into game.case_assignment_events(assignment_id,case_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id)
  values(v_old.id,v_case.id,'lead_transferred',v_actor.id,v_clock,
   jsonb_build_object('previous_personnel_ref',(select personnel_ref from game.police_personnel where id=v_old.personnel_id),
    'replacement_personnel_ref',v_person.personnel_ref,'assignment_role',v_old.assignment_role),p_source_command_id);
 end if;
 insert into game.case_assignments(case_id,personnel_id,assignment_role,assigned_at,status)
 values(v_case.id,v_person.id,lower(p_assignment_role),v_clock,'active') returning * into v_new;
 insert into game.case_assignment_events(assignment_id,case_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id)
 values(v_new.id,v_case.id,'assigned',v_actor.id,v_clock,
  jsonb_build_object('personnel_ref',v_person.personnel_ref,'assignment_role',v_new.assignment_role),p_source_command_id);
 if v_new.assignment_role='lead_investigator' then update game.cases set lead_personnel_id=v_person.id,updated_at=now() where id=v_case.id; end if;
 return jsonb_build_object('ok',true,'case_ref',v_case.case_ref,'personnel_ref',v_person.personnel_ref,
  'assignment_role',v_new.assignment_role,'assignment_id',v_new.id,'assigned_at_game_time',v_clock);
end $$;

create or replace function game.release_case_investigator(
 p_case_ref text,p_personnel_ref text,p_reason text,p_actor_personnel_ref text,p_source_command_id uuid default null
) returns jsonb language plpgsql set search_path to 'pg_catalog','game'
as $$
declare v_case game.cases%rowtype; v_person game.police_personnel%rowtype; v_actor game.police_personnel%rowtype;
 v_assignment game.case_assignments%rowtype; v_clock timestamptz;
begin
 if nullif(btrim(p_case_ref),'') is null or nullif(btrim(p_personnel_ref),'') is null
  or nullif(btrim(p_reason),'') is null or char_length(p_reason)>2000 then
  return jsonb_build_object('ok',false,'code','invalid_release','message','Provide a case, personnel reference and release reason (maximum 2,000 characters).');
 end if;
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional game clock before releasing investigators.'); end if;
 select * into v_case from game.cases where case_ref=btrim(p_case_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference was not found.'); end if;
 select * into v_person from game.police_personnel where personnel_ref=btrim(p_personnel_ref);
 if not found then return jsonb_build_object('ok',false,'code','personnel_not_found','message','Personnel reference was not found.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_personnel_ref);
 if not found or v_actor.employment_status not in ('active','seconded') then return jsonb_build_object('ok',false,'code','invalid_actor','message','The recording officer must be active or seconded police personnel.'); end if;
 select * into v_assignment from game.case_assignments where case_id=v_case.id and personnel_id=v_person.id and status='active' for update;
 if not found then return jsonb_build_object('ok',false,'code','assignment_not_found','message','No active assignment exists for that investigator on this case.'); end if;
 update game.case_assignments set status='released',released_at=v_clock where id=v_assignment.id;
 insert into game.case_assignment_events(assignment_id,case_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id)
 values(v_assignment.id,v_case.id,'released',v_actor.id,v_clock,
  jsonb_build_object('personnel_ref',v_person.personnel_ref,'assignment_role',v_assignment.assignment_role,'reason',btrim(p_reason)),p_source_command_id);
 if v_assignment.assignment_role='lead_investigator' then
  update game.cases set lead_personnel_id=null,updated_at=now() where id=v_case.id and lead_personnel_id=v_person.id;
 end if;
 return jsonb_build_object('ok',true,'case_ref',v_case.case_ref,'personnel_ref',v_person.personnel_ref,
  'assignment_role',v_assignment.assignment_role,'released_at_game_time',v_clock,'reason',btrim(p_reason));
end $$;

create or replace function game.get_case_assignments(p_case_ref text,p_personnel_ref text default null,p_include_history boolean default true)
returns jsonb language plpgsql stable set search_path to 'pg_catalog','game'
as $$
declare v_rows jsonb;
begin
 if nullif(btrim(p_case_ref),'') is null then raise exception 'A case reference is required'; end if;
 select coalesce(jsonb_agg(to_jsonb(q) order by q.assigned_at desc),'[]'::jsonb) into v_rows
 from (
  select c.case_ref,pp.personnel_ref,pp.service_number,a.assignment_role,a.status,a.assigned_at,a.released_at,
   case when p_include_history then (select coalesce(jsonb_agg(jsonb_build_object(
    'event_type',e.event_type,'actor',ap.personnel_ref,'at_game_time',e.event_at_game_time,'data',e.event_data)
    order by e.event_at_game_time,e.created_at),'[]'::jsonb) from game.case_assignment_events e
    join game.police_personnel ap on ap.id=e.actor_personnel_id where e.assignment_id=a.id) else '[]'::jsonb end history
  from game.case_assignments a join game.cases c on c.id=a.case_id
  join game.police_personnel pp on pp.id=a.personnel_id
  where c.case_ref=btrim(p_case_ref) and (p_personnel_ref is null or pp.personnel_ref=btrim(p_personnel_ref))
 ) q;
 return jsonb_build_object('ok',true,'case_ref',btrim(p_case_ref),'assignments',v_rows,'count',jsonb_array_length(v_rows));
end $$;
revoke all on function game.assign_case_investigator(text,text,text,text,uuid) from public,anon,authenticated;
revoke all on function game.release_case_investigator(text,text,text,text,uuid) from public,anon,authenticated;
revoke all on function game.get_case_assignments(text,text,boolean) from public,anon,authenticated;
grant execute on function game.assign_case_investigator(text,text,text,text,uuid) to service_role;
grant execute on function game.release_case_investigator(text,text,text,text,uuid) to service_role;
grant execute on function game.get_case_assignments(text,text,boolean) to service_role;
