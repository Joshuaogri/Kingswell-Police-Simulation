revoke all on function game.interpret_text_command(text) from public,anon,authenticated;
grant execute on function game.interpret_text_command(text) to service_role;
revoke all on function game.interpret_text_command_base(text) from public,anon,authenticated;
grant execute on function game.interpret_text_command_base(text) to service_role;
revoke all on function game.get_patrol_coverage() from public,anon,authenticated;
grant execute on function game.get_patrol_coverage() to service_role;
