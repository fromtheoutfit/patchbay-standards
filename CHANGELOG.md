# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Consuming projects pin `base/` to a commit; the `base/` lines in each entry are what a sync would
bring in.

## [Unreleased]

### Added

- Sixth spec, `agent-os/specs/2026-11-05-2019-gate-spec-2-five-base-proposals/` (issue #10), the
  second gate spec: the five base proposals from patchbay's first two specs landed, each rule
  written from patchbay's shipped files at its `origin/main` and from this repository's gate files
  once aligned, never from the proposals' text; every gate file that changed carries its negative
  test. Revised after the review of PR 11 (ten findings): step 1's root guard, step 2's git list,
  the reason every failing test run asserts, the `cd` and symlink cases and the fixture's wording,
  below. The two repositories' `scripts/gate.sh` share one skeleton; patchbay takes this
  revision's changes to it in its own gate spec after its next sync (fromtheoutfit/patchbay#5).
  - `base/process/verification-gate.md`: "One script" fixes the exit contract (exit 1 at the
    first failing step after `FAIL  step N/M: <reason>` on stderr, whatever the tool returned;
    any argument, or a repository root the script cannot enter, is exit 2 with no step run) and
    gains the listing rule (a step that reads files from the tree reads the files git lists,
    tracked plus untracked-not-ignored, at a work-tree top that is the repository root: git's
    list with each path checked on the disk and a symlink to nothing named, or a tool that reads
    `.gitignore` itself and is given no path git ignores; a copy nested in another repository is
    refused by name); "Every step that can fail is proven to fail" gains the harness shape
    (`mktemp -d` under a hard failure, the scratch directory refused when empty or inside the
    repository before the trap is set, a setup failure stopping the harness, every run asserting
    its expected status and every failing run its reason, the last line of a transcript counting
    the mismatches); "In this repository" rewritten from the aligned scripts (step 1's root guard
    and shell-only parse, step 2's git list, the test count, the current transcripts' home, the
    skeleton the two repositories' `scripts/gate.sh` share and the diff a spec that changes it
    records); "In a consuming project" names the skeleton, the project's step 1, the listing rule
    for its later steps, the exit contract, the pin step and the fixture.
  - `base/process/standards-sync.md` "In a consuming project": the pin step as the form a
    project's workflow uses (a `run` step with an `id` writes `.version` to `GITHUB_OUTPUT` as
    `sha`, the second checkout takes it as `ref` at the default depth; the default branch with
    full history fails on a pin later squashed or deleted), and the fixture a project's negative
    tests use for the drift check (one local clone of the sibling into the scratch directory per
    run, which shares the sibling's objects and so holds the pin whichever ref reaches it, where a
    `--no-local` or `file://` clone would not; each case as `<case>/patchbay` beside a
    `<case>/patchbay-standards` symlink, the sibling never written, the missing-sibling case made
    by removing the symlink, the CI replay from the scratch workspace).
  - `scripts/gate-negative-tests.sh`: tests w (step 1 lists files with git: an ignored
    `scripts/.DS_Store` passes; a tracked `scripts/notes.txt`, a tracked script missing from the
    disk, a tracked symlink to nothing, a copy without `.git` and the same copy inside another
    repository are each refused by name), x (`--help` and a stray argument exit 2 with the usage
    line, a script that cannot enter the repository root exits 2 saying so; the clean copy exits
    0) and y (step 2 lists with git: an ignored draft under `base/` is never linted, the same file
    tracked is, a tracked standard missing from the disk is refused by name); w and y also run
    PR 11's first head, `a5f88ae`, on the bugs they guard. Transcripts in the spec's
    `verification/`, j rerun there, with the guard deletions the reason assertion catches;
    `verification/gate-sh-diff.txt` is the `diff -u` of patchbay's `scripts/gate.sh` at
    `origin/main` against this repository's.

