-- BP-04 clock consistency: premises history must use simulation time only.
-- A paused/uninitialised game clock must never be replaced with wall-clock time.

create or replace function game.record_scene_premises(
 p_scene_ref text,p_property_ref text,p_building_ref text,p_unit_ref text,
 p_reason text,p_actor_ref text,p_command_id uuid
) returns jsonb
language plpgsql
set search_path to 'pg_catalog','game'
as $function$
declare
 v_scene game.incident_scenes%rowtype; v_actor game.police_personnel%rowtype;
 v_property game.properties%rowtype; v_building game.buildings%rowtype;
 v_unit game.building_units%rowtype; v_clock timestamptz; v_event game.scene_premises_history%rowtype;
begin
 select * into v_scene from game.incident_scenes where scene_ref=btrim(p_scene_ref) for update;
 if v_scene.id is null then return jsonb_build_object('ok',false,'code','scene_not_found'); end if;
 select * into v_actor from game.police_personnel
  where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if v_actor.id is null then return jsonb_build_object('ok',false,'code','actor_unavailable'); end if;
 select * into v_property from game.properties where property_ref=btrim(p_property_ref);
 if v_property.id is null then return jsonb_build_object('ok',false,'code','property_not_found'); end if;
 if nullif(lower(btrim(p_building_ref)),'unknown') is not null then
  select * into v_building from game.buildings where building_ref=btrim(p_building_ref);
  if v_building.id is null or v_building.property_id<>v_property.id then
   return jsonb_build_object('ok',false,'code','building_not_in_property');
  end if;
 end if;
 if nullif(lower(btrim(p_unit_ref)),'unknown') is not null then
  if v_building.id is null then return jsonb_build_object('ok',false,'code','building_required_for_unit'); end if;
  select * into v_unit from game.building_units where unit_ref=btrim(p_unit_ref) and building_id=v_building.id;
  if v_unit.id is null or v_unit.building_id<>v_building.id then
   return jsonb_build_object('ok',false,'code','unit_not_in_building');
  end if;
 end if;
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then
  return jsonb_build_object('ok',false,'code','clock_not_initialized',
    'message','Initialize the fictional game clock before recording scene premises.');
 end if;
 if length(btrim(coalesce(p_reason,''))) not between 3 and 2000 then
  return jsonb_build_object('ok',false,'code','invalid_reason');
 end if;
 update game.incident_scenes set property_id=v_property.id,
  building_id=v_building.id,building_unit_id=v_unit.id,updated_at=now()
 where id=v_scene.id;
 insert into game.scene_premises_history(
  event_ref,scene_id,property_id,building_id,building_unit_id,reason,
  recorded_by_personnel_id,recorded_at_game_time,source_command_id
 ) values (
  'KNG-SPH-'||replace(gen_random_uuid()::text,'-',''),v_scene.id,
  v_property.id,v_building.id,v_unit.id,btrim(p_reason),v_actor.id,v_clock,p_command_id
 ) returning * into v_event;
 return jsonb_build_object('ok',true,'record_type','scene_premises',
  'scene_ref',v_scene.scene_ref,'property_ref',v_property.property_ref,
  'building_ref',v_building.building_ref,'unit_ref',v_unit.unit_ref,
  'event_ref',v_event.event_ref,'recorded_at_game_time',v_clock);
end;
$function$;

create or replace function game.record_search_premises_location(
 p_premises_ref text,p_building_ref text,p_unit_ref text,p_reason text,p_actor_ref text,p_command_id uuid
) returns jsonb
language plpgsql
set search_path to 'pg_catalog','game'
as $function$
declare v_premises game.search_premises%rowtype; v_actor game.police_personnel%rowtype;
 v_building game.buildings%rowtype; v_unit game.building_units%rowtype; v_clock timestamptz;
begin
 select * into v_premises from game.search_premises where premises_ref=btrim(p_premises_ref) for update;
 if v_premises.id is null then return jsonb_build_object('ok',false,'code','search_premises_not_found'); end if;
 select * into v_actor from game.police_personnel
  where personnel_ref=btrim(p_actor_ref) and employment_status in ('active','seconded');
 if v_actor.id is null then return jsonb_build_object('ok',false,'code','actor_unavailable'); end if;
 if nullif(lower(btrim(p_building_ref)),'unknown') is not null then
  select * into v_building from game.buildings where building_ref=btrim(p_building_ref);
  if v_building.id is null or v_building.property_id<>v_premises.property_id then
   return jsonb_build_object('ok',false,'code','building_not_in_property');
  end if;
 end if;
 if nullif(lower(btrim(p_unit_ref)),'unknown') is not null then
  if v_building.id is null then return jsonb_build_object('ok',false,'code','building_required_for_unit'); end if;
  select * into v_unit from game.building_units where unit_ref=btrim(p_unit_ref) and building_id=v_building.id;
  if v_unit.id is null or v_unit.building_id<>v_building.id then
   return jsonb_build_object('ok',false,'code','unit_not_in_building');
  end if;
 end if;
 select current_game_time into v_clock from game.simulation_state where id=1;
 if v_clock is null then
  return jsonb_build_object('ok',false,'code','clock_not_initialized',
    'message','Initialize the fictional game clock before recording search premises.');
 end if;
 if length(btrim(coalesce(p_reason,''))) not between 3 and 2000 then
  return jsonb_build_object('ok',false,'code','invalid_reason');
 end if;
 update game.search_premises set building_id=v_building.id,building_unit_id=v_unit.id
 where id=v_premises.id;
 insert into game.search_premises_location_history(
  event_ref,premises_id,property_id,building_id,building_unit_id,reason,
  recorded_by_personnel_id,recorded_at_game_time,source_command_id
 ) values (
  'KNG-SPLH-'||replace(gen_random_uuid()::text,'-',''),v_premises.id,v_premises.property_id,
  v_building.id,v_unit.id,btrim(p_reason),v_actor.id,v_clock,p_command_id
 );
 return jsonb_build_object('ok',true,'record_type','search_premises_location',
  'premises_ref',v_premises.premises_ref,'property_id',v_premises.property_id,
  'building_ref',v_building.building_ref,'unit_ref',v_unit.unit_ref,
  'recorded_at_game_time',v_clock);
end;
$function$;
