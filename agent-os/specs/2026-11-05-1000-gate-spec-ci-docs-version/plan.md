# Gate spec: CI workflow, Docs and Version as judgment steps, and the gate-file fixes from the PR 5 review

GitHub issue #3. Shaped 2026-11-05 in plan mode with `/agent-os:shape-spec`; Steps 1–5 and the
four design decisions asked and answered by the owner (recorded below under Decisions).

## Context

Issue #3 is the one gate spec: `base/process/verification-gate.md` says the gate's files change
only in a spec whose feature is the gate, so every change the PR 5 review found against a gate file
lands here, together, each changed step carrying its negative test. Four things are wrong or
missing today:

- `scripts/check-index.sh` runs `comm` under the user's locale while the `sort`s that feed it run
  under `LC_ALL=C`. Reproduced on this machine: `comm -23` of C-sorted `{process/B, process/a_z,
  process/ab}` against `{process/a_z, process/ab}` under `en_US.UTF-8` reports all three missing.
  It also lists files with `find`, so an untracked `.DS_Store` is refused and an un-added standard
  passes locally. Its header still points at an `index.yml` header PR 5 trimmed.
- `agent-os/standards/index.yml` is a hand-kept duplicate of `index.yml`, held equal by `cmp`.
- Nothing shows `.pymarkdown.yaml` is read: the first spec's test e fails on default rules only.
- The two specs' `shape.md` already record Docs and Version as judgment steps, but
  `shape-spec.md`'s gate task, `gate.sh`'s closing line, `CLAUDE.md` and the gate standard define
  only the retrospective. No CI runs the gate.

Branch `feature/3-gate-spec-…` sits at `origin/main` (aaacc57). No `.github/` exists. `act` is not
installed and will not be. `agent-os/product/` does not exist (Step 4 skipped).

## Decisions

- **Issue #3 is the scope**, in the six-part order the owner gave; gate green at the end of each
  part. Nothing outside it changes but `CHANGELOG.md`, the spec folder, and the `index.yml`
  description the gate rule change requires.
- **Action pins are full commit SHAs with the tag in a comment**, verified today:
  `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1` (2026-07-20) and
  `astral-sh/setup-uv@68559e99cc807c1eb7e9238fd43a15bba460eec2 # v10.3.3` (2026-10-28).
- **uv itself is pinned** through setup-uv's `version` input to `0.13.7` (released 2026-11-03;
  the version on this machine). Runner image pinned to `ubuntu-24.04`, not `-latest`.
- **CI negative proof is a local run of the workflow's own steps** in a scratch copy with a broken
  script: the one `run` step exits non-zero, which fails a job by GitHub's rule. No install, no
  push. The real run happens when the owner opens the PR.
- **"Does not pass the gate" stays.** `main` has no branch protection today (verified, 404). The
  owner will require the gate check after this merges; `shape.md` records that the wording in the
  retrospective and index standards upgrades to "does not merge" once that setting exists and can
  be verified.
- **Editing the two base standards is this spec's feature work** on its own branch, as `CLAUDE.md`
  and the retrospective standard direct; written last, from the shipped files, never from this plan.
- **Negative tests for `git ls-files` run in a scratch `git init` + `git add` fixture** (ls-files
  reads the index; no commit is needed anywhere). Every test runs on a copy in the scratchpad, never
  on the tree.

## Standards applied

Core tier: none yet (Step 5a). Feature-specific, all four: `process/ownership`,
`process/standards-retrospective`, `process/standards-index`, `process/verification-gate`.
`standards.md` snapshots them as they read on `origin/main` today.

## Task 1: Save spec documentation

Create `agent-os/specs/2026-11-05-1000-gate-spec-ci-docs-version/` with `plan.md` (this plan),
`shape.md` (shape of the third spec's: Core Architecture, Scope citing issue #3 as the first
Decision, Shaping answers, Decisions above, Context, Standards Applied, Standards Retrospective,
Verification Gate), `standards.md` (full text of the four standards from `origin/main`),
`references.md` (the gate files, `gate-negative-tests.txt` of the first spec, the third spec's
`shape.md` and `gate-run.txt`), and `verification/` (filled by the tasks below).

## Task 2: `scripts/check-index.sh` fixes (part 1)

- `LC_ALL=C comm …` on both `comm` calls.
- File list: `git ls-files -- base | LC_ALL=C sort` replaces `find base -type f`. Messages say
  "tracked under base/". The non-`.md` refusal now reads the tracked list, so an untracked
  `.DS_Store` is ignored and an un-added standard with an entry fails as "in index.yml but not
  tracked under base/".
