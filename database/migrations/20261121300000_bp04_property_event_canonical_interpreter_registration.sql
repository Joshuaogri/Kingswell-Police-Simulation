-- BP-04: register property/building/unit event syntax in the canonical text interpreter.
-- The dedicated property parser already owns this grammar; this wrapper makes
-- the syntax visible to the general parser and all runtime command entry points
-- without duplicating its grammar or changing existing command behaviour.

alter function game.interpret_text_command(text)
 rename to interpret_text_command_before_bp04_property_events;

create or replace function game.interpret_text_command(p_command_text text)
returns jsonb
language plpgsql
immutable
set search_path to 'pg_catalog','game'
as $function$
declare
 v_property_command jsonb;
begin
 v_property_command:=game.interpret_property_command(p_command_text);
 if v_property_command->>'command_type' is not null then
  return v_property_command;
 end if;
 return game.interpret_text_command_before_bp04_property_events(p_command_text);
end;
$function$;

revoke all on function game.interpret_text_command(text)
 from public,anon,authenticated;
grant execute on function game.interpret_text_command(text) to service_role;
