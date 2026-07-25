---
name: execute
description: The execution door — walks a pre-flight-signed DAG, dispatching each node behind the merge gate, climbing the escalation ladder on findings, and driving every node to done-clean, wave by wave.
disable-model-invocation: true
---

# Execute — walk the signed DAG to done-clean

Enter through `/dag:execute` in Claude Code or `$dag:execute` in Codex.

The loop you live in from a signed **pre-flight** until the **DAG** is done. It runs the DAG **wave by
wave**, each **node** behind the **merge gate**, carrying the **ladder**, **fix-completeness**, the
**proof ledger**, and close-on-proof. Terms are defined once in [`../../GLOSSARY.md`](../../GLOSSARY.md), and how to respond is in
[`../../RESPONSE-RULES.md`](../../RESPONSE-RULES.md).

**The core loop, per node:** dispatch a self-contained brief → **merge gate** (CI + independent review
whose verdict is *posted to the PR* + your own cold read + the **proof contract** satisfied, wherever
the **proof profile** says tier 3 is reachable from a branch) → merge → close the issue. Where tier 3
needs the merged head instead, proof runs straight after the merge and the issue closes on it.

**The one shape, everywhere:** one **teammate** = one node = one worktree = one PR. You are the main
**orchestrator**: you read the frontier, create each worktree, assign each node, and grade what comes back.
Each teammate runs only its assigned node and captures the evidence its contract names; it never
self-claims another node or spawns another agent. Nobody grades their own homework — the contract was
fixed before the code existed, and the **verdict** is yours. Where the profile puts a tier behind a shared
environment, that tier is yours to reach as well.

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

**Check the signature before anything else.** The map must carry the `dag:preflighted` label, and must
*not* carry `dag:halted`. That first label *is* the door between the two halves: planning is
`/dag:plan`'s, execution is yours, and the signature is what moved the DAG across. Without it, this DAG
is not cleared for dispatch — say so plainly and hand back to `/dag:plan`, which routes it. A wave
dispatched off an unsigned DAG is the whole failure the gate exists to prevent, and a wave dispatched off
a halted one repeats a stop a human already raised.

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

Before assigning a node, create its branch and worktree from the run's current base, then give the
teammate the absolute worktree path and a **self-contained brief** — the fields and shape constraint are
in [`dispatch-brief.md`](dispatch-brief.md). The orchestrator owns worktree creation and cleanup; a
teammate never creates its own checkout.

**Choose exactly one runner from the host — never mix runners inside one DAG:**

- **Claude Code → Agent Teams.** The lead creates the team and assigns one ready node to each teammate.
  Agent Teams must be available and enabled; if they are not, stop before dispatch and say what capability
  is missing. Do not fall back to Claude subagents. The lead alone creates and assigns tasks. Teammates do
  not self-claim from the shared task list; that list records the lead's current assignments, while GitHub
  remains the only dependency graph and source of the frontier.
- **Codex → native child agents.** The main agent calls `spawn_agent` once per assigned node, using a
  worker role, `fork_turns: "none"`, and the self-contained brief. Do not create user-owned sidebar
  threads for node work. The main agent alone follows up, waits, interrupts and assigns; child agents do
  not delegate further.

**The mechanics common to both runners:**

- **Size the team from the frontier, not the DAG**: `min(frontier size, run-profile concurrency cap,
  available worker slots)`. Keep the orchestrator itself out of the worker count.
- One explicit worktree each keeps two teammates off the same file.
- A teammate receives the repo's instruction context plus its brief, not an assumed copy of the
  orchestrator's reasoning. The brief is its whole job.
- Recompute the frontier from GitHub after a node becomes done-clean. Never let a worker claim the next
  node from runtime state.
- A resumed session does not restore teammates. Re-read GitHub, open PRs and worktrees, then assign each
  still-open node to a fresh teammate through the same host runner.

*Done when:* every ready node has a teammate whose brief carries its acceptance criteria, proof contract,
consumed edges, exact branch and worktree, and the fix-completeness rule; the team is within both the run
cap and host capacity; every in-flight node's edges are all closed; and no teammate owns more than one
node.

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

**Proof must be current with the code it is about to merge with.** Evidence gathered at an earlier commit
is evidence about *that* commit, and review fixes landing after it can change the very behaviour it
claimed. Here the comparison is against **the PR head** — not the base branch, which does not contain this
node's work yet and would report the whole feature as a difference every time:

```bash
git diff <proof-head> <pr-head> -- <paths the contract's evidence covers>
```

