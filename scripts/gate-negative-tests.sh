#!/usr/bin/env bash
# Negative tests of the verification gate (base/process/verification-gate.md, "Every step that
# can fail is proven to fail"). Not run by scripts/gate.sh; gate step 1 parses this file. Each
# test copies the gate's files into a fresh temporary directory, git-inits and git-adds the copy
# so git ls-files sees it, breaks it in one way, and must fail with the named reason and exit
# status, the steps after it never reached; the positive cases beside them must pass. Every run
# names the status it expects: a mismatch is marked UNEXPECTED and the harness exits 1 at the end
# naming the count, so the transcript's last line says whether every case behaved. A setup step
# that fails stops the harness (exit 2) rather than letting a case fail for the wrong reason.
# Nothing in the tree is touched: the scratch directory is refused unless mktemp made it, outside
# this repository. The transcript of a run is kept in the spec's verification/ folder as
# gate-negative-tests.txt (every test but j) and ci-negative-test.txt (j, the CI replay).
#
# Tests o to v are scripts/sync-standards.sh's (base/process/standards-sync.md), a gate file in
# every consuming project: each builds a scratch patchbay-standards checkout whose HEAD commit holds
# the working tree's files, with origin/main at it as a push would leave it (mk_upstream), beside a
# scratch consuming project, an Agent OS install with its own index sections and two local standards
# (mk_project), and runs the sync from the project as a project would, the sibling checkout as the
# default path and its origin/main as the default ref.
#
# Usage: scripts/gate-negative-tests.sh [test ...]   (default: every test but j; "all" adds j)
#   tests: a b c1 c2 c3 d e f g h i k l m n w x o p q r s t u v j
#   a-d, g, h, k-n  scripts/check-index.sh (gate step 3), each failure by name
#   e, i            gate.sh stops at step 2 on a lint finding (i: with .pymarkdown.yaml shown read)
#   f               gate.sh stops at step 1 on an unparsable script
#   w               step 1's file list: an ignored scripts/.DS_Store passes; a tracked non-shell
#                   file, a tracked script missing from the disk, and a copy that is not a git
#                   work tree each fail by name
#   x               usage: any argument exits 2 with the usage line; the clean copy exits 0
#   j               the CI replay: the run steps of .github/workflows/gate.yml on a clean copy and
#                   a broken one
# Needs git and uv (j reads the workflow with pyyaml, through uv run --with, installing nothing).
# g, k and l also run a script from history (git show <sha>:scripts/check-index.sh) to show the
# bug they guard against as it was; that part is skipped where the commit is absent, and k's
# GNU comm case where gcomm (coreutils) is absent.
set -uo pipefail
cd "$(dirname "$0")/.."
REPO=$(pwd -P)
die() { echo "harness: $1" >&2; exit 2; }   # die <reason>: a setup failure, not a test result
NEG=$(mktemp -d) || die "mktemp -d failed"
[ -n "$NEG" ] && [ -d "$NEG" ] || die "mktemp -d gave no directory"
NEG=$(cd "$NEG" && pwd -P) || die "the scratch directory cannot be entered"   # physical, as the scripts print it
case "$NEG" in
  "$REPO"|"$REPO"/*) die "the scratch directory $NEG is inside this repository; refusing to use it" ;;
esac
trap 'rm -rf "${NEG:?}"' EXIT

runs=0; unexpected=0
check() {  # check <expected status> <status>: print the status and assert it
  runs=$((runs + 1))
  if [ "$2" -eq "$1" ]; then echo "exit=$2"
  else echo "exit=$2  UNEXPECTED (expected $1)"; unexpected=$((unexpected + 1)); fi
}
mk() {  # mk <name>: a copy of the gate's files, git-added so git ls-files sees it
  d="$NEG/$1"; rm -rf "$d"; mkdir -p "$d/agent-os/standards" || die "mk $1: mkdir"
  cp -R base scripts "$d/" || die "mk $1: cp base scripts"
  cp index.yml .pymarkdown.yaml README.md .gitignore "$d/" || die "mk $1: cp root files"
  cp -R agent-os/standards/base agent-os/standards/index.yml "$d/agent-os/standards/" || die "mk $1: cp standards"
  git -c init.defaultBranch=main -C "$d" init -q || die "mk $1: git init"
  git -C "$d" add -A || die "mk $1: git add"
}
run() {  # run <name> <expected status> <cmd...>: run in the copy, print its output and status, assert the status
  local c=$1 want=$2; shift 2
  ( cd "$NEG/$c" && "$@" ) 2>&1 | sed "s#$NEG/\([a-z0-9]*\)#<copy \1>#g"
  check "$want" "${PIPESTATUS[0]}"
}
hdr() { printf '\n### %s\n' "$1"; }
note() { printf -- '-- %s\n' "$1"; }
commit() {  # commit <dir> <message>: in $NEG/<dir>, with a fixed identity and no signing
  git -c user.name=test -c user.email=test@example.invalid -c commit.gpgsign=false \
    -C "$NEG/$1" commit -q --allow-empty -m "$2" || die "commit in $1: $2"
}
push_upstream() {  # push_upstream <dir>: origin/main at HEAD and origin/HEAD pointing at it, as a push to a clone's origin leaves them
  git -C "$NEG/$1" update-ref refs/remotes/origin/main HEAD &&
  git -C "$NEG/$1" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main || die "push_upstream $1"
}
mk_upstream() { mk "$1"; commit "$1" "the working tree"; push_upstream "$1"; }   # a patchbay-standards checkout: HEAD and origin/main hold the working tree's files
mk_project() {  # mk_project <dir>: a consuming project before its first sync, an Agent OS install
  d="$NEG/$1"; rm -rf "$d"; mkdir -p "$d/agent-os/standards/testing" "$d/agent-os/specs" || die "mk_project $1: mkdir"
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
  git -c init.defaultBranch=main -C "$d" init -q || die "mk_project $1: git init"
  git -C "$d" add -A || die "mk_project $1: git add"
  commit "$1" "an Agent OS install"
}
section_of() {  # section_of <index>: its base: section by a second implementation of the rule (sed and a line-buffering awk, not the script's state machine)
  sed -n '/^base:/,$p' "$1" | awk '
    NR > 1 && /^[^[:space:]#]/ { exit }
    { l[NR] = $0; n = NR }
    END { while (n > 0 && (l[n] ~ /^[[:space:]]*$/ || l[n] ~ /^#/)) n--; for (i = 1; i <= n; i++) print l[i] }'
}
entries() { section_of "$1" | grep -c '^  [^[:space:]#]'; }   # entries <index>: the keys in its base: section
expected_index() {  # expected_index <upstream dir>: mk_project's index after --init, built by hand
  cat <<'YML'
# scratch: the standards index. Own sections are edited by hand; base: is synced.
root:
  coding-style:
    description: Four-space indent and one import per line

YML
  section_of "$NEG/$1/index.yml"
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
    die "first sync of $1/project failed"
  git -C "$NEG/$1/project" add -A || die "first_sync $1: git add"
  commit "$1/project" "chore: sync base standards"
}
old_file() {  # old_file <name> <sha> <path>: <path> as of <sha>, beside the copy's as <stem>-<sha>.sh, or return 1
  if git cat-file -e "$2:$3" 2>/dev/null; then
    git show "$2:$3" > "$NEG/$1/${3%.sh}-$2.sh" || die "old_file $1 $2 $3"
    chmod +x "$NEG/$1/${3%.sh}-$2.sh"
  else
    note "commit $2 is not in this clone; its $3 is not shown"; return 1
  fi
}
broken() { printf '#!/usr/bin/env bash\nif true; then\n' > "$NEG/$1/scripts/broken.sh" || die "broken $1"; }   # broken <name>: an unparsable script in the copy

tests=("$@")
[ "${#tests[@]}" -eq 0 ] && tests=(a b c1 c2 c3 d e f g h i k l m n w x o p q r s t u v)
[ "${tests[*]}" = all ] && tests=(a b c1 c2 c3 d e f g h i k l m n w x o p q r s t u v j)

for t in "${tests[@]}"; do case "$t" in
a) hdr "a (tracked file under base/ with no index entry; check-index.sh must fail)"
   mk a; cp "$NEG/a/base/process/ownership.md" "$NEG/a/base/process/orphan.md"; git -C "$NEG/a" add -A
   run a 1 scripts/check-index.sh ;;
b) hdr "b (index entry with no file; check-index.sh must fail)"
   mk b; printf '  python/nothing-here:\n    description: no file\n' >> "$NEG/b/index.yml"
   run b 1 scripts/check-index.sh ;;
c1) hdr "c1 (agent-os/standards/index.yml a regular file byte-identical to index.yml; check-index.sh must fail)"
   mk c1; rm "$NEG/c1/agent-os/standards/index.yml"; cp "$NEG/c1/index.yml" "$NEG/c1/agent-os/standards/index.yml"
   note "cmp shows the bytes match (exit 0), so a byte comparison would have passed:"
   run c1 0 cmp index.yml agent-os/standards/index.yml
   run c1 1 scripts/check-index.sh ;;
c2) hdr "c2 (agent-os/standards/index.yml a symlink to another file; check-index.sh must fail)"
   mk c2; rm "$NEG/c2/agent-os/standards/index.yml"; ln -s ../../README.md "$NEG/c2/agent-os/standards/index.yml"
   run c2 1 scripts/check-index.sh ;;
c3) hdr "c3 (agent-os/standards/index.yml a directory; check-index.sh must fail and say so)"
   mk c3; rm "$NEG/c3/agent-os/standards/index.yml"; mkdir "$NEG/c3/agent-os/standards/index.yml"
   run c3 1 scripts/check-index.sh ;;
d) hdr "d (tracked non-.md file under base/; check-index.sh must fail)"
   mk d; echo note > "$NEG/d/base/notes.txt"; git -C "$NEG/d" add -A
   run d 1 scripts/check-index.sh ;;
e) hdr "e (lint finding: gate.sh must stop at step 2 with the FAIL line, exit 1, and never print 3/3)"
   mk e; printf '# bad\ntext right under the heading with a trailing space \n' > "$NEG/e/base/process/bad.md"
   run e 1 scripts/gate.sh ;;
f) hdr "f (unparsable script: gate.sh must stop at step 1 naming it, exit 1, and never print 2/3)"
   mk f; broken f
   run f 1 scripts/gate.sh ;;
g) hdr "g (comm collation: C-sorted lists with process/B's entry missing, under LANG=en_US.UTF-8; must name process/B alone)"
   mk g; rm "$NEG/g/base/process/"*.md
   for n in B a_z ab; do printf '# %s\n\nA standard.\n' "$n" > "$NEG/g/base/process/$n.md"; done
   printf 'base:\n  process/a_z:\n    description: two\n  process/ab:\n    description: three\n' > "$NEG/g/index.yml"
   git -C "$NEG/g" add -A
   if old_file g aaacc57 scripts/check-index.sh; then
     note "the script at aaacc57 (before issue #3), LANG=en_US.UTF-8 and LC_ALL unset: the bug, every entry reported missing and the indexed ones stale:"
     run g 1 env -u LC_ALL LANG=en_US.UTF-8 scripts/check-index-aaacc57.sh
   fi
   note "shipped script, same environment (must name process/B alone):"
   run g 1 env -u LC_ALL LANG=en_US.UTF-8 scripts/check-index.sh
   printf 'base:\n  process/B:\n    description: one\n  process/a_z:\n    description: two\n  process/ab:\n    description: three\n' > "$NEG/g/index.yml"
   note "shipped script, all three indexed, LANG=en_US.UTF-8 (must pass):"
   run g 0 env -u LC_ALL LANG=en_US.UTF-8 scripts/check-index.sh ;;
h) hdr "h (tracked files are git ls-files: an ignored stray passes, an untracked standard is refused)"
   mk h; touch "$NEG/h/base/.DS_Store"
   note "untracked, ignored base/.DS_Store present (must pass):"
   run h 0 git status --short --ignored base
   run h 0 scripts/check-index.sh
   printf '# New\n\nA standard never git-added.\n' > "$NEG/h/base/process/new.md"
   note "untracked base/process/new.md with no index entry (must fail: under base/ but not tracked):"
   run h 0 git status --short base
   run h 1 scripts/check-index.sh
   printf '  process/new:\n    description: never added\n' >> "$NEG/h/index.yml"
   note "the same file with its index entry (must fail: not tracked, and the entry has no tracked file):"
   run h 1 scripts/check-index.sh ;;
i) hdr "i (.pymarkdown.yaml is read: md013 line lengths 60 in the copy; gate.sh must stop at step 2 on MD013, exit 1, 3/3 never reached)"
   mk i; sed -i.bak 's/line_length: 120/line_length: 60/' "$NEG/i/.pymarkdown.yaml"; rm "$NEG/i/.pymarkdown.yaml.bak"
   grep -n 'line_length' "$NEG/i/.pymarkdown.yaml"
   ( cd "$NEG/i" && scripts/gate.sh > ../i.out 2>&1 ); got=$?
   grep -v 'MD013' "$NEG/i.out" | grep -v '^$'
   echo "   ... $(grep -c MD013 "$NEG/i.out") MD013 findings, Expected: 60, the first three:"
   grep MD013 "$NEG/i.out" | head -3 | sed "s#$NEG/i/##"; check 1 "$got"
   note "the same copy with the key misspelled (line_lenght: 60): --strict-config does not refuse an unknown key, so the default 80 applies with no config error; in this tree, wrapped at 100, that still fails step 2 (Expected: 80), so the misspelling cannot pass here silently:"
   sed -i.bak 's/^    line_length: 60/    line_lenght: 60/' "$NEG/i/.pymarkdown.yaml"; rm "$NEG/i/.pymarkdown.yaml.bak"
   grep -n 'line_len' "$NEG/i/.pymarkdown.yaml"
   ( cd "$NEG/i" && uvx --from "pymarkdownlnt==$(sed -n 's/^PYMARKDOWN_VERSION=//p' scripts/gate.sh)" pymarkdown --strict-config --config .pymarkdown.yaml scan --recurse base README.md > ../i2.out 2>&1 ); got=$?
   echo "   ... $(grep -c MD013 "$NEG/i2.out") MD013 findings, Expected: 80, the first one:"
   grep MD013 "$NEG/i2.out" | head -1 | sed "s#$NEG/i/##"; check 1 "$got" ;;
k) hdr "k (a key that is a prefix of another, testing and testing-fakes: the stripped list must be re-sorted before comm)"
   mk k; printf '# T\n\nA standard.\n' > "$NEG/k/base/process/testing.md"; printf '# TF\n\nA standard.\n' > "$NEG/k/base/process/testing-fakes.md"
   printf '  process/testing:\n    description: t\n  process/testing-fakes:\n    description: tf\n' >> "$NEG/k/index.yml"
   git -C "$NEG/k" add -A
   note "both indexed (must pass):"
   run k 0 scripts/check-index.sh
   printf '# Z\n\nA standard.\n' > "$NEG/k/base/process/zeta.md"; git -C "$NEG/k" add -A
   note "zeta.md tracked beside them with no entry (must fail naming process/zeta alone):"
   run k 1 scripts/check-index.sh
   if old_file k cf1bdf0 scripts/check-index.sh; then
     note "the script at cf1bdf0 (PR 7's first head), BSD comm: testing misreported as both missing and stale:"
     run k 1 scripts/check-index-cf1bdf0.sh
     if command -v gcomm >/dev/null; then
       mkdir -p "$NEG/gnu"; ln -sf "$(command -v gcomm)" "$NEG/gnu/comm"
       note "the same script with GNU comm first on PATH (the ubuntu runner): comm exits 1 on unsorted input, the script reads that as nothing missing, and zeta passes unindexed (the bug, exit 0):"
       run k 0 env PATH="$NEG/gnu:$PATH" scripts/check-index-cf1bdf0.sh
       note "shipped script with GNU comm first on PATH (must fail naming process/zeta alone):"
       run k 1 env PATH="$NEG/gnu:$PATH" scripts/check-index.sh
     fi
   fi ;;
l) hdr "l (a non-ASCII path, base/process/café.md, tracked and indexed; must pass)"
   mk l; printf '# Café\n\nA standard.\n' > "$NEG/l/base/process/café.md"
   printf '  process/café:\n    description: accent\n' >> "$NEG/l/index.yml"; git -C "$NEG/l" add -A
   run l 0 scripts/check-index.sh
   if old_file l cf1bdf0 scripts/check-index.sh; then
     note "the script at cf1bdf0 read the path C-quoted and refused it:"
     run l 1 scripts/check-index-cf1bdf0.sh
   fi ;;
m) hdr "m (a copy that is not a git work tree; check-index.sh must fail by name, not with a bare exit)"
   mk m; rm -rf "$NEG/m/.git"
   run m 1 scripts/check-index.sh ;;
n) hdr "n (a tracked standard deleted from disk, deletion not staged; check-index.sh must fail)"
   mk n; rm "$NEG/n/base/process/ownership.md"
   run n 0 git status --short base
   run n 1 scripts/check-index.sh ;;
w) hdr "w (step 1 lists files with git: an ignored scripts/.DS_Store passes; a tracked scripts/notes.txt is refused by name; a tracked script deleted from the disk is refused; a copy that is not a git work tree is refused by name)"
   mk w; touch "$NEG/w/scripts/.DS_Store" || die "w: touch"
   note "untracked, ignored scripts/.DS_Store present (must pass, exit 0; the gate never lists it):"
   run w 0 git status --short --ignored scripts
   run w 0 scripts/gate.sh
   printf 'a note\n' > "$NEG/w/scripts/notes.txt" || die "w: notes"; git -C "$NEG/w" add scripts/notes.txt || die "w: add notes"
   note "scripts/notes.txt tracked, neither .sh nor a bash shebang (must fail at step 1 naming it, exit 1, 2/3 never printed):"
   run w 1 scripts/gate.sh
   git -C "$NEG/w" rm -q --cached scripts/notes.txt || die "w: rm notes"; rm "$NEG/w/scripts/notes.txt"
   rm "$NEG/w/scripts/gate-negative-tests.sh" || die "w: rm harness copy"
   note "scripts/gate-negative-tests.sh tracked but deleted from the disk, deletion not staged (must fail at step 1 naming it, exit 1):"
   run w 0 git status --short scripts
   run w 1 scripts/gate.sh
   git -C "$NEG/w" checkout -q -- scripts/gate-negative-tests.sh || die "w: restore"
   rm -rf "$NEG/w/.git"
   note "the copy's .git removed (must fail at step 1 by name, exit 1):"
   run w 1 scripts/gate.sh ;;
x) hdr "x (usage: --help and a stray argument each exit 2 with the usage line and run no step; the clean copy exits 0)"
   mk x
   note "clean copy (must pass, exit 0):"
   run x 0 scripts/gate.sh
   note "--help (exit 2, no step banner):"
   run x 2 scripts/gate.sh --help
   note "a stray argument (exit 2):"
   run x 2 scripts/gate.sh x ;;
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
   mk j1; mk j2; broken j2
   replay() {  # replay <name> <expected status>: the workflow's steps against the copy
     local c=$1 want=$2
     uv run --quiet --no-project --with pyyaml python - "$NEG/$c" .github/workflows/gate.yml <<'PY' 2>&1 | sed "s#$NEG/\([a-z0-9]*\)#<copy \1>#g"
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
     check "$want" "${PIPESTATUS[0]}"
   }
   note "j1, clean copy (the job must pass):"; replay j1 0
   note "j2, scripts/broken.sh added as in test f (gate.sh fails at step 1, exit 1, so the job must fail):"; replay j2 1 ;;
o) hdr "o (first sync of a consuming project: refused without --init; the sibling default; --init pins origin/main, not HEAD, creates the base: section and installs the script; an explicit ref off origin/main is warned about; a path inside the checkout resolves to its top)"
   mk_upstream o/patchbay-standards; mk_project o/project
   note "no base: section and no --init (must fail, exit 2, nothing written):"
   run o/project 2 ../patchbay-standards/scripts/sync-standards.sh
   run o/project 0 git status --short
   note "no sibling checkout: the same project copied elsewhere, --init from the checkout's copy (must fail naming ../patchbay-standards, exit 2):"
   mkdir "$NEG/o/elsewhere"; cp -R "$NEG/o/project" "$NEG/o/elsewhere/project"
   run o/elsewhere/project 2 "$NEG/o/patchbay-standards/scripts/sync-standards.sh" --init
   note "the checkout's HEAD one empty commit ahead of origin/main; --init from the sibling checkout, the default path and ref (must pass and pin origin/main):"
   commit o/patchbay-standards "not pushed"
   run o/project 0 ../patchbay-standards/scripts/sync-standards.sh --init
   note "the pinned commit is origin/main, not HEAD:"
   run o/project 0 cat agent-os/standards/base/.version
   run o/patchbay-standards 0 git rev-parse origin/main HEAD
   note "the index is the hand-built expected one, own sections byte for byte (cmp must pass); base/ is the commit's base/ plus .version; the script is the commit's:"
   expected_index o/patchbay-standards > "$NEG/o/expected.yml"
   run o/project 0 cmp agent-os/standards/index.yml ../expected.yml
   run o/project 0 diff -r -x .version ../patchbay-standards/base agent-os/standards/base
   run o/project 0 cmp scripts/sync-standards.sh ../patchbay-standards/scripts/sync-standards.sh
   run o/project 0 git status --short
   note "an explicit ref, HEAD, not on origin/main (must pass with a WARN line naming the commit, and pin HEAD):"
   run o/project 0 scripts/sync-standards.sh ../patchbay-standards HEAD
   run o/project 0 cat agent-os/standards/base/.version
   note "a path inside the checkout, ../patchbay-standards/base, resolves to its top (must pass):"
   run o/project 0 scripts/sync-standards.sh --check ../patchbay-standards/base ;;
p) hdr "p (a working-tree edit in the checkout is not synced; a committed, pushed addition is)"
   mk_upstream p/patchbay-standards; mk_project p/project; first_sync p
   printf '\nAn uncommitted edit.\n' >> "$NEG/p/patchbay-standards/base/process/ownership.md"
   run p/patchbay-standards 0 git status --short
   git -C "$NEG/p/patchbay-standards" show HEAD:base/process/ownership.md > "$NEG/p/committed.md"
   note "sync with the edit uncommitted (must pass with nothing added, removed or changed; the project's file stays the committed bytes):"
   run p/project 0 scripts/sync-standards.sh
   run p/project 0 cmp agent-os/standards/base/process/ownership.md ../committed.md
   run p/project 0 git status --short
   printf '# New\n\nA standard.\n' > "$NEG/p/patchbay-standards/base/process/new.md"
   awk '/^  process\/ownership:/ { print "  process/new:"; print "    description: A new standard" } { print }' "$NEG/p/patchbay-standards/index.yml" > "$NEG/p/index.yml"
   mv "$NEG/p/index.yml" "$NEG/p/patchbay-standards/index.yml"
   git -C "$NEG/p/patchbay-standards" add -A; commit p/patchbay-standards "add process/new"; push_upstream p/patchbay-standards
   note "the edit committed and pushed together with base/process/new.md and its entry (must pass: new.md added, ownership.md changed, index replaced with $(entries "$NEG/p/patchbay-standards/index.yml") entries, the upstream index's count, which the project's section must then hold):"
   run p/project 0 scripts/sync-standards.sh
   run p/project 0 grep -n 'process/new' agent-os/standards/index.yml
   run p/project 0 entries agent-os/standards/index.yml
   run p/project 0 git status --short ;;
q) hdr "q (a file removed upstream is removed here, with its entry)"
   mk_upstream q/patchbay-standards; mk_project q/project; first_sync q
   git -C "$NEG/q/patchbay-standards" rm -q base/process/ownership.md
   awk '/^  process\/ownership:/ { skip = 2 } skip > 0 { skip--; next } { print }' "$NEG/q/patchbay-standards/index.yml" > "$NEG/q/index.yml"
   mv "$NEG/q/index.yml" "$NEG/q/patchbay-standards/index.yml"
   git -C "$NEG/q/patchbay-standards" add -A; commit q/patchbay-standards "remove process/ownership"; push_upstream q/patchbay-standards
   note "sync to the removing commit (must pass: ownership.md removed, index replaced with $(entries "$NEG/q/patchbay-standards/index.yml") entries, the upstream index's count, the file gone):"
   run q/project 0 scripts/sync-standards.sh
   run q/project 0 ls agent-os/standards/base/process
   run q/project 0 entries agent-os/standards/index.yml
   run q/project 1 grep -c 'process/ownership' agent-os/standards/index.yml   # 0 matches, grep's own exit 1
   run q/project 0 git status --short ;;
r) hdr "r (own sections survive byte for byte: after --init, a second sync and --index-only; the section goes where the stock ordering puts it, comments staying with their key, at line 1 included; a missing index is created and its line-1 section replaced and regenerated; the trailing comment of the upstream index stays upstream)"
   mk_upstream r/patchbay-standards; mk_project r/project
   printf '\n# end of the base index\n' >> "$NEG/r/patchbay-standards/index.yml"
   git -C "$NEG/r/patchbay-standards" add -A; commit r/patchbay-standards "a trailing comment"; push_upstream r/patchbay-standards
   note "the upstream index.yml ends with a blank line and a comment, committed and pushed; the section ends at its last indented line, so every expected file below is built by the oracle without them:"
   run r/patchbay-standards 0 tail -3 index.yml
   expected_index r/patchbay-standards > "$NEG/r/expected.yml"
   init_r() { ( cd "$NEG/r/project" && ../patchbay-standards/scripts/sync-standards.sh --init >/dev/null 2>&1 ); check 0 $?; }
   layout() {  # layout <index text>: the project's index set to it, base/ and the script removed, so --init runs fresh
     printf '%s' "$1" > "$NEG/r/project/agent-os/standards/index.yml"; rm -rf "$NEG/r/project/agent-os/standards/base" "$NEG/r/project/scripts"; }
   note "mk_project's index (a header comment, root:, a comment, testing:, a trailing comment) after --init, after a second sync, after --index-only; each cmp against the hand-built file must pass:"
   init_r
   run r/project 0 cmp agent-os/standards/index.yml ../expected.yml
   ( cd "$NEG/r/project" && scripts/sync-standards.sh >/dev/null 2>&1 ); check 0 $?
   run r/project 0 cmp agent-os/standards/index.yml ../expected.yml
   ( cd "$NEG/r/project" && scripts/sync-standards.sh --index-only >/dev/null 2>&1 ); check 0 $?
   run r/project 0 cmp agent-os/standards/index.yml ../expected.yml
   note "an index with api: and zed: and no root: (base: goes between them, under api's trailing blank lines collapsed to one, above zed's comment):"
   layout 'api:
  errors:
    description: One error envelope


# zed
zed:
  last:
    description: The last
'
   { printf 'api:\n  errors:\n    description: One error envelope\n\n'; section_of "$NEG/r/patchbay-standards/index.yml"; printf '\n# zed\nzed:\n  last:\n    description: The last\n'; } > "$NEG/r/expected2.yml"
   init_r; run r/project 0 cmp agent-os/standards/index.yml ../expected2.yml
   note "an index with api: alone (base: is appended after one blank line):"
   layout 'api:
  errors:
    description: One error envelope
'
   { printf 'api:\n  errors:\n    description: One error envelope\n\n'; section_of "$NEG/r/patchbay-standards/index.yml"; } > "$NEG/r/expected3.yml"
   init_r; run r/project 0 cmp agent-os/standards/index.yml ../expected3.yml
   note "an index whose first line is testing: (base: goes on line 1, one blank line, then testing:):"
   layout 'testing:
  fixtures:
    description: f
'
   { section_of "$NEG/r/patchbay-standards/index.yml"; printf '\ntesting:\n  fixtures:\n    description: f\n'; } > "$NEG/r/expected4.yml"
   init_r; run r/project 0 cmp agent-os/standards/index.yml ../expected4.yml
   note "the same with a comment on line 1 directly above testing: (the comment stays with its key; base: goes on line 1):"
   layout '# the index
testing:
  fixtures:
    description: f
'
   { section_of "$NEG/r/patchbay-standards/index.yml"; printf '\n# the index\ntesting:\n  fixtures:\n    description: f\n'; } > "$NEG/r/expected5.yml"
   init_r; run r/project 0 cmp agent-os/standards/index.yml ../expected5.yml
   note "no index file at all (--init creates one holding the section alone, on line 1):"
   layout ''; rm "$NEG/r/project/agent-os/standards/index.yml"
   section_of "$NEG/r/patchbay-standards/index.yml" > "$NEG/r/expected6.yml"
   init_r; run r/project 0 cmp agent-os/standards/index.yml ../expected6.yml
   git -C "$NEG/r/project" add -A; commit r/project "chore: sync base standards"
   sed -i.bak 's/^    description: A person owns every commit/    description: One person owns every commit/' "$NEG/r/patchbay-standards/index.yml"; rm "$NEG/r/patchbay-standards/index.yml.bak"
   git -C "$NEG/r/patchbay-standards" add -A; commit r/patchbay-standards "reword a description"; push_upstream r/patchbay-standards
   section_of "$NEG/r/patchbay-standards/index.yml" > "$NEG/r/expected7.yml"
   if old_file r/patchbay-standards 3d3e111 scripts/sync-standards.sh; then
     note "a description reworded upstream, committed and pushed; the script at 3d3e111 (PR 9's first head) syncing it into this line-1 index: BSD head -n 0 exits 1 and the project is left half-synced, .version at the new commit and the index at the old:"
     run r/project 1 ../patchbay-standards/scripts/sync-standards-3d3e111.sh
     run r/project 0 git status --short
     git -C "$NEG/r/project" checkout -q -- .
   fi
   note "the shipped script on the same (must pass: the line-1 section replaced, cmp against the new section must pass):"
   run r/project 0 scripts/sync-standards.sh
   run r/project 0 cmp agent-os/standards/index.yml ../expected7.yml
   note "a hand edit to the line-1 section, then --index-only (must pass and repair it):"
   sed -i.bak 's/^    description: One person/    description: Hand-edited/' "$NEG/r/project/agent-os/standards/index.yml"; rm "$NEG/r/project/agent-os/standards/index.yml.bak"
   run r/project 0 scripts/sync-standards.sh --index-only
   run r/project 0 cmp agent-os/standards/index.yml ../expected7.yml
   run r/project 0 tail -2 agent-os/standards/index.yml ;;
s) hdr "s (a hand-edited base: entry is drift; --index-only repairs the section and touches nothing else)"
   mk_upstream s/patchbay-standards; mk_project s/project; first_sync s
   sed -i.bak 's/^    description: A person owns every commit.*/    description: Hand-edited here/' "$NEG/s/project/agent-os/standards/index.yml"
   rm "$NEG/s/project/agent-os/standards/index.yml.bak"
   run s/project 0 git diff --stat
   note "--check (must fail: index differs, exit 1):"
   run s/project 1 scripts/sync-standards.sh --check
   note "--index-only (must pass: section replaced), then --check (must pass) and git status (must be empty: nothing but the section was written):"
   run s/project 0 scripts/sync-standards.sh --index-only
   run s/project 0 scripts/sync-standards.sh --check
   run s/project 0 git status --short ;;
