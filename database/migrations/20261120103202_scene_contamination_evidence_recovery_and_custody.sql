-- Source reconstructed from the live database and applied migration history.
-- Applied version: 20261120103202_scene_contamination_evidence_recovery_and_custody

create table game.scene_contamination_events (
  id uuid default gen_random_uuid() not null,
  contamination_ref text not null,
  scene_id uuid not null,
  incident_id uuid not null,
  zone_ref text not null,
  material_or_source text not null,
  suspected_source text,
  control_action text not null,
  notes text,
  recorded_by_personnel_id uuid not null,
  recorded_at timestamptz not null,
  source_command_id uuid,
  created_at timestamptz default now() not null,
  constraint scene_contamination_events_contamination_ref_key UNIQUE (contamination_ref),
  constraint scene_contamination_events_incident_id_fkey FOREIGN KEY (incident_id) REFERENCES game.incidents(id),
  constraint scene_contamination_events_pkey PRIMARY KEY (id),
  constraint scene_contamination_events_recorded_by_personnel_id_fkey FOREIGN KEY (recorded_by_personnel_id) REFERENCES game.police_personnel(id),
  constraint scene_contamination_events_scene_id_fkey FOREIGN KEY (scene_id) REFERENCES game.incident_scenes(id),
  constraint scene_contamination_events_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id)
);

create table game.scene_evidence_recoveries (
  id uuid default gen_random_uuid() not null,
  recovery_ref text not null,
  scene_id uuid not null,
  incident_id uuid not null,
  evidence_id uuid not null,
  plan_id uuid not null,
  recovered_by_personnel_id uuid not null,
  recovered_at timestamptz not null,
  recovery_location text not null,
  recovery_method text not null,
  packaging text not null,
  seal_identifier text not null,
  condition_on_recovery text not null,
  source_command_id uuid,
  created_at timestamptz default now() not null,
  constraint scene_evidence_recoveries_evidence_id_fkey FOREIGN KEY (evidence_id) REFERENCES game.evidence_items(id),
  constraint scene_evidence_recoveries_evidence_id_key UNIQUE (evidence_id),
  constraint scene_evidence_recoveries_incident_id_fkey FOREIGN KEY (incident_id) REFERENCES game.incidents(id),
  constraint scene_evidence_recoveries_pkey PRIMARY KEY (id),
  constraint scene_evidence_recoveries_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES game.scene_examination_plans(id),
  constraint scene_evidence_recoveries_recovered_by_personnel_id_fkey FOREIGN KEY (recovered_by_personnel_id) REFERENCES game.police_personnel(id),
  constraint scene_evidence_recoveries_recovery_ref_key UNIQUE (recovery_ref),
  constraint scene_evidence_recoveries_scene_id_fkey FOREIGN KEY (scene_id) REFERENCES game.incident_scenes(id),
  constraint scene_evidence_recoveries_seal_identifier_key UNIQUE (seal_identifier),
  constraint scene_evidence_recoveries_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id)
);

create table game.scene_evidence_transfer_events (
  id uuid default gen_random_uuid() not null,
  transfer_ref text not null,
  scene_id uuid not null,
  evidence_id uuid not null,
  transfer_id uuid not null,
  event_at timestamptz not null,
  recorded_by_personnel_id uuid not null,
  from_personnel_id uuid,
  to_personnel_id uuid,
  from_location text not null,
  to_location text not null,
  reason text not null,
  notes text,
  source_command_id uuid,
  created_at timestamptz default now() not null,
  constraint scene_evidence_transfer_events_evidence_id_fkey FOREIGN KEY (evidence_id) REFERENCES game.evidence_items(id),
  constraint scene_evidence_transfer_events_from_personnel_id_fkey FOREIGN KEY (from_personnel_id) REFERENCES game.police_personnel(id),
  constraint scene_evidence_transfer_events_pkey PRIMARY KEY (id),
  constraint scene_evidence_transfer_events_recorded_by_personnel_id_fkey FOREIGN KEY (recorded_by_personnel_id) REFERENCES game.police_personnel(id),
  constraint scene_evidence_transfer_events_scene_id_fkey FOREIGN KEY (scene_id) REFERENCES game.incident_scenes(id),
  constraint scene_evidence_transfer_events_source_command_id_fkey FOREIGN KEY (source_command_id) REFERENCES game.game_commands(id),
  constraint scene_evidence_transfer_events_to_personnel_id_fkey FOREIGN KEY (to_personnel_id) REFERENCES game.police_personnel(id),
  constraint scene_evidence_transfer_events_transfer_id_fkey FOREIGN KEY (transfer_id) REFERENCES game.evidence_transfers(id),
  constraint scene_evidence_transfer_events_transfer_id_key UNIQUE (transfer_id),
  constraint scene_evidence_transfer_events_transfer_ref_key UNIQUE (transfer_ref)
);

