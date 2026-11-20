-- Patrol intelligence review player-command regression. Fixtures and command ledger writes roll back.
begin;
do $test$
declare p jsonb; h jsonb; r jsonb; d jsonb;
begin
 p:=game.interpret_text_command('review patrol intelligence KNG-LINK-TEST disposition further_enquiries because Compare timing with other reports');
 if p->>'command_type'<>'review_patrol_intelligence' or p#>>'{payload,disposition}'<>'further_enquiries' then raise exception 'Review parser failed: %',p; end if;
 p:=game.interpret_text_command('patrol intelligence reviews for KNG-LINK-TEST');
 if p->>'command_type'<>'patrol_intelligence_reviews' then raise exception 'Review-history parser failed: %',p; end if;
 h:=game.execute_text_command('patrol intelligence reviews','kng-review-test-0001',null,null);
 if h->>'ok'<>'true' or h->>'status'<>'completed' then raise exception 'Review history command failed: %',h; end if;
 r:=game.execute_text_command('review patrol intelligence KNG-LINK-TEST disposition relevant because Test review','kng-review-test-0002',null,null);
 if r->>'code'<>'missing_attribution' then raise exception 'Missing actor guard failed: %',r; end if;
 d:=game.execute_text_command('review patrol intelligence KNG-LINK-TEST disposition relevant because Test review','kng-review-test-0002',null,null);
 if d->>'duplicate'<>'true' then raise exception 'Idempotency replay failed: %',d; end if;
 h:=game.execute_text_command('help','kng-review-test-help-0001',null,null);
 if not ((h->'available_commands') ? 'review_patrol_intelligence') or not ((h->'available_commands') ? 'patrol_intelligence_reviews') then raise exception 'Help registration failed: %',h; end if;
 if (select count(*) from game.patrol_intelligence_reviews)<>0 then raise exception 'Unexpected review rows'; end if;
end;
$test$;
rollback;
