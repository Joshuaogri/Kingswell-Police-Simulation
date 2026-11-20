-- Kingswell initial scene control, activity, access, field report and resource request records.
create table game.incident_scenes (
 id uuid primary key default gen_random_uuid(), scene_ref text not null unique, incident_id uuid not null references game.incidents(id), case_id uuid references game.cases(id),
 scene_type text not null default 'suspected', location_description text, designation_reason text not null, confidence text not null default 'suspected', status text not null default 'controlled',
 scene_manager_personnel_id uuid references game.police_personnel(id), control_basis text not null, discovered_at timestamptz, attended_at timestamptz, control_started_at timestamptz, released_at timestamptz,
 created_by_personnel_id uuid not null references game.police_personnel(id), created_at timestamptz not null default now(), updated_at timestamptz not null default now(),
 constraint incident_scenes_status_check check(status in ('potential','identified','assessed','designated','controlled','awaiting_specialist','under_examination','partially_released','released','reopened','closed')),
 constraint incident_scenes_confidence_check check(confidence in ('low','moderate','high','suspected','confirmed'))
);
create index incident_scenes_incident_idx on game.incident_scenes(incident_id,status);
create index incident_scenes_manager_idx on game.incident_scenes(scene_manager_personnel_id,status);
create table game.scene_activity_logs (id uuid primary key default gen_random_uuid(),scene_id uuid not null references game.incident_scenes(id),event_at timestamptz not null,event_type text not null,personnel_id uuid references game.police_personnel(id),description text not null,details jsonb not null default '{}'::jsonb,source_command_id uuid references game.game_commands(id),created_at timestamptz not null default now());
create index scene_activity_logs_scene_time_idx on game.scene_activity_logs(scene_id,event_at,id);
create table game.scene_access_events (id uuid primary key default gen_random_uuid(),scene_id uuid not null references game.incident_scenes(id),event_at timestamptz not null,action text not null check(action in ('entry','exit')),personnel_id uuid not null references game.police_personnel(id),organisation_name text not null,role_description text not null,zone_ref text not null default 'general',purpose text not null,recorded_by_personnel_id uuid not null references game.police_personnel(id),source_command_id uuid references game.game_commands(id),created_at timestamptz not null default now());
create index scene_access_events_scene_time_idx on game.scene_access_events(scene_id,event_at,id);
create index scene_access_events_person_zone_idx on game.scene_access_events(scene_id,personnel_id,zone_ref,event_at desc);
create table game.incident_field_reports (id uuid primary key default gen_random_uuid(),report_ref text not null unique,incident_id uuid not null references game.incidents(id),scene_id uuid references game.incident_scenes(id),personnel_id uuid not null references game.police_personnel(id),report_type text not null default 'field_report',observed_at timestamptz not null,submitted_at timestamptz not null,narrative text not null,observations jsonb not null default '[]'::jsonb,actions jsonb not null default '[]'::jsonb,source_command_id uuid references game.game_commands(id),created_at timestamptz not null default now());
create index incident_field_reports_incident_time_idx on game.incident_field_reports(incident_id,submitted_at desc);
create index incident_field_reports_personnel_idx on game.incident_field_reports(personnel_id,submitted_at desc);
create table game.incident_resource_requests (id uuid primary key default gen_random_uuid(),request_ref text not null unique,incident_id uuid not null references game.incidents(id),scene_id uuid references game.incident_scenes(id),requested_by_personnel_id uuid not null references game.police_personnel(id),resource_type text not null,quantity integer not null default 1 check(quantity>0),priority smallint not null default 3 check(priority between 1 and 5),reason text not null,status text not null default 'requested' check(status in ('requested','acknowledged','approved','declined','fulfilled','cancelled')),requested_at timestamptz not null,responded_at timestamptz,response_notes text,fulfilled_by_personnel_id uuid references game.police_personnel(id),source_command_id uuid references game.game_commands(id),created_at timestamptz not null default now());
create index incident_resource_requests_incident_idx on game.incident_resource_requests(incident_id,status,requested_at);
create index incident_resource_requests_scene_idx on game.incident_resource_requests(scene_id,status);
CREATE OR REPLACE FUNCTION game.execute_scene_action(p_command_id uuid, p_command_type text, p_payload jsonb, p_actor_personnel_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare
 v_clock_time timestamptz; v_incident_id uuid; v_incident_ref text; v_incident_status text;
 v_scene_id uuid; v_scene_ref text; v_scene_status text; v_scene_manager uuid; v_personnel_id uuid;
 v_personnel_ref text; v_previous_manager uuid; v_description text; v_reason text; v_resource_type text;
 v_request_ref text; v_report_ref text; v_purpose text; v_zone text; v_last_action text; v_location text;
 v_quantity integer; v_priority smallint;
begin
 select current_game_time into v_clock_time from game.simulation_state where id=1 for update;
 if v_clock_time is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Scene and field actions require the fictional game clock to be initialized.'); end if;
 v_personnel_ref:=nullif(btrim(p_payload->>'personnel_ref'),'');
 if v_personnel_ref is null then return jsonb_build_object('ok',false,'code','missing_personnel_reference','message','A personnel reference is required.'); end if;
 select id into v_personnel_id from game.police_personnel where personnel_ref=v_personnel_ref and employment_status='active';
 if v_personnel_id is null then return jsonb_build_object('ok',false,'code','personnel_unavailable','message','The named officer does not exist or is not actively employed.'); end if;
 if p_command_type='establish_scene' then
  v_scene_ref:=nullif(btrim(p_payload->>'scene_ref'),''); v_incident_ref:=nullif(btrim(p_payload->>'incident_ref'),''); v_reason:=nullif(btrim(p_payload->>'reason'),'');
  if v_scene_ref is null or v_incident_ref is null or v_reason is null then return jsonb_build_object('ok',false,'code','missing_scene_details','message','Scene reference, incident reference and designation reason are required.'); end if;
  if exists(select 1 from game.incident_scenes where scene_ref=v_scene_ref) then return jsonb_build_object('ok',false,'code','scene_reference_exists','message','That scene reference is already in use.'); end if;
  select id,status,location_description into v_incident_id,v_incident_status,v_location from game.incidents where incident_ref=v_incident_ref for update;
  if v_incident_id is null then return jsonb_build_object('ok',false,'code','incident_not_found','message','No incident exists with that reference.'); end if;
  if v_incident_status in ('resolved','closed','cancelled') then return jsonb_build_object('ok',false,'code','incident_not_active','message','A scene cannot be established against a concluded incident.'); end if;
  if not exists(select 1 from game.incident_deployments d where d.incident_id=v_incident_id and d.personnel_id=v_personnel_id and d.status='on_scene' and d.cleared_at is null) then return jsonb_build_object('ok',false,'code','officer_not_on_scene','message','The officer must have a current on-scene deployment at this incident before establishing scene control.'); end if;
  insert into game.incident_scenes(scene_ref,incident_id,scene_type,location_description,designation_reason,confidence,status,scene_manager_personnel_id,control_basis,discovered_at,attended_at,control_started_at,created_by_personnel_id)
  values(v_scene_ref, v_incident_id,coalesce(nullif(btrim(p_payload->>'scene_type'),''),'suspected'),coalesce(nullif(btrim(p_payload->>'location_description'),''),v_location),v_reason,coalesce(nullif(btrim(p_payload->>'confidence'),''),'suspected'),'controlled',v_personnel_id,v_reason,v_clock_time,v_clock_time,v_clock_time,v_personnel_id) returning id into v_scene_id;
  insert into game.scene_activity_logs(scene_id,event_at,event_type,personnel_id,description,details,source_command_id) values(v_scene_id,v_clock_time,'scene_control_established',v_personnel_id,'Scene designated and initial control established.',jsonb_build_object('incident_ref',v_incident_ref,'scene_ref',v_scene_ref,'reason',v_reason),p_command_id);
  insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data) values('scene.control_established',v_clock_time,v_personnel_id,'incident_scene',v_scene_id,jsonb_build_object('command_id',p_command_id,'incident_ref',v_incident_ref,'scene_ref',v_scene_ref,'reason',v_reason));
  return jsonb_build_object('ok',true,'scene_ref',v_scene_ref,'incident_ref',v_incident_ref,'scene_status','controlled','scene_manager',v_personnel_ref,'game_time',v_clock_time,'message','Scene record created and initial scene control established.');
 end if;
 if p_command_type in ('scene_update','assume_scene_command','request_scene_resource','scene_entry','scene_exit') then
  v_scene_ref:=nullif(btrim(p_payload->>'scene_ref'),'');
  if v_scene_ref is null then return jsonb_build_object('ok',false,'code','missing_scene_reference','message','A scene reference is required.'); end if;
  select s.id,s.incident_id,s.status,s.scene_manager_personnel_id,i.incident_ref into v_scene_id,v_incident_id,v_scene_status,v_scene_manager,v_incident_ref from game.incident_scenes s join game.incidents i on i.id=s.incident_id where s.scene_ref=v_scene_ref for update of s;
  if v_scene_id is null then return jsonb_build_object('ok',false,'code','scene_not_found','message','No scene exists with that reference.'); end if;
  if v_scene_status in ('released','closed') then return jsonb_build_object('ok',false,'code','scene_not_active','message','This scene is released or closed.'); end if;
  if p_command_type in ('scene_update','assume_scene_command','request_scene_resource') and not exists(select 1 from game.incident_deployments d where d.incident_id=v_incident_id and d.personnel_id=v_personnel_id and d.status='on_scene' and d.cleared_at is null) then return jsonb_build_object('ok',false,'code','officer_not_on_scene','message','The officer must have an active on-scene deployment at the originating incident.'); end if;
 end if;
 if p_command_type='assume_scene_command' then
  v_previous_manager:=v_scene_manager;
  if v_previous_manager=v_personnel_id then return jsonb_build_object('ok',false,'code','already_scene_manager','message','This officer already holds scene command.'); end if;
  update game.incident_scenes set scene_manager_personnel_id=v_personnel_id,updated_at=now() where id=v_scene_id;
  insert into game.scene_activity_logs(scene_id,event_at,event_type,personnel_id,description,details,source_command_id) values(v_scene_id,v_clock_time,'scene_command_transferred',v_personnel_id,'Scene command transferred to this officer.',jsonb_build_object('previous_manager_personnel_id',v_previous_manager,'new_manager_personnel_id',v_personnel_id),p_command_id);
  insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data) values('scene.command_transferred',v_clock_time,v_personnel_id,'incident_scene',v_scene_id,jsonb_build_object('command_id',p_command_id,'previous_manager_personnel_id',v_previous_manager,'new_manager_personnel_id',v_personnel_id));
  return jsonb_build_object('ok',true,'scene_ref',v_scene_ref,'previous_manager_personnel_id',v_previous_manager,'scene_manager',v_personnel_ref,'game_time',v_clock_time,'message','Scene command responsibility transferred and recorded.');
 elsif p_command_type='scene_update' then
  v_description:=nullif(btrim(p_payload->>'description'),'');
  if v_description is null or char_length(v_description)>4000 then return jsonb_build_object('ok',false,'code','invalid_scene_update','message','Enter a scene update between 1 and 4000 characters.'); end if;
  insert into game.scene_activity_logs(scene_id,event_at,event_type,personnel_id,description,details,source_command_id) values(v_scene_id,v_clock_time,'field_update',v_personnel_id,v_description,jsonb_build_object('incident_ref',v_incident_ref),p_command_id);
  insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data) values('scene.field_update',v_clock_time,v_personnel_id,'incident_scene',v_scene_id,jsonb_build_object('command_id',p_command_id,'incident_ref',v_incident_ref,'description',v_description));
  return jsonb_build_object('ok',true,'scene_ref',v_scene_ref,'incident_ref',v_incident_ref,'event_type','field_update','game_time',v_clock_time,'message','Scene update recorded.');
 elsif p_command_type='request_scene_resource' then
  v_resource_type:=nullif(btrim(p_payload->>'resource_type'),''); v_reason:=nullif(btrim(p_payload->>'reason'),'');
  if v_resource_type is null or v_reason is null then return jsonb_build_object('ok',false,'code','missing_resource_request_details','message','Resource type and reason are required.'); end if;
  v_quantity:=greatest(1,coalesce((p_payload->>'quantity')::integer,1)); v_priority:=least(5,greatest(1,coalesce((p_payload->>'priority')::integer,3)));
  v_request_ref:='KWR-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  insert into game.incident_resource_requests(request_ref,incident_id,scene_id,requested_by_personnel_id,resource_type,quantity,priority,reason,status,requested_at,source_command_id) values(v_request_ref,v_incident_id,v_scene_id,v_personnel_id,v_resource_type,v_quantity,v_priority,v_reason,'requested',v_clock_time,p_command_id);
  insert into game.scene_activity_logs(scene_id,event_at,event_type,personnel_id,description,details,source_command_id) values(v_scene_id,v_clock_time,'resource_requested',v_personnel_id,'Additional resource requested: '||v_resource_type,jsonb_build_object('request_ref',v_request_ref,'quantity',v_quantity,'priority',v_priority,'reason',v_reason),p_command_id);
  insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data) values('scene.resource_requested',v_clock_time,v_personnel_id,'incident_scene',v_scene_id,jsonb_build_object('command_id',p_command_id,'request_ref',v_request_ref,'resource_type',v_resource_type,'reason',v_reason));
  return jsonb_build_object('ok',true,'scene_ref',v_scene_ref,'request_ref',v_request_ref,'resource_type',v_resource_type,'request_status','requested','game_time',v_clock_time,'message','Resource request recorded. It has not yet been approved or deployed.');
 elsif p_command_type in ('scene_entry','scene_exit') then
  v_purpose:=nullif(btrim(p_payload->>'purpose'),''); v_zone:=coalesce(nullif(btrim(p_payload->>'zone'),''),'general');
  if v_purpose is null then return jsonb_build_object('ok',false,'code','missing_access_purpose','message','A purpose is required for every scene entry or exit.'); end if;
  select action into v_last_action from game.scene_access_events where scene_id=v_scene_id and personnel_id=v_personnel_id and zone_ref=v_zone order by event_at desc,id desc limit 1;
  if p_command_type='scene_entry' and v_last_action='entry' then return jsonb_build_object('ok',false,'code','already_inside_scene_zone','message','The officer already has an unmatched entry in this scene zone.'); end if;
  if p_command_type='scene_exit' and coalesce(v_last_action,'')<>'entry' then return jsonb_build_object('ok',false,'code','no_open_scene_entry','message','No matching recorded entry exists for this officer in that scene zone.'); end if;
  insert into game.scene_access_events(scene_id,event_at,action,personnel_id,organisation_name,role_description,zone_ref,purpose,recorded_by_personnel_id,source_command_id) values(v_scene_id,v_clock_time,case when p_command_type='scene_entry' then 'entry' else 'exit' end,v_personnel_id,'Kingswell Police Department','Police personnel',v_zone,v_purpose,v_personnel_id,p_command_id);
  insert into game.scene_activity_logs(scene_id,event_at,event_type,personnel_id,description,details,source_command_id) values(v_scene_id,v_clock_time,case when p_command_type='scene_entry' then 'person_entered' else 'person_exited' end,v_personnel_id,'Scene access event recorded: '||p_command_type,jsonb_build_object('zone_ref',v_zone,'purpose',v_purpose),p_command_id);
  return jsonb_build_object('ok',true,'scene_ref',v_scene_ref,'action',case when p_command_type='scene_entry' then 'entry' else 'exit' end,'zone_ref',v_zone,'personnel_ref',v_personnel_ref,'game_time',v_clock_time,'message','Scene access event recorded.');
 end if;
 if p_command_type='submit_field_report' then
  v_incident_ref:=nullif(btrim(p_payload->>'incident_ref'),''); v_description:=nullif(btrim(p_payload->>'narrative'),''); v_scene_ref:=nullif(btrim(p_payload->>'scene_ref'),'');
  if v_incident_ref is null or v_description is null or char_length(v_description)>8000 then return jsonb_build_object('ok',false,'code','invalid_field_report','message','Incident reference and a narrative between 1 and 8000 characters are required.'); end if;
  select id,status into v_incident_id,v_incident_status from game.incidents where incident_ref=v_incident_ref for update;
  if v_incident_id is null then return jsonb_build_object('ok',false,'code','incident_not_found','message','No incident exists with that reference.'); end if;
  if v_incident_status in ('resolved','closed','cancelled') then return jsonb_build_object('ok',false,'code','incident_not_active','message','A field report cannot be submitted to a concluded incident.'); end if;
  if not exists(select 1 from game.incident_deployments d where d.incident_id=v_incident_id and d.personnel_id=v_personnel_id and d.status='on_scene' and d.cleared_at is null) then return jsonb_build_object('ok',false,'code','officer_not_on_scene','message','The officer must be recorded on scene before submitting a field report.'); end if;
  if v_scene_ref is not null then select id into v_scene_id from game.incident_scenes where scene_ref=v_scene_ref and incident_id=v_incident_id; if v_scene_id is null then return jsonb_build_object('ok',false,'code','scene_incident_mismatch','message','The scene does not belong to the stated incident.'); end if; else v_scene_id:=null; end if;
  v_report_ref:='KWF-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  insert into game.incident_field_reports(report_ref,incident_id,scene_id,personnel_id,report_type,observed_at,submitted_at,narrative,observations,actions,source_command_id) values(v_report_ref,v_incident_id,v_scene_id,v_personnel_id,coalesce(nullif(btrim(p_payload->>'report_type'),''),'field_report'),coalesce(nullif(p_payload->>'observed_at','')::timestamptz,v_clock_time),v_clock_time,v_description,coalesce(p_payload->'observations','[]'::jsonb),coalesce(p_payload->'actions','[]'::jsonb),p_command_id);
  insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data) values('incident.field_report_submitted',v_clock_time,v_personnel_id,'incident',v_incident_id,jsonb_build_object('command_id',p_command_id,'report_ref',v_report_ref,'scene_ref',v_scene_ref));
  if v_scene_id is not null then insert into game.scene_activity_logs(scene_id,event_at,event_type,personnel_id,description,details,source_command_id) values(v_scene_id,v_clock_time,'field_report_submitted',v_personnel_id,'Officer submitted a field report.',jsonb_build_object('report_ref',v_report_ref,'incident_ref',v_incident_ref),p_command_id); end if;
  return jsonb_build_object('ok',true,'report_ref',v_report_ref,'incident_ref',v_incident_ref,'scene_ref',v_scene_ref,'personnel_ref',v_personnel_ref,'game_time',v_clock_time,'message','Field report submitted and linked to the incident.');
 end if;
 return jsonb_build_object('ok',false,'code','unsupported_scene_action','message','This scene action is not supported.');
