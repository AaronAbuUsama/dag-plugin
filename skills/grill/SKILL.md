---
name: grill
description: Sharpen a plan or design through a batched, code-grounded interview — the flagship planning skill.
disable-model-invocation: true
---

# Grill — sharpen the plan until it is buildable

Sharpen a plan or design until it is ready to build. Interview the user relentlessly — but batched and
grounded, never one abstract question at a time.

Terms in **bold** (**design tree**, **frontier**, **round**, **rubric-grill**, **readiness**) are defined
in [`../../GLOSSARY.md`](../../GLOSSARY.md); use them exactly, do not redefine them.

## The loop

Map the plan as a **design tree**. Then repeat until the **frontier** is empty:

1. **Compute the frontier.** List every decision whose prerequisites are already settled — the questions
   answerable *now* without guessing at answers you haven't heard. A decision that depends on another
   still-open decision belongs to a *later* **round**, not this one.
   *Done when:* you have that list and can name what each item is blocked on (nothing) or blocks.
2. **Resolve every fact yourself.** For each frontier item, dispatch a subagent (see `/dag:research`) to
   look up anything findable in the code or environment — call sites, current behaviour, what a type
   already guarantees. Every question you put to the user is one only the user can answer.
   *Done when:* no frontier item is waiting on a fact you could have looked up.
3. **Put the whole frontier to the user as one round.** Number the questions. Each one is a
   **rubric-grill** (below) — no exceptions. Then stop and wait for answers.
   *Done when:* every frontier question is presented grounded and you have handed the round over.
4. **Fold the answers back in.** Each answer settles a decision, which pushes the frontier outward and
   unblocks what depended on it. Update the **design tree**, recompute, and run the next round.
   *Done when:* the answers are recorded and the next frontier is computed.

## An empty frontier is a claim, and it needs a check

"No questions left" usually means *no questions left on the axis you find most natural*. A technical
grilling closes on the technical spine having never asked what the user sees; a product grilling settles
five screens and no data model. Both feel complete from the inside, which is why the frontier needs a
test rather than a feeling.

Before declaring it empty, walk the axes and name what you settled on each. An axis with nothing on it is
either genuinely out of scope — say so — or an unasked round:

| Axis | The question it answers |
|---|---|
| **surface** | what does a user see and do — the actual screens, commands, or messages |
| **data & state** | what is stored, what is derived, what is the source of truth |
| **integration** | what it talks to, and what happens when that thing is down or wrong |
| **operations** | how it is deployed, configured, observed; who can see it |
| **failure** | what breaks, what the user sees when it does, what is recoverable |
| **scope edge** | what is deliberately *not* in this effort |

Pick the axes that fit the effort — those six are the usual set, not a fixed one. The discipline is
naming them *before* you close, so an empty axis has to be defended rather than overlooked.

When every axis is either settled or explicitly out of scope, the frontier is genuinely empty. State the
shared understanding and each node's **readiness**, then stop. Do not start building until the user
confirms.

## Budget the round

The grounding is non-negotiable, which makes length the thing that has to give. A round that arrives as a
wall of text does not get read closely, and a decision made from skimming is the failure this skill
exists to prevent.

**Six questions is a round.** More than that, split it: ask the ones whose answers unblock the most, and
say plainly that a second round follows. Within a question, the artifact and the options table are what
earn their space — cut the prose around them, not them.

## The rubric-grill — the load-bearing move

**A question the user cannot judge from what is on screen is a failed question.** Every decision goes to
them in the five parts below, in this order, with no exceptions and no preamble.

<rubric-grill-order>

**1 — The problem, as code or a diagram. First thing on screen.**

Open with the artifact, not with narration. No "I read the board", no "before the questions", no summary
of what you found — the first thing under the question's heading is a fenced block or a diagram:

````
```ts packages/installation/src/managed-config-store.ts:35-40
export const seedManagedConfig = async (db: Database, cfg: ManagedConfig) => { … }
```
````

Always tag the fence with its language so it renders highlighted, and always label it `file:line`. Reach
for a diagram instead when the shape is a flow, a state machine, or a dependency web — those land faster
drawn than quoted. Prose comes *after* the artifact, and only to say what the artifact means.

**2 — What it touches. Assume they have read none of it.**

The reader has not read the surrounding code, and will not go and read it. So zoom out and put the
context on screen: the callers, the dependents, the sibling that consumes the same shape, the blast
radius of changing it. Every file you reference gets a `file:line` and enough of a quote to judge from.
A reference to code you did not show is a reference they cannot use.

**3 — The rubric, stated as a rubric.**

Name the axes before you score anything, so the scoring can be argued with. Write them out — a list or a
table, but visible and separate from the prose:

| Axis | What it means here |
|---|---|
| floor-first | ships the real thing now, not a promise of it |
| reversibility | how cheaply this is undone if wrong |
| blast radius | how much has to change, and what breaks if it does |
| correctness / integrity | what invariant this protects or gives up |
| parallelizability | can this run beside other work, or does it serialise |
| fit | how well it sits with what is already there |

Pick the axes that fit *this* occasion — those six are the usual set, not a fixed one. A rubric buried
inside a sentence of prose is not a rubric.

**4 — The options, each as code or a diagram.**

Every candidate gets its own artifact: the real code, a diff sketch, or a diagram. Never a prose
description of an approach.

````
```diff packages/installation/src/configuration.ts
- export const readManagedConfig = async (path) => readPrivateJson(path, Schema);
+ export const readManagedConfig = async (db) => store.current();
```
````

Then score them against the rubric from part 3 — a table, one row per option, one column per axis, so the
comparison is read rather than reconstructed. Close with your recommendation and the one-line reason.

**5 — The ask, through `AskUserQuestion`.**

Put the question through the **`AskUserQuestion` tool**, one question per decision, the recommended
option first and marked `(Recommended)`. Never end a round with the ask buried in prose — a decision
typed into chat as a paragraph is a decision that has to be re-found.

The grounding from parts 1–4 goes in your message *before* the tool call; the tool carries only the
choice.

</rubric-grill-order>

## Make it readable, or it will not be read

The grounding only works if it can be taken in at a glance. This is part of the job, not polish:

- **Every code block tagged with its language**, so it syntax-highlights. An untagged fence is a wall of
  grey.
- **Tables for anything compared** — options against axes, before against after. Never a paragraph that
  makes the reader hold six values in their head.
- **Diagrams for shapes** — flows, state machines, dependency webs. Draw them.
- **One heading per decision**, so a round of four questions reads as four blocks and not one essay.
- **Bold the load-bearing clause** in a long paragraph, so the eye finds the thing that decides it.

The user reads the actual tradeoff off the page and rules on it; they never reconstruct it from a
summary. Removing that reconstruction is the entire reason this skill exists — every abstract question,
every untagged block, and every rubric hidden in prose smuggles it back in.

## Tone

Relentless, not deferential. Chase the decision the plan is quietly leaning on but never states. Surface
the assumption the user hasn't noticed they made. A round that returns "looks fine" on every question
grilled nothing — find the fork that actually bites.
