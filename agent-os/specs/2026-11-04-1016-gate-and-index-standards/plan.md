# Issue #1: write the two base standards the first retrospective recorded as missing

## Context

The first spec's retrospective (`agent-os/specs/2026-11-04-0750-shape-spec-gate-retrospective/shape.md`)
named two patterns it introduced that have no standard: the shape of the verification gate and the
index format with the two-index relation. GitHub issue #1 is the scope of this spec: write
`base/process/verification-gate.md` and `base/process/standards-index.md` **from the shipped files**
(`scripts/gate.sh`, `scripts/check-index.sh`, `.pymarkdown.yaml`, `index.yml`,
`verification/gate-negative-tests.txt`, `verification/gate-run.txt`, the retrospective standard's
"Keep the index in step", `CHANGELOG.md`, `README.md`), never from the spec text; index both in both
`index.yml` files; add a CHANGELOG entry; gate green; retrospective recorded; no commit, push or PR.

Shaped 2026-11-04 in plan mode with the questions asked. Answers that shape the work:

- **Scope is exactly the issue.** `shape-spec.md`'s empty Core Architecture tier stays empty.
- **Docs and Version stay in the gate standard**, defined by this repository's practice: *Docs*, the
  documentation the change touches reads true after it (`README.md`, file headers, command text);
  *Version*, the change is recorded under `[Unreleased]` in `CHANGELOG.md`, and the version bumped
  where a repository has one. Both are judgment steps recorded in `shape.md`, never run.
- **CI is left out** of the standard until a workflow ships (no `.github/` exists).
- **The index standard states the invariant only**: a consuming project's `base:` section is
  identical to the root `base:` section at the pinned commit and is never hand-edited. No sync
  script is named (none exists yet).
- **Negative tests are owed by a change to the gate**, not by every spec. Every spec keeps its green
  run as `verification/gate-run.txt`; this spec keeps that only.
- **The first spec's spliced `shape.md` is fixed here**, text only, as its own change set. The
  moved text's "markdownlint-cli2" was updated to "pymarkdown" in the same edit (disclosed at the
  review of PR 5; the plan's "no new content" was not literally true).
- References: the two shipped base standards set shape and voice. Standards applied:
  `process/ownership` and `process/standards-retrospective`. No visuals, no product folder.

## Spec folder

`agent-os/specs/2026-11-04-1016-gate-and-index-standards/` (time of shaping; slug under 40 chars).

## Task 1: Save spec documentation

Create the folder with:

- `plan.md` — this plan.
- `shape.md` — per the template in `.claude/commands/agent-os/shape-spec.md`. Core Architecture
  "none yet; see Step 5a". Scope: the issue, quoted. **First Decision cites GitHub issue #1** as the
  scope. Further Decisions record the five answers above with their reason, and that the standards
  are written from the shipped files the first retrospective names. Context: visuals none,
  references, product N/A. Standards Applied: core none; feature-specific `process/ownership`,
  `process/standards-retrospective`. `## Standards Retrospective` and `## Verification Gate` left
  for Task 7.
- `standards.md` — snapshot sentence, then the full text of `base/process/ownership.md` and
  `base/process/standards-retrospective.md` as they read now.
- `references.md` — the two shipped base standards (shape and voice); `scripts/gate.sh`,
  `scripts/check-index.sh`, `.pymarkdown.yaml`, `index.yml`, the first spec's `verification/`
  transcripts, `CHANGELOG.md` (the shipped sources each standard is verified against); the stock
  `index-standards.md` and `inject-standards.md` (how the index is read: two levels, folder then
  file, description matched).
- No `visuals/`.

## Task 2: `base/process/verification-gate.md`

Shape and voice of `base/process/ownership.md`: one opening paragraph, headed rule sections in bold
imperative with named exceptions, no "consider", "prefer" or "where possible", a closing
"In a consuming project" section. Names no Python tool; where a tool would be named, it says "the
tool pinned in the script" and points at `scripts/gate.sh`. Every sentence traceable to a shipped
file. Sections:

