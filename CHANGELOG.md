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
  - `.github/workflows/gate.yml`: the one CI workflow. One job on every push and pull request:
    checkout, uv, `scripts/gate.sh`, nothing else. `actions/checkout` v7.0.1 and
    `astral-sh/setup-uv` v10.3.3 pinned by commit with the tag beside it, uv pinned to 0.13.7,
    runner `ubuntu-24.04`. Proven to fail when the script fails by running the job's steps from the
    workflow file on a broken copy (`verification/ci-negative-test.txt`), since an agent never pushes.
  - `agent-os/standards/index.yml` is a symlink to `../../index.yml`, as `agent-os/standards/base`
    is to `../../base`: one index to edit, nothing to keep equal.
  - Docs and Version as judgment steps 4 and 5 of the gate, the standards retrospective 6, in
    `shape-spec.md`'s gate task, `scripts/gate.sh`'s header and closing line, and `CLAUDE.md`.
  - Eleven negative tests in `verification/`: the first spec's a, b, d, e, f rerun on the shipped
    scripts; c1 and c2 (a regular file with matching bytes, a symlink elsewhere) replacing c; g (the
    `comm` locale case); h (`git ls-files`); i (`.pymarkdown.yaml` shown to be read); j (CI).
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

- `scripts/check-index.sh` (issue #3): `comm` runs under `LC_ALL=C` like the sorts that feed it
  (under `en_US.UTF-8` a C-sorted list with one entry missing reported every entry missing); the
  file list is `git ls-files -- base`, so an untracked `.DS_Store` is not refused and a standard
  never added to git fails by name; the project index is checked to be a symlink to
  `../../index.yml` instead of compared byte for byte; the header points at
  `base/process/standards-index.md`.
- `index.yml`: the `process/verification-gate` description rewritten for the judgment steps and CI.
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
