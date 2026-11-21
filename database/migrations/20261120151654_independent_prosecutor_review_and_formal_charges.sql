
create sequence game.prosecutor_ref_seq;
create sequence game.charge_ref_seq;

create table game.prosecutor_profiles(
 id uuid primary key default gen_random_uuid(),
 prosecutor_ref text not null unique default ('KWP-'||lpad(nextval('game.prosecutor_ref_seq')::text,7,'0')),
 person_id uuid not null references game.persons(id),
 role text not null check(role in ('prosecutor','senior_prosecutor','chief_prosecutor')),
 status text not null default 'active' check(status in ('active','suspended','left')),
 appointed_by_personnel_id uuid not null references game.police_personnel(id),
 appointed_at_game_time timestamptz not null,
 created_at timestamptz not null default now(),
 unique(person_id)
);
create table game.prosecution_reviews(
 id uuid primary key default gen_random_uuid(),
 referral_id uuid not null unique references game.prosecution_referrals(id),
 prosecutor_id uuid not null references game.prosecutor_profiles(id),
 decision text not null check(decision in ('accepted','returned','declined')),
 reason text not null,
 reviewed_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now()
);
create table game.prosecution_review_events(
 id uuid primary key default gen_random_uuid(),
 review_id uuid not null references game.prosecution_reviews(id),
 event_type text not null check(event_type in ('review_recorded')),
 prosecutor_id uuid not null references game.prosecutor_profiles(id),
 event_at_game_time timestamptz not null,
 reason text not null,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now()
);
create table game.formal_charges(
 id uuid primary key default gen_random_uuid(),
 charge_ref text not null unique default ('KWCHG-'||lpad(nextval('game.charge_ref_seq')::text,7,'0')),
 referral_id uuid not null references game.prosecution_referrals(id),
 case_id uuid not null references game.cases(id),
 person_id uuid not null references game.persons(id),
 prosecutor_id uuid not null references game.prosecutor_profiles(id),
 count_number integer not null check(count_number between 1 and 999),
 offence_code text not null,
 charge_title text not null,
 particulars text not null,
 status text not null default 'filed' check(status in ('filed','amended','withdrawn')),
 filed_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now(),
 unique(referral_id,count_number)
);
create table game.formal_charge_events(
 id uuid primary key default gen_random_uuid(),
 charge_id uuid not null references game.formal_charges(id),
 event_type text not null check(event_type in ('filed','amended','withdrawn')),
 prosecutor_id uuid not null references game.prosecutor_profiles(id),
 event_at_game_time timestamptz not null,
 reason text not null,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now()
);

create index prosecutor_profiles_person_idx on game.prosecutor_profiles(person_id);
create index prosecutor_profiles_appointor_idx on game.prosecutor_profiles(appointed_by_personnel_id);
create index prosecution_reviews_prosecutor_idx on game.prosecution_reviews(prosecutor_id,reviewed_at_game_time);
create index prosecution_reviews_referral_idx on game.prosecution_reviews(referral_id);
create index prosecution_review_events_review_idx on game.prosecution_review_events(review_id,event_at_game_time);
create index prosecution_review_events_prosecutor_idx on game.prosecution_review_events(prosecutor_id);
create index prosecution_review_events_command_idx on game.prosecution_review_events(source_command_id);
create index formal_charges_referral_idx on game.formal_charges(referral_id);
create index formal_charges_case_idx on game.formal_charges(case_id,person_id);
create index formal_charges_prosecutor_idx on game.formal_charges(prosecutor_id);
create index formal_charges_command_idx on game.formal_charges(source_command_id);
create index formal_charge_events_charge_idx on game.formal_charge_events(charge_id,event_at_game_time);
create index formal_charge_events_prosecutor_idx on game.formal_charge_events(prosecutor_id);
create index formal_charge_events_command_idx on game.formal_charge_events(source_command_id);

alter table game.prosecutor_profiles enable row level security;
alter table game.prosecution_reviews enable row level security;
alter table game.prosecution_review_events enable row level security;
alter table game.formal_charges enable row level security;
alter table game.formal_charge_events enable row level security;
revoke all on game.prosecutor_profiles,game.prosecution_reviews,game.prosecution_review_events,game.formal_charges,game.formal_charge_events from public,anon,authenticated;
grant select,insert,update on game.prosecutor_profiles to service_role;
grant select,insert on game.prosecution_reviews,game.prosecution_review_events,game.formal_charges,game.formal_charge_events to service_role;
grant usage,select on sequence game.prosecutor_ref_seq,game.charge_ref_seq to service_role;

create or replace function game.reject_justice_history_mutation()
returns trigger language plpgsql set search_path='pg_catalog','game' as $$
begin raise exception 'Prosecution review and charge histories are append-only'; end $$;
create trigger prosecution_review_events_append_only before update or delete on game.prosecution_review_events for each row execute function game.reject_justice_history_mutation();
create trigger formal_charge_events_append_only before update or delete on game.formal_charge_events for each row execute function game.reject_justice_history_mutation();

