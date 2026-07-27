---
name: research
description: Investigate a DAG node's open fact against current primary sources, return a provenance-bearing candidate answer, and persist it only after the planning lead admits it. Use when a node's readiness is needs-research, or when another dag skill dispatches a research node.
---

# Research — investigate a question against primary sources

This is the brief for one research **teammate** assigned by the main planning **orchestrator**, so the
caller keeps working while it reads. Claude Code assigns it through Agent Teams; Codex assigns it through
native child agents. Do not spawn another agent from inside this skill. This is the AFK fact-finder other
planning skills in the [`dag`](../../GLOSSARY.md) suite dispatch whenever a decision is blocked on a fact
rather than a choice — a `needs-research` node exists precisely because something is knowable but not yet
known.

Its job:

How to respond — the closing message, and any question put to the user — is in
[`../../RESPONSE-RULES.md`](../../RESPONSE-RULES.md).
Source authority, candidate admission and invalidation are governed by
[`../../EVIDENCE-AUTHORITY.md`](../../EVIDENCE-AUTHORITY.md).

1. Investigate the question against **current primary sources** — official docs, current source code,
   specs, first-party APIs — not a secondary write-up of them. Follow every claim back to the source that
   owns it, record the exact repo ref or external version/date, and resolve the current authority pointer
   before reading Git history. Deleted content is `historical/tombstoned`, never current by proximity.
2. Return a **candidate answer** with one premise row per claim: claim, proposed authority class, exact
   source/ref, verification performed and whether it conflicts with a current source. Separate what was
   read from what was inferred.
3. **Post that candidate on the node's issue** when the question came from a `dag:needs-research` node.
   Do not close the issue and do not describe the comment as admitted truth. A teammate report is
   `report/memory` until the planning lead verifies it.
4. The planning lead re-checks repo facts at the exact current ref and posts an admission or contest
   comment. Only an admitted answer gets a premise ID, `Status: active`, and permission to close the
   research issue and unblock descendants.
5. After admission, save the findings to one Markdown file where the repo already keeps such notes,
   citing every source and premise ID. Before admission — including bare-door exploration with no
   `user-intent` premise — write no project research/canon file. Keep the candidate in the issue,
   teammate report or a scratch location instead.

**Before you report more than one finding, look for the nest.** Research that surfaces three findings has
to ask whether they are three things or one thing seen three times — see **looking for the nest** in the
glossary. Name the class in a sentence, separate what you read from what you inferred, and say whether it
warrants diagnosing rather than fixing each symptom. Reporting a list and leaving the reader to notice the
pattern is how a root cause survives being found.

*Done when:* every candidate claim has a proposed authority class and exact ref; the candidate is posted
without closing the node; the lead has admitted or contested it; admitted findings alone are saved with
premise IDs and may close the node; and — where more than one finding came back — you have said whether
they share a root.
