create or replace function game.get_business_record(p_business_number text)
returns jsonb language sql stable as $$
 select jsonb_build_object('organisation',to_jsonb(o),'business',to_jsonb(bp),
  'sites',coalesce((select jsonb_agg(jsonb_build_object('site',to_jsonb(ol),'property',to_jsonb(p),
   'property_profile',to_jsonb(pp),'address',to_jsonb(pa),'district',jsonb_build_object('code',d.code,'name',d.name),
   'neighbourhood',jsonb_build_object('code',n.code,'name',n.name),'building',to_jsonb(b),'unit',to_jsonb(u),'unit_profile',to_jsonb(up))
   order by ol.is_primary_location desc,p.property_ref)
   from game.organisation_locations ol join game.properties p on p.id=ol.property_id
   join game.districts d on d.id=p.district_id join game.neighbourhoods n on n.id=p.neighbourhood_id
   left join game.property_profiles pp on pp.property_id=p.id
   left join game.property_addresses pa on pa.property_id=p.id and pa.is_primary
   left join game.building_units u on u.id=ol.building_unit_id
   left join game.buildings b on b.id=u.building_id
   left join game.building_unit_profiles up on up.building_unit_id=u.id
   where ol.organisation_id=o.id),'[]'::jsonb))
 from game.business_profiles bp join game.organisations o on o.id=bp.organisation_id
 where bp.business_number=p_business_number;
$$;

alter function game.interpret_text_command(text) rename to interpret_text_command_before_property;
alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_property;

create or replace function game.interpret_property_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game'
as $$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^property record ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','property_get_record','payload',jsonb_build_object('property_ref',m[1],'actor_ref',m[2])); end if;
 m:=regexp_match(t,'^property map ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','property_neighbourhood_map','payload',jsonb_build_object('neighbourhood_code',upper(m[1]),'actor_ref',m[2])); end if;
 m:=regexp_match(t,'^property summary by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','property_city_summary','payload',jsonb_build_object('actor_ref',m[1])); end if;
 m:=regexp_match(t,'^business record ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','business_get_record','payload',jsonb_build_object('business_number',m[1],'actor_ref',m[2])); end if;
 m:=regexp_match(t,'^business directory by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','business_directory','payload',jsonb_build_object('actor_ref',m[1],'limit',100)); end if;
 m:=regexp_match(t,'^business directory sector ([a-z_]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','business_directory','payload',jsonb_build_object('sector',lower(m[1]),'actor_ref',m[2],'limit',100)); end if;
 m:=regexp_match(t,'^business directory district ([A-Z0-9-]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','business_directory','payload',jsonb_build_object('district_code',upper(m[1]),'actor_ref',m[2],'limit',100)); end if;
 m:=regexp_match(t,'^business directory search "([^"]+)" by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','business_directory','payload',jsonb_build_object('search',m[1],'actor_ref',m[2],'limit',100)); end if;
 return null;
end $$;

create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game'
as $$
declare r jsonb;
begin
 r:=game.interpret_property_command(p_command_text);
 if r is not null then return r; end if;
 return game.interpret_text_command_before_property(p_command_text);
end $$;

