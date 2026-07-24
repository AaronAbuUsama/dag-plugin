# The review brief

The packet handed to whatever reviews one **node**'s PR. Terms are defined in
[`../../GLOSSARY.md`](../../GLOSSARY.md).

The suite does not own *who* reviews. That is declared on the **map**'s Skills line and is whatever this
repo already trusts — a review skill, a subagent, a bot. It owns what the reviewer is **told**, because a
reviewer given only a diff reviews the diff: it judges style and correctness in the abstract and never
once asks whether this node did the thing it was created to do.

The review runs **before `/dag:prove`**. Finding out at the evidence step that a node can't be proven is
finding out after the work is finished; the reviewer is the last cheap place to catch it.

Compose one per PR, from the node's issue and its **proof ledger** row. Include every field:

- **The node's acceptance criteria**, verbatim. This is the bar the diff is judged against, and it was
  written before the code — the reviewer is checking work against a fixed bar, not forming one.
- **The proof contract**, verbatim: the node's **surface**, its **tiers**, the **evidence form** each
  takes, and the **nonce**.
- **Invariants touched**, as pre-flight named them.
- **Ground already laid** — the merged nodes this one consumes a contract, shape, or name from, so the
  reviewer can tell "targets what exists" from "targets a guess".
- **Where to put the verdict** — a comment on this PR. A verdict left in a transcript did not happen.

## The two questions a review must answer

1. **Does the diff satisfy the acceptance criteria?** Every criterion, named, each met or not met. A
   criterion the diff does not reach is a finding, not an omission.
2. **Does the diff leave the proof contract satisfiable?** The reviewer does not gather the evidence —
   that is `/dag:prove`'s job — it establishes that gathering it will be *possible*: the states the
   contract names are observable, the records it reads are readable, the nonce can be carried through.
   A node that builds correct behaviour nobody can observe is not done, and this is where that surfaces
   while it is still cheap to reshape.

Findings from either question feed the **ladder** exactly the same way.

## The verdict

One comment on the PR carrying: each acceptance criterion with met / not-met, the provability answer,
and every finding. Findings are the review's product — a review returning "looks good" on a node whose
contract it never checked reviewed nothing.

*Done when:* the verdict is posted to the PR as a comment, every acceptance criterion carries a
met/not-met judgement, and the provability question is answered explicitly rather than assumed.
