#!/usr/bin/env bash
# Mechanical checks for the dag suite. Run from the repo root: scripts/check.sh
# Tier 1 only — it proves the suite is internally consistent, never that it works.
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
note() { printf "  %s\n" "$1"; }
bad() { printf "  FAIL: %s\n" "$1"; fail=1; }
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

echo "== manifest =="
python3 -c "
import json,sys
m=json.load(open('.claude-plugin/plugin.json'))
for k in ('name','version','description'):
    assert m.get(k), 'manifest missing '+k
print('  valid JSON, name=%s version=%s' % (m['name'], m['version']))
" || bad "manifest invalid"

echo "== frontmatter =="
for f in skills/*/SKILL.md; do
  d=$(basename "$(dirname "$f")")
  n=$(awk -F': ' '/^name: /{print $2; exit}' "$f")
  [ "$n" = "$d" ] || bad "$f: name '$n' != directory '$d'"
  grep -q "^description: " "$f" || bad "$f: no description"
done
note "$(ls -1 skills/*/SKILL.md | wc -l | tr -d ' ') skills checked"

echo "== /dag: cross-references resolve =="
for s in $(grep -rhoE "/dag:[a-z-]+" --include="*.md" . | sort -u); do
  [ -f "skills/${s#/dag:}/SKILL.md" ] || bad "unresolved reference $s"
done
note "all resolve"

echo "== relative links resolve =="
# Matches ](path.md) and ](path.md#anchor); skips same-file anchors ](#x) and absolute URLs.
find . -name "*.md" -not -path "./.git/*" | while IFS= read -r f; do
  grep -oE "\]\([^)#:][^)#]*\.md(#[^)]*)?\)" "$f" | sed 's/^](//;s/)$//;s/#.*$//' | while read -r l; do
    [ -f "$(dirname "$f")/$l" ] || echo "$f -> $l"
  done
done > "$tmp/links"
if [ -s "$tmp/links" ]; then
  while read -r l; do bad "broken link $l"; done < "$tmp/links"
else
  note "checked"
fi

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

echo "== no vendor residue =="
if grep -rniE "capxul|posthog|convex|agentmail|openfort|hogql|xelmar|matt.?pocock" --include="*.md" --include="*.json" . | grep -v '"email"' | grep -q .; then
  bad "vendor residue found"
else
  note "clean"
fi

echo
[ $fail -eq 0 ] && echo "PASS — tier 1 (mechanical) only." || echo "FAILED"
exit $fail
