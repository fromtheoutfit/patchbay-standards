#!/usr/bin/env bash
# Negative tests of the verification gate (base/process/verification-gate.md, "Every step that
# can fail is proven to fail"). Not run by scripts/gate.sh; gate step 1 parses this file. Each
# test copies the gate's files into a fresh temporary directory, git-inits and git-adds the copy
# so git ls-files sees it, breaks it in one way, and must fail with the named reason and exit
# status, the steps after it never reached; the positive cases beside them must pass. Nothing in
# the tree is touched. The transcript of a run is kept in the spec's verification/ folder as
# gate-negative-tests.txt (every test but j) and ci-negative-test.txt (j, the CI replay).
#
# Tests o to v are scripts/sync-standards.sh's (base/process/standards-sync.md), a gate file in
# every consuming project: each builds a scratch patchbay-standards checkout whose HEAD commit holds
# the working tree's files (mk_upstream) beside a scratch consuming project, an Agent OS install
# with its own index sections and two local standards (mk_project), and runs the sync from the
# project as a project would, the sibling checkout as the default path.
#
# Usage: scripts/gate-negative-tests.sh [test ...]   (default: every test but j; "all" adds j)
#   tests: a b c1 c2 c3 d e f g h i k l m n o p q r s t u v j
# Needs git and uv (j reads the workflow with pyyaml, through uv run --with, installing nothing).
# g, k and l also run a script from history (git show <sha>:scripts/check-index.sh) to show the
# bug they guard against as it was; that part is skipped where the commit is absent, and k's
# GNU comm case where gcomm (coreutils) is absent.
set -uo pipefail
cd "$(dirname "$0")/.."
REPO=$(pwd -P)
NEG=$(cd "$(mktemp -d)" && pwd -P)   # physical, as the scripts print it
trap 'rm -rf "$NEG"' EXIT

mk() {  # mk <name>: a copy of the gate's files, git-added so git ls-files sees it
  d="$NEG/$1"; rm -rf "$d"; mkdir -p "$d/agent-os/standards"
  cp -R base scripts "$d/"
  cp index.yml .pymarkdown.yaml README.md .gitignore "$d/"
  cp -R agent-os/standards/base agent-os/standards/index.yml "$d/agent-os/standards/"
  git -c init.defaultBranch=main -C "$d" init -q && git -C "$d" add -A
}
run() {  # run <name> <cmd...>: run in the copy, print its output and exit status
  ( cd "$NEG/$1" && shift && "$@" ) 2>&1 | sed "s#$NEG/\([a-z0-9]*\)#<copy \1>#g"
  echo "exit=${PIPESTATUS[0]}"
}
hdr() { printf '\n### %s\n' "$1"; }
note() { printf -- '-- %s\n' "$1"; }
commit() {  # commit <dir> <message>: in $NEG/<dir>, with a fixed identity and no signing
  git -c user.name=test -c user.email=test@example.invalid -c commit.gpgsign=false \
    -C "$NEG/$1" commit -q --allow-empty -m "$2"
}
mk_upstream() {  # mk_upstream <dir>: a patchbay-standards checkout whose HEAD holds the working tree's files
  d="$NEG/$1"; rm -rf "$d"; mkdir -p "$d/agent-os"
  cp -R base scripts "$d/"; cp index.yml .pymarkdown.yaml README.md .gitignore "$d/"
  cp -R agent-os/standards "$d/agent-os/"
  git -c init.defaultBranch=main -C "$d" init -q && git -C "$d" add -A && commit "$1" "the working tree"
}
mk_project() {  # mk_project <dir>: a consuming project before its first sync, an Agent OS install
  d="$NEG/$1"; rm -rf "$d"; mkdir -p "$d/agent-os/standards/testing" "$d/agent-os/specs"
  printf '[project]\nname = "scratch"\nversion = "0.1.0"\n' > "$d/pyproject.toml"
  printf '# scratch\n\n## Ownership\n\nThe owner owns every commit.\n' > "$d/CLAUDE.md"
  printf '.DS_Store\n.venv/\n' > "$d/.gitignore"
  printf '# Coding style\n\nFour-space indent, one import per line.\n' > "$d/agent-os/standards/coding-style.md"
  printf '# Fixtures\n\nEvery adapter builds its fake device from the shared fixture.\n' > "$d/agent-os/standards/testing/fixtures.md"
  cat > "$d/agent-os/standards/index.yml" <<'YML'
# scratch: the standards index. Own sections are edited by hand; base: is synced.
root:
  coding-style:
    description: Four-space indent and one import per line

# project standards below
testing:
  fixtures:
    description: Every adapter builds its fake device from the shared fixture
# end of index
YML
  git -c init.defaultBranch=main -C "$d" init -q && git -C "$d" add -A && commit "$1" "an Agent OS install"
}
expected_index() {  # expected_index <upstream dir>: mk_project's index after --init, built by hand (sed, not the script's awk)
  cat <<'YML'
# scratch: the standards index. Own sections are edited by hand; base: is synced.
root:
  coding-style:
    description: Four-space indent and one import per line

YML
  sed -n '/^base:/,$p' "$NEG/$1/index.yml"
  cat <<'YML'

# project standards below
testing:
  fixtures:
    description: Every adapter builds its fake device from the shared fixture
# end of index
YML
}
first_sync() {  # first_sync <test>: $NEG/<test>/project synced from its sibling checkout with --init, quietly, and committed
  ( cd "$NEG/$1/project" && ../patchbay-standards/scripts/sync-standards.sh --init >/dev/null 2>&1 ) ||
    { echo "first sync of $1/project failed"; return 1; }
  git -C "$NEG/$1/project" add -A && commit "$1/project" "chore: sync base standards"
}
old_script() {  # old_script <name> <sha>: scripts/check-index-<sha>.sh in the copy, or return 1
  if git cat-file -e "$2:scripts/check-index.sh" 2>/dev/null; then
    git show "$2:scripts/check-index.sh" > "$NEG/$1/scripts/check-index-$2.sh"
    chmod +x "$NEG/$1/scripts/check-index-$2.sh"
  else
    note "commit $2 is not in this clone; its script is not shown"; return 1
  fi
}

