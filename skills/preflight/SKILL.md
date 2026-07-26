---
name: preflight
description: Internal planning gate reached through dag:plan — validate every node's invariants, criteria, edges, and proof contract before dispatch. Do not invoke directly outside the planning router.
---

# Pre-flight — validate the DAG

Run this **once**, after a **DAG** of **nodes** and **edges** exists (laid down by `/dag:chart`) and
before Wave 1 dispatch. It is the whole-DAG conformance gate: catch every architecture violation here,
against the *design*, where it is cheap — not later, in review, against the *code*, where it is most
expensive. Terms below are defined once in [`../../GLOSSARY.md`](../../GLOSSARY.md), and how to respond is in
[`../../RESPONSE-RULES.md`](../../RESPONSE-RULES.md).

Inputs: the DAG, the project's architecture-**invariant** doc, and each node's written spec (its
acceptance criteria). Work the four steps in order; each produces one column of the signed table.

**Judge the open build nodes only.** De-fog nodes — grilling, research, spike — are planning moves, not
dispatchable work: they carry no proof contract by design, and `/dag:plan` closes each one as its answer
lands. A de-fog node still open here means planning isn't finished, and that is a stop before pre-flight
rather than a node to validate. If the repo has no architecture-invariant doc, say so and judge against
whatever design record exists rather than blocking on a file the suite never creates.

## 1. Invariant conformance, per node

For each node, read its spec and name which architecture **invariants** it touches. For each invariant
touched, confirm the node's *design* will satisfy it — there is no code yet, so you are checking the
plan, not an implementation. Give the node one verdict:

- **satisfies** — the design meets every invariant it touches.
- **at-risk** — the design plausibly meets them but a specific choice is unconfirmed; name the choice.
  A working state for the length of this audit only — it cannot survive the signature, and the rule that
  says so is at the bottom of this file.
- **re-plan** — the design cannot satisfy an invariant as written.

*Done when:* every node in the DAG carries an invariant list and one of the three verdicts — no node
left unjudged, and every at-risk node names the unconfirmed choice it is waiting on rather than the
verdict alone.

## 2. Acceptance-criteria checkability

For each node, read each written acceptance criterion and confirm it can be checked against a *design*
now. A criterion you can only settle by running finished code is a criterion that will be validated
reactively, in review — the exact failure this gate exists to prevent. Where a criterion is
design-checkable, it belongs in that node's proof-contract reasoning (step 4).

*Done when:* every acceptance criterion of every node is marked **design-checkable** or **code-only**,
and each code-only criterion names why it resists a design check.

## 3. Edge audit

For each declared blocking **edge**, confirm it is real: node B genuinely cannot proceed until node A
merges. Then hunt **hidden edges** — a node depending on another's *specific implementation choice*, not
merely its merge. The motivating case: one node consumed a data shape a sibling had chosen internally,
and the declared edges recorded only the merge dependency, never the shape — so the coupling was
invisible until review. For every pair that shares a contract, a shape, or a name one side defines and
the other consumes, add the missing edge now.

**Note file-level contention, but do not make it an edge.** Two nodes with no dependency between them can
still be dispatched into the same wave and both rewrite the same package — the first to merge invalidates
the other's branch *and the proof gathered on it*. That is not a blocking edge and must not become one;
it is a scheduling note, recorded here because this is the only pass that sees every node's touched
surface at once. Name which nodes contend, so a wave can be composed without paying for the same rebase
and re-proof twice.

**Findings across nodes are a cluster too.** Several nodes failing the same invariant, or several hidden
edges carrying the same shape, is one design gap rendered N times — apply **looking for the nest** and say
so before sending each node back on its own. A DAG re-planned node-by-node against one root cause gets
re-planned again.

*Done when:* every declared edge is confirmed-or-removed, every node has been checked for hidden edges
against the nodes it shares a contract with — new edges added where found — contending nodes are named as
a scheduling note rather than edged, and any pattern across nodes is called a possible shared root rather
than logged N times.

## 4. Proof contract, per node

Each node's **proof contract** was written into its issue when the node was created. Here you validate
it — you are not inventing it now, and neither will the agent that builds the node.

### Baseline every tier command before you judge a single node

Collect every distinct command any node's contract names, and **run each one, on the base branch, now**.
Record the result. This is the one place in this gate where you execute something, and it is deliberate:
every other check here asks whether a contract is *coherent*, and a command can be perfectly coherent,
correctly named, and have been exiting non-zero for days. **A contract is runnable only if the thing it
names runs today.**

A command that does not pass is not a runnable tier. Every node naming it is a **stop**, and repairing
the command becomes its own node — the chart does not get signed over a bar nothing can clear.

**The repair node is the exception, and without it nothing moves.** Its whole job is to turn that command
green, so a red baseline is its *starting condition*, not a disqualification. Hold the ordinary rule to it
and you deadlock the chart: the repair node's own contract names the broken command, so it is a stop too,
so the DAG never signs, so `/dag:execute` never dispatches the one node that would fix it, and the command
stays red forever. Sign it. Its contract records the red baseline as the "before" and the command passing
as the proof it is done — a genuinely stronger contract than most, because the failure is already
observed. Every other node naming that command stays a stop until the repair merges and the command
**re-baselines green**; blocking them behind the repair node is `/dag:replan`'s job, not a reason to
refuse the signature.

