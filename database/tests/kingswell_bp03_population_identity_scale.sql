-- BP-03 100,000 canonical-person identity scale regression.
-- Test-only fictional NPCs; the transaction is rolled back and the clock is untouched.
BEGIN;
SET LOCAL ROLE service_role;
INSERT INTO game.persons(person_ref,given_name,family_name,date_of_birth,nationality,person_status,birth_city_id,occupation,preferred_language,personality_profile,behaviour_profile)
SELECT 'KW-BP03-IDLOAD-'||lpad(g::text,6,'0'),
       (ARRAY['Ari','Mara','Jon','Iris','Noah','Talia','Eli','Nia'])[((g-1)%8)+1],
       (ARRAY['Aster','Bennett','Caldwell','Dawson','Ellery','Farrow','Givens','Hale'])[((g-1)%8)+1],
       date '1940-01-01'+((g*37)%27000),'Asterfell','active',
       (SELECT id FROM game.cities WHERE code='KNG'),'Resident','Asterian',
       jsonb_build_object('temperament',CASE WHEN g%2=0 THEN 'measured' ELSE 'outgoing' END),
       jsonb_build_object('profile_version',1)
FROM generate_series(1,100000) g;
DO $$
BEGIN
 IF (SELECT count(*) FROM game.persons WHERE person_ref LIKE 'KW-BP03-IDLOAD-%')<>100000
 OR (SELECT count(DISTINCT person_ref) FROM game.persons WHERE person_ref LIKE 'KW-BP03-IDLOAD-%')<>100000
 THEN RAISE EXCEPTION '100,000 canonical person identity scale regression failed'; END IF;
 IF (SELECT current_game_time FROM game.simulation_state WHERE id=1) IS NOT NULL
 THEN RAISE EXCEPTION 'Identity scale test changed fictional clock'; END IF;
END $$;
ROLLBACK;