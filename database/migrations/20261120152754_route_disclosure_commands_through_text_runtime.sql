
alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_disclosure;
create or replace function game.execute_text_command(
 p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null
) returns jsonb language plpgsql set search_path='pg_catalog','game' as $$
declare i jsonb;typ text;d jsonb;cmd game.game_commands%rowtype;res jsonb;
begin
 i:=game.interpret_text_command(p_command_text);typ:=i->>'command_type';d:=coalesce(i->'payload','{}'::jsonb);
 if typ='help' then
  res:=game.execute_text_command_before_disclosure(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  return jsonb_set(res,'{available_commands}',(select coalesce(jsonb_agg(distinct x),'[]'::jsonb) from jsonb_array_elements_text(coalesce(res->'available_commands','[]'::jsonb)||jsonb_build_array('assign_defence_counsel','create_prosecution_disclosure','create_defence_disclosure','add_disclosure_item','set_disclosure_item_treatment','serve_disclosure_package','acknowledge_disclosure_package','get_disclosure_packages','get_disclosure_package')) x),true);
 end if;
 if typ not in ('assign_defence_counsel','create_prosecution_disclosure','create_defence_disclosure','add_disclosure_item','set_disclosure_item_treatment','serve_disclosure_package','acknowledge_disclosure_package','get_disclosure_packages','get_disclosure_package') then
  return game.execute_text_command_before_disclosure(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
 end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key is required';end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload)
 values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,typ,d) on conflict(idempotency_key) do nothing;
 if not found then
  select * into cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if cmd.command_text<>p_command_text or cmd.command_type<>typ or cmd.payload<>d then return jsonb_build_object('ok',false,'code','idempotency_conflict');end if;
  return coalesce(cmd.result,jsonb_build_object('ok',cmd.status='completed'))||jsonb_build_object('duplicate',true);
 end if;
 select * into cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 res:=game.execute_justice_command(cmd.id,typ,d,null);
 if coalesce((res->>'ok')::boolean,false) then
  res:=res||jsonb_build_object('status','completed','command_id',cmd.id);
  update game.game_commands set status='completed',result=res,completed_at=now() where id=cmd.id;
 else
  update game.game_commands set status='rejected',result=res,rejection_reason=coalesce(res->>'message','Disclosure command rejected'),completed_at=now() where id=cmd.id;
  res:=res||jsonb_build_object('command_id',cmd.id);
 end if;
 return res;
end $$;
revoke all on function game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.execute_text_command(text,text,uuid,uuid) to service_role;
