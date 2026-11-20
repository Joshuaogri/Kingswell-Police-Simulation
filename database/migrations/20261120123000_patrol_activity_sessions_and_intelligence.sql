create table game.patrol_activity_sessions (
 id uuid primary key default gen_random_uuid(),
 session_ref text not null unique,
 unit_id uuid not null references game.police_units(id),
 personnel_id uuid not null references game.police_personnel(id),
 beat_id uuid not null references game.patrol_beats(id),
 schedule_id uuid not null references game.patrol_schedules(id),
 activity_type text not null check (activity_type in ('foot_patrol','stationary_observation','community_engagement','business_visit','area_check','vehicle_patrol_stop','other')),
 location_access_point_id uuid not null references game.property_access_points(id),
 started_at_game_time timestamptz not null,
 ended_at_game_time timestamptz,
 status text not null default 'active' check (status in ('active','completed')),
 reason text not null check (length(btrim(reason))>0),
 details text,
 end_reason text,
 created_at timestamptz not null default now(),
 check ((status='active' and ended_at_game_time is null) or (status='completed' and ended_at_game_time is not null)),
 check (ended_at_game_time is null or ended_at_game_time>started_at_game_time)
);
create unique index patrol_activity_one_active_unit_idx on game.patrol_activity_sessions(unit_id) where status='active';
create unique index patrol_activity_one_active_officer_idx on game.patrol_activity_sessions(personnel_id) where status='active';
create index patrol_activity_beat_time_idx on game.patrol_activity_sessions(beat_id,started_at_game_time desc);
create index patrol_activity_unit_time_idx on game.patrol_activity_sessions(unit_id,started_at_game_time desc);

create table game.patrol_activity_events (
 id uuid primary key default gen_random_uuid(),
 session_id uuid not null references game.patrol_activity_sessions(id),
 event_type text not null check (event_type in ('activity_started','activity_completed')),
 event_time_game_time timestamptz not null,
 command_id uuid references game.game_commands(id),
 details jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now()
);
create index patrol_activity_events_session_idx on game.patrol_activity_events(session_id,event_time_game_time);

alter table game.patrol_activity_sessions enable row level security;
alter table game.patrol_activity_events enable row level security;
revoke all on game.patrol_activity_sessions,game.patrol_activity_events from public,anon,authenticated;
grant select,insert,update on game.patrol_activity_sessions to service_role;
grant select,insert on game.patrol_activity_events to service_role;

create or replace function game.reject_patrol_activity_event_mutation()
returns trigger language plpgsql set search_path to ''
as $f$ begin raise exception 'Patrol activity event history is append-only'; end; $f$;
create trigger patrol_activity_events_append_only
before update or delete on game.patrol_activity_events
for each row execute function game.reject_patrol_activity_event_mutation();

create or replace function game.guard_active_patrol_activity()
returns trigger language plpgsql set search_path to ''
as $f$
begin
 if (new.operational_state is distinct from old.operational_state and new.operational_state<>'on_patrol')
    or new.current_access_point_id is distinct from old.current_access_point_id then
  if exists(select 1 from game.patrol_activity_sessions s where s.unit_id=old.id and s.status='active') then
   raise exception 'End the active patrol activity before moving the unit or ending patrol';
  end if;
 end if;
 return new;
end;$f$;
create trigger police_units_active_patrol_activity_guard
before update of operational_state,current_access_point_id on game.police_units
for each row execute function game.guard_active_patrol_activity();

create or replace function game.start_patrol_activity(
 p_command_id uuid,p_unit_ref text,p_personnel_ref text,p_access_ref text,
 p_activity_type text,p_reason text,p_details text default null
) returns jsonb language plpgsql set search_path to ''
as $f$
declare clk timestamptz; u game.police_units%rowtype; officer game.police_personnel%rowtype;
 sch game.patrol_schedules%rowtype; beat game.patrol_beats%rowtype; access_id uuid; session_id uuid; new_ref text;
