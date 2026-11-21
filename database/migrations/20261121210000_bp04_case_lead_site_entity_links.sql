-- BP-04 / investigations: link a case lead directly to a canonical organisation premises site.
-- Extends the existing lead-entity link register; no duplicate site/property records.
alter table game.case_lead_entity_links
 add column if not exists organisation_location_id uuid
 references game.organisation_locations(id) on delete restrict;

alter table game.case_lead_entity_links
 drop constraint if exists case_lead_entity_links_entity_type_check;
alter table game.case_lead_entity_links
 add constraint case_lead_entity_links_entity_type_check
 check(entity_type in ('person','organisation','property','site','evidence','incident'));

alter table game.case_lead_entity_links
 drop constraint if exists case_lead_entity_link_exactly_one;
alter table game.case_lead_entity_links
 add constraint case_lead_entity_link_exactly_one check (
  (entity_type='person' and person_id is not null and num_nonnulls(organisation_id,property_id,organisation_location_id,evidence_id,incident_id)=0) or
  (entity_type='organisation' and organisation_id is not null and num_nonnulls(person_id,property_id,organisation_location_id,evidence_id,incident_id)=0) or
  (entity_type='property' and property_id is not null and num_nonnulls(person_id,organisation_id,organisation_location_id,evidence_id,incident_id)=0) or
  (entity_type='site' and organisation_location_id is not null and num_nonnulls(person_id,organisation_id,property_id,evidence_id,incident_id)=0) or
  (entity_type='evidence' and evidence_id is not null and num_nonnulls(person_id,organisation_id,property_id,organisation_location_id,incident_id)=0) or
  (entity_type='incident' and incident_id is not null and num_nonnulls(person_id,organisation_id,property_id,evidence_id,organisation_location_id)=0)
 );
create index if not exists case_lead_entity_links_site_idx
 on game.case_lead_entity_links(organisation_location_id)
 where organisation_location_id is not null;

create or replace function game.link_case_lead_entity(
 p_lead_ref text,p_entity_type text,p_entity_ref text,p_reason text,p_actor_ref text,p_command_id uuid
) returns jsonb language plpgsql set search_path to 'pg_catalog','game' as $$
declare
 v_lead game.case_leads%rowtype; v_actor game.police_personnel%rowtype;
 v_clock timestamptz; v_person uuid; v_org uuid; v_property uuid;
 v_site uuid; v_evidence uuid; v_incident uuid;
 v_existing game.case_lead_entity_links%rowtype; v_link game.case_lead_entity_links%rowtype;
begin
 select * into v_lead from game.case_leads where lead_ref=btrim(p_lead_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','lead_not_found','message','Lead reference not found.'); end if;
 if v_lead.status in ('resolved','closed','disproved') then return jsonb_build_object('ok',false,'code','lead_inactive','message','A terminal lead cannot receive new entity links.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found then return jsonb_build_object('ok',false,'code','actor_unavailable','message','The acting officer must be active or seconded.'); end if;
 if v_lead.assigned_personnel_id is distinct from v_actor.id and not exists(
  select 1 from game.case_assignments a where a.case_id=v_lead.case_id and a.personnel_id=v_actor.id and a.status='active'
 ) then return jsonb_build_object('ok',false,'code','not_assigned','message','The acting officer must own the lead or hold an active assignment to its case.'); end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before linking investigative entities.'); end if;
 if length(btrim(coalesce(p_reason,''))) not between 3 and 2000 then return jsonb_build_object('ok',false,'code','invalid_reason','message','A reason between 3 and 2000 characters is required.'); end if;
 case p_entity_type
 when 'person' then select id into v_person from game.persons where person_ref=btrim(p_entity_ref);
 when 'organisation' then select id into v_org from game.organisations where organisation_ref=btrim(p_entity_ref);
 when 'property' then select id into v_property from game.properties where property_ref=btrim(p_entity_ref);
 when 'site' then select organisation_location_id into v_site from game.organisation_site_dossiers where site_ref=btrim(p_entity_ref);
 when 'evidence' then select id into v_evidence from game.evidence_items where evidence_ref=btrim(p_entity_ref) and (case_id is null or case_id=v_lead.case_id);
 when 'incident' then select id into v_incident from game.incidents where incident_ref=btrim(p_entity_ref);
 else return jsonb_build_object('ok',false,'code','invalid_entity_type','message','Entity type must be person, organisation, property, site, evidence or incident.');
 end case;
 if v_person is null and v_org is null and v_property is null and v_site is null and v_evidence is null and v_incident is null then
  return jsonb_build_object('ok',false,'code','entity_not_found','message','The referenced existing game entity was not found or is not linkable to this case.');
 end if;
 select * into v_existing from game.case_lead_entity_links
 where lead_id=v_lead.id and entity_type=p_entity_type and entity_ref=btrim(p_entity_ref);
 if found then return jsonb_build_object('ok',true,'duplicate',true,'link_ref',v_existing.link_ref,'lead_ref',v_lead.lead_ref,'entity_type',p_entity_type,'entity_ref',p_entity_ref,'message','This entity is already linked to the lead.'); end if;
 insert into game.case_lead_entity_links(
  lead_id,case_id,entity_type,entity_ref,person_id,organisation_id,property_id,
  organisation_location_id,evidence_id,incident_id,reason,linked_by_personnel_id,
  linked_at_game_time,source_command_id
 ) values(
  v_lead.id,v_lead.case_id,p_entity_type,btrim(p_entity_ref),v_person,v_org,v_property,
  v_site,v_evidence,v_incident,btrim(p_reason),v_actor.id,v_clock,p_command_id
 ) returning * into v_link;
 return jsonb_build_object('ok',true,'link_ref',v_link.link_ref,'lead_ref',v_lead.lead_ref,
  'entity_type',p_entity_type,'entity_ref',p_entity_ref,'game_time',v_clock,
  'message','Existing game entity linked to investigative lead.');
end $$;

alter function game.interpret_text_command(text)
 rename to interpret_text_command_before_case_site_entity_links;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game' as $$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^case lead link ([^[:space:]]+) entity (person|organisation|property|site|evidence|incident) ([^[:space:]]+) because "([^"]+)" by ([^[:space:]]+)$','i');
 if m is not null then
  return jsonb_build_object('recognized',true,'command_type','link_case_lead_entity',
   'payload',jsonb_build_object('lead_ref',m[1],'entity_type',lower(m[2]),
    'entity_ref',m[3],'reason',m[4],'actor_ref',m[5]));
 end if;
 return game.interpret_text_command_before_case_site_entity_links(p_command_text);
end $$;

revoke all on function game.link_case_lead_entity(text,text,text,text,text,uuid),
 game.interpret_text_command(text) from public,anon,authenticated;
grant execute on function game.link_case_lead_entity(text,text,text,text,text,uuid),
 game.interpret_text_command(text) to service_role;
