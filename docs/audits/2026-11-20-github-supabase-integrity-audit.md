# GitHub–Supabase Integrity Audit

**Audit date:** 2026-11-20  
**Repository:** `Joshuaogri/Kingswell-Police-Simulation`  
**Branch:** `main`  
**Supabase project:** `Kingswell-Police-Simulation` (`gdbzkgejyfwfackyuorl`)  
**Scope:** Read-only inspection of repository structure, migration inventory, live database schema/data, security posture, project documentation and selected regression tests.

## 1. Executive result

The GitHub repository and live Supabase project are connected and the Supabase project is healthy. The live game database contains a substantial seeded Kingswell world and police-simulation foundation.

**Database deployment must remain disabled.** The repository migration directory and Supabase migration history do not currently reconcile by exact migration version and name. Applying migrations or repairing migration history before investigating those differences could replay existing changes or misrepresent the database's actual history.

No database migrations, schema changes, permission changes, record updates or deletes were performed during this audit. The only database commands that executed writes were two existing regression scripts explicitly wrapped in transactions and rolled back.

## 2. Verified service state

| Item | Verified state |
|---|---|
| Supabase project | `ACTIVE_HEALTHY` |
| Database | PostgreSQL 17.12 |
| Region | `eu-west-1` |
| GitHub working branch | `main` |
| GitHub Actions workflows | Two: `.github/workflows/deploy-pages.yml` and `.github/workflows/verify-supabase-migrations.yml` |
| Existing workflow purpose | Publishes the browser test centre to GitHub Pages |
| Supabase deployment in existing workflow | None |
| Supabase CLI project configuration | No `supabase/config.toml` found |
| Migration directory | `database/migrations/` |
| Test directory | `database/tests/` |

A repository-wide search found no references to `SUPABASE_ACCESS_TOKEN` or `SUPABASE_DB_PASSWORD`; no current workflow uses them. Their presence in repository Actions secrets was confirmed by the user, but their values were never accessed or displayed. The latest observed Pages workflow run (ID `44808455988`) completed successfully in both build and deploy jobs. This verifies the static GitHub Pages test-centre deployment only; it does not verify Supabase authentication, database connectivity or migration deployment.

## 3. Migration reconciliation

