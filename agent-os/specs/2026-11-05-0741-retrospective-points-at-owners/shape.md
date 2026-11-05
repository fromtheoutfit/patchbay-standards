# Point the retrospective standard at the standards that own its rules — Shaping Notes

Shaped 2026-11-05 in plan mode with `/agent-os:shape-spec`, the questions asked and answered by the
owner (Steps 1–5 and the two drafting decisions, recorded under Decisions).

## Core Architecture (Non-Negotiable)

None yet; see Step 5a of `.claude/commands/agent-os/shape-spec.md`. The first base standards will
fill this tier.

## Scope

GitHub issue #2, "Point 'Keep the index in step' and 'Never edit this file' at the standards that
own those rules". `base/process/standards-retrospective.md` restates two rules other base standards
now own, and the copies disagree:

- "Keep the index in step" says a consuming project's `base:` section is "copied verbatim by the
  sync script" (no sync script exists) and orders the index `base:` first (the stock
  `/agent-os:index-standards` command alphabetizes folders; `base/process/standards-index.md` says
  alphabetical). It becomes a short pointer: the index is kept in step in the same change set as the
  standards it lists; the format and the two-index relation are `standards-index.md`'s.
- "Never edit this file from inside a retrospective" keeps its own rule and points at
  `base/process/verification-gate.md` for the gate files instead of listing them, so the protected
  set has one source.

No other change to the file. CHANGELOG entry under Unreleased; gate green; `verification/gate-run.txt`
kept; no commit, PR or push by an agent.

## Shaping answers

- **Step 1, scope:** exactly the issue. `shape-spec.md`'s empty Core Architecture tier stays empty.
- **Step 2, visuals:** none.
- **Step 3, references:** the two pointer targets as shipped on `main`, and the issue #1 spec folder
  for the shape of the spec files and the `gate-run.txt` first line; see `references.md`.
- **Step 4, product context:** `agent-os/product/` does not exist. Skipped.
- **Step 5, standards:** all four under `base/process`, included.

## Decisions

- **GitHub issue #2 is the scope.** Its two bullets are the two sections; its "Rules" line is this
  spec's definition of done. Nothing else in the file changes, and nothing outside it but the
  CHANGELOG and this spec folder.
- **Editing a base standard is this spec's feature work**, on its own branch, as `CLAUDE.md` and the
  standard's own "Who owns which standard" direct. It is not a retrospective edit; the proposal it
  applies was recorded in the retrospective of
  `agent-os/specs/2026-11-04-1016-gate-and-index-standards/shape.md` and widened at the review of PR 5.
- **Verified against the standards as shipped on `main`** (0c6f91c, which this branch sits at), never
  against this plan: `base/process/standards-index.md`, `base/process/verification-gate.md`,
  `scripts/check-index.sh` (which knows no sync script) and
  `.claude/commands/agent-os/index-standards.md` Step 6 (which alphabetizes folders). `references.md`
  maps each sentence of the new text to its source.
- **"Keep the index in step" is the pointer alone.** The "not indexed is invisible" reason lives once,
  in `standards-index.md`'s opening paragraph, so it is not repeated here. Why: a why that lives in
  two places is the drift this issue removes.
- **"Does not pass the gate", not "does not merge".** No CI exists; `scripts/gate.sh` step 3 is what
  refuses a proposal without its entry. The gate spec (issue #3) upgrades the wording when a workflow
  ships. The same correction PR 5 made in `standards-index.md`.
- **"Never edit this file" says "in its own spec", not "outside a spec".** The file's own ownership
  section says changing a base standard is a spec's feature work on its own branch, and the gate
  standard says a change to the gate is its own spec; the old phrase contradicted both, and this spec
  is itself the case. The section's own rule is kept, as the issue asks.
- **`index.yml` is untouched.** The retrospective standard's description still says what it decides;
  no file was added, renamed or removed.

## Context

- **Visuals:** None.
- **References:** `references.md`.
- **Product alignment:** N/A (no `agent-os/product/`).

## Standards Applied

**Core (always applied):**
- none yet (Step 5a)

**Feature-specific:**
- `process/ownership` — no commit, push, PR, approval or merge by an agent; no tool installed
  (the gate's pinned tool runs through `uvx`, already present).
- `process/standards-retrospective` — the file this spec edits as feature work; governs the
  retrospective below and the rule that the new text is verified against shipped files.
- `process/standards-index` — owns the index rule the first pointer hands over; the pointer must say
  only what this standard says.
- `process/verification-gate` — owns the gate-file rule the second pointer hands over; the pointer
  must say only what this standard says.

## Standards Retrospective

Per `base/process/standards-retrospective.md`. Applied 2026-11-05 from the shipped diff
(`git diff origin/main`: `CHANGELOG.md`, `base/process/standards-retrospective.md` lines 86–102, and
this spec folder). The rewrite of the two sections is this spec's feature work, not a retrospective
edit; the questions are asked of everything the diff touched.

1. *A pattern no standard covers?* None. A section that keeps its one-line rule and hands the detail
   to the owning standard by path is the shape `base/process/verification-gate.md` already uses to
   cite the retrospective.
2. *A standard wrong or stale?* None beyond the two sections the feature corrected. One already
   recorded for the gate spec (issue #3), not re-proposed: `scripts/check-index.sh` line 7 still says
   "see the header of `index.yml` for how the two relate".
3. *A deliberate deviation?* None. The file's own "Never edit this file from inside a retrospective"
   is honoured: this is the retrospective's own spec on its own branch.
4. *A moved pointer?* None. Both targets, `base/process/standards-index.md` and
   `base/process/verification-gate.md`, exist on `main` and are indexed; the `(proposed, base)`
   example under "Recording the answer" still names a file that exists.

No project standard exists to edit. `index.yml` is unchanged: the retrospective standard's
description still says what it decides.

Standards retrospective: no changes.

## Verification Gate

Spec is not complete until `scripts/gate.sh` passes — `bash -n` on every file under `scripts/`,
`pymarkdown` over `base/` and `README.md`, and `scripts/check-index.sh` — and the standards
retrospective above is filled in.

**Results (2026-11-05):** `scripts/gate.sh` exit 0, run as the last act before hand-over on branch
`feature/2-point-keep-the-index-in-step-and-never-edit-this-file-at-the-standards-that-own-those-rules`;
`verification/gate-run.txt` holds the transcript with the date and branch on its first line. Both
scripts parse; pymarkdown 0.9.41 reports no findings over `base/` and `README.md`; `index.yml` and
`base/` agree on 4 standards and the project index is identical. No gate file changed (`git diff
origin/main` is empty under `scripts/`, `.pymarkdown.yaml` and `.claude/`), so no negative test is
owed. Everything in `standards-retrospective.md` outside the two sections is byte-identical to
`main`, checked by diffing the file with lines 86–110 of the `main` copy and 86–102 of this one
removed. **Standards retrospective:** above.
