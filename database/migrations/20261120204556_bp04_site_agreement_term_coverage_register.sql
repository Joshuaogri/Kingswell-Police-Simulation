-- BP-04: add a transparent clause-completeness register to each existing site agreement.
-- This records whether terms are evidenced in canonical agreement columns; it does not
-- invent contract dates, rents, deposits, repair obligations or counterparties.

update game.organisation_site_agreements a
set agreement_details = coalesce(a.agreement_details,'{}'::jsonb)
 || jsonb_build_object(
  'contract_term_coverage',jsonb_build_object(
   'coverage_basis','review_of_canonical_agreement_columns',
   'execution_date',case when a.execution_date is null then 'not_recorded' else 'recorded' end,
   'effective_from',case when a.effective_from is null then 'not_recorded' else 'recorded' end,
   'effective_to',case when a.effective_to is null then 'not_recorded' else 'recorded' end,
   'break_date',case when a.break_date is null then 'not_recorded' else 'recorded' end,
   'renewal_date',case when a.renewal_date is null then 'not_recorded' else 'recorded' end,
   'notice_days',case when a.notice_days is null then 'not_recorded' else 'recorded' end,
   'rent_amount',case when a.rent_amount is null then 'not_recorded' else 'recorded' end,
   'rent_currency',case when a.rent_currency is null then 'not_recorded' else 'recorded' end,
   'rent_frequency',case when a.rent_frequency is null then 'not_recorded' else 'recorded' end,
   'deposit_amount',case when a.deposit_amount is null then 'not_recorded' else 'recorded' end,
   'permitted_use',case when a.permitted_use is null then 'not_recorded' else 'recorded' end,
   'restrictions',case when a.restrictions is null then 'not_recorded' else 'recorded' end,
   'repair_responsibility',case when a.repair_responsibility is null then 'not_recorded' else 'recorded' end,
   'service_charge_responsibility',case when a.service_charge_responsibility is null then 'not_recorded' else 'recorded' end,
   'subletting_allowed',case when a.subletting_allowed is null then 'not_recorded' else 'recorded' end,
   'counterparty',case
     when a.counterparty_organisation_id is not null then 'organisation_linked'
     when a.counterparty_person_id is not null then 'person_linked'
     else 'not_identified' end,
   'occupancy_dates_are_contract_dates',false,
   'note','Site occupancy dates are retained as occupancy provenance and are not substituted for execution or contractual effective dates.'
  ),
  'term_coverage_provenance',jsonb_build_object(
   'source','existing canonical agreement columns and linked site occupancy record',
   'method','field-presence audit only',
   'unknown_values','left null and explicitly marked not_recorded',
   'last_reviewed_on','2026-11-20'
  )
 ),
 updated_at=now()
where a.agreement_type in ('commercial_lease','small_commercial_lease');

do $$
begin
 if (select count(*) from game.organisation_site_agreements
     where agreement_details ? 'contract_term_coverage')<>1232 then
  raise exception 'BP-04 agreement term coverage register incomplete'; end if;
 if exists(
  select 1 from game.organisation_site_agreements a
  where a.agreement_details#>>'{contract_term_coverage,occupancy_dates_are_contract_dates}'<>'false'
     or a.agreement_details#>>'{term_coverage_provenance,method}'<>'field-presence audit only'
 ) then raise exception 'BP-04 agreement term provenance invalid'; end if;
 if exists(
  select 1 from game.organisation_site_agreements a
  where a.execution_date is null
    and a.agreement_details#>>'{contract_term_coverage,execution_date}'<>'not_recorded'
 ) then raise exception 'BP-04 agreement execution-date unknown state inconsistent'; end if;
end $$;
