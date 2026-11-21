
create sequence game.prosecution_referral_ref_seq;

create table game.prosecution_referrals (
 id uuid primary key default gen_random_uuid(),
 referral_ref text not null unique default ('KWPREF-'||lpad(nextval('game.prosecution_referral_ref_seq')::text,7,'0')),
 case_id uuid not null references game.cases(id),
 arrest_id uuid not null references game.arrests(id),
 person_id uuid not null references game.persons(id),
 submitted_by_personnel_id uuid not null references game.police_personnel(id),
 submitted_at_game_time timestamptz not null,
 summary text not null,
 proposed_charges text not null,
 evidence_summary text not null,
 status text not null default 'pending',
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now(),
 constraint prosecution_referrals_status_check check(status in ('pending','accepted','returned','declined')),
 constraint prosecution_referrals_arrest_unique unique(arrest_id)
);

create table game.prosecution_referral_events (
 id uuid primary key default gen_random_uuid(),
 referral_id uuid not null references game.prosecution_referrals(id),
 event_type text not null check(event_type in ('submitted','accepted','returned','declined')),
 actor_personnel_id uuid not null references game.police_personnel(id),
 event_at_game_time timestamptz not null,
 reason text not null,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now()
);

create index prosecution_referrals_case_idx on game.prosecution_referrals(case_id,submitted_at_game_time);
create index prosecution_referrals_arrest_idx on game.prosecution_referrals(arrest_id);
create index prosecution_referrals_person_idx on game.prosecution_referrals(person_id);
create index prosecution_referrals_submitter_idx on game.prosecution_referrals(submitted_by_personnel_id);
create index prosecution_referrals_command_idx on game.prosecution_referrals(source_command_id);
create index prosecution_referral_events_referral_idx on game.prosecution_referral_events(referral_id,event_at_game_time);
create index prosecution_referral_events_actor_idx on game.prosecution_referral_events(actor_personnel_id);
create index prosecution_referral_events_command_idx on game.prosecution_referral_events(source_command_id);

alter table game.prosecution_referrals enable row level security;
alter table game.prosecution_referral_events enable row level security;
revoke all on game.prosecution_referrals,game.prosecution_referral_events from public,anon,authenticated;
grant select,insert,update on game.prosecution_referrals to service_role;
grant select,insert on game.prosecution_referral_events to service_role;
grant usage,select on sequence game.prosecution_referral_ref_seq to service_role;

create or replace function game.reject_prosecution_history_mutation()
returns trigger language plpgsql set search_path='pg_catalog','game' as $$
begin raise exception 'Prosecution referral history is append-only'; end $$;

create trigger prosecution_referral_events_append_only
before update or delete on game.prosecution_referral_events
for each row execute function game.reject_prosecution_history_mutation();

create or replace function game.interpret_prosecution_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path='pg_catalog','game' as $$
declare m text[];
begin
 m:=regexp_match(p_command_text,'^prosecution refer ([A-Za-z0-9_-]+) arrest ([A-Za-z0-9_-]+) by ([A-Za-z0-9_-]+) summary "([^"]{1,4000})" charges "([^"]{1,4000})" evidence "([^"]{1,8000})"$','i');
 if m is not null then return jsonb_build_object('command_type','submit_prosecution_referral','payload',jsonb_build_object('case_ref',m[1],'arrest_ref',m[2],'actor_ref',m[3],'summary',m[4],'charges',m[5],'evidence',m[6]));end if;
 m:=regexp_match(p_command_text,'^prosecution decision ([A-Za-z0-9_-]+) set (accepted|returned|declined) by ([A-Za-z0-9_-]+) because "([^"]{1,4000})"$','i');
 if m is not null then return jsonb_build_object('command_type','decide_prosecution_referral','payload',jsonb_build_object('referral_ref',m[1],'decision',lower(m[2]),'actor_ref',m[3],'reason',m[4]));end if;
 m:=regexp_match(p_command_text,'^prosecution referrals ([A-Za-z0-9_-]+) by ([A-Za-z0-9_-]+)$','i');
 if m is not null then return jsonb_build_object('command_type','get_prosecution_referrals','payload',jsonb_build_object('case_ref',m[1],'actor_ref',m[2]));end if;
 return null;
