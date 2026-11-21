-- BP-04: expose existing property title, asset, maintenance and agreement lifecycle histories
-- in the canonical property dossier. No tables or facts are created.

create or replace function game.get_property_record(p_property_ref text)
returns jsonb
language sql
stable
set search_path to 'pg_catalog','game'
as $function$
select jsonb_build_object(
  'property',to_jsonb(p),
  'district',jsonb_build_object('code',d.code,'name',d.name,'type',d.district_type),
  'neighbourhood',jsonb_build_object('code',n.code,'name',n.name),
  'road',jsonb_build_object('name',r.name,'type',r.road_type),
  'profile',to_jsonb(pp),
  'addresses',coalesce((
    select jsonb_agg(to_jsonb(a) order by a.is_primary desc,a.address_ref)
    from game.property_addresses a where a.property_id=p.id
  ),'[]'::jsonb),
  'access_points',coalesce((
    select jsonb_agg(jsonb_build_object(
      'access',to_jsonb(ap),'road_segment',to_jsonb(rs),
      'nearest_junction',jsonb_build_object('code',j.junction_code,'name',j.junction_name,'x_m',j.x_m,'y_m',j.y_m)
    ) order by ap.is_primary desc,ap.access_ref)
    from game.property_access_points ap
    join game.road_segments rs on rs.id=ap.road_segment_id
    join game.road_junctions j on j.id=ap.nearest_junction_id
    where ap.property_id=p.id
  ),'[]'::jsonb),
  'interests',coalesce((
    select jsonb_agg(jsonb_build_object('interest',to_jsonb(pi),'holder_organisation',to_jsonb(o))
      order by pi.interest_type,pi.valid_from)
    from game.property_interest_records pi
    left join game.organisations o on o.id=pi.holder_organisation_id
    where pi.property_id=p.id
  ),'[]'::jsonb),
  'valuation_history',coalesce((
    select jsonb_agg(to_jsonb(v) order by v.assessed_on desc,v.created_at desc)
    from game.property_valuation_records v where v.property_id=p.id
  ),'[]'::jsonb),
  'title_events',coalesce((
    select jsonb_agg(jsonb_build_object(
      'event',to_jsonb(e),
      'transferor_organisation',to_jsonb(tfo),
      'transferor_person',to_jsonb(tfp),
      'transferee_organisation',to_jsonb(tto),
      'transferee_person',to_jsonb(ttp)
    ) order by e.occurred_on desc nulls last,e.recorded_on desc nulls last,e.created_at desc)
    from game.property_title_events e
    left join game.organisations tfo on tfo.id=e.transferor_organisation_id
    left join game.persons tfp on tfp.id=e.transferor_person_id
    left join game.organisations tto on tto.id=e.transferee_organisation_id
    left join game.persons ttp on ttp.id=e.transferee_person_id
    where e.property_id=p.id
  ),'[]'::jsonb),
  'asset_events',coalesce((
    select jsonb_agg(to_jsonb(e) order by e.occurred_on desc nulls last,e.created_at desc)
    from game.property_asset_events e where e.property_id=p.id
  ),'[]'::jsonb),
  'physical_assets',coalesce((
    select jsonb_agg(to_jsonb(a) order by a.asset_category,a.asset_ref)
    from game.property_physical_assets a where a.property_id=p.id
  ),'[]'::jsonb),
  'asset_maintenance_events',coalesce((
    select jsonb_agg(jsonb_build_object('event',to_jsonb(me),'asset_ref',a.asset_ref,'asset_name',a.asset_name)
      order by me.occurred_at desc nulls last,me.created_at desc)
    from game.physical_asset_maintenance_events me
    join game.property_physical_assets a on a.id=me.asset_id
    where a.property_id=p.id
  ),'[]'::jsonb),
  'site_agreements',coalesce((
    select jsonb_agg(jsonb_build_object(
      'agreement',to_jsonb(a),
      'site',to_jsonb(ol),
      'tenant',to_jsonb(tenant),
      'counterparty_organisation',to_jsonb(cp),
      'lifecycle_events',coalesce((
        select jsonb_agg(to_jsonb(ae) order by ae.occurred_on,ae.recorded_on,ae.created_at)
        from game.organisation_site_agreement_events ae
        where ae.agreement_id=a.id
      ),'[]'::jsonb)
    ) order by a.agreement_ref)
    from game.organisation_site_agreement_locations al
    join game.organisation_site_agreements a on a.id=al.agreement_id
    join game.organisation_locations ol on ol.id=al.organisation_location_id
    join game.organisations tenant on tenant.id=a.tenant_organisation_id
    left join game.organisations cp on cp.id=a.counterparty_organisation_id
    where ol.property_id=p.id
  ),'[]'::jsonb),
  'buildings',coalesce((
    select jsonb_agg(jsonb_build_object(
      'building',to_jsonb(b),'profile',to_jsonb(bp),
      'units',(
        select coalesce(jsonb_agg(jsonb_build_object(
          'unit',to_jsonb(u),'profile',to_jsonb(up),
          'occupiers',(
            select coalesce(jsonb_agg(jsonb_build_object(
              'organisation',to_jsonb(oo),'business',to_jsonb(biz),'site',to_jsonb(ol)
            )),'[]'::jsonb)
            from game.organisation_locations ol
            join game.organisations oo on oo.id=ol.organisation_id
            left join game.business_profiles biz on biz.organisation_id=oo.id
            where ol.building_unit_id=u.id and ol.valid_to is null
          )
        ) order by up.floor_number,u.unit_ref),'[]'::jsonb)
        from game.building_units u
        left join game.building_unit_profiles up on up.building_unit_id=u.id
        where u.building_id=b.id
      )
    ) order by b.building_ref)
    from game.buildings b
    left join game.building_profiles bp on bp.building_id=b.id
    where b.property_id=p.id
  ),'[]'::jsonb),
  'record_coverage',jsonb_build_object(
    'title_history','recorded_events_only',
    'physical_assets','recorded_assets_only',
    'asset_maintenance','recorded_events_only',
    'agreement_lifecycle','recorded_events_only',
    'unknown_values_are_not_inferred',true,
    'empty_history_does_not_prove_no_historical_event',true
  )
)
from game.properties p
join game.districts d on d.id=p.district_id
join game.neighbourhoods n on n.id=p.neighbourhood_id
left join game.roads r on r.id=p.road_id
left join game.property_profiles pp on pp.property_id=p.id
where p.property_ref=p_property_ref;
$function$;
