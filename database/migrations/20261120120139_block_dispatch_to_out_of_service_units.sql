create or replace function game.guard_dispatch_to_out_of_service_unit()
returns trigger language plpgsql set search_path to ''
as $function$
begin
 if new.unit_id is not null and exists(
   select 1 from game.police_units u
   where u.id=new.unit_id and u.operational_state='out_of_service'
 ) then
   raise exception 'Unit is out of service and cannot receive an incident deployment';
 end if;
 return new;
end;$function$;
drop trigger if exists trg_guard_dispatch_to_out_of_service_unit on game.incident_deployments;
create trigger trg_guard_dispatch_to_out_of_service_unit
before insert or update of unit_id on game.incident_deployments
for each row execute function game.guard_dispatch_to_out_of_service_unit();
revoke all on function game.guard_dispatch_to_out_of_service_unit() from public,anon,authenticated;
grant execute on function game.guard_dispatch_to_out_of_service_unit() to service_role;
