---
name: preflight
description: Pre-flight gate for a DAG of work — validates every node against its invariants, acceptance criteria, edges, and proof contract before any dispatch.
disable-model-invocation: true
---

# Pre-flight — validate the DAG

Run this **once**, after a **DAG** of **nodes** and **edges** exists (laid down by `/dag:chart`) and
before Wave 1 dispatch. It is the whole-DAG conformance gate: catch every architecture violation here,
against the *design*, where it is cheap — not later, in review, against the *code*, where it is most
expensive. Terms below are defined once in [`../../GLOSSARY.md`](../../GLOSSARY.md).

Inputs: the DAG, the project's architecture-**invariant** doc, and each node's written spec (its
acceptance criteria). Work the four steps in order; each produces one column of the signed table.

## 1. Invariant conformance, per node

For each node, read its spec and name which architecture **invariants** it touches. For each invariant
touched, confirm the node's *design* will satisfy it — there is no code yet, so you are checking the
plan, not an implementation. Give the node one verdict:

- **satisfies** — the design meets every invariant it touches.
- **at-risk** — the design plausibly meets them but a specific choice is unconfirmed; name the choice.
- **re-plan** — the design cannot satisfy an invariant as written.

*Done when:* every node in the DAG carries an invariant list and one of the three verdicts — no node
left unjudged.

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

*Done when:* every declared edge is confirmed-or-removed, and every node has been checked for hidden
edges against the nodes it shares a contract with — new edges added where found.

## 4. Proof contract, per node

Each node's **proof contract** was written into its issue when the node was created. Here you validate
it — you are not inventing it now, and neither will the agent that builds the node.

For each node, check its contract against the map's **proof profile**:

- Its **tiers** exist in this repo and each names the command or query that reaches it.
- Its **evidence form** matches its **surface** — a UI node yields screenshots and a video, a backend
  node a durable delta with exact ids, a CLI node its captured output. Every node has a surface, so no
  node is exempt.
- The evidence is *reachable* — the states are observable and the records readable once the node is
  built. If satisfying the contract would need something the node doesn't build, add it to the node.
- Its **stage** follows the profile, not the node: where tier 3 is reachable from a branch the contract
  is a **merge gate** signal; where it isn't, the contract names the shared environment it waits on.
- A **nonce** ties the evidence to its run.

**The hard rule:** a node whose contract cannot be run as written does not pass pre-flight. "Prove it
later" is banned — it is a **stop**, sent back to reshape the node into something provable, or to a
**spike** when whether it can be observed at all is itself the unknown. A design that admits no proof
is a design no one can call done.

*Done when:* every node's contract is validated against the profile — tiers reachable, evidence form
matching its surface, nonce present — or the node is marked **stop** and returned to planning.

## Sign the pre-flight

Emit one table, one row per node:

| node | invariant verdict | acceptance criteria | edges | proof contract |
|------|-------------------|---------------------|-------|----------------|
| … | satisfies / at-risk / re-plan | all design-checkable? | confirmed (+ hidden found) | the runnable contract, or **stop** |

Any node with a **re-plan** verdict or a **stop** proof contract is not dispatchable. It goes back to
planning before Wave 1 begins — `/dag:plan` routes it to a grill, a spike, or a re-chart. Pre-flight is
signed only when every remaining node is **satisfies**-or-resolved-**at-risk**, fully design-checkable,
edge-audited, and carries a proof contract. Only a signed pre-flight clears the DAG for dispatch.

**Record the signature on the chart.** Post the signed table as a comment on the `dag:map` issue and add
the `dag:preflighted` label to it. That label *is* the signature — it lives on GitHub, so `/dag:plan`
reads it from any context window and hands the DAG to `/dag:execute`. Sending any node back to planning
later removes the label until pre-flight is re-signed.