CREATE INDEX scene_contamination_events_incident_idx ON game.scene_contamination_events USING btree (incident_id);
CREATE INDEX scene_contamination_events_scene_time_idx ON game.scene_contamination_events USING btree (scene_id, recorded_at);
CREATE INDEX scene_evidence_recoveries_plan_idx ON game.scene_evidence_recoveries USING btree (plan_id);
CREATE INDEX scene_evidence_recoveries_scene_time_idx ON game.scene_evidence_recoveries USING btree (scene_id, recovered_at);
CREATE INDEX scene_evidence_transfer_events_evidence_time_idx ON game.scene_evidence_transfer_events USING btree (evidence_id, event_at);
CREATE INDEX scene_evidence_transfer_events_scene_idx ON game.scene_evidence_transfer_events USING btree (scene_id, event_at);

alter table game.scene_contamination_events enable row level security;
alter table game.scene_evidence_recoveries enable row level security;
alter table game.scene_evidence_transfer_events enable row level security;

CREATE OR REPLACE FUNCTION game.execute_evidence_action(p_command_id uuid, p_command_type text, p_payload jsonb, p_actor_personnel_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare
 v_now timestamptz; v_actor uuid; v_scene uuid; v_incident uuid; v_scene_ref text;
 v_plan uuid; v_plan_status text; v_examiner uuid; v_attendance uuid; v_qualification uuid;
 v_evidence uuid; v_evidence_ref text; v_recovery_ref text; v_transfer_ref text; v_transfer uuid;
 v_zone text; v_material text; v_source text; v_action text; v_notes text;
 v_type text; v_description text; v_location text; v_method text; v_packaging text; v_seal text; v_condition text;
 v_to uuid; v_to_ref text; v_from_location text; v_to_location text; v_reason text; v_custodian uuid;
begin
 select current_game_time into v_now from game.simulation_state where id=1 for update;
 if v_now is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','This action requires the fictional game clock.'); end if;
 select id into v_actor from game.police_personnel where personnel_ref=nullif(btrim(p_payload->>'personnel_ref'),'') and employment_status='active';
 if v_actor is null then return jsonb_build_object('ok',false,'code','personnel_unavailable','message','An active personnel reference is required.'); end if;

 if p_command_type='record_scene_contamination' then
  v_scene_ref:=nullif(btrim(p_payload->>'scene_ref'),'');
  select id,incident_id into v_scene,v_incident from game.incident_scenes where scene_ref=v_scene_ref and status not in ('released','closed') for update;
  if v_scene is null then return jsonb_build_object('ok',false,'code','scene_not_active','message','An active scene is required.'); end if;
  if not exists(select 1 from game.incident_deployments where incident_id=v_incident and personnel_id=v_actor and status='on_scene' and cleared_at is null) then return jsonb_build_object('ok',false,'code','officer_not_on_scene','message','Only an officer recorded on scene can report contamination.'); end if;
  v_zone:=nullif(btrim(p_payload->>'zone'),''); v_material:=nullif(btrim(p_payload->>'material'),''); v_source:=nullif(btrim(p_payload->>'source'),''); v_action:=nullif(btrim(p_payload->>'control_action'),''); v_notes:=nullif(btrim(p_payload->>'notes'),'');
  if v_zone is null or v_material is null or v_action is null then return jsonb_build_object('ok',false,'code','contamination_details_required','message','Zone, material and control action are required.'); end if;
  v_recovery_ref:='KWCT-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  insert into game.scene_contamination_events(contamination_ref,scene_id,incident_id,zone_ref,material_or_source,suspected_source,control_action,notes,recorded_by_personnel_id,recorded_at,source_command_id)
  values(v_recovery_ref,v_scene,v_incident,v_zone,v_material,v_source,v_action,v_notes,v_actor,v_now,p_command_id);
  insert into game.scene_activity_logs(scene_id,event_at,event_type,personnel_id,description,details,source_command_id)
  values(v_scene,v_now,'contamination_reported',v_actor,'Potential contamination and control action recorded.',jsonb_build_object('contamination_ref',v_recovery_ref,'zone',v_zone,'material',v_material,'control_action',v_action),p_command_id);
  insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data)
  values('scene.contamination_reported',v_now,v_actor,'incident_scene',v_scene,jsonb_build_object('command_id',p_command_id,'contamination_ref',v_recovery_ref));
  return jsonb_build_object('ok',true,'contamination_ref',v_recovery_ref,'scene_ref',v_scene_ref,'game_time',v_now,'message','Potential contamination recorded; no conclusion that evidence was contaminated is implied.');
 elsif p_command_type='recover_scene_evidence' then
  v_scene_ref:=nullif(btrim(p_payload->>'scene_ref'),'');
  select id,incident_id into v_scene,v_incident from game.incident_scenes where scene_ref=v_scene_ref and status not in ('released','closed') for update;
  if v_scene is null then return jsonb_build_object('ok',false,'code','scene_not_active','message','Evidence recovery requires an active scene.'); end if;
  select id,status,examiner_personnel_id,attendance_id,qualification_id into v_plan,v_plan_status,v_examiner,v_attendance,v_qualification from game.scene_examination_plans where plan_ref=nullif(btrim(p_payload->>'plan_ref'),'') and scene_id=v_scene for update;
  if v_plan is null or v_examiner<>v_actor or v_plan_status not in ('in_progress','completed') then return jsonb_build_object('ok',false,'code','examiner_plan_required','message','The assigned examiner and an active or completed examination plan are required.'); end if;
  if not exists(select 1 from game.scene_specialist_attendances a join game.personnel_qualifications q on q.id=a.qualification_id where a.id=v_attendance and a.personnel_id=v_actor and a.status='attending' and q.id=v_qualification and q.status='valid' and (q.expires_on is null or q.expires_on>=v_now::date)) then return jsonb_build_object('ok',false,'code','examiner_qualification_invalid','message','The examiner must have current qualifying attendance at this scene.'); end if;
  v_type:=nullif(btrim(p_payload->>'evidence_type'),''); v_description:=nullif(btrim(p_payload->>'description'),''); v_location:=nullif(btrim(p_payload->>'location'),''); v_method:=nullif(btrim(p_payload->>'method'),''); v_packaging:=nullif(btrim(p_payload->>'packaging'),''); v_seal:=nullif(btrim(p_payload->>'seal'),''); v_condition:=nullif(btrim(p_payload->>'condition'),'');
  if v_type is null or v_description is null or v_location is null or v_method is null or v_packaging is null or v_seal is null or v_condition is null then return jsonb_build_object('ok',false,'code','evidence_recovery_details_required','message','Evidence type, description, location, method, packaging, seal and condition are required.'); end if;
  v_evidence_ref:='KWE-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  insert into game.evidence_items(evidence_ref,case_id,incident_id,collected_by_personnel_id,evidence_type,description,collected_at,collection_location,current_status,storage_location,metadata)
  select v_evidence_ref,s.case_id,v_incident,v_actor,v_type,v_description,v_now,v_location,'collected',v_packaging,jsonb_build_object('recovery_method',v_method,'packaging',v_packaging,'seal_identifier',v_seal,'condition_on_recovery',v_condition,'scene_ref',v_scene_ref,'plan_ref',p_payload->>'plan_ref')
  from game.incident_scenes s where s.id=v_scene returning id into v_evidence;
  v_recovery_ref:='KWREC-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  insert into game.scene_evidence_recoveries(recovery_ref,scene_id,incident_id,evidence_id,plan_id,recovered_by_personnel_id,recovered_at,recovery_location,recovery_method,packaging,seal_identifier,condition_on_recovery,source_command_id)
  values(v_recovery_ref,v_scene,v_incident,v_evidence,v_plan,v_actor,v_now,v_location,v_method,v_packaging,v_seal,v_condition,p_command_id);
  insert into game.scene_activity_logs(scene_id,event_at,event_type,personnel_id,description,details,source_command_id)
  values(v_scene,v_now,'evidence_recovered',v_actor,'Evidence recovered, packaged and sealed.',jsonb_build_object('evidence_ref',v_evidence_ref,'recovery_ref',v_recovery_ref,'plan_ref',p_payload->>'plan_ref'),p_command_id);
  insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data)
  values('scene.evidence_recovered',v_now,v_actor,'evidence_item',v_evidence,jsonb_build_object('command_id',p_command_id,'evidence_ref',v_evidence_ref,'recovery_ref',v_recovery_ref));
  return jsonb_build_object('ok',true,'evidence_ref',v_evidence_ref,'recovery_ref',v_recovery_ref,'game_time',v_now,'message','Evidence item and recovery record created with packaging, seal and condition.');
 elsif p_command_type='transfer_scene_evidence' then
  v_evidence_ref:=nullif(btrim(p_payload->>'evidence_ref'),''); v_to_ref:=nullif(btrim(p_payload->>'to_personnel_ref'),'');
  select id,collected_by_personnel_id into v_evidence,v_custodian from game.evidence_items where evidence_ref=v_evidence_ref for update;
  if v_evidence is null then return jsonb_build_object('ok',false,'code','evidence_not_found','message','Evidence reference not found.'); end if;
  select to_personnel_id into v_custodian from game.evidence_transfers where evidence_id=v_evidence order by transferred_at desc,id desc limit 1;
  if v_custodian is null then select collected_by_personnel_id into v_custodian from game.evidence_items where id=v_evidence; end if;
  if v_custodian is distinct from v_actor then return jsonb_build_object('ok',false,'code','evidence_custodian_mismatch','message','The acting officer is not the recorded current custodian.'); end if;
  select id into v_to from game.police_personnel where personnel_ref=v_to_ref and employment_status='active';
  if v_to is null or v_to=v_actor then return jsonb_build_object('ok',false,'code','recipient_unavailable','message','A different active receiving officer is required.'); end if;
  v_from_location:=nullif(btrim(p_payload->>'from_location'),''); v_to_location:=nullif(btrim(p_payload->>'to_location'),''); v_reason:=nullif(btrim(p_payload->>'reason'),''); v_notes:=nullif(btrim(p_payload->>'notes'),'');
  if v_from_location is null or v_to_location is null or v_reason is null then return jsonb_build_object('ok',false,'code','transfer_details_required','message','Both locations and a transfer reason are required.'); end if;
  select scene_id into v_scene from game.scene_evidence_recoveries where evidence_id=v_evidence;
  if v_scene is null then return jsonb_build_object('ok',false,'code','scene_recovery_not_found','message','The evidence item has no linked scene recovery record.'); end if;
  v_transfer_ref:='KWTR-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  insert into game.evidence_transfers(evidence_id,transferred_at,from_personnel_id,to_personnel_id,from_location,to_location,transfer_reason,notes)
  values(v_evidence,v_now,v_actor,v_to,v_from_location,v_to_location,v_reason,v_notes) returning id into v_transfer;
  update game.evidence_items set current_status='transferred',storage_location=v_to_location where id=v_evidence;
  insert into game.scene_evidence_transfer_events(transfer_ref,scene_id,evidence_id,transfer_id,event_at,recorded_by_personnel_id,from_personnel_id,to_personnel_id,from_location,to_location,reason,notes,source_command_id)
  values(v_transfer_ref,v_scene,v_evidence,v_transfer,v_now,v_actor,v_actor,v_to,v_from_location,v_to_location,v_reason,v_notes,p_command_id);
  insert into game.scene_activity_logs(scene_id,event_at,event_type,personnel_id,description,details,source_command_id)
  values(v_scene,v_now,'evidence_transferred',v_actor,'Evidence custody transferred and receiving officer recorded.',jsonb_build_object('evidence_ref',v_evidence_ref,'transfer_ref',v_transfer_ref,'recipient_ref',v_to_ref),p_command_id);
  insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data)
  values('scene.evidence_transferred',v_now,v_actor,'evidence_item',v_evidence,jsonb_build_object('command_id',p_command_id,'transfer_ref',v_transfer_ref,'to_personnel_ref',v_to_ref));
  return jsonb_build_object('ok',true,'evidence_ref',v_evidence_ref,'transfer_ref',v_transfer_ref,'to_personnel_ref',v_to_ref,'game_time',v_now,'message','Evidence custody transfer recorded with both custodians and locations.');
 end if;
 return jsonb_build_object('ok',false,'code','unsupported_evidence_action','message','Unsupported evidence action.');
