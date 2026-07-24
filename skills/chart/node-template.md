# Chart templates and the create-then-wire mechanic

Reached from `SKILL.md` step 4. Terms are defined in [`../../GLOSSARY.md`](../../GLOSSARY.md).

## Map body (issue labelled `dag:map`)

The whole chart at low resolution — the index, loaded once per session. Nodes aren't listed by hand;
they're open child issues found by query. The map only gists and links.

```markdown
## Destination

<what reaching the end of this chart looks like — the spec, feature, or change it builds to. One or two lines.>

## Notes

<domain; skills every node should consult; standing preferences for this effort.>

## Nodes

<!-- one line per node: title (linked) — readiness — one-line gist. -->

- [<node title>](link) — clear — <gist>
- [<node title>](link) — needs-prototype (spike: [<spike title>](link)) — <gist>

## Not yet specified

<!-- only if escalated to fog-of-war: the un-ticketable regions, graduated into nodes as upstream de-fog resolves. -->
```

## Node body (child issue of the map)

```markdown
## What to build

The end-to-end behaviour this node makes work, from the user's perspective — not a layer-by-layer list.

## Acceptance criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Readiness

clear | needs-grilling | needs-research | needs-prototype — one line on the de-fog node if any.

## Blocked by

The blocking nodes (build edges + any de-fog node), or "None — on the frontier".
```

Avoid file paths and code snippets — they go stale. Exception: a prototype/spike that produced a
decision-encoding snippet (state machine, reducer, schema, type shape) — inline the decision-rich bit and
note it came from a spike.

De-fog node bodies (grilling / research / prototype) hold just the question or spike goal; the matching
`/dag:grill`, `/dag:research`, `/dag:prototype` skill drives them.

## Create, then wire — two passes

Issues must exist before they can reference each other, so create everything first, wire second.

**Pass 1 — create.** Create the map issue (label `dag:map`). Then create every node and de-fog node as a
child (sub-issue) of the map. Capture each returned issue number.

```bash
gh issue create --title "map: <destination>" --label dag:map --body-file map.md
gh issue create --title "<node title>" --body-file node-NN.md   # repeat per node; note each number
```

**Pass 2 — wire.** Now that every node has an id, add the native blocking edges — for each node, link the
nodes that block it (build edges and its de-fog node). Use GitHub's sub-issue / blocked-by relationship
(the `gh` sub-issue commands or the issue's Relationships UI) so the frontier renders visually; fall back
to a "Blocked by" body list only if native blocking is unavailable. Wiring sorts nodes into the frontier
(no open blockers) and the blocked.

*Done when:* every build and de-fog edge is a native blocking link and GitHub shows the correct frontier.
