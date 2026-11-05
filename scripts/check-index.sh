#!/usr/bin/env bash
# Gate step 3: index.yml lists exactly the tracked files under base/.
#
#   - every tracked file under base/ has an entry under `base:` (base/<path>.md => "<path>:")
#   - no entry under `base:` lacks a tracked file
#   - every tracked file under base/ is a .md (base/ holds standards and nothing else)
#   - nothing under base/ is untracked (a standard never git-added is reported, not passed), and
#     no tracked file is missing from the disk (a deletion not yet staged is reported)
#   - agent-os/standards/index.yml is a symlink to ../../index.yml (see
#     base/process/standards-index.md for how the two relate)
#
# "Tracked" is git ls-files, so this runs only in a git work tree whose top is the repository
# root, and says so when it is not in one. An ignored stray such as .DS_Store is neither tracked
# nor reported. Every list is sorted after its last transform, and both lists are checked sorted
# before comm compares them, so comm's own exit is never mistaken for "nothing missing".
#
# Usage: scripts/check-index.sh   (exit 0 when all hold; each failure is named)
set -euo pipefail
export LC_ALL=C   # one collation for every sort and comm below
cd "$(dirname "$0")/.."

fail=0
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

root=$(pwd -P)
if ! top=$(git rev-parse --show-toplevel 2>/dev/null) || [ "$top" != "$root" ]; then
  echo "FAIL  not a git work tree rooted at $root" \
       "(the files under base/ are read with git ls-files)"
  exit 1
fi

git -c core.quotePath=false ls-files -- base | sort > "$tmp/files"
git -c core.quotePath=false ls-files --others --exclude-standard -- base | sort > "$tmp/untracked"
if [ -s "$tmp/untracked" ]; then
  echo "FAIL  under base/ but not tracked (git add it, or keep it out of base/):"
  sed 's/^/        /' "$tmp/untracked"
  fail=1
fi
while IFS= read -r f; do [ -e "$f" ] || echo "$f"; done < "$tmp/files" > "$tmp/gone"
if [ -s "$tmp/gone" ]; then
  echo "FAIL  tracked but missing on disk (stage the deletion, or restore the file):"
  sed 's/^/        /' "$tmp/gone"
  fail=1
fi
if grep -v '\.md$' "$tmp/files" > "$tmp/not-md"; then
  echo "FAIL  not a standard (only .md files belong under base/):"
  sed 's/^/        /' "$tmp/not-md"
  fail=1
fi
sed -n -e 's#^base/##' -e 's#\.md$##p' "$tmp/files" | sort > "$tmp/expected"

# Entries are the two-space-indented keys of the `base:` section.
awk '
  /^base:[[:space:]]*$/        { inbase = 1; next }
  /^[^[:space:]#]/             { inbase = 0 }
  inbase && /^  [^[:space:]#]/ { sub(/^  /, ""); sub(/:[[:space:]]*$/, ""); print }
' index.yml | sort > "$tmp/listed"

for list in expected listed; do
  if ! sort -c "$tmp/$list" 2>/dev/null; then
    echo "FAIL  internal: the $list list is not sorted; comm would misreport"
    exit 1
  fi
done
if ! comm -23 "$tmp/expected" "$tmp/listed" > "$tmp/missing" ||
   ! comm -13 "$tmp/expected" "$tmp/listed" > "$tmp/stale"; then
  echo "FAIL  internal: comm could not compare the lists"
  exit 1
fi
if [ -s "$tmp/missing" ]; then
  echo "FAIL  tracked under base/ but not in index.yml:"
  sed 's/^/        /' "$tmp/missing"
  fail=1
fi
if [ -s "$tmp/stale" ]; then
  echo "FAIL  in index.yml but not tracked under base/:"
  sed 's/^/        /' "$tmp/stale"
  fail=1
fi

# The project index is the root index, reached through a symlink: one file to edit, nothing to
# keep equal. Anything else at that path is refused by what it is, a regular file included.
link=agent-os/standards/index.yml
target=$(readlink "$link" 2>/dev/null || true)
if ! { [ -L "$link" ] && [ "$target" = ../../index.yml ]; }; then
  if [ -L "$link" ]; then found="a symlink to $target"
  elif [ -d "$link" ]; then found="a directory"
  elif [ -e "$link" ]; then found="a regular file"
  else found="missing"; fi
  echo "FAIL  $link is not a symlink to ../../index.yml (found: $found)"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  n=$(wc -l < "$tmp/expected" | tr -d ' ')
  echo "ok   index.yml and the tracked files under base/ agree ($n standard(s))"
fi
exit "$fail"
