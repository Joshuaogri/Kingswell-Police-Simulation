# Superseded, unapplied migration drafts

These 36 SQL files were previously present in the active `database/migrations/` directory but do not appear as applied records in the live Supabase migration history and do not match the SQL statements of any applied migration. They have been preserved here, unchanged, to retain development history while preventing Supabase CLI from treating them as pending migrations.

Do not execute or move these files back into the active migration directory. The authoritative applied SQL sources are the 228 files in `database/migrations/`, reconciled against `supabase_migrations.schema_migrations` on 2026-11-21. Any future schema change must be authored as a new migration with a new version; it must not reuse or replay an archived draft.
