alter function game.interpret_text_command(text) rename to interpret_text_command_before_case_activity;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path=pg_catalog,game as $$
declare t text:=btrim(coalesce(p_command_text,''));m text[];
begin
 m:=regexp_match(t,'^case activity record ([^[:space:]]+) type ([^[:space:]]+) by ([^[:space:]]+) method "(.+)" outcome ([^[:space:]]+) because "(.+)" result "(.+)"$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','record_case_activity','payload',jsonb_build_object('case_ref',m[1],'activity_type',lower(m[2]),'actor_ref',m[3],'method',m[4],'outcome',lower(m[5]),'description',m[6],'result',m[7]));end if;
 m:=regexp_match(t,'^case activity link ([^[:space:]]+) ([^[:space:]]+) ([^[:space:]]+) by ([^[:space:]]+) because "(.+)"$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','link_case_activity','payload',jsonb_build_object('activity_ref',m[1],'entity_type',lower(m[2]),'entity_ref',m[3],'actor_ref',m[4],'reason',m[5]));end if;
 m:=regexp_match(t,'^case activity (?:list|history) ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','get_case_activity','payload',jsonb_build_object('case_ref',m[1],'actor_ref',m[2]));end if;
 return game.interpret_text_command_before_case_activity(p_command_text);
end $$;
alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_case_activity;
create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare v_i jsonb;v_type text;v_payload jsonb;v_cmd game.game_commands%rowtype;v_result jsonb;v_actor game.police_personnel%rowtype;v_case game.cases%rowtype;
begin
 v_i:=game.interpret_text_command(p_command_text);v_type:=v_i->>'command_type';v_payload:=coalesce(v_i->'payload','{}'::jsonb);
 if v_type='help' then
  v_result:=game.execute_text_command_before_case_activity(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  return jsonb_set(v_result,'{available_commands}',(select coalesce(jsonb_agg(distinct x),'[]'::jsonb) from jsonb_array_elements_text(coalesce(v_result->'available_commands','[]'::jsonb)||jsonb_build_array('record_case_activity','link_case_activity','get_case_activity')) x),true);
 end if;
 if v_type not in ('record_case_activity','link_case_activity','get_case_activity') then return game.execute_text_command_before_case_activity(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);end if;
 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then raise exception 'Command text must contain between 1 and 4000 characters';end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key between 8 and 200 characters is required';end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload) values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload) on conflict(idempotency_key) do nothing;
 if not found then select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if v_cmd.command_text<>p_command_text or v_cmd.command_type<>v_type or v_cmd.payload<>v_payload then return jsonb_build_object('ok',false,'code','idempotency_conflict','message','This command key was already used for a different command.','command_id',v_cmd.id);end if;
  return coalesce(v_cmd.result,jsonb_build_object('ok',v_cmd.status='completed','status',v_cmd.status,'command_id',v_cmd.id))||jsonb_build_object('duplicate',true);
 end if;
 select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(v_payload->>'actor_ref');
 if v_actor.id is null or v_actor.employment_status not in ('active','seconded') or (p_actor_personnel_id is not null and p_actor_personnel_id<>v_actor.id) then
  v_result:=jsonb_build_object('ok',false,'code','actor_mismatch','message','The named command actor must match active or seconded personnel.');
 else
  if v_type='record_case_activity' then
   v_result:=game.record_case_activity(v_payload->>'case_ref',v_payload->>'activity_type',v_payload->>'method',v_payload->>'description',v_payload->>'result',v_payload->>'outcome',v_actor.personnel_ref,v_actor.personnel_ref,v_cmd.id);
  elsif v_type='link_case_activity' then
   v_result:=game.link_case_activity(v_payload->>'activity_ref',v_payload->>'entity_type',v_payload->>'entity_ref',v_payload->>'reason',v_actor.personnel_ref,v_cmd.id);
  else
   select * into v_case from game.cases where case_ref=btrim(v_payload->>'case_ref');
   if not found then v_result:=jsonb_build_object('ok',false,'code','case_not_found','message','Case reference not found.');
   elsif not exists(select 1 from game.case_assignments a where a.case_id=v_case.id and a.personnel_id=v_actor.id and a.status='active' and a.released_at is null) and v_case.lead_personnel_id is distinct from v_actor.id then
    v_result:=jsonb_build_object('ok',false,'code','case_access_denied','message','The viewing officer must be the case lead or actively assigned to the case.');
   else v_result:=game.get_case_activity(v_case.case_ref,200);end if;
  end if;
 end if;
 if coalesce((v_result->>'ok')::boolean,false) then v_result:=v_result||jsonb_build_object('status','completed','command_id',v_cmd.id);update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_cmd.id;
 else update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Case activity command rejected.'),result=v_result,completed_at=now() where id=v_cmd.id;v_result:=v_result||jsonb_build_object('command_id',v_cmd.id);end if;
 return v_result;
end $$;
revoke all on function game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) to service_role;
