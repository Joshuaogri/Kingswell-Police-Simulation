
create table game.patrol_intelligence_links (
 id uuid primary key default gen_random_uuid(),
 link_ref text not null unique default ('PIL-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12))),
 source_observation_id uuid references game.patrol_observations(id) on delete restrict,
 source_contact_id uuid references game.patrol_contacts(id) on delete restrict,
 target_incident_id uuid references game.incidents(id) on delete restrict,
 target_case_id uuid references game.cases(id) on delete restrict,
 reason text not null check (length(btrim(reason)) between 3 and 2000),
 linked_at_game_time timestamptz not null,
 actor_personnel_id uuid references game.police_personnel(id) on delete restrict,
 source_command_id uuid not null references game.game_commands(id) on delete restrict,
 created_at timestamptz not null default now(),
 constraint patrol_intelligence_links_one_source check (
  (source_observation_id is not null)::integer + (source_contact_id is not null)::integer = 1
 ),
 constraint patrol_intelligence_links_one_target check (
  (target_incident_id is not null)::integer + (target_case_id is not null)::integer = 1
 )
);
create unique index patrol_intelligence_links_observation_incident_uq
 on game.patrol_intelligence_links(source_observation_id,target_incident_id)
 where source_observation_id is not null and target_incident_id is not null;
create unique index patrol_intelligence_links_observation_case_uq
 on game.patrol_intelligence_links(source_observation_id,target_case_id)
 where source_observation_id is not null and target_case_id is not null;
create unique index patrol_intelligence_links_contact_incident_uq
 on game.patrol_intelligence_links(source_contact_id,target_incident_id)
 where source_contact_id is not null and target_incident_id is not null;
create unique index patrol_intelligence_links_contact_case_uq
 on game.patrol_intelligence_links(source_contact_id,target_case_id)
 where source_contact_id is not null and target_case_id is not null;
create index patrol_intelligence_links_incident_time_idx
 on game.patrol_intelligence_links(target_incident_id,linked_at_game_time desc)
 where target_incident_id is not null;
create index patrol_intelligence_links_case_time_idx
 on game.patrol_intelligence_links(target_case_id,linked_at_game_time desc)
 where target_case_id is not null;
create index patrol_intelligence_links_observation_time_idx
 on game.patrol_intelligence_links(source_observation_id,linked_at_game_time desc)
 where source_observation_id is not null;
create index patrol_intelligence_links_contact_time_idx
 on game.patrol_intelligence_links(source_contact_id,linked_at_game_time desc)
 where source_contact_id is not null;
alter table game.patrol_intelligence_links enable row level security;

create or replace function game.reject_patrol_intelligence_link_mutation()
returns trigger language plpgsql set search_path to ''
as $f$
begin
 raise exception 'Patrol intelligence links are append-only and cannot be changed or deleted';
end;$f$;
create trigger patrol_intelligence_links_immutable
before update or delete on game.patrol_intelligence_links
for each row execute function game.reject_patrol_intelligence_link_mutation();

create or replace function game.link_patrol_record(
 p_command_id uuid,p_source_ref text,p_target_type text,p_target_ref text,
 p_reason text,p_actor_personnel_id uuid default null
) returns jsonb
language plpgsql set search_path to ''
as $f$
declare
 v_now timestamptz; v_source_type text; v_observation_id uuid; v_contact_id uuid;
 v_incident_id uuid; v_case_id uuid; v_link_id uuid; v_link_ref text;
 v_source_label text; v_target_label text;
begin
 if p_command_id is null then raise exception 'A source command is required'; end if;
 if nullif(btrim(p_source_ref),'') is null or nullif(btrim(p_target_ref),'') is null then
  raise exception 'Source and target references are required';
 end if;
 if nullif(btrim(p_reason),'') is null or char_length(btrim(p_reason))<3 then
  raise exception 'Provide a reason of at least three characters';
 end if;
 if lower(p_target_type) not in ('incident','case') then raise exception 'Target must be an incident or case'; end if;
 select current_game_time into v_now from game.simulation_state where id=1;
 if v_now is null then raise exception 'Patrol intelligence linking requires an initialized fictional clock'; end if;
 if p_actor_personnel_id is not null and not exists(
  select 1 from game.police_personnel pp where pp.id=p_actor_personnel_id and pp.employment_status='active'
 ) then raise exception 'Actor must be an active police personnel record'; end if;
 select id into v_observation_id from game.patrol_observations where observation_ref=btrim(p_source_ref);
 if v_observation_id is not null then
  v_source_type:='observation'; v_source_label:=btrim(p_source_ref);
 else
  select id into v_contact_id from game.patrol_contacts where contact_ref=btrim(p_source_ref);
  if v_contact_id is null then raise exception 'Patrol observation/contact reference not found'; end if;
  v_source_type:='contact'; v_source_label:=btrim(p_source_ref);
 end if;
 if lower(p_target_type)='incident' then
  select id into v_incident_id from game.incidents where incident_ref=btrim(p_target_ref) for key share;
  if v_incident_id is null then raise exception 'Incident reference not found'; end if;
  v_target_label:=btrim(p_target_ref);
 else
  select id into v_case_id from game.cases where case_ref=btrim(p_target_ref) for key share;
  if v_case_id is null then raise exception 'Case reference not found'; end if;
  v_target_label:=btrim(p_target_ref);
 end if;
 if v_observation_id is not null then
  insert into game.patrol_intelligence_links(source_observation_id,target_incident_id,target_case_id,reason,linked_at_game_time,actor_personnel_id,source_command_id)
  values(v_observation_id,v_incident_id,v_case_id,btrim(p_reason),v_now,p_actor_personnel_id,p_command_id)
  on conflict do nothing returning id,link_ref into v_link_id,v_link_ref;
 else
  insert into game.patrol_intelligence_links(source_contact_id,target_incident_id,target_case_id,reason,linked_at_game_time,actor_personnel_id,source_command_id)
  values(v_contact_id,v_incident_id,v_case_id,btrim(p_reason),v_now,p_actor_personnel_id,p_command_id)
  on conflict do nothing returning id,link_ref into v_link_id,v_link_ref;
 end if;
 if v_link_id is null then
  select id,link_ref into v_link_id,v_link_ref from game.patrol_intelligence_links
  where (source_observation_id=v_observation_id or source_contact_id=v_contact_id)
   and (target_incident_id=v_incident_id or target_case_id=v_case_id);
  return jsonb_build_object('ok',true,'status','completed','duplicate',true,'link_ref',v_link_ref,
   'source_type',v_source_type,'source_ref',v_source_label,'target_type',lower(p_target_type),'target_ref',v_target_label,
   'message','This patrol record was already linked to that target; the existing link was retained.');
 end if;
 insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data)
 values('patrol_intelligence.record_linked',v_now,p_actor_personnel_id,'patrol_intelligence_link',v_link_id,
  jsonb_build_object('link_ref',v_link_ref,'source_type',v_source_type,'source_ref',v_source_label,
   'target_type',lower(p_target_type),'target_ref',v_target_label,'reason',btrim(p_reason),'command_id',p_command_id));
 return jsonb_build_object('ok',true,'status','completed','link_ref',v_link_ref,
  'source_type',v_source_type,'source_ref',v_source_label,'target_type',lower(p_target_type),'target_ref',v_target_label,
  'reason',btrim(p_reason),'linked_at_game_time',v_now,'actor_personnel_id',p_actor_personnel_id,
  'message','Patrol record linked. The original observation/contact remains unchanged.');