end;
$function$
;
CREATE OR REPLACE FUNCTION game.submit_command(p_command_text text, p_command_type text, p_payload jsonb DEFAULT '{}'::jsonb, p_idempotency_key text DEFAULT NULL::text, p_session_id uuid DEFAULT NULL::uuid, p_actor_personnel_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare
  v_command game.game_commands%rowtype;
  v_clock game.simulation_state%rowtype;
  v_new_time timestamptz;
  v_minutes integer;
  v_start_text text;
  v_type text := lower(btrim(coalesce(p_command_type,'')));
  v_result jsonb;
  v_summary text;
  v_location text;
  v_channel text;
  v_priority smallint;
  v_incident_ref text;
  v_call_ref text;
  v_incident_id uuid;
  v_call_id uuid;
  v_unit_id uuid;
  v_unit_ref text;
  v_unit_status text;
  v_incident_status text;
  v_personnel_ids uuid[];
  v_personnel_id uuid;
  v_dispatch_count integer;
  v_personnel_ref text;
  v_deployment_id uuid;
  v_deployment_status text;
  v_deployment_unit_id uuid;
  v_dispatched_at timestamptz;
  v_arrived_at timestamptz;
  v_scene_action_types text[] := array['establish_scene','assume_scene_command','scene_update','submit_field_report','request_scene_resource','scene_entry','scene_exit'];
begin
  if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then raise exception 'Command text must contain between 1 and 4000 characters'; end if;
  if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key between 8 and 200 characters is required'; end if;
  if p_payload is null or jsonb_typeof(p_payload) <> 'object' then raise exception 'Command payload must be a JSON object'; end if;

  insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload)
    values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,p_payload)
    on conflict(idempotency_key) do nothing;
  if not found then
    select * into v_command from game.game_commands where idempotency_key=p_idempotency_key for update;
    if v_command.command_text<>p_command_text or v_command.command_type<>v_type or v_command.payload<>p_payload then
      return jsonb_build_object('ok',false,'code','idempotency_conflict','message','This command key was already used for a different command.','command_id',v_command.id);
    end if;
    return coalesce(v_command.result,jsonb_build_object('ok',v_command.status='completed','status',v_command.status,'command_id',v_command.id,'message','Previously received command; no duplicate action was executed.')) || jsonb_build_object('duplicate',true);
  end if;
  select * into v_command from game.game_commands where idempotency_key=p_idempotency_key for update;

  if v_type='help' then
    v_result:=jsonb_build_object('ok',true,'status','completed','command_id',v_command.id,'available_commands',jsonb_build_array('help','status','initialize_clock','advance_time','receive_call','dispatch_unit','acknowledge_dispatch','arrive_scene','establish_scene','assume_scene_command','scene_update','submit_field_report','request_scene_resource','scene_entry','scene_exit'),'note','Domain actions will be registered as their owning game systems are implemented.');
  elsif v_type='status' then
    select * into v_clock from game.simulation_state where id=1;
    v_result:=jsonb_build_object('ok',true,'status','completed','command_id',v_command.id,'world',coalesce(v_clock.world_name,'Kingswell'),'clock_initialized',v_clock.current_game_time is not null,'game_time',v_clock.current_game_time,'time_paused',coalesce(v_clock.time_paused,true),'time_scale',coalesce(v_clock.time_scale,1));
  elsif v_type='initialize_clock' then
    v_start_text:=p_payload->>'start_at';
    if v_start_text is null or not pg_input_is_valid(v_start_text,'timestamptz') then
      v_result:=jsonb_build_object('ok',false,'code','invalid_start_time','message','The fictional game clock needs an explicitly chosen valid start date and time.');
      update game.game_commands set status='rejected',rejection_reason='Invalid or missing start_at timestamp.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    select * into v_clock from game.simulation_state where id=1 for update;
    if v_clock.current_game_time is not null then
      v_result:=jsonb_build_object('ok',false,'code','clock_already_initialized','message','The game clock is already initialized; use a controlled clock correction workflow.');
      update game.game_commands set status='rejected',rejection_reason='Clock already initialized.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    v_new_time:=v_start_text::timestamptz;
    update game.simulation_state set current_game_time=v_new_time,time_paused=true,updated_at=now() where id=1;
    insert into game.game_clock_history(command_id,previous_game_time,resulting_game_time,advancement_minutes,reason) values(v_command.id,null,v_new_time,0,'Explicit initial fictional clock configuration');
    insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,event_data) values('runtime.clock.initialized',v_new_time,p_actor_personnel_id,'simulation_clock',jsonb_build_object('command_id',v_command.id,'resulting_game_time',v_new_time));
    v_result:=jsonb_build_object('ok',true,'status','completed','command_id',v_command.id,'clock_initialized',true,'game_time',v_new_time,'time_paused',true);
  elsif v_type='advance_time' then
    if jsonb_typeof(p_payload->'minutes')<>'number' or not pg_input_is_valid(p_payload->>'minutes','integer') then
      v_result:=jsonb_build_object('ok',false,'code','invalid_duration','message','Provide minutes as a positive whole number (maximum 1440 per command).');
      update game.game_commands set status='rejected',rejection_reason='Minutes must be an integer.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    v_minutes:=(p_payload->>'minutes')::integer;
    if v_minutes<1 or v_minutes>1440 then
      v_result:=jsonb_build_object('ok',false,'code','duration_out_of_range','message','Time advancement must be between 1 and 1440 minutes per command.');
      update game.game_commands set status='rejected',rejection_reason='Duration outside 1–1440 minutes.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    select * into v_clock from game.simulation_state where id=1 for update;
    if v_clock.current_game_time is null then
      v_result:=jsonb_build_object('ok',false,'code','clock_not_initialized','message','The game clock has no configured fictional start date and time yet.');
      update game.game_commands set status='rejected',rejection_reason='Clock not initialized.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    v_new_time:=v_clock.current_game_time+make_interval(mins=>v_minutes);
    update game.simulation_state set current_game_time=v_new_time,updated_at=now() where id=1;
    insert into game.game_clock_history(command_id,previous_game_time,resulting_game_time,advancement_minutes,reason) values(v_command.id,v_clock.current_game_time,v_new_time,v_minutes,coalesce(nullif(p_payload->>'reason',''),'Explicit player time-advance command'));
    insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,event_data) values('runtime.clock.advanced',v_new_time,p_actor_personnel_id,'simulation_clock',jsonb_build_object('command_id',v_command.id,'previous_game_time',v_clock.current_game_time,'resulting_game_time',v_new_time,'minutes',v_minutes,'reason',coalesce(nullif(p_payload->>'reason',''),'Explicit player time-advance command')));
    v_result:=jsonb_build_object('ok',true,'status','completed','command_id',v_command.id,'previous_game_time',v_clock.current_game_time,'game_time',v_new_time,'advanced_minutes',v_minutes,'time_paused',v_clock.time_paused);
  elsif v_type='receive_call' then
    v_summary:=nullif(btrim(p_payload->>'summary'),'');
    v_location:=nullif(btrim(p_payload->>'location'),'');
    v_channel:=coalesce(nullif(lower(btrim(p_payload->>'channel')),''),'telephone');
    if v_summary is null or char_length(v_summary)>2000 or v_location is null or char_length(v_location)>1000 then
      v_result:=jsonb_build_object('ok',false,'code','invalid_call_details','message','A call summary and location are required.');
      update game.game_commands set status='rejected',rejection_reason='Missing or oversized call summary/location.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    if v_channel not in ('telephone','radio','in_person','digital') then
      v_result:=jsonb_build_object('ok',false,'code','invalid_call_channel','message','Call channel must be telephone, radio, in_person or digital.');
      update game.game_commands set status='rejected',rejection_reason='Unsupported call channel.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    if p_payload ? 'priority' and (jsonb_typeof(p_payload->'priority')<>'number' or not pg_input_is_valid(p_payload->>'priority','smallint')) then
      v_result:=jsonb_build_object('ok',false,'code','invalid_priority','message','Priority must be a whole number from 1 to 5.');
      update game.game_commands set status='rejected',rejection_reason='Invalid priority value.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    if jsonb_typeof(p_payload->'priority')='number' and pg_input_is_valid(p_payload->>'priority','smallint') then
      v_priority:=(p_payload->>'priority')::smallint;
    else
      v_priority:=3;
    end if;
    if v_priority<1 or v_priority>5 then
      v_result:=jsonb_build_object('ok',false,'code','invalid_priority','message','Call priority must be between 1 (highest) and 5 (lowest).');
      update game.game_commands set status='rejected',rejection_reason='Priority outside 1–5.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    select * into v_clock from game.simulation_state where id=1 for update;
    if v_clock.current_game_time is null then
      v_result:=jsonb_build_object('ok',false,'code','clock_not_initialized','message','Emergency-call intake requires the fictional game clock to be initialized first.');
      update game.game_commands set status='rejected',rejection_reason='Game clock not initialized; no real-world timestamp substituted.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    v_incident_ref:='KW-INC-'||to_char(v_clock.current_game_time at time zone 'UTC','YYYYMMDD-HH24MISS')||'-'||upper(substr(replace(v_command.id::text,'-',''),1,6));
    v_call_ref:='KW-CALL-'||to_char(v_clock.current_game_time at time zone 'UTC','YYYYMMDD-HH24MISS')||'-'||upper(substr(replace(v_command.id::text,'-',''),1,6));
    if p_payload ? 'caller_person_id' and not pg_input_is_valid(p_payload->>'caller_person_id','uuid') then
      v_result:=jsonb_build_object('ok',false,'code','invalid_caller_reference','message','Caller person reference is not a valid fictional person ID.');
      update game.game_commands set status='rejected',rejection_reason='Invalid caller person UUID.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    insert into game.incidents(incident_ref,reported_at,location_description,priority,status,summary,details)
      values(v_incident_ref,v_clock.current_game_time,v_location,v_priority,'new',v_summary,
        jsonb_build_object('source','dispatch_call','call_channel',v_channel,'originating_command_id',v_command.id))
      returning id into v_incident_id;
    insert into game.dispatch_calls(call_ref,incident_id,received_at,caller_person_id,caller_name,caller_contact,
      call_channel,call_taker_personnel_id,call_summary,call_record,status)
      values(v_call_ref,v_incident_id,v_clock.current_game_time,
        case when p_payload ? 'caller_person_id' and pg_input_is_valid(p_payload->>'caller_person_id','uuid') then (p_payload->>'caller_person_id')::uuid else null end,
        nullif(btrim(p_payload->>'caller_name'),''),nullif(btrim(p_payload->>'caller_contact'),''),
        v_channel,p_actor_personnel_id,v_summary,
        jsonb_build_object('original_command_text',p_command_text,'location_description',v_location,
          'priority',v_priority,'caller_statement',v_summary),
        'received')
      returning id into v_call_id;
    insert into game.dispatch_events(incident_id,event_at,event_type,personnel_id,details)
      values(v_incident_id,v_clock.current_game_time,'call_received',p_actor_personnel_id,
        jsonb_build_object('call_id',v_call_id,'call_ref',v_call_ref,'priority',v_priority,'channel',v_channel));
    insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data)
      values('dispatch.call_received',v_clock.current_game_time,p_actor_personnel_id,'incident',v_incident_id,
        jsonb_build_object('command_id',v_command.id,'call_id',v_call_id,'call_ref',v_call_ref,
          'incident_ref',v_incident_ref,'priority',v_priority,'location',v_location));
    v_result:=jsonb_build_object('ok',true,'status','completed','command_id',v_command.id,
      'call_id',v_call_id,'call_ref',v_call_ref,'incident_id',v_incident_id,
      'incident_ref',v_incident_ref,'priority',v_priority,'call_status','received',
      'incident_status','new','game_time',v_clock.current_game_time,
      'message','Emergency call recorded and linked to a new incident. No unit has been dispatched.');
  elsif v_type='dispatch_unit' then
    v_incident_ref:=nullif(btrim(p_payload->>'incident_ref'),'');
    v_unit_ref:=nullif(btrim(p_payload->>'unit_ref'),'');
    if v_incident_ref is null or v_unit_ref is null then
      v_result:=jsonb_build_object('ok',false,'code','missing_dispatch_reference','message','Both an incident reference and unit reference are required.');
      update game.game_commands set status='rejected',rejection_reason='Missing incident or unit reference.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    select * into v_clock from game.simulation_state where id=1 for update;
    if v_clock.current_game_time is null then
      v_result:=jsonb_build_object('ok',false,'code','clock_not_initialized','message','Unit dispatch requires the fictional game clock to be initialized.');
      update game.game_commands set status='rejected',rejection_reason='Game clock not initialized.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    select id,status into v_incident_id,v_incident_status from game.incidents where incident_ref=v_incident_ref for update;
    if v_incident_id is null then
      v_result:=jsonb_build_object('ok',false,'code','incident_not_found','message','No incident exists with that reference.');
      update game.game_commands set status='rejected',rejection_reason='Incident reference not found.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    if v_incident_status not in ('new','graded','queued') then
      v_result:=jsonb_build_object('ok',false,'code','incident_not_dispatchable','message','Incident is not in a dispatchable state. Current status: '||v_incident_status);
      update game.game_commands set status='rejected',rejection_reason='Incident is not in a dispatchable state.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    select id,status into v_unit_id,v_unit_status from game.police_units where unit_ref=v_unit_ref for update;
    if v_unit_id is null or v_unit_status<>'active' then
      v_result:=jsonb_build_object('ok',false,'code','unit_unavailable','message','The requested unit does not exist or is not active.');
      update game.game_commands set status='rejected',rejection_reason='Unit missing or inactive.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    if exists(select 1 from game.incident_deployments where incident_id=v_incident_id and cleared_at is null and status not in ('cleared','cancelled','completed')) then
      v_result:=jsonb_build_object('ok',false,'code','incident_already_deployed','message','This incident already has an active deployment.');
      update game.game_commands set status='rejected',rejection_reason='Incident already has an active deployment.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    select array_agg(x.personnel_id order by x.personnel_id) into v_personnel_ids
    from (
      select distinct pp.id as personnel_id
      from game.duty_rosters dr
      join game.duty_assignments da on da.roster_id=dr.id
      join game.police_personnel pp on pp.id=da.personnel_id
      where dr.unit_id=v_unit_id and dr.status='active'
        and dr.starts_at<=v_clock.current_game_time and dr.ends_at>v_clock.current_game_time
        and da.status in ('assigned','on_duty')
        and da.starts_at<=v_clock.current_game_time and da.ends_at>v_clock.current_game_time
        and pp.employment_status='active' 
        and not exists (
          select 1 from game.incident_deployments prior
          where prior.personnel_id=pp.id and prior.cleared_at is null
            and prior.status not in ('cleared','cancelled','completed')
        )
    ) x;
    if coalesce(cardinality(v_personnel_ids),0)=0 then
      v_result:=jsonb_build_object('ok',false,'code','no_available_personnel','message','No active, on-duty personnel from this unit are available at the current fictional game time.');
      update game.game_commands set status='rejected',rejection_reason='No eligible on-duty personnel.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    v_dispatch_count:=0;
    foreach v_personnel_id in array v_personnel_ids loop
      insert into game.incident_deployments(incident_id,personnel_id,unit_id,dispatched_at,deployment_role,status)
        values(v_incident_id,v_personnel_id,v_unit_id,v_clock.current_game_time,'responding officer','dispatched');
      insert into game.dispatch_events(incident_id,event_at,event_type,personnel_id,unit_id,details)
        values(v_incident_id,v_clock.current_game_time,'unit_dispatched',v_personnel_id,v_unit_id,
          jsonb_build_object('unit_ref',v_unit_ref,'incident_ref',v_incident_ref,'command_id',v_command.id));
      v_dispatch_count:=v_dispatch_count+1;
    end loop;
    update game.incidents set status='dispatched',updated_at=now() where id=v_incident_id;
    update game.dispatch_calls set status='dispatched' where incident_id=v_incident_id;
    insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data)
      values('dispatch.unit_dispatched',v_clock.current_game_time,p_actor_personnel_id,'incident',v_incident_id,
        jsonb_build_object('command_id',v_command.id,'unit_ref',v_unit_ref,'personnel_ids',to_jsonb(v_personnel_ids),'personnel_count',v_dispatch_count));
    v_result:=jsonb_build_object('ok',true,'status','completed','command_id',v_command.id,
      'incident_ref',v_incident_ref,'unit_ref',v_unit_ref,'incident_status','dispatched',
      'personnel_ids',to_jsonb(v_personnel_ids),'personnel_count',v_dispatch_count,
      'game_time',v_clock.current_game_time,'message','Eligible on-duty personnel dispatched. No arrival is recorded until a separate arrival action.');

  elsif v_type='acknowledge_dispatch' then
    v_incident_ref:=nullif(btrim(p_payload->>'incident_ref'),'');
    v_personnel_ref:=nullif(btrim(p_payload->>'personnel_ref'),'');
    if v_incident_ref is null or v_personnel_ref is null then
      v_result:=jsonb_build_object('ok',false,'code','missing_deployment_reference','message','Both an incident reference and personnel reference are required.');
      update game.game_commands set status='rejected',rejection_reason='Missing incident or personnel reference.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    select * into v_clock from game.simulation_state where id=1 for update;
    if v_clock.current_game_time is null then
      v_result:=jsonb_build_object('ok',false,'code','clock_not_initialized','message','Dispatch acknowledgement requires the fictional game clock to be initialized.');
      update game.game_commands set status='rejected',rejection_reason='Game clock not initialized.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    select i.id into v_incident_id from game.incidents i where i.incident_ref=v_incident_ref for update;
    if v_incident_id is null then
      v_result:=jsonb_build_object('ok',false,'code','incident_not_found','message','No incident exists with that reference.');
      update game.game_commands set status='rejected',rejection_reason='Incident reference not found.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    select d.id,d.status,d.unit_id,d.dispatched_at,d.arrived_at
      into v_deployment_id,v_deployment_status,v_deployment_unit_id,v_dispatched_at,v_arrived_at
    from game.incident_deployments d join game.police_personnel pp on pp.id=d.personnel_id
    where d.incident_id=v_incident_id and pp.personnel_ref=v_personnel_ref and d.cleared_at is null
    order by d.dispatched_at desc nulls last limit 1 for update of d;
    if v_deployment_id is null then
      v_result:=jsonb_build_object('ok',false,'code','deployment_not_found','message','No active deployment was found for that officer and incident.');
      update game.game_commands set status='rejected',rejection_reason='Active deployment not found.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    if v_deployment_status='responding' then
      v_result:=jsonb_build_object('ok',false,'code','already_acknowledged','message','This officer has already acknowledged the dispatch.');
      update game.game_commands set status='rejected',rejection_reason='Dispatch already acknowledged.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    if v_deployment_status<>'dispatched' then
      v_result:=jsonb_build_object('ok',false,'code','deployment_not_acknowledgeable','message','This deployment cannot be acknowledged in its current state: '||v_deployment_status);
      update game.game_commands set status='rejected',rejection_reason='Deployment state does not permit acknowledgement.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    if v_dispatched_at is null or v_clock.current_game_time<v_dispatched_at then
      v_result:=jsonb_build_object('ok',false,'code','invalid_game_time','message','The fictional clock cannot acknowledge a dispatch before it was issued.');
      update game.game_commands set status='rejected',rejection_reason='Acknowledgement precedes dispatch time.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    update game.incident_deployments set status='responding' where id=v_deployment_id;
    insert into game.dispatch_events(incident_id,event_at,event_type,personnel_id,unit_id,details)
      select v_incident_id,v_clock.current_game_time,'dispatch_acknowledged',d.personnel_id,d.unit_id,
        jsonb_build_object('personnel_ref',v_personnel_ref,'command_id',v_command.id)
      from game.incident_deployments d where d.id=v_deployment_id;
    insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data)
      select 'dispatch.officer_acknowledged',v_clock.current_game_time,p_actor_personnel_id,'incident_deployment',d.id,
        jsonb_build_object('command_id',v_command.id,'incident_ref',v_incident_ref,'personnel_ref',v_personnel_ref)
      from game.incident_deployments d where d.id=v_deployment_id;
    v_result:=jsonb_build_object('ok',true,'status','completed','command_id',v_command.id,
      'incident_ref',v_incident_ref,'personnel_ref',v_personnel_ref,'deployment_status','responding',
      'game_time',v_clock.current_game_time,'message','Dispatch acknowledged. Officer is responding; arrival has not yet been recorded.');
  elsif v_type='arrive_scene' then
    v_incident_ref:=nullif(btrim(p_payload->>'incident_ref'),'');
    v_personnel_ref:=nullif(btrim(p_payload->>'personnel_ref'),'');
    if v_incident_ref is null or v_personnel_ref is null then
      v_result:=jsonb_build_object('ok',false,'code','missing_deployment_reference','message','Both an incident reference and personnel reference are required.');
      update game.game_commands set status='rejected',rejection_reason='Missing incident or personnel reference.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    select * into v_clock from game.simulation_state where id=1 for update;
    if v_clock.current_game_time is null then
      v_result:=jsonb_build_object('ok',false,'code','clock_not_initialized','message','Scene arrival requires the fictional game clock to be initialized.');
      update game.game_commands set status='rejected',rejection_reason='Game clock not initialized.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    select i.id,i.status into v_incident_id,v_incident_status from game.incidents i where i.incident_ref=v_incident_ref for update;
    if v_incident_id is null then
      v_result:=jsonb_build_object('ok',false,'code','incident_not_found','message','No incident exists with that reference.');
      update game.game_commands set status='rejected',rejection_reason='Incident reference not found.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    select d.id,d.status,d.unit_id,d.dispatched_at,d.arrived_at
      into v_deployment_id,v_deployment_status,v_deployment_unit_id,v_dispatched_at,v_arrived_at
    from game.incident_deployments d join game.police_personnel pp on pp.id=d.personnel_id
    where d.incident_id=v_incident_id and pp.personnel_ref=v_personnel_ref and d.cleared_at is null
    order by d.dispatched_at desc nulls last limit 1 for update of d;
    if v_deployment_id is null then
      v_result:=jsonb_build_object('ok',false,'code','deployment_not_found','message','No active deployment was found for that officer and incident.');
      update game.game_commands set status='rejected',rejection_reason='Active deployment not found.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    if v_deployment_status='on_scene' or v_arrived_at is not null then
      v_result:=jsonb_build_object('ok',false,'code','already_on_scene','message','This officer is already recorded as on scene.');
      update game.game_commands set status='rejected',rejection_reason='Officer already on scene.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    if v_deployment_status<>'responding' then
      v_result:=jsonb_build_object('ok',false,'code','dispatch_not_acknowledged','message','The officer must acknowledge the dispatch before reporting arrival.');
      update game.game_commands set status='rejected',rejection_reason='Dispatch acknowledgement required before arrival.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    if v_dispatched_at is null or v_clock.current_game_time<v_dispatched_at then
      v_result:=jsonb_build_object('ok',false,'code','invalid_game_time','message','The fictional clock cannot record arrival before dispatch.');
      update game.game_commands set status='rejected',rejection_reason='Arrival precedes dispatch time.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    update game.incident_deployments set status='on_scene',arrived_at=v_clock.current_game_time where id=v_deployment_id;
    if v_incident_status='dispatched' then update game.incidents set status='attending',updated_at=now() where id=v_incident_id; end if;
    insert into game.dispatch_events(incident_id,event_at,event_type,personnel_id,unit_id,details)
      select v_incident_id,v_clock.current_game_time,'officer_arrived',d.personnel_id,d.unit_id,
        jsonb_build_object('personnel_ref',v_personnel_ref,'command_id',v_command.id)
      from game.incident_deployments d where d.id=v_deployment_id;
    insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data)
      select 'dispatch.officer_arrived',v_clock.current_game_time,p_actor_personnel_id,'incident_deployment',d.id,
        jsonb_build_object('command_id',v_command.id,'incident_ref',v_incident_ref,'personnel_ref',v_personnel_ref)
      from game.incident_deployments d where d.id=v_deployment_id;
    v_result:=jsonb_build_object('ok',true,'status','completed','command_id',v_command.id,
      'incident_ref',v_incident_ref,'personnel_ref',v_personnel_ref,'deployment_status','on_scene',
      'incident_status',case when v_incident_status='dispatched' then 'attending' else v_incident_status end,
      'game_time',v_clock.current_game_time,'message','Officer arrival recorded. The officer is now on scene.');
  elsif v_type = any(v_scene_action_types) then
    v_result:=game.execute_scene_action(v_command.id,v_type,p_payload,p_actor_personnel_id);
    if coalesce((v_result->>'ok')::boolean,false)=false then
      update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Scene action rejected.'),result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
  else
    v_result:=jsonb_build_object('ok',false,'code','unknown_command','message','This command is not registered in the runtime yet.','command_type',v_type);
    update game.game_commands set status='rejected',rejection_reason='Command type is not registered.',result=v_result,completed_at=now() where id=v_command.id;
    return v_result || jsonb_build_object('command_id',v_command.id);
  end if;
  update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_command.id;
  return v_result;
