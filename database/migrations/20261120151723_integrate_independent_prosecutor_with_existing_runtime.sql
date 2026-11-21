
create or replace function game.interpret_prosecution_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path='pg_catalog','game' as $$
declare m text[];
begin
 m:=regexp_match(p_command_text,'^prosecution refer ([A-Za-z0-9_-]+) arrest ([A-Za-z0-9_-]+) by ([A-Za-z0-9_-]+) summary "([^"]+)" charges "([^"]+)" evidence "([^"]+)"$','i');
 if m is not null then return jsonb_build_object('command_type','submit_prosecution_referral','payload',jsonb_build_object('case_ref',m[1],'arrest_ref',m[2],'actor_ref',m[3],'summary',m[4],'charges',m[5],'evidence',m[6]));end if;
 m:=regexp_match(p_command_text,'^prosecution referrals ([A-Za-z0-9_-]+) by ([A-Za-z0-9_-]+)$','i');
 if m is not null then return jsonb_build_object('command_type','get_prosecution_referrals','payload',jsonb_build_object('case_ref',m[1],'actor_ref',m[2]));end if;
 return null;
end $$;

create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path='pg_catalog','game' as $$
declare i jsonb;typ text;d jsonb;cmd game.game_commands%rowtype;actor game.police_personnel%rowtype;res jsonb;
begin
 i:=game.interpret_text_command(p_command_text);typ:=i->>'command_type';d:=coalesce(i->'payload','{}'::jsonb);
 if typ='help' then
  res:=game.execute_text_command_before_arrest_custody(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  return jsonb_set(res,'{available_commands}',(select coalesce(jsonb_agg(distinct x),'[]') from jsonb_array_elements_text(coalesce(res->'available_commands','[]')||jsonb_build_array('appoint_prosecutor','record_prosecution_review','file_formal_charge','get_formal_charges','submit_prosecution_referral','get_prosecution_referrals'))x),true);
 end if;
 if typ not in ('appoint_prosecutor','record_prosecution_review','file_formal_charge','get_formal_charges','submit_prosecution_referral','get_prosecution_referrals') then
  return game.execute_text_command_before_arrest_custody(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
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
 if typ in ('appoint_prosecutor','submit_prosecution_referral','get_prosecution_referrals') then
  select * into actor from game.police_personnel where personnel_ref=d->>'actor_ref' and employment_status in ('active','seconded');
  if actor.id is null or (p_actor_personnel_id is not null and p_actor_personnel_id<>actor.id) then res:=jsonb_build_object('ok',false,'code','actor_mismatch');
  elsif typ='appoint_prosecutor' then res:=game.execute_justice_command(cmd.id,typ,d,actor.id);
  else res:=game.execute_prosecution_command(cmd.id,typ,d,actor.id);end if;
 else
  res:=game.execute_justice_command(cmd.id,typ,d,null);
 end if;
 if coalesce((res->>'ok')::boolean,false) then
  res:=res||jsonb_build_object('status','completed','command_id',cmd.id);
  update game.game_commands set status='completed',result=res,completed_at=now() where id=cmd.id;
 else
  update game.game_commands set status='rejected',result=res,rejection_reason=coalesce(res->>'message','Justice command rejected'),completed_at=now() where id=cmd.id;
  res:=res||jsonb_build_object('command_id',cmd.id);
 end if;
 return res;
end $$;
revoke all on function game.interpret_prosecution_command(text) from public,anon,authenticated;
grant execute on function game.interpret_prosecution_command(text) to service_role;
revoke all on function game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.execute_text_command(text,text,uuid,uuid) to service_role;
