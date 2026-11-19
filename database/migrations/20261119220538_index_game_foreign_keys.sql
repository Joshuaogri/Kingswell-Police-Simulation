do $$
declare fk record; col_name text; idx_name text;
begin
 for fk in
  select c.conrelid::regclass as table_name, c.conrelid::oid as table_oid,
         c.conname, c.conkey[1] as first_attnum
  from pg_constraint c
  join pg_namespace n on n.oid=c.connamespace
  where n.nspname='game' and c.contype='f'
 loop
  select a.attname into col_name from pg_attribute a
   where a.attrelid=fk.table_oid and a.attnum=fk.first_attnum;
  if not exists (
   select 1 from pg_index i
   where i.indrelid=fk.table_oid and i.indisvalid
     and split_part(i.indkey::text,' ',1)::integer=fk.first_attnum
  ) then
   idx_name := left('idx_fk_' || replace(fk.table_name::text,'.','_') || '_' || col_name, 63);
   execute format('create index if not exists %I on %s (%I)',idx_name,fk.table_name,col_name);
  end if;
 end loop;
end $$;