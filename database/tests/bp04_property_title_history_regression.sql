-- BP-04 title history regression; transaction rollback removes the temporary immutability-test row.
begin;
do $$
declare v_property uuid; v_ref text; v_json jsonb; v_id uuid;
begin
 if (select count(*) from game.property_interest_records where interest_type='registered_owner' and valid_to is null)<>656
 then raise exception 'BP04: seeded registered title baseline changed'; end if;
 if (select count(*) from game.property_title_events)<>0
 then raise exception 'BP04: title history unexpectedly contains unverified events'; end if;
 if (select count(*) from game.property_asset_events)<>0
 then raise exception 'BP04: asset event baseline unexpectedly changed'; end if;
 if to_regprocedure('game.get_property_title_history(text)') is null
 or to_regprocedure('game.get_property_asset_history(text)') is null
 then raise exception 'BP04: property history query missing'; end if;
 if has_table_privilege('anon','game.property_title_events','select')
 or has_table_privilege('authenticated','game.property_title_events','select')
 then raise exception 'BP04: title event table exposed'; end if;
 select id,property_ref into v_property,v_ref from game.properties limit 1;
 v_json:=game.get_property_title_history(v_ref);
 if v_json is null or not(v_json?'property' and v_json?'current_registered_title'
 and v_json?'title_events' and v_json?'limitations')
 then raise exception 'BP04: title history query response incomplete'; end if;
 v_json:=game.get_property_asset_history(v_ref);
 if v_json is null or not(v_json?'property' and v_json?'asset_events' and v_json?'event_count')
 then raise exception 'BP04: asset history query response incomplete'; end if;
 insert into game.property_title_events(event_ref,property_id,event_type,registration_status,source_description)
 values('TEST-TITLE-EVENT-'||replace(gen_random_uuid()::text,'-',''),v_property,'other','unknown','Regression-only temporary event')
 returning id into v_id;
 begin
  update game.property_title_events set source_description='should fail' where id=v_id;
  raise exception 'BP04: title event update was not blocked';
 exception when others then
  if sqlerrm='BP04: title event update was not blocked' then raise; end if;
 end;
end $$;
rollback;
