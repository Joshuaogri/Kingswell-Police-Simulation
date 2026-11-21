-- BP-04 property-interest write, closure and history workflows.
-- All holder identities resolve to existing canonical Kingswell people or organisations.

alter table game.property_interest_records
 add column if not exists source_reference text,
 add column if not exists recorded_by_personnel_id uuid references game.police_personnel(id) on delete restrict,
 add column if not exists command_id uuid references game.game_commands(id) on delete restrict,
 add column if not exists updated_at timestamptz not null default now();

create table if not exists game.property_interest_events (
 id uuid primary key default gen_random_uuid(),
 event_ref text not null unique,
 property_interest_id uuid not null references game.property_interest_records(id) on delete restrict,
 event_type text not null check(event_type in ('recorded','ended','corrected','other')),
 occurred_on date,
 recorded_on date not null default current_date,
 actor_person_id uuid references game.persons(id) on delete restrict,
 command_id uuid references game.game_commands(id) on delete restrict,
 source_reference text,
 source_description text,
 event_details jsonb not null default '{}'::jsonb check(jsonb_typeof(event_details)='object'),
 created_at timestamptz not null default now()
);
create index if not exists property_interest_events_interest_date_idx
 on game.property_interest_events(property_interest_id,occurred_on,recorded_on,created_at);

create or replace function game.reject_property_interest_event_mutation()
returns trigger language plpgsql set search_path to 'pg_catalog','game' as $function$
begin
 raise exception 'Property interest events are append-only; record a correction event instead';
end;
$function$;
drop trigger if exists property_interest_events_append_only on game.property_interest_events;
create trigger property_interest_events_append_only
 before update or delete on game.property_interest_events
 for each row execute function game.reject_property_interest_event_mutation();