end;$f$;
revoke all on function game.link_patrol_record(uuid,text,text,text,text,uuid) from public,anon,authenticated;
grant execute on function game.link_patrol_record(uuid,text,text,text,text,uuid) to service_role;

alter function game.interpret_text_command(text) rename to interpret_text_command_before_link;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game'
as $f$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^link[[:space:]]+patrol[[:space:]]+record[[:space:]]+([^[:space:]]+)[[:space:]]+to[[:space:]]+(incident|case)[[:space:]]+([^[:space:]]+)[[:space:]]+because[[:space:]]+(.+)$','i');
 if m is not null then
  return jsonb_build_object('recognized',true,'command_type','link_patrol_record',
   'payload',jsonb_build_object('source_ref',m[1],'target_type',lower(m[2]),'target_ref',m[3],'reason',btrim(m[4])));
 end if;
 return game.interpret_text_command_before_link(p_command_text);
end;$f$;
revoke all on function game.interpret_text_command(text) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text) to service_role;

do $patch$
declare def text; marker text; injected text; old_help text; new_help text;
begin
 def:=pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure);
 marker:=$m$  elsif v_type='search_patrol_intelligence' then
    v_result:=game.search_patrol_intelligence(p_payload->>'query',p_payload->>'beat_ref',p_payload->>'access_ref',p_payload->>'person_ref',p_payload->>'organisation_ref',p_payload->>'incident_ref',
      case when nullif(p_payload->>'since','') is null then null else (p_payload->>'since')::timestamptz end,
      case when nullif(p_payload->>'until','') is null then null else (p_payload->>'until')::timestamptz end,100)
      || jsonb_build_object('status','completed','command_id',v_command.id);
$m$;
 injected:=$i$  elsif v_type='link_patrol_record' then
    v_result:=game.link_patrol_record(v_command.id,p_payload->>'source_ref',p_payload->>'target_type',p_payload->>'target_ref',p_payload->>'reason',p_actor_personnel_id);
$i$;
 if position(marker in def)=0 then raise exception 'Could not locate searchable patrol intelligence dispatcher branch'; end if;
 def:=replace(def,marker,marker||injected);
 old_help:='''record_patrol_contact'',''search_patrol_intelligence'')';
 new_help:='''record_patrol_contact'',''search_patrol_intelligence'',''link_patrol_record'')';
 if position(old_help in def)=0 then raise exception 'Could not locate help command list'; end if;
 def:=replace(def,old_help,new_help);
 execute def;
end;$patch$;
