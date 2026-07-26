---
name: feedback
description: Capture a DAG Engineering workflow failure, wrong route, lost state, or contradicted contract with reproducible evidence and return it to the dag-plugin source repository. Use when the user asks to record feedback or an observed DAG failure should become an actionable upstream report.
---

# Feedback — return a failure to the source

Record what happened without diagnosing beyond the evidence. This skill reports against
`AaronAbuUsama/dag-plugin`; it does not alter the downstream chart and does not fix the plugin.

## 1. Establish the report

Collect:

- plugin version or candidate commit;
- host and host version;
- downstream repository and the invoked door;
- starting Atlas, map, node, labels, and relevant comments;
- expected route, citing the exact skill clause;
- actual route and its durable effects;
- the shortest reproduction;
- redacted transcript, commands, issue links, or screenshots that prove the difference.

Remove credentials, private user content, tokens, and unrelated repository data. If the evidence does
not establish the claimed failure, mark it **not reproduced** instead of strengthening the story.

Classify the result as exactly one of:

- **confirmed** — evidence or a reproduction contradicts the shipped contract;
- **not reproduced** — the report is useful but the failure is not established;
- **already fixed** — the reported version fails but the current candidate does not;
- **expectation gap** — behavior matches the contract and the contract may need reconsideration.

## 2. Check for an existing report

Search open and closed issues in `AaronAbuUsama/dag-plugin` using the route, state and failure phrase.
Append evidence to a matching open issue rather than filing a duplicate. If a closed issue claims the
same fix, test or compare the reported version before calling it already fixed.

## 3. Draft, then write

Use this issue body:

```markdown
## Failure
<one sentence>

## Version
- Plugin:
- Host:
- Repository:
- Invocation:

## Expected route
<expected state transition and source clause>

## Actual route
<observed transition and durable effects>

## Reproduction
1. ...

## Evidence
- ...

## Verdict
confirmed | not reproduced | already fixed | expectation gap
```

If the user explicitly asked to file or record the feedback, create or update the GitHub issue. Otherwise
show the redacted draft and ask before making the external write. Use an existing feedback/bug label when
available; do not create repository configuration from this skill.

Return the issue URL or the draft, plus any downstream state the failure left unsafe.

## 4. Close the loop

A confirmed report is fixed only when:

1. the old behavior is reproduced or its durable evidence is sufficient;
2. the relevant skill contract is corrected;
3. an independent reviewer checks the affected route and its neighbouring transitions;
4. the original reproduction passes on the candidate;
5. the issue names the fixed version.

Never close feedback because a patch looks plausible.
