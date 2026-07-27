#!/usr/bin/env python3
"""Executable regression oracle for the planning evidence-authority contract.

The plugin is instruction-driven, so this harness proves the contract's state transitions against real
temporary Git histories; it does not claim that a particular model followed the instructions. A cold
plugin run remains the live acceptance test.
"""

from __future__ import annotations

import subprocess
import tempfile
import unittest
from dataclasses import dataclass
from hashlib import sha256
from pathlib import Path


ACTIVE = "active"
CONTESTED = "contested"
INVALID = "invalid"
SUPERSEDED = "superseded"
UNKNOWN = "unknown"

USER_INTENT = "user-intent"
CURRENT_REPO = "current-repo-source"
CURRENT_EXTERNAL = "current-external-primary"
HISTORICAL = "historical/tombstoned"
INFERENCE = "inference"
REPORT = "report/memory"


@dataclass(frozen=True)
class Premise:
    premise_id: str
    claim: str
    authority: str | None
    source_ref: str
    status: str


@dataclass(frozen=True)
class InvalidationReceipt:
    premise_id: str
    trigger: str
    previous_status: str
    new_status: str
    descendants: tuple[str, ...]
    nearest_valid_frontier: str


def run(repo: Path, *args: str) -> str:
    return subprocess.run(
        args,
        cwd=repo,
        check=True,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    ).stdout.strip()


def write(repo: Path, relative_path: str, body: str) -> None:
    path = repo / relative_path
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(body)


def commit(repo: Path, message: str) -> str:
    run(repo, "git", "add", "-A")
    run(repo, "git", "commit", "-m", message)
    return run(repo, "git", "rev-parse", "HEAD")


def init_repo() -> tempfile.TemporaryDirectory[str]:
    temp = tempfile.TemporaryDirectory()
    repo = Path(temp.name)
    run(repo, "git", "init", "-q")
    run(repo, "git", "config", "user.name", "Regression")
    run(repo, "git", "config", "user.email", "regression@example.com")
    return temp


