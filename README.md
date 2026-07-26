# DAG Engineering

A Claude Code and Codex plugin that makes an agent **prove its work** instead of reporting that the
tests passed.

You describe what you want. If the destination is unclear it first preserves an Atlas of decisions and
related expeditions. Then it breaks one destination into slices as GitHub issues, fixes the evidence bar
before code exists, and refuses to close anything until that evidence is in the pull request.

**[Read the docs →](docs/)** — the [walkthrough](docs/docs/02-walkthrough.mdx) shows one expedition end to
end, with the real issue bodies and the PR comment.

## Quick start

**Claude Code**

```text
/plugin marketplace add AaronAbuUsama/dag-plugin
/plugin install dag@dag-engineering
```

**Codex**

```bash
codex plugin marketplace add AaronAbuUsama/dag-plugin
codex plugin add dag@dag-engineering
```

Then use the same skills with the host's native syntax:

| Move | Claude Code | Codex |
|---|---|---|
| Configure the repo once | `/dag:setup` | `$dag:setup` |
| Settle, chart and sign the plan | `/dag:plan` | `$dag:plan` |
| Walk the signed graph to done-clean | `/dag:execute` | `$dag:execute` |

**Updating.** Third-party marketplaces do not auto-update by default, so an install stays put until you
refresh it — then restart, since the running session keeps the version it launched with:

```bash
claude plugin marketplace update dag-engineering
claude plugin update dag@dag-engineering            # add --scope local if installed per-project
```

**Two doors, one for each half.** `dag:plan` is where you live until the plan is signed: run it from any
window and it reads the state off GitHub, tells you where you are, and runs the next move — so you never
have to work out which skill to reach for, or type a second command to start. When it says the DAG is
signed, you run `dag:execute` once and it drives the rest on its own. Claude Code spells those doors
`/dag:plan` and `/dag:execute`; Codex spells them `$dag:plan` and `$dag:execute`.

## Two phases, two doors

```
        YOU drive                    │        THE ORCHESTRATOR drives
  wayfind · grill · prototype · chart│   execute · prove · diagnose
  settle the plan, fix the proof     │   walk the graph, gather the evidence
────────────── dag:plan ─────────────►│◄──────────── dag:execute ────────────
                          the pre-flight signature
```

**Planning is human-in-the-loop**: `dag:plan` reads the chart's state and runs the next move *with* you,
in the same turn — you make the decisions, it never hands you a command to type. **Execution is not**:
once pre-flight is signed, `dag:execute` walks the graph on its own. The main orchestrator reads the
frontier from GitHub, creates the worktrees and assigns one issue to each teammate. Claude Code uses
Agent Teams; Codex uses native child agents. Workers never self-claim from a runtime task list or
delegate further. The signed pre-flight is the door between the halves; a rung-3 stop freezes dispatch
and hands the DAG back to planning instead of running the rest on broken assumptions.

## Why two commands are enough

The state lives on **GitHub**, not in the conversation — an Atlas is a `dag:atlas` issue above related
expedition charts; each chart is a `dag:map` issue with child nodes, blocking edges and a signature.
A fresh context window running either door picks up where the last one left off.

## The pipeline

```
WAYFIND ──► GRILL / PROTOTYPE ──► CHART ──► PRE-FLIGHT ──► EXECUTE ──►(DIAGNOSE)──► done-clean
if needed     settle one            onto      sign it        walk it     find the nest
              expedition            GitHub

  └──────────────── dag:plan ───────────────┘   └────────── dag:execute ──────────┘
```

| Phase | Skill | What it does |
|---|---|---|
| **entry** | `dag:plan` | The planning door — reads state and runs the next move, through to the signature. |
| | `dag:execute` | The execution door — walks the signed graph to done-clean. |
| **setup** | `/dag:setup` | One-time: GitHub tracker + the suite's labels. |
| **plan** | Wayfinding *(internal)* | Resolves destination fog into an Atlas of expedition charts. |
| **plan** | `/dag:grill` | Batched, code-grounded interview — the whole frontier per round, every question shown in real code with graded options. Never abstract. |
| | `/dag:grill-deep` | `grill` + writes ADRs and a glossary as decisions settle. |
| | `/dag:research` | Finds a fact a decision waits on (agent-driven). |
| | `/dag:prototype` | A throwaway spike to answer what isn't knowable on paper. |
| | `/dag:chart` | Lays the plan down as a GitHub DAG — nodes + native blocking, each node's readiness de-risked first. |
| **build** | `/dag:preflight` | The gate: every node checked against its invariants, criteria, edges, and a runnable proof contract before any dispatch. |
| | `/dag:execute` | Wave execution behind the merge gate, the escalation ladder, no proof deferral, close-on-proof. |
| | `/dag:prove` | Captures a node's evidence and posts it **into the PR** — screenshots and video for a UI, the durable delta for a backend, the transcript for a CLI — plus a committed receipt. |
| | `/dag:diagnose` | The nest-finder — one design gap behind a recurring cluster. `execute` reaches it automatically. |
| **support** | `/dag:feedback` | Captures an evidence-backed workflow failure and returns it to this repository. |

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

- **The docs site** lives in [`docs/`](docs/) — `bun run --cwd docs dev` to read it locally. It is live
  on [GitHub Pages](https://aaronabuusama.github.io/dag-plugin/) and deployed by
  [`.github/workflows/docs.yml`](.github/workflows/docs.yml).
- **The guided tour** is just `dag:plan` with no chart yet — it orients you and starts.
- **The vocabulary** — every **bold term** in the skills — lives in [`GLOSSARY.md`](GLOSSARY.md).
- **Each skill** reads as a standalone playbook under [`skills/`](skills/).

## Install & update

Install from the marketplace as above. For local Claude Code iteration, use
`claude --plugin-dir /path/to/dag-plugin`. `scripts/check.sh` checks both manifests and the shared skill
suite; `claude plugin validate .` validates the Claude package. No external skill dependencies.

Claude Code updating is two steps and a restart — refresh the marketplace, then move the install — and
`claude plugin update` defaults to `--scope user`, so a per-project install needs `--scope local` or it
reports the plugin as not installed. Codex refreshes the configured marketplace with
`codex plugin marketplace upgrade dag-engineering`. Full detail in the
[quickstart](docs/docs/01-quickstart.mdx#updating).

**What it needs.** GitHub is the tracker and that is not optional — the chart's **edges** are GitHub's
own issue-dependency relation, so `gh` authenticated against the repo is a hard requirement.
Execution needs the host's native multi-agent runner: Agent Teams in Claude Code, or child agents in
Codex. There is no Claude subagent fallback. `/dag:prove` needs whatever its **evidence form** calls for
— a browser to drive a UI, `ffmpeg` to pull a still out of a journey video. The optional DAG output
style is Claude Code-only; the shared response rules carry the same behavioral contract in Codex.

MIT licensed. Changes in [`CHANGELOG.md`](CHANGELOG.md).
