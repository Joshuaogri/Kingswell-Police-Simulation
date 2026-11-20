begin;
do $$
declare r jsonb;
begin
 r:=game.submit_command('help','help','{}'::jsonb,'forensic-workflow-help-01',null,null);
 if not coalesce((r->>'ok')::boolean,false) then raise exception 'help command failed'; end if;
 foreach r in array array[
   game.interpret_text_command('forensic method OFF-01 DNA-01: DNA | STR profiling | 1.0 | verification_pending | casework samples | stated limits'),
   game.interpret_text_command('validate forensic method OFF-02 DNA-01: validated | independent method review'),
   game.interpret_text_command('forensic request OFF-01 CASE-01 EVD-01: DNA | assess sample | full scope | recorded authority | 2'),
   game.interpret_text_command('triage forensic OFF-01 KWFR-01: accept | within scope'),
   game.interpret_text_command('receive lab submission OFF-01 KWFR-01 EVD-01 OFF-02: locker A | lab intake | sealed | intact | none'),
   game.interpret_text_command('assign forensic OFF-01 KWFR-01 KWLAB-01 OFF-03 DNA-01: H1 versus H2'),
   game.interpret_text_command('start forensic OFF-03 KWEX-01'),
   game.interpret_text_command('record forensic findings OFF-03 KWEX-01: observation | interpretation | H1 versus H2 | limitations | inconclusive'),
   game.interpret_text_command('review forensic OFF-04 KWFIND-01: technical | approved | review complete'),
   game.interpret_text_command('issue forensic report OFF-01 KWFR-01: summary | full report body')
 ] loop
   if not coalesce((r->>'recognized')::boolean,false) then raise exception 'forensic command parser failed: %',r; end if;
 end loop;
 r:=game.execute_text_command('forensic request OFF-01 CASE-01 EVD-01: DNA | assess sample | full scope | recorded authority | 2','forensic-workflow-clock-guard-01',null,null);
 if r->>'code'<>'clock_not_initialized' then raise exception 'runtime routing or clock guard failed: %',r; end if;
 if (select count(*) from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='game' and c.relname in ('forensic_methods','forensic_method_reviews','forensic_requests','forensic_request_items','forensic_lab_submissions','forensic_examinations','forensic_findings','forensic_reviews','forensic_reports') and c.relrowsecurity)<>9 then raise exception 'forensic RLS assertion failed'; end if;
 if (select count(*) from game.game_commands where idempotency_key='forensic-workflow-clock-guard-01')<>1 then raise exception 'command ledger entry missing inside test transaction'; end if;
end $$;
rollback;
