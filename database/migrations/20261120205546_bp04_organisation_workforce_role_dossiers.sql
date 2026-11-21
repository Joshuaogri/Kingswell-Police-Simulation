-- BP-04 workforce/role dossier tranche: enrich existing personnel links only.
create table if not exists game.organisation_job_role_catalog (
 job_role_ref text primary key, job_title text not null unique, role_family text not null,
 role_summary text not null, typical_responsibilities jsonb not null default '[]'::jsonb check(jsonb_typeof(typical_responsibilities)='array'),
 sector_scope text not null, supervision_status text not null default 'not_recorded',
 access_authority_status text not null default 'not_recorded',
 provenance jsonb not null default '{}'::jsonb check(jsonb_typeof(provenance)='object')
);
insert into game.organisation_job_role_catalog(job_role_ref,job_title,role_family,role_summary,typical_responsibilities,sector_scope,provenance)
select 'KWROLE-'||upper(regexp_replace(job_title,'[^A-Za-z0-9]+','-','g')),job_title,
 case when job_title ilike '%Financial%' then 'finance_and_customer_accounts'
 when job_title ilike '%Trade%' or job_title ilike '%Wholesale%' then 'trade_and_commercial_operations'
 when job_title ilike '%Logistics%' then 'warehouse_and_logistics'
 when job_title ilike '%Transport%' then 'transport_operations'
 when job_title ilike '%Neighbourhood%' then 'community_and_local_services'
 when job_title ilike '%Retail%' then 'retail_and_customer_service'
 when job_title ilike '%Production%' then 'production_and_manufacturing'
 when job_title ilike '%Hospitality%' then 'hospitality_and_visitor_services'
 when job_title ilike '%Professional%' then 'professional_services'
 when job_title ilike '%Technology%' then 'technology_and_media'
 when job_title ilike '%Construction%' then 'construction_and_property'
 when job_title ilike '%Property Management%' then 'property_management'
 else 'general_business_operations' end,
 'Role description derived from the existing canonical job title; role-family guide, not a verified individual job specification.',
 case when job_title ilike '%Financial%' then '["customer account support","transaction processing","financial service administration","record handling"]'::jsonb
 when job_title ilike '%Trade%' or job_title ilike '%Wholesale%' then '["trade order processing","supplier and customer coordination","goods movement administration","commercial records"]'::jsonb
 when job_title ilike '%Logistics%' then '["goods receipt and dispatch","stock movement","warehouse operations","inventory handling"]'::jsonb
 when job_title ilike '%Transport%' then '["transport service operations","vehicle or passenger coordination","route and service support","operational records"]'::jsonb
 when job_title ilike '%Neighbourhood%' then '["local service delivery","community-facing support","service request handling","neighbourhood operations"]'::jsonb
 when job_title ilike '%Retail%' then '["customer assistance","sales transactions","merchandise handling","shop-floor operations"]'::jsonb
 when job_title ilike '%Production%' then '["production activities","materials handling","quality and output recording","workplace operations"]'::jsonb
 when job_title ilike '%Hospitality%' then '["guest assistance","service delivery","booking coordination","venue operations"]'::jsonb
 when job_title ilike '%Professional%' then '["client service delivery","professional administration","case or project support","business records"]'::jsonb
 when job_title ilike '%Technology%' then '["technology or media support","digital systems or content operations","technical administration","service records"]'::jsonb
 when job_title ilike '%Construction%' then '["construction or property project support","site coordination","materials and contractor liaison","project records"]'::jsonb
 when job_title ilike '%Property Management%' then '["premises administration","occupier liaison","maintenance coordination","property records"]'::jsonb
 else '["business operations","customer or supplier coordination","routine administrative records"]'::jsonb end,
 'Derived from existing seeded fictional employment title; actual sector inherited from employing organisation.',
 jsonb_build_object('source','game.organisation_personnel.job_title','classification','seeded fictional role-family reference','not_an_individual_job_description',true)
from (select distinct job_title from game.organisation_personnel) t
on conflict(job_title) do nothing;

create table if not exists game.organisation_personnel_dossiers (
 organisation_personnel_id uuid primary key references game.organisation_personnel(id) on delete restrict,
 job_role_ref text not null references game.organisation_job_role_catalog(job_role_ref) on delete restrict,
 employment_record_ref text not null unique, employment_summary text not null,
 work_scope jsonb not null default '{}'::jsonb check(jsonb_typeof(work_scope)='object'),
 department_assignment_status text not null default 'not_recorded',
 supervisor_assignment_status text not null default 'not_recorded',
 physical_site_assignment_status text not null default 'not_recorded',
 work_schedule_status text not null default 'not_recorded',
 authority_and_system_access_status text not null default 'not_recorded',
 record_provenance jsonb not null default '{}'::jsonb check(jsonb_typeof(record_provenance)='object'),
 created_at timestamptz not null default now(),updated_at timestamptz not null default now()
);
insert into game.organisation_personnel_dossiers(organisation_personnel_id,job_role_ref,employment_record_ref,employment_summary,work_scope,record_provenance)
select op.id,c.job_role_ref,'KWEMP-'||replace(op.id::text,'-',''),c.role_summary,
 jsonb_build_object('canonical_job_title',op.job_title,'employment_type',op.employment_type,
 'current_status',case when op.is_current then 'current' else 'historical' end,
 'valid_from',op.valid_from,'valid_to',op.valid_to,'employing_organisation_id',op.organisation_id,'person_id',op.person_id),
 jsonb_build_object('source','existing game.organisation_personnel record and canonical job-role catalogue',
 'classification','derived fictional workforce dossier','no_person_identity_created',true,
 'department_supervisor_site_schedule_and_access_not_inferred',true)
