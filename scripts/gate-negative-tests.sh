#!/usr/bin/env bash
# Negative tests of the verification gate (base/process/verification-gate.md, "Every step that
# can fail is proven to fail"). Not run by scripts/gate.sh; gate step 1 parses this file. Each
# test copies the gate's files into a fresh temporary directory, git-inits and git-adds the copy
# so git ls-files sees it, breaks it in one way, and must fail with the named reason and exit
# status, the steps after it never reached; the two positive cases (k, l) must pass. Nothing in
# the tree is touched. The transcript of a run is kept in the spec's verification/ folder as
# gate-negative-tests.txt (every test but j) and ci-negative-test.txt (j, the CI replay).
#
# Usage: scripts/gate-negative-tests.sh [test ...]   (default: every test but j; "all" adds j)
#   tests: a b c1 c2 c3 d e f g h i k l m n j
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
old_script() {  # old_script <name> <sha>: scripts/check-index-<sha>.sh in the copy, or return 1
  if git cat-file -e "$2:scripts/check-index.sh" 2>/dev/null; then
    git show "$2:scripts/check-index.sh" > "$NEG/$1/scripts/check-index-$2.sh"
    chmod +x "$NEG/$1/scripts/check-index-$2.sh"
  else
    note "commit $2 is not in this clone; its script is not shown"; return 1
  fi
}

tests=("$@")
[ "${#tests[@]}" -eq 0 ] && tests=(a b c1 c2 c3 d e f g h i k l m n)
[ "${tests[*]}" = all ] && tests=(a b c1 c2 c3 d e f g h i k l m n j)

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
*) echo "unknown test: $t" >&2; exit 2 ;;
esac; done
