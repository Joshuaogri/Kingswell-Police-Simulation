alter table game.organisation_locations
 add column if not exists lease_reference text,
 add column if not exists lease_type text,
 add column if not exists rent_band text,
 add column if not exists lease_details jsonb not null default '{}'::jsonb;
do $$
begin
 if not exists(select 1 from pg_constraint where conname='organisation_locations_lease_details_object_bp04') then
  alter table game.organisation_locations add constraint organisation_locations_lease_details_object_bp04 check(jsonb_typeof(lease_details)='object');
 end if;
end $$;
