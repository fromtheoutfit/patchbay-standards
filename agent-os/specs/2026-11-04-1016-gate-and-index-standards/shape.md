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
   paths relative to the standards root without the `.md`; the description line says what the
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
- `process/standards-retrospective` — governs gate step 4 below, and the rule that both new
  standards are verified against shipped files, never the spec; both are feature work on this
  branch, not retrospective edits.

## Standards Retrospective

Per `base/process/standards-retrospective.md`. Filled in at the END of the spec, from the shipped
diff. "No changes" is valid; silence is not.

Applied 2026-11-04 from the shipped diff. The two new standards are this spec's feature work, not
retrospective edits; the questions below are asked of everything else the diff touched.

1. *A pattern no standard covers?* None beyond the two files written. "Every spec keeps its green
   run as `verification/gate-run.txt`" was a habit of the first spec and is now a rule in
   `base/process/verification-gate.md`, verified against both specs' `verification/` folders.
2. *A standard wrong or stale?* One, in a base standard, so proposed below rather than edited:
   `base/process/standards-retrospective.md`, "Keep the index in step", says the `base:` section is
   "copied verbatim by the sync script". No sync script exists, and the new index standard states
   the invariant without naming one, so the two base standards now disagree on wording.
3. *A deliberate deviation?* From the issue, not from a standard, both decided at shaping: the CI
   bullet was left out of the gate standard (no workflow exists to verify it against) and the index
   standard names no sync script. Neither standard was deviated from.
4. *A moved pointer?* The index format rule moved from the header comment of `index.yml` into
   `base/process/standards-index.md`; the header now points there. No standard pointed at the
   header text. The gate's files, `scripts/gate.sh`, `scripts/check-index.sh` and
   `.pymarkdown.yaml`, are untouched, so the six negative tests were not rerun.

No project standard exists to edit, and `index.yml` was changed as feature work (Task 4).

### Standards retrospective (proposed, base)

- `base/process/standards-retrospective.md`, "Keep the index in step" — replace "copied verbatim by
  the sync script and keyed by each standard's path relative to `base/` without the `.md`" with the
  invariant: the project's `base:` section is identical to the root `base:` section at the commit
  the project pins and is never hand-edited, with the format itself deferred to
  `base/process/standards-index.md`. Proved by `scripts/check-index.sh` as shipped, which holds the
  two indexes identical and knows no sync script. Proposed, not applied; becomes a pull request to
  `patchbay-standards` on its own branch.

## Verification Gate

Spec is not complete until `scripts/gate.sh` passes — `bash -n` on every file under `scripts/`,
`pymarkdown` over `base/` and `README.md`, and `scripts/check-index.sh` — and the standards
retrospective above is filled in.

**Results (2026-11-04):** `scripts/gate.sh` exit 0 — `verification/gate-run.txt`: both scripts
parse; pymarkdown 0.9.41 reports no findings over `base/` and `README.md`; `index.yml` and `base/`
agree on 4 standards and the project index is identical. The first run stopped at step 2 with
MD038 on `standards-index.md` line 26 (a code span holding a trailing space); the sentence was
reworded and the whole gate rerun from step 1. The negative tests were not rerun: no gate file
changed.

**Docs:** `README.md` reads true unchanged; the `index.yml` header points at the index standard;
each new file's opening paragraph names what it governs. **Version:** the entry under
`[Unreleased]` in `CHANGELOG.md`. **Standards retrospective:** above.
