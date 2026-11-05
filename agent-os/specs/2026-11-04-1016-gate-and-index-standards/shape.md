# The two base standards the first retrospective recorded as missing — Shaping Notes

Shaped 2026-11-04 in plan mode with `/agent-os:shape-spec`, the questions asked and answered by the
owner (Steps 1–5 and the issue's open points, recorded under Decisions).

## Core Architecture (Non-Negotiable)

None yet; see Step 5a of `.claude/commands/agent-os/shape-spec.md`. The first base standards will
fill this tier.

## Scope

GitHub issue #1, "Write the two base standards the first retrospective recorded as missing":

1. `base/process/verification-gate.md` — the shape every patchbay repository's gate takes: one
   `scripts/gate.sh` running the runnable steps in a fixed order and stopping at the first failure,
   versions pinned in the script, rule sets in a versioned config file; the gate the final,
   always-included task of every spec, the runnable steps followed by Docs, Version and the
   standards retrospective, which are judgment recorded in `shape.md`; a failing step fixed at its
   cause and the whole gate rerun; every step that can fail proven to fail by a negative test with
   the transcript in the spec's `verification/` folder; the gate's own files changed only outside a
   spec. What is fixed across repositories and what each repository fills in. No Python tool named.
2. `base/process/standards-index.md` — the index format and the two-index relation: keys are
   paths relative to their section without the `.md` (corrected at review; the issue said
   "root"); the description line says what the
   standard decides, not its area, and holds no `: `; `index.yml` lists every standard and nothing
   else; a consuming project's `agent-os/standards/index.yml` is its own sections plus the root
   `base:` section, never hand-edited; the `agent-os/standards/base` symlink never ships.

Both written from the shipped files, not from the first spec's prose; rules with named exceptions;
indexed in both `index.yml` files; a CHANGELOG entry under Unreleased; gate green; no commit, PR or
push by an agent.

## Shaping answers

- **Step 1, scope:** exactly the issue. `shape-spec.md`'s empty Core Architecture tier stays empty.
- **Step 2, visuals:** none.
- **Step 3, references:** the two shipped base standards set shape and voice; see `references.md`.
- **Step 4, product context:** `agent-os/product/` does not exist. Skipped.
- **Step 5, standards:** `process/ownership` and `process/standards-retrospective`, both included.

## Decisions

- **GitHub issue #1 is the scope.** Its two numbered sections are the two files; its "Rules for
  both" and "Done when" are this spec's definition of done. Nothing outside it changes.
- **Written from the shipped files.** `verification-gate.md` is verified against `scripts/gate.sh`,
  `scripts/check-index.sh`, `.pymarkdown.yaml`, the first spec's `verification/gate-run.txt` and
  `verification/gate-negative-tests.txt`, `CHANGELOG.md` and `README.md`. `standards-index.md` is
  verified against `index.yml`, `scripts/check-index.sh`, the `agent-os/standards/` listing and
  the retrospective standard's "Keep the index in step". The first spec's `shape.md` named the
  gaps; it is not a source for either file's content.
- **Docs and Version stay in the gate standard**, defined by this repository's practice. Docs: the
  documentation the change touches reads true after it. Version: the change is recorded under
  `[Unreleased]` in `CHANGELOG.md`, and the version bumped where a repository has one. Nothing
  shipped runs either; both are judgment recorded in `shape.md`, like the retrospective. Why: the
  owner wants every repository's gate to carry them; `CHANGELOG.md` and `README.md` as shipped
  are what they are verified against here.
- **CI is left out** of the standard. No `.github/` exists; the spec that adds a workflow proposes
  the rule, verified against that workflow. Why: a rule with no shipped file behind it would be
  written from intention, which is the trap the retrospective standard names.
- **The index standard states the invariant and names no sync script.** A consuming project's
  `base:` section is identical to the root `base:` section at the commit it pins and is never
  hand-edited. The script that will produce that is not written; the spec that writes it names it.
- **Negative tests are owed by a change to the gate**, not by every spec. The spec that adds or
  changes a step ships that step's negative test and its transcript in `verification/`; every spec
  keeps its green run as `verification/gate-run.txt`. This spec changes no gate file, so it keeps
  `gate-run.txt` only.
- **The first spec's spliced `shape.md` is fixed here** as its own change set: its filled-in
  retrospective had been written into the middle of its Scope section while a second, stale "no
  changes" block stayed under the `## Standards Retrospective` heading. Text moved, nothing added.
- **`index.yml`'s header is trimmed** to a pointer at the new standard and the one-line format
  reminder, so the rule has one source. The index entries themselves are unchanged in form.

## Revision after review (2026-11-04)

The review of PR 5 listed 30 findings; the owner and the agent went through them one by one in
plan mode and decided each. The dispositions are tabled in `plan.md`. The decisions that reverse
or extend the ones above:

- **Docs and Version leave the gate standard.** The decision above kept them on the owner's
  intent; the review showed `shape-spec.md`, `scripts/gate.sh` and `CLAUDE.md` define the gate as
  three runnable steps plus the retrospective, so a spec that follows the command fails the
  standard. The standard now says what the gate files say. Both specs' `shape.md` files record
  Docs and Version under their gate results, so shipped practice is ahead of the gate files; that
  is recorded in the retrospective below and the two steps are re-added by the gate spec,
  issue #3, together with the gate-file changes, so the gate changes once.
- **Issue #3 is the one gate spec.** Every finding against a gate file joins it: `gate.sh`'s
  closing line, `check-index.sh`'s header pointer, `comm` under `LC_ALL=C` with the failing case
  as a negative test, tracked files only, the index copy as a symlink with the `cmp` check
  replaced, a negative test proving the lint config is read, Docs and Version in the command
  text, the script and `CLAUDE.md`, and the CI workflow it already carried. Nothing under
  `scripts/`, `.pymarkdown.yaml` or `shape-spec.md` changes in this PR.
- **Issue #2 widens.** The retrospective standard's "Keep the index in step" and "Never edit this
  file" each become a short pointer at the standard that now owns the rule, and the section
  ordering sentence goes, so no rule lives in two places that can disagree.
- **No standard is named that does not exist.** "Toolchain standard" is gone from the gate
  standard; each repository's step list is its own, and the standard that names the steps is
  cited when it ships. The same for the index standard: the stock `index-standards` command is
  described as it behaves, hand editing is the rule because that is what is shipped, and the safe
  regeneration is named when it exists.
- **The index key is relative to its section**, the `root` section resolves to the standards
  root, sections and keys are alphabetical as the stock command writes them.
- **`gate-run.txt` carries its date and branch on the first line**, and the run is the last thing
  before hand-over. The first spec's transcript predates the rule and stays as recorded.
- **`.gitignore` with `.DS_Store`** is added here; the script-side fix (tracked files) belongs
  to issue #3.
- **The first spec's `shape.md` is corrected twice** (negative test e does not show the config is
  read; the gate agreed on 2 standards, not 1), and the unsplice's "markdownlint-cli2" to
  "pymarkdown" change is disclosed in `plan.md`, here and in the CHANGELOG.
