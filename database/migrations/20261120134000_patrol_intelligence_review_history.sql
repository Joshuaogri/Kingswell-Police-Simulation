-- Append-only officer review history for patrol-intelligence investigation links.
create table game.patrol_intelligence_reviews (
  id uuid primary key default gen_random_uuid(),
  review_ref text not null unique,
  link_id uuid not null references game.patrol_intelligence_links(id) on delete restrict,
  disposition text not null check (disposition in ('relevant','further_enquiries','insufficient_information','not_relevant')),
  review_note text not null check (char_length(btrim(review_note)) between 1 and 3000),
  actor_personnel_id uuid not null references game.police_personnel(id) on delete restrict,
  source_command_id uuid not null references game.game_commands(id) on delete restrict,
  reviewed_at_game_time timestamptz not null,
  created_at timestamptz not null default now()
);
create index patrol_intelligence_reviews_link_time_idx on game.patrol_intelligence_reviews(link_id, reviewed_at_game_time desc);
create index patrol_intelligence_reviews_actor_fk_idx on game.patrol_intelligence_reviews(actor_personnel_id);
create index patrol_intelligence_reviews_command_fk_idx on game.patrol_intelligence_reviews(source_command_id);
alter table game.patrol_intelligence_reviews enable row level security;
revoke all on game.patrol_intelligence_reviews from public, anon, authenticated;
grant select, insert on game.patrol_intelligence_reviews to service_role;
create trigger patrol_intelligence_reviews_append_only before update or delete on game.patrol_intelligence_reviews
for each row execute function game.reject_patrol_intelligence_link_mutation();

create or replace function game.record_patrol_intelligence_review(
 p_command_id uuid, p_link_ref text, p_disposition text, p_note text, p_actor_personnel_id uuid
) returns jsonb language plpgsql security invoker set search_path = pg_catalog, game as $$
declare v_link game.patrol_intelligence_links%rowtype; v_clock timestamptz; v_ref text; v_review_id uuid;
begin
 if p_command_id is null or p_actor_personnel_id is null then
  return jsonb_build_object('ok',false,'code','missing_attribution','message','A source command and active officer attribution are required.');
 end if;
 if p_disposition not in ('relevant','further_enquiries','insufficient_information','not_relevant') then
  return jsonb_build_object('ok',false,'code','invalid_disposition','message','Disposition must be relevant, further_enquiries, insufficient_information or not_relevant.');
 end if;
 if nullif(btrim(p_note),'') is null or char_length(p_note)>3000 then
  return jsonb_build_object('ok',false,'code','invalid_review_note','message','A review note of 1–3000 characters is required.');
 end if;
 select current_game_time into v_clock from game.simulation_state where id=1 for update;
 if v_clock is null then return jsonb_build_object('ok',false,'code','clock_not_initialized','message','The fictional clock must be initialized before recording an intelligence review.'); end if;
 select * into v_link from game.patrol_intelligence_links where link_ref=btrim(p_link_ref);
 if v_link.id is null then return jsonb_build_object('ok',false,'code','link_not_found','message','No patrol-intelligence link exists with that reference.'); end if;
 if not exists(select 1 from game.police_personnel pp where pp.id=p_actor_personnel_id and pp.employment_status='active') then
  return jsonb_build_object('ok',false,'code','actor_unavailable','message','The reviewing officer must be active police personnel.');
 end if;
 v_ref:='KNG-PIR-'||upper(substr(replace(gen_random_uuid()::text,'-',''),1,12));
 insert into game.patrol_intelligence_reviews(review_ref,link_id,disposition,review_note,actor_personnel_id,source_command_id,reviewed_at_game_time)
 values(v_ref,v_link.id,p_disposition,btrim(p_note),p_actor_personnel_id,p_command_id,v_clock) returning id into v_review_id;
 insert into game.game_events(event_key,game_time,actor_personnel_id,entity_type,entity_id,event_data)
 values('patrol_intelligence.link_reviewed',v_clock,p_actor_personnel_id,'patrol_intelligence_review',v_review_id,
  jsonb_build_object('review_ref',v_ref,'link_ref',v_link.link_ref,'disposition',p_disposition,'command_id',p_command_id));
 return jsonb_build_object('ok',true,'review_ref',v_ref,'link_ref',v_link.link_ref,'disposition',p_disposition,
  'reviewed_at_game_time',v_clock,'message','Intelligence link review recorded. The original patrol record and linkage remain unchanged.');
end;
$$;

create or replace function game.get_patrol_intelligence_reviews(p_reference text default null,p_limit integer default 100)
returns jsonb language plpgsql security invoker set search_path = pg_catalog, game as $$
declare v_rows jsonb;
begin
 if p_limit is null or p_limit<1 or p_limit>500 then raise exception 'Review history limit must be between 1 and 500'; end if;
 select coalesce(jsonb_agg(to_jsonb(q) order by q.reviewed_at_game_time desc),'[]'::jsonb) into v_rows
 from (
  select r.review_ref,l.link_ref,
   case when l.source_observation_id is not null then (select o.observation_ref from game.patrol_observations o where o.id=l.source_observation_id)
        else (select c.contact_ref from game.patrol_contacts c where c.id=l.source_contact_id) end as source_ref,
   case when l.target_incident_id is not null then (select i.incident_ref from game.incidents i where i.id=l.target_incident_id)
        else (select c.case_ref from game.cases c where c.id=l.target_case_id) end as target_ref,
   r.disposition,r.review_note,pp.personnel_ref as reviewing_officer,r.reviewed_at_game_time
  from game.patrol_intelligence_reviews r join game.patrol_intelligence_links l on l.id=r.link_id
  join game.police_personnel pp on pp.id=r.actor_personnel_id
  where p_reference is null or p_reference in (r.review_ref,l.link_ref,
   case when l.source_observation_id is not null then (select o.observation_ref from game.patrol_observations o where o.id=l.source_observation_id)
        else (select c.contact_ref from game.patrol_contacts c where c.id=l.source_contact_id) end,
   case when l.target_incident_id is not null then (select i.incident_ref from game.incidents i where i.id=l.target_incident_id)
        else (select c.case_ref from game.cases c where c.id=l.target_case_id) end)
  order by r.reviewed_at_game_time desc limit p_limit
 ) q;
 return jsonb_build_object('ok',true,'reviews',v_rows,'count',jsonb_array_length(v_rows),
  'note','Reviews record an officer assessment of an investigative association; they do not alter source records or establish guilt.');
end;
$$;
revoke all on function game.record_patrol_intelligence_review(uuid,text,text,text,uuid) from public, anon, authenticated;
revoke all on function game.get_patrol_intelligence_reviews(text,integer) from public, anon, authenticated;
grant execute on function game.record_patrol_intelligence_review(uuid,text,text,text,uuid) to service_role;
grant execute on function game.get_patrol_intelligence_reviews(text,integer) to service_role;
