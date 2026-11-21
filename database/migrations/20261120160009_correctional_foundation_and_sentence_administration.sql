
CREATE SEQUENCE IF NOT EXISTS game.correctional_facility_ref_seq START 1;
CREATE SEQUENCE IF NOT EXISTS game.prisoner_admission_ref_seq START 1;
CREATE SEQUENCE IF NOT EXISTS game.sentence_term_ref_seq START 1;

CREATE TABLE game.correctional_facilities (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 facility_ref text NOT NULL UNIQUE DEFAULT ('KWCF-' || lpad(nextval('game.correctional_facility_ref_seq')::text,6,'0')),
 facility_name text NOT NULL,
 facility_type text NOT NULL CHECK (facility_type IN ('remand','prison','open_prison','youth_custody','mixed')),
 capacity integer NOT NULL CHECK (capacity > 0),
 location_description text NOT NULL,
 status text NOT NULL DEFAULT 'active' CHECK (status IN ('active','restricted','closed')),
 created_at timestamptz NOT NULL DEFAULT now(),
 updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE game.prisoner_admissions (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 admission_ref text NOT NULL UNIQUE DEFAULT ('KWPA-' || lpad(nextval('game.prisoner_admission_ref_seq')::text,7,'0')),
 person_id uuid NOT NULL REFERENCES game.persons(id),
 facility_id uuid NOT NULL REFERENCES game.correctional_facilities(id),
 admitted_at_game_time timestamptz NOT NULL,
 admission_type text NOT NULL CHECK (admission_type IN ('remand','sentenced','transfer_in')),
 source_court_case_id uuid REFERENCES game.court_cases(id),
 receiving_officer_id uuid REFERENCES game.court_official_profiles(id),
 admission_notes text NOT NULL,
 status text NOT NULL DEFAULT 'active' CHECK (status IN ('active','transferred','released','escaped','deceased')),
 released_at_game_time timestamptz,
 release_reason text,
 source_command_id uuid NOT NULL REFERENCES game.game_commands(id),
 created_at timestamptz NOT NULL DEFAULT now(),
 CHECK ((status IN ('active','escaped') AND released_at_game_time IS NULL) OR (status IN ('transferred','released','deceased') AND released_at_game_time IS NOT NULL))
);
CREATE UNIQUE INDEX prisoner_one_active_admission_per_person
 ON game.prisoner_admissions(person_id) WHERE status IN ('active','escaped');

CREATE TABLE game.prisoner_sentence_terms (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 term_ref text NOT NULL UNIQUE DEFAULT ('KWST-' || lpad(nextval('game.sentence_term_ref_seq')::text,7,'0')),
 admission_id uuid NOT NULL REFERENCES game.prisoner_admissions(id),
 sentence_id uuid NOT NULL UNIQUE REFERENCES game.trial_sentences(id),
 sequence_number integer NOT NULL CHECK (sequence_number > 0),
 commencement_mode text NOT NULL CHECK (commencement_mode IN ('first','concurrent','consecutive')),
 commenced_at_game_time timestamptz NOT NULL,
 original_duration_days integer NOT NULL CHECK (original_duration_days > 0),
 status text NOT NULL DEFAULT 'active' CHECK (status IN ('active','completed','varied','quashed')),
 notes text NOT NULL,
 source_command_id uuid NOT NULL REFERENCES game.game_commands(id),
 created_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(admission_id, sequence_number)
);

CREATE TABLE game.sentence_credit_events (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 term_id uuid NOT NULL REFERENCES game.prisoner_sentence_terms(id),
 credit_days integer NOT NULL CHECK (credit_days > 0),
 credit_type text NOT NULL CHECK (credit_type IN ('pre_sentence_custody','appeal_credit','administrative_adjustment','other')),
 reason text NOT NULL,
 credited_at_game_time timestamptz NOT NULL,
 recorded_by_official_id uuid NOT NULL REFERENCES game.court_official_profiles(id),
 source_command_id uuid NOT NULL REFERENCES game.game_commands(id),
 created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE game.correctional_events (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 admission_id uuid NOT NULL REFERENCES game.prisoner_admissions(id),
 event_type text NOT NULL CHECK (event_type IN ('admitted','classified','placed','transferred','visit','communication','work_assignment','education','health_welfare','incident','discipline','review','release_approved','released','escape','returned')),
 event_at_game_time timestamptz NOT NULL,
 actor_person_id uuid REFERENCES game.persons(id),
 actor_official_id uuid REFERENCES game.court_official_profiles(id),
 details jsonb NOT NULL DEFAULT '{}'::jsonb,
 source_command_id uuid NOT NULL REFERENCES game.game_commands(id),
 created_at timestamptz NOT NULL DEFAULT now(),
 CHECK (actor_person_id IS NOT NULL OR actor_official_id IS NOT NULL)
);

CREATE TABLE game.prisoner_placements (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 admission_id uuid NOT NULL REFERENCES game.prisoner_admissions(id),
 facility_id uuid NOT NULL REFERENCES game.correctional_facilities(id),
 unit_name text NOT NULL,
 cell_or_room text NOT NULL,
 placed_at_game_time timestamptz NOT NULL,
 ended_at_game_time timestamptz,
 placement_reason text NOT NULL,
 source_command_id uuid NOT NULL REFERENCES game.game_commands(id),
 created_at timestamptz NOT NULL DEFAULT now(),
 CHECK (ended_at_game_time IS NULL OR ended_at_game_time >= placed_at_game_time)
);
CREATE UNIQUE INDEX prisoner_one_current_placement
 ON game.prisoner_placements(admission_id) WHERE ended_at_game_time IS NULL;

CREATE OR REPLACE FUNCTION game.reject_correctional_history_mutation()
RETURNS trigger LANGUAGE plpgsql SET search_path TO 'pg_catalog','game'
AS $$
BEGIN
 RAISE EXCEPTION 'Correctional history is append-only';
END;
$$;

CREATE TRIGGER sentence_credit_events_append_only
 BEFORE UPDATE OR DELETE ON game.sentence_credit_events
 FOR EACH ROW EXECUTE FUNCTION game.reject_correctional_history_mutation();
CREATE TRIGGER correctional_events_append_only
 BEFORE UPDATE OR DELETE ON game.correctional_events
 FOR EACH ROW EXECUTE FUNCTION game.reject_correctional_history_mutation();

ALTER TABLE game.correctional_facilities ENABLE ROW LEVEL SECURITY;
ALTER TABLE game.prisoner_admissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE game.prisoner_sentence_terms ENABLE ROW LEVEL SECURITY;
ALTER TABLE game.sentence_credit_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE game.correctional_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE game.prisoner_placements ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION game.get_correctional_record(p_admission_ref text)
RETURNS jsonb LANGUAGE sql STABLE SECURITY DEFINER SET search_path TO 'pg_catalog','game'
AS $$
 SELECT jsonb_build_object(
  'ok',true,
  'admission',to_jsonb(a)-'id'-'source_command_id',
  'person_ref',p.person_ref,
  'facility',jsonb_build_object('facility_ref',f.facility_ref,'name',f.facility_name,'type',f.facility_type,'location',f.location_description),
  'placements',(SELECT coalesce(jsonb_agg(to_jsonb(pl)-'id'-'source_command_id' ORDER BY pl.placed_at_game_time),'[]'::jsonb) FROM game.prisoner_placements pl WHERE pl.admission_id=a.id),
  'sentence_terms',(SELECT coalesce(jsonb_agg(jsonb_build_object(
    'term_ref',t.term_ref,'sentence_ref',s.sentence_ref,'sentence_type',s.sentence_type,
    'sequence_number',t.sequence_number,'commencement_mode',t.commencement_mode,
    'commenced_at',t.commenced_at_game_time,'original_duration_days',t.original_duration_days,
    'credit_days',(SELECT coalesce(sum(c.credit_days),0) FROM game.sentence_credit_events c WHERE c.term_id=t.id),
    'remaining_days',greatest(0,t.original_duration_days-(SELECT coalesce(sum(c.credit_days),0) FROM game.sentence_credit_events c WHERE c.term_id=t.id)),
    'status',t.status,'notes',t.notes
  ) ORDER BY t.sequence_number),'[]'::jsonb) FROM game.prisoner_sentence_terms t JOIN game.trial_sentences s ON s.id=t.sentence_id WHERE t.admission_id=a.id),
  'events',(SELECT coalesce(jsonb_agg(to_jsonb(e)-'id'-'source_command_id' ORDER BY e.event_at_game_time),'[]'::jsonb) FROM game.correctional_events e WHERE e.admission_id=a.id)
 )
 FROM game.prisoner_admissions a
 JOIN game.persons p ON p.id=a.person_id
 JOIN game.correctional_facilities f ON f.id=a.facility_id
 WHERE a.admission_ref=p_admission_ref
$$;
