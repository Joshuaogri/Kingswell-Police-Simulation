create table if not exists game.patrol_schedules (
 id uuid primary key default gen_random_uuid(), schedule_ref text not null unique,
 unit_id uuid not null references game.police_units(id), beat_id uuid not null references game.patrol_beats(id),
 roster_id uuid references game.duty_rosters(id), starts_at timestamptz not null, ends_at timestamptz not null,
 status text not null default 'scheduled' check(status in ('scheduled','active','completed','cancelled')),
 created_at timestamptz not null default now(), check(ends_at>starts_at)
);
create index if not exists patrol_schedules_unit_time_idx on game.patrol_schedules(unit_id,starts_at,ends_at);
create index if not exists patrol_schedules_beat_time_idx on game.patrol_schedules(beat_id,starts_at,ends_at);
alter table game.patrol_schedules enable row level security;
revoke all on game.patrol_schedules from public,anon,authenticated;
grant select,insert,update on game.patrol_schedules to service_role;
create table if not exists game.patrol_coverage_events (
 id uuid primary key default gen_random_uuid(), unit_id uuid not null references game.police_units(id),
 beat_id uuid not null references game.patrol_beats(id), schedule_id uuid references game.patrol_schedules(id),
 event_type text not null check(event_type in ('patrol_started','patrol_ended','beat_changed','coverage_interrupted')),
 event_time timestamptz not null, reason text not null check(length(btrim(reason))>0),
 details jsonb not null default '{}'::jsonb, created_at timestamptz not null default now()
);
create index if not exists patrol_coverage_events_beat_time_idx on game.patrol_coverage_events(beat_id,event_time desc);
alter table game.patrol_coverage_events enable row level security;
revoke all on game.patrol_coverage_events from public,anon,authenticated;
grant select,insert on game.patrol_coverage_events to service_role;
revoke update,delete on game.patrol_coverage_events from service_role;
create or replace function game.assign_unit_patrol_beat(p_unit_ref text,p_beat_ref text,p_reason text)
returns jsonb language plpgsql set search_path to ''
as $function$
declare u game.police_units%rowtype; b game.patrol_beats%rowtype; c timestamptz;
begin
 if length(btrim(coalesce(p_reason,'')))=0 then raise exception 'A reason is required'; end if;
 select current_game_time into c from game.simulation_state where id=1;
 if c is null then raise exception 'Fictional clock is not initialized'; end if;
 select * into u from game.police_units where unit_ref=p_unit_ref for update;
 if not found or u.status<>'active' then raise exception 'Active patrol unit not found'; end if;
 if u.operational_state in ('responding','on_scene','returning','out_of_service') then raise exception 'Unit cannot change beat while %',u.operational_state; end if;
 select * into b from game.patrol_beats where beat_ref=p_beat_ref and status='active';
 if not found then raise exception 'Active patrol beat not found'; end if;
 update game.police_units set assigned_beat_id=b.id where id=u.id;
 insert into game.patrol_coverage_events(unit_id,beat_id,event_type,event_time,reason,details)
 values(u.id,b.id,'beat_changed',c,btrim(p_reason),jsonb_build_object('previous_beat_id',u.assigned_beat_id));
 return jsonb_build_object('unit_ref',u.unit_ref,'beat_ref',b.beat_ref,'assigned_at',c);
end;$function$;
create or replace function game.schedule_unit_patrol(p_schedule_ref text,p_unit_ref text,p_beat_ref text,p_starts_at timestamptz,p_ends_at timestamptz,p_roster_ref text default null)
returns jsonb language plpgsql set search_path to ''
as $function$
declare u game.police_units%rowtype; b game.patrol_beats%rowtype; r game.duty_rosters%rowtype; sid uuid;
begin
 if p_ends_at<=p_starts_at then raise exception 'Patrol schedule end must be after start'; end if;
 select * into u from game.police_units where unit_ref=p_unit_ref and status='active';
 if not found then raise exception 'Active unit not found'; end if;
 select * into b from game.patrol_beats where beat_ref=p_beat_ref and status='active';
 if not found then raise exception 'Active beat not found'; end if;
 if p_roster_ref is not null then
  select * into r from game.duty_rosters where roster_ref=p_roster_ref and unit_id=u.id and status='active';
  if not found then raise exception 'Active roster for this unit not found'; end if;
  if p_starts_at<r.starts_at or p_ends_at>r.ends_at then raise exception 'Patrol schedule must fit within the selected duty roster'; end if;
 end if;
 if exists(select 1 from game.patrol_schedules s where s.unit_id=u.id and s.status in ('scheduled','active') and tstzrange(s.starts_at,s.ends_at,'[)') && tstzrange(p_starts_at,p_ends_at,'[)')) then raise exception 'Unit already has an overlapping patrol schedule'; end if;
 insert into game.patrol_schedules(schedule_ref,unit_id,beat_id,roster_id,starts_at,ends_at) values(p_schedule_ref,u.id,b.id,r.id,p_starts_at,p_ends_at) returning id into sid;
 return jsonb_build_object('schedule_ref',p_schedule_ref,'unit_ref',u.unit_ref,'beat_ref',b.beat_ref,'starts_at',p_starts_at,'ends_at',p_ends_at,'status','scheduled');
