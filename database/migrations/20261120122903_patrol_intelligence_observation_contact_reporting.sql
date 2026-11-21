do $patch$
declare def text; old text; new text;
begin
 def:=pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure);
 old:=$o$'patrol_intelligence','start_patrol_activity','end_patrol_activity')$o$;
 new:=$n$'patrol_intelligence','start_patrol_activity','end_patrol_activity','record_patrol_observation','record_patrol_contact')$n$;
 if position(old in def)=0 then raise exception 'Could not locate patrol help command list'; end if;
 def:=replace(def,old,new);
 execute def;
end;$patch$;

alter function game.get_patrol_intelligence(timestamptz,timestamptz) rename to get_patrol_intelligence_before_records;
create or replace function game.get_patrol_intelligence(p_since timestamptz default null,p_until timestamptz default null)
returns jsonb language plpgsql stable set search_path to ''
as $f$
declare base jsonb; v_now timestamptz; v_from timestamptz; v_to timestamptz; observations jsonb; contacts jsonb; totals jsonb;
begin
 base:=game.get_patrol_intelligence_before_records(p_since,p_until);
 select current_game_time into v_now from game.simulation_state where id=1;
 v_to:=coalesce(p_until,v_now); v_from:=coalesce(p_since,'-infinity'::timestamptz);
 select coalesce(jsonb_agg(jsonb_build_object('category',x.category,'records',x.records) order by x.category),'[]'::jsonb)
 into observations from (select category,count(*)::integer records from game.patrol_observations where observed_at_game_time>=v_from and observed_at_game_time<=v_to group by category) x;
 select coalesce(jsonb_agg(jsonb_build_object('contact_type',x.contact_type,'records',x.records,'linked_people',x.people,'linked_organisations',x.organisations,'linked_properties',x.properties,'linked_incidents',x.incidents) order by x.contact_type),'[]'::jsonb)
 into contacts from (select contact_type,count(*)::integer records,count(person_id)::integer people,count(organisation_id)::integer organisations,count(property_id)::integer properties,count(incident_id)::integer incidents from game.patrol_contacts where contacted_at_game_time>=v_from and contacted_at_game_time<=v_to group by contact_type) x;
 totals:=coalesce(base->'totals','{}'::jsonb)||jsonb_build_object(
  'patrol_observations',(select count(*) from game.patrol_observations where observed_at_game_time>=v_from and observed_at_game_time<=v_to),
  'patrol_contacts',(select count(*) from game.patrol_contacts where contacted_at_game_time>=v_from and contacted_at_game_time<=v_to)
 );
 return base||jsonb_build_object('observation_by_category',observations,'contact_by_type',contacts,'totals',totals);
end;$f$;
revoke all on function game.get_patrol_intelligence(timestamptz,timestamptz) from public,anon,authenticated;
grant execute on function game.get_patrol_intelligence(timestamptz,timestamptz) to service_role;
