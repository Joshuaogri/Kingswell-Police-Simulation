-- BP-04 individual site dossier composition regression.
begin;
do $$
declare v_site_ref text; v_record jsonb;
begin
 select site_ref into v_site_ref
 from game.organisation_site_dossiers
 order by site_ref limit 1;
 if v_site_ref is null then
  raise exception 'Expected seeded canonical site dossier fixture';
 end if;
 v_record:=game.get_organisation_site_record(v_site_ref);
 if v_record is null then
  raise exception 'Known site returned no dossier: %',v_site_ref;
 end if;
 if not (v_record ?& array[
  'site','organisation','site_location','property','property_record',
  'building','unit','unit_profile','unit_infrastructure','site_agreements',
  'recorded_department_assignments','record_coverage'
 ]) then
  raise exception 'Site dossier missing required sections: %',v_record;
 end if;
 if coalesce(v_record#>>'{record_coverage,unknown_values_are_not_inferred}','false')<>'true' then
  raise exception 'Site dossier lost unknown-information safeguard';
 end if;
 if jsonb_typeof(v_record->'site_agreements')<>'array'
  or jsonb_typeof(v_record->'recorded_department_assignments')<>'array' then
  raise exception 'Site dossier collections must always be arrays';
 end if;
 if game.get_organisation_site_record('KWSITE-NOT-FOUND') is not null then
  raise exception 'Unknown site unexpectedly returned a dossier';
 end if;
end;
$$;
rollback;
