-- Finalise required-name constraints for BP-02/BP-04 canonical place identities.
begin;

alter table game.properties
  alter column property_name set not null;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid='game.properties'::regclass
      and conname='properties_property_name_nonblank'
  ) then
    alter table game.properties
      add constraint properties_property_name_nonblank
      check (length(btrim(property_name))>0);
  end if;
end;
$$;

alter table game.roads
  alter column official_name set not null;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid='game.roads'::regclass
      and conname='roads_official_name_nonblank'
  ) then
    alter table game.roads
      add constraint roads_official_name_nonblank
      check (length(btrim(official_name))>0);
  end if;
end;
$$;

commit;
