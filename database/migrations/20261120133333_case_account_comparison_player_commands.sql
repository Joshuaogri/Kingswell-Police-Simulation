alter function game.interpret_text_command(text) rename to interpret_text_command_before_account_comparisons;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game' as $$
declare t text:=btrim(coalesce(p_command_text,''));m text[];
begin
 m:=regexp_match(t,'^case compare accounts ([^[:space:]]+) first (witness_statement|interview_turn) ([^[:space:]]+) second (witness_statement|interview_turn) ([^[:space:]]+) category (timeline_conflict|location_conflict|sequence_conflict|action_conflict|identity_conflict|description_conflict|other) because "([^"]+)" by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','record_case_account_comparison','payload',jsonb_build_object('case_ref',m[1],'first_type',lower(m[2]),'first_ref',m[3],'second_type',lower(m[4]),'second_ref',m[5],'category',lower(m[6]),'description',m[7],'actor_ref',m[8])); end if;
 m:=regexp_match(t,'^case account comparison assess ([^[:space:]]+) as (unresolved|explained|partially_explained|not_a_conflict) because "([^"]+)" by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','assess_case_account_comparison','payload',jsonb_build_object('comparison_ref',m[1],'disposition',lower(m[2]),'assessment',m[3],'actor_ref',m[4])); end if;
 m:=regexp_match(t,'^case account comparison link evidence ([^[:space:]]+) ([^[:space:]]+) because "([^"]+)" by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','link_case_account_comparison_evidence','payload',jsonb_build_object('comparison_ref',m[1],'evidence_ref',m[2],'reason',m[3],'actor_ref',m[4])); end if;
 m:=regexp_match(t,'^case account comparisons ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','get_case_account_comparisons','payload',jsonb_build_object('case_ref',m[1])); end if;
 return game.interpret_text_command_before_account_comparisons(p_command_text);
end $$;

alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_account_comparisons;
create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare v_i jsonb;v_type text;v_payload jsonb;v_cmd game.game_commands%rowtype;v_result jsonb;v_actor game.police_personnel%rowtype;
begin
 v_i:=game.interpret_text_command(p_command_text);v_type:=v_i->>'command_type';v_payload:=coalesce(v_i->'payload','{}'::jsonb);
 if v_type='help' then
  v_result:=game.execute_text_command_before_account_comparisons(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  return jsonb_set(v_result,'{available_commands}',coalesce(v_result->'available_commands','[]'::jsonb)||jsonb_build_array('record_case_account_comparison','assess_case_account_comparison','link_case_account_comparison_evidence','get_case_account_comparisons'),true);
 end if;
 if coalesce((v_i->>'recognized')::boolean,false)=false or v_type not in ('record_case_account_comparison','assess_case_account_comparison','link_case_account_comparison_evidence','get_case_account_comparisons') then
  return game.execute_text_command_before_account_comparisons(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
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
 if v_type='get_case_account_comparisons' then
  v_result:=game.get_case_account_comparisons(v_payload->>'case_ref',null);
 else
  select * into v_actor from game.police_personnel where personnel_ref=btrim(v_payload->>'actor_ref');
  if not found or (p_actor_personnel_id is not null and p_actor_personnel_id<>v_actor.id) then v_result:=jsonb_build_object('ok',false,'code','actor_mismatch','message','The command actor must match the named police personnel record.');
  elsif v_type='record_case_account_comparison' then
   v_result:=game.record_case_account_comparison(v_payload->>'case_ref',v_payload->>'first_type',v_payload->>'first_ref',v_payload->>'second_type',v_payload->>'second_ref',v_payload->>'category',v_payload->>'description',v_payload->>'actor_ref',v_cmd.id);
  elsif v_type='assess_case_account_comparison' then
   v_result:=game.assess_case_account_comparison(v_payload->>'comparison_ref',v_payload->>'disposition',v_payload->>'assessment',v_payload->>'actor_ref',v_cmd.id);
  else
   v_result:=game.link_case_account_comparison_evidence(v_payload->>'comparison_ref',v_payload->>'evidence_ref',v_payload->>'reason',v_payload->>'actor_ref',v_cmd.id);
  end if;
 end if;
 if coalesce((v_result->>'ok')::boolean,false) then
  v_result:=v_result||jsonb_build_object('status','completed','command_id',v_cmd.id);
  update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_cmd.id;
 else
  update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Account comparison command rejected.'),result=v_result,completed_at=now() where id=v_cmd.id;
  v_result:=v_result||jsonb_build_object('command_id',v_cmd.id);
 end if;
 return v_result;
end $$;
revoke all on function game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) to service_role;
