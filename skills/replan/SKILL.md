---
name: replan
description: Internal planning move reached through dag:plan when pre-flight or execution stops a chart — classify whether the node, validation method, or destination failed, then return the work to the correct planning level. Do not invoke as a public door.
---

# Re-plan — send the failure to the level that owns it

You are here because pre-flight or execution stopped a chart carrying `dag:halted`. Read the map's halt
comment, where it surfaced, the evidence, and either the signed pre-flight table or the pre-flight draft
that raised the stop. Terms are defined in
[`../../GLOSSARY.md`](../../GLOSSARY.md); response rules are in
[`../../RESPONSE-RULES.md`](../../RESPONSE-RULES.md).

## 1. Classify the halt

Exactly one level owns the failure:

| Verdict | What failed | Route |
|---|---|---|
| **node-wrong** | one node's premise or specification | a de-fog issue under this chart |
| **method-wrong** | a shared check, proof contract, profile or edge method let bad work through | repair the affected class across this chart |
| **destination-wrong** | the chart may be aiming at the wrong outcome, boundary or system shape | Wayfinding in the parent Atlas |

Name the verdict and cite the evidence. If the evidence cannot distinguish them, create the smallest
decision issue that can; do not pick the cheapest repair.

## 2. Node-wrong — de-fog the node

Confirm a separate issue carrying `dag:needs-grilling` or `dag:needs-prototype` is both a child of the
map and a blocker of the stopped build node. Read both relationships back. Never put the readiness label
on the build node itself.

Then clear the chart-level halt:

```bash
gh issue edit <map-number> --remove-label dag:halted
```

The chart remains unsigned and the de-fog edge prevents premature pre-flight. Hand back to `dag:plan`,
which routes the decision.

*Done when:* the map's sub-issue read includes the de-fog issue, the node's blocker read includes it, the
map is unsigned but not halted, and the next planning move is visible from GitHub.

## 3. Destination-wrong — return to the Atlas

Do not amend proof contracts or re-sign the existing destination.

Find the map's parent Atlas. If it has none, read [`../plan/wayfind.md`](../plan/wayfind.md) and create
one from the chart, its halt evidence and the wider intent. Record the stopped map under **Expeditions**
and attach it as an Atlas sub-issue using the same `sub_issues` endpoint as Wayfinding. Add an Atlas
decision issue containing:

- the destination the chart assumed;
- the evidence that invalidated it;
- which wider boundary or relationship is now uncertain;
- what deciding it will do to this map.

Keep `dag:halted` on the map while that decision is open. Follow Wayfinding one move at a time.

When the decision lands:

- destination retained → record why, amend the map if necessary, remove `dag:halted`, run full
  pre-flight;
- destination replaced → leave the old map halted until its open nodes are explicitly closed or moved,
  then close the old map with a supersession comment linking the Atlas decision before charting the new
  expedition;
- destination abandoned → close the map and its remaining nodes with the Atlas decision linked.

*Done when:* the destination decision lives in the Atlas, the old chart cannot be re-signed while it is
open, and the decision's result explicitly retains, replaces or abandons that chart.

## 4. Method-wrong — find the affected class

Name the failing mechanism in the gate's own words: which check passed something it should have caught,
and what it could not see.

Read every open node against that mechanism. The affected class is every node sharing the contract,
profile line, tier command or edge assumption — including already-merged nodes still awaiting proof.
List the class by node number.

If only one node carries it, re-check the classification: that is usually node-wrong rather than a
chart-level method failure.

*Done when:* the failed mechanism and every node carrying it are named.

## 5. Amend the class and add the repair

Amend every affected node's proof contract in its issue body. Comment the delta as well so a teammate
that read the old contract sees the change. Never weaken the bar merely to make it reachable.

File one repair node with its own acceptance criteria and proof contract. Attach it as a map sub-issue,
then block every affected node behind it through GitHub's native dependency:

```bash
REPAIR_ID=$(gh api repos/<owner>/<repo>/issues/<repair-number> --jq .id)
gh api -X POST repos/<owner>/<repo>/issues/<map-number>/sub_issues -F sub_issue_id=$REPAIR_ID
gh api -X POST repos/<owner>/<repo>/issues/<blocked>/dependencies/blocked_by \
  -F issue_id=$REPAIR_ID
```

Write the repair contract around the observed failure. A red tier command is its baseline, not a reason
the repair can never dispatch.

*Done when:* every affected contract is amended, the map's sub-issue read includes the repair node, and
blocker readback shows the whole class behind it.

## 6. Record and re-enter the gate

Comment on the map with the halt, verdict, affected class, amendments and repair node. Then remove
`dag:halted` and run full pre-flight:

```bash
gh issue edit <map-number> --remove-label dag:halted
```

Re-run every baseline and every node row, not only the amended class.

*Done when:* the durable re-plan comment exists, the halt is cleared, and full pre-flight has either
re-signed the chart or returned another explicit stop.
