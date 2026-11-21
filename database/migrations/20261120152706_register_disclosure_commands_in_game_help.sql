CREATE OR REPLACE FUNCTION game.execute_justice_command(p_command_id uuid, p_type text, p jsonb, p_actor_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare
 n timestamptz; res jsonb; pro game.prosecutor_profiles%rowtype; counsel game.defence_counsel_profiles%rowtype;
 person_row game.persons%rowtype; cas game.cases%rowtype; ref game.prosecution_referrals%rowtype;
 pkg game.disclosure_packages%rowtype; item game.disclosure_items%rowtype; receipt game.disclosure_receipts%rowtype;
 ev game.evidence_items%rowtype; recipient game.persons%rowtype; actor_kind text; actor_id uuid;
begin
 if p_type='help' then
  res:=game.execute_justice_command_before_disclosure(p_command_id,p_type,p,p_actor_id);
  return jsonb_set(res,'{available_commands}',(select coalesce(jsonb_agg(distinct x),'[]'::jsonb) from jsonb_array_elements_text(coalesce(res->'available_commands','[]'::jsonb)||jsonb_build_array('assign_defence_counsel','create_prosecution_disclosure','create_defence_disclosure','add_disclosure_item','set_disclosure_item_treatment','serve_disclosure_package','acknowledge_disclosure_package','get_disclosure_packages','get_disclosure_package')) x),true);
 end if;
 if p_type not in ('assign_defence_counsel','create_prosecution_disclosure','create_defence_disclosure','add_disclosure_item','set_disclosure_item_treatment','serve_disclosure_package','acknowledge_disclosure_package','get_disclosure_packages','get_disclosure_package') then
  return game.execute_justice_command_before_disclosure(p_command_id,p_type,p,p_actor_id);
 end if;
 select current_game_time into n from game.simulation_state where id=1 for update;
 if n is null then return jsonb_build_object('ok',false,'code','clock_not_initialized');end if;

 if p_type='assign_defence_counsel' then
  select * into pro from game.prosecutor_profiles where prosecutor_ref=p->>'prosecutor_ref' and status='active';
  select * into cas from game.cases where case_ref=p->>'case_ref' and status='open';
  select * into person_row from game.persons where person_ref=p->>'person_ref';
  if pro.id is null or cas.id is null or person_row.id is null then return jsonb_build_object('ok',false,'code','active_prosecutor_open_case_or_person_not_found');end if;
  select * into counsel from game.defence_counsel_profiles where person_id=person_row.id;
  if counsel.id is null then
   insert into game.defence_counsel_profiles(person_id,created_by_prosecutor_id,created_at_game_time) values(person_row.id,pro.id,n) returning * into counsel;
  elsif counsel.status<>'active' then return jsonb_build_object('ok',false,'code','defence_counsel_not_active');end if;
  if exists(select 1 from game.defence_counsel_assignments where case_id=cas.id and status='active' and counsel_id<>counsel.id) then return jsonb_build_object('ok',false,'code','case_already_has_active_defence_counsel');end if;
  insert into game.defence_counsel_assignments(case_id,counsel_id,assigned_by_prosecutor_id,assigned_at_game_time)
  values(cas.id,counsel.id,pro.id,n) on conflict(case_id,counsel_id) do update set status='active',released_at_game_time=null;
  return jsonb_build_object('ok',true,'counsel_ref',counsel.counsel_ref,'case_ref',cas.case_ref,'person_ref',person_row.person_ref);
 elsif p_type='create_prosecution_disclosure' then
  select * into pro from game.prosecutor_profiles where prosecutor_ref=p->>'prosecutor_ref' and status='active';
  select * into ref from game.prosecution_referrals where referral_ref=p->>'referral_ref' and status='accepted';
  if pro.id is null or ref.id is null then return jsonb_build_object('ok',false,'code','active_prosecutor_and_accepted_referral_required');end if;
  if exists(select 1 from game.formal_charges where referral_id=ref.id and status='filed') is false then return jsonb_build_object('ok',false,'code','filed_charge_required');end if;
  insert into game.disclosure_packages(case_id,referral_id,package_type,title,created_by_prosecutor_id,created_at_game_time,source_command_id)
  values(ref.case_id,ref.id,'prosecution',p->>'title',pro.id,n,p_command_id) returning * into pkg;
  insert into game.disclosure_events(package_id,event_type,actor_kind,actor_profile_id,event_at_game_time,reason,source_command_id)
  values(pkg.id,'package_created','prosecutor',pro.id,n,'Prosecution disclosure package created',p_command_id);
  return jsonb_build_object('ok',true,'package_ref',pkg.package_ref,'status',pkg.status,'package_type',pkg.package_type);
 elsif p_type='create_defence_disclosure' then
  select * into cas from game.cases where case_ref=p->>'case_ref' and status='open';
  select * into counsel from game.defence_counsel_profiles where counsel_ref=p->>'counsel_ref' and status='active';
  if cas.id is null or counsel.id is null or not exists(select 1 from game.defence_counsel_assignments where case_id=cas.id and counsel_id=counsel.id and status='active') then return jsonb_build_object('ok',false,'code','active_assigned_defence_counsel_and_open_case_required');end if;
  insert into game.disclosure_packages(case_id,package_type,title,created_by_counsel_id,created_at_game_time,source_command_id)
  values(cas.id,'defence',p->>'title',counsel.id,n,p_command_id) returning * into pkg;
  insert into game.disclosure_events(package_id,event_type,actor_kind,actor_profile_id,event_at_game_time,reason,source_command_id)
  values(pkg.id,'package_created','defence_counsel',counsel.id,n,'Defence disclosure package created',p_command_id);
  return jsonb_build_object('ok',true,'package_ref',pkg.package_ref,'status',pkg.status,'package_type',pkg.package_type);
 elsif p_type in ('add_disclosure_item','set_disclosure_item_treatment') then
  if p_type='add_disclosure_item' then
   select * into pkg from game.disclosure_packages where package_ref=p->>'package_ref' and status='draft';
   if pkg.id is null then return jsonb_build_object('ok',false,'code','draft_package_not_found');end if;
   if pkg.package_type='prosecution' then
    select * into pro from game.prosecutor_profiles where prosecutor_ref=p->>'actor_ref' and status='active';
    if pro.id is null or pro.id<>pkg.created_by_prosecutor_id then return jsonb_build_object('ok',false,'code','package_prosecutor_required');end if;
    actor_kind:='prosecutor';actor_id:=pro.id;
   else
    select * into counsel from game.defence_counsel_profiles where counsel_ref=p->>'actor_ref' and status='active';
    if counsel.id is null or counsel.id<>pkg.created_by_counsel_id then return jsonb_build_object('ok',false,'code','package_defence_counsel_required');end if;
    actor_kind:='defence_counsel';actor_id:=counsel.id;
   end if;
   if p->>'category'='evidence' then
    select * into ev from game.evidence_items where evidence_ref=p->>'source_ref' and case_id=pkg.case_id;
    if ev.id is null then return jsonb_build_object('ok',false,'code','same_case_evidence_reference_not_found');end if;
   end if;
   insert into game.disclosure_items(package_id,category,source_ref,title,description,added_at_game_time,source_command_id)
   values(pkg.id,p->>'category',p->>'source_ref',p->>'title',p->>'description',n,p_command_id) returning * into item;
   insert into game.disclosure_events(package_id,item_id,event_type,actor_kind,actor_profile_id,event_at_game_time,reason,source_command_id)
   values(pkg.id,item.id,'item_added',actor_kind,actor_id,n,item.title,p_command_id);
   return jsonb_build_object('ok',true,'item_ref',item.item_ref,'package_ref',pkg.package_ref,'treatment',item.treatment);
  else
   select * into item from game.disclosure_items where item_ref=p->>'item_ref';
   select * into pkg from game.disclosure_packages where id=item.package_id and status='draft';
   if item.id is null or pkg.id is null then return jsonb_build_object('ok',false,'code','draft_disclosure_item_not_found');end if;
   if pkg.package_type='prosecution' then
    select * into pro from game.prosecutor_profiles where prosecutor_ref=p->>'actor_ref' and status='active';
    if pro.id is null or pro.id<>pkg.created_by_prosecutor_id then return jsonb_build_object('ok',false,'code','package_prosecutor_required');end if;
    actor_kind:='prosecutor';actor_id:=pro.id;
   else
    select * into counsel from game.defence_counsel_profiles where counsel_ref=p->>'actor_ref' and status='active';
    if counsel.id is null or counsel.id<>pkg.created_by_counsel_id then return jsonb_build_object('ok',false,'code','package_defence_counsel_required');end if;
    actor_kind:='defence_counsel';actor_id:=counsel.id;
   end if;
   update game.disclosure_items set treatment=p->>'treatment',treatment_reason=p->>'reason' where id=item.id returning * into item;
   insert into game.disclosure_events(package_id,item_id,event_type,actor_kind,actor_profile_id,event_at_game_time,reason,source_command_id)
   values(pkg.id,item.id,'item_treatment_changed',actor_kind,actor_id,n,item.treatment||': '||coalesce(item.treatment_reason,''),p_command_id);
   return jsonb_build_object('ok',true,'item_ref',item.item_ref,'treatment',item.treatment);
  end if;
 elsif p_type='serve_disclosure_package' then
  select * into pkg from game.disclosure_packages where package_ref=p->>'package_ref' and status='draft';
  select * into recipient from game.persons where person_ref=p->>'recipient_person_ref';
  if pkg.id is null or recipient.id is null then return jsonb_build_object('ok',false,'code','draft_package_or_recipient_not_found');end if;
  if not exists(select 1 from game.disclosure_items where package_id=pkg.id) then return jsonb_build_object('ok',false,'code','package_has_no_materials');end if;
  if pkg.package_type='prosecution' then
   select * into pro from game.prosecutor_profiles where prosecutor_ref=p->>'actor_ref' and status='active';
   select * into counsel from game.defence_counsel_profiles where person_id=recipient.id and status='active';
   if pro.id is null or pro.id<>pkg.created_by_prosecutor_id or counsel.id is null or not exists(select 1 from game.defence_counsel_assignments where case_id=pkg.case_id and counsel_id=counsel.id and status='active') then return jsonb_build_object('ok',false,'code','prosecutor_and_assigned_defence_recipient_required');end if;
   update game.disclosure_packages set recipient_counsel_id=counsel.id,status='served',served_at_game_time=n where id=pkg.id;
   insert into game.disclosure_receipts(package_id,recipient_kind,recipient_profile_id,recipient_person_id,served_at_game_time,source_command_id)
   values(pkg.id,'defence_counsel',counsel.id,recipient.id,n,p_command_id);
   actor_kind:='prosecutor';actor_id:=pro.id;
  else
   select * into counsel from game.defence_counsel_profiles where id=pkg.created_by_counsel_id and status='active';
   select * into pro from game.prosecutor_profiles pp where pp.person_id=recipient.id and pp.status='active' and exists(select 1 from game.prosecution_reviews pr join game.prosecution_referrals rr on rr.id=pr.referral_id where pr.prosecutor_id=pp.id and rr.case_id=pkg.case_id);
   if counsel.id is null or pro.id is null then return jsonb_build_object('ok',false,'code','defence_counsel_and_active_prosecutor_recipient_required');end if;
   update game.disclosure_packages set recipient_prosecutor_id=pro.id,status='served',served_at_game_time=n where id=pkg.id;
   insert into game.disclosure_receipts(package_id,recipient_kind,recipient_profile_id,recipient_person_id,served_at_game_time,source_command_id)
   values(pkg.id,'prosecutor',pro.id,recipient.id,n,p_command_id);
   actor_kind:='defence_counsel';actor_id:=counsel.id;
  end if;
  insert into game.disclosure_events(package_id,event_type,actor_kind,actor_profile_id,event_at_game_time,reason,source_command_id)
  values(pkg.id,'package_served',actor_kind,actor_id,n,'Package served to '||recipient.person_ref,p_command_id);
  return jsonb_build_object('ok',true,'package_ref',pkg.package_ref,'status','served','recipient_person_ref',recipient.person_ref);
 elsif p_type='acknowledge_disclosure_package' then
  select * into pkg from game.disclosure_packages where package_ref=p->>'package_ref' and status='served';
  if pkg.id is null then return jsonb_build_object('ok',false,'code','served_package_not_found');end if;
  select * into receipt from game.disclosure_receipts where package_id=pkg.id;
  if receipt.id is null then return jsonb_build_object('ok',false,'code','service_receipt_not_found');end if;
  if receipt.recipient_kind='defence_counsel' then
   select * into counsel from game.defence_counsel_profiles where counsel_ref=p->>'actor_ref' and id=receipt.recipient_profile_id and status='active';
   if counsel.id is null then return jsonb_build_object('ok',false,'code','intended_defence_recipient_required');end if;
   actor_kind:='defence_counsel';actor_id:=counsel.id;
  else
   select * into pro from game.prosecutor_profiles where prosecutor_ref=p->>'actor_ref' and id=receipt.recipient_profile_id and status='active';
   if pro.id is null then return jsonb_build_object('ok',false,'code','intended_prosecutor_recipient_required');end if;
   actor_kind:='prosecutor';actor_id:=pro.id;
  end if;
  update game.disclosure_receipts set acknowledged_at_game_time=n,acknowledgement_command_id=p_command_id where id=receipt.id;
  update game.disclosure_packages set status='acknowledged',acknowledged_at_game_time=n where id=pkg.id;
  insert into game.disclosure_events(package_id,event_type,actor_kind,actor_profile_id,event_at_game_time,reason,source_command_id)
  values(pkg.id,'package_acknowledged',actor_kind,actor_id,n,'Receipt acknowledged by intended recipient',p_command_id);
  return jsonb_build_object('ok',true,'package_ref',pkg.package_ref,'status','acknowledged');
 elsif p_type='get_disclosure_packages' then
  select * into cas from game.cases where case_ref=p->>'case_ref';
  if cas.id is null then return jsonb_build_object('ok',false,'code','case_not_found');end if;
  if not exists(select 1 from game.case_assignments ca join game.police_personnel pp on pp.id=ca.personnel_id where ca.case_id=cas.id and ca.status='active' and pp.personnel_ref=p->>'actor_ref')
   and not exists(select 1 from game.prosecutor_profiles where prosecutor_ref=p->>'actor_ref' and status='active')
   and not exists(select 1 from game.defence_counsel_profiles dc join game.defence_counsel_assignments da on da.counsel_id=dc.id where dc.counsel_ref=p->>'actor_ref' and da.case_id=cas.id and da.status='active') then return jsonb_build_object('ok',false,'code','case_access_required');end if;
  return jsonb_build_object('ok',true,'packages',coalesce((select jsonb_agg(jsonb_build_object('package_ref',dp.package_ref,'type',dp.package_type,'title',dp.title,'status',dp.status,'created_at',dp.created_at_game_time,'served_at',dp.served_at_game_time,'acknowledged_at',dp.acknowledged_at_game_time) order by dp.created_at_game_time) from game.disclosure_packages dp where dp.case_id=cas.id),'[]'::jsonb));
 elsif p_type='get_disclosure_package' then
  select * into pkg from game.disclosure_packages where package_ref=p->>'package_ref';
  if pkg.id is null then return jsonb_build_object('ok',false,'code','package_not_found');end if;
  if not exists(select 1 from game.case_assignments ca join game.police_personnel pp on pp.id=ca.personnel_id where ca.case_id=pkg.case_id and ca.status='active' and pp.personnel_ref=p->>'actor_ref')
   and not exists(select 1 from game.prosecutor_profiles where prosecutor_ref=p->>'actor_ref' and status='active')
   and not exists(select 1 from game.defence_counsel_profiles dc join game.defence_counsel_assignments da on da.counsel_id=dc.id where dc.counsel_ref=p->>'actor_ref' and da.case_id=pkg.case_id and da.status='active') then return jsonb_build_object('ok',false,'code','case_access_required');end if;
  return jsonb_build_object('ok',true,'package',jsonb_build_object('package_ref',pkg.package_ref,'type',pkg.package_type,'title',pkg.title,'status',pkg.status,'items',coalesce((select jsonb_agg(jsonb_build_object('item_ref',di.item_ref,'category',di.category,'source_ref',di.source_ref,'title',di.title,'description',di.description,'treatment',di.treatment,'reason',di.treatment_reason) order by di.item_ref) from game.disclosure_items di where di.package_id=pkg.id),'[]'::jsonb),'receipt',(select jsonb_build_object('recipient_kind',dr.recipient_kind,'recipient_person_ref',pe.person_ref,'served_at',dr.served_at_game_time,'acknowledged_at',dr.acknowledged_at_game_time) from game.disclosure_receipts dr join game.persons pe on pe.id=dr.recipient_person_id where dr.package_id=pkg.id)));
 end if;
 return jsonb_build_object('ok',false,'code','unsupported_disclosure_command');
end $function$
;
revoke all on function game.execute_justice_command(uuid,text,jsonb,uuid) from public,anon,authenticated;
grant execute on function game.execute_justice_command(uuid,text,jsonb,uuid) to service_role;
