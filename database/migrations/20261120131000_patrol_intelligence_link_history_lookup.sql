-- Read-only lookup of permanent patrol-intelligence linkage history.
create or replace function game.get_patrol_intelligence_links(p_reference text default null,p_limit integer default 100)
returns jsonb language plpgsql stable set search_path to ''
as $f$
declare v_now timestamptz; result jsonb; v_ref text:=nullif(btrim(p_reference),'');
begin
 select current_game_time into v_now from game.simulation_state where id=1;
 if v_now is null then raise exception 'Patrol intelligence link lookup requires an initialized fictional clock'; end if;
 if p_limit is null or p_limit<1 or p_limit>500 then raise exception 'Link lookup limit must be between 1 and 500'; end if;
 with links as (
  select l.link_ref,l.reason,l.linked_at_game_time,
   coalesce(o.observation_ref,c.contact_ref) source_ref,
   case when o.id is not null then 'observation' else 'contact' end source_type,
   coalesce(i.incident_ref,ca.case_ref) target_ref,
   case when i.id is not null then 'incident' else 'case' end target_type,
   pp.personnel_ref actor_personnel_ref
  from game.patrol_intelligence_links l
  left join game.patrol_observations o on o.id=l.source_observation_id
  left join game.patrol_contacts c on c.id=l.source_contact_id
  left join game.incidents i on i.id=l.target_incident_id
  left join game.cases ca on ca.id=l.target_case_id
  left join game.police_personnel pp on pp.id=l.actor_personnel_id
  where v_ref is null or v_ref in (l.link_ref,o.observation_ref,c.contact_ref,i.incident_ref,ca.case_ref)
 ), limited as (select * from links order by linked_at_game_time desc,link_ref limit p_limit)
 select jsonb_build_object('ok',true,'reference',v_ref,
  'links',coalesce((select jsonb_agg(jsonb_build_object('link_ref',link_ref,'source_type',source_type,'source_ref',source_ref,
   'target_type',target_type,'target_ref',target_ref,'reason',reason,'linked_at_game_time',linked_at_game_time,
   'actor_personnel_ref',actor_personnel_ref) order by linked_at_game_time desc) from limited),'[]'::jsonb),
  'links_returned',(select count(*) from limited),'links_match_count',(select count(*) from links),
  'note','A link records an investigative association only. It does not change the source record or establish that its contents are proven.')
 into result;
 return result;
end;$f$;
revoke all on function game.get_patrol_intelligence_links(text,integer) from public,anon,authenticated;
grant execute on function game.get_patrol_intelligence_links(text,integer) to service_role;

alter function game.interpret_text_command(text) rename to interpret_text_command_before_link_lookup;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game'
as $f$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^patrol[[:space:]]+intelligence[[:space:]]+links(?:[[:space:]]+for[[:space:]]+([^[:space:]]+))?$','i');
 if m is not null then return jsonb_build_object('recognized',true,'command_type','patrol_intelligence_links',
  'payload',jsonb_build_object('reference',nullif(btrim(m[1]),''))); end if;
 return game.interpret_text_command_before_link_lookup(p_command_text);
end;$f$;
revoke all on function game.interpret_text_command(text) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text) to service_role;

do $patch$
declare def text; marker text; injected text; old_help text; new_help text;
begin
 def:=pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure);
 marker:=$m$  elsif v_type='link_patrol_record' then
    v_result:=game.link_patrol_record(v_command.id,p_payload->>'source_ref',p_payload->>'target_type',p_payload->>'target_ref',p_payload->>'reason',p_actor_personnel_id);
$m$;
 injected:=$i$  elsif v_type='patrol_intelligence_links' then
    v_result:=game.get_patrol_intelligence_links(p_payload->>'reference',100) || jsonb_build_object('status','completed','command_id',v_command.id);
$i$;
 if position(marker in def)=0 then raise exception 'Could not locate patrol intelligence link dispatcher branch'; end if;
 def:=replace(def,marker,marker||injected);
 old_help:='''search_patrol_intelligence'',''link_patrol_record'')';
 new_help:='''search_patrol_intelligence'',''link_patrol_record'',''patrol_intelligence_links'')';
 if position(old_help in def)=0 then raise exception 'Could not locate patrol intelligence help list'; end if;
 def:=replace(def,old_help,new_help);
 execute def;
end;$patch$;