begin
 if p_command_id is null then raise exception 'Command identifier is required'; end if;
 if nullif(btrim(p_reason),'') is null then raise exception 'Activity reason is required'; end if;
 if p_activity_type not in ('foot_patrol','stationary_observation','community_engagement','business_visit','area_check','vehicle_patrol_stop','other') then raise exception 'Unsupported patrol activity type'; end if;
 select current_game_time into clk from game.simulation_state where id=1 for update;
 if clk is null then raise exception 'Fictional clock is not initialized'; end if;
 select * into u from game.police_units where unit_ref=p_unit_ref and status='active' for update;
 if not found or u.operational_state<>'on_patrol' then raise exception 'Unit must be active and on patrol'; end if;
 select * into sch from game.patrol_schedules where unit_id=u.id and status='active' and starts_at<=clk and ends_at>clk order by starts_at desc limit 1 for update;
 if not found then raise exception 'Unit has no active patrol schedule at current fictional time'; end if;
 select * into beat from game.patrol_beats where id=sch.beat_id and status='active';
 if not found then raise exception 'Assigned patrol beat is not active'; end if;
 select * into officer from game.police_personnel where personnel_ref=p_personnel_ref and employment_status='active' for update;
 if not found or officer.current_unit_id is distinct from u.id then raise exception 'Officer must be active and assigned to this patrol unit'; end if;
 select id into access_id from game.property_access_points where access_ref=p_access_ref and is_primary;
 if access_id is null then raise exception 'Activity location access point was not found'; end if;
 if u.current_access_point_id is distinct from access_id then raise exception 'Activity location must match the unit current recorded location'; end if;
 if not exists(select 1 from game.patrol_beat_road_segments br join game.property_access_points ap on ap.road_segment_id=br.road_segment_id where br.beat_id=beat.id and ap.id=access_id) then raise exception 'Activity location is outside the assigned patrol beat'; end if;
 if exists(select 1 from game.patrol_activity_sessions where (unit_id=u.id or personnel_id=officer.id) and status='active') then raise exception 'Unit or officer already has an active patrol activity'; end if;
 new_ref:='KPA-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
 insert into game.patrol_activity_sessions(session_ref,unit_id,personnel_id,beat_id,schedule_id,activity_type,location_access_point_id,started_at_game_time,reason,details)
 values(new_ref,u.id,officer.id,beat.id,sch.id,p_activity_type,access_id,clk,btrim(p_reason),nullif(btrim(p_details),'')) returning id into session_id;
 insert into game.patrol_activity_events(session_id,event_type,event_time_game_time,command_id,details)
 values(session_id,'activity_started',clk,p_command_id,jsonb_build_object('activity_type',p_activity_type,'reason',btrim(p_reason),'location_access_point_id',access_id));
 insert into game.game_events(event_key,game_time,entity_type,entity_id,event_data)
 values('patrol.activity.started.'||replace(p_command_id::text,'-',''),clk,'police_unit',u.id,jsonb_build_object('session_ref',new_ref,'personnel_ref',officer.personnel_ref,'activity_type',p_activity_type,'reason',btrim(p_reason)));
 return jsonb_build_object('session_ref',new_ref,'unit_ref',u.unit_ref,'personnel_ref',officer.personnel_ref,'beat_ref',beat.beat_ref,'activity_type',p_activity_type,'location_access_ref',p_access_ref,'status','active','started_at',clk,'game_time',clk);
end;$f$;

