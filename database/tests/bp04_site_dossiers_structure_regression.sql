-- BP-04 site dossier and organisation structure regression.
do $$
declare v_org text; v_site text; v_json jsonb;
begin
 if (select count(*) from game.organisation_site_dossiers)<>1477
 then raise exception 'BP04: expected one dossier per 1,477 existing organisation sites'; end if;
 if exists(select 1 from game.organisation_locations ol left join game.organisation_site_dossiers sd
 on sd.organisation_location_id=ol.id where sd.organisation_location_id is null)
 then raise exception 'BP04: site dossier coverage gap'; end if;
 if exists(select 1 from game.organisation_site_dossiers sd
 join game.organisation_locations ol on ol.id=sd.organisation_location_id
 where sd.organisation_id<>ol.organisation_id or sd.property_id<>ol.property_id
 or sd.building_unit_id<>ol.building_unit_id or sd.site_ref<>ol.site_ref)
 then raise exception 'BP04: site dossier does not preserve canonical site links'; end if;
 if (select count(*) from game.organisation_departments)=0
 or (select count(*) from game.organisation_department_positions)=0
 or (select count(*) from game.organisation_department_assignments)
    <>(select count(*) from game.organisation_personnel)
 then raise exception 'BP04: generated department, position and employment assignment coverage is incomplete'; end if;
 if exists(
   select 1 from game.organisation_department_assignments a
   join game.organisation_personnel ep on ep.id=a.organisation_personnel_id
   join game.organisation_departments d on d.id=a.department_id
   join game.organisation_department_positions p on p.id=a.position_id
   where ep.organisation_id<>d.organisation_id
      or p.department_id<>d.id
 ) then raise exception 'BP04: employment, department and position identities do not reconcile'; end if;
 if exists(
   select 1 from game.organisation_department_positions p
   where p.position_title='Department Lead'
     and (p.position_status<>'vacant'
       or p.authority_profile->>'supervisory_authority'<>'not_assigned')
 ) then raise exception 'BP04: generated department lead positions must remain vacant without assigned authority'; end if;
 if has_table_privilege('anon','game.organisation_department_assignments','select')
 or has_table_privilege('authenticated','game.organisation_department_assignments','select')
 then raise exception 'BP04: organisation structure exposed to client roles'; end if;
 select o.organisation_ref into v_org from game.organisations o
 join game.organisation_site_dossiers sd on sd.organisation_id=o.id limit 1;
 v_json:=game.get_organisation_structure_record(v_org);
 if v_json is null or not(v_json?'organisation' and v_json?'departments' and v_json?'sites' and v_json?'structure_status')
 then raise exception 'BP04: organisation structure query incomplete'; end if;
 select site_ref into v_site from game.organisation_site_dossiers limit 1;
 v_json:=game.get_organisation_site_record(v_site);
 if v_json is null or not(v_json?'site' and v_json?'organisation')
 then raise exception 'BP04: site dossier query incomplete'; end if;
end $$;
