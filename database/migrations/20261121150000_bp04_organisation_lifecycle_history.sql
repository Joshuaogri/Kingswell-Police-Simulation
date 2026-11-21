-- BP-04: source-backed, append-only organisation/business lifecycle history.
-- Event capture never silently changes current names, status, parentage or site records.

create table if not exists game.organisation_lifecycle_events (
 id uuid primary key default gen_random_uuid(),
 event_ref text not null unique,
 organisation_id uuid not null references game.organisations(id),
 event_type text not null check (event_type in (
  'formed','registered','trading_commenced','name_changed','trading_name_changed',
  'restructured','parent_changed','subsidiary_created','merged','acquired','relocated',
  'suspended','resumed','insolvency_started','administration_started','receivership_started',
  'closed','reopened','dissolved','deregistered','ceased_trading','corrected','other'
 )),
 occurred_on date,
 recorded_on date not null default current_date,
 prior_name text,
 resulting_name text,
 related_organisation_id uuid references game.organisations(id),
 subject text not null,
 description text not null,
 actor_person_id uuid references game.persons(id),
 source_reference text,
 source_description text not null default 'Source details not supplied.',
 event_details jsonb not null default '{}'::jsonb check(jsonb_typeof(event_details)='object'),
 created_at timestamptz not null default now(),
 constraint organisation_lifecycle_event_ref_length check(length(btrim(event_ref)) between 4 and 100),
 constraint organisation_lifecycle_subject_length check(length(btrim(subject)) between 1 and 200),
 constraint organisation_lifecycle_description_length check(length(btrim(description)) between 1 and 4000),
 constraint organisation_lifecycle_not_self_related check(related_organisation_id is null or related_organisation_id<>organisation_id)
);
create index if not exists organisation_lifecycle_events_timeline_idx
 on game.organisation_lifecycle_events(organisation_id,occurred_on,recorded_on,created_at);
create index if not exists organisation_lifecycle_events_related_idx
 on game.organisation_lifecycle_events(related_organisation_id) where related_organisation_id is not null;
alter table game.organisation_lifecycle_events enable row level security;
revoke all on game.organisation_lifecycle_events from anon,authenticated;
grant all on game.organisation_lifecycle_events to service_role;

create or replace function game.prevent_organisation_lifecycle_event_mutation()
returns trigger language plpgsql set search_path to 'pg_catalog','game'
as $function$
begin
 raise exception 'Lifecycle history is append-only; record a correction event instead.';
end;
$function$;
drop trigger if exists organisation_lifecycle_events_append_only on game.organisation_lifecycle_events;
create trigger organisation_lifecycle_events_append_only
 before update or delete on game.organisation_lifecycle_events
 for each row execute function game.prevent_organisation_lifecycle_event_mutation();

create or replace function game.get_organisation_lifecycle_history(p_organisation_ref text)
returns jsonb language sql stable set search_path to 'pg_catalog','game'
as $function$
 select jsonb_build_object(
  'organisation',to_jsonb(o),
  'events',coalesce((select jsonb_agg(jsonb_build_object(
    'event',to_jsonb(e),'related_organisation',to_jsonb(ro)
   ) order by e.occurred_on nulls last,e.recorded_on,e.created_at,e.event_ref)
   from game.organisation_lifecycle_events e
   left join game.organisations ro on ro.id=e.related_organisation_id
   where e.organisation_id=o.id),'[]'::jsonb),
  'event_count',(select count(*) from game.organisation_lifecycle_events e where e.organisation_id=o.id),
  'unknown_event_dates_are_preserved',true,
  'current_organisation_state_is_not_rewritten',true
 )
 from game.organisations o where o.organisation_ref=p_organisation_ref;
$function$;

-- Preserve the prior command handlers under internal names, then add the new
-- command at the same public entry points. Existing command types delegate unchanged.
alter function game.interpret_property_command(text) rename to interpret_property_command_before_lifecycle;
create or replace function game.interpret_property_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game'
as $function$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,
  '^organisation lifecycle event ([^[:space:]]+) ([^[:space:]]+) (formed|registered|trading_commenced|name_changed|trading_name_changed|restructured|parent_changed|subsidiary_created|merged|acquired|relocated|suspended|resumed|insolvency_started|administration_started|receivership_started|closed|reopened|dissolved|deregistered|ceased_trading|corrected|other) (unknown|[0-9]{4}-[0-9]{2}-[0-9]{2}) ([^[:space:]]+) "([^"]{1,200})" "([^"]+)" "([^"]{0,200})" "([^"]*)" by ([^[:space:]]+)$','i');
 if m is not null then
  return jsonb_build_object('command_type','organisation_lifecycle_event_record',
   'payload',jsonb_build_object(
    'organisation_ref',m[1],'event_ref',m[2],'event_type',lower(m[3]),
    'occurred_on',case when lower(m[4])='unknown' then null else m[4] end,
    'related_organisation_ref',case when lower(m[5])='unknown' then null else m[5] end,
    'subject',m[6],'description',m[7],'source_reference',nullif(m[8],''),
    'source_description',nullif(m[9],''),'actor_ref',m[10]));
 end if;
 return game.interpret_property_command_before_lifecycle(p_command_text);
