do $$
declare v_def text;v_old text;v_new text;
begin
 v_old:=','||chr(10)||'  ''forensic_requests'',(select coalesce(jsonb_agg(jsonb_build_object(''request_ref'',fr.request_ref)';
 v_new:=','||chr(10)||'  ''activities'',game.get_case_activity(v_case.case_ref,500)->''activities'','||chr(10)||'  ''forensic_requests'',(select coalesce(jsonb_agg(jsonb_build_object(''request_ref'',fr.request_ref)';
 select pg_get_functiondef('game.get_case_review_dossier(text)'::regprocedure) into v_def;
 if position(v_old in v_def)=0 then raise exception 'Dossier top-level forensic section anchor not found';end if;
 execute replace(v_def,v_old,v_new);
end $$;