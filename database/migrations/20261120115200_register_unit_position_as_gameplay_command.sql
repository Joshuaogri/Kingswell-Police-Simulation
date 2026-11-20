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
  v_match:=regexp_match(v_text,'^position[[:space:]]+unit[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+at[[:space:]]+([A-Fa-f0-9-]+)[[:space:]]+because[[:space:]]+(.+)$','i');
  if v_match is not null then
    return jsonb_build_object('recognized',true,'command_type','record_unit_position','payload',jsonb_build_object('unit_ref',v_match[1],'access_point_id',v_match[2],'reason',btrim(v_match[3])));
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
    v_match:=regexp_match(v_text,'^scene[[:space:]]+safety[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+for[[:space:]]+([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[|][[:space:]]*([^|]+)[|][[:space:]]*(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','record_scene_safety','payload',jsonb_build_object('personnel_ref',v_match[1],'scene_ref',v_match[2],'hazard_summary',btrim(v_match[3]),'controls_taken',btrim(v_match[4]),'residual_risk',btrim(v_match[5]))); end if;
  v_match:=regexp_match(v_text,'^set[[:space:]]+boundary[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+for[[:space:]]+([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[|][[:space:]]*(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','set_scene_boundary','payload',jsonb_build_object('personnel_ref',v_match[1],'scene_ref',v_match[2],'boundary_description',btrim(v_match[3]),'reason',btrim(v_match[4]))); end if;
  v_match:=regexp_match(v_text,'^resource[[:space:]]+(approve|decline|fulfil|cancel)[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+([A-Za-z0-9._/-]+):[[:space:]]*(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type',case lower(v_match[1]) when 'approve' then 'approve_scene_resource' when 'decline' then 'decline_scene_resource' when 'cancel' then 'cancel_scene_resource' else 'fulfil_scene_resource' end,'payload',jsonb_build_object('personnel_ref',v_match[2],'request_ref',v_match[3],'notes',btrim(v_match[4]))); end if;
  v_match:=regexp_match(v_text,'^release[[:space:]]+scene[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+because[[:space:]]+(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','release_scene','payload',jsonb_build_object('personnel_ref',v_match[1],'scene_ref',v_match[2],'reason',btrim(v_match[3]))); end if;
  v_match:=regexp_match(v_text,'^reopen[[:space:]]+scene[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+because[[:space:]]+(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','reopen_scene','payload',jsonb_build_object('personnel_ref',v_match[1],'scene_ref',v_match[2],'reason',btrim(v_match[3]))); end if;

  v_match:=regexp_match(v_text,'^specialist[[:space:]]+attend[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+at[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+as[[:space:]]+([^:]+):[[:space:]]*(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','specialist_attend','payload',jsonb_build_object('personnel_ref',v_match[1],'scene_ref',v_match[2],'discipline',btrim(v_match[3]),'purpose',btrim(v_match[4]))); end if;
  v_match:=regexp_match(v_text,'^specialist[[:space:]]+depart[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+from[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+because[[:space:]]+(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','specialist_depart','payload',jsonb_build_object('personnel_ref',v_match[1],'scene_ref',v_match[2],'reason',btrim(v_match[3]))); end if;
  v_match:=regexp_match(v_text,'^plan[[:space:]]+examination[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+for[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+by[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+in[[:space:]]+([^:]+):[[:space:]]*([^|]+)[|][[:space:]]*([^|]+)[|][[:space:]]*(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','plan_scene_examination','payload',jsonb_build_object('personnel_ref',v_match[1],'scene_ref',v_match[2],'examiner_ref',v_match[3],'discipline',btrim(v_match[4]),'question',btrim(v_match[5]),'scope',btrim(v_match[6]),'limitations',btrim(v_match[7]))); end if;
  v_match:=regexp_match(v_text,'^start[[:space:]]+examination[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+because[[:space:]]+(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','start_scene_examination','payload',jsonb_build_object('personnel_ref',v_match[1],'plan_ref',v_match[2],'reason',btrim(v_match[3]))); end if;
  v_match:=regexp_match(v_text,'^complete[[:space:]]+examination[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[|][[:space:]]*([^|]+)[|][[:space:]]*(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','complete_scene_examination','payload',jsonb_build_object('personnel_ref',v_match[1],'plan_ref',v_match[2],'observations',btrim(v_match[3]),'findings',btrim(v_match[4]),'limitations',btrim(v_match[5]))); end if;
  v_match:=regexp_match(v_text,'^cancel[[:space:]]+examination[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+because[[:space:]]+(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','cancel_scene_examination','payload',jsonb_build_object('personnel_ref',v_match[1],'plan_ref',v_match[2],'reason',btrim(v_match[3]))); end if;
    v_match:=regexp_match(v_text,'^record[[:space:]]+contamination[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+at[[:space:]]+([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[|][[:space:]]*([^|]+)[|][[:space:]]*(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','record_scene_contamination','payload',jsonb_build_object('personnel_ref',v_match[1],'scene_ref',v_match[2],'zone',btrim(v_match[3]),'material',btrim(v_match[4]),'control_action',btrim(v_match[5]))); end if;
  v_match:=regexp_match(v_text,'^recover[[:space:]]+evidence[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+from[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+under[[:space:]]+([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[|][[:space:]]*([^|]+)[|][[:space:]]*([^|]+)[|][[:space:]]*([^|]+)[|][[:space:]]*([^|]+)[|][[:space:]]*([^|]+)[|][[:space:]]*(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','recover_scene_evidence','payload',jsonb_build_object('personnel_ref',v_match[1],'scene_ref',v_match[2],'plan_ref',v_match[3],'evidence_type',btrim(v_match[4]),'description',btrim(v_match[5]),'location',btrim(v_match[6]),'method',btrim(v_match[7]),'packaging',btrim(v_match[8]),'seal',btrim(v_match[9]),'condition',btrim(v_match[10]))); end if;
  v_match:=regexp_match(v_text,'^transfer[[:space:]]+evidence[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+to[[:space:]]+([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[|][[:space:]]*([^|]+)[|][[:space:]]*(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','transfer_scene_evidence','payload',jsonb_build_object('personnel_ref',v_match[1],'evidence_ref',v_match[2],'to_personnel_ref',v_match[3],'from_location',btrim(v_match[4]),'to_location',btrim(v_match[5]),'reason',btrim(v_match[6]))); end if;

  v_match:=regexp_match(v_text,'^forensic method ([A-Za-z0-9._/-]+) ([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[|]([^|]+)[|]([^|]+)[|]([^|]+)[|]([^|]+)[|](.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','register_forensic_method','payload',jsonb_build_object('personnel_ref',v_match[1],'method_ref',v_match[2],'discipline',btrim(v_match[3]),'method_name',btrim(v_match[4]),'method_version',btrim(v_match[5]),'validation_status',btrim(v_match[6]),'authorised_scope',btrim(v_match[7]),'known_limitations',btrim(v_match[8]))); end if;
  v_match:=regexp_match(v_text,'^forensic request ([A-Za-z0-9._/-]+) ([A-Za-z0-9._/-]+) ([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[|]([^|]+)[|]([^|]+)[|]([^|]+)[|][[:space:]]*([1-5])$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','submit_forensic_request','payload',jsonb_build_object('personnel_ref',v_match[1],'case_ref',v_match[2],'evidence_ref',v_match[3],'discipline',btrim(v_match[4]),'question',btrim(v_match[5]),'scope',btrim(v_match[6]),'legal_basis',btrim(v_match[7]),'priority',v_match[8]::integer)); end if;
  v_match:=regexp_match(v_text,'^triage forensic ([A-Za-z0-9._/-]+) ([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[|](.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','triage_forensic_request','payload',jsonb_build_object('personnel_ref',v_match[1],'request_ref',v_match[2],'decision',btrim(v_match[3]),'notes',btrim(v_match[4]))); end if;
  v_match:=regexp_match(v_text,'^receive lab submission ([A-Za-z0-9._/-]+) ([A-Za-z0-9._/-]+) ([A-Za-z0-9._/-]+) ([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[|]([^|]+)[|]([^|]+)[|]([^|]+)[|](.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','receive_forensic_submission','payload',jsonb_build_object('personnel_ref',v_match[1],'request_ref',v_match[2],'evidence_ref',v_match[3],'receiver_ref',v_match[4],'from_location',btrim(v_match[5]),'lab_location',btrim(v_match[6]),'condition',btrim(v_match[7]),'seal_condition',btrim(v_match[8]),'discrepancy',btrim(v_match[9]))); end if;
  v_match:=regexp_match(v_text,'^assign forensic ([A-Za-z0-9._/-]+) ([A-Za-z0-9._/-]+) ([A-Za-z0-9._/-]+) ([A-Za-z0-9._/-]+) ([A-Za-z0-9._/-]+):[[:space:]]*(.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','assign_forensic_examiner','payload',jsonb_build_object('personnel_ref',v_match[1],'request_ref',v_match[2],'submission_ref',v_match[3],'examiner_ref',v_match[4],'method_ref',v_match[5],'propositions',btrim(v_match[6]))); end if;
  v_match:=regexp_match(v_text,'^start forensic ([A-Za-z0-9._/-]+) ([A-Za-z0-9._/-]+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','start_forensic_examination','payload',jsonb_build_object('personnel_ref',v_match[1],'examination_ref',v_match[2])); end if;
  v_match:=regexp_match(v_text,'^record forensic findings ([A-Za-z0-9._/-]+) ([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[|]([^|]+)[|]([^|]+)[|]([^|]+)[|](.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','record_forensic_findings','payload',jsonb_build_object('personnel_ref',v_match[1],'examination_ref',v_match[2],'observations',btrim(v_match[3]),'interpretation',btrim(v_match[4]),'propositions',btrim(v_match[5]),'limitations',btrim(v_match[6]),'outcome',btrim(v_match[7]))); end if;
  v_match:=regexp_match(v_text,'^review forensic ([A-Za-z0-9._/-]+) ([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[|]([^|]+)[|](.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','review_forensic_findings','payload',jsonb_build_object('personnel_ref',v_match[1],'finding_ref',v_match[2],'review_type',btrim(v_match[3]),'decision',btrim(v_match[4]),'notes',btrim(v_match[5]))); end if;
  v_match:=regexp_match(v_text,'^issue forensic report ([A-Za-z0-9._/-]+) ([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[|](.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','issue_forensic_report','payload',jsonb_build_object('personnel_ref',v_match[1],'request_ref',v_match[2],'summary',btrim(v_match[3]),'report_body',btrim(v_match[4]))); end if;
  v_match:=regexp_match(v_text,'^validate forensic method ([A-Za-z0-9._/-]+) ([A-Za-z0-9._/-]+):[[:space:]]*([^|]+)[|](.+)$','i');
  if v_match is not null then return jsonb_build_object('recognized',true,'command_type','validate_forensic_method','payload',jsonb_build_object('personnel_ref',v_match[1],'method_ref',v_match[2],'decision',btrim(v_match[3]),'notes',btrim(v_match[4]))); end if;
  return jsonb_build_object('recognized',false,'command_type','unknown','payload','{}'::jsonb,'message','Command not recognised. Use help to see the supported command forms.');
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
    v_result:=jsonb_build_object('ok',true,'status','completed','command_id',v_command.id,'available_commands',jsonb_build_array('help','status','initialize_clock','advance_time','receive_call','dispatch_unit','record_unit_position','acknowledge_dispatch','arrive_scene','establish_scene','assume_scene_command','scene_update','submit_field_report','request_scene_resource','scene_entry','scene_exit','record_scene_safety','set_scene_boundary','approve_scene_resource','decline_scene_resource','fulfil_scene_resource','cancel_scene_resource','release_scene','reopen_scene','specialist_attend','specialist_depart','plan_scene_examination','start_scene_examination','complete_scene_examination','cancel_scene_examination','record_scene_contamination','recover_scene_evidence','transfer_scene_evidence','register_forensic_method','validate_forensic_method','submit_forensic_request','triage_forensic_request','receive_forensic_submission','assign_forensic_examiner','start_forensic_examination','record_forensic_findings','review_forensic_findings','issue_forensic_report'),'note','Forensic laboratory workflow commands are available.');
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

  elsif v_type='record_unit_position' then
    v_unit_ref:=nullif(btrim(p_payload->>'unit_ref'),'');
    if v_unit_ref is null or nullif(btrim(p_payload->>'access_point_id'),'') is null or nullif(btrim(p_payload->>'reason'),'') is null then
      v_result:=jsonb_build_object('ok',false,'code','missing_position_details','message','Unit reference, access-point UUID and reason are required.');
      update game.game_commands set status='rejected',rejection_reason='Missing unit position details.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    if not pg_input_is_valid(p_payload->>'access_point_id','uuid') then
      v_result:=jsonb_build_object('ok',false,'code','invalid_access_point','message','The supplied access-point reference is not a valid UUID.');
      update game.game_commands set status='rejected',rejection_reason='Invalid access-point UUID.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    select * into v_clock from game.simulation_state where id=1 for update;
    if v_clock.current_game_time is null then
      v_result:=jsonb_build_object('ok',false,'code','clock_not_initialized','message','Unit position updates require the fictional game clock to be initialized.');
      update game.game_commands set status='rejected',rejection_reason='Game clock not initialized.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    select id into v_unit_id from game.police_units where unit_ref=v_unit_ref and status='active' for update;
    if v_unit_id is null then
      v_result:=jsonb_build_object('ok',false,'code','unit_unavailable','message','The requested police unit does not exist or is not active.');
      update game.game_commands set status='rejected',rejection_reason='Unit missing or inactive.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    if not exists(select 1 from game.property_access_points ap join game.road_segments rs on rs.id=ap.road_segment_id and rs.is_routable where ap.id=(p_payload->>'access_point_id')::uuid) then
      v_result:=jsonb_build_object('ok',false,'code','access_point_unavailable','message','The access point must exist and connect to a currently routable road.');
      update game.game_commands set status='rejected',rejection_reason='Access point unavailable or road not routable.',result=v_result,completed_at=now() where id=v_command.id;
      return v_result || jsonb_build_object('command_id',v_command.id);
    end if;
    v_result:=game.record_unit_position(v_unit_ref,(p_payload->>'access_point_id')::uuid,btrim(p_payload->>'reason'));
    insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data)
      values('unit.position.updated.'||replace(v_command.id::text,'-',''),v_clock.current_game_time,p_actor_personnel_id,'police_unit',v_unit_id,
        jsonb_build_object('command_id',v_command.id,'unit_ref',v_unit_ref)||v_result);
    v_result:=v_result||jsonb_build_object('ok',true,'status','completed','command_id',v_command.id,
      'message','Unit position recorded. Any active deployment routes were recalculated and logged.');
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
  elsif v_type in ('register_forensic_method','validate_forensic_method','submit_forensic_request','triage_forensic_request','receive_forensic_submission','assign_forensic_examiner','start_forensic_examination','record_forensic_findings','review_forensic_findings','issue_forensic_report') then
    v_result:=game.execute_forensic_action(v_command.id,v_type,p_payload,p_actor_personnel_id);
    if coalesce((v_result->>'ok')::boolean,false)=false then
      update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Forensic action rejected.'),result=v_result,completed_at=now() where id=v_command.id;
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