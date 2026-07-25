---
name: execute
description: The execution door — walks a pre-flight-signed DAG, dispatching each node behind the merge gate, climbing the escalation ladder on findings, and driving every node to done-clean, wave by wave.
disable-model-invocation: true
---

# Execute — walk the signed DAG to done-clean

The loop you live in from a signed **pre-flight** until the **DAG** is done. It runs the DAG **wave by
wave**, each **node** behind the **merge gate**, carrying the **ladder**, **fix-completeness**, the
**proof ledger**, and close-on-proof. Terms are defined once in [`../../GLOSSARY.md`](../../GLOSSARY.md).

**The core loop, per node:** dispatch a self-contained brief → **merge gate** (CI + independent review
whose verdict is *posted to the PR* + your own cold read + the **proof contract** satisfied, wherever
the **proof profile** says tier 3 is reachable from a branch) → merge → close the issue. Where tier 3
needs the merged head instead, proof runs straight after the merge and the issue closes on it.

**The one shape, everywhere:** one **teammate** = one node = one worktree = one PR. You are the team
lead: each teammate runs its own node and captures the evidence its contract names, and you grade what
comes back. Nobody grades their own homework — the contract was fixed before the code existed, and the
**verdict** is yours. Where the profile puts a tier behind a shared environment, that tier is yours to
reach as well.

**How this run behaves comes from the map's run profile** — the concurrency cap, the model per role,
and the **autonomy level** — not from this conversation, so a fresh context window runs the DAG the way
the last one did. Autonomy decides how freely the loop runs:
- **autonomous** (default) — the **inner loop** (diagnose the nest, apply the consolidating fix,
  continue) runs freely; the **outer loop** fires only for the three rung-3 cases below, pre-validated.
- **supervised** — diagnose the nest autonomously, but return with the validated diagnosis *before*
  applying a consolidating fix.

Inputs: the signed pre-flight table (nodes, edges, proof contracts) and each node's spec. Work the steps
in order; steps 2–5 repeat per wave until the DAG is done.

## 1. Open the run

**Check the signature before anything else.** The map must carry the `dag:preflighted` label. That label
*is* the door between the two halves: planning is `/dag:plan`'s, execution is yours, and the signature is
what moved the DAG across. Without it, this DAG is not cleared for dispatch — say so plainly and hand
back to `/dag:plan`, which routes to `/dag:preflight`. A wave dispatched off an unsigned DAG is the
whole failure the gate exists to prevent.

Then read the run's inputs **off GitHub**, not off memory — this window may be the second one:

```bash
R=<owner>/<repo>
gh issue view <map-number> --json body,labels          # run profile, proof profile, Skills line
gh issue view <map-number> --comments --json comments  # the signed pre-flight table
gh api --paginate repos/$R/issues/<map-number>/sub_issues --jq '.[] | {number,title,state}'
```

**Derive the proof ledger; never store it in this conversation.** One row per open node — its **proof
contract** from the node's own issue body, and whichever tiers already carry a recorded result in that
issue's comments. The ledger is the record that keeps **triage-clean** (reviews pass) from ever passing
for **done-clean** (proof gathered, in the PR), so it has to survive a crashed window: as each tier's
result lands, post it to that node's issue. A ledger held only in context is a ledger that resumes as an
empty one, and a merged-but-unproven node then looks exactly like a done-clean one.

*Done when:* the map carries `dag:preflighted`, the run profile and signed table have been read off
GitHub, and every open node has a ledger row derived from its issue — or you have stopped and handed
back because the signature is absent.

## 2. Dispatch the wave

Compute the ready set: every unstarted node whose blocking **edges** are all **closed** — the same
predicate `chart`, `plan` and GitHub's own UI use, so the frontier you dispatch is the frontier the
tracker renders. Under close-on-proof a blocker closes when its proof lands, not when it merges.

Give each ready node to one **teammate**, working in its own worktree from a **self-contained brief** — the fields and
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
in-flight node's edges are all closed.

## 3. Work the merge gate

A node merges only when every signal is clean: CI green; an **independent review** — whichever the map's
Skills line names, briefed with [`review-brief.md`](review-brief.md) and its **verdict posted to the PR
as a comment**, never left in a transcript; your own cold read of the full diff; and — wherever the
**proof profile** says tier 3 is reachable from a branch — the node's **proof contract** satisfied by
`/dag:prove`, with the evidence in the PR. Each review round returns findings; every round's findings feed the ladder (step 4), and the fix goes back through every signal.

**Proof belongs at this gate whenever it can be reached from the branch.** The open PR is the one moment
a reviewer is actually reading, and a node whose proof can't be gathered has not earned a merge — far
cheaper to learn before the merge than after. Only where tier 3 genuinely needs the merged head does
proof move to step 5.

