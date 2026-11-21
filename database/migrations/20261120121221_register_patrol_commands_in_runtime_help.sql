do $patch$
declare def text; old text; new text;
begin
 def:=pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure);
 old:=$old$'review_forensic_findings','issue_forensic_report')$old$;
 new:=$new$'review_forensic_findings','issue_forensic_report','assign_patrol_beat','schedule_patrol','start_patrol','end_patrol','patrol_coverage','patrol_move')$new$;
 if position(old in def)=0 then raise exception 'Could not locate help command list'; end if;
 execute replace(def,old,new);
end;$patch$;