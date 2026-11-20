-- BP-04 workforce and job-role dossier regression.
do $$
declare v_org text; v_person text; v_json jsonb;
begin
 if (select count(*) from game.organisation_job_role_catalog)<>13
 then raise exception 'BP04: expected 13 canonical job-role families'; end if;
 if (select count(*) from game.organisation_personnel_dossiers)<>43412
 then raise exception 'BP04: all 43,412 existing employment links must have dossiers'; end if;
 if exists(select 1 from game.organisation_personnel op left join game.organisation_personnel_dossiers d
  on d.organisation_personnel_id=op.id where d.organisation_personnel_id is null)
 then raise exception 'BP04: employment dossier missing'; end if;
 if exists(select 1 from game.organisation_personnel_dossiers
  where department_assignment_status<>'not_recorded'
   or supervisor_assignment_status<>'not_recorded'
   or physical_site_assignment_status<>'not_recorded'
   or work_schedule_status<>'not_recorded'
   or authority_and_system_access_status<>'not_recorded')
 then raise exception 'BP04: unsupported employment assignment was invented'; end if;
 if exists(select 1 from game.organisation_personnel op join game.organisation_personnel_dossiers d
  on d.organisation_personnel_id=op.id join game.organisation_job_role_catalog c on c.job_role_ref=d.job_role_ref
  where c.job_title<>op.job_title)
 then raise exception 'BP04: employment dossier role does not match canonical title'; end if;
 if has_table_privilege('anon','game.organisation_personnel_dossiers','select')
  or has_table_privilege('authenticated','game.organisation_personnel_dossiers','select')
 then raise exception 'BP04: personnel dossiers exposed to client roles'; end if;
 select organisation_ref into v_org from game.organisations o
 join game.organisation_personnel op on op.organisation_id=o.id
 order by o.organisation_ref limit 1;
 v_json:=game.get_organisation_workforce_record(v_org);
 if v_json is null or not(v_json?'organisation' and v_json?'workforce_summary'
  and v_json?'role_breakdown' and v_json?'employees' and v_json?'assignment_policy')
 then raise exception 'BP04: organisation workforce query incomplete'; end if;
 select p.person_ref into v_person from game.persons p
 join game.organisation_personnel op on op.person_id=p.id limit 1;
 v_json:=game.get_person_employment_record(v_person);
 if v_json is null or not(v_json?'person' and v_json?'employment')
 then raise exception 'BP04: person employment query incomplete'; end if;
end $$;
