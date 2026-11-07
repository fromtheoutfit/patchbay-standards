#!/usr/bin/env bash
# Negative tests of the verification gate (base/process/verification-gate.md, "Every step that
# can fail is proven to fail"). Not run by scripts/gate.sh; gate step 1 parses this file. Each
# test copies the gate's files into a fresh temporary directory, git-inits and git-adds the copy
# so git ls-files sees it, breaks it in one way, and must fail with the named reason and exit
# status, the steps after it never reached; the positive cases beside them must pass. Every run
# names the status it expects, and a run that expects a failure also names the reason its output
# must hold, the FAIL or refusal line with its path where one is printed: gate.sh, check-index.sh
# and sync-standards.sh each give one status for several reasons, so a status alone cannot tell a
# guard from its absence. A reason holding gate.sh's FAIL  step N/M line also holds the run to no
# step banner past step N, and one that is gate.sh's usage or cd line to none at all, so the steps
# after a failure are checked as never reached, not assumed; a passing run may name lines its output
# must hold too. The reason is found line by line, in order, and says nothing of what else was printed,
# so a case that says a step names an entry alone follows its run with only, which holds the entries
# listed under the run's FAIL lines to exactly those it names, and a case that says a line is
# printed once follows it with times, which holds one whole line to an exact count. A mismatch of
# any of these is marked UNEXPECTED and the harness exits 1 at the end naming the count, so the
# transcript's last line says whether every case behaved. Every setup step (a command that builds a
# case's state) stops the harness by name when it fails (exit 2) rather than letting a case fail for
# the wrong reason. A change to these assertions is shown to discriminate by a mutation, the guard
# it covers deleted in a copy and the case coming back UNEXPECTED, recorded in the spec's
# verification/ beside the run. Nothing in the tree is touched: the scratch directory is refused
# unless mktemp made it, outside this repository. The transcript of one run is kept in the spec's
# verification/ folder as gate-negative-tests.txt (every test but j) and ci-negative-test.txt (j,
# the CI replay), each holding that one run and ending on its count; an earlier run kept as
# evidence, a failing one before a fix, goes in a file of its own.
#
# Every case copies base/ and scripts/ as the tree holds them (mk), so a case whose expectation
# depends on what a copied directory holds sets the whole of that directory (g empties base/ and
# writes its own), and one that needs a named file there stops by name without it (a, n and y need
# base/process/ownership.md). The tests are rerun whenever the gate's files change, and whenever a
# spec adds, removes or renames a file under a directory mk copies.
#
# Tests o to v are scripts/sync-standards.sh's (base/process/standards-sync.md), a gate file in
# every consuming project: each builds a scratch patchbay-standards checkout whose HEAD commit holds
# the working tree's files, with origin/main at it as a push would leave it (mk_upstream), beside a
# scratch consuming project, an Agent OS install with its own index sections and two local standards
# (mk_project), and runs the sync from the project as a project would, the sibling checkout as the
# default path and its origin/main as the default ref.
#
# Usage: scripts/gate-negative-tests.sh [test ...]   (default: every test but j; "all" adds j)
#   tests: a b c1 c2 c3 d e f g h i k l m n w x y z o p q r s t u v j
#   a-d, g, h, k-n  scripts/check-index.sh (gate step 3), each failure by name (h: a standard in
#                   a three-way merge conflict listed once; m: the copy entered in upper case
#                   passes, a corrupt index, a copy under another repository's .git/ and one in a
#                   bare repository fail by name)
#   e, i            gate.sh stops at step 2 on a lint finding, after the install's ok line (i: the
#                   rule set in .pymarkdown.yaml shown read: a changed value applied, a misspelled
#                   key not refused, an unparsable value and an unparsable file each refused)
#   f               gate.sh stops at step 1 on an unparsable script
#   w               step 1's file list: an ignored scripts/.DS_Store passes; the copy entered in
#                   upper case passes; a script in a three-way merge conflict is listed once; a
#                   corrupt index, a git that refuses step 1's listing, a mktemp that makes no
#                   directory, a tracked non-shell file, a tracked script missing from the disk, a
#                   tracked symlink to nothing, a copy that is not a git work tree, one inside
#                   another repository, one under another repository's .git/ and one in a bare
#                   repository each fail by name
#   x               not run as the gate: any argument exits 2 with the usage line, a script that
#                   cannot enter the repository root exits 2 saying so; the clean copy exits 0
#   y               step 2's file list: an ignored .md under base/ is never linted; force-added
#                   under a .gitignore, step 1 refuses it by name, two such files under one FAIL; a
#                   force-added file no step reads, and one only .git/info/exclude or a global
#                   excludes file matches, pass step 1; with no pattern matching it, git lists it
#                   and step 2 lints it; a git that refuses step 2's listing, and a tracked .md
#                   missing from the disk, each fail by name
#   z               step 2's install fails as itself: the clean copy's install ok line comes before
#                   the lint's; uvx missing from PATH, and a pin naming a version never published,
#                   each fail step 2 by name as the install, before pymarkdown lints
#   j               the CI replay: the run steps of .github/workflows/gate.yml on a clean copy and
#                   a broken one
# Needs git and uv (j reads the workflow with pyyaml, through uv run --with, installing nothing),
# and, the first time, network access to fetch the pinned pymarkdown into the uv cache. z hides uvx
# with PATH=/usr/bin:/bin, where the commands steps 1 and 2 use before uvx (bash, dirname, git,
# sort, head, grep) must be and uvx must not. w and y put a git that refuses one call first on
# PATH (shim, in the scratch directory), every other call the real git, and w a mktemp that makes
# no directory. m, u and w run from a copy's path typed in upper case (upper_run), after upper
# says the file system is case-insensitive.
# g, h, k, l, m, r, t, u, w and y also run a script from history (git show <sha>:<path>) to show
# the bug they guard against as it was; that part is skipped where the commit is absent, k's GNU
# comm case where gcomm (coreutils) is absent, and the upper-case runs of m, u and w on a
# case-sensitive file system, where the path typed in upper case is no directory.
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
NEGUP=$(printf '%s' "$NEG" | tr '[:lower:]' '[:upper:]')   # the scratch path typed in upper case (w, m, u)

runs=0; unexpected=0
says() {  # says <text> <file>: each line of the text is found in the file, in order, as a fixed string within a line
  WANT=$1 awk 'BEGIN { n = split(ENVIRON["WANT"], w, "\n"); k = 1 }
    k <= n && index($0, w[k]) { k++ }
    END { exit (k <= n) }' "$2"
}
later() {  # later <n> <file>: the file holds a gate.sh step banner (== K/M) past step <n>
  awk -v n="$1" '/^== [0-9]+\// && substr($0, 4) + 0 > n { f = 1 } END { exit !f }' "$2"
}
check() {  # check <expected status> <status> [<expected text> <printed output>]: print the status; assert it, the text (required for a failure), and no gate.sh step past the one the text fails at
  local n=
  runs=$((runs + 1))
  case ${3:-} in
    *'FAIL  step '[0-9]*) n=${3##*FAIL  step }; n=${n%%/*} ;;   # the last FAIL  step N/M line the text names
    'usage: scripts/gate.sh'*|'gate: cannot enter'*) n=0 ;;      # not run as the gate: no step at all
  esac
  if [ "$2" -ne "$1" ]; then
    echo "exit=$2  UNEXPECTED (expected $1)"; unexpected=$((unexpected + 1))
  elif { [ "$1" -ne 0 ] || [ -n "${3:-}" ]; } && ! { [ -n "${3:-}" ] && says "$3" "$4"; }; then
    echo "exit=$2  UNEXPECTED (the output does not say: ${3:-<no reason named>})"; unexpected=$((unexpected + 1))
  elif [ -n "$n" ] && later "$n" "$4"; then
    echo "exit=$2  UNEXPECTED (a step after step $n was reached)"; unexpected=$((unexpected + 1))
  else
    echo "exit=$2"
  fi
}
shown() {  # shown <raw output>: print it with the scratch paths shortened to <copy name> (<COPY NAME> when typed in upper case), into $NEG/run.out too
  sed -e "s#$NEG/\([a-z0-9]*\)#<copy \1>#g" -e "s#$NEGUP/\([A-Z0-9]*\)#<COPY \1>#g" "$1" > "$NEG/run.out" || die "sed on $1"
  cat "$NEG/run.out"
}
run() {  # run <name> <expected status> [<expected text, when the status is not 0>] <cmd...>: run in the copy, print its output and status, assert both
  local c=$1 want=$2 text= got; shift 2
  if [ "$want" -ne 0 ]; then text=$1; shift; fi
  ( cd "$NEG/$c" && "$@" ) > "$NEG/run.raw" 2>&1; got=$?
  shown "$NEG/run.raw"
  check "$want" "$got" "$text" "$NEG/run.out"
}
only() {  # only <entry>...: after run, the entries listed under its FAIL lines (each indented eight spaces) are exactly these, in order; a mismatch is UNEXPECTED, an assertion on that run, not another run
  local want got
  want=$(printf '        %s\n' "$@")
  got=$(grep '^        ' "$NEG/run.out")
  if [ "$got" = "$want" ]; then
    echo "only=$*"
  else
    echo "only=$*  UNEXPECTED (listed: $(printf '%s\n' "$got" | sed 's/^ *//' | paste -sd ' ' -))"; unexpected=$((unexpected + 1))
  fi
}
times() {  # times <n> <line>: after run, its output holds exactly this whole line exactly n times; a mismatch is UNEXPECTED, an assertion on that run, not another run
  local got
  got=$(grep -cxF -- "$2" "$NEG/run.out")
  if [ "$got" -eq "$1" ]; then echo "times=$1 x $2"
  else echo "times=$1 x $2  UNEXPECTED (found $got)"; unexpected=$((unexpected + 1)); fi
}
shim() {  # shim: $NEG/shim/git, the real git but for a call whose arguments hold $GATE_TEST_REFUSE, which it refuses (exit 128); a case puts it first on PATH
  [ -x "$NEG/shim/git" ] && return 0
  mkdir -p "$NEG/shim" || die "shim: mkdir"
  cat > "$NEG/shim/git" <<SH || die "shim: write"
#!/usr/bin/env bash
# git, refusing a call whose arguments hold \$GATE_TEST_REFUSE; every other call is the real git
case " \$* " in *"\${GATE_TEST_REFUSE:?}"*) echo "git (test shim): refusing: \$*" >&2; exit 128 ;; esac
exec "$(command -v git)" "\$@"
SH
  chmod +x "$NEG/shim/git" || die "shim: chmod"
}
upper() {  # upper: 0 on a case-insensitive file system, where the scratch path typed in upper case is the same directory; otherwise a note that the upper-case runs are skipped, and 1
  [ -d "$NEGUP" ] && return 0
  note "this file system is case-sensitive: the scratch path in upper case is no directory, so the upper-case runs are skipped"; return 1
}
upper_run() {  # upper_run <copy> <expected status> [<expected text, when the status is not 0>] <cmd...>: run, from the copy's path typed in upper case
  local c=$1 want=$2 u text=(); shift 2
  if [ "$want" -ne 0 ]; then text=("$1"); shift; fi
  u=$NEGUP/$(printf '%s' "$c" | tr '[:lower:]' '[:upper:]')
  run "$c" "$want" ${text[@]+"${text[@]}"} bash -c 'cd "$1" && shift && exec "$@"' _ "$u" "$@"
}
hdr() { printf '\n### %s\n' "$1"; }
note() { printf -- '-- %s\n' "$1"; }
mk() {  # mk <name>: a copy of the gate's files, git-added so git ls-files sees it
  d="$NEG/$1"; rm -rf "$d" || die "mk $1: rm"; mkdir -p "$d/agent-os/standards" || die "mk $1: mkdir"
  cp -R base scripts "$d/" || die "mk $1: cp base scripts"
  cp index.yml .pymarkdown.yaml README.md .gitignore "$d/" || die "mk $1: cp root files"
  cp -R agent-os/standards/base agent-os/standards/index.yml "$d/agent-os/standards/" || die "mk $1: cp standards"
  git -c init.defaultBranch=main -C "$d" init -q || die "mk $1: git init"
  git -C "$d" add -A || die "mk $1: git add"
}
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
  d="$NEG/$1"; rm -rf "$d" || die "mk_project $1: rm"; mkdir -p "$d/agent-os/standards/testing" "$d/agent-os/specs" || die "mk_project $1: mkdir"
  printf '[project]\nname = "scratch"\nversion = "0.1.0"\n' > "$d/pyproject.toml" || die "mk_project $1: pyproject.toml"
  printf '# scratch\n\n## Ownership\n\nThe owner owns every commit.\n' > "$d/CLAUDE.md" || die "mk_project $1: CLAUDE.md"
  printf '.DS_Store\n.venv/\n' > "$d/.gitignore" || die "mk_project $1: .gitignore"
  printf '# Coding style\n\nFour-space indent, one import per line.\n' > "$d/agent-os/standards/coding-style.md" || die "mk_project $1: coding-style.md"
  printf '# Fixtures\n\nEvery adapter builds its fake device from the shared fixture.\n' > "$d/agent-os/standards/testing/fixtures.md" || die "mk_project $1: fixtures.md"
  cat > "$d/agent-os/standards/index.yml" <<'YML' || die "mk_project $1: index.yml"
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
    chmod +x "$NEG/$1/${3%.sh}-$2.sh" || die "old_file $1 $2 $3: chmod"
  else
    note "commit $2 is not in this clone; its $3 is not shown"; return 1
  fi
}
broken() { printf '#!/usr/bin/env bash\nif true; then\n' > "$NEG/$1/scripts/broken.sh" || die "broken $1"; }   # broken <name>: an unparsable script in the copy

