CREATE OR REPLACE FUNCTION game.execute_justice_command(p_command_id uuid, p_type text, p jsonb, p_actor_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare n timestamptz; pro game.prosecutor_profiles%rowtype; off game.court_official_profiles%rowtype; case_row game.cases%rowtype;
 pe game.persons%rowtype; co game.courts%rowtype; cc game.court_cases%rowtype; h game.court_hearings%rowtype;
 cp game.court_cases%rowtype; ord game.court_orders%rowtype; target_time timestamptz; res jsonb; courtcaseid uuid; packageid uuid;
begin
 if p_type='help' then
  res:=game.execute_justice_command_before_court(p_command_id,p_type,p,p_actor_id);
  return jsonb_set(res,'{available_commands}',(select coalesce(jsonb_agg(distinct x),'[]'::jsonb) from jsonb_array_elements_text(coalesce(res->'available_commands','[]'::jsonb)||jsonb_build_array('create_court','appoint_court_official','register_court_case','assign_court_judge','schedule_court_hearing','record_court_attendance','adjourn_court_hearing','conclude_court_hearing','issue_court_order','get_court_docket','get_court_hearing')) x),true);
 end if;
 if p_type not in ('create_court','appoint_court_official','register_court_case','assign_court_judge','schedule_court_hearing','record_court_attendance','adjourn_court_hearing','conclude_court_hearing','issue_court_order','get_court_docket','get_court_hearing') then
  return game.execute_justice_command_before_court(p_command_id,p_type,p,p_actor_id);
 end if;
 select current_game_time into n from game.simulation_state where id=1 for update;
 if n is null then return jsonb_build_object('ok',false,'code','clock_not_initialized');end if;
 if p_type in ('create_court','appoint_court_official','register_court_case','assign_court_judge') then
  select * into pro from game.prosecutor_profiles where prosecutor_ref=coalesce(p->>'prosecutor_ref',p->>'actor_ref') and status='active';
  if pro.id is null then return jsonb_build_object('ok',false,'code','active_prosecutor_required');end if;
 elsif p_type in ('schedule_court_hearing','record_court_attendance','adjourn_court_hearing','conclude_court_hearing','issue_court_order') then
  select * into off from game.court_official_profiles where official_ref=coalesce(p->>'judge_ref',p->>'official_ref') and status='active';
  if off.id is null then return jsonb_build_object('ok',false,'code','active_court_official_required');end if;
 end if;

 if p_type='create_court' then
  if nullif(btrim(p->>'court_name'),'') is null then return jsonb_build_object('ok',false,'code','court_name_required');end if;
  insert into game.courts(court_name,court_level,created_by_prosecutor_id,created_at_game_time) values(btrim(p->>'court_name'),p->>'court_level',pro.id,n) returning * into co;
  insert into game.court_hearing_events(court_id,event_type,actor_kind,actor_profile_id,event_at_game_time,details,source_command_id) values(co.id,'court_created','prosecutor',pro.id,n,jsonb_build_object('court_ref',co.court_ref,'court_name',co.court_name,'court_level',co.court_level),p_command_id);
  return jsonb_build_object('ok',true,'court_ref',co.court_ref,'court_name',co.court_name,'court_level',co.court_level);
 elsif p_type='appoint_court_official' then
  select * into pe from game.persons where person_ref=p->>'person_ref';
  if pe.id is null then return jsonb_build_object('ok',false,'code','person_not_found');end if;
  if exists(select 1 from game.court_official_profiles where person_id=pe.id) then return jsonb_build_object('ok',false,'code','court_official_profile_already_exists');end if;
  insert into game.court_official_profiles(person_id,official_role,appointed_by_prosecutor_id,appointed_at_game_time) values(pe.id,p->>'official_role',pro.id,n) returning * into off;
  insert into game.court_hearing_events(subject_official_id,event_type,actor_kind,actor_profile_id,event_at_game_time,details,source_command_id) values(off.id,'official_appointed','prosecutor',pro.id,n,jsonb_build_object('official_ref',off.official_ref,'person_ref',pe.person_ref,'role',off.official_role),p_command_id);
  return jsonb_build_object('ok',true,'official_ref',off.official_ref,'person_ref',pe.person_ref,'official_role',off.official_role);
 elsif p_type='register_court_case' then
  select * into case_row from game.cases where case_ref=p->>'case_ref' and status not in ('closed');
  select * into co from game.courts where court_ref=p->>'court_ref' and status='active';
  if case_row.id is null or co.id is null then return jsonb_build_object('ok',false,'code','open_case_and_active_court_required');end if;
  if not exists(select 1 from game.formal_charges where case_id=case_row.id and status='filed') then return jsonb_build_object('ok',false,'code','filed_formal_charge_required');end if;
  if exists(select 1 from game.court_cases where case_id=case_row.id and status in ('registered','active')) then return jsonb_build_object('ok',false,'code','case_already_registered_with_court');end if;
  insert into game.court_cases(case_id,court_id,registered_by_prosecutor_id,registered_at_game_time) values(case_row.id,co.id,pro.id,n) returning * into cc;
  insert into game.court_hearing_events(court_case_id,event_type,actor_kind,actor_profile_id,event_at_game_time,details,source_command_id) values(cc.id,'case_registered','prosecutor',pro.id,n,jsonb_build_object('case_ref',case_row.case_ref,'court_ref',co.court_ref),p_command_id);
  return jsonb_build_object('ok',true,'court_case_ref',cc.court_case_ref,'case_ref',case_row.case_ref,'court_ref',co.court_ref,'status',cc.status);
 elsif p_type='assign_court_judge' then
  select * into cc from game.court_cases where court_case_ref=p->>'court_case_ref' and status in ('registered','active');
  select * into off from game.court_official_profiles where official_ref=p->>'judge_ref' and status='active' and official_role in ('judge','senior_judge','chief_judge');
  if cc.id is null or off.id is null then return jsonb_build_object('ok',false,'code','active_court_case_and_judge_required');end if;
  update game.court_cases set assigned_judge_id=off.id,status='active' where id=cc.id;
  insert into game.court_hearing_events(court_case_id,event_type,actor_kind,actor_profile_id,event_at_game_time,details,source_command_id) values(cc.id,'judge_assigned','prosecutor',pro.id,n,jsonb_build_object('judge_ref',off.official_ref),p_command_id);
  return jsonb_build_object('ok',true,'court_case_ref',cc.court_case_ref,'judge_ref',off.official_ref);
 elsif p_type='schedule_court_hearing' then
  select * into cc from game.court_cases where court_case_ref=p->>'court_case_ref' and status='active' and assigned_judge_id=off.id;
  if cc.id is null then return jsonb_build_object('ok',false,'code','assigned_active_judge_required');end if;
  begin target_time:=(p->>'scheduled_at')::timestamptz; exception when others then return jsonb_build_object('ok',false,'code','invalid_scheduled_timestamp');end;
  if target_time<n then return jsonb_build_object('ok',false,'code','hearing_cannot_be_scheduled_in_past');end if;
  insert into game.court_hearings(court_case_id,hearing_type,scheduled_at_game_time,scheduled_by_official_id) values(cc.id,p->>'hearing_type',target_time,off.id) returning * into h;
  insert into game.court_hearing_events(court_case_id,hearing_id,event_type,actor_kind,actor_profile_id,event_at_game_time,details,source_command_id) values(cc.id,h.id,'hearing_scheduled','court_official',off.id,n,jsonb_build_object('hearing_ref',h.hearing_ref,'scheduled_at',target_time,'hearing_type',h.hearing_type),p_command_id);
  return jsonb_build_object('ok',true,'hearing_ref',h.hearing_ref,'scheduled_at',h.scheduled_at_game_time,'status',h.status);
 elsif p_type='record_court_attendance' then
  select * into h from game.court_hearings where hearing_ref=p->>'hearing_ref' and status='scheduled';
  select * into pe from game.persons where person_ref=p->>'person_ref';
  if h.id is null or pe.id is null then return jsonb_build_object('ok',false,'code','scheduled_hearing_and_person_required');end if;
  if not exists(select 1 from game.court_cases where id=h.court_case_id and assigned_judge_id=off.id) and off.official_role not in ('clerk','registrar') then return jsonb_build_object('ok',false,'code','assigned_judge_or_court_clerk_required');end if;
  insert into game.court_hearing_attendance(hearing_id,person_id,attendance_role,attendance_status,recorded_by_official_id,recorded_at_game_time,notes)
  values(h.id,pe.id,p->>'attendance_role',p->>'attendance_status',off.id,n,'Attendance recorded by court NPC')
  on conflict(hearing_id,person_id,attendance_role) do update set attendance_status=excluded.attendance_status,recorded_by_official_id=excluded.recorded_by_official_id,recorded_at_game_time=excluded.recorded_at_game_time;
  insert into game.court_hearing_events(court_case_id,hearing_id,event_type,actor_kind,actor_profile_id,event_at_game_time,details,source_command_id)
  values(h.court_case_id,h.id,'attendance_recorded','court_official',off.id,n,jsonb_build_object('person_ref',pe.person_ref,'role',p->>'attendance_role','status',p->>'attendance_status'),p_command_id);
  return jsonb_build_object('ok',true,'hearing_ref',h.hearing_ref,'person_ref',pe.person_ref,'attendance_status',p->>'attendance_status');
 elsif p_type='adjourn_court_hearing' then
  select * into h from game.court_hearings where hearing_ref=p->>'hearing_ref' and status='scheduled';
  if h.id is null or not exists(select 1 from game.court_cases where id=h.court_case_id and assigned_judge_id=off.id) or nullif(btrim(p->>'reason'),'') is null then return jsonb_build_object('ok',false,'code','scheduled_hearing_assigned_judge_and_reason_required');end if;
  update game.court_hearings set status='adjourned',notes=concat_ws(E'\n',notes,'Adjourned: '||(p->>'reason')) where id=h.id;
  insert into game.court_hearing_events(court_case_id,hearing_id,event_type,actor_kind,actor_profile_id,event_at_game_time,details,source_command_id) values(h.court_case_id,h.id,'hearing_adjourned','court_official',off.id,n,jsonb_build_object('reason',p->>'reason'),p_command_id);
  return jsonb_build_object('ok',true,'hearing_ref',h.hearing_ref,'status','adjourned');
 elsif p_type='conclude_court_hearing' then
  select * into h from game.court_hearings where hearing_ref=p->>'hearing_ref' and status='scheduled';
  if h.id is null or not exists(select 1 from game.court_cases where id=h.court_case_id and assigned_judge_id=off.id) then return jsonb_build_object('ok',false,'code','scheduled_hearing_assigned_judge_required');end if;
  if n<h.scheduled_at_game_time then return jsonb_build_object('ok',false,'code','hearing_not_yet_due_in_fictional_time');end if;
  if nullif(btrim(p->>'outcome'),'') is null then return jsonb_build_object('ok',false,'code','hearing_outcome_required');end if;
  update game.court_hearings set status='concluded',concluded_at_game_time=n,outcome=p->>'outcome',notes=p->>'notes' where id=h.id returning * into h;
  insert into game.court_hearing_events(court_case_id,hearing_id,event_type,actor_kind,actor_profile_id,event_at_game_time,details,source_command_id) values(h.court_case_id,h.id,'hearing_concluded','court_official',off.id,n,jsonb_build_object('outcome',h.outcome,'notes',h.notes),p_command_id);
  return jsonb_build_object('ok',true,'hearing_ref',h.hearing_ref,'status',h.status,'outcome',h.outcome);
 elsif p_type='issue_court_order' then
  select * into h from game.court_hearings where hearing_ref=p->>'hearing_ref' and status='scheduled';
  if h.id is null or not exists(select 1 from game.court_cases where id=h.court_case_id and assigned_judge_id=off.id) then return jsonb_build_object('ok',false,'code','scheduled_hearing_assigned_judge_required');end if;
  if n<h.scheduled_at_game_time then return jsonb_build_object('ok',false,'code','hearing_not_yet_due_in_fictional_time');end if;
  insert into game.court_orders(hearing_id,order_type,order_text,issued_by_official_id,issued_at_game_time,source_command_id) values(h.id,p->>'order_type',p->>'order_text',off.id,n,p_command_id) returning * into ord;
  insert into game.court_hearing_events(court_case_id,hearing_id,event_type,actor_kind,actor_profile_id,event_at_game_time,details,source_command_id) values(h.court_case_id,h.id,'order_issued','court_official',off.id,n,jsonb_build_object('order_ref',ord.order_ref,'order_type',ord.order_type),p_command_id);
  return jsonb_build_object('ok',true,'order_ref',ord.order_ref);
 elsif p_type='get_court_docket' then
  select * into case_row from game.cases where case_ref=p->>'case_ref';
  if case_row.id is null then return jsonb_build_object('ok',false,'code','case_not_found');end if;
  if not exists(select 1 from game.case_assignments ca join game.police_personnel pp on pp.id=ca.personnel_id where ca.case_id=case_row.id and ca.status='active' and pp.personnel_ref=p->>'actor_ref')
   and not exists(select 1 from game.prosecutor_profiles pr join game.prosecution_reviews rv on rv.prosecutor_id=pr.id join game.prosecution_referrals rr on rr.id=rv.referral_id where pr.prosecutor_ref=p->>'actor_ref' and pr.status='active' and rr.case_id=cp.id)
   and not exists(select 1 from game.defence_counsel_profiles dc join game.defence_counsel_assignments da on da.counsel_id=dc.id where dc.counsel_ref=p->>'actor_ref' and da.case_id=cp.id and da.status='active')
   and not exists(select 1 from game.court_official_profiles o join game.court_cases ccx on ccx.assigned_judge_id=o.id where o.official_ref=p->>'actor_ref' and ccx.case_id=cp.id)
   then return jsonb_build_object('ok',false,'code','case_access_required');end if;
  return jsonb_build_object('ok',true,'case_ref',case_row.case_ref,'court_cases',coalesce((select jsonb_agg(jsonb_build_object('court_case_ref',ccx.court_case_ref,'court_ref',c.court_ref,'court_name',c.court_name,'status',ccx.status,'judge_ref',j.official_ref,'hearings',(select coalesce(jsonb_agg(jsonb_build_object('hearing_ref',hh.hearing_ref,'type',hh.hearing_type,'scheduled_at',hh.scheduled_at_game_time,'status',hh.status,'outcome',hh.outcome) order by hh.scheduled_at_game_time),'[]'::jsonb) from game.court_hearings hh where hh.court_case_id=ccx.id)) order by ccx.registered_at_game_time) from game.court_cases ccx join game.courts c on c.id=ccx.court_id left join game.court_official_profiles j on j.id=ccx.assigned_judge_id where ccx.case_id=case_row.id),'[]'::jsonb));
 elsif p_type='get_court_hearing' then
  select * into h from game.court_hearings where hearing_ref=p->>'hearing_ref';
  if h.id is null then return jsonb_build_object('ok',false,'code','hearing_not_found');end if;
  if not exists(select 1 from game.case_assignments ca join game.police_personnel pp on pp.id=ca.personnel_id join game.court_cases ccx on ccx.case_id=ca.case_id where ccx.id=h.court_case_id and ca.status='active' and pp.personnel_ref=p->>'actor_ref')
   and not exists(select 1 from game.court_cases ccx join game.court_official_profiles o on o.id=ccx.assigned_judge_id where ccx.id=h.court_case_id and o.official_ref=p->>'actor_ref')
   and not exists(select 1 from game.court_cases ccx join game.prosecution_referrals rr on rr.case_id=ccx.case_id join game.prosecution_reviews rv on rv.referral_id=rr.id join game.prosecutor_profiles pr on pr.id=rv.prosecutor_id where ccx.id=h.court_case_id and pr.prosecutor_ref=p->>'actor_ref' and pr.status='active')
   and not exists(select 1 from game.court_cases ccx join game.defence_counsel_assignments da on da.case_id=ccx.case_id join game.defence_counsel_profiles dc on dc.id=da.counsel_id where ccx.id=h.court_case_id and dc.counsel_ref=p->>'actor_ref' and da.status='active')
   then return jsonb_build_object('ok',false,'code','hearing_access_required');end if;
  return jsonb_build_object('ok',true,'hearing',jsonb_build_object('hearing_ref',h.hearing_ref,'type',h.hearing_type,'scheduled_at',h.scheduled_at_game_time,'status',h.status,'outcome',h.outcome,'notes',h.notes,'attendance',(select coalesce(jsonb_agg(jsonb_build_object('person_ref',attendance_person.person_ref,'role',a.attendance_role,'status',a.attendance_status) order by a.attendance_role),'[]'::jsonb) from game.court_hearing_attendance a join game.persons attendance_person on attendance_person.id=a.person_id where a.hearing_id=h.id),'orders',(select coalesce(jsonb_agg(jsonb_build_object('order_ref',o.order_ref,'type',o.order_type,'details',o.order_text) order by o.issued_at_game_time),'[]'::jsonb) from game.court_orders o where o.hearing_id=h.id)));
 end if;
 return jsonb_build_object('ok',false,'code','unsupported_court_command');
end $function$
;
revoke all on function game.execute_justice_command(uuid,text,jsonb,uuid) from public,anon,authenticated;
grant execute on function game.execute_justice_command(uuid,text,jsonb,uuid) to service_role;
