---
name: map
description: The one entry point — run it from anywhere and it reads the chart's state, tells you where you are, and drives the next step. Stateful across context windows; routes both the planning and execution phases.
disable-model-invocation: true
---

# Map — where you are, and the next move

**The single entry point to the whole suite.** Run `/dag:map` from any context window, at any point. It
finds the **chart** on GitHub, reads its state, and drives the next step — so neither you (planning) nor
the orchestrator (executing) ever has to know which skill to reach for. Terms are defined once in
[`../../GLOSSARY.md`](../../GLOSSARY.md).

**Why it works across sessions:** the state lives on the tracker, not in the conversation. The chart —
the `dag:map` issue, its child **nodes**, their readiness labels, their native blocking **edges**, and
the `dag:preflighted` signature — *is* the memory. A fresh window running `/dag:map` reads the same state
and continues exactly where the last one stopped.

## 1. Locate the chart

Find the `dag:map` issue on the repo's tracker. If GitHub isn't configured yet, run `/dag:setup` first.

- **No `dag:map` issue** → there is no chart yet. You are at the start: go to *Planning*, first move
  `/dag:grill`.

## 2. Read the state

With a chart, read these off GitHub — no memory of prior turns needed:

- The open **nodes** — the map's sub-issues — and their readiness labels (`dag:needs-grilling` /
  `dag:needs-research` / `dag:needs-prototype`; no label = **clear**).
- The **frontier**: open nodes whose every blocking node is closed.
- Whether the map carries the `dag:preflighted` label (the pre-flight **signature**).

## 3. Drive the next move

Route by state. The pre-flight signature is the line between the two drivers — **planning is yours,
execution is the orchestrator's** — and the conductor behaves accordingly.

| Chart state | Next move | Driver |
|---|---|---|
| No chart | `/dag:grill` to settle the plan, then `/dag:chart` to lay it down | **you** (human-in-the-loop) |
| Frontier has a `dag:needs-grilling` node | `/dag:grill` (or `/dag:grill-deep` if it warrants written ADRs) | **you** |
| Frontier has a `dag:needs-research` / `dag:needs-prototype` node | `/dag:research` / `/dag:prototype` — these self-dispatch | agent, you review |
| Chart complete, no `dag:preflighted` label | `/dag:preflight` | handoff |
| Map labelled `dag:preflighted` | `/dag:run` — it self-drives the ladder → `/dag:diagnose`, and `/dag:prove` on each merged node | **orchestrator** |
| A merged node whose proof isn't in its PR | `/dag:prove` — capture the evidence and post it | **orchestrator** |
| Every node done-clean and closed | The DAG is done. | — |

**Before the signature — planning, human-in-the-loop.** Propose the single next planning move, run it
*with* the user, and stop. One move per turn; the user drives the decisions, you never pick them alone.

**After the signature — execution, orchestrator-driven.** Hand off to `/dag:run` and let it drive:
wave dispatch, the merge gate, and the ladder (which reaches `/dag:diagnose` on its own). You do not
step back in per-node; `run` owns the loop until a rung-3 stop or the DAG is done.

## First time here?

With no chart, `/dag:map` is also the tour. The pipeline, once:

```
GRILL / PROTOTYPE ──► CHART ──► PRE-FLIGHT ──► RUN ──►（DIAGNOSE）──► done-clean
   settle the plan    onto     gate it        walk it   find the nest
   & de-fog it        GitHub                            when a class recurs
```

The rules the suite exists to hold: **verification is king** — a claim you can't verify isn't a result,
and only reality verifies code against the world; **proof is defined before the code**, at issue-creation,
so no agent ever picks its own bar; **proof is never deferred and never merely asserted** — it is shown,
in the pull request; **a recurring bug-class means stop patching and diagnose**; **every fix passes
fix-completeness**. Run `/dag:grill` to begin.
