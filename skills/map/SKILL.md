---
name: map
description: Router over the DAG-execution suite — names each skill and when to reach for it. User-invoked index for building, validating, running, and proving a DAG of work.
disable-model-invocation: true
---

# The DAG suite — map

Turning a plan into proven-done work runs through one pipeline. This skill is the index; the terms
below are defined once in [`../../GLOSSARY.md`](../../GLOSSARY.md).

```
   CREATE ──► PRE-FLIGHT ──► RUN ──►（DIAGNOSE）──► PROVE ──► CLOSE
   (your          dag:         dag:     dag:          your      dag:
   ticketing)   preflight      run    diagnose       rig/proof   run
```

## Reach for

- **Building the plan** → your own ticketing/spec flow. This suite starts once a **DAG** of nodes with
  **edges** exists.
- **Before dispatching any node** → **`/dag:preflight`**. Walk every node against its invariants, its
  own acceptance criteria, its edges, and its **proof contract**. Nothing dispatches until pre-flight is
  signed. This is the cheapest place to catch an architecture violation — skip it and you pay for it
  later, in review, at its most expensive.
- **Executing the DAG** → **`/dag:run`**. Wave-by-wave dispatch behind the **merge gate**, carrying the
  **ladder**, the **fix-completeness** check, the **proof ledger**, and close-on-proof. This is the
  loop you live in until the DAG is done.
- **A bug-class keeps recurring** → **`/dag:diagnose`** (usually invoked *by* `/dag:run` automatically
  when a trigger fires — see the ladder). Find the **nest** behind a **cluster**; return a consolidating
  fix or an escalation. You rarely call this by hand.
- **Proving a node on real infrastructure** → your project's proof/deploy skill (e.g. `rig`). The
  **proof contract** defined at pre-flight is what you satisfy here. `/dag:run` gates merge on it.

## The one knob: autonomy level

`/dag:run` defaults to **autonomous** — when a bug-class recurs it diagnoses the **nest** and applies
the consolidating fix on its own (the **inner loop**), and only escalates to you (the **outer loop**)
when the node's *premise* is wrong, the proof can't be gathered, or the fix costs more than it's worth
— and even then it arrives *pre-validated*: here is the nest, here is my confidence, here is whether the
fix unblocks. Set the level when you start a run:

- **autonomous** (default) — diagnose and fix the nest without checking in; escalate only the three
  outer-loop cases above, pre-validated.
- **supervised** — diagnose the nest autonomously, but come back with the validated diagnosis *before*
  applying a consolidating fix.

The point of the suite is to run without a human in the loop. Prefer **autonomous**; reach for
**supervised** only when a subsystem is high-stakes enough that you want eyes on a restructure before it
lands.

## The non-negotiables (why this suite exists)

Three rules the suite enforces because their absence is what makes rollouts expensive:

- **Proof is never deferred.** A node's **proof contract** is a pre-flight deliverable; a node that
  can't be proven is a **stop**, not a merge. `triage-clean` (reviews pass) is not `done-clean` (proof
  satisfied).
- **A recurring bug-class means stop patching and diagnose.** Patching symptoms in an undiagnosed
  subsystem spawns **fix-induced** defects. The ladder makes the switch to diagnosis automatic.
- **Every fix — including a consolidating one — passes fix-completeness.** Enumerate every branch and
  caller before "done".
