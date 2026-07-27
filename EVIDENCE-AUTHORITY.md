# Evidence authority — premises that may move planning state

Planning turns observations into decisions, issues, maps and signatures. That conversion is allowed only
when the observation has authority for the claim being made. This file is the one contract for admitting
those premises, recording what derives from them, and retracting descendants when a premise fails. Terms
are defined in [`GLOSSARY.md`](GLOSSARY.md); response presentation remains in
[`RESPONSE-RULES.md`](RESPONSE-RULES.md).

The contract governs planning and planning-side repair. It does not replace native GitHub blocking, the
proof ledger, or exact-head runtime proof. Those remain execution mechanisms; premise links are
epistemic provenance.

## Authority belongs to a claim domain

| Class | Owns | What it may unlock |
|---|---|---|
| `user-intent` | desired outcome, scope, value, choices and corrections | planning territory and human decisions |
| `current-repo-source` | current repository or system facts at an exact worktree/HEAD ref, including the current canon pointer | repo-fact premises |
| `current-external-primary` | current external facts at a versioned URL, API or spec and observation date | external-fact premises after lead verification |
| `historical/tombstoned` | how the project used to be, including deleted or rejected alternatives | historical explanation only |
| `inference` | a proposed consequence of admitted premises | recommendations and questions, visibly labelled |
| `report/memory` | teammate reports, transcripts, tracker summaries and model memory | an investigation to verify the claim |

There is no global ranking. The user owns intent; the current repo owns current repo facts. Repository
context may ground an interview but cannot supply a goal. A user preference cannot rewrite what HEAD
contains. An inference or report can open a question, never silently become a fact or close one.

## Resolve current authority before history

For a current repo claim:

1. Record the working tree state and exact HEAD.
2. Resolve the repo's current authority pointer first — for example its README, AGENTS instructions,
   canon index, architecture document, manifest or live configuration.
3. Read the pointed-to source at that same current ref.
4. Only then use Git history, and only when history is needed to explain a change.

An absent path is `unknown` unless current history establishes an intentional deletion. A deletion is a
first-class negative authority signal: the deleted content is `historical/tombstoned`, not a gap to fill.
It may explain what was tried, but it cannot ground a current decision. A historical artifact becomes
current again only when a current authoritative source explicitly re-adopts it; mere survival in Git
history is not adoption.

External primary sources carry the same currency obligation: record the URL or API, version where one
exists, and the date observed. “Primary” identifies who owns a fact; it does not prove the source is
current.

## Record every premise that can unlock work

Before a claim changes planning territory, closes a decision, creates or advances durable planning
state, writes an ADR, declares a node clear, or signs pre-flight, give it a premise record:

```markdown
### Premise P-3
- **Claim:** `docs/design/screens.html` is the current visual acceptance source
- **Class:** `current-repo-source`
- **Source/ref:** `README.md:10-33 @ 3e93a42`, corroborated by `ARCHITECTURE.md:234-235`
- **Status:** active
- **Derived artifacts:** recommendation R-2; decision D-4; map #21; nodes #22 and #23
```

Allowed statuses are:

- `active` — admitted and usable in its authority domain;
- `contested` — contradictory evidence exists; it unlocks nothing;
- `invalid` — disproved or corrected; descendants must be invalidated;
- `superseded` — once valid, now replaced by a newer authoritative premise.

Use stable premise IDs within the owning Atlas, map or standalone planning issue. Every durable
descendant carries `Derived from: P-...`: Atlas decisions, recommendations, research answers, ADRs, maps,
nodes and pre-flight signatures. When a child derives from another descendant, record that too; the chain
must remain walkable back to its premises.

Keep immutable source anchors: path plus commit, issue/comment URL, versioned URL plus observation date,
or an exact user answer. Do not replace provenance with a list of guessed implementation paths.

## Admission gate

A premise may unlock a transition or mutation only when all are true:

1. its class owns the claim domain;
2. its exact source/ref and currentness are recorded;
3. its status is `active`;
4. a `report/memory` or `inference` claim that is knowable has been re-verified into the authority class
   that owns it;
5. planning territory has an active `user-intent` premise.

Apply this gate immediately before:

- creating or advancing an Atlas, decision issue, map or node;
- folding an answer into durable decisions or closing a de-fog issue;
- writing a project research note, glossary term or ADR as accepted knowledge;
- declaring readiness `clear`;
- signing pre-flight.

Read-only exploration may precede admission. It remains a draft: label it with its provisional class,
keep it out of project canon and tracker answers, and do not let it unlock anything.

### Bare planning door

When no Atlas/map exists and the invocation supplies no desired outcome, destination, problem or scope,
there is no `user-intent` premise. Inspect only enough current code/canon to frame one batched,
code-grounded interview asking what outcome is being planned. Then stop for the answer. Do not create or
edit issues, dependencies, project research files, ADRs or glossary entries before the answer establishes
the planning territory.

### Research and teammate reports

A research teammate posts a **candidate answer** with its sources and authority classes. The planning
lead re-checks any repo fact at the exact current ref and admits or contests the answer. Only the lead's
admission comment may close the research issue and unblock descendants.

Exploration before premise admission stays in the teammate report, a scratch location, or chat. Do not
write it into the project's durable research/canon tree merely because research was performed. Once
admitted, persist the note and include its premise record.

## Invalidate descendants before replacing a premise

A user correction, changed canon pointer, deletion, conflicting current source, failed verification, or
superseding decision is an invalidation trigger. Before issuing a corrected recommendation or baseline:

1. mark the premise `contested`, `invalid` or `superseded` and cite the contradiction;
2. walk every `Derived from` link and enumerate all descendants;
3. retract or mark superseded every dependent recommendation and decision;
4. reopen or replace affected de-fog decisions;
5. remove `dag:preflighted` from any affected map and stop new dispatch;
6. explicitly retain, amend, replace, abandon or supersede each affected Atlas, map and node;
7. post one invalidation receipt;
8. recompute from the nearest frontier whose premises remain active.

Use the existing re-plan shape for durable repair: affected-class enumeration, one recorded repair,
full pre-flight again. Do not weaken or overload native blocking edges. A map can be operationally fresh
and still epistemically unsafe; both conditions must hold.

The invalidation receipt is:

```markdown
## Premise invalidation
- **Premise:** P-3 — <claim>
- **Trigger:** <correction or contradictory source/ref>
- **Previous status → new status:** active → invalid
- **Descendants:** <every recommendation, decision, issue, map, node, ADR and signature>
- **Disposition:** <retracted, reopened, amended, retained with reason, superseded or abandoned>
- **Nearest valid frontier:** <where planning resumes>
```

No descendant may be omitted or silently carried into a “corrected baseline.” If the traversal is
incomplete, planning is stopped, not corrected.

## Presentation

An evidence table shows both verification and authority:

| Claim | Evidence/ref | Verified | Authority | Premise status |
|---|---|---|---|---|
| The current canon points at `screens.html` | `README.md:10-19 @ abc1234` | read at HEAD | `current-repo-source` | active |
| An old design used cyan radicals | deleted file at `92878a9` | read from history | `historical/tombstoned` | historical only |
| The queue is unbounded | teammate report | not re-checked | `report/memory` | contested |

“Observed” and “authoritative for this claim” are different assertions. Show both.