def exists_at_head(repo: Path, path: str) -> bool:
    result = subprocess.run(
        ("git", "cat-file", "-e", f"HEAD:{path}"),
        cwd=repo,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    return result.returncode == 0


def was_deleted(repo: Path, path: str) -> bool:
    output = run(repo, "git", "log", "--diff-filter=D", "--format=%H", "--", path)
    return bool(output)


def exact_ref(repo: Path, path: str) -> str:
    head = run(repo, "git", "rev-parse", "HEAD")
    status = run(repo, "git", "status", "--porcelain", "--", path)
    if not status:
        return f"{path}@{head}"
    digest = sha256((repo / path).read_bytes()).hexdigest()[:12]
    return f"{path}@{head}+worktree:{digest}"


def classify_canon_candidate(repo: Path, path: str) -> Premise:
    head = run(repo, "git", "rev-parse", "HEAD")
    current_pointer = (repo / "CANON").read_text().strip()
    worktree_exists = (repo / path).is_file()
    head_exists = exists_at_head(repo, path)
    if path == current_pointer and worktree_exists:
        source_ref = f"{exact_ref(repo, 'CANON')} -> {exact_ref(repo, path)}"
        return Premise("P-canon", f"{path} is current canon", CURRENT_REPO, source_ref, ACTIVE)
    if was_deleted(repo, path) and not head_exists:
        deletion = run(repo, "git", "log", "-1", "--diff-filter=D", "--format=%H", "--", path)
        return Premise(
            "P-canon",
            f"{path} is current canon",
            HISTORICAL,
            f"{path}@deleted:{deletion}",
            SUPERSEDED,
        )
    if path == current_pointer and not worktree_exists:
        return Premise("P-canon", f"{path} is current canon", None, f"{path}@{head}", UNKNOWN)
    if worktree_exists:
        return Premise(
            "P-canon",
            f"{path} is current canon",
            CURRENT_REPO,
            exact_ref(repo, path),
            SUPERSEDED,
        )
    return Premise("P-canon", f"{path} is current canon", None, f"{path}@{head}", UNKNOWN)


def may_unlock(premise: Premise, claim_domain: str) -> bool:
    owners = {
        "planning-territory": USER_INTENT,
        "repo-fact": CURRENT_REPO,
        "external-fact": CURRENT_EXTERNAL,
    }
    return premise.status == ACTIVE and premise.authority == owners[claim_domain]


def plan_entry(user_intent: Premise | None) -> tuple[str, tuple[str, ...]]:
    if user_intent is None or not may_unlock(user_intent, "planning-territory"):
        return "batched-outcome-interview", ()
    return "route-supplied-intent", ("planning-state",)


def invalidate(
    premise: Premise,
    trigger: str,
    derived_from: dict[str, set[str]],
    nearest_valid_frontier: str,
) -> InvalidationReceipt:
    invalidated = {premise.premise_id}
    descendants: list[str] = []
    changed = True
    while changed:
        changed = False
        for artifact, parents in derived_from.items():
            if artifact not in invalidated and parents & invalidated:
                invalidated.add(artifact)
                descendants.append(artifact)
                changed = True
    return InvalidationReceipt(
        premise_id=premise.premise_id,
        trigger=trigger,
        previous_status=premise.status,
        new_status=INVALID,
        descendants=tuple(descendants),
        nearest_valid_frontier=nearest_valid_frontier,
    )


class EvidenceAuthorityRegression(unittest.TestCase):
    def test_deleted_file_in_history_is_tombstoned(self) -> None:
        with init_repo() as temp:
            repo = Path(temp)
            write(repo, "design/old.html", "old exploration")
            commit(repo, "add exploration")
            (repo / "design/old.html").unlink()
            write(repo, "design/current.html", "current walkthrough")
            write(repo, "CANON", "design/current.html\n")
            commit(repo, "replace exploration with current canon")

            old = classify_canon_candidate(repo, "design/old.html")
            current = classify_canon_candidate(repo, "design/current.html")

            self.assertEqual((old.authority, old.status), (HISTORICAL, SUPERSEDED))
            self.assertFalse(may_unlock(old, "repo-fact"))
            self.assertTrue(may_unlock(current, "repo-fact"))

    def test_changed_canon_pointer_supersedes_old_source_and_descendants(self) -> None:
        with init_repo() as temp:
            repo = Path(temp)
            write(repo, "design/a.html", "A")
            write(repo, "CANON", "design/a.html\n")
            commit(repo, "point canon at A")
            write(repo, "design/b.html", "B")
            write(repo, "CANON", "design/b.html\n")
            commit(repo, "point canon at B")

            old = classify_canon_candidate(repo, "design/a.html")
            new = classify_canon_candidate(repo, "design/b.html")
            receipt = invalidate(
                Premise("P-old", old.claim, old.authority, old.source_ref, ACTIVE),
                "CANON now points at design/b.html",
                {"R-1": {"P-old"}, "D-1": {"R-1"}, "M-1": {"D-1"}},
                "re-open visual direction",
            )

            self.assertEqual(old.status, SUPERSEDED)
            self.assertTrue(may_unlock(new, "repo-fact"))
            self.assertEqual(receipt.descendants, ("R-1", "D-1", "M-1"))

    def test_dirty_worktree_deletion_is_not_active_head_evidence(self) -> None:
        with init_repo() as temp:
            repo = Path(temp)
            write(repo, "design/current.html", "committed")
            write(repo, "CANON", "design/current.html\n")
            commit(repo, "add current canon")
            (repo / "design/current.html").unlink()

            current = classify_canon_candidate(repo, "design/current.html")

            self.assertEqual((current.authority, current.status), (None, UNKNOWN))
            self.assertFalse(may_unlock(current, "repo-fact"))

    def test_dirty_worktree_modification_has_an_exact_ref(self) -> None:
        with init_repo() as temp:
            repo = Path(temp)
            write(repo, "design/current.html", "committed")
            write(repo, "CANON", "design/current.html\n")
            commit(repo, "add current canon")
            clean = classify_canon_candidate(repo, "design/current.html")
            write(repo, "design/current.html", "uncommitted change")

            dirty = classify_canon_candidate(repo, "design/current.html")

            self.assertTrue(may_unlock(dirty, "repo-fact"))
            self.assertNotEqual(dirty.source_ref, clean.source_ref)
            self.assertIn("+worktree:", dirty.source_ref)

    def test_absent_current_source_stays_unknown(self) -> None:
        with init_repo() as temp:
            repo = Path(temp)
            write(repo, "README", "canon target is absent")
            write(repo, "CANON", "design/missing.html\n")
            commit(repo, "initial")

            absent = classify_canon_candidate(repo, "design/missing.html")

            self.assertEqual((absent.authority, absent.status), (None, UNKNOWN))
            self.assertFalse(may_unlock(absent, "repo-fact"))

    def test_memory_cannot_override_current_head(self) -> None:
        memory = Premise("P-memory", "theme is blue", REPORT, "memory:turn-4", ACTIVE)
        head = Premise("P-head", "theme is red", CURRENT_REPO, "theme.css@abc1234", ACTIVE)

        self.assertFalse(may_unlock(memory, "repo-fact"))
        self.assertTrue(may_unlock(head, "repo-fact"))

    def test_research_report_cannot_close_over_current_source(self) -> None:
        report = Premise("P-report", "API returns v1", REPORT, "agent-report:7", ACTIVE)
        current = Premise("P-api", "API returns v2", CURRENT_REPO, "api.ts@abc1234", ACTIVE)

        self.assertFalse(may_unlock(report, "repo-fact"))
        self.assertTrue(may_unlock(current, "repo-fact"))

    def test_user_correction_invalidates_all_and_only_descendants(self) -> None:
        intent = Premise("P-intent", "ship selectable themes", USER_INTENT, "user-answer:1", ACTIVE)
        receipt = invalidate(
            intent,
            "user correction: pick one theme",
            {
                "R-theme": {"P-intent"},
                "D-theme": {"R-theme"},
                "Atlas-5": {"D-theme"},
                "Map-9": {"Atlas-5"},
                "Node-10": {"Map-9"},
                "R-independent": {"P-other"},
            },
            "theme decision interview",
        )

        self.assertEqual(
            receipt.descendants,
            ("R-theme", "D-theme", "Atlas-5", "Map-9", "Node-10"),
        )
        self.assertNotIn("R-independent", receipt.descendants)
        self.assertEqual(receipt.new_status, INVALID)

    def test_no_intent_fresh_repo_is_read_only(self) -> None:
        route, writes = plan_entry(None)

        self.assertEqual(route, "batched-outcome-interview")
        self.assertEqual(writes, ())

    def test_historical_artifact_requires_current_readoption(self) -> None:
        with init_repo() as temp:
            repo = Path(temp)
            write(repo, "design/old.html", "old")
            write(repo, "CANON", "design/old.html\n")
            commit(repo, "add old")
            (repo / "design/old.html").unlink()
            commit(repo, "delete old")
            tombstoned = classify_canon_candidate(repo, "design/old.html")
            write(repo, "design/old.html", "re-adopted")
            write(repo, "CANON", "design/old.html\n")
            commit(repo, "re-adopt old as current canon")
            readopted = classify_canon_candidate(repo, "design/old.html")

            self.assertEqual(tombstoned.authority, HISTORICAL)
            self.assertFalse(may_unlock(tombstoned, "repo-fact"))
            self.assertTrue(may_unlock(readopted, "repo-fact"))


if __name__ == "__main__":
    unittest.main(verbosity=2)
