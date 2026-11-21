-- BP-04 organisation structure/workforce gameplay command regression.
begin;
do $$
declare parsed jsonb; routed jsonb; missing_structure jsonb; missing_workforce jsonb;
begin
 parsed:=game.interpret_text_command('organisation structure KWORG-TEST by KNG-TEST-0001');
 if parsed->>'command_type'<>'organisation_structure_get'
  or parsed#>>'{payload,organisation_ref}'<>'KWORG-TEST' then
  raise exception 'Organisation structure command was not recognised: %',parsed;
 end if;
 parsed:=game.interpret_text_command('organisation workforce KWORG-TEST by KNG-TEST-0001');
 if parsed->>'command_type'<>'organisation_workforce_get'
  or parsed#>>'{payload,organisation_ref}'<>'KWORG-TEST' then
  raise exception 'Organisation workforce command was not recognised: %',parsed;
 end if;
 missing_structure:=game.get_organisation_structure_record('KWORG-DOES-NOT-EXIST');
 if missing_structure is not null then
  raise exception 'Unknown organisation unexpectedly returned structure: %',missing_structure;
 end if;
 missing_workforce:=game.get_organisation_workforce_record('KWORG-DOES-NOT-EXIST');
 if missing_workforce is not null then
  raise exception 'Unknown organisation unexpectedly returned workforce: %',missing_workforce;
 end if;
 routed:=game.execute_text_command(
  'organisation structure KWORG-DOES-NOT-EXIST by KNG-NONEXISTENT',
  'bp04-organisation-structure-actor-01',null,null
 );
 if routed->>'code'<>'actor_mismatch' then
  raise exception 'Organisation structure command bypassed actor validation: %',routed;
 end if;
 routed:=game.execute_text_command(
  'organisation workforce KWORG-DOES-NOT-EXIST by KNG-NONEXISTENT',
  'bp04-organisation-workforce-actor-01',null,null
 );
 if routed->>'code'<>'actor_mismatch' then
  raise exception 'Organisation workforce command bypassed actor validation: %',routed;
 end if;
end;
$$;
rollback;
