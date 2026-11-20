-- Unified read-only investigative case review dossier and player command.
create or replace function game.get_case_review_dossier(p_case_ref text)
returns jsonb
language plpgsql
stable
set search_path to 'pg_catalog','game'
as $$
declare v_case game.cases%rowtype; v_result jsonb;
begin
 select * into v_case from game.cases where case_ref=btrim(p_case_ref);
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','The requested case does not exist.'); end if;
 select jsonb_build_object(
  'ok',true,
  'case',jsonb_build_object('case_ref',v_case.case_ref,'title',v_case.case_title,'type',v_case.case_type,'status',v_case.status,'summary',v_case.summary,'opened_at',v_case.opened_at,'closed_at',v_case.closed_at,'lead_personnel_id',v_case.lead_personnel_id),
  'assignments',game.get_case_assignments(v_case.case_ref,null,true),
  'leads',game.get_case_leads(v_case.case_ref,null),
  'enquiries',coalesce((select jsonb_agg(jsonb_build_object('enquiry_ref',e.enquiry_ref,'lead_ref',l.lead_ref,'method',e.method,'action',e.action,'result',e.result,'outcome',e.outcome,'source_reference',e.source_reference,'conducted_at',e.conducted_at_game_time,'officer_ref',pp.personnel_ref) order by e.conducted_at_game_time,e.enquiry_ref) from game.case_enquiries e join game.case_leads l on l.id=e.lead_id left join game.police_personnel pp on pp.id=e.conducted_by_personnel_id where e.case_id=v_case.id),'[]'::jsonb),
  'lead_entity_links',coalesce((select jsonb_agg(jsonb_build_object('link_ref',x.link_ref,'lead_ref',l.lead_ref,'entity_type',x.entity_type,'entity_ref',x.entity_ref,'reason',x.reason,'linked_at',x.linked_at_game_time) order by x.linked_at_game_time,x.link_ref) from game.case_lead_entity_links x join game.case_leads l on l.id=x.lead_id where x.case_id=v_case.id),'[]'::jsonb),
  'tasks',game.get_case_tasks(v_case.case_ref,null,500),
  'interviews',coalesce((select jsonb_agg(jsonb_build_object(
   'interview_ref',i.interview_ref,'person_ref',p.person_ref,'person_name',concat_ws(' ',p.given_name,p.middle_names,p.family_name),'method',i.method,'purpose',i.purpose,'location',i.location_description,'started_at',i.started_at_game_time,
   'turns',coalesce((select jsonb_agg(jsonb_build_object('turn_ref',t.turn_ref,'turn_number',t.turn_number,'question',t.question_text,'answer',t.answer_text,'recorded_at',t.recorded_at_game_time) order by t.turn_number) from game.case_interview_turns t where t.interview_id=i.id),'[]'::jsonb),
   'suspect_interview',case when sir.id is null then null else jsonb_build_object('reason',sir.reason,'recorded_at',sir.recorded_at_game_time,'assessments',coalesce((select jsonb_agg(jsonb_build_object('turn_ref',t.turn_ref,'assessment',a.response_assessment,'reason',a.assessment_reason,'assessed_at',a.assessed_at_game_time) order by a.assessed_at_game_time) from game.case_suspect_interview_assessments a join game.case_interview_turns t on t.id=a.turn_id where a.interview_id=i.id),'[]'::jsonb)) end
  ) order by i.started_at_game_time,i.interview_ref) from game.case_interviews i join game.persons p on p.id=i.interviewee_person_id left join game.case_suspect_interview_records sir on sir.interview_id=i.id where i.case_id=v_case.id),'[]'::jsonb),
  'witness_statements',game.get_case_witness_statements(v_case.case_ref),
  'account_comparisons',game.get_case_account_comparisons(v_case.case_ref,null),
  'evidence',coalesce((select jsonb_agg(jsonb_build_object('evidence_ref',e.evidence_ref,'type',e.evidence_type,'description',e.description,'collected_at',e.collected_at,'collection_location',e.collection_location,'status',e.current_status,'storage_location',e.storage_location,'transfers',coalesce((select jsonb_agg(jsonb_build_object('transferred_at',tr.transferred_at,'from_location',tr.from_location,'to_location',tr.to_location,'reason',tr.transfer_reason) order by tr.transferred_at) from game.evidence_transfers tr where tr.evidence_id=e.id),'[]'::jsonb),'forensic_requests',coalesce((select jsonb_agg(jsonb_build_object('request_ref',fr.request_ref,'discipline',fr.discipline,'question',fr.examination_question,'scope',fr.scope,'status',fr.status,'triage_decision',fr.triage_decision,'reports',coalesce((select jsonb_agg(jsonb_build_object('report_ref',rp.report_ref,'version',rp.version_number,'summary',rp.report_summary,'body',rp.report_body,'status',rp.status,'issued_at',rp.issued_at) order by rp.version_number) from game.forensic_reports rp where rp.request_id=fr.id),'[]'::jsonb),'examinations',coalesce((select jsonb_agg(jsonb_build_object('examination_ref',ex.examination_ref,'status',ex.status,'question',ex.examination_question,'scope',ex.scope,'findings',coalesce((select jsonb_agg(jsonb_build_object('finding_ref',fd.finding_ref,'version',fd.version_number,'observations',fd.observations,'interpretation',fd.interpretation,'propositions',fd.propositions,'limitations',fd.limitations,'outcome',fd.outcome,'recorded_at',fd.recorded_at) order by fd.version_number) from game.forensic_findings fd where fd.examination_id=ex.id),'[]'::jsonb)) order by ex.assigned_at) from game.forensic_examinations ex where ex.request_id=fr.id),'[]'::jsonb)) order by fr.submitted_at) from game.forensic_request_items ri join game.forensic_requests fr on fr.id=ri.request_id where ri.evidence_id=e.id),'[]'::jsonb)) order by e.collected_at,e.evidence_ref) from game.evidence_items e where e.case_id=v_case.id),'[]'::jsonb),
  'forensic_requests',coalesce((select jsonb_agg(jsonb_build_object('request_ref',fr.request_ref,'discipline',fr.discipline,'question',fr.examination_question,'scope',fr.scope,'priority',fr.priority,'status',fr.status,'triage_decision',fr.triage_decision,'submitted_at',fr.submitted_at,'items',coalesce((select jsonb_agg(jsonb_build_object('evidence_ref',e.evidence_ref,'requested_context',ri.requested_context)) from game.forensic_request_items ri join game.evidence_items e on e.id=ri.evidence_id where ri.request_id=fr.id),'[]'::jsonb)) order by fr.submitted_at,fr.request_ref) from game.forensic_requests fr where fr.case_id=v_case.id),'[]'::jsonb),
  'incidents',coalesce((select jsonb_agg(jsonb_build_object('incident_ref',i.incident_ref,'relationship',ci.relationship_type,'summary',i.summary,'details',i.details,'status',i.status,'reported_at',i.reported_at,'occurred_from',i.occurred_from,'occurred_to',i.occurred_to,'location',i.location_description) order by i.reported_at) from game.case_incidents ci join game.incidents i on i.id=ci.incident_id where ci.case_id=v_case.id),'[]'::jsonb),
  'account_comparison_count',(select count(*) from game.case_account_comparisons c where c.case_id=v_case.id),
  'evidence_count',(select count(*) from game.evidence_items e where e.case_id=v_case.id),
  'generated_at_game_time',(select current_game_time from game.simulation_state where id=1)
 ) into v_result;
 return v_result;
