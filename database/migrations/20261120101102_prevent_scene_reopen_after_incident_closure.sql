-- Prevent reopening a released scene after its originating incident is concluded.
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
 v_quantity integer; v_priority smallint; v_resource_request_id uuid; v_resource_status text; v_requester_id uuid; v_request_notes text;
begin
 select current_game_time into v_clock_time from game.simulation_state where id=1 for update;
 if v_clock_time is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Scene and field actions require the fictional game clock to be initialized.'); end if;
 v_personnel_ref:=nullif(btrim(p_payload->>'personnel_ref'),'');
 if v_personnel_ref is null then return jsonb_build_object('ok',false,'code','missing_personnel_reference','message','A personnel reference is required.'); end if;
 select id into v_personnel_id from game.police_personnel where personnel_ref=v_personnel_ref and employment_status='active';
 if v_personnel_id is null then return jsonb_build_object('ok',false,'code','personnel_unavailable','message','The named officer does not exist or is not actively employed.'); end if;
 if p_command_type in ('approve_scene_resource','decline_scene_resource','fulfil_scene_resource','cancel_scene_resource') then
  v_request_ref:=nullif(btrim(p_payload->>'request_ref'),''); v_request_notes:=nullif(btrim(p_payload->>'notes'),'');
  if v_request_ref is null or v_request_notes is null or char_length(v_request_notes)>2000 then return jsonb_build_object('ok',false,'code','invalid_resource_response','message','A resource request reference and notes between 1 and 2000 characters are required.'); end if;
  select rr.id,rr.status,rr.requested_by_personnel_id,rr.scene_id,s.scene_ref,s.incident_id,s.scene_manager_personnel_id,s.status,i.incident_ref into v_resource_request_id,v_resource_status,v_requester_id,v_scene_id,v_scene_ref,v_incident_id,v_scene_manager,v_scene_status,v_incident_ref from game.incident_resource_requests rr join game.incident_scenes s on s.id=rr.scene_id join game.incidents i on i.id=rr.incident_id where rr.request_ref=v_request_ref for update of rr,s;
  if v_resource_request_id is null then return jsonb_build_object('ok',false,'code','resource_request_not_found','message','No resource request exists with that reference.'); end if;
  if p_command_type in ('approve_scene_resource','decline_scene_resource','cancel_scene_resource') and v_scene_manager is distinct from v_personnel_id then return jsonb_build_object('ok',false,'code','scene_command_required','message','Only the current scene manager can approve, decline or cancel this scene resource request.'); end if;
  if p_command_type='approve_scene_resource' then
   if v_resource_status not in ('requested','acknowledged') then return jsonb_build_object('ok',false,'code','resource_request_not_approvable','message','Only requested or acknowledged resource requests can be approved.'); end if;
   update game.incident_resource_requests set status='approved',responded_at=v_clock_time,responded_by_personnel_id=v_personnel_id,response_notes=v_request_notes where id=v_resource_request_id;
  elsif p_command_type='decline_scene_resource' then
   if v_resource_status not in ('requested','acknowledged') then return jsonb_build_object('ok',false,'code','resource_request_not_declineable','message','Only requested or acknowledged resource requests can be declined.'); end if;
   update game.incident_resource_requests set status='declined',responded_at=v_clock_time,responded_by_personnel_id=v_personnel_id,response_notes=v_request_notes where id=v_resource_request_id;
  elsif p_command_type='cancel_scene_resource' then
   if v_resource_status not in ('requested','acknowledged','approved') then return jsonb_build_object('ok',false,'code','resource_request_not_cancellable','message','This resource request can no longer be cancelled.'); end if;
   update game.incident_resource_requests set status='cancelled',responded_at=v_clock_time,responded_by_personnel_id=v_personnel_id,response_notes=v_request_notes where id=v_resource_request_id;
  else
   if v_resource_status<>'approved' then return jsonb_build_object('ok',false,'code','resource_request_not_approved','message','A resource request must be approved before fulfilment is recorded.'); end if;
   if not exists(select 1 from game.incident_deployments d where d.incident_id=v_incident_id and d.personnel_id=v_personnel_id and d.status='on_scene' and d.cleared_at is null) then return jsonb_build_object('ok',false,'code','resource_fulfiller_not_on_scene','message','The officer recording fulfilment must have an active on-scene deployment at the incident.'); end if;
   update game.incident_resource_requests set status='fulfilled',fulfilled_by_personnel_id=v_personnel_id,fulfilled_at=v_clock_time,response_notes=v_request_notes where id=v_resource_request_id;
  end if;
  insert into game.scene_resource_request_events(resource_request_id,event_at,event_type,actor_personnel_id,notes,source_command_id) values(v_resource_request_id,v_clock_time,case p_command_type when 'approve_scene_resource' then 'approved' when 'decline_scene_resource' then 'declined' when 'cancel_scene_resource' then 'cancelled' else 'fulfilled' end,v_personnel_id,v_request_notes,p_command_id);
  insert into game.scene_activity_logs(scene_id,event_at,event_type,personnel_id,description,details,source_command_id) values(v_scene_id,v_clock_time,'resource_'||case p_command_type when 'approve_scene_resource' then 'approved' when 'decline_scene_resource' then 'declined' when 'cancel_scene_resource' then 'cancelled' else 'fulfilled' end,v_personnel_id,'Resource request '||v_request_ref||' updated.',jsonb_build_object('request_ref',v_request_ref,'previous_status',v_resource_status,'notes',v_request_notes),p_command_id);
  insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data) values('scene.resource_request_'||case p_command_type when 'approve_scene_resource' then 'approved' when 'decline_scene_resource' then 'declined' when 'cancel_scene_resource' then 'cancelled' else 'fulfilled' end,v_clock_time,v_personnel_id,'incident_scene',v_scene_id,jsonb_build_object('command_id',p_command_id,'request_ref',v_request_ref,'notes',v_request_notes));
  return jsonb_build_object('ok',true,'scene_ref',v_scene_ref,'incident_ref',v_incident_ref,'request_ref',v_request_ref,'request_status',case p_command_type when 'approve_scene_resource' then 'approved' when 'decline_scene_resource' then 'declined' when 'cancel_scene_resource' then 'cancelled' else 'fulfilled' end,'game_time',v_clock_time,'message','Resource request status updated and recorded.');
 end if;

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
 if p_command_type in ('scene_update','assume_scene_command','request_scene_resource','scene_entry','scene_exit','release_scene','reopen_scene') then
  v_scene_ref:=nullif(btrim(p_payload->>'scene_ref'),'');
  if v_scene_ref is null then return jsonb_build_object('ok',false,'code','missing_scene_reference','message','A scene reference is required.'); end if;
  select s.id,s.incident_id,s.status,s.scene_manager_personnel_id,i.incident_ref,i.status into v_scene_id,v_incident_id,v_scene_status,v_scene_manager,v_incident_ref,v_incident_status from game.incident_scenes s join game.incidents i on i.id=s.incident_id where s.scene_ref=v_scene_ref for update of s;
  if v_scene_id is null then return jsonb_build_object('ok',false,'code','scene_not_found','message','No scene exists with that reference.'); end if;
  if v_scene_status='closed' or (v_scene_status='released' and p_command_type<>'reopen_scene') then return jsonb_build_object('ok',false,'code','scene_not_active','message','This scene is released or closed.'); end if;
  if p_command_type in ('scene_update','assume_scene_command','request_scene_resource','release_scene','reopen_scene') and not exists(select 1 from game.incident_deployments d where d.incident_id=v_incident_id and d.personnel_id=v_personnel_id and d.status='on_scene' and d.cleared_at is null) then return jsonb_build_object('ok',false,'code','officer_not_on_scene','message','The officer must have an active on-scene deployment at the originating incident.'); end if;
 end if;
 if p_command_type='release_scene' then
  v_reason:=nullif(btrim(p_payload->>'reason'),'');
  if v_reason is null then return jsonb_build_object('ok',false,'code','release_reason_required','message','A reason is required to release a scene.'); end if;
  if v_scene_manager is distinct from v_personnel_id then return jsonb_build_object('ok',false,'code','scene_command_required','message','Only the current scene manager can release the scene.'); end if;
  if v_scene_status in ('released','closed') then return jsonb_build_object('ok',false,'code','scene_not_releasable','message','The scene is already released or closed.'); end if;
  if not exists(select 1 from game.scene_safety_assessments where scene_id=v_scene_id) then return jsonb_build_object('ok',false,'code','safety_assessment_required','message','A recorded scene safety assessment is required before release.'); end if;
  if exists(select 1 from game.incident_resource_requests where scene_id=v_scene_id and status in ('requested','acknowledged','approved')) then return jsonb_build_object('ok',false,'code','resource_requests_outstanding','message','Outstanding resource requests must be resolved before scene release.'); end if;
  if exists(select 1 from game.scene_access_events e where e.scene_id=v_scene_id and e.action='entry' and not exists(select 1 from game.scene_access_events x where x.scene_id=e.scene_id and x.personnel_id=e.personnel_id and x.zone_ref=e.zone_ref and x.action='exit' and x.event_sequence>e.event_sequence)) then return jsonb_build_object('ok',false,'code','personnel_still_inside_scene','message','All recorded scene entries must have matching exits before release.'); end if;
  update game.incident_scenes set status='released',released_at=v_clock_time,updated_at=now() where id=v_scene_id;
  insert into game.scene_lifecycle_events(scene_id,event_at,event_type,personnel_id,reason,source_command_id) values(v_scene_id,v_clock_time,'released',v_personnel_id,v_reason,p_command_id);
  insert into game.scene_activity_logs(scene_id,event_at,event_type,personnel_id,description,details,source_command_id) values(v_scene_id,v_clock_time,'scene_released',v_personnel_id,'Scene formally released.',jsonb_build_object('reason',v_reason),p_command_id);
  insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data) values('scene.released',v_clock_time,v_personnel_id,'incident_scene',v_scene_id,jsonb_build_object('command_id',p_command_id,'scene_ref',v_scene_ref,'reason',v_reason));
  return jsonb_build_object('ok',true,'scene_ref',v_scene_ref,'scene_status','released','released_at',v_clock_time,'message','Scene formally released. The scene record and its history remain retained.');
 elsif p_command_type='reopen_scene' then
  v_reason:=nullif(btrim(p_payload->>'reason'),'');
  if v_reason is null then return jsonb_build_object('ok',false,'code','reopen_reason_required','message','A reason is required to reopen a scene.'); end if;
  if v_scene_status<>'released' then return jsonb_build_object('ok',false,'code','scene_not_reopenable','message','Only a released scene can be reopened.'); end if;
  if v_incident_status in ('resolved','closed','cancelled') then return jsonb_build_object('ok',false,'code','incident_not_reopenable','message','A scene cannot be reopened after its originating incident has been concluded.'); end if;
  update game.incident_scenes set status='reopened',scene_manager_personnel_id=v_personnel_id,released_at=null,attended_at=v_clock_time,updated_at=now() where id=v_scene_id;
  insert into game.scene_lifecycle_events(scene_id,event_at,event_type,personnel_id,reason,source_command_id) values(v_scene_id,v_clock_time,'reopened',v_personnel_id,v_reason,p_command_id);
  insert into game.scene_activity_logs(scene_id,event_at,event_type,personnel_id,description,details,source_command_id) values(v_scene_id,v_clock_time,'scene_reopened',v_personnel_id,'Previously released scene reopened.',jsonb_build_object('reason',v_reason),p_command_id);
  insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data) values('scene.reopened',v_clock_time,v_personnel_id,'incident_scene',v_scene_id,jsonb_build_object('command_id',p_command_id,'scene_ref',v_scene_ref,'reason',v_reason));
  return jsonb_build_object('ok',true,'scene_ref',v_scene_ref,'scene_status','reopened','scene_manager',v_personnel_ref,'game_time',v_clock_time,'message','Scene reopened and scene command assigned to the attending officer.');
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
  if nullif(p_payload->>'quantity','') is not null and not pg_input_is_valid(p_payload->>'quantity','integer') then return jsonb_build_object('ok',false,'code','invalid_resource_quantity','message','Resource quantity must be a whole number.'); end if;
  if nullif(p_payload->>'priority','') is not null and not pg_input_is_valid(p_payload->>'priority','integer') then return jsonb_build_object('ok',false,'code','invalid_resource_priority','message','Resource priority must be a whole number from 1 to 5.'); end if;
  v_quantity:=greatest(1,coalesce((p_payload->>'quantity')::integer,1)); v_priority:=least(5,greatest(1,coalesce((p_payload->>'priority')::integer,3)));
  v_request_ref:='KWR-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  insert into game.incident_resource_requests(request_ref,incident_id,scene_id,requested_by_personnel_id,resource_type,quantity,priority,reason,status,requested_at,source_command_id) values(v_request_ref,v_incident_id,v_scene_id,v_personnel_id,v_resource_type,v_quantity,v_priority,v_reason,'requested',v_clock_time,p_command_id);
  insert into game.scene_activity_logs(scene_id,event_at,event_type,personnel_id,description,details,source_command_id) values(v_scene_id,v_clock_time,'resource_requested',v_personnel_id,'Additional resource requested: '||v_resource_type,jsonb_build_object('request_ref',v_request_ref,'quantity',v_quantity,'priority',v_priority,'reason',v_reason),p_command_id);
  insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data) values('scene.resource_requested',v_clock_time,v_personnel_id,'incident_scene',v_scene_id,jsonb_build_object('command_id',p_command_id,'request_ref',v_request_ref,'resource_type',v_resource_type,'reason',v_reason));
  return jsonb_build_object('ok',true,'scene_ref',v_scene_ref,'request_ref',v_request_ref,'resource_type',v_resource_type,'request_status','requested','game_time',v_clock_time,'message','Resource request recorded. It has not yet been approved or deployed.');
 elsif p_command_type in ('scene_entry','scene_exit') then
  v_purpose:=nullif(btrim(p_payload->>'purpose'),''); v_zone:=coalesce(nullif(btrim(p_payload->>'zone'),''),'general');
  if v_purpose is null then return jsonb_build_object('ok',false,'code','missing_access_purpose','message','A purpose is required for every scene entry or exit.'); end if;
  select action into v_last_action from game.scene_access_events where scene_id=v_scene_id and personnel_id=v_personnel_id and zone_ref=v_zone order by event_sequence desc limit 1;
  if p_command_type='scene_entry' and v_last_action='entry' then return jsonb_build_object('ok',false,'code','already_inside_scene_zone','message','The officer already has an unmatched entry in this scene zone.'); end if;
  if p_command_type='scene_exit' and coalesce(v_last_action,'')<>'entry' then return jsonb_build_object('ok',false,'code','no_open_scene_entry','message','No matching recorded entry exists for this officer in that scene zone.'); end if;
  insert into game.scene_access_events(scene_id,event_at,action,personnel_id,organisation_name,role_description,zone_ref,purpose,recorded_by_personnel_id,source_command_id) values(v_scene_id,v_clock_time,case when p_command_type='scene_entry' then 'entry' else 'exit' end,v_personnel_id,'Kingswell Police Department','Police personnel',v_zone,v_purpose,v_personnel_id,p_command_id);
  insert into game.scene_activity_logs(scene_id,event_at,event_type,personnel_id,description,details,source_command_id) values(v_scene_id,v_clock_time,case when p_command_type='scene_entry' then 'person_entered' else 'person_exited' end,v_personnel_id,'Scene access event recorded: '||p_command_type,jsonb_build_object('zone_ref',v_zone,'purpose',v_purpose),p_command_id);
  return jsonb_build_object('ok',true,'scene_ref',v_scene_ref,'action',case when p_command_type='scene_entry' then 'entry' else 'exit' end,'zone_ref',v_zone,'personnel_ref',v_personnel_ref,'game_time',v_clock_time,'message','Scene access event recorded.');
 end if;
 if p_command_type='record_scene_safety' then
  v_scene_ref:=nullif(btrim(p_payload->>'scene_ref'),'');
  v_description:=nullif(btrim(p_payload->>'hazard_summary'),'');
  v_reason:=nullif(btrim(p_payload->>'controls_taken'),'');
  if v_scene_ref is null or v_description is null or v_reason is null or nullif(btrim(p_payload->>'residual_risk'),'') is null then
    return jsonb_build_object('ok',false,'code','incomplete_safety_assessment','message','Scene reference, hazard summary, controls taken and residual risk are required.');
  end if;
  select s.id,s.incident_id,s.status,i.incident_ref into v_scene_id,v_incident_id,v_scene_status,v_incident_ref
    from game.incident_scenes s join game.incidents i on i.id=s.incident_id
    where s.scene_ref=v_scene_ref for update of s;
  if v_scene_id is null then return jsonb_build_object('ok',false,'code','scene_not_found','message','No scene exists with that reference.'); end if;
  if v_scene_status in ('released','closed') then return jsonb_build_object('ok',false,'code','scene_not_active','message','This scene is released or closed.'); end if;
  if not exists(select 1 from game.incident_deployments d where d.incident_id=v_incident_id and d.personnel_id=v_personnel_id and d.status='on_scene' and d.cleared_at is null) then
    return jsonb_build_object('ok',false,'code','officer_not_on_scene','message','The officer must have an active on-scene deployment at the originating incident.');
  end if;
  insert into game.scene_safety_assessments(scene_id,assessed_by_personnel_id,assessed_at,hazard_summary,people_at_risk,controls_taken,residual_risk,specialist_support_required,details,source_command_id)
  values(v_scene_id,v_personnel_id,v_clock_time,v_description,nullif(btrim(p_payload->>'people_at_risk'),''),v_reason,
    btrim(p_payload->>'residual_risk'),coalesce((p_payload->>'specialist_support_required')::boolean,false),
    coalesce(p_payload->'details','{}'::jsonb),p_command_id);
  update game.incident_scenes set safety_status='assessed',updated_at=now() where id=v_scene_id;
  insert into game.scene_activity_logs(scene_id,event_at,event_type,personnel_id,description,details,source_command_id)
  values(v_scene_id,v_clock_time,'safety_assessment_recorded',v_personnel_id,'Scene safety assessment recorded.',
    jsonb_build_object('hazard_summary',v_description,'controls_taken',v_reason,'residual_risk',btrim(p_payload->>'residual_risk'),'specialist_support_required',coalesce((p_payload->>'specialist_support_required')::boolean,false)),p_command_id);
  insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data)
  values('scene.safety_assessed',v_clock_time,v_personnel_id,'incident_scene',v_scene_id,
    jsonb_build_object('command_id',p_command_id,'incident_ref',v_incident_ref,'scene_ref',v_scene_ref));
  return jsonb_build_object('ok',true,'scene_ref',v_scene_ref,'safety_status','assessed','game_time',v_clock_time,'message','Scene safety assessment recorded.');
 elsif p_command_type='set_scene_boundary' then
  v_scene_ref:=nullif(btrim(p_payload->>'scene_ref'),'');
  v_description:=nullif(btrim(p_payload->>'boundary_description'),'');
  v_reason:=nullif(btrim(p_payload->>'reason'),'');
  if v_scene_ref is null or v_description is null or v_reason is null then
    return jsonb_build_object('ok',false,'code','incomplete_boundary_details','message','Scene reference, boundary description and reason are required.');
  end if;
  select id,incident_id,status,scene_manager_personnel_id into v_scene_id,v_incident_id,v_scene_status,v_scene_manager
    from game.incident_scenes where scene_ref=v_scene_ref for update;
  if v_scene_id is null then return jsonb_build_object('ok',false,'code','scene_not_found','message','No scene exists with that reference.'); end if;
  if v_scene_status in ('released','closed') then return jsonb_build_object('ok',false,'code','scene_not_active','message','This scene is released or closed.'); end if;
  if v_scene_manager is distinct from v_personnel_id then return jsonb_build_object('ok',false,'code','scene_command_required','message','Only the current scene manager can revise scene boundaries.'); end if;
  if not exists(select 1 from game.incident_deployments d where d.incident_id=v_incident_id and d.personnel_id=v_personnel_id and d.status='on_scene' and d.cleared_at is null) then
    return jsonb_build_object('ok',false,'code','officer_not_on_scene','message','The scene manager must remain on scene to revise the boundary.');
  end if;
  update game.scene_boundary_revisions set status='superseded' where scene_id=v_scene_id and status='active';
  v_request_ref:='KWB-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  insert into game.scene_boundary_revisions(scene_id,boundary_ref,boundary_description,rationale,status,effective_at,set_by_personnel_id,source_command_id)
  values(v_scene_id,v_request_ref,v_description,v_reason,'active',v_clock_time,v_personnel_id,p_command_id);
  update game.incident_scenes set boundary_description=v_description,updated_at=now() where id=v_scene_id;
  insert into game.scene_activity_logs(scene_id,event_at,event_type,personnel_id,description,details,source_command_id)
  values(v_scene_id,v_clock_time,'scene_boundary_revised',v_personnel_id,'Scene boundary revised.',
    jsonb_build_object('boundary_ref',v_request_ref,'boundary_description',v_description,'reason',v_reason),p_command_id);
  insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data)
  values('scene.boundary_revised',v_clock_time,v_personnel_id,'incident_scene',v_scene_id,
    jsonb_build_object('command_id',p_command_id,'boundary_ref',v_request_ref,'boundary_description',v_description,'reason',v_reason));
  return jsonb_build_object('ok',true,'scene_ref',v_scene_ref,'boundary_ref',v_request_ref,'boundary_description',v_description,'game_time',v_clock_time,'message','Scene boundary revision recorded.');
 end if;

 if p_command_type='submit_field_report' then
  v_incident_ref:=nullif(btrim(p_payload->>'incident_ref'),''); v_description:=nullif(btrim(p_payload->>'narrative'),''); v_scene_ref:=nullif(btrim(p_payload->>'scene_ref'),'');
  if v_incident_ref is null or v_description is null or char_length(v_description)>8000 then return jsonb_build_object('ok',false,'code','invalid_field_report','message','Incident reference and a narrative between 1 and 8000 characters are required.'); end if;
  select id,status into v_incident_id,v_incident_status from game.incidents where incident_ref=v_incident_ref for update;
  if v_incident_id is null then return jsonb_build_object('ok',false,'code','incident_not_found','message','No incident exists with that reference.'); end if;
  if v_incident_status in ('resolved','closed','cancelled') then return jsonb_build_object('ok',false,'code','incident_not_active','message','A field report cannot be submitted to a concluded incident.'); end if;
  if not exists(select 1 from game.incident_deployments d where d.incident_id=v_incident_id and d.personnel_id=v_personnel_id and d.status='on_scene' and d.cleared_at is null) then return jsonb_build_object('ok',false,'code','officer_not_on_scene','message','The officer must be recorded on scene before submitting a field report.'); end if;
  if nullif(p_payload->>'observed_at','') is not null and not pg_input_is_valid(p_payload->>'observed_at','timestamptz') then return jsonb_build_object('ok',false,'code','invalid_observed_at','message','Observed time must be a valid timestamp.'); end if;
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
revoke all on function game.execute_scene_action(uuid,text,jsonb,uuid) from public,anon,authenticated;
grant execute on function game.execute_scene_action(uuid,text,jsonb,uuid) to service_role;
