-- BP-04 generated business operations and organisation-structure regression.
-- Runs after the isolated population fixture; all generated rows roll back.
begin;
do $test$
declare r jsonb; v_employment bigint; v_assignments bigint; v_businesses bigint;
begin
  r:=game.seed_bp04_organisation_structures();
  if coalesce((r->>'ok')::boolean,false) is not true then
    raise exception 'Organisation structure seed failed: %',r;
  end if;

  select count(*) into v_employment from game.organisation_personnel;
  select count(*) into v_assignments from game.organisation_department_assignments;
  if v_assignments<>v_employment then
    raise exception 'Expected one department assignment per employment record; employment %, assignments %',v_employment,v_assignments;
  end if;

  if exists(
    select 1 from game.organisation_personnel op
    left join game.organisation_department_assignments da on da.organisation_personnel_id=op.id
    where da.id is null
  ) then raise exception 'At least one canonical employment record lacks an organisation structure assignment'; end if;

  if exists(
    select 1 from game.organisation_department_assignments da
    join game.organisation_department_positions p on p.id=da.position_id
    join game.organisation_departments d on d.id=da.department_id
    where p.department_id<>d.id or d.organisation_id is null
  ) then raise exception 'Organisation assignment position/department hierarchy is inconsistent'; end if;

  if exists(
    select 1 from game.organisation_department_assignments da
    join game.organisation_personnel op on op.id=da.organisation_personnel_id
    join game.organisation_departments d on d.id=da.department_id
    where d.organisation_id<>op.organisation_id
  ) then raise exception 'Organisation assignment crosses canonical organisation boundary'; end if;

  if exists(
    select 1 from game.organisation_department_assignments da
    join game.organisation_site_dossiers sd on sd.organisation_location_id=da.site_dossier_id
    join game.organisations o on o.id=sd.organisation_id
    join game.organisation_personnel op on op.id=da.organisation_personnel_id
    where o.id<>op.organisation_id
  ) then raise exception 'Organisation assignment site belongs to another organisation'; end if;

  select count(*) into v_businesses from game.business_profiles;
  if (select count(*) from game.business_profiles where operational_profile<>'{}'::jsonb)<>v_businesses then
    raise exception 'Every business must have a populated individual operational profile';
  end if;

  if not exists(select 1 from game.organisation_department_positions where position_title='Department Lead' and position_status='vacant') then
    raise exception 'Generated department framework must retain explicit vacant lead positions';
  end if;

  if exists(
    select 1 from game.organisation_department_assignments da
    join game.organisation_personnel op on op.id=da.organisation_personnel_id
    where da.supervisor_employment_id is not null
  ) then raise exception 'Seed must not invent supervisor assignments'; end if;
end;
$test$;
rollback;
