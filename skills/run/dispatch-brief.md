# The dispatch brief

The self-contained packet handed to the one agent that runs one **node**. Self-contained means the
agent can carry the node to a merge-ready PR without coming back to ask — every fact it needs is in the
brief or reachable from a pointer inside it. Terms are defined in [`../../GLOSSARY.md`](../../GLOSSARY.md).

Compose one per node from the node's spec and its **proof ledger** row. Include every field:

- **Scope — the vertical slice.** The narrow-but-complete path this node cuts (schema→logic→tests),
  and its boundary: what is in, and what belongs to a sibling node so the agent doesn't reach into it.
- **Acceptance criteria.** The node's written criteria, verbatim from its spec — the bar its own work
  and the merge gate both judge against.
- **Proof contract.** From the ledger, verbatim: the node's **surface**, its **tiers**, the **evidence
  form** each tier takes, and the **nonce**. This was fixed when the node was created and **is not the
  agent's to choose, lower, or reinterpret** — the agent builds so it is satisfiable (leaving the states
  observable and the records readable), and the orchestrator captures it after merge via `/dag:prove`.
  An agent that finds the contract unsatisfiable says so and stops; it never substitutes a bar it can
  clear.
- **Invariants touched.** The architecture invariants this node's design must hold, named at pre-flight.
- **Ground already laid.** The merged nodes this one builds on and the exact contract/shape/name it
  consumes from each (the hidden-edge couplings pre-flight surfaced) — so it targets what exists, not a
  guess.
- **Fix-completeness rule.** Stated to the agent for its own work: before any change is "done",
  enumerate every branch and caller the change's reasoning touches, and cover each.
- **Review handoff.** The agent opens one PR and requests the independent review; the review **verdict
  posts to the PR** as a comment, so the artifact records its own review.

## The shape constraint (state it in every brief)

One agent = one node = one worktree = one PR. The agent works in its own worktree and never touches the
live box — deploy and live proof are the orchestrator's, gathered after merge.

*Self-contained test:* read the brief cold as if you were the agent. If any acceptance criterion, edge
dependency, or proof requirement forces a round-trip to the orchestrator to understand, the brief isn't
done — fold the missing fact in.
