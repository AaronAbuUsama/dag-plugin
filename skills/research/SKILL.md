---
name: research
description: Investigate a question against high-trust primary sources and capture the findings as a Markdown file in the repo. Use when a node's readiness is needs-research, a planning skill needs a fact settled before it can proceed, or the user wants a topic, docs, or API researched and the legwork delegated to a background agent.
---

Spin up a **background agent** to do the research, so the caller keeps working while it reads. This is the AFK fact-finder other planning skills in the [`dag`](../../GLOSSARY.md) suite dispatch whenever a decision is blocked on a fact rather than a choice — a `needs-research` node exists precisely because something is knowable but not yet known.

Its job:

1. Investigate the question against **primary sources** — official docs, source code, specs, first-party APIs — not a secondary write-up of them. Follow every claim back to the source that owns it.
2. Write the findings to a single Markdown file, citing each claim's source.
3. Save it where the repo already keeps such notes; match the existing convention, and if there is none, put it somewhere sensible and say where. If the repo has no tracker or chart set up yet to record the resulting decision against, run [`/dag:setup`](../setup/SKILL.md) first.
