-- Explicit per-premises outcomes; prevent silent assumption that every premises was searched.
do $outer$
declare d text;needle text;replacement text;
begin
 select pg_get_functiondef('game.execute_search_command(uuid,text,jsonb,uuid)'::regprocedure) into d;
 needle:=' elsif p_command_type=''close_search_operation'' then';
 replacement:=$patch$ elsif p_command_type='set_search_premises_status' then
  select * into prm from game.search_premises where premises_ref=p_payload->>'premises_ref' for update;
  select * into o from game.search_operations where id=prm.operation_id;
  if prm.id is null or o.status<>'executing' then return jsonb_build_object('ok',false,'code','search_not_active');end if;
  if not exists(select 1 from game.search_operation_team where operation_id=o.id and personnel_id=p_actor_id) then return jsonb_build_object('ok',false,'code','team_members_only');end if;
  if prm.status<>'planned' or p_payload->>'premises_status' not in ('searched','not_searched') or nullif(btrim(p_payload->>'reason'),'') is null then return jsonb_build_object('ok',false,'code','premises_status_invalid','message','Premises must be pending, with a searched/not_searched outcome and reason.');end if;
  update game.search_premises set status=p_payload->>'premises_status',searched_at_game_time=case when p_payload->>'premises_status'='searched' then n else null end,outcome_summary=btrim(p_payload->>'reason') where id=prm.id;
  insert into game.search_operation_events(operation_id,event_type,actor_personnel_id,event_at_game_time,event_data,source_command_id) values(o.id,'premises_status_recorded',p_actor_id,n,jsonb_build_object('premises_ref',prm.premises_ref,'status',p_payload->>'premises_status','reason',p_payload->>'reason'),p_command_id);
  return jsonb_build_object('ok',true,'premises_ref',prm.premises_ref,'status',p_payload->>'premises_status');
 elsif p_command_type='close_search_operation' then$patch$;
 if position(needle in d)=0 then raise exception 'Premises status handler insertion point missing';end if;
 d:=replace(d,needle,replacement);
 needle:='update game.search_operations set status=''completed'',closed_at_game_time=n,closure_reason=btrim(p_payload->>''reason'') where id=o.id;update game.search_premises set status=''searched'',searched_at_game_time=n,outcome_summary=''Search completed; see individual logs.'' where operation_id=o.id and status=''planned'';';
 replacement:='if exists(select 1 from game.search_premises where operation_id=o.id and status=''planned'') then return jsonb_build_object(''ok'',false,''code'',''premises_outcomes_incomplete'',''message'',''Record a searched or not_searched outcome for every premises before closing.'');end if; update game.search_operations set status=''completed'',closed_at_game_time=n,closure_reason=btrim(p_payload->>''reason'') where id=o.id;';
 if position(needle in d)=0 then raise exception 'Search close guard replacement point missing';end if;
 d:=replace(d,needle,replacement);execute d;
 select pg_get_functiondef('game.interpret_search_command(text)'::regprocedure) into d;
 needle:='return null;end $function$';
 replacement:=$parser$m:=regexp_match(t,'^search premises status ([^[:space:]]+) set (searched|not_searched) because "(.+)" by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','set_search_premises_status','payload',jsonb_build_object('premises_ref',m[1],'premises_status',lower(m[2]),'reason',m[3],'actor_ref',m[4]));end if;
 return null;end $function$;$parser$;
 if position(needle in d)=0 then raise exception 'Search parser insertion point missing';end if;
 d:=replace(d,needle,replacement);execute d;
 select pg_get_functiondef('game.execute_text_command(text,text,uuid,uuid)'::regprocedure) into d;
 d:=replace(d,'''get_search_operations''))x','''get_search_operations'',''set_search_premises_status''))x');
 d:=replace(d,'''get_search_operations'') then','''get_search_operations'',''set_search_premises_status'') then');
 execute d;
end $outer$;
