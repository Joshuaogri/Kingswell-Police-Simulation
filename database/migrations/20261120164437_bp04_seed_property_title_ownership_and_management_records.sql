with ranked_properties as (
 select p.*,row_number() over(order by p.property_ref) rn from game.properties p
),
owners as (
 select p.id property_id,p.property_ref,
  case when p.land_use in ('civic_and_public','education_and_health') then pub_est.id
   when p.land_use='aviation' then airport.id when p.land_use='port_and_maritime' then port.id
   when p.land_use='transport_and_commercial' then terminal.id else estate.id end owner_id,
  case when p.land_use in ('civic_and_public','education_and_health','aviation','port_and_maritime') then 'public_or_institutional'
   else 'private_estate_holding' end owner_kind
 from ranked_properties p
 left join game.organisations pub_est on pub_est.organisation_ref='KWORG-PUB-01'
 left join game.organisations airport on airport.organisation_ref='KWORG-PUB-17'
 left join game.organisations port on port.organisation_ref='KWORG-PUB-16'
 left join game.organisations terminal on terminal.organisation_ref='KWORG-EST-12'
 left join game.organisations estate on estate.organisation_ref='KWORG-EST-'||lpad((1+mod(p.rn-1,12))::text,2,'0')
)
insert into game.property_interest_records(property_id,holder_organisation_id,interest_type,ownership_share_pct,valid_from,title_reference,source_description,interest_details)
select o.property_id,o.owner_id,'registered_owner',100,date '1985-01-01','KNG-TITLE-'||replace(o.property_ref,'KNG-P-',''),
 'Fictional registered-title entry created for the Kingswell property register.',
 jsonb_build_object('record_basis','seeded_city_property_register','ownership_type',o.owner_kind)
from owners o
where not exists(select 1 from game.property_interest_records pir where pir.property_id=o.property_id and pir.interest_type='registered_owner' and pir.valid_to is null);

insert into game.property_interest_records(property_id,holder_organisation_id,interest_type,valid_from,title_reference,source_description,interest_details)
select p.id,pir.holder_organisation_id,'landlord',date '1985-01-01',pir.title_reference,
 'Landlord relationship follows the registered estate holder in the seeded fictional property register.',
 jsonb_build_object('landlord_basis','registered_estate_holder','lease_records','recorded_at_occupier_site')
from game.properties p join game.property_interest_records pir on pir.property_id=p.id
 and pir.interest_type='registered_owner' and pir.valid_to is null
where p.land_use not in ('civic_and_public','education_and_health','aviation','port_and_maritime')
 and not exists(select 1 from game.property_interest_records x where x.property_id=p.id and x.interest_type='landlord' and x.valid_to is null);

insert into game.property_interest_records(property_id,holder_organisation_id,interest_type,valid_from,title_reference,source_description,interest_details)
select p.id,manager.id,'property_manager',date '2005-01-01','KNG-TITLE-'||replace(p.property_ref,'KNG-P-',''),
 'Fictional estate-management appointment recorded against the property.',
 jsonb_build_object('management_scope','building_and_common_areas','service_records','future_property_management_system')
from game.properties p
join game.organisations manager on manager.organisation_ref='KWORG-EST-'||
 lpad((1+mod(ascii(substr(p.property_ref,length(p.property_ref),1))::integer,12))::text,2,'0')
where p.land_use not in ('civic_and_public','education_and_health','aviation','port_and_maritime')
 and not exists(select 1 from game.property_interest_records x where x.property_id=p.id and x.interest_type='property_manager' and x.valid_to is null);
