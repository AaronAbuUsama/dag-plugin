# Wayfind — orient before charting

Use this move when there is not yet one settled destination to turn into a **chart**. A chart answers
how one **expedition** reaches one destination; Wayfinding answers what the destinations are, how they
relate, and which expedition should be charted next.

`/dag:plan` reaches this move. `/dag:replan` also reaches it when execution proves that a chart's
destination, rather than a node or its validation method, was wrong. Terms are defined in
[`../../GLOSSARY.md`](../../GLOSSARY.md); response rules are in
[`../../RESPONSE-RULES.md`](../../RESPONSE-RULES.md).

## 1. Locate or create the Atlas

An **Atlas** is one open GitHub issue labelled `dag:atlas`. It is the durable index above related
charts, not another chart and not a store for their node detail.

```bash
gh issue list --label dag:atlas --state open --json number,title
```

Use the one the user named or the only one whose scope matches. If several could match, show them and
ask; never guess. If none matches, create one:

```markdown
# North star
<The direction and value sought. It may be less precise than a chart destination.>

## Known terrain
<What exists, the system boundary currently visible, and primary-source links.>

## Decisions so far
- <decision and why>

## Open decisions
- <question whose answer changes which expeditions exist or how they relate>

## Expeditions
- <linked dag:map issue — one settled destination>

## Not yet specified
- <important territory that cannot honestly be charted yet>

## Out of scope
- <explicit boundary>
```

Title it `atlas: <initiative or system>` and label it `dag:atlas`. The body is a summary that can be
rewritten as knowledge improves; the issue history and comments preserve how it changed.

*Done when:* one Atlas unambiguously owns this territory and a fresh context can tell what is known,
what is open, and which charts already exist.

## 2. Turn fog into decision issues

Create only the next decisions that materially change the shape of the Atlas. Each is a child issue of
the Atlas and carries the existing readiness label that names how it resolves:

- `dag:needs-grilling` — a choice the user must settle;
- `dag:needs-research` — a fact primary sources can settle;
- `dag:needs-prototype` — something not knowable on paper.

Several consequences of one unknown are one decision issue, not several. Do not create implementation
nodes here. A decision issue records the question, why it changes the map, and what becomes chartable
when it lands.

Run one decision move per planning turn. Put the answer in a comment, fold the result into **Decisions
so far**, update or remove the matching **Open decisions** line, then close the decision issue. The
close advances the Atlas frontier in the same way a de-fog issue advances a chart.

*Done when:* the current question has one durable answer, the Atlas summary reflects it, and no closed
decision remains listed as open.

## 3. Graduate a settled destination

The moment one bounded destination is clear enough to state, graduate it into an **expedition**:

1. Write the destination and scope edge into the Atlas expedition entry.
2. Read [`../chart/SKILL.md`](../chart/SKILL.md) and copy both into that expedition's map.
3. Add the resulting `dag:map` issue as a child of the Atlas and link it under **Expeditions**:

```bash
R=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
MAP_ID=$(gh api repos/$R/issues/<map-number> --jq .id)
gh api -X POST repos/$R/issues/<atlas-number>/sub_issues -F sub_issue_id=$MAP_ID
   ```

4. Leave unresolved territory under **Open decisions** or **Not yet specified**; every still-relevant
   unspecified item must name the next child decision that advances it. Do not force it into the chart.

One Atlas may hold several expeditions. One chart still owns exactly one destination.

*Done when:* the chart can be understood without the Wayfinding conversation, the Atlas links it once,
and no unresolved destination premise was smuggled into its nodes.

## 4. Resume or finish

On every re-entry, read the Atlas body, its open child decision issues, and its child `dag:map` issues
from GitHub. Do not depend on the prior conversation.

Keep the Atlas open while it has an open decision, unspecified territory that still matters, or an
active expedition. For every still-relevant **Not yet specified** item, create the next decision issue
before ending the move; otherwise move it to **Out of scope**. Close the Atlas only when its intended
territory is fully represented by completed expeditions, explicit decisions, or **Out of scope**.

*Done when:* the next planning move is visible from GitHub alone: resolve one Atlas decision, chart one
graduated expedition, resume an existing chart, or close the Atlas.