create or replace function game.interpret_justice_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path='pg_catalog','game' as $$
declare m text[];
begin
 m:=regexp_match(p_command_text,'^prosecutor appoint ([A-Za-z0-9_-]+) role (prosecutor|senior_prosecutor|chief_prosecutor) by ([A-Za-z0-9_-]+)$','i');
 if m is not null then return jsonb_build_object('command_type','appoint_prosecutor','payload',jsonb_build_object('person_ref',m[1],'role',lower(m[2]),'actor_ref',m[3]));end if;
 m:=regexp_match(p_command_text,'^prosecutor review ([A-Za-z0-9_-]+) set (accepted|returned|declined) by ([A-Za-z0-9_-]+) because "([^"]+)"$','i');
 if m is not null then return jsonb_build_object('command_type','record_prosecution_review','payload',jsonb_build_object('referral_ref',m[1],'decision',lower(m[2]),'prosecutor_ref',m[3],'reason',m[4]));end if;
 m:=regexp_match(p_command_text,'^prosecution charge file ([A-Za-z0-9_-]+) by ([A-Za-z0-9_-]+) count ([0-9]+) offence ([A-Za-z0-9_-]+) title "([^"]+)" particulars "([^"]+)"$','i');
 if m is not null then return jsonb_build_object('command_type','file_formal_charge','payload',jsonb_build_object('referral_ref',m[1],'prosecutor_ref',m[2],'count_number',m[3]::integer,'offence_code',m[4],'title',m[5],'particulars',m[6]));end if;
 m:=regexp_match(p_command_text,'^prosecution charges ([A-Za-z0-9_-]+) by ([A-Za-z0-9_-]+)$','i');
 if m is not null then return jsonb_build_object('command_type','get_formal_charges','payload',jsonb_build_object('referral_ref',m[1],'prosecutor_ref',m[2]));end if;
 return null;
end $$;

create or replace function game.execute_justice_command(p_command_id uuid,p_type text,p jsonb,p_actor_id uuid)
returns jsonb language plpgsql security definer set search_path='pg_catalog','game' as $$
declare n timestamptz; person_row game.persons%rowtype; police game.police_personnel%rowtype; pro game.prosecutor_profiles%rowtype; ref game.prosecution_referrals%rowtype; review game.prosecution_reviews%rowtype; charge game.formal_charges%rowtype;
begin
 select current_game_time into n from game.simulation_state where id=1 for update;
 if n is null then return jsonb_build_object('ok',false,'code','clock_not_initialized');end if;
 if p_type='appoint_prosecutor' then
  select * into police from game.police_personnel where personnel_ref=p->>'actor_ref' and employment_status in ('active','seconded');
  select * into person_row from game.persons where person_ref=p->>'person_ref';
  if police.id is null or (p_actor_id is not null and p_actor_id<>police.id) then return jsonb_build_object('ok',false,'code','appointing_officer_not_found');end if;
  if person_row.id is null then return jsonb_build_object('ok',false,'code','person_not_found');end if;
  if exists(select 1 from game.prosecutor_profiles where person_id=person_row.id) then return jsonb_build_object('ok',false,'code','prosecutor_profile_exists');end if;
  insert into game.prosecutor_profiles(person_id,role,appointed_by_personnel_id,appointed_at_game_time)
  values(person_row.id,p->>'role',police.id,n) returning * into pro;
  return jsonb_build_object('ok',true,'prosecutor_ref',pro.prosecutor_ref,'role',pro.role,'status',pro.status);
 elsif p_type='record_prosecution_review' then
  select * into pro from game.prosecutor_profiles where prosecutor_ref=p->>'prosecutor_ref' and status='active';
  select * into ref from game.prosecution_referrals where referral_ref=p->>'referral_ref' and status='pending';
  if pro.id is null or ref.id is null then return jsonb_build_object('ok',false,'code','active_prosecutor_or_pending_referral_not_found');end if;
  if nullif(btrim(p->>'reason'),'') is null then return jsonb_build_object('ok',false,'code','review_reason_required');end if;
  insert into game.prosecution_reviews(referral_id,prosecutor_id,decision,reason,reviewed_at_game_time,source_command_id)
  values(ref.id,pro.id,p->>'decision',p->>'reason',n,p_command_id) returning * into review;
  insert into game.prosecution_review_events(review_id,event_type,prosecutor_id,event_at_game_time,reason,source_command_id)
  values(review.id,'review_recorded',pro.id,n,review.reason,p_command_id);
  update game.prosecution_referrals set status=review.decision where id=ref.id;
  insert into game.prosecution_referral_events(referral_id,event_type,actor_personnel_id,event_at_game_time,reason,source_command_id)
  values(ref.id,review.decision,ref.submitted_by_personnel_id,n,'Independent prosecutor review by '||pro.prosecutor_ref||': '||review.reason,p_command_id);
  return jsonb_build_object('ok',true,'referral_ref',ref.referral_ref,'decision',review.decision,'prosecutor_ref',pro.prosecutor_ref);
 elsif p_type='file_formal_charge' then
  select * into pro from game.prosecutor_profiles where prosecutor_ref=p->>'prosecutor_ref' and status='active';
  select * into ref from game.prosecution_referrals where referral_ref=p->>'referral_ref' and status='accepted';
  if pro.id is null or ref.id is null then return jsonb_build_object('ok',false,'code','accepted_referral_and_active_prosecutor_required');end if;
  if nullif(btrim(p->>'title'),'') is null or nullif(btrim(p->>'particulars'),'') is null or nullif(btrim(p->>'offence_code'),'') is null then return jsonb_build_object('ok',false,'code','charge_details_incomplete');end if;
  if exists(select 1 from game.formal_charges where referral_id=ref.id and count_number=(p->>'count_number')::integer) then return jsonb_build_object('ok',false,'code','charge_count_already_exists');end if;
  insert into game.formal_charges(referral_id,case_id,person_id,prosecutor_id,count_number,offence_code,charge_title,particulars,filed_at_game_time,source_command_id)
  values(ref.id,ref.case_id,ref.person_id,pro.id,(p->>'count_number')::integer,p->>'offence_code',p->>'title',p->>'particulars',n,p_command_id) returning * into charge;
  insert into game.formal_charge_events(charge_id,event_type,prosecutor_id,event_at_game_time,reason,source_command_id)
  values(charge.id,'filed',pro.id,n,'Formal charge filed',p_command_id);
  return jsonb_build_object('ok',true,'charge_ref',charge.charge_ref,'status',charge.status,'count_number',charge.count_number);
 elsif p_type='get_formal_charges' then
  select * into pro from game.prosecutor_profiles where prosecutor_ref=p->>'prosecutor_ref' and status='active';
  select * into ref from game.prosecution_referrals where referral_ref=p->>'referral_ref';
  if pro.id is null or ref.id is null then return jsonb_build_object('ok',false,'code','active_prosecutor_or_referral_not_found');end if;
  return jsonb_build_object('ok',true,'charges',coalesce((select jsonb_agg(jsonb_build_object('charge_ref',fc.charge_ref,'count_number',fc.count_number,'offence_code',fc.offence_code,'title',fc.charge_title,'particulars',fc.particulars,'status',fc.status,'filed_at',fc.filed_at_game_time) order by fc.count_number) from game.formal_charges fc where fc.referral_id=ref.id),'[]'::jsonb));
 end if;
 return jsonb_build_object('ok',false,'code','unsupported_command');
