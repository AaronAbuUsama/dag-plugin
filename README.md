# `dag` — provable wave execution

A Claude Code plugin for running a **DAG of work slices to done-clean**: validate the plan against its
own invariants before dispatch, execute wave-by-wave behind a merge gate, and escalate from *patching
symptoms* to *diagnosing the nest* the moment a bug-class recurs — autonomously by default.

It encodes the lessons of a real multi-wave rollout where one node took 11 review rounds and **half its
findings were introduced by earlier fixes** — the signature of patching without diagnosis. See the
motivating retrospective for the evidence behind every rule here.

## The pipeline

```
CREATE ──► PRE-FLIGHT ──► RUN ──►（DIAGNOSE）──► PROVE ──► CLOSE
(ticketing)  dag:preflight  dag:run  dag:diagnose  (your rig)  dag:run
```

| Skill | Invoke | What it does |
|---|---|---|
| `map` | `/dag:map` | The router — names each skill and when to reach for it. Start here. |
| `preflight` | `/dag:preflight` | The gate: every node checked against its invariants, acceptance criteria, edges, and **proof contract** before any dispatch. |
| `run` | `/dag:run` | The execution loop — wave dispatch behind the merge gate, the escalation ladder, no proof deferral, close-on-proof. |
| `diagnose` | `/dag:diagnose` | The nest-finder — given a recurring cluster of findings, find the one design gap and close it. Usually invoked automatically by `run`. |

Shared vocabulary lives in [`GLOSSARY.md`](GLOSSARY.md).

## The three non-negotiables

- **Proof is never deferred.** A node's proof contract is a pre-flight deliverable; a node that can't be
  proven is a *stop*, not a merge. Reviews-clean ≠ done.
- **A recurring bug-class means stop patching and diagnose.** Patching an undiagnosed subsystem spawns
  new defects; the ladder makes the switch to diagnosis automatic (trigger: same class twice, or round 4).
- **Every fix passes fix-completeness** — enumerate every branch and caller before "done", including a
  consolidating fix over every call site of the nest.

## Use it

Load locally while iterating:

```bash
claude --plugin-dir /path/to/dag-plugin
```

Then `/dag:map` for the tour, or `/dag:preflight` to gate a DAG. To distribute across machines, publish
this repo to a plugin marketplace and pin a version; bump `version` in `.claude-plugin/plugin.json` to
release an update.