1. **Opening.** The gate is the definition of done: the final, always-included task of every spec,
   whether or not `/agent-os:shape-spec` shaped it, in a fixed order; a spec with a red step or an
   unrecorded retrospective is unfinished work however small the change. (Source: `shape-spec.md`
   Task N, Step 8; `CLAUDE.md` Specs section.)
2. **One script.** `scripts/gate.sh` runs every runnable step in a fixed order, under
   `set -euo pipefail`, and exits non-zero at the first failing step; later steps never run. It
   prints a numbered banner per step, names what passed (`ok   ...`) or what failed with the reason,
   and ends by naming the judgment steps that follow it. (Source: `gate.sh` lines 12, 19–35;
   `check-index.sh` FAIL lines; negative tests e and f.)
3. **Pinned.** Tool versions are pinned in the script, in one named variable each, and run through
   the repository's pinned-tool runner so nothing is installed into the project. Rule sets live in a
   versioned config file read in strict mode, so a bad config is a failure rather than a silent
   fall-back to defaults. A pin or rule set is bumped deliberately, outside a spec, and the gate
   rerun. (Source: `gate.sh` lines 15–17, 28–29; `.pymarkdown.yaml` header.)
4. **The fixed order.** Runnable steps, then Docs, then Version, then the standards retrospective.
   Docs: the documentation the change touches reads true after it. Version: the change is recorded
   under `[Unreleased]` in `CHANGELOG.md`, naming what a sync would bring in; the version is bumped
   where the repository has one. The retrospective is per `base/process/standards-retrospective.md`.
   All three are judgment, recorded in the spec's `shape.md`, and nothing in the script runs them.
   (Source: `gate.sh` lines 2–5, 35; `CHANGELOG.md` header; `README.md`.)
5. **A failing step is fixed at its cause.** The whole gate is rerun from step 1. Named
   non-fixes: skipping the step, loosening the rule set, excluding the file, editing the script.
   (Source: `shape-spec.md` "fix the underlying issue (do not bypass)".)
6. **Every step that can fail is proven to fail.** A step is shown to discriminate by a negative
   test: a broken copy that must fail with the named reason and exit status. The spec that adds or
   changes a step ships that test's transcript in its `verification/` folder; every spec keeps its
   green run as `verification/gate-run.txt`. Negative tests run on scratchpad copies, never on the
   tree. (Source: `verification/gate-negative-tests.txt` a–f, `gate-run.txt`.)
7. **The gate's own files change only outside a spec.** The script(s), the rule-set config and the
   gate task text in `shape-spec.md` are never changed as a side effect of a spec whose feature is
   something else; a change to the gate is its own work, on its own branch, with the owner, carrying
   its negative tests. (Source: retrospective standard "Never edit this file...", `.pymarkdown.yaml`
   header, `gate.sh` line 15.)
8. **What is fixed and what each repository fills in.** Fixed: everything above. Filled in: the
   repository's own runnable step list and the tools behind it. `patchbay-standards` has three
   (every script parses, the standards and README lint clean, the index equals `base/`); a
   consuming project adds the steps its toolchain standard names. (Source: `gate.sh` steps 1–3.)
9. **In a consuming project.** Synced as `agent-os/standards/base/process/verification-gate.md`;
   the project's `shape-spec.md` gate task lists its step list in this order; its `CLAUDE.md`
   names the gate script as the definition of done.

## Task 3: `base/process/standards-index.md`

Same shape. Sections:

