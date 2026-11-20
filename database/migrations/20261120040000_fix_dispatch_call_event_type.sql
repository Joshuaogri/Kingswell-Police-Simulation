-- Explicit history record for dispatch event_type correction.
-- The corrected definition is included in 20261120030000_text_interpreter_dispatch_intake.sql.
do $$ begin
  if not exists (select 1 from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='game' and p.proname='submit_command') then
    raise exception 'Runtime command function is missing.';
  end if;
end $$;
