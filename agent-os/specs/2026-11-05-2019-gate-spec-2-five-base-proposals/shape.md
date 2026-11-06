# Gate spec 2: land the five base proposals from patchbay's first specs and align this repository's gate — Shaping Notes

Shaped 2026-11-05 in plan mode with `/agent-os:shape-spec`, the Step 1–5 questions and the three
design decisions asked and answered by the owner (recorded under Shaping answers and Decisions).

## Core Architecture (Non-Negotiable)

None yet; see Step 5a of `.claude/commands/agent-os/shape-spec.md`. The first base standards will
fill this tier.

## Scope

GitHub issue #10, "Gate spec 2: land the five base proposals from patchbay's first specs and align
this repository's gate". The first proposals to flow upstream from a consuming project: patchbay's
first two specs record five changes to the gate and sync standards under "Standards retrospective
(proposed, base)", each verified against patchbay's shipped scripts and workflow. This is the gate
spec that lands them here and brings this repository's own gate files into line, so the two
repositories' gates agree. In the issue's order: `scripts/gate.sh` and
`scripts/gate-negative-tests.sh` aligned first, a negative test per changed step, gate green; then
the five rules in `base/process/verification-gate.md` and `base/process/standards-sync.md`, written
from patchbay's files at `origin/main` and this repository's aligned scripts, never from the
proposals' text; then the CHANGELOG. Gate green, `verification/gate-run.txt` with date and branch;
no commit, stage, PR or push by an agent.

## Shaping answers

- **Step 1, scope:** issue #10 as written. The sixth proposal in the fifth spec's `shape.md` (what
  a spec records when a new base file is not yet staged) is not in the issue and stays out.
- **Step 2, visuals:** none.
- **Step 3, references:** patchbay's three gate files and two `shape.md` at `origin/main`
  (`0916b55`), this repository's gate files and the fourth and fifth specs' records; see
  `references.md`.
- **Step 4, product context:** `agent-os/product/` does not exist. Skipped.
- **Step 5, standards:** all five under `base/process`, included in `standards.md`; two are edited
  here as feature work.

## Decisions

- **GitHub issue #10 is the scope.** Its three sections (the `verification-gate.md` rules, the
  `standards-sync.md` rule, this repository's gate files) are the tasks; its "Rules" paragraph is
  this spec's definition of done. Nothing outside it changes but `CHANGELOG.md`, the two
  `index.yml` descriptions whose rules change, the step-1 wording in `CLAUDE.md` and
  `shape-spec.md` (the Docs step: they described step 1 as `find` does it), and this spec folder.
- **Proposal 4 lives in `standards-sync.md` "In a consuming project"** (owner's choice over
  `verification-gate.md`'s negative-test section): the fixture exists for the drift check, and the
  sibling checkout is that standard's concern, as the CI layout already is. The gate standard's
  negative-test section stays general.
- **Proposal 2 is a general listing rule plus per-repository step text** (owner's choice over a
  named script-parsing rule): `verification-gate.md` says of itself that it names no step and no
  tool, and that stays true. Under "One script", a step that reads files from the tree lists them
  with git, tracked plus untracked-not-ignored, verified by `gate.sh` step 1 in both repositories,
  `check-index.sh` and `sync-standards.sh`; the shell-only parse and the by-name refusal are each
  gate's step 1, in "In this repository" and "In a consuming project".
- **The new tests are w (step 1's file list) and x (usage)** (owner's choice over relettering the
  harness): patchbay's letters for the same cases, g and u, are taken here. e and f now end in the
  `FAIL  step N/3` line with exit 1 (f's recorded status was `bash -n`'s 2).
- **Sequence:** the two gate files first, gate green; the rules; the CHANGELOG. Every negative test
  rerun after the last edit to a gate file, j included.
- **The two `gate.sh` files read the same apart from their step lists.** `verification/gate-sh-diff.txt`
  is the `diff -u` of patchbay's at `origin/main` against this repository's as shipped. Its hunks
  are the header's step paragraphs, the pins block (`PYMARKDOWN_VERSION` here, "none yet" there),
  the step banners and bodies, the N/M numbers in the usage, header and closing lines, and the
  standard paths spelled from each repository's root (`base/process/…` here,
  `agent-os/standards/base/process/…` there). The skeleton is identical: the usage check, the
  `step` and `fail` helpers, step 1's loop, the closing line's shape.
