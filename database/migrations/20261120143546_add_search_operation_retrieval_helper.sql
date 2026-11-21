create or replace function game.get_search_operations(p_case_id uuid) returns jsonb language sql stable set search_path=pg_catalog,game as $$
select jsonb_build_object('ok',true,'case_ref',c.case_ref,
'warrants',(select coalesce(jsonb_agg(jsonb_build_object('warrant_ref',sw.warrant_ref,'authority',sw.issuing_authority,'scope',sw.scope_description,'issued_at',sw.issued_at_game_time,'valid_until',sw.valid_until_game_time,'status',sw.status) order by sw.issued_at_game_time),'[]'::jsonb) from game.search_warrants sw where sw.case_id=c.id),
'operations',(select coalesce(jsonb_agg(jsonb_build_object('operation_ref',so.operation_ref,'warrant_ref',sw.warrant_ref,'method',so.method,'objective',so.objective,'status',so.status,
'team',(select coalesce(jsonb_agg(jsonb_build_object('personnel_ref',p.personnel_ref,'role',tm.team_role) order by tm.created_at),'[]'::jsonb) from game.search_operation_team tm join game.police_personnel p on p.id=tm.personnel_id where tm.operation_id=so.id),
'premises',(select coalesce(jsonb_agg(jsonb_build_object('premises_ref',sp.premises_ref,'property_ref',pr.property_ref,'description',sp.premises_description,'status',sp.status,
'logs',(select coalesce(jsonb_agg(jsonb_build_object('log_ref',sl.log_ref,'type',sl.event_type,'location',sl.location_within_premises,'narrative',sl.narrative,'at',sl.recorded_at_game_time) order by sl.recorded_at_game_time),'[]'::jsonb) from game.search_logs sl where sl.premises_id=sp.id),
'recovered_property',(select coalesce(jsonb_agg(jsonb_build_object('recovery_ref',rp.recovery_ref,'description',rp.item_description,'category',rp.item_category,'disposition',rp.disposition,'seizure_ref',ss.seizure_ref,'evidence_ref',ei.evidence_ref) order by rp.recovered_at_game_time),'[]'::jsonb) from game.recovered_property rp left join game.search_seizures ss on ss.recovery_id=rp.id left join game.evidence_items ei on ei.id=ss.evidence_id where rp.premises_id=sp.id)
) order by sp.created_at),'[]'::jsonb) from game.search_premises sp join game.properties pr on pr.id=sp.property_id where sp.operation_id=so.id),
'events',(select coalesce(jsonb_agg(jsonb_build_object('type',ev.event_type,'at',ev.event_at_game_time,'actor',p.personnel_ref,'data',ev.event_data) order by ev.event_at_game_time,ev.created_at),'[]'::jsonb) from game.search_operation_events ev join game.police_personnel p on p.id=ev.actor_personnel_id where ev.operation_id=so.id)
) order by so.created_at_game_time),'[]'::jsonb) from game.search_operations so join game.search_warrants sw on sw.id=so.warrant_id where so.case_id=c.id))
from game.cases c where c.id=p_case_id
$$;
do $$
declare d text;s int;e int;
begin
 select pg_get_functiondef('game.execute_search_command(uuid,text,jsonb,uuid)'::regprocedure) into d;
 s:=strpos(d,'return jsonb_build_object(''ok'',true,''case_ref'',c.case_ref,''warrants'',');
 e:=case when s=0 then 0 else s+strpos(substr(d,s),'end if;return jsonb_build_object(''ok'',false,''code'',''unsupported_search_command'')')-1 end;
 if s=0 or e<s then raise exception 'Could not locate search retrieval block (%,%)',s,e;end if;
 d:=substr(d,1,s-1)||'return game.get_search_operations(c.id);'||substr(d,e);
 execute d;
end $$;
revoke all on function game.get_search_operations(uuid) from public,anon,authenticated;
grant execute on function game.get_search_operations(uuid) to service_role;