tests=("$@")
[ "${#tests[@]}" -eq 0 ] && tests=(a b c1 c2 c3 d e f g h i k l m n w x y z o p q r s t u v)
[ "${tests[*]}" = all ] && tests=(a b c1 c2 c3 d e f g h i k l m n w x y z o p q r s t u v j)

for t in "${tests[@]}"; do case "$t" in
a) hdr "a (tracked file under base/ with no index entry; check-index.sh must fail)"
   mk a; cp "$NEG/a/base/process/ownership.md" "$NEG/a/base/process/orphan.md" || die "a: cp"; git -C "$NEG/a" add -A || die "a: git add"
   run a 1 $'FAIL  tracked under base/ but not in index.yml:\n        process/orphan' scripts/check-index.sh ;;
b) hdr "b (index entry with no file; check-index.sh must fail)"
   mk b; printf '  python/nothing-here:\n    description: no file\n' >> "$NEG/b/index.yml" || die "b: index entry"
   run b 1 $'FAIL  in index.yml but not tracked under base/:\n        python/nothing-here' scripts/check-index.sh ;;
c1) hdr "c1 (agent-os/standards/index.yml a regular file byte-identical to index.yml; check-index.sh must fail)"
   mk c1; rm "$NEG/c1/agent-os/standards/index.yml" || die "c1: rm"; cp "$NEG/c1/index.yml" "$NEG/c1/agent-os/standards/index.yml" || die "c1: cp"
   note "cmp shows the bytes match (exit 0), so a byte comparison would have passed:"
   run c1 0 cmp index.yml agent-os/standards/index.yml
   run c1 1 "FAIL  agent-os/standards/index.yml is not a symlink to ../../index.yml (found: a regular file)" scripts/check-index.sh ;;
c2) hdr "c2 (agent-os/standards/index.yml a symlink to another file; check-index.sh must fail)"
   mk c2; rm "$NEG/c2/agent-os/standards/index.yml" || die "c2: rm"; ln -s ../../README.md "$NEG/c2/agent-os/standards/index.yml" || die "c2: ln"
   run c2 1 "FAIL  agent-os/standards/index.yml is not a symlink to ../../index.yml (found: a symlink to ../../README.md)" scripts/check-index.sh ;;
c3) hdr "c3 (agent-os/standards/index.yml a directory; check-index.sh must fail and say so)"
   mk c3; rm "$NEG/c3/agent-os/standards/index.yml" || die "c3: rm"; mkdir "$NEG/c3/agent-os/standards/index.yml" || die "c3: mkdir"
   run c3 1 "FAIL  agent-os/standards/index.yml is not a symlink to ../../index.yml (found: a directory)" scripts/check-index.sh ;;
d) hdr "d (tracked non-.md file under base/; check-index.sh must fail)"
   mk d; echo note > "$NEG/d/base/notes.txt" || die "d: notes.txt"; git -C "$NEG/d" add -A || die "d: git add"
   run d 1 $'FAIL  not a standard (only .md files belong under base/):\n        base/notes.txt' scripts/check-index.sh ;;
e) hdr "e (lint finding: gate.sh must install the pin, then stop at step 2 on the finding with the FAIL line, exit 1, and never print 3/3)"
   mk e; printf '# bad\ntext right under the heading with a trailing space \n' > "$NEG/e/base/process/bad.md" || die "e: bad.md"
   run e 1 $'ok   pymarkdownlnt==\nbase/process/bad.md:2:51: MD009: Trailing spaces\nFAIL  step 2/3: pymarkdown reported findings, or could not read .pymarkdown.yaml (see above)' scripts/gate.sh ;;
f) hdr "f (unparsable script: gate.sh must stop at step 1 naming it, exit 1, and never print 2/3)"
   mk f; broken f
   run f 1 "FAIL  step 1/3: scripts/broken.sh does not parse" scripts/gate.sh ;;
g) hdr "g (comm collation: C-sorted lists with process/B's entry missing, under LANG=en_US.UTF-8; must name process/B alone)"
   mk g; rm -r "$NEG/g/base" || die "g: rm"; mkdir -p "$NEG/g/base/process" || die "g: mkdir"
   for n in B a_z ab; do printf '# %s\n\nA standard.\n' "$n" > "$NEG/g/base/process/$n.md" || die "g: $n.md"; done
   printf 'base:\n  process/a_z:\n    description: two\n  process/ab:\n    description: three\n' > "$NEG/g/index.yml" || die "g: index"
   git -C "$NEG/g" add -A || die "g: git add"
   if old_file g aaacc57 scripts/check-index.sh; then
     note "the script at aaacc57 (before issue #3), LANG=en_US.UTF-8 and LC_ALL unset: the bug, every entry reported missing and the indexed ones stale:"
     run g 1 $'FAIL  under base/ but not in index.yml:\n        process/B\n        process/a_z\n        process/ab\nFAIL  in index.yml but not under base/:\n        process/a_z' env -u LC_ALL LANG=en_US.UTF-8 scripts/check-index-aaacc57.sh
   fi
   note "shipped script, same environment (must name process/B alone):"
   run g 1 $'FAIL  tracked under base/ but not in index.yml:\n        process/B' env -u LC_ALL LANG=en_US.UTF-8 scripts/check-index.sh
   only process/B
   printf 'base:\n  process/B:\n    description: one\n  process/a_z:\n    description: two\n  process/ab:\n    description: three\n' > "$NEG/g/index.yml" || die "g: index, all three"
   note "shipped script, all three indexed, LANG=en_US.UTF-8 (must pass):"
   run g 0 env -u LC_ALL LANG=en_US.UTF-8 scripts/check-index.sh ;;
