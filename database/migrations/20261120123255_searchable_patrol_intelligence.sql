
create index if not exists patrol_observations_location_category_time_idx
 on game.patrol_observations(location_access_point_id,category,observed_at_game_time desc);
create index if not exists patrol_contacts_location_type_time_idx
 on game.patrol_contacts(location_access_point_id,contact_type,contacted_at_game_time desc);

create or replace function game.search_patrol_intelligence(
 p_query text default null,
 p_beat_ref text default null,
 p_access_ref text default null,
 p_person_ref text default null,
 p_organisation_ref text default null,
 p_incident_ref text default null,
 p_since timestamptz default null,
 p_until timestamptz default null,
 p_limit integer default 100
) returns jsonb
language plpgsql stable set search_path to ''
as $f$
declare v_now timestamptz; v_from timestamptz; v_to timestamptz; q text; result jsonb;
begin
 select current_game_time into v_now from game.simulation_state where id=1;
 if v_now is null then raise exception 'Patrol intelligence search requires an initialized fictional clock'; end if;
 v_from:=coalesce(p_since,'-infinity'::timestamptz);
 v_to:=coalesce(p_until,v_now);
 if v_from>=v_to or v_to>v_now then raise exception 'Invalid patrol intelligence time window'; end if;
 if p_limit is null or p_limit<1 or p_limit>500 then raise exception 'Search limit must be between 1 and 500'; end if;
 q:=nullif(btrim(p_query),'');
 if p_beat_ref is not null and not exists(select 1 from game.patrol_beats where beat_ref=p_beat_ref) then raise exception 'Patrol beat reference not found'; end if;
 if p_access_ref is not null and not exists(select 1 from game.property_access_points where access_ref=p_access_ref) then raise exception 'Access point reference not found'; end if;
 if p_person_ref is not null and not exists(select 1 from game.persons where person_ref=p_person_ref) then raise exception 'Person reference not found'; end if;
 if p_organisation_ref is not null and not exists(select 1 from game.organisations where organisation_ref=p_organisation_ref) then raise exception 'Organisation reference not found'; end if;
 if p_incident_ref is not null and not exists(select 1 from game.incidents where incident_ref=p_incident_ref) then raise exception 'Incident reference not found'; end if;
 with records as (
  select 'observation'::text record_type,o.observation_ref record_ref,o.observed_at_game_time recorded_at,
   o.category record_category,o.description narrative,null::text outcome,null::text notes,
   b.beat_ref,a.access_ref,null::text person_ref,null::text organisation_ref,null::text incident_ref,
   p.address_line location
  from game.patrol_observations o
  join game.patrol_beats b on b.id=o.beat_id
  join game.property_access_points a on a.id=o.location_access_point_id
  left join game.properties p on p.id=a.property_id
  left join game.patrol_contacts pc on false
  where o.observed_at_game_time between v_from and v_to
   and (p_beat_ref is null or b.beat_ref=p_beat_ref)
   and (p_access_ref is null or a.access_ref=p_access_ref)
   and p_person_ref is null and p_organisation_ref is null and p_incident_ref is null
   and (q is null or o.category ilike '%'||q||'%' or o.description ilike '%'||q||'%')
  union all
  select 'contact',c.contact_ref,c.contacted_at_game_time,c.contact_type,c.outcome,c.outcome,c.notes,
   b.beat_ref,a.access_ref,pe.person_ref,org.organisation_ref,i.incident_ref,p.address_line
  from game.patrol_contacts c
  join game.patrol_beats b on b.id=c.beat_id
  join game.property_access_points a on a.id=c.location_access_point_id
  left join game.persons pe on pe.id=c.person_id
  left join game.organisations org on org.id=c.organisation_id
  left join game.incidents i on i.id=c.incident_id
  left join game.properties p on p.id=c.property_id
  where c.contacted_at_game_time between v_from and v_to
   and (p_beat_ref is null or b.beat_ref=p_beat_ref)
   and (p_access_ref is null or a.access_ref=p_access_ref)
   and (p_person_ref is null or pe.person_ref=p_person_ref)
   and (p_organisation_ref is null or org.organisation_ref=p_organisation_ref)
   and (p_incident_ref is null or i.incident_ref=p_incident_ref)
   and (q is null or c.contact_type ilike '%'||q||'%' or c.outcome ilike '%'||q||'%' or coalesce(c.notes,'') ilike '%'||q||'%')
 ), limited as (
  select * from records order by recorded_at desc,record_type,record_ref limit p_limit
 ), repeats as (
  select record_type,record_category,access_ref,location,count(*)::integer record_count,
   min(recorded_at) first_recorded_at,max(recorded_at) last_recorded_at
  from records group by record_type,record_category,access_ref,location having count(*)>1
 )
 select jsonb_build_object(
  'ok',true,'window',jsonb_build_object('from',case when v_from='-infinity'::timestamptz then null else v_from end,'to',v_to),
  'filters',jsonb_build_object('query',q,'beat_ref',p_beat_ref,'access_ref',p_access_ref,'person_ref',p_person_ref,'organisation_ref',p_organisation_ref,'incident_ref',p_incident_ref),
  'records',coalesce((select jsonb_agg(jsonb_build_object('record_type',record_type,'record_ref',record_ref,'recorded_at',recorded_at,'category_or_type',record_category,'description_or_outcome',narrative,'notes',notes,'beat_ref',beat_ref,'access_ref',access_ref,'location',location,'person_ref',person_ref,'organisation_ref',organisation_ref,'incident_ref',incident_ref) order by recorded_at desc) from limited),'[]'::jsonb),
  'repeat_concerns',coalesce((select jsonb_agg(jsonb_build_object('record_type',record_type,'category_or_type',record_category,'access_ref',access_ref,'location',location,'record_count',record_count,'first_recorded_at',first_recorded_at,'last_recorded_at',last_recorded_at) order by record_count desc,last_recorded_at desc) from repeats),'[]'::jsonb),
  'records_returned',(select count(*) from limited),
  'records_match_count',(select count(*) from records),
  'interpretation','Counts show repeated recorded reports only. They do not establish criminality, corroboration, risk, identity or guilt.'
 ) into result;
 return result;
