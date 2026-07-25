---
name: research
description: Settle a DAG node's open fact against primary sources and capture the findings as a Markdown file in the repo. Use when a node's readiness is needs-research, or when another dag skill dispatches a research node.
---

# Research — settle a question against primary sources

Spin up a **background agent** to do the research, so the caller keeps working while it reads. This is
the AFK fact-finder other planning skills in the [`dag`](../../GLOSSARY.md) suite dispatch whenever a
decision is blocked on a fact rather than a choice — a `needs-research` node exists precisely because
something is knowable but not yet known.

Its job:

The shape of the message a turn ends with is in
[`../../STOPPING-MESSAGE.md`](../../STOPPING-MESSAGE.md).

1. Investigate the question against **primary sources** — official docs, source code, specs, first-party
   APIs — not a secondary write-up of them. Follow every claim back to the source that owns it.
2. Write the findings to a single Markdown file, citing each claim's source.
3. Save it where the repo already keeps such notes; match the existing convention, and if there is none,
   put it somewhere sensible and say where.
4. **Post the answer on the node's issue** when the question came from a `dag:needs-research` node — the
   finding itself, not just a path to it, plus a link to the file. That comment is what the next
   `/dag:plan` window reads to close the node and unblock what it was blocking. A finding that lives
   only in a file is a finding the router cannot see, and the node it de-fogs stays blocked forever.

**Before you report more than one finding, look for the nest.** Research that surfaces three findings has
to ask whether they are three things or one thing seen three times — see **looking for the nest** in the
glossary. Name the class in a sentence, separate what you read from what you inferred, and say whether it
warrants diagnosing rather than fixing each symptom. Reporting a list and leaving the reader to notice the
pattern is how a root cause survives being found.

*Done when:* the question is answered against primary sources with each claim cited, the file is saved
and its location stated, the answer is a comment on the node's issue for a `needs-research` node, and —
where more than one finding came back — you have said whether they share a root.
