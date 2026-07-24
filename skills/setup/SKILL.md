---
name: setup
description: One-time repo configuration for the DAG suite — confirms GitHub native blocking, creates the label vocabulary chart/run rely on, and lays out domain docs. Run once before /dag:chart.
disable-model-invocation: true
---

# Setup — configure this repo for the DAG suite

Scaffold the three things the rest of the suite assumes exist: a **tracker** that supports native
blocking, the **label vocabulary** `chart` and `run` read and write, and a **domain doc** layout. Terms
are defined once in [`../../GLOSSARY.md`](../../GLOSSARY.md). Prompt-driven, not a script: explore,
present, confirm, then write.

## Process

### 1. Explore

- `git remote -v` — confirm this repo's remote is GitHub. The suite is GitHub-native: `chart`'s **edges**
  are the tracker's real blocking relationship, not prose links, and no other tracker renders that.
- `gh auth status` — confirmed and scoped to this repo.
- `gh label list` — which of the suite's labels (below) already exist.
- `CLAUDE.md` / `AGENTS.md` at the repo root — does either exist, and is there already a `## DAG suite`
  section?
- `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/` — existing domain docs.
- Monorepo signals — `pnpm-workspace.yaml`, a `workspaces` field, populated `packages/*/src`. Their
  absence (the common case) means single-context.

*Done when:* you know the remote, auth state, which labels already exist, which root doc to edit, and
whether domain docs already exist.

### 2. Confirm native blocking

`chart` renders the **frontier** from GitHub's real issue-blocking relation (Issues → Development panel,
or `gh issue edit --add-blocked-by` where available) — not from checklists or "blocked by #12" prose.
Verify it, don't assume it: open two throwaway issues, link one as blocked by the other, confirm the
relation shows in the UI or `gh issue view --json`, then close both.

*Done when:* you have confirmed, on this repo, that a real blocking link can be created and read back —
not just that the repo has Issues enabled.

### 3. Create the label vocabulary

Create every label below with `gh label create <name> --color <hex> --description "<text>" --force`
(idempotent — safe to re-run):

| Label | Meaning |
|---|---|
| `dag:map` | Marks the parent **map** issue that indexes a chart's nodes. |
| `dag:preflighted` | On the map issue: pre-flight is signed and the DAG is cleared for `run`. The conductor reads it. |
| `dag:needs-grilling` | Node's **readiness** is needs-grilling — a decision is still open. |
| `dag:needs-research` | Node's readiness is needs-research — a fact must be found first. |
| `dag:needs-prototype` | Node's readiness is needs-prototype — not knowable on paper; a spike blocks it. |

A node with none of the three readiness labels is **clear** — spec it and build, no de-fog node needed.
Don't add a "ready" or "blocked" label: that state is native, not a label — a node is on the frontier when
every issue blocking it is closed, and GitHub's UI already shows blocked/unblocked. `run` closes each
node's issue itself the moment its proof contract is satisfied (close-on-proof) — no closing label either.

*Done when:* `gh label list` shows all five labels present with the descriptions above.

### 4. Domain docs

Default to **single-context** — one `CONTEXT.md` + `docs/adr/` at the repo root — and write it without
asking; it fits almost every repo. Offer **multi-context** (a root `CONTEXT-MAP.md` pointing at
per-context `CONTEXT.md` files) only when step 1 found monorepo signals, and confirm which the user wants.

*Done when:* the chosen layout's files exist (or already existed) and the user has confirmed the choice.

### 5. Confirm and write

Show the user a draft of the `## DAG suite` block below before writing it.

**Pick the file:** edit `CLAUDE.md` if it exists, else `AGENTS.md` if it exists, else ask the user which
to create. Never create one when the other already exists. If a `## DAG suite` block is already there,
update it in place rather than duplicating it.

```markdown
## DAG suite

Issues live on GitHub; native blocking is confirmed working. Labels: `dag:map` (map issue),
`dag:preflighted` (pre-flight signed), `dag:needs-grilling` / `dag:needs-research` /
`dag:needs-prototype` (readiness — absent means clear).
Domain docs: [single-context | multi-context], see CONTEXT.md[/CONTEXT-MAP.md]. See `GLOSSARY.md` and
`/dag:map` for the suite's terms and skills.
```

*Done when:* the block is written (or updated) in the chosen root doc.

### 6. Done

Tell the user setup is complete: every label in step 3 exists, native blocking is confirmed, domain docs
are in place, and the root doc carries the `## DAG suite` block. Re-running this skill is only needed to
change the label set or domain layout later.
