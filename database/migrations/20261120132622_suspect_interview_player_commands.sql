alter function game.interpret_text_command(text) rename to interpret_text_command_before_suspect_interviews;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game' as $$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^case suspect interview classify ([^[:space:]]+) because "([^"]+)" by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','classify_case_suspect_interview','payload',jsonb_build_object('interview_ref',m[1],'reason',m[2],'actor_ref',m[3])); end if;
 m:=regexp_match(t,'^case suspect interview assess ([^[:space:]]+) turn ([^[:space:]]+) as (admission|denial|no_comment|qualified_response|correction|other) because "([^"]+)" by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','assess_case_suspect_interview_turn','payload',jsonb_build_object('interview_ref',m[1],'turn_ref',m[2],'assessment',lower(m[3]),'reason',m[4],'actor_ref',m[5])); end if;
 m:=regexp_match(t,'^case suspect interview review ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','get_case_suspect_interview_review','payload',jsonb_build_object('interview_ref',m[1])); end if;
 return game.interpret_text_command_before_suspect_interviews(p_command_text);
end $$;

alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_suspect_interviews;
create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare v_i jsonb; v_type text; v_payload jsonb; v_cmd game.game_commands%rowtype; v_result jsonb; v_actor game.police_personnel%rowtype;
begin
 v_i:=game.interpret_text_command(p_command_text); v_type:=v_i->>'command_type'; v_payload:=coalesce(v_i->'payload','{}'::jsonb);
 if coalesce((v_i->>'recognized')::boolean,false)=false or v_type not in ('classify_case_suspect_interview','assess_case_suspect_interview_turn','get_case_suspect_interview_review') then
  return game.execute_text_command_before_suspect_interviews(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
 end if;
 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then raise exception 'Command text must contain between 1 and 4000 characters'; end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key between 8 and 200 characters is required'; end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload) values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload) on conflict(idempotency_key) do nothing;
 if not found then
  select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if v_cmd.command_text<>p_command_text or v_cmd.command_type<>v_type or v_cmd.payload<>v_payload then return jsonb_build_object('ok',false,'code','idempotency_conflict','message','This command key was already used for a different command.','command_id',v_cmd.id); end if;
  return coalesce(v_cmd.result,jsonb_build_object('ok',v_cmd.status='completed','status',v_cmd.status,'command_id',v_cmd.id))||jsonb_build_object('duplicate',true);
 end if;
 select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 if v_type='get_case_suspect_interview_review' then
  v_result:=game.get_case_suspect_interview_review(v_payload->>'interview_ref');
 else
  select * into v_actor from game.police_personnel where personnel_ref=btrim(v_payload->>'actor_ref');
  if not found or (p_actor_personnel_id is not null and p_actor_personnel_id<>v_actor.id) then
   v_result:=jsonb_build_object('ok',false,'code','actor_mismatch','message','The command actor must match the named police personnel record.');
  elsif v_type='classify_case_suspect_interview' then
   v_result:=game.record_case_suspect_interview(v_payload->>'interview_ref',v_payload->>'reason',v_payload->>'actor_ref',v_cmd.id);
  else
   v_result:=game.assess_case_suspect_interview_turn(v_payload->>'interview_ref',v_payload->>'turn_ref',v_payload->>'assessment',v_payload->>'reason',v_payload->>'actor_ref',v_cmd.id);
  end if;
 end if;
 if coalesce((v_result->>'ok')::boolean,false) then
  v_result:=v_result||jsonb_build_object('status','completed','command_id',v_cmd.id);
  update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_cmd.id;
 else
  update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Suspect interview command rejected.'),result=v_result,completed_at=now() where id=v_cmd.id;
  v_result:=v_result||jsonb_build_object('command_id',v_cmd.id);
 end if;
 return v_result;
end $$;
revoke all on function game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) to service_role;
