---
name: plan
description: The planning door — reads Atlas and chart state from GitHub, resolves destination fog when necessary, and runs the next move through to the pre-flight signature that hands one expedition to execution.
---

# Plan — where you are, and the next move

Run `/dag:plan` in Claude Code or `$dag:plan` in Codex from any context window before a DAG is signed.
It finds the **Atlas** or **chart**, reads its state from GitHub, and performs the next planning move in
this turn. Terms are defined in [`../../GLOSSARY.md`](../../GLOSSARY.md); response rules are in
[`../../RESPONSE-RULES.md`](../../RESPONSE-RULES.md).

Planning ends at the **pre-flight** signature. Past it the chart belongs to
[`/dag:execute`](../execute/SKILL.md).

The tracker is the memory. An Atlas persists its decisions and expedition charts. A chart persists its
nodes, readiness labels, edges, proof contracts and signature. Never depend on a prior conversation.

## 1. Locate the planning artifact

```bash
gh label list --json name --jq '.[].name'
gh issue list --label dag:atlas --state open --json number,title
gh issue list --label dag:map --state open --json number,title
```

- An issue number or exact title named by the user wins.
- One matching Atlas owns destination/system questions and relationships between expeditions.
- One matching map owns planning toward that chart's single destination.
- If one Atlas has no open decision and exactly one active child map, continue that map. With several
  active child maps, name them and ask which expedition to advance.
- Several plausible artifacts → name them and ask which one; never choose by recency.
- No artifact → inspect the request. One known destination starts an **expedition**. Fog about the
  destination, system boundary, or relationship between several destinations starts **Wayfinding**.

If any required label, including `dag:atlas`, is missing, hand over `/dag:setup`. Querying issues by a
missing label returns an empty list rather than an error, so check the label vocabulary first. That is
the only setup exception to the two-door flow.

## 2. Read the state

For an Atlas, read its body, open child decision issues and child `dag:map` issues. The body must make
the North star, Decisions so far, Open decisions, Expeditions, Not yet specified and Out of scope
visible.

For a chart, read:

- the map body, including **Destination**, **Scope edge** and **Not yet specified**;
- its open child nodes and `dag:needs-grilling` / `dag:needs-research` /
  `dag:needs-prototype` labels;
- each node's native blockers and the resulting **frontier**;
- `dag:preflighted` and `dag:halted` on the map;
- the map comments holding the signed table or halt record.

```bash
R=<owner>/<repo>
gh api --paginate repos/$R/issues/<parent-number>/sub_issues \
  --jq '.[] | {number,title,state,labels:[.labels[].name]}'
gh api --paginate repos/$R/issues/<n>/dependencies/blocked_by \
  --jq '.[] | {number,state}'
```

`--paginate` is mandatory: a truncated graph looks like a valid smaller graph.

## 3. Run the next move

Read the matching rows top-down and perform the first move that applies:

| State | Move | Read and follow |
|---|---|---|
| No artifact; destination/system shape is foggy | create or advance an Atlas | [`wayfind.md`](wayfind.md) |
| No artifact; one destination is known | grill, then chart the expedition | [`../grill/SKILL.md`](../grill/SKILL.md), then [`../chart/SKILL.md`](../chart/SKILL.md) |
| Atlas has an open decision, relevant unspecified territory, or newly chartable region | advance Wayfinding once | [`wayfind.md`](wayfind.md) |
| Map has `dag:halted` | classify and repair the returned chart | [`../replan/SKILL.md`](../replan/SKILL.md) |
| Chart frontier has `dag:needs-grilling` | settle that decision | [`../grill/SKILL.md`](../grill/SKILL.md), or [`../grill-deep/SKILL.md`](../grill-deep/SKILL.md) when ADRs are warranted |
| Chart frontier has `dag:needs-research` | dispatch research | the model-invoked `research` skill |
| Chart frontier has `dag:needs-prototype` | run the spike | the model-invoked `prototype` skill |
| Map has a `Not yet specified` entry whose decision has landed | graduate it into nodes | [`../chart/SKILL.md`](../chart/SKILL.md) |
| Chart complete and unsigned | pre-flight and sign it | [`../preflight/SKILL.md`](../preflight/SKILL.md) |
| Map has `dag:preflighted` | planning is done | tell the user to run `/dag:execute` |

`/dag:plan` is a door, not a signpost. Planning skills are internal moves: read their `SKILL.md` and
follow it here. `/dag:execute` is the only workflow command handed back to the user.

An Atlas does not make every child map active. Select its only active chart, or ask when several remain,
before applying chart rows.
`dag:halted` is read before a chart's de-fog state because the stop must first be classified as
node-wrong, method-wrong or destination-wrong.

**Chart complete** means no open de-fog issue and no unresolved **Not yet specified** entry remains
under the map. Every such entry must be graduated, moved to **Out of scope**, or still point at an open
de-fog issue. A clear-looking frontier does not excuse uncertainty buried elsewhere.

## 4. Persist every planning move

Planning is human-in-the-loop and advances one move per turn.

When a decision lands:

1. record the answer as a comment on its de-fog or Atlas decision issue;
2. for Atlas decisions, fold it into **Decisions so far** and remove it from **Open decisions**;
3. close the decision issue.

That close advances the durable frontier. A result left only in chat did not happen.

When the move needs user input, ground the question through
[`../../RESPONSE-RULES.md`](../../RESPONSE-RULES.md), ask it, and continue the move in the same turn.
Do not ask the user whether something is “an Atlas”; show the concrete destination uncertainty and
recommend the matching level.

If two decision issues answer the same underlying question, name the possible **nest** and route to
diagnosis rather than multiplying decisions.

## 5. Recover a partial stop

If execution stopped but crashed before writing durable state, reconstruct the stop from its PR/issue
evidence:

- node premise wrong → remove `dag:preflighted`, create a separate de-fog issue, attach it as a map
  sub-issue, then make it block the stopped node;
- method or destination wrong → replace `dag:preflighted` with `dag:halted` and record
  `Class: method-wrong` or `Class: destination-wrong` on the map.

Never put a `dag:needs-*` label on the build node. Planning closes readiness-labelled issues when their
answer lands; labelling the build node would close it unbuilt.

## 6. End with a position

Read [`../../RESPONSE-RULES.md`](../../RESPONSE-RULES.md) before the closing message. State the selected
Atlas or chart, the move completed, the durable state written, and what comes next. Re-running
`/dag:plan` resumes planning; only a signed chart hands over `/dag:execute`.

The pipeline:

```text
WAYFIND ──► GRILL / PROTOTYPE ──► CHART ──► PRE-FLIGHT ──► EXECUTE ──► done-clean
if the       settle one             one       sign it        walk it
destination expedition              map
is foggy

└──────────────────── /dag:plan ────────────────────┘   └─ /dag:execute ─┘
```