end;
$function$
;
CREATE OR REPLACE FUNCTION game.interpret_text_command(p_command_text text)
 RETURNS jsonb
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare
  v_text text:=btrim(coalesce(p_command_text,''));
  v_match text[];
begin
  if char_length(v_text)=0 or char_length(v_text)>4000 then
    return jsonb_build_object('recognized',false,'command_type','unknown','payload','{}'::jsonb,'message','Enter a command between 1 and 4000 characters.');
  end if;
  if lower(v_text) in ('help','commands') then
    return jsonb_build_object('recognized',true,'command_type','help','payload','{}'::jsonb);
  elsif lower(v_text) in ('status','game status','clock status') then
    return jsonb_build_object('recognized',true,'command_type','status','payload','{}'::jsonb);
  end if;
  v_match:=regexp_match(v_text,'^advance[[:space:]]+time[[:space:]]+([0-9]+)[[:space:]]+minutes?$','i');
  if v_match is not null then
    return jsonb_build_object('recognized',true,'command_type','advance_time','payload',jsonb_build_object('minutes',v_match[1]::numeric));
  end if;
  v_match:=regexp_match(v_text,'^acknowledge[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+for[[:space:]]+([A-Za-z0-9._/-]+)$','i');
  if v_match is not null then
    return jsonb_build_object('recognized',true,'command_type','acknowledge_dispatch','payload',jsonb_build_object('personnel_ref',v_match[1],'incident_ref',v_match[2]));
  end if;
  v_match:=regexp_match(v_text,'^arrive[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+at[[:space:]]+([A-Za-z0-9._/-]+)$','i');
  if v_match is not null then
    return jsonb_build_object('recognized',true,'command_type','arrive_scene','payload',jsonb_build_object('personnel_ref',v_match[1],'incident_ref',v_match[2]));
  end if;
    v_match:=regexp_match(v_text,'^dispatch[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+to[[:space:]]+([A-Za-z0-9._/-]+)$','i');
  if v_match is not null then
    return jsonb_build_object('recognized',true,'command_type','dispatch_unit','payload',jsonb_build_object('unit_ref',v_match[1],'incident_ref',v_match[2]));
  end if;
  v_match:=regexp_match(v_text,'^(911|call|report|radio)[[:space:]]*:?[[:space:]]*(.+?)[[:space:]]+at[[:space:]]+(.+)$','i');
  if v_match is not null then
    return jsonb_build_object('recognized',true,'command_type','receive_call','payload',
      jsonb_build_object('summary',btrim(v_match[2]),'location',btrim(v_match[3]),
        'channel',case when lower(v_match[1])='radio' then 'radio' else 'telephone' end,'priority',3));
  end if;
  v_match:=regexp_match(v_text,'^establish[[:space:]]+scene[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+at[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+by[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+because[[:space:]]+(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','establish_scene','payload',jsonb_build_object('scene_ref',v_match[1],'incident_ref',v_match[2],'personnel_ref',v_match[3],'reason',v_match[4])); end if;
  v_match:=regexp_match(v_text,'^take[[:space:]]+command[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+of[[:space:]]+([A-Za-z0-9._/-]+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','assume_scene_command','payload',jsonb_build_object('personnel_ref',v_match[1],'scene_ref',v_match[2])); end if;
  v_match:=regexp_match(v_text,'^scene[[:space:]]+update[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+for[[:space:]]+([A-Za-z0-9._/-]+):[[:space:]]*(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','scene_update','payload',jsonb_build_object('personnel_ref',v_match[1],'scene_ref',v_match[2],'description',v_match[3])); end if;
  v_match:=regexp_match(v_text,'^field[[:space:]]+report[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+for[[:space:]]+([A-Za-z0-9._/-]+)(?:[[:space:]]+at[[:space:]]+([A-Za-z0-9._/-]+))?:[[:space:]]*(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','submit_field_report','payload',jsonb_build_object('personnel_ref',v_match[1],'incident_ref',v_match[2],'scene_ref',v_match[3],'narrative',v_match[4])); end if;
  v_match:=regexp_match(v_text,'^request[[:space:]]+resource[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+for[[:space:]]+([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[[:space:]]*[|][[:space:]]*(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','request_scene_resource','payload',jsonb_build_object('personnel_ref',v_match[1],'scene_ref',v_match[2],'resource_type',btrim(v_match[3]),'reason',btrim(v_match[4]))); end if;
  v_match:=regexp_match(v_text,'^scene[[:space:]]+(entry|exit)[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+(?:into|from)[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+for[[:space:]]+(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type',case when lower(v_match[1])='entry' then 'scene_entry' else 'scene_exit' end,'payload',jsonb_build_object('personnel_ref',v_match[2],'scene_ref',v_match[3],'purpose',v_match[4])); end if;
    return jsonb_build_object('recognized',false,'command_type','unknown','payload','{}'::jsonb,
    'message','Command not recognised. Use help to see the supported command forms.');
end;
$function$
;
revoke all on function game.execute_scene_action(uuid,text,jsonb,uuid) from public,anon,authenticated;
grant execute on function game.execute_scene_action(uuid,text,jsonb,uuid) to service_role;
revoke all on function game.submit_command(text,text,jsonb,text,uuid,uuid) from public,anon,authenticated;
revoke all on function game.interpret_text_command(text) from public,anon,authenticated;
grant execute on function game.submit_command(text,text,jsonb,text,uuid,uuid) to service_role;
grant execute on function game.interpret_text_command(text) to service_role;