It is cheap by construction: a chart of twenty nodes usually names three or four distinct commands, so
this is one run each, not one per node.

**A tier reached through a shared environment rather than a command is baselined differently** — name
**when that path was last exercised end to end**. Never exercised is not a runnable tier either: the
first node to depend on it is sequenced behind a **spike** that exercises the path, rather than dispatched
alongside two siblings that all take a first dependency on it at once. Three nodes discovering together
that a shared path was never real is one failure paid for three times.

*Done when:* every distinct tier command in the chart has been run on the base branch with its result
recorded; every environment-reached tier carries when it was last exercised end to end; every command that
failed, or path never exercised, is named along with every node depending on it; and any repair node for a
red command is signed rather than stopped by the command it exists to fix.

### Then, per node, check its contract against the map's **proof profile**

- Its **tiers** exist in this repo, each names the command or query that reaches it, and that command
  **passed the baseline above**. "It is named in the repo's task runner" is not the check; "it was green
  a moment ago" is.
- Its **evidence form** matches its **surface** — a UI node yields screenshots and a video, a backend
  node a durable delta with exact ids, a CLI node its captured output. Every node has a surface, so no
  node is exempt.
- The evidence is *reachable* — the states are observable and the records readable once the node is
  built. If satisfying the contract would need something the node doesn't build, add it to the node.
- Its **stage** follows the profile, not the node: where tier 3 is reachable from a branch the contract
  is a **merge gate** signal; where it isn't, the contract names the shared environment it waits on.
- A **nonce** ties the evidence to its run.

**The hard rule:** a node whose contract cannot be run as written does not pass pre-flight — and *cannot
be run* means **red at the baseline just now**, not merely incoherent on paper. "Prove it later" is
banned — it is a **stop**, sent back to reshape the node into something provable, or to a **spike** when
whether it can be observed at all is itself the unknown. A design that admits no proof is a design no one
can call done.

*Done when:* every node's contract is validated against the profile — tiers reachable, evidence form
matching its surface, nonce present — or the node is marked **stop** and returned to planning.

## Sign the pre-flight

Emit the **baseline** first — one row per distinct tier command or environment-reached path, shared by
every node that names it:

| tier command / path | how baselined | result | nodes depending on it |
|---|---|---|---|
| … | run on the base branch just now / last exercised end to end on `<date>` | green, or red + what failed | the node numbers |

A red row or a never-exercised path makes every node in its last column a **stop**, whatever the rest of
that node's row says.

Then one table, one row per node:

| node | invariants touched | invariant verdict | acceptance criteria | edges + couplings | proof contract |
|---|---|---|---|---|---|
| … | the invariants, named | satisfies / at-risk **→ settled how** / re-plan | all design-checkable? | confirmed, plus the exact contract/shape/name each hidden edge carries | the runnable contract, or **stop** |

**Name the invariants and the couplings, don't just grade them.** Both the dispatch brief and the
review brief quote this table per node — "invariants touched, as pre-flight named them" and "the
exact contract/shape/name it consumes". A verdict word alone leaves those fields to be reconstructed
from the pre-flight author's context window, which is the one place the suite says state must never
live.

Any node with a **re-plan** verdict or a **stop** proof contract is not dispatchable. It goes back to
planning before Wave 1 begins — `/dag:plan` routes it to a grill, a spike, or a re-chart.

**An at-risk verdict cannot survive the signature.** Either the unconfirmed choice is settled here and
recorded on that node's issue — making the node **satisfies** — or it gets a **de-fog node**: a new issue
carrying `dag:needs-grilling`, blocking the at-risk node, and the chart is not complete. There is no third
state to carry forward, and no label to invent for one: at-risk *means* an open decision, which the
readiness vocabulary already names and the planning router already routes. A verdict this gate writes and
nothing reads back is a verdict that gets signed over, and it looks handled while it does it.

**The label goes on the new de-fog node, never on the at-risk node itself.** `/dag:plan` closes a
readiness-labelled issue when its move lands, and that close is how the node behind it reaches the
frontier — so a build node wearing the label is a build node planning will close, with the work unbuilt
and its proof contract unsatisfied. Same shape `chart` uses for every other de-fog signal.

Pre-flight is signed only when every remaining node is **satisfies**, fully design-checkable,
edge-audited, and carries a proof contract. Only a signed pre-flight clears the DAG for dispatch.

**Record the signature on the chart.** Post the signed table as a comment on the `dag:map` issue and add
the `dag:preflighted` label to it. That label *is* the signature — it lives on GitHub, so `/dag:plan`
reads it from any context window and hands the DAG to `/dag:execute`. Whoever sends a node back to planning later
removes that label in the same step, and pre-flight must be re-signed before execution resumes.
