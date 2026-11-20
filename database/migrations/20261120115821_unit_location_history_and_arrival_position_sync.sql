-- Keep patrol-unit position synchronized with recorded officer arrival.
-- The fictional clock remains explicit and player-controlled.

create table if not exists game.unit_location_history (
  id uuid primary key default gen_random_uuid(),
  unit_id uuid not null references game.police_units(id),
  access_point_id uuid not null references game.property_access_points(id),
  recorded_at_game_time timestamptz not null,
  source text not null check (source in ('arrival','manual_position','return_to_base','deployment')),
  deployment_id uuid references game.incident_deployments(id),
  recorded_by_personnel_id uuid references game.police_personnel(id),
  reason text not null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  constraint unit_location_history_reason_nonblank check (length(btrim(reason)) > 0)
);

create index if not exists unit_location_history_unit_time_idx
  on game.unit_location_history(unit_id, recorded_at_game_time desc);
create index if not exists unit_location_history_access_point_idx
  on game.unit_location_history(access_point_id);
create index if not exists unit_location_history_deployment_idx
  on game.unit_location_history(deployment_id) where deployment_id is not null;

alter table game.unit_location_history enable row level security;
revoke all on game.unit_location_history from public, anon, authenticated;
grant select, insert on game.unit_location_history to service_role;
revoke update, delete on game.unit_location_history from service_role;

create or replace function game.sync_unit_position_on_officer_arrival()
returns trigger
language plpgsql
set search_path to ''
as $function$
declare
  v_clock timestamptz;
  v_access_point_id uuid;
  v_unit_id uuid;
  v_other_deployment record;
  v_recalculation jsonb;
begin
  if old.arrived_at is not null or new.arrived_at is null then
    return new;
  end if;

  select s.current_game_time into v_clock
  from game.simulation_state s where s.id=1;
  if v_clock is null then
    raise exception 'The fictional game clock is not initialized';
  end if;
  if new.arrived_at <> v_clock then
    raise exception 'Arrival time must match the current fictional game time';
  end if;

  select ap.id into v_access_point_id
  from game.incidents i
  join game.property_access_points ap
    on ap.property_id=i.location_property_id and ap.is_primary
  join game.road_segments rs
    on rs.id=ap.road_segment_id and rs.is_routable
  where i.id=new.incident_id
  order by ap.created_at
  limit 1;

  if v_access_point_id is null then
    raise exception 'Arrival cannot update unit position: incident has no registered routable property access point';
  end if;

  v_unit_id:=new.unit_id;
  update game.police_units
  set current_access_point_id=v_access_point_id,
      current_location_updated_at=v_clock
  where id=v_unit_id;

  insert into game.unit_location_history(
    unit_id,access_point_id,recorded_at_game_time,source,
    deployment_id,recorded_by_personnel_id,reason,details
  ) values (
    v_unit_id,v_access_point_id,v_clock,'arrival',
    new.id,new.personnel_id,'Officer arrival at incident scene',
    jsonb_build_object('incident_id',new.incident_id,'deployment_status',new.status)
  );

  for v_other_deployment in
    select d.id
    from game.incident_deployments d
    where d.unit_id=v_unit_id
      and d.id<>new.id
      and d.arrived_at is null
      and d.cleared_at is null
      and d.status not in ('cleared','cancelled','completed')
    order by d.dispatched_at,d.id
  loop
    v_recalculation:=game.recalculate_deployment_route(
      v_other_deployment.id,
      'Unit position changed after officer arrival at another incident',
      'route_recalculated'
    );
  end loop;

  return new;
end;
$function$;

drop trigger if exists trg_sync_unit_position_on_officer_arrival
  on game.incident_deployments;
create trigger trg_sync_unit_position_on_officer_arrival
after update of arrived_at on game.incident_deployments
for each row
when (old.arrived_at is null and new.arrived_at is not null)
execute function game.sync_unit_position_on_officer_arrival();

revoke all on function game.sync_unit_position_on_officer_arrival() from public, anon, authenticated;
grant execute on function game.sync_unit_position_on_officer_arrival() to service_role;