- **The patchbay checkout is read at `origin/main`**, never from its working tree, which is on a
  feature branch; its `.version` pins this repository's `b3fc2fe`, the `main` this branch starts
  from.

## Context

- **Visuals:** None.
- **References:** `references.md`.
- **Product alignment:** N/A (no `agent-os/product/`).

## Standards Applied

**Core (always applied):**
- none yet (Step 5a)

**Feature-specific:**
- `process/verification-gate` — the gate's own spec: every gate file changes here with its
  negative test; edited as feature work from the aligned scripts (the exit contract, the listing
  rule, the harness shape, "In this repository" and "In a consuming project").
- `process/standards-sync` — edited as feature work from patchbay's workflow and harness (the pin
  step, the fixture); the listing rule is verified against `scripts/sync-standards.sh` too.
- `process/ownership` — no commit, stage, push, PR, approval or merge by an agent; nothing
  installed (bash, git and uv are already present).
- `process/standards-retrospective` — governs the closing step; the base edits here are feature
  work on this spec's branch, not retrospective edits.
- `process/standards-index` — the two descriptions rewritten because their rules changed, in the
  same change set; the symlink follows.

## Verification Gate

Spec is not complete until `scripts/gate.sh` passes — `bash -n` on every shell script under
`scripts/` as git lists them, `pymarkdown` over `base/` and `README.md`, and
`scripts/check-index.sh` — and the three judgment steps are recorded, in this order: Docs,
Version, then the standards retrospective below.

**Results (2026-11-05):** `scripts/gate.sh` exit 0 on the tree, run as the last act before
hand-over on branch
`task/10-gate-spec-2-land-the-five-base-proposals-from-patchbays-first-specs-and-align-this-repositorys-gate`;
`verification/gate-run.txt` holds the transcript with the date and branch on its first line. The
gate was green after each part, in the issue's order: after `scripts/gate.sh` was aligned, after
the harness, after the two standards and the index. Both gate files changed in this spec, so every
negative test ran after the last edit to either, each run asserting its expected status:
`verification/gate-negative-tests.txt` holds every test but j, 123 runs, 0 unexpected, the
harness's own exit 0 on its last line. w (step 1 lists files with git: an ignored
`scripts/.DS_Store` passes with the gate green; a tracked `scripts/notes.txt` is "not a shell
script", exit 1, `2/3` never printed; the tracked harness copy deleted from the disk is "tracked
but missing from the disk", exit 1; the copy without `.git` is "not a git work tree", exit 1) and
x (`--help` and a stray argument print the usage line and exit 2 with no step banner; the clean
copy exits 0) are new. e ends in `FAIL  step 2/3` and f in `FAIL  step 1/3`, each exit 1, where f
recorded `bash -n`'s 2 before. a to n are otherwise the fifth spec's cases on the aligned gate, o
to v the sync script's, every recorded status reproduced. `verification/ci-negative-test.txt`
holds j, 2 runs, 0 unexpected: the workflow's one `run` step passes on the clean copy and fails
with exit 1 on the copy with `scripts/broken.sh`, the job stopping at step 3; the workflow is
unchanged since the fourth spec, and j reruns because both gate files changed. The hosted run on
the pull request is for the owner to record at its end once it exists.
`verification/gate-sh-diff.txt` is the `diff -u` of patchbay's `scripts/gate.sh` at `origin/main`
(`0916b55`) against this repository's: its hunks are the header's step paragraphs, the standard
paths spelled from each root, the pins block, the N/M numbers, and the step banners and bodies;
the usage check, the `step` and `fail` helpers, step 1's loop and the closing line's shape are
identical. That is the reading of "differ only in their step lists" this spec records: the step
lists, the pins those steps need and the paths each repository spells from its root.

