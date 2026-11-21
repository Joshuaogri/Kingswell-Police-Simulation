do $$
declare d text;
begin
 select pg_get_functiondef('game.submit_command(text,text,jsonb,text,uuid,uuid)'::regprocedure) into d;
 d:=replace(d,$old$'cancel_scene_examination'),'note','Domain actions will be registered as their owning game systems are implemented.'$old$,
 $new$'cancel_scene_examination','record_scene_contamination','recover_scene_evidence','transfer_scene_evidence'),'note','Scene contamination, evidence recovery and custody transfer commands are available.'$new$);
 execute d;
end $$;
