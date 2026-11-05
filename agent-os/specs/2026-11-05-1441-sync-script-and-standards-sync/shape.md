# Sync spec: `scripts/sync-standards.sh`, the safe index regeneration, and `base/process/standards-sync.md` — Shaping Notes

Shaped 2026-11-05 in plan mode with `/agent-os:shape-spec`, the Step 1–5 questions and the four
design decisions asked and answered by the owner (recorded under Decisions).

## Core Architecture (Non-Negotiable)

None yet; see Step 5a of `.claude/commands/agent-os/shape-spec.md`. The first base standards will
fill this tier.

## Scope

GitHub issue #8, "Sync spec: scripts/sync-standards.sh, the safe index regeneration, and
base/process/standards-sync.md". The script that makes a second patchbay repository possible: the
sync, the drift check, the safe regeneration of a consuming project's `base:` section, and the
standard that describes them, verified against the scripts as shipped. In the owner's order, the
gate green after each part:

1. `scripts/sync-standards.sh` with its negative tests against a scratch project in a temp dir.
2. The drift check.
3. The index regeneration, runnable alone.
4. `base/process/standards-sync.md` and the `standards-index.md` pointers, written from the
   shipped scripts.
5. "Does not merge" in `standards-index.md` and `standards-retrospective.md`, with the branch
   protection output recorded in `verification/`.

CHANGELOG entry under Unreleased; gate green; `verification/gate-run.txt`; no commit, stage, PR or
push by an agent.

## Shaping answers

- **Step 1, scope:** exactly the issue, in the five-part order above. `README.md` unchanged.
- **Step 2, visuals:** none.
- **Step 3, references:** the shipped gate files and the four spec folders; see `references.md`.
- **Step 4, product context:** `agent-os/product/` does not exist. Skipped.
- **Step 5, standards:** all four under `base/process`, included; three are edited here as feature
  work.

## Decisions

- **GitHub issue #8 is the scope.** Its sections are the parts above; its "Rules" paragraph is this
  spec's definition of done. Nothing outside it changes but `CHANGELOG.md`, `index.yml` (the new
  entry and the rewritten `standards-index` description) and this spec folder.
