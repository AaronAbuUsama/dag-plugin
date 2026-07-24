---
name: grill
description: Sharpen a plan or design through a batched, code-grounded interview — the flagship planning skill.
disable-model-invocation: true
---

Sharpen a plan or design until it is ready to build. Interview the user relentlessly — but batched and grounded, never one abstract question at a time.

Terms in **bold** (**design tree**, **frontier**, **round**, **rubric-grill**, **readiness**) are defined in [`../../GLOSSARY.md`](../../GLOSSARY.md); use them exactly, do not redefine them.

## The loop

Map the plan as a **design tree**. Then repeat until the **frontier** is empty:

1. **Compute the frontier.** List every decision whose prerequisites are already settled — the questions answerable *now* without guessing at answers you haven't heard. A decision that depends on another still-open decision belongs to a *later* **round**, not this one.
   *Done when:* you have that list and can name what each item is blocked on (nothing) or blocks.
2. **Resolve every fact yourself.** For each frontier item, dispatch a subagent (see `/dag:research`) to look up anything findable in the code or environment — call sites, current behaviour, what a type already guarantees. Every question you put to the user is one only the user can answer.
   *Done when:* no frontier item is waiting on a fact you could have looked up.
3. **Put the whole frontier to the user as one round.** Number the questions. Each one is a **rubric-grill** (below) — no exceptions. Then stop and wait for answers.
   *Done when:* every frontier question is presented grounded and you have handed the round over.
4. **Fold the answers back in.** Each answer settles a decision, which pushes the frontier outward and unblocks what depended on it. Update the **design tree**, recompute, and run the next round.
   *Done when:* the answers are recorded and the next frontier is computed.

When the frontier is empty, every branch has been visited and nothing is silently assumed. State the shared understanding and each node's **readiness**, then stop. Do not start building until the user confirms.

## The rubric-grill — the load-bearing move

**A question the user cannot judge from what is on screen is a failed question.** Before *any* decision goes to them, lay out the tradeoff in the concrete, in this order:

1. **The problem, in the concrete.** The actual code at issue — `file:line` plus the real snippet, not a paraphrase of it. Reach for a diagram instead only when the shape (a data flow, a state machine, a dependency web) lands faster that way.
2. **What it touches.** Zoom out one level: the surrounding code, its callers and dependents, and the blast radius of changing it. Show what the choice actually moves.
3. **The options, in the concrete.** Each candidate as real code or a diff sketch — or a diagram — never a prose description of an approach.
4. **Graded against a rubric that fits the occasion.** Score the options on the axes that matter here — floor-first (ships the real thing now, not a promise of it), reversibility, blast radius, correctness/integrity, parallelizability, fit with what's already there. Then give your recommendation and why.
5. **The ask.** Only now, having shown all of the above, pose the question — with your recommended answer.

The user reads the actual tradeoff off the page and rules on it; they never reconstruct it from a summary. Removing that reconstruction is the entire reason this skill exists — every abstract question you skip smuggles it back in.

## Tone

Relentless, not deferential. Chase the decision the plan is quietly leaning on but never states. Surface the assumption the user hasn't noticed they made. A round that returns "looks fine" on every question grilled nothing — find the fork that actually bites.
