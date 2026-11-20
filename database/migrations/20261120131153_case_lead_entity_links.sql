create sequence game.case_lead_entity_link_ref_seq;
create table game.case_lead_entity_links (
 id uuid primary key default gen_random_uuid(),
 link_ref text not null unique default ('KNG-LINK-'||lpad(nextval('game.case_lead_entity_link_ref_seq')::text,7,'0')),
 lead_id uuid not null references game.case_leads(id) on delete restrict,
 case_id uuid not null references game.cases(id) on delete restrict,
 entity_type text not null check(entity_type in ('person','organisation','property','evidence','incident')),
 entity_ref text not null,
 person_id uuid references game.persons(id) on delete restrict,
 organisation_id uuid references game.organisations(id) on delete restrict,
 property_id uuid references game.properties(id) on delete restrict,
 evidence_id uuid references game.evidence_items(id) on delete restrict,
 incident_id uuid references game.incidents(id) on delete restrict,
 reason text not null check(length(btrim(reason)) between 3 and 2000),
 linked_by_personnel_id uuid not null references game.police_personnel(id) on delete restrict,
 linked_at_game_time timestamptz not null,
 source_command_id uuid references game.game_commands(id) on delete restrict,
 created_at timestamptz not null default now(),
 constraint case_lead_entity_link_exactly_one check (
 (entity_type='person' and person_id is not null and num_nonnulls(organisation_id,property_id,evidence_id,incident_id)=0) or
 (entity_type='organisation' and organisation_id is not null and num_nonnulls(person_id,property_id,evidence_id,incident_id)=0) or
 (entity_type='property' and property_id is not null and num_nonnulls(person_id,organisation_id,evidence_id,incident_id)=0) or
 (entity_type='evidence' and evidence_id is not null and num_nonnulls(person_id,organisation_id,property_id,incident_id)=0) or
 (entity_type='incident' and incident_id is not null and num_nonnulls(person_id,organisation_id,property_id,evidence_id)=0)
 ), unique(lead_id,entity_type,entity_ref)
);
create index case_lead_entity_links_lead_idx on game.case_lead_entity_links(lead_id,linked_at_game_time);
create index case_lead_entity_links_person_idx on game.case_lead_entity_links(person_id) where person_id is not null;
create index case_lead_entity_links_org_idx on game.case_lead_entity_links(organisation_id) where organisation_id is not null;
create index case_lead_entity_links_property_idx on game.case_lead_entity_links(property_id) where property_id is not null;
create index case_lead_entity_links_evidence_idx on game.case_lead_entity_links(evidence_id) where evidence_id is not null;
create index case_lead_entity_links_incident_idx on game.case_lead_entity_links(incident_id) where incident_id is not null;
alter table game.case_lead_entity_links enable row level security;
revoke all on game.case_lead_entity_links from public,anon,authenticated;
grant select,insert on game.case_lead_entity_links to service_role;
grant usage,select on sequence game.case_lead_entity_link_ref_seq to service_role;
create trigger case_lead_entity_links_append_only before update or delete on game.case_lead_entity_links for each row execute function game.reject_case_investigation_history_mutation();

