---
name: prove
description: Put a node's proof in the pull request — the evidence its surface calls for, a committed receipt, and a tier table a reviewer can check. Use when a merged node owes its proof, when a PR asserts behaviour it does not show, or when browser evidence (screenshots, video) belongs in a PR.
---

# Prove — show it, don't claim it

Satisfy one node's **proof contract** and land the evidence where a human will actually look: **in the
pull request**. `execute` reaches this skill at the **merge gate**, on the open PR, wherever the **proof
profile** says tier 3 is reachable from a branch — and straight after the merge where it isn't. You can
also run it directly on any PR that owes proof. Terms are defined once in [`../../GLOSSARY.md`](../../GLOSSARY.md);
the capture mechanics live in [`evidence.md`](evidence.md).

Two things a reviewer needs from this, and both matter: **verification** — seeing the thing actually
happened — and **debugging** — having the artifacts to work out what went wrong when it didn't.

Inputs: the node's issue (its proof table, surface, and nonce), the map's **proof profile**, and the PR.

## 1. Establish the baseline

Read the node's proof contract and the profile. **Mint the nonce now** — a fresh value for this run,
never the one written in the issue and never one reused from an earlier run. A value that already lives
in the repo (a committed receipt carries every previous one) cannot be shown absent, so reusing it
turns the next step into theatre.

Then show it appears **nowhere yet**: establish its absence at each tier the contract names, using that
tier's own reach command, and record the empty result.

*Done when:* every tier the contract names has a reach command from the profile, and the nonce's absence
at each of them is recorded with the query that established it.

## 2. Run the proof at each tier

Work the contract's **proof tiers** in order against the **exact committed head**, running as the
**proof profile** says this repo runs it — never a rebuilt tree, never uncommitted changes. Record for
each tier: the command or query run, its result, the UTC window, and the exact identifiers it produced.

**Carry the nonce through the behaviour, not past it.** The contract names where it enters and which
path it must travel. Drive it the way a real user would, so it reaches each tier *by doing the node's
actual job* — a nonce the code emits alongside the feature proves the code ran; only one that travelled
the path the acceptance criteria name proves the feature worked.

**Never weaken an assertion to manufacture green.** A failing proof is a finding about the product, not a
problem with the proof — take it to step 5.

*Done when:* every tier in the contract has been run and carries a **verdict** with its identifiers, and
no assertion was loosened, skipped, or retried into passing.

## 3. Capture the evidence in the node's form

The **evidence form** follows the node's surface — the mechanics for each are in
[`evidence.md`](evidence.md):

- **UI / browser** — a full-frame screenshot of every state the contract names, plus the video of the
  journey. Then *open the artifacts and look at them*: clipped content, unresolved spinners, and
  misleading copy are invisible to an assertion that passed.
- **backend / data** — the durable delta: the record before, the record after, the exact ids.
- **API / SDK** — the real request and response, with ids.
- **CLI / tooling** — the invocation and its full output, captured verbatim.
- **messaging / external surface** — the message as the real recipient saw it, plus its provider id.

Redact **before** capturing, never after: mask secrets, credentials, tokens, and personal data at the
source so no artifact ever contains them. Review every artifact before it is attached.

*Done when:* each tier's evidence exists in the form its surface calls for, you have inspected every
artifact rather than trusting the assertion that produced it, and no artifact contains a secret or
personal datum.

## 4. Commit the receipt, then post it into the PR

Both, in that order — the committed **receipt** outlives the PR page and is the fallback when inline
media doesn't render.

**Commit the receipt** to the profile's receipt path: a self-contained gallery holding the artifacts, the
exact identifiers, the tier table, and the **chain of evidence**.

**Post into the PR** — the body carries the tier table with one **verdict** per tier; the evidence
(screenshots inline, video and receipt linked) goes in the body or a comment. Follow the URL rules in
[`evidence.md`](evidence.md), then **look at the rendered PR page** and confirm the images actually
loaded and the links resolve — a broken embed is an unproven claim.

Close with the two lines that keep the report honest:

- **Chain of evidence** — convergence where this repo has corroborating tiers (the same nonce at each),
  or, where it has none, the observation itself and why the artifact carries it.
- **Irreversible footprint** — the durable records, messages, emails, and published artifacts this run
  created.

*Done when:* the receipt is committed, the PR carries the tier table and the evidence, you have confirmed
on the rendered page that every image and link resolves, and both closing lines are present.

## 5. When a tier fails

A failed tier is the proof working. Diagnose from the artifacts you just captured — never from
guesswork — cheapest first: the failure-instant snapshot, then the video frames, then the collector's
events and **errors** for the run's window, then the logs. Classify what you find:

- **product defect** — the system is wrong. Fix the root cause where every caller converges, then rerun
  the same proof. If the same class recurs, this is `/dag:diagnose`'s trigger — hand it over.
- **spec defect** — the node's premise was wrong. Do not fix around it; this is a **stop**.
- **harness defect** — our own command, wrapper, or capture is broken. That is our work: repair it and
  rerun. A repairable failure of ours is **NOT PROVEN** plus work — never **BLOCKED**.

*Done when:* the failure is classified, and either the proof has been rerun to a verdict or the node is a
recorded stop with the failure evidence attached.

## 6. Report

Return the tier table with a verdict per tier, the receipt link, the chain of evidence, and the
irreversible footprint. State plainly what this run proves **and what it does not** — an unreached tier
is reported as `NOT PROVEN`, never promoted into one that was reached.

*Done when:* every tier in the contract carries a verdict, and no tier's evidence is used to speak for
another.
