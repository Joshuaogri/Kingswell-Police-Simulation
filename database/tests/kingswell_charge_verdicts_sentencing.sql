-- Rollback-only charge verdict and sentencing regression checks.
begin;
do $$
declare r jsonb;
begin
 r:=game.interpret_text_command('court verdict record KWCHG-0000001 at KWH-0000001 by KWCO-0000001 as guilty because "Evidence proved the charge"');
 if r->>'command_type'<>'record_trial_verdict' or r->'payload'->>'verdict'<>'guilty' then raise exception 'Verdict parser failed: %',r; end if;
 r:=game.interpret_text_command('court verdict record KWCHG-0000001 at KWH-0000001 by KWCO-0000001 as not_guilty because "Evidence did not prove the charge"');
 if r->>'command_type'<>'record_trial_verdict' or r->'payload'->>'verdict'<>'not_guilty' then raise exception 'Not-guilty parser failed: %',r; end if;
 r:=game.interpret_text_command('court sentence impose KWCHG-0000001 at KWH-0000002 by KWCO-0000001 type custodial duration_days 180 fine_amount 0 details "Six months custody"');
 if r->>'command_type'<>'impose_trial_sentence' or r->'payload'->>'duration_days'<>'180' then raise exception 'Custodial sentence parser failed: %',r; end if;
 r:=game.interpret_text_command('court sentence impose KWCHG-0000001 at KWH-0000002 by KWCO-0000001 type fine duration_days 0 fine_amount 250.00 details "Fine imposed"');
 if r->>'command_type'<>'impose_trial_sentence' or r->'payload'->>'fine_amount'<>'250.00' then raise exception 'Fine parser failed: %',r; end if;
 r:=game.interpret_text_command('court plea record KWCHG-0000001 by KWP-0000001 as guilty');
 if r->>'command_type'<>'record_trial_plea' then raise exception 'Plea parser regression: %',r; end if;
 r:=game.interpret_text_command('court create by KWP-0000001 name "Kingswell Central Court" level district');
 if r->>'command_type'<>'create_court' then raise exception 'Court parser regression: %',r; end if;
 r:=game.interpret_text_command('prosecution refer CASE-1 arrest ARREST-1 by OFF-1 summary "x" charges "y" evidence "z"');
 if r->>'command_type'<>'submit_prosecution_referral' then raise exception 'Prosecution parser regression: %',r; end if;
 r:=game.execute_text_command('help','trial-outcome-help-rollback-0001',null,null);
 if not (r->'available_commands' ? 'record_trial_verdict') or not (r->'available_commands' ? 'impose_trial_sentence') or not (r->'available_commands' ? 'create_court') then raise exception 'Help registration regression: %',r; end if;
end $$;
rollback;
