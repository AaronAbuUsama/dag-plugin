# Changelog

## 0.5.0

**First real run, and what it broke.** Three failures found by running the suite on an actual repo
rather than reading it.

- **The doors now open.** `/dag:plan` answered with "next move: `/dag:grill`" and stopped — a door that
  hands you another command to type is a signpost. It now *runs* the move in the same turn, reading the
  named skill's `SKILL.md` and following it. `/dag:setup` did the same thing and worse, routing two hops
  past the door to a planning step; it now hands back to `/dag:plan` and names nothing else. The only
  commands either door ever hands over are the other door and, if the repo isn't configured, `/dag:setup`.
- **One question, then work.** Where a move needs an input only the user can give — most often which
  effort a chart covers — it goes through `AskUserQuestion` and the move starts in the same turn. Not a
  command to type *and* a question to answer.
- **The rubric-grill is codified properly.** It was ordered but not enforced, so prose led and the
  grounding followed. Now: the artifact is the first thing on screen, fenced and language-tagged and
  labelled `file:line`, with no preamble; context assumes the reader has read none of the surrounding
  code; the rubric is stated as a visible table before anything is scored; every option carries its own
  code or diagram and the comparison is a table; and the ask goes through **`AskUserQuestion`** rather
  than trailing off into prose. A section on presentation makes syntax highlighting, tables and diagrams
  part of the job rather than polish — the grounding only works if it can be taken in at a glance.
- **The docs cover updating, not just installing.** Third-party marketplaces do not auto-update by
  default, so an install sat on whatever version it was added at with nothing saying so. Now documented:
  refresh the marketplace, move the install, restart — plus the trap that `claude plugin update` defaults
  to `--scope user` and reports a per-project install as not installed at all.

## 0.4.0

**The running model, and two doors.** Tier 3 stops meaning *deployed* and starts meaning *running and
observed* — which is what it was always trying to say.

- **Tier 3 is the exact committed head running, observed doing the real thing.** Where it runs is a
  repo detail the **proof profile** answers. A run nobody watched is not tier 3, wherever it happened;
  "we have no deploy target" no longer means "we have no tier 3". No runner, command, or host is named
  anywhere in the suite.
- **Proof runs at the merge gate** wherever the profile says tier 3 is reachable from a branch — it is
  the fourth gate signal, satisfied on the open PR, so *proof is never deferred* is now literally true
  and a node reaches done-clean before it lands. Where tier 3 needs the merged head, the profile says
  so and proof follows the merge as before.
- **The teammate gathers its own evidence; the orchestrator grades it.** "The live box is yours alone"
  was a shared-server assumption, not a rule. What was load-bearing in it survives: nobody grades their
  own homework.
- **The chain of evidence degrades honestly** — convergence where the repo has corroborating tiers, and
  otherwise the observation itself. A repo with only tiers 1 and 3 could previously never satisfy it.
- **`/dag:plan` and `/dag:execute` replace the former `map` and `run` doors.** One door could not open
  any of its rooms — every planning target was user-invoked, so the promised handoff could never fire.
  Two doors match the two phases, and the pre-flight signature is the line between them: `execute` refuses
  to start without it. The `dag:map` issue and label are unchanged.
- **The GitHub mechanics are real.** Every command for creating a blocking edge or a sub-issue was
  invented and would have failed on any repo. Replaced with the REST endpoints, tested live. `chart`
  now applies the `dag:needs-*` readiness labels it never applied, so the planning router can fire.
- **`scripts/check.sh` can fail.** Its orphan-term check set a flag inside a pipeline subshell and
  always exited 0; four other checks were narrower than they read. Every check is now
  fault-injection-proven, and one new check keeps foreign skills from shipping inside the plugin.

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
