-- Cover all foreign keys on patrol intelligence linkage records.
create index patrol_intelligence_links_actor_personnel_fk_idx
 on game.patrol_intelligence_links(actor_personnel_id);
create index patrol_intelligence_links_source_command_fk_idx
 on game.patrol_intelligence_links(source_command_id);
