alter function game.get_case_review_dossier(text) rename to get_case_review_dossier_before_disclosure;
create or replace function game.get_case_review_dossier(p_case_ref text)
returns jsonb language plpgsql stable set search_path='pg_catalog','game' as $$
declare base jsonb; cid uuid;
begin
 base:=game.get_case_review_dossier_before_disclosure(p_case_ref);
 if coalesce((base->>'ok')::boolean,false) is not true then return base;end if;
 select id into cid from game.cases where case_ref=btrim(p_case_ref);
 return jsonb_set(base,'{disclosure}',jsonb_build_object(
  'defence_counsel',(select coalesce(jsonb_agg(jsonb_build_object('counsel_ref',dc.counsel_ref,'person_ref',p.person_ref,'name',concat_ws(' ',p.given_name,p.middle_names,p.family_name),'status',dc.status,'assignment_status',da.status,'assigned_at',da.assigned_at_game_time) order by da.assigned_at_game_time),'[]'::jsonb) from game.defence_counsel_assignments da join game.defence_counsel_profiles dc on dc.id=da.counsel_id join game.persons p on p.id=dc.person_id where da.case_id=cid),
  'packages',(select coalesce(jsonb_agg(jsonb_build_object('package_ref',dp.package_ref,'type',dp.package_type,'title',dp.title,'status',dp.status,'created_at',dp.created_at_game_time,'served_at',dp.served_at_game_time,'acknowledged_at',dp.acknowledged_at_game_time,
   'items',(select coalesce(jsonb_agg(jsonb_build_object('item_ref',di.item_ref,'category',di.category,'source_ref',di.source_ref,'title',di.title,'description',di.description,'treatment',di.treatment,'treatment_reason',di.treatment_reason) order by di.item_ref),'[]'::jsonb) from game.disclosure_items di where di.package_id=dp.id),
   'receipt',(select jsonb_build_object('recipient_kind',dr.recipient_kind,'recipient_person_ref',rp.person_ref,'served_at',dr.served_at_game_time,'acknowledged_at',dr.acknowledged_at_game_time) from game.disclosure_receipts dr join game.persons rp on rp.id=dr.recipient_person_id where dr.package_id=dp.id)
  ) order by dp.created_at_game_time,dp.package_ref),'[]'::jsonb) from game.disclosure_packages dp where dp.case_id=cid)
 ),true);
end $$;
revoke all on function game.get_case_review_dossier(text) from public,anon,authenticated;
grant execute on function game.get_case_review_dossier(text) to service_role;
