
ALTER FUNCTION game.interpret_text_command(text) RENAME TO interpret_text_command_before_correctional;
ALTER FUNCTION game.execute_text_command(text,text,uuid,uuid) RENAME TO execute_text_command_before_correctional;

CREATE OR REPLACE FUNCTION game.interpret_correctional_command(p_command_text text)
RETURNS jsonb LANGUAGE plpgsql IMMUTABLE SET search_path TO 'pg_catalog','game'
AS $$
DECLARE t text:=btrim(coalesce(p_command_text,'')); m text[];
BEGIN
 m:=regexp_match(t,'^prison facility create by ([^[:space:]]+) name "([^"]+)" type (remand|prison|open_prison|youth_custody|mixed) capacity ([0-9]+) location "([^"]+)"$','i');
 IF m IS NOT NULL THEN RETURN jsonb_build_object('command_type','correctional_create_facility','payload',jsonb_build_object('actor_ref',m[1],'name',m[2],'facility_type',lower(m[3]),'capacity',m[4]::integer,'location',m[5])); END IF;
 m:=regexp_match(t,'^prison admit person ([^[:space:]]+) to ([^[:space:]]+) by ([^[:space:]]+) type (remand|sentenced|transfer_in) notes "([^"]+)"(?: sentence ([^[:space:]]+))?(?: court_case ([^[:space:]]+))?$','i');
 IF m IS NOT NULL THEN RETURN jsonb_build_object('command_type','correctional_admit','payload',jsonb_build_object('person_ref',m[1],'facility_ref',m[2],'actor_ref',m[3],'admission_type',lower(m[4]),'notes',m[5],'sentence_ref',m[6],'court_case_ref',m[7])); END IF;
 m:=regexp_match(t,'^prison sentence add ([^[:space:]]+) sentence ([^[:space:]]+) sequence ([0-9]+) mode (first|concurrent|consecutive) by ([^[:space:]]+) notes "([^"]+)"$','i');
 IF m IS NOT NULL THEN RETURN jsonb_build_object('command_type','correctional_add_sentence','payload',jsonb_build_object('admission_ref',m[1],'sentence_ref',m[2],'sequence_number',m[3]::integer,'commencement_mode',lower(m[4]),'actor_ref',m[5],'notes',m[6])); END IF;
 m:=regexp_match(t,'^prison place ([^[:space:]]+) facility ([^[:space:]]+) unit "([^"]+)" cell "([^"]+)" by ([^[:space:]]+) reason "([^"]+)"$','i');
 IF m IS NOT NULL THEN RETURN jsonb_build_object('command_type','correctional_place_prisoner','payload',jsonb_build_object('admission_ref',m[1],'facility_ref',m[2],'unit_name',m[3],'cell',m[4],'actor_ref',m[5],'reason',m[6])); END IF;
 m:=regexp_match(t,'^prison record ([^[:space:]]+) by ([^[:space:]]+)$','i');
 IF m IS NOT NULL THEN RETURN jsonb_build_object('command_type','correctional_get_record','payload',jsonb_build_object('admission_ref',m[1],'actor_ref',m[2])); END IF;
 m:=regexp_match(t,'^prison facilities by ([^[:space:]]+)$','i');
 IF m IS NOT NULL THEN RETURN jsonb_build_object('command_type','correctional_list_facilities','payload',jsonb_build_object('actor_ref',m[1])); END IF;
 RETURN NULL;
END;
$$;

CREATE OR REPLACE FUNCTION game.execute_correctional_command(
 p_command_id uuid,p_type text,p jsonb,p_actor_id uuid
) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER SET search_path TO 'pg_catalog','game'
AS $$
DECLARE
 n timestamptz; v_personnel game.police_personnel%rowtype; v_person_id uuid;
 v_facility game.correctional_facilities%rowtype; v_admission game.prisoner_admissions%rowtype;
 v_sentence game.trial_sentences%rowtype; v_person game.persons%rowtype;
 v_case_id uuid; v_count integer; v_term game.prisoner_sentence_terms%rowtype;
