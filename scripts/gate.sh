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
# does not ignore, in one git ls-files -z call, each path once (a path in merge conflict is in the
# index once per stage), so an ignored stray such as .DS_Store is never seen and a file a spec adds
# before it is staged is. Each listing is written to a file in a temporary directory and git's own
# status checked, since neither a pipe nor a process substitution keeps it: a listing git could not
# make (a corrupt index) fails its step by name rather than reading as an empty one. Step 1 first
# refuses a tree whose work-tree top is not the repository root, a copy without .git inside another
# repository included, so no step lists files against an outer repository; it asks git whether
# this is inside a work tree (git rev-parse --is-inside-work-tree is true, which it is not in .git/
# or a bare repository, where --show-cdup is empty too) and whether it is the top (--show-cdup is
# empty), and compares no paths, since a path typed in another case, or spelled C:/ rather than
# /c/, names the same directory. Step 1 then refuses every tracked file a committed .gitignore
# matches under the paths the gate's listings read (git ls-files --cached --ignored
# --exclude-per-directory=.gitignore -- scripts base README.md: a file force-added, or added
# before its pattern), naming each under one FAIL line: git lists such a file though the
# repository says it is ignored, and a tool that reads .gitignore itself skips it. Only committed
# .gitignore files count, so every clone of a commit gets the same answer; .git/info/exclude and
# the global excludes file are the machine's, and a file no step reads never fails the gate. A
# listed path missing from the disk, or a symlink to nothing, fails its step by name. Step 1
# parses a file ending in .sh or starting with a bash shebang; any other file fails the step by
# name, since only shell scripts live under scripts/. Step 2 passes pymarkdown the .md files of
# its list rather than a directory to walk.
#
# Step 2 installs the pinned tool as its own check before the tool lints (the rule in
# base/process/verification-gate.md, "One script"): uvx missing from PATH, or a pin uvx cannot
# install (a version never published, no network the first time), fails the step by name as the
# install, never as a finding of pymarkdown's. uvx has no form that installs without running, so the
# check runs `pymarkdown version`, which checks nothing in the tree, and a pymarkdown that will not
# start fails there under the same reason; only then does pymarkdown lint, and its reason is about
# findings and the rule set it reads. The pinned invocation is built once and used by both calls.
# The pin lives here because this repository has no package manifest; uv's own version is pinned in
# CI only, as setup-uv's input.
#
# Step 1 needs bash, git and mktemp. Step 2 needs git, uv (uvx) and, the first time, network access to
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
git_list() { local out=$1; shift; git ls-files -z "$@" > "$out.raw" && LC_ALL=C sort -zu "$out.raw" > "$out"; }   # git_list <file> <ls-files args...>: git's list into <file>, NUL-separated, sorted, each path once; fails when git cannot list
listed() { local out=$1; shift; git_list "$out" --cached --others --exclude-standard -- "$@"; }   # listed <file> <path...>: what git lists under the paths, tracked or untracked not ignored
fail_list() {  # fail_list <step> <reason> <file>: fail the step naming every path in the NUL-separated file, each indented eight spaces
  local f
  printf 'FAIL  step %s: %s:\n' "$1" "$2" >&2
  while IFS= read -r -d '' f; do printf '        %s\n' "$f" >&2; done < "$3"
  exit 1
}
present() {  # present <step> <path>: fail the step unless the listed path is on the disk
  if [ -L "$2" ] && [ ! -e "$2" ]; then fail "$1" "$2 is a symlink to nothing"; fi
  [ -e "$2" ] || fail "$1" "$2 is tracked but missing from the disk"
}

step "1/3  bash -n on every shell script under scripts/ (tracked or untracked, not ignored), in a tree with no tracked file a .gitignore ignores"
root=$(pwd -P)
inside=$(git rev-parse --is-inside-work-tree 2>/dev/null) && [ "$inside" = true ] &&
  cdup=$(git rev-parse --show-cdup 2>/dev/null) && [ -z "$cdup" ] ||
  fail 1/3 "not a git work tree rooted at $root; the gate lists files with git ls-files"
tmp=$(mktemp -d) && [ -n "$tmp" ] && [ -d "$tmp" ] ||
  fail 1/3 "mktemp -d made no temporary directory for git's listings (see above)"
trap 'rm -rf "$tmp"' EXIT
git_list "$tmp/ignored" --cached --ignored --exclude-per-directory=.gitignore -- scripts base README.md ||
  fail 1/3 "git could not list the tracked files a .gitignore ignores (see above)"
if [ -s "$tmp/ignored" ]; then
  fail_list 1/3 "tracked, but a .gitignore ignores them; stop ignoring each (a ! pattern, and for a file under an ignored directory, ignore dir/* rather than dir/ first) or stop tracking it (git rm --cached)" "$tmp/ignored"
fi
listed "$tmp/scripts" scripts || fail 1/3 "git could not list the files under scripts/ (see above)"
n=0
while IFS= read -r -d '' f; do
  present 1/3 "$f"
  case "$f" in
    *.sh) ;;
    *) head -n 1 "$f" | grep -Eq '^#!.*bash' || fail 1/3 "$f is not a shell script; only shell scripts live under scripts/" ;;
  esac
  bash -n "$f" || fail 1/3 "$f does not parse"
  echo "ok   $f"; n=$((n + 1))
done < "$tmp/scripts"
[ "$n" -gt 0 ] || fail 1/3 "git lists no file under scripts/"

step "2/3  uvx installs pymarkdownlnt $PYMARKDOWN_VERSION, then pymarkdown lints the .md files under base/ and README.md as git lists them (rules in .pymarkdown.yaml)"
listed "$tmp/md" base README.md || fail 2/3 "git could not list the files under base/ and README.md (see above)"
md=()
while IFS= read -r -d '' f; do
  case "$f" in *.md) ;; *) continue ;; esac
  present 2/3 "$f"
  md+=("$f")
done < "$tmp/md"
[ "${#md[@]}" -gt 0 ] || fail 2/3 "git lists no .md file under base/ or README.md"
command -v uvx >/dev/null 2>&1 || fail 2/3 "uvx is not on PATH; step 2 runs the pinned pymarkdown through it"
pmd=(uvx --from "pymarkdownlnt==$PYMARKDOWN_VERSION" pymarkdown)   # the pinned invocation, for both calls
v=$("${pmd[@]}" version) ||
  fail 2/3 "uvx could not install pymarkdownlnt==$PYMARKDOWN_VERSION, the pinned version, or pymarkdown would not start (see above)"
echo "ok   pymarkdownlnt==$PYMARKDOWN_VERSION installed through uvx (pymarkdown version: $v)"
"${pmd[@]}" --strict-config --config .pymarkdown.yaml scan "${md[@]}" ||
  fail 2/3 "pymarkdown reported findings, or could not read .pymarkdown.yaml (see above)"
echo "ok   no findings in ${#md[@]} file(s)"

step "3/3  index.yml lists exactly the tracked files under base/"
scripts/check-index.sh ||
  fail 3/3 "index.yml and the tracked files under base/ disagree, or the index symlink is wrong (see above)"

printf '\nGate steps 1-3 passed. Steps 4-6 are judgment, recorded in shape.md: Docs, Version, the standards retrospective.\n'
