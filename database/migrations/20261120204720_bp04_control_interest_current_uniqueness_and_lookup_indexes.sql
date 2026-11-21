-- BP-04: enforce one current control-interest row per holder and control type.
-- Historical rows remain available after valid_to is set.
create unique index if not exists organisation_control_current_person_uq
 on game.organisation_control_interests(organisation_id,holder_person_id,control_type)
 where valid_to is null and holder_person_id is not null;
create unique index if not exists organisation_control_current_organisation_uq
 on game.organisation_control_interests(organisation_id,holder_organisation_id,control_type)
 where valid_to is null and holder_organisation_id is not null;
create index if not exists organisation_control_subject_timeline_idx
 on game.organisation_control_interests(organisation_id,valid_from,valid_to);
create index if not exists organisation_control_holder_person_idx
 on game.organisation_control_interests(holder_person_id,valid_from,valid_to)
 where holder_person_id is not null;
create index if not exists organisation_control_holder_organisation_idx
 on game.organisation_control_interests(holder_organisation_id,valid_from,valid_to)
 where holder_organisation_id is not null;
