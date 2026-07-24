---
name: run
description: Execution loop for a signed-off DAG of work — dispatches each node behind the merge gate, climbs the escalation ladder on findings, and drives every node to done-clean, wave by wave.
disable-model-invocation: true
---

# Run — drive the DAG to done-clean

The loop you live in from a signed **pre-flight** until the **DAG** is done. It runs the DAG **wave by
wave**, each **node** behind the **merge gate**, carrying the **ladder**, **fix-completeness**, the
**proof ledger**, and close-on-proof. Terms are defined once in [`../../GLOSSARY.md`](../../GLOSSARY.md).

**The core loop, per node:** dispatch a self-contained brief → **merge gate** (CI + independent review
whose verdict is *posted to the PR* + your own cold read) → merge → deploy → satisfy the **proof
contract** live → close the issue.

**The one shape, everywhere:** one agent = one node = one worktree = one PR. You own deploy and live
proof; agents never touch the live box.

**The one knob — autonomy level** (set at step 1, from the router):
- **autonomous** (default) — the **inner loop** (diagnose the nest, apply the consolidating fix,
  continue) runs freely; the **outer loop** fires only for the three rung-3 cases below, pre-validated.
- **supervised** — diagnose the nest autonomously, but return with the validated diagnosis *before*
  applying a consolidating fix.

Inputs: the signed pre-flight table (nodes, edges, proof contracts) and each node's spec. Work the steps
in order; steps 2–5 repeat per wave until the DAG is done.

## 1. Open the run

Fix the **autonomy level** for this run. Seed the **proof ledger**: one row per node carrying the
**proof contract** pre-flight signed, every row marked unsatisfied. The ledger is the single record that
keeps **triage-clean** (reviews pass) from ever passing for **done-clean** (proof gathered).

*Done when:* the autonomy level is fixed, and every node in the DAG has a ledger row with its proof
contract and an unsatisfied mark.

## 2. Dispatch the wave

Compute the ready set: every unstarted node whose blocking **edges** have all merged. Dispatch each as
one agent in its own worktree with a **self-contained brief** — the fields and the shape constraint are
in [`dispatch-brief.md`](dispatch-brief.md). Hold in-flight nodes under a small concurrency ceiling, so
each runs in a fresh context and you can cold-read every diff yourself.

*Done when:* every ready node has a dispatched agent whose brief carries its acceptance criteria, proof
contract, consumed edges, and the fix-completeness rule; nothing over the ceiling; and every in-flight
node's edges are all merged.

## 3. Work the merge gate

A node merges only when all three signals are clean: CI green; an **independent review** — bot or
subagent — whose **verdict is posted to the PR as a comment**, never left in a transcript; and your own
cold read of the full diff. Each review round returns findings; every round's findings feed the ladder
(step 4), and the fix goes back through all three signals.

*Done when:* CI is green, the review verdict is posted to the PR, your cold read is clean, and every
finding of the last round was resolved through the ladder — the node is **triage-clean**.

## 4. Climb the ladder

The response to review findings, per round. Climb the moment any trigger fires — hold nothing back for
the round count.

| Rung | Mode | What you do |
|---|---|---|
| **1 — Patch** | triage | Fix the reported defect. The normal response for rounds 1–2. |
| **2 — Diagnose + fix** (inner loop) | diagnosis | Stop patching. Invoke `/dag:diagnose` on the **cluster**; act on its verdict below. Autonomous by default. |
| **3 — Stop** (outer loop, rare) | escalate | Surface to the human, **pre-validated**. |

**Climb to rung 2 the moment any trigger fires:**
- **The tell** — a finding whose fix needs a *new mechanism*, not a tightened check.
- **Class-recurrence** — the same bug-class a *second time*. The primary trigger; act on the recurrence,
  not on a count.
- **Round-count backstop** — round **4** reached, whatever the findings look like. By four, a pattern is
  real. This backstop has teeth: hitting it *is* the climb, not a suggestion.

**Act on `/dag:diagnose`'s verdict (the rung-2 → rung-3 stop line):**
- **code-wrong** — the implementation was wrong. Apply the consolidating fix and continue, staying on
  rung 2, no human. Under **supervised** autonomy, return the validated diagnosis first, then apply.
- **independent** — no nest; the findings are genuinely unrelated. Resume patching at rung 1, with
  confidence.
- **node-wrong** — the node's spec or premise is wrong. Climb to rung 3.

**Rung 3 fires only** when diagnose returns **node-wrong**, the node's live proof cannot be gathered, or
the consolidating fix would cost more than the node is worth. It arrives pre-validated: the **nest**, a
confidence level, and whether the fix unblocks — a stop the human can act on, not a bare "I'm stuck."
The node goes back to CREATE / pre-flight.

**Fix-completeness binds every fix on every rung, the consolidating one included:** before a fix is
done, enumerate every branch and caller its reasoning touches, and cover each. A consolidating fix
covers *every call site of the nest* — half a consolidation reopens the class it was meant to close.

*Done when:* every finding of the round is patched (rung 1, fix-complete), folded into a consolidating
fix (rung 2, fix-complete over the whole nest), or raised as a pre-validated stop (rung 3) — and no
finding is still being patched after a trigger has fired.

## 5. Finish the node

Triage-clean clears the node to merge; it does not make the node done. Carry it through, in one sitting:
merge → deploy (you, never the agent) → satisfy the **proof contract** live, gathering the node's nonce
and receipt into its ledger row → **done-clean**. **Proof is never deferred** — you never merge a node
whose live proof you already know can't be gathered (that is a rung-3 stop), and you never leave a merged
node's proof for "post-deploy" or "later." The instant the proof contract is satisfied, close the node's
issue in the same step — close-on-proof, so the recorded state never drifts from the real one.

*Done when:* the node is deployed, its proof contract is satisfied live with the receipt in its ledger
row, and its issue is closed — or the node is a rung-3 stop and its ledger row says so.

## 6. Advance the DAG

A wave is complete when every node in it is done-clean and closed — merges alone don't complete it.
Recompute the ready set (step 2) and run the next wave. The DAG is done when every ledger row is
satisfied-and-closed or a recorded stop.

*Done when:* every node in the DAG is done-clean with a closed issue, or is an open rung-3 stop returned
to CREATE — no node left in an in-between state.