*Done when:* CI is green, the review verdict is posted to the PR, your cold read is clean, every finding
of the last round was resolved through the ladder, and the proof contract is satisfied — or the profile
says this node's tier 3 waits for the merged head.

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
**Unsign the DAG before you surface the stop**, or the next fresh window reads the signature and resumes
autonomous execution over a graph you just halted:

```bash
gh issue edit <map-number> --remove-label dag:preflighted
```

The node then goes back to `/dag:plan`, which routes it to a grill, a spike, or a re-chart, and
pre-flight is re-signed before execution resumes.

**Fix-completeness binds every fix on every rung, the consolidating one included:** before a fix is
done, enumerate every branch and caller its reasoning touches, and cover each. A consolidating fix
covers *every call site of the nest* — half a consolidation reopens the class it was meant to close.

*Done when:* every finding of the round is patched (rung 1, fix-complete), folded into a consolidating
fix (rung 2, fix-complete over the whole nest), or raised as a pre-validated stop (rung 3) — and no
finding is still being patched after a trigger has fired.

## 5. Finish the node

Where tier 3 was reachable from the branch, the node arrives here already proven — the merge gate took
its evidence in step 3. Merge it, and close its issue on the satisfied contract.

Where tier 3 needs the merged head, triage-clean clears the node to merge but does not make it done.
Carry it through in one sitting: merge → get the head running the way the profile says this repo runs
it → **`/dag:prove`** the node, which runs its **proof contract** at each **tier**, captures the evidence
in the form its surface calls for, commits the **receipt**, and posts the tier table and the evidence
**into the PR** → **done-clean**.

The contract was written when the node was created, so nothing here is invented now: the agent that built
the node never chose its own bar, and you are checking evidence against a bar set before the code existed.

**Proof is never deferred, and never merely asserted.** You never merge a node whose proof you already
know can't be gathered (that is a rung-3 stop), you never leave a merged node's proof for "later," and a
tier with no evidence in the PR is `NOT PROVEN` — never promoted from a tier that was reached. Record each
tier's verdict in the ledger row. The instant the contract is satisfied, close the node's issue in the
same step — close-on-proof, so the recorded state never drifts from the real one.

*Done when:* `/dag:prove` has returned a verdict for every tier in the node's contract with the evidence
posted to the PR and the receipt committed, the node is merged, and its issue is closed — or the node is
a rung-3 stop and its ledger row says which tier failed and why.

## 6. Advance the DAG

A wave is complete when every node in it is done-clean and closed — merges alone don't complete it.
Recompute the ready set (step 2) and run the next wave. The DAG is done when every ledger row is
satisfied-and-closed or a recorded stop.

*Done when:* every node in the DAG is done-clean with a closed issue, or is an open rung-3 stop returned
to planning — no node left in an in-between state.

## 7. End the turn with a position — every time, no exceptions

Execution runs long and unattended, so a turn ends whenever the loop pauses: a wave completed, a rung-3
stop, the DAG done, or the context window running out mid-wave. **Whichever it is, the last thing in the
turn is this block.** Not a log of what happened; a statement of where the run now stands.

```markdown
**Where we are** — <wave N of the DAG; how many nodes done-clean, in flight, blocked>

**What's saved, and where** — <closed issues, merged PRs, committed receipts; then open PRs and worktrees>

**What happens next** — <the next wave, or the decision a stop needs from the user>

**What you do** — <almost always: nothing, or run `/dag:execute` again>
```

- **Where we are** — position in the DAG, in nodes rather than prose. The user has not been watching.
- **What's saved, and where** — durable first (closed issues, merged commits, committed receipts), then
  what is still in flight (open PRs, live worktrees). Those two have very different survival odds, and a
  resumed session inherits only the first cleanly.
- **What happens next** — the next wave, which is yours to run. The one case where it is genuinely the
  user's is a rung-3 stop, and then say exactly what the decision is.
- **What you do** — usually **nothing, or run `/dag:execute` again**. Say it plainly. Re-running the same
  command resumes from the tracker, and a user who has not read the docs has no way to know that.

**A stop is not an ending, and must not read like one.** When the ladder reaches rung 3 the block still
closes the turn — with the named nest, whether fixing it unblocks the rest of the graph, and the fact that
`dag:preflighted` has been removed so the DAG is back in planning. A stop that reads as a failure report
leaves the user with a diagnosis and no idea what to do with it.

**Never hand over a planning command.** If the answer is that planning has to happen again, say so and
name **`/dag:plan`** — the other door. Never `/dag:grill`, never `/dag:preflight`.

*Done when:* the turn's final block carries all four lines, the position is stated in nodes, in-flight
work is listed separately from durable work, and "what you do" states plainly that re-running
`/dag:execute` resumes.
