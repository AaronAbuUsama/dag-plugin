---
name: chart
description: Turn a grilled or specced plan into a chart — a DAG of GitHub issues, buildable vertical-slice nodes joined by native blocking edges, each node's readiness classified and de-risked before it reaches the frontier.
disable-model-invocation: true
---

# Chart — plan into a walkable DAG

Take a plan that is already grilled or specced and lay it down as a **chart**: a **map** parent issue on
GitHub indexing child **node** issues, joined by the tracker's **native blocking** so the **frontier**
renders visually. The suite then walks it from `/dag:preflight` onward. Terms are defined once in
[`../../GLOSSARY.md`](../../GLOSSARY.md); this skill uses them without redefining.

The plan arrives from `/dag:grill`, `/dag:grill-deep`, or a spec/PRD the user points at. GitHub is the
tracker (issues + sub-issues + native blocking); run `/dag:setup` if it hasn't been configured.

**Default posture: decompose, don't rediscover.** The grilling already burned off the fog — your job is to
decompose a known plan into buildable nodes and wire their edges, not to rediscover the route. Chart what
you can specify now. Only when the effort is genuinely huge *and* still foggy — you can't yet slice whole
regions into nodes — escalate to full fog-of-war (see [Escalation](#escalation-full-fog-of-war)); it is
an option, not the path.

## Refer by name

Every map and node is an issue with a **title**. In everything the human reads — narration, the map's
index — name it by that title, never a bare `#42`. A wall of numbers is illegible; the id rides inside
the name's link, never stands in for it.

## The chart's shape

- **Map** — one issue labelled `dag:map`, the canonical artifact. An **index**, not a store: it lists
  each node once and links to it; detail lives in the node, never restated on the map.
- **Node** — a child issue of the map: one tracer-bullet vertical slice (see below), its body carrying
  what-to-build, acceptance criteria, and its blocking edges. One node = one **teammate** = one PR.
- **Edge** — the tracker's native blocking relationship, not prose. A node is on the **frontier** when
  every node blocking it is closed.

The map body and node body templates, and the create-then-wire GitHub mechanics, live in
[`node-template.md`](node-template.md) — read it before step 4.

## Nodes are tracer bullets

<vertical-slice-rules>

- Each node cuts a narrow but COMPLETE path through every layer (schema → logic → UI → tests) — vertical,
  never a horizontal slice of one layer.
- A completed node is demoable or verifiable on its own.
- Each node is sized to fit one fresh context window.
- Prefactoring ("make the change easy, then make the easy change") is its own node, first.

</vertical-slice-rules>

**Wide refactors are the exception.** A mechanical change whose **blast radius** fans across the codebase
— rename a shared symbol, retype a column — can't land green as one vertical slice. Sequence it
**expand → migrate-in-batches → contract**: expand adds the new form beside the old (nothing breaks);
each migrate batch (per package/dir) is its own node blocked by expand, CI green throughout because the
old form survives; contract deletes the old form, blocked by every batch. If batches can't stay green
alone, share an integration branch that all block a final integrate-and-verify node — green promised only
there.

## Readiness routes each node

Classify every node's **readiness** while charting, then wire its de-fog move as a blocking node so the
unknown is settled *before* the build reaches the frontier:

- **clear** — spec it and build. No de-fog node; it sits on the frontier or blocked only by build edges.
- **needs-grilling** — a decision is still open. Add a grilling node (`/dag:grill`) that blocks the build
  node.
- **needs-research** — a fact must be found first. Add a research node (`/dag:research`) that blocks the
  build node; fire its subagent in step 5.
- **needs-prototype** — not knowable on paper. Emit a **spike**: a throwaway-prototype node
  (`/dag:prototype`) that blocks the build node until it resolves. This is how the not-knowable gets
  de-risked cheaply before the real build commits.

A de-fog node is a real child issue with its own blocking edge into the build node — so the frontier
never surfaces a build node whose premise is still unsettled.

**The `dag:needs-*` label goes on the de-fog node, not the build node.** The de-fog node is the one
sitting on the frontier with work to do; the build node is blocked and invisible to the router by
definition. A label on a blocked node is a label nothing ever reads. The label says what *kind* of
de-fogging this node is, so `/dag:plan` can route it without opening it.

## Process

### 1. Gather the plan

Work from the grilling/spec already in context. If the user passed a reference (spec path, issue URL),
fetch its full body and comments. Explore the codebase enough to name nodes in the project's glossary
vocabulary and spot prefactoring opportunities.

*Done when:* you can state the destination and every buildable region of the plan in one pass.

### 2. Draft the vertical-slice nodes

Decompose the plan into tracer-bullet nodes per the rules above, prefactoring first, wide refactors
sequenced as expand/contract. For each node name its build-order blocking edges — the nodes that must
merge before it can start.

*Done when:* every buildable slice of the plan is a named node with its build edges listed, and no node
is a horizontal single-layer slice.

### 3. Classify readiness and add de-fog nodes

Give every build node one readiness verdict. For each non-**clear** node, add its de-fog node
(grilling / research / spike) and record that it blocks the build node.

The verdict routes the work later, so it lands as a **label on the de-fog node** — `dag:needs-grilling`,
`dag:needs-research`, or `dag:needs-prototype`. A **clear** node has no de-fog node and no label at all.
Apply it when the de-fog issue is created (step 4). `/dag:plan` routes off these labels and reads nothing
else, and it only ever sees the frontier — so a label on the blocked build node is a label no router
will ever read.

*Done when:* every build node carries a readiness verdict in its body; every non-clear one has a de-fog
node blocking it; and every de-fog node carries the `dag:needs-*` label matching what it is for — no
build node left resting on an unsettled premise, and no label stranded on a blocked node.

### 3b. Write each node's proof contract

Proof is decided here, at issue-creation, **not** by whoever builds the node later. An implementing agent
that invents its own bar picks the bar it can clear — so the bar is written down before the code exists.

First settle the **proof profile** for this effort and put it on the map: which **tiers** genuinely exist
in this repo and the command or query that reaches each. Take it from the repo (its test command, how it
runs its code and how a run is watched, where durable records live, whether errors and events are
collected somewhere queryable) and confirm it with the user. Tiers this repo doesn't have are recorded as
absent — but "we don't deploy anywhere" is not one of them: if the repo can run its code, it has tier 3.

Then, per node: name its **surface** — that fixes the **evidence form** — and fill its proof table from
the profile, plus the **nonce** the run will carry. Every node has a surface and so has an evidence form:
a backend node proves itself with a durable delta and exact ids, a CLI node with its captured output, a
UI node with screenshots and a video.

**When a node's proof can't be defined, do not chart it as buildable.** That is a de-fog signal, exactly
like readiness — route it: a decision about *what would even count* as proof → **needs-grilling**; nobody
knows yet whether the thing can be observed at all → **needs-prototype**, and the spike's goal is to find
out. A node whose proof stays undefinable is reshaped until it is provable, or it doesn't get built.

Write the **run profile** onto the map too — concurrency, models, autonomy — and the **Skills** line:
what a teammate consults while building, and which review its PR gets. The suite delegates who does
the work and owns only what they are told, so a skill left unnamed here is a teammate guessing.
Defaults are fine; stating them is what keeps a fresh context window running the DAG the same way.

*Done when:* the map carries the proof profile and the run profile, every build node's issue body carries a proof table whose
tiers are drawn from that profile plus a nonce, and every node whose proof could not be defined has a
de-fog node blocking it instead of a proof table.

### 4. Create, then wire

Create the map, then every node as a child issue — **first pass creates, second pass wires the blocking
edges** (issues need ids before they can reference each other). Follow the mechanics in
[`node-template.md`](node-template.md).

*Done when:* the map indexes every node, and every build and de-fog edge exists as a native blocking
link — the frontier renders correctly in GitHub's UI.

### 5. Fire research and hand off

Spin up a `/dag:research` subagent for each research node so they resolve in parallel, each capturing
findings back on its issue. Then hand the chart to `/dag:preflight`.

*Done when:* every research node has a running subagent, and the chart is handed to `/dag:preflight`.

## Escalation: full fog-of-war

When the effort is genuinely huge and still foggy — whole regions you can't yet slice into nodes — don't
force premature nodes. Chart only what's specifiable now and write the rest into a **Not yet specified**
section on the map: the dim, un-ticketable view toward the destination. As upstream de-fog nodes resolve,
**graduate** each patch that has become specifiable into fresh nodes, clearing it from Not yet specified.
Reach for this only when the plan genuinely can't be fully sliced up front.