h) hdr "h (tracked files are git ls-files: an ignored stray passes, an untracked standard is refused, a standard in a three-way merge conflict is listed once)"
   mk h; touch "$NEG/h/base/.DS_Store" || die "h: touch"
   note "untracked, ignored base/.DS_Store present (must pass):"
   run h 0 git status --short --ignored base
   run h 0 scripts/check-index.sh
   printf '# New\n\nA standard never git-added.\n' > "$NEG/h/base/process/new.md" || die "h: new.md"
   note "untracked base/process/new.md with no index entry (must fail: under base/ but not tracked):"
   run h 0 git status --short base
   run h 1 $'FAIL  under base/ but not tracked (git add it, or keep it out of base/):\n        base/process/new.md' scripts/check-index.sh
   printf '  process/new:\n    description: never added\n' >> "$NEG/h/index.yml" || die "h: index entry"
   note "the same file with its index entry (must fail: not tracked, and the entry has no tracked file):"
   run h 1 $'FAIL  under base/ but not tracked (git add it, or keep it out of base/):\n        base/process/new.md\nFAIL  in index.yml but not tracked under base/:\n        process/new' scripts/check-index.sh
   mk hc; printf '# Conflict\n\nA standard.\n' > "$NEG/hc/base/process/conflict.md" || die "h: conflict.md"
   printf '  process/conflict:\n    description: in conflict\n' >> "$NEG/hc/index.yml" || die "h: index entry"; git -C "$NEG/hc" add index.yml || die "h: add index"
   ch=$(git -C "$NEG/hc" hash-object -w base/process/conflict.md) || die "h: hash-object"
   printf '100644 %s 1\tbase/process/conflict.md\n100644 %s 2\tbase/process/conflict.md\n100644 %s 3\tbase/process/conflict.md\n' "$ch" "$ch" "$ch" |
     git -C "$NEG/hc" update-index --index-info || die "h: index-info"
   note "a fresh copy with base/process/conflict.md indexed and in a three-way merge conflict, its index entry at stages 1, 2 and 3 (must pass: the path is listed once):"
   run hc 0 git ls-files -s base/process/conflict.md
   run hc 0 scripts/check-index.sh
   if old_file hc 11ceffd scripts/check-index.sh; then
     note "the script at 11ceffd (main before the eleventh spec) on the same: sorted without -u, the three stages leave two copies of the entry unmatched, reported missing (the bug):"
     run hc 1 $'FAIL  tracked under base/ but not in index.yml:\n        process/conflict' scripts/check-index-11ceffd.sh
     only process/conflict process/conflict
   fi ;;
i) hdr "i (.pymarkdown.yaml is read: md013 line lengths 60 in the copy; gate.sh must stop at step 2 on MD013, exit 1, 3/3 never reached; a misspelled key is not refused; a value pymarkdown cannot use, and a file YAML cannot parse, each fail step 2 by name)"
   mk i; sed -i.bak 's/line_length: 120/line_length: 60/' "$NEG/i/.pymarkdown.yaml" || die "i: sed"; rm "$NEG/i/.pymarkdown.yaml.bak" || die "i: rm .bak"
   grep -n 'line_length' "$NEG/i/.pymarkdown.yaml" || die "i: line_length not set"
   ( cd "$NEG/i" && scripts/gate.sh > ../i.out 2>&1 ); got=$?
   grep -v 'MD013' "$NEG/i.out" | grep -v '^$'
   echo "   ... $(grep -c MD013 "$NEG/i.out") MD013 findings, Expected: 60, the first three:"
   grep MD013 "$NEG/i.out" | head -3 | sed "s#$NEG/i/##"
   check 1 "$got" $'MD013: Line length [Expected: 60\nFAIL  step 2/3: pymarkdown reported findings, or could not read .pymarkdown.yaml (see above)' "$NEG/i.out"
   note "the same copy with the key misspelled (line_lenght: 60): --strict-config does not refuse an unknown key, so the default 80 applies with no config error; in this tree, wrapped at 100, that still fails step 2 (Expected: 80), so the misspelling cannot pass here silently:"
   sed -i.bak 's/^    line_length: 60/    line_lenght: 60/' "$NEG/i/.pymarkdown.yaml" || die "i: sed misspelling"; rm "$NEG/i/.pymarkdown.yaml.bak" || die "i: rm .bak"
   grep -n 'line_len' "$NEG/i/.pymarkdown.yaml" || die "i: line_len not found"
   ( cd "$NEG/i" && uvx --from "pymarkdownlnt==$(sed -n 's/^PYMARKDOWN_VERSION=//p' scripts/gate.sh)" pymarkdown --strict-config --config .pymarkdown.yaml scan --recurse base README.md > ../i2.out 2>&1 ); got=$?
   echo "   ... $(grep -c MD013 "$NEG/i2.out") MD013 findings, Expected: 80, the first one:"
   grep MD013 "$NEG/i2.out" | head -1 | sed "s#$NEG/i/##"
   check 1 "$got" "MD013: Line length [Expected: 80" "$NEG/i2.out"
   note "the key spelled right again with a value pymarkdown cannot use, line_length: wide (valid YAML; --strict-config refuses it, so step 2 must fail naming the property, exit 1):"
   sed -i.bak 's/^    line_lenght: 60$/    line_length: wide/' "$NEG/i/.pymarkdown.yaml" || die "i: sed wide"; rm "$NEG/i/.pymarkdown.yaml.bak" || die "i: rm .bak"
   grep -n '^    line_length: wide$' "$NEG/i/.pymarkdown.yaml" || die "i: line_length wide not set"
   run i 1 $'The value for property \'plugins.md013.line_length\' must be of type \'int\'.\nFAIL  step 2/3: pymarkdown reported findings, or could not read .pymarkdown.yaml (see above)' scripts/gate.sh
   note "line_length back at 120 and a stray [ appended, a file YAML cannot parse (step 2 must fail naming the file, exit 1; pymarkdown's traceback is elided from the print, not from the check):"
   sed -i.bak 's/^    line_length: wide$/    line_length: 120/' "$NEG/i/.pymarkdown.yaml" || die "i: sed restore"; rm "$NEG/i/.pymarkdown.yaml.bak" || die "i: rm .bak"
   grep -qx '    line_length: 120' "$NEG/i/.pymarkdown.yaml" || die "i: line_length not restored"
   printf '[\n' >> "$NEG/i/.pymarkdown.yaml" || die "i: append ["
   ( cd "$NEG/i" && scripts/gate.sh > ../i3.out 2>&1 ); got=$?
   sed "s#$NEG/\([a-z0-9]*\)#<copy \1>#g" "$NEG/i3.out" | awk '
     /^Traceback / { skip = 1; n = 1; next }
     skip && /^[^ ]/ { skip = 0; print "   ... the traceback, " n " lines, elided" }
     skip { n++; next }
     { print }
     END { if (skip) print "   ... the traceback, " n " lines, elided, to the end of the output" }'
   check 1 "$got" $'/.pymarkdown.yaml\' is not a valid YAML file\nFAIL  step 2/3: pymarkdown reported findings, or could not read .pymarkdown.yaml (see above)' "$NEG/i3.out" ;;
k) hdr "k (a key that is a prefix of another, testing and testing-fakes: the stripped list must be re-sorted before comm)"
   mk k; printf '# T\n\nA standard.\n' > "$NEG/k/base/process/testing.md" || die "k: testing.md"; printf '# TF\n\nA standard.\n' > "$NEG/k/base/process/testing-fakes.md" || die "k: testing-fakes.md"
   printf '  process/testing:\n    description: t\n  process/testing-fakes:\n    description: tf\n' >> "$NEG/k/index.yml" || die "k: index entries"
   git -C "$NEG/k" add -A || die "k: git add"
   note "both indexed (must pass):"
   run k 0 scripts/check-index.sh
   printf '# Z\n\nA standard.\n' > "$NEG/k/base/process/zeta.md" || die "k: zeta.md"; git -C "$NEG/k" add -A || die "k: git add zeta"
   note "zeta.md tracked beside them with no entry (must fail naming process/zeta alone):"
   run k 1 $'FAIL  tracked under base/ but not in index.yml:\n        process/zeta' scripts/check-index.sh
   only process/zeta
   if old_file k cf1bdf0 scripts/check-index.sh; then
     note "the script at cf1bdf0 (PR 7's first head), BSD comm: testing misreported as both missing and stale:"
     run k 1 $'FAIL  tracked under base/ but not in index.yml:\n        process/testing\n        process/zeta\nFAIL  in index.yml but not tracked under base/:\n        process/testing' scripts/check-index-cf1bdf0.sh
     if command -v gcomm >/dev/null; then
       mkdir -p "$NEG/gnu" || die "k: mkdir gnu"; ln -sf "$(command -v gcomm)" "$NEG/gnu/comm" || die "k: ln gcomm"
       note "the same script with GNU comm first on PATH (the ubuntu runner): comm exits 1 on unsorted input, the script reads that as nothing missing, and zeta passes unindexed (the bug, exit 0):"
       run k 0 env PATH="$NEG/gnu:$PATH" scripts/check-index-cf1bdf0.sh
       note "shipped script with GNU comm first on PATH (must fail naming process/zeta alone):"
       run k 1 $'FAIL  tracked under base/ but not in index.yml:\n        process/zeta' env PATH="$NEG/gnu:$PATH" scripts/check-index.sh
       only process/zeta
     fi
   fi ;;
l) hdr "l (a non-ASCII path, base/process/café.md, tracked and indexed; must pass)"
   mk l; printf '# Café\n\nA standard.\n' > "$NEG/l/base/process/café.md" || die "l: café.md"
   printf '  process/café:\n    description: accent\n' >> "$NEG/l/index.yml" || die "l: index entry"; git -C "$NEG/l" add -A || die "l: git add"
   run l 0 scripts/check-index.sh
   if old_file l cf1bdf0 scripts/check-index.sh; then
     note "the script at cf1bdf0 read the path C-quoted and refused it:"
     run l 1 $'FAIL  not a standard (only .md files belong under base/):\n        "base/process/caf\\303\\251.md"' scripts/check-index-cf1bdf0.sh
   fi ;;
