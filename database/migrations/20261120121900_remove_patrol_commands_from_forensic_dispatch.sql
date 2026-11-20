-- Keep patrol command types out of the forensic-action dispatch branch.
-- They remain registered in the help command list and have dedicated runtime branches.
do $patch$
declare def text; old_forensic text; new_forensic text;
begin
 def:=pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure);
 old_forensic:=$old$'review_forensic_findings','issue_forensic_report','assign_patrol_beat','schedule_patrol','start_patrol','end_patrol','patrol_coverage','patrol_move') then$old$;
 new_forensic:=$new$'review_forensic_findings','issue_forensic_report') then$new$;
 if position(old_forensic in def)=0 then
  if position(new_forensic in def)>0 then return; end if;
  raise exception 'Could not locate forensic action list';
 end if;
 execute replace(def,old_forensic,new_forensic);
end;$patch$;