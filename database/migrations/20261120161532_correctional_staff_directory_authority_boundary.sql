-- BP-29 authority boundary: correctional staff appointments are internal correctional
-- NPC decisions, not police-player commands. Keep the read-only directory query.
DO $migration$
DECLARE v text; start_marker text; end_marker text;
BEGIN
 SELECT pg_get_functiondef('game.interpret_correctional_command(text)'::regprocedure) INTO v;
 start_marker := ' m:=regexp_match(t,''^prison staff appoint ([^[:space:]]+) to ([^[:space:]]+) role (facility_governor|deputy_governor|custody_supervisor|correctional_officer|escort_officer|healthcare_professional|psychologist|educator|probation_officer|social_worker|administrator|specialist) by ([^[:space:]]+)$'',''i'');';
 end_marker := ' m:=regexp_match(t,''^prison staff list ([^[:space:]]+) by ([^[:space:]]+)$'',''i'');';
 IF position(start_marker IN v)=0 OR position(end_marker IN v)=0 THEN RAISE EXCEPTION 'Staff parser correction markers missing'; END IF;
 v:=replace(v,start_marker || ' IF m IS NOT NULL THEN RETURN jsonb_build_object(''command_type'',''correctional_staff_appoint'',''payload'',jsonb_build_object(''person_ref'',m[1],''facility_ref'',m[2],''role'',lower(m[3]),''actor_ref'',m[4])); END IF;' || end_marker,end_marker);
 EXECUTE v;

 SELECT pg_get_functiondef('game.execute_correctional_command(uuid,text,jsonb,uuid)'::regprocedure) INTO v;
 start_marker := ' ELSIF p_type=''correctional_staff_appoint'' THEN';
 end_marker := ' ELSIF p_type=''correctional_staff_list'' THEN';
 IF position(start_marker IN v)=0 OR position(end_marker IN v)=0 THEN RAISE EXCEPTION 'Staff executor correction markers missing'; END IF;
 v:=substring(v from 1 for position(start_marker IN v)-1) || substring(v from position(end_marker IN v));
 EXECUTE v;

 SELECT pg_get_functiondef('game.execute_text_command(text,text,uuid,uuid)'::regprocedure) INTO v;
 v:=replace(v,',''correctional_staff_appoint''','');
 EXECUTE v;
END
$migration$;
