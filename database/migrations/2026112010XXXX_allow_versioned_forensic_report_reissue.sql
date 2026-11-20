CREATE OR REPLACE FUNCTION game.execute_forensic_action(p_command_id uuid, p_command_type text, p_payload jsonb, p_actor_personnel_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare
 t timestamptz; a uuid; req uuid; rr text; cid uuid; ev uuid; er text; sid uuid; sr text; ex uuid; xr text; fid uuid; fr text; mid uuid; examiner uuid; receiver uuid; custodian uuid; tr uuid; dec text; notes text; d text; q text; sc text; lb text; pr smallint; fl text; ll text; cond text; seal text; discrepancy text; props text; obs text; interp text; lim text; outcome text; rt text; summ text; rb text; ms text; md text; st text; ver integer; ref text; registrar uuid;
begin
 select current_game_time into t from game.simulation_state where id=1 for update;
 if t is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Forensic actions require the fictional game clock.'); end if;
 select id into a from game.police_personnel where personnel_ref=nullif(btrim(p_payload->>'personnel_ref'),'') and employment_status='active';
 if a is null then return jsonb_build_object('ok',false,'code','personnel_unavailable','message','An active personnel reference is required.'); end if;
 if p_command_type='register_forensic_method' then
  ref:=nullif(btrim(p_payload->>'method_ref'),''); d:=nullif(btrim(p_payload->>'discipline'),''); q:=nullif(btrim(p_payload->>'method_name'),''); sc:=nullif(btrim(p_payload->>'method_version'),''); ms:=lower(coalesce(nullif(btrim(p_payload->>'validation_status'),''),'verification_pending'));
  if ms<>'verification_pending' then return jsonb_build_object('ok',false,'code','method_must_be_pending','message','New methods must enter verification_pending. A different qualified reviewer must validate them.'); end if; lb:=nullif(btrim(p_payload->>'authorised_scope'),''); lim:=nullif(btrim(p_payload->>'known_limitations'),'');
  if ref is null or d is null or q is null or sc is null or lb is null or lim is null or ms not in ('validated','verification_pending','suspended','retired') then return jsonb_build_object('ok',false,'code','invalid_method_record','message','Method reference, discipline, name, version, validation status, scope and limitations are required.'); end if;
  insert into game.forensic_methods(method_ref,discipline,method_name,method_version,validation_status,authorised_scope,known_limitations,registered_by_personnel_id,registered_at,source_command_id) values(ref,d,q,sc,ms,lb,lim,a,t,p_command_id) returning id into mid;
  return jsonb_build_object('ok',true,'method_ref',ref,'validation_status',ms,'message','Method registered; supplied validation status is not independently certified.');
 elsif p_command_type='validate_forensic_method' then
  ref:=nullif(btrim(p_payload->>'method_ref'),''); dec:=lower(nullif(btrim(p_payload->>'decision'),'')); notes:=nullif(btrim(p_payload->>'notes'),'');
  select id,discipline,registered_by_personnel_id into mid,d,registrar from game.forensic_methods where method_ref=ref and active for update;
  if mid is null or registrar=a or dec not in ('validated','changes_required','suspended') or notes is null then return jsonb_build_object('ok',false,'code','method_review_invalid','message','A different active reviewer, method, supported decision and rationale are required.'); end if;
  if not exists(select 1 from game.personnel_qualifications where personnel_id=a and status='valid' and (expires_on is null or expires_on>=t::date) and (lower(qualification_code)=lower(d) or lower(qualification_name)=lower(d))) then return jsonb_build_object('ok',false,'code','method_reviewer_not_qualified','message','Reviewer needs a current qualification matching the method discipline.'); end if;
  fr:='KWMREV-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  insert into game.forensic_method_reviews(review_ref,method_id,reviewer_personnel_id,decision,review_notes,reviewed_at,source_command_id) values(fr,mid,a,dec,notes,t,p_command_id);
  update game.forensic_methods set validation_status=case dec when 'validated' then 'validated' when 'suspended' then 'suspended' else 'verification_pending' end where id=mid;
  insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data) values('forensics.method_reviewed',t,a,'forensic_method',mid,jsonb_build_object('command_id',p_command_id,'review_ref',fr,'decision',dec));
  return jsonb_build_object('ok',true,'method_ref',ref,'review_ref',fr,'validation_status',case dec when 'validated' then 'validated' when 'suspended' then 'suspended' else 'verification_pending' end);
 elsif p_command_type='submit_forensic_request' then
  rr:=nullif(btrim(p_payload->>'case_ref'),''); er:=nullif(btrim(p_payload->>'evidence_ref'),''); d:=nullif(btrim(p_payload->>'discipline'),''); q:=nullif(btrim(p_payload->>'question'),''); sc:=nullif(btrim(p_payload->>'scope'),''); lb:=nullif(btrim(p_payload->>'legal_basis'),'');
  if rr is null or er is null or d is null or q is null or sc is null or lb is null or not pg_input_is_valid(p_payload->>'priority','smallint') then return jsonb_build_object('ok',false,'code','invalid_forensic_request','message','Case, evidence, discipline, question, scope, legal basis and priority are required.'); end if;
  pr:=(p_payload->>'priority')::smallint; if pr not between 1 and 5 then return jsonb_build_object('ok',false,'code','invalid_priority','message','Priority must be 1 to 5.'); end if;
  select id into cid from game.cases where case_ref=rr and status not in ('closed','cancelled') for update;
  select id into ev from game.evidence_items where evidence_ref=er and case_id=cid for update;
  if cid is null or ev is null then return jsonb_build_object('ok',false,'code','case_evidence_mismatch','message','Open case and evidence linked to that case are required.'); end if;
  rr:='KWFR-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  insert into game.forensic_requests(request_ref,case_id,requested_by_personnel_id,discipline,examination_question,scope,legal_basis,priority,status,submitted_at,source_command_id) values(rr,cid,a,d,q,sc,lb,pr,'submitted',t,p_command_id) returning id into req;
  insert into game.forensic_request_items(request_id,evidence_id,requested_context) values(req,ev,coalesce(nullif(btrim(p_payload->>'context'),''),''));
  return jsonb_build_object('ok',true,'request_ref',rr,'status','submitted');
 elsif p_command_type='triage_forensic_request' then
  rr:=nullif(btrim(p_payload->>'request_ref'),''); dec:=lower(nullif(btrim(p_payload->>'decision'),'')); notes:=nullif(btrim(p_payload->>'notes'),'');
  select id,status into req,st from game.forensic_requests where request_ref=rr for update;
  if req is null or st<>'submitted' or dec not in ('accept','defer','decline') or notes is null then return jsonb_build_object('ok',false,'code','triage_invalid','message','Submitted request, decision and rationale required.'); end if;
  update game.forensic_requests set status=case dec when 'accept' then 'accepted' when 'defer' then 'deferred' else 'declined' end,triage_decision=dec,triage_notes=notes,triaged_by_personnel_id=a,triaged_at=t where id=req;
  return jsonb_build_object('ok',true,'request_ref',rr,'status',case dec when 'accept' then 'accepted' when 'defer' then 'deferred' else 'declined' end);
 elsif p_command_type='receive_forensic_submission' then
  rr:=nullif(btrim(p_payload->>'request_ref'),''); er:=nullif(btrim(p_payload->>'evidence_ref'),''); fl:=nullif(btrim(p_payload->>'from_location'),''); ll:=nullif(btrim(p_payload->>'lab_location'),''); cond:=nullif(btrim(p_payload->>'condition'),''); seal:=nullif(btrim(p_payload->>'seal_condition'),''); discrepancy:=nullif(btrim(p_payload->>'discrepancy'),'');
  if lower(coalesce(discrepancy,'')) in ('none','no discrepancy','no discrepancy reported') then discrepancy:=null; end if;
  select id into receiver from game.police_personnel where personnel_ref=nullif(btrim(p_payload->>'receiver_ref'),'') and employment_status='active';
  select r.id,r.status,e.id into req,st,ev from game.forensic_requests r join game.forensic_request_items i on i.request_id=r.id join game.evidence_items e on e.id=i.evidence_id where r.request_ref=rr and e.evidence_ref=er for update of r,e;
  if req is null or st<>'accepted' or receiver is null or receiver=a or fl is null or ll is null or cond is null or seal is null then return jsonb_build_object('ok',false,'code','submission_invalid','message','Accepted request, linked evidence, receiving officer, locations, condition and seal condition required.'); end if;
  select to_personnel_id into custodian from game.evidence_transfers where evidence_id=ev order by transferred_at desc,id desc limit 1;
  if custodian is null then select collected_by_personnel_id into custodian from game.evidence_items where id=ev; end if;
  if custodian is distinct from a then return jsonb_build_object('ok',false,'code','not_current_custodian','message','Submitting officer is not the recorded custodian.'); end if;
  if exists(select 1 from game.forensic_lab_submissions where request_id=req and evidence_id=ev) then return jsonb_build_object('ok',false,'code','submission_exists','message','Submission already exists.'); end if;
  insert into game.evidence_transfers(evidence_id,transferred_at,from_personnel_id,to_personnel_id,from_location,to_location,transfer_reason,notes) values(ev,t,a,receiver,fl,ll,'Forensic laboratory submission '||rr,coalesce(discrepancy,'No discrepancy recorded.')) returning id into tr;
  update game.evidence_items set current_status='under_examination',storage_location=ll where id=ev;
  sr:='KWLAB-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  insert into game.forensic_lab_submissions(submission_ref,request_id,evidence_id,submitted_by_personnel_id,received_by_personnel_id,custody_transfer_id,received_at,received_condition,seal_condition,discrepancy,laboratory_location,status,source_command_id) values(sr,req,ev,a,receiver,tr,t,cond,seal,discrepancy,ll,case when discrepancy is not null or lower(seal)<>'intact' then 'quarantined' else 'received' end,p_command_id) returning id into sid;
  return jsonb_build_object('ok',true,'submission_ref',sr,'status',case when discrepancy is not null or lower(seal)<>'intact' then 'quarantined' else 'received' end);
 elsif p_command_type='assign_forensic_examiner' then
  rr:=nullif(btrim(p_payload->>'request_ref'),''); sr:=nullif(btrim(p_payload->>'submission_ref'),''); ref:=nullif(btrim(p_payload->>'method_ref'),''); props:=nullif(btrim(p_payload->>'propositions'),'');
  select id into examiner from game.police_personnel where personnel_ref=nullif(btrim(p_payload->>'examiner_ref'),'') and employment_status='active';
  select id,discipline,examination_question,scope into req,d,q,sc from game.forensic_requests where request_ref=rr and status in ('accepted','in_progress','reported') for update;
  select id,status into sid,st from game.forensic_lab_submissions where submission_ref=sr and request_id=req for update;
  select id,discipline,validation_status into mid,md,ms from game.forensic_methods where method_ref=ref and active for update;
  if req is null or sid is null or st<>'received' or examiner is null or props is null or mid is null or ms<>'validated' or md<>d then return jsonb_build_object('ok',false,'code','assignment_invalid','message','Accepted request, received submission, active examiner and matching active validated method required.'); end if;
  if not exists(select 1 from game.personnel_qualifications where personnel_id=examiner and status='valid' and (expires_on is null or expires_on>=t::date) and (lower(qualification_code)=lower(d) or lower(qualification_name)=lower(d))) then return jsonb_build_object('ok',false,'code','examiner_not_qualified','message','Examiner lacks a current matching discipline qualification.'); end if;
  xr:='KWEX-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  insert into game.forensic_examinations(examination_ref,request_id,submission_id,method_id,examiner_personnel_id,assigned_by_personnel_id,method_version_snapshot,examination_question,scope,propositions,status,assigned_at,source_command_id) select xr,req,sid,mid,examiner,a,m.method_version,q,sc,props,'assigned',t,p_command_id from game.forensic_methods m where m.id=mid returning id into ex;
  update game.forensic_requests set status='in_progress' where id=req;
  return jsonb_build_object('ok',true,'examination_ref',xr,'status','assigned');
 elsif p_command_type='start_forensic_examination' then
  select id,status,examiner_personnel_id into ex,st,examiner from game.forensic_examinations where examination_ref=nullif(btrim(p_payload->>'examination_ref'),'') for update;
  if ex is null or examiner<>a or st<>'assigned' then return jsonb_build_object('ok',false,'code','not_startable','message','Only assigned examiner can start this examination.'); end if;
  update game.forensic_examinations set status='in_progress',started_at=t where id=ex;
  return jsonb_build_object('ok',true,'status','in_progress');
 elsif p_command_type='record_forensic_findings' then
  select id,status,examiner_personnel_id into ex,st,examiner from game.forensic_examinations where examination_ref=nullif(btrim(p_payload->>'examination_ref'),'') for update;
  obs:=nullif(btrim(p_payload->>'observations'),''); interp:=nullif(btrim(p_payload->>'interpretation'),''); props:=nullif(btrim(p_payload->>'propositions'),''); lim:=nullif(btrim(p_payload->>'limitations'),''); outcome:=lower(nullif(btrim(p_payload->>'outcome'),''));
  if ex is null or examiner<>a or st<>'in_progress' or obs is null or interp is null or props is null or lim is null or outcome not in ('supports','contradicts','inconclusive','no_result','neutral') then return jsonb_build_object('ok',false,'code','findings_invalid','message','Assigned examiner, in-progress examination, observations, interpretation, propositions, limitations and valid outcome required.'); end if;
  select coalesce(max(version_number),0)+1 into ver from game.forensic_findings where examination_id=ex;
  fr:='KWFIND-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  insert into game.forensic_findings(finding_ref,examination_id,version_number,recorded_by_personnel_id,observations,interpretation,propositions,limitations,outcome,recorded_at,source_command_id) values(fr,ex,ver,a,obs,interp,props,lim,outcome,t,p_command_id) returning id into fid;
  update game.forensic_examinations set status='completed',completed_at=t where id=ex;
  return jsonb_build_object('ok',true,'finding_ref',fr,'outcome',outcome,'message','Scientific finding recorded; no legal conclusion is implied.');
 elsif p_command_type='review_forensic_findings' then
  fr:=nullif(btrim(p_payload->>'finding_ref'),''); rt:=lower(nullif(btrim(p_payload->>'review_type'),'')); dec:=lower(nullif(btrim(p_payload->>'decision'),'')); notes:=nullif(btrim(p_payload->>'notes'),'');
  select f.id,e.examiner_personnel_id,m.discipline into fid,examiner,d from game.forensic_findings f join game.forensic_examinations e on e.id=f.examination_id join game.forensic_methods m on m.id=e.method_id where f.finding_ref=fr for update of f;
  if fid is null or examiner=a or rt not in ('technical','peer','independent') or dec not in ('approved','changes_required','disputed') or notes is null then return jsonb_build_object('ok',false,'code','review_invalid','message','Different reviewer, review type, decision and notes required.'); end if;
  if not exists(select 1 from game.personnel_qualifications where personnel_id=a and status='valid' and (expires_on is null or expires_on>=t::date) and (lower(qualification_code)=lower(d) or lower(qualification_name)=lower(d))) then return jsonb_build_object('ok',false,'code','reviewer_not_qualified','message','Reviewer needs a current qualification matching the finding discipline.'); end if;
  ref:='KWREV-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  insert into game.forensic_reviews(review_ref,finding_id,reviewer_personnel_id,review_type,decision,review_notes,reviewed_at,source_command_id) values(ref,fid,a,rt,dec,notes,t,p_command_id);
  return jsonb_build_object('ok',true,'review_ref',ref,'decision',dec);
 elsif p_command_type='issue_forensic_report' then
  rr:=nullif(btrim(p_payload->>'request_ref'),''); summ:=nullif(btrim(p_payload->>'summary'),''); rb:=nullif(btrim(p_payload->>'report_body'),'');
  select id into req from game.forensic_requests where request_ref=rr and status in ('accepted','in_progress') for update;
  if req is null or summ is null or rb is null or not exists(select 1 from game.forensic_findings f join game.forensic_examinations e on e.id=f.examination_id where e.request_id=req) then return jsonb_build_object('ok',false,'code','report_not_ready','message','Active request, report content and findings are required.'); end if;
  if exists(select 1 from game.forensic_examinations where request_id=req and status<>'completed') then return jsonb_build_object('ok',false,'code','examinations_incomplete','message','All examinations must be complete.'); end if;
  if exists(select 1 from (select distinct on(f.examination_id) f.id from game.forensic_findings f join game.forensic_examinations e on e.id=f.examination_id where e.request_id=req order by f.examination_id,f.version_number desc) z where coalesce((select decision from game.forensic_reviews where finding_id=z.id order by reviewed_at desc,id desc limit 1),'')<>'approved') then return jsonb_build_object('ok',false,'code','technical_review_required','message','Latest findings must have approved technical review.'); end if;
  select coalesce(max(version_number),0)+1 into ver from game.forensic_reports where request_id=req;
  ref:='KWREP-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
  insert into game.forensic_reports(report_ref,request_id,version_number,authored_by_personnel_id,report_summary,report_body,status,issued_at,source_command_id) values(ref,req,ver,a,summ,rb,'issued',t,p_command_id);
  update game.forensic_reports set status='superseded' where request_id=req and report_ref<>ref and status='issued';
  update game.forensic_requests set status='reported' where id=req;
  return jsonb_build_object('ok',true,'report_ref',ref,'version',ver,'status','issued');
 end if;
 return jsonb_build_object('ok',false,'code','unsupported_forensic_action','message','Unsupported forensic action.');
end;
$function$
;
revoke all on function game.execute_forensic_action(uuid,text,jsonb,uuid) from public,anon,authenticated;
grant execute on function game.execute_forensic_action(uuid,text,jsonb,uuid) to service_role;
