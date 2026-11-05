# Issue #2: point "Keep the index in step" and "Never edit this file" at the standards that own those rules

## Context

`base/process/standards-retrospective.md` restates two rules that other base standards now own, and
the copies already disagree. "Keep the index in step" names a sync script that does not exist
(`scripts/check-index.sh` knows none) and orders the index `base:` first where the stock
`/agent-os:index-standards` command (Step 6) alphabetizes folders and `base/process/standards-index.md`
says alphabetical. "Never edit this file from inside a retrospective" lists the protected gate files,
a set `base/process/verification-gate.md` now owns under "The gate's own files change only in their
own spec". GitHub issue #2 is the scope: each section becomes a short pointer at the owning standard,
so no rule lives in two places that can disagree. This is the proposal recorded in the retrospective
of `agent-os/specs/2026-11-04-1016-gate-and-index-standards/shape.md`, widened at the review of PR 5.

Editing a base standard is this spec's feature work on its own branch
(`feature/2-point-keep-the-index-in-step-...`, currently at `origin/main` 0c6f91c, so the pointer
targets are the standards as shipped on main). Shaped 2026-11-05 in plan mode; the owner answered:

- **Scope is exactly the issue.** Two sections rewritten; nothing else in the file changes.
  CHANGELOG under Unreleased, gate green, `verification/gate-run.txt` kept, then stop and print
  `git status --short`. No commit, push or PR.
- **Visuals:** none. **Product context:** `agent-os/product/` does not exist; skipped.
- **References:** the two pointer targets as shipped on main, and the issue #1 spec folder for the
  shape of plan/shape/standards/references and the `gate-run.txt` first-line convention.
- **Standards included:** all four under `base/process` (ownership and standards-retrospective
  govern the work; standards-index and verification-gate are what the pointers must agree with).
- **"Keep the index in step" is the pointer alone**; the "not indexed is invisible" why lives once,
  in `standards-index.md`'s opening paragraph. "does not merge" is written "does not pass the gate":
  no CI exists, and the gate spec (#3) upgrades the wording when it does (the same correction PR 5
  made in `standards-index.md`).
- **"Never edit this file" aligns "outside a spec" to "in its own spec"**, matching the file's own
  "Who owns which standard" and the gate standard; the issue's "keeps its own rule" still holds.

## Spec folder

`agent-os/specs/2026-11-05-0741-retrospective-points-at-owners/`

## Task 1: Save spec documentation

Create the folder with, in the shape of the issue #1 spec folder:

- `plan.md` — this plan.
- `shape.md` — Core Architecture "None yet; see Step 5a"; Scope = issue #2 quoted in substance;
  **first Decision cites GitHub issue #2 as the scope**; the shaping answers above; Context (no
  visuals, references, no product); Standards Applied (core: none yet; feature-specific: the four);
  `## Standards Retrospective` and `## Verification Gate` headings left to be filled at the end.
