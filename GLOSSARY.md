# Glossary — the shared vocabulary of the `dag` suite

The suite's skills lean on these **leading words**. Each is a compact concept the model already holds;
repeated across the skills, they anchor the same behaviour every run. Define a term once here; the
skills use it without re-defining.

---

**DAG** — the plan as a graph of **nodes** (work slices) joined by **edges** (a node blocks another
until it closes — and under close-on-proof it closes when its proof lands, not when it merges). Laid down by `/dag:chart` from a grilled plan; the suite then validates it, walks it,
and closes it.

**node** — one work slice: a narrow-but-complete vertical path (schema→logic→tests) sized for a single
fresh context, demoable on its own. One node = one **teammate** = one worktree = one PR.

**pre-flight** — the checklist you run *before the wheels leave the ground*. A whole-DAG gate, run once
before any dispatch: every node checked against the architecture invariants, its own acceptance
criteria, its edges, and its **proof contract**. You do not dispatch until pre-flight is signed. Skipping
it is why architecture violations get caught late, in review, at their most expensive.

**invariant** — a rule no node may violate, stated in the project's architecture doc. Conformance is
checked at pre-flight against the *design*, not discovered in review against the *code*.

**verification** — the suite's first principle: *a claim that cannot be verified is not a result.* Tests
verify the code against itself; only reality verifies the code against the world. Everything below
exists to keep those two from being confused.

**proof tier** — proof ordered by how close it gets to reality. A higher tier never substitutes for a
lower one, and a lower one never *promotes* into a higher one:

1. **mechanical** — types, lint, build, unit tests. The code agrees with itself.
2. **integrated** — the real components wired together, still hermetic. No mocks at the seam under test.
3. **live** — the exact committed head **running**, observed doing the real thing. Where and how it runs
   is a repo detail the **proof profile** answers; what makes it tier 3 is that the head is running and
   someone is watching it. A run nobody observed is not tier 3, wherever it happened.
4. **readback** — the system's own durable record of *that same event*, read back independently.
5. **observed** — what the run emitted: events, and especially **errors**, queried from wherever this
   repo collects them.

Which tiers exist is a property of the repo, not of the suite — declared once on the **map** (see
**proof profile**). Tier 3 is absent only when the code genuinely cannot be run and watched at all,
which is rare — "no deploy target" is not that: if you can run it, you can prove it. A repo with no
error/event collector has no tier 5. Absent tiers are stated as absent, never faked and never quietly
skipped.

**verdict** — a judgement returned in one word from a fixed vocabulary, so it cannot be hedged. Each
judging step has its own, and every one of them is issued by the grader, never by the party being
graded:

- a **proof tier** — **PROVEN** / **NOT PROVEN** / **BLOCKED**
- pre-flight, on a node's invariants — satisfies / at-risk / re-plan
- diagnosis, on a cluster — code-wrong / node-wrong / independent

`BLOCKED` is reserved for a genuine external or authorization gate; anything we could fix ourselves is
`NOT PROVEN` plus work. Never say green, ready, proven, works, or live without naming which verdict, of
what, in the same sentence. Understating is recoverable; overstating is how a rollout ships nothing.

**evidence form** — *what the proof looks like*, which follows the **surface** the node touches. The
discipline is identical; only the artifact changes:

- **UI / browser** — a full-frame screenshot of each state, plus a video of the journey.
- **backend / data** — the durable delta: the record before, the record after, with exact ids.
- **API / SDK** — the real request and response, with exact ids.
- **CLI / tooling** — the invocation and its output, captured verbatim (a screenshot is fine).
- **messaging / external surface** — the message as the real recipient saw it, plus its provider id.

Every node has a surface, so **every node has an evidence form** — "backend, so nothing to show" is not
a thing.

**proof contract** — the concrete, runnable evidence that one node is done: which **tiers** it must
reach, the **evidence form** for each, and the **nonce** that ties the evidence to this run. Written
into the node's issue **when the node is created** — before any code — and validated at pre-flight.
**A node whose proof contract cannot be defined does not get built**: that is a **stop**, routed back to
a grill (a decision is open) or a **spike** (nobody knows yet whether it can be proven).

**baseline** — running a **proof contract**'s tier command *before* the contract is signed, to establish
that the bar can be cleared today. A command can be perfectly coherent, correctly named, and have been
failing for days; every desk check passes it. A tier reached through a shared environment instead of a
command is baselined by naming **when that path was last exercised end to end** — never exercised is not
a runnable tier. Distinct from the **nonce**'s absence check, which baselines the *token*, not the bar.

**nonce** — a unique token minted **per proof run** and carried through the evidence, so a receipt can
only belong to *this* run. The **proof contract** fixes where it enters and which path it must travel;
the *value* is minted at run time, never written into the issue — a value recorded before the run is
already in the repo and can never be shown absent. And it must travel **through the behaviour the
acceptance criteria name**: a token the code emits alongside the feature proves the code ran, not that
the feature worked. Its absence is established first, at each tier the contract names.

