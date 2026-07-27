#!/usr/bin/env bash
# Mechanical checks for the dag suite. Run from the repo root: scripts/check.sh
# Tier 1 only — it proves the suite is internally consistent, never that it works.
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
note() { printf "  %s\n" "$1"; }
bad() { printf "  FAIL: %s\n" "$1"; fail=1; }
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

echo "== manifests =="
python3 -c "
import json, pathlib
claude=json.load(open('.claude-plugin/plugin.json'))
codex=json.load(open('.codex-plugin/plugin.json'))
market=json.load(open('.claude-plugin/marketplace.json'))
for label, manifest in (('Claude', claude), ('Codex', codex)):
    for key in ('name','version','description'):
        assert manifest.get(key), '%s manifest missing %s' % (label, key)
assert claude['name'] == codex['name'] == market['plugins'][0]['name']
assert claude['version'] == codex['version'] == market['metadata']['version']
assert codex.get('skills') == './skills/' and pathlib.Path(codex['skills']).is_dir()
print('  valid JSON, name=%s version=%s (Claude + Codex)' % (claude['name'], claude['version']))
" || bad "manifest invalid"

echo "== frontmatter =="
for f in skills/*/SKILL.md; do
  d=$(basename "$(dirname "$f")")
  n=$(awk -F': ' '/^name: /{print $2; exit}' "$f")
  [ "$n" = "$d" ] || bad "$f: name '$n' != directory '$d'"
  grep -q "^description: " "$f" || bad "$f: no description"
done
note "$(ls -1 skills/*/SKILL.md | wc -l | tr -d ' ') skills checked"

echo "== Codex-compatible skill frontmatter =="
if grep -R "^disable-model-invocation: true$" skills/*/SKILL.md > "$tmp/codex-frontmatter"; then
  while read -r l; do bad "Codex ingestion rejects $l"; done < "$tmp/codex-frontmatter"
else
  note "no Claude-only invocation guards"
fi

echo "== skills/ holds only this plugin's own skills =="
# A skill installer that symlinks a foreign skill into skills/ makes the plugin ship it.
# The suite's own skills are real directories; anything linked in came from elsewhere.
for d in skills/*; do
  [ -L "$d" ] && bad "$(basename "$d") is a symlink in skills/ — it would ship with the plugin"
done
note "no foreign skills linked in"

echo "== /dag: cross-references resolve =="
for s in $(git ls-files -z -- '*.md' '*.mdx' | xargs -0 grep -hoE "/dag:[a-z-]+" | sort -u); do
  [ -f "skills/${s#/dag:}/SKILL.md" ] || bad "unresolved reference $s"
done
note "all resolve"

echo "== relative links resolve =="
# Matches ](path.md) and ](path.md#anchor); skips same-file anchors ](#x) and absolute URLs.
git ls-files -- '*.md' | while IFS= read -r f; do
  grep -oE "\]\([^)#:][^)#]*\.md(#[^)]*)?\)" "$f" | sed 's/^](//;s/)$//;s/#.*$//' | while read -r l; do
    [ -f "$(dirname "$f")/$l" ] || echo "$f -> $l"
  done
done > "$tmp/links"
if [ -s "$tmp/links" ]; then
  while read -r l; do bad "broken link $l"; done < "$tmp/links"
else
  note "checked"
fi

echo "== evidence-authority contract is wired =="
python3 - <<'PYAUTH' || bad "evidence-authority contract incomplete"
from pathlib import Path

contract = Path("EVIDENCE-AUTHORITY.md")
assert contract.is_file(), "missing EVIDENCE-AUTHORITY.md"
body = contract.read_text()
for term in (
    "user-intent",
    "current-repo-source",
    "current-external-primary",
    "historical/tombstoned",
    "report/memory",
    "Derived from",
    "invalidation receipt",
):
    assert term in body, f"contract missing {term}"
assert "historical only" not in body

covered = (
    "README.md",
    "skills/setup/SKILL.md",
    "skills/plan/SKILL.md",
    "skills/plan/wayfind.md",
    "skills/grill/SKILL.md",
    "skills/grill-deep/SKILL.md",
    "skills/research/SKILL.md",
    "skills/prototype/SKILL.md",
    "skills/prototype/LOGIC.md",
    "skills/prototype/UI.md",
    "skills/chart/SKILL.md",
    "skills/chart/node-template.md",
    "skills/preflight/SKILL.md",
    "skills/replan/SKILL.md",
    "skills/feedback/SKILL.md",
    "RESPONSE-RULES.md",
    "output-styles/dag-house-style.md",
    "GLOSSARY.md",
)
for name in covered:
    assert "EVIDENCE-AUTHORITY.md" in Path(name).read_text(), f"{name} does not reference the contract"

plan = Path("skills/plan/SKILL.md").read_text()
assert plan.index("request carries no planning intent") < plan.index(
    "destination/system shape is foggy"
), "no-intent route must precede foggy Wayfinding"
assert "Make no GitHub or repo mutation" in plan

wayfind = Path("skills/plan/wayfind.md").read_text()
assert "active `user-intent` premise" in wayfind

readme = Path("README.md").read_text()
setup = Path("skills/setup/SKILL.md").read_text()
assert "if the invocation is bare" in readme and "before writing" in readme
assert "setup completion is not planning intent" in setup

logic = Path("skills/prototype/LOGIC.md").read_text()
ui = Path("skills/prototype/UI.md").read_text()
assert "exact commit" in logic and "not current product canon" in logic
assert "exact commit" in ui and "not current product canon" in ui

templates = Path("skills/chart/node-template.md").read_text()
assert templates.count("## Premises") >= 2, "map and node templates both need premise fields"
assert "**Derived from:**" in templates

research = Path("skills/research/SKILL.md").read_text()
assert "candidate answer" in research and "Only an admitted answer" in research
assert "write no project research/canon file" in research

deep = Path("skills/grill-deep/SKILL.md").read_text()
assert deep.count("Derived from:") >= 2 and "Source refs:" in deep

style = Path("output-styles/dag-house-style.md").read_text()
response = Path("RESPONSE-RULES.md").read_text()
assert "historical only" not in response
assert "Cheap and reversible does not authorize a write" in style
assert "A grill presents the whole" in style
assert "Ask and carry on rather than parking" not in style

print(f"  contract + {len(covered)} covered call sites checked")
PYAUTH

echo "== completion criteria use one format =="
grep -rn "Done when" skills/*/SKILL.md | grep -v '\*Done when' > "$tmp/criteria" || true
if [ -s "$tmp/criteria" ]; then
  while read -r l; do bad "off-format completion criterion: $l"; done < "$tmp/criteria"
