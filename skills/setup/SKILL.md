---
name: setup
description: One-time repo configuration for the DAG suite — confirms GitHub native blocking, creates the label vocabulary chart and execute rely on, and lays out domain docs. Run once, before the planning door.
---

# Setup — configure this repo for the DAG suite

Scaffold the three things the rest of the suite assumes exist: a **tracker** that supports native
blocking, the **label vocabulary** `chart` and `execute` read and write, and a **domain doc** layout. Terms
are defined once in [`../../GLOSSARY.md`](../../GLOSSARY.md). Prompt-driven, not a script: explore,
present, confirm, then write.

How to respond — the closing message, and any question put to the user — is in
[`../../RESPONSE-RULES.md`](../../RESPONSE-RULES.md).

## Process

### 1. Explore

- `git remote -v` — confirm this repo's remote is GitHub. The suite is GitHub-native: `chart`'s **edges**
  are the tracker's real blocking relationship, not prose links, and no other tracker renders that.
- `gh auth status` — authenticated, and the token carries `repo`. It reports the host and scopes,
  not per-repo access, so confirm that separately with a read against this repo.
- `gh label list` — which of the suite's labels (below) already exist.
- `CLAUDE.md` / `AGENTS.md` at the repo root — does either exist, is `CLAUDE.md` a symlink or a real
  file, does it already import `@AGENTS.md`, and is there already a `## DAG suite` section?
- `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/` — existing domain docs.
- Monorepo signals — a workspace declaration in whatever form this repo's tooling uses, plus populated
  `packages/*/src`. Their absence (the common case) means single-context.

*Done when:* you know the remote, auth state, which labels already exist, the relationship between the
two host instruction files, and whether domain docs already exist.

### 2. Confirm native blocking

`chart` renders the **frontier** from GitHub's real issue-dependency relation — not from checklists or
"blocked by #12" prose. It is a REST endpoint rather than a `gh issue` flag, and it takes the issue's
**database id**, never its `#number`:

```bash
gh api repos/<owner>/<repo>/issues/<n> --jq .id                       # the database id
gh api -X POST repos/<owner>/<repo>/issues/<blocked>/dependencies/blocked_by \
  -F issue_id=<blocker-database-id>
gh api repos/<owner>/<repo>/issues/<n>/dependencies/blocked_by        # read the blockers back
```

Verify it on this repo rather than assuming it: open two throwaway issues, link one as blocked by the
other, read the relation back, then **delete the link and close both** — a probe that leaves a live
dependency between two junk issues has changed the tracker it was only meant to test.

```bash
gh api -X DELETE repos/<owner>/<repo>/issues/<blocked>/dependencies/blocked_by/<blocker-database-id>
```

The read carries each blocker's `state`, which is what lets the frontier be computed with one query per
node.

*Done when:* a blocking link has been created and read back on this repo with the commands above — not
merely that the repo has Issues enabled.

### 3. Create the label vocabulary

Create every label below with `gh label create <name> --color <hex> --description "<text>" --force`
(idempotent — safe to re-run):

GitHub renders a label description as plain text and caps it at 100 characters, so these are written
without markup and short enough to survive:

| Label | Description to set |
|---|---|
| `dag:map` | `The parent map issue indexing this chart's nodes` |
| `dag:preflighted` | `Pre-flight signed; this DAG is cleared for /dag:execute` |
| `dag:halted` | `Execution stopped this DAG; it is re-planned before it is re-signed` |
| `dag:needs-grilling` | `De-fog node: a decision is still open` |
| `dag:needs-research` | `De-fog node: a fact must be found first` |
| `dag:needs-prototype` | `De-fog node: not knowable on paper; a spike answers it` |

The three `dag:needs-*` labels go on **de-fog** nodes, which is where `/dag:plan` reads them.
`dag:map`, `dag:preflighted` and `dag:halted` go on the map, and the last two are a pair: `preflighted`
says a DAG is cleared for execution, `halted` says one was stopped mid-flight and must be re-planned
before it can be cleared again.

A node with none of the three readiness labels is **clear** — spec it and build, no de-fog node needed.
Don't add a "ready" or "blocked" label: that state is native, not a label — a node is on the frontier when
every issue blocking it is closed, and GitHub's UI already shows blocked/unblocked. `execute` closes each
node's issue itself the moment its proof contract is satisfied (close-on-proof) — no closing label either.

*Done when:* `gh label list` shows all six labels present with the descriptions above.

### 4. Domain docs

Default to **single-context** — one `CONTEXT.md` + `docs/adr/` at the repo root — and write it without
asking; it fits almost every repo. Offer **multi-context** (a root `CONTEXT-MAP.md` pointing at
per-context `CONTEXT.md` files) only when step 1 found monorepo signals, and confirm which the user wants.

*Done when:* the chosen layout's files exist (or already existed) and the user has confirmed the choice.

### 5. Confirm and write

Show the user a draft of the `## DAG suite` block below before writing it.

**One shared instruction source:** `AGENTS.md` is canonical for instructions both hosts need. Claude Code
reaches it through `CLAUDE.md`; Codex reads it directly. Apply the first matching case:

1. **Neither exists:** create `AGENTS.md`, then create `CLAUDE.md` as a relative symlink to it.
2. **Only `AGENTS.md` exists:** update it and create the `CLAUDE.md` symlink.
3. **`CLAUDE.md` already symlinks to `AGENTS.md`:** update `AGENTS.md`; do not replace the link.
4. **Only a real `CLAUDE.md` exists:** separate shared instructions into a new `AGENTS.md`. If nothing
   Claude-specific remains, replace `CLAUDE.md` with the relative symlink; otherwise keep the real file,
   put `@AGENTS.md` at its top, and retain the Claude-only section below it.
5. **Both are real files:** put the shared DAG block in `AGENTS.md` once and ensure `CLAUDE.md` imports
   `@AGENTS.md`. Remove any duplicate DAG block from `CLAUDE.md`, preserving Claude-only instructions.

On Windows, or anywhere symlink creation is unavailable, use a real `CLAUDE.md` containing
`@AGENTS.md` instead. Never overwrite host-specific instructions. Show the exact migration diff with the
draft before writing it.

```markdown
## DAG suite

Issues live on GitHub; native blocking is confirmed working. Labels: `dag:map` (map issue),
`dag:preflighted` (pre-flight signed), `dag:halted` (execution stopped it; re-plan before re-signing),
`dag:needs-grilling` / `dag:needs-research` / `dag:needs-prototype` (readiness — absent means clear).
Domain docs: [single-context | multi-context], see CONTEXT.md[/CONTEXT-MAP.md]. See `GLOSSARY.md` and
the planning door for the suite's terms and skills (`/dag:plan` in Claude Code, `$dag:plan` in Codex).
```

*Done when:* the block exists once in `AGENTS.md`, Claude Code reaches it through a symlink or import,
Codex reads it directly, and every pre-existing host-specific instruction is preserved.

### 6. Done

Tell the user setup is complete: every label in step 3 exists, native blocking is confirmed, domain docs
are in place, and the root doc carries the `## DAG suite` block. Re-running this skill is only needed to
change the label set or domain layout later.

**Then hand back to the door — `/dag:plan` — and name nothing else.** Never route the user to a planning
step like `/dag:grill` or `/dag:chart`: which step comes next is `/dag:plan`'s judgement, read off the
chart's state, and naming one here teaches the user a model the suite spends the rest of its time undoing.
Two doors is the whole interface.
