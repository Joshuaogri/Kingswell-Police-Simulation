-- Kingswell BP-29: correctional NPC staff profiles and directory commands.
CREATE SEQUENCE IF NOT EXISTS game.correctional_staff_ref_seq START 1;

CREATE TABLE game.correctional_staff_profiles (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 staff_ref text NOT NULL UNIQUE DEFAULT ('KWCS-' || lpad(nextval('game.correctional_staff_ref_seq')::text,7,'0')),
 person_id uuid NOT NULL UNIQUE REFERENCES game.persons(id),
 facility_id uuid NOT NULL REFERENCES game.correctional_facilities(id),
 role text NOT NULL CHECK (role IN ('facility_governor','deputy_governor','custody_supervisor','correctional_officer','escort_officer','healthcare_professional','psychologist','educator','probation_officer','social_worker','administrator','specialist')),
 employment_status text NOT NULL DEFAULT 'active' CHECK (employment_status IN ('active','suspended','ended')),
 appointed_at_game_time timestamptz NOT NULL,
 appointed_by_person_id uuid NOT NULL REFERENCES game.persons(id),
 source_command_id uuid NOT NULL REFERENCES game.game_commands(id),
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX correctional_staff_facility_status_idx ON game.correctional_staff_profiles(facility_id,employment_status,role);

CREATE TABLE game.correctional_staff_events (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 staff_profile_id uuid NOT NULL REFERENCES game.correctional_staff_profiles(id),
 event_type text NOT NULL CHECK (event_type IN ('appointed','suspended','reactivated','role_changed','transferred','ended')),
 event_at_game_time timestamptz NOT NULL,
 actor_person_id uuid NOT NULL REFERENCES game.persons(id),
 details jsonb NOT NULL DEFAULT '{}'::jsonb,
 source_command_id uuid NOT NULL REFERENCES game.game_commands(id),
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX correctional_staff_events_profile_time_idx ON game.correctional_staff_events(staff_profile_id,event_at_game_time);
CREATE TRIGGER correctional_staff_events_append_only BEFORE UPDATE OR DELETE ON game.correctional_staff_events FOR EACH ROW EXECUTE FUNCTION game.reject_correctional_history_mutation();
ALTER TABLE game.correctional_staff_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE game.correctional_staff_events ENABLE ROW LEVEL SECURITY;

DO $migration$
DECLARE v text; old text; new text;
BEGIN
 SELECT pg_get_functiondef('game.interpret_correctional_command(text)'::regprocedure) INTO v;
 old := ' m:=regexp_match(t,''^prison record ([^[:space:]]+) by ([^[:space:]]+)$'',''i'');';
 new := ' m:=regexp_match(t,''^prison staff appoint ([^[:space:]]+) to ([^[:space:]]+) role (facility_governor|deputy_governor|custody_supervisor|correctional_officer|escort_officer|healthcare_professional|psychologist|educator|probation_officer|social_worker|administrator|specialist) by ([^[:space:]]+)$'',''i'');' ||
 ' IF m IS NOT NULL THEN RETURN jsonb_build_object(''command_type'',''correctional_staff_appoint'',''payload'',jsonb_build_object(''person_ref'',m[1],''facility_ref'',m[2],''role'',lower(m[3]),''actor_ref'',m[4])); END IF;' ||
 ' m:=regexp_match(t,''^prison staff list ([^[:space:]]+) by ([^[:space:]]+)$'',''i'');' ||
 ' IF m IS NOT NULL THEN RETURN jsonb_build_object(''command_type'',''correctional_staff_list'',''payload'',jsonb_build_object(''facility_ref'',m[1],''actor_ref'',m[2])); END IF;' ||
 old;
 IF position(old IN v)=0 THEN RAISE EXCEPTION 'Correctional parser insertion point missing'; END IF;
 EXECUTE replace(v,old,new);

 SELECT pg_get_functiondef('game.execute_correctional_command(uuid,text,jsonb,uuid)'::regprocedure) INTO v;
 old := ' v_case_id uuid; v_count integer; v_term game.prisoner_sentence_terms%rowtype;';
 new := old || E'\n v_staff game.correctional_staff_profiles%rowtype;';
 IF position(old IN v)=0 THEN RAISE EXCEPTION 'Correctional executor declaration missing'; END IF;
 v:=replace(v,old,new);
 old := ' ELSIF p_type=''correctional_get_record'' THEN';
 new := ' ELSIF p_type=''correctional_staff_appoint'' THEN' ||
 ' SELECT * INTO v_person FROM game.persons WHERE person_ref=p->>''person_ref'';' ||
 ' SELECT * INTO v_facility FROM game.correctional_facilities WHERE facility_ref=p->>''facility_ref'' AND status=''active'' FOR UPDATE;' ||
 ' IF v_person.id IS NULL OR v_facility.id IS NULL THEN RETURN jsonb_build_object(''ok'',false,''code'',''person_or_facility_not_found''); END IF;' ||
 ' IF EXISTS(SELECT 1 FROM game.correctional_staff_profiles WHERE person_id=v_person.id) THEN RETURN jsonb_build_object(''ok'',false,''code'',''staff_profile_already_exists''); END IF;' ||
 ' INSERT INTO game.correctional_staff_profiles(person_id,facility_id,role,appointed_at_game_time,appointed_by_person_id,source_command_id) VALUES(v_person.id,v_facility.id,p->>''role'',n,v_person_id,p_command_id) RETURNING * INTO v_staff;' ||
 ' INSERT INTO game.correctional_staff_events(staff_profile_id,event_type,event_at_game_time,actor_person_id,details,source_command_id) VALUES(v_staff.id,''appointed'',n,v_person_id,jsonb_build_object(''staff_ref'',v_staff.staff_ref,''person_ref'',v_person.person_ref,''facility_ref'',v_facility.facility_ref,''role'',v_staff.role),p_command_id);' ||
 ' INSERT INTO game.game_clock_history(command_id,previous_game_time,resulting_game_time,advancement_minutes,reason) VALUES(p_command_id,n,n,0,''Correctional NPC staff appointment'');' ||
 ' RETURN jsonb_build_object(''ok'',true,''staff_ref'',v_staff.staff_ref,''person_ref'',v_person.person_ref,''facility_ref'',v_facility.facility_ref,''role'',v_staff.role,''employment_status'',v_staff.employment_status);' ||
 ' ELSIF p_type=''correctional_staff_list'' THEN' ||
 ' RETURN jsonb_build_object(''ok'',true,''facility_ref'',p->>''facility_ref'',''staff'',(SELECT coalesce(jsonb_agg(jsonb_build_object(''staff_ref'',s.staff_ref,''person_ref'',p2.person_ref,''role'',s.role,''employment_status'',s.employment_status,''appointed_at'',s.appointed_at_game_time) ORDER BY s.role,p2.person_ref),''[]''::jsonb) FROM game.correctional_staff_profiles s JOIN game.persons p2 ON p2.id=s.person_id JOIN game.correctional_facilities f ON f.id=s.facility_id WHERE f.facility_ref=p->>''facility_ref''));' ||
 old;
 IF position(old IN v)=0 THEN RAISE EXCEPTION 'Correctional executor insertion point missing'; END IF;
 EXECUTE replace(v,old,new);

 SELECT pg_get_functiondef('game.execute_text_command(text,text,uuid,uuid)'::regprocedure) INTO v;
 old := '''correctional_create_facility'',''correctional_admit'',''correctional_add_sentence'',''correctional_place_prisoner'',''correctional_get_record'',''correctional_list_facilities''';
 new := old || ',''correctional_staff_appoint'',''correctional_staff_list''';
 IF position(old IN v)=0 THEN RAISE EXCEPTION 'Text command list insertion point missing'; END IF;
 EXECUTE replace(v,old,new);
END
$migration$;
