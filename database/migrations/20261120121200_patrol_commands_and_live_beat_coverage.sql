-- Add player-facing patrol grammar, coverage query and command-ledger integration.
alter function game.interpret_text_command(text) rename to interpret_text_command_base;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game'
as $function$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^assign[[:space:]]+beat[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+to[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+because[[:space:]]+(.+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','assign_patrol_beat','payload',jsonb_build_object('unit_ref',m[1],'beat_ref',m[2],'reason',btrim(m[3]))); end if;
 m:=regexp_match(t,'^schedule[[:space:]]+patrol[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+in[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+from[[:space:]]+(.+)[[:space:]]+to[[:space:]]+(.+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','schedule_patrol','payload',jsonb_build_object('schedule_ref',m[1],'unit_ref',m[2],'beat_ref',m[3],'starts_at',m[4],'ends_at',m[5])); end if;
 m:=regexp_match(t,'^start[[:space:]]+patrol[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+because[[:space:]]+(.+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','start_patrol','payload',jsonb_build_object('unit_ref',m[1],'reason',btrim(m[2]))); end if;
 m:=regexp_match(t,'^end[[:space:]]+patrol[[:space:]]+([A-Za-z0-9._/-]+)[[:space:]]+because[[:space:]]+(.+)$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','end_patrol','payload',jsonb_build_object('unit_ref',m[1],'reason',btrim(m[2]))); end if;
 if lower(t) in ('patrol status','patrol coverage','beat coverage') then return jsonb_build_object('recognized',true,'command_type','patrol_coverage','payload','{}'::jsonb); end if;
 return game.interpret_text_command_base(p_command_text);
end;$function$;
create or replace function game.get_patrol_coverage()
returns jsonb language plpgsql stable set search_path to ''
as $function$
declare c timestamptz; result jsonb;
begin
 select current_game_time into c from game.simulation_state where id=1;
 select jsonb_build_object('game_time',c,
  'beats',coalesce((select jsonb_agg(jsonb_build_object('beat_ref',b.beat_ref,'beat_name',b.beat_name,'district_id',b.district_id,'neighbourhood_id',b.neighbourhood_id,'active_units',coalesce(x.units,'[]'::jsonb),'coverage_status',case when jsonb_array_length(coalesce(x.units,'[]'::jsonb))>0 then 'covered' else 'uncovered' end) order by b.beat_ref)
   from game.patrol_beats b left join lateral (select jsonb_agg(jsonb_build_object('unit_ref',u.unit_ref,'unit_name',u.unit_name,'state',u.operational_state,'schedule_ref',s.schedule_ref,'started_at',s.starts_at,'ends_at',s.ends_at)) units from game.police_units u join game.patrol_schedules s on s.unit_id=u.id and s.beat_id=b.id and s.status='active' where u.status='active' and u.operational_state='on_patrol') x on true where b.status='active'),'[]'::jsonb),
  'totals',jsonb_build_object('active_beats',(select count(*) from game.patrol_beats where status='active'),
   'covered_beats',(select count(*) from game.patrol_beats b where b.status='active' and exists(select 1 from game.police_units u join game.patrol_schedules s on s.unit_id=u.id and s.beat_id=b.id and s.status='active' where u.status='active' and u.operational_state='on_patrol')),
   'uncovered_beats',(select count(*) from game.patrol_beats b where b.status='active' and not exists(select 1 from game.police_units u join game.patrol_schedules s on s.unit_id=u.id and s.beat_id=b.id and s.status='active' where u.status='active' and u.operational_state='on_patrol')))) into result;
 return result;
end;$function$;
do $patch$
declare def text; marker text; injected text;
begin
 def:=pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure);
 marker:=$marker$  else
    v_result:=jsonb_build_object('ok',false,'code','unknown_command'$marker$;
 injected:=$inject$  elsif v_type='assign_patrol_beat' then
    v_result:=game.assign_unit_patrol_beat(p_payload->>'unit_ref',p_payload->>'beat_ref',p_payload->>'reason') || jsonb_build_object('ok',true,'status','completed');
  elsif v_type='schedule_patrol' then
    v_result:=game.schedule_unit_patrol(p_payload->>'schedule_ref',p_payload->>'unit_ref',p_payload->>'beat_ref',(p_payload->>'starts_at')::timestamptz,(p_payload->>'ends_at')::timestamptz,null) || jsonb_build_object('ok',true,'status','completed');
  elsif v_type='start_patrol' then
    v_result:=game.start_unit_patrol(p_payload->>'unit_ref',p_payload->>'reason') || jsonb_build_object('ok',true,'status','completed');
  elsif v_type='end_patrol' then
    v_result:=game.end_unit_patrol(p_payload->>'unit_ref',p_payload->>'reason') || jsonb_build_object('ok',true,'status','completed');
  elsif v_type='patrol_coverage' then
    v_result:=jsonb_build_object('ok',true,'status','completed','coverage',game.get_patrol_coverage());
$inject$;
 if position(marker in def)=0 then raise exception 'Could not locate unknown-command branch'; end if;
 execute replace(def,marker,injected||marker);
end;$patch$;
revoke all on function game.interpret_text_command(text),game.interpret_text_command_base(text),game.get_patrol_coverage() from public,anon,authenticated;
grant execute on function game.interpret_text_command(text),game.interpret_text_command_base(text),game.get_patrol_coverage() to service_role;