t) hdr "t (the drift check passes after a sync and fails on a one-byte edit, an extra file, a missing file; an ignored stray is not drift; a ref or a missing .version is a usage error)"
   mk_upstream t/patchbay-standards; mk_project t/project; first_sync t
   note "clean (must pass):"
   run t/project 0 scripts/sync-standards.sh --check
   note "one byte appended to process/ownership.md (must fail naming it, exit 1):"
   printf 'x' >> "$NEG/t/project/agent-os/standards/base/process/ownership.md"
   run t/project 1 scripts/sync-standards.sh --check
   git -C "$NEG/t/project" checkout -q -- agent-os/standards/base/process/ownership.md
   note "an extra file under base/, untracked (must fail: extra):"
   printf '# Extra\n' > "$NEG/t/project/agent-os/standards/base/process/extra.md"
   run t/project 1 scripts/sync-standards.sh --check
   rm "$NEG/t/project/agent-os/standards/base/process/extra.md"
   note "a tracked file deleted from disk (must fail: missing):"
   rm "$NEG/t/project/agent-os/standards/base/process/standards-index.md"
   run t/project 1 scripts/sync-standards.sh --check
   git -C "$NEG/t/project" checkout -q -- agent-os/standards/base/process/standards-index.md
   note "an ignored .DS_Store under base/ (must pass):"
   touch "$NEG/t/project/agent-os/standards/base/.DS_Store"
   run t/project 0 git status --short --ignored agent-os/standards/base
   run t/project 0 scripts/sync-standards.sh --check
   rm "$NEG/t/project/agent-os/standards/base/.DS_Store"
   note "--check with a ref (usage, exit 2):"
   run t/project 2 scripts/sync-standards.sh --check ../patchbay-standards HEAD
   note "--check with no .version (exit 2):"
   mv "$NEG/t/project/agent-os/standards/base/.version" "$NEG/t/version.bak"
   run t/project 2 scripts/sync-standards.sh --check
   mv "$NEG/t/version.bak" "$NEG/t/project/agent-os/standards/base/.version"
   note "--check with a pinned commit the checkout does not have (exit 2):"
   printf '%s\n' 0123456789abcdef0123456789abcdef01234567 > "$NEG/t/project/agent-os/standards/base/.version"
   run t/project 2 scripts/sync-standards.sh --check
   git -C "$NEG/t/project" checkout -q -- agent-os/standards/base/.version
   run t/project 0 git status --short ;;
