
create table game.scene_contamination_events(
 id uuid primary key default gen_random_uuid(), contamination_ref text not null unique,
 scene_id uuid not null references game.incident_scenes(id), incident_id uuid not null references game.incidents(id),
 zone_ref text not null, material_or_source text not null, suspected_source text,
 control_action text not null, notes text, recorded_by_personnel_id uuid not null references game.police_personnel(id),
 recorded_at timestamptz not null, source_command_id uuid references game.game_commands(id), created_at timestamptz not null default now()
);
create table game.scene_evidence_recoveries(
 id uuid primary key default gen_random_uuid(), recovery_ref text not null unique,
 scene_id uuid not null references game.incident_scenes(id), incident_id uuid not null references game.incidents(id),
 evidence_id uuid not null unique references game.evidence_items(id), plan_id uuid not null references game.scene_examination_plans(id),
 recovered_by_personnel_id uuid not null references game.police_personnel(id), recovered_at timestamptz not null,
 recovery_location text not null, recovery_method text not null, packaging text not null,
 seal_identifier text not null unique, condition_on_recovery text not null,
 source_command_id uuid references game.game_commands(id), created_at timestamptz not null default now()
);
create table game.scene_evidence_transfer_events(
 id uuid primary key default gen_random_uuid(), transfer_ref text not null unique,
 scene_id uuid not null references game.incident_scenes(id), evidence_id uuid not null references game.evidence_items(id),
 transfer_id uuid not null unique references game.evidence_transfers(id), event_at timestamptz not null,
 recorded_by_personnel_id uuid not null references game.police_personnel(id),
 from_personnel_id uuid references game.police_personnel(id), to_personnel_id uuid references game.police_personnel(id),
 from_location text not null, to_location text not null, reason text not null, notes text,
 source_command_id uuid references game.game_commands(id), created_at timestamptz not null default now()
);
alter table game.scene_contamination_events enable row level security;
alter table game.scene_evidence_recoveries enable row level security;
alter table game.scene_evidence_transfer_events enable row level security;
create index scene_contamination_events_scene_time_idx on game.scene_contamination_events(scene_id,recorded_at);
create index scene_contamination_events_incident_idx on game.scene_contamination_events(incident_id);
create index scene_evidence_recoveries_scene_time_idx on game.scene_evidence_recoveries(scene_id,recovered_at);
create index scene_evidence_recoveries_plan_idx on game.scene_evidence_recoveries(plan_id);
create index scene_evidence_transfer_events_evidence_time_idx on game.scene_evidence_transfer_events(evidence_id,event_at);
create index scene_evidence_transfer_events_scene_idx on game.scene_evidence_transfer_events(scene_id,event_at);

create or replace function game.execute_evidence_action(p_command_id uuid,p_command_type text,p_payload jsonb,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
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
end $$;

do $$
declare d text;
begin
 select pg_get_functiondef('game.interpret_text_command(text)'::regprocedure) into d;
 d:=replace(d,
 $old$return jsonb_build_object('recognized',false,'command_type','unknown','payload','{}'::jsonb,
    'message','Command not recognised. Use help to see the supported command forms.');$old$,
 $new$v_match:=regexp_match(v_text,'^record[[:space:]]+contamination[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+at[[:space:]]+([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[|][[:space:]]*([^|]+)[|][[:space:]]*(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','record_scene_contamination','payload',jsonb_build_object('personnel_ref',v_match[1],'scene_ref',v_match[2],'zone',btrim(v_match[3]),'material',btrim(v_match[4]),'control_action',btrim(v_match[5]))); end if;
  v_match:=regexp_match(v_text,'^recover[[:space:]]+evidence[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+from[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+under[[:space:]]+([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[|][[:space:]]*([^|]+)[|][[:space:]]*([^|]+)[|][[:space:]]*([^|]+)[|][[:space:]]*([^|]+)[|][[:space:]]*([^|]+)[|][[:space:]]*(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','recover_scene_evidence','payload',jsonb_build_object('personnel_ref',v_match[1],'scene_ref',v_match[2],'plan_ref',v_match[3],'evidence_type',btrim(v_match[4]),'description',btrim(v_match[5]),'location',btrim(v_match[6]),'method',btrim(v_match[7]),'packaging',btrim(v_match[8]),'seal',btrim(v_match[9]),'condition',btrim(v_match[10]))); end if;
  v_match:=regexp_match(v_text,'^transfer[[:space:]]+evidence[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+to[[:space:]]+([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[|][[:space:]]*([^|]+)[|][[:space:]]*(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','transfer_scene_evidence','payload',jsonb_build_object('personnel_ref',v_match[1],'evidence_ref',v_match[2],'to_personnel_ref',v_match[3],'from_location',btrim(v_match[4]),'to_location',btrim(v_match[5]),'reason',btrim(v_match[6]))); end if;
  return jsonb_build_object('recognized',false,'command_type','unknown','payload','{}'::jsonb,'message','Command not recognised. Use help to see the supported command forms.');$new$);
 execute d;

 select pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure) into d;
 d:=replace(d,
 $old$  elsif v_type = any(v_scene_action_types) then
    v_result:=game.execute_scene_action(v_command.id,v_type,p_payload,p_actor_personnel_id);$old$,
 $new$  elsif v_type in ('record_scene_contamination','recover_scene_evidence','transfer_scene_evidence') then
    v_result:=game.execute_evidence_action(v_command.id,v_type,p_payload,p_actor_personnel_id);
    if coalesce((v_result->>'ok')::boolean,false)=false then
      update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Evidence action rejected.'),result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
  elsif v_type = any(v_scene_action_types) then
    v_result:=game.execute_scene_action(v_command.id,v_type,p_payload,p_actor_personnel_id);$new$);
 d:=replace(d,
 $old$'cancel_scene_examination'];$old$,
 $new$'cancel_scene_examination','record_scene_contamination','recover_scene_evidence','transfer_scene_evidence'];$new$);
 execute d;
end $$;