- **The drift check is a `--check` flag on the sync script** (owner's choice). One file is copied
  into each project and one version carried; the check reuses the sync's export and section
  extraction and writes nothing. A project's gate step is `scripts/sync-standards.sh --check`.
- **The upstream is a path argument with a sibling default** (owner's choice): `<path>` defaults to
  `../patchbay-standards`, the sibling layout every checkout here follows; a path that is not a
  patchbay-standards checkout fails with exit 2 naming the path. A project's CI adds one checkout
  step for the sibling. Why: the invariant is "byte-identical to patchbay-standards", so the check
  compares against the real thing, not a manifest that only proves "matches what the sync wrote".
  No clone fallback: no network call and no hard-coded URL in a gate step.
- **`base/` is replaced by `git archive` into a temp dir, compared by sorted lists and `cmp`, then
  swapped** (owner's choice over `rsync --delete`): only git, tar, comm and cmp are needed, and the
  sync's report and `--check` come from the same comparison so they cannot disagree. The swap is
  `rm -rf` then `mv`, a directory nothing else holds open.
- **The script copies itself from the synced commit, `mv`'d over the project's copy as the last
  act** (owner's choice over copying `$0`): tree and script always come from one commit, and the
  running bash keeps the old inode open so replacing the file under it is safe.
- **The section rule.** The `base:` section is the line `base:` with nothing after the colon plus
  every following line that is indented, blank or a column-0 comment, ending at the last indented
  line; trailing blank and comment lines and the next column-0 key belong to the project. A second
  `base:` line, or one with content after the colon, is "not parseable" (exit 2). `--init` inserts
  the section with one blank line on each side before the first column-0 key other than `root:`
  that sorts after `base` in C collation, else at the end; with no index file at all it creates
  one holding the section alone.
- **Exit codes:** 0 success; 1 a failed check (drift under `--check`, or the post-write
  verification of a sync); 2 usage and preconditions.
- **`.version` is the one non-`.md` file under a project's `agent-os/standards/base/`**, written
  after the swap and excluded from every comparison.
- **The project-side file list mirrors `check-index.sh`**: tracked plus untracked-not-ignored
  under `agent-os/standards/base`, existing on disk; an ignored `.DS_Store` is never drift.
- **The scratch project is a realistic Agent OS install**: `pyproject.toml`, `CLAUDE.md`, an index
  with a header comment, a `root:` section, a comment between sections, a `testing:` section and a
  trailing comment, and two local standards, so "own sections survive byte-for-byte" is tested
  against something that would notice.

## Context

- **Visuals:** None.
- **References:** `references.md`.
- **Product alignment:** N/A (no `agent-os/product/`).

## Standards Applied

**Core (always applied):**
- none yet (Step 5a)

**Feature-specific:**
- `process/ownership` — no commit, stage, push, PR, approval or merge by an agent; nothing
  installed outside the repository (git, tar, comm, cmp, awk and uv are already present).
- `process/standards-retrospective` — governs the closing step; its "does not pass the gate"
  sentence is edited here as feature work, verified against the branch protection output.
- `process/standards-index` — edited here as feature work: the interim hand-copy sentences become
  pointers at the sync standard, the safe regeneration is named, and "does not pass" becomes "does
  not merge".
- `process/verification-gate` — the gate-file rule (the sync script and the harness are gate
  files, so this spec carries their negative tests); its "In this repository" count and "In a
  consuming project" paragraph are edited here as feature work, from the shipped harness.

## Verification Gate

Spec is not complete until `scripts/gate.sh` passes — `bash -n` on every file under `scripts/`,
`pymarkdown` over `base/` and `README.md`, and `scripts/check-index.sh` — and the three judgment
steps are recorded, in this order: Docs, Version, then the standards retrospective below.

**Results (2026-11-05):** `scripts/gate.sh` run as the last act before hand-over on branch
`feature/8-sync-spec-scriptssync-standardssh-the-safe-index-regeneration-and-baseprocessstandards-syncmd`;
`verification/gate-run.txt` holds two transcripts with the date and branch on the first line. On
the tree as handed over, steps 1 and 2 pass (five scripts parse; pymarkdown 0.9.41 reports no
findings over `base/`, the new standard included, and `README.md`) and step 3 reports one thing:
`base/process/standards-sync.md` is under `base/` but not tracked, so its entry has no tracked
file. That is `check-index.sh` doing what the index standard says it does, and the fix is the
owner's `git add` of the new standard, which the ownership rule keeps from an agent. The second
transcript is the same `scripts/gate.sh` on a temporary copy of the tree with that one file
git-added, the copy pattern the harness uses: exit 0, step 3 agreeing on 5 standards and the
symlink in place. The gate was also green after each part (the script, the harness tests, the
standards) up to the point the new standard was created. Every gate-file edit (the new script,
the harness) was followed by `scripts/gate-negative-tests.sh`: a to n unchanged from the fourth
spec's transcript but for the new script in step 1's parse list, o to v each failing by name with
the expected exit status and passing where they must, in `verification/gate-negative-tests.txt`.
`verification/branch-protection.txt` holds the `gh api` output the "does not merge" wording is
verified against.

**Docs (step 4):** `README.md` reads true unchanged ("synced in, pinned by commit, never edited
in place" is now what the script does). `CLAUDE.md` reads true unchanged: the gate's three runnable
steps and the base standards "every patchbay repository syncs in" are as shipped.
`scripts/sync-standards.sh`'s header lists its three modes, the four things a sync writes, the
section rule, the file list and the exit codes, each read against the code below it.
`scripts/gate-negative-tests.sh`'s header and usage line name o to v and the two scratch fixtures.
`index.yml`'s header is unchanged and true. `base/process/standards-sync.md` was written from the
shipped script and harness and read back against them line by line (every flag, default, exit
status, test letter and file name resolves). `base/process/standards-index.md`'s two pointers
resolve to the new standard and the `--index-only` flag; `base/process/verification-gate.md`'s
test counts are the harness's (fifteen a to n, eight o to v, j); its "In a consuming project"
sentence matches what the script does to its own copy. `base/process/standards-retrospective.md`'s
"does not merge" matches `verification/branch-protection.txt`. `.claude/commands/agent-os/*` are
unchanged; `index-standards.md` still describes the stock rewrite, which the standards now say is
not run on a synced index. No line in `base/` or `CLAUDE.md` exceeds 100 columns.

**Version (step 5):** recorded under `[Unreleased]` in `CHANGELOG.md`: Added for the fifth spec
(the script and its three modes, tests o to v, the new standard, the protection record); Changed
for the three edited standards and the `index.yml` description. The repository has no version
number to bump.

**Not done by the agent, by rule:** no file staged, committed or pushed. The owner's `git add
base/process/standards-sync.md` (with the rest) is what turns the tree's step 3 green; rerunning
`scripts/gate.sh` after it is one command.

## Standards Retrospective

Step 6, always last. Per `base/process/standards-retrospective.md`. Applied 2026-11-05 from the
shipped diff (`git status` against `main`: `CHANGELOG.md`, `base/process/standards-index.md`,
`base/process/standards-retrospective.md`, `base/process/standards-sync.md` (new),
`base/process/verification-gate.md`, `index.yml`, `scripts/gate-negative-tests.sh`,
`scripts/sync-standards.sh` (new), and this spec folder). The edits to the four base files are
this spec's feature work, written from the shipped script and harness, not retrospective edits;
the questions are asked of everything the diff touched.

1. *A pattern no standard covers?* Two, both written into `base/process/standards-sync.md` as
   feature work before the standard was declared done and verified against the shipped files: the
   sync itself (what it writes, the `base:` section rule, the sibling default, the self-copy) and
   the scratch-fixture shape for testing a script that runs in a consuming project (a checkout
   whose `HEAD` holds the working tree's files beside a scratch Agent OS install, `mk_upstream`
   and `mk_project` in the harness). Nothing else new: the stderr report follows `gate.sh`'s
   `ok   <what>` shape, the JSON object is the issue's ask, and the test transcript follows the
   fourth spec's.
2. *A standard wrong or stale?* Corrected as feature work: `standards-index.md`'s interim
   hand-copy sentence and "named here when it ships"; `verification-gate.md`'s count of fifteen
   tests and its claim that the gate spec holds "the current transcripts" (now the spec that last
   changed the harness); both "does not pass the gate" sentences, now "does not merge", true since
   the owner enabled branch protection after PR 7 and recorded here. Found while reading, not
   changed: `verification-gate.md` says every spec keeps its green run and that a step that
   cannot pass on the shipped tree is a defect in the tree, and `standards-index.md` says
   `check-index.sh` refuses an untracked file under `base/`; together they mean a spec that adds
   a base standard cannot show the gate green on its own tree before the owner stages the file,
   which this spec met (Results above). That is a gap in the gate standard, proposed below.
3. *A deliberate deviation?* One, recorded here as a one-off: `gate-run.txt` holds the tree's
   run with its one named step-3 report and a green run on a temporary copy with the new standard
   git-added, instead of a single green run on the tree. Reason: the ownership rule; staging is
   the owner's. The rest follows the standards: the gate files changed in this spec, which the
   issue frames as theirs; the base edits are on this spec's branch for the owner's review.
4. *A moved pointer?* None moved. New pointers added where a standard named a thing that now
   exists: `standards-index.md` at `standards-sync.md` and `--index-only`,
   `verification-gate.md` at the sync standard and `--check`, `standards-retrospective.md`
   unchanged but for the merge wording (its two pointers still resolve).

No project standard exists to edit. `index.yml`: `process/standards-sync` added and the
`process/standards-index` description rewritten because its rule changed, in the same change set,
as `standards-index.md` directs. The symlink follows.

### Standards retrospective (proposed, base)

- `base/process/verification-gate.md` — "Every step that can fail is proven to fail" or "Every
  spec keeps its green run": say what a spec that adds a tracked-only input (a new standard under
  `base/`) records when the owner has not yet staged it, since `scripts/check-index.sh` refuses an
  untracked file by design and an agent never stages. This spec's answer, the tree's run beside a
  green run on a temporary copy with the file git-added, both in `gate-run.txt`, is the shape to
  write down or to replace. Proposed, not applied; a base standard changes in its own spec here,
  with the owner.
