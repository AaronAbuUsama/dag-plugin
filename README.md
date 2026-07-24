# DAG Engineering

One way to turn intent into a **graph of provable work** and walk it — from a first loose idea all the
way to shipped, proven, closed. Grill a plan (batched, grounded in real code), prototype whatever isn't
knowable on paper, chart it onto GitHub as a DAG of issues, then pre-flight, run, and diagnose it to
*done-clean*.

It encodes the lessons of a real multi-wave rollout where one node took 11 review rounds and **half its
findings were introduced by earlier fixes** — the signature of patching without diagnosis. Every rule
here is paid for.

## Quick start (60 seconds)

```
/plugin marketplace add AaronAbuUsama/dag-plugin
/plugin install dag@dag-engineering
```

```
/dag:setup      # once per repo — configures the GitHub tracker + labels
/dag:map        # every time after — it drives everything
```

**That's the whole interface: `/dag:map`.** Run it from any window, at any point. It reads the state off
GitHub, tells you where you are, and runs the next step — so you never have to remember which skill to
reach for. Early on it grills you and charts the plan; once the plan is signed off it runs and proves the
work on its own. You just keep running `/dag:map`.

## Two phases, one door

```
        YOU drive                    │        THE ORCHESTRATOR drives
  grill · prototype · chart          │   run · prove · diagnose
  settle the plan, fix the proof     │   walk the graph, gather the evidence
────────────────────────────────────►│◄────────────────────────────────────
                          the pre-flight signature
```

**Planning is human-in-the-loop**: `/dag:map` proposes one move at a time and runs it *with* you — you
make the decisions. **Execution is not**: once pre-flight is signed, `/dag:run` walks the graph on its
own, dispatching an **agent team** (one teammate = one node = one worktree = one PR), climbing the
escalation ladder, and proving each node before closing it. The signed pre-flight is the door between
them, and it lives on GitHub as a label — which is how one command can serve both sides.

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
| | `/dag:prove` | Captures a node's evidence and posts it **into the PR** — screenshots and video for a UI, the durable delta for a backend, the transcript for a CLI — plus a committed receipt. |
| | `/dag:diagnose` | The nest-finder — one design gap behind a recurring cluster. `run` reaches it automatically. |

## The non-negotiables

- **Verification is king.** A claim you can't verify isn't a result. Tests verify the code against
  itself; only reality verifies it against the world — so a node is done when the real system was
  observed doing the real thing, not when the suite is green.
- **Proof is defined before the code.** Every node's proof contract — which tiers, what evidence, what
  nonce — is written when the issue is created. The agent that builds it never picks its own bar.
- **Proof is never deferred, and never merely asserted.** It is *shown*, in the pull request, in the
  form the surface calls for. A node that can't be proven is a *stop*, not a merge. Reviews-clean ≠ done.
- **A recurring bug-class means stop patching and diagnose.** Patching an undiagnosed subsystem spawns
  new defects; the ladder switches to diagnosis automatically (same class twice, or round 4).
- **Every fix passes fix-completeness** — enumerate every branch and caller before "done", including a
  consolidating fix over every call site of the nest.

## Go deeper

- **The guided tour** is just `/dag:map` with no chart yet — it orients you and starts.
- **The vocabulary** — every **bold term** in the skills — lives in [`GLOSSARY.md`](GLOSSARY.md).
- **Each skill** reads as a standalone playbook under [`skills/`](skills/).

## Install & update

Install from the marketplace as above, or load a working copy with
`claude --plugin-dir /path/to/dag-plugin` while iterating. `scripts/check.sh` runs the suite's own
consistency checks. No external skill dependencies.

MIT licensed. Changes in [`CHANGELOG.md`](CHANGELOG.md).
