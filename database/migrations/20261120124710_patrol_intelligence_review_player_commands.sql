
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path=pg_catalog,game as $$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^review[[:space:]]+patrol[[:space:]]+intelligence[[:space:]]+([^[:space:]]+)[[:space:]]+disposition[[:space:]]+(relevant|further_enquiries|insufficient_information|not_relevant)[[:space:]]+because[[:space:]]+(.+)$','i');
 if m is not null then
  return jsonb_build_object('recognized',true,'command_type','review_patrol_intelligence',
   'payload',jsonb_build_object('link_ref',m[1],'disposition',lower(m[2]),'note',btrim(m[3])));
 end if;
 m:=regexp_match(t,'^patrol[[:space:]]+intelligence[[:space:]]+reviews(?:[[:space:]]+for[[:space:]]+([^[:space:]]+))?$','i');
 if m is not null then
  return jsonb_build_object('recognized',true,'command_type','patrol_intelligence_reviews',
   'payload',jsonb_build_object('reference',nullif(btrim(m[1]),'')));
 end if;
 return game.interpret_text_command_before_link_lookup(p_command_text);
end;
$$;

create or replace function game.execute_text_command(
 p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null
) returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare v_interpreted jsonb; v_type text; v_payload jsonb; v_command game.game_commands%rowtype; v_result jsonb;
begin
 v_interpreted:=game.interpret_text_command(p_command_text);
 v_type:=v_interpreted->>'command_type';
 if coalesce((v_interpreted->>'recognized')::boolean,false)=false
    or v_type not in ('review_patrol_intelligence','patrol_intelligence_reviews') then
  return game.execute_text_command_before_patrol_reviews(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
 end if;
 v_payload:=coalesce(v_interpreted->'payload','{}'::jsonb);
 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then
  raise exception 'Command text must contain between 1 and 4000 characters';
 end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then
  raise exception 'A unique idempotency key between 8 and 200 characters is required';
 end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload)
 values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload)
 on conflict(idempotency_key) do nothing;
 if not found then
  select * into v_command from game.game_commands where idempotency_key=p_idempotency_key for update;
  if v_command.command_text<>p_command_text or v_command.command_type<>v_type or v_command.payload<>v_payload then
   return jsonb_build_object('ok',false,'code','idempotency_conflict','message','This command key was already used for a different command.','command_id',v_command.id);
  end if;
  return coalesce(v_command.result,jsonb_build_object('ok',v_command.status='completed','status',v_command.status,'command_id',v_command.id,'message','Previously received command; no duplicate action was executed.'))
   || jsonb_build_object('duplicate',true);
 end if;
 select * into v_command from game.game_commands where idempotency_key=p_idempotency_key for update;
 if v_type='review_patrol_intelligence' then
  v_result:=game.record_patrol_intelligence_review(v_command.id,v_payload->>'link_ref',v_payload->>'disposition',v_payload->>'note',p_actor_personnel_id);
 else
  v_result:=game.get_patrol_intelligence_reviews(v_payload->>'reference',100);
 end if;
 if coalesce((v_result->>'ok')::boolean,false) then
  v_result:=v_result||jsonb_build_object('status','completed','command_id',v_command.id);
  update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_command.id;
 else
  update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Patrol intelligence review rejected.'),result=v_result,completed_at=now() where id=v_command.id;
  v_result:=v_result||jsonb_build_object('command_id',v_command.id);
 end if;
 return v_result;
end;
$$;

revoke all on function game.interpret_text_command(text) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text) to service_role;
revoke all on function game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.execute_text_command(text,text,uuid,uuid) to service_role;
