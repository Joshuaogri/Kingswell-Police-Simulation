alter table game.police_units
  add column if not exists current_access_point_id uuid references game.property_access_points(id),
  add column if not exists current_location_updated_at timestamptz;
alter table game.incident_deployments
  add column if not exists route_calculation_id uuid references game.road_route_calculations(id),
  add column if not exists route_origin_access_point_id uuid references game.property_access_points(id),
  add column if not exists route_destination_access_point_id uuid references game.property_access_points(id),
  add column if not exists route_status text,
  add column if not exists route_distance_m integer,
  add column if not exists route_estimated_seconds integer,
  add column if not exists estimated_arrival_at timestamptz,
  add column if not exists route_basis text,
  add column if not exists route_computed_at timestamptz;
alter table game.incident_deployments add constraint incident_deployments_route_status_check
  check (route_status is null or route_status in ('calculated','unreachable','location_unresolved'));
create table if not exists game.deployment_route_history (
  id uuid primary key default gen_random_uuid(),
  deployment_id uuid not null references game.incident_deployments(id) on delete cascade,
  route_calculation_id uuid references game.road_route_calculations(id),
  event_type text not null check (event_type in ('initial_route','route_recalculated','route_unavailable')),
  origin_access_point_id uuid references game.property_access_points(id),
  destination_access_point_id uuid references game.property_access_points(id),
  route_status text not null check (route_status in ('calculated','unreachable','location_unresolved')),
  distance_m integer, estimated_duration_seconds integer, estimated_arrival_at timestamptz,
  basis text not null, recorded_at timestamptz not null default now(),
  details jsonb not null default '{}'::jsonb
);
create index if not exists incident_deployments_route_calculation_idx on game.incident_deployments(route_calculation_id) where route_calculation_id is not null;
create index if not exists deployment_route_history_deployment_time_idx on game.deployment_route_history(deployment_id,recorded_at desc);
create index if not exists police_units_current_access_point_idx on game.police_units(current_access_point_id) where current_access_point_id is not null;
alter table game.deployment_route_history enable row level security;
revoke all on game.deployment_route_history from public, anon, authenticated;
grant select,insert,update,delete on game.deployment_route_history to service_role;
grant select,insert,update on game.incident_deployments to service_role;
grant select,update on game.police_units to service_role;
create or replace function game.snapshot_deployment_route()
returns trigger language plpgsql security invoker set search_path = '' as $function$
declare
  v_clock timestamptz; v_origin uuid; v_destination uuid; v_route uuid;
  v_status text := 'location_unresolved'; v_distance integer; v_seconds integer;
  v_eta timestamptz; v_basis text := 'No routable origin or incident property access point is recorded.';
begin
  select s.current_game_time into v_clock from game.simulation_state s where s.id=1;
  select coalesce(u.current_access_point_id,pf.access_point_id) into v_origin
  from game.police_units u left join game.police_facilities pf on pf.id=u.base_facility_id where u.id=new.unit_id;
  select ap.id into v_destination from game.incidents i
  join game.property_access_points ap on ap.property_id=i.location_property_id and ap.is_primary
  join game.road_segments rs on rs.id=ap.road_segment_id and rs.is_routable
  where i.id=new.incident_id order by ap.created_at limit 1;
  if v_origin is not null and v_destination is not null then
    begin
      v_route:=game.calculate_road_route(v_origin,v_destination,'police','fastest');
      select r.route_status,r.distance_m,r.estimated_duration_seconds into v_status,v_distance,v_seconds
      from game.road_route_calculations r where r.id=v_route;
      if v_status='calculated' then
        v_eta:=v_clock+make_interval(secs=>v_seconds);
        v_basis:='Baseline posted-speed estimate; no live traffic, siren uplift or turn-delay model.';
      else v_basis:='No connected route exists in the current routable road graph.'; end if;
    exception when others then
      v_route:=null; v_status:='location_unresolved'; v_basis:='Route calculation unavailable: '||sqlerrm;
    end;
  end if;
  update game.incident_deployments set route_calculation_id=v_route,
    route_origin_access_point_id=v_origin,route_destination_access_point_id=v_destination,
    route_status=v_status,route_distance_m=v_distance,route_estimated_seconds=v_seconds,
    estimated_arrival_at=v_eta,route_basis=v_basis,route_computed_at=coalesce(v_clock,now())
  where id=new.id;
  insert into game.deployment_route_history(deployment_id,route_calculation_id,event_type,
    origin_access_point_id,destination_access_point_id,route_status,distance_m,
    estimated_duration_seconds,estimated_arrival_at,basis,details)
  values(new.id,v_route,'initial_route',v_origin,v_destination,v_status,v_distance,v_seconds,v_eta,v_basis,
    jsonb_build_object('unit_id',new.unit_id,'incident_id',new.incident_id,'clock_time',v_clock,
      'origin_source',case when v_origin is null then 'missing'
        when exists(select 1 from game.police_units u where u.id=new.unit_id and u.current_access_point_id=v_origin)
        then 'unit_current_position' else 'unit_base_facility' end));
  return null;