from game.organisation_personnel op join game.organisation_job_role_catalog c on c.job_title=op.job_title
on conflict(organisation_personnel_id) do nothing;

create index if not exists organisation_personnel_dossiers_role_idx on game.organisation_personnel_dossiers(job_role_ref);
create index if not exists organisation_personnel_org_current_idx on game.organisation_personnel(organisation_id,is_current,job_title);

create or replace function game.get_organisation_workforce_record(p_organisation_ref text)
returns jsonb language sql stable as $$
 select jsonb_build_object(
 'organisation',jsonb_build_object('id',o.id,'ref',o.organisation_ref,'name',o.name,'type',o.organisation_type),
 'workforce_summary',jsonb_build_object('total_links',count(op.id),
 'current_employees',count(op.id) filter(where op.is_current),
 'distinct_people',count(distinct op.person_id),'role_families',count(distinct rc.role_family),
 'department_assignments_recorded',count(*) filter(where d.department_assignment_status<>'not_recorded'),
 'supervisor_assignments_recorded',count(*) filter(where d.supervisor_assignment_status<>'not_recorded'),
 'physical_site_assignments_recorded',count(*) filter(where d.physical_site_assignment_status<>'not_recorded')),
 'role_breakdown',coalesce((select jsonb_agg(to_jsonb(rb) order by rb.total desc,rb.job_title) from (
  select rc2.job_title,rc2.role_family,count(op2.id) total,count(op2.id) filter(where op2.is_current) current
  from game.organisation_personnel op2 join game.organisation_personnel_dossiers d2 on d2.organisation_personnel_id=op2.id
  join game.organisation_job_role_catalog rc2 on rc2.job_role_ref=d2.job_role_ref
  where op2.organisation_id=o.id group by rc2.job_title,rc2.role_family
 ) rb),'[]'::jsonb),
 'employees',coalesce(jsonb_agg(jsonb_build_object('employment',to_jsonb(op),'dossier',to_jsonb(d),'role',to_jsonb(rc),
  'person',jsonb_build_object('id',p.id,'ref',p.person_ref,'name',concat_ws(' ',p.given_name,p.middle_names,p.family_name)))
  order by op.job_title,p.family_name,p.given_name) filter(where op.id is not null),'[]'::jsonb),
 'assignment_policy',jsonb_build_object('departments','not_recorded_until_created_as_canonical_records',
 'supervisors','not_inferred_from_job_titles','physical_sites','not_assumed_from_employer_site_or_home_address',
 'work_schedules','not_generated_by_this_dossier'))
 from game.organisations o left join game.organisation_personnel op on op.organisation_id=o.id
 left join game.organisation_personnel_dossiers d on d.organisation_personnel_id=op.id
 left join game.organisation_job_role_catalog rc on rc.job_role_ref=d.job_role_ref
 left join game.persons p on p.id=op.person_id
 where o.organisation_ref=p_organisation_ref group by o.id,o.organisation_ref,o.name,o.organisation_type;
$$;

create or replace function game.get_person_employment_record(p_person_ref text)
returns jsonb language sql stable as $$
 select jsonb_build_object('person',jsonb_build_object('id',p.id,'ref',p.person_ref,
 'name',concat_ws(' ',p.given_name,p.middle_names,p.family_name)),
 'employment',coalesce(jsonb_agg(jsonb_build_object('employment',to_jsonb(op),'dossier',to_jsonb(d),'role',to_jsonb(rc),
 'organisation',jsonb_build_object('id',o.id,'ref',o.organisation_ref,'name',o.name,'type',o.organisation_type))
 order by op.valid_from desc nulls last,o.name) filter(where op.id is not null),'[]'::jsonb))
 from game.persons p left join game.organisation_personnel op on op.person_id=p.id
 left join game.organisation_personnel_dossiers d on d.organisation_personnel_id=op.id
 left join game.organisation_job_role_catalog rc on rc.job_role_ref=d.job_role_ref
 left join game.organisations o on o.id=op.organisation_id
 where p.person_ref=p_person_ref group by p.id,p.person_ref,p.given_name,p.middle_names,p.family_name;
$$;
alter table game.organisation_job_role_catalog enable row level security;
alter table game.organisation_personnel_dossiers enable row level security;
revoke all on game.organisation_job_role_catalog,game.organisation_personnel_dossiers from public,anon,authenticated;
grant all on game.organisation_job_role_catalog,game.organisation_personnel_dossiers to service_role;