The initial filename/CLI comparison has now been supplemented by a direct, read-only query of \`supabase_migrations.schema_migrations\`, retrieving the stored version, migration name and statement-array digest. The remote table also contains the original \`statements\` array, so a deeper SQL-content comparison is possible and is the next audit step.

| Measure | Verified count |
|---|---:|
| SQL migration files in GitHub | 212 |
| Applied migration records in Supabase | 225 |
| Exact version identifiers present on both sides | 138 |
| GitHub-only version identifiers | 74 |
| Supabase-only version identifiers | 87 |
| Distinct migration names found on both sides after removing a leading 8- or 14-digit timestamp prefix from stored names | 207 |
| Supabase records with no matching repository migration name after that normalisation | 17 |
| GitHub migration files with no matching Supabase migration name after that normalisation | 3 |

The 138 exact version identifiers are not proof of SQL equivalence. One exact-version record (`20261120121100`) is a genuine different-name and different-SQL collision. Another (`20261120110252`) has a different stored name but its executed SQL matches the repository file after comment/whitespace normalisation. A third record (\`20261120130735\`) has a stored name prefixed with \`20261120_\`; after removing that date prefix its name matches the repository migration name.

The 17 unmatched Supabase names and three unmatched repository names must be mapped to actual SQL files, including renamed or retimestamped candidates. The Supabase history table stores executed statement arrays, which can be compared with repository SQL after accounting for statement splitting and formatting. That comparison has not yet been completed. No migration deployment or repair is authorised by this inventory.

Two distinct repository migrations share the human-readable name `case_review_dossier_and_player_command` at versions `20261120133851` and `20261120133944`. Their SQL files are different in content and should be treated as separate migrations, not as duplicate files.

**Decision:** Do not run `supabase db push`, `supabase migration repair`, or any migration replay until the complete mapping and current-schema comparison are documented.

## 4. Live database structure

The live `game` schema currently contains:

| Measure | Live count |
|---|---:|
| Tables | 207 |
| Foreign-key constraints | 691 |
| Indexes | 999 |
| Tables with RLS enabled | 202 |
| Tables with RLS disabled | 5 |
| RLS policies | 0 |
| Functions | 227 |
| SECURITY DEFINER functions | 9 |
| Tables in `public` schema | 0 |

The `game` schema has no USAGE privilege for either `anon` or `authenticated`. Direct SELECT and INSERT grants for those roles were also absent on the five tables with RLS disabled. The private schema is therefore not directly exposed to those client roles through the permissions checked in this audit.

### RLS-disabled tables

- `game.property_valuation_records`
- `game.property_asset_events`
- `game.organisation_control_interests`
- `game.organisation_site_agreements`
- `game.organisation_site_agreement_locations`

These are a real RLS configuration gap. Do not simply enable RLS without deciding the intended server-side access model: enabling RLS without policies would deny ordinary access, and broad policies would be inappropriate for this private game database.

### Function execution grants requiring review

Two SECURITY DEFINER functions have EXECUTE granted to both `anon` and `authenticated`:

- `game.execute_correctional_command(uuid,text,jsonb,uuid)`
- `game.get_correctional_record(text)`

The `game` schema currently denies USAGE to both roles, so these functions are not currently reachable through the ordinary client API. However, the grants should be reviewed before any schema exposure. The command function accepts a caller-supplied personnel ID and actor reference rather than binding the actor to an authenticated session; the record function has no actor argument. Do not expose these functions to client roles.

### Advisor findings

| Advisor finding | Count | Interpretation |
|---|---:|---|
| RLS enabled, no policy | 202 | Consistent with a private, server-only schema; keep the schema private until the runtime access model is defined |
| Function search path not fixed | 31 | All 31 identified functions are invoker-rights, not SECURITY DEFINER; review and set explicit paths where appropriate |
| Unindexed foreign keys | 114 | Review against actual query patterns and indexes; do not blindly add indexes |
| Unused indexes | 302 | Do not drop based on this snapshot alone; retain until representative gameplay workload measurements justify removal |
| Health advisor findings | 0 | No health findings returned |

The nine SECURITY DEFINER functions identified in the live schema all had an explicit `search_path` setting. The two functions listed above are the ones whose EXECUTE grants require particular attention.

## 5. Live game data acceptance checks

Exact SQL counts and the repository's read-only BP-03 acceptance checks confirmed:

| Acceptance measure | Observed result |
|---|---:|
| Unique Kingswell persons | 100,000 |
| Incomplete core person profiles | 0 |
| Households | 24,512 |
| Households without an allocated dwelling unit | 0 |
| Current primary household memberships | 100,000 |
| Current primary residential addresses | 100,000 |
| Dwelling occupancy/capacity mismatches | 0 |
| Address/household dwelling mismatches | 0 |
| Birth events | 100,000 |
| People with a birth event | 100,000 |
| Relationship records | 309,760 |
| Self-relationships | 0 |
| Business profiles | 1,452 |
| Estimated business jobs | 43,412 |
| Current employment links | 43,412 |
| Businesses with headcount mismatch | 0 |

The 206,600 person-population membership records represent overlapping categories, not 206,600 different people. They include 100,000 permanent residents plus additional current categories such as students, workers, retired and unemployed people.

The live simulation clock is paused and its fictional current time is still unset. Six completed command-verification records exist. The following gameplay tables had zero records at the time of the audit: game events, incidents, cases, evidence items and dispatch calls.

## 6. Regression tests executed

The following existing repository tests were executed against the connected live database:

| Test | Result |
|---|---|
| `database/tests/kingswell_bp03_live_population_acceptance.sql` | Read-only acceptance checks executed without SQL error; exact acceptance metrics were separately queried and recorded above |
| `database/tests/bp04_organisation_dossier_regression.sql` | Passed; read-only assertions returned without SQL error |
| `database/tests/kingswell_correctional_runtime.sql` | Passed; rollback-only parser/runtime assertions returned without SQL error |
| `database/tests/kingswell_patrol_road_movement.sql` | Passed; rollback-only end-to-end movement, clock, location and coverage assertions returned without SQL error |
| `database/tests/kingswell_court_registry_and_hearings.sql` | Passed; rollback-only court registry/docket/hearing assertions returned without SQL error |
| `database/tests/kingswell_trial_proceedings.sql` | Passed; rollback-only trial parser/routing assertions returned without SQL error |
| `database/tests/kingswell_correctional_foundation.sql` | Passed; rollback-only schema/index assertions returned without SQL error |
| `database/tests/kingswell_correctional_staff.sql` | Passed after correcting a brittle test assertion; delegated runtime routing and actor validation verified |
| `database/tests/kingswell_correctional_staff_authority.sql` | Passed after correcting a brittle test assertion; staff listing remains available while police-driven staff appointment remains unavailable |

The first versions of the two correctional staff tests inspected only the outermost `execute_text_command` wrapper and falsely reported that the staff directory handler was missing. Inspection showed the outer wrapper delegates to `execute_text_command_before_property`, which contains the correctional staff route and calls the correctional executor. A rollback-only command call reached actor validation as expected. The two tests were corrected in GitHub to verify this actual delegation chain and were rerun successfully.

No production database function, schema, permission or game record was changed while correcting the tests. The two staff test files were updated in GitHub only.

These results validate the listed slices; they do not prove every system, every migration or the complete game is correct.

## 7. Documentation drift

The current live database has 207 tables, 691 foreign keys and 999 indexes. The implementation register still describes an earlier snapshot of 185 tables, 629 foreign keys and 915 indexes. Other sections of the implementation register and technical architecture retain still older counts (including 123, 42 and 40 tables) and outdated descriptions of systems now present in the live database.

The older database-to-blueprint audit is explicitly a historical 40-table snapshot and should remain as historical evidence. It must not be presented as the current state.

The approved BP-01 to BP-44 master blueprint remains the design baseline. This audit does not amend or reopen it.

## 8. Required next actions

1. Reconcile every Supabase migration record against the repository files, including version changes, renames and missing SQL files.
2. Compare the current live schema against the schema implied by the reconciled migration chain. Identify any live-only or repository-only objects.
3. Review the two SECURITY DEFINER function grants and the five RLS-disabled tables against the intended private server-side runtime model. Prepare a versioned hardening migration; do not apply it as part of this read-only audit.
4. Review the 114 unindexed foreign keys and 31 invoker-rights functions with mutable search paths. Make targeted changes only when supported by schema and workload evidence.
5. Update the implementation register and technical architecture with the current verified counts and actual implementation status, retaining the approved blueprint and historical audit records.
6. Add a read-only GitHub Actions database validation workflow only after the migration directory/configuration is reconciled. It must never run `db push` automatically.

## 9. Audit conclusion

**Verified:** Supabase is healthy; the live Kingswell population and business acceptance metrics pass; selected BP-03, BP-04 and correctional runtime tests execute successfully; the private `game` schema is not exposed to ordinary client roles by the schema permissions checked.

**Discrepancy:** GitHub and Supabase migration inventories do not currently reconcile; project status documentation is stale; several security and performance findings need targeted review.

**Unverified:** Exact historical SQL equivalence for every applied migration, full schema reproducibility from the repository, all 44 blueprint divisions, backup/restore readiness and full end-to-end game playability.

**No production migration, schema, data or permission changes were made during this audit.**


## 10. Migration version-collision case study: patrol road movement

A focused comparison of the patrol migration sequence found a concrete version collision:

| Supabase applied version | Supabase recorded name | GitHub file/version |
|---|---|---|
| `20261120120433` | `index_patrol_schedule_coverage_foreign_keys` | `20261120121100_index_patrol_schedule_coverage_foreign_keys.sql` |
| `20261120121100` | `record_transit_and_on_beat_patrol_segments` | `20261120121600_record_transit_and_on_beat_patrol_segments.sql` |

The GitHub file `20261120121100_index_patrol_schedule_coverage_foreign_keys.sql` contains four index statements. The Supabase history row at that exact version is instead named `record_transit_and_on_beat_patrol_segments`. The GitHub file for that recorded migration is now timestamped `20261120121600`.

This means the repository file at version `20261120121100` and the applied Supabase migration at version `20261120121100` do not represent the same named change. Meanwhile, the matching index migration exists in Supabase under the earlier version `20261120120433`.

The same patrol sequence shows several other name-matched migrations whose GitHub timestamps have moved later than their Supabase applied versions. One applied migration, `restrict_patrol_command_parser_and_coverage_access` at `20261120120636`, has no same-name migration file in the current repository inventory.

The live database does contain `game.move_patrol_unit` and the patrol movement event structure. The rollback-only regression `database/tests/kingswell_patrol_road_movement.sql` executed successfully against the live database. This confirms the current patrol movement slice works under that test; it does not prove the historical migration files are identical.

**Why this matters:** migration tools reconcile by version identifiers. A file whose timestamp collides with a different applied migration can be treated as already applied even though its SQL is different. A retimestamped migration may instead appear pending and be replayed. The migration chain must therefore be reconciled by version, recorded name, repository path, SQL purpose and current live object state—not by filenames or names alone.

**Required treatment:** preserve both the live schema and all existing migration records. Do not rename files, repair migration history, push migrations or replay the patrol sequence until each migration has an explicit one-to-one reconciliation decision.

Supabase's [CLI migration-list reference](https://supabase.com/docs/reference/cli/supabase-migration-list) explicitly states that it compares timestamps only. It does not compare migration names or SQL contents. Therefore, a same-version/different-name collision such as `20261120121100` may not be reported by `supabase migration list` at all. CLI output alone is not a sufficient integrity check for Kingswell.


## 11. Full migration-name and version reconciliation inventory

The following table maps each of the 72 normalised-name matches whose repository filename timestamp differs from the applied Supabase version. The pairing is by normalised migration name; it is an inventory aid, not proof that the historical SQL bytes are identical.

| Supabase version | Supabase name | GitHub file timestamp | GitHub filename |
|---|---|---|---|
| `20261119234957` | `runtime_foundation_commands_clock` | `20261120010000` | `20261120010000_runtime_foundation_commands_clock.sql` |
| `20261119235103` | `harden_runtime_command_validation` | `20261120020000` | `20261120020000_harden_runtime_command_validation.sql` |
| `20261120000129` | `validate_optional_dispatch_call_fields` | `20261120050000` | `20261120050000_validate_optional_dispatch_call_fields.sql` |
| `20261120000935` | `unit_dispatch_and_rostered_personnel` | `20261120060000` | `20261120060000_unit_dispatch_and_rostered_personnel.sql` |
| `20261120001047` | `register_dispatch_commands_in_help` | `20261120070000` | `20261120070000_register_dispatch_commands_in_help.sql` |
| `20261120001259` | `honour_rostered_cross_unit_attachments` | `20261120080000` | `20261120080000_honour_rostered_cross_unit_attachments.sql` |
| `20261120100148` | `index_scene_workflow_foreign_keys` | `20261120100100` | `20261120100100_index_scene_workflow_foreign_keys.sql` |
| `20261120113533` | `kingswell_live_dispatch_route_integration` | `20261120114500` | `20261120114500_kingswell_live_dispatch_route_integration.sql` |
| `20261120113738` | `index_dispatch_route_foreign_keys` | `20261120114600` | `20261120114600_index_dispatch_route_foreign_keys.sql` |
| `20261120113841` | `enforce_deployment_route_history_append_only` | `20261120114700` | `20261120114700_enforce_deployment_route_history_append_only.sql` |
| `20261120115032` | `register_unit_position_as_gameplay_command` | `20261120115200` | `20261120115200_register_unit_position_as_gameplay_command.sql` |
| `20261120115508` | `player_dispatch_options_and_unit_reassignment` | `20261120115500` | `20261120115500_player_dispatch_options_and_unit_reassignment.sql` |
| `20261120120105` | `patrol_unit_operational_state_lifecycle` | `20261120120000` | `20261120120000_patrol_unit_operational_state_lifecycle.sql` |
| `20261120120139` | `block_dispatch_to_out_of_service_units` | `20261120120100` | `20261120120100_block_dispatch_to_out_of_service_units.sql` |
| `20261120120220` | `index_patrol_unit_state_history_foreign_keys` | `20261120120200` | `20261120120200_index_patrol_unit_state_history_foreign_keys.sql` |
| `20261120120342` | `patrol_beat_assignment_scheduling_and_coverage` | `20261120121000` | `20261120121000_patrol_beat_assignment_scheduling_and_coverage.sql` |
| `20261120120433` | `index_patrol_schedule_coverage_foreign_keys` | `20261120121100` | `20261120121100_index_patrol_schedule_coverage_foreign_keys.sql` |
| `20261120120556` | `patrol_commands_and_live_beat_coverage` | `20261120121200` | `20261120121200_patrol_commands_and_live_beat_coverage.sql` |
| `20261120120710` | `suspend_patrol_coverage_on_incident_deployment` | `20261120121300` | `20261120121300_suspend_patrol_coverage_on_incident_deployment.sql` |
| `20261120120955` | `patrol_road_movement_and_segment_history` | `20261120121400` | `20261120121400_patrol_road_movement_and_segment_history.sql` |
| `20261120121018` | `fix_patrol_movement_route_variable_ambiguity` | `20261120121500` | `20261120121500_fix_patrol_movement_route_variable_ambiguity.sql` |
| `20261120121100` | `record_transit_and_on_beat_patrol_segments` | `20261120121600` | `20261120121600_record_transit_and_on_beat_patrol_segments.sql` |
| `20261120121122` | `include_road_movement_in_patrol_coverage` | `20261120121700` | `20261120121700_include_road_movement_in_patrol_coverage.sql` |
| `20261120121221` | `register_patrol_commands_in_runtime_help` | `20261120121800` | `20261120121800_register_patrol_commands_in_runtime_help.sql` |
| `20261120121513` | `remove_patrol_commands_from_forensic_dispatch` | `20261120121900` | `20261120121900_remove_patrol_commands_from_forensic_dispatch.sql` |
| `20261120121815` | `patrol_intelligence_and_coverage_gap_reporting` | `20261120122000` | `20261120122000_patrol_intelligence_and_coverage_gap_reporting.sql` |
| `20261120122310` | `patrol_activity_sessions_and_intelligence` | `20261120123000` | `20261120123000_patrol_activity_sessions_and_intelligence.sql` |
| `20261120122446` | `harden_patrol_activity_record_history` | `20261120122500` | `20261120122500_harden_patrol_activity_record_history.sql` |
| `20261120122533` | `index_patrol_movement_event_foreign_keys` | `20261120122600` | `20261120122600_index_patrol_movement_event_foreign_keys.sql` |
| `20261120122844` | `patrol_observations_and_civilian_contacts` | `20261120124000` | `20261120124000_patrol_observations_and_civilian_contacts.sql` |
| `20261120122903` | `patrol_intelligence_observation_contact_reporting` | `20261120124100` | `20261120124100_patrol_intelligence_observation_contact_reporting.sql` |
| `20261120122948` | `allow_patrol_observation_contact_events` | `20261120124200` | `20261120124200_allow_patrol_observation_contact_events.sql` |
| `20261120123044` | `index_patrol_observation_contact_foreign_keys` | `20261120124300` | `20261120124300_index_patrol_observation_contact_foreign_keys.sql` |
| `20261120123255` | `20261120125000_searchable_patrol_intelligence` | `20261120125000` | `20261120125000_searchable_patrol_intelligence.sql` |
| `20261120123316` | `20261120125100_refine_patrol_intelligence_search` | `20261120125100` | `20261120125100_refine_patrol_intelligence_search.sql` |
| `20261120123807` | `20261120130000_patrol_intelligence_investigation_links` | `20261120130000` | `20261120130000_patrol_intelligence_investigation_links.sql` |
| `20261120123949` | `20261120131000_patrol_intelligence_link_history_lookup` | `20261120131000` | `20261120131000_patrol_intelligence_link_history_lookup.sql` |
| `20261120124058` | `20261120132000_index_patrol_intelligence_link_foreign_keys` | `20261120132000` | `20261120132000_index_patrol_intelligence_link_foreign_keys.sql` |
| `20261120124452` | `patrol_intelligence_review_history` | `20261120134000` | `20261120134000_patrol_intelligence_review_history.sql` |
| `20261120124710` | `patrol_intelligence_review_player_commands` | `20261120135000` | `20261120135000_patrol_intelligence_review_player_commands.sql` |
| `20261120125144` | `case_investigative_task_management` | `20261120140000` | `20261120140000_case_investigative_task_management.sql` |
| `20261120125347` | `case_task_player_commands` | `20261120140100` | `20261120140100_case_task_player_commands.sql` |
| `20261120125411` | `case_task_create_command_actor_attribution` | `20261120140200` | `20261120140200_case_task_create_command_actor_attribution.sql` |
| `20261120125559` | `case_task_help_command_registration` | `20261120140300` | `20261120140300_case_task_help_command_registration.sql` |
| `20261120130118` | `revoke_ambiguous_case_assignment_release` | `20261120130100` | `20261120130100_revoke_ambiguous_case_assignment_release.sql` |
| `20261120135626` | `case_lead_handovers_and_continuity` | `20261120135500` | `20261120135500_case_lead_handovers_and_continuity.sql` |
| `20261120140743` | `fix_case_task_submission_retrieval_task_reference` | `20261120140610` | `20261120140610_fix_case_task_submission_retrieval_task_reference.sql` |
| `20261120142033` | `index_surveillance_operation_foreign_keys` | `20261120141805` | `20261120141805_index_surveillance_operation_foreign_keys.sql` |
| `20261120142136` | `require_surveillance_team_lead_before_deployment` | `20261120142215` | `20261120142215_require_surveillance_team_lead_before_deployment.sql` |
| `20261120153836` | `constrain_court_event_subject_links` | `20261120153831` | `20261120153831_constrain_court_event_subject_links.sql` |
| `20261120160009` | `correctional_foundation_and_sentence_administration` | `20261120161000` | `20261120161000_correctional_foundation_and_sentence_administration.sql` |
| `20261120160103` | `correctional_foreign_key_indexes` | `20261120162000` | `20261120162000_correctional_foreign_key_indexes.sql` |
| `20261120160348` | `correctional_command_runtime_integration` | `20261120170000` | `20261120170000_correctional_command_runtime_integration.sql` |
| `20261120160601` | `correctional_sentence_case_link_validation` | `20261120170500` | `20261120170500_correctional_sentence_case_link_validation.sql` |
| `20261120161236` | `correctional_read_only_queries_without_clock` | `20261120161200` | `20261120161200_correctional_read_only_queries_without_clock.sql` |
| `20261120161443` | `correctional_staff_profiles_and_commands` | `20261120173500` | `20261120173500_correctional_staff_profiles_and_commands.sql` |
| `20261120161532` | `correctional_staff_directory_authority_boundary` | `20261120174500` | `20261120174500_correctional_staff_directory_authority_boundary.sql` |
| `20261120194513` | `kingswell_bp02_detailed_map_seed_reconciliation` | `20261120194000` | `20261120194000_kingswell_bp02_detailed_map_seed_reconciliation.sql` |
| `20261120194528` | `kingswell_bp02_turn_traffic_aware_routing_engine_v2` | `20261120194100` | `20261120194100_kingswell_bp02_turn_traffic_aware_routing_engine_v2.sql` |
| `20261120203656` | `bp04_sync_business_profiles_to_current_site_dossiers` | `20261120203410` | `20261120203410_bp04_sync_business_profiles_to_current_site_dossiers.sql` |
| `20261120203946` | `bp04_individualise_property_planning_and_building_system_dossiers` | `20261120204100` | `20261120204100_bp04_individualise_property_planning_and_building_system_dossiers.sql` |
| `20261120203959` | `bp04_add_building_specific_system_profile_references` | `20261120204200` | `20261120204200_bp04_add_building_specific_system_profile_references.sql` |
| `20261120204220` | `bp04_individualise_unit_access_and_metering_dossiers` | `20261120204300` | `20261120204300_bp04_individualise_unit_access_and_metering_dossiers.sql` |
| `20261120204556` | `bp04_site_agreement_term_coverage_register` | `20261120205000` | `20261120205000_bp04_site_agreement_term_coverage_register.sql` |
| `20261120204720` | `bp04_control_interest_current_uniqueness_and_lookup_indexes` | `20261120205500` | `20261120205500_bp04_control_interest_current_uniqueness_and_lookup_indexes.sql` |
| `20261120205002` | `bp04_site_agreement_lifecycle_event_history` | `20261120214800` | `20261120214800_bp04_site_agreement_lifecycle_event_history.sql` |
| `20261120205301` | `bp04_detailed_organisation_institution_profiles` | `20261120220500` | `20261120220500_bp04_detailed_organisation_institution_profiles.sql` |
| `20261120205546` | `bp04_organisation_workforce_role_dossiers` | `20261120222000` | `20261120222000_bp04_organisation_workforce_role_dossiers.sql` |
| `20261120205750` | `bp04_site_dossiers_and_organisation_structure` | `20261120223500` | `20261120223500_bp04_site_dossiers_and_organisation_structure.sql` |
| `20261120205942` | `bp04_property_interest_and_agreement_review_dossiers` | `20261120225000` | `20261120225000_bp04_property_interest_and_agreement_review_dossiers.sql` |
| `20261120205957` | `bp04_correct_agreement_review_completeness_predicate` | `20261120225500` | `20261120225500_bp04_correct_agreement_review_completeness_predicate.sql` |
| `20261120210216` | `bp04_property_title_transfer_history_framework` | `20261120231000` | `20261120231000_bp04_property_title_transfer_history_framework.sql` |

### Supabase migration names without a same-name GitHub file

| Supabase version | Supabase migration name | Exact-version file check |
|---|---|---|
| `20261119235755` | `text_command_interpreter_and_dispatch_call_intake` | No repository file with this version |
| `20261119235824` | `fix_dispatch_call_event_type_argument` | No repository file with this version |
| `20261120110252` | `kingswell_bp02_geographic_foundation_schema_and_seed` | `20261120110252_kingswell_bp02_geographic_foundation.sql` (same version, different name) |
| `20261120114606` | `dispatch_eta_ranking_unit_positions_and_route_recalculation` | No repository file with this version |
| `20261120120636` | `restrict_patrol_command_parser_and_coverage_access` | No repository file with this version |
| `20261120124722` | `fix_patrol_intelligence_review_command_fallback` | No repository file with this version |
| `20261120140249` | `case_task_dependency_and_workload_player_commands` | No repository file with this version |
| `20261120192715` | `kingswell_bp02_detailed_street_atlas_and_service_access` | No repository file with this version |
| `20261120192817` | `kingswell_bp02_turn_traffic_and_closure_aware_routing` | No repository file with this version |
| `20261120192929` | `kingswell_bp02_dispatch_uses_simulation_clock_for_road_conditions` | No repository file with this version |
| `20261120193001` | `kingswell_bp02_map_version_and_turn_control_register` | No repository file with this version |
| `20261120193024` | `kingswell_bp02_extend_patrol_beat_coverage_to_service_lanes` | No repository file with this version |
| `20261120193404` | `kingswell_bp02_connect_all_named_secondary_roads` | No repository file with this version |
| `20261120193433` | `kingswell_bp02_complete_no_uturn_controls_for_all_segments` | No repository file with this version |
| `20261120193805` | `kingswell_bp02_correct_service_lane_beat_coverage` | No repository file with this version |
| `20261120193909` | `kingswell_bp02_signalised_junction_turn_bans` | No repository file with this version |
| `20261120210623` | `bp04_physical_asset_inventory_and_unit_infrastructure` | No repository file with this version |

### GitHub migration files without a same-name Supabase record

| GitHub file timestamp | GitHub filename |
|---|---|
| `20261120030000` | `20261120030000_text_interpreter_dispatch_intake.sql` |
| `20261120040000` | `20261120040000_fix_dispatch_call_event_type.sql` |
| `20261120115000` | `20261120115000_dispatch_eta_ranking_unit_position_and_recalculation.sql` |

### Exact-version records whose recorded name differs from the GitHub filename

| Version | Supabase migration name | GitHub file at that version |
|---|---|---|
| `20261120110252` | `kingswell_bp02_geographic_foundation_schema_and_seed` | `20261120110252_kingswell_bp02_geographic_foundation.sql` |
| `20261120121100` | `record_transit_and_on_beat_patrol_segments` | `20261120121100_index_patrol_schedule_coverage_foreign_keys.sql` |

The `20261120121100` record is the confirmed patrol version/content collision described in sections 10 and 13. The `20261120110252` stored name differs, but its statement content matches the repository file after comment/whitespace normalisation. See section 13 for the direct SQL comparisons.


## 12. GitHub Actions connectivity verification

The manual-only workflow \`.github/workflows/verify-supabase-migrations.yml\` now connects successfully through the shared IPv4 session pooler and runs \`supabase migration list\`. Run \`44827744093\` completed successfully on 2026-11-20. The job verified that the database-password secret was injected without displaying its value, read local and remote migration versions, and uploaded the \`kingswell-supabase-migration-inventory\` artifact.

The workflow performs no \`db push\`, migration repair, reset or SQL write. It remains manually triggered only. The database password and Supabase access token remain separate secrets; neither value is stored in the repository or exposed in logs.

The CLI inventory is timestamp-only. It is useful for version counts but cannot detect same-version/different-name collisions or compare SQL contents. A separate read-only SQL inspection was therefore performed against \`supabase_migrations.schema_migrations\` for the more complete reconciliation in section 13.


## 13. Direct remote migration-history inspection

A read-only query of \`supabase_migrations.schema_migrations\` confirmed the table columns include \`version\`, \`name\`, \`statements\`, \`created_by\`, \`idempotency_key\` and \`rollback\`. The audit retrieved all 225 version/name records and computed a digest over each stored statement array for later comparison. No rows were inserted, updated or deleted.

### Exact-version name and content checks

| Version | Supabase recorded name | GitHub file at same version | SQL comparison result |
|---|---|---|---|
| \`20261120110252\` | \`kingswell_bp02_geographic_foundation_schema_and_seed\` | \`20261120110252_kingswell_bp02_geographic_foundation.sql\` | **Content matches** after removing SQL comments and normalising whitespace; name differs only |
| \`20261120121100\` | \`record_transit_and_on_beat_patrol_segments\` | \`20261120121100_index_patrol_schedule_coverage_foreign_keys.sql\` | **Content does not match**; remote SQL implements patrol movement, while the repository file creates patrol schedule/coverage indexes |

For \`20261120121100\`, the remote statement was also compared with the later candidate file \`20261120121600_record_transit_and_on_beat_patrol_segments.sql\`. The candidate has substantial common beginning and ending sections, but the complete normalised SQL is not equal. It must not be assumed to be a faithful copy of the applied migration.

The record at \`20261120130735\` is not treated as a third genuine collision: Supabase stores the name as \`20261120_case_investigative_leads_and_enquiries\`, while the repository suffix is \`case_investigative_leads_and_enquiries\`. Removing the leading eight-digit date prefix makes the names match.

### Duplicate applied migration name

The remote history contains two records named \`case_review_dossier_and_player_command\`, at versions \`20261120133851\` and \`20261120133944\`.

- The stored SQL for \`20261120133851\` matches the repository file at the same version after removing SQL comments and normalising whitespace.
- The stored SQL for \`20261120133944\` does **not** match either repository file at \`20261120133851\` or \`20261120133944\`. The repository's \`20261120133944\` file is a much shorter command-interpreter change, while the remote statement contains a different case-review dossier definition and additional SQL. This is a confirmed historical-file/content discrepancy requiring recovery or explicit classification.

### Migration names without a counterpart

The 17 remote-only names and three repository-only names are listed in section 11. The mismatch pattern includes renamed migrations, migrations whose timestamps moved, and possible missing historical SQL files. Name similarity alone is not sufficient to decide which files are safe to rename or replay.

### Reconciliation decision

1. Preserve the live database and every existing migration-history row.
2. Compare each remote \`statements\` array against the candidate repository SQL file, beginning with the two genuine exact-version collisions and the duplicate-name pair.
3. Map all 17 remote-only and three repository-only names to candidate files or classify them as genuinely missing.
4. Only after the content mapping is complete, compare the live schema with the repository's intended final schema and prepare a non-deploying reconciliation plan.
5. Keep automatic migration deployment disabled. Do not run \`db push\`, \`migration repair\`, reset or replay during this work.

**No production migration, schema, data or permission changes were made during this direct inspection.**


### Statement-level comparison runs #5 and #6

GitHub Actions run `44830241692` completed successfully and exported all 225 remote migration statement arrays. Its first canonical-text comparison reported 94 remote records with exact text matches, 131 without an exact match, and 82 same-version/different-text pairs. Inspection of a representative pair showed that Supabase's stored function definitions can use different dollar-quote tags (for example, `$scene$` rather than `$function$`) even where the function body and SQL behaviour are the same. The initial digest therefore over-reported mismatches.

The comparison script was corrected in commit `82a8d70d89cd534e4aafa27bafb0e59d24243c40` to normalise PostgreSQL dollar-quote tags before hashing. Manual workflow run #6 (`44830544686`) checked out commit `d0659c910f0c39099c43ebaf350023865e595771`, completed successfully, and reproduced the same counts after that correction: 94 remote records with exact canonical-text matches, 131 without an exact match, and 82 same-version/different-content pairs. The dollar-quote normalisation did not reduce the reported totals. These figures are now the current canonical-text comparison results, not semantic-equivalence findings. A canonical text difference remains an investigation lead, not proof of a behavioural SQL difference.


## 14. Corrected statement-level comparison run #6

GitHub Actions run [44830544686](https://github.com/Joshuaogri/Kingswell-Police-Simulation/actions/runs/44830544686) completed successfully on 2026-11-20. It checked out commit d0659c910f0c39099c43ebaf350023865e595771, read the remote migration history in a read-only transaction, ran the corrected comparator, and uploaded artifact 14675758444. The raw remote statement export was removed before artifact upload.

| Measure | Run #6 result |
|---|---:|
| Repository migration files | 212 |
| Applied Supabase records | 225 |
| Exact version identifiers | 138 |
| Repository-only versions | 74 |
| Supabase-only versions | 87 |
| Shared normalised names | 207 |
| Remote names without repository match | 17 |
| Repository names without remote match | 3 |
| Remote records with exact canonical SQL match | 94 |
| Remote records without exact canonical SQL match | 131 |
| Repository files without exact canonical SQL match | 99 |
| Same-version/different-content pairs | 82 |

The totals are unchanged from run #5 despite the dollar-quote-tag normalisation. The corrected run therefore does not support the earlier hypothesis that dollar-quote labels alone explain the broad mismatch count. The 131 remote records and 99 repository files without an exact canonical match require direct mapping and inspection; do not automatically classify all of them as missing or behaviourally different migrations.

### Confirmed example: version 20261120121100

A direct read-only query of the live migration-history row returned:

- Version: 20261120121100
- Stored name: record_transit_and_on_beat_patrol_segments
- One stored SQL statement, 5,485 characters
- SQL begins by adding within_assigned_beat to game.patrol_movement_events and defining game.move_patrol_unit(...).

The repository file at that same version is 20261120121100_index_patrol_schedule_coverage_foreign_keys.sql, which is an index migration. This is a genuine same-version/content collision, not merely a timestamp or stored-name difference. The later candidate 20261120121600_record_transit_and_on_beat_patrol_segments.sql must still be compared in full with the stored SQL before being treated as a recovered historical copy.

### Safety and next action

The workflow did not run db push, migration repair, reset, or any SQL write. The direct row inspection was a SELECT. No migration-history rows, schema objects, game records or permissions were changed.

The next work is content-led reconciliation: group remote and repository entries by canonical digest, then inspect unmatched migrations in chronological clusters, beginning with exact-version collisions and the duplicated case_review_dossier_and_player_command history entry. Compare complete SQL and current live object definitions; record each mapping as exact copy, renamed/retimestamped copy, equivalent-but-text-different, genuinely divergent, or unrecovered. Keep deployment and migration-history repair disabled until that register is complete.


## 15. Content-led review of the first migration collisions

The first two targeted collision groups were inspected using read-only queries against `supabase_migrations.schema_migrations` and the corresponding GitHub migration files. No live database changes were made.

### 15.1 Version 20261120121100 — patrol movement versus indexes

- Supabase stores version `20261120121100` under the name `record_transit_and_on_beat_patrol_segments`.
- Its stored SQL is one 5,485-character statement that adds `within_assigned_beat` to `game.patrol_movement_events` and defines `game.move_patrol_unit(...)`.
- GitHub's same-version file, `20261120121100_index_patrol_schedule_coverage_foreign_keys.sql`, is only 457 characters and creates four indexes. It is not the migration recorded remotely.
- GitHub also contains `20261120121600_record_transit_and_on_beat_patrol_segments.sql` (5,162 characters), which implements a closely related patrol movement function. It is a plausible predecessor/related revision, but it is not an exact recovery of the remotely stored SQL. The remote statement includes additional destination-on-assigned-beat and schedule-boundary validation and differs in other implementation details.
- Classification: **same-version content collision confirmed; related candidate found; exact historical source not yet recovered**. Do not replace either file or alter migration history on this evidence alone.

### 15.2 Version 20261120133944 — duplicate case-review migration name

- Supabase contains two rows named `case_review_dossier_and_player_command`, at versions `20261120133851` and `20261120133944`.
- The remote `20261120133851` row matches the GitHub `20261120133851_case_review_dossier_and_player_command.sql` baseline after ordinary comment/whitespace normalisation.
- The remote `20261120133944` row is not the GitHub file at the same version. The remote statement redefines the large case-review dossier function and the command interpreter/executor; the GitHub same-version file is a shorter follow-on that adds the named-actor and active-case-assignment access restriction.
- The remote `20261120133944` SQL also does not match the GitHub `20261120133851` baseline. This is therefore not explained by a simple filename/name discrepancy or by the two local files being exact duplicates.
- Classification: **duplicate remote name and same-version content collision confirmed; remote historical SQL differs from both local candidates; exact source/revision lineage unresolved**. Preserve both remote rows and both repository files pending recovery of the original migration artifact or a documented reconstruction decision.

### 15.3 Reconciliation status and safety

These checks confirm that at least two of the 82 same-version/different-content pairs are substantive historical-source mismatches, not merely dollar-quote-tag formatting. They do not establish that the differing SQL has equivalent or different runtime behaviour in every respect. Continue content-led investigation in chronological groups, retain all candidate files and remote history, and complete the remaining source mapping and live-schema comparison before considering any migration-history repair or deployment. The audit remains read-only; no migration was pushed, repaired, reset, or replayed.


## 16. Content-led review of version 20261120095728

The remote and repository SQL for `scene_control_field_reports_and_resource_requests` were retrieved and compared in full.

- Remote record: one statement, 58,148 characters; stored MD5 `d3178061b652034f6bdfbb22bdef5a0c`.
- GitHub file: `20261120095728_scene_control_field_reports_and_resource_requests.sql`, 58,268 characters.
- The initial canonical comparison differed because of PostgreSQL-equivalent declaration formatting (including a typed NULL default and quoted versus unquoted `search_path`) and the location of the `execute_scene_action` permission statements.
- After normalising those declaration forms and excluding the same two permission statements from the ordering comparison, the remaining complete SQL was identical. The remote version places the `execute_scene_action` revoke/grant immediately after that function; the repository version places the same revoke/grant at the end of the migration.
- Classification: **equivalent SQL with statement-order/formatting differences; no missing function or schema definition identified in this pair**. Retain the existing migration file and remote history. Do not rewrite history merely to force a text hash match.

This is a confirmed example where the raw canonical hash mismatch is not evidence of a substantive implementation divergence. The reconciliation process must distinguish this class from genuine content collisions.


## 17. Content-led review of specialist attendance migration versions 20261120102135 and 20261120102257

### 17.1 Version 20261120102135

- The remote row is one 77,336-character statement. The GitHub file at the same version is 43,505 characters.
- The `game.interpret_text_command` and `game.submit_command` function definitions in the remote statement match the two functions in the GitHub file after declaration/format normalisation.
- The remote statement additionally replaces `game.execute_scene_action` with a 33,060-character function. This is not present in the GitHub file. It includes scene-management/resource operations and the scene-specialist/examination command routing. The remote function's routing includes the specialist command names, although the detailed specialist attendance/examination branches are introduced in the following version.
- The next migration, `20261120102257_implement_specialist_attendance_and_scene_examination`, contains a later and substantially expanded `execute_scene_action` implementation. It is not an exact copy of the 20261120102135 function and cannot be used as an exact historical recovery.
- Classification: **same-version remote-only function replacement; parser and command-submission functions match; exact earlier handler revision not recovered**. The later 20261120102257 implementation is a related successor, not a substitute for the missing historical statement.

### 17.2 Version 20261120102257

- Remote and GitHub both contain the `game.execute_scene_action` specialist attendance and scene examination implementation.
- Remote SQL is 48,919 characters; GitHub SQL is 48,957 characters. The full normalised comparison differs only in the missing-scene-reference error message: the repository version additionally says that a valid examination plan reference is acceptable.
- All remaining normalised function text matches.
- Classification: **same implementation with one user-facing validation-message difference**. This is a minor source difference, not evidence of a missing handler or schema capability. Preserve both records pending the overall reconciliation; do not rewrite history.

These two adjacent versions demonstrate why a version collision must be assessed at function level: one migration has an extra historical function replacement absent from the repository, while the next migration's implementation is substantially present in both sources.


## 18. Content-led review of version 20261120103202

The remote migration and the repository file `20261120103202_scene_contamination_evidence_recovery_and_custody.sql` use different source forms.

- The remote statement creates the three scene contamination/evidence recovery/evidence transfer tables, defines `game.execute_evidence_action(...)`, and uses a dynamic `DO` block to patch the existing command interpreter and `game.submit_command`.
- The repository file contains the same three table definitions in reconstructed form, defines `game.execute_evidence_action(...)`, and records static definitions for the affected command functions rather than the remote migration's dynamic `pg_get_functiondef`/text-replacement procedure.
- The `execute_evidence_action` function body matches after normalising the dollar-quote delimiter, `search_path` declaration formatting, and typed-NULL default notation. The remote dynamic patch routes `record_scene_contamination`, `recover_scene_evidence`, and `transfer_scene_evidence` to that handler and registers those command types; the repository's static command handler contains the corresponding evidence-action routing.
- This repository file explicitly identifies itself as reconstructed from the live database and applied migration history. It should therefore be treated as a reconstructed implementation record, not proof that the original migration text has been recovered verbatim.
- The table definitions have been identified in both sources, but this pass has not yet completed a column-by-column and constraint-by-constraint comparison of the three table definitions or a full behavioural comparison of the dynamically patched functions.

Classification: **reconstructed-source candidate; evidence handler and command-routing intent align, but exact historical source and full DDL parity remain unverified**. Preserve the current file and remote record. Do not rewrite migration history or treat this pair as fully cleared until the remaining schema/function parity checks are complete.


## 19. Content-led review of version 20261120103219

The remote migration is a single dynamic `DO` block (484 characters) that changes the help text in the existing `game.submit_command` function. It replaces the generic “domain actions will be registered” note with the specific notice that scene contamination, evidence recovery and custody transfer commands are available.

The GitHub file is a reconstructed full-definition source (45,836 characters), not a copy of the original short `DO` block. Its static function definitions contain the updated help notice and all three evidence command names. This is consistent with the effect of the remote replacement, but the exact historical migration text is not preserved in the repository.

Classification: **reconstructed equivalent help/runtime state; original dynamic patch not reproduced verbatim**. Retain the file and remote history. This entry can be cleared as a source-form difference once the static command-function definition is included in the overall function parity review.


## 20. Content-led review of version 20261120103941

The remote migration is 7,007 characters; the GitHub file is a 11,972-character reconstructed DDL record. The two sources use different formatting and constraint-declaration styles, but their structural inventory was compared.

- Both define the same eight tables: `forensic_methods`, `forensic_requests`, `forensic_request_items`, `forensic_lab_submissions`, `forensic_examinations`, `forensic_findings`, `forensic_reviews`, and `forensic_reports`.
- Every table has the same column count and column names in both sources; no missing or extra columns were found.
- Both define the same seven indexes.
- Both enable row-level security on the same eight tables.
- The GitHub file is explicitly reconstructed from the applied live migration. This comparison establishes structural inventory parity, not byte-for-byte recovery of the original migration or a complete proof that every constraint expression is identical.

Classification: **reconstructed DDL with matching table/column/index/RLS inventory; constraint-expression parity remains to be checked in the final schema comparison**. Retain the repository file and remote history without changes.


## 21. Content-led review of version 20261120104208

The complete remote statement and GitHub migration file for `forensic_laboratory_commands_and_review_workflow` produce identical canonical SQL after normalising comments, whitespace, dollar-quote tags, typed-NULL defaults, and equivalent `search_path` declaration formatting.

Classification: **canonical SQL match after formatting/declaration normalisation**. No substantive divergence was identified in this pair. Retain the existing file and remote history.


## 22. Content-led review of version 20261120104301

The remote and repository versions of `index_forensic_and_scene_foreign_keys` define the same 29 indexes. Every index name matches; there are no missing or extra indexes. The only SQL difference is that the reconstructed GitHub file spells out PostgreSQL's default `USING btree` access method while the remote statement omits it. Removing that explicit default makes the complete statements identical after whitespace normalisation.

Classification: **equivalent index definitions; formatting/default-method difference only**. Retain the existing file and remote history.


## 23. Content-led review of version 20261120104502

The complete remote statement and GitHub file for `independent_forensic_method_validation_and_review_qualification` produce identical canonical SQL after normalising comments, whitespace, dollar-quote tags, typed-NULL defaults, and equivalent `search_path` declaration formatting.

Classification: **canonical SQL match after formatting/declaration normalisation**. No substantive divergence was identified in this pair. Retain the existing file and remote history.


## 24. Content-led review of version 20261120110935

The remote migration uses set-based CTE inserts; the GitHub reconstruction uses procedural loops. The source text is different, but both describe the same 24 neighbourhood centres, 24 local roads, four local junctions per neighbourhood, four internal local-road links plus one neighbourhood connector per centre, and three river bridges with west/east approaches and bridge/approach segments. Both also apply the same emergency/freight access update to roads `KNG-R008` and `KNG-R009`.

A read-only check of the live Kingswell city records returned:
- 27 target roads (24 local roads and 3 bridges)
- 102 target junctions (96 neighbourhood junctions and 6 bridge approaches)
- 129 target road segments (120 neighbourhood segments and 9 bridge/approach segments)
- 2 target freight-access segments on `KNG-R008` and `KNG-R009`

Classification: **different SQL implementation styles with matching intended network structure and live record counts**. The reconstruction is consistent with the applied network inventory; retain both records. This does not replace the later route-connectivity and reachability tests.


## 25. Content-led review of version 20261120111654

The remote migration and GitHub reconstruction use different procedural seed implementations, but the structural and seed-input inventories align.

- Both define `city_landmarks`, `property_addresses`, and `property_access_points`.
- Both define the same nine indexes.
- Both use the same 24 neighbourhood centre codes and a 1-to-20 lot loop.
- The live Kingswell city inventory currently contains 656 properties, 656 buildings, 26,888 building units, 656 addresses, 1,136 property access points, and 24 city landmarks.

Classification: **reconstructed seed implementation with matching table/index/centre/loop inventory and live object counts**. The two SQL implementations are not text-equivalent; retain both. Detailed row-by-row seed-value comparison remains part of the final data parity review.


## 26. Content-led review of version 20261120112406

The complete remote statement and GitHub file for `kingswell_police_facilities_patrol_sectors_and_beats` produce identical canonical SQL after normalising comments, whitespace, dollar-quote tags, typed-NULL defaults, and equivalent declaration formatting.

Classification: **canonical SQL match after formatting/declaration normalisation**. No substantive divergence was identified in this pair. Retain the existing file and remote history.


## 27. Content-led review of version 20261120112929

The remote and repository definitions of `game.calculate_road_route(...)` differ by one redundant assignment in the remote SQL: `v_duration := v_duration;`. Removing that no-op statement makes the complete canonical SQL identical after formatting/declaration normalisation.

Classification: **equivalent routing function; remote contains a redundant self-assignment only**. No functional difference was identified. Retain the existing file and remote history.


## 28. Content-led review of version 20261120125918

Three of the four function definitions match after normalisation: the append-only event trigger function, `game.release_case_investigator(...)`, and `game.get_case_assignments(...)`. The `game.assign_case_investigator(...)` function differs in assignment replacement rules.

- Remote SQL selects the active assignment for the same case and requested role, then releases that assignment before inserting the replacement. This applies to any requested role, not only `lead_investigator`.
- The GitHub file first checks whether the same person already holds that role. It replaces an existing assignment only when the requested role is `lead_investigator`; other investigator, supervisor and specialist assignments can coexist for different personnel.
- This changes gameplay behaviour: the remote historical function effectively permits only one active person per case/role, while the repository reconstruction allows multiple active non-lead personnel in the same role.
- Both sources still maintain the unique active lead constraint and the unique active case/person/role constraint.

Classification: **genuine function-level behavioural divergence; assignment multiplicity policy unresolved**. Preserve the remote history and repository file. Do not silently choose one policy or alter the live database; this needs an explicit design decision during the final runtime/schema reconciliation.


## 29. Content-led review of version 20261120125958 — assignment-policy follow-up

The remote and GitHub versions of `case_assignment_supporting_investigator_fix` produce identical canonical SQL after whitespace and dollar-quote normalisation.

The migration's explicit design note states that supporting investigators are concurrent assignments and only the lead-investigator role transfers ownership. Its function implements the same role-specific rule found in the GitHub reconstruction of version `20261120125918`: duplicate assignment of the same person/role is idempotent, and only a new lead-investigator assignment releases the previous lead.

This later applied migration therefore resolves the earlier historical divergence in the live migration sequence. The version `20261120125918` pair remains a genuine historical-source mismatch, but the subsequent remote migration restores the repository's role-specific assignment behaviour.

Classification: **exact canonical match; later migration explicitly supersedes the earlier assignment-policy discrepancy**. No live change is required.


## 30. Content-led review of version 20261120130042

The `game.release_case_investigator(...)` function body, `game.interpret_text_command(...)`, and `game.execute_text_command(...)` match between remote and repository sources after normalisation. The only substantive source-file difference is an additional repository permission statement revoking `service_role` access to the legacy five-argument `release_case_investigator` overload. The remote migration revokes public/anon/authenticated access to the new six-argument role-specific function and grants that new function to `service_role`, but does not include the legacy-overload revoke.

Classification: **matching runtime function bodies; repository adds a legacy-overload permission cleanup**. Treat the extra revoke as a separate permission delta for the final privilege audit, not as a function-body mismatch. Do not change live privileges during this reconciliation.


## 31. Content-led review of version 20261120130735

The remote migration name is `20261120_case_investigative_leads_and_enquiries`, while the GitHub filename omits that date prefix. The complete SQL is canonically identical after normalising formatting and declaration syntax.

Classification: **migration-name prefix difference only; exact canonical SQL match**. No source or runtime change is needed.


## 32. Content-led review of version 20261120131748

The remote and repository sources differ in table creation order and reconstructed constraint formatting, but their object inventories and function bodies were compared.

- Both define the same five tables, three sequences, ten indexes, and five append-only triggers.
- All five tables have matching column counts and column names.
- Both enable row-level security on the same five tables.
- All ten function definitions match after normalising dollar-quote delimiters and declaration formatting, including the command interpreter/executor, interview lifecycle, transcript, witness-statement lifecycle and read functions.

Classification: **reconstructed DDL with matching table/column/index/sequence/trigger/RLS inventory and identical canonical function bodies**. Constraint-expression parity remains part of the final schema check. Retain the repository file and remote history.


## 33. Content-led review of suspect-interview migrations 20261120132555, 20261120132622 and 20261120132728

### 33.1 Version 20261120132555

- Both sources define the same two suspect-interview tables with matching column counts and names, the same two indexes, the same two RLS-enabled tables, and the same append-only history trigger function.
- The response-assessment, review, and immutable-history trigger functions match. The `record_case_suspect_interview` function differs: the GitHub reconstruction adds a check that the case exists and is not closed before suspect-interview classification. The remote version at 20261120132555 does not yet contain that guard.
- Classification: **later case-state guard appears early in the repository reconstruction; the remote history adds it in a subsequent migration**.

### 33.2 Version 20261120132622

- The interpreter function matches.
- The GitHub reconstruction's `execute_text_command` also includes the help-command augmentation listing the three suspect-interview commands. The remote 20261120132622 version does not yet include that help branch.
- Classification: **later help integration appears early in the repository reconstruction; the remote history adds it in the next migration**.

### 33.3 Version 20261120132728

- The remote migration adds both the closed/missing-case guard to `record_case_suspect_interview` and the help-command augmentation to `execute_text_command`.
- Both complete function bodies match the corresponding GitHub migration file after formatting/declaration normalisation.
- This later remote migration therefore accounts for both differences observed in the two earlier pairs.

Overall classification: **the 20261120132555 and 20261120132622 repository files contain later function state ahead of its historical remote migration version; the subsequent 20261120132728 migration matches and formally introduces those changes**. The final runtime state is represented by the later migration. Preserve the history and do not backdate or rewrite the earlier files.


## 34. Content-led review of version 20261120133310

The remote and GitHub sources differ in DDL reconstruction and formatting, but the main object and function inventories align.

- Both define the same three tables: `case_account_comparisons`, `case_account_comparison_assessments`, and `case_account_comparison_evidence_links`. All three have matching column counts and column names.
- Both define the same seven indexes and enable row-level security on the same three tables.
- All five function bodies match after normalising dollar-quote delimiters and typed-NULL defaults: append-only mutation guard, comparison recording, assessment, evidence linking, and comparison retrieval.

Classification: **reconstructed DDL with matching table/column/index/RLS inventory and identical canonical function bodies**. Constraint-expression parity remains part of the final schema check. Retain both sources.