- Header comment: the two-index relation is in `base/process/standards-index.md` (not the
  `index.yml` header).
- Negative tests, transcripts appended to `verification/gate-negative-tests.txt`:
  - **g (locale):** scratch copy with `base/process/{B,a_z,ab}.md` all indexed. `main`'s script
    (`git show origin/main:scripts/check-index.sh`) under `LANG=en_US.UTF-8` reports all three
    missing (the bug); the shipped script passes under both locales; with `process/B`'s entry
    removed it names `process/B` alone under `en_US.UTF-8`.
  - **h (tracked files):** `git init` fixture: untracked `base/process/new.md` with an entry fails
    by name; untracked `base/.DS_Store` is not refused; a `git add`ed `base/notes.txt` is (test d).
- Run `scripts/gate.sh`: green.

## Task 3: The index symlink (part 2)

- `rm agent-os/standards/index.yml && ln -s ../../index.yml agent-os/standards/index.yml`
  (typechange; the owner stages it).
- `check-index.sh`: replace the `cmp` block with `[ -L … ] && [ "$(readlink …)" = ../../index.yml ]`,
  failing as "agent-os/standards/index.yml is not a symlink to ../../index.yml (found: <what>)".
- Negative tests replacing the first spec's c: **c1** a regular file byte-identical to `index.yml`
  fails; **c2** a symlink to another target fails.
- Gate green.

## Task 4: `.pymarkdown.yaml` is shown to be read (part 3)

- No change to the config. Negative test **i**: scratch copy whose `.pymarkdown.yaml` sets
  `md013.line_length: 60`; `gate.sh` stops at step 2 with MD013 naming a file under `base/`, step
  3 never reached. Note beside it: the misspelled key `line_lenght` still passes `--strict-config`
  (the limit the issue records; the test is the answer).
- Rerun a, b, d, e, f on the shipped scripts. Gate green.

## Task 5: Docs and Version as judgment steps (part 4)

- `.claude/commands/agent-os/shape-spec.md`, gate task: steps 1–3 runnable; **4. Docs** (the
  documentation the change touches reads true after it); **5. Version** (the change recorded under
  `[Unreleased]` in `CHANGELOG.md`, and the version bumped where a repository has one);
  **6. Standards retrospective**. "`gate.sh` runs steps 1–3; steps 4–6 are judgment, recorded in
  `shape.md`." The `shape.md` template's Verification Gate paragraph and Step 8's reminder say the
  same.
- `scripts/gate.sh` header and closing line: "Gate steps 1-3 passed. Steps 4-6 are judgment,
  recorded in shape.md: Docs, Version, the standards retrospective."
- `CLAUDE.md` "Specs & the standards retrospective": the gate is the three runnable steps, then
  Docs, Version and the retrospective last.
- No runnable step changes, so no negative test is owed; the gate-run transcript shows the new
  closing line. Gate green.

## Task 6: `.github/workflows/gate.yml` (part 5)

One job, `on: push` and `on: pull_request`, `permissions: contents: read`, `runs-on: ubuntu-24.04`:
checkout (SHA pin), setup-uv (SHA pin, `version: "0.13.7"`), `run: scripts/gate.sh`. Nothing else:
no lint, no matrix, no cache config. A header comment points at the standard's CI rule.

- Syntax check without a push: `uv run --with pyyaml python -c` parses the file and prints the
  step list (read-only, nothing installed into the project).
- Negative test **j**, transcript in `verification/ci-negative-test.txt`: in a scratch copy with
  `scripts/broken.sh` added, run the workflow's steps as the file lists them (`uv --version` for
  the install step's effect, then `scripts/gate.sh`), show exit 2 at step 1, and state the rule
  that a non-zero `run` step fails the job. The owner's PR gives the real run.
- Gate green (the workflow is not under `scripts/` or `base/`; step 1 and 2 ignore it).

## Task 7: The standards, written from the shipped files (part 6)

Feature work on base standards, verified against Tasks 2–6 as shipped, never against this plan:

- `base/process/verification-gate.md`: "The fixed order" gains Docs and Version before the
  retrospective; a **CI** section (one workflow runs `scripts/gate.sh` and nothing else, one job,
  every action pinned to a commit with its tag in a comment, the runner's version pinned, the
  workflow fails when the script fails, proven without a push); "In this repository" names the
  workflow, the symlink check, the `git ls-files` list and this spec's negative-test set (the first
  spec's six stay as recorded; this spec holds the current set).