create or replace function game.end_patrol_activity(p_command_id uuid,p_session_ref text,p_duration_minutes integer,p_reason text)
returns jsonb language plpgsql set search_path to ''
as $f$
declare clk timestamptz; s game.patrol_activity_sessions%rowtype; sch game.patrol_schedules%rowtype; ending timestamptz; u game.police_units%rowtype;
begin
 if p_command_id is null then raise exception 'Command identifier is required'; end if;
 if p_duration_minutes is null or p_duration_minutes<1 or p_duration_minutes>720 then raise exception 'Activity duration must be between 1 and 720 minutes'; end if;
 if nullif(btrim(p_reason),'') is null then raise exception 'Activity completion reason is required'; end if;
 select current_game_time into clk from game.simulation_state where id=1 for update;
 if clk is null then raise exception 'Fictional clock is not initialized'; end if;
 select * into s from game.patrol_activity_sessions where session_ref=p_session_ref and status='active' for update;
 if not found then raise exception 'Active patrol activity session not found'; end if;
 select * into sch from game.patrol_schedules where id=s.schedule_id and status='active' for update;
 if not found then raise exception 'Patrol schedule is no longer active'; end if;
 ending:=clk+make_interval(mins=>p_duration_minutes);
 if ending>sch.ends_at then raise exception 'Activity duration would exceed the active patrol schedule'; end if;
 select * into u from game.police_units where id=s.unit_id for update;
 update game.patrol_activity_sessions set status='completed',ended_at_game_time=ending,end_reason=btrim(p_reason) where id=s.id;
 insert into game.patrol_activity_events(session_id,event_type,event_time_game_time,command_id,details)
 values(s.id,'activity_completed',ending,p_command_id,jsonb_build_object('duration_minutes',p_duration_minutes,'reason',btrim(p_reason)));
 update game.simulation_state set current_game_time=ending,updated_at=now() where id=1;
 insert into game.game_clock_history(command_id,previous_game_time,resulting_game_time,advancement_minutes,reason)
 values(p_command_id,clk,ending,p_duration_minutes,'Patrol activity: '||btrim(p_reason));
 insert into game.game_events(event_key,game_time,entity_type,entity_id,event_data)
 values('patrol.activity.completed.'||replace(p_command_id::text,'-',''),ending,'police_unit',s.unit_id,jsonb_build_object('session_ref',s.session_ref,'activity_type',s.activity_type,'duration_minutes',p_duration_minutes,'reason',btrim(p_reason)));
 return jsonb_build_object('session_ref',s.session_ref,'unit_ref',u.unit_ref,'activity_type',s.activity_type,'status','completed','started_at',s.started_at_game_time,'ended_at',ending,'duration_minutes',p_duration_minutes,'game_time',ending);
end;$f$;

revoke all on function game.start_patrol_activity(uuid,text,text,text,text,text,text) from public,anon,authenticated;
revoke all on function game.end_patrol_activity(uuid,text,integer,text) from public,anon,authenticated;
grant execute on function game.start_patrol_activity(uuid,text,text,text,text,text,text) to service_role;
grant execute on function game.end_patrol_activity(uuid,text,integer,text) to service_role;