tests=("$@")
[ "${#tests[@]}" -eq 0 ] && tests=(a b c1 c2 c3 d e f g h i k l m n o p q r s t u v)
[ "${tests[*]}" = all ] && tests=(a b c1 c2 c3 d e f g h i k l m n o p q r s t u v j)

for t in "${tests[@]}"; do case "$t" in
a) hdr "a (tracked file under base/ with no index entry; check-index.sh must fail)"
   mk a; cp "$NEG/a/base/process/ownership.md" "$NEG/a/base/process/orphan.md"; git -C "$NEG/a" add -A
   run a scripts/check-index.sh ;;
b) hdr "b (index entry with no file; check-index.sh must fail)"
   mk b; printf '  python/nothing-here:\n    description: no file\n' >> "$NEG/b/index.yml"
   run b scripts/check-index.sh ;;
c1) hdr "c1 (agent-os/standards/index.yml a regular file byte-identical to index.yml; check-index.sh must fail)"
   mk c1; rm "$NEG/c1/agent-os/standards/index.yml"; cp "$NEG/c1/index.yml" "$NEG/c1/agent-os/standards/index.yml"
   note "cmp shows the bytes match (exit 0), so a byte comparison would have passed:"
   run c1 cmp index.yml agent-os/standards/index.yml
   run c1 scripts/check-index.sh ;;
c2) hdr "c2 (agent-os/standards/index.yml a symlink to another file; check-index.sh must fail)"
   mk c2; rm "$NEG/c2/agent-os/standards/index.yml"; ln -s ../../README.md "$NEG/c2/agent-os/standards/index.yml"
   run c2 scripts/check-index.sh ;;
c3) hdr "c3 (agent-os/standards/index.yml a directory; check-index.sh must fail and say so)"
   mk c3; rm "$NEG/c3/agent-os/standards/index.yml"; mkdir "$NEG/c3/agent-os/standards/index.yml"
   run c3 scripts/check-index.sh ;;
d) hdr "d (tracked non-.md file under base/; check-index.sh must fail)"
   mk d; echo note > "$NEG/d/base/notes.txt"; git -C "$NEG/d" add -A
   run d scripts/check-index.sh ;;
e) hdr "e (lint finding: gate.sh must stop at step 2, never reach 3/3)"
   mk e; printf '# bad\ntext right under the heading with a trailing space \n' > "$NEG/e/base/process/bad.md"
   run e scripts/gate.sh ;;
f) hdr "f (unparsable script: gate.sh must stop at step 1)"
   mk f; printf '#!/usr/bin/env bash\nif true; then\n' > "$NEG/f/scripts/broken.sh"
   run f scripts/gate.sh ;;
