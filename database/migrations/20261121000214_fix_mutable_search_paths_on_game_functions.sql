-- Pin the search path on every game-schema function that lacked one.
-- This prevents caller-controlled schemas from shadowing game objects or built-ins.
DO $$
DECLARE f record;
BEGIN
  FOR f IN
    SELECT n.nspname, p.proname, pg_catalog.oidvectortypes(p.proargtypes) AS argtypes
    FROM pg_catalog.pg_proc p
    JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
    WHERE n.nspname = 'game'
      AND NOT EXISTS (
        SELECT 1 FROM unnest(coalesce(p.proconfig, ARRAY[]::text[])) cfg
        WHERE cfg LIKE 'search_path=%'
      )
  LOOP
    EXECUTE format(
      'ALTER FUNCTION %I.%I(%s) SET search_path = pg_catalog, game',
      f.nspname, f.proname, f.argtypes
    );
  END LOOP;
END
$$;