Empty means the proof still describes what is about to merge. Non-empty means re-prove — and a re-proof is
not merely fresher, it is often strictly better evidence, because the fixes it runs against created states
the first run could not reach.

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
**Freeze dispatch immediately, then mark the halt before you surface the stop.** Assign no fresh node.
Compare every in-flight node with the named nest: interrupt the teammates whose premise or proof contract
depends on it; let an in-flight node continue only when you can show it is independent. Then mark both the
map and the node, in that order. Removing the signature alone is *lossy*: a chart you halted and a chart
nobody ever signed look identical to `/dag:plan`, so it routes both straight back to signing, with the
same method that just failed.

```bash
R=<owner>/<repo>
gh issue edit <map-number> --remove-label dag:preflighted --add-label dag:halted

# the question the stop raises becomes its own de-fog node, blocking the stopped one
gh issue create --title "De-fog: <the question>" --label dag:needs-grilling \
  --body "<the pre-validated nest, and what settling it unblocks>"   # or dag:needs-prototype,
                                                                     # if whether it can be
                                                                     # observed is the unknown
gh api repos/$R/issues/<defog-number> --jq .id
gh api -X POST repos/$R/issues/<stopped-node>/dependencies/blocked_by -F issue_id=<defog-database-id>
```

**Never put the readiness label on the stopped node itself.** `/dag:plan` closes a readiness-labelled
issue the moment its move lands — that close is precisely how the build node behind it reaches the
frontier. Label the build node and planning closes *the build node*, unbuilt, unproven, and looking done.
The de-fog node is a separate issue that blocks it, which is the same shape `chart` uses everywhere else.

`dag:halted` is what stops the next fresh window resuming autonomous execution over a graph you just
stopped. The de-fog node is what stops the stopped node arriving back in planning as an ordinary open
issue with nothing on it to say a human halted here. The chart then goes back to `/dag:plan`, which routes
it to a **re-plan**, and pre-flight is re-signed in full before execution resumes.

**Fix-completeness binds every fix on every rung, the consolidating one included:** before a fix is
done, enumerate every branch and caller its reasoning touches, and cover each. A consolidating fix
covers *every call site of the nest* — half a consolidation reopens the class it was meant to close.

*Done when:* every finding of the round is patched (rung 1, fix-complete), folded into a consolidating
fix (rung 2, fix-complete over the whole nest), or raised as a pre-validated stop (rung 3) — and no
finding is still being patched after a trigger has fired; on rung 3, dispatch is frozen and every
in-flight node has been interrupted-or-proven-independent.

## 5. Finish the node

Where tier 3 was reachable from the branch, the node arrives here already proven — the merge gate took
its evidence in step 3. Merge it, and close its issue on the satisfied contract.

**Past the merge, currency is checked by content, never by ancestry.** A squash merge does not keep the
proof commit as an ancestor, so `git merge-base --is-ancestor` answers "not merged" for work that merged
perfectly. Now that the base *does* contain the node's work, diffing against it is the reliable check:

```bash
git diff <proof-head> origin/main -- <paths the contract's evidence covers>
```

Empty confirms the evidence still describes what shipped. Non-empty means the merge changed something the
proof spoke for — a conflict resolution, a rebase, someone else's node landing in the same paths — and the
node owes a re-proof before it closes.

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
stop, the DAG done, or the context window running out mid-wave.

**Read [`../../RESPONSE-RULES.md`](../../RESPONSE-RULES.md) before you write the closing message.**
Not optional and not a reference for later: the shape lives there and nowhere else, and there is
deliberately no template here to copy from.

What is specific to this door, and additional to that file:

- **State position in nodes, not prose** — how many done-clean, in flight, blocked. The user has not been
  watching.
- **List durable work separately from in-flight work.** Closed issues, merged commits and committed
  receipts survive a crash; open PRs and live worktrees do not, and a resumed session inherits only the
  first cleanly. Blurring them tells the user they have more than they do.
- **A stop is not an ending and must not read like one.** When the ladder reaches rung 3 the closing
  message still carries the named **nest**, whether fixing it unblocks the rest of the graph, and the fact
  that the map now carries `dag:halted` instead of `dag:preflighted` so the DAG is back in planning. A
  stop that reads as a failure report leaves the user holding a diagnosis with nothing to do about it.
- **"What you do" says that re-running resumes** — usually *nothing, or run `/dag:execute` again*. And
  where planning has to happen again, name `/dag:plan`, the other door. Never `/dag:grill`, never
  `/dag:preflight`.

*Done when:* you have read `RESPONSE-RULES.md` this turn and the closing message follows it; position is
stated in nodes; in-flight work is listed separately from durable work; and "what you do" states plainly
that re-running `/dag:execute` resumes.
