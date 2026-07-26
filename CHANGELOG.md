# Changelog

## 0.11.0

**One workflow, two native harnesses.** The shared skill suite now ships both Claude Code and Codex
plugin manifests. The two public doors keep the same behavior: Claude Code invokes `/dag:plan` and
`/dag:execute`; Codex invokes `$dag:plan` and `$dag:execute`.

- **Execution has one runner per host.** Claude Code uses Agent Teams only; Codex uses native child
  agents only. There is no Claude subagent fallback and no user-owned Codex task used for a worker.
- **The main orchestrator owns the frontier.** It reads GitHub, creates worktrees, assigns one issue per
  teammate, grades proof and advances the wave. Workers never self-claim from a host task list or
  delegate further; GitHub remains the durable DAG.
- **Rung-3 still stops the graph.** New dispatch freezes immediately and in-flight work proceeds only
  when it is proven independent of the diagnosed nest.
- **Shared repo instructions have one source.** `AGENTS.md` is canonical. `CLAUDE.md` symlinks to it
  where possible, or imports it when Claude-specific instructions must remain.
- **Questions use the host surface.** Claude Code uses `AskUserQuestion`; Codex uses
  `request_user_input` when available and otherwise asks directly, with the same code-grounded rubric.
- **The docs site now deploys on every successful `main` docs build.** GitHub Pages is enabled at
  `https://aaronabuusama.github.io/dag-plugin/`.

## 0.10.0

Everything here comes from one 21-node field run that merged eight nodes with real evidence and then
halted deliberately. The proof discipline held under pressure — two teammates found their tier 2 command
red, reported it, and refused to substitute a bar they could clear. What failed was upstream of them.

**Pre-flight certified a proof contract by reading it, never by running it.** Two nodes were signed
`runnable` on a tier 2 command that had been failing on `main` for two days before the signature; three
more unbuilt nodes still carry it. The gate's rule was already correct — *a node whose contract cannot be
run as written does not pass* — and every check underneath it was a desk check. "Its tiers exist and each
names the command that reaches it" is satisfied by the command existing in the task runner. "The evidence
is reachable" is future-tense, about the node's own output. A rotted command passes all five bullets.

- **Pre-flight now baselines.** Before it judges a single node: collect every distinct tier command in the
  chart and **run each one on the base branch**. A red command is not a runnable tier — every node naming
  it is a stop, and repairing it becomes its own node. Cheap by construction; twenty nodes usually name
  three or four distinct commands.
- **A tier reached through a shared environment is baselined by date** — when was that path last exercised
  end to end? Never exercised is not a runnable tier either: the first node to depend on it is sequenced
  behind a spike, rather than three taking a first dependency on it simultaneously. In the field run,
  three tiers had never been exercised once and three merged nodes came to owe them at the same moment.
- **"Cannot be run as written" now means red at the baseline**, not incoherent on paper.
- **Chart records which of the profile's commands CI actually gates.** An ungated tier command is
  unverified by default and *will* rot between charting and signing — in that repo neither lint nor the
  evals were gated, and both had rotted.

**Unsigning was lossy, so the planning router would re-sign the chart it had just halted.** A rung-3 stop
removed `dag:preflighted` and did nothing else, which makes a chart a human stopped identical to a chart
nobody ever signed. Walked against the live halted chart: no open node carried a `dag:needs-*` label, the
map carried only `dag:map`, and the router's "chart complete, unsigned → pre-flight and sign it" row was
the only match. It would have re-signed the same unachievable tier with the same desk-check method.

- **The stop writes two marks instead of one removal** — `dag:halted` onto the map in the same edit that
  takes the signature off, and a de-fog node filed to block the node it stopped.
- **`plan` reads the map's halt before anything else**, and routes it above the de-fog rows: a halted
  chart's remaining questions are asked against a plan already shown wrong somewhere.
- **`execute` refuses to open a run on a halted map**, not merely an unsigned one.

