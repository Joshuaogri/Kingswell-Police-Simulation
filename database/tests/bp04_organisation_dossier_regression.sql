-- BP-04 organisation and institution dossier regression.
do $$
declare v_ref text; v_json jsonb;
begin
 if (select count(*) from game.organisation_profiles)<>1490
 then raise exception 'BP04: organisation dossier population must remain 1490'; end if;
 if exists(select 1 from game.organisations o left join game.organisation_profiles p on p.organisation_id=o.id where p.organisation_id is null)
 then raise exception 'BP04: organisation dossier missing'; end if;
 if exists(select 1 from game.organisation_profiles where
  governance_structure_status<>'not_recorded'
  or legal_form_status<>'not_recorded'
  or registration_identifier_status<>'not_recorded'
  or regulator_or_oversight_status<>'not_recorded'
  or parent_relationship_status<>'not_recorded')
 then raise exception 'BP04: unverified legal or governance facts asserted'; end if;
 if exists(select 1 from game.organisations o join game.organisation_profiles p on p.organisation_id=o.id
  where p.operational_dependencies->>'parent_organisation_id' is distinct from o.parent_organisation_id::text
    and not (o.parent_organisation_id is null and p.operational_dependencies->>'parent_organisation_id' is null))
 then raise exception 'BP04: organisation parent link diverges from canonical hierarchy'; end if;
 if exists(select 1 from game.organisation_profiles p join game.organisations o on o.id=p.organisation_id
  where p.profile_ref<>'KWORG-PROFILE-'||o.organisation_ref)
 then raise exception 'BP04: organisation dossier ref mismatch'; end if;
 if has_table_privilege('anon','game.organisation_profiles','select')
  or has_table_privilege('authenticated','game.organisation_profiles','select')
 then raise exception 'BP04: organisation profiles exposed to client roles'; end if;
 select organisation_ref into v_ref from game.organisations order by organisation_ref limit 1;
 v_json:=game.get_organisation_record(v_ref);
 if v_json is null or not (v_json?'organisation' and v_json?'profile'
   and v_json?'business_profile' and v_json?'parent_organisation'
   and v_json?'child_organisations' and v_json?'locations'
   and v_json?'property_interests' and v_json?'control_interests'
   and v_json?'site_agreements_as_tenant' and v_json?'site_agreements_as_counterparty')
 then raise exception 'BP04: organisation dossier query missing sections'; end if;
 if (select count(*) from game.organisations where organisation_type='business')<>1452
 then raise exception 'BP04: canonical business population changed'; end if;
 if (select count(*) from game.organisations where organisation_type<>'business')<>38
 then raise exception 'BP04: canonical institution population changed'; end if;
end $$;
