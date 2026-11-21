-- BP-04 property/building/unit event capture.
-- Uses the existing canonical property_asset_events register; no parallel history table.
alter table game.property_asset_events
  add column if not exists event_ref text,
  add column if not exists actor_personnel_id uuid references game.police_personnel(id) on delete restrict;
create unique index if not exists property_asset_events_event_ref_uidx
  on game.property_asset_events(event_ref) where event_ref is not null;

create or replace function game.prevent_property_asset_event_mutation()
returns trigger language plpgsql set search_path to 'pg_catalog','game'
as $function$
begin
 raise exception 'Property asset history is append-only; record a correction event instead.';
end;
$function$;
drop trigger if exists property_asset_events_append_only on game.property_asset_events;
create trigger property_asset_events_append_only
 before update or delete on game.property_asset_events
 for each row execute function game.prevent_property_asset_event_mutation();

alter function game.interpret_property_command(text)
 rename to interpret_property_command_before_asset_event;
create or replace function game.interpret_property_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game'
as $function$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,
  $bp04event$^property event ([^[:space:]]+) ([^[:space:]]+) (inspection|condition_assessment|defect|maintenance|repair|alteration|refurbishment|construction|demolition|safety_review|utility_event|damage|other) (planned|open|in_progress|completed|cancelled|recorded|unknown) (not_applicable|low|moderate|high|critical|unknown) (unknown|[0-9]{4}-[0-9]{2}-[0-9]{2}) (unknown|[0-9]{4}-[0-9]{2}-[0-9]{2}) (unknown|[^[:space:]]+) (unknown|[^[:space:]]+) "([^"]{1,200})" "([^"]+)" "([^"]*)" "([^"]*)" (unknown|[^[:space:]]+) (unknown|[^[:space:]]+) "([^"]*)" "([^"]*)" by ([^[:space:]]+)$bp04event$,'i');
 if m is not null then
  return jsonb_build_object('command_type','property_asset_event_record','payload',jsonb_build_object(
   'property_ref',m[1],'event_ref',m[2],'event_type',lower(m[3]),
   'event_status',lower(m[4]),'severity',lower(m[5]),
   'occurred_on',case when lower(m[6])='unknown' then null else m[6] end,
   'completed_on',case when lower(m[7])='unknown' then null else m[7] end,
   'building_ref',case when lower(m[8])='unknown' then null else m[8] end,
   'unit_ref',case when lower(m[9])='unknown' then null else m[9] end,
   'subject',m[10],'description',m[11],
   'findings',nullif(m[12],''),'action_required',nullif(m[13],''),
   'responsible_organisation_ref',case when lower(m[14])='unknown' then null else m[14] end,
   'responsible_person_ref',case when lower(m[15])='unknown' then null else m[15] end,
   'source_reference',nullif(m[16],''),'source_description',nullif(m[17],''),
   'actor_ref',m[18]));
 end if;
 return game.interpret_property_command_before_asset_event(p_command_text);
end;
$function$;

alter function game.execute_property_command(uuid,text,jsonb,uuid)
 rename to execute_property_command_before_asset_event;
create or replace function game.execute_property_command(
 p_command_id uuid,p_type text,payload jsonb,p_actor_id uuid
) returns jsonb language plpgsql volatile set search_path to 'pg_catalog','game'
as $function$
declare
 v_actor game.police_personnel%rowtype;
 v_property game.properties%rowtype;
 v_building game.buildings%rowtype;
 v_unit game.building_units%rowtype;
 v_org game.organisations%rowtype;
 v_person game.persons%rowtype;
 v_existing game.property_asset_events%rowtype;
 v_event game.property_asset_events%rowtype;
 v_occurred date;
 v_completed date;
begin
 if p_type<>'property_asset_event_record' then
  return game.execute_property_command_before_asset_event(p_command_id,p_type,payload,p_actor_id);
 end if;
 select * into v_actor from game.police_personnel
  where id=p_actor_id and employment_status in ('active','seconded');
 if v_actor.id is null or v_actor.personnel_ref<>payload->>'actor_ref' then
  return jsonb_build_object('ok',false,'code','actor_mismatch');
 end if;
 if coalesce(length(btrim(payload->>'event_ref')),0) not between 4 and 100
  or coalesce(length(btrim(payload->>'subject')),0) not between 1 and 200
  or coalesce(length(btrim(payload->>'description')),0) not between 1 and 4000 then
  return jsonb_build_object('ok',false,'code','invalid_property_asset_event');
 end if;
 select * into v_property from game.properties where property_ref=payload->>'property_ref';
 if v_property.id is null then return jsonb_build_object('ok',false,'code','property_not_found'); end if;
 if nullif(payload->>'building_ref','') is not null then
  select * into v_building from game.buildings where building_ref=payload->>'building_ref';
  if v_building.id is null or v_building.property_id<>v_property.id then
   return jsonb_build_object('ok',false,'code','building_not_found_for_property');
  end if;
 end if;
 if nullif(payload->>'unit_ref','') is not null then
  if v_building.id is null then return jsonb_build_object('ok',false,'code','building_required_for_unit'); end if;
  select * into v_unit from game.building_units where unit_ref=payload->>'unit_ref';
  if v_unit.id is null or v_unit.building_id<>v_building.id then
   return jsonb_build_object('ok',false,'code','unit_not_found_for_building');
  end if;
 end if;
 if nullif(payload->>'responsible_organisation_ref','') is not null then
  select * into v_org from game.organisations where organisation_ref=payload->>'responsible_organisation_ref';
  if v_org.id is null then return jsonb_build_object('ok',false,'code','responsible_organisation_not_found'); end if;
 end if;
 if nullif(payload->>'responsible_person_ref','') is not null then
  select * into v_person from game.persons where person_ref=payload->>'responsible_person_ref';
  if v_person.id is null then return jsonb_build_object('ok',false,'code','responsible_person_not_found'); end if;
 end if;
 begin
  v_occurred:=nullif(payload->>'occurred_on','')::date;
  v_completed:=nullif(payload->>'completed_on','')::date;
 exception when others then return jsonb_build_object('ok',false,'code','invalid_property_asset_event_date'); end;
 if v_occurred is not null and v_completed is not null and v_completed<v_occurred then
  return jsonb_build_object('ok',false,'code','invalid_property_asset_event_date');
 end if;
 insert into game.property_asset_events(
  event_ref,property_id,building_id,building_unit_id,event_type,event_status,severity,
  occurred_on,completed_on,subject,description,findings,action_required,
  responsible_organisation_id,responsible_person_id,source_reference,source_description,actor_personnel_id
 ) values (
  btrim(payload->>'event_ref'),v_property.id,v_building.id,v_unit.id,
  lower(payload->>'event_type'),lower(payload->>'event_status'),lower(payload->>'severity'),
  v_occurred,v_completed,btrim(payload->>'subject'),btrim(payload->>'description'),
  nullif(payload->>'findings',''),nullif(payload->>'action_required',''),
  v_org.id,v_person.id,nullif(payload->>'source_reference',''),
  nullif(payload->>'source_description',''),v_actor.id
 ) on conflict(event_ref) where event_ref is not null do nothing returning * into v_event;
 if v_event.id is null then
  select * into v_existing from game.property_asset_events where event_ref=btrim(payload->>'event_ref');
  if v_existing.property_id=v_property.id
   and v_existing.building_id is not distinct from v_building.id
   and v_existing.building_unit_id is not distinct from v_unit.id
   and v_existing.event_type=lower(payload->>'event_type')
   and v_existing.event_status=lower(payload->>'event_status')
   and v_existing.severity=lower(payload->>'severity')
   and v_existing.occurred_on is not distinct from v_occurred
   and v_existing.completed_on is not distinct from v_completed
   and v_existing.subject=btrim(payload->>'subject')
   and v_existing.description=btrim(payload->>'description')
   and v_existing.findings is not distinct from nullif(payload->>'findings','')
   and v_existing.action_required is not distinct from nullif(payload->>'action_required','')
   and v_existing.responsible_organisation_id is not distinct from v_org.id
   and v_existing.responsible_person_id is not distinct from v_person.id
   and v_existing.source_reference is not distinct from nullif(payload->>'source_reference','')
   and v_existing.source_description is not distinct from nullif(payload->>'source_description','')
   and v_existing.actor_personnel_id=v_actor.id then
   return jsonb_build_object('ok',true,'record_type','property_asset_event','duplicate',true,'event',to_jsonb(v_existing));
  end if;
  return jsonb_build_object('ok',false,'code','property_asset_event_ref_conflict');
 end if;
 return jsonb_build_object('ok',true,'record_type','property_asset_event','event',to_jsonb(v_event));
end;
$function$;

alter function game.execute_text_command_before_runtime_chain_repair(text,text,uuid,uuid)
 rename to execute_text_command_before_property_asset_event;
create or replace function game.execute_text_command_before_runtime_chain_repair(
 p_command_text text,p_idempotency_key text,p_session_id uuid default null,
 p_actor_personnel_id uuid default null
) returns jsonb language plpgsql set search_path to 'pg_catalog','game'
as $function$
declare i jsonb; typ text; d jsonb; cmd game.game_commands%rowtype;
 res jsonb; actor game.police_personnel%rowtype;
begin
 i:=game.interpret_text_command(p_command_text);
 typ:=i->>'command_type'; d:=coalesce(i->'payload','{}'::jsonb);
 if typ='help' then
  res:=game.execute_text_command_before_property_asset_event(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  return jsonb_set(res,'{available_commands}',
   coalesce(res->'available_commands','[]'::jsonb)||jsonb_build_array('property_asset_event_record'),true);
 end if;
 if typ<>'property_asset_event_record' then
  return game.execute_text_command_before_property_asset_event(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
 end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then
  raise exception 'A unique idempotency key between 8 and 200 characters is required';
 end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload)
 values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,typ,d)
 on conflict(idempotency_key) do nothing;
 if not found then
  select * into cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if cmd.command_text<>p_command_text or cmd.command_type<>typ or cmd.payload<>d then
   return jsonb_build_object('ok',false,'code','idempotency_conflict');
  end if;
  return coalesce(cmd.result,jsonb_build_object('ok',cmd.status='completed'))||jsonb_build_object('duplicate',true);
 end if;
 select * into cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 select * into actor from game.police_personnel
  where personnel_ref=d->>'actor_ref' and employment_status in ('active','seconded');
 if actor.id is null or (p_actor_personnel_id is not null and p_actor_personnel_id<>actor.id) then
  res:=jsonb_build_object('ok',false,'code','actor_mismatch');
 else
  res:=game.execute_property_command(cmd.id,typ,d,actor.id);
 end if;
 if coalesce((res->>'ok')::boolean,false) then
  res:=res||jsonb_build_object('status','completed','command_id',cmd.id);
  update game.game_commands set status='completed',result=res,completed_at=now() where id=cmd.id;
 else
  update game.game_commands set status='rejected',result=res,
   rejection_reason=coalesce(res->>'message',res->>'code','Property asset event rejected'),
   completed_at=now() where id=cmd.id;
  res:=res||jsonb_build_object('command_id',cmd.id);
 end if;
 return res;
end;
$function$;

revoke all on function game.prevent_property_asset_event_mutation(),
 game.interpret_property_command(text),game.execute_property_command(uuid,text,jsonb,uuid),
 game.execute_text_command_before_runtime_chain_repair(text,text,uuid,uuid)
 from public,anon,authenticated;
grant execute on function game.interpret_property_command(text),
 game.execute_text_command(text,text,uuid,uuid)
 to service_role;