end;$f$;

revoke all on function game.search_patrol_intelligence(text,text,text,text,text,text,timestamptz,timestamptz,integer) from public,anon,authenticated;
grant execute on function game.search_patrol_intelligence(text,text,text,text,text,text,timestamptz,timestamptz,integer) to service_role;

alter function game.interpret_text_command(text) rename to interpret_text_command_before_search;
create or replace function game.interpret_text_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game'
as $f$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^search[[:space:]]+patrol[[:space:]]+intelligence(?:[[:space:]]+for[[:space:]]+(.+))?$','i');
 if m is not null then
  return jsonb_build_object('recognized',true,'command_type','search_patrol_intelligence','payload',jsonb_build_object('query',nullif(btrim(m[1]),'')));
 end if;
 return game.interpret_text_command_before_search(p_command_text);
end;$f$;
revoke all on function game.interpret_text_command(text) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text) to service_role;

do $patch$
declare def text; marker text; injected text;
begin
 def:=pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure);
 marker:=$m$  elsif v_type='record_patrol_contact' then
    v_result:=game.record_patrol_contact(v_command.id,p_payload->>'session_ref',p_payload->>'contact_type',p_payload->>'access_ref',p_payload->>'person_ref',p_payload->>'organisation_ref',p_payload->>'property_ref',p_payload->>'incident_ref',p_payload->>'outcome',p_payload->>'notes',p_actor_personnel_id);
$m$;
 injected:=$i$  elsif v_type='search_patrol_intelligence' then
    v_result:=game.search_patrol_intelligence(p_payload->>'query',p_payload->>'beat_ref',p_payload->>'access_ref',p_payload->>'person_ref',p_payload->>'organisation_ref',p_payload->>'incident_ref',
      case when nullif(p_payload->>'since','') is null then null else (p_payload->>'since')::timestamptz end,
      case when nullif(p_payload->>'until','') is null then null else (p_payload->>'until')::timestamptz end,100)
      || jsonb_build_object('status','completed','command_id',v_command.id);
$i$;
 if position(marker in def)=0 then raise exception 'Could not locate patrol contact dispatcher branch'; end if;
 def:=replace(def,marker,marker||injected);
 def:=replace(def,'''record_patrol_contact'')','''record_patrol_contact'',''search_patrol_intelligence'')');
 execute def;
end;$patch$;
