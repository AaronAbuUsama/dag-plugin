---
name: plan
description: The planning door — reads the chart's state off GitHub, tells you where you are, and runs the next planning move itself, through to the pre-flight signature that hands the DAG to /dag:execute.
disable-model-invocation: true
---

# Plan — where you are, and the next move

**The planning half's one door.** Run `/dag:plan` from any context window, at any point before the DAG is
signed. It finds the **chart** on GitHub, reads its state, and **runs** the next move — so you never have
to work out which skill to reach for, or type a second command to get started. Terms are defined once in
[`../../GLOSSARY.md`](../../GLOSSARY.md).

Planning ends at the **pre-flight** signature. Past it the DAG belongs to
[`/dag:execute`](../execute/SKILL.md), which walks it to done-clean.

**Why it works across sessions:** the state lives on the tracker, not in the conversation. The chart —
the `dag:map` issue, its child **nodes**, their readiness labels, their **edges**, and the
`dag:preflighted` signature — *is* the memory. A fresh window running `/dag:plan` reads the same state
and continues exactly where the last one stopped.

## 1. Locate the chart

```bash
gh issue list --label dag:map --state open --json number,title
```

- **No `dag:map` issue** → there is no chart yet. You are at the start: ask which effort this chart
  covers, then grill it (step 3). If the `dag:*` labels are missing, GitHub isn't configured — that is the
  one time you hand over a command: `/dag:setup`.
- **More than one** → name them and ask which effort this is. Two open charts in one repo is two
  efforts, and every step below reads a single map.

## 2. Read the state

With a chart, read these off GitHub — no memory of prior turns needed:

- The open **nodes** — the map's sub-issues — and their readiness labels (`dag:needs-grilling` /
  `dag:needs-research` / `dag:needs-prototype`; no label = **clear**).
- The **frontier**: open nodes whose every blocker is closed.
- Whether the map carries the `dag:preflighted` label — the **signature**.

```bash
R=<owner>/<repo>
gh api --paginate repos/$R/issues/<map-number>/sub_issues --jq '.[] | {number, title, state}'
gh api --paginate repos/$R/issues/<n>/dependencies/blocked_by --jq '.[] | {number, state}'
```

`--paginate` is not optional: both endpoints return 30 per page by default, and a truncated read looks
exactly like a smaller DAG rather than an error. The blocker read carries each blocker's `state`, so the
frontier costs one query per node and no more.

## 3. Run the next move

Route by state, then **run the move in this turn**. Do not hand the user a command to type. The planning
skills are user-invoked, which means you cannot dispatch them as skills — so you reach the move by
**reading that skill's `SKILL.md` and following it here**, in this window, as written.

`/dag:plan` is a door, not a signpost. A door that answers with another command to run has not opened
anything, and the suite promises two commands total — naming a third breaks that promise every time it
fires.

| Chart state | The move you run | Read and follow |
|---|---|---|
| No chart | grill the plan, then chart it | [`../grill/SKILL.md`](../grill/SKILL.md), then [`../chart/SKILL.md`](../chart/SKILL.md) |
| Frontier has a `dag:needs-grilling` node | grill that decision | [`../grill/SKILL.md`](../grill/SKILL.md) — or [`../grill-deep/SKILL.md`](../grill-deep/SKILL.md) if it warrants written ADRs |
| Frontier has a `dag:needs-research` node | `/dag:research` (model-invoked — dispatch it) | it runs its own agent; you review what returns |
| Frontier has a `dag:needs-prototype` node | `/dag:prototype` (model-invoked — dispatch it) | the spike that de-risks the node |
| Chart complete (below), no `dag:preflighted` label | pre-flight and sign it | [`../preflight/SKILL.md`](../preflight/SKILL.md) |
| Map labelled `dag:preflighted` | Planning is done. Tell the user to run `/dag:execute` — that is the *other door*, and the one command you do hand over. |  |

`research` and `prototype` are model-invoked, so dispatch those directly. The rest are user-invoked, so
read their `SKILL.md` and follow it in this turn. `/dag:execute` is the only command you ever hand the
user, because it is the other door.

**Chart complete** means every de-fog node is closed — no `dag:needs-*` label is left on an open
issue anywhere in the chart. Not "the frontier looks clear": a de-fog node buried behind build edges
still has an unanswered question in it, and pre-flight signed over the top of one is the premature
dispatch the gate exists to prevent.

**Planning is human-in-the-loop.** Run one move per turn, *with* the user, and stop. The user makes the
decisions; you never pick them alone.

**When the move needs an input only the user can give, ask it and then start — in the same turn.** The
commonest is scope: with no chart, which effort does this one cover? Put that through
**`AskUserQuestion`** with the candidates you found in the repo as options, and carry straight on into
the grill once it is answered. What you never do is stop, hand over a command, *and* ask a question — one
command in should produce one question back and then work, not a homework list.

**Close the de-fog node when its move lands.** Record the answer as a comment on that node — the
decision a grill settled, the fact research found, the verdict a spike returned — then close it. That
close is the whole mechanism: it unblocks the build node onto the frontier, and it retires the
`dag:needs-*` label without anyone removing one, because a closed node is never on the frontier. A
de-fog move whose node stays open leaves its build node blocked forever.

*Done when:* the move's answer is a comment on its de-fog node and that node is closed, or the move is
still in flight and you have said so.

**A node sent back after the signature lands here again.** `/dag:execute` removes `dag:preflighted` from
the map when it raises a rung-3 stop, so the chart arrives here unsigned and this router picks it up like
any other planning state. If you find a stopped node while the label is still on, take it off yourself —
that label is what lets a fresh window resume autonomous execution over a DAG a human already halted:

```bash
gh issue edit <map-number> --remove-label dag:preflighted
```

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
diagnose**; **every fix passes fix-completeness**.

Then get on with step 3 — ask which effort this chart covers, and start grilling it.
