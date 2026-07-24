---
name: preflight
description: Pre-flight gate for a DAG of work — validates every node against its invariants, acceptance criteria, edges, and proof contract before any dispatch.
disable-model-invocation: true
---

# Pre-flight — validate the DAG

Run this **once**, after a **DAG** of **nodes** and **edges** exists (from your ticketing flow) and
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
merely its merge. The motivating case: S1↔S2's `surfaceRepositories` coupling, where S2 relied on a
shape S1 chose internally and the original edges never recorded it. For every pair that shares a
contract, a shape, or a name one side defines and the other consumes, add the missing edge now.

*Done when:* every declared edge is confirmed-or-removed, and every node has been checked for hidden
edges against the nodes it shares a contract with — new edges added where found.

## 4. Proof contract, per node

For each node, define its concrete, runnable **proof contract**: which proof layers, what nonce, what
receipt establishes this node is **done-clean**. The proof contract is a pre-flight deliverable.

**The hard rule:** a node whose proof contract you cannot even *define* here does not pass pre-flight.
"Prove it after deploy" is banned — an undefined proof is a **stop** signal before work starts, sent
back to CREATE to reshape the node into something provable. A design that admits no proof is a design
no one can call done.

*Done when:* every node carries a written, runnable proof contract — or is marked **stop** and returned
to CREATE.

## Sign the pre-flight

Emit one table, one row per node:

| node | invariant verdict | acceptance criteria | edges | proof contract |
|------|-------------------|---------------------|-------|----------------|
| … | satisfies / at-risk / re-plan | all design-checkable? | confirmed (+ hidden found) | the runnable contract, or **stop** |

Any node with a **re-plan** verdict or a **stop** proof contract goes back to the CREATE stage before
Wave 1 begins — it is not dispatchable. Pre-flight is signed only when every remaining node is
**satisfies**-or-resolved-**at-risk**, fully design-checkable, edge-audited, and carries a proof
contract. Only a signed pre-flight clears the DAG for dispatch.