**`/dag:replan` — a chart-level move, because the method failed rather than a node.** The suite had two
responses to a chart coming back: grill an open decision, or diagnose a cluster of code findings. Neither
fits a chart whose nodes are individually fine and whose *signing* was wrong. The failure sits upstream of
every node, so repairing the node that surfaced it repairs nothing — the same defect waits in every
sibling sharing the contract, to be discovered one build cycle at a time. `replan` classifies the halt
(a wrong node is still a de-fog node and goes back to the router), finds the class across every open node,
amends every contract carrying it *without lowering a bar*, files the repair as a real node with real
blocking edges, records the re-plan on the map, and re-enters pre-flight in full. It is read-and-followed
by `/dag:plan`, so the two-door promise is untouched — there is no third command.

**An at-risk verdict can no longer survive the signature.** Pre-flight already said to sign only when
every node is satisfies-or-resolved-at-risk, but the verdict lives in a column of a table in a comment and
nothing reads it back. The field chart was signed with two unresolved at-risk nodes, and that pre-flight
invented a `dag:at-risk` label — with a description found nowhere in this plugin — to persist a state the
suite gives no home to. The fix removes a state rather than adding one: an unresolved at-risk node *is* an
open decision, which `dag:needs-grilling` already names and the router already routes. Settle the choice
and the node is **satisfies**, or it gets a de-fog node blocking it and the chart is not complete. The
readiness label goes on that new issue, never on the build node — planning closes a readiness-labelled
issue when its move lands, and closing a build node loses the work unbuilt. No sixth readiness label, no
new routing row.

**Four seams, one line each, where each belongs.**

- **Split tier 3, in the dispatch brief.** Where a profile splits tier 3 — some nodes provable from a
  branch, others only on a shared environment taking merged commits — the brief states per node which half
  applies and who runs it, and names any environment the teammate must not touch. A brief that named the
  environment's skill and left the half to be inferred got an unmerged branch deployed to a live
  single-home box.
- **Time-bounded criteria, in `prove`.** Widening a timeout until it passes is weakening an assertion in
  the form that does not look like one, and two green runs only prove the machine was quiet twice. Drive a
  deterministic clock; the bound belongs in the code and in the PR body.
- **Proof currency, in `execute`'s merge gate.** There was no currency check at all, and the obvious one is
  wrong — a squash merge does not preserve ancestry, so `--is-ancestor` reports "not merged" for work that
  merged perfectly. Diff the paths the evidence covers instead. A re-proof is not merely fresher: it runs
  against fixes that create states the first run could not reach.
- **File-level contention, in pre-flight's edge audit.** Two independent nodes rewriting one package cost a
  rebase *and* a re-proof when the first merges. Named as a scheduling note, deliberately not an edge.

## 0.9.0

**The response rules are always on.** Everything about how this suite talks to a human lived somewhere that
only loads sometimes — and the audit found the same bug three times over.

`STOPPING-MESSAGE.md` was linked from all eleven skills in one informational clause, while both doors
carried a *complete inline template* of the shape under a heading reading "every time, no exceptions". The
inline copy was already in context, cost nothing and looked complete, so it won every time and the linked
file never got opened. It did not compete with the file, it **shadowed** it. And six more universal rules —
the decision protocol, resolve-every-fact-yourself, assume-they-have-read-no-code, language-tag every
fence, a-rubric-in-prose-is-not-a-rubric, budget the round — were filed inside `grill`, so they fired only
while grilling. A roll-up got none of them.

- **The plugin now ships an output style**, `output-styles/dag-house-style.md`, with
  `force-for-plugin: true` — it loads into the system prompt every turn the plugin is enabled, with no file
  to read and no skill to invoke. That is the only surface here that fires unconditionally; `hooks` and
  `outputStyles` were both declared in the manifest schema and neither was used.
- **It carries the reflexes, not the vocabulary.** Headline first, `---` between sections, tables over
  prose, evidence with its source visible and *your* verification never blurred with a report you received,
  short turns staying short — plus the decision block's six ordered parts. Roughly 70 lines, which is a
  permanent per-turn cost and the reason it is reflexes rather than the whole spec.
- **Both inline templates are gone.** Each door keeps only what is genuinely local, the reference is
  imperative rather than informational, and each `Done when:` requires having read the file that turn.
- **`STOPPING-MESSAGE.md` → `RESPONSE-RULES.md`.** It always covered the decision block, which fires
  mid-turn rather than at the end; the old name undersold it and probably helped it read as a niche
  reference.
