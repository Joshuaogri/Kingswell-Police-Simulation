-- BP-04 organisation and site dossier command regression.
begin;
do $$
declare parsed jsonb; routed jsonb; missing_org jsonb; missing_site jsonb;
begin
 parsed:=game.interpret_text_command('organisation record KWORG-NOT-REAL by KNG-TEST-0001');
 if parsed->>'command_type'<>'organisation_get_record'
  or parsed#>>'{payload,organisation_ref}'<>'KWORG-NOT-REAL' then
  raise exception 'Organisation dossier command was not recognised: %',parsed;
 end if;
 parsed:=game.interpret_text_command('organisation site record KWSITE-NOT-REAL by KNG-TEST-0001');
 if parsed->>'command_type'<>'organisation_site_get_record'
  or parsed#>>'{payload,site_ref}'<>'KWSITE-NOT-REAL' then
  raise exception 'Organisation site dossier command was not recognised: %',parsed;
 end if;
 missing_org:=game.get_organisation_record('KWORG-DOES-NOT-EXIST');
 if missing_org is not null then
  raise exception 'Unknown organisation unexpectedly returned a dossier: %',missing_org;
 end if;
 missing_site:=game.get_organisation_site_record('KWSITE-DOES-NOT-EXIST');
 if missing_site is not null then
  raise exception 'Unknown site unexpectedly returned a dossier: %',missing_site;
 end if;
 routed:=game.execute_text_command(
  'organisation record KWORG-DOES-NOT-EXIST by KNG-NONEXISTENT',
  'bp04-organisation-dossier-actor-01',null,null
 );
 if routed->>'code'<>'actor_mismatch' then
  raise exception 'Organisation dossier command bypassed actor validation: %',routed;
 end if;
 routed:=game.execute_text_command(
  'organisation site record KWSITE-DOES-NOT-EXIST by KNG-NONEXISTENT',
  'bp04-site-dossier-actor-01',null,null
 );
 if routed->>'code'<>'actor_mismatch' then
  raise exception 'Site dossier command bypassed actor validation: %',routed;
 end if;
end;
$$;
rollback;