end $$;

create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path='pg_catalog','game' as $$
declare r jsonb;
begin
 r:=game.interpret_justice_command(p_command_text);
 if r is not null then return r;end if;
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
  return jsonb_set(res,'{available_commands}',(select coalesce(jsonb_agg(distinct x),'[]') from jsonb_array_elements_text(coalesce(res->'available_commands','[]')||jsonb_build_array('appoint_prosecutor','record_prosecution_review','file_formal_charge','get_formal_charges'))x),true);
 end if;
 if typ not in ('appoint_prosecutor','record_prosecution_review','file_formal_charge','get_formal_charges') then return game.execute_text_command_before_arrest_custody(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key is required';end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload)
 values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,typ,d) on conflict(idempotency_key) do nothing;
 if not found then
  select * into cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if cmd.command_text<>p_command_text or cmd.command_type<>typ or cmd.payload<>d then return jsonb_build_object('ok',false,'code','idempotency_conflict');end if;
  return coalesce(cmd.result,jsonb_build_object('ok',cmd.status='completed'))||jsonb_build_object('duplicate',true);
 end if;
 select * into cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 if typ='appoint_prosecutor' then
  select * into actor from game.police_personnel where personnel_ref=d->>'actor_ref' and employment_status in ('active','seconded');
  if actor.id is null or (p_actor_personnel_id is not null and p_actor_personnel_id<>actor.id) then res:=jsonb_build_object('ok',false,'code','actor_mismatch');
  else res:=game.execute_justice_command(cmd.id,typ,d,actor.id);end if;
 else
  res:=game.execute_justice_command(cmd.id,typ,d,null);
 end if;
 if coalesce((res->>'ok')::boolean,false) then
  res:=res||jsonb_build_object('status','completed','command_id',cmd.id);
  update game.game_commands set status='completed',result=res,completed_at=now() where id=cmd.id;
 else
  update game.game_commands set status='rejected',result=res,rejection_reason=coalesce(res->>'message','Justice command rejected'),completed_at=now() where id=cmd.id;
  res:=res||jsonb_build_object('command_id',cmd.id);
 end if;
 return res;
end $$;

revoke all on function game.interpret_justice_command(text) from public,anon,authenticated;
revoke all on function game.execute_justice_command(uuid,text,jsonb,uuid) from public,anon,authenticated;
grant execute on function game.interpret_justice_command(text) to service_role;
grant execute on function game.execute_justice_command(uuid,text,jsonb,uuid) to service_role;
revoke all on function game.interpret_text_command(text) from public,anon,authenticated;
revoke all on function game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text) to service_role;
grant execute on function game.execute_text_command(text,text,uuid,uuid) to service_role;
