-- BP-04 property-interest dossiers and occupancy-agreement completeness review.
create table if not exists game.property_interest_dossiers (
 property_interest_id uuid primary key references game.property_interest_records(id) on delete restrict,
 interest_dossier_ref text not null unique,
 property_id uuid not null references game.properties(id) on delete restrict,
 property_ref text not null,
 property_address text,
 district_id uuid,
 neighbourhood_id uuid,
 road_id uuid,
 property_type text,
 land_use text,
 parcel_area_sqm numeric,
 holder_type text not null,
 holder_ref text not null,
 holder_name text not null,
 interest_type text not null,
 ownership_share_pct numeric,
 valid_from date,
 valid_to date,
 title_reference text,
 title_record_status text not null,
 source_description text,
 interest_details jsonb not null default '{}'::jsonb,
 provenance jsonb not null default '{}'::jsonb check(jsonb_typeof(provenance)='object'),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
insert into game.property_interest_dossiers(
 property_interest_id,interest_dossier_ref,property_id,property_ref,property_address,district_id,neighbourhood_id,road_id,
 property_type,land_use,parcel_area_sqm,holder_type,holder_ref,holder_name,interest_type,ownership_share_pct,
 valid_from,valid_to,title_reference,title_record_status,source_description,interest_details,provenance
)
select i.id,'KWI-'||replace(i.id::text,'-',''),p.id,p.property_ref,
 concat_ws(', ',nullif(p.address_line,''),nullif(p.postal_code,''),'Kingswell'),
 p.district_id,p.neighbourhood_id,p.road_id,p.property_type,p.land_use,p.parcel_area_sqm,
 case when i.holder_organisation_id is not null then 'organisation' else 'person' end,
 coalesce(o.organisation_ref,pe.person_ref),
 coalesce(o.name,concat_ws(' ',pe.given_name,pe.middle_names,pe.family_name)),
 i.interest_type,i.ownership_share_pct,i.valid_from,i.valid_to,i.title_reference,
 case when i.title_reference is null then 'not_recorded' else 'recorded_in_seeded_register' end,
 i.source_description,i.interest_details,
 jsonb_build_object('source','canonical property_interest_records and linked property/holder records',
 'classification','derived interest dossier','independent_title_document_not_attached',true,
 'beneficial_ownership_not_inferred_from_registered_title',true)
from game.property_interest_records i
join game.properties p on p.id=i.property_id
left join game.organisations o on o.id=i.holder_organisation_id
left join game.persons pe on pe.id=i.holder_person_id
on conflict(property_interest_id) do nothing;

create table if not exists game.organisation_site_agreement_review_dossiers (
 agreement_id uuid primary key references game.organisation_site_agreements(id) on delete restrict,
 review_dossier_ref text not null unique,
 agreement_ref text not null,
 tenant_organisation_id uuid not null references game.organisations(id) on delete restrict,
 counterparty_status text not null,
 counterparty_ref text,
 counterparty_name text,
 counterparty_role text,
 linked_site_count integer not null default 0,
 linked_property_refs jsonb not null default '[]'::jsonb,
 linked_site_refs jsonb not null default '[]'::jsonb,
 occupancy_start_dates jsonb not null default '[]'::jsonb,
 occupancy_end_dates jsonb not null default '[]'::jsonb,
 missing_contract_fields jsonb not null default '[]'::jsonb,
 contract_completeness_status text not null,
 lifecycle_event_count integer not null default 0,
 lifecycle_status text not null,
 source_reference text,
 source_description text,
 review_notes jsonb not null default '{}'::jsonb,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
insert into game.organisation_site_agreement_review_dossiers(
 agreement_id,review_dossier_ref,agreement_ref,tenant_organisation_id,counterparty_status,
 counterparty_ref,counterparty_name,counterparty_role,linked_site_count,linked_property_refs,linked_site_refs,
 occupancy_start_dates,occupancy_end_dates,missing_contract_fields,contract_completeness_status,
 lifecycle_event_count,lifecycle_status,source_reference,source_description,review_notes
)
select a.id,'KWAR-'||replace(a.id::text,'-',''),a.agreement_ref,a.tenant_organisation_id,
 case when a.counterparty_organisation_id is not null then 'organisation_linked'
      when a.counterparty_person_id is not null then 'person_linked' else 'unresolved' end,
 coalesce(co.organisation_ref,cp.person_ref),
 coalesce(co.name,concat_ws(' ',cp.given_name,cp.middle_names,cp.family_name)),
 a.counterparty_role,
 count(distinct ol.id),
 coalesce(jsonb_agg(distinct p.property_ref) filter(where p.property_ref is not null),'[]'::jsonb),
 coalesce(jsonb_agg(distinct ol.site_ref) filter(where ol.site_ref is not null),'[]'::jsonb),
 coalesce(jsonb_agg(distinct ol.valid_from) filter(where ol.valid_from is not null),'[]'::jsonb),
 coalesce(jsonb_agg(distinct ol.valid_to) filter(where ol.valid_to is not null),'[]'::jsonb),
 to_jsonb(array_remove(array[
  case when a.execution_date is null then 'execution_date' end,
  case when a.effective_from is null then 'effective_from' end,
  case when a.effective_to is null then 'effective_to' end,
  case when a.break_date is null then 'break_date' end,
  case when a.renewal_date is null then 'renewal_date' end,
  case when a.notice_days is null then 'notice_days' end,
  case when a.rent_amount is null then 'rent_amount' end,
  case when a.rent_currency is null then 'rent_currency' end,
  case when a.rent_frequency is null then 'rent_frequency' end,
  case when a.deposit_amount is null then 'deposit_amount' end,
  case when a.permitted_use is null then 'permitted_use' end,
  case when a.restrictions is null then 'restrictions' end,
  case when a.repair_responsibility is null then 'repair_responsibility' end,
  case when a.service_charge_responsibility is null then 'service_charge_responsibility' end,
  case when a.subletting_allowed is null then 'subletting_allowed' end
 ],null)),
 case when a.execution_date is not null and a.effective_from is not null
   and a.rent_amount is not null and a.counterparty_organisation_id is not null
   and a.counterparty_person_id is not null then 'core_terms_recorded'
  when a.counterparty_organisation_id is null and a.counterparty_person_id is null then 'counterparty_unresolved_and_terms_incomplete'
  else 'terms_incomplete' end,
 (select count(*) from game.organisation_site_agreement_events ev where ev.agreement_id=a.id),
 case when exists(select 1 from game.organisation_site_agreement_events ev where ev.agreement_id=a.id)
 then 'lifecycle_events_recorded' else 'no_lifecycle_events_recorded' end,
 a.source_reference,a.source_description,
 jsonb_build_object('occupancy_dates_are_not_contract_dates',true,
 'missing_fields_are_not_inferred',true,'counterparty_not_assumed_to_be_registered_owner',true,
 'review_basis','canonical agreement fields, linked site occupancy and lifecycle event table')
from game.organisation_site_agreements a
left join game.organisations co on co.id=a.counterparty_organisation_id
left join game.persons cp on cp.id=a.counterparty_person_id
left join game.organisation_site_agreement_locations al on al.agreement_id=a.id
left join game.organisation_locations ol on ol.id=al.organisation_location_id
left join game.properties p on p.id=ol.property_id
group by a.id,a.agreement_ref,a.tenant_organisation_id,a.counterparty_organisation_id,a.counterparty_person_id,
 co.organisation_ref,cp.person_ref,co.name,cp.given_name,cp.middle_names,cp.family_name,a.counterparty_role,
 a.execution_date,a.effective_from,a.effective_to,a.break_date,a.renewal_date,a.notice_days,a.rent_amount,
 a.rent_currency,a.rent_frequency,a.deposit_amount,a.permitted_use,a.restrictions,a.repair_responsibility,
 a.service_charge_responsibility,a.subletting_allowed,a.source_reference,a.source_description
on conflict(agreement_id) do nothing;

create index if not exists property_interest_dossiers_property_idx on game.property_interest_dossiers(property_id,interest_type);
create index if not exists property_interest_dossiers_holder_idx on game.property_interest_dossiers(holder_ref,interest_type);
create index if not exists agreement_review_counterparty_idx on game.organisation_site_agreement_review_dossiers(counterparty_status);
create index if not exists agreement_review_completeness_idx on game.organisation_site_agreement_review_dossiers(contract_completeness_status);

create or replace function game.get_property_interest_record(p_property_ref text)
returns jsonb language sql stable as $$
 select jsonb_build_object('property',jsonb_build_object('id',p.id,'ref',p.property_ref,
 'address',concat_ws(', ',nullif(p.address_line,''),nullif(p.postal_code,''),'Kingswell'),
 'property_type',p.property_type,'land_use',p.land_use,'parcel_area_sqm',p.parcel_area_sqm),
 'interests',coalesce((select jsonb_agg(to_jsonb(d) order by d.interest_type,d.valid_from desc nulls last)
 from game.property_interest_dossiers d where d.property_id=p.id),'[]'::jsonb),
 'ownership_summary',coalesce((select jsonb_agg(jsonb_build_object('holder_type',d.holder_type,
 'holder_ref',d.holder_ref,'holder_name',d.holder_name,'share_pct',d.ownership_share_pct,
 'title_reference',d.title_reference) order by d.holder_name)
 from game.property_interest_dossiers d where d.property_id=p.id and d.interest_type='registered_owner'),'[]'::jsonb))
 from game.properties p where p.property_ref=p_property_ref;
$$;

create or replace function game.get_site_agreement_review(p_agreement_ref text)
returns jsonb language sql stable as $$
 select jsonb_build_object('review',to_jsonb(r),'agreement',to_jsonb(a),
 'tenant',jsonb_build_object('ref',t.organisation_ref,'name',t.name),
 'counterparty',case when co.id is not null then jsonb_build_object('type','organisation','ref',co.organisation_ref,'name',co.name)
 when cp.id is not null then jsonb_build_object('type','person','ref',cp.person_ref,'name',concat_ws(' ',cp.given_name,cp.middle_names,cp.family_name))
 else null end,
 'linked_sites',coalesce((select jsonb_agg(jsonb_build_object('site_ref',ol.site_ref,'site_name',ol.site_name,
 'occupancy_status',ol.occupancy_status,'valid_from',ol.valid_from,'valid_to',ol.valid_to,
 'property_ref',p.property_ref,'address',p.address_line,'unit_ref',bu.unit_ref))
 from game.organisation_site_agreement_locations al join game.organisation_locations ol on ol.id=al.organisation_location_id
 join game.properties p on p.id=ol.property_id join game.building_units bu on bu.id=ol.building_unit_id
 where al.agreement_id=a.id),'[]'::jsonb),
 'lifecycle_events',coalesce((select jsonb_agg(to_jsonb(ev) order by ev.occurred_on nulls last,ev.created_at)
 from game.organisation_site_agreement_events ev where ev.agreement_id=a.id),'[]'::jsonb))
 from game.organisation_site_agreement_review_dossiers r
 join game.organisation_site_agreements a on a.id=r.agreement_id
 join game.organisations t on t.id=a.tenant_organisation_id
 left join game.organisations co on co.id=a.counterparty_organisation_id
 left join game.persons cp on cp.id=a.counterparty_person_id
 where a.agreement_ref=p_agreement_ref;
$$;

alter table game.property_interest_dossiers enable row level security;
alter table game.organisation_site_agreement_review_dossiers enable row level security;
revoke all on game.property_interest_dossiers,game.organisation_site_agreement_review_dossiers from public,anon,authenticated;
grant all on game.property_interest_dossiers,game.organisation_site_agreement_review_dossiers to service_role;
