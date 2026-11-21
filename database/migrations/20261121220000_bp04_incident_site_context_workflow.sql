-- BP-04: connect canonical organisation premises to incident location context.
-- Incident-location associations must match the incident's canonical property;
-- related-site associations are explicit and never imply the incident occurred there.
create table game.incident_site_associations (
 id uuid primary key default gen_random_uuid(),
 association_ref text not null unique default ('KNG-ISA-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12))),
 incident_id uuid not null references game.incidents(id) on delete restrict,
 organisation_location_id uuid not null references game.organisation_locations(id) on delete restrict,
 relation_type text not null check(relation_type in ('incident_location','related_site')),
 reason text not null check(length(btrim(reason)) between 3 and 2000),
 recorded_by_personnel_id uuid not null references game.police_personnel(id) on delete restrict,
 recorded_at_game_time timestamptz not null,
 source_command_id uuid references game.game_commands(id) on delete restrict,
 created_at timestamptz not null default now(),
 unique(incident_id,organisation_location_id,relation_type)
);
create index incident_site_associations_incident_idx on game.incident_site_associations(incident_id,relation_type);
create index incident_site_associations_site_idx on game.incident_site_associations(organisation_location_id);
alter table game.incident_site_associations enable row level security;
revoke all on game.incident_site_associations from public,anon,authenticated;
grant select,insert on game.incident_site_associations to service_role;

create or replace function game.reject_incident_site_association_mutation()
returns trigger language plpgsql set search_path to 'pg_catalog','game'
as $$ begin raise exception 'Incident site association history is append-only'; end $$;
create trigger incident_site_associations_append_only
before update or delete on game.incident_site_associations
for each row execute function game.reject_incident_site_association_mutation();

create or replace function game.record_incident_site_association(
 p_incident_ref text,p_site_ref text,p_relation_type text,p_reason text,p_actor_ref text,p_command_id uuid
) returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare
 v_incident game.incidents%rowtype; v_site game.organisation_site_dossiers%rowtype;
 v_actor game.police_personnel%rowtype; v_clock timestamptz;
 v_existing game.incident_site_associations%rowtype; v_assoc game.incident_site_associations%rowtype;
begin
 select * into v_incident from game.incidents where incident_ref=btrim(p_incident_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','incident_not_found','message','Incident reference not found.'); end if;
 select * into v_site from game.organisation_site_dossiers where site_ref=btrim(p_site_ref);
 if not found or v_site.organisation_location_id is null then
  return jsonb_build_object('ok',false,'code','site_not_found','message','Canonical organisation site reference not found.');
 end if;
 if p_relation_type not in ('incident_location','related_site') then
  return jsonb_build_object('ok',false,'code','invalid_relation','message','Relation must be incident_location or related_site.');
 end if;
 if p_relation_type='incident_location' and v_incident.location_property_id is distinct from v_site.property_id then
  return jsonb_build_object('ok',false,'code','location_mismatch','message','An incident-location site must belong to the incident’s recorded canonical property. Use related_site if it is contextual rather than the incident location.');
 end if;
 select * into v_actor from game.police_personnel
 where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found then return jsonb_build_object('ok',false,'code','actor_unavailable','message','The acting officer must be active or seconded.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional game clock before recording incident-site context.'); end if;
 if length(btrim(coalesce(p_reason,''))) not between 3 and 2000 then
  return jsonb_build_object('ok',false,'code','invalid_reason','message','A reason between 3 and 2000 characters is required.');
 end if;
 select * into v_existing from game.incident_site_associations
 where incident_id=v_incident.id and organisation_location_id=v_site.organisation_location_id and relation_type=p_relation_type;
 if found then return jsonb_build_object('ok',true,'duplicate',true,'association_ref',v_existing.association_ref,
  'incident_ref',v_incident.incident_ref,'site_ref',v_site.site_ref,'relation_type',p_relation_type,
  'message','This incident-site association already exists.'); end if;
 insert into game.incident_site_associations(incident_id,organisation_location_id,relation_type,reason,
  recorded_by_personnel_id,recorded_at_game_time,source_command_id)
 values(v_incident.id,v_site.organisation_location_id,p_relation_type,btrim(p_reason),v_actor.id,v_clock,p_command_id)
 returning * into v_assoc;
 return jsonb_build_object('ok',true,'association_ref',v_assoc.association_ref,'incident_ref',v_incident.incident_ref,
  'site_ref',v_site.site_ref,'relation_type',p_relation_type,'game_time',v_clock,
  'message','Canonical premises site linked to incident context.');
end $$;

create or replace function game.get_incident_site_context(p_incident_ref text)
returns jsonb language plpgsql stable set search_path to 'pg_catalog','game' as $$
declare v_incident game.incidents%rowtype; v_rows jsonb;
begin
 select * into v_incident from game.incidents where incident_ref=btrim(p_incident_ref);
 if not found then return jsonb_build_object('ok',false,'code','incident_not_found','message','Incident reference not found.'); end if;
 select coalesce(jsonb_agg(jsonb_build_object(
  'association_ref',a.association_ref,'site_ref',d.site_ref,'organisation_ref',o.organisation_ref,
  'organisation_name',o.name,'property_ref',p.property_ref,'address_line',p.address_line,
  'relation_type',a.relation_type,'reason',a.reason,'recorded_by',pp.personnel_ref,
  'recorded_at_game_time',a.recorded_at_game_time
 ) order by case a.relation_type when 'incident_location' then 0 else 1 end,a.created_at),'[]'::jsonb)
 into v_rows
 from game.incident_site_associations a
 join game.organisation_locations ol on ol.id=a.organisation_location_id
 join game.organisation_site_dossiers d on d.organisation_location_id=ol.id
 join game.organisations o on o.id=ol.organisation_id
 join game.properties p on p.id=ol.property_id
 join game.police_personnel pp on pp.id=a.recorded_by_personnel_id
 where a.incident_id=v_incident.id;
 return jsonb_build_object('ok',true,'incident_ref',v_incident.incident_ref,
  'canonical_location_property_id',v_incident.location_property_id,
  'count',jsonb_array_length(v_rows),'sites',v_rows);
end $$;

alter function game.interpret_text_command(text) rename to interpret_text_command_before_incident_site_context;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game' as $$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^incident site link ([^[:space:]]+) ([^[:space:]]+) relation (incident_location|related_site) because "([^"]+)" by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','record_incident_site_association',
  'payload',jsonb_build_object('incident_ref',m[1],'site_ref',m[2],'relation_type',lower(m[3]),'reason',m[4],'actor_ref',m[5])); end if;
 m:=regexp_match(t,'^incident site context ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','get_incident_site_context',
  'payload',jsonb_build_object('incident_ref',m[1])); end if;
 return game.interpret_text_command_before_incident_site_context(p_command_text);
end $$;

alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_incident_site_context;
create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare v_i jsonb; v_type text; v_payload jsonb; v_cmd game.game_commands%rowtype;
 v_result jsonb; v_actor game.police_personnel%rowtype;
begin
 v_i:=game.interpret_text_command(p_command_text); v_type:=v_i->>'command_type'; v_payload:=coalesce(v_i->'payload','{}'::jsonb);
 if coalesce((v_i->>'recognized')::boolean,false)=false or v_type not in ('record_incident_site_association','get_incident_site_context') then
  v_result:=game.execute_text_command_before_incident_site_context(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  if v_type='help' and coalesce((v_result->>'ok')::boolean,false) then
   return jsonb_set(v_result,'{available_commands}',coalesce(v_result->'available_commands','[]'::jsonb)||
    jsonb_build_array('record_incident_site_association','get_incident_site_context'));
  end if;
  return v_result;
 end if;
 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then raise exception 'Command text must contain between 1 and 4000 characters'; end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key between 8 and 200 characters is required'; end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload)
 values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload)
 on conflict(idempotency_key) do nothing;
 if not found then
  select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if v_cmd.command_text<>p_command_text or v_cmd.command_type<>v_type or v_cmd.payload<>v_payload then
   return jsonb_build_object('ok',false,'code','idempotency_conflict','message','This command key was already used for a different command.','command_id',v_cmd.id);
  end if;
  return coalesce(v_cmd.result,jsonb_build_object('ok',v_cmd.status='completed','status',v_cmd.status,'command_id',v_cmd.id))||jsonb_build_object('duplicate',true);
 end if;
 select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 if v_type='record_incident_site_association' then
  select * into v_actor from game.police_personnel where personnel_ref=btrim(v_payload->>'actor_ref');
  if not found or (p_actor_personnel_id is not null and p_actor_personnel_id<>v_actor.id) then
   v_result:=jsonb_build_object('ok',false,'code','actor_mismatch','message','The command actor must match the named police personnel record.');
  else
   v_result:=game.record_incident_site_association(v_payload->>'incident_ref',v_payload->>'site_ref',
    v_payload->>'relation_type',v_payload->>'reason',v_payload->>'actor_ref',v_cmd.id);
  end if;
 else v_result:=game.get_incident_site_context(v_payload->>'incident_ref'); end if;
 if coalesce((v_result->>'ok')::boolean,false) then
  v_result:=v_result||jsonb_build_object('status','completed','command_id',v_cmd.id);
  update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_cmd.id;
 else
  update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Incident-site command rejected.'),result=v_result,completed_at=now() where id=v_cmd.id;
  v_result:=v_result||jsonb_build_object('command_id',v_cmd.id);
 end if;
 return v_result;
end $$;

revoke all on function game.record_incident_site_association(text,text,text,text,text,uuid),
 game.get_incident_site_context(text),game.interpret_text_command(text),
 game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.record_incident_site_association(text,text,text,text,text,uuid),
 game.get_incident_site_context(text),game.interpret_text_command(text),
 game.execute_text_command(text,text,uuid,uuid) to service_role;
