-- Patrol intelligence review-history smoke regression. All test work is rolled back.
begin;
do $test$
declare v jsonb; v_lookup jsonb; v_rls boolean; v_trigger_count integer;
begin
 v:=game.record_patrol_intelligence_review(null,'MISSING','relevant','Test',null);
 if v->>'code'<>'missing_attribution' then raise exception 'Missing attribution was not rejected: %',v; end if;
 v_lookup:=game.get_patrol_intelligence_reviews(null,100);
 if v_lookup->>'ok'<>'true' or jsonb_typeof(v_lookup->'reviews')<>'array' then raise exception 'Review lookup failed: %',v_lookup; end if;
 select c.relrowsecurity into v_rls from pg_class c where c.oid='game.patrol_intelligence_reviews'::regclass;
 if not coalesce(v_rls,false) then raise exception 'Review table must have RLS enabled'; end if;
 select count(*) into v_trigger_count from pg_trigger where tgrelid='game.patrol_intelligence_reviews'::regclass and not tgisinternal and tgname='patrol_intelligence_reviews_append_only';
 if v_trigger_count<>1 then raise exception 'Append-only trigger missing'; end if;
 if exists(select 1 from game.patrol_intelligence_reviews) then raise exception 'Unexpected persistent review fixture rows'; end if;
end;
$test$;
rollback;