alter function game.get_patrol_intelligence(timestamptz,timestamptz) rename to get_patrol_intelligence_before_activity;
create or replace function game.get_patrol_intelligence(p_since timestamptz default null,p_until timestamptz default null)
returns jsonb language plpgsql stable set search_path to ''
as $f$
declare base jsonb; v_now timestamptz; v_from timestamptz; v_to timestamptz; activities jsonb; unit_activities jsonb; totals jsonb;
begin
 base:=game.get_patrol_intelligence_before_activity(p_since,p_until);
 select current_game_time into v_now from game.simulation_state where id=1;
 v_to:=coalesce(p_until,v_now); v_from:=coalesce(p_since,'-infinity'::timestamptz);
 select coalesce(jsonb_agg(jsonb_build_object('activity_type',a.activity_type,'sessions',a.sessions,'completed_sessions',a.completed_sessions,'activity_minutes',a.activity_minutes) order by a.activity_type),'[]'::jsonb)
 into activities from (
  select activity_type,count(*)::integer sessions,count(*) filter(where status='completed')::integer completed_sessions,
   round(coalesce(sum(extract(epoch from (coalesce(ended_at_game_time,started_at_game_time)-started_at_game_time))/60.0),0),1) activity_minutes
  from game.patrol_activity_sessions where started_at_game_time>=v_from and started_at_game_time<=v_to group by activity_type
 ) a;
 select coalesce(jsonb_agg(jsonb_build_object('unit_ref',x.unit_ref,'activity_sessions',x.sessions,'activity_minutes',x.minutes,'foot_patrol_minutes',x.foot_minutes,'stationary_observation_minutes',x.observation_minutes) order by x.minutes desc,x.unit_ref),'[]'::jsonb)
 into unit_activities from (
  select u.unit_ref,count(s.id)::integer sessions,
   round(coalesce(sum(extract(epoch from (coalesce(s.ended_at_game_time,s.started_at_game_time)-s.started_at_game_time))/60.0),0),1) minutes,
   round(coalesce(sum(extract(epoch from (coalesce(s.ended_at_game_time,s.started_at_game_time)-s.started_at_game_time)) filter(where s.activity_type='foot_patrol')/60.0,0),1) foot_minutes,
   round(coalesce(sum(extract(epoch from (coalesce(s.ended_at_game_time,s.started_at_game_time)-s.started_at_game_time)) filter(where s.activity_type='stationary_observation')/60.0,0),1) observation_minutes
  from game.police_units u join game.patrol_activity_sessions s on s.unit_id=u.id
  where s.started_at_game_time>=v_from and s.started_at_game_time<=v_to group by u.id,u.unit_ref
 ) x;
 totals:=coalesce(base->'totals','{}'::jsonb)||jsonb_build_object(
  'patrol_activity_sessions',(select count(*) from game.patrol_activity_sessions where started_at_game_time>=v_from and started_at_game_time<=v_to),
  'patrol_activity_minutes',(select round(coalesce(sum(extract(epoch from (coalesce(ended_at_game_time,started_at_game_time)-started_at_game_time))/60.0),0),1) from game.patrol_activity_sessions where started_at_game_time>=v_from and started_at_game_time<=v_to)
 );
 return base||jsonb_build_object('activity_by_type',activities,'unit_patrol_activity',unit_activities,'totals',totals);
end;$f$;
revoke all on function game.get_patrol_intelligence(timestamptz,timestamptz) from public,anon,authenticated;
grant execute on function game.get_patrol_intelligence(timestamptz,timestamptz) to service_role;

alter function game.interpret_text_command(text) rename to interpret_text_command_before_activity;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game'
as $f$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^start[[:space:]]+patrol[[:space:]]+activity[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+by[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+at[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+type[[:space:]]+(foot_patrol|stationary_observation|community_engagement|business_visit|area_check|vehicle_patrol_stop|other)[[:space:]]+because[[:space:]]+(.+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','start_patrol_activity','payload',jsonb_build_object('unit_ref',m[1],'personnel_ref',m[2],'access_ref',m[3],'activity_type',lower(m[4]),'reason',btrim(m[5]))); end if;
 m:=regexp_match(t,'^end[[:space:]]+patrol[[:space:]]+activity[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+after[[:space:]]+([0-9]+)[[:space:]]+minutes[[:space:]]+because[[:space:]]+(.+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','end_patrol_activity','payload',jsonb_build_object('session_ref',m[1],'duration_minutes',m[2]::integer,'reason',btrim(m[3]))); end if;
 if lower(t) in ('patrol intelligence','patrol gaps','patrol analysis') then return jsonb_build_object('recognized',true,'command_type','patrol_intelligence','payload','{}'::jsonb); end if;
 m:=regexp_match(t,'^patrol[[:space:]]+move[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+to[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+because[[:space:]]+(.+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','patrol_move','payload',jsonb_build_object('unit_ref',m[1],'destination_access_ref',m[2],'reason',btrim(m[3]))); end if;
 return game.interpret_text_command_before_activity(p_command_text);
end;$f$;
revoke all on function game.interpret_text_command(text) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text) to service_role;

do $patch$
declare def text; marker text; injected text; help_old text; help_new text;
begin
 def:=pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure);
 marker:=$m$  elsif v_type='patrol_intelligence' then
    v_result:=jsonb_build_object('ok',true,'status','completed','command_id',v_command.id,'intelligence',game.get_patrol_intelligence());
$m$;
 injected:=$i$  elsif v_type='start_patrol_activity' then
    v_result:=game.start_patrol_activity(v_command.id,p_payload->>'unit_ref',p_payload->>'personnel_ref',p_payload->>'access_ref',p_payload->>'activity_type',p_payload->>'reason',p_payload->>'details') || jsonb_build_object('ok',true,'status','completed','command_id',v_command.id);
  elsif v_type='end_patrol_activity' then
    v_result:=game.end_patrol_activity(v_command.id,p_payload->>'session_ref',(p_payload->>'duration_minutes')::integer,p_payload->>'reason') || jsonb_build_object('ok',true,'status','completed','command_id',v_command.id);
$i$;
 if position(marker in def)=0 then raise exception 'Could not locate patrol intelligence dispatcher branch'; end if;
 def:=replace(def,marker,marker||injected);
 help_old:=$h$'patrol_coverage','patrol_move','patrol_intelligence')$h$;
 help_new:=$hn$'patrol_coverage','patrol_move','patrol_intelligence','start_patrol_activity','end_patrol_activity')$hn$;
 if position(help_old in def)=0 then raise exception 'Could not locate patrol help list'; end if;
 def:=replace(def,help_old,help_new);
 def:=replace(def,$n$'note','Patrol intelligence and forensic laboratory commands are available.')$n$,$nn$'note','Patrol movement, activity logging, intelligence and forensic laboratory commands are available.')$nn$;
 execute def;
end;$patch$;
