-- Protect the five new operational record tables with RLS in the private game schema.
alter table game.incident_scenes enable row level security;
alter table game.scene_activity_logs enable row level security;
alter table game.scene_access_events enable row level security;
alter table game.incident_field_reports enable row level security;
alter table game.incident_resource_requests enable row level security;