**halt** — a signed DAG stopped mid-flight by a rung-3 escalation, recorded as `dag:halted` on the map in
the same edit that removes `dag:preflighted`. Unsigning alone is *lossy*: a chart a human stopped and a
chart nobody ever signed look identical, and the planning router sends both to be signed. The halt is
cleared only by a **re-plan** — find the class behind the stop, amend every contract carrying it, file the
repair node — after which pre-flight is re-run in full, not spot-checked over the amended nodes.

**primary source** — the thing that owns the fact, not a write-up of it: official docs, the source
code, a spec, a first-party API — or, for a **spike**, the spike's own code. Research follows every
claim back to one; a secondary account is where stale facts come from.

**database id** — GitHub's internal issue id, which every dependency and sub-issue endpoint takes, and
which is *not* the `#number` a human sees. Read it with `gh api repos/<owner>/<repo>/issues/<n> --jq
.id`. Passing the number where the id belongs is the single most common way a chart wires itself wrong.

**looking for the nest** — a reflex, not a phase. The moment **two or more findings could plausibly share
a root**, say so *unprompted* — during research, planning, grilling, review, or ad-hoc debugging, not only
during a rollout. **Recognition counts as well as arithmetic:** one instance examined closely enough that
you recognise its shape somewhere else is a cluster of two, even though you only set out to find one. Three symptoms reported as three items, when they are one class, is the failure: someone
then has to ask "are these related?", and that question should never need asking.

Saying so means three things, in one short block:

- **name the class in one sentence** — the shared shape, not the shared file
- **state confidence, and separate verified instances from suspected ones** — which you read, which you
  inferred
- **flag whether it warrants diagnosing rather than patching each symptom**

The judgement itself — is the cluster real, what is the verdict, what does a consolidating fix have to
cover — is [`/dag:diagnose`](skills/diagnose/SKILL.md)'s, and it is reached rather than re-derived. This
entry is the trigger; that skill is the machinery.

**receipt** — the durable, reviewer-openable record of a satisfied proof contract: the artifacts, the
exact identifiers, and the **chain of evidence**. Committed to the repo so it outlives the PR page.

**chain of evidence** — the short argument that the artifacts actually prove the claim. Where the repo
has corroborating tiers, that argument is **convergence**: the same **nonce** at independent tiers (live
*and* readback *and* observed), each a channel you didn't write. Where it has none, the argument rests
on the observation itself — which is exactly why that observation must be an artifact a reviewer can
open, never an assertion that it happened. Say which of the two this is: a chain claiming a convergence
it doesn't have is worse than one that states it has none.

**proof ledger** — the running record of each node's proof contract and whether it is satisfied. Makes
the difference between the two done-states impossible to blur:

- **triage-clean** — the reviews are clean. Necessary, not sufficient.
- **done-clean** — the proof contract is *satisfied*: the evidence exists, is in the PR, and is
  committed as a receipt. The only real "done".

Proof is never deferred, and it is never merely asserted — **show it, don't claim it**. Where the
**proof profile** says tier 3 is reachable from a branch, proof is gathered *before* the merge, as a
**merge gate** signal — so "never deferred" is literal, and a node reaches **done-clean** before it
lands. Where tier 3 needs the merged head, proof runs immediately after the merge and the issue closes
on it. If a node cannot be proven, that is a **stop** signal — before work starts if the contract can't
be defined, or at the gate if the evidence can't be gathered — never a shrug.

**proof profile** — what *this repo* can prove with, declared once in the map's Notes and read by every
proof step: which **tiers** exist here, the command or query that reaches each, and where receipts are
committed. For tier 3 that means **how this repo runs its code**, and how a run is driven and observed.
This is the whole of the suite's per-repo configuration — the skills stay generic, the repo supplies its
own reality.

**agent team** — how a wave is executed: you are the team lead, and each ready **node** goes to one
**teammate** — a separate session with its own context window that inherits the repo's context and its
brief, never the lead's conversation. Teammates share a task list that unblocks work as its blockers
complete, so the team mirrors the **frontier**. Sized from the frontier and held under the concurrency
cap. It is the suite's one runner; there is no second way to walk a DAG.

**run profile** — how an effort is run, declared on the **map** beside the **proof profile**: the
concurrency cap, the model per role, and the **autonomy level**. It lives on GitHub rather than in a
conversation, so every context window runs the DAG the same way.

**merge gate** — the signals that must all be clean before a node merges: CI, an independent review
(bot or subagent — whose verdict is *posted to the PR*, not left in a transcript), the orchestrator's
own cold read of the diff, and — wherever the **proof profile** says tier 3 is reachable from a
branch — the node's **proof contract** satisfied, with the evidence in the PR.