u) hdr "u (refusals, each exit 2 by name and nothing written: inside patchbay-standards itself, not at a work-tree root, a plain directory or another repository as the path, a ref that is not a commit, an unknown flag, two mode flags, a commit whose index.yml has no parseable base: section, no origin/HEAD to default to, a second base: line in the project's index)"
   mk_upstream u/patchbay-standards; mk_project u/project; mkdir "$NEG/u/plain"; first_sync u
   note "run inside the checkout itself, where agent-os/standards/base is a symlink:"
   run u/patchbay-standards 2 scripts/sync-standards.sh --init .
   note "run from a folder below the project's root:"
   run u/project/agent-os 2 ../../patchbay-standards/scripts/sync-standards.sh ../../patchbay-standards
   note "a plain directory as the path:"
   run u/project 2 scripts/sync-standards.sh ../plain
   note "a git checkout that is not patchbay-standards (the project itself):"
   run u/project 2 scripts/sync-standards.sh . HEAD
   note "a ref that is not a commit:"
   run u/project 2 scripts/sync-standards.sh ../patchbay-standards no-such-ref
   note "an unknown flag:"
   run u/project 2 scripts/sync-standards.sh --frobnicate
   note "two mode flags:"
   run u/project 2 scripts/sync-standards.sh --check --index-only
   printf 'base: {}\n' > "$NEG/u/patchbay-standards/index.yml"
   git -C "$NEG/u/patchbay-standards" add -A; commit u/patchbay-standards "an index with no section"
   note "a commit whose index.yml is base: {} (the checkout's HEAD, not pushed): refused before anything is written, so git status stays empty:"
   run u/project 2 scripts/sync-standards.sh ../patchbay-standards HEAD
   run u/project 0 git status --short
   git -C "$NEG/u/patchbay-standards" symbolic-ref --delete refs/remotes/origin/HEAD
   note "no origin/HEAD in the checkout and no ref given:"
   run u/project 2 scripts/sync-standards.sh
   push_upstream u/patchbay-standards
   note "a second base: line appended to the project's index (not a parseable section), even with --init:"
   printf 'base: {}\n' >> "$NEG/u/project/agent-os/standards/index.yml"
   run u/project 2 scripts/sync-standards.sh --init
   run u/project 2 scripts/sync-standards.sh --check
   run u/project 0 git status --short ;;
