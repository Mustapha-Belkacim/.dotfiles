#!/usr/bin/env python3
"""Collect sprint commit data across repos and group it by issue-tracker key.

Usage:
  collect_commits.py --since 2026-08-11 --until 2026-08-24 \
      [--repos ~/projects/repo-a ~/projects/repo-b] \
      [--scan-root ~/projects] [--max-depth 4] \
      [--author me|<email-or-substring>] \
      [--branches all|current] \
      [--key-prefix ABC] \
      [--json out.json] [--markdown out.md]

Defaults come from the skill's config.env (or $SPRINT_READOUT_CONFIG):
REPO_SCAN_ROOT, REPO_MAX_DEPTH, GIT_AUTHOR_EMAIL, ISSUE_KEY_PREFIX.
Anything still unset falls back to ~/projects, depth 4, each repo's own
`git config user.email`, all branches, and ABC-#### keys.

Outputs a JSON blob and a human-readable markdown digest:
  - per-ticket: commits, subjects, repos, files changed, insertions/deletions
  - per-repo totals
  - sprint totals (KPI numbers for the deck)
  - commits with no ticket key (flagged, they usually need a manual line)
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

CONFIG_KEYS = ("REPO_SCAN_ROOT", "REPO_MAX_DEPTH", "GIT_AUTHOR_EMAIL",
               "ISSUE_KEY_PREFIX")


def load_config() -> dict[str, str]:
    """Read KEY=value pairs from the skill's config.env, if it exists.

    Real environment variables win, so a caller can always override.
    """
    path = Path(os.environ.get("SPRINT_READOUT_CONFIG",
                               Path(__file__).resolve().parent.parent / "config.env"))
    cfg: dict[str, str] = {}
    if path.is_file():
        for line in path.read_text().splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, val = line.partition("=")
            val = val.strip().strip('"').strip("'")
            cfg[key.strip()] = os.path.expandvars(os.path.expanduser(val))
    for key in CONFIG_KEYS:
        if os.environ.get(key):
            cfg[key] = os.environ[key]
    return cfg


SEP = "\x1e"  # record separator
FIELD = "\x1f"  # field separator


def sh(args: list[str], cwd: Path) -> str:
    res = subprocess.run(args, cwd=cwd, capture_output=True, text=True)
    if res.returncode != 0:
        return ""
    return res.stdout


SKIP_DIRS = {"node_modules", ".venv", "venv", "__pycache__", ".terraform",
             "dist", "build", "target", ".idea", ".vscode", "vendor"}


def find_repos(scan_root: Path, max_depth: int) -> list[Path]:
    """Walk scan_root up to max_depth looking for git repos (dirs or worktrees)."""
    repos: list[Path] = []

    def walk(d: Path, depth: int) -> None:
        if depth > max_depth:
            return
        if (d / ".git").exists():
            repos.append(d)
            return  # don't descend into a repo's submodule-like children
        try:
            children = sorted(c for c in d.iterdir() if c.is_dir())
        except (PermissionError, OSError):
            return
        for c in children:
            if c.name in SKIP_DIRS or c.name.startswith("."):
                continue
            walk(c, depth + 1)

    walk(scan_root, 0)
    return repos


NUMSTAT_RE = re.compile(r"^(\d+|-)\t(\d+|-)\t(.+)$")


def collect_repo(repo: Path, label: str, since: str, until: str, author: str | None,
                 branches: str, key_re: re.Pattern) -> list[dict]:
    # SEP must lead the record: --numstat output trails the format, so a trailing
    # separator would glue one commit's diffstat onto the next commit's header.
    fmt = SEP + FIELD.join(["%H", "%ad", "%an", "%ae", "%s", "%b"])
    args = ["git", "log", f"--since={since} 00:00", f"--until={until} 23:59",
            "--no-merges", "--date=short", f"--pretty=format:{fmt}", "--numstat"]
    if branches == "all":
        args.insert(2, "--all")
    if author:
        args.append(f"--author={author}")
    raw = sh(args, repo)
    if not raw.strip():
        return []

    commits = []
    for record in raw.split(SEP):
        if not record.strip():
            continue
        parts = record.split(FIELD)
        if len(parts) < 6:
            continue
        sha, date, name, email, subject = (parts[0], parts[1], parts[2],
                                           parts[3], parts[4])
        blob_lines = parts[5].splitlines()
        while blob_lines and not blob_lines[-1].strip():
            blob_lines.pop()

        # numstat rows are appended after the body — peel them off the tail
        stat_lines = []
        while blob_lines and NUMSTAT_RE.match(blob_lines[-1]):
            stat_lines.append(blob_lines.pop())
        body = "\n".join(blob_lines)

        added = deleted = files = 0
        touched = []
        for line in stat_lines:
            cols = line.split("\t")
            if len(cols) != 3:
                continue
            a, d, path = cols
            files += 1
            touched.append(path)
            added += int(a) if a.isdigit() else 0
            deleted += int(d) if d.isdigit() else 0

        keys = sorted(set(m.group(0).upper() for m in key_re.finditer(subject + " " + body)))
        subject_keys = [m.group(0).upper() for m in key_re.finditer(subject)]
        primary = subject_keys[0] if subject_keys else (keys[0] if keys else None)
        commits.append({
            "sha": sha,
            "date": date,
            "author": name,
            "email": email,
            "subject": subject.strip(),
            "body": body.strip(),
            "tickets": keys,
            "primary_ticket": primary,
            "files": files,
            "insertions": added,
            "deletions": deleted,
            "paths": touched[:50],
            "repo": label,
        })
    return commits


def main() -> int:
    cfg = load_config()
    p = argparse.ArgumentParser()
    p.add_argument("--since", required=True)
    p.add_argument("--until", required=True)
    p.add_argument("--repos", nargs="*", default=[])
    p.add_argument("--scan-root", default=cfg.get("REPO_SCAN_ROOT") or
                   str(Path.home() / "projects"))
    p.add_argument("--max-depth", type=int,
                   default=int(cfg.get("REPO_MAX_DEPTH") or 4),
                   help="how deep under --scan-root to look for git repos")
    p.add_argument("--author", default=cfg.get("GIT_AUTHOR_EMAIL") or "me")
    p.add_argument("--branches", choices=["all", "current"], default="all")
    p.add_argument("--key-prefix", default=cfg.get("ISSUE_KEY_PREFIX") or "ABC")
    p.add_argument("--json", dest="json_out", default="")
    p.add_argument("--markdown", dest="md_out", default="")
    args = p.parse_args()

    key_re = re.compile(rf"\b{args.key_prefix}-\d+\b", re.IGNORECASE)

    if args.repos:
        root = None
        repos = [Path(os.path.expanduser(r)).resolve() for r in args.repos]
    else:
        root = Path(os.path.expanduser(args.scan_root)).resolve()
        if not root.is_dir():
            print(f"scan root not found: {root}", file=sys.stderr)
            return 1
        repos = find_repos(root, args.max_depth)

    all_commits: list[dict] = []
    for repo in repos:
        if not (repo / ".git").exists():
            continue
        label = repo.name
        if root is not None:
            try:
                label = str(repo.relative_to(root))
            except ValueError:
                pass
        author = args.author
        if author == "me":
            author = sh(["git", "config", "user.email"], repo).strip() or None
        all_commits.extend(collect_repo(repo, label, args.since, args.until, author,
                                        args.branches, key_re))

    # A commit can appear in several checkouts (worktrees, clones) and, after a rebase
    # or cherry-pick, under several SHAs. Collapse both so KPI numbers aren't inflated.
    deduped: list[dict] = []
    seen_shas: set[str] = set()
    by_identity: dict[tuple, dict] = {}
    collapsed = 0
    for c in all_commits:
        if c["sha"] in seen_shas:
            continue
        seen_shas.add(c["sha"])
        identity = (c["email"], c["date"], c["subject"], c["insertions"], c["deletions"])
        if identity in by_identity:
            by_identity[identity].setdefault("duplicate_shas", []).append(c["sha"][:10])
            collapsed += 1
            continue
        c["sha"] = c["sha"][:10]
        by_identity[identity] = c
        deduped.append(c)
    all_commits = deduped

    by_ticket: dict[str, dict] = defaultdict(
        lambda: {"commits": [], "repos": set(), "files": 0, "insertions": 0, "deletions": 0})
    untagged: list[dict] = []
    by_repo: dict[str, dict] = defaultdict(
        lambda: {"commits": 0, "tickets": set(), "files": 0, "insertions": 0, "deletions": 0})

    for c in all_commits:
        r = by_repo[c["repo"]]
        r["commits"] += 1
        r["files"] += c["files"]
        r["insertions"] += c["insertions"]
        r["deletions"] += c["deletions"]
        r["tickets"].update(c["tickets"])
        if not c["tickets"]:
            untagged.append(c)
        for k in c["tickets"]:
            t = by_ticket[k]
            t["commits"].append({"sha": c["sha"], "date": c["date"],
                                 "repo": c["repo"], "subject": c["subject"]})
            t["repos"].add(c["repo"])
            t["files"] += c["files"]
            t["insertions"] += c["insertions"]
            t["deletions"] += c["deletions"]

    def key_num(k: str) -> int:
        m = re.search(r"(\d+)$", k)
        return int(m.group(1)) if m else 0

    result = {
        "sprint": {"since": args.since, "until": args.until},
        "totals": {
            "commits": len(all_commits),
            "tickets": len(by_ticket),
            "repos": len([r for r in by_repo if by_repo[r]["commits"]]),
            "files_touched": sum(c["files"] for c in all_commits),
            "insertions": sum(c["insertions"] for c in all_commits),
            "deletions": sum(c["deletions"] for c in all_commits),
            "untagged_commits": len(untagged),
            "duplicates_collapsed": collapsed,
        },
        "tickets": {
            k: {**v, "repos": sorted(v["repos"]), "commit_count": len(v["commits"])}
            for k, v in sorted(by_ticket.items(), key=lambda kv: key_num(kv[0]))
        },
        "repos": {
            k: {**v, "tickets": sorted(v["tickets"]), "ticket_count": len(v["tickets"])}
            for k, v in sorted(by_repo.items()) if v["commits"]
        },
        "untagged": untagged,
        "commits": all_commits,
    }

    payload = json.dumps(result, indent=2)
    if args.json_out:
        Path(args.json_out).write_text(payload)
    else:
        print(payload)

    if args.md_out:
        lines = [f"# Sprint commit digest · {args.since} → {args.until}", ""]
        t = result["totals"]
        lines += [
            f"- **{t['commits']}** commits · **{t['tickets']}** tickets · "
            f"**{t['repos']}** repos",
            f"- **{t['files_touched']}** file changes · +{t['insertions']} / -{t['deletions']}",
            f"- **{t['untagged_commits']}** commits without a ticket key "
            f"· **{t['duplicates_collapsed']}** duplicates collapsed", "",
            "## Per ticket", "",
        ]
        for k, v in result["tickets"].items():
            lines.append(f"### {k} · {v['commit_count']} commit(s) · "
                         f"{', '.join(v['repos'])} · +{v['insertions']}/-{v['deletions']}")
            for c in v["commits"]:
                lines.append(f"- `{c['sha']}` {c['date']} [{c['repo']}] {c['subject']}")
            lines.append("")
        lines += ["## Per repo", "", "| Repo | Commits | Tickets | Files | +/− |",
                  "|---|---:|---:|---:|---|"]
        for k, v in result["repos"].items():
            lines.append(f"| {k} | {v['commits']} | {v['ticket_count']} | "
                         f"{v['files']} | +{v['insertions']}/-{v['deletions']} |")
        if untagged:
            lines += ["", "## Untagged commits (need a manual line)", ""]
            for c in untagged:
                lines.append(f"- `{c['sha']}` {c['date']} [{c['repo']}] {c['subject']}")
        Path(args.md_out).write_text("\n".join(lines) + "\n")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