create or replace function game.execute_property_command(p_command_id uuid,p_type text,payload jsonb,p_actor_id uuid)
returns jsonb language plpgsql stable set search_path to 'pg_catalog','game'
as $$
declare v_personnel game.police_personnel%rowtype; v_data jsonb;
begin
 select * into v_personnel from game.police_personnel where id=p_actor_id and employment_status in ('active','seconded');
 if v_personnel.id is null or v_personnel.personnel_ref<>payload->>'actor_ref' then return jsonb_build_object('ok',false,'code','actor_mismatch'); end if;
 if p_type='property_get_record' then
  v_data:=game.get_property_record(payload->>'property_ref');
  if v_data is null then return jsonb_build_object('ok',false,'code','property_not_found','property_ref',payload->>'property_ref'); end if;
  return jsonb_build_object('ok',true,'record_type','property','record',v_data);
 elsif p_type='property_neighbourhood_map' then
  v_data:=game.get_neighbourhood_property_map(payload->>'neighbourhood_code');
  if v_data is null then return jsonb_build_object('ok',false,'code','neighbourhood_not_found','neighbourhood_code',payload->>'neighbourhood_code'); end if;
  return jsonb_build_object('ok',true,'record_type','neighbourhood_property_map','map',v_data);
 elsif p_type='property_city_summary' then
  v_data:=game.get_city_property_summary('KNG');
  return jsonb_build_object('ok',true,'record_type','city_property_summary','summary',v_data);
 elsif p_type='business_get_record' then
  v_data:=game.get_business_record(payload->>'business_number');
  if v_data is null then return jsonb_build_object('ok',false,'code','business_not_found','business_number',payload->>'business_number'); end if;
  return jsonb_build_object('ok',true,'record_type','business','record',v_data);
 elsif p_type='business_directory' then
  select coalesce(jsonb_agg(to_jsonb(x)),'[]'::jsonb) into v_data
  from game.list_business_directory(payload->>'sector',payload->>'district_code',payload->>'search',coalesce((payload->>'limit')::integer,100)) x;
  return jsonb_build_object('ok',true,'record_type','business_directory','count',jsonb_array_length(v_data),'businesses',v_data);
 end if;
 return jsonb_build_object('ok',false,'code','unsupported_property_command');
end $$;

create or replace function game.execute_text_command(
 p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null
)
returns jsonb language plpgsql set search_path to 'pg_catalog','game'
as $$
declare i jsonb; typ text; d jsonb; cmd game.game_commands%rowtype; res jsonb; actor game.police_personnel%rowtype;
begin
 i:=game.interpret_text_command(p_command_text); typ:=i->>'command_type'; d:=coalesce(i->'payload','{}'::jsonb);
 if typ='help' then
  res:=game.execute_text_command_before_property(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  return jsonb_set(res,'{available_commands}',
   (select coalesce(jsonb_agg(distinct x),'[]'::jsonb)
    from jsonb_array_elements_text(coalesce(res->'available_commands','[]'::jsonb)||
     jsonb_build_array('property_get_record','property_neighbourhood_map','property_city_summary','business_get_record','business_directory')) x),true);
 end if;
 if typ not in ('property_get_record','property_neighbourhood_map','property_city_summary','business_get_record','business_directory') then
  return game.execute_text_command_before_property(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
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
 select * into actor from game.police_personnel where personnel_ref=d->>'actor_ref' and employment_status in ('active','seconded');
 if actor.id is null or (p_actor_personnel_id is not null and p_actor_personnel_id<>actor.id) then res:=jsonb_build_object('ok',false,'code','actor_mismatch');
 else res:=game.execute_property_command(cmd.id,typ,d,actor.id); end if;
 if coalesce((res->>'ok')::boolean,false) then
  res:=res||jsonb_build_object('status','completed','command_id',cmd.id);
  update game.game_commands set status='completed',result=res,completed_at=now() where id=cmd.id;
 else
  update game.game_commands set status='rejected',result=res,rejection_reason=coalesce(res->>'message',res->>'code','Property command rejected'),completed_at=now() where id=cmd.id;
  res:=res||jsonb_build_object('command_id',cmd.id);
 end if;
 return res;
end $$;

revoke all on function game.interpret_property_command(text) from public,anon,authenticated;
revoke all on function game.execute_property_command(uuid,text,jsonb,uuid) from public,anon,authenticated;
revoke all on function game.get_business_record(text) from public,anon,authenticated;
revoke all on function game.interpret_text_command_before_property(text) from public,anon,authenticated;
revoke all on function game.execute_text_command_before_property(text,text,uuid,uuid) from public,anon,authenticated;
revoke all on function game.interpret_text_command(text) from public,anon,authenticated;
revoke all on function game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text) to service_role;
grant execute on function game.execute_text_command(text,text,uuid,uuid) to service_role;
