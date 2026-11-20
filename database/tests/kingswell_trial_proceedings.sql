-- Rollback-only trial foundation parser and routing checks.
begin;
do $$
declare r jsonb;
begin
 r:=game.interpret_text_command('court plea record KWCHG-0000001 by KWP-0000001 as guilty');
 if r->>'command_type'<>'record_trial_plea' then raise exception 'Plea parser failed: %',r; end if;
 r:=game.interpret_text_command('court trial record KWH-0000001 by KWCO-0000001 type witness_examination speaker KWP-0000001 details "Examination commenced"');
 if r->>'command_type'<>'record_trial_proceeding' then raise exception 'Proceeding parser failed: %',r; end if;
 r:=game.interpret_text_command('court trial tender KWH-0000001 evidence KWEV-0000001 by KWP-0000001 side prosecution purpose "Identification"');
 if r->>'command_type'<>'tender_trial_evidence' then raise exception 'Tender parser failed: %',r; end if;
 r:=game.interpret_text_command('court trial rule KWTE-0000001 by KWCO-0000001 ruling admitted because "Relevant"');
 if r->>'command_type'<>'rule_trial_evidence' then raise exception 'Ruling parser failed: %',r; end if;
 r:=game.interpret_text_command('court create by KWP-0000001 name "Kingswell Central Court" level district');
 if r->>'command_type'<>'create_court' then raise exception 'Court parser regression: %',r; end if;
 r:=game.interpret_text_command('prosecution refer CASE-1 arrest ARREST-1 by OFF-1 summary "x" charges "y" evidence "z"');
 if r->>'command_type'<>'submit_prosecution_referral' then raise exception 'Prosecution parser regression: %',r; end if;
 if not exists(select 1 from information_schema.tables where table_schema='game' and table_name='trial_pleas') then raise exception 'Trial tables missing'; end if;
 if not exists(select 1 from pg_trigger where tgname='trial_pleas_append_only') then raise exception 'Plea immutability trigger missing'; end if;
 r:=game.execute_text_command('help','trial-help-rollback-test-0001',null,null);
 if not (r->'available_commands' ? 'record_trial_plea') or not (r->'available_commands' ? 'create_court') then raise exception 'Trial/court help registration failed: %',r; end if;
end $$;
rollback;
