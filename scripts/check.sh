#!/usr/bin/env bash
# Mechanical checks for the dag suite. Run from the repo root: scripts/check.sh
# Rung 1 only — it proves the suite is internally consistent, never that it works.
set -uo pipefail
cd "$(dirname "$0")/.."
fail=0
note() { printf "  %s\n" "$1"; }
bad() { printf "  FAIL: %s\n" "$1"; fail=1; }

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
while IFS= read -r f; do
  grep -oE "\]\([^)#][^)]*\.md\)" "$f" | sed 's/](//;s/)//' | while read -r l; do
    [ -f "$(dirname "$f")/$l" ] || echo "  FAIL: $f -> $l"
  done
done < <(find . -name "*.md" -not -path "./.git/*") | tee /tmp/dag-links.txt
grep -q FAIL /tmp/dag-links.txt && fail=1
note "checked"

echo "== completion criteria use one format =="
if grep -rn "^[0-9]\+\..*[^*]Done when" skills/*/SKILL.md >/dev/null 2>&1; then
  bad "inline 'Done when' found — use the *Done when:* form"
else
  note "consistent"
fi

echo "== glossary terms are used =="
grep -oE '^\*\*[a-z][^*]+\*\*' GLOSSARY.md | sed 's/\*\*//g' | while read -r t; do
  # a compound entry ("x vs y", "a / b") is used if any of its parts is
  hit=0
  echo "$t" | tr '/' '\n' | sed 's/ vs /\n/g' | while read -r part; do
    part=$(echo "$part" | sed 's/^ *//;s/ *$//'); [ -z "$part" ] && continue
    grep -rqi -- "$part" skills/ && exit 7
  done; [ $? -eq 7 ] && hit=1
  [ $hit -eq 1 ] || echo "  orphan term: $t"
done

echo "== no vendor residue =="
if grep -rniE "capxul|posthog|convex|agentmail|openfort|hogql|xelmar|matt.?pocock" --include="*.md" --include="*.json" . | grep -vE "^\./?docs/" | grep -v '"email"' | grep -q .; then
  bad "vendor residue found"
else
  note "clean"
fi

echo
[ $fail -eq 0 ] && echo "PASS — rung 1 (mechanical) only." || echo "FAILED"
exit $fail
