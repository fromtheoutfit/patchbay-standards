#!/usr/bin/env bash
# The runnable half of the verification gate: steps 1-3 of the gate every spec in this
# repository ends with (.claude/commands/agent-os/shape-spec.md, Task N). Steps 4-6 are
# judgment, recorded in the spec's shape.md: Docs (the documentation the change touches reads
# true), Version (the change under [Unreleased] in CHANGELOG.md) and the standards
# retrospective per base/process/standards-retrospective.md; nothing here can run them. The
# shape of the gate is base/process/verification-gate.md's. CI runs this same script and nothing
# else (.github/workflows/gate.yml).
#
# Usage: scripts/gate.sh        (no arguments; any argument is usage, exit 2)
#
# Exit status: 0 when every step passed; 1 at the first step that fails, after a line
# "FAIL  step N/M: <reason>" on stderr naming it, whatever status the tool returned, so a
# failing step 1 is reported before step 2 has a chance to pass; 2 on usage.
#
# Step 1 parses every shell script under scripts/ as git lists them: the tracked files plus the
# untracked ones git does not ignore (the rule scripts/check-index.sh applies to base/), so an
# ignored stray such as .DS_Store is never seen and a script a spec adds before it is staged is. A
# file ending in .sh or starting with a bash shebang is parsed; any other file fails the step by
# name, since only shell scripts live under scripts/; a tracked file missing from the disk, and a
# tree that is not a git work tree, each fail by name.
#
# Step 1 needs bash and git. Step 2 needs uv (uvx) and, the first time, network access to fetch
# the pinned pymarkdown into the uv cache; uv is the one installer the patchbay packages use, so
# nothing else is assumed: no Node, no package.json. Step 3 needs git, comm, awk and sed. Nothing
# is installed to run the gate.
set -euo pipefail
cd "$(dirname "$0")/.."

if [ $# -ne 0 ]; then
  echo "usage: scripts/gate.sh   (no arguments; exits 1 at the first failing step, 2 on usage)" >&2
  exit 2
fi

# Pinned: pymarkdownlnt 0.9.41, published 2026-10-13. Bump deliberately, in the gate's own spec
# (base/process/verification-gate.md), and rerun the gate.
PYMARKDOWN_VERSION=0.9.41

step() { printf '\n== %s\n' "$1"; }
fail() { printf 'FAIL  step %s: %s\n' "$1" "$2" >&2; exit 1; }   # fail <step> <reason>

step "1/3  bash -n on every shell script under scripts/ (tracked or untracked, not ignored)"
git rev-parse --show-toplevel >/dev/null 2>&1 || fail 1/3 "not a git work tree; step 1 lists files with git ls-files"
n=0
while IFS= read -r -d '' f; do
  [ -e "$f" ] || fail 1/3 "$f is tracked but missing from the disk"
  case "$f" in
    *.sh) ;;
    *) head -n 1 "$f" | grep -Eq '^#!.*bash' || fail 1/3 "$f is not a shell script; only shell scripts live under scripts/" ;;
  esac
  bash -n "$f" || fail 1/3 "$f does not parse"
  echo "ok   $f"; n=$((n + 1))
done < <({ git -c core.quotePath=false ls-files -z -- scripts
           git -c core.quotePath=false ls-files -z --others --exclude-standard -- scripts; } | LC_ALL=C sort -zu)
[ "$n" -gt 0 ] || fail 1/3 "git lists no file under scripts/"

step "2/3  pymarkdown $PYMARKDOWN_VERSION over base/ and README.md (rules in .pymarkdown.yaml)"
uvx --from "pymarkdownlnt==$PYMARKDOWN_VERSION" pymarkdown \
  --strict-config --config .pymarkdown.yaml scan --recurse base README.md ||
  fail 2/3 "pymarkdown reported findings, or could not run (see above)"
echo "ok   no findings"

step "3/3  index.yml lists exactly the tracked files under base/"
scripts/check-index.sh ||
  fail 3/3 "index.yml and the tracked files under base/ disagree, or the index symlink is wrong (see above)"

printf '\nGate steps 1-3 passed. Steps 4-6 are judgment, recorded in shape.md: Docs, Version, the standards retrospective.\n'