m) hdr "m (check-index.sh asks git for the top: the copy entered through its path in upper case passes; a corrupt index, a copy that is not a git work tree, the same copy inside another repository's work tree, under another repository's .git/ and in a bare repository each fail by name, not with a bare exit)"
   mk m
   if upper; then
     note "the copy entered through its path in upper case (this file system is case-insensitive; must pass, exit 0):"
     upper_run m 0 scripts/check-index.sh
     if old_file m 11ceffd scripts/check-index.sh; then
       note "the script at 11ceffd (main before the eleventh spec) on the same: pwd -P and git's top compared as strings, the root refused (the bug):"
       upper_run m 1 "FAIL  not a git work tree rooted at <COPY M> (the files under base/ are read with git ls-files)" scripts/check-index-11ceffd.sh
       rm "$NEG/m/scripts/check-index-11ceffd.sh" || die "m: rm old script"
     fi
   fi
   cp "$NEG/m/.git/index" "$NEG/m-index" || die "m: save index"
   printf 'garbage' > "$NEG/m/.git/index" || die "m: corrupt index"
   note "the copy's index overwritten with garbage, so git cannot list (must fail naming the listing, exit 1):"
   run m 1 $'index file smaller than expected\nFAIL  git could not list the files under base/ (see above)' scripts/check-index.sh
   if old_file m 11ceffd scripts/check-index.sh; then
     note "the script at 11ceffd on the same: set -e ends it at the listing with git's status, 128, and no FAIL line (the bug):"
     run m 128 "index file smaller than expected" scripts/check-index-11ceffd.sh
     rm "$NEG/m/scripts/check-index-11ceffd.sh" || die "m: rm old script"
   fi
   cp "$NEG/m-index" "$NEG/m/.git/index" || die "m: restore index"
   run m 0 scripts/check-index.sh
   rm -rf "$NEG/m/.git" || die "m: rm .git"
   note "the copy's .git removed (must fail by name, exit 1):"
   run m 1 "FAIL  not a git work tree rooted at <copy m> (the files under base/ are read with git ls-files)" scripts/check-index.sh
   mkdir "$NEG/mo" || die "m: mkdir mo"; git -c init.defaultBranch=main -C "$NEG/mo" init -q || die "m: git init mo"
   cp -R "$NEG/m" "$NEG/mo/copy" || die "m: cp into mo"
   note "the same copy, still without .git, inside another repository's work tree (<copy mo>, nothing tracked there; must fail by name, exit 1):"
   run mo/copy 1 "FAIL  not a git work tree rooted at <copy mo>/copy (the files under base/ are read with git ls-files)" scripts/check-index.sh
   mkdir "$NEG/mg" || die "m: mkdir mg"; git -c init.defaultBranch=main -C "$NEG/mg" init -q || die "m: git init mg"
   cp -R "$NEG/m" "$NEG/mg/.git/tree" || die "m: cp into mg/.git"
   git init -q --bare "$NEG/mb.git" || die "m: git init --bare"; cp -R "$NEG/m" "$NEG/mb.git/tree" || die "m: cp into mb.git"
   note "the same copy inside another repository's .git/, where --show-cdup prints nothing but git is in no work tree (must fail by name, exit 1):"
   run mg/.git/tree 1 "FAIL  not a git work tree rooted at <copy mg>/.git/tree (the files under base/ are read with git ls-files)" scripts/check-index.sh
   if old_file mg/.git/tree 00cf7ca scripts/check-index.sh; then
     note "the script at 00cf7ca (PR 23's first head) on the same: --show-cdup alone passes the root guard, and the listing fails, for another reason (the bug):"
     run mg/.git/tree 1 "FAIL  git could not list the files under base/ (see above)" scripts/check-index-00cf7ca.sh
   fi
   note "the same copy inside a bare repository (must fail by name, exit 1):"
   run mb.git/tree 1 "FAIL  not a git work tree rooted at <copy mb>.git/tree (the files under base/ are read with git ls-files)" scripts/check-index.sh ;;
n) hdr "n (a tracked standard deleted from disk, deletion not staged; check-index.sh must fail)"
   mk n; rm "$NEG/n/base/process/ownership.md" || die "n: rm"
   run n 0 git status --short base
   run n 1 $'FAIL  tracked but missing on disk (stage the deletion, or restore the file):\n        base/process/ownership.md' scripts/check-index.sh ;;
w) hdr "w (step 1 lists files with git: an ignored scripts/.DS_Store passes; the copy entered through its path in upper case passes; a script in a three-way merge conflict is listed once; a corrupt index, a git that refuses step 1's listing of scripts/, and a mktemp that makes no directory, are each refused by name; a tracked scripts/notes.txt is refused by name; a tracked script deleted from the disk, and a tracked symlink to nothing, are each refused by name; a copy that is not a git work tree, and the same copy inside another repository's work tree, under another repository's .git/ and in a bare repository, are each refused by name)"
   mk w; touch "$NEG/w/scripts/.DS_Store" || die "w: touch"
   note "untracked, ignored scripts/.DS_Store present (must pass, exit 0; the gate never lists it):"
   run w 0 git status --short --ignored scripts
   run w 0 scripts/gate.sh
   if upper; then
     note "the copy entered through its path in upper case (this file system is case-insensitive): step 1 asks git whether this is the top and compares no paths, and step 3's check-index.sh does the same, so the gate must pass, exit 0:"
     upper_run w 0 scripts/gate.sh
     if old_file w 11ceffd scripts/gate.sh; then
       note "the gate at 11ceffd (main before the eleventh spec) on the same: step 1 compares pwd -P with git's top as strings and refuses the repository's own root (the bug):"
       upper_run w 1 "FAIL  step 1/3: not a git work tree rooted at <COPY W>; the gate lists files with git ls-files" scripts/gate-11ceffd.sh
       rm "$NEG/w/scripts/gate-11ceffd.sh" || die "w: rm old gate"
     fi
   fi
   printf '#!/usr/bin/env bash\necho conflict\n' > "$NEG/w/scripts/conflict.sh" || die "w: conflict.sh"
   ch=$(git -C "$NEG/w" hash-object -w scripts/conflict.sh) || die "w: hash-object"
   printf '100755 %s 1\tscripts/conflict.sh\n100755 %s 2\tscripts/conflict.sh\n100755 %s 3\tscripts/conflict.sh\n' "$ch" "$ch" "$ch" |
     git -C "$NEG/w" update-index --index-info || die "w: index-info"
   note "scripts/conflict.sh in a three-way merge conflict, its index entry at stages 1, 2 and 3 (step 1 must list it once, and the gate pass, exit 0):"
   run w 0 git ls-files -s scripts/conflict.sh
   run w 0 scripts/gate.sh
   times 1 'ok   scripts/conflict.sh'
   if old_file w 11ceffd scripts/gate.sh; then
     note "the gate at 11ceffd on the same: listed without -u, the path is parsed, printed and counted three times (the bug):"
     run w 0 scripts/gate-11ceffd.sh
     times 3 'ok   scripts/conflict.sh'
     rm "$NEG/w/scripts/gate-11ceffd.sh" || die "w: rm old gate"
   fi
   git -C "$NEG/w" rm -q --cached scripts/conflict.sh || die "w: rm conflict"; rm "$NEG/w/scripts/conflict.sh" || die "w: rm conflict file"
   cp "$NEG/w/.git/index" "$NEG/w-index" || die "w: save index"
   printf 'garbage' > "$NEG/w/.git/index" || die "w: corrupt index"
   note "the copy's index overwritten with garbage, so git cannot list (must fail at step 1 naming its first listing, of the tracked files a .gitignore ignores, exit 1, 2/3 never printed):"
   run w 1 $'index file smaller than expected\nFAIL  step 1/3: git could not list the tracked files a .gitignore ignores (see above)' scripts/gate.sh
   if old_file w 11ceffd scripts/gate.sh; then
     note "the gate at 11ceffd on the same: the listing's failure is lost in the process substitution, and step 1 says git lists no file (the bug):"
     run w 1 "FAIL  step 1/3: git lists no file under scripts/" scripts/gate-11ceffd.sh
     rm "$NEG/w/scripts/gate-11ceffd.sh" || die "w: rm old gate"
   fi
   cp "$NEG/w-index" "$NEG/w/.git/index" || die "w: restore index"
   run w 0 git status --short scripts
   shim
   note "a git on PATH that refuses step 1's listing of scripts/ alone, every other call the real git, so the listing of the tracked files a .gitignore ignores passes first (must fail at step 1 naming the scripts/ listing, exit 1, 2/3 never printed):"
   run w 1 $'git (test shim): refusing\nFAIL  step 1/3: git could not list the files under scripts/ (see above)' env PATH="$NEG/shim:$PATH" GATE_TEST_REFUSE=' --exclude-standard -- scripts ' scripts/gate.sh
   mkdir -p "$NEG/nomktemp" || die "w: mkdir nomktemp"
   printf '#!/usr/bin/env bash\necho "mktemp (test shim): refusing" >&2; exit 1\n' > "$NEG/nomktemp/mktemp" || die "w: write mktemp shim"
   chmod +x "$NEG/nomktemp/mktemp" || die "w: chmod mktemp shim"
   note "a mktemp on PATH that makes no directory, so step 1 has nowhere to write git's listings (must fail at step 1 by name, exit 1, 2/3 never printed):"
   run w 1 $'mktemp (test shim): refusing\nFAIL  step 1/3: mktemp -d made no temporary directory for git\'s listings (see above)' env PATH="$NEG/nomktemp:$PATH" scripts/gate.sh
   printf 'a note\n' > "$NEG/w/scripts/notes.txt" || die "w: notes"; git -C "$NEG/w" add scripts/notes.txt || die "w: add notes"
   note "scripts/notes.txt tracked, neither .sh nor a bash shebang (must fail at step 1 naming it, exit 1, 2/3 never printed):"
   run w 1 "FAIL  step 1/3: scripts/notes.txt is not a shell script; only shell scripts live under scripts/" scripts/gate.sh
   git -C "$NEG/w" rm -q --cached scripts/notes.txt || die "w: rm notes"; rm "$NEG/w/scripts/notes.txt" || die "w: rm notes file"
   rm "$NEG/w/scripts/gate-negative-tests.sh" || die "w: rm harness copy"
   note "scripts/gate-negative-tests.sh tracked but deleted from the disk, deletion not staged (must fail at step 1 naming it, exit 1):"
   run w 0 git status --short scripts
   run w 1 "FAIL  step 1/3: scripts/gate-negative-tests.sh is tracked but missing from the disk" scripts/gate.sh
   git -C "$NEG/w" checkout -q -- scripts/gate-negative-tests.sh || die "w: restore"
   ln -s nowhere.sh "$NEG/w/scripts/dangling.sh" || die "w: ln dangling"; git -C "$NEG/w" add scripts/dangling.sh || die "w: add dangling"
   note "scripts/dangling.sh tracked, a symlink to nothing (must fail at step 1 naming it as one, not as missing from the disk, exit 1):"
   run w 1 "FAIL  step 1/3: scripts/dangling.sh is a symlink to nothing" scripts/gate.sh
   git -C "$NEG/w" rm -q --cached scripts/dangling.sh || die "w: rm dangling"; rm "$NEG/w/scripts/dangling.sh" || die "w: rm dangling link"
   rm -rf "$NEG/w/.git" || die "w: rm .git"
   note "the copy's .git removed (must fail at step 1 by name, exit 1):"
   run w 1 "FAIL  step 1/3: not a git work tree rooted at <copy w>; the gate lists files with git ls-files" scripts/gate.sh
   mkdir "$NEG/wo" || die "w: mkdir wo"; git -c init.defaultBranch=main -C "$NEG/wo" init -q || die "w: git init wo"
   cp -R "$NEG/w" "$NEG/wo/copy" || die "w: cp into wo"
   note "the same copy, still without .git, inside another repository's work tree (<copy wo>, nothing tracked there): git's work-tree top is the outer repository, not the copy:"
   run wo/copy 0 git rev-parse --show-toplevel
   note "the shipped script on it (must fail at step 1 by name, exit 1, no file listed against the outer repository):"
   run wo/copy 1 "FAIL  step 1/3: not a git work tree rooted at <copy wo>/copy; the gate lists files with git ls-files" scripts/gate.sh
   if old_file wo/copy a5f88ae scripts/gate.sh; then
     note "the script at a5f88ae (PR 11's first head) on the same: step 1 lists the copy's files as the outer repository's untracked ones and passes; only check-index.sh's own guard, at step 3, stops it (the bug):"
     run wo/copy 1 $'ok   scripts/sync-standards.sh\nFAIL  not a git work tree rooted at <copy wo>/copy\nFAIL  step 3/3' scripts/gate-a5f88ae.sh
   fi
   mkdir "$NEG/wg" || die "w: mkdir wg"; git -c init.defaultBranch=main -C "$NEG/wg" init -q || die "w: git init wg"
   cp -R "$NEG/w" "$NEG/wg/.git/tree" || die "w: cp into wg/.git"
   git init -q --bare "$NEG/wb.git" || die "w: git init --bare"; cp -R "$NEG/w" "$NEG/wb.git/tree" || die "w: cp into wb.git"
   note "the same copy, still without .git, inside another repository's .git/ (<copy wg>/.git/tree), where git rev-parse --show-cdup prints nothing but git is in no work tree (must fail at step 1 by name, exit 1):"
   run wg/.git/tree 0 git rev-parse --is-inside-work-tree --show-cdup
   run wg/.git/tree 1 "FAIL  step 1/3: not a git work tree rooted at <copy wg>/.git/tree; the gate lists files with git ls-files" scripts/gate.sh
   if old_file wg/.git/tree 00cf7ca scripts/gate.sh; then
     note "the gate at 00cf7ca (PR 23's first head) on the same: --show-cdup alone passes the root guard, and step 1 fails at the listing, for another reason (the bug):"
     run wg/.git/tree 1 "FAIL  step 1/3: git could not list the tracked files git ignores (see above)" scripts/gate-00cf7ca.sh
   fi
   note "the same copy inside a bare repository (<copy wb>.git/tree; must fail at step 1 by name, exit 1):"
   run wb.git/tree 0 git rev-parse --is-inside-work-tree --show-cdup
   run wb.git/tree 1 "FAIL  step 1/3: not a git work tree rooted at <copy wb>.git/tree; the gate lists files with git ls-files" scripts/gate.sh ;;
