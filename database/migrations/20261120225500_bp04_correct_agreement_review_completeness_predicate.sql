-- Correct the agreement completeness predicate: a counterparty is either an organisation or a person.
update game.organisation_site_agreement_review_dossiers r
set contract_completeness_status=case
 when a.execution_date is not null and a.effective_from is not null
  and a.rent_amount is not null
  and (a.counterparty_organisation_id is not null or a.counterparty_person_id is not null)
 then 'core_terms_recorded'
 when a.counterparty_organisation_id is null and a.counterparty_person_id is null
 then 'counterparty_unresolved_and_terms_incomplete'
 else 'terms_incomplete' end,
 updated_at=now()
from game.organisation_site_agreements a
where a.id=r.agreement_id;
