-- Kingswell NPC trial proceedings foundation.
create sequence game.trial_plea_ref_seq;
create sequence game.trial_event_ref_seq;
create sequence game.trial_tender_ref_seq;

create table game.trial_pleas(
 id uuid primary key default gen_random_uuid(),
 plea_ref text not null unique default ('KWPL-'||lpad(nextval('game.trial_plea_ref_seq')::text,7,'0')),
 charge_id uuid not null references game.formal_charges(id),
 person_id uuid not null references game.persons(id),
 plea text not null check(plea in ('guilty','not_guilty','no_plea')),
 recorded_at_game_time timestamptz not null,
 recorded_by_person_id uuid not null references game.persons(id),
 notes text,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now()
);
create index trial_pleas_charge_idx on game.trial_pleas(charge_id,recorded_at_game_time desc);

create table game.trial_proceedings(
 id uuid primary key default gen_random_uuid(),
 event_ref text not null unique default ('KWTP-'||lpad(nextval('game.trial_event_ref_seq')::text,7,'0')),
 hearing_id uuid not null references game.court_hearings(id),
 event_type text not null check(event_type in ('prosecution_opening','defence_opening','witness_examination','witness_cross_examination','re_examination','accused_testimony','submission','objection','judicial_ruling','closing_submission','jury_direction','verdict_announcement','other')),
 speaker_person_id uuid not null references game.persons(id),
 recorded_by_official_id uuid not null references game.court_official_profiles(id),
 details text not null,
 recorded_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now()
);
create index trial_proceedings_hearing_idx on game.trial_proceedings(hearing_id,recorded_at_game_time);

create table game.trial_evidence_tenders(
 id uuid primary key default gen_random_uuid(),
 tender_ref text not null unique default ('KWTE-'||lpad(nextval('game.trial_tender_ref_seq')::text,7,'0')),
 hearing_id uuid not null references game.court_hearings(id),
 evidence_id uuid not null references game.evidence_items(id),
 tendered_by_kind text not null check(tendered_by_kind in ('prosecutor','defence_counsel')),
 tendered_by_profile_id uuid not null,
 purpose text not null,
 status text not null default 'pending' check(status in ('pending','admitted','excluded','limited')),
 ruling_reason text,
 tendered_at_game_time timestamptz not null,
 ruled_at_game_time timestamptz,
 source_command_id uuid not null references game.game_commands(id),
 ruling_command_id uuid references game.game_commands(id),
 created_at timestamptz not null default now(),
 check((status='pending' and ruled_at_game_time is null and ruling_command_id is null) or (status<>'pending' and ruled_at_game_time is not null and ruling_command_id is not null))
);
create unique index trial_tender_once_per_hearing_idx on game.trial_evidence_tenders(hearing_id,evidence_id);
create index trial_tenders_hearing_idx on game.trial_evidence_tenders(hearing_id,status);

create table game.trial_proceeding_events(
 id uuid primary key default gen_random_uuid(),
 event_type text not null check(event_type in ('plea_recorded','proceeding_recorded','evidence_tendered','evidence_ruled')),
 subject_ref text not null,
 actor_kind text not null check(actor_kind in ('person','court_official','prosecutor','defence_counsel')),
 actor_profile_id uuid not null,
 event_at_game_time timestamptz not null,
 details jsonb not null default '{}'::jsonb,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now()
);
create index trial_proceeding_events_subject_idx on game.trial_proceeding_events(subject_ref,event_at_game_time);
create index trial_proceeding_events_command_idx on game.trial_proceeding_events(source_command_id);

alter table game.trial_pleas enable row level security;
alter table game.trial_proceedings enable row level security;
alter table game.trial_evidence_tenders enable row level security;
alter table game.trial_proceeding_events enable row level security;
revoke all on game.trial_pleas,game.trial_proceedings,game.trial_evidence_tenders,game.trial_proceeding_events from public,anon,authenticated;
grant select,insert on game.trial_pleas,game.trial_proceedings,game.trial_proceeding_events to service_role;
grant select,insert,update on game.trial_evidence_tenders to service_role;
grant usage,select on sequence game.trial_plea_ref_seq,game.trial_event_ref_seq,game.trial_tender_ref_seq to service_role;

create or replace function game.reject_trial_history_mutation()
returns trigger language plpgsql set search_path='pg_catalog','game' as $$
begin raise exception 'Trial history is append-only'; end $$;
create trigger trial_pleas_append_only before update or delete on game.trial_pleas for each row execute function game.reject_trial_history_mutation();
create trigger trial_proceedings_append_only before update or delete on game.trial_proceedings for each row execute function game.reject_trial_history_mutation();
create trigger trial_proceeding_events_append_only before update or delete on game.trial_proceeding_events for each row execute function game.reject_trial_history_mutation();

alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_trial;
CREATE OR REPLACE FUNCTION game.interpret_text_command(p_command_text text)
 RETURNS jsonb
 LANGUAGE plpgsql
 IMMUTABLE
 SET search_path TO 'pg_catalog', 'game'
AS $function$
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
end $function$

CREATE OR REPLACE FUNCTION game.execute_trial_command(p_command_id uuid, p_type text, p jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'game'
AS $function$
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
end $function$

CREATE OR REPLACE FUNCTION game.execute_text_command(p_command_text text, p_idempotency_key text, p_session_id uuid DEFAULT NULL::uuid, p_actor_personnel_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare i jsonb; typ text; d jsonb; cmd game.game_commands%rowtype; res jsonb;
begin
 i:=game.interpret_text_command(p_command_text); typ:=i->>'command_type'; d:=coalesce(i->'payload','{}'::jsonb);
 if typ not in ('record_trial_plea','record_trial_proceeding','tender_trial_evidence','rule_trial_evidence') then
  return game.execute_text_command_before_trial(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
 end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key is required'; end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload)
 values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,typ,d) on conflict(idempotency_key) do nothing;
 if not found then
  select * into cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if cmd.command_text<>p_command_text or cmd.command_type<>typ or cmd.payload<>d then return jsonb_build_object('ok',false,'code','idempotency_conflict'); end if;
  return coalesce(cmd.result,jsonb_build_object('ok',cmd.status='completed'))||jsonb_build_object('duplicate',true);
 end if;
 select * into cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 res:=game.execute_trial_command(cmd.id,typ,d);
 if coalesce((res->>'ok')::boolean,false) then
  res:=res||jsonb_build_object('status','completed','command_id',cmd.id);
  update game.game_commands set status='completed',result=res,completed_at=now() where id=cmd.id;
 else
  update game.game_commands set status='rejected',result=res,rejection_reason=coalesce(res->>'message','Trial command rejected'),completed_at=now() where id=cmd.id;
  res:=res||jsonb_build_object('command_id',cmd.id);
 end if;
 return res;
end $function$

CREATE OR REPLACE FUNCTION game.get_trial_record(p_hearing_ref text)
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'game'
AS $function$
 select jsonb_build_object(
  'ok',true,'hearing_ref',h.hearing_ref,
  'pleas',(select coalesce(jsonb_agg(jsonb_build_object('plea_ref',p.plea_ref,'charge_ref',fc.charge_ref,'person_ref',person.person_ref,'plea',p.plea,'recorded_at',p.recorded_at_game_time,'notes',p.notes) order by p.recorded_at_game_time),'[]'::jsonb) from game.trial_pleas p join game.formal_charges fc on fc.id=p.charge_id join game.persons person on person.id=p.person_id where fc.case_id=cc.case_id),
  'proceedings',(select coalesce(jsonb_agg(jsonb_build_object('event_ref',tp.event_ref,'type',tp.event_type,'speaker_ref',sp.person_ref,'details',tp.details,'recorded_at',tp.recorded_at_game_time) order by tp.recorded_at_game_time),'[]'::jsonb) from game.trial_proceedings tp join game.persons sp on sp.id=tp.speaker_person_id where tp.hearing_id=h.id),
  'evidence_tenders',(select coalesce(jsonb_agg(jsonb_build_object('tender_ref',t.tender_ref,'evidence_ref',e.evidence_ref,'side',t.tendered_by_kind,'purpose',t.purpose,'status',t.status,'ruling_reason',t.ruling_reason) order by t.tendered_at_game_time),'[]'::jsonb) from game.trial_evidence_tenders t join game.evidence_items e on e.id=t.evidence_id where t.hearing_id=h.id)
 )
 from game.court_hearings h join game.court_cases cc on cc.id=h.court_case_id
 where h.hearing_ref=p_hearing_ref and h.hearing_type='trial'
$function$

revoke all on function game.interpret_text_command(text) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text) to service_role;
revoke all on function game.execute_trial_command(uuid,text,jsonb) from public,anon,authenticated;
grant execute on function game.execute_trial_command(uuid,text,jsonb) to service_role;
revoke all on function game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.execute_text_command(text,text,uuid,uuid) to service_role;
revoke all on function game.get_trial_record(text) from public,anon,authenticated;
grant execute on function game.get_trial_record(text) to service_role;
