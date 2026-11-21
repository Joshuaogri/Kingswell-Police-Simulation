CREATE OR REPLACE FUNCTION game.execute_arrest_custody_command(p_command_id uuid, p_type text, p jsonb, p_actor_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog', 'game'
AS $function$
declare n timestamptz; v_arrest game.arrests%rowtype; ce game.custody_episodes%rowtype; v_person_id uuid;v_case_id uuid;inc_id uuid;target_id uuid;result jsonb;ev uuid;prop_id uuid;actor_ref text;
begin
 select current_game_time into n from game.simulation_state where id=1;
 if n is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before arrest or custody operations.');end if;
 actor_ref:= (select personnel_ref from game.police_personnel where id=p_actor_id);
 if p_type='execute_arrest' then
  select c.id into v_case_id from game.cases c where c.case_ref=p->>'case_ref' and c.status='open';
  select pe.id into v_person_id from game.persons pe where pe.person_ref=p->>'person_ref';
  if v_case_id is null or v_person_id is null then return jsonb_build_object('ok',false,'code','case_or_person_not_found');end if;
  if not exists(select 1 from game.case_persons cp where cp.case_id=v_case_id and cp.person_id=v_person_id and cp.case_role in ('suspect','person_of_interest')) then return jsonb_build_object('ok',false,'code','person_not_linked_as_suspect','message','Person must already be linked to the case as a suspect or person of interest.');end if;
  if not exists(select 1 from game.case_assignments ca where cv_arrest.case_id=v_case_id and ca.personnel_id=p_actor_id and cv_arrest.status='active' and ca.released_at is null) and not exists(select 1 from game.cases c where c.id=v_case_id and c.lead_personnel_id=p_actor_id) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  if nullif(btrim(p->>'grounds'),'') is null or nullif(btrim(p->>'location'),'') is null or nullif(btrim(p->>'warnings'),'') is null then return jsonb_build_object('ok',false,'code','arrest_record_incomplete');end if;
  if p->>'basis' not in ('warrant','grounds','other') or (p->>'basis'='warrant' and nullif(btrim(p->>'authority_reference'),'') is null) then return jsonb_build_object('ok',false,'code','arrest_basis_invalid');end if;
  if exists(select 1 from game.arrests where game.arrests.case_id=v_case_id and game.arrests.person_id=v_person_id and status in ('arrested','transporting','booked')) then return jsonb_build_object('ok',false,'code','active_arrest_exists');end if;
  insert into game.arrests(case_id,person_id,incident_id,arresting_personnel_id,arrest_basis,authority_reference,grounds_description,arrest_location,arrested_at_game_time,force_used,injury_or_complaint,warnings_or_rights_record,witness_details,body_camera_reference,source_command_id)
  values(v_case_id,v_person_id,(select id from game.incidents where incident_ref=p->>'incident_ref'),p_actor_id,p->>'basis',nullif(p->>'authority_reference',''),p->>'grounds',p->>'location',n,coalesce(nullif(p->>'force',''),'none'),coalesce(nullif(p->>'injuries',''),'none_recorded'),p->>'warnings',nullif(p->>'witnesses',''),nullif(p->>'body_camera',''),p_command_id) returning * into v_arrest;
  insert into game.arrest_events(arrest_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(v_arrest.id,'arrest_executed',p_actor_id,n,to_jsonb(a)-'id'-'source_command_id',p_command_id);
  return jsonb_build_object('ok',true,'arrest_ref',v_arrest.arrest_ref,'status',v_arrest.status);
 elsif p_type='transport_arrest' then
  select * into v_arrest from game.arrests where arrest_ref=p->>'arrest_ref' for update;
  if v_arrest.id is null or v_arrest.status<>'arrested' then return jsonb_build_object('ok',false,'code','arrest_not_transportable');end if;
  if v_arrest.arresting_personnel_id<>p_actor_id and not exists(select 1 from game.case_assignments ca where cv_arrest.case_id=v_arrest.case_id and ca.personnel_id=p_actor_id and cv_arrest.status='active' and ca.released_at is null) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  if nullif(btrim(p->>'destination'),'') is null or nullif(btrim(p->>'vehicle'),'') is null or nullif(btrim(p->>'handover'),'') is null then return jsonb_build_object('ok',false,'code','transport_details_incomplete');end if;
  insert into game.arrest_transport_legs(arrest_id,transporting_personnel_id,departure_location,destination_location,vehicle_description,departed_at_game_time,arrived_at_game_time,handover_notes,source_command_id) values(v_arrest.id,p_actor_id,v_arrest.arrest_location,p->>'destination',p->>'vehicle',n,n,p->>'handover',p_command_id);
  update game.arrests set status='transporting' where id=v_arrest.id;
  insert into game.arrest_events(arrest_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(v_arrest.id,'transport_arrived',p_actor_id,n,jsonb_build_object('destination',p->>'destination','vehicle',p->>'vehicle','handover',p->>'handover'),p_command_id);
  return jsonb_build_object('ok',true,'arrest_ref',v_arrest.arrest_ref,'status','transporting');
 elsif p_type='book_custody' then
  select * into v_arrest from game.arrests where arrest_ref=p->>'arrest_ref' for update;
  if v_arrest.id is null or v_arrest.status<>'transporting' then return jsonb_build_object('ok',false,'code','transport_arrival_required');end if;
  if nullif(btrim(p->>'identity_check'),'') is null or nullif(btrim(p->>'risk'),'') is null or nullif(btrim(p->>'health'),'') is null or nullif(btrim(p->>'cell'),'') is null then return jsonb_build_object('ok',false,'code','booking_details_incomplete');end if;
  insert into game.custody_episodes(arrest_id,case_id,person_id,booking_officer_id,booked_at_game_time,identity_check,risk_assessment,health_welfare_screen,medication_disclosure,safeguarding_notes,cell_location,source_command_id)
  values(v_arrest.id,v_arrest.case_id,v_arrest.person_id,p_actor_id,n,p->>'identity_check',p->>'risk',p->>'health',nullif(p->>'medication',''),nullif(p->>'safeguarding',''),p->>'cell',p_command_id) returning * into ce;
  update game.arrests set status='booked' where id=v_arrest.id;
  insert into game.arrest_events(arrest_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(v_arrest.id,'custody_booking',p_actor_id,n,jsonb_build_object('custody_ref',ce.custody_ref,'cell',ce.cell_location),p_command_id);
  return jsonb_build_object('ok',true,'custody_ref',ce.custody_ref,'arrest_ref',v_arrest.arrest_ref,'status',ce.status);
 elsif p_type='record_custody_property' then
  select * into ce from game.custody_episodes where custody_ref=p->>'custody_ref' for update;
  if ce.id is null or ce.status<>'in_custody' then return jsonb_build_object('ok',false,'code','custody_not_active');end if;
  if nullif(btrim(p->>'item'),'') is null or nullif(btrim(p->>'condition'),'') is null or p->>'disposition' not in ('stored','retained_as_evidence','returned','transferred') then return jsonb_build_object('ok',false,'code','property_details_invalid');end if;
  if p->>'disposition'='retained_as_evidence' then
   insert into game.evidence_items(evidence_ref,case_id,collected_by_personnel_id,evidence_type,description,collected_at,collection_location,current_status,storage_location,metadata)
   values('KWE-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12)),ce.case_id,p_actor_id,'custody_property',p->>'item',n,'Custody booking','held',coalesce(nullif(p->>'storage',''),'Evidence Store'),jsonb_build_object('source','custody_property','custody_ref',ce.custody_ref,'condition',p->>'condition')) returning id into ev;
  end if;
  insert into game.custody_property(custody_episode_id,recorded_by_personnel_id,item_description,condition_description,disposition,storage_location,evidence_id,recorded_at_game_time,source_command_id)
  values(ce.id,p_actor_id,p->>'item',p->>'condition',p->>'disposition',nullif(p->>'storage',''),ev,n,p_command_id) returning id into prop_id;
  return jsonb_build_object('ok',true,'property_ref',(select property_ref from game.custody_property where id=prop_id),'evidence_id',ev);
 elsif p_type='custody_check' then
  select * into ce from game.custody_episodes where custody_ref=p->>'custody_ref';
  if ce.id is null or ce.status<>'in_custody' then return jsonb_build_object('ok',false,'code','custody_not_active');end if;
  if p->>'check_type' not in ('welfare','health','risk','observation') or nullif(btrim(p->>'observation'),'') is null then return jsonb_build_object('ok',false,'code','check_details_invalid');end if;
  insert into game.custody_welfare_checks(custody_episode_id,check_type,officer_personnel_id,checked_at_game_time,observation,escalation,source_command_id) values(ce.id,p->>'check_type',p_actor_id,n,p->>'observation',nullif(p->>'escalation',''),p_command_id);
  return jsonb_build_object('ok',true,'custody_ref',ce.custody_ref,'check_type',p->>'check_type');
 elsif p_type='custody_event' then
  select * into ce from game.custody_episodes where custody_ref=p->>'custody_ref';
  if ce.id is null or ce.status<>'in_custody' then return jsonb_build_object('ok',false,'code','custody_not_active');end if;
  if nullif(btrim(p->>'details'),'') is null then return jsonb_build_object('ok',false,'code','event_details_required');end if;
  insert into game.custody_events(custody_episode_id,event_type,actor_personnel_id,event_at_game_time,details,source_command_id) values(ce.id,p->>'event_type',p_actor_id,n,p->>'details',p_command_id);
  return jsonb_build_object('ok',true,'custody_ref',ce.custody_ref,'event_type',p->>'event_type');
 elsif p_type in ('release_custody','transfer_custody') then
  select * into ce from game.custody_episodes where custody_ref=p->>'custody_ref' for update;
  if ce.id is null or ce.status<>'in_custody' then return jsonb_build_object('ok',false,'code','custody_not_active');end if;
  if nullif(btrim(p->>'reason'),'') is null then return jsonb_build_object('ok',false,'code','final_reason_required');end if;
  if p_type='transfer_custody' and nullif(btrim(p->>'destination'),'') is null then return jsonb_build_object('ok',false,'code','transfer_destination_required');end if;
  update game.custody_episodes set status=case when p_type='release_custody' then 'released' else 'transferred' end,release_or_transfer_at_game_time=n,final_outcome=case when p_type='release_custody' then coalesce(p->>'outcome','released') else 'transferred' end,final_reason=p->>'reason' where id=ce.id;
  update game.arrests set status=case when p_type='release_custody' then 'released' else 'transferred' end where id=ce.arrest_id;
  insert into game.custody_events(custody_episode_id,event_type,actor_personnel_id,event_at_game_time,details,source_command_id) values(ce.id,case when p_type='release_custody' then 'handover' else 'handover' end,p_actor_id,n,case when p_type='release_custody' then 'Released: '||p->>'outcome'||'. '||p->>'reason' else 'Transferred to '||p->>'destination'||'. '||p->>'reason' end,p_command_id);
  insert into game.arrest_events(arrest_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(ce.arrest_id,case when p_type='release_custody' then 'released' else 'transferred' end,p_actor_id,n,jsonb_build_object('outcome',p->>'outcome','destination',p->>'destination','reason',p->>'reason'),p_command_id);
  return jsonb_build_object('ok',true,'custody_ref',ce.custody_ref,'status',case when p_type='release_custody' then 'released' else 'transferred' end);
 elsif p_type='get_case_arrests' then
  if not exists(select 1 from game.cases c where c.case_ref=p->>'case_ref' and (c.lead_personnel_id=p_actor_id or exists(select 1 from game.case_assignments ca where cv_arrest.case_id=c.id and ca.personnel_id=p_actor_id and cv_arrest.status='active' and ca.released_at is null))) then return jsonb_build_object('ok',false,'code','case_access_denied');end if;
  return jsonb_build_object('ok',true,'arrests',(select coalesce(jsonb_agg(jsonb_build_object('arrest_ref',v_arrest.arrest_ref,'person_ref',pe.person_ref,'status',v_arrest.status,'basis',a.arrest_basis,'grounds',a.grounds_description,'location',v_arrest.arrest_location,'arrested_at',a.arrested_at_game_time,'transport',(select jsonb_agg(to_jsonb(t)-'id' order by t.departed_at_game_time) from game.arrest_transport_legs t where t.arrest_id=ar.id),'custody',(select to_jsonb(cu)-'id' from game.custody_episodes cu where cu.arrest_id=ar.id),'events',(select jsonb_agg(to_jsonb(ae)-'id' order by ae.event_at_game_time) from game.arrest_events ae where ae.arrest_id=ar.id)) order by a.arrested_at_game_time),'[]'::jsonb) from game.arrests a join game.persons pe on pe.id=v_arrest.person_id where v_arrest.case_id=(select id from game.cases where case_ref=p->>'case_ref')));
 end if;
 return jsonb_build_object('ok',false,'code','unsupported_command');
end $function$
