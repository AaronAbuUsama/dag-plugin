# Response rules

How this suite talks to a human. It covers the message a turn ends with — a state roll-up, a finding, a
decision, a grill, or a two-line update — and the **decision block**, which fires whenever a question goes
to the user, mid-turn as often as at the end. Terms are in [`GLOSSARY.md`](GLOSSARY.md).
Evidence authority, premise admission and correction receipts are in
[`EVIDENCE-AUTHORITY.md`](EVIDENCE-AUTHORITY.md); presentation must never hide those states.

The reflexes here that must hold with nothing read are also in this plugin's output style, which loads
every turn. This file is the full vocabulary behind them.

**Composable slots, not a template.** Pick the slots the message actually needs and skip the rest. A
three-line update is three lines; imposing ceremony on it is a failure of this style, not compliance with
it.

The one rule with no exceptions: **hard separators between major sections.** A wall of paragraphs and
bullets that blur together is the failure mode this exists to prevent — use `---` between slots whenever
there is more than one.

---

## HEADLINE — always

One sentence, first thing, telling the reader **the shape of the news before any detail**. Not a summary
of what you did — an answer to "what am I about to read, and does it need me?"

```markdown
Setup is done and the chart is ready to lay down — nothing needs you.
```
```markdown
Three findings, and they look like one root cause. One decision needed.
```
```markdown
Stopped: the node's premise is wrong and re-planning it unblocks four others.
```

A reader who stops after the headline should still know whether to keep reading.

---

## FLIGHT DECK — for state

Scannable state. A compact table or a tight key/value block, never prose. The body of a roll-up.

```markdown
| | |
|---|---|
| **Where** | wave 2 of 4 · 6 nodes done-clean, 2 in flight, 12 blocked |
| **Saved** | issues #364–#371 closed · 6 receipts committed |
| **In flight** | PR #372, PR #373 · 2 worktrees live |
| **Next** | wave 3 dispatches 4 nodes — mine to run |
```

Values carry numbers and identifiers, not adjectives. "Good progress" is not state; "6 of 20 done-clean"
is.

---

## EVIDENCE TABLE — a component, not a format

Drop this in **whenever the message makes claims that need backing**. It is not tied to any one kind of
message — a finding, a roll-up, and a grill can all need one.

```markdown
| Claim | Evidence/ref | Verified | Authority | Premise status |
|---|---|---|---|---|
| The listener is torn down when auth settles | `wa/session.ts:214 @ abc1234` | ✅ read it at HEAD | `current-repo-source` | active |
| An old design used cyan radicals | deleted file at `92878a9` | ✅ read from history | `historical/tombstoned` | active |
| The coalescer's queue is unbounded | agent report, not re-checked | ⚠️ unverified | `report/memory` | contested |
```

**Verification and authority are separate.** `Verified` separates what *you* checked from what something
else told you. `Authority` says whether that source owns this claim now. A deleted file can be personally
verified and still have no authority over the current product. Mark unverified, historical, contested and
inferred rows plainly rather than dropping them.

Evidence is a `file:line @ commit`, a command and its result, a versioned URL plus observation date, or
an exact user answer. "As discussed" is not evidence.

When a correction invalidates a displayed recommendation or decision, show the premise invalidation
receipt and every descendant disposition before presenting a replacement baseline.

---

## DECISION BLOCK — whenever the human must choose

This is the whole of the decision protocol, and it applies to **every** moment you ask a human to decide,
choose, or unblock — structured question prompts, grills, and any options put in front of them. Nothing
here is optional and the order is fixed:

1. **The problem, in authoritative code.** Current `file:line @ ref` and real snippets, in a
   language-tagged fence. Not a paraphrase of the code — the code. Historical material is labelled
   `historical/tombstoned` and can explain history, never pose as current source. A diagram instead only
   when the shape (a flow, a state machine, a dependency web) lands faster drawn.
2. **What it touches.** Zoom out: the surrounding code, its callers and dependents, the blast radius.
   **Assume the reader has read none of it** — a reference to code you did not show is one they cannot use.
3. **The options, as code or diffs.** Each candidate as a concrete snippet or diff sketch. Never a prose
   description of an approach.
4. **Graded against a stated rubric.** Name the axes first, then score every option against them in a
   table:

   | Axis | What it means here |
   |---|---|
   | floor-first | ships the real thing now, not a promise of it |
   | reversibility | how cheaply this is undone if wrong |
   | blast radius | how much changes, and what breaks if it does |
   | correctness / integrity | what invariant this protects or gives up |
   | parallelizability | can it run beside other work, or does it serialise |
   | fit | how well it sits with what is already there |

5. **A recommendation, with the reason.** One option, one line of why.
6. **Only then, the question** — through the host's question surface, recommended option first.

Use exactly one question path per host:

- **Claude Code** — `AskUserQuestion`.
- **Codex** — `request_user_input` when that tool is available; otherwise ask the grounded question
  directly in the response. Do not stall trying to call a tool the current Codex mode does not expose.

A rubric inside a sentence of prose is not a rubric. A question asked before parts 1–5 are on screen is a
question the reader cannot judge, and asking it is the failure this block exists to prevent.

---

## WHAT YOU DO — always, if the turn ends

The last line. What the human does now, in plain words — and it is usually **nothing, or run the same
command again**. Say it outright: someone who has not read the docs has no way to know that re-running the
door resumes the work.

Never hand over a *step* command. The two doors name only each other.

---

## Composing it

| Kind of turn | Slots |
|---|---|
| Two-line update | headline, and stop |
| State roll-up | headline · flight deck · what you do |
| A finding | headline · evidence table · what you do |
| A decision | headline · decision block *(which contains its own evidence)* |
| A grill | headline · one decision block per question |
| A stop | headline · flight deck · evidence table · decision block |

When in doubt, fewer slots. The style earns its keep by making a long message scannable, not by making a
short one formal.
