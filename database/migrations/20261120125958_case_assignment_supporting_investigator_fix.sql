create or replace function game.assign_case_investigator(
 p_case_ref text,p_personnel_ref text,p_assignment_role text,p_actor_personnel_ref text,p_source_command_id uuid default null
) returns jsonb language plpgsql set search_path to 'pg_catalog','game'
as $$
declare v_case game.cases%rowtype; v_person game.police_personnel%rowtype; v_actor game.police_personnel%rowtype;
 v_clock timestamptz; v_old game.case_assignments%rowtype; v_new game.case_assignments%rowtype;
begin
 if nullif(btrim(p_case_ref),'') is null or nullif(btrim(p_personnel_ref),'') is null
   or lower(coalesce(p_assignment_role,'')) not in ('lead_investigator','investigator','supervisor','specialist') then
  return jsonb_build_object('ok',false,'code','invalid_assignment','message','Provide a case, personnel reference and role: lead_investigator, investigator, supervisor or specialist.');
 end if;
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional game clock before assigning investigators.'); end if;
 select * into v_case from game.cases where case_ref=btrim(p_case_ref) for update;
 if not found then return jsonb_build_object('ok',false,'code','case_not_found','message','Case reference was not found.'); end if;
 if v_case.status='closed' then return jsonb_build_object('ok',false,'code','case_closed','message','Investigators cannot be assigned to a closed case.'); end if;
 select * into v_person from game.police_personnel where personnel_ref=btrim(p_personnel_ref);
 if not found or v_person.employment_status not in ('active','seconded') then return jsonb_build_object('ok',false,'code','invalid_personnel','message','The investigator must be active or seconded police personnel.'); end if;
 select * into v_actor from game.police_personnel where personnel_ref=btrim(p_actor_personnel_ref);
 if not found or v_actor.employment_status not in ('active','seconded') then return jsonb_build_object('ok',false,'code','invalid_actor','message','The recording officer must be active or seconded police personnel.'); end if;
 if exists(select 1 from game.case_assignments where case_id=v_case.id and personnel_id=v_person.id and assignment_role=lower(p_assignment_role) and status='active') then
  return jsonb_build_object('ok',true,'already_assigned',true,'case_ref',v_case.case_ref,'personnel_ref',v_person.personnel_ref,'assignment_role',lower(p_assignment_role));
 end if;
 if lower(p_assignment_role)='lead_investigator' then
  select * into v_old from game.case_assignments where case_id=v_case.id and status='active' and assignment_role='lead_investigator' for update;
  if v_old.id is not null then
   update game.case_assignments set status='released',released_at=v_clock where id=v_old.id;
   insert into game.case_assignment_events(assignment_id,case_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id)
   values(v_old.id,v_case.id,'lead_transferred',v_actor.id,v_clock,
    jsonb_build_object('previous_personnel_ref',(select personnel_ref from game.police_personnel where id=v_old.personnel_id),
     'replacement_personnel_ref',v_person.personnel_ref,'assignment_role',v_old.assignment_role),p_source_command_id);
  end if;
 end if;
 insert into game.case_assignments(case_id,personnel_id,assignment_role,assigned_at,status)
 values(v_case.id,v_person.id,lower(p_assignment_role),v_clock,'active') returning * into v_new;
 insert into game.case_assignment_events(assignment_id,case_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id)
 values(v_new.id,v_case.id,'assigned',v_actor.id,v_clock,
  jsonb_build_object('personnel_ref',v_person.personnel_ref,'assignment_role',v_new.assignment_role),p_source_command_id);
 if v_new.assignment_role='lead_investigator' then update game.cases set lead_personnel_id=v_person.id,updated_at=now() where id=v_case.id; end if;
 return jsonb_build_object('ok',true,'case_ref',v_case.case_ref,'personnel_ref',v_person.personnel_ref,
  'assignment_role',v_new.assignment_role,'assignment_id',v_new.id,'assigned_at_game_time',v_clock);
end $$;
