-- Keep privileged correctional functions server-only.
REVOKE ALL ON FUNCTION game.execute_correctional_command(uuid, text, jsonb, uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION game.execute_correctional_command(uuid, text, jsonb, uuid) TO service_role;
REVOKE ALL ON FUNCTION game.get_correctional_record(text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION game.get_correctional_record(text) TO service_role;
