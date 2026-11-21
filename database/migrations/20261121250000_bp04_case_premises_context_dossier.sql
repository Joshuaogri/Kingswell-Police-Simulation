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

-- Preserve the complete existing dossier by wrapping its current public function.
-- The underlying function may itself be a wrapper around earlier dossier sections;
-- never rewrite its body by matching a fragile textual return statement.
alter function game.get_case_review_dossier(text)
  rename to get_case_review_dossier_before_premises;

create or replace function game.get_case_review_dossier(p_case_ref text)
returns jsonb
language plpgsql
stable
set search_path to 'pg_catalog','game'
as $function$
declare
  v_result jsonb;
begin
  v_result:=game.get_case_review_dossier_before_premises(p_case_ref);

  if coalesce((v_result->>'ok')::boolean,false) is not true then
    return v_result;
  end if;

  return v_result || jsonb_build_object(
    'premises_context',
    game.get_case_premises_context(p_case_ref)
  );
end;
$function$;

revoke all on function game.get_case_review_dossier(text) from public,anon,authenticated;
grant execute on function game.get_case_review_dossier(text) to service_role;
