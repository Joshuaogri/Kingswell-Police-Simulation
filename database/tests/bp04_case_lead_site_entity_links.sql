-- BP-04 site-to-investigation entity-link regression.
begin;
do $$
declare parsed jsonb; v_site_ref text; v_location_id uuid;
begin
 parsed:=game.interpret_text_command(
  'case lead link KNG-LD-TEST entity site KWSITE-TEST because "Premises relevant to reported activity" by KNG-OFFICER-TEST'
 );
 if parsed->>'command_type'<>'link_case_lead_entity'
  or parsed#>>'{payload,entity_type}'<>'site'
  or parsed#>>'{payload,entity_ref}'<>'KWSITE-TEST' then
  raise exception 'Case lead site link command was not recognised: %',parsed;
 end if;
 select site_ref,organisation_location_id into v_site_ref,v_location_id
 from game.organisation_site_dossiers order by site_ref limit 1;
 if v_site_ref is null or v_location_id is null then
  raise exception 'Expected canonical organisation site dossier fixture';
 end if;
 if not exists(
  select 1 from information_schema.columns
  where table_schema='game' and table_name='case_lead_entity_links'
   and column_name='organisation_location_id'
 ) then raise exception 'Case lead entity link register lacks canonical site FK'; end if;
 if not exists(
  select 1 from pg_constraint
  where conrelid='game.case_lead_entity_links'::regclass
   and conname='case_lead_entity_link_exactly_one'
 ) then raise exception 'Case lead entity link exact-one constraint missing'; end if;
 if not exists(
  select 1 from pg_constraint c
  join pg_attribute a on a.attrelid=c.conrelid and a.attnum=any(c.conkey)
  where c.conrelid='game.case_lead_entity_links'::regclass
   and c.contype='f' and a.attname='organisation_location_id'
 ) then raise exception 'Canonical organisation location foreign key missing'; end if;
end;
$$;
rollback;
