---
name: research
description: Settle a DAG node's open fact against primary sources and return the cited answer to planning. Use when a node's readiness is needs-research, or when another dag skill dispatches a research node.
---

# Research — settle a question against primary sources

This is the brief for one research **teammate** assigned by the main planning **orchestrator**, so the
caller keeps working while it reads. Claude Code assigns it through Agent Teams; Codex assigns it through
a separate Codex task. Do not create another task from inside this skill. This is the AFK fact-finder other
planning skills in the [`dag`](../../GLOSSARY.md) suite dispatch whenever a decision is blocked on a fact
rather than a choice — a `needs-research` node exists precisely because something is knowable but not yet
known.

Its job:

How to respond — the closing message, and any question put to the user — is in
[`../../RESPONSE-RULES.md`](../../RESPONSE-RULES.md).

1. Investigate the question against **current primary sources** — official docs, current source code,
   specs, first-party APIs — not a secondary write-up of them. Follow every claim back to the source that
   owns it. Use history when the question itself is historical.
2. Return one cited answer to the planning caller, separating what you read from what you inferred.
3. **Post that answer on the node's issue** when the question came from a `dag:needs-research` node. The
   planning caller decides whether it settles the question and closes the node.

**Before you report more than one finding, look for the nest.** Research that surfaces three findings has
to ask whether they are three things or one thing seen three times — see **looking for the nest** in the
glossary. Name the class in a sentence, separate what you read from what you inferred, and say whether it
warrants diagnosing rather than fixing each symptom. Reporting a list and leaving the reader to notice the
pattern is how a root cause survives being found.

*Done when:* the question is answered against current primary sources with each claim cited, the answer
is returned to planning and posted on the node for a `needs-research` question, and — where more than one
finding came back — you have said whether they share a root.
