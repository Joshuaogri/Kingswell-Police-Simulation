
create table game.case_handover_events (
 id uuid primary key default gen_random_uuid(),
 handover_ref text not null unique,
 case_id uuid not null references game.cases(id),
 previous_lead_personnel_id uuid not null references game.police_personnel(id),
 new_lead_personnel_id uuid not null references game.police_personnel(id),
 transferred_by_personnel_id uuid not null references game.police_personnel(id),
 continuity_note text not null check (length(btrim(continuity_note))>0),
 transferred_at_game_time timestamptz not null,
 source_command_id uuid not null references game.game_commands(id),
 created_at timestamptz not null default now(),
 check (previous_lead_personnel_id <> new_lead_personnel_id)
);
create index case_handover_events_case_time_idx on game.case_handover_events(case_id,transferred_at_game_time desc);
create index case_handover_events_previous_lead_idx on game.case_handover_events(previous_lead_personnel_id);
create index case_handover_events_new_lead_idx on game.case_handover_events(new_lead_personnel_id);
alter table game.case_handover_events enable row level security;
revoke all on game.case_handover_events from public,anon,authenticated;
grant select,insert on game.case_handover_events to service_role;
create trigger case_handover_events_immutable before update or delete on game.case_handover_events
 for each row execute function game.prevent_case_governance_mutation();

create or replace function game.transfer_case_lead(
 p_case_ref text,p_from_personnel_ref text,p_to_personnel_ref text,p_note text,
 p_actor_personnel_id uuid,p_source_command_id uuid
) returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare v_case game.cases%rowtype; v_old game.police_personnel%rowtype; v_new game.police_personnel%rowtype;
 v_clock timestamptz; v_ref text; v_assignment jsonb;
begin
 if nullif(btrim(p_case_ref),'') is null or nullif(btrim(p_from_personnel_ref),'') is null
  or nullif(btrim(p_to_personnel_ref),'') is null or nullif(btrim(p_note),'') is null then
  return jsonb_build_object('ok',false,'code','invalid_handover','message','Case, outgoing lead, incoming lead and a continuity note are required.');
 end if;
 if char_length(p_note)>4000 then return jsonb_build_object('ok',false,'code','invalid_handover','message','The continuity note cannot exceed 4,000 characters.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before transferring case ownership.'); end if;
 select * into v_case from game.cases where case_ref=btrim(p_case_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference was not found.'); end if;
 if v_case.status='closed' then return jsonb_build_object('ok',false,'code','case_closed','message','A closed case cannot be transferred.'); end if;
 if not exists(select 1 from game.case_assignments a where a.case_id=v_case.id and a.personnel_id=p_actor_personnel_id and a.assignment_role='supervisor' and a.status='active' and a.released_at is null) then
  return jsonb_build_object('ok',false,'code','supervisor_access_denied','message','An active supervisor assignment to this case is required.');
 end if;
 select * into v_old from game.police_personnel where personnel_ref=btrim(p_from_personnel_ref);
 select * into v_new from game.police_personnel where personnel_ref=btrim(p_to_personnel_ref);
 if v_old.id is null or v_new.id is null or v_old.employment_status not in ('active','seconded') or v_new.employment_status not in ('active','seconded') then
  return jsonb_build_object('ok',false,'code','personnel_unavailable','message','Both outgoing and incoming leads must be active or seconded personnel.');
 end if;
 if v_case.lead_personnel_id is distinct from v_old.id then
  return jsonb_build_object('ok',false,'code','outgoing_lead_mismatch','message','The named outgoing officer is not the current case lead.');
 end if;
 if v_old.id=v_new.id then return jsonb_build_object('ok',false,'code','same_lead','message','The incoming lead must be a different officer.'); end if;
 v_assignment:=game.assign_case_investigator(v_case.case_ref,v_new.personnel_ref,'lead_investigator',
  (select personnel_ref from game.police_personnel where id=p_actor_personnel_id),p_source_command_id);
 if not coalesce((v_assignment->>'ok')::boolean,false) then return v_assignment; end if;
 v_ref:='KHO-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
 insert into game.case_handover_events(handover_ref,case_id,previous_lead_personnel_id,new_lead_personnel_id,
  transferred_by_personnel_id,continuity_note,transferred_at_game_time,source_command_id)
 values(v_ref,v_case.id,v_old.id,v_new.id,p_actor_personnel_id,btrim(p_note),v_clock,p_source_command_id);
 return jsonb_build_object('ok',true,'handover_ref',v_ref,'case_ref',v_case.case_ref,
  'previous_lead',v_old.personnel_ref,'new_lead',v_new.personnel_ref,'continuity_note',btrim(p_note),
  'transferred_at_game_time',v_clock,'assignment',v_assignment);
end $$;

create or replace function game.get_case_handovers(p_case_ref text)
returns jsonb language plpgsql stable set search_path=pg_catalog,game as $$
declare v_case game.cases%rowtype;
begin
 select * into v_case from game.cases where case_ref=btrim(p_case_ref);
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference was not found.'); end if;
 return jsonb_build_object('ok',true,'case_ref',v_case.case_ref,
  'handovers',(select coalesce(jsonb_agg(jsonb_build_object('handover_ref',h.handover_ref,
   'from',oldp.personnel_ref,'to',newp.personnel_ref,'transferred_by',actor.personnel_ref,
   'continuity_note',h.continuity_note,'transferred_at_game_time',h.transferred_at_game_time)
   order by h.transferred_at_game_time,h.created_at),'[]'::jsonb)
   from game.case_handover_events h
   join game.police_personnel oldp on oldp.id=h.previous_lead_personnel_id
   join game.police_personnel newp on newp.id=h.new_lead_personnel_id
   join game.police_personnel actor on actor.id=h.transferred_by_personnel_id
   where h.case_id=v_case.id));
end $$;

alter function game.interpret_text_command(text) rename to interpret_text_command_before_case_handovers;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path=pg_catalog,game as $$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^case transfer ([^[:space:]]+) from ([^[:space:]]+) to ([^[:space:]]+) because "(.+)" by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','transfer_case_lead',
  'payload',jsonb_build_object('case_ref',m[1],'from_ref',m[2],'to_ref',m[3],'note',m[4],'actor_ref',m[5])); end if;
 m:=regexp_match(t,'^case handovers ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','get_case_handovers',
  'payload',jsonb_build_object('case_ref',m[1],'actor_ref',m[2])); end if;
 return game.interpret_text_command_before_case_handovers(p_command_text);
