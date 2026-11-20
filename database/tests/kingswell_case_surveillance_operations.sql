begin;
do $$
declare v jsonb;
begin
 v:=game.interpret_text_command('surveillance plan create CASE-1 by OFF-1 method static_observation at "Northgate roofline" objective "Observe the loading bay during the stated period" subject "Unknown dark saloon vehicle and occupants"');
 if v->>'command_type'<>'create_surveillance_operation' or v#>>'{payload,case_ref}'<>'CASE-1' or v#>>'{payload,method}'<>'static_observation' then raise exception 'Plan parser failed: %',v;end if;
 v:=game.interpret_text_command('surveillance team add KWS-123 OFF-2 role observer by OFF-1');
 if v->>'command_type'<>'add_surveillance_team' then raise exception 'Team parser failed: %',v;end if;
 v:=game.interpret_text_command('surveillance deploy KWS-123 by OFF-1');
 if v->>'command_type'<>'start_surveillance_operation' then raise exception 'Deploy parser failed: %',v;end if;
 v:=game.interpret_text_command('surveillance log KWS-123 by OFF-2 type vehicle_movement at "Market Lane junction" details "Dark saloon travelled eastbound" subject "Unknown driver" movement "Eastbound, then turned south" vehicle "Dark four-door saloon"');
 if v->>'command_type'<>'record_surveillance_observation' or v#>>'{payload,entry_type}'<>'vehicle_movement' then raise exception 'Observation parser failed: %',v;end if;
 v:=game.interpret_text_command('surveillance link KWO-123 evidence EVD-1 by OFF-2 because "Image capture supports vehicle description"');
 if v->>'command_type'<>'link_surveillance_observation' then raise exception 'Link parser failed: %',v;end if;
 v:=game.interpret_text_command('surveillance close KWS-123 by OFF-1 because "Deployment concluded"');
 if v->>'command_type'<>'close_surveillance_operation' then raise exception 'Close parser failed: %',v;end if;
 v:=game.interpret_text_command('surveillance cancel KWS-123 by OFF-1 because "Plan no longer required"');
 if v->>'command_type'<>'cancel_surveillance_operation' then raise exception 'Cancel parser failed: %',v;end if;
 v:=game.interpret_text_command('surveillance operations CASE-1 by OFF-1');
 if v->>'command_type'<>'get_surveillance_operations' then raise exception 'List parser failed: %',v;end if;
 if not (select relrowsecurity from pg_class where oid='game.surveillance_operations'::regclass) or not (select relrowsecurity from pg_class where oid='game.surveillance_operation_team'::regclass) or not (select relrowsecurity from pg_class where oid='game.surveillance_observations'::regclass) or not (select relrowsecurity from pg_class where oid='game.surveillance_observation_links'::regclass) or not (select relrowsecurity from pg_class where oid='game.surveillance_operation_events'::regclass) then raise exception 'RLS missing';end if;
 if has_table_privilege('anon','game.surveillance_operations','select') or has_table_privilege('authenticated','game.surveillance_operations','select') then raise exception 'Public role access unexpectedly granted';end if;
 if not has_table_privilege('service_role','game.surveillance_operations','select') then raise exception 'Service role access missing';end if;
 if position('surveillance_operations' in pg_get_functiondef('game.get_case_review_dossier(text)'::regprocedure))=0 then raise exception 'Dossier integration missing';end if;
end $$;
select game.execute_text_command('help','kng-surveillance-help-0001',null,null);
rollback;
