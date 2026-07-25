---
name: grill-deep
description: The heavy grill — runs the full batched, code-grounded interview and records the decisions it settles as durable ADRs and glossary entries. Reach for it when a design warrants written decisions, not just a sharpened plan.
disable-model-invocation: true
---

# Grill-deep — grill, and write the decisions down

Grill-deep is [`/dag:grill`](../grill/SKILL.md) plus a durable paper trail. Everything about the
interview — the **design tree**, the batched **rounds** over the **frontier**, the **rubric-grill** on
every question — is grill's, unchanged. Run that skill's loop exactly as written. This file adds one
thing on top: as each round *settles* a decision, capture it — a resolved term to the glossary, a hard
trade-off to an ADR — right then, while the reasoning is fresh.

Terms in **bold** (**design tree**, **frontier**, **round**, **rubric-grill**, **readiness**) are defined
in [`../../GLOSSARY.md`](../../GLOSSARY.md).

The shape of the message a turn ends with is in
[`../../STOPPING-MESSAGE.md`](../../STOPPING-MESSAGE.md).

## The delta: capture as you settle

Grill's loop folds each round's answers back into the design tree (its step 4). Grill-deep extends that
fold with a capture pass, run *before* you recompute the next frontier so nothing settled slips by
unrecorded:

1. **Glossary — every term the round pinned down.** When a round settles what a word *means* — sharpens
   a fuzzy term, picks one word over rival spellings, resolves two people meaning different things —
   write it to `CONTEXT.md` immediately (format below). Don't batch these to the end; capture them the
   moment they crystallise. And challenge forward: if the user reaches for a term the glossary already
   defines differently, stop the round and surface the clash before it settles wrong.
2. **ADR — every decision that will outlive its reasoning.** Offer an ADR only when *all three* hold:
   **hard to reverse** (changing your mind later costs real work), **surprising without context** (a
   future reader will look at the code and wonder "why this way?"), and **the result of a real
   trade-off** (there were genuine alternatives and you picked one for stated reasons). The rubric-grill
   you just ran *is* the ADR's raw material — the options and the grading are already on the page. If any
   of the three is missing, skip it; you'd only reverse an easy decision or restate an obvious one.

**An ADR that records a symptom as if it were the root cause is durable damage** — it outlives the
session and the next reader trusts it. So before writing one, apply **looking for the nest** (glossary) to
what the round settled: a decision that is really one instance of a wider gap should name the gap it
belongs to, or wait until that gap is diagnosed. This matters more here than in `grill`, because here the
mistake gets written down.

*Done (per round):* every term the round resolved is in `CONTEXT.md`, and every decision meeting all
three ADR tests has an ADR — or you can name why each settled decision needed neither — and no ADR
records a symptom as a root cause.

## Where the docs live

Create files lazily — only when you have the first thing to write.

- **`CONTEXT.md`** at the repo root (a single glossary for most repos). If a `CONTEXT-MAP.md` exists, the
  repo has several contexts; write the term into the one it belongs to, and ask if it's unclear.
  `CONTEXT.md` is a glossary and nothing else — no implementation detail, no spec, no scratch notes.
- **`docs/adr/`**, sequentially numbered `0001-slug.md`, `0002-slug.md`. Scan the directory for the
  highest number and increment.

### Glossary entry format

Be opinionated: when several words name one concept, pick the best and list the rest under `_Avoid_`. One
or two sentences — define what it *is*, not what it does. Only terms specific to this project belong; a
general programming concept does not, however much the project leans on it.

```md
**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request
```

### ADR format

One to three sentences is a complete ADR — the value is recording *that* a decision was made and *why*,
not filling sections.

```md
# {Short title of the decision}

{1–3 sentences: the context, what you decided, and why.}
```

Add `Status`, `Considered Options`, or `Consequences` only when a rejected alternative is worth
remembering or a downstream effect is non-obvious. Most ADRs need none.

## Completion

Grill's completion still governs the interview: the frontier is empty, every branch visited, each node's
**readiness** stated, and you stop before building until the user confirms. Grill-deep adds one bar to
clear alongside it — **the paper trail is whole**: every resolved term lives in the glossary and every
all-three decision has its ADR, so a reader who never sat in the interview can reconstruct what was
decided and why.
