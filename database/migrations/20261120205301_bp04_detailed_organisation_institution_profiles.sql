-- BP-04 canonical organisation and institution dossiers.
-- Adds one dossier per existing organisation; does not create organisations,
-- parent links, directors, regulators or legal identities.
create table if not exists game.organisation_profiles (
 organisation_id uuid primary key references game.organisations(id) on delete restrict,
 profile_ref text not null unique,
 organisation_class text not null check(organisation_class in
  ('commercial_business','public_government','public_service','public_authority',
   'financial_institution','property_holding','education','healthcare',
   'transport_infrastructure','media_culture','other_institution')),
 operating_model text not null,
 primary_remit text not null,
 service_or_market_scope text not null,
 governance_structure_status text not null default 'not_recorded',
 legal_form_status text not null default 'not_recorded',
 registration_identifier_status text not null default 'not_recorded',
 regulator_or_oversight_status text not null default 'not_recorded',
 parent_relationship_status text not null default 'not_recorded',
 branch_network_summary text not null,
 staffing_summary text not null,
 premises_summary text not null,
 public_contact_profile text not null,
 operational_dependencies jsonb not null default '{}'::jsonb check(jsonb_typeof(operational_dependencies)='object'),
 profile_provenance jsonb not null default '{}'::jsonb check(jsonb_typeof(profile_provenance)='object'),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);

with classified as (
 select o.*,
 case
  when o.organisation_type='business' then 'commercial_business'
  when o.organisation_type in ('city_government','government_ministry','government_department','executive_office','legislature') then 'public_government'
  when o.organisation_type in ('public_hospital','emergency_service','public_university','national_archive','public_broadcaster') then 'public_service'
  when o.organisation_type in ('trade_authority','port_authority','airport_authority','customs_authority','transport_authority','revenue_authority','financial_regulator') then 'public_authority'
  when o.organisation_type='central_bank' then 'financial_institution'
  when o.organisation_type='property_holding_company' or o.organisation_type='public_estate_authority' then 'property_holding'
  when o.organisation_type='public_university' then 'education'
  when o.organisation_type='public_hospital' then 'healthcare'
  when o.organisation_type in ('port_authority','airport_authority','transport_authority','public_transport_operator') then 'transport_infrastructure'
  when o.organisation_type in ('public_broadcaster','national_archive') then 'media_culture'
  else 'other_institution' end as org_class
 from game.organisations o
)
insert into game.organisation_profiles(
 organisation_id,profile_ref,organisation_class,operating_model,primary_remit,
 service_or_market_scope,branch_network_summary,staffing_summary,premises_summary,
 public_contact_profile,operational_dependencies,profile_provenance
)
select c.id,'KWORG-PROFILE-'||c.organisation_ref,c.org_class,
 case when c.organisation_type='business' then 'Commercial trading organisation; detailed activity is held in the linked business profile.'
      when c.organisation_type='property_holding_company' then 'Property ownership and asset-holding organisation; asset operations depend on recorded property and site interests.'
      when c.organisation_type='city_government' then 'Municipal executive organisation; internal departments and delegated authority require separate records.'
      when c.organisation_type='government_ministry' then 'Government ministry; portfolio and subordinate bodies require separate authoritative records.'
      when c.organisation_type='government_department' then 'Government department; operational remit and reporting line require separate records.'
      when c.organisation_type='public_hospital' then 'Public healthcare institution; clinical departments and service capacity require separate records.'
      when c.organisation_type='public_university' then 'Public higher-education institution; faculties and campus operations require separate records.'
      when c.organisation_type in ('port_authority','airport_authority','transport_authority','public_transport_operator') then 'Transport and infrastructure organisation; operational facilities and service schedules require separate records.'
      when c.organisation_type in ('trade_authority','customs_authority','revenue_authority','financial_regulator','central_bank') then 'Specialist public or financial institution; statutory remit and oversight relationships require separate records.'
      else 'Institutional organisation; detailed internal operating structure requires separate records.' end,
 case when c.organisation_type='business' then 'Commercial goods, services and trading activity; consult linked business profile.'
      when c.organisation_type='property_holding_company' then 'Property holding, leasing and asset interests.'
      when c.organisation_type='public_hospital' then 'Public healthcare provision.'
      when c.organisation_type='public_university' then 'Higher education and research.'
      when c.organisation_type='emergency_service' then 'Public emergency response service.'
      when c.organisation_type='public_broadcaster' then 'Public broadcasting and information.'
      when c.organisation_type='national_archive' then 'Public records and archival services.'
      when c.organisation_type='public_transport_operator' then 'Public transport operations.'
      else replace(initcap(replace(c.organisation_type,'_',' ')),'  ',' ')||' institutional remit.' end,
 case when c.organisation_type='business' then 'Commercial customers, suppliers and business counterparties; specific market detail is held in the business profile.'
      else 'Kingswell city and relevant institutional service users; precise eligibility and service catchment not separately recorded.' end,
 case when exists(select 1 from game.organisation_locations l where l.organisation_id=c.id and l.valid_to is null)
      then 'Current sites are listed in the linked organisation-location register; branch designation beyond recorded site roles is not inferred.'
      else 'No current site link recorded; this does not establish that the organisation has no premises.' end,
 case when c.organisation_type='business' then 'Use linked business profile employee estimate; individual staff records remain separately authoritative.'
      else 'Organisation-specific staffing establishment, vacancies and reporting lines are not yet recorded in this dossier.' end,
 case when exists(select 1 from game.organisation_locations l where l.organisation_id=c.id and l.valid_to is null)
      then 'Premises are represented by linked canonical organisation-location records.'
      else 'Premises not linked in the current organisation-location register.' end,
 'Public contact channels, named officers and opening hours require explicit source records; none are inferred by this dossier.',
 jsonb_build_object(
  'organisation_type',c.organisation_type,
  'parent_organisation_id',c.parent_organisation_id,
  'business_profile_linked',exists(select 1 from game.business_profiles bp where bp.organisation_id=c.id),
  'current_site_count',(select count(*) from game.organisation_locations l where l.organisation_id=c.id and l.valid_to is null),
  'property_interest_count',(select count(*) from game.property_interest_records pi where pi.holder_organisation_id=c.id and pi.valid_to is null),
  'site_agreement_counterparty_count',(select count(*) from game.organisation_site_agreements a where a.counterparty_organisation_id=c.id)
 ),
 jsonb_build_object(
  'source','existing canonical game.organisations, business_profiles, organisation_locations, property_interest_records and site_agreements',
  'basis','derived fictional organisation dossier; not proof of legal registration, regulator approval, governance membership or actual public contact details',
  'unknowns_preserved',true
 )
