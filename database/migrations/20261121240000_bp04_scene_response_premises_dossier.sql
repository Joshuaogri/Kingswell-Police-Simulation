-- BP-04: complete read-only on-scene response dossier with canonical premises context.
-- Composes existing incident, scene, dispatch, field, safety, access and specialist records.
-- Does not create or mutate incident location, deployment or scene records.
create or replace function game.get_scene_response_record(p_scene_ref text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $function$
declare
  v_scene_id uuid;
  v_incident_id uuid;
  v_incident_ref text;
  v_scene jsonb;
  v_incident jsonb;
  v_deployments jsonb;
  v_activity jsonb;
  v_access jsonb;
  v_reports jsonb;
  v_resources jsonb;
  v_safety jsonb;
  v_boundaries jsonb;
  v_specialists jsonb;
  v_examinations jsonb;
begin
  select s.id,s.incident_id,i.incident_ref,
    jsonb_build_object(
      'scene_ref',s.scene_ref,'scene_type',s.scene_type,
      'location_description',s.location_description,
      'designation_reason',s.designation_reason,'confidence',s.confidence,
      'status',s.status,'control_basis',s.control_basis,
      'scene_manager',manager.personnel_ref,
      'discovered_at',s.discovered_at,'attended_at',s.attended_at,
      'control_started_at',s.control_started_at,'released_at',s.released_at,
      'created_at',s.created_at
    )
  into v_scene_id,v_incident_id,v_incident_ref,v_scene
  from game.incident_scenes s
  join game.incidents i on i.id=s.incident_id
  left join game.police_personnel manager on manager.id=s.scene_manager_personnel_id
  where s.scene_ref=btrim(coalesce(p_scene_ref,''));

  if v_scene_id is null then
    return jsonb_build_object('ok',false,'code','scene_not_found',
      'message','No scene exists with that reference.');
  end if;

  select jsonb_build_object(
    'incident_ref',i.incident_ref,'summary',i.summary,'priority',i.priority,
    'status',i.status,'location_description',i.location_description,
    'premises_context',game.get_incident_site_context(i.incident_ref)
  )
  into v_incident
  from game.incidents i where i.id=v_incident_id;

  select coalesce(jsonb_agg(jsonb_build_object(
    'personnel_ref',pp.personnel_ref,'name',concat_ws(' ',p.given_name,p.family_name),
    'unit_ref',u.unit_ref,'deployment_role',d.deployment_role,
    'status',d.status,'dispatched_at',d.dispatched_at,
    'arrived_at',d.arrived_at,'cleared_at',d.cleared_at
  ) order by d.dispatched_at,pp.personnel_ref),'[]'::jsonb)
  into v_deployments
  from game.incident_deployments d
  join game.police_personnel pp on pp.id=d.personnel_id
  join game.persons p on p.id=pp.person_id
  left join game.police_units u on u.id=d.unit_id
  where d.incident_id=v_incident_id;

  select coalesce(jsonb_agg(jsonb_build_object(
    'event_at',l.event_at,'event_type',l.event_type,
    'personnel_ref',pp.personnel_ref,'description',l.description,'details',l.details
  ) order by l.event_at,l.id),'[]'::jsonb)
  into v_activity
  from game.scene_activity_logs l
  left join game.police_personnel pp on pp.id=l.personnel_id
  where l.scene_id=v_scene_id;

  select coalesce(jsonb_agg(jsonb_build_object(
    'event_at',a.event_at,'action',a.action,'personnel_ref',pp.personnel_ref,
    'organisation_name',a.organisation_name,'role_description',a.role_description,
    'zone_ref',a.zone_ref,'purpose',a.purpose,'recorded_by',recorder.personnel_ref
  ) order by a.event_at,a.id),'[]'::jsonb)
  into v_access
  from game.scene_access_events a
  join game.police_personnel pp on pp.id=a.personnel_id
  join game.police_personnel recorder on recorder.id=a.recorded_by_personnel_id
  where a.scene_id=v_scene_id;

  select coalesce(jsonb_agg(jsonb_build_object(
    'report_ref',r.report_ref,'report_type',r.report_type,
    'personnel_ref',pp.personnel_ref,'observed_at',r.observed_at,
    'submitted_at',r.submitted_at,'narrative',r.narrative,
    'observations',r.observations,'actions',r.actions
  ) order by r.submitted_at desc,r.id),'[]'::jsonb)
  into v_reports
  from game.incident_field_reports r
  join game.police_personnel pp on pp.id=r.personnel_id
  where r.scene_id=v_scene_id or (r.scene_id is null and r.incident_id=v_incident_id);

  select coalesce(jsonb_agg(jsonb_build_object(
    'request_ref',r.request_ref,'resource_type',r.resource_type,
    'quantity',r.quantity,'priority',r.priority,'reason',r.reason,
    'status',r.status,'requested_at',r.requested_at,
    'responded_at',r.responded_at,'response_notes',r.response_notes,
    'requested_by',requester.personnel_ref,'fulfilled_by',fulfiller.personnel_ref
  ) order by r.requested_at,r.id),'[]'::jsonb)
  into v_resources
  from game.incident_resource_requests r
  join game.police_personnel requester on requester.id=r.requested_by_personnel_id
  left join game.police_personnel fulfiller on fulfiller.id=r.fulfilled_by_personnel_id
  where r.scene_id=v_scene_id;

  select coalesce(jsonb_agg(jsonb_build_object(
    'assessed_at',a.assessed_at,'assessed_by',pp.personnel_ref,
    'hazard_summary',a.hazard_summary,'people_at_risk',a.people_at_risk,
    'controls_taken',a.controls_taken,'residual_risk',a.residual_risk,
    'specialist_support_required',a.specialist_support_required,'details',a.details
  ) order by a.assessed_at desc,a.id),'[]'::jsonb)
  into v_safety
  from game.scene_safety_assessments a
  join game.police_personnel pp on pp.id=a.assessed_by_personnel_id
  where a.scene_id=v_scene_id;

  select coalesce(jsonb_agg(jsonb_build_object(
    'boundary_ref',b.boundary_ref,'description',b.boundary_description,
    'rationale',b.rationale,'status',b.status,'effective_at',b.effective_at,
    'set_by',pp.personnel_ref
  ) order by b.effective_at desc,b.id),'[]'::jsonb)
  into v_boundaries
  from game.scene_boundary_revisions b
  join game.police_personnel pp on pp.id=b.set_by_personnel_id
  where b.scene_id=v_scene_id;

  select coalesce(jsonb_agg(jsonb_build_object(
    'attendance_ref',a.attendance_ref,'personnel_ref',pp.personnel_ref,
    'unit_ref',u.unit_ref,'discipline',a.discipline,'purpose',a.purpose,
    'attended_at',a.attended_at,'departed_at',a.departed_at,
    'departure_reason',a.departure_reason,'status',a.status
  ) order by a.attended_at,a.id),'[]'::jsonb)
  into v_specialists
  from game.scene_specialist_attendances a
  join game.police_personnel pp on pp.id=a.personnel_id
  left join game.police_units u on u.id=a.unit_id
  where a.scene_id=v_scene_id;

  select coalesce(jsonb_agg(jsonb_build_object(
    'plan_ref',p.plan_ref,'attendance_ref',a.attendance_ref,
    'examiner',examiner.personnel_ref,'discipline',p.discipline,
    'examination_question',p.examination_question,'scope',p.scope,
    'known_limitations',p.known_limitations,'status',p.status,
    'created_at',p.created_at,'started_at',p.started_at,
    'completed_at',p.completed_at,'record',case when r.id is null then null else
      jsonb_build_object('recorded_at',r.recorded_at,'observations',r.observations,
        'findings',r.findings,'limitations',r.limitations) end
  ) order by p.created_at,p.id),'[]'::jsonb)
  into v_examinations
  from game.scene_examination_plans p
  join game.scene_specialist_attendances a on a.id=p.attendance_id
  join game.police_personnel examiner on examiner.id=p.examiner_personnel_id
  left join game.scene_examination_records r on r.plan_id=p.id
  where p.scene_id=v_scene_id;

  return jsonb_build_object(
    'ok',true,'record_type','scene_response','scene',v_scene,
    'incident',v_incident,'deployments',v_deployments,
    'activity',v_activity,'access_log',v_access,
    'field_reports',v_reports,'resource_requests',v_resources,
    'safety_assessments',v_safety,'boundary_history',v_boundaries,
    'specialist_attendance',v_specialists,'examination_plans',v_examinations,
    'coverage',jsonb_build_object(
      'premises_context_included',true,
      'incident_location_and_related_sites_distinguished',true,
      'empty_arrays_mean_no_records_found',true,
      'no_incident_or_scene_location_was_inferred',true
    )
  );
end;
$function$;

revoke all on function game.get_scene_response_record(text) from public,anon,authenticated;
grant execute on function game.get_scene_response_record(text) to service_role;
