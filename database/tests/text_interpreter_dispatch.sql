-- Text interpreter and dispatch call-intake regression test.
-- Run inside a transaction; all generated fictional test records are rolled back.
begin;
do $test$
declare r jsonb; parsed jsonb; before_calls integer;
begin
  parsed:=game.interpret_text_command('911 Caller reports smoke coming from a shop at 14 Market Lane');
  if parsed->>'command_type'<>'receive_call' or parsed#>>'{payload,location}'<>'14 Market Lane' then raise exception 'Text parser failed: %',parsed; end if;
  parsed:=game.interpret_text_command('advance time 25 minutes');
  if parsed->>'command_type'<>'advance_time' or parsed#>>'{payload,minutes}'<>'25' then raise exception 'Time parser failed: %',parsed; end if;
  r:=game.submit_command('Initialize fictional test clock','initialize_clock','{"start_at":"2035-06-01T08:00:00Z"}'::jsonb,'dispatch-test-clock-init-0001');
  if r->>'ok'<>'true' then raise exception 'Clock setup failed: %',r; end if;
  select count(*) into before_calls from game.dispatch_calls;
  r:=game.execute_text_command('911 Caller reports smoke coming from a shop at 14 Market Lane','dispatch-test-call-0001');
  if r->>'ok'<>'true' or r->>'call_status'<>'received' or r->>'incident_status'<>'new' then raise exception 'Dispatch call failed: %',r; end if;
  if (select count(*) from game.dispatch_calls)<>before_calls+1 then raise exception 'Call ledger row not created'; end if;
  if (select count(*) from game.incidents where incident_ref=r->>'incident_ref')<>1 then raise exception 'Linked incident missing'; end if;
  if (select count(*) from game.dispatch_events de join game.incidents i on i.id=de.incident_id where i.incident_ref=r->>'incident_ref' and de.event_type='call_received')<>1 then raise exception 'Dispatch event missing'; end if;
  r:=game.execute_text_command('911 Caller reports smoke coming from a shop at 14 Market Lane','dispatch-test-call-0001');
  if r->>'duplicate'<>'true' then raise exception 'Idempotent retry failed: %',r; end if;
  r:=game.execute_text_command('what is happening now','dispatch-test-unknown-0001');
  if r->>'ok'<>'false' or r->>'code'<>'unknown_command' then raise exception 'Unknown text not safely rejected: %',r; end if;
end;
$test$;
rollback;