x) hdr "x (not run as the gate: --help and a stray argument each exit 2 with the usage line and run no step; a script that cannot enter the repository root exits 2 saying so; the clean copy exits 0)"
   mk x
   note "clean copy (must pass, exit 0):"
   run x 0 scripts/gate.sh
   note "--help (exit 2, no step banner):"
   run x 2 "usage: scripts/gate.sh   (no arguments; exits 1 at the first failing step, 2 on usage)" scripts/gate.sh --help
   note "a stray argument (exit 2):"
   run x 2 "usage: scripts/gate.sh   (no arguments; exits 1 at the first failing step, 2 on usage)" scripts/gate.sh x
   note "the copy's gate.sh run as bash -c with \$0 under a directory that does not exist, so its cd to the repository root fails (exit 2 saying so, no step banner):"
   run x 2 "gate: cannot enter the repository root, <copy x>/nowhere/scripts/..; not run as the gate" bash -c "$(cat "$NEG/x/scripts/gate.sh")" "$NEG/x/nowhere/scripts/gate.sh" ;;
y) hdr "y (step 2 lists with git: an ignored base/process/draft.md with a lint finding is never linted; the same file force-added under the copy's .gitignore is refused at step 1 by name, and with a second such file both are named under one FAIL line; a force-added file under a directory no step reads passes; matched only by .git/info/exclude or a global excludes file, the machine's own, the draft passes step 1 and step 2 lints it; untracked with no pattern matching it, git lists it and step 2 lints it; a git that refuses step 2's listing, and a tracked standard deleted from the disk, are each refused by name)"
   F1IGN="FAIL  step 1/3: tracked, but a .gitignore ignores them; stop ignoring each (a ! pattern, and for a file under an ignored directory, ignore dir/* rather than dir/ first) or stop tracking it (git rm --cached):"
   mk y; printf 'base/process/draft.md\n' >> "$NEG/y/.gitignore" || die "y: ignore draft"
   printf '# draft\ntext right under the heading with a trailing space \n' > "$NEG/y/base/process/draft.md" || die "y: draft.md"
   note "base/process/draft.md, with two findings, ignored through the copy's .gitignore (must pass, exit 0; step 2 never lints it, step 3 never sees it):"
   run y 0 git status --short --ignored base
   run y 0 scripts/gate.sh
   if old_file y a5f88ae scripts/gate.sh; then
     note "the script at a5f88ae (PR 11's first head) on the same: pymarkdown --recurse walks the disk, lints the ignored draft and fails step 2 (the bug):"
     run y 1 $'base/process/draft.md:2:\nFAIL  step 2/3' scripts/gate-a5f88ae.sh
     rm "$NEG/y/scripts/gate-a5f88ae.sh" || die "y: rm old script"
   fi
   git -C "$NEG/y" add -f base/process/draft.md || die "y: add draft"
   note "the same file force-added: git lists it as tracked, and the copy's .gitignore still matches it, so a tool that reads .gitignore itself would skip it (must fail at step 1 naming it alone, exit 1, 2/3 never printed):"
   run y 0 git ls-files --cached --ignored --exclude-per-directory=.gitignore
   run y 1 "$F1IGN" scripts/gate.sh
   only base/process/draft.md
   if old_file y 11ceffd scripts/gate.sh; then
     note "the gate at 11ceffd (main before the eleventh spec) on the same: step 1 passes, and step 2 lints a file that a tool reading .gitignore would have skipped (the state the refusal closes):"
     run y 1 $'ok   scripts/sync-standards.sh\nbase/process/draft.md:2:51: MD009: Trailing spaces\nFAIL  step 2/3' scripts/gate-11ceffd.sh
     rm "$NEG/y/scripts/gate-11ceffd.sh" || die "y: rm old gate"
   fi
   printf 'scripts/local.sh\n' >> "$NEG/y/.gitignore" || die "y: ignore local.sh"
   printf '#!/usr/bin/env bash\necho local\n' > "$NEG/y/scripts/local.sh" || die "y: local.sh"; git -C "$NEG/y" add -f scripts/local.sh || die "y: add local.sh"
   note "a second file force-added, scripts/local.sh, under a line of its own in the copy's .gitignore (must fail at step 1 naming both under one FAIL line, exit 1):"
   run y 1 "$F1IGN" scripts/gate.sh
   only base/process/draft.md scripts/local.sh
   if old_file y 00cf7ca scripts/gate.sh; then
     note "the gate at 00cf7ca (PR 23's first head) on the same: it stops at the first file and names it alone, so a tree with two such files takes two runs to see them (the bug):"
     run y 1 "FAIL  step 1/3: base/process/draft.md is tracked but git ignores it" scripts/gate-00cf7ca.sh
     rm "$NEG/y/scripts/gate-00cf7ca.sh" || die "y: rm old gate"
   fi
   git -C "$NEG/y" rm -q --cached scripts/local.sh base/process/draft.md || die "y: rm local.sh and draft"; rm "$NEG/y/scripts/local.sh" || die "y: rm local.sh file"
   sed -i.bak '/^scripts\/local\.sh$/d' "$NEG/y/.gitignore" || die "y: sed .gitignore"; rm "$NEG/y/.gitignore.bak" || die "y: rm .bak"
   printf 'vendor/\n' >> "$NEG/y/.gitignore" || die "y: ignore vendor"
   mkdir "$NEG/y/vendor" || die "y: mkdir vendor"; printf 'x\n' > "$NEG/y/vendor/x.txt" || die "y: vendor/x.txt"; git -C "$NEG/y" add -f vendor/x.txt || die "y: add vendor"
   note "vendor/x.txt force-added under an ignored vendor/, a directory no gate step reads (must pass, exit 0: the refusal reads only the paths the gate's listings read):"
   run y 0 git ls-files --cached --ignored --exclude-per-directory=.gitignore
   run y 0 scripts/gate.sh
   if old_file y 00cf7ca scripts/gate.sh; then
     note "the gate at 00cf7ca on the same: its refusal reads the whole tree and fails a file no step reads (the bug):"
     run y 1 "FAIL  step 1/3: vendor/x.txt is tracked but git ignores it" scripts/gate-00cf7ca.sh
     rm "$NEG/y/scripts/gate-00cf7ca.sh" || die "y: rm old gate"
   fi
   git -C "$NEG/y" rm -q --cached vendor/x.txt || die "y: rm vendor"; rm -r "$NEG/y/vendor" || die "y: rm vendor dir"
   sed -i.bak -e '/^vendor\/$/d' -e '/^base\/process\/draft\.md$/d' "$NEG/y/.gitignore" || die "y: sed .gitignore"; rm "$NEG/y/.gitignore.bak" || die "y: rm .bak"
   grep -q 'draft\|vendor' "$NEG/y/.gitignore" && die "y: draft or vendor still in .gitignore"
   printf 'base/process/draft.md\n' >> "$NEG/y/.git/info/exclude" || die "y: info/exclude"
   git -C "$NEG/y" add -f base/process/draft.md || die "y: add draft again"
   note "the ignore line moved from .gitignore to .git/info/exclude, the clone's own file, and the draft force-added again: step 1 reads committed .gitignore files alone, so it passes, and step 2 lints the draft (must fail at step 2 on its findings, exit 1):"
   run y 0 git check-ignore -v --no-index base/process/draft.md
   run y 1 $'ok   scripts/sync-standards.sh\nbase/process/draft.md:2:51: MD009: Trailing spaces\nFAIL  step 2/3' scripts/gate.sh
   if old_file y 00cf7ca scripts/gate.sh; then
     note "the gate at 00cf7ca on the same: it reads .git/info/exclude too, so this clone refuses a file another clone passes (the bug):"
     run y 1 "FAIL  step 1/3: base/process/draft.md is tracked but git ignores it" scripts/gate-00cf7ca.sh
     rm "$NEG/y/scripts/gate-00cf7ca.sh" || die "y: rm old gate"
   fi
   sed -i.bak '/^base\/process\/draft\.md$/d' "$NEG/y/.git/info/exclude" || die "y: sed info/exclude"; rm "$NEG/y/.git/info/exclude.bak" || die "y: rm .bak"
   grep -q 'draft' "$NEG/y/.git/info/exclude" && die "y: draft still in info/exclude"
   printf 'base/process/draft.md\n' > "$NEG/y-global-ignore" || die "y: global ignore"
   printf '[core]\n\texcludesFile = %s\n' "$NEG/y-global-ignore" > "$NEG/y-gitconfig" || die "y: global config"
   note "the same with only a global excludes file matching the draft (GIT_CONFIG_GLOBAL at a scratch config naming it, the developer's own): step 1 passes, and step 2 lints the draft (must fail at step 2 on its findings, exit 1):"
   run y 0 env GIT_CONFIG_GLOBAL="$NEG/y-gitconfig" git check-ignore -v --no-index base/process/draft.md
   run y 1 $'ok   scripts/sync-standards.sh\nbase/process/draft.md:2:51: MD009: Trailing spaces\nFAIL  step 2/3' env GIT_CONFIG_GLOBAL="$NEG/y-gitconfig" scripts/gate.sh
   if old_file y 00cf7ca scripts/gate.sh; then
     note "the gate at 00cf7ca on the same: it reads the global excludes file too, so this developer's gate refuses a file CI passes (the bug):"
     run y 1 "FAIL  step 1/3: base/process/draft.md is tracked but git ignores it" env GIT_CONFIG_GLOBAL="$NEG/y-gitconfig" scripts/gate-00cf7ca.sh
     rm "$NEG/y/scripts/gate-00cf7ca.sh" || die "y: rm old gate"
   fi
   git -C "$NEG/y" rm -q --cached base/process/draft.md || die "y: rm draft again"
   note "no pattern matches the file now: untracked and not ignored, git lists it, so step 2 lints it (must fail at step 2 on its findings, exit 1, 3/3 never printed):"
   run y 0 git status --short --ignored base
   run y 1 $'base/process/draft.md:2:51: MD009: Trailing spaces\nFAIL  step 2/3: pymarkdown reported findings, or could not read .pymarkdown.yaml (see above)' scripts/gate.sh
   rm "$NEG/y/base/process/draft.md" || die "y: rm draft file"
   shim
   note "a git on PATH that refuses step 2's listing of base/ and README.md alone, every other call the real git (must fail at step 2 naming the listing, exit 1, 3/3 never printed):"
   run y 1 $'ok   scripts/sync-standards.sh\ngit (test shim): refusing\nFAIL  step 2/3: git could not list the files under base/ and README.md (see above)' env PATH="$NEG/shim:$PATH" GATE_TEST_REFUSE=' -- base README.md ' scripts/gate.sh
   if old_file y 11ceffd scripts/gate.sh; then
     note "the gate at 11ceffd on the same: the listing's failure is lost, and step 2 says git lists no .md file (the bug):"
     run y 1 "FAIL  step 2/3: git lists no .md file under base/ or README.md" env PATH="$NEG/shim:$PATH" GATE_TEST_REFUSE=' -- base README.md ' scripts/gate-11ceffd.sh
     rm "$NEG/y/scripts/gate-11ceffd.sh" || die "y: rm old gate"
   fi
   rm "$NEG/y/base/process/ownership.md" || die "y: rm ownership.md"
   note "base/process/ownership.md tracked but deleted from the disk, deletion not staged (must fail at step 2 naming it, exit 1, before pymarkdown runs):"
   run y 1 "FAIL  step 2/3: base/process/ownership.md is tracked but missing from the disk" scripts/gate.sh ;;