end;
$function$;

alter function game.execute_property_command(uuid,text,jsonb,uuid)
 rename to execute_property_command_before_lifecycle;
create or replace function game.execute_property_command(
 p_command_id uuid,p_type text,payload jsonb,p_actor_id uuid
) returns jsonb language plpgsql volatile set search_path to 'pg_catalog','game'
as $function$
declare
 v_personnel game.police_personnel%rowtype;
 v_org game.organisations%rowtype;
 v_related_org game.organisations%rowtype;
 v_existing game.organisation_lifecycle_events%rowtype;
 v_event_type text;
 v_occurred_on date;
begin
 if p_type<>'organisation_lifecycle_event_record' then
  return game.execute_property_command_before_lifecycle(p_command_id,p_type,payload,p_actor_id);
 end if;
 select * into v_personnel from game.police_personnel
  where id=p_actor_id and employment_status in ('active','seconded');
 if v_personnel.id is null or v_personnel.personnel_ref<>payload->>'actor_ref' then
  return jsonb_build_object('ok',false,'code','actor_mismatch');
 end if;
 if coalesce(length(btrim(payload->>'event_ref')),0) not between 4 and 100
  or coalesce(length(btrim(payload->>'subject')),0) not between 1 and 200
  or coalesce(length(btrim(payload->>'description')),0) not between 1 and 4000 then
  return jsonb_build_object('ok',false,'code','invalid_lifecycle_event');
 end if;
 v_event_type:=lower(btrim(payload->>'event_type'));
 if v_event_type not in (
  'formed','registered','trading_commenced','name_changed','trading_name_changed',
  'restructured','parent_changed','subsidiary_created','merged','acquired','relocated',
  'suspended','resumed','insolvency_started','administration_started','receivership_started',
  'closed','reopened','dissolved','deregistered','ceased_trading','corrected','other'
 ) then return jsonb_build_object('ok',false,'code','invalid_lifecycle_event_type'); end if;
 select * into v_org from game.organisations where organisation_ref=payload->>'organisation_ref';
 if v_org.id is null then
  return jsonb_build_object('ok',false,'code','organisation_not_found',
   'organisation_ref',payload->>'organisation_ref');
 end if;
 if nullif(payload->>'related_organisation_ref','') is not null then
  select * into v_related_org from game.organisations
   where organisation_ref=payload->>'related_organisation_ref';
  if v_related_org.id is null or v_related_org.id=v_org.id then
   return jsonb_build_object('ok',false,'code','related_organisation_not_found_or_invalid');
  end if;
 end if;
 if nullif(payload->>'occurred_on','') is null then v_occurred_on:=null;
 else
  begin v_occurred_on:=(payload->>'occurred_on')::date;
  exception when others then return jsonb_build_object('ok',false,'code','invalid_event_date'); end;
 end if;
 insert into game.organisation_lifecycle_events(
  event_ref,organisation_id,event_type,occurred_on,recorded_on,related_organisation_id,subject,description,
  actor_person_id,source_reference,source_description
 ) values(
  btrim(payload->>'event_ref'),v_org.id,v_event_type,v_occurred_on,current_date,v_related_org.id,
  btrim(payload->>'subject'),btrim(payload->>'description'),v_personnel.person_id,
  nullif(btrim(payload->>'source_reference'),''),coalesce(nullif(btrim(payload->>'source_description'),''),'Source details not supplied.')
 ) on conflict(event_ref) do nothing;
 if not found then
  select * into v_existing from game.organisation_lifecycle_events
   where event_ref=btrim(payload->>'event_ref');
  if v_existing.organisation_id=v_org.id and v_existing.event_type=v_event_type
   and v_existing.occurred_on is not distinct from v_occurred_on
   and v_existing.subject=btrim(payload->>'subject')
   and v_existing.description=btrim(payload->>'description')
   and v_existing.related_organisation_id is not distinct from v_related_org.id
   and v_existing.actor_person_id=v_personnel.person_id
   and v_existing.source_reference is not distinct from nullif(btrim(payload->>'source_reference'),'')
   and v_existing.source_description is not distinct from
    coalesce(nullif(btrim(payload->>'source_description'),''),'Source details not supplied.') then
   return jsonb_build_object('ok',true,'record_type','organisation_lifecycle_event',
    'event_ref',v_existing.event_ref,'event',to_jsonb(v_existing),'duplicate',true);
  end if;
  return jsonb_build_object('ok',false,'code','event_ref_conflict');
 end if;
 select * into v_existing from game.organisation_lifecycle_events
  where event_ref=btrim(payload->>'event_ref');
 return jsonb_build_object('ok',true,'record_type','organisation_lifecycle_event',
  'event_ref',v_existing.event_ref,'event',to_jsonb(v_existing));
end;
$function$;


-- Route the new command through the existing command audit/idempotency and actor-validation chain.
alter function game.execute_text_command_before_runtime_chain_repair(text,text,uuid,uuid)
 rename to execute_text_command_before_organisation_lifecycle;
