---
name: plan
description: The planning door — reads the chart's state off GitHub, tells you where you are, and names the single next planning move, through to the pre-flight signature that hands the DAG to /dag:execute.
disable-model-invocation: true
---

# Plan — where you are, and the next move

**The planning half's one door.** Run `/dag:plan` from any context window, at any point before the DAG is
signed. It finds the **chart** on GitHub, reads its state, and names the single next move — so you never
have to work out which skill to reach for. Terms are defined once in
[`../../GLOSSARY.md`](../../GLOSSARY.md).

Planning ends at the **pre-flight** signature. Past it the DAG belongs to
[`/dag:execute`](../execute/SKILL.md), which walks it to done-clean.

**Why it works across sessions:** the state lives on the tracker, not in the conversation. The chart —
the `dag:map` issue, its child **nodes**, their readiness labels, their **edges**, and the
`dag:preflighted` signature — *is* the memory. A fresh window running `/dag:plan` reads the same state
and continues exactly where the last one stopped.

## 1. Locate the chart

Find the `dag:map` issue on the repo's tracker. If GitHub isn't configured yet, run `/dag:setup` first.

- **No `dag:map` issue** → there is no chart yet. You are at the start: the first move is `/dag:grill`.

## 2. Read the state

With a chart, read these off GitHub — no memory of prior turns needed:

- The open **nodes** — the map's sub-issues — and their readiness labels (`dag:needs-grilling` /
  `dag:needs-research` / `dag:needs-prototype`; no label = **clear**).
- The **frontier**: open nodes whose every blocker is closed.
- Whether the map carries the `dag:preflighted` label — the **signature**.

```bash
gh api repos/<owner>/<repo>/issues/<map-number>/sub_issues      # every node
gh api repos/<owner>/<repo>/issues/<n>/dependencies/blocked_by  # one node's blockers, each with .state
```

The blocker read carries each blocker's `state`, so the frontier costs one query per node and no more.

## 3. Name the next move

Route by state, and **name the command for the user to run**. The planning skills are user-invoked, so
you hand the move over rather than firing it — the user never has to work out *which* move, only run it.

| Chart state | Next move |
|---|---|
| No chart | `/dag:grill` to settle the plan, then `/dag:chart` to lay it down |
| Frontier has a `dag:needs-grilling` node | `/dag:grill` — or `/dag:grill-deep` if it warrants written ADRs |
| Frontier has a `dag:needs-research` node | `/dag:research` — it dispatches its own agent; you review what returns |
| Frontier has a `dag:needs-prototype` node | `/dag:prototype` — the spike that de-risks the node |
| Chart complete, no `dag:preflighted` label | `/dag:preflight` — the last planning move |
| Map labelled `dag:preflighted` | Planning is done. Run `/dag:execute`; it owns the DAG from here. |

**Planning is human-in-the-loop.** Name one move per turn, run it *with* the user, and stop. The user
makes the decisions; you never pick them alone. `research` and `prototype` are the exception — they
dispatch their own agents, and the user reviews what comes back.

**Close the de-fog node when its move lands.** Record the answer as a comment on that node — the
decision a grill settled, the fact research found, the verdict a spike returned — then close it. That
close is the whole mechanism: it unblocks the build node onto the frontier, and it retires the
`dag:needs-*` label without anyone removing one, because a closed node is never on the frontier. A
de-fog move whose node stays open leaves its build node blocked forever.

*Done when:* the move's answer is a comment on its de-fog node and that node is closed, or the move is
still in flight and you have said so.

**A node sent back after the signature lands here again.** When `/dag:execute` returns a rung-3 stop, the
map's `dag:preflighted` label comes off and the DAG is back in planning until pre-flight is re-signed.

## First time here?

With no chart, `/dag:plan` is also the tour. The pipeline, once:

```
GRILL / PROTOTYPE ──► CHART ──► PRE-FLIGHT ──► EXECUTE ──►(DIAGNOSE)──► done-clean
  settle the plan     onto      sign it        walk it     find the nest
  & de-fog it         GitHub                               when a class recurs

  └─────────────── /dag:plan ──────────────┘   └────────── /dag:execute ─────────┘
```

The rules the suite exists to hold: **verification is king** — a claim you can't verify isn't a result,
and only reality verifies code against the world; **proof is defined before the code**, at
issue-creation, so no agent ever picks its own bar; **proof is never deferred and never merely
asserted** — it is shown, in the pull request; **a recurring bug-class means stop patching and
diagnose**; **every fix passes fix-completeness**. Run `/dag:grill` to begin.
