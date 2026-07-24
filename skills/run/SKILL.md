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

**The one shape, everywhere:** one **teammate** = one node = one worktree = one PR. You are the team
lead; you own deploy and live proof, and the live box is yours alone.

**The one knob — autonomy level** (set at step 1, from the router):
- **autonomous** (default) — the **inner loop** (diagnose the nest, apply the consolidating fix,
  continue) runs freely; the **outer loop** fires only for the three rung-3 cases below, pre-validated.
- **supervised** — diagnose the nest autonomously, but return with the validated diagnosis *before*
  applying a consolidating fix.

Inputs: the signed pre-flight table (nodes, edges, proof contracts) and each node's spec. Work the steps
in order; steps 2–5 repeat per wave until the DAG is done.

## 1. Open the run

Fix the **autonomy level** for this run. Seed the **proof ledger**: one row per node carrying the
**proof contract** pre-flight signed — its **tiers**, **evidence form**, and **nonce** — every tier
marked unsatisfied. The ledger is the single record that keeps **triage-clean** (reviews pass) from ever
passing for **done-clean** (proof gathered, in the PR).

*Done when:* the autonomy level is fixed, and every node in the DAG has a ledger row carrying its proof
contract's tiers, each unsatisfied.

## 2. Dispatch the wave

Compute the ready set: every unstarted node whose blocking **edges** have all merged. Give each ready
node to one **teammate**, working in its own worktree from a **self-contained brief** — the fields and
the shape constraint are in [`dispatch-brief.md`](dispatch-brief.md).

**An agent team is how a wave runs, and its mechanics shape the work:**

- A teammate inherits the repo's own context and its brief — **never your conversation**. The brief is
  its whole world, which is why self-contained is a hard requirement rather than a style.
- The team's shared task list unblocks a task the moment its blockers complete — the same **frontier**
  you compute here, kept live. Let it, and re-derive the frontier from GitHub rather than from memory.
- **Size the team from the frontier, not the DAG**: three focused teammates beat five scattered ones, and
  a wave of four ready nodes wants about four. Stay under the **concurrency cap** so each node runs in a
  fresh context and you can cold-read every diff yourself.
- One worktree each keeps two teammates off the same file.
- A teammate cannot spawn teammates, so a node is sized to be carried by one.
- A resumed session does not restore teammates. That costs you the spawns and nothing else — the chart
  is on GitHub, so re-read the state and give the open nodes to fresh teammates.

*Done when:* every ready node has a teammate whose brief carries its acceptance criteria, proof contract,
consumed edges, and the fix-completeness rule; the team is within the concurrency cap; and every
in-flight node's edges are all merged.

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
merge → deploy (you, never the agent) → **`/dag:prove`** the node, which runs its **proof contract** at
each **tier**, captures the evidence in the form its surface calls for, commits the **receipt**, and posts
the tier table and the evidence **into the PR** → **done-clean**.

The contract was written when the node was created, so nothing here is invented now: the agent that built
the node never chose its own bar, and you are checking evidence against a bar set before the code existed.

**Proof is never deferred, and never merely asserted.** You never merge a node whose proof you already
know can't be gathered (that is a rung-3 stop), you never leave a merged node's proof for "later," and a
tier with no evidence in the PR is `NOT PROVEN` — never promoted from a tier that was reached. Record each
tier's verdict in the ledger row. The instant the contract is satisfied, close the node's issue in the
same step — close-on-proof, so the recorded state never drifts from the real one.

*Done when:* the node is deployed, `/dag:prove` has returned a verdict for every tier in its contract with
the evidence posted to the PR and the receipt committed, and its issue is closed — or the node is a rung-3
stop and its ledger row says which tier failed and why.

## 6. Advance the DAG

A wave is complete when every node in it is done-clean and closed — merges alone don't complete it.
Recompute the ready set (step 2) and run the next wave. The DAG is done when every ledger row is
satisfied-and-closed or a recorded stop.

*Done when:* every node in the DAG is done-clean with a closed issue, or is an open rung-3 stop returned
to CREATE — no node left in an in-between state.
