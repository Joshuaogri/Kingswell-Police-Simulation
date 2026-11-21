-- Feed the fictional simulation clock into routing for dispatch and deployment snapshots.
do $$
declare v_def text;
begin
 select pg_get_functiondef('game.snapshot_deployment_route()'::regprocedure) into v_def;
 if position('calculate_road_route(v_origin,v_destination,''police'',''fastest'')' in v_def)=0 then
  raise exception 'Could not locate route call in snapshot_deployment_route';
 end if;
 v_def:=replace(v_def,'calculate_road_route(v_origin,v_destination,''police'',''fastest'')',
  'calculate_road_route(v_origin,v_destination,''police'',''fastest'',v_clock)');
 v_def:=replace(v_def,'Baseline posted-speed estimate; no live traffic, siren uplift or turn-delay model.',
  'Fictional-clock route estimate using authored peak traffic, active road conditions, turn restrictions and access rules; no siren-speed uplift.');
 execute v_def;

 select pg_get_functiondef('game.get_dispatch_candidates(text)'::regprocedure) into v_def;
 if position('calculate_road_route(v_origin,v_destination,''police'',''fastest'')' in v_def)=0 then
  raise exception 'Could not locate route call in get_dispatch_candidates';
 end if;
 v_def:=replace(v_def,'calculate_road_route(v_origin,v_destination,''police'',''fastest'')',
  'calculate_road_route(v_origin,v_destination,''police'',''fastest'',v_clock)');
 v_def:=replace(v_def,'Baseline posted-speed estimate; no live traffic, siren uplift or turn-delay model.',
  'Fictional-clock route estimate using authored peak traffic, active road conditions, turn restrictions and access rules; no siren-speed uplift.');
 execute v_def;
end $$;
