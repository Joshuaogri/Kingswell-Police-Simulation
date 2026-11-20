begin;
do $$
declare v_before_routes bigint; v_after_routes bigint; v_before_history bigint; v_after_history bigint; v_clock timestamptz;
begin
 select count(*) into v_before_routes from game.road_route_calculations;
 select count(*) into v_before_history from game.deployment_route_history;
 select current_game_time into v_clock from game.simulation_state where id=1;
 if not exists(select 1 from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='game' and c.relname='deployment_route_history' and c.relrowsecurity) then raise exception 'Route history RLS missing'; end if;
 if not has_function_privilege('service_role','game.get_dispatch_candidates(text)','EXECUTE') or has_function_privilege('anon','game.get_dispatch_candidates(text)','EXECUTE') or has_function_privilege('authenticated','game.get_dispatch_candidates(text)','EXECUTE') then raise exception 'Candidate function ACL incorrect'; end if;
 if not exists(select 1 from pg_trigger t join pg_class c on c.oid=t.tgrelid join pg_namespace n on n.oid=c.relnamespace where n.nspname='game' and c.relname='incident_deployments' and t.tgname='incident_deployment_route_snapshot' and not t.tgisinternal) then raise exception 'Route snapshot trigger missing'; end if;
 if v_clock is null then
   begin perform * from game.get_dispatch_candidates('KNG-TEST-NO-INCIDENT'); raise exception 'Expected clock guard';
   exception when others then if sqlerrm not like '%fictional game clock is not initialized%' then raise; end if; end;
 end if;
 if exists(select 1 from game.police_units) then raise exception 'Expected no persistent unit seed in baseline regression'; end if;
 select count(*) into v_after_routes from game.road_route_calculations;
 select count(*) into v_after_history from game.deployment_route_history;
 if v_before_routes<>v_after_routes or v_before_history<>v_after_history then raise exception 'Readiness checks wrote persistent route data'; end if;
end $$;
rollback;