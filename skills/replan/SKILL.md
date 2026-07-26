---
name: replan
description: Internal planning move reached through dag:plan after execution halts — repair the whole affected chart and return it to pre-flight. Do not invoke directly outside the planning router.
---

# Re-plan — the chart was wrong, not the node

You are here because a signed DAG came back. Not one node sent back to be grilled — the whole chart,
unsigned by `/dag:execute` and carrying a **halt**. Terms are defined once in
[`../../GLOSSARY.md`](../../GLOSSARY.md), and how to respond is in
[`../../RESPONSE-RULES.md`](../../RESPONSE-RULES.md).

**What makes this its own move.** `/dag:grill` settles a decision that is open. `/dag:diagnose` finds the
design gap behind a **cluster** of *code* findings. Neither fits a chart whose nodes are individually fine
and whose *method* was wrong — a contract validated by a check that could not see the defect, an edge
audit that missed a shared shape, a profile that named a path nobody had ever walked. The failure is
upstream of every node, so fixing the node that surfaced it fixes nothing: the same defect is sitting in
every sibling that shares the contract, waiting to be discovered again one build cycle at a time.

`/dag:plan` routes here; you never reach this skill by typing a command.

Inputs: the map issue and the halt recorded on it, the signed pre-flight table from before the halt, and
the nodes still open.

## 1. Read the halt, and say what actually failed

Read the stop as recorded on the map — the node it surfaced on, the tier or check that failed, and the
evidence. Then classify it, because only one of these belongs here:

- **the node was wrong** — its premise or spec. That is a de-fog move, not a re-plan: confirm a de-fog
  node blocks it — a *separate* issue carrying `dag:needs-grilling`, or `dag:needs-prototype` where the
  unknown is whether the thing can be observed at all, never a label on the build node itself — then
  **clear the halt** and hand back to `/dag:plan`, which routes it. Re-planning a whole chart around one
  bad node is ceremony.

  ```bash
  gh issue edit <map-number> --remove-label dag:halted
  ```

  Clearing it is not optional: `dag:halted` is what routed this turn here, so leaving it on sends the next
  `/dag:plan` straight back to this skill for the same node, forever.
- **the method was wrong** — the node was fine and something that validated it was not. This is yours.

Name the failing mechanism in one sentence, in the gate's own words: *which check passed something it
should have caught, and what it was blind to.*

*Done when:* the halt is classified, and where it is a method failure you can name the check that passed
it and what that check could not see.

## 2. Find the class — every node carrying the same defect

**This is [looking for the nest](../../GLOSSARY.md) at chart scale.** The node that surfaced the halt is
the first instance, never the only one — a chart's nodes are written from one profile by one author in one
sitting, so a defect in the method is reproduced across every node the method touched.

Read every open node against the failing mechanism, not against its own spec. Where the defect is a
shared contract, a shared profile line, or a shared tier command, the class is *every node naming it* —
including the ones already merged and awaiting proof, and including the ones nobody has looked at yet.

Say the count out loud. "Five nodes carry this" is the finding; "the node that failed carried this" is the
symptom you arrived with.

*Done when:* every open node has been checked against the failing mechanism and the class is listed by
node number — or you have said plainly that the class is one node and this was not a method failure after
all.

## 3. Amend every contract in the class

Fix the class, not the instance. Amend each affected node's issue body in place — the **proof contract**
lives there and is read by whoever builds the node, so an amendment anywhere else is an amendment nobody
will see.

Where the amendment changes what a node must prove, say so in a comment on that node as well as in the
body: a teammate that already read the old contract needs the delta, not a silently rewritten table.

**Do not lower a bar to make it reachable.** A contract that cannot be met is a finding about the plan; a
contract quietly weakened until it passes is the failure the whole suite exists to prevent. Where the
honest amendment is "this cannot be proven until X exists", X is step 4's repair node and the contract
waits behind it.

*Done when:* every node in the class carries an amended contract in its issue body, no amendment weakened
a bar to reach it, and any node whose contract now depends on unbuilt work is edged behind it in step 4.

## 4. File the repair node, and edge the class behind it

The thing that broke the method is work. File it as a **node** like any other — its own issue, its own
acceptance criteria, its own proof contract — and add a real blocking **edge** from every node in the
class to it:

```bash
gh api repos/<owner>/<repo>/issues/<n> --jq .id                       # the repair node's database id
gh api -X POST repos/<owner>/<repo>/issues/<blocked>/dependencies/blocked_by \
  -F issue_id=<repair-node-database-id>
```

A note on the map saying "fix the evals first" is not an edge and does not stop a wave. The tracker's
blocking relation is what `/dag:execute` computes the ready set from, so that is where the ordering has to
live.

**Where the defect was in the gate itself rather than in this repo, the repair is still a node** — a
contract nobody can meet because the profile named a path that does not exist is repaired by making the
path exist, and that is buildable work.

**Write the repair node's own contract around the failure, not around a clean start.** Where it repairs a
red tier command, the red **baseline** is its recorded "before" and the command passing is its proof — and
pre-flight signs it on exactly that basis rather than stopping it for naming a command that is broken
today. A repair node held to the ordinary rule is a repair node that never dispatches.

*Done when:* the repair node exists with criteria and a contract, and every node in the class is blocked
by it through the tracker's real dependency relation — verified by reading the blockers back.

## 5. Record the re-plan on the map, then hand back to pre-flight

Post one comment on the `dag:map` issue: the halt, the mechanism that failed, the class by node number,
what each amendment changed, and the repair node. **This is the only durable record that this chart was
halted once and why** — the next signature is read by a context window that was not here, and a chart that
looks freshly planned gets signed with the same method that failed.

Then remove the halt and re-enter the gate:

```bash
gh issue edit <map-number> --remove-label dag:halted
```

Re-signing is a full [pre-flight](../preflight/SKILL.md), not a spot-check of the amended nodes — its
baseline step re-runs every tier command in the chart, including the ones that were green last time. A
command that rotted once is in a repo where commands rot.

*Done when:* the re-plan comment is on the map, `dag:halted` is removed, and pre-flight has been re-run in
full over the whole chart — never over the amended nodes alone.