**triage vs diagnosis** — the two review modes.
- **triage** — what a point-reviewer does: surface one symptom at a time. Fast, shallow, never names
  the underlying cause. The default mode, correct for rounds 1–2.
- **diagnosis** — find the *disease* behind a cluster of symptoms. Slow, deep, names the root. You
  switch from triage to diagnosis when a trigger fires (see **the tell**, **class-recurrence**).

**the nest** — the single design gap that generates a **cluster** of findings. "Stop hitting moles,
find the nest." Diagnosis exists to find the nest and close it with one **consolidating fix**, instead
of patching each mole forever.

**cluster** — two or more distinct findings that are the same underlying issue recurring at a different
checkpoint or after a fix reshaped the code. A cluster is the signature of a nest.

**the tell** — the sharpest early signal that you are in whack-a-mole and must switch to diagnosis: a
finding whose *fix needs a new mechanism*, not a tightened check. When a fix adds machinery rather than
narrowing an existing guard, the design has a hole near it — stop and diagnose.

**class-recurrence** — the primary escalation trigger: the **same bug-class appears a second time**.
Do not wait for a round count; a class recurring means there is a nest.

**fix-induced** — a defect *introduced by an earlier fix* rather than present in the original code. The
direct cost of patching symptoms in a subsystem you have not diagnosed. High fix-induced rates are the
statistical fingerprint of missing diagnosis.

**fix-completeness** — before a fix is "done", enumerate *every branch and caller* the fix's reasoning
touches; the fix is not done until each is covered. The one-line discipline that kills the narrow-fix
regression class — including on a **consolidating fix**, which must cover every call site of the nest.

**the ladder** — the escalation path when review findings arrive:
1. **Patch** (triage) — fix the reported defect. Normal for rounds 1–2.
2. **Diagnose + fix** (the **inner loop**) — find the nest, apply the consolidating fix, continue.
   Autonomous by default; most escalations resolve and die here without a human.
3. **Stop** (the **outer loop**, rare) — surface to the human, *pre-validated*: the nest, a confidence
   level, and whether the fix unblocks. Fires only when the node's spec/premise is wrong (not just its
   code), the proof can't be gathered, or the fix would cost more than it's worth.

**inner loop / outer loop** — the inner loop is autonomous diagnose-and-fix (rung 2); the outer loop is
the rare, pre-validated human escalation (rung 3). The **autonomy level** (from the **run profile**) decides
how freely the inner loop runs before the outer loop is allowed to fire — autonomous by default.

**code-wrong vs node-wrong** — diagnosis's verdict on a cluster. **code-wrong**: the implementation was
wrong → consolidate and continue (rung 2, autonomous). **node-wrong**: the node's spec or premise was
wrong → stop and re-plan (rung 3). A third outcome, **independent**: no nest, the findings are genuinely
unrelated → resume patching, with confidence.

---

## Planning — turning intent into the DAG

**design tree** — the plan seen as decisions, each branching into the decisions that hang off it.
Grilling walks it in **rounds**, not depth-first.

**frontier** — the set of decisions whose prerequisites are already settled: the questions you can ask
*now* without guessing at answers you haven't heard yet. (The same word names the executable edge of a
**chart**: the open, unblocked, unclaimed nodes.)

**round** — one batched pass over the whole **frontier**. Ask every frontier question at once — numbered,
each with a recommended answer — then recompute the frontier from the answers. The cure for
one-question-at-a-time slowness.

**rubric-grill** — how a question is put, so it is never asked in the abstract. Before any decision goes
to the human, show: (1) the **problem**, in code (`file:line` + real snippets) or a diagram — whichever
fits the occasion; (2) **what it touches** — surrounding code, callers, blast radius; (3) the **options**,
each as concrete code / a diff sketch or diagram; (4) graded against a **rubric that fits the occasion**
(floor-first, reversibility, blast radius, correctness, parallelizability, fit), with a recommendation.
*Only then* ask. Facts are the agent's job — dispatch a subagent for anything lookable-up, never ask the
human for it; the **decisions** are the human's.

**readiness** — how knowable a node is, decided while charting. **clear** (spec it and build) /
**needs-grilling** (a decision to settle first) / **needs-prototype** (not knowable on paper) /
**needs-research** (a fact to find first). Readiness routes a node to the right de-fogging move before it
is buildable.

**spike** — a throwaway **prototype** (code that answers a design question, then is discarded) raised as
its own node that **blocks** a `needs-prototype` build node until it resolves. De-risks the unknowable
cheaply, before the real build commits.

**chart** — the DAG embodied on the issue tracker: a `map` parent issue indexing child **node** issues
joined by the tracker's **native blocking** relationship, so the **frontier** renders visually in the
tracker's own UI. Charting is turning a grilled/prototyped plan into this graph; the suite then walks it.
