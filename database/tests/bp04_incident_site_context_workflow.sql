-- BP-04 incident-to-site context regression.
begin;
do $$
declare parsed jsonb;
begin
 parsed:=game.interpret_text_command(
  'incident site link KNG-INC-TEST KNG-SITE-TEST relation incident_location because "The reported incident address is this operating premises" by KNG-OFFICER-TEST'
 );
 if parsed->>'command_type'<>'record_incident_site_association'
  or parsed#>>'{payload,relation_type}'<>'incident_location'
  or parsed#>>'{payload,site_ref}'<>'KNG-SITE-TEST' then
  raise exception 'Incident-site association command was not recognised: %',parsed;
 end if;
 parsed:=game.interpret_text_command('incident site context KNG-INC-TEST');
 if parsed->>'command_type'<>'get_incident_site_context'
  or parsed#>>'{payload,incident_ref}'<>'KNG-INC-TEST' then
  raise exception 'Incident site context query command was not recognised: %',parsed;
 end if;
 if not exists(select 1 from information_schema.columns where table_schema='game'
  and table_name='incident_site_associations' and column_name='organisation_location_id') then
  raise exception 'Incident-site association missing canonical organisation location reference';
 end if;
 if not exists(select 1 from pg_constraint where conrelid='game.incident_site_associations'::regclass
  and contype='u' and pg_get_constraintdef(oid)='UNIQUE (incident_id, organisation_location_id, relation_type)') then
  raise exception 'Incident-site association uniqueness constraint missing';
 end if;
end;
$$;
rollback;
