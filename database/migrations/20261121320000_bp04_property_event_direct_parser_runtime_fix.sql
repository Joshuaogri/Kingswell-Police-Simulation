-- BP-04: route property-event execution through its dedicated parser.
-- The canonical interpreter is wrapped by several historical runtime migrations.
-- Calling the dedicated grammar parser here avoids stale interpreter routing in
-- the legacy executor chain while leaving every other command on that chain.

create or replace function game.execute_text_command(
 p_command_text text,p_idempotency_key text,p_session_id uuid default null,
 p_actor_personnel_id uuid default null
) returns jsonb
language plpgsql
set search_path to 'pg_catalog','game'
as $function$
declare
 v_interpreted jsonb;
 v_type text;
 v_payload jsonb;
 v_command game.game_commands%rowtype;
 v_actor game.police_personnel%rowtype;
 v_result jsonb;
begin
 v_interpreted:=game.interpret_property_command(p_command_text);
 v_type:=v_interpreted->>'command_type';
 if v_type is distinct from 'property_asset_event_record' then
  return game.execute_text_command_before_bp04_property_event_interpreter_fix(
   p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id
  );
 end if;

 v_payload:=coalesce(v_interpreted->'payload','{}'::jsonb);
 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then
  raise exception 'Command text must contain between 1 and 4000 characters';
 end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then
  raise exception 'A unique idempotency key between 8 and 200 characters is required';
 end if;

 insert into game.game_commands(
  idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload
 ) values (
  p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload
 ) on conflict(idempotency_key) do nothing;

 if not found then
  select * into v_command from game.game_commands
   where idempotency_key=p_idempotency_key for update;
  if v_command.command_text<>p_command_text
   or v_command.command_type<>v_type
   or v_command.payload<>v_payload then
   return jsonb_build_object('ok',false,'code','idempotency_conflict');
  end if;
  return coalesce(v_command.result,jsonb_build_object('ok',v_command.status='completed'))
   ||jsonb_build_object('duplicate',true);
 end if;

 select * into v_command from game.game_commands
  where idempotency_key=p_idempotency_key for update;
 select * into v_actor from game.police_personnel
  where personnel_ref=btrim(v_payload->>'actor_ref')
   and employment_status in ('active','seconded');

 if v_actor.id is null
  or (p_actor_personnel_id is not null and p_actor_personnel_id<>v_actor.id) then
  v_result:=jsonb_build_object('ok',false,'code','actor_mismatch');
 else
  v_result:=game.execute_property_command(
   v_command.id,v_type,v_payload,v_actor.id
  );
 end if;

 if coalesce((v_result->>'ok')::boolean,false) then
  v_result:=v_result||jsonb_build_object(
   'status','completed','command_id',v_command.id
  );
  update game.game_commands
   set status='completed',result=v_result,completed_at=now()
   where id=v_command.id;
 else
  update game.game_commands
   set status='rejected',result=v_result,
    rejection_reason=coalesce(v_result->>'message',v_result->>'code',
     'Property asset event command rejected'),
    completed_at=now()
   where id=v_command.id;
  v_result:=v_result||jsonb_build_object('command_id',v_command.id);
 end if;
 return v_result;
end;
$function$;

revoke all on function game.execute_text_command(text,text,uuid,uuid)
 from public,anon,authenticated;
grant execute on function game.execute_text_command(text,text,uuid,uuid)
 to service_role;