g) hdr "g (comm collation: C-sorted lists with process/B's entry missing, under LANG=en_US.UTF-8; must name process/B alone)"
   mk g; rm "$NEG/g/base/process/"*.md
   for n in B a_z ab; do printf '# %s\n\nA standard.\n' "$n" > "$NEG/g/base/process/$n.md"; done
   printf 'base:\n  process/a_z:\n    description: two\n  process/ab:\n    description: three\n' > "$NEG/g/index.yml"
   git -C "$NEG/g" add -A
   if old_script g aaacc57; then
     note "the script at aaacc57 (before issue #3), LANG=en_US.UTF-8 and LC_ALL unset: the bug, every entry reported missing and the indexed ones stale:"
     run g env -u LC_ALL LANG=en_US.UTF-8 scripts/check-index-aaacc57.sh
   fi
   note "shipped script, same environment (must name process/B alone):"
   run g env -u LC_ALL LANG=en_US.UTF-8 scripts/check-index.sh
   printf 'base:\n  process/B:\n    description: one\n  process/a_z:\n    description: two\n  process/ab:\n    description: three\n' > "$NEG/g/index.yml"
   note "shipped script, all three indexed, LANG=en_US.UTF-8 (must pass):"
   run g env -u LC_ALL LANG=en_US.UTF-8 scripts/check-index.sh ;;
h) hdr "h (tracked files are git ls-files: an ignored stray passes, an untracked standard is refused)"
   mk h; touch "$NEG/h/base/.DS_Store"
   note "untracked, ignored base/.DS_Store present (must pass):"
   run h git status --short --ignored base
   run h scripts/check-index.sh
   printf '# New\n\nA standard never git-added.\n' > "$NEG/h/base/process/new.md"
   note "untracked base/process/new.md with no index entry (must fail: under base/ but not tracked):"
   run h git status --short base
   run h scripts/check-index.sh
   printf '  process/new:\n    description: never added\n' >> "$NEG/h/index.yml"
   note "the same file with its index entry (must fail: not tracked, and the entry has no tracked file):"
   run h scripts/check-index.sh ;;
i) hdr "i (.pymarkdown.yaml is read: md013 line lengths 60 in the copy; gate.sh must stop at step 2 on MD013, 3/3 never reached)"
   mk i; sed -i.bak 's/line_length: 120/line_length: 60/' "$NEG/i/.pymarkdown.yaml"; rm "$NEG/i/.pymarkdown.yaml.bak"
   grep -n 'line_length' "$NEG/i/.pymarkdown.yaml"
   ( cd "$NEG/i" && scripts/gate.sh > ../i.out 2>&1 ); echo "exit=$?" > "$NEG/i.exit"
   grep -v 'MD013' "$NEG/i.out" | grep -v '^$'
   echo "   ... $(grep -c MD013 "$NEG/i.out") MD013 findings, Expected: 60, the first three:"
   grep MD013 "$NEG/i.out" | head -3 | sed "s#$NEG/i/##"; cat "$NEG/i.exit"
   note "the same copy with the key misspelled (line_lenght: 60): --strict-config does not refuse an unknown key, so the default 80 applies with no config error; in this tree, wrapped at 100, that still fails step 2 (Expected: 80), so the misspelling cannot pass here silently:"
   sed -i.bak 's/^    line_length: 60/    line_lenght: 60/' "$NEG/i/.pymarkdown.yaml"; rm "$NEG/i/.pymarkdown.yaml.bak"
   grep -n 'line_len' "$NEG/i/.pymarkdown.yaml"
   ( cd "$NEG/i" && uvx --from "pymarkdownlnt==$(sed -n 's/^PYMARKDOWN_VERSION=//p' scripts/gate.sh)" pymarkdown --strict-config --config .pymarkdown.yaml scan --recurse base README.md > ../i2.out 2>&1 ); echo "exit=$?" > "$NEG/i2.exit"
   echo "   ... $(grep -c MD013 "$NEG/i2.out") MD013 findings, Expected: 80, the first one:"
   grep MD013 "$NEG/i2.out" | head -1 | sed "s#$NEG/i/##"; cat "$NEG/i2.exit" ;;