z) hdr "z (step 2 installs the pinned pymarkdown as itself: the clean copy shows the install's ok line before the lint's; uvx missing from PATH is refused by name; a pin naming a version never published fails as the install, pymarkdown never linting, 3/3 never printed)"
   mk z
   note "clean copy (must pass, exit 0, the install's ok line before the lint's):"
   ( cd "$NEG/z" && scripts/gate.sh ) > "$NEG/run.raw" 2>&1; got=$?
   shown "$NEG/run.raw"
   check 0 "$got" $'ok   pymarkdownlnt==
ok   no findings' "$NEG/run.out"
   env PATH=/usr/bin:/bin bash -c 'command -v uvx' >/dev/null 2>&1 && die "z: uvx is on /usr/bin:/bin, so PATH cannot hide it"
   for c in bash dirname git sort head grep; do
     env PATH=/usr/bin:/bin bash -c "command -v $c" >/dev/null 2>&1 || die "z: $c is not on /usr/bin:/bin"
   done
   note "PATH=/usr/bin:/bin, where git and bash are and uvx is not (step 1 must pass, then step 2 must fail naming uvx, exit 1):"
   run z 1 $'ok   scripts/sync-standards.sh\nFAIL  step 2/3: uvx is not on PATH; step 2 runs the pinned pymarkdown through it' env PATH=/usr/bin:/bin scripts/gate.sh
   sed -i.bak 's/^PYMARKDOWN_VERSION=.*$/PYMARKDOWN_VERSION=0.9.999/' "$NEG/z/scripts/gate.sh" || die "z: sed pin"; rm "$NEG/z/scripts/gate.sh.bak" || die "z: rm .bak"
   grep -qx 'PYMARKDOWN_VERSION=0.9.999' "$NEG/z/scripts/gate.sh" || die "z: pin not rewritten"
   note "the copy's pin set to 0.9.999, a version never published (step 2 must fail as the install, exit 1, pymarkdown never linting, 3/3 never printed; why uvx refused it is uv's to say, and is not asserted):"
   run z 0 grep -n '^PYMARKDOWN_VERSION=' scripts/gate.sh
   run z 1 "FAIL  step 2/3: uvx could not install pymarkdownlnt==0.9.999, the pinned version, or pymarkdown would not start (see above)" scripts/gate.sh ;;
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
   replay() {  # replay <name> <expected status> [<expected text>]: the workflow's steps against the copy
     local c=$1 want=$2 text=${3:-} got
     uv run --quiet --no-project --with pyyaml python -u - "$NEG/$c" .github/workflows/gate.yml > "$NEG/run.raw" 2>&1 <<'PY'
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
     got=$?
     shown "$NEG/run.raw"
     check "$want" "$got" "$text" "$NEG/run.out"
   }
   note "j1, clean copy (the job must pass):"; replay j1 0
   note "j2, scripts/broken.sh added as in test f (gate.sh fails at step 1, exit 1, so the job must fail):"
   replay j2 1 $'FAIL  step 1/3: scripts/broken.sh does not parse\njob: FAILED at step 3' ;;
o) hdr "o (first sync of a consuming project: refused without --init; the sibling default; --init pins origin/main, not HEAD, creates the base: section and installs the script; an explicit ref off origin/main is warned about; a path inside the checkout resolves to its top)"
   mk_upstream o/patchbay-standards; mk_project o/project
   note "no base: section and no --init (must fail, exit 2, nothing written):"
   run o/project 2 "FAIL  agent-os/standards/index.yml has no base: section; a first sync passes --init to create it" ../patchbay-standards/scripts/sync-standards.sh
   run o/project 0 git status --short
   note "no sibling checkout: the same project copied elsewhere, --init from the checkout's copy (must fail naming ../patchbay-standards, exit 2):"
   mkdir "$NEG/o/elsewhere" || die "o: mkdir elsewhere"; cp -R "$NEG/o/project" "$NEG/o/elsewhere/project" || die "o: cp project"
   run o/elsewhere/project 2 "FAIL  ../patchbay-standards is not a git checkout; pass the path to a patchbay-standards checkout" "$NEG/o/patchbay-standards/scripts/sync-standards.sh" --init
   note "the checkout's HEAD one empty commit ahead of origin/main; --init from the sibling checkout, the default path and ref (must pass and pin origin/main):"
   commit o/patchbay-standards "not pushed"
   run o/project 0 ../patchbay-standards/scripts/sync-standards.sh --init
   note "the pinned commit is origin/main, not HEAD:"
   run o/project 0 cat agent-os/standards/base/.version
   run o/patchbay-standards 0 git rev-parse origin/main HEAD
   note "the index is the hand-built expected one, own sections byte for byte (cmp must pass); base/ is the commit's base/ plus .version; the script is the commit's:"
   expected_index o/patchbay-standards > "$NEG/o/expected.yml" || die "o: expected index"
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
   printf '\nAn uncommitted edit.\n' >> "$NEG/p/patchbay-standards/base/process/ownership.md" || die "p: edit"
   run p/patchbay-standards 0 git status --short
   git -C "$NEG/p/patchbay-standards" show HEAD:base/process/ownership.md > "$NEG/p/committed.md" || die "p: committed bytes"
   note "sync with the edit uncommitted (must pass with nothing added, removed or changed; the project's file stays the committed bytes):"
   run p/project 0 scripts/sync-standards.sh
   run p/project 0 cmp agent-os/standards/base/process/ownership.md ../committed.md
   run p/project 0 git status --short
   printf '# New\n\nA standard.\n' > "$NEG/p/patchbay-standards/base/process/new.md" || die "p: new.md"
   awk '/^  process\/ownership:/ { print "  process/new:"; print "    description: A new standard" } { print }' "$NEG/p/patchbay-standards/index.yml" > "$NEG/p/index.yml" || die "p: index entry"
   mv "$NEG/p/index.yml" "$NEG/p/patchbay-standards/index.yml" || die "p: mv index"
   git -C "$NEG/p/patchbay-standards" add -A || die "p: git add"; commit p/patchbay-standards "add process/new"; push_upstream p/patchbay-standards
   note "the edit committed and pushed together with base/process/new.md and its entry (must pass: new.md added, ownership.md changed, index replaced with $(entries "$NEG/p/patchbay-standards/index.yml") entries, the upstream index's count, which the project's section must then hold):"
   run p/project 0 scripts/sync-standards.sh
   run p/project 0 grep -n 'process/new' agent-os/standards/index.yml
   run p/project 0 entries agent-os/standards/index.yml
   run p/project 0 git status --short ;;
