# DAG Engineering

A Claude Code plugin that makes an agent **prove its work** instead of reporting that the tests passed.

You describe what you want. It breaks the work into slices as GitHub issues, writes down what would
convince you each slice works *before any code exists*, then builds them — and refuses to close anything
until it has captured that evidence and put it in the pull request.

**[Read the docs →](docs/)** — the [walkthrough](docs/docs/02-walkthrough.mdx) shows one effort end to
end, with the real issue bodies and the PR comment.

## Quick start

```
/plugin marketplace add AaronAbuUsama/dag-plugin
/plugin install dag@dag-engineering
```

```
/dag:setup      # once per repo — configures the GitHub tracker + labels
/dag:plan       # settle the plan, chart it, sign it off
/dag:execute    # walk the signed graph to done-clean
```

**Two doors, one for each half.** `/dag:plan` is where you live until the plan is signed: run it from any
window and it reads the state off GitHub, tells you where you are, and names the single next move — so
you never have to work out which skill to reach for. When it says the DAG is signed, you run
`/dag:execute` once and it drives the rest on its own.

## Two phases, two doors

```
        YOU drive                    │        THE ORCHESTRATOR drives
  grill · prototype · chart          │   execute · prove · diagnose
  settle the plan, fix the proof     │   walk the graph, gather the evidence
────────────── /dag:plan ───────────►│◄──────────── /dag:execute ───────────
                          the pre-flight signature
```

**Planning is human-in-the-loop**: `/dag:plan` names one move at a time and runs it *with* you — you make
the decisions. **Execution is not**: once pre-flight is signed, `/dag:execute` walks the graph on its own,
dispatching an **agent team** (one teammate = one node = one worktree = one PR), climbing the escalation
ladder, and proving each node before closing it. The signed pre-flight is the door between them, and it
lives on GitHub as a label — so `/dag:execute` refuses to start without it, and a rung-3 stop hands the
DAG back to `/dag:plan`.

## Why two commands are enough

The state lives on **GitHub**, not in the conversation — the chart (a `dag:map` issue, its child node
issues, their blocking edges, the pre-flight signature) *is* the memory. So a fresh context window
running either door picks up exactly where the last one left off. Stateful by construction.

## The pipeline

```
GRILL / PROTOTYPE ──► CHART ──► PRE-FLIGHT ──► EXECUTE ──►(DIAGNOSE)──► done-clean
  settle the plan     onto      sign it        walk it     find the nest when
  & de-fog it         GitHub                               a bug-class recurs

  └─────────────── /dag:plan ──────────────┘   └────────── /dag:execute ─────────┘
```

| Phase | Skill | What it does |
|---|---|---|
| **entry** | `/dag:plan` | The planning door — reads state, names the next move, through to the signature. |
| | `/dag:execute` | The execution door — walks the signed graph to done-clean. |
| **setup** | `/dag:setup` | One-time: GitHub tracker + the suite's labels. |
| **plan** | `/dag:grill` | Batched, code-grounded interview — the whole frontier per round, every question shown in real code with graded options. Never abstract. |
| | `/dag:grill-deep` | `grill` + writes ADRs and a glossary as decisions settle. |
| | `/dag:research` | Finds a fact a decision waits on (agent-driven). |
| | `/dag:prototype` | A throwaway spike to answer what isn't knowable on paper. |
| | `/dag:chart` | Lays the plan down as a GitHub DAG — nodes + native blocking, each node's readiness de-risked first. |
| **build** | `/dag:preflight` | The gate: every node checked against its invariants, criteria, edges, and a runnable proof contract before any dispatch. |
| | `/dag:execute` | Wave execution behind the merge gate, the escalation ladder, no proof deferral, close-on-proof. |
| | `/dag:prove` | Captures a node's evidence and posts it **into the PR** — screenshots and video for a UI, the durable delta for a backend, the transcript for a CLI — plus a committed receipt. |
| | `/dag:diagnose` | The nest-finder — one design gap behind a recurring cluster. `execute` reaches it automatically. |

## The non-negotiables

- **Verification is king.** A claim you can't verify isn't a result. Tests verify the code against
  itself; only reality verifies it against the world — so a node is done when the real system was
  observed doing the real thing, not when the suite is green.
- **Proof is defined before the code.** Every node's proof contract — which tiers, what evidence, what
  nonce — is written when the issue is created. The agent that builds it never picks its own bar.
- **Proof is never deferred, and never merely asserted.** It is *shown*, in the pull request, in the
  form the surface calls for. A node that can't be proven is a *stop*, not a merge. Reviews-clean ≠ done.
- **A recurring bug-class means stop patching and diagnose.** Patching an undiagnosed subsystem spawns
  new defects; the ladder switches to diagnosis automatically (same class twice, or round 4).
- **Every fix passes fix-completeness** — enumerate every branch and caller before "done", including a
  consolidating fix over every call site of the nest.

## Go deeper

- **The docs site** lives in [`docs/`](docs/) — `bun run --cwd docs dev` to read it locally. It is
  published to GitHub Pages by [`.github/workflows/docs.yml`](.github/workflows/docs.yml) once Pages is
  enabled for the repo.
- **The guided tour** is just `/dag:plan` with no chart yet — it orients you and starts.
- **The vocabulary** — every **bold term** in the skills — lives in [`GLOSSARY.md`](GLOSSARY.md).
- **Each skill** reads as a standalone playbook under [`skills/`](skills/).

## Install & update

Install from the marketplace as above, or load a working copy with
`claude --plugin-dir /path/to/dag-plugin` while iterating. `scripts/check.sh` runs the suite's own
consistency checks. No external skill dependencies.

**What it needs.** GitHub is the tracker and that is not optional — the chart's **edges** are GitHub's
own issue-dependency relation, so `gh` authenticated against the repo is a hard requirement.
`/dag:execute` runs a wave as an **agent team**. `/dag:prove` needs whatever its **evidence form** calls
for — a browser to drive a UI, `ffmpeg` to pull a still out of a journey video.

MIT licensed. Changes in [`CHANGELOG.md`](CHANGELOG.md).
