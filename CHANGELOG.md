# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Consuming projects pin `base/` to a commit; the `base/` lines in each entry are what a sync would
bring in.

## [Unreleased]

### Added

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