k) hdr "k (a key that is a prefix of another, testing and testing-fakes: the stripped list must be re-sorted before comm)"
   mk k; printf '# T\n\nA standard.\n' > "$NEG/k/base/process/testing.md"; printf '# TF\n\nA standard.\n' > "$NEG/k/base/process/testing-fakes.md"
   printf '  process/testing:\n    description: t\n  process/testing-fakes:\n    description: tf\n' >> "$NEG/k/index.yml"
   git -C "$NEG/k" add -A
   note "both indexed (must pass):"
   run k scripts/check-index.sh
   printf '# Z\n\nA standard.\n' > "$NEG/k/base/process/zeta.md"; git -C "$NEG/k" add -A
   note "zeta.md tracked beside them with no entry (must fail naming process/zeta alone):"
   run k scripts/check-index.sh
   if old_script k cf1bdf0; then
     note "the script at cf1bdf0 (PR 7's first head), BSD comm: testing misreported as both missing and stale:"
     run k scripts/check-index-cf1bdf0.sh
     if command -v gcomm >/dev/null; then
       mkdir -p "$NEG/gnu"; ln -sf "$(command -v gcomm)" "$NEG/gnu/comm"
       note "the same script with GNU comm first on PATH (the ubuntu runner): comm exits 1 on unsorted input, the script reads that as nothing missing, and zeta passes unindexed:"
       run k env PATH="$NEG/gnu:$PATH" scripts/check-index-cf1bdf0.sh
       note "shipped script with GNU comm first on PATH (must fail naming process/zeta alone):"
       run k env PATH="$NEG/gnu:$PATH" scripts/check-index.sh
     fi
   fi ;;
l) hdr "l (a non-ASCII path, base/process/café.md, tracked and indexed; must pass)"
   mk l; printf '# Café\n\nA standard.\n' > "$NEG/l/base/process/café.md"
   printf '  process/café:\n    description: accent\n' >> "$NEG/l/index.yml"; git -C "$NEG/l" add -A
   run l scripts/check-index.sh
   if old_script l cf1bdf0; then
     note "the script at cf1bdf0 read the path C-quoted and refused it:"
     run l scripts/check-index-cf1bdf0.sh
   fi ;;
m) hdr "m (a copy that is not a git work tree; check-index.sh must fail by name, not with a bare exit)"
   mk m; rm -rf "$NEG/m/.git"
   run m scripts/check-index.sh ;;
n) hdr "n (a tracked standard deleted from disk, deletion not staged; check-index.sh must fail)"
   mk n; rm "$NEG/n/base/process/ownership.md"
   run n git status --short base
   run n scripts/check-index.sh ;;
j) hdr "j (CI replay: the run steps of .github/workflows/gate.yml, in order, on a clean copy and on a copy with a broken script)"
   cat <<'TXT'
The workflow is not run on a hosting service here. The job's steps are read from the workflow file
and the run steps executed in order in a copy of the tree, each under the shell GitHub gives a run
step on ubuntu (bash --noprofile --norc -eo pipefail). GitHub's rule: a step that exits non-zero
fails the job unless continue-on-error is set, and this job sets nothing. This replays the job's
control flow on this machine's toolchain; it is not the ubuntu run. The hosted run on the pull
request is the proof of the workflow itself, recorded by run id and conclusion in the spec's
verification/ once it exists. The two uses steps are checkout, which the copy stands in for, and
setup-uv pinned to a version; the uv on PATH here is shown.
TXT
   echo "uv on PATH: $(uv --version)"
   mk j1; mk j2; printf '#!/usr/bin/env bash\nif true; then\n' > "$NEG/j2/scripts/broken.sh"
   replay() {
     uv run --quiet --no-project --with pyyaml python - "$NEG/$1" .github/workflows/gate.yml <<'PY' 2>&1 | sed "s#$NEG/\([a-z0-9]*\)#<copy \1>#g"
import subprocess, sys, yaml
tree, wf = sys.argv[1], sys.argv[2]
w = yaml.safe_load(open(wf)); on = w[True] if True in w else w["on"]; job = w["jobs"]["gate"]
print(f"job: gate  runs-on: {job['runs-on']}  timeout-minutes: {job.get('timeout-minutes')}  on: {on}")
for i, s in enumerate(job["steps"], 1):
    if "uses" in s:
        print(f"step {i}: uses {s['uses']}  with {s.get('with', {})}  (not run here)"); continue
    print(f"step {i}: run {s['run']}")
    r = subprocess.run(["bash", "--noprofile", "--norc", "-eo", "pipefail", "-c", s["run"]], cwd=tree)
    print(f"step {i} exit={r.returncode}")
    if r.returncode:
        print(f"job: FAILED at step {i} (a run step that exits non-zero fails the job)"); sys.exit(r.returncode)
print("job: passed")
PY
     echo "exit=${PIPESTATUS[0]}"
   }
   note "j1, clean copy (the job must pass):"; replay j1
   note "j2, scripts/broken.sh added as in test f (gate.sh fails at step 1, so the job must fail):"; replay j2 ;;
