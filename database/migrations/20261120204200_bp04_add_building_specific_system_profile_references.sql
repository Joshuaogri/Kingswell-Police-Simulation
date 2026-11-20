-- Give every building's seeded system design profile a stable canonical reference.
-- This differentiates dossiers without asserting unique installed equipment or inspection results.
update game.building_profiles bp
set building_systems=jsonb_set(
 bp.building_systems,'{system_design_profile}',
 (bp.building_systems->'system_design_profile')||
 jsonb_build_object('profile_reference',b.building_ref,
  'profile_variant',mod(abs(hashtext(b.building_ref)::bigint),100000)::integer),true),
 updated_at=now()
from game.buildings b
where b.id=bp.building_id and bp.building_systems?'system_design_profile';
