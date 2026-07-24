---
name: diagnose
description: Find the one design gap behind a cluster of review findings and return a consolidating fix or a pre-validated escalation. Use when a bug-class recurs, or when a fix needs a new mechanism rather than a tightened check.
---

# Diagnose — find the nest

The rung-2 engine of the **ladder**. You arrive here because a trigger fired: a bug-class recurred, or a
patch spawned an adjacent defect. Stop patching. You answer one question: **what single design gap
generates all of these findings, and is there one consolidating fix that closes the class?** Terms below
are defined once in [`../../GLOSSARY.md`](../../GLOSSARY.md).

Inputs: the **cluster** of findings, the **whole subsystem** they touch (not the diff), and the
architecture **invariants**. Work the steps in order.

## 1. Confirm the cluster is real

Read every finding in the cluster and name the underlying shape they share — the same assumption
violated, the same check missing, the same state read stale. A shared *file* is not a shared shape; a
shared shape is the signature of a **nest**.

*Done when:* you can write one sentence — "each of these findings is <shape> recurring at a new call
site / branch / checkpoint" — that every finding in the cluster fits. If one finding does not fit, drop
it from the cluster; if fewer than two remain, the verdict is **independent** (skip to step 3).

## 2. Read the whole subsystem, not the diff

This is the step that separates **diagnosis** from **triage**, and it is the load-bearing behaviour of
this skill. The diff shows you where a mole surfaced; it never shows you the nest — and every patch aimed at a
mole you haven't diagnosed risks a **fix-induced** defect in its place. Open the whole
subsystem the cluster lives in — every module that reads or writes the shared state, every path that
touches the invariant in question — and trace the assumption end to end. The motivating failure did the
opposite: six TOCTOU/stale-state findings were patched one diff at a time across rounds 3→11, and nobody
read the subsystem as a whole until round 11 — five rounds late.

*Done when:* you can state, in **one sentence**, the invariant or assumption the subsystem fails to
hold — e.g. "every consumer of live PR state assumes it is fresh, but nothing re-reads it after the
window opens." **That sentence names the nest.** If you cannot write it, you have not read enough of the
subsystem yet — keep reading; do not proceed on the diff.

## 3. Return one verdict

Judge the nest against the subsystem and the invariants, and return exactly one:

- **code-wrong** — the implementation has a gap; the spec and premise are sound. → Propose the
  consolidating fix (step 4). Rung 2, autonomous.
- **node-wrong** — the findings trace to a wrong spec or premise, not wrong code; no implementation
  change closes them honestly. → Do **not** fix. Assemble the escalation package (step 5). Rung 3.
- **independent** — step 1 or 2 dissolved the cluster; the findings are genuinely unrelated. → Say so,
  and resume patching each on its own, now with confidence there is no nest.

*Done when:* the verdict is named and its one-sentence justification points back at the nest sentence
from step 2 (or, for **independent**, at why the shapes differ).

## 4. If code-wrong: the consolidating fix, complete

Design the **one consolidating fix** that closes the nest — the shared primitive, guard, or invariant
enforcement that every member of the cluster routes through. Then apply **fix-completeness** *to the
consolidation itself*. This is where the motivating round-11 fix failed: a shared guard closed five of
the cluster's six members but missed one call site, and that sixth mole reached merge unresolved. Do not
repeat it.

*Done when — the exhaustive criterion:* you have enumerated **every** call site and **every** branch in
the subsystem where the nest's assumption is relied on — found by grepping the whole subsystem for the
shared state, guard, or invariant from step 2, not by listing only the sites the cluster's findings named
— and for each one you have marked it *covered by the consolidating fix* or *carved out with a stated
reason*. A call site that is neither covered nor reasoned-out means the fix is not done — return to it.
The output is the named nest, the consolidating fix, and this complete call-site list.

## 5. If node-wrong: the escalation package

Do not fix; hand rung 3 something pre-validated. Assemble: the **named nest** (the step-2 sentence), the
**confidence** that the premise — not the code — is what is wrong, and an **unblock assessment**: does
re-planning this node unblock the DAG, and what does it cost. This is the outer loop's whole input; make
it decidable without re-deriving the diagnosis.

*Done when:* the package carries all three — nest, confidence, unblock assessment — and a human could act
on it without re-reading the cluster.
