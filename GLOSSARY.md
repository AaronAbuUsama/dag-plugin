# Glossary — the shared vocabulary of the `dag` suite

The suite's skills lean on these **leading words**. Each is a compact concept the model already holds;
repeated across the skills, they anchor the same behaviour every run. Define a term once here; the
skills use it without re-defining.

---

**DAG** — the plan as a graph of **nodes** (work slices) joined by **edges** (a node blocks another
until it merges). Built upstream by a ticketing skill; this suite validates it, runs it, and closes it.

**node** — one work slice: a narrow-but-complete vertical path (schema→logic→tests) sized for a single
fresh context, demoable on its own. One node = one agent = one worktree = one PR.

**pre-flight** — the checklist you run *before the wheels leave the ground*. A whole-DAG gate, run once
before any dispatch: every node checked against the architecture invariants, its own acceptance
criteria, its edges, and its **proof contract**. You do not dispatch until pre-flight is signed. Skipping
it is why architecture violations get caught late, in review, at their most expensive.

**invariant** — a rule no node may violate, stated in the project's architecture doc. Conformance is
checked at pre-flight against the *design*, not discovered in review against the *code*.

**proof contract** — the concrete, runnable evidence that one node is done: which proof layers, what
nonce, what receipt. Defined at pre-flight. **A node with no runnable proof contract does not pass
pre-flight** — "we'll prove it after deploy" is banned.

**proof ledger** — the running record of each node's proof contract and whether it is satisfied. Makes
the difference between the two done-states impossible to blur:

- **triage-clean** — the reviews are clean. Necessary, not sufficient.
- **done-clean** — the proof contract is *satisfied* (the live evidence exists). The only real "done".

Proof is never deferred. If a node cannot be proven, that is a **stop** signal — before work starts if
the contract can't even be defined, or at merge if the evidence can't be gathered — never a shrug.

**merge gate** — the three signals that must all be clean before a node merges: CI, an independent
review (bot or subagent — whose verdict is *posted to the PR*, not left in a transcript), and the
orchestrator's own cold read of the diff.

**triage vs diagnosis** — the two review modes.
- **triage** — what a point-reviewer does: surface one symptom at a time. Fast, shallow, never names
  the underlying cause. The default mode, correct for rounds 1–2.
- **diagnosis** — find the *disease* behind a cluster of symptoms. Slow, deep, names the root. You
  switch from triage to diagnosis when a trigger fires (see **the tell**, **class-recurrence**).

**the nest** — the single design gap that generates a **cluster** of findings. "Stop hitting moles,
find the nest." Diagnosis exists to find the nest and close it with one **consolidating fix**, instead
of patching each mole forever.

**cluster** — two or more distinct findings that are the same underlying issue recurring at a different
checkpoint or after a fix reshaped the code. A cluster is the signature of a nest.

**the tell** — the sharpest early signal that you are in whack-a-mole and must switch to diagnosis: a
finding whose *fix needs a new mechanism*, not a tightened check. When a fix adds machinery rather than
narrowing an existing guard, the design has a hole near it — stop and diagnose.

**class-recurrence** — the primary escalation trigger: the **same bug-class appears a second time**.
Do not wait for a round count; a class recurring means there is a nest.

**fix-induced** — a defect *introduced by an earlier fix* rather than present in the original code. The
direct cost of patching symptoms in a subsystem you have not diagnosed. High fix-induced rates are the
statistical fingerprint of missing diagnosis.

**fix-completeness** — before a fix is "done", enumerate *every branch and caller* the fix's reasoning
touches; the fix is not done until each is covered. The one-line discipline that kills the narrow-fix
regression class — including on a **consolidating fix**, which must cover every call site of the nest.

**the ladder** — the escalation path when review findings arrive:
1. **Patch** (triage) — fix the reported defect. Normal for rounds 1–2.
2. **Diagnose + fix** (the **inner loop**) — find the nest, apply the consolidating fix, continue.
   Autonomous by default; most escalations resolve and die here without a human.
3. **Stop** (the **outer loop**, rare) — surface to the human, *pre-validated*: the nest, a confidence
   level, and whether the fix unblocks. Fires only when the node's spec/premise is wrong (not just its
   code), the proof can't be gathered, or the fix would cost more than it's worth.

**inner loop / outer loop** — the inner loop is autonomous diagnose-and-fix (rung 2); the outer loop is
the rare, pre-validated human escalation (rung 3). The **autonomy level** (set via the router) decides
how freely the inner loop runs before the outer loop is allowed to fire — autonomous by default.

**code-wrong vs node-wrong** — diagnosis's verdict on a cluster. **code-wrong**: the implementation was
wrong → consolidate and continue (rung 2, autonomous). **node-wrong**: the node's spec or premise was
wrong → stop and re-plan (rung 3). A third outcome, **independent**: no nest, the findings are genuinely
unrelated → resume patching, with confidence.
