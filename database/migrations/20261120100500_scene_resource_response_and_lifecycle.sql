-- Resource-request response lifecycle and formal scene release/reopening.
alter table game.incident_resource_requests add column responded_by_personnel_id uuid references game.police_personnel(id);
alter table game.incident_resource_requests add column fulfilled_at timestamptz;
create table game.scene_resource_request_events(id uuid primary key default gen_random_uuid(),resource_request_id uuid not null references game.incident_resource_requests(id),event_at timestamptz not null,event_type text not null check(event_type in ('approved','declined','cancelled','fulfilled')),actor_personnel_id uuid not null references game.police_personnel(id),notes text not null,source_command_id uuid references game.game_commands(id),created_at timestamptz not null default now());
create table game.scene_lifecycle_events(id uuid primary key default gen_random_uuid(),scene_id uuid not null references game.incident_scenes(id),event_at timestamptz not null,event_type text not null check(event_type in ('released','reopened')),personnel_id uuid not null references game.police_personnel(id),reason text not null,source_command_id uuid references game.game_commands(id),created_at timestamptz not null default now());
alter table game.scene_resource_request_events enable row level security;
alter table game.scene_lifecycle_events enable row level security;
create index scene_resource_request_events_request_fk_idx on game.scene_resource_request_events(resource_request_id);
create index scene_resource_request_events_actor_fk_idx on game.scene_resource_request_events(actor_personnel_id);
create index scene_resource_request_events_command_fk_idx on game.scene_resource_request_events(source_command_id);
create index scene_lifecycle_events_scene_fk_idx on game.scene_lifecycle_events(scene_id);
create index scene_lifecycle_events_personnel_fk_idx on game.scene_lifecycle_events(personnel_id);
create index scene_lifecycle_events_command_fk_idx on game.scene_lifecycle_events(source_command_id);
