-- BP-04 scene response dossier regression.
begin;
do $$
declare
  v_result jsonb;
  v_definition text;
begin
  if to_regprocedure('game.get_scene_response_record(text)') is null then
    raise exception 'Scene response dossier function is missing';
  end if;

  v_result:=game.get_scene_response_record('KNG-SCENE-DOES-NOT-EXIST');
  if coalesce((v_result->>'ok')::boolean,true) or v_result->>'code'<>'scene_not_found' then
    raise exception 'Unknown scene must return a stable not-found response: %',v_result;
  end if;

  select pg_get_functiondef('game.get_scene_response_record(text)'::regprocedure)
    into v_definition;
  if position('get_incident_site_context' in v_definition)=0
    or position('incident_deployments' in v_definition)=0
    or position('scene_activity_logs' in v_definition)=0
    or position('scene_access_events' in v_definition)=0
    or position('incident_field_reports' in v_definition)=0
    or position('incident_resource_requests' in v_definition)=0
    or position('scene_safety_assessments' in v_definition)=0
    or position('scene_boundary_revisions' in v_definition)=0
    or position('scene_specialist_attendances' in v_definition)=0
    or position('scene_examination_plans' in v_definition)=0 then
    raise exception 'Scene response dossier does not compose all required operational records';
  end if;

  if not exists (
    select 1 from pg_proc p
    join pg_namespace n on n.oid=p.pronamespace
    where n.nspname='game' and p.proname='get_scene_response_record'
      and p.prosecdef=true
  ) then
    raise exception 'Scene response dossier must run with controlled SECURITY DEFINER privileges';
  end if;
end;
$$;
rollback;
