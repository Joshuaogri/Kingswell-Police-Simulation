create or replace function game.interpret_property_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path to 'pg_catalog','game'
as $$
declare t text:=btrim(coalesce(p_command_text,'')); m text[];
begin
 m:=regexp_match(t,'^property record ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','property_get_record','payload',jsonb_build_object('property_ref',m[1],'actor_ref',m[2])); end if;
 m:=regexp_match(t,'^property map ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','property_neighbourhood_map','payload',jsonb_build_object('neighbourhood_code',upper(m[1]),'actor_ref',m[2])); end if;
 m:=regexp_match(t,'^property summary by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','property_city_summary','payload',jsonb_build_object('actor_ref',m[1])); end if;
 m:=regexp_match(t,'^business record ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','business_get_record','payload',jsonb_build_object('business_number',m[1],'actor_ref',m[2])); end if;
 m:=regexp_match(t,'^business directory by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','business_directory','payload',jsonb_build_object('actor_ref',m[1],'limit',500)); end if;
 m:=regexp_match(t,'^business directory sector ([a-z_]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','business_directory','payload',jsonb_build_object('sector',lower(m[1]),'actor_ref',m[2],'limit',500)); end if;
 m:=regexp_match(t,'^business directory district ([A-Z0-9-]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','business_directory','payload',jsonb_build_object('district_code',upper(m[1]),'actor_ref',m[2],'limit',500)); end if;
 m:=regexp_match(t,'^business directory search "([^"]+)" by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','business_directory','payload',jsonb_build_object('search',m[1],'actor_ref',m[2],'limit',500)); end if;
 return null;
end $$;
