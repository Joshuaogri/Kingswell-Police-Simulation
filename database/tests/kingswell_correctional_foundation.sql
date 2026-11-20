-- Rollback-only schema regression for the correctional foundation.
BEGIN;
DO $$
DECLARE v_count integer;
BEGIN
 SELECT count(*) INTO v_count FROM information_schema.tables WHERE table_schema='game'
 AND table_name IN ('correctional_facilities','prisoner_admissions','prisoner_sentence_terms','sentence_credit_events','correctional_events','prisoner_placements');
 IF v_count <> 6 THEN RAISE EXCEPTION 'Expected 6 correctional tables, found %',v_count; END IF;
 SELECT count(*) INTO v_count FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
 WHERE n.nspname='game' AND c.relname IN ('correctional_facilities','prisoner_admissions','prisoner_sentence_terms','sentence_credit_events','correctional_events','prisoner_placements') AND c.relrowsecurity;
 IF v_count <> 6 THEN RAISE EXCEPTION 'RLS missing from one or more correctional tables'; END IF;
 SELECT count(*) INTO v_count FROM pg_trigger
 WHERE tgname IN ('sentence_credit_events_append_only','correctional_events_append_only') AND NOT tgisinternal;
 IF v_count <> 2 THEN RAISE EXCEPTION 'Append-only triggers missing'; END IF;
 IF to_regprocedure('game.get_correctional_record(text)') IS NULL THEN RAISE EXCEPTION 'Correctional record projection missing'; END IF;
END $$;
ROLLBACK;
