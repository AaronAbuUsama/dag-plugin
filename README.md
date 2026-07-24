# DAG Engineering

One way to turn intent into a **graph of provable work** and walk it — from a first loose idea all the
way to shipped, proven, closed. Grill a plan (batched, grounded in real code), prototype whatever isn't
knowable on paper, chart it onto GitHub as a DAG of issues, then pre-flight, run, and diagnose it to
*done-clean*.

It encodes the lessons of a real multi-wave rollout where one node took 11 review rounds and **half its
findings were introduced by earlier fixes** — the signature of patching without diagnosis. Every rule
here is paid for.

## Quick start (60 seconds)

```bash
claude --plugin-dir /path/to/dag-plugin      # load it
```

```
/dag:setup      # once per repo — configures the GitHub tracker + labels
/dag:map        # every time after — it drives everything
```

**That's the whole interface: `/dag:map`.** Run it from any window, at any point. It reads the state off
GitHub, tells you where you are, and runs the next step — so you never have to remember which skill to
reach for. Early on it grills you and charts the plan; once the plan is signed off it runs and proves the
work on its own. You just keep running `/dag:map`.

## Why one command is enough

The state lives on **GitHub**, not in the conversation — the chart (a `dag:map` issue, its child node
issues, their blocking edges, the pre-flight signature) *is* the memory. So a fresh context window
running `/dag:map` picks up exactly where the last one left off. Stateful by construction.

## The pipeline

```
GRILL / PROTOTYPE ──► CHART ──► PRE-FLIGHT ──► RUN ──►（DIAGNOSE）──► done-clean
  settle the plan     onto      gate it        walk it   find the nest when
  & de-fog it         GitHub                             a bug-class recurs
```

| Phase | Skill | What it does |
|---|---|---|
| **entry** | `/dag:map` | The one command — reads state, drives the next move. Start here. |
| **setup** | `/dag:setup` | One-time: GitHub tracker + the suite's labels. |
| **plan** | `/dag:grill` | Batched, code-grounded interview — the whole frontier per round, every question shown in real code with graded options. Never abstract. |
| | `/dag:grill-deep` | `grill` + writes ADRs and a glossary as decisions settle. |
| | `/dag:research` | Finds a fact a decision waits on (agent-driven). |
| | `/dag:prototype` | A throwaway spike to answer what isn't knowable on paper. |
| | `/dag:chart` | Lays the plan down as a GitHub DAG — nodes + native blocking, each node's readiness de-risked first. |
| **build** | `/dag:preflight` | The gate: every node checked against its invariants, criteria, edges, and a runnable proof contract before any dispatch. |
| | `/dag:run` | Wave execution behind the merge gate, the escalation ladder, no proof deferral, close-on-proof. |
| | `/dag:diagnose` | The nest-finder — one design gap behind a recurring cluster. `run` reaches it automatically. |

## The three non-negotiables

- **Proof is never deferred.** A node's proof contract is a pre-flight deliverable; a node that can't be
  proven is a *stop*, not a merge. Reviews-clean ≠ done.
- **A recurring bug-class means stop patching and diagnose.** Patching an undiagnosed subsystem spawns
  new defects; the ladder switches to diagnosis automatically (same class twice, or round 4).
- **Every fix passes fix-completeness** — enumerate every branch and caller before "done", including a
  consolidating fix over every call site of the nest.

## Go deeper

- **The guided tour** is just `/dag:map` with no chart yet — it orients you and starts.
- **The vocabulary** — every **bold term** in the skills — lives in [`GLOSSARY.md`](GLOSSARY.md).
- **Each skill** reads as a standalone playbook under [`skills/`](skills/).

## Install & update

Load locally with `--plugin-dir` while iterating. To use it across machines, publish this repo as a
plugin marketplace and `/plugin install` it; bump `version` in `.claude-plugin/plugin.json` to release
an update. Everything here is yours — no external skill dependencies.
