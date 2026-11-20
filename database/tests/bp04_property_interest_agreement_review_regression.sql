-- BP-04 property interests and agreement review regression.
do $$
declare v_property text; v_agreement text; v_json jsonb;
begin
 if (select count(*) from game.property_interest_dossiers)<>1608
 then raise exception 'BP04: expected 1,608 property-interest dossiers'; end if;
 if exists(select 1 from game.property_interest_records i left join game.property_interest_dossiers d
 on d.property_interest_id=i.id where d.property_interest_id is null)
 then raise exception 'BP04: property interest dossier coverage gap'; end if;
 if exists(select 1 from game.property_interest_dossiers d join game.property_interest_records i
 on i.id=d.property_interest_id where d.property_id<>i.property_id or d.interest_type<>i.interest_type
 or d.holder_ref is null or d.holder_name is null)
 then raise exception 'BP04: property interest dossier does not match canonical holder/interest'; end if;
 if (select count(*) from game.property_interest_records where interest_type='registered_owner' and valid_to is null)<>656
 then raise exception 'BP04: registered owner baseline changed'; end if;
 if (select count(*) from game.property_interest_records where interest_type='landlord' and valid_to is null)<>476
 then raise exception 'BP04: landlord baseline changed'; end if;
 if (select count(*) from game.organisation_site_agreement_review_dossiers)<>1232
 then raise exception 'BP04: expected 1,232 agreement review dossiers'; end if;
 if (select count(*) from game.organisation_site_agreement_review_dossiers where counterparty_status='unresolved')<>152
 then raise exception 'BP04: unresolved counterparty count unexpectedly changed'; end if;
 if exists(select 1 from game.organisation_site_agreement_review_dossiers r
 join game.organisation_site_agreements a on a.id=r.agreement_id
 where (a.execution_date is null and not(r.missing_contract_fields?'execution_date'))
 or (a.effective_from is null and not(r.missing_contract_fields?'effective_from'))
 or (a.rent_amount is null and not(r.missing_contract_fields?'rent_amount')))
 then raise exception 'BP04: missing contract field register is incomplete'; end if;
 if exists(select 1 from game.organisation_site_agreement_review_dossiers r
 join game.organisation_site_agreements a on a.id=r.agreement_id
 where a.counterparty_organisation_id is null and a.counterparty_person_id is null
 and r.counterparty_status<>'unresolved')
 then raise exception 'BP04: unresolved counterparties incorrectly classified'; end if;
 if has_table_privilege('anon','game.property_interest_dossiers','select')
 or has_table_privilege('authenticated','game.organisation_site_agreement_review_dossiers','select')
 then raise exception 'BP04: private property/contract dossiers exposed'; end if;
 select property_ref into v_property from game.properties limit 1;
 v_json:=game.get_property_interest_record(v_property);
 if v_json is null or not(v_json?'property' and v_json?'interests' and v_json?'ownership_summary')
 then raise exception 'BP04: property interest query incomplete'; end if;
 select agreement_ref into v_agreement from game.organisation_site_agreements limit 1;
 v_json:=game.get_site_agreement_review(v_agreement);
 if v_json is null or not(v_json?'review' and v_json?'agreement' and v_json?'tenant'
  and v_json?'linked_sites' and v_json?'lifecycle_events')
 then raise exception 'BP04: agreement review query incomplete'; end if;
end $$;
