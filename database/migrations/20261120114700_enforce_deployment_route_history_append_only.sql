revoke update,delete on table game.deployment_route_history from public,anon,authenticated,service_role;
grant select,insert on table game.deployment_route_history to service_role;