-- Tighten execute privileges for the internal evidence-action handler.
-- The function remains callable by the trusted service role only.
revoke all on function game.execute_evidence_action(uuid,text,jsonb,uuid) from public, anon, authenticated;
grant execute on function game.execute_evidence_action(uuid,text,jsonb,uuid) to service_role;
