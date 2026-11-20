-- Correct optional whitespace between the final delimiter and priority in forensic request commands.
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
  return jsonb_build_object('recognized',false,'command_type','unknown','payload','{}'::jsonb,'message','Command not recognised. Use help to see the supported command forms.');
end;
$function$
;
