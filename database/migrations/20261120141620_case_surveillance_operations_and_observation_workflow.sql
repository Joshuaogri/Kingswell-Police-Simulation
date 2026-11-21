create table game.surveillance_operations(
 id uuid primary key default gen_random_uuid(), operation_ref text not null unique,
 case_id uuid not null references game.cases(id), objective text not null check(char_length(btrim(objective)) between 5 and 4000),
 subject_description text not null check(char_length(btrim(subject_description)) between 2 and 4000),
 method text not null check(method in ('static_observation','mobile_observation','vehicle_observation','technical_observation','mixed','other')),
 operating_location text not null check(char_length(btrim(operating_location)) between 2 and 1000),
 status text not null default 'planned' check(status in ('planned','deployed','completed','cancelled')),
 created_by_personnel_id uuid not null references game.police_personnel(id),
 created_at_game_time timestamptz not null, deployed_at_game_time timestamptz, closed_at_game_time timestamptz,
 closure_reason text, source_command_id uuid not null references game.game_commands(id), created_at timestamptz not null default now()
);
create table game.surveillance_operation_team(
 id uuid primary key default gen_random_uuid(), operation_id uuid not null references game.surveillance_operations(id),
 personnel_id uuid not null references game.police_personnel(id), team_role text not null check(team_role in ('team_lead','observer','driver','technical_operator','relief','other')),
 assigned_by_personnel_id uuid not null references game.police_personnel(id), assigned_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id), created_at timestamptz not null default now(), unique(operation_id,personnel_id)
);
create table game.surveillance_observations(
 id uuid primary key default gen_random_uuid(), entry_ref text not null unique, operation_id uuid not null references game.surveillance_operations(id),
 entry_type text not null check(entry_type in ('sighting','person_movement','vehicle_movement','arrival','departure','contact','location_change','observation','incident','evidence_recovered','other')),
 location text not null check(char_length(btrim(location)) between 2 and 1000),
 details text not null check(char_length(btrim(details)) between 3 and 8000),
 subject_description text, direction_or_movement text, vehicle_description text,
 recorded_by_personnel_id uuid not null references game.police_personnel(id), observed_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id), created_at timestamptz not null default now()
);
create table game.surveillance_observation_links(
 id uuid primary key default gen_random_uuid(), observation_id uuid not null references game.surveillance_observations(id),
 operation_id uuid not null references game.surveillance_operations(id), entity_type text not null check(entity_type in ('person','evidence','incident','task','lead')),
 entity_ref text not null, reason text not null check(char_length(btrim(reason)) between 2 and 1000),
 linked_by_personnel_id uuid not null references game.police_personnel(id), linked_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id), created_at timestamptz not null default now(), unique(observation_id,entity_type,entity_ref)
);
create table game.surveillance_operation_events(
 id uuid primary key default gen_random_uuid(), operation_id uuid not null references game.surveillance_operations(id),
 event_type text not null check(event_type in ('operation_created','team_member_added','deployment_started','observation_recorded','observation_linked','operation_completed','operation_cancelled')),
 actor_personnel_id uuid not null references game.police_personnel(id), event_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id), event_data jsonb not null default '{}'::jsonb, created_at timestamptz not null default now()
);
create index surveillance_operations_case_time_idx on game.surveillance_operations(case_id,created_at_game_time desc);
create index surveillance_team_operation_idx on game.surveillance_operation_team(operation_id,personnel_id);
create index surveillance_observations_operation_time_idx on game.surveillance_observations(operation_id,observed_at_game_time desc);
create index surveillance_links_observation_idx on game.surveillance_observation_links(observation_id);
create index surveillance_events_operation_time_idx on game.surveillance_operation_events(operation_id,event_at_game_time);
alter table game.surveillance_operations enable row level security;
alter table game.surveillance_operation_team enable row level security;
alter table game.surveillance_observations enable row level security;
alter table game.surveillance_observation_links enable row level security;
alter table game.surveillance_operation_events enable row level security;
revoke all on game.surveillance_operations,game.surveillance_operation_team,game.surveillance_observations,game.surveillance_observation_links,game.surveillance_operation_events from public,anon,authenticated;
grant select,insert,update on game.surveillance_operations to service_role;
grant select,insert on game.surveillance_operation_team,game.surveillance_observations,game.surveillance_observation_links,game.surveillance_operation_events to service_role;
create or replace function game.prevent_surveillance_history_mutation() returns trigger language plpgsql set search_path=pg_catalog,game as $$ begin raise exception 'Surveillance team, observations, links and event history are append-only';end $$;
create trigger surveillance_team_immutable before update or delete on game.surveillance_operation_team for each row execute function game.prevent_surveillance_history_mutation();
create trigger surveillance_observations_immutable before update or delete on game.surveillance_observations for each row execute function game.prevent_surveillance_history_mutation();
create trigger surveillance_links_immutable before update or delete on game.surveillance_observation_links for each row execute function game.prevent_surveillance_history_mutation();
create trigger surveillance_events_immutable before update or delete on game.surveillance_operation_events for each row execute function game.prevent_surveillance_history_mutation();
create or replace function game.create_surveillance_operation(p_case_ref text,p_method text,p_location text,p_objective text,p_subject text,p_actor_ref text,p_command_id uuid)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare c game.cases%rowtype;a game.police_personnel%rowtype;tm timestamptz;o game.surveillance_operations%rowtype;
begin
 select * into c from game.cases where case_ref=btrim(p_case_ref) for update;
 if not found or c.status in ('closed','archived') then return jsonb_build_object('ok',false,'code','case_unavailable','message','The case must exist and remain open.');end if;
 select * into a from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found or (not exists(select 1 from game.case_assignments x where x.case_id=c.id and x.personnel_id=a.id and x.status='active' and x.released_at is null) and c.lead_personnel_id is distinct from a.id) then return jsonb_build_object('ok',false,'code','case_access_denied','message','The planning officer must be active and assigned to the case.');end if;
 select current_game_time into tm from game.simulation_state where id=1 for update;
 if tm is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before planning surveillance.');end if;
 if p_method not in ('static_observation','mobile_observation','vehicle_observation','technical_observation','mixed','other') or char_length(btrim(coalesce(p_location,''))) not between 2 and 1000 or char_length(btrim(coalesce(p_objective,''))) not between 5 and 4000 or char_length(btrim(coalesce(p_subject,''))) not between 2 and 4000 then return jsonb_build_object('ok',false,'code','invalid_plan','message','Method, location, objective or subject description is invalid.');end if;
 insert into game.surveillance_operations(operation_ref,case_id,objective,subject_description,method,operating_location,created_by_personnel_id,created_at_game_time,source_command_id)
 values('KWS-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),c.id,btrim(p_objective),btrim(p_subject),p_method,btrim(p_location),a.id,tm,p_command_id) returning * into o;
 insert into game.surveillance_operation_events(operation_id,event_type,actor_personnel_id,event_at_game_time,source_command_id,event_data) values(o.id,'operation_created',a.id,tm,p_command_id,jsonb_build_object('method',p_method,'location',p_location));
 return jsonb_build_object('ok',true,'operation_ref',o.operation_ref,'case_ref',c.case_ref,'status',o.status,'message','Surveillance operation planned.');
end $$;
create or replace function game.add_surveillance_team_member(p_operation_ref text,p_personnel_ref text,p_role text,p_actor_ref text,p_command_id uuid)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare o game.surveillance_operations%rowtype;a game.police_personnel%rowtype;m game.police_personnel%rowtype;tm timestamptz;
begin
 select * into o from game.surveillance_operations where operation_ref=btrim(p_operation_ref) for update;
 if not found or o.status<>'planned' then return jsonb_build_object('ok',false,'code','operation_not_planned','message','Team can only be assigned before deployment.');end if;
 select * into a from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found or (not exists(select 1 from game.case_assignments x where x.case_id=o.case_id and x.personnel_id=a.id and x.status='active' and x.released_at is null) and not exists(select 1 from game.cases c where c.id=o.case_id and c.lead_personnel_id=a.id)) then return jsonb_build_object('ok',false,'code','case_access_denied','message','The assigning officer must be assigned to the case.');end if;
 select * into m from game.police_personnel where personnel_ref=btrim(p_personnel_ref) and employment_status in ('active','seconded');
 if not found or (not exists(select 1 from game.case_assignments x where x.case_id=o.case_id and x.personnel_id=m.id and x.status='active' and x.released_at is null) and not exists(select 1 from game.cases c where c.id=o.case_id and c.lead_personnel_id=m.id)) then return jsonb_build_object('ok',false,'code','member_not_assigned','message','The team member must be active and assigned to the case.');end if;
 if p_role not in ('team_lead','observer','driver','technical_operator','relief','other') then return jsonb_build_object('ok',false,'code','invalid_role','message','Unsupported surveillance team role.');end if;
 select current_game_time into tm from game.simulation_state where id=1;
 if tm is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock first.');end if;
 insert into game.surveillance_operation_team(operation_id,personnel_id,team_role,assigned_by_personnel_id,assigned_at_game_time,source_command_id) values(o.id,m.id,p_role,a.id,tm,p_command_id) on conflict(operation_id,personnel_id) do nothing;
 if not found then return jsonb_build_object('ok',false,'code','already_assigned','message','That officer is already assigned to this operation.');end if;
 insert into game.surveillance_operation_events(operation_id,event_type,actor_personnel_id,event_at_game_time,source_command_id,event_data) values(o.id,'team_member_added',a.id,tm,p_command_id,jsonb_build_object('personnel_ref',m.personnel_ref,'role',p_role));
 return jsonb_build_object('ok',true,'operation_ref',o.operation_ref,'personnel_ref',m.personnel_ref,'role',p_role,'message','Surveillance team member assigned.');
end $$;
create or replace function game.start_surveillance_operation(p_operation_ref text,p_actor_ref text,p_command_id uuid)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare o game.surveillance_operations%rowtype;a game.police_personnel%rowtype;tm timestamptz;
begin
 select * into o from game.surveillance_operations where operation_ref=btrim(p_operation_ref) for update;
 if not found or o.status<>'planned' then return jsonb_build_object('ok',false,'code','operation_not_planned','message','Only a planned operation can be deployed.');end if;
 select * into a from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found or not exists(select 1 from game.surveillance_operation_team t where t.operation_id=o.id and t.personnel_id=a.id) then return jsonb_build_object('ok',false,'code','not_on_team','message','The deploying officer must be assigned to this surveillance team.');end if;
 if not exists(select 1 from game.surveillance_operation_team where operation_id=o.id) then return jsonb_build_object('ok',false,'code','empty_team','message','Assign at least one team member before deployment.');end if;
 select current_game_time into tm from game.simulation_state where id=1 for update;
 if tm is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock first.');end if;
 update game.surveillance_operations set status='deployed',deployed_at_game_time=tm where id=o.id;
 insert into game.surveillance_operation_events(operation_id,event_type,actor_personnel_id,event_at_game_time,source_command_id) values(o.id,'deployment_started',a.id,tm,p_command_id);
 return jsonb_build_object('ok',true,'operation_ref',o.operation_ref,'status','deployed','deployed_at_game_time',tm,'message','Surveillance deployment started.');
end $$;
create or replace function game.record_surveillance_observation(p_operation_ref text,p_type text,p_location text,p_details text,p_subject text,p_movement text,p_vehicle text,p_actor_ref text,p_command_id uuid)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare o game.surveillance_operations%rowtype;a game.police_personnel%rowtype;tm timestamptz;r game.surveillance_observations%rowtype;
begin
 select * into o from game.surveillance_operations where operation_ref=btrim(p_operation_ref) for update;
 if not found or o.status<>'deployed' then return jsonb_build_object('ok',false,'code','operation_not_deployed','message','Observation can only be recorded during an active deployment.');end if;
 select * into a from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found or not exists(select 1 from game.surveillance_operation_team t where t.operation_id=o.id and t.personnel_id=a.id) then return jsonb_build_object('ok',false,'code','not_on_team','message','Only assigned surveillance team members may record observations.');end if;
 if p_type not in ('sighting','person_movement','vehicle_movement','arrival','departure','contact','location_change','observation','incident','evidence_recovered','other') or char_length(btrim(coalesce(p_location,''))) not between 2 and 1000 or char_length(btrim(coalesce(p_details,''))) not between 3 and 8000 then return jsonb_build_object('ok',false,'code','invalid_observation','message','Observation type, location and details are required.');end if;
 select current_game_time into tm from game.simulation_state where id=1 for update;
 if tm is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock first.');end if;
 insert into game.surveillance_observations(entry_ref,operation_id,entry_type,location,details,subject_description,direction_or_movement,vehicle_description,recorded_by_personnel_id,observed_at_game_time,source_command_id)
 values('KWO-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,10)),o.id,p_type,btrim(p_location),btrim(p_details),nullif(btrim(coalesce(p_subject,'')),''),nullif(btrim(coalesce(p_movement,'')),''),nullif(btrim(coalesce(p_vehicle,'')),''),a.id,tm,p_command_id) returning * into r;
 insert into game.surveillance_operation_events(operation_id,event_type,actor_personnel_id,event_at_game_time,source_command_id,event_data) values(o.id,'observation_recorded',a.id,tm,p_command_id,jsonb_build_object('entry_ref',r.entry_ref,'entry_type',p_type));
 return jsonb_build_object('ok',true,'operation_ref',o.operation_ref,'entry_ref',r.entry_ref,'observed_at_game_time',tm,'message','Surveillance observation recorded.');
end $$;
create or replace function game.link_surveillance_observation(p_entry_ref text,p_entity_type text,p_entity_ref text,p_reason text,p_actor_ref text,p_command_id uuid)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare r game.surveillance_observations%rowtype;o game.surveillance_operations%rowtype;a game.police_personnel%rowtype;tm timestamptz;ok boolean:=false;
begin
 select * into r from game.surveillance_observations where entry_ref=btrim(p_entry_ref);
 if not found then return jsonb_build_object('ok',false,'code','entry_not_found','message','Observation reference not found.');end if;
 select * into o from game.surveillance_operations where id=r.operation_id;
 select * into a from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found or not exists(select 1 from game.surveillance_operation_team t where t.operation_id=o.id and t.personnel_id=a.id) then return jsonb_build_object('ok',false,'code','not_on_team','message','Only assigned team members may link records.');end if;
 if char_length(btrim(coalesce(p_reason,''))) not between 2 and 1000 then return jsonb_build_object('ok',false,'code','invalid_reason','message','A link reason is required.');end if;
 case p_entity_type
 when 'person' then select exists(select 1 from game.case_persons cp join game.persons p on p.id=cp.person_id where cp.case_id=o.case_id and p.person_ref=btrim(p_entity_ref)) into ok;
 when 'evidence' then select exists(select 1 from game.evidence_items e where e.case_id=o.case_id and e.evidence_ref=btrim(p_entity_ref)) into ok;
 when 'incident' then select exists(select 1 from game.case_incidents ci join game.incidents i on i.id=ci.incident_id where ci.case_id=o.case_id and i.incident_ref=btrim(p_entity_ref)) into ok;
 when 'task' then select exists(select 1 from game.case_tasks t where t.case_id=o.case_id and t.task_ref=btrim(p_entity_ref)) into ok;
 when 'lead' then select exists(select 1 from game.case_leads l where l.case_id=o.case_id and l.lead_ref=btrim(p_entity_ref)) into ok;
 else return jsonb_build_object('ok',false,'code','invalid_entity_type','message','Unsupported link type.');end case;
 if not ok then return jsonb_build_object('ok',false,'code','entity_not_in_case','message','The linked reference does not exist in this case.');end if;
 select current_game_time into tm from game.simulation_state where id=1;
 if tm is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock first.');end if;
 insert into game.surveillance_observation_links(observation_id,operation_id,entity_type,entity_ref,reason,linked_by_personnel_id,linked_at_game_time,source_command_id) values(r.id,o.id,p_entity_type,btrim(p_entity_ref),btrim(p_reason),a.id,tm,p_command_id) on conflict(observation_id,entity_type,entity_ref) do nothing;
 if not found then return jsonb_build_object('ok',false,'code','already_linked','message','That record is already linked.');end if;
 insert into game.surveillance_operation_events(operation_id,event_type,actor_personnel_id,event_at_game_time,source_command_id,event_data) values(o.id,'observation_linked',a.id,tm,p_command_id,jsonb_build_object('entry_ref',r.entry_ref,'entity_type',p_entity_type,'entity_ref',p_entity_ref));
 return jsonb_build_object('ok',true,'entry_ref',r.entry_ref,'entity_type',p_entity_type,'entity_ref',p_entity_ref,'message','Observation linked to case record.');
end $$;
create or replace function game.close_surveillance_operation(p_operation_ref text,p_actor_ref text,p_reason text,p_command_id uuid,p_cancel boolean default false)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare o game.surveillance_operations%rowtype;a game.police_personnel%rowtype;tm timestamptz;s text;
begin
 select * into o from game.surveillance_operations where operation_ref=btrim(p_operation_ref) for update;
 if not found or o.status not in ('planned','deployed') then return jsonb_build_object('ok',false,'code','operation_not_open','message','The operation is already closed or unavailable.');end if;
 select * into a from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found or (not exists(select 1 from game.case_assignments x where x.case_id=o.case_id and x.personnel_id=a.id and x.status='active' and x.released_at is null) and not exists(select 1 from game.cases c where c.id=o.case_id and c.lead_personnel_id=a.id)) then return jsonb_build_object('ok',false,'code','case_access_denied','message','The closing officer must be assigned to the case.');end if;
 if char_length(btrim(coalesce(p_reason,''))) not between 2 and 1000 then return jsonb_build_object('ok',false,'code','invalid_reason','message','A closure reason is required.');end if;
 select current_game_time into tm from game.simulation_state where id=1;
 if tm is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock first.');end if;
 s:=case when p_cancel then 'cancelled' else 'completed' end;
 update game.surveillance_operations set status=s,closed_at_game_time=tm,closure_reason=btrim(p_reason) where id=o.id;
 insert into game.surveillance_operation_events(operation_id,event_type,actor_personnel_id,event_at_game_time,source_command_id,event_data) values(o.id,case when p_cancel then 'operation_cancelled' else 'operation_completed' end,a.id,tm,p_command_id,jsonb_build_object('reason',p_reason));
 return jsonb_build_object('ok',true,'operation_ref',o.operation_ref,'status',s,'closed_at_game_time',tm,'message','Surveillance operation closed.');
end $$;
create or replace function game.get_surveillance_operations(p_case_ref text,p_limit integer default 100)
returns jsonb language plpgsql stable set search_path=pg_catalog,game as $$
declare c game.cases%rowtype;ops jsonb;
begin
 select * into c from game.cases where case_ref=btrim(p_case_ref);
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference not found.');end if;
 if p_limit not between 1 and 200 then return jsonb_build_object('ok',false,'code','invalid_limit','message','Limit must be between 1 and 200.');end if;
 select coalesce(jsonb_agg(x.item order by x.created_at desc),'[]'::jsonb) into ops from (
 select o.created_at,jsonb_build_object('operation_ref',o.operation_ref,'objective',o.objective,'subject_description',o.subject_description,'method',o.method,'operating_location',o.operating_location,'status',o.status,'created_at_game_time',o.created_at_game_time,'deployed_at_game_time',o.deployed_at_game_time,'closed_at_game_time',o.closed_at_game_time,'closure_reason',o.closure_reason,
 'team',(select coalesce(jsonb_agg(jsonb_build_object('personnel_ref',p.personnel_ref,'role',t.team_role,'assigned_at_game_time',t.assigned_at_game_time) order by t.created_at),'[]'::jsonb) from game.surveillance_operation_team t join game.police_personnel p on p.id=t.personnel_id where t.operation_id=o.id),
 'observations',(select coalesce(jsonb_agg(jsonb_build_object('entry_ref',r.entry_ref,'type',r.entry_type,'location',r.location,'details',r.details,'subject_description',r.subject_description,'direction_or_movement',r.direction_or_movement,'vehicle_description',r.vehicle_description,'recorded_by',p.personnel_ref,'observed_at_game_time',r.observed_at_game_time,'links',(select coalesce(jsonb_agg(jsonb_build_object('entity_type',l.entity_type,'entity_ref',l.entity_ref,'reason',l.reason)),'[]'::jsonb) from game.surveillance_observation_links l where l.observation_id=r.id)) order by r.observed_at_game_time),'[]'::jsonb) from game.surveillance_observations r join game.police_personnel p on p.id=r.recorded_by_personnel_id where r.operation_id=o.id),
 'events',(select coalesce(jsonb_agg(jsonb_build_object('event_type',e.event_type,'actor',p.personnel_ref,'at',e.event_at_game_time,'data',e.event_data) order by e.event_at_game_time),'[]'::jsonb) from game.surveillance_operation_events e join game.police_personnel p on p.id=e.actor_personnel_id where e.operation_id=o.id)) item
 from game.surveillance_operations o where o.case_id=c.id order by o.created_at desc limit p_limit)x;
 return jsonb_build_object('ok',true,'case_ref',c.case_ref,'operations',ops,'count',jsonb_array_length(ops));
end $$;
revoke all on function game.create_surveillance_operation(text,text,text,text,text,text,uuid),game.add_surveillance_team_member(text,text,text,text,uuid),game.start_surveillance_operation(text,text,uuid),game.record_surveillance_observation(text,text,text,text,text,text,text,text,uuid),game.link_surveillance_observation(text,text,text,text,text,uuid),game.close_surveillance_operation(text,text,text,uuid,boolean),game.get_surveillance_operations(text,integer) from public,anon,authenticated;
grant execute on function game.create_surveillance_operation(text,text,text,text,text,text,uuid),game.add_surveillance_team_member(text,text,text,text,uuid),game.start_surveillance_operation(text,text,uuid),game.record_surveillance_observation(text,text,text,text,text,text,text,text,uuid),game.link_surveillance_observation(text,text,text,text,text,uuid),game.close_surveillance_operation(text,text,text,uuid,boolean),game.get_surveillance_operations(text,integer) to service_role;alter function game.interpret_text_command(text) rename to interpret_text_command_before_surveillance;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path=pg_catalog,game as $$
declare t text:=btrim(coalesce(p_command_text,''));m text[];
begin
 m:=regexp_match(t,'^surveillance plan create ([^[:space:]]+) by ([^[:space:]]+) method ([^[:space:]]+) at "(.+)" objective "(.+)" subject "(.+)"$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','create_surveillance_operation','payload',jsonb_build_object('case_ref',m[1],'actor_ref',m[2],'method',lower(m[3]),'location',m[4],'objective',m[5],'subject',m[6]));end if;
 m:=regexp_match(t,'^surveillance team add ([^[:space:]]+) ([^[:space:]]+) role ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','add_surveillance_team','payload',jsonb_build_object('operation_ref',m[1],'personnel_ref',m[2],'role',lower(m[3]),'actor_ref',m[4]));end if;
 m:=regexp_match(t,'^surveillance deploy ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','start_surveillance_operation','payload',jsonb_build_object('operation_ref',m[1],'actor_ref',m[2]));end if;
 m:=regexp_match(t,'^surveillance log ([^[:space:]]+) by ([^[:space:]]+) type ([^[:space:]]+) at "(.+)" details "(.+)" subject "(.+)" movement "(.+)" vehicle "(.+)"$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','record_surveillance_observation','payload',jsonb_build_object('operation_ref',m[1],'actor_ref',m[2],'entry_type',lower(m[3]),'location',m[4],'details',m[5],'subject',m[6],'movement',m[7],'vehicle',m[8]));end if;
 m:=regexp_match(t,'^surveillance link ([^[:space:]]+) ([^[:space:]]+) ([^[:space:]]+) by ([^[:space:]]+) because "(.+)"$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','link_surveillance_observation','payload',jsonb_build_object('entry_ref',m[1],'entity_type',lower(m[2]),'entity_ref',m[3],'actor_ref',m[4],'reason',m[5]));end if;
 m:=regexp_match(t,'^surveillance close ([^[:space:]]+) by ([^[:space:]]+) because "(.+)"$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','close_surveillance_operation','payload',jsonb_build_object('operation_ref',m[1],'actor_ref',m[2],'reason',m[3]));end if;
 m:=regexp_match(t,'^surveillance cancel ([^[:space:]]+) by ([^[:space:]]+) because "(.+)"$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','cancel_surveillance_operation','payload',jsonb_build_object('operation_ref',m[1],'actor_ref',m[2],'reason',m[3]));end if;
 m:=regexp_match(t,'^surveillance operations ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','get_surveillance_operations','payload',jsonb_build_object('case_ref',m[1],'actor_ref',m[2]));end if;
 return game.interpret_text_command_before_surveillance(p_command_text);
end $$;
alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_surveillance;
create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare i jsonb;typ text;d jsonb;cmd game.game_commands%rowtype;res jsonb;actor game.police_personnel%rowtype;
begin
 i:=game.interpret_text_command(p_command_text);typ:=i->>'command_type';d:=coalesce(i->'payload','{}'::jsonb);
 if typ='help' then res:=game.execute_text_command_before_surveillance(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  return jsonb_set(res,'{available_commands}',(select coalesce(jsonb_agg(distinct x),'[]'::jsonb) from jsonb_array_elements_text(coalesce(res->'available_commands','[]'::jsonb)||jsonb_build_array('create_surveillance_operation','add_surveillance_team','start_surveillance_operation','record_surveillance_observation','link_surveillance_observation','close_surveillance_operation','cancel_surveillance_operation','get_surveillance_operations'))x),true);end if;
 if typ not in ('create_surveillance_operation','add_surveillance_team','start_surveillance_operation','record_surveillance_observation','link_surveillance_observation','close_surveillance_operation','cancel_surveillance_operation','get_surveillance_operations') then return game.execute_text_command_before_surveillance(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key is required';end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload) values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,typ,d) on conflict(idempotency_key) do nothing;
 if not found then select * into cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if cmd.command_text<>p_command_text or cmd.command_type<>typ or cmd.payload<>d then return jsonb_build_object('ok',false,'code','idempotency_conflict','message','Command key already used for a different command.');end if;
  return coalesce(cmd.result,jsonb_build_object('ok',cmd.status='completed'))||jsonb_build_object('duplicate',true);end if;
 select * into cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 select * into actor from game.police_personnel where personnel_ref=btrim(d->>'actor_ref') and employment_status in ('active','seconded');
 if actor.id is null or (p_actor_personnel_id is not null and p_actor_personnel_id<>actor.id) then res:=jsonb_build_object('ok',false,'code','actor_mismatch','message','Named actor must match active or seconded personnel.');
 else
 case typ
 when 'create_surveillance_operation' then res:=game.create_surveillance_operation(d->>'case_ref',d->>'method',d->>'location',d->>'objective',d->>'subject',actor.personnel_ref,cmd.id);
 when 'add_surveillance_team' then res:=game.add_surveillance_team_member(d->>'operation_ref',d->>'personnel_ref',d->>'role',actor.personnel_ref,cmd.id);
 when 'start_surveillance_operation' then res:=game.start_surveillance_operation(d->>'operation_ref',actor.personnel_ref,cmd.id);
 when 'record_surveillance_observation' then res:=game.record_surveillance_observation(d->>'operation_ref',d->>'entry_type',d->>'location',d->>'details',d->>'subject',d->>'movement',d->>'vehicle',actor.personnel_ref,cmd.id);
 when 'link_surveillance_observation' then res:=game.link_surveillance_observation(d->>'entry_ref',d->>'entity_type',d->>'entity_ref',d->>'reason',actor.personnel_ref,cmd.id);
 when 'close_surveillance_operation' then res:=game.close_surveillance_operation(d->>'operation_ref',actor.personnel_ref,d->>'reason',cmd.id,false);
 when 'cancel_surveillance_operation' then res:=game.close_surveillance_operation(d->>'operation_ref',actor.personnel_ref,d->>'reason',cmd.id,true);
 when 'get_surveillance_operations' then
  if exists(select 1 from game.cases c where c.case_ref=d->>'case_ref' and (c.lead_personnel_id=actor.id or exists(select 1 from game.case_assignments a where a.case_id=c.id and a.personnel_id=actor.id and a.status='active' and a.released_at is null))) then res:=game.get_surveillance_operations(d->>'case_ref',100);
  else res:=jsonb_build_object('ok',false,'code','case_access_denied','message','Officer must be assigned to the case.');end if;
 else res:=jsonb_build_object('ok',false,'code','unsupported_command','message','Unsupported surveillance command.');end case;
 end if;
 if coalesce((res->>'ok')::boolean,false) then res:=res||jsonb_build_object('status','completed','command_id',cmd.id);update game.game_commands set status='completed',result=res,completed_at=now() where id=cmd.id;
 else update game.game_commands set status='rejected',result=res,rejection_reason=coalesce(res->>'message','Surveillance command rejected.'),completed_at=now() where id=cmd.id;res:=res||jsonb_build_object('command_id',cmd.id);end if;
 return res;
end $$;
revoke all on function game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) to service_role;do $$
declare d text;old text;new text;
begin
 old:=','||chr(10)||'  ''activities'',game.get_case_activity(v_case.case_ref,500)->''activities'',';
 new:=','||chr(10)||'  ''activities'',game.get_case_activity(v_case.case_ref,500)->''activities'','||chr(10)||'  ''surveillance_operations'',game.get_surveillance_operations(v_case.case_ref,100)->''operations'',';
 select pg_get_functiondef('game.get_case_review_dossier(text)'::regprocedure) into d;
 if position(old in d)=0 then raise exception 'Could not locate dossier activity insertion point';end if;
 execute replace(d,old,new);
end $$;
