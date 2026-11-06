# Gate spec 2: land the five base proposals from patchbay's first specs and align this repository's gate

GitHub issue #10. Shaped 2026-11-05 in plan mode with `/agent-os:shape-spec`; Steps 1–5 and the
three design decisions asked and answered by the owner (recorded under Decisions). Branch
`task/10-gate-spec-2-…`, clean at `b3fc2fe` (`main`).

## Context

patchbay's first two specs (the bootstrap and its revision after the PR 3 review, both merged in
patchbay PR 3, `origin/main` = `0916b55`) are the first proposals to flow upstream. Their
`shape.md` files record five changes under "Standards retrospective (proposed, base)", each
verified against patchbay's shipped `scripts/gate.sh`, `scripts/gate-negative-tests.sh` and
`.github/workflows/gate.yml`:

1. **Exit contract** (verification-gate.md): exit 1 at the first failing step after
   `FAIL  step N/M: <reason>` on stderr, whatever the tool returned; exit 2 on usage.
2. **What the script-parsing step lists** (verification-gate.md): git's list, tracked plus
   untracked-not-ignored; shell scripts only (`.sh` or a bash shebang); anything else refused by
   name. `find` sees ignored strays and non-bash files.
3. **Harness shape** (verification-gate.md): `mktemp -d` under a hard failure, refused when empty
   or inside the repository before any trap; every run names its expected status; the harness
   fails on a mismatch, so the transcript's last line says whether the cases behaved.
4. **Fixture for a consuming project's drift-check tests**: one clone of the sibling per run,
   `<case>/patchbay` beside a `<case>/patchbay-standards` symlink, the sibling never written, the
   missing-sibling case made by removing the symlink.
5. **CI pin step** (standards-sync.md): a `run` step reads `.version` into `GITHUB_OUTPUT`, the
   checkout takes it as `ref` at the default depth; `main` with full history fails on a pin that
   was later squashed or deleted.

This repository's gate does neither 1 nor 2 nor 3 today: `scripts/gate.sh` lets the tool's
status through (test f records `exit=2` from `bash -n`), takes arguments silently, and lists
`scripts/` with `find`; the harness has the bare `NEG=$(cd "$(mktemp -d)" && pwd -P)` line and
asserts nothing. Issue #10 is the gate spec that aligns the two gate files here, with a negative
test per changed step, and then writes the five rules from the shipped files.

The patchbay checkout at `../patchbay` is on a feature branch; every patchbay file is read at
`origin/main` (`git -C ../patchbay show origin/main:<path>`), never from its working tree.

## Decisions

- **Issue #10 as written is the scope** (owner). The sixth proposal in this repository's sync
  spec (what a spec records when a new base file is not yet staged) is not in the issue and
  stays out. Nothing outside the issue changes but `CHANGELOG.md`, `index.yml` descriptions the
  rule changes require, the step-1 wording in `CLAUDE.md` and `shape-spec.md` (Docs), and the
  spec folder.
- **Proposal 4 lives in `standards-sync.md` "In a consuming project"** (owner), beside the
  `--check` gate step and the CI layout already there; `verification-gate.md`'s negative-test
  section stays general.
- **Proposal 2 is a general listing rule plus per-repository step text** (owner): under "One
  script", a step that reads files from the tree lists them with git (tracked plus
  untracked-not-ignored, paths unquoted, each checked on disk; not a work tree fails by name),
  verified by `gate.sh` step 1 in both repositories, `check-index.sh` and `sync-standards.sh`.
  The shell-only parse and by-name refusal go in "In this repository" and "In a consuming
  project" as each gate's step 1. The sentence "this standard names no step and no tool" stays
  true.
