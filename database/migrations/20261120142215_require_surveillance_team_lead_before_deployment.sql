create unique index surveillance_operation_single_team_lead_idx on game.surveillance_operation_team(operation_id) where team_role='team_lead';

create or replace function game.start_surveillance_operation(p_operation_ref text,p_actor_ref text,p_command_id uuid)
returns jsonb language plpgsql set search_path=pg_catalog,game as $$
declare o game.surveillance_operations%rowtype;a game.police_personnel%rowtype;tm timestamptz;
begin
 select * into o from game.surveillance_operations where operation_ref=btrim(p_operation_ref) for update;
 if not found or o.status<>'planned' then return jsonb_build_object('ok',false,'code','operation_not_planned','message','Only a planned operation can be deployed.');end if;
 select * into a from game.police_personnel where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if not found or not exists(select 1 from game.surveillance_operation_team t where t.operation_id=o.id and t.personnel_id=a.id) then return jsonb_build_object('ok',false,'code','not_on_team','message','The deploying officer must be assigned to this surveillance team.');end if;
 if not exists(select 1 from game.surveillance_operation_team where operation_id=o.id and team_role='team_lead') then return jsonb_build_object('ok',false,'code','team_lead_required','message','Assign one team lead before deployment.');end if;
 select current_game_time into tm from game.simulation_state where id=1 for update;
 if tm is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock first.');end if;
 update game.surveillance_operations set status='deployed',deployed_at_game_time=tm where id=o.id;
 insert into game.surveillance_operation_events(operation_id,event_type,actor_personnel_id,event_at_game_time,source_command_id) values(o.id,'deployment_started',a.id,tm,p_command_id);
 return jsonb_build_object('ok',true,'operation_ref',o.operation_ref,'status','deployed','deployed_at_game_time',tm,'message','Surveillance deployment started.');
end $$;
revoke all on function game.start_surveillance_operation(text,text,uuid) from public,anon,authenticated;
grant execute on function game.start_surveillance_operation(text,text,uuid) to service_role;
