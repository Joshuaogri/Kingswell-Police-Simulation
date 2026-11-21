-- BP-04 regression fixes: PostgreSQL ARE repeat counts are limited to 255.
-- Reason length is validated in the scene/search record functions, so command
-- recognition uses an unbounded non-quote capture and lets the validator decide.

create or replace function game.execute_text_command(
 p_command_text text,p_idempotency_key text,p_session_id uuid default null,
 p_actor_personnel_id uuid default null
) returns jsonb
language plpgsql
set search_path to 'pg_catalog','game'
as $function$
declare
 m text[]; v_type text; v_payload jsonb; v_cmd game.game_commands%rowtype;
 v_actor game.police_personnel%rowtype; v_result jsonb;
begin
 -- Property event commands use the dedicated property parser; they are not
 -- part of the older generic text interpreter's command catalogue.
 v_payload:=game.interpret_property_command(p_command_text)->'payload';
 if game.interpret_property_command(p_command_text)->>'command_type'='property_asset_event_record' then
  v_type:='property_asset_event_record';
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
    jsonb_build_array('scene_premises_set','scene_premises_get',
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

create or replace function game.get_case_review_dossier(p_case_ref text)
returns jsonb
language plpgsql stable
set search_path to 'pg_catalog','game'
as $function$
declare v_result jsonb;
begin
 v_result:=game.get_case_review_dossier_before_bp04_evidence_premises(p_case_ref);
 if coalesce((v_result->>'ok')::boolean,false) is not true then return v_result; end if;
 return v_result || jsonb_build_object(
  'premises_context',game.get_case_premises_context(p_case_ref),
  'evidence_premises_context',game.get_case_evidence_premises_context(p_case_ref)
 );
end;
$function$;

revoke all on function game.execute_text_command(text,text,uuid,uuid),
 game.get_case_review_dossier(text) from public,anon,authenticated;
grant execute on function game.execute_text_command(text,text,uuid,uuid),
 game.get_case_review_dossier(text) to service_role;
