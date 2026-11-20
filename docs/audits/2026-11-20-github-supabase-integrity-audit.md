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
| GitHub Actions workflows | One: `.github/workflows/deploy-pages.yml` |
| Existing workflow purpose | Publishes the browser test centre to GitHub Pages |
| Supabase deployment in existing workflow | None |
| Supabase CLI project configuration | No `supabase/config.toml` found |
| Migration directory | `database/migrations/` |
| Test directory | `database/tests/` |

The Pages workflow does not use `SUPABASE_ACCESS_TOKEN` or `SUPABASE_DB_PASSWORD`. Their presence in repository Actions secrets was confirmed by the user, but their values were never accessed or displayed.

## 3. Migration reconciliation

| Measure | Count |
|---|---:|
| SQL migration files in GitHub | 212 |
| Applied migration records in Supabase | 225 |
| Records matching by normalised migration name | 208 |
| Name matches with the exact same version timestamp | 134 |
| Name matches with different version timestamps | 74 |
| Supabase records with no matching GitHub migration name | 17 |
| GitHub migration files with no matching Supabase migration name | 3 |

The 74 migrations with matching names but different version timestamps require particular attention. Supabase uses migration versions as well as names. A name match does not make a different version safe to deploy.

The 17 unmatched Supabase migration names and three unmatched repository migration names must be mapped to their actual SQL files, including renamed or retimestamped candidates. The Supabase migration history provides version/name records, not a checksum or copy of each historical SQL file, so byte-for-byte comparison with the SQL originally applied is not currently possible from migration history alone.

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

The following existing repository tests were executed against the connected database:

| Test | Result |
|---|---|
| `database/tests/kingswell_correctional_runtime.sql` | Passed; rollback-only parser/runtime assertions returned without SQL error |
| `database/tests/bp04_organisation_dossier_regression.sql` | Passed; read-only assertions returned without SQL error |
| `database/tests/kingswell_bp03_live_population_acceptance.sql` | Read-only checks executed without SQL error; exact acceptance metrics separately queried and recorded above |

No persistent test fixtures were intentionally created. The correctional runtime regression explicitly begins a transaction and rolls it back.

These results validate only the tested slices; they do not prove every system or every migration is correct.

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
