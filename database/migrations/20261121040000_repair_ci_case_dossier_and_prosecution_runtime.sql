-- Repair the nine isolated gameplay regressions identified by CI.
-- This migration changes only schema/runtime performance and case command integration.

-- The BP-03 employee routine audit must use an indexed person/category lookup.
CREATE INDEX IF NOT EXISTS person_routines_person_category_status_day_idx
  ON game.person_routines(person_id,routine_category,routine_status,day_of_week);

-- Restore case dossier sections removed when the previous patch used a stale source anchor.
DO $migration$
DECLARE
  v_definition text;
  v_marker_position integer;
  v_insert text;
BEGIN
  SELECT pg_get_functiondef('game.get_case_review_dossier(text)'::regprocedure)
    INTO v_definition;

  IF position('''activities''' IN v_definition)=0 THEN
    v_marker_position:=strpos(v_definition,'''forensic_requests''');
    IF v_marker_position=0 THEN
      RAISE EXCEPTION 'Case dossier forensic section anchor not found';
    END IF;
    v_insert :=
      '  ''activities'',game.get_case_activity(v_case.case_ref,500)->''activities'',' || E'\n' ||
      '  ''surveillance_operations'',(SELECT coalesce(jsonb_agg(to_jsonb(so)-''id''-''case_id''-''source_command_id'' ORDER BY so.created_at),''[]''::jsonb) FROM game.surveillance_operations so WHERE so.case_id=v_case.id),' || E'\n' ||
      '  ';
    v_definition:=substring(v_definition from 1 for v_marker_position-1)
      ||v_insert||substring(v_definition from v_marker_position);
    EXECUTE v_definition;
  ELSE
    IF position('''surveillance_operations''' IN v_definition)=0 THEN
      RAISE EXCEPTION 'Case dossier has activity integration but lacks surveillance integration';
    END IF;
  END IF;
END
$migration$;

-- Preserve all three prosecution referral command forms in the active interpreter.
CREATE OR REPLACE FUNCTION game.interpret_prosecution_command(p_command_text text)
RETURNS jsonb
LANGUAGE plpgsql IMMUTABLE
SET search_path TO 'pg_catalog','game'
AS $function$
DECLARE m text[];
BEGIN
  m:=regexp_match(p_command_text,'^prosecution refer ([A-Za-z0-9_-]+) arrest ([A-Za-z0-9_-]+) by ([A-Za-z0-9_-]+) summary "([^"]{1,4000})" charges "([^"]{1,4000})" evidence "([^"]{1,8000})"$','i');
  IF m IS NOT NULL THEN
    RETURN jsonb_build_object('command_type','submit_prosecution_referral','payload',jsonb_build_object('case_ref',m[1],'arrest_ref',m[2],'actor_ref',m[3],'summary',m[4],'charges',m[5],'evidence',m[6]));
  END IF;

  m:=regexp_match(p_command_text,'^prosecution decision ([A-Za-z0-9_-]+) set (accepted|returned|declined) by ([A-Za-z0-9_-]+) because "([^"]{1,4000})"$','i');
  IF m IS NOT NULL THEN
    RETURN jsonb_build_object('command_type','decide_prosecution_referral','payload',jsonb_build_object('referral_ref',m[1],'decision',lower(m[2]),'actor_ref',m[3],'reason',m[4]));
  END IF;

  m:=regexp_match(p_command_text,'^prosecution referrals ([A-Za-z0-9_-]+) by ([A-Za-z0-9_-]+)$','i');
  IF m IS NOT NULL THEN
    RETURN jsonb_build_object('command_type','get_prosecution_referrals','payload',jsonb_build_object('case_ref',m[1],'actor_ref',m[2]));
  END IF;
  RETURN NULL;
END;
$function$;

REVOKE ALL ON FUNCTION game.interpret_prosecution_command(text) FROM PUBLIC,anon,authenticated;
GRANT EXECUTE ON FUNCTION game.interpret_prosecution_command(text) TO service_role;