end;$function$;
create or replace function game.start_unit_patrol(p_unit_ref text,p_reason text)
returns jsonb language plpgsql set search_path to ''
as $function$
declare u game.police_units%rowtype; c timestamptz; s game.patrol_schedules%rowtype; n integer;
begin
 if length(btrim(coalesce(p_reason,'')))=0 then raise exception 'A reason is required'; end if;
 select current_game_time into c from game.simulation_state where id=1;
 if c is null then raise exception 'Fictional clock is not initialized'; end if;
 select * into u from game.police_units where unit_ref=p_unit_ref for update;
 if not found or u.status<>'active' then raise exception 'Active unit not found'; end if;
 if u.operational_state not in ('at_station','on_patrol') then raise exception 'Unit cannot start patrol while %',u.operational_state; end if;
 if u.assigned_beat_id is null then raise exception 'Unit has no assigned patrol beat'; end if;
 select count(*) into n from game.duty_rosters r where r.unit_id=u.id and r.status='active' and r.starts_at<=c and r.ends_at>c;
 if n=0 then raise exception 'Unit has no active duty roster at current fictional time'; end if;
 if exists(select 1 from game.incident_deployments d where d.unit_id=u.id and d.cleared_at is null and d.status not in ('cleared','cancelled','completed')) then raise exception 'Unit has active incident deployment'; end if;
 select * into s from game.patrol_schedules where unit_id=u.id and beat_id=u.assigned_beat_id and status='scheduled' and starts_at<=c and ends_at>c order by starts_at limit 1 for update;
 if not found then raise exception 'No active patrol schedule for the assigned beat'; end if;
 update game.patrol_schedules set status='active' where id=s.id;
 update game.police_units set operational_state='on_patrol',operational_state_updated_at=c where id=u.id;
 insert into game.unit_operational_state_history(unit_id,previous_state,new_state,changed_at_game_time,source,reason) values(u.id,u.operational_state,'on_patrol',c,'manual',btrim(p_reason));
 insert into game.patrol_coverage_events(unit_id,beat_id,schedule_id,event_type,event_time,reason) values(u.id,s.beat_id,s.id,'patrol_started',c,btrim(p_reason));
 return jsonb_build_object('unit_ref',u.unit_ref,'beat_id',s.beat_id,'schedule_ref',s.schedule_ref,'state','on_patrol','started_at',c);
end;$function$;
create or replace function game.end_unit_patrol(p_unit_ref text,p_reason text)
returns jsonb language plpgsql set search_path to ''
as $function$
declare u game.police_units%rowtype; c timestamptz; s game.patrol_schedules%rowtype; v_state text;
begin
 if length(btrim(coalesce(p_reason,'')))=0 then raise exception 'A reason is required'; end if;
 select current_game_time into c from game.simulation_state where id=1;
 if c is null then raise exception 'Fictional clock is not initialized'; end if;
 select * into u from game.police_units where unit_ref=p_unit_ref for update;
 if not found or u.operational_state<>'on_patrol' then raise exception 'Unit is not currently on patrol'; end if;
 select * into s from game.patrol_schedules where unit_id=u.id and status='active' order by starts_at desc limit 1 for update;
 if not found then raise exception 'No active patrol schedule found'; end if;
 if u.base_facility_id is null then v_state:='returning';
 else v_state:='at_station'; end if;
 update game.patrol_schedules set status='completed' where id=s.id;
 if v_state='at_station' then
  update game.police_units set operational_state=v_state,operational_state_updated_at=c,current_access_point_id=(select access_point_id from game.police_facilities where id=u.base_facility_id),current_location_updated_at=c where id=u.id;
 else
  update game.police_units set operational_state=v_state,operational_state_updated_at=c where id=u.id;
 end if;
 insert into game.unit_operational_state_history(unit_id,previous_state,new_state,changed_at_game_time,source,reason) values(u.id,'on_patrol',v_state,c,'manual',btrim(p_reason));
 insert into game.patrol_coverage_events(unit_id,beat_id,schedule_id,event_type,event_time,reason) values(u.id,s.beat_id,s.id,'patrol_ended',c,btrim(p_reason));
 return jsonb_build_object('unit_ref',u.unit_ref,'state',v_state,'ended_at',c);
end;$function$;
revoke all on function game.assign_unit_patrol_beat(text,text,text),game.schedule_unit_patrol(text,text,text,timestamptz,timestamptz,text),game.start_unit_patrol(text,text),game.end_unit_patrol(text,text) from public,anon,authenticated;
grant execute on function game.assign_unit_patrol_beat(text,text,text),game.schedule_unit_patrol(text,text,text,timestamptz,timestamptz,text),game.start_unit_patrol(text,text),game.end_unit_patrol(text,text) to service_role;