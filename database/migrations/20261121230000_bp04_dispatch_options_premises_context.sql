-- BP-04: expose canonical premises context inside the normal dispatch-options incident dossier.
-- This is a read-model composition only; it does not change incident location or dispatch behaviour.
create or replace function game.get_dispatch_options(p_incident_ref text)
returns jsonb language plpgsql volatile set search_path=''
as $function$
declare
  v_incident jsonb;
  v_candidates jsonb;
  v_premises jsonb;
  v_clock timestamptz;
begin
  select s.current_game_time into v_clock
  from game.simulation_state s where s.id=1;
  if v_clock is null then
    raise exception 'The fictional game clock is not initialized.';
  end if;

  select jsonb_build_object(
    'incident_ref',i.incident_ref,
    'summary',i.summary,
    'priority',i.priority,
    'status',i.status,
    'location',coalesce(i.location_description,pa.formatted_address),
    'game_time',v_clock
  )
  into v_incident
  from game.incidents i
  left join game.property_addresses pa on pa.property_id=i.location_property_id
  where i.incident_ref=p_incident_ref and i.status in ('new','graded','queued');

  if v_incident is null then
    raise exception 'Incident not found or not currently dispatchable.';
  end if;

  v_premises:=game.get_incident_site_context(p_incident_ref);
  v_incident:=v_incident||jsonb_build_object('premises_context',v_premises);

  select coalesce(jsonb_agg(
    jsonb_build_object(
      'unit_ref',c.unit_ref,
      'unit_name',c.unit_name,
      'base_facility',c.base_facility,
      'available_officer_count',c.eligible_personnel_count,
      'route_status',c.route_status,
      'route_ref',c.route_ref,
      'distance_m',c.distance_m,
      'estimated_duration_seconds',c.estimated_duration_seconds,
      'estimated_arrival_at',c.estimated_arrival_at,
      'route_basis',c.route_basis,
      'officers',coalesce((
        select jsonb_agg(jsonb_build_object(
          'personnel_ref',pp.personnel_ref,
          'name',concat_ws(' ',nullif(p.preferred_name,''),p.given_name,nullif(p.middle_names,''),p.family_name),
          'service_number',pp.service_number
        ) order by pp.personnel_ref)
        from unnest(c.personnel_refs) x(personnel_ref)
        join game.police_personnel pp on pp.personnel_ref=x.personnel_ref
        join game.persons p on p.id=pp.person_id
      ),'[]'::jsonb)
    ) order by c.estimated_arrival_at nulls last,
      c.estimated_duration_seconds nulls last,c.distance_m nulls last,c.unit_ref
  ),'[]'::jsonb)
  into v_candidates
  from game.get_dispatch_candidates_ranked(p_incident_ref) c;

  return jsonb_build_object(
    'incident',v_incident,
    'candidate_count',jsonb_array_length(v_candidates),
    'candidates',v_candidates,
    'selection_note','Read-only options; no unit or officer has been dispatched.'
  );
end;
$function$;

revoke all on function game.get_dispatch_options(text) from public,anon,authenticated;
grant execute on function game.get_dispatch_options(text) to service_role;
