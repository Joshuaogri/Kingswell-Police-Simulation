-- BP-04: expose canonical premises context inside the investigative case dossier.
-- Sources are only explicit case-incident associations and explicit investigative lead site links.
-- The relationship/source remains visible; no incident location or site relationship is inferred.
create or replace function game.get_case_premises_context(p_case_ref text)
returns jsonb
language plpgsql
stable
set search_path to 'pg_catalog','game'
as $function$
declare
  v_case_id uuid;
  v_case_ref text;
  v_rows jsonb;
begin
  select c.id,c.case_ref into v_case_id,v_case_ref
  from game.cases c
  where c.case_ref=btrim(coalesce(p_case_ref,''));

  if v_case_id is null then
    return jsonb_build_object('ok',false,'code','case_not_found',
      'message','Case reference not found.','sites','[]'::jsonb);
  end if;

  with linked_sites as (
    select
      a.organisation_location_id,
      d.site_ref,
      'incident_association'::text as link_source,
      a.relation_type as relationship,
      i.incident_ref as source_ref,
      a.reason as link_reason,
      pp.personnel_ref as linked_by,
      a.recorded_at_game_time as linked_at
    from game.case_incidents ci
    join game.incidents i on i.id=ci.incident_id
    join game.incident_site_associations a on a.incident_id=i.id
    join game.organisation_site_dossiers d
      on d.organisation_location_id=a.organisation_location_id
    join game.police_personnel pp on pp.id=a.recorded_by_personnel_id
    where ci.case_id=v_case_id

    union all

    select
      l.organisation_location_id,
      l.entity_ref as site_ref,
      'investigative_lead'::text as link_source,
      'lead_site'::text as relationship,
      lead.lead_ref as source_ref,
      l.reason as link_reason,
      pp.personnel_ref as linked_by,
      l.linked_at_game_time as linked_at
    from game.case_lead_entity_links l
    join game.case_leads lead on lead.id=l.lead_id
    join game.police_personnel pp on pp.id=l.linked_by_personnel_id
    where l.case_id=v_case_id
      and l.entity_type='site'
      and l.organisation_location_id is not null
  )
  select coalesce(jsonb_agg(
    jsonb_build_object(
      'site_ref',s.site_ref,
      'link_source',s.link_source,
      'relationship',s.relationship,
      'source_ref',s.source_ref,
      'reason',s.link_reason,
      'linked_by',s.linked_by,
      'linked_at_game_time',s.linked_at,
      'site_record',game.get_organisation_site_record(s.site_ref)
    )
    order by s.link_source,s.source_ref,s.site_ref
  ),'[]'::jsonb)
  into v_rows
  from linked_sites s;

  return jsonb_build_object(
    'ok',true,
    'case_ref',v_case_ref,
    'count',jsonb_array_length(v_rows),
    'sites',v_rows,
    'coverage',jsonb_build_object(
      'incident_site_associations_included',true,
      'investigative_lead_site_links_included',true,
      'only_explicit_links_included',true,
      'relationship_and_source_preserved',true,
      'unlinked_sites_not_inferred',true
    )
  );
end;
$function$;

-- Extend the existing comprehensive dossier in place; retain every existing section.
do $patch$
declare
  v_definition text;
  v_anchor text := ' return v_result;';
  v_replacement text := ' v_result:=v_result||jsonb_build_object(''premises_context'',game.get_case_premises_context(v_case.case_ref));'||E'\n return v_result;';
begin
  select pg_get_functiondef('game.get_case_review_dossier(text)'::regprocedure)
    into v_definition;
  if position(v_anchor in v_definition)=0 then
    raise exception 'Case dossier return anchor not found; refusing to replace an unexpected definition';
  end if;
  if position('get_case_premises_context' in v_definition)>0 then
    raise exception 'Case dossier already contains premises context; migration must not be applied twice';
  end if;
  v_definition:=replace(v_definition,v_anchor,v_replacement);
  execute v_definition;
end
$patch$;

revoke all on function game.get_case_premises_context(text) from public,anon,authenticated;
grant execute on function game.get_case_premises_context(text) to service_role;