o) hdr "o (first sync of a consuming project: refused without --init; the sibling default; --init creates the base: section, pins the commit, installs the script)"
   mk_upstream o/patchbay-standards; mk_project o/project
   note "no base: section and no --init (must fail, exit 2, nothing written):"
   run o/project ../patchbay-standards/scripts/sync-standards.sh
   run o/project git status --short
   note "no sibling checkout: the same project copied elsewhere, --init from the checkout's copy (must fail naming ../patchbay-standards, exit 2):"
   mkdir "$NEG/o/elsewhere"; cp -R "$NEG/o/project" "$NEG/o/elsewhere/project"
   run o/elsewhere/project "$NEG/o/patchbay-standards/scripts/sync-standards.sh" --init
   note "--init from the sibling checkout, the default path (must pass):"
   run o/project ../patchbay-standards/scripts/sync-standards.sh --init
   note "the pinned commit is the checkout's HEAD:"
   run o/project cat agent-os/standards/base/.version
   run o/patchbay-standards git rev-parse HEAD
   note "the index is the hand-built expected one, own sections byte for byte (cmp must pass); base/ is the commit's base/ plus .version; the script is the commit's:"
   expected_index o/patchbay-standards > "$NEG/o/expected.yml"
   run o/project cmp agent-os/standards/index.yml ../expected.yml
   run o/project diff -r -x .version ../patchbay-standards/base agent-os/standards/base
   run o/project cmp scripts/sync-standards.sh ../patchbay-standards/scripts/sync-standards.sh
   run o/project git status --short ;;
p) hdr "p (a working-tree edit in the checkout is not synced; a committed addition is)"
   mk_upstream p/patchbay-standards; mk_project p/project; first_sync p
   printf '\nAn uncommitted edit.\n' >> "$NEG/p/patchbay-standards/base/process/ownership.md"
   run p/patchbay-standards git status --short
   git -C "$NEG/p/patchbay-standards" show HEAD:base/process/ownership.md > "$NEG/p/committed.md"
   note "sync with the edit uncommitted (must pass with nothing added, removed or changed; the project's file stays the committed bytes):"
   run p/project scripts/sync-standards.sh
   run p/project cmp agent-os/standards/base/process/ownership.md ../committed.md
   run p/project git status --short
   note "the edit committed together with base/process/new.md and its entry (must pass: new.md added, ownership.md changed, index replaced with 5 entries):"
   printf '# New\n\nA standard.\n' > "$NEG/p/patchbay-standards/base/process/new.md"
   awk '/^  process\/ownership:/ { print "  process/new:"; print "    description: A new standard" } { print }' "$NEG/p/patchbay-standards/index.yml" > "$NEG/p/index.yml"
   mv "$NEG/p/index.yml" "$NEG/p/patchbay-standards/index.yml"
   git -C "$NEG/p/patchbay-standards" add -A; commit p/patchbay-standards "add process/new"
   run p/project scripts/sync-standards.sh
   run p/project grep -n 'process/new' agent-os/standards/index.yml
   run p/project git status --short ;;
q) hdr "q (a file removed upstream is removed here, with its entry)"
   mk_upstream q/patchbay-standards; mk_project q/project; first_sync q
   git -C "$NEG/q/patchbay-standards" rm -q base/process/ownership.md
   awk '/^  process\/ownership:/ { skip = 2 } skip > 0 { skip--; next } { print }' "$NEG/q/patchbay-standards/index.yml" > "$NEG/q/index.yml"
   mv "$NEG/q/index.yml" "$NEG/q/patchbay-standards/index.yml"
   git -C "$NEG/q/patchbay-standards" add -A; commit q/patchbay-standards "remove process/ownership"
   note "sync to the removing commit (must pass: ownership.md removed, index replaced with 3 entries, the file gone):"
   run q/project scripts/sync-standards.sh
   run q/project ls agent-os/standards/base/process
   run q/project grep -c 'process/ownership' agent-os/standards/index.yml   # 0 matches, grep's own exit 1
   run q/project git status --short ;;