**Docs (step 4):** `README.md` reads true unchanged. `CLAUDE.md`'s Specs section now says step 1
as the script does it, every shell script under `scripts/` as git lists them, and names the exit
contract; nothing else in it changed and the rest reads true (the gate's three steps, the
judgment order, CI). `.claude/commands/agent-os/shape-spec.md`: the gate task's step 1 and its
"runs steps 1–3 as one command" sentence, and the template's Verification Gate paragraph, say the
same; Step 8's reminder names the three steps and reads true. `scripts/gate.sh`'s header names
steps 1-3, the judgment steps 4-6, the usage, the exit contract, the listing rule and what each
step needs, each read against the code below it; `scripts/gate-negative-tests.sh`'s header names
the hard failure, the guard, the assertion, the summary line, the test list with w and x and what
each group tests, read against the helpers and cases. `.github/workflows/gate.yml` is unchanged
and its header true. `index.yml`'s header is unchanged and true; the two rewritten descriptions
hold no `: ` and no ` #`, and step 3 agrees on 5 standards. `base/process/verification-gate.md`
and `base/process/standards-sync.md` were written from the files and read back line by line:
every status, the `FAIL` line, the listing flags, the harness's guard and counts, the pin step's
`id`, `GITHUB_OUTPUT`, `sha` and `ref`, the fixture's clone and symlink, the test letters, the
transcript home. `base/process/standards-index.md`, `base/process/standards-retrospective.md` and
`base/process/ownership.md` are unchanged and read true against the diff. No line in `base/`,
`CLAUDE.md` or `CHANGELOG.md` exceeds 100 columns.

**Version (step 5):** recorded under `[Unreleased]` in `CHANGELOG.md`: the sixth spec's Added
entry (the two standards, the harness's w and x, the diff transcript) and Changed entries for
`scripts/gate.sh`, `scripts/gate-negative-tests.sh`, the two documents and `index.yml`. The
repository has no version number to bump.

**Not done by the agent, by rule:** no file staged, committed or pushed, no pull request opened;
the owner reads the diff at commit time.

## Standards Retrospective

Step 6, always last. Per `base/process/standards-retrospective.md`. Applied 2026-11-05 from the
shipped diff against `main` (`.claude/commands/agent-os/shape-spec.md`, `CHANGELOG.md`,
`CLAUDE.md`, `base/process/standards-sync.md`, `base/process/verification-gate.md`, `index.yml`,
`scripts/gate-negative-tests.sh`, `scripts/gate.sh`, and this spec folder). The edits to the two
base files are this spec's feature work, written from the shipped scripts and patchbay's files,
not retrospective edits; the questions are asked of everything the diff touched.

1. *A pattern no standard covers?* The five proposals are now rules, as feature work. This spec
   itself taught one more, written into `verification-gate.md` "In this repository" as feature
   work: a gate aligned with another repository's keeps the `diff -u` of the two scripts in its
   `verification/`, so "read the same apart from their step lists" has its proof beside it
   (`verification/gate-sh-diff.txt`). Nothing else new: the harness's one `check` helper, shared
   by `run`, test i's direct captures and j's replay, is a detail of the harness-shape rule; the
   test letters, the transcript headers and this record follow the fourth and fifth specs'.
2. *A standard wrong or stale?* Four sentences, each corrected as feature work from the files:
   `verification-gate.md`'s "exits non-zero" (now 1, named, and 2 on usage), its "every script
   under `scripts/` parses" (shell scripts, as git lists them), its "fifteen" (seventeen), and
   `standards-sync.md`'s two-form clause for the sibling checkout ("or the checkout fetches the
   whole history"), which patchbay's revision showed fails on a squashed pin. Found while reading,
   not changed: the fifth spec's open proposal (what a spec records when a new base file is not
   yet staged) is still open and still not this spec's; `verification-gate.md`'s "Every step
   reports by name" reads true with the `FAIL` line on stderr, since a bare exit code is still
   not a report.
3. *A deliberate deviation?* None. The gate files changed in this spec, whose feature is the
   gate, each with its negative test; the two scripts' remaining differences beyond the step
   lists (the pins and the paths) are the stated reading of the issue's rule, recorded under
   Results, not a departure from it.
4. *A moved pointer?* One, updated: `verification-gate.md`'s "the spec that last changed the
   harness holds the current transcripts" now names issue #10. No standard pointed at a file this
   spec renamed; `CLAUDE.md` and `shape-spec.md` still point at `scripts/gate.sh` and
   `scripts/check-index.sh`, which exist.

No project standard exists to edit. `index.yml`: the `process/verification-gate` and
`process/standards-sync` descriptions rewritten because their rules changed, in the same change
set, as `standards-index.md` directs; the symlink follows. No retrospective edit beyond the
feature work above, and no new base proposal: the base files this spec touches are its feature,
on its own branch, for the owner's review.

### Standards retrospective (proposed, base)

None. The five proposals this spec lands were the base changes; they are applied here as feature
work, not proposed.