- Fifth spec, `agent-os/specs/2026-11-05-1441-sync-script-and-standards-sync/` (issue #8): the sync
  that makes a second patchbay repository possible, and the standard that describes it, verified
  against the script as shipped.
  - `scripts/sync-standards.sh`: run from a consuming project's root, with the sibling
    `../patchbay-standards` as the default path and its `origin/HEAD`, origin's default branch, as
    the default ref; an explicit ref off that branch is synced with a warning. Reads `base/`,
    `index.yml` and the script itself out of the commit's tree with `git cat-file`, raw, never the
    working tree; checks every precondition, builds the new `base/`, `.version` and index in a
    temporary directory, then swaps them in, so a refusal writes nothing; replaces
    `agent-os/standards/base/` whole; writes the commit to `agent-os/standards/base/.version`;
    replaces the `base:` section of `agent-os/standards/index.yml` byte for byte and leaves every
    other line in place; verifies the result against the export; copies itself from the same
    commit over the project's copy as the last thing it writes. Reports what changed on stderr and
    one JSON object on stdout; exit 0, 1 on a failed check, 2 on usage or a precondition, each
    named. `--init` creates the `base:` section (and the index) for a first sync, one blank line
    on each side; `--index-only` regenerates the section alone, the safe replacement for the stock
    `index-standards` on a synced index; `--check` is the drift check, naming every file missing,
    extra or changed, a differing section and a differing script. Revised after the owner's review
    of PR 9, 22 findings with two reproduced on macOS (BSD `head -n 0` crashed the splice of a
    section on line 1, and a sync that failed there was left half-written); the dispositions are
    in the spec's `plan.md`.
  - `scripts/gate-negative-tests.sh`: tests o to v for the sync, each on a scratch checkout whose
    `HEAD` and `origin/main` hold the working tree's files beside a scratch Agent OS project with
    its own index sections and two local standards: o (first sync, the sibling default, `--init`
    pinning `origin/main` with `HEAD` ahead, the warning on an explicit `HEAD`, a path inside the
    checkout), p (a working-tree edit is not synced, a committed and pushed addition is), q (a
    removed file is removed), r (own sections survive byte for byte against a hand-built index in
    six layouts, the section on line 1 created, replaced and regenerated, the upstream index's
    trailing comment staying upstream, the PR 9 head's script shown crashing and leaving the
    project half-synced), s (a hand-edited entry is drift and `--index-only` repairs it), t
    (`--check` on a one-byte edit, an extra file, a missing file, an ignored stray, a ref, a
    missing `.version`), u (refusals by name, each writing nothing), v (the script copies itself
    from the commit, not the working tree, as the last thing it writes). Transcripts in the spec's
    `verification/`, the CI replay j rerun there too.
  - `base/process/standards-sync.md`: what the sync writes and nothing else; the invariant and
    `--check`; pinned, not tracking, with the default ref, the sync commit's title and scope; the
    `base:` section rule, `--index-only` and `--init`; a base edit is a pull request here; the
    layout of a consuming project's gate workflow. Indexed in `index.yml`.
  - `verification/branch-protection.txt`: the `gh api .../branches/main/protection` output showing
    the `gate` check required on `main`, which the "does not merge" wording below is verified
    against.

- Fourth spec, `agent-os/specs/2026-11-05-1000-gate-spec-ci-docs-version/` (issue #3), the gate's
  own spec: every gate file changes here and nowhere else, each changed step with its negative test.
  - `.github/workflows/gate.yml`: the gate's workflow. One job on every pull request and every push
    to `main`: checkout, uv, `scripts/gate.sh`, nothing else. `actions/checkout` v7.0.1 and
    `astral-sh/setup-uv` v10.3.3 pinned by commit with the tag beside it, uv pinned to 0.13.7,
    runner `ubuntu-24.04`, a ten-minute timeout, no persisted credential, no cache. The job's run
    steps are replayed from the workflow file on a broken copy before any push
    (`verification/ci-negative-test.txt`); the hosted runs on the pull request are recorded there
    by id.
  - `agent-os/standards/index.yml` is a symlink to `../../index.yml`, as `agent-os/standards/base`
    is to `../../base`: one index to edit, nothing to keep equal.
  - Docs and Version as judgment steps 4 and 5 of the gate, the standards retrospective 6, in
    `shape-spec.md`'s gate task, `scripts/gate.sh`'s header and closing line, and `CLAUDE.md`.
  - `scripts/gate-negative-tests.sh`: every negative test as a committed script, not run by the
    gate, parsed by step 1, each test on a temporary copy. Transcripts in `verification/`: the
    first spec's a, b, d, e, f on the shipped scripts; c1, c2, c3 (a regular file with matching
    bytes, a symlink elsewhere, a directory) replacing c; g (the `comm` locale case); h (an
    untracked standard refused, an ignored stray not); i (`.pymarkdown.yaml` shown to be read);
    k (a key that is a prefix of another, with the PR 7 head's script shown passing an unindexed
    standard under GNU `comm`); l (a non-ASCII path); m (not a git work tree); n (a tracked file
    missing from the disk); j (the CI replay).
  - `base/process/verification-gate.md`: the Docs and Version rules in "The fixed order", a "CI"
    section, the workflow added to the protected gate files, "In this repository" and "In a
    consuming project" updated, all written from the shipped files.
  - `base/process/standards-index.md`: the tracked-files rule under "Every standard and nothing
    else" and the symlink under "In this repository", written from the shipped script.

- Second spec, `agent-os/specs/2026-11-04-1016-gate-and-index-standards/` (issue #1): the two base
  standards the first retrospective recorded as missing, written from the shipped gate and index
  and revised after the review of PR 5 so every claim is backed by a shipped file.
  - `base/process/verification-gate.md`: one `scripts/gate.sh` runs the runnable steps in a fixed
    order and stops at the first failure; versions pinned in the script, rule sets in a versioned
    config; the runnable steps followed by the standards retrospective as judgment recorded in
    `shape.md`; a failing step fixed at its cause; every step proven to fail by a negative test;
    every spec's `gate-run.txt` dated; the gate's own files changed only in their own spec.
  - `base/process/standards-index.md`: two-level keys as paths relative to their section without
    the `.md`, the reserved `root` section, the description line says what the standard decides
    and holds no `: ` or ` #`, every standard indexed and nothing else, a consuming project's
    `base:` section identical to the root's at the pinned commit with no entry edited by hand, the
    stock `index-standards` command not run on a synced index, the `agent-os/standards/base`
    symlink never ships.
  - Both indexed in `index.yml` and `agent-os/standards/index.yml`.

- First spec, `agent-os/specs/2026-11-04-0750-shape-spec-gate-retrospective/`: the process
  backbone, modelled on the Loser League repository.
  - `.claude/commands/agent-os/shape-spec.md` customized: an empty "Core Architecture
    (always included)" tier, the snapshot paragraph, the final verification-gate task, and
    the rule that a base standard is never edited in place during a spec but proposed in
    `shape.md` and sent here as a pull request.
  - The verification gate, `scripts/gate.sh`: `bash -n` on every file under `scripts/`,
    pymarkdown 0.9.41 through `uvx` over `base/` and `README.md` (rules in `.pymarkdown.yaml`),
    and `scripts/check-index.sh` holding `index.yml` equal to the files under `base/` and to
    `agent-os/standards/index.yml`; the standards retrospective as step 4.
  - `base/process/standards-retrospective.md`: the retrospective standard, language-neutral,
    with base ownership and the `(proposed, base)` recording shape.
  - `base/process/ownership.md`: a person owns every commit, pull request, approval and
    merge; an agent never lands work; system-wide tools are asked for before install.
  - `index.yml` at the root (one `base:` section), `agent-os/standards/index.yml` identical to
    it, and `agent-os/standards/base` as a symlink to `base/`.
  - `CLAUDE.md`: Git, Ownership, no-AI-attribution and specs-and-retrospective rules.

### Changed

- `scripts/gate.sh` (issue #10): aligned with patchbay's, then revised after the review of PR 11.
  Exits 1 at the first failing step after `FAIL  step N/3: <reason>` on stderr, whatever
  `bash -n`, pymarkdown or `check-index.sh` returned (test f recorded `bash -n`'s 2 before); any
  argument is usage, exit 2, no step run, and a repository root it cannot enter is exit 2, said.
  Step 1 refuses a tree whose work-tree top is not the repository root, then lists `scripts/`
  with one `git ls-files -z --cached --others --exclude-standard` in place of `find`, so an
  ignored stray is never parsed and a script added before it is staged is; a file ending in `.sh`
  or starting with a bash shebang is parsed, any other file fails the step by name, and a tracked
  file missing from the disk or a symlink to nothing fails by name. Step 2 passes pymarkdown the
  `.md` files under `base/` and `README.md` as git lists them, not `--recurse`, so an ignored
  draft is never linted. The header says the exit contract, the listing rule, citing the
  standard, and what each step needs.
- `scripts/gate-negative-tests.sh` (issue #10): the harness shape patchbay's has, then revised
  after the review of PR 11. The scratch directory comes from `mktemp -d` under a hard failure
  and is refused when empty or at or under the repository before the trap is set; every setup
  step that fails stops the harness by name (exit 2); `run` takes the status each case expects
  and, for a failure, the lines its output must hold, prints `exit=N` or marks it `UNEXPECTED`,
  and the harness ends with `N runs, M unexpected` and exits 1 on any mismatch. Every existing
  case asserts the status the fifth spec's transcript recorded and, when it fails, the reason it
  printed; e and f end in the `FAIL` line.
- `CLAUDE.md` and `.claude/commands/agent-os/shape-spec.md` (issue #10): steps 1 and 2 described
  as the script does them, the files under `scripts/`, `base/` and `README.md` as git lists them,
  and the exit contract named.
- `index.yml` (issue #10): the `process/verification-gate` description rewritten for the exit
  contract, the git listing, the asserting harness and the shared skeleton;
  `process/standards-sync` names the CI checkout at the pin read from `.version`.
- `base/process/standards-index.md` (issue #8): the interim hand-copy sentence and "named here when
  it ships" are pointers at `base/process/standards-sync.md` and `scripts/sync-standards.sh
  --index-only`; a base change without its index entry "does not merge" (the `gate` check is
  required on `main`) rather than "does not pass the gate".
  `base/process/standards-retrospective.md`: the same "does not merge" in "Keep the index in step".
  `base/process/verification-gate.md`: the negative-test count in "In this repository" rewritten
  from the shipped harness (fifteen, a to n except j), the current transcripts' home, j's included,
  and `sync-standards.sh --check` named as a consuming project's gate step with the workflow's
  checkout of `patchbay-standards` at the pinned commit.
  `index.yml`: the `process/standards-index` description rewritten for the sync, and the
  `process/standards-sync` description naming the default ref.
- `scripts/check-index.sh` (issue #3): `LC_ALL=C` is exported once, so `comm` collates like the
  sorts that feed it (under `en_US.UTF-8` a C-sorted list with one entry missing reported every
  entry missing); every list is sorted after its last transform and both are checked sorted before
  `comm`, whose exit is tested on its own (the PR 7 head sorted before stripping, so GNU `comm`
  refused the input and the script read that as nothing missing); the file list is
  `git ls-files -- base` with paths unquoted, so an ignored `.DS_Store` is not refused, a standard
  never added to git is refused by name, a tracked file missing from the disk is refused, and a
  non-ASCII path passes; outside a git work tree the step fails by name; the project index is
  checked to be a symlink to `../../index.yml` instead of compared byte for byte, a directory
  reported as such; the header points at `base/process/standards-index.md`.
- `index.yml`: the `process/verification-gate` description rewritten for the judgment steps and CI;
  the header says tracked files and the symlink.
- `scripts/gate.sh`, `.pymarkdown.yaml`: a pin or rule set is bumped "in the gate's own spec", as
  the gate standard says, not "outside a spec".
- `base/process/standards-retrospective.md` (issue #2, third spec
  `agent-os/specs/2026-11-05-0741-retrospective-points-at-owners/`): "Keep the index in step" and
  "Never edit this file from inside a retrospective" are each a short pointer at the standard that
  owns the rule, `base/process/standards-index.md` and `base/process/verification-gate.md`. The
  sync-script sentence, the `base:`-first ordering sentence and the gate-file list are gone, and
  the retrospective is changed "in its own spec" rather than "outside a spec", as the file's
  ownership section and the gate standard already say. Nothing else in the file changes.
- `index.yml` and `agent-os/standards/index.yml`: the header trimmed to a pointer at the index
  standard; all four descriptions shortened to one sentence each.
- The first spec's `shape.md` unspliced: its filled-in retrospective moved from inside Scope to its
  own heading, replacing the stale "no changes" block, and the moved text's "markdownlint-cli2"
  updated to "pymarkdown". Two records corrected after the review of PR 5: negative test e does
  not show the config is read (its rules are defaults), and the gate run agreed on 2 standards,
  not 1.
- `.gitignore` added, ignoring `.DS_Store`.
