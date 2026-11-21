
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path='pg_catalog','game' as $$
declare m text[]; r jsonb;
begin
 m:=regexp_match(btrim(p_command_text),'^court plea record ([A-Za-z0-9_-]+) by ([A-Za-z0-9_-]+) as (guilty|not_guilty|no_plea)(?: notes "([^"]*)")?$','i');
 if m is not null then return jsonb_build_object('command_type','record_trial_plea','payload',jsonb_build_object('charge_ref',m[1],'person_ref',m[2],'plea',lower(m[3]),'notes',m[4])); end if;
 m:=regexp_match(btrim(p_command_text),'^court trial record ([A-Za-z0-9_-]+) by ([A-Za-z0-9_-]+) type (prosecution_opening|defence_opening|witness_examination|witness_cross_examination|re_examination|accused_testimony|submission|objection|judicial_ruling|closing_submission|jury_direction|verdict_announcement|other) speaker ([A-Za-z0-9_-]+) details "([^"]+)"$','i');
 if m is not null then return jsonb_build_object('command_type','record_trial_proceeding','payload',jsonb_build_object('hearing_ref',m[1],'official_ref',m[2],'event_type',lower(m[3]),'speaker_ref',m[4],'details',m[5])); end if;
 m:=regexp_match(btrim(p_command_text),'^court trial tender ([A-Za-z0-9_-]+) evidence ([A-Za-z0-9_-]+) by ([A-Za-z0-9_-]+) side (prosecution|defence) purpose "([^"]+)"$','i');
 if m is not null then return jsonb_build_object('command_type','tender_trial_evidence','payload',jsonb_build_object('hearing_ref',m[1],'evidence_ref',m[2],'actor_ref',m[3],'side',lower(m[4]),'purpose',m[5])); end if;
 m:=regexp_match(btrim(p_command_text),'^court trial rule ([A-Za-z0-9_-]+) by ([A-Za-z0-9_-]+) ruling (admitted|excluded|limited) because "([^"]+)"$','i');
 if m is not null then return jsonb_build_object('command_type','rule_trial_evidence','payload',jsonb_build_object('tender_ref',m[1],'judge_ref',m[2],'ruling',lower(m[3]),'reason',m[4])); end if;
 r:=game.interpret_justice_command(p_command_text);
 if r is not null then return r; end if;
 r:=game.interpret_prosecution_command(p_command_text);
 if r is not null then return r; end if;
 return game.interpret_text_command_before_arrest_custody(p_command_text);
end $$;

create or replace function game.execute_trial_command(p_command_id uuid,p_type text,p jsonb)
returns jsonb language plpgsql security definer set search_path='pg_catalog','game' as $$
declare n timestamptz; ch game.formal_charges%rowtype; pl game.trial_pleas%rowtype; pe game.persons%rowtype; h game.court_hearings%rowtype; cc game.court_cases%rowtype;
 off game.court_official_profiles%rowtype; ev game.evidence_items%rowtype; pro game.prosecutor_profiles%rowtype; dc game.defence_counsel_profiles%rowtype;
 te game.trial_evidence_tenders%rowtype; tp game.trial_proceedings%rowtype; side_kind text; side_id uuid;
