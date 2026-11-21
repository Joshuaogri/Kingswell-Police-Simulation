do $$
declare d text;needle text;replacement text;
begin
 select pg_get_functiondef('game.get_case_review_dossier(text)'::regprocedure) into d;
 needle:='''surveillance_operations'',game.get_surveillance_operations(v_case.case_ref,100)->''operations'',';
 replacement:=needle||E'\n  '||'''search_operations'',game.get_search_operations(v_case.id)->''operations'',';
 if position(needle in d)=0 then raise exception 'Could not locate surveillance dossier field';end if;
 d:=replace(d,needle,replacement);
 execute d;
end $$;
