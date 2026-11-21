create or replace function game.get_case_review_dossier(p_case_ref text)
returns jsonb
language plpgsql stable
set search_path to 'pg_catalog','game'
as $function$
declare v_case game.cases%rowtype; v_result jsonb; v_lead_ref text;
begin
 select * into v_case from game.cases where case_ref=btrim(p_case_ref);
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference not found.'); end if;
 select pp.personnel_ref into v_lead_ref from game.police_personnel pp where pp.id=v_case.lead_personnel_id;

 select jsonb_build_object(
  'ok',true,'dossier_version','1.0','generated_at',now(),
  'case',jsonb_build_object('case_ref',v_case.case_ref,'title',v_case.case_title,'type',v_case.case_type,'status',v_case.status,'summary',v_case.summary,'opened_at',v_case.opened_at,'closed_at',v_case.closed_at,'lead_personnel_ref',v_lead_ref,'case_data',v_case.case_data),
  'assignments',(select coalesce(jsonb_agg(jsonb_build_object('personnel_ref',pp.personnel_ref,'name',concat_ws(' ',p.given_name,p.middle_names,p.family_name),'role',a.assignment_role,'status',a.status,'assigned_at',a.assigned_at,'released_at',a.released_at,'history',(select coalesce(jsonb_agg(jsonb_build_object('event_type',e.event_type,'at',e.event_at_game_time,'actor',ap.personnel_ref,'data',e.event_data) order by e.event_at_game_time,e.created_at),'[]'::jsonb) from game.case_assignment_events e join game.police_personnel ap on ap.id=e.actor_personnel_id where e.assignment_id=a.id)) order by a.assigned_at,a.id),'[]'::jsonb) from game.case_assignments a join game.police_personnel pp on pp.id=a.personnel_id join game.persons p on p.id=pp.person_id where a.case_id=v_case.id),
  'incidents',(select coalesce(jsonb_agg(jsonb_build_object('incident_ref',i.incident_ref,'relationship',ci.relationship_type,'type_id',i.incident_type_id,'reported_at',i.reported_at,'occurred_from',i.occurred_from,'occurred_to',i.occurred_to,'location',i.location_description,'priority',i.priority,'status',i.status,'summary',i.summary) order by i.reported_at),'[]'::jsonb) from game.case_incidents ci join game.incidents i on i.id=ci.incident_id where ci.case_id=v_case.id),
  'people',(select coalesce(jsonb_agg(jsonb_build_object('person_ref',p.person_ref,'name',concat_ws(' ',p.given_name,p.middle_names,p.family_name),'role',cp.case_role,'notes',cp.notes) order by cp.case_role,p.family_name,p.given_name),'[]'::jsonb) from game.case_persons cp join game.persons p on p.id=cp.person_id where cp.case_id=v_case.id),
  'leads',(select coalesce(jsonb_agg(jsonb_build_object('lead_ref',l.lead_ref,'title',l.title,'description',l.description,'source_type',l.source_type,'source_reference',l.source_reference,'assigned_to',ap.personnel_ref,'status',l.status,'priority',l.priority,'confidence',l.confidence,'assessment_reason',l.assessment_reason,'created_at',l.created_at_game_time,'updated_at',l.updated_at_game_time,
    'events',(select coalesce(jsonb_agg(jsonb_build_object('event_type',e.event_type,'at',e.event_at_game_time,'actor',ep.personnel_ref,'data',e.event_data) order by e.event_at_game_time,e.created_at),'[]'::jsonb) from game.case_lead_events e join game.police_personnel ep on ep.id=e.actor_personnel_id where e.lead_id=l.id),
    'enquiries',(select coalesce(jsonb_agg(jsonb_build_object('enquiry_ref',q.enquiry_ref,'method',q.method,'action',q.action,'result',q.result,'outcome',q.outcome,'source_reference',q.source_reference,'conducted_by',cp.personnel_ref,'conducted_at',q.conducted_at_game_time,'recorded_by',rp.personnel_ref,'events',(select coalesce(jsonb_agg(jsonb_build_object('event_type',qe.event_type,'at',qe.event_at_game_time,'actor',qep.personnel_ref,'data',qe.event_data) order by qe.event_at_game_time,qe.created_at),'[]'::jsonb) from game.case_enquiry_events qe join game.police_personnel qep on qep.id=qe.actor_personnel_id where qe.enquiry_id=q.id)) order by q.conducted_at_game_time),'[]'::jsonb) from game.case_enquiries q join game.police_personnel cp on cp.id=q.conducted_by_personnel_id join game.police_personnel rp on rp.id=q.recorded_by_personnel_id where q.lead_id=l.id),
    'entity_links',(select coalesce(jsonb_agg(jsonb_build_object('link_ref',x.link_ref,'entity_type',x.entity_type,'entity_ref',x.entity_ref,'reason',x.reason,'linked_by',lp.personnel_ref,'linked_at',x.linked_at_game_time) order by x.created_at),'[]'::jsonb) from game.case_lead_entity_links x join game.police_personnel lp on lp.id=x.linked_by_personnel_id where x.lead_id=l.id)
   ) order by l.created_at_game_time,l.created_at),'[]'::jsonb) from game.case_leads l left join game.police_personnel ap on ap.id=l.assigned_personnel_id where l.case_id=v_case.id),
  'interviews',(select coalesce(jsonb_agg(jsonb_build_object('interview_ref',iv.interview_ref,'interviewee',jsonb_build_object('person_ref',p.person_ref,'name',concat_ws(' ',p.given_name,p.middle_names,p.family_name)),'interviewer',ip.personnel_ref,'method',iv.method,'purpose',iv.purpose,'location',iv.location_description,'notes',iv.notes,'started_at',iv.started_at_game_time,'suspect_interview',exists(select 1 from game.case_suspect_interview_records sr where sr.interview_id=iv.id),'suspect_classification',(select jsonb_build_object('reason',sr.reason,'recorded_by',sp.personnel_ref,'recorded_at',sr.recorded_at_game_time) from game.case_suspect_interview_records sr join game.police_personnel sp on sp.id=sr.recorded_by_personnel_id where sr.interview_id=iv.id),
    'events',(select coalesce(jsonb_agg(jsonb_build_object('event_type',e.event_type,'at',e.event_at_game_time,'reason',e.reason,'actor',ep.personnel_ref) order by e.event_at_game_time,e.created_at),'[]'::jsonb) from game.case_interview_events e join game.police_personnel ep on ep.id=e.actor_personnel_id where e.interview_id=iv.id),
    'turns',(select coalesce(jsonb_agg(jsonb_build_object('turn_ref',t.turn_ref,'number',t.turn_number,'question',t.question_text,'answer',t.answer_text,'recorded_by',tp.personnel_ref,'recorded_at',t.recorded_at_game_time,'suspect_response_assessments',(select coalesce(jsonb_agg(jsonb_build_object('assessment',a.response_assessment,'reason',a.assessment_reason,'assessed_by',ap2.personnel_ref,'at',a.assessed_at_game_time) order by a.assessed_at_game_time,a.created_at),'[]'::jsonb) from game.case_suspect_interview_assessments a join game.police_personnel ap2 on ap2.id=a.assessed_by_personnel_id where a.turn_id=t.id)) order by t.turn_number),'[]'::jsonb) from game.case_interview_turns t join game.police_personnel tp on tp.id=t.recorded_by_personnel_id where t.interview_id=iv.id),
    'linked_statements',(select coalesce(jsonb_agg(jsonb_build_object('statement_ref',s.statement_ref,'form',s.statement_form,'recorded_at',s.recorded_at_game_time,'statement_text',s.statement_text,'outcomes',(select coalesce(jsonb_agg(jsonb_build_object('event_type',se.event_type,'at',se.event_at_game_time,'reason',se.reason,'actor',sep.personnel_ref) order by se.event_at_game_time,se.created_at),'[]'::jsonb) from game.case_witness_statement_events se join game.police_personnel sep on sep.id=se.actor_personnel_id where se.statement_id=s.id)) order by s.recorded_at_game_time),'[]'::jsonb) from game.case_witness_statements s where s.interview_id=iv.id)
   ) order by iv.started_at_game_time,iv.created_at),'[]'::jsonb) from game.case_interviews iv join game.persons p on p.id=iv.interviewee_person_id join game.police_personnel ip on ip.id=iv.interviewer_personnel_id where iv.case_id=v_case.id),
  'witness_statements',(select coalesce(jsonb_agg(jsonb_build_object('statement_ref',s.statement_ref,'witness',wp.person_ref,'witness_name',concat_ws(' ',wp.given_name,wp.middle_names,wp.family_name),'interview_ref',iv.interview_ref,'form',s.statement_form,'text',s.statement_text,'supplements',prior.statement_ref,'recorded_by',rp.personnel_ref,'recorded_at',s.recorded_at_game_time,'events',(select coalesce(jsonb_agg(jsonb_build_object('event_type',e.event_type,'at',e.event_at_game_time,'reason',e.reason,'actor',ep.personnel_ref) order by e.event_at_game_time,e.created_at),'[]'::jsonb) from game.case_witness_statement_events e join game.police_personnel ep on ep.id=e.actor_personnel_id where e.statement_id=s.id)) order by s.recorded_at_game_time),'[]'::jsonb) from game.case_witness_statements s join game.persons wp on wp.id=s.witness_person_id join game.police_personnel rp on rp.id=s.recorded_by_personnel_id left join game.case_interviews iv on iv.id=s.interview_id left join game.case_witness_statements prior on prior.id=s.supplements_statement_id where s.case_id=v_case.id),
  'account_comparisons',game.get_case_account_comparisons(v_case.case_ref,null)->'comparisons',
  'evidence',(select coalesce(jsonb_agg(jsonb_build_object('evidence_ref',e.evidence_ref,'type',e.evidence_type,'description',e.description,'collected_at',e.collected_at,'collected_by',cp.personnel_ref,'collection_location',e.collection_location,'status',e.current_status,'storage_location',e.storage_location,'metadata',e.metadata,
    'transfers',(select coalesce(jsonb_agg(jsonb_build_object('transferred_at',tr.transferred_at,'from_personnel',fp.personnel_ref,'to_personnel',tp.personnel_ref,'from_location',tr.from_location,'to_location',tr.to_location,'reason',tr.transfer_reason,'notes',tr.notes) order by tr.transferred_at,tr.id),'[]'::jsonb) from game.evidence_transfers tr left join game.police_personnel fp on fp.id=tr.from_personnel_id left join game.police_personnel tp on tp.id=tr.to_personnel_id where tr.evidence_id=e.id),
    'forensic_requests',(select coalesce(jsonb_agg(jsonb_build_object('request_ref',fr.request_ref,'discipline',fr.discipline,'question',fr.examination_question,'scope',fr.scope,'priority',fr.priority,'status',fr.status,'triage_decision',fr.triage_decision,'triage_notes',fr.triage_notes,'submitted_at',fr.submitted_at,'examinations',(select coalesce(jsonb_agg(jsonb_build_object('examination_ref',fx.examination_ref,'method_version',fx.method_version_snapshot,'question',fx.examination_question,'scope',fx.scope,'status',fx.status,'assigned_at',fx.assigned_at,'started_at',fx.started_at,'completed_at',fx.completed_at,'findings',(select coalesce(jsonb_agg(jsonb_build_object('finding_ref',ff.finding_ref,'version',ff.version_number,'observations',ff.observations,'interpretation',ff.interpretation,'propositions',ff.propositions,'limitations',ff.limitations,'outcome',ff.outcome,'recorded_at',ff.recorded_at,'reviews',(select coalesce(jsonb_agg(jsonb_build_object('review_ref',rv.review_ref,'type',rv.review_type,'decision',rv.decision,'notes',rv.review_notes,'reviewed_at',rv.reviewed_at) order by rv.reviewed_at),'[]'::jsonb) from game.forensic_reviews rv where rv.finding_id=ff.id)) order by ff.version_number),'[]'::jsonb) from game.forensic_findings ff where ff.examination_id=fx.id)) order by fx.assigned_at),'[]'::jsonb) from game.forensic_examinations fx where fx.request_id=fr.id),
    'reports',(select coalesce(jsonb_agg(jsonb_build_object('report_ref',rp.report_ref,'version',rp.version_number,'summary',rp.report_summary,'body',rp.report_body,'status',rp.status,'issued_at',rp.issued_at) order by rp.version_number),'[]'::jsonb) from game.forensic_reports rp where rp.request_id=fr.id)
   ) order by fr.created_at),'[]'::jsonb) from game.forensic_requests fr where fr.case_id=v_case.id and exists(select 1 from game.forensic_request_items ri where ri.request_id=fr.id and ri.evidence_id=e.id))
   ) order by e.collected_at,e.evidence_ref),'[]'::jsonb) from game.evidence_items e left join game.police_personnel cp on cp.id=e.collected_by_personnel_id where e.case_id=v_case.id),
  'forensic_requests',(select coalesce(jsonb_agg(jsonb_build_object('request_ref',fr.request_ref,'discipline',fr.discipline,'question',fr.examination_question,'scope',fr.scope,'priority',fr.priority,'status',fr.status,'triage_decision',fr.triage_decision,'triage_notes',fr.triage_notes,'submitted_at',fr.submitted_at,'items',(select coalesce(jsonb_agg(jsonb_build_object('evidence_ref',e.evidence_ref,'context',ri.requested_context) order by e.evidence_ref),'[]'::jsonb) from game.forensic_request_items ri join game.evidence_items e on e.id=ri.evidence_id where ri.request_id=fr.id),'reports',(select coalesce(jsonb_agg(jsonb_build_object('report_ref',rp.report_ref,'version',rp.version_number,'summary',rp.report_summary,'body',rp.report_body,'status',rp.status,'issued_at',rp.issued_at) order by rp.version_number),'[]'::jsonb) from game.forensic_reports rp where rp.request_id=fr.id)) order by fr.created_at),'[]'::jsonb) from game.forensic_requests fr where fr.case_id=v_case.id)
 ) into v_result;
 return v_result;
