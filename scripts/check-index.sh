#!/usr/bin/env bash
# Gate step 3: index.yml lists exactly the files under base/.
#
#   - every tracked file under base/ has an entry under `base:` (base/<path>.md => "<path>:")
#   - no entry under `base:` lacks a tracked file
#   - every tracked file under base/ is a .md (base/ holds standards and nothing else)
#   - agent-os/standards/index.yml is a symlink to ../../index.yml (see
#     base/process/standards-index.md for how the two relate)
#
# "Tracked" is git ls-files: an untracked .DS_Store is not refused, and a standard that was
# never git-added does not pass here and merge with a dangling index entry.
#
# Usage: scripts/check-index.sh   (exit 0 when all hold; each failure is named)
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

git ls-files -- base | LC_ALL=C sort > "$tmp/files"
if grep -v '\.md$' "$tmp/files" > "$tmp/not-md"; then
  echo "FAIL  not a standard (only .md files belong under base/):"
  sed 's/^/        /' "$tmp/not-md"
  fail=1
fi
sed -n -e 's#^base/##' -e 's#\.md$##p' "$tmp/files" > "$tmp/expected"

# Entries are the two-space-indented keys of the `base:` section.
awk '
  /^base:[[:space:]]*$/        { inbase = 1; next }
  /^[^[:space:]#]/             { inbase = 0 }
  inbase && /^  [^[:space:]#]/ { sub(/^  /, ""); sub(/:[[:space:]]*$/, ""); print }
' index.yml | LC_ALL=C sort > "$tmp/listed"

# comm must collate as the sorts above did, or a C-sorted list reads as unsorted under a UTF-8
# locale and every line is reported as missing.
if LC_ALL=C comm -23 "$tmp/expected" "$tmp/listed" > "$tmp/missing" && [ -s "$tmp/missing" ]; then
  echo "FAIL  tracked under base/ but not in index.yml:"
  sed 's/^/        /' "$tmp/missing"
  fail=1
fi
if LC_ALL=C comm -13 "$tmp/expected" "$tmp/listed" > "$tmp/stale" && [ -s "$tmp/stale" ]; then
  echo "FAIL  in index.yml but not tracked under base/:"
  sed 's/^/        /' "$tmp/stale"
  fail=1
fi
# The project index is the root index, reached through a symlink: one file to edit, nothing to
# keep equal. A regular file is refused even when its bytes match.
link=agent-os/standards/index.yml
if [ -L "$link" ] && [ "$(readlink "$link")" = ../../index.yml ]; then
  :
else
  if [ -L "$link" ]; then found="a symlink to $(readlink "$link")"
  elif [ -e "$link" ]; then found="a regular file"
  else found="missing"; fi
  echo "FAIL  $link is not a symlink to ../../index.yml (found: $found)"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "ok   index.yml and base/ agree ($(wc -l < "$tmp/expected" | tr -d ' ') standard(s))"
fi
exit "$fail"