- **All four index descriptions are one sentence**, the first spec's two included.
- **The review reply is drafted outside the tree** and posted only when the owner says so, after
  the owner has committed and pushed.

## Context

- **Visuals:** None.
- **References:** `references.md`.
- **Product alignment:** N/A (no `agent-os/product/`).

## Standards Applied

**Core (always applied):**
- none yet (Step 5a)

**Feature-specific:**
- `process/ownership` — no commit, push, PR, approval or merge by an agent; a tool outside the
  repository is asked for before install (uv is already present; the gate's pinned tool runs
  through `uvx` and is not an install).
- `process/standards-retrospective` — governs the retrospective below, and the rule that both new
  standards are verified against shipped files, never the spec; both are feature work on this
  branch, not retrospective edits.

## Standards Retrospective

Per `base/process/standards-retrospective.md`. Applied 2026-11-04 from the shipped diff, and
reapplied the same day from the revised diff after the review of PR 5. The two new standards are
this spec's feature work, not retrospective edits; the questions below are asked of everything
the diff touched, the two standards included where the review showed them wrong.

1. *A pattern no standard covers?* Two, both now rules in `base/process/verification-gate.md`:
   every spec keeps its green run as `verification/gate-run.txt`, and the transcript's first line
   gives the date and branch. Verified against this spec's `verification/gate-run.txt` as shipped.
2. *A standard wrong or stale?* Three.
   - Both standards this spec wrote were wrong in the ways the review named: claims about the
     gate files, the stock commands and the YAML reader that the shipped files do not back. Fixed
     as this spec's feature work, each sentence re-verified against the file it describes;
     `plan.md` tables the findings.
   - `base/process/standards-retrospective.md` is wrong in two sections, "Keep the index in step"
     (names a sync script that does not exist; orders sections `base:` first where the stock
     command alphabetizes) and "Never edit this file" (restates the gate-file rule, and lists a
     protected set the gate standard now owns). Proposed below; issue #2.
   - Shipped practice is ahead of the gate files: both specs' `shape.md` record Docs and Version
     under their gate results, while `shape-spec.md`, `scripts/gate.sh` and `CLAUDE.md` define
     three runnable steps and the retrospective. The gate standard follows the gate files;
     the practice is proposed below as the gate spec's change; issue #3.