begin
 select current_game_time into n from game.simulation_state where id=1 for update;
 if n is null then return jsonb_build_object('ok',false,'code','clock_not_initialized'); end if;
 if p_type='record_trial_plea' then
  select * into ch from game.formal_charges where charge_ref=p->>'charge_ref' and status='filed';
  select * into pe from game.persons where person_ref=p->>'person_ref';
  if ch.id is null or pe.id is null or pe.id<>ch.person_id then return jsonb_build_object('ok',false,'code','filed_charge_and_accused_person_required'); end if;
  if not exists(select 1 from game.court_cases c where c.case_id=ch.case_id and c.status in ('registered','active')) then return jsonb_build_object('ok',false,'code','active_court_registration_required'); end if;
  insert into game.trial_pleas(charge_id,person_id,plea,recorded_at_game_time,recorded_by_person_id,notes,source_command_id)
  values(ch.id,pe.id,p->>'plea',n,pe.id,nullif(p->>'notes',''),p_command_id) returning * into pl;
  insert into game.trial_proceeding_events(event_type,subject_ref,actor_kind,actor_profile_id,event_at_game_time,details,source_command_id)
  values('plea_recorded',pl.plea_ref,'person',pe.id,n,jsonb_build_object('charge_ref',p->>'charge_ref','plea',p->>'plea','notes',p->>'notes'),p_command_id);
  return jsonb_build_object('ok',true,'plea_ref',pl.plea_ref,'charge_ref',p->>'charge_ref','plea',p->>'plea','recorded_at',n);
 elsif p_type='record_trial_proceeding' then
  select * into h from game.court_hearings where hearing_ref=p->>'hearing_ref' and hearing_type='trial' and status='scheduled';
  select * into off from game.court_official_profiles where official_ref=p->>'official_ref' and status='active' and official_role in ('judge','senior_judge','chief_judge');
  select * into pe from game.persons where person_ref=p->>'speaker_ref';
  if h.id is null or off.id is null or pe.id is null or nullif(btrim(p->>'details'),'') is null then return jsonb_build_object('ok',false,'code','scheduled_trial_hearing_judge_speaker_and_details_required'); end if;
  if not exists(select 1 from game.court_cases c where c.id=h.court_case_id and c.assigned_judge_id=off.id) then return jsonb_build_object('ok',false,'code','assigned_trial_judge_required'); end if;
  if n<h.scheduled_at_game_time then return jsonb_build_object('ok',false,'code','trial_hearing_not_yet_due'); end if;
  insert into game.trial_proceedings(hearing_id,event_type,speaker_person_id,recorded_by_official_id,details,recorded_at_game_time,source_command_id)
  values(h.id,p->>'event_type',pe.id,off.id,p->>'details',n,p_command_id) returning * into tp;
  insert into game.trial_proceeding_events(event_type,subject_ref,actor_kind,actor_profile_id,event_at_game_time,details,source_command_id)
  values('proceeding_recorded',tp.event_ref,'court_official',off.id,n,jsonb_build_object('hearing_ref',h.hearing_ref,'event_type',tp.event_type,'speaker_ref',pe.person_ref,'details',tp.details),p_command_id);
  return jsonb_build_object('ok',true,'event_ref',tp.event_ref,'hearing_ref',h.hearing_ref,'event_type',tp.event_type);
 elsif p_type='tender_trial_evidence' then
  select * into h from game.court_hearings where hearing_ref=p->>'hearing_ref' and hearing_type='trial' and status='scheduled';
  select * into ev from game.evidence_items where evidence_ref=p->>'evidence_ref';
  if h.id is null or ev.id is null then return jsonb_build_object('ok',false,'code','scheduled_trial_and_evidence_required'); end if;
  select * into cc from game.court_cases where id=h.court_case_id and case_id=ev.case_id and status='active';
  if cc.id is null then return jsonb_build_object('ok',false,'code','evidence_must_belong_to_trial_case'); end if;
  if p->>'side'='prosecution' then
   select pp.* into pro from game.prosecutor_profiles pp where pp.prosecutor_ref=p->>'actor_ref' and pp.status='active'
    and exists(select 1 from game.prosecution_reviews rv join game.prosecution_referrals rr on rr.id=rv.referral_id where rv.prosecutor_id=pp.id and rr.case_id=ev.case_id);
   if pro.id is null then return jsonb_build_object('ok',false,'code','case_prosecutor_required'); end if;
   side_kind:='prosecutor'; side_id:=pro.id;
  else
   select dcp.* into dc from game.defence_counsel_profiles dcp where dcp.counsel_ref=p->>'actor_ref' and dcp.status='active'
    and exists(select 1 from game.defence_counsel_assignments da where da.counsel_id=dcp.id and da.case_id=ev.case_id and da.status='active');
   if dc.id is null then return jsonb_build_object('ok',false,'code','assigned_defence_counsel_required'); end if;
   side_kind:='defence_counsel'; side_id:=dc.id;
  end if;
  insert into game.trial_evidence_tenders(hearing_id,evidence_id,tendered_by_kind,tendered_by_profile_id,purpose,tendered_at_game_time,source_command_id)
  values(h.id,ev.id,side_kind,side_id,p->>'purpose',n,p_command_id) returning * into te;
  insert into game.trial_proceeding_events(event_type,subject_ref,actor_kind,actor_profile_id,event_at_game_time,details,source_command_id)
  values('evidence_tendered',te.tender_ref,side_kind,side_id,n,jsonb_build_object('hearing_ref',h.hearing_ref,'evidence_ref',ev.evidence_ref,'side',p->>'side','purpose',te.purpose),p_command_id);
  return jsonb_build_object('ok',true,'tender_ref',te.tender_ref,'evidence_ref',ev.evidence_ref,'status',te.status);
 elsif p_type='rule_trial_evidence' then
  select * into te from game.trial_evidence_tenders where tender_ref=p->>'tender_ref' and status='pending';
  select * into h from game.court_hearings where id=te.hearing_id;
  select * into off from game.court_official_profiles where official_ref=p->>'judge_ref' and status='active' and official_role in ('judge','senior_judge','chief_judge');
  if te.id is null or h.id is null or off.id is null or nullif(btrim(p->>'reason'),'') is null then return jsonb_build_object('ok',false,'code','pending_tender_assigned_judge_and_reason_required'); end if;
  if not exists(select 1 from game.court_cases c where c.id=h.court_case_id and c.assigned_judge_id=off.id) then return jsonb_build_object('ok',false,'code','assigned_trial_judge_required'); end if;
  if n<h.scheduled_at_game_time then return jsonb_build_object('ok',false,'code','trial_hearing_not_yet_due'); end if;
  update game.trial_evidence_tenders set status=p->>'ruling',ruling_reason=p->>'reason',ruled_at_game_time=n,ruling_command_id=p_command_id where id=te.id returning * into te;
  insert into game.trial_proceeding_events(event_type,subject_ref,actor_kind,actor_profile_id,event_at_game_time,details,source_command_id)
  values('evidence_ruled',te.tender_ref,'court_official',off.id,n,jsonb_build_object('ruling',te.status,'reason',te.ruling_reason),p_command_id);
  return jsonb_build_object('ok',true,'tender_ref',te.tender_ref,'ruling',te.status,'reason',te.ruling_reason);
 end if;
 return jsonb_build_object('ok',false,'code','unsupported_trial_command');
end $$;