- `base/process/standards-index.md`: "Every standard and nothing else" says the tracked files
  under `base/`; "In this repository" says `agent-os/standards/index.yml` is a symlink to
  `../../index.yml` that `check-index.sh` refuses anything else for, so there is one file to edit.
- `index.yml`: `process/verification-gate` description rewritten for CI and the judgment steps
  (the index standard: rewritten when the rule changes). The symlink follows it.
- Gate green.

## Task 8: CHANGELOG, retrospective, gate

- `CHANGELOG.md` under `[Unreleased]`: Added (workflow, symlink, negative tests), Changed
  (`check-index.sh`, `gate.sh`, `shape-spec.md`, `CLAUDE.md`, the two standards, index
  description). Docs step: `README.md` reads true unchanged; every pointer checked.
- Standards retrospective in `shape.md`, the four questions against `git diff origin/main`; the
  two base edits are feature work, not retrospective edits. Record the "does not merge" upgrade
  as deferred to branch protection.
- Final `scripts/gate.sh` as the last act, transcript to `verification/gate-run.txt` with date and
  branch on line 1. Then `git status --short`, no commit, no stage, no push.

## Verification

- After each part: `scripts/gate.sh` exit 0.
- Negative tests a, b, c1, c2, d, e, f, g, h, i in `verification/gate-negative-tests.txt`; j in
  `verification/ci-negative-test.txt`; each with the named reason and exit status.
- `git diff origin/main --stat` lists only: the spec folder, `scripts/`, `agent-os/standards/index.yml`
  (typechange), `.claude/commands/agent-os/shape-spec.md`, `CLAUDE.md`, `.github/workflows/gate.yml`,
  the two standards, `index.yml`, `CHANGELOG.md`.

---

# Revision after the first review of PR 7 (2026-11-05)

Same spec, same branch, same folder `agent-os/specs/2026-11-05-1000-gate-spec-ci-docs-version/`.
The owner's review comment on PR 7 lists 27 findings at `cf1bdf0`; the dispositions below were
decided with the owner in plan mode (four were choices, asked and answered; the rest accepted as
the review recommends). The first finding is real and blocks: on ubuntu, GNU `comm` exits 1 on
unsorted input and the script reads that as "nothing missing", so CI passes an unindexed standard.

## Dispositions