r) hdr "r (own sections survive byte for byte: after --init, a second sync and --index-only; the section goes where the stock ordering puts it, comments staying with their key; a missing index is created)"
   mk_upstream r/patchbay-standards; mk_project r/project
   expected_index r/patchbay-standards > "$NEG/r/expected.yml"
   note "mk_project's index (root:, a comment, testing:, a trailing comment) after --init, after a second sync, after --index-only; each cmp against the hand-built file must pass:"
   ( cd "$NEG/r/project" && ../patchbay-standards/scripts/sync-standards.sh --init >/dev/null 2>&1 ); echo "exit=$?"
   run r/project cmp agent-os/standards/index.yml ../expected.yml
   ( cd "$NEG/r/project" && scripts/sync-standards.sh >/dev/null 2>&1 ); echo "exit=$?"
   run r/project cmp agent-os/standards/index.yml ../expected.yml
   ( cd "$NEG/r/project" && scripts/sync-standards.sh --index-only >/dev/null 2>&1 ); echo "exit=$?"
   run r/project cmp agent-os/standards/index.yml ../expected.yml
   note "an index with api: and zed: and no root: (base: goes between them, under api's trailing blank, above zed's comment):"
   printf 'api:\n  errors:\n    description: One error envelope\n\n\n# zed\nzed:\n  last:\n    description: The last\n' > "$NEG/r/project/agent-os/standards/index.yml"
   rm -rf "$NEG/r/project/agent-os/standards/base" "$NEG/r/project/scripts"
   { printf 'api:\n  errors:\n    description: One error envelope\n\n'; sed -n '/^base:/,$p' "$NEG/r/patchbay-standards/index.yml"; printf '\n# zed\nzed:\n  last:\n    description: The last\n'; } > "$NEG/r/expected2.yml"
   ( cd "$NEG/r/project" && ../patchbay-standards/scripts/sync-standards.sh --init >/dev/null 2>&1 ); echo "exit=$?"
   run r/project cmp agent-os/standards/index.yml ../expected2.yml
   note "an index with api: alone (base: is appended after one blank line):"
   printf 'api:\n  errors:\n    description: One error envelope\n' > "$NEG/r/project/agent-os/standards/index.yml"
   { printf 'api:\n  errors:\n    description: One error envelope\n\n'; sed -n '/^base:/,$p' "$NEG/r/patchbay-standards/index.yml"; } > "$NEG/r/expected3.yml"
   ( cd "$NEG/r/project" && scripts/sync-standards.sh --init >/dev/null 2>&1 ); echo "exit=$?"
   run r/project cmp agent-os/standards/index.yml ../expected3.yml
   note "no index file at all (--init creates one holding the section alone):"
   rm "$NEG/r/project/agent-os/standards/index.yml"
   sed -n '/^base:/,$p' "$NEG/r/patchbay-standards/index.yml" > "$NEG/r/expected4.yml"
   ( cd "$NEG/r/project" && scripts/sync-standards.sh --init >/dev/null 2>&1 ); echo "exit=$?"
   run r/project cmp agent-os/standards/index.yml ../expected4.yml ;;
s) hdr "s (a hand-edited base: entry is drift; --index-only repairs the section and touches nothing else)"
   mk_upstream s/patchbay-standards; mk_project s/project; first_sync s
   sed -i.bak 's/^    description: A person owns every commit.*/    description: Hand-edited here/' "$NEG/s/project/agent-os/standards/index.yml"
   rm "$NEG/s/project/agent-os/standards/index.yml.bak"
   run s/project git diff --stat
   note "--check (must fail: index differs, exit 1):"
   run s/project scripts/sync-standards.sh --check
   note "--index-only (must pass: section replaced), then --check (must pass) and git status (must be empty: nothing but the section was written):"
   run s/project scripts/sync-standards.sh --index-only
   run s/project scripts/sync-standards.sh --check
   run s/project git status --short ;;
