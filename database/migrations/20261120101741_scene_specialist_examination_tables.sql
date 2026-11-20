create table game.scene_specialist_attendances(
 id uuid primary key default gen_random_uuid(),attendance_ref text not null unique,
 scene_id uuid not null references game.incident_scenes(id),incident_id uuid not null references game.incidents(id),
 personnel_id uuid not null references game.police_personnel(id),deployment_id uuid not null references game.incident_deployments(id),
 unit_id uuid references game.police_units(id),qualification_id uuid not null references game.personnel_qualifications(id),
 discipline text not null,purpose text not null,attended_at timestamptz not null,departed_at timestamptz,
 departure_reason text,status text not null check(status in ('attending','departed')),
 source_command_id uuid references game.game_commands(id),created_at timestamptz not null default now(),
 check((status='attending' and departed_at is null) or (status='departed' and departed_at is not null))
);
create unique index scene_specialist_one_active_attendance_idx on game.scene_specialist_attendances(scene_id,personnel_id) where status='attending';
create index scene_specialist_attendances_scene_fk_idx on game.scene_specialist_attendances(scene_id);
create index scene_specialist_attendances_incident_fk_idx on game.scene_specialist_attendances(incident_id);
create index scene_specialist_attendances_personnel_fk_idx on game.scene_specialist_attendances(personnel_id);
create index scene_specialist_attendances_deployment_fk_idx on game.scene_specialist_attendances(deployment_id);
create index scene_specialist_attendances_unit_fk_idx on game.scene_specialist_attendances(unit_id);
create index scene_specialist_attendances_qualification_fk_idx on game.scene_specialist_attendances(qualification_id);
create index scene_specialist_attendances_command_fk_idx on game.scene_specialist_attendances(source_command_id);
alter table game.scene_specialist_attendances enable row level security;
create table game.scene_examination_plans(
 id uuid primary key default gen_random_uuid(),plan_ref text not null unique,
 scene_id uuid not null references game.incident_scenes(id),attendance_id uuid not null references game.scene_specialist_attendances(id),
 examiner_personnel_id uuid not null references game.police_personnel(id),qualification_id uuid not null references game.personnel_qualifications(id),
 discipline text not null,examination_question text not null,scope text not null,known_limitations text not null,
 status text not null check(status in ('planned','in_progress','completed','cancelled')),
 created_by_personnel_id uuid not null references game.police_personnel(id),created_at timestamptz not null,
 started_at timestamptz,completed_at timestamptz,source_command_id uuid references game.game_commands(id)
);
create index scene_examination_plans_scene_fk_idx on game.scene_examination_plans(scene_id);
create index scene_examination_plans_attendance_fk_idx on game.scene_examination_plans(attendance_id);
create index scene_examination_plans_examiner_fk_idx on game.scene_examination_plans(examiner_personnel_id);
create index scene_examination_plans_qualification_fk_idx on game.scene_examination_plans(qualification_id);
create index scene_examination_plans_creator_fk_idx on game.scene_examination_plans(created_by_personnel_id);
create index scene_examination_plans_command_fk_idx on game.scene_examination_plans(source_command_id);
alter table game.scene_examination_plans enable row level security;
create table game.scene_examination_events(
 id uuid primary key default gen_random_uuid(),plan_id uuid not null references game.scene_examination_plans(id),
 event_at timestamptz not null,event_type text not null check(event_type in ('planned','started','completed','cancelled')),
 actor_personnel_id uuid not null references game.police_personnel(id),details jsonb not null default '{}'::jsonb,
 source_command_id uuid references game.game_commands(id),created_at timestamptz not null default now()
);
create index scene_examination_events_plan_fk_idx on game.scene_examination_events(plan_id);
create index scene_examination_events_actor_fk_idx on game.scene_examination_events(actor_personnel_id);
create index scene_examination_events_command_fk_idx on game.scene_examination_events(source_command_id);
alter table game.scene_examination_events enable row level security;
create table game.scene_examination_records(
 id uuid primary key default gen_random_uuid(),plan_id uuid not null references game.scene_examination_plans(id),
 examiner_personnel_id uuid not null references game.police_personnel(id),qualification_id uuid not null references game.personnel_qualifications(id),
 recorded_at timestamptz not null,observations text not null,findings text not null,limitations text not null,
 source_command_id uuid references game.game_commands(id),created_at timestamptz not null default now(),unique(plan_id)
);
create index scene_examination_records_plan_fk_idx on game.scene_examination_records(plan_id);
create index scene_examination_records_examiner_fk_idx on game.scene_examination_records(examiner_personnel_id);
create index scene_examination_records_qualification_fk_idx on game.scene_examination_records(qualification_id);
create index scene_examination_records_command_fk_idx on game.scene_examination_records(source_command_id);
alter table game.scene_examination_records enable row level security;