create or replace function game.interpret_bp04_property_interest_command(p_command_text text)
returns jsonb language plpgsql immutable
set search_path to 'pg_catalog','game'
as $function$
declare v_text text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(v_text,
  '^property interest record ([^[:space:]]+) (registered_owner|beneficial_owner|freeholder|leaseholder|landlord|mortgagee|property_manager|receiver|other) (person|organisation) ([^[:space:]]+) (unknown|[0-9]+([.][0-9]+)?) (unknown|[0-9]{4}-[0-9]{2}-[0-9]{2}) (unknown|[0-9]{4}-[0-9]{2}-[0-9]{2}) (unknown|[^[:space:]]+) (unknown|[^[:space:]]+) "([^"]+)" "([^"]*)" by ([^[:space:]]+)$','i');
 if m is not null then
  return jsonb_build_object('command_type','property_interest_record','payload',jsonb_build_object(
   'property_ref',m[1],'interest_type',lower(m[2]),'holder_type',lower(m[3]),
   'holder_ref',m[4],'ownership_share_pct',case when lower(m[5])='unknown' then null else m[5] end,
   'valid_from',case when lower(m[7])='unknown' then null else m[7] end,
   'valid_to',case when lower(m[8])='unknown' then null else m[8] end,
   'title_reference',case when lower(m[9])='unknown' then null else m[9] end,
   'source_reference',case when lower(m[10])='unknown' then null else m[10] end,
   'source_description',m[11],'notes',m[12],'actor_ref',m[13]));
 end if;
 m:=regexp_match(v_text,
  '^property interest end ([^[:space:]]+) (registered_owner|beneficial_owner|freeholder|leaseholder|landlord|mortgagee|property_manager|receiver|other) (person|organisation) ([^[:space:]]+) ([0-9]{4}-[0-9]{2}-[0-9]{2}) "([^"]+)" (unknown|[^[:space:]]+) "([^"]+)" by ([^[:space:]]+)$','i');
 if m is not null then
  return jsonb_build_object('command_type','property_interest_end','payload',jsonb_build_object(
   'property_ref',m[1],'interest_type',lower(m[2]),'holder_type',lower(m[3]),
   'holder_ref',m[4],'valid_to',m[5],'reason',m[6],
   'source_reference',case when lower(m[7])='unknown' then null else m[7] end,
   'source_description',m[8],'actor_ref',m[9]));
 end if;
 m:=regexp_match(v_text,'^property interest history ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then
  return jsonb_build_object('command_type','property_interest_history_get',
   'payload',jsonb_build_object('property_ref',m[1],'actor_ref',m[2]));
 end if;
 return '{}'::jsonb;
end;
$function$;

create or replace function game.record_property_interest(p_command_id uuid,p_payload jsonb,p_actor_id uuid)
returns jsonb language plpgsql volatile
set search_path to 'pg_catalog','game'
as $function$
declare
 v_actor game.police_personnel%rowtype; v_property game.properties%rowtype;
 v_person game.persons%rowtype; v_org game.organisations%rowtype;
 v_existing game.property_interest_records%rowtype; v_interest game.property_interest_records%rowtype;
 v_share numeric; v_from date; v_to date; v_details jsonb; v_event_ref text;
begin
 select * into v_actor from game.police_personnel where id=p_actor_id
  and employment_status in ('active','seconded');
 if v_actor.id is null or v_actor.personnel_ref<>p_payload->>'actor_ref' then
  return jsonb_build_object('ok',false,'code','actor_mismatch');
 end if;
 select * into v_property from game.properties where property_ref=p_payload->>'property_ref';
 if v_property.id is null then return jsonb_build_object('ok',false,'code','property_not_found'); end if;
 if p_payload->>'holder_type'='person' then
  select * into v_person from game.persons where person_ref=p_payload->>'holder_ref';
  if v_person.id is null then return jsonb_build_object('ok',false,'code','interest_holder_not_found'); end if;
 elsif p_payload->>'holder_type'='organisation' then
  select * into v_org from game.organisations where organisation_ref=p_payload->>'holder_ref';
  if v_org.id is null then return jsonb_build_object('ok',false,'code','interest_holder_not_found'); end if;
 else
  return jsonb_build_object('ok',false,'code','invalid_interest_holder_type');
 end if;
 begin
  v_share:=nullif(p_payload->>'ownership_share_pct','')::numeric;
  v_from:=nullif(p_payload->>'valid_from','')::date;
  v_to:=nullif(p_payload->>'valid_to','')::date;
 exception when others then
  return jsonb_build_object('ok',false,'code','invalid_interest_value');
 end;
 if (v_share is not null and (v_share<=0 or v_share>100))
  or (v_from is not null and v_to is not null and v_to<v_from) then
  return jsonb_build_object('ok',false,'code','invalid_interest_value');
 end if;
 v_details:=jsonb_build_object('recording_notes',coalesce(p_payload->>'notes',''),
  'recorded_through','BP-04 property interest command');
 select * into v_existing from game.property_interest_records
 where property_id=v_property.id
  and holder_person_id is not distinct from case when p_payload->>'holder_type'='person' then v_person.id else null end
  and holder_organisation_id is not distinct from case when p_payload->>'holder_type'='organisation' then v_org.id else null end
  and interest_type=p_payload->>'interest_type'
  and ownership_share_pct is not distinct from v_share
  and valid_from is not distinct from v_from and valid_to is not distinct from v_to
  and title_reference is not distinct from nullif(p_payload->>'title_reference','')
  and source_reference is not distinct from nullif(p_payload->>'source_reference','')
  and source_description is not distinct from nullif(p_payload->>'source_description','')
  and interest_details=v_details
 limit 1;
 if v_existing.id is not null then
  return jsonb_build_object('ok',true,'record_type','property_interest','duplicate',true,
   'record',to_jsonb(v_existing));
 end if;
 begin
  insert into game.property_interest_records(
   property_id,holder_person_id,holder_organisation_id,interest_type,ownership_share_pct,
   valid_from,valid_to,title_reference,source_description,interest_details,
   source_reference,recorded_by_personnel_id,command_id
  ) values (
   v_property.id,case when p_payload->>'holder_type'='person' then v_person.id else null end,
   case when p_payload->>'holder_type'='organisation' then v_org.id else null end,
   p_payload->>'interest_type',v_share,v_from,v_to,
   nullif(p_payload->>'title_reference',''),p_payload->>'source_description',v_details,
   nullif(p_payload->>'source_reference',''),v_actor.id,p_command_id
  ) returning * into v_interest;
 exception when unique_violation then
  return jsonb_build_object('ok',false,'code','current_property_interest_conflict',
   'message','A current interest for this property, holder and interest type already exists with different details.');
 end;
 v_event_ref:='KNG-PI-REC-'||replace(p_command_id::text,'-','');
 insert into game.property_interest_events(event_ref,property_interest_id,event_type,actor_person_id,
  command_id,source_reference,source_description,event_details)
 values(v_event_ref,v_interest.id,'recorded',v_actor.person_id,p_command_id,
  nullif(p_payload->>'source_reference',''),p_payload->>'source_description',
  jsonb_build_object('property_ref',v_property.property_ref,'interest_type',v_interest.interest_type,
   'holder_type',p_payload->>'holder_type','holder_ref',p_payload->>'holder_ref',
   'valid_from',v_from,'valid_to',v_to,'title_reference',v_interest.title_reference));
 return jsonb_build_object('ok',true,'record_type','property_interest','record',to_jsonb(v_interest),
  'event_ref',v_event_ref);
end;
$function$;

create or replace function game.end_property_interest(p_command_id uuid,p_payload jsonb,p_actor_id uuid)
returns jsonb language plpgsql volatile
set search_path to 'pg_catalog','game'
as $function$
declare
 v_actor game.police_personnel%rowtype; v_property game.properties%rowtype;
 v_person game.persons%rowtype; v_org game.organisations%rowtype;
 v_interest game.property_interest_records%rowtype; v_end date; v_event_ref text;
begin
 select * into v_actor from game.police_personnel where id=p_actor_id
  and employment_status in ('active','seconded');
 if v_actor.id is null or v_actor.personnel_ref<>p_payload->>'actor_ref' then
  return jsonb_build_object('ok',false,'code','actor_mismatch');
 end if;
 select * into v_property from game.properties where property_ref=p_payload->>'property_ref';
 if v_property.id is null then return jsonb_build_object('ok',false,'code','property_not_found'); end if;
 if p_payload->>'holder_type'='person' then
  select * into v_person from game.persons where person_ref=p_payload->>'holder_ref';
  if v_person.id is null then return jsonb_build_object('ok',false,'code','interest_holder_not_found'); end if;
 else
  select * into v_org from game.organisations where organisation_ref=p_payload->>'holder_ref';
  if v_org.id is null then return jsonb_build_object('ok',false,'code','interest_holder_not_found'); end if;
 end if;
 begin v_end:=(p_payload->>'valid_to')::date;
 exception when others then return jsonb_build_object('ok',false,'code','invalid_interest_end_date'); end;
 select * into v_interest from game.property_interest_records
 where property_id=v_property.id
  and interest_type=p_payload->>'interest_type'
  and holder_person_id is not distinct from case when p_payload->>'holder_type'='person' then v_person.id else null end
  and holder_organisation_id is not distinct from case when p_payload->>'holder_type'='organisation' then v_org.id else null end
  and valid_to is null
 for update;
 if v_interest.id is null then
  return jsonb_build_object('ok',false,'code','current_interest_not_found');
 end if;
 if v_interest.valid_from is not null and v_end<v_interest.valid_from then
  return jsonb_build_object('ok',false,'code','invalid_interest_end_date');
 end if;
 update game.property_interest_records set valid_to=v_end,updated_at=now() where id=v_interest.id;
 v_interest.valid_to:=v_end;
 v_event_ref:='KNG-PI-END-'||replace(p_command_id::text,'-','');
 insert into game.property_interest_events(event_ref,property_interest_id,event_type,occurred_on,
  actor_person_id,command_id,source_reference,source_description,event_details)
 values(v_event_ref,v_interest.id,'ended',v_end,v_actor.person_id,p_command_id,
  nullif(p_payload->>'source_reference',''),p_payload->>'source_description',
  jsonb_build_object('property_ref',v_property.property_ref,'interest_type',v_interest.interest_type,
   'holder_type',p_payload->>'holder_type','holder_ref',p_payload->>'holder_ref',
   'reason',p_payload->>'reason'));
 return jsonb_build_object('ok',true,'record_type','property_interest','record',to_jsonb(v_interest),
  'event_ref',v_event_ref);
end;
$function$;

create or replace function game.get_property_interest_history(p_property_ref text)
returns jsonb language sql stable
set search_path to 'pg_catalog','game'
as $function$
 select jsonb_build_object(
  'property',jsonb_build_object('property_ref',p.property_ref,'address',p.address_line),
  'interest_count',(select count(*) from game.property_interest_records i where i.property_id=p.id),
  'interests',coalesce((select jsonb_agg(jsonb_build_object(
    'interest',to_jsonb(i),
    'holder',case when i.holder_person_id is not null
      then jsonb_build_object('type','person','ref',pn.person_ref,'name',pn.full_name)
      else jsonb_build_object('type','organisation','ref',o.organisation_ref,'name',o.name) end,
    'events',coalesce((select jsonb_agg(to_jsonb(e) order by e.occurred_on nulls first,e.recorded_on,e.created_at)
      from game.property_interest_events e where e.property_interest_id=i.id),'[]'::jsonb)
   ) order by i.valid_from nulls first,i.created_at)
   from game.property_interest_records i
   left join game.persons pn on pn.id=i.holder_person_id
   left join game.organisations o on o.id=i.holder_organisation_id
   where i.property_id=p.id),'[]'::jsonb),
  'history_status',case when exists(select 1 from game.property_interest_events e
    join game.property_interest_records i on i.id=e.property_interest_id where i.property_id=p.id)
    then 'interest_events_recorded' else 'no_interest_events_recorded' end)
 from game.properties p where p.property_ref=p_property_ref;
$function$;

create or replace function game.execute_text_command(
 p_command_text text,p_idempotency_key text,p_session_id uuid default null,
 p_actor_personnel_id uuid default null
) returns jsonb
language plpgsql
set search_path to 'pg_catalog','game'
as $function$
declare
 m text[]; v_type text; v_payload jsonb; v_interpreted jsonb; v_cmd game.game_commands%rowtype;
 v_actor game.police_personnel%rowtype; v_result jsonb;
begin
 -- BP-04 property-interest commands have their own stable parser.
 v_interpreted:=game.interpret_bp04_property_interest_command(p_command_text);
 if v_interpreted->>'command_type' is not null then
  v_type:=v_interpreted->>'command_type';
  v_payload:=v_interpreted->'payload';
 else
  -- Property-event commands use the existing generic parser extension.
  v_payload:=game.interpret_text_command(p_command_text)->'payload';
  if game.interpret_text_command(p_command_text)->>'command_type'='property_asset_event_record' then
   v_type:='property_asset_event_record';
  end if;
 end if;
 if v_type is null then
 m:=regexp_match(btrim(coalesce(p_command_text,'')),
  '^scene premises set ([^[:space:]]+) ([^[:space:]]+) (unknown|[^[:space:]]+) (unknown|[^[:space:]]+) because "([^"]+)" by ([^[:space:]]+)$','i');
 if m is not null then
  v_type:='scene_premises_set';
  v_payload:=jsonb_build_object('scene_ref',m[1],'property_ref',m[2],
   'building_ref',m[3],'unit_ref',m[4],'reason',m[5],'actor_ref',m[6]);
 else
  m:=regexp_match(btrim(coalesce(p_command_text,'')),
   '^scene premises get ([^[:space:]]+) by ([^[:space:]]+)$','i');
  if m is not null then
   v_type:='scene_premises_get';
   v_payload:=jsonb_build_object('scene_ref',m[1],'actor_ref',m[2]);
  else
   m:=regexp_match(btrim(coalesce(p_command_text,'')),
    '^search premises set ([^[:space:]]+) (unknown|[^[:space:]]+) (unknown|[^[:space:]]+) because "([^"]+)" by ([^[:space:]]+)$','i');
   if m is not null then
    v_type:='search_premises_location_set';
    v_payload:=jsonb_build_object('premises_ref',m[1],'building_ref',m[2],
     'unit_ref',m[3],'reason',m[4],'actor_ref',m[5]);
   else
    m:=regexp_match(btrim(coalesce(p_command_text,'')),
     '^search premises get ([^[:space:]]+) by ([^[:space:]]+)$','i');
    if m is not null then
     v_type:='search_premises_location_get';
     v_payload:=jsonb_build_object('premises_ref',m[1],'actor_ref',m[2]);
    end if;
   end if;
  end if;
 end if;
 end if;

 if v_type is null then
  v_result:=game.execute_text_command_before_bp04_exact_premises(
   p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  if p_command_text ilike 'help' and coalesce((v_result->>'ok')::boolean,false) then
   return jsonb_set(v_result,'{available_commands}',
    coalesce(v_result->'available_commands','[]'::jsonb)||
    jsonb_build_array('property_asset_event_record','property_interest_record','property_interest_end',
      'property_interest_history_get','scene_premises_set','scene_premises_get',
      'search_premises_location_set','search_premises_location_get'),true);
  end if;
  return v_result;
 end if;

 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then
  raise exception 'Command text must contain between 1 and 4000 characters';
 end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then
  raise exception 'A unique idempotency key between 8 and 200 characters is required';
 end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,
  command_text,command_type,payload)
 values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload)
 on conflict(idempotency_key) do nothing;
 if not found then
  select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if v_cmd.command_text<>p_command_text or v_cmd.command_type<>v_type or v_cmd.payload<>v_payload then
   return jsonb_build_object('ok',false,'code','idempotency_conflict');
  end if;
  return coalesce(v_cmd.result,jsonb_build_object('ok',v_cmd.status='completed'))||
    jsonb_build_object('duplicate',true);
 end if;
 select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 select * into v_actor from game.police_personnel
  where personnel_ref=btrim(v_payload->>'actor_ref')
    and employment_status in ('active','seconded');
 if v_actor.id is null or (p_actor_personnel_id is not null and p_actor_personnel_id<>v_actor.id) then
  v_result:=jsonb_build_object('ok',false,'code','actor_mismatch');
 else
  case v_type
   when 'property_interest_record' then
    v_result:=game.record_property_interest(v_cmd.id,v_payload,v_actor.id);
   when 'property_interest_end' then
    v_result:=game.end_property_interest(v_cmd.id,v_payload,v_actor.id);
   when 'property_interest_history_get' then
    v_result:=coalesce(game.get_property_interest_history(v_payload->>'property_ref'),
      jsonb_build_object('ok',false,'code','property_not_found'));
   when 'property_asset_event_record' then
    v_result:=game.execute_property_command(v_cmd.id,v_type,v_payload,v_actor.id);
   when 'scene_premises_set' then
    v_result:=game.record_scene_premises(v_payload->>'scene_ref',v_payload->>'property_ref',
     v_payload->>'building_ref',v_payload->>'unit_ref',v_payload->>'reason',
     v_payload->>'actor_ref',v_cmd.id);
   when 'scene_premises_get' then
    v_result:=coalesce(game.get_scene_premises_record(v_payload->>'scene_ref'),
     jsonb_build_object('ok',false,'code','scene_not_found'));
   when 'search_premises_location_set' then
    v_result:=game.record_search_premises_location(v_payload->>'premises_ref',
     v_payload->>'building_ref',v_payload->>'unit_ref',v_payload->>'reason',
     v_payload->>'actor_ref',v_cmd.id);
   else
    v_result:=coalesce(game.get_search_premises_location(v_payload->>'premises_ref'),
     jsonb_build_object('ok',false,'code','search_premises_not_found'));
  end case;
 end if;
 if coalesce((v_result->>'ok')::boolean,false) then
  v_result:=v_result||jsonb_build_object('status','completed','command_id',v_cmd.id);
  update game.game_commands set status='completed',result=v_result,completed_at=now()
   where id=v_cmd.id;
 else
  update game.game_commands set status='rejected',result=v_result,
   rejection_reason=coalesce(v_result->>'message',v_result->>'code','Premises location command rejected'),
   completed_at=now() where id=v_cmd.id;
  v_result:=v_result||jsonb_build_object('command_id',v_cmd.id);
 end if;
 return v_result;
end;
$function$;

revoke all on game.property_interest_events from public,anon,authenticated;
grant all on game.property_interest_events to service_role;
revoke all on function game.interpret_bp04_property_interest_command(text),
 game.record_property_interest(uuid,jsonb,uuid),game.end_property_interest(uuid,jsonb,uuid),
 game.get_property_interest_history(text),game.execute_text_command(text,text,uuid,uuid)
 from public,anon,authenticated;
grant execute on function game.interpret_bp04_property_interest_command(text),
 game.record_property_interest(uuid,jsonb,uuid),game.end_property_interest(uuid,jsonb,uuid),
 game.get_property_interest_history(text),game.execute_text_command(text,text,uuid,uuid)
 to service_role;
