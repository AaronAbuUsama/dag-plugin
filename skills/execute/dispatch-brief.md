# The dispatch brief

The self-contained packet handed to the one **teammate** that runs one **node**. Self-contained means
the teammate can carry the node to a merge-ready PR without coming back to ask — every fact it needs is in the
brief or reachable from a pointer inside it. Terms are defined in [`../../GLOSSARY.md`](../../GLOSSARY.md).

Compose one per node from the node's spec and its **proof ledger** row. Include every field:

- **Scope — the vertical slice.** The narrow-but-complete path this node cuts (schema→logic→tests),
  and its boundary: what is in, and what belongs to a sibling node so the teammate doesn't reach into it.
- **Assignment.** The node issue number, runtime runner (Claude Code Agent Teams or Codex task),
  exact branch name, and assigned worktree (absolute path for Agent Teams; the task-owned cwd for
  Codex). The teammate works only
  there, owns only this node, never self-claims another task, and never spawns another agent.
- **Acceptance criteria.** The node's written criteria, verbatim from its spec — the bar its own work
  and the merge gate both judge against.
- **Proof contract.** From the ledger, verbatim: the node's **surface**, its **tiers**, the **evidence
  form** each tier takes, and the **nonce**. This was fixed when the node was created and **is not the
  teammate's to choose, lower, or reinterpret**. Where the profile says tier 3 is reachable from a
  branch, the teammate runs its node and captures the evidence onto its own PR via `/dag:prove`, before
  the gate; where it isn't, it builds so the contract stays satisfiable — states observable, records
  readable — and the orchestrator captures it after merge. A teammate that finds the contract
  unsatisfiable says so and stops; it never substitutes a bar it can clear.
- **Which half of a split tier 3 this node uses, and who runs it.** A profile that splits tier 3 — some
  nodes provable from a branch, others only on a shared environment that takes merged commits — has to say
  per node which half applies, in words, not by naming the skill and leaving the teammate to infer it. And
  **name any shared environment this teammate must not touch.** The motivating case: a brief named the
  environment's skill without saying which half, so the teammate deployed an unmerged branch to a live
  single-home box, proved there, and rolled back. The evidence was stronger than required and the rollback
  verified — and it still broke the chart's own rule on the one box that could not afford it.
- **Invariants touched.** The architecture invariants this node's design must hold, named at pre-flight.
- **Ground already laid.** The merged nodes this one builds on and the exact contract/shape/name it
  consumes from each (the hidden-edge couplings pre-flight surfaced) — so it targets what exists, not a
  guess.
- **Skills for this expedition.** The map's **Skills** line, verbatim — what this teammate consults while
  building, and which review its PR gets. The suite does not supply an implementation method of its
  own; it names the ones this expedition has chosen, and the brief is the only place the teammate can learn
  them.
- **Fix-completeness rule.** Stated to the teammate for its own work: before any change is "done",
  enumerate every branch and caller the change's reasoning touches, and cover each.
- **Review handoff.** The teammate opens one PR and requests the review the map named, handing it the
  packet in [`review-brief.md`](review-brief.md); the review **verdict posts to the PR** as a comment,
  so the artifact records its own review.

## The shape constraint (state it in every brief)

One **teammate** = one node = one worktree = one PR. The orchestrator assigns the node and its worktree;
the teammate runs only that node there and captures the evidence its contract names. It
never self-claims more work, delegates, or grades that evidence — the **verdict** is the orchestrator's.
Any tier the profile puts behind a shared environment is the orchestrator's to reach.

*Self-contained test:* read the brief cold as if you were the teammate. If any acceptance criterion, edge
dependency, or proof requirement forces a round-trip to the orchestrator to understand, the brief isn't
done — fold the missing fact in.
