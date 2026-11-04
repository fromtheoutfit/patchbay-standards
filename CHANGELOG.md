# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Consuming projects pin `base/` to a commit, so each entry names what a sync would bring in.

## [Unreleased]

### Added

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
