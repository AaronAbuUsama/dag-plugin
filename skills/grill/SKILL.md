---
name: grill
description: Internal planning move reached through dag:plan — sharpen a plan through a batched, code-grounded interview. Do not invoke directly outside the planning router.
---

# Grill — sharpen the plan until it is buildable

Sharpen a plan or design until it is ready to build. Interview the user relentlessly — but batched and
grounded, never one abstract question at a time.

Terms in **bold** (**design tree**, **frontier**, **round**, **rubric-grill**, **readiness**) are defined
in [`../../GLOSSARY.md`](../../GLOSSARY.md); use them exactly, do not redefine them.
Before a fact, answer or artifact can settle a branch, apply
[`../../EVIDENCE-AUTHORITY.md`](../../EVIDENCE-AUTHORITY.md).

## The loop

Map the plan as a **design tree**. Then repeat until the **frontier** is empty:

1. **Compute the frontier.** List every decision whose prerequisites are already settled by `active`
   admitted premises — the questions answerable *now* without guessing at answers you haven't heard. A
   decision that depends on another still-open or contested premise belongs to a *later* **round**, not
   this one.
   *Done when:* you have that list and can name what each item is blocked on (nothing) or blocks.
2. **Resolve every fact yourself** — the rule is in the output style; here it means resolving the current
   repo authority pointer and exact HEAD before history, then assigning one research teammate through the
   current host's agent-team path (see `/dag:research`) per frontier item for anything findable in the
   code or environment: call sites, current behaviour, what a type already guarantees. A teammate report
   is a candidate premise until the planning lead re-checks and admits it.
   *Done when:* no frontier item is waiting on a fact you could have looked up, and every fact used in the
   round has an active premise record at an exact current ref.
3. **Put the whole frontier to the user as one round.** Number the questions. Each one is a
   **rubric-grill** (below) — no exceptions. Then stop and wait for answers.
   *Done when:* every frontier question is presented grounded and you have handed the round over.
4. **Fold the answers back in.** Admit each answer as a `user-intent` premise with an exact answer ref,
   then attach `Derived from: P-...` to the decisions it settles. That pushes the frontier outward and
   unblocks what depended on it. A correction to an earlier answer triggers the descendant invalidation
   receipt before recomputing. Update the **design tree**, recompute, and run the next round. If two or more
   of the round's answers point at the same underlying gap, say so — see **looking for the nest** in the
   glossary; a plan built around three symptoms of one root cause designs the root cause in.
   *Done when:* the answers are recorded, the next frontier is computed, and any shared root across the
   round's answers is named rather than left for the user to spot.

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
| **scope edge** | what is deliberately *not* in this expedition |

Pick the axes that fit the expedition — those six are the usual set, not a fixed one. The discipline is
naming them *before* you close, so an empty axis has to be defended rather than overlooked.

When every axis is either settled by active premises or explicitly out of scope, the frontier is genuinely
empty. State the shared understanding, its premise IDs and each node's **readiness**, then stop. Do not
start building until the user confirms.

## Budget the round

The grounding is non-negotiable, which makes length the thing that has to give. A round that arrives as a
wall of text does not get read closely, and a decision made from skimming is the failure this skill
exists to prevent.

**Six questions is a round.** More than that, split it: ask the ones whose answers unblock the most, and
say plainly that a second round follows. Within a question, the artifact and the options table are what
earn their space — cut the prose around them, not them.

## The rubric-grill — the load-bearing move

**A question the user cannot judge from what is on screen is a failed question.** “Real” also means
authoritative for the claim: current repo source at exact HEAD, or visibly labelled historical material
used only to explain history. The six ordered parts — the problem as real code, what it touches, the
options as code or diffs, a stated rubric, a
recommendation, then the ask through the current host's question surface — are the **decision block** in
[`../../RESPONSE-RULES.md`](../../RESPONSE-RULES.md), and they are in this plugin's output style so they
hold every turn. Read the file before a round; it is not restated here, because two copies drift and the
inline one always wins.

What grilling adds on top:

- **Every question in the round is a full decision block.** No exceptions, no "this one's simple". A round
  of four questions is four grounded blocks under four headings, not one essay.
- **The artifact comes first inside each question** — no preamble, no summary of what you found. The fence
  is the first thing under the heading.

## Tone

Relentless, not deferential. Chase the decision the plan is quietly leaning on but never states. Surface
the assumption the user hasn't noticed they made. A round that returns "looks fine" on every question
grilled nothing — find the fork that actually bites.
