-- BP-04 scene/search premises must never substitute wall-clock time for game time.
begin;
do $test$
declare v_def text;
begin
 v_def:=pg_get_functiondef('game.record_scene_premises(text,text,text,text,text,text,uuid)'::regprocedure);
 if position('clock_not_initialized' in v_def)=0 then
  raise exception 'Scene premises command does not enforce the initialized simulation clock';
 end if;
 v_def:=pg_get_functiondef('game.record_search_premises_location(text,text,text,text,text,uuid)'::regprocedure);
 if position('clock_not_initialized' in v_def)=0 then
  raise exception 'Search premises command does not enforce the initialized simulation clock';
 end if;
end;
$test$;
rollback;