create or replace function game.link_case_lead_entity(p_lead_ref text,p_entity_type text,p_entity_ref text,p_reason text,p_actor_ref text,p_command_id uuid)
returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare v_lead game.case_leads%rowtype; v_actor game.police_personnel%rowtype; v_clock timestamptz; v_person uuid; v_org uuid; v_property uuid; v_evidence uuid; v_incident uuid; v_existing game.case_lead_entity_links%rowtype; v_link game.case_lead_entity_links%rowtype;
begin
 select * into v_lead from game.case_leads where lead_ref=btrim(p_lead_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','lead_not_found','message','Lead reference not found.'); end if;
 if v_lead.status in ('resolved','closed','disproved') then return jsonb_build_object('ok',false,'code','lead_inactive','message','A terminal lead cannot receive new entity links.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found then return jsonb_build_object('ok',false,'code','actor_unavailable','message','The acting officer must be active or seconded.'); end if;
 if v_lead.assigned_personnel_id is distinct from v_actor.id and not exists(select 1 from game.case_assignments a where a.case_id=v_lead.case_id and a.personnel_id=v_actor.id and a.status='active') then
 return jsonb_build_object('ok',false,'code','not_assigned','message','The acting officer must own the lead or hold an active assignment to its case.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before linking investigative entities.'); end if;
 if length(btrim(coalesce(p_reason,''))) not between 3 and 2000 then return jsonb_build_object('ok',false,'code','invalid_reason','message','A reason between 3 and 2000 characters is required.'); end if;
 case p_entity_type
 when 'person' then select id into v_person from game.persons where person_ref=btrim(p_entity_ref);
 when 'organisation' then select id into v_org from game.organisations where organisation_ref=btrim(p_entity_ref);
 when 'property' then select id into v_property from game.properties where property_ref=btrim(p_entity_ref);
 when 'evidence' then select id into v_evidence from game.evidence_items where evidence_ref=btrim(p_entity_ref) and (case_id is null or case_id=v_lead.case_id);
 when 'incident' then select id into v_incident from game.incidents where incident_ref=btrim(p_entity_ref);
 else return jsonb_build_object('ok',false,'code','invalid_entity_type','message','Entity type must be person, organisation, property, evidence or incident.');
 end case;
 if v_person is null and v_org is null and v_property is null and v_evidence is null and v_incident is null then return jsonb_build_object('ok',false,'code','entity_not_found','message','The referenced existing game entity was not found or is not linkable to this case.'); end if;
 select * into v_existing from game.case_lead_entity_links where lead_id=v_lead.id and entity_type=p_entity_type and entity_ref=btrim(p_entity_ref);
 if found then return jsonb_build_object('ok',true,'duplicate',true,'link_ref',v_existing.link_ref,'lead_ref',v_lead.lead_ref,'entity_type',p_entity_type,'entity_ref',p_entity_ref,'message','This entity is already linked to the lead.'); end if;
 insert into game.case_lead_entity_links(lead_id,case_id,entity_type,entity_ref,person_id,organisation_id,property_id,evidence_id,incident_id,reason,linked_by_personnel_id,linked_at_game_time,source_command_id)
 values(v_lead.id,v_lead.case_id,p_entity_type,btrim(p_entity_ref),v_person,v_org,v_property,v_evidence,v_incident,btrim(p_reason),v_actor.id,v_clock,p_command_id) returning * into v_link;
 return jsonb_build_object('ok',true,'link_ref',v_link.link_ref,'lead_ref',v_lead.lead_ref,'entity_type',p_entity_type,'entity_ref',p_entity_ref,'game_time',v_clock,'message','Existing game entity linked to investigative lead.');
end $$;

create or replace function game.get_case_lead_entity_links(p_lead_ref text)
returns jsonb language plpgsql stable set search_path to 'pg_catalog','game' as $$
declare v_lead game.case_leads%rowtype; v_rows jsonb;
begin
 select * into v_lead from game.case_leads where lead_ref=btrim(p_lead_ref);
 if not found then return jsonb_build_object('ok',false,'code','lead_not_found','message','Lead reference not found.'); end if;
 select coalesce(jsonb_agg(jsonb_build_object('link_ref',l.link_ref,'entity_type',l.entity_type,'entity_ref',l.entity_ref,'reason',l.reason,'linked_by',pp.personnel_ref,'game_time',l.linked_at_game_time) order by l.linked_at_game_time,l.link_ref),'[]'::jsonb)
 into v_rows from game.case_lead_entity_links l join game.police_personnel pp on pp.id=l.linked_by_personnel_id where l.lead_id=v_lead.id;
 return jsonb_build_object('ok',true,'lead_ref',v_lead.lead_ref,'count',jsonb_array_length(v_rows),'links',v_rows);
end $$;

alter function game.interpret_text_command(text) rename to interpret_text_command_before_lead_entity_links;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game' as $$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^case lead link ([^[:space:]]+) entity (person|organisation|property|evidence|incident) ([^[:space:]]+) because "([^"]+)" by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','link_case_lead_entity','payload',jsonb_build_object('lead_ref',m[1],'entity_type',lower(m[2]),'entity_ref',m[3],'reason',m[4],'actor_ref',m[5])); end if;
 m:=regexp_match(t,'^case lead links ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','list_case_lead_entity_links','payload',jsonb_build_object('lead_ref',m[1])); end if;
 return game.interpret_text_command_before_lead_entity_links(p_command_text);
end $$;

alter function game.execute_text_command(text,text,uuid,uuid) rename to execute_text_command_before_lead_entity_links;
create or replace function game.execute_text_command(p_command_text text,p_idempotency_key text,p_session_id uuid default null,p_actor_personnel_id uuid default null)
returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare v_i jsonb; v_type text; v_payload jsonb; v_cmd game.game_commands%rowtype; v_result jsonb; v_actor game.police_personnel%rowtype;
begin
 v_i:=game.interpret_text_command(p_command_text); v_type:=v_i->>'command_type'; v_payload:=coalesce(v_i->'payload','{}'::jsonb);
 if coalesce((v_i->>'recognized')::boolean,false)=false or v_type not in ('link_case_lead_entity','list_case_lead_entity_links') then
  v_result:=game.execute_text_command_before_lead_entity_links(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  if v_type='help' and coalesce((v_result->>'ok')::boolean,false) then return jsonb_set(v_result,'{available_commands}',coalesce(v_result->'available_commands','[]'::jsonb)||jsonb_build_array('link_case_lead_entity','list_case_lead_entity_links')); end if;
  return v_result;
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
 if v_type='link_case_lead_entity' then
  select * into v_actor from game.police_personnel where personnel_ref=btrim(v_payload->>'actor_ref');
  if not found or (p_actor_personnel_id is not null and p_actor_personnel_id<>v_actor.id) then v_result:=jsonb_build_object('ok',false,'code','actor_mismatch','message','The command actor must match the named police personnel record.');
  else v_result:=game.link_case_lead_entity(v_payload->>'lead_ref',v_payload->>'entity_type',v_payload->>'entity_ref',v_payload->>'reason',v_payload->>'actor_ref',v_cmd.id); end if;
 else v_result:=game.get_case_lead_entity_links(v_payload->>'lead_ref'); end if;
 if coalesce((v_result->>'ok')::boolean,false) then
  v_result:=v_result||jsonb_build_object('status','completed','command_id',v_cmd.id);
  update game.game_commands set status='completed',result=v_result,completed_at=now() where id=v_cmd.id;
 else
  update game.game_commands set status='rejected',rejection_reason=coalesce(v_result->>'message','Lead entity-link command rejected.'),result=v_result,completed_at=now() where id=v_cmd.id;
  v_result:=v_result||jsonb_build_object('command_id',v_cmd.id);
 end if;
 return v_result;
end $$;
revoke all on function game.link_case_lead_entity(text,text,text,text,text,uuid),game.get_case_lead_entity_links(text),game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) from public,anon,authenticated;
grant execute on function game.link_case_lead_entity(text,text,text,text,text,uuid),game.get_case_lead_entity_links(text),game.interpret_text_command(text),game.execute_text_command(text,text,uuid,uuid) to service_role;