#!/usr/bin/env bash
# The runnable half of the verification gate: steps 1-3 of the gate every spec in this
# repository ends with (.claude/commands/agent-os/shape-spec.md, Task N). Step 4, the
# standards retrospective, is judgment, recorded in the spec's shape.md per
# base/process/standards-retrospective.md; nothing here can run it.
#
# Usage: scripts/gate.sh        (exits non-zero on the first failing step)
#
# Step 2 needs uv (uvx) and, the first time, network access to fetch the pinned pymarkdown
# into the uv cache. uv is the one installer the patchbay packages use, so nothing else is
# assumed: no Node, no package.json.
set -euo pipefail
cd "$(dirname "$0")/.."

# Pinned: pymarkdownlnt 0.9.41, published 2026-10-13. Bump deliberately, outside a spec, and
# rerun the gate.
PYMARKDOWN_VERSION=0.9.41

step() { printf '\n== %s\n' "$1"; }

step "1/3  bash -n on every file under scripts/"
while IFS= read -r f; do
  bash -n "$f"
  echo "ok   $f"
done < <(find scripts -type f | LC_ALL=C sort)

step "2/3  pymarkdown $PYMARKDOWN_VERSION over base/ and README.md"
uvx --from "pymarkdownlnt==$PYMARKDOWN_VERSION" pymarkdown \
  --strict-config --config .pymarkdown.yaml scan --recurse base README.md
echo "ok   no findings"

step "3/3  index.yml lists exactly the files under base/"
scripts/check-index.sh

printf '\nGate steps 1-3 passed. Step 4 is the standards retrospective: record it in shape.md.\n'
