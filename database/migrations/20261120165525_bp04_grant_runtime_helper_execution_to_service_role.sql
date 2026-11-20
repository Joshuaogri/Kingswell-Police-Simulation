grant execute on function game.interpret_property_command(text) to service_role;
grant execute on function game.execute_property_command(uuid,text,jsonb,uuid) to service_role;
grant execute on function game.get_business_record(text) to service_role;
grant execute on function game.interpret_text_command_before_property(text) to service_role;
grant execute on function game.execute_text_command_before_property(text,text,uuid,uuid) to service_role;