end $$;

create or replace function game.execute_prosecution_command(p_command_id uuid,p_type text,p jsonb,p_actor_id uuid)
returns jsonb language plpgsql security definer set search_path='pg_catalog','game' as $$
declare n timestamptz; c game.cases%rowtype; a game.arrests%rowtype; r game.prosecution_referrals%rowtype; v_ref text;
begin
 select current_game_time into n from game.simulation_state where id=1 for update;
 if n is null then return jsonb_build_object('ok',false,'code','clock_not_initialized');end if;
 if p_type='submit_prosecution_referral' then
  select * into c from game.cases where case_ref=p->>'case_ref' and status in ('open','under_investigation','submitted');
  select * into a from game.arrests where arrest_ref=p->>'arrest_ref';
  if c.id is null or a.id is null or a.case_id<>c.id then return jsonb_build_object('ok',false,'code','case_or_arrest_not_found');end if;
  if a.person_id is null or not exists(select 1 from game.case_persons cp where cp.case_id=c.id and cp.person_id=a.person_id and cp.case_role in ('suspect','person_of_interest')) then return jsonb_build_object('ok',false,'code','arrested_person_not_linked_to_case');end if;
  if not (c.lead_personnel_id=p_actor_id or exists(select 1 from game.case_assignments ca where ca.case_id=c.id and ca.personnel_id=p_actor_id and ca.status='active' and ca.released_at is null)) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  if nullif(btrim(p->>'summary'),'') is null or nullif(btrim(p->>'charges'),'') is null or nullif(btrim(p->>'evidence'),'') is null then return jsonb_build_object('ok',false,'code','referral_incomplete');end if;
  if exists(select 1 from game.prosecution_referrals where arrest_id=a.id) then return jsonb_build_object('ok',false,'code','referral_already_exists');end if;
  insert into game.prosecution_referrals(case_id,arrest_id,person_id,submitted_by_personnel_id,submitted_at_game_time,summary,proposed_charges,evidence_summary,source_command_id)
  values(c.id,a.id,a.person_id,p_actor_id,n,p->>'summary',p->>'charges',p->>'evidence',p_command_id) returning * into r;
  insert into game.prosecution_referral_events(referral_id,event_type,actor_personnel_id,event_at_game_time,reason,source_command_id)
  values(r.id,'submitted',p_actor_id,n,'Referral submitted: '||r.summary,p_command_id);
  return jsonb_build_object('ok',true,'referral_ref',r.referral_ref,'status',r.status);
 elsif p_type='decide_prosecution_referral' then
  select * into r from game.prosecution_referrals where referral_ref=p->>'referral_ref' for update;
  if r.id is null or r.status<>'pending' then return jsonb_build_object('ok',false,'code','pending_referral_not_found');end if;
  if nullif(btrim(p->>'reason'),'') is null then return jsonb_build_object('ok',false,'code','decision_reason_required');end if;
  update game.prosecution_referrals set status=p->>'decision' where id=r.id;
  insert into game.prosecution_referral_events(referral_id,event_type,actor_personnel_id,event_at_game_time,reason,source_command_id)
  values(r.id,p->>'decision',p_actor_id,n,p->>'reason',p_command_id);
  return jsonb_build_object('ok',true,'referral_ref',r.referral_ref,'status',p->>'decision');
 elsif p_type='get_prosecution_referrals' then
  select * into c from game.cases where case_ref=p->>'case_ref';
  if c.id is null or not (c.lead_personnel_id=p_actor_id or exists(select 1 from game.case_assignments ca where ca.case_id=c.id and ca.personnel_id=p_actor_id and ca.status='active' and ca.released_at is null)) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  return jsonb_build_object('ok',true,'referrals',coalesce((select jsonb_agg(jsonb_build_object('referral_ref',pr.referral_ref,'arrest_ref',ar.arrest_ref,'person_ref',pe.person_ref,'status',pr.status,'summary',pr.summary,'proposed_charges',pr.proposed_charges,'evidence_summary',pr.evidence_summary,'submitted_at',pr.submitted_at_game_time,'events',(select coalesce(jsonb_agg(jsonb_build_object('event_type',e.event_type,'actor',pp.personnel_ref,'at',e.event_at_game_time,'reason',e.reason) order by e.event_at_game_time),'[]'::jsonb) from game.prosecution_referral_events e join game.police_personnel pp on pp.id=e.actor_personnel_id where e.referral_id=pr.id)) order by pr.submitted_at_game_time) from game.prosecution_referrals pr join game.arrests ar on ar.id=pr.arrest_id join game.persons pe on pe.id=pr.person_id where pr.case_id=c.id),'[]'::jsonb));
 end if;
 return jsonb_build_object('ok',false,'code','unsupported_command');