end $$;

alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_case_handovers;
create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare v_i jsonb; v_type text; v_payload jsonb; v_cmd game.game_commands%rowtype;
 v_result jsonb; v_actor game.police_personnel%rowtype; v_case_id uuid;
begin
 v_i:=game.interpret_text_command(p_command_text); v_type:=v_i->>'command_type'; v_payload:=coalesce(v_i->'payload','{}'::jsonb);
 if v_type='help' then
  v_result:=game.execute_text_command_before_case_handovers(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  v_result:=jsonb_set(v_result,'{available_commands}',(select coalesce(jsonb_agg(distinct x),'[]'::jsonb)
   from jsonb_array_elements_text(coalesce(v_result->'available_commands','[]'::jsonb)||jsonb_build_array('transfer_case_lead','get_case_handovers')) x),true);
  return v_result;
 end if;
 if v_type not in ('transfer_case_lead','get_case_handovers') then
  return game.execute_text_command_before_case_handovers(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
 end if;
 if p_command_text is null or char_length(btrim(p_command_text)) not between 1 and 4000 then raise exception 'Command text must contain between 1 and 4000 characters'; end if;
 if p_idempotency_key is null or char_length(p_idempotency_key) not between 8 and 200 then raise exception 'A unique idempotency key between 8 and 200 characters is required'; end if;
 insert into game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload)
 values(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,v_type,v_payload) on conflict(idempotency_key) do nothing;
 if not found then
  select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
  if v_cmd.command_text<>p_command_text or v_cmd.command_type<>v_type or v_cmd.payload<>v_payload then
   return jsonb_build_object('ok',false,'code','idempotency_conflict','message','This command key was already used for a different command.','command_id',v_cmd.id);
  end if;
  return coalesce(v_cmd.result,jsonb_build_object('ok',v_cmd.status='completed','status',v_cmd.status,'command_id',v_cmd.id))||jsonb_build_object('duplicate',true);
 end if;
 select * into v_cmd from game.game_commands where idempotency_key=p_idempotency_key for update;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(v_payload->>'actor_ref');
 select id into v_case_id from game.cases where case_ref=btrim(v_payload->>'case_ref');
 if not found then v_result:=jsonb_build_object('ok',false,'code','case_not_found','message','Case reference was not found.');
 elsif v_actor.id is null or v_actor.employment_status not in ('active','seconded') or (p_actor_personnel_id is not null and p_actor_personnel_id<>v_actor.id) then
  v_result:=jsonb_build_object('ok',false,'code','actor_mismatch','message','The named command actor must match active or seconded personnel.');
 elsif not exists(select 1 from game.case_assignments a where a.case_id=v_case_id and a.personnel_id=v_actor.id and a.assignment_role='supervisor' and a.status='active' and a.released_at is null) then
  v_result:=jsonb_build_object('ok',false,'code','supervisor_access_denied','message','An active supervisor assignment to this case is required.');
 else
  begin
   if v_type='transfer_case_lead' then
    v_result:=game.transfer_case_lead(v_payload->>'case_ref',v_payload->>'from_ref',v_payload->>'to_ref',v_payload->>'note',v_actor.id,v_cmd.id);
   else v_result:=game.get_case_handovers(v_payload->>'case_ref'); end if;
  exception when others then v_result:=jsonb_build_object('ok',false,'code','case_handover_rejected','message',sqlerrm); end;
 end if;
 if coalesce((v_result->>'ok')::boolean,false) then
  v_result:=v_result||jsonb_build_object('status','completed','command_id',v_cmd.id);
  update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_cmd.id;
 else
  update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Case handover rejected.'),result=v_result,completed_at=now() where id=v_cmd.id;
  v_result:=v_result||jsonb_build_object('command_id',v_cmd.id);
 end if;
 return v_result;
end $$;

revoke all on function game.transfer_case_lead(text,text,text,text,uuid,uuid),game.get_case_handovers(text),
 game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.transfer_case_lead(text,text,text,text,uuid,uuid),game.get_case_handovers(text),
 game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) to service_role;