1. **Opening.** `agent-os/standards/index.yml` is what `/agent-os:shape-spec` Step 5 reads; a
   standard not indexed is invisible to every later spec. (Source: retrospective standard "Keep the
   index in step"; `inject-standards.md` line 61.)
2. **Keys.** Two levels, section then key, as the stock commands read them; a key is the standard's
   path relative to its section without the `.md`; in the `base:` section the key carries the
   path under `base/` (`process/ownership`), resolving to `agent-os/standards/base/process/ownership.md`
   in a project. (Source: `index.yml` header; `check-index.sh` lines 24–31; `index-standards.md`
   lines 66–99.)
3. **The description line.** One line, saying what the standard decides, not its area; it is what
   matching reads. It holds no `: ` (the YAML parser refuses it unquoted). (Source: `index.yml`
   header and entries; `index-standards.md` line 53.)
4. **Every standard and nothing else.** `index.yml` lists every file under `base/` and no entry
   without a file; only `.md` files live under `base/`. `scripts/check-index.sh` holds all three
   and names each failure. (Source: `check-index.sh` lines 18–42; negative tests a, b, d.)
5. **Two indexes, one `base:` section.** The root `index.yml` of `patchbay-standards` holds the
   `base:` section and nothing else. A consuming project's `agent-os/standards/index.yml` is its own
   sections plus a `base:` section identical to the root `base:` section at the commit the project
   pins, never hand-edited; a project's own sections change in the same change set as its own
   standards. A base change that adds or renames a file carries its entry. (Source: `index.yml`
   header; retrospective standard "Keep the index in step"; `check-index.sh` line 43.)
6. **In this repository.** `agent-os/standards/index.yml` is identical to `index.yml` (no sections
   of its own) and `check-index.sh` holds it so. `agent-os/standards/base` is a symlink to
   `../../base`, this repository's convenience so the stock commands resolve the same paths; it never
   ships to a project. (Source: `ls -la agent-os/standards`; negative test c.)
7. **In a consuming project.** Synced as `agent-os/standards/base/process/standards-index.md`.

## Task 4: Index both files

Add `process/standards-index` and `process/verification-gate` to the `base:` section of `index.yml`,
alphabetical (ownership, standards-index, standards-retrospective, verification-gate), one description
line each saying what the standard decides, no `: `. Copy `index.yml` to
`agent-os/standards/index.yml` so the two stay byte-identical. Trim the `index.yml` header comment
to a pointer at `base/process/standards-index.md` plus the one-line format reminder, so the rule has
one source.

## Task 5: CHANGELOG

Under `## [Unreleased]` / `### Added`, one entry for this spec naming the two standards, the index
entries, and the fix to the first spec's `shape.md`.

## Task 6: Fix the first spec's spliced `shape.md` (own change set)

In `agent-os/specs/2026-11-04-0750-shape-spec-gate-retrospective/shape.md`: move the filled-in
retrospective (lines 37–84) out of Scope to the `## Standards Retrospective` heading, replacing the
stale "no changes" block (lines 174–193); restore Scope item 2's sentence
("...matching `## Verification Gate` and `## Standards Retrospective` sections in the `shape.md`
template."). No new content. Listed separately when the work is reported.

## Task 7 (FINAL): Verification gate

1. `scripts/gate.sh` (steps 1–3: `bash -n` on `scripts/`, pymarkdown over `base/` and `README.md`,
   `scripts/check-index.sh`); save the transcript as the spec's `verification/gate-run.txt`.
2. Docs: `README.md`, `index.yml` header, file headers read true. Version: the CHANGELOG entry.
3. **Standards retrospective** in `shape.md`, from the diff, verified against the shipped files.
   Expected candidates to decide then, not now: whether the retrospective standard's "copied
   verbatim by the sync script" wording is now a `(proposed, base)` item given the index standard
   states the invariant without a script; whether `index.yml`'s header trim is a pointer move.
   "No changes" is valid; silence is not.
4. Then stop and print `git status --short`. No commit, stage, push or PR.

## Verification

- `scripts/gate.sh` exits 0 on the shipped tree; step 3 reports 4 standard(s).
- `cmp index.yml agent-os/standards/index.yml` is silent.
- Negative tests are not rerun: no gate file changes. `shape.md` says so.
- Each sentence in the two standards names, in `shape.md` or the file, the shipped file it was
  verified against; nothing is taken from the first spec's prose.
- `git status --short` shows only: the two new standards, both `index.yml` files, `CHANGELOG.md`,
  the new spec folder, and the first spec's `shape.md`.

## Revision after review (2026-11-04)

The review of PR 5 listed 30 findings. Each was decided one by one with the owner, in plan mode;
the decisions are in `shape.md` under "Revision after review". Nothing under `scripts/`,
`.pymarkdown.yaml` or `.claude/commands/agent-os/shape-spec.md` changes: every gate-file finding
is a proposal in this spec's retrospective and the scope of issue #3, which becomes the one gate
spec; the retrospective-standard findings widen issue #2.

| Finding | Disposition |
|---|---|
| 1a Docs and Version in the gate standard, not in the gate files | Dropped from `verification-gate.md` to match the shipped gate; shipped practice (both `shape.md` files) recorded as ahead of the gate files; re-added by issue #3 |
| 1b `gate.sh` closing line names one judgment step | Issue #3 |
| 1c This retrospective recorded none of it | Retrospective rewritten (Task R7) |
| 1d `check-index.sh` header points at the trimmed `index.yml` header | Issue #3 |
| 2a "outside a spec" vs "shaped as a spec" | A gate change is its own spec whose feature is the gate |
| 2b `[Unreleased]` and version bump | Removed entirely |
| 2c Protected set omits `check-index.sh` | "every script it runs" |
| 2d Inline suppression is not a gate change | Reworded |
| 2e `--strict-config` overclaim | Only "a config the tool cannot parse fails the step"; the config-read negative test to issue #3 |
| 2f README example | Rewritten from the first commit: a blank line after the heading |
| 2g Nonexistent toolchain standard | No standard named; the step list is each repository's own |
| 2h First-spec "named exception" | Deleted |
| 2i Repository facts in the consuming-project section | New "In this repository" section |
| 2j `gate-run.txt` undated | First line is date and branch; the run is the last thing before hand-over |
| 2k "scratchpad copies" | "a temporary copy outside the tree" |
| 3a "relative to the standards root" | "relative to its section" in `index.yml`, `shape.md`, this file |
| 3b `root` resolution | Exception stated |
| 3c Section order | Alphabetical, as the stock command writes; ordering sentence to issue #2 |
| 3d "the YAML parser refuses the file" | `: ` nests, ` #` truncates, when the stock commands read the file |
| 3e "does not merge" | "the gate does not pass"; tracked-files check to issue #3 |
| 3f `index-standards` claim | The stock command rewrites the whole file and is not run on a synced index; a safe regeneration named when it ships |
| 3g "arrives on the next sync" | No entry edited by hand; the section replaced whole at a recorded commit |
| 3h `comm` locale, untracked files | Issue #3; `.gitignore` added here |
| 4a Negative test e "proves the config is read" | Corrected in the first spec's `shape.md` |
| 4b "1 standard" vs transcript's 2 | Corrected |
| 4c Undisclosed lint-name change | Disclosed here, in `shape.md` and the CHANGELOG |
| 4d CHANGELOG | Added/Changed split; header reworded |
| 5a Symlink the index copy | Issue #3 |
| 5b Duplicated rules | Issue #2 widened |
| 5c Run-on descriptions | All four shortened |

### Task R1: amend the spec documentation

This file, `shape.md` (Scope fix, "Revision after review", the retrospective and gate sections),
`references.md` (the review and the files it was checked against), `standards.md` (one line).

### Task R2: rewrite `base/process/verification-gate.md`

Verified against `scripts/gate.sh`, `scripts/check-index.sh`, `.pymarkdown.yaml`,
`.claude/commands/agent-os/shape-spec.md` (gate task), `CLAUDE.md`, both specs' `shape.md` and
`verification/` folders, and the first commit's change to `README.md`. Findings 1a, 2a-2k.

### Task R3: rewrite `base/process/standards-index.md`

Verified against `index.yml`, `scripts/check-index.sh`, the `agent-os/standards/` listing and
`.claude/commands/agent-os/index-standards.md`. Findings 3a-3g.

### Task R4: `index.yml` and `agent-os/standards/index.yml`

The `process/standards-index` description corrected (3a); all four descriptions one sentence (5c).

### Task R5: the first spec's `shape.md`, `CHANGELOG.md`, `.gitignore`

Findings 4a, 4b, 4d, 3h.

### Task R6: issues #2 and #3

Both bodies rewritten with `gh issue edit`, no attribution: #3 as the gate spec, #2 widened.

### Task R7 (FINAL): verification gate

`scripts/gate.sh` rerun after the last edit, transcript to `verification/gate-run.txt` with the
date and branch on its first line; the retrospective rewritten from the shipped diff. Then stop:
no commit, stage, push or PR. The reply to the review is drafted outside the tree and posted only
when the owner says so.
