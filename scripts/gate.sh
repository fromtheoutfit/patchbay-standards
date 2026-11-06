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
# failing step 1 is reported before step 2 has a chance to pass; 2 on usage, or when the
# repository root cannot be entered, each said on stderr with no step run.
#
# A step that reads files from the tree reads the files git lists (the rule in
# base/process/verification-gate.md, "One script"): the tracked files plus the untracked ones git
# does not ignore, in one git ls-files -z call, so an ignored stray such as .DS_Store is never
# seen and a file a spec adds before it is staged is. Step 1 first refuses a tree whose work-tree
# top is not the repository root, a copy without .git inside another repository included, so no
# step lists files against an outer repository; a listed path missing from the disk, or a
# symlink to nothing, fails its step by name. Step 1 parses a file ending in .sh or starting with
# a bash shebang; any other file fails the step by name, since only shell scripts live under
# scripts/. Step 2 passes pymarkdown the .md files of its list rather than a directory to walk.
#
# Step 2 installs the pinned tool as its own check before the tool runs (the rule in
# base/process/verification-gate.md, "One script"): uvx missing from PATH, or a pin uvx cannot
# install (a version never published, no network the first time), fails the step by name as the
# install, never as a finding of pymarkdown's; only then does pymarkdown lint, and its reason is
# about findings and the rule set it reads. The pin lives here because this repository has no
# package manifest; uv's own version is pinned in CI only, as setup-uv's input.
#
# Step 1 needs bash and git. Step 2 needs git, uv (uvx) and, the first time, network access to
# fetch the pinned pymarkdown into the uv cache; uv is the one installer the patchbay packages
# use, so nothing else is assumed: no Node, no package.json. Step 3 needs git, comm, awk and sed.
# Nothing is installed to run the gate but the pinned pymarkdown, which uvx keeps in the uv cache,
# outside the repository and the project.
set -euo pipefail
cd "$(dirname "$0")/.." || { echo "gate: cannot enter the repository root, $(dirname "$0")/..; not run as the gate" >&2; exit 2; }

if [ $# -ne 0 ]; then
  echo "usage: scripts/gate.sh   (no arguments; exits 1 at the first failing step, 2 on usage)" >&2
  exit 2
fi

# Pinned: pymarkdownlnt 0.9.41, published 2026-10-13. Bump deliberately, in the gate's own spec
# (base/process/verification-gate.md), and rerun the gate.
PYMARKDOWN_VERSION=0.9.41

step() { printf '\n== %s\n' "$1"; }
fail() { printf 'FAIL  step %s: %s\n' "$1" "$2" >&2; exit 1; }   # fail <step> <reason>
listed() { git ls-files -z --cached --others --exclude-standard -- "$@" | LC_ALL=C sort -z; }   # listed <path...>: what git lists, NUL-separated, sorted
present() {  # present <step> <path>: fail the step unless the listed path is on the disk
  if [ -L "$2" ] && [ ! -e "$2" ]; then fail "$1" "$2 is a symlink to nothing"; fi
  [ -e "$2" ] || fail "$1" "$2 is tracked but missing from the disk"
}

step "1/3  bash -n on every shell script under scripts/ (tracked or untracked, not ignored)"
root=$(pwd -P)
top=$(git rev-parse --show-toplevel 2>/dev/null) && [ "$top" = "$root" ] ||
  fail 1/3 "not a git work tree rooted at $root; the gate lists files with git ls-files"
n=0
while IFS= read -r -d '' f; do
  present 1/3 "$f"
  case "$f" in
    *.sh) ;;
    *) head -n 1 "$f" | grep -Eq '^#!.*bash' || fail 1/3 "$f is not a shell script; only shell scripts live under scripts/" ;;
  esac
  bash -n "$f" || fail 1/3 "$f does not parse"
  echo "ok   $f"; n=$((n + 1))
done < <(listed scripts)
[ "$n" -gt 0 ] || fail 1/3 "git lists no file under scripts/"

step "2/3  uvx installs pymarkdownlnt $PYMARKDOWN_VERSION, then pymarkdown lints the .md files under base/ and README.md as git lists them (rules in .pymarkdown.yaml)"
md=()
while IFS= read -r -d '' f; do
  case "$f" in *.md) ;; *) continue ;; esac
  present 2/3 "$f"
  md+=("$f")
done < <(listed base README.md)
[ "${#md[@]}" -gt 0 ] || fail 2/3 "git lists no .md file under base/ or README.md"
command -v uvx >/dev/null 2>&1 || fail 2/3 "uvx is not on PATH; step 2 runs the pinned pymarkdown through it"
v=$(uvx --from "pymarkdownlnt==$PYMARKDOWN_VERSION" pymarkdown version) ||
  fail 2/3 "uvx could not install pymarkdownlnt==$PYMARKDOWN_VERSION, the pinned version (see above)"
echo "ok   pymarkdownlnt==$PYMARKDOWN_VERSION installed through uvx (pymarkdown version: $v)"
uvx --from "pymarkdownlnt==$PYMARKDOWN_VERSION" pymarkdown \
  --strict-config --config .pymarkdown.yaml scan "${md[@]}" ||
  fail 2/3 "pymarkdown reported findings, or could not read .pymarkdown.yaml (see above)"
echo "ok   no findings in ${#md[@]} file(s)"

step "3/3  index.yml lists exactly the tracked files under base/"
scripts/check-index.sh ||
  fail 3/3 "index.yml and the tracked files under base/ disagree, or the index symlink is wrong (see above)"

printf '\nGate steps 1-3 passed. Steps 4-6 are judgment, recorded in shape.md: Docs, Version, the standards retrospective.\n'
