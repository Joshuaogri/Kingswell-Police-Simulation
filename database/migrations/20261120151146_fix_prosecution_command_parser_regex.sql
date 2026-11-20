create or replace function game.interpret_prosecution_command(p_command_text text)
returns jsonb language plpgsql immutable set search_path='pg_catalog','game' as $$
declare m text[];
begin
 m:=regexp_match(p_command_text,'^prosecution refer ([A-Za-z0-9_-]+) arrest ([A-Za-z0-9_-]+) by ([A-Za-z0-9_-]+) summary "([^"]+)" charges "([^"]+)" evidence "([^"]+)"$','i');
 if m is not null then return jsonb_build_object('command_type','submit_prosecution_referral','payload',jsonb_build_object('case_ref',m[1],'arrest_ref',m[2],'actor_ref',m[3],'summary',m[4],'charges',m[5],'evidence',m[6]));end if;
 m:=regexp_match(p_command_text,'^prosecution decision ([A-Za-z0-9_-]+) set (accepted|returned|declined) by ([A-Za-z0-9_-]+) because "([^"]+)"$','i');
 if m is not null then return jsonb_build_object('command_type','decide_prosecution_referral','payload',jsonb_build_object('referral_ref',m[1],'decision',lower(m[2]),'actor_ref',m[3],'reason',m[4]));end if;
 m:=regexp_match(p_command_text,'^prosecution referrals ([A-Za-z0-9_-]+) by ([A-Za-z0-9_-]+)$','i');
 if m is not null then return jsonb_build_object('command_type','get_prosecution_referrals','payload',jsonb_build_object('case_ref',m[1],'actor_ref',m[2]));end if;
 return null;
end $$;