create or replace function game.execute_text_command_before_runtime_chain_repair(
 p_command_text text,p_idempotency_key text,p_session_id uuid default null,
 p_actor_personnel_id uuid default null
) returns jsonb language plpgsql set search_path to 'pg_catalog','game'
as $function$
declare
 interpreted jsonb;
 command_type text;
 command_payload jsonb;
 command_row game.game_commands%rowtype;
 actor game.police_personnel%rowtype;
 result jsonb;
begin
 interpreted:=game.interpret_text_command(p_command_text);
 command_type:=interpreted->>'command_type';
 command_payload:=coalesce(interpreted->'payload','{}'::jsonb);
 if command_type='help' then
  result:=game.execute_text_command_before_organisation_lifecycle(
   p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  return jsonb_set(result,'{available_commands}',
   coalesce(result->'available_commands','[]'::jsonb)||
   jsonb_build_array('organisation_lifecycle_event_record'),true);
 end if;
 if command_type<>'organisation_lifecycle_event_record' then
  return game.execute_text_command_before_organisation_lifecycle(
   p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
 end if;
 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then
  raise exception 'Command text must contain between 1 and 4000 characters';
 end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then
  raise exception 'A unique idempotency key between 8 and 200 characters is required';
 end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,
  command_text,command_type,payload)
 values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,
  command_type,command_payload)
 on conflict(idempotency_key) do nothing;
 if not found then
  select * into command_row from game.game_commands
   where idempotency_key=p_idempotency_key for update;
  if command_row.command_text<>p_command_text
   or command_row.command_type<>command_type
   or command_row.payload<>command_payload then
   return jsonb_build_object('ok',false,'code','idempotency_conflict');
  end if;
  return coalesce(command_row.result,
   jsonb_build_object('ok',command_row.status='completed'))||
   jsonb_build_object('duplicate',true);
 end if;
 select * into command_row from game.game_commands
  where idempotency_key=p_idempotency_key for update;
 select * into actor from game.police_personnel
  where personnel_ref=command_payload->>'actor_ref'
   and employment_status in ('active','seconded');
 if actor.id is null or
  (p_actor_personnel_id is not null and p_actor_personnel_id<>actor.id) then
  result:=jsonb_build_object('ok',false,'code','actor_mismatch',
   'message','The named command actor must match active or seconded personnel.');
 else
  result:=game.execute_property_command(command_row.id,command_type,
   command_payload,actor.id);
 end if;
 if coalesce((result->>'ok')::boolean,false) then
  result:=result||jsonb_build_object('status','completed','command_id',command_row.id);
  update game.game_commands set status='completed',result=result,completed_at=now()
   where id=command_row.id;
 else
  update game.game_commands set status='rejected',result=result,
   rejection_reason=coalesce(result->>'message',result->>'code','Lifecycle command rejected'),
   completed_at=now() where id=command_row.id;
  result:=result||jsonb_build_object('command_id',command_row.id);
 end if;
 return result;
end;
$function$;

-- Enrich existing dossiers with the same authoritative lifecycle timeline.
alter function game.get_organisation_record(text) rename to get_organisation_record_before_lifecycle;
create or replace function game.get_organisation_record(p_organisation_ref text)
returns jsonb language sql stable set search_path to 'pg_catalog','game'
as $function$
 select case when base_record is null then null else
  base_record || jsonb_build_object('lifecycle_history',game.get_organisation_lifecycle_history(p_organisation_ref))
 end
 from (select game.get_organisation_record_before_lifecycle(p_organisation_ref) as base_record) q;
$function$;

alter function game.get_business_record(text) rename to get_business_record_before_lifecycle;
create or replace function game.get_business_record(p_business_number text)
returns jsonb language sql stable set search_path to 'pg_catalog','game'
as $function$
 select case when base_record is null then null else
  base_record || jsonb_build_object('lifecycle_history',
   game.get_organisation_lifecycle_history(o.organisation_ref))
 end
 from game.business_profiles bp
 join game.organisations o on o.id=bp.organisation_id
 cross join lateral (select game.get_business_record_before_lifecycle(p_business_number) as base_record) q
 where bp.business_number=p_business_number;
$function$;

-- Keep lifecycle read/write helpers private to the game runtime service.
revoke all on function game.get_organisation_lifecycle_history(text),
 game.interpret_property_command(text),
 game.execute_property_command(uuid,text,jsonb,uuid),
 game.execute_text_command_before_runtime_chain_repair(text,text,uuid,uuid),
 game.get_organisation_record(text),
 game.get_business_record(text),
 game.prevent_organisation_lifecycle_event_mutation()
from public,anon,authenticated;
grant execute on function game.get_organisation_lifecycle_history(text),
 game.interpret_property_command(text),
 game.execute_property_command(uuid,text,jsonb,uuid),
 game.execute_text_command_before_runtime_chain_repair(text,text,uuid,uuid),
 game.get_organisation_record(text),
 game.get_business_record(text),
 game.prevent_organisation_lifecycle_event_mutation()
to service_role;