| # | Finding | Decision |
|---|---------|----------|
| 1 | expected list unsorted after `sed` | Fix: sort after each transform. Reproduced here with `sort -c`. Negative test k. |
| 2 | failed `comm` counts as success | Fix: `LC_ALL=C sort -c` both inputs first (BSD `comm` has no `--check-order`), and `comm … > f \|\| FAIL` tested apart from `[ -s ]`. |
| 3 | quoted non-ASCII paths | Fix: `git -c core.quotePath=false ls-files`. Negative test l (`café.md`, must pass). |
| 4 | outside a work tree, no FAIL line | Fix: `git rev-parse --show-toplevel` must equal the script's root, else `FAIL  not a git work tree …`. Negative test m. |
| 5 | reads the index, not the disk | Fix: a tracked path missing on disk is `FAIL  tracked but missing on disk`. Negative test n. `standards-index.md` reworded to what the script does. |
| 6 | opposite pin rules in the standard | Fix: `:31` and `:35` say "in the gate's own spec", matching the CI section and the files-change-only-in-their-own-spec rule. |
| 7 | `gate.sh` pin comment "outside a spec" | Fix wording. |
| 8 | `.pymarkdown.yaml` header stale pointer | Fix: "changes only in the gate's own spec, with a person (base/process/verification-gate.md)". |
| 9 | template records retrospective before Docs/Version | Fix: template order is Verification Gate (results, Docs, Version) then Standards Retrospective last. |
| 10 | this spec's `shape.md` same order | Fix: reorder; add a "Revision after review" section like the second spec's. |
| 11 | `shape-spec.md:137` "gate step 4" | Fix: step 6. Docs record corrected. |
| 12 | template names the symlink as the file to update | Fix in `shape-spec.md` only: "the root `index.yml` here; the project index in a consuming project". Stock commands left as stock (owner's choice). |
| 13 | setup-uv caching on by default | Fix: `enable-cache: false`. |
| 14 | gate runs twice per push | Fix: `push: branches: [main]` plus `pull_request` (owner's choice). |
| 15 | credentials persist | Fix: `persist-credentials: false`. |
| 16 | no timeout | Fix: `timeout-minutes: 10`. |
| 17 | macOS replay does not prove CI | Narrow the claim (owner's choice): the replay proves the job fails on a non-zero exit before any push; the hosted run on the PR proves the workflow and is recorded in `verification/` by run id and conclusion once it exists; toolchain portability is the script's own, proven by its negative tests. The two runs on `cf1bdf0` (42062523298 push, 42062688286 pull_request, both SUCCESS) are recorded now. |
| 18 | harness never committed | Fix: `scripts/gate-negative-tests.sh` (owner's choice), a to n, the CI replay inside it via `uv run --no-project --with pyyaml`; step 1 parses it; not run by `gate.sh`; its usage header says what it is. |
| 19 | one-workflow rule binds every project's CI | Fix: scope to the gate workflow: "the gate's workflow runs the script and nothing else"; a project may have other workflows. |
| 20 | misspelled config key accepted | Narrow the claim: "a config the tool cannot parse fails the step; the tool does not refuse an unknown key, so the rule set is read back in the negative test that changes a value". |
| 21 | untracked standard with no entry passes | Fix: `git ls-files --others --exclude-standard -- base` non-empty is `FAIL  under base/ but not tracked`. Negative test h extended; `standards-index.md` and CHANGELOG reworded. |
| 22 | `index.yml` header stale | Fix wording: tracked files; symlink. |
| 23 | `gate.sh` banner, `check-index.sh` header and ok line stale | Fix: "tracked files under base/". |
| 24 | per-command `LC_ALL=C` | Fix: `export LC_ALL=C` after `set -euo pipefail`; prefixes removed. |
| 25 | directory reported as "a regular file" | Fix: `[ -d ]` branch. |
| 26 | `if A && B; then :; else` | Fix: `if ! { …; }` with `readlink` stored once. |
| 27 | lines over 100 columns, orphaned "every plan," | Fix: reflow those lines in `verification-gate.md` and `shape-spec.md` (the long lines at 371–374 are stock tips, left). |

## Tasks

1. **`scripts/check-index.sh`** (1–5, 21–26): `export LC_ALL=C`; work-tree check; `git -c
   core.quotePath=false ls-files -- base`; untracked-under-base check; missing-on-disk check;
   sort after each transform; `sort -c` both inputs; `comm` exit tested apart from `[ -s ]`;
   symlink branch rewritten with directory case; header and ok line say "tracked".
2. **`scripts/gate-negative-tests.sh`** (18): the scratchpad harness, committed, a to n plus the
   CI replay (j). Usage header: what it is, that it is not run by `gate.sh`, that every copy is in
   `mktemp -d`. New tests: k (`testing-fakes.md` next to `testing.md`, all indexed, must pass; and
   `zeta.md` unindexed beside them must fail, under GNU and BSD `comm` where present), l (`café.md`
   indexed, must pass), m (a non-git copy, `FAIL  not a git work tree`), n (tracked file `rm`ed,
   `FAIL  tracked but missing on disk`), h extended (untracked `.md` with no entry fails).
3. **`.github/workflows/gate.yml`** (13–16): triggers, `enable-cache: false`,
   `persist-credentials: false`, `timeout-minutes: 10`.
4. **Wording** (6–8, 22, 23, 27): `verification-gate.md` pin sentences, `gate.sh` pin comment and
   banner, `.pymarkdown.yaml` header, `index.yml` header; reflow.
5. **`shape-spec.md`** (9, 11, 12, 27): template order, step 6, root index wording, orphan line.
6. **Standards from the shipped files** (5, 17, 19, 20, 21): `verification-gate.md` CI section and
   "In this repository" (now the harness, fourteen tests, hosted run recorded by id);
   `standards-index.md` tracked/untracked/missing-on-disk rules as the script reports them.
7. **Records**: `shape.md` reordered with a "Revision after review (2026-11-05)" section and the
   hosted run ids; CHANGELOG lines for 21 and the harness; `verification/gate-negative-tests.txt`
   regenerated by the committed harness; `ci-negative-test.txt` regenerated with the hosted runs
   noted; gate green after each task; final `gate-run.txt` last; `git status --short`.

## Verification

- `scripts/gate.sh` exit 0 after each task and last.
- `scripts/gate-negative-tests.sh` runs a to n and j; every negative fails with the named reason;
  k and l pass; k's unindexed case fails under `gcomm` too (the ubuntu case the review reproduced).
- `awk 'length>100'` over `base/`, `CLAUDE.md`, the edited parts of `shape-spec.md`: none.
- The workflow parses; its steps are the three, with the four new settings.