- **Rules have one home each.** Where a skill still names a global rule it points at it and adds only its
  own mechanics — `grill` on how to resolve facts, `plan` on charting being the reversible write. Three
  genuine duplicates were found and cut, one of them introduced during this change.

**`prove` fires on what people ask, and the obligation no longer depends on it firing at all.** A live run
on 0.8.1 was asked "CI is red, fix it, update the PR". It diagnosed and fixed correctly, then reported the
proof **in chat** — no receipt, no PR comment, PR #385 with zero comments. `prove` was model-invocable and
in the registry. One Skill call, never made.

The cause is trigger shape, not the spine. `execute` has `/dag:prove` as a numbered step with a
`Done when: /dag:prove has returned a verdict` gate, the ledger derived from the tracker, and
close-on-proof leaving a merged-but-unproven node visibly open. All intact. But `prove` was the only skill
in the suite whose description named **world-states** — "a merged node owes its proof", "a PR asserts
behaviour it does not show" — rather than anything a person says. `research` and `prototype` are dispatched
by `plan` and `chart`; `diagnose` by `execute` at rung 2. `prove` had that too, at `execute` step 5 — but
only inside a door. "Fix CI and update the PR" pattern-matched to debugging, so no lookup happened, and off-piste
turns are most turns during a long rollout.

- **The obligation moved to the always-on style**, where no dispatch is needed: evidence goes where a
  reviewer will see it, never chat alone, on any turn whether or not a workflow skill is running. That
  addresses the actual harm rather than the missed dispatch.
- **`prove`'s description triggers on request phrases** — opening or updating a PR, asked to fix something
  and report back, about to say a change works — keeping the world-state clauses after them.
- **`prove` gained a reduced path** for a PR with no chart behind it, since the new description invites it
  there: name the claim, pick the evidence form, capture, post. No inventing a DAG to justify a contract.

Enforcement stays deferred, now with a better candidate than the one this changelog first named. A `Stop`
hook must either grep for claim-language or call GitHub every turn end; a **`PostToolUse` hook on
`gh pr create`** would catch the same thing deterministically, because the world-state is *created* by an
observable action rather than polled for. Held until the two cheap fixes above are measured — the hook's
cost is certain and its necessity is not.

## 0.8.1

**Finishing 0.8.0's own criterion.** That release said the nest trigger goes where findings are produced,
then missed three skills that produce them. A patch rather than a minor: no new behaviour, just the stated
scope actually covered.

- **`prototype`** had zero references across all three of its files, while `SKILL.md` step 6 instructs the
  run to capture the spike's verdict as a comment on the node issue — a finding by 0.8.0's own definition.
  It was also the skill that found the *second* confirmed instance of the very nest 0.8.0 uses as its
  worked example, so the release fixed the skill that found instance one and missed the one that found
  instance two.
- **`grill-deep`** had zero while `grill` had the trigger, which is backwards: the variant that writes
  **ADRs** is where mistaking a symptom for a root cause becomes durable, because the next reader trusts
  what is written down.
- **`plan`** had no real trigger — its two apparent hits were the ASCII tour diagram and the word
  *commonest*. It is the router: the one surface that reads every node's state at once and closes de-fog
  nodes as their answers land, which puts it in the best position to notice that two de-fog nodes settled
  the same underlying question.

**The entry condition was also too narrow to admit a spike.** It fired on "two or more findings", and a
spike returns one verdict — so a literal reading excluded `prototype` even after adding a trigger. The
glossary entry now says recognition counts as well as arithmetic: one instance examined closely enough that
you recognise its shape elsewhere is a cluster of two. `prototype`'s trigger is phrased around that
recognition rather than a count, since examining one mechanism in detail is exactly what makes a spike good
at spotting the same shape somewhere else.

`setup` still has no trigger, correctly — it configures the tracker and produces no findings.

## 0.8.0

**A house style for the stopping message.** Every skill ends a turn by talking to a human, and nothing
said what that message should look like — so each turn invented a layout, and long roll-ups collapsed into
a wall of paragraphs and bullets with no hard breaks. Reported as genuinely hard to read.

`STOPPING-MESSAGE.md` (since renamed to [`RESPONSE-RULES.md`](RESPONSE-RULES.md)) defines it as **composable slots, not a template**: a
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
