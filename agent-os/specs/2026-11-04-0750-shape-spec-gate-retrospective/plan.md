# First spec: shape-spec, the verification gate and the standards retrospective — Plan

## Context

`patchbay-standards` holds the shared Agent OS standards for the patchbay family of Python
packages (`patchbay` core, `patchbay-<instrument>` adapters, later orchestration packages). The
standards live under `base/`; a sync script (not yet written) copies that folder into each
consuming project as `agent-os/standards/base/`, pinned to a commit. A consuming project never
edits `base/`; it proposes changes here as a pull request.

At the start of this spec Agent OS is installed with the stock commands and an empty standards
index. This spec gives the repository its process backbone, mimicking the Loser League
repository's approach (`~/Code/Sites/loser`) with only the guards that make sense here.

Spec folder: `agent-os/specs/2026-11-04-0750-shape-spec-gate-retrospective/`.

## Tasks

### Task 1: Save spec documentation

Create the spec folder with `plan.md` (this plan), `shape.md` (scope, shaping answers with their
evidence, decisions, retrospective, gate results), `standards.md` (the snapshot: none applied,
the index was empty) and `references.md` (the Loser files studied). No visuals.

### Task 2: Customize `.claude/commands/agent-os/shape-spec.md`

Keep the stock flow (plan-mode prerequisite, Steps 1–9, output structure, content templates,
tips). Add, in Loser's shape:

- Step 5 opens with the two kinds of standard and the base-ownership rule: a standard under
  `base/` (here) or `agent-os/standards/base/` (consuming project) is owned by this repository
  and never edited in place during a spec; a proposed change is recorded in `shape.md` under
  `## Standards retrospective (proposed, base)` and becomes a PR here.
- Step 5a "Core Architecture (always included)", empty, with a note that the first base
  standards fill it; Step 5b feature-specific standards, reading `agent-os/standards/index.yml`.
- The "what you read here is a snapshot; standards change at the END of the spec, in the
  retrospective" paragraph.
- Step 7's "Task N (FINAL — ALWAYS INCLUDED): Verification gate" in Loser's shape, with this
  repository's four steps; Step 8's "always include the final verification task" paragraph;
  Step 9's three-point "ready for execution" text.
- `shape.md` template gains Core Architecture (none yet), Standards Retrospective (with the
  `(proposed, base)` sub-list) and Verification Gate sections; `standards.md` template gains the
  snapshot sentence; tips gain "the gate is the definition of done" and "standards are a living
  record".

Leave out everything Loser-specific: Launch Obligations (5c), MCP Parity (5d), the Redline
unattended mode.

### Task 3: The verification gate

- `.pymarkdown.yaml` — the pinned rule set (default rules; MD013 at 120 for lines and headings,
  off for code blocks and tables).
- `scripts/check-index.sh` — gate step 3: every file under `base/` has an entry under `base:` in
  `index.yml`, no entry lacks a file, only `.md` files live under `base/`, and
  `agent-os/standards/index.yml` is identical to `index.yml`.
- `scripts/gate.sh` — one command for steps 1–3: `bash -n` on every file under `scripts/`;
  `uvx --from pymarkdownlnt==0.9.41 pymarkdown --strict-config --config .pymarkdown.yaml scan
  --recurse base README.md` (uv is the one installer the patchbay packages use);
  `scripts/check-index.sh`. Exits non-zero on the first failure; prints that step 4 is the
  retrospective, recorded in `shape.md`.

### Task 4: Port the standards retrospective to `base/process/standards-retrospective.md`

From Loser's `agent-os/standards/process/standards-retrospective.md`, examples made
language-neutral, keeping: the four diff-checkable questions, "verify against the code, not the
spec", "never edit this file from inside a retrospective" (extended to `scripts/gate.sh`,
`scripts/check-index.sh` and `.pymarkdown.yaml`), "own change set". Add "Who owns which
standard" (the base-ownership rule; every standards edit approved by a person, always) and the
`(proposed, base)` recording shape. Describe in "Keep the index in step" how the two indexes
relate.

### Task 5: The two indexes

- `index.yml` at the repo root: a header recording how the indexes relate, then one `base:`
  section keyed by path relative to `base/` without the `.md`
  (`process/standards-retrospective`), one description line saying what the standard decides.
- `agent-os/standards/index.yml`: identical to the root file (this repository has no project
  standards of its own); `agent-os/standards/base` a symlink to `../../base` so the stock
  commands resolve `base/<path>` here exactly as in a consuming project.

### Task 6: `CLAUDE.md`

Loser's `## Git` rule (minus the Redline sentence), its `### No AI attribution — anywhere`
section verbatim (minus the Redline paragraph), and `## Specs & the standards retrospective`
adapted to this gate and the base-ownership rule. Nothing else.

### Task 6a (added at the owner's review): Ownership

`## Ownership` in `CLAUDE.md`, directly under the Git section; the same rule as a base standard,
`base/process/ownership.md`, indexed in both `index.yml` files; the unasked uv install recorded in
`shape.md` as the deviation that prompted it. No "Git rule for Redline agents" section exists in
this repository to mirror the line into.

### Task 6b (added at the owner's review): CHANGELOG.md

Keep a Changelog format; an `[Unreleased]` section whose first entry is this spec.

### Task 7 (FINAL — ALWAYS INCLUDED): Verification gate

Run the full verification gate, in order. The spec is not complete until every step passes:

1. `bash -n` on every file under `scripts/`
2. `pymarkdown` 0.9.41 through `uvx` over `base/` and `README.md` (rules in `.pymarkdown.yaml`)
3. `scripts/check-index.sh` — `index.yml` lists exactly the files under `base/`, and
   `agent-os/standards/index.yml` is identical to it
4. **Standards retrospective** — per `base/process/standards-retrospective.md`, recorded in
   `shape.md`; "no changes" is valid, silence is not

`scripts/gate.sh` runs steps 1–3. If any step fails, fix the underlying issue (do not bypass)
and rerun before marking the spec complete.
