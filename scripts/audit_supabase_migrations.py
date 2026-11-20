#!/usr/bin/env python3
"""Read-only comparison of Supabase migration history with repository SQL files."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from pathlib import Path


def canonical_sql(source: str) -> str:
    """Remove SQL comments while preserving quoted strings and dollar-quoted bodies."""
    out: list[str] = []
    i = 0
    n = len(source)
    state = "normal"
    block_depth = 0
    dollar_tag = ""

    while i < n:
        ch = source[i]
        nxt = source[i + 1] if i + 1 < n else ""

        if state == "line_comment":
            if ch == "\n":
                out.append("\n")
                state = "normal"
            i += 1
            continue

        if state == "block_comment":
            if ch == "/" and nxt == "*":
                block_depth += 1
                i += 2
            elif ch == "*" and nxt == "/":
                block_depth -= 1
                i += 2
                if block_depth == 0:
                    out.append(" ")
                    state = "normal"
            else:
                if ch == "\n":
                    out.append("\n")
                i += 1
            continue

        if state == "single_quote":
            out.append(ch)
            if ch == "'" and nxt == "'":
                out.append(nxt)
                i += 2
            elif ch == "\\" and i + 1 < n:
                out.append(nxt)
                i += 2
            else:
                if ch == "'":
                    state = "normal"
                i += 1
            continue

        if state == "double_quote":
            out.append(ch)
            if ch == '"' and nxt == '"':
                out.append(nxt)
                i += 2
            else:
                if ch == '"':
                    state = "normal"
                i += 1
            continue

        if state == "dollar_quote":
            if source.startswith(dollar_tag, i):
                out.append("$")
                i += len(dollar_tag)
                state = "normal"
            else:
                out.append(ch)
                i += 1
            continue

        if ch == "-" and nxt == "-":
            state = "line_comment"
            i += 2
        elif ch == "/" and nxt == "*":
            state = "block_comment"
            block_depth = 1
            i += 2
        elif ch == "'":
            out.append(ch)
            state = "single_quote"
            i += 1
        elif ch == '"':
            out.append(ch)
            state = "double_quote"
            i += 1
        elif ch == "$":
            match = re.match(r"\$[A-Za-z_][A-Za-z_0-9]*\$|\$\$", source[i:])
            if match:
                dollar_tag = match.group(0)
                out.append("$")
                i += len(dollar_tag)
                state = "dollar_quote"
            else:
                out.append(ch)
                i += 1
        else:
            out.append(ch)
            i += 1

    return re.sub(r"\s+", " ", "".join(out)).strip()


def digest(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def normalized_name(name: str) -> str:
    return re.sub(r"^\d{8,14}_", "", name)


def load_local(directory: Path) -> list[dict]:
    result = []
    for path in sorted(directory.glob("*.sql")):
        stem = path.name[:-4]
        version = stem[:14]
        name = stem[15:] if len(stem) > 15 and stem[14] == "_" else stem
        sql = canonical_sql(path.read_text(encoding="utf-8-sig"))
        result.append({
            "version": version,
            "name": name,
            "normalized_name": normalized_name(name),
            "file": path.name,
            "sha256": digest(sql),
            "canonical_chars": len(sql),
        })
    return result


def load_remote(path: Path) -> list[dict]:
    rows = json.loads(path.read_text(encoding="utf-8"))
    result = []
    for row in rows:
        statements = row.get("statements") or []
        sql = canonical_sql("\n".join(statements))
        name = row.get("name") or ""
        result.append({
            "version": str(row["version"]),
            "name": name,
            "normalized_name": normalized_name(name),
            "sha256": digest(sql),
            "canonical_chars": len(sql),
        })
    return result


def reconcile(local: list[dict], remote: list[dict]) -> dict:
    local_by_hash: dict[str, list[dict]] = {}
    remote_by_hash: dict[str, list[dict]] = {}
    local_by_version = {item["version"]: item for item in local}
    remote_by_version = {item["version"]: item for item in remote}

    for item in local:
        local_by_hash.setdefault(item["sha256"], []).append(item)
    for item in remote:
        remote_by_hash.setdefault(item["sha256"], []).append(item)

    content_matches = []
    remote_without_content_match = []
    for item in remote:
        candidates = local_by_hash.get(item["sha256"], [])
        if candidates:
            for candidate in candidates:
                content_matches.append({
                    "remote_version": item["version"],
                    "remote_name": item["name"],
                    "repository_file": candidate["file"],
                    "repository_version": candidate["version"],
                    "same_version": item["version"] == candidate["version"],
                    "same_normalized_name": item["normalized_name"] == candidate["normalized_name"],
                })
        else:
            remote_without_content_match.append({
                "version": item["version"],
                "name": item["name"],
                "sha256": item["sha256"],
                "canonical_chars": item["canonical_chars"],
            })

    local_without_content_match = [
        {"version": item["version"], "file": item["file"], "sha256": item["sha256"]}
        for item in local if item["sha256"] not in remote_by_hash
    ]

    version_collisions = []
    for version in sorted(set(local_by_version) & set(remote_by_version)):
        l_item = local_by_version[version]
        r_item = remote_by_version[version]
        if l_item["sha256"] != r_item["sha256"]:
            version_collisions.append({
                "version": version,
                "repository_file": l_item["file"],
                "repository_name": l_item["name"],
                "remote_name": r_item["name"],
                "repository_sha256": l_item["sha256"],
                "remote_sha256": r_item["sha256"],
            })

    local_names = {item["normalized_name"] for item in local}
    remote_names = {item["normalized_name"] for item in remote}
    return {
        "counts": {
            "repository_files": len(local),
            "remote_records": len(remote),
            "exact_version_matches": len(set(local_by_version) & set(remote_by_version)),
            "repository_only_versions": len(set(local_by_version) - set(remote_by_version)),
            "remote_only_versions": len(set(remote_by_version) - set(local_by_version)),
            "shared_normalized_names": len(local_names & remote_names),
            "remote_names_without_repository_match": len(remote_names - local_names),
            "repository_names_without_remote_match": len(local_names - remote_names),
            "remote_records_with_content_match": len({m["remote_version"] for m in content_matches}),
            "remote_records_without_content_match": len(remote_without_content_match),
            "repository_files_without_content_match": len(local_without_content_match),
            "same_version_different_content": len(version_collisions),
        },
        "content_matches": content_matches,
        "same_version_different_content": version_collisions,
        "remote_without_content_match": remote_without_content_match,
        "repository_without_content_match": local_without_content_match,
    }


def render_markdown(report: dict) -> str:
    c = report["counts"]
    lines = [
        "# Supabase migration content reconciliation",
        "",
        "Generated by a read-only comparison of the supabase_migrations.schema_migrations statements array with database/migrations/*.sql.",
        "SQL comments are removed with quote-aware parsing, dollar-quote tags are normalised, and whitespace is normalised before SHA-256 comparison. This is a canonical-text comparison, not a PostgreSQL semantic-equivalence proof.",
        "",
        "## Summary",
        "",
        "| Measure | Count |",
        "|---|---:|",
    ]
    for key, label in [
        ("repository_files", "Repository migration files"),
        ("remote_records", "Applied Supabase records"),
        ("exact_version_matches", "Exact version identifiers"),
        ("repository_only_versions", "Repository-only versions"),
        ("remote_only_versions", "Supabase-only versions"),
        ("shared_normalized_names", "Shared normalised names"),
        ("remote_names_without_repository_match", "Remote names without repository match"),
        ("repository_names_without_remote_match", "Repository names without remote match"),
        ("remote_records_with_content_match", "Remote records with exact canonical SQL match"),
        ("remote_records_without_content_match", "Remote records without exact canonical SQL match"),
        ("repository_files_without_content_match", "Repository files without exact canonical SQL match"),
        ("same_version_different_content", "Same-version/different-content collisions"),
    ]:
        lines.append(f"| {label} | {c[key]} |")

    lines += ["", "## Same-version, different-content collisions", ""]
    if report["same_version_different_content"]:
        lines += ["| Version | Repository file | Repository name | Remote name |", "|---|---|---|---|"]
        for item in report["same_version_different_content"]:
            lines.append(f"| {item['version']} | {item['repository_file']} | {item['repository_name']} | {item['remote_name']} |")
    else:
        lines.append("None.")

    lines += ["", "## Remote records without an exact canonical SQL match", ""]
    if report["remote_without_content_match"]:
        lines += ["| Version | Remote name | Canonical characters |", "|---|---|---:|"]
        for item in report["remote_without_content_match"]:
            lines.append(f"| {item['version']} | {item['name']} | {item['canonical_chars']} |")
    else:
        lines.append("None.")

    lines += ["", "## Repository files without an exact canonical SQL match", ""]
    if report["repository_without_content_match"]:
        lines += ["| Version | Repository file |", "|---|---|"]
        for item in report["repository_without_content_match"]:
            lines.append(f"| {item['version']} | {item['file']} |")
    else:
        lines.append("None.")

    lines += [
        "",
        "## Exact content matches",
        "",
        "The JSON companion contains every exact canonical match, including cases where the version or migration name differs.",
        "",
        "## Safety",
        "",
        "This audit performs SELECT-only access to migration history. It does not modify migration records, database schema, game data, permissions, or repository migration files.",
        "Do not deploy, repair, reset, rename, or replay migrations solely from this report. Review every mismatch and compare live schema state before deciding on a reconciliation plan.",
        "",
    ]
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--remote", required=True, type=Path)
    parser.add_argument("--migrations-dir", required=True, type=Path)
    parser.add_argument("--markdown", required=True, type=Path)
    parser.add_argument("--json", required=True, type=Path)
    args = parser.parse_args()

    local = load_local(args.migrations_dir)
    remote = load_remote(args.remote)
    report = reconcile(local, remote)
    args.markdown.write_text(render_markdown(report), encoding="utf-8")
    args.json.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(json.dumps(report["counts"], sort_keys=True))


if __name__ == "__main__":
    main()
