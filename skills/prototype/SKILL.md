---
name: prototype
description: Build the throwaway spike that de-risks a DAG node. Use when a node's readiness is needs-prototype, or when another dag skill raises a spike against a node.
---

# Prototype

A **spike** is throwaway code that answers one design question, then is discarded. The question
decides the shape. This is how the suite de-risks a **needs-prototype** node cheaply, before the real
build commits — see [`../../GLOSSARY.md`](../../GLOSSARY.md).

The shape of the message a turn ends with is in
[`../../STOPPING-MESSAGE.md`](../../STOPPING-MESSAGE.md).

## Pick a branch

Identify which question is being answered — from the user's prompt, the surrounding code, the
node's readiness note, or by asking if the user is around:

- **"Does this logic / state model feel right?"** → [LOGIC.md](LOGIC.md). Build a tiny interactive
  terminal app that pushes the state machine through cases that are hard to reason about on paper.
- **"What should this look like?"** → [UI.md](UI.md). Generate several radically different UI
  variations on a single route, switchable via a URL search param and a floating bottom bar.

The two branches produce very different artifacts — getting this wrong wastes the whole spike. If the
question is genuinely ambiguous and the user isn't reachable, default to whichever branch better
matches the surrounding code (a backend module → logic; a page or component → UI) and state the
assumption at the top of the prototype.

## Rules that apply to both

1. **Throwaway from day one, and clearly marked as such.** Locate the prototype code close to where
   it will actually be used (next to the module or page it's prototyping for) so context is obvious —
   but name it so a casual reader can see it's a spike, not production. For throwaway UI routes, obey
   whatever routing convention the project already uses; don't invent a new top-level structure.
2. **One command to run.** Use the repo's own package manager and task runner — read it off the
   lockfile rather than guessing. Where the repo doesn't settle it, ask, and prefer **bun**: it executes
   TypeScript as-is, so a spike needs no build step. The user must be able to start it without thinking.
3. **No persistence by default.** State lives in memory. Persistence is the thing the spike is
   _checking_, not something it should depend on. If the question explicitly involves a database, hit
   a scratch DB or a local file with a clear "PROTOTYPE — wipe me" name.
4. **Skip the polish.** No tests, no error handling beyond what makes the spike _runnable_, no
   abstractions. The point is to learn something fast.
5. **Surface the state.** After every action (logic) or on every variant switch (UI), print or render
   the full relevant state so the user can see what changed.
6. **Capture it when done.** Fold any validated decision into the real code, then capture the spike
   itself as a **primary source**: commit it to a throwaway branch, out of main, and leave a context
   pointer to that branch on the node's issue. Capture the verdict too — the question it settled and
   the answer — as a comment on the node issue that the `needs-prototype` build node was blocked on.
   If the tracker isn't configured yet, run `/dag:setup` first. The main branch keeps only the
   validated decision.
