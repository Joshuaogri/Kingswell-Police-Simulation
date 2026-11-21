create or replace function game.interpret_arrest_custody_command(p_command_text text) returns jsonb language plpgsql immutable set search_path=pg_catalog,game as $$
declare t text:=btrim(coalesce(p_command_text,''));m text[];
begin
 m:=regexp_match(t,'^arrest execute ([^[:space:]]+) person ([^[:space:]]+) by ([^[:space:]]+) basis ([^[:space:]]+) location "([^"]+)" grounds "([^"]+)" force "([^"]+)" injuries "([^"]+)" warnings "([^"]+)"(?: authority "([^"]+)")?(?: witnesses "([^"]+)")?(?: body_camera "([^"]+)")?(?: incident ([^[:space:]]+))?$','i');
 if m is not null then return jsonb_build_object('command_type','execute_arrest','payload',jsonb_build_object('case_ref',m[1],'person_ref',m[2],'actor_ref',m[3],'basis',lower(m[4]),'location',m[5],'grounds',m[6],'force',m[7],'injuries',m[8],'warnings',m[9],'authority_reference',m[10],'witnesses',m[11],'body_camera',m[12],'incident_ref',m[13]));end if;
 m:=regexp_match(t,'^arrest transport ([^[:space:]]+) by ([^[:space:]]+) to "([^"]+)" vehicle "([^"]+)" handover "([^"]+)"$','i');
 if m is not null then return jsonb_build_object('command_type','transport_arrest','payload',jsonb_build_object('arrest_ref',m[1],'actor_ref',m[2],'destination',m[3],'vehicle',m[4],'handover',m[5]));end if;
 m:=regexp_match(t,'^custody book ([^[:space:]]+) by ([^[:space:]]+) identity "([^"]+)" risk "([^"]+)" health "([^"]+)" cell "([^"]+)"(?: medication "([^"]+)")?(?: safeguarding "([^"]+)")?$','i');
 if m is not null then return jsonb_build_object('command_type','book_custody','payload',jsonb_build_object('arrest_ref',m[1],'actor_ref',m[2],'identity_check',m[3],'risk',m[4],'health',m[5],'cell',m[6],'medication',m[7],'safeguarding',m[8]));end if;
 m:=regexp_match(t,'^custody property ([^[:space:]]+) by ([^[:space:]]+) item "([^"]+)" condition "([^"]+)" disposition ([^[:space:]]+)(?: storage "([^"]+)")?$','i');
 if m is not null then return jsonb_build_object('command_type','record_custody_property','payload',jsonb_build_object('custody_ref',m[1],'actor_ref',m[2],'item',m[3],'condition',m[4],'disposition',lower(m[5]),'storage',m[6]));end if;
 m:=regexp_match(t,'^custody check ([^[:space:]]+) by ([^[:space:]]+) type ([^[:space:]]+) observation "([^"]+)"(?: escalation "([^"]+)")?$','i');
 if m is not null then return jsonb_build_object('command_type','custody_check','payload',jsonb_build_object('custody_ref',m[1],'actor_ref',m[2],'check_type',lower(m[3]),'observation',m[4],'escalation',m[5]));end if;
 m:=regexp_match(t,'^custody event ([^[:space:]]+) by ([^[:space:]]+) type ([^[:space:]]+) details "([^"]+)"$','i');
 if m is not null then return jsonb_build_object('command_type','custody_event','payload',jsonb_build_object('custody_ref',m[1],'actor_ref',m[2],'event_type',lower(m[3]),'details',m[4]));end if;
 m:=regexp_match(t,'^custody release ([^[:space:]]+) by ([^[:space:]]+) outcome ([^[:space:]]+) because "([^"]+)"$','i');
 if m is not null then return jsonb_build_object('command_type','release_custody','payload',jsonb_build_object('custody_ref',m[1],'actor_ref',m[2],'outcome',lower(m[3]),'reason',m[4]));end if;
 m:=regexp_match(t,'^custody transfer ([^[:space:]]+) by ([^[:space:]]+) to "([^"]+)" because "([^"]+)"$','i');
 if m is not null then return jsonb_build_object('command_type','transfer_custody','payload',jsonb_build_object('custody_ref',m[1],'actor_ref',m[2],'destination',m[3],'reason',m[4]));end if;
 m:=regexp_match(t,'^case arrests ([^[:space:]]+) by ([^[:space:]]+)$','i');
 if m is not null then return jsonb_build_object('command_type','get_case_arrests','payload',jsonb_build_object('case_ref',m[1],'actor_ref',m[2]));end if;
 return null;
end $$;