- **New tests are w (step 1's file list) and x (usage)** (owner); g and u, patchbay's letters for
  the same cases, are taken here. e and f show the `FAIL` line and exit 1.
- **Sequence** (issue): the two gate files first, gate green; then the rules; then the CHANGELOG.
  Negative tests rerun after the last edit to any gate file, j included.
- **Both `gate.sh` files read the same apart from their step lists.** Stated assumption, recorded
  in `shape.md` and shown by the diff in `verification/gate-sh-diff.txt`: the hunks are the step
  paragraphs of the header, the pins block (a `PYMARKDOWN_VERSION` here, "none yet" there), the
  step bodies and banners, the N/M numbers, and the standard paths spelled from each
  repository's root (`base/process/…` here, `agent-os/standards/base/process/…` there). The
  skeleton (usage check, `step`/`fail` helpers, the step-1 loop, the closing line's shape) is
  identical.
- **No commit, stage, push or PR by an agent.** Hand-over ends with `git status --short`.

## Standards applied

Core tier: none yet (Step 5a). Feature-specific, all five under `base/process`:
`verification-gate` and `standards-sync` (edited here as feature work, from the shipped files),
`ownership`, `standards-retrospective`, `standards-index` (descriptions rewritten when a rule
changes). `standards.md` snapshots them as they read on `main` today.

## Task 1: Save spec documentation

`agent-os/specs/2026-11-05-2019-gate-spec-2-five-base-proposals/`: `plan.md` (this plan),
`shape.md` (the template's shape: Core Architecture, Scope citing issue #10 as the first
Decision, Shaping answers, Decisions, Context, Standards Applied, Verification Gate with Docs and
Version, Standards Retrospective last), `standards.md` (full text of the five standards from
`main`), `references.md` (patchbay's three gate files and two `shape.md` at `origin/main`
`0916b55`; here `scripts/gate.sh`, the harness, `check-index.sh`, `sync-standards.sh`'s listing
rule at lines 267–268, the fourth and fifth specs' records), `verification/` filled by Tasks 2–6.

## Task 2: `scripts/gate.sh` aligned with patchbay's

Model: `git -C ../patchbay show origin/main:scripts/gate.sh`. Same skeleton, this repository's
three steps:

- Header in patchbay's shape: steps 1–3 runnable, 4–6 judgment; usage line "(no arguments; any
  argument is usage, exit 2)"; the exit-status paragraph; the step-1 listing paragraph; what each
  step needs (step 2: uv, network the first time). Paths `base/process/…`.
- `if [ $# -ne 0 ]; then echo "usage: …" >&2; exit 2; fi` after `cd`.
- Pins block: `PYMARKDOWN_VERSION=0.9.41` with its comment, unchanged.
- `step()` and `fail() { printf 'FAIL  step %s: %s\n' "$1" "$2" >&2; exit 1; }`.
- Step 1, patchbay's loop verbatim with `1/3`: `git rev-parse --show-toplevel || fail`; the
  `while read -d ''` over `git -c core.quotePath=false ls-files -z -- scripts` plus
  `ls-files -z --others --exclude-standard -- scripts`, `LC_ALL=C sort -zu`; `[ -e ]` or fail
  "tracked but missing from the disk"; `*.sh` or a `^#!.*bash` first line, else fail "is not a
  shell script"; `bash -n || fail "does not parse"`; `ok   $f`; count, fail "git lists no file".
  Banner: `1/3  bash -n on every shell script under scripts/ (tracked or untracked, not ignored)`.
- Step 2: `uvx … || fail 2/3 "pymarkdown reported findings (see above)"`.
- Step 3: `scripts/check-index.sh || fail 3/3 "index.yml and the tracked files under base/ disagree (see above)"`.
- Closing line unchanged in shape: "Gate steps 1-3 passed. Steps 4-6 are judgment …".
- Run `scripts/gate.sh`: green. Write `verification/gate-sh-diff.txt`: the first line names the
  two inputs and date, then `diff -u <(git -C ../patchbay show origin/main:scripts/gate.sh) scripts/gate.sh`.

## Task 3: `scripts/gate-negative-tests.sh` adopts the harness shape

Model: patchbay's harness at `origin/main` (`die`, the guard, `run` with an expected status, the
summary line). Keep every existing test (a to v, j) and its fixtures (`mk`, `mk_upstream`,
`mk_project`, `section_of`, `expected_index`, `first_sync`, `old_file`).

- `die() { echo "harness: $1" >&2; exit 2; }`. Scratch: `NEG=$(mktemp -d) || die`; refused when
  empty or not a directory; `NEG=$(cd "$NEG" && pwd -P) || die`; `case "$NEG" in "$REPO"|"$REPO"/*) die`;
  then `trap 'rm -rf "${NEG:?}"' EXIT`.
- Setup under `die`: `mk` (mkdir, cp, git init, git add), `mk_project`, `commit`,
  `push_upstream`, `first_sync` (replaces `|| continue`). `old_file`'s "commit not in this clone"
  stays a note and a skip, not a failure.
- `run <case> <expected> <cmd...>`: as today plus `got=${PIPESTATUS[0]}`; `runs`/`unexpected`
  counters; `exit=N` or `exit=N  UNEXPECTED (expected M)`. A shared `check <want> <got>` helper
  prints that line and counts, used by `run`, by test i's two direct captures and by j's `replay`
  (which takes an expected status too).
- Every existing `run` call gets the status the fifth spec's transcript records
  (`verification/gate-negative-tests.txt`: 114 `exit=` lines, read per test in order); the one
  change under the new contract is f, 2 → 1. q's `grep -c` (0 matches) is 1, as recorded.
- New tests, on `mk` copies, each `run` asserting:
  - **w** (step 1 lists with git): ignored `scripts/.DS_Store` passes (`git status --ignored`
    shown, `gate.sh` 0); a tracked `scripts/notes.txt` fails at step 1 by name, 1; the tracked
    harness copy deleted from the disk, deletion unstaged, fails at step 1 by name, 1; the copy's
    `.git` removed fails at step 1 by name, 1. Mirrors patchbay's g.
  - **x** (usage): the clean copy 0; `--help` 2 with the usage line; a stray argument 2.
    Mirrors patchbay's u.
  - e and f headers reworded: step 2 (e) and step 1 (f) each end in the `FAIL  step N/3` line
    and exit 1, the later banner never printed.
- Default list `a b c1 c2 c3 d e f g h i k l m n w x o p q r s t u v`; `all` adds j. Header:
  what changed (hard failure on setup, expected status per run, the guard, the summary), the
  test list with w and x, "the transcript's last line says whether every case behaved".
- End: `printf '\n%d runs, %d unexpected\n'`; `[ "$unexpected" -eq 0 ]`.
- Run `scripts/gate.sh`: green. Run the harness: `verification/gate-negative-tests.txt` (every
  test but j, first line date and branch, last line `N runs, 0 unexpected`);
  `scripts/gate-negative-tests.sh j > verification/ci-negative-test.txt` (the workflow is
  unchanged; j reruns because the harness changed; the hosted run id is for the owner to add).

## Task 4: The five rules, written from the shipped files

Feature work on two base standards, each sentence read against `../patchbay` at `origin/main`
and this repository's scripts as shipped by Tasks 2–3, never against the proposal text or this
plan. Lines wrapped at 100.

`base/process/verification-gate.md`:

- "One script", first bullet: the exit contract (exit 1 at the first failing step, after
  `FAIL  step N/M: <reason>` on stderr, whatever the tool returned; any argument is usage, exit
  2; a green run means every step ran and passed). Proof: both `gate.sh`; here e, f, x; patchbay
  a, d, u.
- "One script", new bullet: a step that reads files from the tree lists them with git, tracked
  plus untracked-not-ignored, paths unquoted, each checked on disk; not a git work tree fails by
  name; an ignored stray is never seen and a file added before it is staged is. Proof: `gate.sh`
  step 1 in both, `check-index.sh`, `sync-standards.sh`; here h, m, n, w; patchbay g.
- "Every step that can fail is proven to fail", new bullet: the harness shape (scratch from
  `mktemp -d` under a hard failure, refused when empty or at or under the repository before any
  trap; a setup failure stops the harness, exit 2; every run names its expected status, a
  mismatch marked, exit 1 at the end naming the count, the last line of a transcript). Proof:
  both harnesses.
- "In this repository": step 1 as shipped (shell scripts only, `.sh` or a bash shebang, any
  other file refused by name), the exit contract, the harness count (a to n except j, w, x; o to
  v; j), the current transcripts' home (this spec), the `gate-sh-diff.txt`.
- "In a consuming project": the project's step 1 is the same rule, and its gate carries the
  contract; the workflow's checkout of `patchbay-standards` at the pinned commit by the pin step
  (pointer to `standards-sync.md`).

`base/process/standards-sync.md` "In a consuming project":

- The pin step as the form: a `run` step with an `id` reads `.version` into `GITHUB_OUTPUT`
  (`sha=…`), the second checkout takes `steps.<id>.outputs.sha` as `ref` at the default depth;
  `main` with full history is not used, because a pin off `main` that was later squashed or
  deleted fails only in CI. Proof: patchbay `.github/workflows/gate.yml`, test j.
- The fixture: the project's negative tests clone the sibling once into the scratch directory
  per run, lay each case out as `<case>/patchbay` with `<case>/patchbay-standards` a symlink to
  the clone so the default path resolves as in the tree, never write the sibling, and make the
  missing-sibling case by removing the symlink. Proof: patchbay harness `mk`, tests d and j.

`index.yml`: `process/verification-gate` description rewritten for the exit contract and the git
listing; `process/standards-sync` for the pin step. One sentence each, no `: ` or ` #`.

Run `scripts/gate.sh`: green (pymarkdown over the edited standards; `check-index.sh`).

## Task 5: Docs, CHANGELOG, retrospective

- **Docs:** `CLAUDE.md:48` and `shape-spec.md:190, 229, 300` say "every shell script under
  `scripts/` as git lists them" instead of "every file"; `README.md` reads true unchanged; both
  scripts' headers read against the code; `.github/workflows/gate.yml`'s header unchanged and
  true; every standard that names the changed files reread. Recorded in `shape.md`.
- **Version:** `CHANGELOG.md` under `[Unreleased]`: Added, the sixth spec (issue #10) with
  bullets for `scripts/gate.sh`, the harness (w, x, the shape), `verification-gate.md`,
  `standards-sync.md`, `verification/gate-sh-diff.txt`; Changed, the two scripts' behaviour
  changes and the `index.yml` descriptions. No version number to bump.
- **Retrospective** in `shape.md`, the four questions against `git diff main`; the base edits
  are feature work, listed apart from the spec folder; `index.yml` in step; "no changes" or the
  entries, never silence.

## Task 6: Verification gate (final)

1. `bash -n` on every shell script under `scripts/` as git lists them (step 1).
2. `pymarkdown` 0.9.41 through `uvx` over `base/` and `README.md` (step 2).
3. `scripts/check-index.sh` (step 3).
4. Docs, 5. Version, 6. Standards retrospective, recorded in `shape.md` in that order.

`scripts/gate.sh` as the last act, transcript to `verification/gate-run.txt` with the date and
branch on line 1; then `git status --short`; stop.

## Verification

- `scripts/gate.sh` exit 0 after Task 2, Task 3, Task 4 and last.
- `scripts/gate-negative-tests.sh` ends `N runs, 0 unexpected`; e and f end in `FAIL  step` with
  exit 1; w and x as above; j passes on the clean copy and fails at the gate step on the broken
  one; transcripts in `verification/`.
- `diff -u` of the two `gate.sh` files shows only the hunks named under Decisions.
- `scripts/gate.sh --help` exits 2; `scripts/gate.sh x` exits 2.
- `git diff main --stat` lists only: the spec folder, `scripts/gate.sh`,
  `scripts/gate-negative-tests.sh`, `base/process/verification-gate.md`,
  `base/process/standards-sync.md`, `index.yml`, `CHANGELOG.md`, `CLAUDE.md`,
  `.claude/commands/agent-os/shape-spec.md`.
- `awk 'length>100'` over the edited standards, `CLAUDE.md` and `CHANGELOG.md`: none.