3. *A deliberate deviation?* None from a standard. Two notes for later specs, not deviations: the
   CI rule stays out of the gate standard until the workflow ships (issue #3), and a consuming
   project loses `/agent-os:index-standards` under the index standard as written, which is a real
   cost, so the standards-sync spec ships a safe regeneration (the stock command over the
   project's own sections, then the pinned `base:` section re-applied) and the index standard
   names it when it exists rather than leaving hand editing as the permanent rule.
4. *A moved pointer?* The index format rule moved from the header of `index.yml` into
   `base/process/standards-index.md`; the header points there. `scripts/check-index.sh` line 7
   still says "see the header of index.yml for how the two relate", which no longer holds; it is
   a gate file, so the fix is proposed below (issue #3). The gate's files are untouched, so the six
   negative tests were not rerun.

No project standard exists to edit, and `index.yml` was changed as feature work.

### Standards retrospective (proposed, base)

Proposed, not applied; each becomes a pull request to `patchbay-standards` on its own branch.

- `base/process/standards-retrospective.md` (issue #2) — "Keep the index in step" becomes a
  short pointer at `base/process/standards-index.md`: the index is kept in step in the same
  change set, the format and the two-index relation are that standard's. The sync-script
  sentence and the section-ordering sentence go. "Never edit this file from inside a
  retrospective" keeps its own rule and points at `base/process/verification-gate.md` for the
  gate files instead of listing them. Proved by `scripts/check-index.sh` as shipped, which knows
  no sync script, and by `index-standards.md` Step 6, which alphabetizes folders.
- The gate files (issue #3, the one gate spec, with the CI workflow it already carried; every
  step that changes carries its negative test): `scripts/gate.sh` ends by naming every judgment
  step; `scripts/check-index.sh` points at `base/process/standards-index.md` instead of the
  `index.yml` header, runs `comm` under `LC_ALL=C` (the failing case: C-sorted `process/B`,
  `process/a_z`, `process/ab` against the last two reports all three missing in a UTF-8 locale),
  and reads tracked files so an untracked `.DS_Store` or an un-added standard is not counted;
  `agent-os/standards/index.yml` becomes a symlink to `../../index.yml` and the `cmp` check a
  symlink check; a negative test shows `.pymarkdown.yaml` is the config read (a config that
  changes a default, shown to apply; a misspelled key passes `--strict-config` today);
  `shape-spec.md`'s gate task, `gate.sh`'s closing line and `CLAUDE.md` gain Docs and Version
  as judgment steps, and `base/process/verification-gate.md` gains the matching rules, verified
  against those files once they ship.

## Verification Gate

Spec is not complete until `scripts/gate.sh` passes — `bash -n` on every file under `scripts/`,
`pymarkdown` over `base/` and `README.md`, and `scripts/check-index.sh` — and the standards
retrospective above is filled in.

**Results (2026-11-04, first hand-over):** `scripts/gate.sh` exit 0; both scripts parse; pymarkdown
0.9.41 reported no findings; `index.yml` and `base/` agreed on 4 standards. The first run stopped
at step 2 with MD038 on `standards-index.md` (a code span holding a trailing space); the sentence
was reworded and the whole gate rerun from step 1.

**Results (2026-11-04, revised after the review of PR 5):** `scripts/gate.sh` exit 0, rerun as the
last act before hand-over on branch
`feature/1-write-the-two-base-standards-the-first-retrospective-recorded-as-missing`;
`verification/gate-run.txt` holds the transcript with the date and branch on its first line. Both
scripts parse; pymarkdown 0.9.41 reports no findings over `base/` and `README.md`; `index.yml` and
`base/` agree on 4 standards and the project index is identical. No gate file changed between the
two hand-overs (`git diff main` is empty under `scripts/`, `.pymarkdown.yaml` and `.claude/`), so
the six negative tests were not rerun.

**Docs and Version**, recorded here as this repository's practice, which is ahead of the gate
files until issue #3 lands: `README.md` reads true unchanged; the `index.yml` header points at the
index standard; each standard's opening paragraph names what it governs; the change is recorded
under `[Unreleased]` in `CHANGELOG.md`. **Standards retrospective:** above.