from classified c
on conflict(organisation_id) do update set
 organisation_class=excluded.organisation_class,
 operating_model=excluded.operating_model,
 primary_remit=excluded.primary_remit,
 service_or_market_scope=excluded.service_or_market_scope,
 branch_network_summary=excluded.branch_network_summary,
 staffing_summary=excluded.staffing_summary,
 premises_summary=excluded.premises_summary,
 public_contact_profile=excluded.public_contact_profile,
 operational_dependencies=excluded.operational_dependencies,
 profile_provenance=excluded.profile_provenance,
 updated_at=now();

create index if not exists organisation_profiles_class_idx on game.organisation_profiles(organisation_class,profile_ref);

create or replace function game.get_organisation_record(p_organisation_ref text)
returns jsonb language sql stable as $$
 select jsonb_build_object(
  'organisation',to_jsonb(o),
  'profile',to_jsonb(op),
  'business_profile',to_jsonb(bp),
  'parent_organisation',to_jsonb(parent_org),
  'child_organisations',coalesce((select jsonb_agg(to_jsonb(child) order by child.organisation_ref)
    from game.organisations child where child.parent_organisation_id=o.id),'[]'::jsonb),
  'locations',coalesce((select jsonb_agg(jsonb_build_object(
    'site',to_jsonb(ol),'property',to_jsonb(p),'address',to_jsonb(pa),
    'building',to_jsonb(b),'unit',to_jsonb(u))
    order by ol.is_primary_location desc,p.property_ref,ol.site_ref)
    from game.organisation_locations ol
    join game.properties p on p.id=ol.property_id
    left join game.property_addresses pa on pa.property_id=p.id and pa.is_primary
    left join game.building_units u on u.id=ol.building_unit_id
    left join game.buildings b on b.id=u.building_id
    where ol.organisation_id=o.id),'[]'::jsonb),
  'property_interests',coalesce((select jsonb_agg(to_jsonb(pi) order by pi.interest_type,pi.valid_from)
    from game.property_interest_records pi where pi.holder_organisation_id=o.id),'[]'::jsonb),
  'control_interests',coalesce((select jsonb_agg(to_jsonb(ci) order by ci.control_type,ci.valid_from)
    from game.organisation_control_interests ci
    where ci.organisation_id=o.id or ci.holder_organisation_id=o.id),'[]'::jsonb),
  'site_agreements_as_tenant',coalesce((select jsonb_agg(to_jsonb(a) order by a.agreement_ref)
    from game.organisation_site_agreements a where a.tenant_organisation_id=o.id),'[]'::jsonb),
  'site_agreements_as_counterparty',coalesce((select jsonb_agg(to_jsonb(a) order by a.agreement_ref)
    from game.organisation_site_agreements a where a.counterparty_organisation_id=o.id),'[]'::jsonb)
 )
 from game.organisations o
 join game.organisation_profiles op on op.organisation_id=o.id
 left join game.business_profiles bp on bp.organisation_id=o.id
 left join game.organisations parent_org on parent_org.id=o.parent_organisation_id
 where o.organisation_ref=p_organisation_ref;
$$;

alter table game.organisation_profiles enable row level security;
revoke all on game.organisation_profiles from public,anon,authenticated;
grant all on game.organisation_profiles to service_role;