end $$;
revoke all on function game.get_case_review_dossier(text) from public,anon,authenticated;
grant execute on function game.get_case_review_dossier(text) to service_role;
alter function game.interpret_text_command(text) rename to interpret_text_command_before_case_review_dossier;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game' as $$
declare t text:=btrim(coalesce(p_command_text,''));m text[];
begin
 m:=regexp_match(t,'^case review ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','get_case_review_dossier','payload',jsonb_build_object('case_ref',m[1])); end if;
 return game.interpret_text_command_before_case_review_dossier(p_command_text);
end $$;
alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_case_review_dossier;
create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare v_i jsonb;v_cmd game.game_commands%rowtype;v_result jsonb;v_type text;v_payload jsonb;
begin
 v_i:=game.interpret_text_command(p_command_text);v_type:=v_i->>'command_type';v_payload:=coalesce(v_i->'payload','{}'::jsonb);
 if v_type='help' then
  v_result:=game.execute_text_command_before_case_review_dossier(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  return jsonb_set(v_result,'{available_commands}',coalesce(v_result->'available_commands','[]'::jsonb)||jsonb_build_array('get_case_review_dossier'),true);
 end if;
 if coalesce((v_i->>'recognized')::boolean,false)=false or v_type<>'get_case_review_dossier' then return game.execute_text_command_before_case_review_dossier(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id); end if;
 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then raise exception 'Command text must contain between 1 and 4000 characters'; end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key between 8 and 200 characters is required'; end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload) values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload) on conflict(idempotency_key) do nothing;
 if not found then
  select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if v_cmd.command_text<>p_command_text or v_cmd.command_type<>v_type or v_cmd.payload<>v_payload then return jsonb_build_object('ok',false,'code','idempotency_conflict','message','This command key was already used for a different command.','command_id',v_cmd.id); end if;
  return coalesce(v_cmd.result,jsonb_build_object('ok',v_cmd.status='completed','status',v_cmd.status,'command_id',v_cmd.id))||jsonb_build_object('duplicate',true);
 end if;
 select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 v_result:=game.get_case_review_dossier(v_payload->>'case_ref');
 if coalesce((v_result->>'ok')::boolean,false) then
  v_result:=v_result||jsonb_build_object('status','completed','command_id',v_cmd.id);
  update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_cmd.id;
 else
  update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Case review retrieval failed.'),result=v_result,completed_at=now() where id=v_cmd.id;
  v_result:=v_result||jsonb_build_object('command_id',v_cmd.id);
 end if;
 return v_result;
end $$;
revoke all on function game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) to service_role;