end $$;

create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path='pg_catalog','game' as $$
declare r jsonb;
begin
 r:=game.interpret_prosecution_command(p_command_text);
 if r is not null then return r;end if;
 return game.interpret_text_command_before_arrest_custody(p_command_text);
end $$;

create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path='pg_catalog','game' as $$
declare i jsonb;typ text;d jsonb;cmd game.game_commands%rowtype;actor game.police_personnel%rowtype;res jsonb;
begin
 i:=game.interpret_text_command(p_command_text);typ:=i->>'command_type';d:=coalesce(i->'payload','{}'::jsonb);
 if typ='help' then
  res:=game.execute_text_command_before_arrest_custody(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  return jsonb_set(res,'{available_commands}',(select coalesce(jsonb_agg(distinct x),'[]') from jsonb_array_elements_text(coalesce(res->'available_commands','[]')||jsonb_build_array('submit_prosecution_referral','decide_prosecution_referral','get_prosecution_referrals'))x),true);
 end if;
 if typ not in ('submit_prosecution_referral','decide_prosecution_referral','get_prosecution_referrals') then return game.execute_text_command_before_arrest_custody(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key is required';end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload)
 values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,typ,d) on conflict(idempotency_key) do nothing;
 if not found then
  select * into cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if cmd.command_text<>p_command_text or cmd.command_type<>typ or cmd.payload<>d then return jsonb_build_object('ok',false,'code','idempotency_conflict');end if;
  return coalesce(cmd.result,jsonb_build_object('ok',cmd.status='completed'))||jsonb_build_object('duplicate',true);
 end if;
 select * into cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 select * into actor from game.police_personnel where personnel_ref=d->>'actor_ref' and employment_status in ('active','seconded');
 if actor.id is null or (p_actor_personnel_id is not null and p_actor_personnel_id<>actor.id) then res:=jsonb_build_object('ok',false,'code','actor_mismatch');
 else res:=game.execute_prosecution_command(cmd.id,typ,d,actor.id);end if;
 if coalesce((res->>'ok')::boolean,false) then
  res:=res||jsonb_build_object('status','completed','command_id',cmd.id);
  update game.game_commands set status='completed',result=res,completed_at=now() where id=cmd.id;
 else
  update game.game_commands set status='rejected',result=res,rejection_reason=coalesce(res->>'message','Prosecution command rejected'),completed_at=now() where id=cmd.id;
  res:=res||jsonb_build_object('command_id',cmd.id);
 end if;
 return res;
end $$;

revoke all on function game.interpret_prosecution_command(text) from public,anon,authenticated;
revoke all on function game.execute_prosecution_command(uuid,text,jsonb,uuid) from public,anon,authenticated;
grant execute on function game.interpret_prosecution_command(text) to service_role;
grant execute on function game.execute_prosecution_command(uuid,text,jsonb,uuid) to service_role;
revoke all on function game.interpret_text_command(text) from public,anon,authenticated;
revoke all on function game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text) to service_role;
grant execute on function game.execute_text_command(text,text,uuid,uuid) to service_role;