q) hdr "q (a file removed upstream is removed here, with its entry)"
   mk_upstream q/patchbay-standards; mk_project q/project; first_sync q
   git -C "$NEG/q/patchbay-standards" rm -q base/process/ownership.md || die "q: git rm"
   awk '/^  process\/ownership:/ { skip = 2 } skip > 0 { skip--; next } { print }' "$NEG/q/patchbay-standards/index.yml" > "$NEG/q/index.yml" || die "q: index"
   mv "$NEG/q/index.yml" "$NEG/q/patchbay-standards/index.yml" || die "q: mv index"
   git -C "$NEG/q/patchbay-standards" add -A || die "q: git add"; commit q/patchbay-standards "remove process/ownership"; push_upstream q/patchbay-standards
   note "sync to the removing commit (must pass: ownership.md removed, index replaced with $(entries "$NEG/q/patchbay-standards/index.yml") entries, the upstream index's count, the file gone):"
   run q/project 0 scripts/sync-standards.sh
   run q/project 0 ls agent-os/standards/base/process
   run q/project 0 entries agent-os/standards/index.yml
   run q/project 1 "0" grep -c 'process/ownership' agent-os/standards/index.yml   # 0 matches, grep's own exit 1
   run q/project 0 git status --short ;;
r) hdr "r (own sections survive byte for byte: after --init, a second sync and --index-only; the section goes where the stock ordering puts it, comments staying with their key, at line 1 included; a missing index is created and its line-1 section replaced and regenerated; the trailing comment of the upstream index stays upstream)"
   mk_upstream r/patchbay-standards; mk_project r/project
   printf '\n# end of the base index\n' >> "$NEG/r/patchbay-standards/index.yml" || die "r: trailing comment"
   git -C "$NEG/r/patchbay-standards" add -A || die "r: git add"; commit r/patchbay-standards "a trailing comment"; push_upstream r/patchbay-standards
   note "the upstream index.yml ends with a blank line and a comment, committed and pushed; the section ends at its last indented line, so every expected file below is built by the oracle without them:"
   run r/patchbay-standards 0 tail -3 index.yml
   expected_index r/patchbay-standards > "$NEG/r/expected.yml" || die "r: expected index"
   init_r() { ( cd "$NEG/r/project" && ../patchbay-standards/scripts/sync-standards.sh --init >/dev/null 2>&1 ); check 0 $?; }
   layout() {  # layout <index text>: the project's index set to it, base/ and the script removed, so --init runs fresh
     printf '%s' "$1" > "$NEG/r/project/agent-os/standards/index.yml" || die "r: layout index"
     rm -rf "$NEG/r/project/agent-os/standards/base" "$NEG/r/project/scripts" || die "r: layout rm"; }
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
   { printf 'api:\n  errors:\n    description: One error envelope\n\n'; section_of "$NEG/r/patchbay-standards/index.yml"; printf '\n# zed\nzed:\n  last:\n    description: The last\n'; } > "$NEG/r/expected2.yml" || die "r: expected2"
   init_r; run r/project 0 cmp agent-os/standards/index.yml ../expected2.yml
   note "an index with api: alone (base: is appended after one blank line):"
   layout 'api:
  errors:
    description: One error envelope
'
   { printf 'api:\n  errors:\n    description: One error envelope\n\n'; section_of "$NEG/r/patchbay-standards/index.yml"; } > "$NEG/r/expected3.yml" || die "r: expected3"
   init_r; run r/project 0 cmp agent-os/standards/index.yml ../expected3.yml
   note "an index whose first line is testing: (base: goes on line 1, one blank line, then testing:):"
   layout 'testing:
  fixtures:
    description: f
'
   { section_of "$NEG/r/patchbay-standards/index.yml"; printf '\ntesting:\n  fixtures:\n    description: f\n'; } > "$NEG/r/expected4.yml" || die "r: expected4"
   init_r; run r/project 0 cmp agent-os/standards/index.yml ../expected4.yml
   note "the same with a comment on line 1 directly above testing: (the comment stays with its key; base: goes on line 1):"
   layout '# the index
testing:
  fixtures:
    description: f
'
   { section_of "$NEG/r/patchbay-standards/index.yml"; printf '\n# the index\ntesting:\n  fixtures:\n    description: f\n'; } > "$NEG/r/expected5.yml" || die "r: expected5"
   init_r; run r/project 0 cmp agent-os/standards/index.yml ../expected5.yml
   note "no index file at all (--init creates one holding the section alone, on line 1):"
   layout ''; rm "$NEG/r/project/agent-os/standards/index.yml" || die "r: rm index"
   section_of "$NEG/r/patchbay-standards/index.yml" > "$NEG/r/expected6.yml" || die "r: expected6"
   init_r; run r/project 0 cmp agent-os/standards/index.yml ../expected6.yml
   git -C "$NEG/r/project" add -A || die "r: git add project"; commit r/project "chore: sync base standards"
   sed -i.bak 's/^    description: A person owns every commit/    description: One person owns every commit/' "$NEG/r/patchbay-standards/index.yml" || die "r: reword"; rm "$NEG/r/patchbay-standards/index.yml.bak" || die "r: rm .bak"
   git -C "$NEG/r/patchbay-standards" add -A || die "r: git add reword"; commit r/patchbay-standards "reword a description"; push_upstream r/patchbay-standards
   section_of "$NEG/r/patchbay-standards/index.yml" > "$NEG/r/expected7.yml" || die "r: expected7"
   if old_file r/patchbay-standards 3d3e111 scripts/sync-standards.sh; then
     note "a description reworded upstream, committed and pushed; the script at 3d3e111 (PR 9's first head) syncing it into this line-1 index: BSD head -n 0 exits 1 and the project is left half-synced, .version at the new commit and the index at the old:"
     run r/project 1 "head: illegal line count -- 0" ../patchbay-standards/scripts/sync-standards-3d3e111.sh
     run r/project 0 git status --short
     git -C "$NEG/r/project" checkout -q -- . || die "r: restore project"
   fi
   note "the shipped script on the same (must pass: the line-1 section replaced, cmp against the new section must pass):"
   run r/project 0 scripts/sync-standards.sh
   run r/project 0 cmp agent-os/standards/index.yml ../expected7.yml
   note "a hand edit to the line-1 section, then --index-only (must pass and repair it):"
   sed -i.bak 's/^    description: One person/    description: Hand-edited/' "$NEG/r/project/agent-os/standards/index.yml" || die "r: hand edit"; rm "$NEG/r/project/agent-os/standards/index.yml.bak" || die "r: rm .bak"
   run r/project 0 scripts/sync-standards.sh --index-only
   run r/project 0 cmp agent-os/standards/index.yml ../expected7.yml
   run r/project 0 tail -2 agent-os/standards/index.yml ;;
s) hdr "s (a hand-edited base: entry is drift; --index-only repairs the section and touches nothing else)"
   mk_upstream s/patchbay-standards; mk_project s/project; first_sync s
   sed -i.bak 's/^    description: A person owns every commit.*/    description: Hand-edited here/' "$NEG/s/project/agent-os/standards/index.yml" || die "s: hand edit"
   rm "$NEG/s/project/agent-os/standards/index.yml.bak" || die "s: rm .bak"
   run s/project 0 git diff --stat
   note "--check (must fail: index differs, exit 1):"
   run s/project 1 $'index    base: section differs\nFAIL  drift from patchbay-standards at' scripts/sync-standards.sh --check
   note "--index-only (must pass: section replaced), then --check (must pass) and git status (must be empty: nothing but the section was written):"
   run s/project 0 scripts/sync-standards.sh --index-only
   run s/project 0 scripts/sync-standards.sh --check
   run s/project 0 git status --short ;;