end; $function$;
drop trigger if exists incident_deployment_route_snapshot on game.incident_deployments;
create trigger incident_deployment_route_snapshot after insert on game.incident_deployments
for each row execute function game.snapshot_deployment_route();
create or replace function game.get_dispatch_candidates(p_incident_ref text)
returns table(unit_ref text,unit_name text,base_facility text,eligible_personnel_count integer,
  personnel_refs text[],route_status text,route_ref text,distance_m integer,
  estimated_duration_seconds integer,estimated_arrival_at timestamptz,route_basis text)
language plpgsql security invoker set search_path = '' as $function$
declare
  v_clock timestamptz; v_incident_id uuid; v_destination uuid; v_unit record; v_origin uuid;
  v_route uuid; v_route_status text; v_distance integer; v_seconds integer; v_eta timestamptz;
  v_refs text[]; v_count integer; v_facility text; v_basis text;
begin
  select s.current_game_time into v_clock from game.simulation_state s where s.id=1;
  if v_clock is null then raise exception 'The fictional game clock is not initialized.'; end if;
  select i.id into v_incident_id from game.incidents i
  where i.incident_ref=p_incident_ref and i.status in ('new','graded','queued');
  if v_incident_id is null then raise exception 'Incident not found or not dispatchable.'; end if;
  if exists(select 1 from game.incident_deployments d where d.incident_id=v_incident_id
    and d.cleared_at is null and d.status not in ('cleared','cancelled','completed')) then
    raise exception 'Incident already has an active deployment.';
  end if;
  select ap.id into v_destination from game.incidents i
  join game.property_access_points ap on ap.property_id=i.location_property_id and ap.is_primary
  join game.road_segments rs on rs.id=ap.road_segment_id and rs.is_routable
  where i.id=v_incident_id order by ap.created_at limit 1;
  for v_unit in
    select u.id,u.unit_ref,u.unit_name,u.current_access_point_id,pf.access_point_id,pf.facility_name
    from game.police_units u left join game.police_facilities pf on pf.id=u.base_facility_id
    where u.status='active' and exists (
      select 1 from game.duty_rosters dr join game.duty_assignments da on da.roster_id=dr.id
      join game.police_personnel pp on pp.id=da.personnel_id
      where dr.unit_id=u.id and dr.status='active' and dr.starts_at<=v_clock and dr.ends_at>v_clock
        and da.status in ('assigned','on_duty') and da.starts_at<=v_clock and da.ends_at>v_clock
        and pp.employment_status='active' and not exists (
          select 1 from game.incident_deployments prior where prior.personnel_id=pp.id
            and prior.cleared_at is null and prior.status not in ('cleared','cancelled','completed')))
    order by u.unit_ref
  loop
    select array_agg(q.personnel_ref order by q.personnel_ref),count(*)::integer into v_refs,v_count
    from (select distinct pp.personnel_ref from game.duty_rosters dr
      join game.duty_assignments da on da.roster_id=dr.id join game.police_personnel pp on pp.id=da.personnel_id
      where dr.unit_id=v_unit.id and dr.status='active' and dr.starts_at<=v_clock and dr.ends_at>v_clock
        and da.status in ('assigned','on_duty') and da.starts_at<=v_clock and da.ends_at>v_clock
        and pp.employment_status='active' and not exists (
          select 1 from game.incident_deployments prior where prior.personnel_id=pp.id
            and prior.cleared_at is null and prior.status not in ('cleared','cancelled','completed'))) q;
    v_origin:=coalesce(v_unit.current_access_point_id,v_unit.access_point_id);
    v_route:=null; v_route_status:='location_unresolved'; v_distance:=null; v_seconds:=null; v_eta:=null;
    v_basis:='No routable unit origin or incident property access point is recorded.';
    v_facility:=v_unit.facility_name;
    if v_origin is not null and v_destination is not null then
      begin
        v_route:=game.calculate_road_route(v_origin,v_destination,'police','fastest');
        select r.route_status,r.distance_m,r.estimated_duration_seconds into v_route_status,v_distance,v_seconds
        from game.road_route_calculations r where r.id=v_route;
        if v_route_status='calculated' then
          v_eta:=v_clock+make_interval(secs=>v_seconds);
          v_basis:='Baseline posted-speed estimate; no live traffic, siren uplift or turn-delay model.';
        else v_basis:='No connected route exists in the current routable road graph.'; end if;
      exception when others then v_route:=null; v_route_status:='location_unresolved'; v_basis:='Route calculation unavailable: '||sqlerrm;
      end;
    end if;
    unit_ref:=v_unit.unit_ref; unit_name:=v_unit.unit_name; base_facility:=v_facility;
    eligible_personnel_count:=v_count; personnel_refs:=v_refs; route_status:=v_route_status;
    select r.route_ref into route_ref from game.road_route_calculations r where r.id=v_route;
    distance_m:=v_distance; estimated_duration_seconds:=v_seconds; estimated_arrival_at:=v_eta;
    route_basis:=v_basis; return next;
  end loop;
end; $function$;
revoke all on function game.snapshot_deployment_route() from public,anon,authenticated;
revoke all on function game.get_dispatch_candidates(text) from public,anon,authenticated;
grant execute on function game.get_dispatch_candidates(text) to service_role;