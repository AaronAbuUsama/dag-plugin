# Changelog

## 0.8.0

**A house style for the stopping message.** Every skill ends a turn by talking to a human, and nothing
said what that message should look like — so each turn invented a layout, and long roll-ups collapsed into
a wall of paragraphs and bullets with no hard breaks. Reported as genuinely hard to read.

[`STOPPING-MESSAGE.md`](STOPPING-MESSAGE.md) defines it as **composable slots, not a template**: a
HEADLINE that gives the shape of the news before any detail, a FLIGHT DECK for scannable state, an
EVIDENCE TABLE, a DECISION BLOCK, and a closing what-you-do. Pick the slots the message needs and skip the
rest — a three-line update stays three lines, because imposing ceremony on a short turn is a failure of the
style rather than compliance with it. Hard `---` separators between slots whenever there is more than one.

- **The evidence table is a component, not a format** — droppable into a finding, a roll-up or a grill
  alike. Its `Verified` column is the point: what *you* checked never blurs with what an agent reported,
  because an agent's report is a claim about the code rather than a reading of it. Unverified rows are
  labelled, not dropped.
- **The decision protocol stops being a second, parallel rule.** The problem in code · what it touches ·
  options as code or diffs · a stated rubric · a recommendation · then the question — that is now the
  DECISION BLOCK slot of this one style, binding on `AskUserQuestion` prompts, grills, and any options put
  in front of a human. `grill`'s rubric-grill defers to it explicitly rather than restating it.
- **All eleven skills point at it**, beside the glossary link they already carried.

---

**Looking for the nest is a reflex, not a rollout ritual.** Nest thinking was stranded in the execution
half: `diagnose` is the whole skill and `execute` uses it operationally, while `plan` had one mention
inside an ASCII diagram and **eight skills had none at all** — chart, grill, grill-deep, preflight,
prototype, research, setup, prove. So the planning half had no instruction to look for a shared root.

What that cost, in a real session: a research node investigating why a health endpoint reported a dead
connection as "online" surfaced three findings — a phase field that tracks startup rather than
connectivity, a live status signal whose listener is torn down the instant auth settles and whose getter is
never read, and a coalescer parked on an unbounded queue that outlives the transport. Those are one class:
*live truth exists at the transport boundary and is discarded at the seam, so downstream invents its own
state and never reconciles it.* They were reported as three separate items, and **the user had to ask** "are
these symptoms of a deeper issue?" before they were collapsed. That prompt should never have been necessary.

- **The reflex is defined once**, in the glossary as **looking for the nest**: the moment two or more
  findings could plausibly share a root, say so unprompted — name the class in one sentence, state
  confidence with verified instances separated from suspected ones, and flag whether it warrants diagnosing
  rather than patching each symptom.
- **The judgement stays where it already lives.** The entry points at `/dag:diagnose` for whether the
  cluster is real, what the verdict is, and what a consolidating fix must cover. The glossary carries the
  trigger; the skill carries the machinery, and nothing is duplicated.
- **The trigger goes where findings are produced** — `research` (more than one finding), `prove` (more than
  one failing tier), `preflight` (the same invariant or coupling across nodes), `grill` (a round's answers
  pointing at one gap), and `chart` (several nodes waiting on what is really one decision — which should be
  one de-fog node blocking three, not three de-fog nodes).


## 0.7.0

**Every turn ends with a position.** The suite said how to choose a move and how to run one, and nothing
about how to *end a turn* — each step had a `Done when:` for the work and there was no contract for the
closing message. So handoff quality was left to judgement, and judgement drifts exactly when a session
goes sideways, which is when the user most needs to know where they stand.

Both doors now close every turn with the same fixed block — where we are · what's saved and where · what
happens next · what you do — and the last line almost always reads "nothing, or run the same command
again", stated outright, because a user who hasn't read the docs has no way to know that re-running
resumes the work. That is the single fact the whole design rests on.

- **`/dag:plan`** re-anchors after off-piste work: a turn that went sideways into a bug fix or a tangent
  still ends with the block, saying where that left the plan. It also asks-and-carries-on rather than
  parking — where the next move needs a decision and the move is cheap and reversible, it asks and keeps
  going in the same turn, because stopping for permission on a reversible write turns one command into a
  homework list.
- **`/dag:execute`** states position in nodes rather than prose, and lists durable work (closed issues,
  merged commits, committed receipts) separately from in-flight work (open PRs, live worktrees) — a
  resumed session inherits the first cleanly and the second not at all.
- **A rung-3 stop no longer reads like an ending.** The block still closes the turn, carrying the named
  nest, whether fixing it unblocks the rest of the graph, and the fact that `dag:preflighted` has been
  removed so the DAG is back in planning. A stop that reads as a failure report leaves the user holding a
  diagnosis with nothing to do about it.
- **Neither door hands over a planning command.** "Run `/dag:preflight`" in a closing message is the exact
  thing the doors exist to prevent; `/dag:execute` and `/dag:plan` name only each other.

## 0.6.0

**What the first charted epic taught it.** Four gaps found by using the suite on real work, all
structural rather than one-off.

- **An empty frontier is now a claim that gets checked.** `grill` said "when the frontier is empty,
  stop" and offered no test for what a complete frontier covers — so a grilling closes on whichever axis
  the griller finds most natural and feels finished. Twice in one run the frontier was declared empty and
  reopened with real questions. It now walks named axes before closing — surface, data and state,
  integration, operations, failure, scope edge — and an axis with nothing on it must be defended as out
  of scope rather than overlooked.
- **The map has to stay fresh, and now says so.** The template was write-once: no DAG diagram in it, and
  nothing anywhere saying to keep it current as nodes close. A stale map is worse than no map because
  people trust it. The map body now carries a standing freshness instruction and a mermaid DAG, with the
  two clauses that make it bind — regenerate *in the same turn as finishing the work*, and *recompute the
  frontier from the tracker, never from the file*. Closed nodes grey out rather than vanishing, because
  the shape of what has been walked is the point.
- **Rounds are budgeted.** The grounding is non-negotiable, so length is what has to give; six questions
  is a round, and past that it splits. A wall of text gets skimmed, and a decision made from skimming is
  the failure the rubric-grill exists to prevent.
- **`chart` no longer spawns agents unprompted.** Its last step told the run to fire a subagent per
  research node, which collides with any repo or session rule against spawning agents unasked — and a
  chart with eight research nodes is eight agents. It now announces what it is about to dispatch, and
  where a standing rule forbids it, that rule wins: the nodes are named as ready-to-fire and the user
  triggers them. `chart` also hands back to `/dag:plan` rather than naming `/dag:preflight`, which was
  the last place a skill routed past the door.

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
