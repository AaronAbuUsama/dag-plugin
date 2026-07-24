# Changelog

## 0.3.0

**The proof layer.** Verification is the suite's first principle: a claim that cannot be verified is
not a result, and only reality verifies code against the world.

- **Proof tiers** — evidence ordered by closeness to reality (mechanical → integrated → live →
  readback → observed). A higher tier never substitutes for a lower one; which tiers exist is a
  property of the repo, declared once in the map's **proof profile**.
- **Proof is defined before the code.** Every node's proof contract — tiers, evidence form, nonce —
  is written into its issue when the node is created. A node whose proof cannot be defined routes to
  a grill or a spike rather than being charted as buildable.
- **`/dag:prove`** (new) — captures the evidence the node's surface calls for (screenshots and video
  for a UI, the durable delta for a backend, the transcript for a CLI), commits a receipt, and posts
  the tier table and evidence **into the pull request**.
- **Agent teams** are the one way a wave runs. One teammate = one node = one worktree = one PR.
- **Run profile** — concurrency, models, autonomy on the map, so a fresh window runs the DAG the same
  way the last one did.
- `scripts/check.sh` — mechanical consistency checks for the suite itself.

## 0.2.0

The full plan→build suite behind one stateful entry point (then named `map`, since split into `plan` and
`execute`): setup, grill, grill-deep, research, prototype, chart, preflight, run, diagnose.

## 0.1.0

Provable wave execution: preflight, run, diagnose, map.