- `standards.md` — the full text of `base/process/ownership.md`, `standards-retrospective.md`
  (as it reads *before* this spec's edit; the snapshot paragraph says so), `standards-index.md`,
  `verification-gate.md`.
- `references.md` — the pointer targets and what each sentence of the new text is verified against
  (table below); the issue #1 spec folder for shape; `.claude/commands/agent-os/index-standards.md`
  Step 6 and `scripts/check-index.sh` as the proofs the issue names.
- No `visuals/`.

## Task 2: Rewrite the two sections of `base/process/standards-retrospective.md`

Only lines 86–110 change (the two sections). Every other byte of the file stays, including the
`(proposed, base)` example under "Recording the answer", which already names this file.

Replace lines 86–100 with:

```markdown
## Keep the index in step

A standard added, renamed or removed carries its index entry in the same change set: a project
standard in the project's own sections of `agent-os/standards/index.yml`, a base proposal in the
root `index.yml` of `patchbay-standards`, where `scripts/check-index.sh` holds the index to the
files under `base/` so a proposal without its entry does not pass the gate. The index's format, the
description line and how a consuming project's index relates to the root index are
`base/process/standards-index.md`'s.
```

Replace lines 102–110 with:

```markdown
## Never edit this file from inside a retrospective

A gate that rewrites its own terms during the process it governs is precisely what this
prohibition exists for. Strengthening or relaxing the retrospective is a deliberate edit made in
its own spec, with the user, on its own branch, never inside the retrospective of some other spec.

The gate's own files are under the same rule. Which files those are, and that they change only in
a spec whose feature is the gate, are `base/process/verification-gate.md`'s.
```

Gone: "copied verbatim by the sync script", "followed by the project's own sections", the
`/agent-os:index-standards` regeneration sentence and the description-line advice (both now
`standards-index.md`'s), the list `shape-spec.md` / `scripts/gate.sh` / `scripts/check-index.sh` /
`.pymarkdown.yaml` (now `verification-gate.md`'s). Lines wrap under 120 (MD013).

Verification of each claim against the shipped standards on main, not against this plan:

| Sentence | Shipped source |
|---|---|
| entry in the same change set, project sections by hand | `standards-index.md` "Two indexes" bullet 3; "The description line" bullet 3 |
| base proposal carries its entry; `check-index.sh` holds the root index to `base/` | `standards-index.md` "Every standard and nothing else" bullets 1 and 3; `scripts/check-index.sh` (no sync script anywhere in it) |
| "does not pass the gate" | `scripts/gate.sh` step 3 runs `check-index.sh`; no `.github/` exists |
| format, description line, two-index relation are `standards-index.md`'s | its opening paragraph: "fixes the index's format and how a consuming project's index relates to the root index" |
| gate files change only in a spec whose feature is the gate | `verification-gate.md` "The gate's own files change only in their own spec", both bullets |
| "in its own spec" | this file's "Who owns which standard" (parenthetical) and `verification-gate.md` bullet 2 |

`index.yml` is not touched: the retrospective standard's description still says what it decides,
and no file was added, renamed or removed.

## Task 3: CHANGELOG entry

Under `## [Unreleased]` → `### Changed`, a new first bullet (the first bullet there is about
`index.yml`; this one goes above it so the base change leads, as the header's "the `base/` lines in
each entry are what a sync would bring in" expects):

> - `base/process/standards-retrospective.md` (issue #2, third spec
>   `agent-os/specs/2026-11-05-0741-retrospective-points-at-owners/`): "Keep the index in step" and
>   "Never edit this file from inside a retrospective" are each a short pointer at the standard that
>   owns the rule, `base/process/standards-index.md` and `base/process/verification-gate.md`. The
>   sync-script sentence, the `base:`-first ordering sentence and the gate-file list are gone, and
>   the retrospective is changed "in its own spec" rather than "outside a spec", as the file's
>   ownership section and the gate standard already say. Nothing else in the file changes.

## Task 4 (FINAL): Verification gate

1. From the repo root, last thing after every edit:

   ```bash
   { printf '%s  branch %s\n\n' "$(date +%F)" "$(git branch --show-current)"; scripts/gate.sh; } \
     | tee agent-os/specs/2026-11-05-0741-retrospective-points-at-owners/verification/gate-run.txt
   ```

   Expected: both scripts parse, pymarkdown 0.9.41 no findings, `index.yml` and `base/` agree
   (4 standards), exit 0. If step 2 flags MD013 or MD038 on the new text, fix the text and rerun from
   step 1 (never the config). `tee` into the spec folder adds no new file under `base/`, so step 3
   is unaffected. Write the run's results into `shape.md` "Verification Gate".
2. **Standards retrospective** in `shape.md`, from the shipped diff (`git diff origin/main`):
   - Q1 new pattern: none expected (a pointer section is already the shape `verification-gate.md`
     uses to cite the retrospective).
   - Q2 wrong/stale: the correction *is* the feature; nothing further expected. Candidates seen while
     reading and already owned by issue #3, not re-proposed: `scripts/check-index.sh` line 7 still
     points at the `index.yml` header.
   - Q3 deviation: none. The file's own prohibition is honoured, since this is the retrospective's
     own spec on its own branch, not a retrospective edit.
   - Q4 moved pointers: none; both targets exist on main and are indexed.
   - Expected record: `Standards retrospective: no changes.` plus the note above. No
     `(proposed, base)` list unless the diff teaches otherwise. No `index.yml` change.
   Retrospective edits, if any arise, are listed separately in the hand-over.
3. Stop. Print `git status --short`. No stage, commit, push or PR.

## Verification (end to end)

- `git diff origin/main -- base/` touches only the two sections of `standards-retrospective.md`
  (lines 86–110 on main); `diff <(git show origin/main:base/process/standards-retrospective.md | sed '86,110d') <(sed '86,$d;' ...)` style spot check: everything outside the two sections is
  byte-identical.
- `grep -n "sync script\|followed by the project" base/process/standards-retrospective.md` → nothing.
- `verification/gate-run.txt` first line is today's date and the branch; last line names step 4.
- `CHANGELOG.md` has the entry under Unreleased/Changed; `git status --short` shows only
  `CHANGELOG.md`, `base/process/standards-retrospective.md` and the new spec folder.
