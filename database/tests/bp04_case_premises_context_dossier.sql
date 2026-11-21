-- BP-04 case premises context regression.
begin;
do $$
declare
  v_result jsonb;
  v_definition text;
begin
  if to_regprocedure('game.get_case_premises_context(text)') is null then
    raise exception 'Case premises context function is missing';
  end if;

  v_result:=game.get_case_premises_context('KNG-CASE-DOES-NOT-EXIST');
  if coalesce((v_result->>'ok')::boolean,true)
    or v_result->>'code'<>'case_not_found'
    or jsonb_typeof(v_result->'sites')<>'array' then
    raise exception 'Unknown case must return stable not-found response with empty sites: %',v_result;
  end if;

  select pg_get_functiondef('game.get_case_premises_context(text)'::regprocedure)
    into v_definition;
  if position('incident_site_associations' in v_definition)=0
    or position('case_lead_entity_links' in v_definition)=0
    or position('entity_type=''site''' in v_definition)=0
    or position('get_organisation_site_record' in v_definition)=0 then
    raise exception 'Case premises context must compose explicit incident and lead site links with canonical site dossiers';
  end if;

  select pg_get_functiondef('game.get_case_review_dossier(text)'::regprocedure)
    into v_definition;
  if position('get_case_premises_context' in v_definition)=0 then
    raise exception 'Comprehensive case dossier does not include premises context';
  end if;
end;
$$;
rollback;