else
  note "consistent"
fi

echo "== glossary terms are used =="
python3 - <<'PY' > "$tmp/orphans"
import re, pathlib
body = "\n".join(p.read_text() for p in pathlib.Path("skills").rglob("*.md")).lower()
for term in re.findall(r"^\*\*([^*]+)\*\* — ", pathlib.Path("GLOSSARY.md").read_text(), re.M):
    # a compound entry ("x vs y", "a / b") is used if any of its parts is
    parts = [p.strip().lower() for p in re.split(r" vs |/", term) if p.strip()]
    if not any(re.search(r"(?<!\w)%ss?(?!\w)" % re.escape(p), body) for p in parts):
        print(term)
PY
if [ -s "$tmp/orphans" ]; then
  while read -r t; do bad "orphan glossary term: $t"; done < "$tmp/orphans"
else
  note "all used"
fi

echo "== shared vocabulary is defined in the glossary =="
# A bolded term used across two or more skills is vocabulary, not emphasis — and vocabulary
# the glossary never defines reads as shared meaning while actually being one file's invention.
python3 - <<'PY2' > "$tmp/undefined"
import re, pathlib, collections

def norm(s):
    s = s.strip().lower().removeprefix("the ")
    return s.rstrip("s")

# GLOSSARY *is* the vocabulary file, so a term bolded anywhere in it counts as defined.
defined = set()
for m in re.findall(r"\*\*([^*]+)\*\*", pathlib.Path("GLOSSARY.md").read_text()):
    for part in re.split(r" vs |/", m):
        defined.add(norm(part))

where = collections.defaultdict(set)
for f in sorted(pathlib.Path("skills").rglob("*.md")):
    for term in set(re.findall(r"\*\*([a-z][a-z -]{2,24})\*\*", f.read_text())):
        where[norm(term)].add(f.parent.name)

EMPHASIS = {"bold", "not", "never", "always", "every", "all", "one", "now", "before", "after",
            "once", "only", "and", "or", "both", "each", "any", "no", "yes", "then", "first"}

for term, files in sorted(where.items()):
    if len(files) >= 2 and term not in defined and term not in EMPHASIS:
        print(f"{term}  (used in: {', '.join(sorted(files))})")
PY2
if [ -s "$tmp/undefined" ]; then
  while read -r l; do bad "shared term never defined: $l"; done < "$tmp/undefined"
else
  note "all defined"
fi

echo "== readiness labels are created on de-fog nodes, never edited onto existing ones =="
# /dag:plan closes a readiness-labelled issue the moment its move lands — that close is how the
# node behind it reaches the frontier. So adding one to a build node closes the build node,
# unbuilt and unproven. A de-fog node is *created* carrying its label (gh issue create --label).
# The one legitimate edit is moving a mislabelled label back onto its de-fog node, which is why
# the exemption is by placeholder name: say `defog` in the target when that is what you mean.
git ls-files -z -- '*.md' '*.mdx' | xargs -0 grep -n "issue edit.*--add-label dag:needs-" |
  grep -v "defog" > "$tmp/readiness" || true
if [ -s "$tmp/readiness" ]; then
  while read -r l; do bad "readiness label edited onto an existing issue: $l"; done < "$tmp/readiness"
else
  note "none"
fi

echo "== no vendor residue =="
if git ls-files -z -- '*.md' '*.mdx' '*.json' | xargs -0 grep -niE "capxul|posthog|convex|agentmail|openfort|hogql|xelmar|matt.?pocock" | grep -v '"email"' | grep -q .; then
  bad "vendor residue found"
else
  note "clean"
fi

echo
[ $fail -eq 0 ] && echo "PASS — tier 1 (mechanical) only." || echo "FAILED"
exit $fail
