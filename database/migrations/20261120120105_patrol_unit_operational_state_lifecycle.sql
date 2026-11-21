alter table game.police_units
  add column if not exists operational_state text not null default 'at_station',
  add column if not exists operational_state_updated_at timestamptz,
  add constraint police_units_operational_state_check
    check (operational_state in ('at_station','on_patrol','responding','on_scene','returning','out_of_service'));

create table if not exists game.unit_operational_state_history (
  id uuid primary key default gen_random_uuid(),
  unit_id uuid not null references game.police_units(id),
  previous_state text,
  new_state text not null check (new_state in ('at_station','on_patrol','responding','on_scene','returning','out_of_service')),
  changed_at_game_time timestamptz not null,
  source text not null check (source in ('dispatch','arrival','deployment_cleared','manual','return_to_station','service_status')),
  reason text not null check (length(btrim(reason))>0),
  deployment_id uuid references game.incident_deployments(id),
  command_id uuid references game.game_commands(id),
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
create index if not exists unit_operational_state_history_unit_time_idx
  on game.unit_operational_state_history(unit_id,changed_at_game_time desc);
create index if not exists unit_operational_state_history_deployment_idx
  on game.unit_operational_state_history(deployment_id) where deployment_id is not null;
alter table game.unit_operational_state_history enable row level security;
revoke all on game.unit_operational_state_history from public,anon,authenticated;
grant select,insert on game.unit_operational_state_history to service_role;
revoke update,delete on game.unit_operational_state_history from service_role;

create or replace function game.set_unit_operational_state(
  p_unit_ref text,p_new_state text,p_reason text,p_source text default 'manual'
) returns jsonb
language plpgsql
set search_path to ''
as $function$
declare
 v_unit game.police_units%rowtype;
 v_clock timestamptz;
 v_active boolean;
 v_scene boolean;
begin
 if p_reason is null or length(btrim(p_reason))=0 then raise exception 'A reason is required'; end if;
 if p_new_state not in ('at_station','on_patrol','returning','out_of_service') then
   raise exception 'This state is controlled by dispatch/deployment events'; end if;
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then raise exception 'The fictional game clock is not initialized'; end if;
 select * into v_unit from game.police_units where unit_ref=p_unit_ref for update;
 if not found or v_unit.status<>'active' then raise exception 'Active unit not found'; end if;
 select exists(select 1 from game.incident_deployments d where d.unit_id=v_unit.id
  and d.cleared_at is null and d.status not in ('cleared','cancelled','completed')),
 exists(select 1 from game.incident_deployments d where d.unit_id=v_unit.id
  and d.arrived_at is not null and d.cleared_at is null and d.status not in ('cleared','cancelled','completed'))
 into v_active,v_scene;
 if p_new_state in ('at_station','on_patrol','out_of_service') and v_active then
   raise exception 'Unit has an active incident deployment and cannot enter state %',p_new_state;
 end if;
 if p_new_state='at_station' and v_unit.base_facility_id is null then
   raise exception 'Unit has no base facility recorded';
 end if;
 if p_new_state='at_station' then
   update game.police_units u set current_access_point_id=pf.access_point_id,
    current_location_updated_at=v_clock
   from game.police_facilities pf where u.id=v_unit.id and pf.id=u.base_facility_id;
   if not found then raise exception 'Unit base facility has no registered access point'; end if;
 end if;
 update game.police_units set operational_state=p_new_state,operational_state_updated_at=v_clock where id=v_unit.id;
 if v_unit.operational_state is distinct from p_new_state then
  insert into game.unit_operational_state_history(unit_id,previous_state,new_state,changed_at_game_time,source,reason)
  values(v_unit.id,v_unit.operational_state,p_new_state,v_clock,
    case when p_new_state='at_station' then 'return_to_station' when p_new_state='out_of_service' then 'service_status' else p_source end,
    btrim(p_reason));
 end if;
 return jsonb_build_object('unit_ref',p_unit_ref,'previous_state',v_unit.operational_state,
   'new_state',p_new_state,'changed_at_game_time',v_clock);
end;$function$;

create or replace function game.sync_unit_operational_state_from_deployment()
returns trigger language plpgsql set search_path to ''
as $function$
declare
 v_unit_id uuid;
 v_clock timestamptz;
 v_target text;
 v_source text;
 v_reason text;
 v_old text;
 v_deployment_id uuid;
begin
 v_unit_id:=coalesce(new.unit_id,old.unit_id);
 if v_unit_id is null then return coalesce(new,old); end if;
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then raise exception 'The fictional game clock is not initialized'; end if;
 if tg_op='INSERT' then
   v_target:='responding'; v_source:='dispatch'; v_reason:='Unit assigned to incident response'; v_deployment_id:=new.id;
 elsif old.arrived_at is null and new.arrived_at is not null then
   v_target:='on_scene'; v_source:='arrival'; v_reason:='Unit arrived at incident scene'; v_deployment_id:=new.id;
 elsif (old.cleared_at is null and new.cleared_at is not null)
    or (old.status is distinct from new.status and new.status in ('cleared','cancelled','completed')) then
   if exists(select 1 from game.incident_deployments d where d.unit_id=v_unit_id and d.id<>new.id
     and d.cleared_at is null and d.status not in ('cleared','cancelled','completed') and d.arrived_at is not null) then
     v_target:='on_scene';
   elsif exists(select 1 from game.incident_deployments d where d.unit_id=v_unit_id and d.id<>new.id
     and d.cleared_at is null and d.status not in ('cleared','cancelled','completed')) then
     v_target:='responding';
   else v_target:='returning'; end if;
   v_source:='deployment_cleared'; v_reason:='Active incident deployment ended'; v_deployment_id:=new.id;
 else
   return new;
 end if;
 select operational_state into v_old from game.police_units where id=v_unit_id for update;
 update game.police_units set operational_state=v_target,operational_state_updated_at=v_clock where id=v_unit_id;
 if v_old is distinct from v_target then
  insert into game.unit_operational_state_history(unit_id,previous_state,new_state,changed_at_game_time,source,reason,deployment_id)
  values(v_unit_id,v_old,v_target,v_clock,v_source,v_reason,v_deployment_id);
 end if;
 return coalesce(new,old);
end;$function$;

drop trigger if exists trg_unit_operational_state_from_deployment on game.incident_deployments;
create trigger trg_unit_operational_state_from_deployment
after insert or update of arrived_at,cleared_at,status on game.incident_deployments
for each row execute function game.sync_unit_operational_state_from_deployment();

revoke all on function game.set_unit_operational_state(text,text,text,text) from public,anon,authenticated;
grant execute on function game.set_unit_operational_state(text,text,text,text) to service_role;
revoke all on function game.sync_unit_operational_state_from_deployment() from public,anon,authenticated;
grant execute on function game.sync_unit_operational_state_from_deployment() to service_role;
