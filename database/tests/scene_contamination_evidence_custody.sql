begin;
do $$
declare r jsonb;
begin
 r:=game.submit_command('help','help','{}'::jsonb,'evidence-help-test-001',null,null);
 if not coalesce((r->>'ok')::boolean,false) or not (r->'available_commands' ? 'record_scene_contamination') or not (r->'available_commands' ? 'recover_scene_evidence') or not (r->'available_commands' ? 'transfer_scene_evidence') then raise exception 'evidence help catalogue regression'; end if;
 r:=game.interpret_text_command('record contamination OFF-001 at SCN-001: Zone A | unknown fluid | isolate area');
 if not coalesce((r->>'recognized')::boolean,false) or r->>'command_type'<>'record_scene_contamination' then raise exception 'contamination parser regression'; end if;
 r:=game.interpret_text_command('recover evidence OFF-001 from SCN-001 under PLN-001: trace | glass fragment | window sill | sterile forceps | rigid box | SEAL-001 | intact');
 if not coalesce((r->>'recognized')::boolean,false) or r->>'command_type'<>'recover_scene_evidence' or r#>>'{payload,seal}'<>'SEAL-001' then raise exception 'evidence recovery parser regression'; end if;
 r:=game.interpret_text_command('transfer evidence OFF-001 KWE-001 to OFF-002: locker A | secure store B | authorised submission');
 if not coalesce((r->>'recognized')::boolean,false) or r->>'command_type'<>'transfer_scene_evidence' then raise exception 'evidence transfer parser regression'; end if;
 if not (select relrowsecurity from pg_class where oid='game.scene_contamination_events'::regclass) then raise exception 'contamination RLS disabled'; end if;
 if not (select relrowsecurity from pg_class where oid='game.scene_evidence_recoveries'::regclass) then raise exception 'recovery RLS disabled'; end if;
 if not (select relrowsecurity from pg_class where oid='game.scene_evidence_transfer_events'::regclass) then raise exception 'transfer RLS disabled'; end if;
 if not exists(select 1 from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='game' and p.proname='execute_evidence_action') then raise exception 'evidence action handler missing'; end if;
 if (game.execute_evidence_action(gen_random_uuid(),'record_scene_contamination','{"personnel_ref":"OFF-001","scene_ref":"SCN-001","zone":"Zone A","material":"unknown","control_action":"isolate"}'::jsonb,null)->>'code')<>'clock_not_initialized' then raise exception 'clock guard regression'; end if;
end $$;
rollback;