v) hdr "v (the script copies itself from the synced commit as the last thing it writes; a working-tree edit to it is not copied)"
   mk_upstream v/patchbay-standards; mk_project v/project; first_sync v
   printf '\n# a later change to the script\n' >> "$NEG/v/patchbay-standards/scripts/sync-standards.sh"
   note "the change uncommitted, sync (must pass; the project's script unchanged):"
   run v/project 0 scripts/sync-standards.sh
   run v/project 0 git status --short
   git -C "$NEG/v/patchbay-standards" add -A; commit v/patchbay-standards "change the script"; push_upstream v/patchbay-standards
   note "the change committed and pushed, sync (must pass, exit 0 with the JSON printed after the copy; the project's script updated to the commit's bytes, cmp must pass):"
   run v/project 0 scripts/sync-standards.sh
   run v/project 0 cmp scripts/sync-standards.sh ../patchbay-standards/scripts/sync-standards.sh
   run v/project 0 tail -1 scripts/sync-standards.sh
   run v/project 0 git status --short
   note "and the drift check against the new commit (must pass):"
   run v/project 0 scripts/sync-standards.sh --check ;;
*) die "unknown test: $t" ;;
esac; done

printf '\n%d runs, %d unexpected\n' "$runs" "$unexpected"
[ "$unexpected" -eq 0 ]
