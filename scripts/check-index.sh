#!/usr/bin/env bash
# Gate step 3: index.yml lists exactly the files under base/.
#
#   - every file under base/ has an entry under `base:` (base/<path>.md => "<path>:")
#   - no entry under `base:` lacks a file
#   - every file under base/ is a .md (base/ holds standards and nothing else)
#   - agent-os/standards/index.yml is identical to index.yml (see the header of index.yml
#     for how the two relate)
#
# Usage: scripts/check-index.sh   (exit 0 when all hold; each failure is named)
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

find base -type f | LC_ALL=C sort > "$tmp/files"
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

if comm -23 "$tmp/expected" "$tmp/listed" > "$tmp/missing" && [ -s "$tmp/missing" ]; then
  echo "FAIL  under base/ but not in index.yml:"
  sed 's/^/        /' "$tmp/missing"
  fail=1
fi
if comm -13 "$tmp/expected" "$tmp/listed" > "$tmp/stale" && [ -s "$tmp/stale" ]; then
  echo "FAIL  in index.yml but not under base/:"
  sed 's/^/        /' "$tmp/stale"
  fail=1
fi
if ! cmp -s index.yml agent-os/standards/index.yml; then
  echo "FAIL  agent-os/standards/index.yml differs from index.yml (they are the same file by rule):"
  diff index.yml agent-os/standards/index.yml | sed 's/^/        /' || true
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "ok   index.yml and base/ agree ($(wc -l < "$tmp/expected" | tr -d ' ') standard(s))"
fi
exit "$fail"