t) hdr "t (the drift check passes after a sync and fails on a one-byte edit, an extra file, a missing file; an ignored stray is not drift; a ref or a missing .version is a usage error)"
   mk_upstream t/patchbay-standards; mk_project t/project; first_sync t
   note "clean (must pass):"
   run t/project scripts/sync-standards.sh --check
   note "one byte appended to process/ownership.md (must fail naming it, exit 1):"
   printf 'x' >> "$NEG/t/project/agent-os/standards/base/process/ownership.md"
   run t/project scripts/sync-standards.sh --check
   git -C "$NEG/t/project" checkout -q -- agent-os/standards/base/process/ownership.md
   note "an extra file under base/, untracked (must fail: extra):"
   printf '# Extra\n' > "$NEG/t/project/agent-os/standards/base/process/extra.md"
   run t/project scripts/sync-standards.sh --check
   rm "$NEG/t/project/agent-os/standards/base/process/extra.md"
   note "a tracked file deleted from disk (must fail: missing):"
   rm "$NEG/t/project/agent-os/standards/base/process/standards-index.md"
   run t/project scripts/sync-standards.sh --check
   git -C "$NEG/t/project" checkout -q -- agent-os/standards/base/process/standards-index.md
   note "an ignored .DS_Store under base/ (must pass):"
   touch "$NEG/t/project/agent-os/standards/base/.DS_Store"
   run t/project git status --short --ignored agent-os/standards/base
   run t/project scripts/sync-standards.sh --check
   rm "$NEG/t/project/agent-os/standards/base/.DS_Store"
   note "--check with a ref (usage, exit 2):"
   run t/project scripts/sync-standards.sh --check ../patchbay-standards HEAD
   note "--check with no .version (exit 2):"
   mv "$NEG/t/project/agent-os/standards/base/.version" "$NEG/t/version.bak"
   run t/project scripts/sync-standards.sh --check
   mv "$NEG/t/version.bak" "$NEG/t/project/agent-os/standards/base/.version"
   note "--check with a pinned commit the checkout does not have (exit 2):"
   printf '%s\n' 0123456789abcdef0123456789abcdef01234567 > "$NEG/t/project/agent-os/standards/base/.version"
   run t/project scripts/sync-standards.sh --check
   git -C "$NEG/t/project" checkout -q -- agent-os/standards/base/.version
   run t/project git status --short ;;
u) hdr "u (refusals, each exit 2 by name: inside patchbay-standards itself, not at a work-tree root, a plain directory or another repository as the path, a ref that is not a commit, an unknown flag, an unparseable base: line)"
   mk_upstream u/patchbay-standards; mk_project u/project; mkdir "$NEG/u/plain"
   note "run inside the checkout itself, where agent-os/standards/base is a symlink:"
   run u/patchbay-standards scripts/sync-standards.sh --init .
   note "run from a folder below the project's root:"
   run u/project/agent-os ../../patchbay-standards/scripts/sync-standards.sh --init ../../patchbay-standards
   note "a plain directory as the path:"
   run u/project ../patchbay-standards/scripts/sync-standards.sh --init ../plain
   note "a git checkout that is not patchbay-standards (the project itself):"
   run u/project ../patchbay-standards/scripts/sync-standards.sh --init .
   note "a ref that is not a commit:"
   run u/project ../patchbay-standards/scripts/sync-standards.sh --init ../patchbay-standards no-such-ref
   note "an unknown flag:"
   run u/project ../patchbay-standards/scripts/sync-standards.sh --frobnicate
   note "a base: line that is not a parseable section (base: {}), even with --init:"
   printf 'base: {}\n' >> "$NEG/u/project/agent-os/standards/index.yml"
   run u/project ../patchbay-standards/scripts/sync-standards.sh --init
   run u/project git status --short ;;
v) hdr "v (the script copies itself from the synced commit, as the last act; a working-tree edit to it is not copied)"
   mk_upstream v/patchbay-standards; mk_project v/project; first_sync v
   printf '\n# a later change to the script\n' >> "$NEG/v/patchbay-standards/scripts/sync-standards.sh"
   note "the change uncommitted, sync (must pass; the project's script unchanged):"
   run v/project scripts/sync-standards.sh
   run v/project git status --short
   git -C "$NEG/v/patchbay-standards" add -A; commit v/patchbay-standards "change the script"
   note "the change committed, sync (must pass, exit 0 with the JSON printed; the project's script updated to the commit's bytes, cmp must pass):"
   run v/project scripts/sync-standards.sh
   run v/project cmp scripts/sync-standards.sh ../patchbay-standards/scripts/sync-standards.sh
   run v/project tail -1 scripts/sync-standards.sh
   run v/project git status --short
   note "and the drift check against the new commit (must pass):"
   run v/project scripts/sync-standards.sh --check ;;
*) echo "unknown test: $t" >&2; exit 2 ;;
esac; done