BEGIN
 SELECT current_game_time INTO n FROM game.simulation_state WHERE id=1 FOR UPDATE;
 IF n IS NULL THEN RETURN jsonb_build_object('ok',false,'code','clock_not_initialized','message','Initialize the fictional clock before correctional operations.'); END IF;
 SELECT * INTO v_personnel FROM game.police_personnel WHERE id=p_actor_id AND employment_status IN ('active','seconded');
 IF v_personnel.id IS NULL OR v_personnel.personnel_ref<>p->>'actor_ref' THEN RETURN jsonb_build_object('ok',false,'code','actor_mismatch'); END IF;
 v_person_id:=v_personnel.person_id;

 IF p_type='correctional_create_facility' THEN
  IF coalesce((p->>'capacity')::integer,0)<1 OR nullif(btrim(p->>'name'),'') IS NULL OR nullif(btrim(p->>'location'),'') IS NULL THEN
   RETURN jsonb_build_object('ok',false,'code','facility_details_invalid');
  END IF;
  INSERT INTO game.correctional_facilities(facility_name,facility_type,capacity,location_description)
  VALUES(p->>'name',p->>'facility_type',(p->>'capacity')::integer,p->>'location') RETURNING * INTO v_facility;
  INSERT INTO game.game_clock_history(command_id,previous_game_time,resulting_game_time,advancement_minutes,reason)
  VALUES(p_command_id,n,n,0,'Correctional facility created');
  RETURN jsonb_build_object('ok',true,'facility_ref',v_facility.facility_ref,'name',v_facility.facility_name,'capacity',v_facility.capacity);
 ELSIF p_type='correctional_admit' THEN
  SELECT * INTO v_person FROM game.persons WHERE person_ref=p->>'person_ref';
  SELECT * INTO v_facility FROM game.correctional_facilities WHERE facility_ref=p->>'facility_ref' AND status='active' FOR UPDATE;
  IF v_person.id IS NULL OR v_facility.id IS NULL THEN RETURN jsonb_build_object('ok',false,'code','person_or_facility_not_found'); END IF;
  IF EXISTS(SELECT 1 FROM game.prisoner_admissions WHERE person_id=v_person.id AND status IN ('active','escaped')) THEN RETURN jsonb_build_object('ok',false,'code','active_admission_exists'); END IF;
  SELECT count(*) INTO v_count FROM game.prisoner_admissions WHERE facility_id=v_facility.id AND status IN ('active','escaped');
  IF v_count>=v_facility.capacity THEN RETURN jsonb_build_object('ok',false,'code','facility_capacity_reached'); END IF;
  IF p->>'admission_type'='sentenced' THEN
   SELECT * INTO v_sentence FROM game.trial_sentences WHERE sentence_ref=p->>'sentence_ref';
   IF v_sentence.id IS NULL OR v_sentence.sentence_type<>'custodial' OR v_sentence.duration_days<1 THEN RETURN jsonb_build_object('ok',false,'code','custodial_sentence_required'); END IF;
   IF NOT EXISTS(SELECT 1 FROM game.trial_verdicts tv JOIN game.formal_charges fc ON fc.id=tv.charge_id WHERE tv.id=v_sentence.verdict_id AND tv.verdict='guilty' AND fc.person_id=v_person.id AND fc.status='filed') THEN RETURN jsonb_build_object('ok',false,'code','sentence_person_or_verdict_mismatch'); END IF;
  ELSIF nullif(p->>'sentence_ref','') IS NOT NULL THEN
   RETURN jsonb_build_object('ok',false,'code','sentence_only_for_sentenced_admission');
  END IF;
  IF nullif(p->>'court_case_ref','') IS NOT NULL THEN
   SELECT id INTO v_case_id FROM game.court_cases WHERE court_case_ref=p->>'court_case_ref' AND status='active';
   IF v_case_id IS NULL THEN RETURN jsonb_build_object('ok',false,'code','court_case_not_found'); END IF;
  ELSIF p->>'admission_type'='sentenced' THEN
   SELECT ch.court_case_id INTO v_case_id FROM game.trial_sentences ts JOIN game.court_hearings h ON h.id=ts.hearing_id JOIN game.court_cases ch ON ch.id=h.court_case_id WHERE ts.id=v_sentence.id;
  END IF;
  INSERT INTO game.prisoner_admissions(person_id,facility_id,admitted_at_game_time,admission_type,source_court_case_id,receiving_officer_id,admission_notes,source_command_id)
  VALUES(v_person.id,v_facility.id,n,p->>'admission_type',v_case_id,NULL,p->>'notes',p_command_id) RETURNING * INTO v_admission;
  INSERT INTO game.correctional_events(admission_id,event_type,event_at_game_time,actor_person_id,details,source_command_id)
  VALUES(v_admission.id,'admitted',n,v_person_id,jsonb_build_object('admission_type',p->>'admission_type','facility_ref',v_facility.facility_ref,'notes',p->>'notes'),p_command_id);
  IF p->>'admission_type'='sentenced' THEN
   INSERT INTO game.prisoner_sentence_terms(admission_id,sentence_id,sequence_number,commencement_mode,commenced_at_game_time,original_duration_days,notes,source_command_id)
   VALUES(v_admission.id,v_sentence.id,1,'first',n,v_sentence.duration_days,'Initial custodial sentence: '||p->>'notes',p_command_id);
  END IF;
  RETURN jsonb_build_object('ok',true,'admission_ref',v_admission.admission_ref,'person_ref',v_person.person_ref,'facility_ref',v_facility.facility_ref,'status',v_admission.status);
 ELSIF p_type='correctional_add_sentence' THEN
  SELECT * INTO v_admission FROM game.prisoner_admissions WHERE admission_ref=p->>'admission_ref' AND status='active' FOR UPDATE;
  SELECT * INTO v_sentence FROM game.trial_sentences WHERE sentence_ref=p->>'sentence_ref';
  IF v_admission.id IS NULL OR v_sentence.id IS NULL THEN RETURN jsonb_build_object('ok',false,'code','admission_or_sentence_not_found'); END IF;
  IF v_sentence.sentence_type<>'custodial' OR v_sentence.duration_days<1 THEN RETURN jsonb_build_object('ok',false,'code','custodial_sentence_required'); END IF;
  IF NOT EXISTS(SELECT 1 FROM game.trial_verdicts tv JOIN game.formal_charges fc ON fc.id=tv.charge_id WHERE tv.id=v_sentence.verdict_id AND tv.verdict='guilty' AND fc.person_id=v_admission.person_id AND fc.status='filed') THEN RETURN jsonb_build_object('ok',false,'code','sentence_person_or_verdict_mismatch'); END IF;
  SELECT count(*) INTO v_count FROM game.prisoner_sentence_terms WHERE admission_id=v_admission.id;
  IF (p->>'sequence_number')::integer<>v_count+1 THEN RETURN jsonb_build_object('ok',false,'code','sentence_sequence_mismatch','expected_sequence',v_count+1); END IF;
  IF (p->>'commencement_mode')='first' AND v_count>0 OR (p->>'commencement_mode') IN ('concurrent','consecutive') AND v_count=0 THEN RETURN jsonb_build_object('ok',false,'code','sentence_commencement_mode_invalid'); END IF;
  INSERT INTO game.prisoner_sentence_terms(admission_id,sentence_id,sequence_number,commencement_mode,commenced_at_game_time,original_duration_days,notes,source_command_id)
  VALUES(v_admission.id,v_sentence.id,(p->>'sequence_number')::integer,p->>'commencement_mode',n,v_sentence.duration_days,p->>'notes',p_command_id) RETURNING * INTO v_term;
  INSERT INTO game.correctional_events(admission_id,event_type,event_at_game_time,actor_person_id,details,source_command_id)
  VALUES(v_admission.id,'review',n,v_person_id,jsonb_build_object('action','sentence_added','term_ref',v_term.term_ref,'sentence_ref',v_sentence.sentence_ref,'mode',v_term.commencement_mode),p_command_id);
  RETURN jsonb_build_object('ok',true,'term_ref',v_term.term_ref,'sentence_ref',v_sentence.sentence_ref,'sequence_number',v_term.sequence_number,'mode',v_term.commencement_mode,'duration_days',v_term.original_duration_days);
 ELSIF p_type='correctional_place_prisoner' THEN
  SELECT * INTO v_admission FROM game.prisoner_admissions WHERE admission_ref=p->>'admission_ref' AND status='active' FOR UPDATE;
  SELECT * INTO v_facility FROM game.correctional_facilities WHERE facility_ref=p->>'facility_ref' AND status='active' FOR UPDATE;
  IF v_admission.id IS NULL OR v_facility.id IS NULL THEN RETURN jsonb_build_object('ok',false,'code','admission_or_facility_not_found'); END IF;
  IF v_admission.facility_id<>v_facility.id THEN RETURN jsonb_build_object('ok',false,'code','placement_facility_mismatch'); END IF;
  IF nullif(btrim(p->>'unit_name'),'') IS NULL OR nullif(btrim(p->>'cell'),'') IS NULL THEN RETURN jsonb_build_object('ok',false,'code','placement_details_required'); END IF;
  IF EXISTS(SELECT 1 FROM game.prisoner_placements WHERE facility_id=v_facility.id AND unit_name=p->>'unit_name' AND cell_or_room=p->>'cell' AND ended_at_game_time IS NULL) THEN RETURN jsonb_build_object('ok',false,'code','cell_already_occupied'); END IF;
  UPDATE game.prisoner_placements SET ended_at_game_time=n WHERE admission_id=v_admission.id AND ended_at_game_time IS NULL;
  INSERT INTO game.prisoner_placements(admission_id,facility_id,unit_name,cell_or_room,placed_at_game_time,placement_reason,source_command_id)
  VALUES(v_admission.id,v_facility.id,p->>'unit_name',p->>'cell',n,p->>'reason',p_command_id);
  INSERT INTO game.correctional_events(admission_id,event_type,event_at_game_time,actor_person_id,details,source_command_id)
  VALUES(v_admission.id,'placed',n,v_person_id,jsonb_build_object('facility_ref',v_facility.facility_ref,'unit',p->>'unit_name','cell',p->>'cell','reason',p->>'reason'),p_command_id);
  RETURN jsonb_build_object('ok',true,'admission_ref',v_admission.admission_ref,'facility_ref',v_facility.facility_ref,'unit',p->>'unit_name','cell',p->>'cell');
 ELSIF p_type='correctional_get_record' THEN
  IF NOT EXISTS(SELECT 1 FROM game.police_personnel WHERE id=p_actor_id AND employment_status IN ('active','seconded')) THEN RETURN jsonb_build_object('ok',false,'code','actor_mismatch'); END IF;
  RETURN coalesce(game.get_correctional_record(p->>'admission_ref'),jsonb_build_object('ok',false,'code','admission_not_found'));
 ELSIF p_type='correctional_list_facilities' THEN
  RETURN jsonb_build_object('ok',true,'facilities',(SELECT coalesce(jsonb_agg(jsonb_build_object('facility_ref',f.facility_ref,'name',f.facility_name,'type',f.facility_type,'capacity',f.capacity,'occupied',(SELECT count(*) FROM game.prisoner_admissions a WHERE a.facility_id=f.id AND a.status IN ('active','escaped')),'status',f.status,'location',f.location_description) ORDER BY f.facility_name),'[]'::jsonb) FROM game.correctional_facilities f));
 END IF;
 RETURN jsonb_build_object('ok',false,'code','unsupported_command');
