import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import audit_supabase_migrations as audit


class ReconciliationEmptySqlTests(unittest.TestCase):
    def local_item(self, version, filename, sql):
        canonical = audit.canonical_sql(sql)
        return {
            "version": version,
            "name": filename.removesuffix(".sql"),
            "normalized_name": filename.removesuffix(".sql"),
            "file": filename,
            "sha256": audit.digest(canonical),
            "canonical_chars": len(canonical),
        }

    def remote_item(self, version, name, sql):
        canonical = audit.canonical_sql(sql)
        return {
            "version": version,
            "name": name,
            "normalized_name": name,
            "sha256": audit.digest(canonical),
            "canonical_chars": len(canonical),
        }

    def test_comment_only_sql_is_not_a_content_match(self):
        local = [
            self.local_item("20261120010000", "20261120010000_comment_only.sql", "-- local note\n"),
            self.local_item("20261120020000", "20261120020000_real.sql", "SELECT 1;"),
        ]
        remote = [
            self.remote_item("20261120030000", "remote_comment_only", "-- remote note\n"),
            self.remote_item("20261120040000", "remote_real", "SELECT 1;"),
        ]

        report = audit.reconcile(local, remote)

        self.assertEqual(len(report["content_matches"]), 1)
        self.assertEqual(report["content_matches"][0]["remote_version"], "20261120040000")
        self.assertEqual(report["content_matches"][0]["repository_version"], "20261120020000")
        self.assertEqual(report["counts"]["remote_records_with_content_match"], 1)
        self.assertEqual(report["counts"]["remote_records_with_empty_canonical_sql"], 1)
        self.assertEqual(report["counts"]["repository_files_with_empty_canonical_sql"], 1)
        self.assertEqual(len(report["remote_empty_canonical_sql"]), 1)
        self.assertEqual(len(report["repository_empty_canonical_sql"]), 1)

    def test_empty_sql_is_not_reported_as_unmatched_nonempty_sql(self):
        local = [self.local_item("001", "001_note.sql", "-- only a note")]
        remote = [self.remote_item("002", "remote_note", "-- another note")]

        report = audit.reconcile(local, remote)

        self.assertEqual(report["content_matches"], [])
        self.assertEqual(report["remote_without_content_match"], [])
        self.assertEqual(report["repository_without_content_match"], [])
        self.assertEqual(report["counts"]["remote_records_without_content_match"], 0)
        self.assertEqual(report["counts"]["repository_files_without_content_match"], 0)

    def test_same_version_empty_vs_nonempty_remains_a_collision(self):
        local = [self.local_item("003", "003_note.sql", "-- only a note")]
        remote = [self.remote_item("003", "remote_real", "SELECT 3;")]

        report = audit.reconcile(local, remote)

        self.assertEqual(report["counts"]["same_version_different_content"], 1)
        self.assertEqual(report["same_version_different_content"][0]["repository_canonical_chars"], 0)
        self.assertGreater(report["same_version_different_content"][0]["remote_canonical_chars"], 0)

    def test_comment_only_canonical_sql_is_empty(self):
        self.assertEqual(audit.canonical_sql("-- note\n/* another note */"), "")


if __name__ == "__main__":
    unittest.main()