end $function$
;
revoke all on function game.execute_evidence_action(uuid,text,jsonb,uuid) from public,anon,authenticated;
grant execute on function game.execute_evidence_action(uuid,text,jsonb,uuid) to service_role;

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
  v_scene_action_types text[] := array['establish_scene','assume_scene_command','scene_update','submit_field_report','request_scene_resource','scene_entry','scene_exit','record_scene_safety','set_scene_boundary','approve_scene_resource','decline_scene_resource','fulfil_scene_resource','cancel_scene_resource','release_scene','reopen_scene','specialist_attend','specialist_depart','plan_scene_examination','start_scene_examination','complete_scene_examination','cancel_scene_examination','record_scene_contamination','recover_scene_evidence','transfer_scene_evidence'];
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
    v_result:=jsonb_build_object('ok',true,'status','completed','command_id',v_command.id,'available_commands',jsonb_build_array('help','status','initialize_clock','advance_time','receive_call','dispatch_unit','acknowledge_dispatch','arrive_scene','establish_scene','assume_scene_command','scene_update','submit_field_report','request_scene_resource','scene_entry','scene_exit','record_scene_safety','set_scene_boundary','approve_scene_resource','decline_scene_resource','fulfil_scene_resource','cancel_scene_resource','release_scene','reopen_scene','specialist_attend','specialist_depart','plan_scene_examination','start_scene_examination','complete_scene_examination','cancel_scene_examination','record_scene_contamination','recover_scene_evidence','transfer_scene_evidence'),'note','Scene contamination, evidence recovery and custody transfer commands are available.');
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
  elsif v_type in ('record_scene_contamination','recover_scene_evidence','transfer_scene_evidence') then
    v_result:=game.execute_evidence_action(v_command.id,v_type,p_payload,p_actor_personnel_id);
    if coalesce((v_result->>'ok')::boolean,false)=false then
      update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Evidence action rejected.'),result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
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
