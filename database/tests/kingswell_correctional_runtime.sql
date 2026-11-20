-- Rollback-only correctional parser/runtime regression.
BEGIN;
DO $$
DECLARE r jsonb;
BEGIN
 r:=game.interpret_text_command('prison facility create by KW-TEST name "Test Facility" type remand capacity 10 location "Test Sector"');
 IF r->>'command_type'<>'correctional_create_facility' THEN RAISE EXCEPTION 'Facility parser failed: %',r; END IF;
 r:=game.interpret_text_command('prison admit person KWPERS-0001 to KWCF-000001 by KW-TEST type remand notes "Test admission" court_case KWCC-000001');
 IF r->>'command_type'<>'correctional_admit' THEN RAISE EXCEPTION 'Admission parser failed: %',r; END IF;
 r:=game.interpret_text_command('prison sentence add KWPA-0000001 sentence KWSENT-000001 sequence 1 mode first by KW-TEST notes "Test sentence"');
 IF r->>'command_type'<>'correctional_add_sentence' THEN RAISE EXCEPTION 'Sentence parser failed: %',r; END IF;
 r:=game.interpret_text_command('prison place KWPA-0000001 facility KWCF-000001 unit "A Wing" cell "A-01" by KW-TEST reason "Test placement"');
 IF r->>'command_type'<>'correctional_place_prisoner' THEN RAISE EXCEPTION 'Placement parser failed: %',r; END IF;
 r:=game.interpret_text_command('prison record KWPA-0000001 by KW-TEST');
 IF r->>'command_type'<>'correctional_get_record' THEN RAISE EXCEPTION 'Record parser failed: %',r; END IF;
 r:=game.interpret_text_command('prison facilities by KW-TEST');
 IF r->>'command_type'<>'correctional_list_facilities' THEN RAISE EXCEPTION 'Facility list parser failed: %',r; END IF;
 r:=game.interpret_text_command('court verdict record KWC-000001 at KWH-000001 by KWO-000001 as guilty because "Test existing parser"');
 IF r->>'command_type'<>'record_trial_verdict' THEN RAISE EXCEPTION 'Existing court parser regression: %',r; END IF;
 r:=game.execute_text_command('prison facilities by KW-TEST','test-correctional-runtime-0001',NULL,NULL);
 IF r->>'code'<>'actor_mismatch' THEN RAISE EXCEPTION 'Runtime dispatch failed: %',r; END IF;
END $$;
ROLLBACK;