t) hdr "t (the drift check passes after a sync and fails on a one-byte edit, an extra file, a missing file; an ignored stray is not drift; a ref or a missing .version is a usage error; a project index git cannot read is refused by name, exit 2)"
   mk_upstream t/patchbay-standards; mk_project t/project; first_sync t
   note "clean (must pass):"
   run t/project 0 scripts/sync-standards.sh --check
   note "one byte appended to process/ownership.md (must fail naming it, exit 1):"
   printf 'x' >> "$NEG/t/project/agent-os/standards/base/process/ownership.md" || die "t: append"
   run t/project 1 $'changed  process/ownership.md\nFAIL  drift from patchbay-standards at' scripts/sync-standards.sh --check
   git -C "$NEG/t/project" checkout -q -- agent-os/standards/base/process/ownership.md || die "t: restore ownership.md"
   note "an extra file under base/, untracked (must fail: extra):"
   printf '# Extra\n' > "$NEG/t/project/agent-os/standards/base/process/extra.md" || die "t: extra.md"
   run t/project 1 $'extra    process/extra.md\nFAIL  drift from patchbay-standards at' scripts/sync-standards.sh --check
   rm "$NEG/t/project/agent-os/standards/base/process/extra.md" || die "t: rm extra.md"
   note "a tracked file deleted from disk (must fail: missing):"
   rm "$NEG/t/project/agent-os/standards/base/process/standards-index.md" || die "t: rm standards-index.md"
   run t/project 1 $'missing  process/standards-index.md\nFAIL  drift from patchbay-standards at' scripts/sync-standards.sh --check
   git -C "$NEG/t/project" checkout -q -- agent-os/standards/base/process/standards-index.md || die "t: restore standards-index.md"
   note "an ignored .DS_Store under base/ (must pass):"
   touch "$NEG/t/project/agent-os/standards/base/.DS_Store" || die "t: touch"
   run t/project 0 git status --short --ignored agent-os/standards/base
   run t/project 0 scripts/sync-standards.sh --check
   rm "$NEG/t/project/agent-os/standards/base/.DS_Store" || die "t: rm .DS_Store"
   note "--check with a ref (usage, exit 2):"
   run t/project 2 "FAIL  --check takes no ref; it reads the commit in agent-os/standards/base/.version" scripts/sync-standards.sh --check ../patchbay-standards HEAD
   note "--check with no .version (exit 2):"
   mv "$NEG/t/project/agent-os/standards/base/.version" "$NEG/t/version.bak" || die "t: mv .version"
   run t/project 2 "FAIL  agent-os/standards/base/.version is missing; nothing is pinned (run a sync first)" scripts/sync-standards.sh --check
   mv "$NEG/t/version.bak" "$NEG/t/project/agent-os/standards/base/.version" || die "t: restore .version"
   note "--check with a pinned commit the checkout does not have (exit 2):"
   printf '%s\n' 0123456789abcdef0123456789abcdef01234567 > "$NEG/t/project/agent-os/standards/base/.version" || die "t: absent pin"
   run t/project 2 "FAIL  pinned commit 0123456789abcdef0123456789abcdef01234567 is not in <copy t>/patchbay-standards (fetch it)" scripts/sync-standards.sh --check
   git -C "$NEG/t/project" checkout -q -- agent-os/standards/base/.version || die "t: restore pin"
   cp "$NEG/t/project/.git/index" "$NEG/t-index" || die "t: save index"
   printf 'garbage' > "$NEG/t/project/.git/index" || die "t: corrupt index"
   note "the project's index overwritten with garbage, so git cannot list the project's files (--check must fail naming the listing, exit 2, the script's status for a precondition):"
   run t/project 2 $'index file smaller than expected\nFAIL  git could not list the files under agent-os/standards/base (see above)' scripts/sync-standards.sh --check
   if old_file t/project 00cf7ca scripts/sync-standards.sh; then
     note "the script at 00cf7ca (PR 23's first head) on the same: set -e ends it at the listing with git's status, 128, outside its 0, 1 and 2, and no FAIL line (the bug):"
     run t/project 128 "index file smaller than expected" scripts/sync-standards-00cf7ca.sh --check
     rm "$NEG/t/project/scripts/sync-standards-00cf7ca.sh" || die "t: rm old script"
   fi
   cp "$NEG/t-index" "$NEG/t/project/.git/index" || die "t: restore index"
   run t/project 0 git status --short ;;
u) hdr "u (refusals, each exit 2 by name and nothing written: inside patchbay-standards itself, not at a work-tree root (a root typed in upper case is the root, and passes; the project's .git/ is no work tree), a plain directory or another repository as the path, a ref that is not a commit, an unknown flag, two mode flags, a commit whose index.yml has no parseable base: section, no origin/HEAD to default to, a second base: line in the project's index)"
   mk_upstream u/patchbay-standards; mk_project u/project; mkdir "$NEG/u/plain" || die "u: mkdir plain"; first_sync u
   note "run inside the checkout itself, where agent-os/standards/base is a symlink:"
   run u/patchbay-standards 2 "FAIL  agent-os/standards/base is a symlink: this is patchbay-standards itself, not a consuming project" scripts/sync-standards.sh --init .
   note "run from a folder below the project's root:"
   run u/project/agent-os 2 "FAIL  run from the consuming project's root, the top of its git work tree (here: <copy u>/project/agent-os)" ../../patchbay-standards/scripts/sync-standards.sh ../../patchbay-standards
   if upper; then
     note "the project's root entered through its path in upper case (this file system is case-insensitive): the root is asked of git, so --check must pass, exit 0:"
     upper_run u/project 0 scripts/sync-standards.sh --check
     if old_file u/project 11ceffd scripts/sync-standards.sh; then
       note "the script at 11ceffd (main before the eleventh spec) on the same: pwd -P and git's top compared as strings, the root refused (the bug):"
       upper_run u/project 2 "FAIL  run from the consuming project's root, the top of its git work tree (here: <COPY U>/PROJECT)" scripts/sync-standards-11ceffd.sh --check
       rm "$NEG/u/project/scripts/sync-standards-11ceffd.sh" || die "u: rm old script"
     fi
   fi
   note "run from the project's .git/, where --show-cdup prints nothing but git is in no work tree (must fail, exit 2, nothing written into .git/):"
   run u/project/.git 2 "FAIL  run from the consuming project's root, the top of its git work tree (here: <copy u>/project/.git)" ../scripts/sync-standards.sh --init ../../patchbay-standards HEAD
   run u/project 0 find .git -maxdepth 1 -name agent-os
   times 0 '.git/agent-os'
   if old_file u/project 00cf7ca scripts/sync-standards.sh; then
     note "the script at 00cf7ca (PR 23's first head) on the same: --show-cdup alone passes the root guard, agent-os/standards/ is written into .git/, and the script dies bare at a project-side git call (the bug):"
     run u/project/.git 128 "fatal: this operation must be run in a work tree" ../scripts/sync-standards-00cf7ca.sh --init ../../patchbay-standards HEAD
     run u/project 0 find .git -maxdepth 1 -name agent-os
     times 1 '.git/agent-os'
     rm -rf "$NEG/u/project/.git/agent-os" "$NEG/u/project/scripts/sync-standards-00cf7ca.sh" || die "u: rm what the old script wrote"
   fi
   note "a plain directory as the path:"
   run u/project 2 "FAIL  ../plain is not a git checkout; pass the path to a patchbay-standards checkout" scripts/sync-standards.sh ../plain
   note "a git checkout that is not patchbay-standards (the project itself):"
   run u/project 2 "FAIL  <copy u>/project is not a patchbay-standards checkout at" scripts/sync-standards.sh . HEAD
   note "a ref that is not a commit:"
   run u/project 2 "FAIL  no-such-ref is not a commit in <copy u>/patchbay-standards" scripts/sync-standards.sh ../patchbay-standards no-such-ref
   note "an unknown flag:"
   run u/project 2 "FAIL  unknown flag --frobnicate" scripts/sync-standards.sh --frobnicate
   note "two mode flags:"
   run u/project 2 "FAIL  one mode per run: --check and --index-only both given" scripts/sync-standards.sh --check --index-only
   printf 'base: {}\n' > "$NEG/u/patchbay-standards/index.yml" || die "u: base: {}"
   git -C "$NEG/u/patchbay-standards" add -A || die "u: git add"; commit u/patchbay-standards "an index with no section"
   note "a commit whose index.yml is base: {} (the checkout's HEAD, not pushed): refused before anything is written, so git status stays empty:"
   run u/project 2 "has no parseable base: section (state: unparseable); nothing written" scripts/sync-standards.sh ../patchbay-standards HEAD
   run u/project 0 git status --short
   git -C "$NEG/u/patchbay-standards" symbolic-ref --delete refs/remotes/origin/HEAD || die "u: delete origin/HEAD"
   note "no origin/HEAD in the checkout and no ref given:"
   run u/project 2 "FAIL  no default ref: <copy u>/patchbay-standards has no origin/HEAD" scripts/sync-standards.sh
   push_upstream u/patchbay-standards
   note "a second base: line appended to the project's index (not a parseable section), even with --init:"
   printf 'base: {}\n' >> "$NEG/u/project/agent-os/standards/index.yml" || die "u: second base: line"
   run u/project 2 "FAIL  agent-os/standards/index.yml has a base: line that is not a parseable section (a second base: line, or content after the colon)" scripts/sync-standards.sh --init
   run u/project 2 "FAIL  agent-os/standards/index.yml has a base: line that is not a parseable section (a second base: line, or content after the colon)" scripts/sync-standards.sh --check
   git -C "$NEG/u/project" checkout -q -- agent-os/standards/index.yml || die "u: restore index.yml"
   cp "$NEG/u/project/agent-os/standards/base/.version" "$NEG/u-version" || die "u: save .version"
   cp "$NEG/u/project/agent-os/standards/index.yml" "$NEG/u-index.yml" || die "u: save index.yml"
   cp "$NEG/u/project/.git/index" "$NEG/u-gitindex" || die "u: save git index"
   printf 'garbage' > "$NEG/u/project/.git/index" || die "u: corrupt git index"
   note "the project's git index overwritten with garbage, then a sync to HEAD~1, the checkout's commit before the base: {} one (must fail naming the listing, exit 2, before anything is written: .version and the index unchanged):"
   run u/project 2 $'index file smaller than expected\nFAIL  git could not list the files under agent-os/standards/base (see above)' scripts/sync-standards.sh ../patchbay-standards HEAD~1
   run u/project 0 cmp agent-os/standards/base/.version ../../u-version
   run u/project 0 cmp agent-os/standards/index.yml ../../u-index.yml
   cp "$NEG/u-gitindex" "$NEG/u/project/.git/index" || die "u: restore git index"
   run u/project 0 git status --short ;;
v) hdr "v (the script copies itself from the synced commit as the last thing it writes; a working-tree edit to it is not copied)"
   mk_upstream v/patchbay-standards; mk_project v/project; first_sync v
   printf '\n# a later change to the script\n' >> "$NEG/v/patchbay-standards/scripts/sync-standards.sh" || die "v: edit script"
   note "the change uncommitted, sync (must pass; the project's script unchanged):"
   run v/project 0 scripts/sync-standards.sh
   run v/project 0 git status --short
   git -C "$NEG/v/patchbay-standards" add -A || die "v: git add"; commit v/patchbay-standards "change the script"; push_upstream v/patchbay-standards
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
