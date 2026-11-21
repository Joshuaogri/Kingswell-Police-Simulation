-- BP-04 organisation and site dossier retrieval through the normal game command interface.
-- Reuses canonical organisation/site read models and the existing audited command chain.
alter function game.interpret_property_command(text)
 rename to interpret_property_command_before_organisation_site_dossiers;
create or replace function game.interpret_property_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game'
as $function$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^organisation record ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then
  return jsonb_build_object('command_type','organisation_get_record',
   'payload',jsonb_build_object('organisation_ref',m[1],'actor_ref',m[2]));
 end if;
 m:=regexp_match(t,'^organisation site record ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then
  return jsonb_build_object('command_type','organisation_site_get_record',
   'payload',jsonb_build_object('site_ref',m[1],'actor_ref',m[2]));
 end if;
 return game.interpret_property_command_before_organisation_site_dossiers(p_command_text);
end;
$function$;

alter function game.execute_property_command(uuid,text,jsonb,uuid)
 rename to execute_property_command_before_organisation_site_dossiers;
create or replace function game.execute_property_command(
 p_command_id uuid,p_type text,payload jsonb,p_actor_id uuid
) returns jsonb language plpgsql volatile set search_path to 'pg_catalog','game'
as $function$
declare v_actor game.police_personnel%rowtype; v_data jsonb;
begin
 if p_type not in ('organisation_get_record','organisation_site_get_record') then
  return game.execute_property_command_before_organisation_site_dossiers(p_command_id,p_type,payload,p_actor_id);
 end if;
 select * into v_actor from game.police_personnel
  where id=p_actor_id and employment_status in ('active','seconded');
 if v_actor.id is null or v_actor.personnel_ref<>payload->>'actor_ref' then
  return jsonb_build_object('ok',false,'code','actor_mismatch');
 end if;
 if p_type='organisation_get_record' then
  v_data:=game.get_organisation_record(payload->>'organisation_ref');
  if v_data is null then
   return jsonb_build_object('ok',false,'code','organisation_not_found','organisation_ref',payload->>'organisation_ref');
  end if;
  return jsonb_build_object('ok',true,'record_type','organisation','record',v_data);
 end if;
 v_data:=game.get_organisation_site_record(payload->>'site_ref');
 if v_data is null then
  return jsonb_build_object('ok',false,'code','organisation_site_not_found','site_ref',payload->>'site_ref');
 end if;
 return jsonb_build_object('ok',true,'record_type','organisation_site','record',v_data);
end;
$function$;

alter function game.execute_text_command_before_runtime_chain_repair(text,text,uuid,uuid)
 rename to execute_text_command_before_organisation_site_dossiers;
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
  res:=game.execute_text_command_before_organisation_site_dossiers(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  return jsonb_set(res,'{available_commands}',
   (select coalesce(jsonb_agg(distinct x),'[]'::jsonb)
    from jsonb_array_elements_text(coalesce(res->'available_commands','[]'::jsonb)||
     jsonb_build_array('organisation_get_record','organisation_site_get_record')) x),true);
 end if;
 if typ not in ('organisation_get_record','organisation_site_get_record') then
  return game.execute_text_command_before_organisation_site_dossiers(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
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
   rejection_reason=coalesce(res->>'message',res->>'code','Organisation dossier query rejected'),
   completed_at=now() where id=cmd.id;
  res:=res||jsonb_build_object('command_id',cmd.id);
 end if;
 return res;
end;
$function$;

revoke all on function game.interpret_property_command(text),
 game.execute_property_command(uuid,text,jsonb,uuid),
 game.execute_text_command_before_runtime_chain_repair(text,text,uuid,uuid)
 from public,anon,authenticated;
grant execute on function game.interpret_property_command(text),
 game.execute_text_command(text,text,uuid,uuid) to service_role;