end
$function$;

alter function game.interpret_text_command(text) rename to interpret_text_command_before_case_review;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game' as $function$
declare t text:=btrim(coalesce(p_command_text,''));m text[];
begin
 m:=regexp_match(t,'^case review ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','get_case_review_dossier','payload',jsonb_build_object('case_ref',m[1],'actor_ref',m[2])); end if;
 return game.interpret_text_command_before_case_review(p_command_text);
end
$function$;

alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_case_review;
create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $function$
declare v_i jsonb;v_type text;v_payload jsonb;v_cmd game.game_commands%rowtype;v_result jsonb;v_actor game.police_personnel%rowtype;v_case_id uuid;
begin
 v_i:=game.interpret_text_command(p_command_text);v_type:=v_i->>'command_type';v_payload:=coalesce(v_i->'payload','{}'::jsonb);
 if v_type='help' then
  v_result:=game.execute_text_command_before_case_review(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  return jsonb_set(v_result,'{available_commands}',coalesce(v_result->'available_commands','[]'::jsonb)||jsonb_build_array('get_case_review_dossier'),true);
 end if;
 if coalesce((v_i->>'recognized')::boolean,false)=false or v_type<>'get_case_review_dossier' then
  return game.execute_text_command_before_case_review(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
 end if;
 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then raise exception 'Command text must contain between 1 and 4000 characters'; end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key between 8 and 200 characters is required'; end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload) values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload) on conflict(idempotency_key) do nothing;
 if not found then
  select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if v_cmd.command_text<>p_command_text or v_cmd.command_type<>v_type or v_cmd.payload<>v_payload then return jsonb_build_object('ok',false,'code','idempotency_conflict','message','This command key was already used for a different command.','command_id',v_cmd.id); end if;
  return coalesce(v_cmd.result,jsonb_build_object('ok',v_cmd.status='completed','status',v_cmd.status,'command_id',v_cmd.id))||jsonb_build_object('duplicate',true);
 end if;
 select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(v_payload->>'actor_ref');
 select id into v_case_id from game.cases where case_ref=btrim(v_payload->>'case_ref');
 if not found then v_result:=jsonb_build_object('ok',false,'code','case_not_found','message','Case reference not found.');
 elsif v_actor.id is null or (p_actor_personnel_id is not null and p_actor_personnel_id<>v_actor.id) then v_result:=jsonb_build_object('ok',false,'code','actor_mismatch','message','The command actor must match the named police personnel record.');
 elsif not exists(select 1 from game.case_assignments a where a.case_id=v_case_id and a.personnel_id=v_actor.id and a.status='active' and a.released_at is null) and not exists(select 1 from game.cases c where c.id=v_case_id and c.lead_personnel_id=v_actor.id) then v_result:=jsonb_build_object('ok',false,'code','case_access_denied','message','The officer must be the recorded case lead or hold an active assignment to this case.');
 else v_result:=game.get_case_review_dossier(v_payload->>'case_ref'); end if;
 if coalesce((v_result->>'ok')::boolean,false) then
  v_result:=v_result||jsonb_build_object('status','completed','command_id',v_cmd.id);
  update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_cmd.id;
 else
  update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Case review request rejected.'),result=v_result,completed_at=now() where id=v_cmd.id;
  v_result:=v_result||jsonb_build_object('command_id',v_cmd.id);
 end if;
 return v_result;
end
$function$;
revoke all on function game.get_case_review_dossier(text),game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.get_case_review_dossier(text),game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) to service_role;