END;
$$;

CREATE OR REPLACE FUNCTION game.interpret_text_command(p_command_text text)
RETURNS jsonb LANGUAGE plpgsql IMMUTABLE SET search_path TO 'pg_catalog','game'
AS $$
DECLARE r jsonb;
BEGIN
 r:=game.interpret_correctional_command(p_command_text);
 IF r IS NOT NULL THEN RETURN r; END IF;
 RETURN game.interpret_text_command_before_correctional(p_command_text);
END;
$$;

CREATE OR REPLACE FUNCTION game.execute_text_command(
 p_command_text text,p_idempotency_key text,p_session_id uuid DEFAULT NULL,p_actor_personnel_id uuid DEFAULT NULL
) RETURNS jsonb LANGUAGE plpgsql SET search_path TO 'pg_catalog','game'
AS $$
DECLARE i jsonb; typ text; d jsonb; cmd game.game_commands%rowtype; res jsonb; actor game.police_personnel%rowtype;
BEGIN
 i:=game.interpret_text_command(p_command_text); typ:=i->>'command_type'; d:=coalesce(i->'payload','{}'::jsonb);
 IF typ='help' THEN
  res:=game.execute_text_command_before_correctional(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
  RETURN jsonb_set(res,'{available_commands}',(SELECT coalesce(jsonb_agg(DISTINCT x),'[]'::jsonb) FROM jsonb_array_elements_text(coalesce(res->'available_commands','[]'::jsonb)||jsonb_build_array('correctional_create_facility','correctional_admit','correctional_add_sentence','correctional_place_prisoner','correctional_get_record','correctional_list_facilities')) x),true);
 END IF;
 IF typ NOT IN ('correctional_create_facility','correctional_admit','correctional_add_sentence','correctional_place_prisoner','correctional_get_record','correctional_list_facilities') THEN
  RETURN game.execute_text_command_before_correctional(p_command_text,p_idempotency_key,p_session_id,p_actor_personnel_id);
 END IF;
 IF p_idempotency_key IS NULL OR char_length(p_idempotency_key) NOT BETWEEN 8 AND 200 THEN RAISE EXCEPTION 'A unique idempotency key is required'; END IF;
 INSERT INTO game.game_commands(idempotency_key,session_id,actor_personnel_id,command_text,command_type,payload)
 VALUES(p_idempotency_key,p_session_id,p_actor_personnel_id,p_command_text,typ,d) ON CONFLICT(idempotency_key) DO NOTHING;
 IF NOT FOUND THEN
  SELECT * INTO cmd FROM game.game_commands WHERE idempotency_key=p_idempotency_key FOR UPDATE;
  IF cmd.command_text<>p_command_text OR cmd.command_type<>typ OR cmd.payload<>d THEN RETURN jsonb_build_object('ok',false,'code','idempotency_conflict'); END IF;
  RETURN coalesce(cmd.result,jsonb_build_object('ok',cmd.status='completed'))||jsonb_build_object('duplicate',true);
 END IF;
 SELECT * INTO cmd FROM game.game_commands WHERE idempotency_key=p_idempotency_key FOR UPDATE;
 SELECT * INTO actor FROM game.police_personnel WHERE personnel_ref=d->>'actor_ref' AND employment_status IN ('active','seconded');
 IF actor.id IS NULL OR (p_actor_personnel_id IS NOT NULL AND p_actor_personnel_id<>actor.id) THEN
  res:=jsonb_build_object('ok',false,'code','actor_mismatch');
 ELSE
  res:=game.execute_correctional_command(cmd.id,typ,d,actor.id);
 END IF;
 IF coalesce((res->>'ok')::boolean,false) THEN
  res:=res||jsonb_build_object('status','completed','command_id',cmd.id);
  UPDATE game.game_commands SET status='completed',result=res,completed_at=now() WHERE id=cmd.id;
 ELSE
  UPDATE game.game_commands SET status='rejected',result=res,rejection_reason=coalesce(res->>'message','Correctional command rejected'),completed_at=now() WHERE id=cmd.id;
  res:=res||jsonb_build_object('command_id',cmd.id);
 END IF;
 RETURN res;
END;
$$;
