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

## Revision after review (2026-11-05)

The owner's review of PR 9 at `3d3e111` listed 22 findings, two reproduced on macOS and blocking:
BSD `head -n 0` exits 1, so a `base:` section or an `--init` insertion point on line 1 crashed the
splice, and a sync that failed there had already replaced `base/` and `.version`, leaving the
project half-synced. The owner and the agent went through the findings in plan mode and decided
each; the dispositions are tabled in `plan.md` under "Revision after the review of PR 9". Four were
the owner's choices; the rest were accepted as the review recommends. The decisions that extend or
reverse the ones above:

- **The whole review, on this branch, in this spec folder.** Every transcript in `verification/`
  is rerun: `gate-run.txt`, `gate-negative-tests.txt`, and j in `ci-negative-test.txt` so the
  verification-gate sentence about the current transcripts reads true here.
- **The self-copy stays the last act; the words change** (owner's choice over exec'ing the target
  commit's script first). The project's copy is replaced with the script at the pinned commit as
  the last thing a sync writes, so the next sync runs it; the sync that delivers a change to the
  script is run by the copy before it. The header and `standards-sync.md` say that, not "the
  version that produced its tree".
- **The default ref is origin's default branch** (owner's choice), `refs/remotes/origin/HEAD` of the
  checkout, `origin/main` here, not the checkout's `HEAD`: a bare sync pins a pushed, merged commit.
  A checkout with no `origin/HEAD` is told to pass a ref or set one (exit 2). An explicit ref whose
  commit is not an ancestor of that branch is synced with a `WARN` line naming it, since a rebased
  or abandoned branch leaves the pin pointing at nothing. The scratch upstream in the harness
  carries `origin/main` so the default is what the tests exercise (test o pins `origin/main` with
  `HEAD` one commit ahead, then syncs `HEAD` explicitly and shows the warning).
- **The export is `git ls-tree` plus `git cat-file blob`**, not `git archive`: raw bytes from the
  commit's tree, so neither the checkout's `core.autocrlf` nor an attribute reaches the project
  (the review reproduced `git archive` writing `\r\n` under `core.autocrlf=true`). An entry that is
  not a regular blob, or a path holding a control character, is refused (exit 2) at both ends, so
  the newline-separated lists and the JSON hold by construction.
- **A sync builds everything in a temporary directory and swaps it in.** Every precondition is
  checked first, the target commit's `base:` section included, and nothing in the project is
  touched before all of `base/` (with `.version`), the new index and the section are built; exit 2
  leaves the project as it was. The index is written to a temporary file beside it and moved into
  place; the JSON is printed after the script copy, not before it.
- **One awk walks the section**, printing its bounds; extraction, splice and `--init` insertion are
  each one awk over a line range, so `head -n 0` cannot happen and the two state machines of the
  first round cannot drift apart. `--init` normalizes the blank lines around the insertion (the
  run directly above collapses to one, a missing final newline is added) and the header and the
  standard now say so.
- **The verification-gate sentence is fixed in place, as feature work** (owner's choice over
  reverting it to a proposal, the review's low-confidence item 18): the file's "In this
  repository" paragraph is Task 5 of the first plan, and the retrospective's answer 2 below says the
  edit was feature work. The count reads "a to n except j", and j is rerun here.
- **The CI guidance names the layout**: both repositories under the workspace, the project in a
  subdirectory and `patchbay-standards` beside it at the commit in `.version`, the gate run from the
  project's directory. `actions/checkout` cannot write outside the workspace, so a sibling of the
  workspace root is not an option there.
- **The harness** builds its upstream with `mk` plus a commit and `origin/main` (`push_upstream`
  moves it, as a push would), checks `first_sync`, computes the entry counts it reports, and its
  oracle trims the trailing blank and comment lines of the root `index.yml` by a second
  implementation of the rule; r syncs an upstream index with a trailing comment to show the rule's
  upstream side, and runs the `3d3e111` script on the line-1 case to show items 1 and 2 as they
  were.

## Context

- **Visuals:** None.
- **References:** `references.md`.
- **Product alignment:** N/A (no `agent-os/product/`).

## Standards Applied

**Core (always applied):**
- none yet (Step 5a)

**Feature-specific:**
- `process/ownership` — no commit, stage, push, PR, approval or merge by an agent; nothing
  installed outside the repository (git, comm, cmp, awk, sed and uv are already present).
- `process/standards-sync` — added for the revision after the review of PR 9, as it read at
  `3d3e111` (`standards.md`); rewritten here as feature work from the shipped script, so that the
  self-copy, the default ref, the export, the build-then-swap and the CI layout read true.
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

**Results (2026-11-05, after the review of PR 9):** `scripts/gate.sh` exit 0 on the tree, run as
the last act before hand-over on branch
`feature/8-sync-spec-scriptssync-standardssh-the-safe-index-regeneration-and-baseprocessstandards-syncmd`;
`verification/gate-run.txt` holds the transcript with the date and branch on its first line. One
transcript now: every input is tracked, so step 3 agrees on 5 standards on the tree itself (the
first hand-over's two-transcript record, with the new standard unstaged, is superseded). The gate
was green after each part of the revision: the script, the harness, the standards. Every gate-file
edit was followed by the harness, after its last edit: `verification/gate-negative-tests.txt`, a to
n unchanged from the fourth spec's transcript but for test i's MD013 counts, which rise with the
lines under `base/`, and o to v each failing by name with the expected exit status and passing
where they must, r running the `3d3e111` script on a section on line 1 to show the crash and the
half-synced project the review reproduced and then the shipped script on the same;
`verification/ci-negative-test.txt`, j (the CI replay) rerun because the harness changed, with the
hosted run on PR 9's first head recorded by id (42099057981, success on `3d3e111`); the run on the
revised head is read back by the owner or the next session after the push.
`verification/branch-protection.txt` is unchanged.

**Docs (step 4):** `README.md` reads true unchanged ("synced in, pinned by commit, never edited
in place"); `CLAUDE.md` reads true unchanged. `scripts/sync-standards.sh`'s header names its three
modes, the default path and ref and what each refusal is, what a sync does in order (`git
cat-file`, every precondition first, built in a temporary directory and swapped in, the copy of
itself as the last write and what that means for the sync that delivers a change), the section
rule with `--init`'s normalization, the file list and the exit codes, each read against the code
below it. `scripts/gate-negative-tests.sh`'s header and usage line name o to v, the two fixtures
and `origin/main` as the default ref. `index.yml`'s header is unchanged and true; the
`process/standards-sync` description names the default ref and holds no `: ` and no ` #`.
`base/process/standards-sync.md` was rewritten from the shipped script and harness and read back
line by line: every flag, default, exit status, the `WARN` line, the test letters, the CI layout.
`base/process/verification-gate.md`: fifteen (a to n except j) is the harness's count; the current
transcripts, j's included, are in this spec's `verification/`; its "In a consuming project"
sentence matches `standards-sync.md`. `base/process/standards-index.md` and
`base/process/standards-retrospective.md` are unchanged this round and read true against the
script. `.claude/commands/agent-os/*` are unchanged. No line in `base/`, `CLAUDE.md` or
`CHANGELOG.md` exceeds 100 columns.

**Version (step 5):** recorded under `[Unreleased]` in `CHANGELOG.md`: the fifth spec's Added
bullets rewritten to the shipped script, harness and standard, with one sentence naming the PR 9
review and where its dispositions are; the Changed lines for `verification-gate.md` and
`index.yml` updated. The repository has no version number to bump.

**Not done by the agent, by rule:** no file staged, committed or pushed, and the pull request not
edited; the owner reads the revision at commit time.

## Standards Retrospective

Step 6, always last. Per `base/process/standards-retrospective.md`. Applied 2026-11-05 twice,
at the first hand-over and again after the review of PR 9, from the shipped diff against `main`
(`CHANGELOG.md`, `base/process/standards-index.md`, `base/process/standards-retrospective.md`,
`base/process/standards-sync.md` (new), `base/process/verification-gate.md`, `index.yml`,
`scripts/gate-negative-tests.sh`, `scripts/sync-standards.sh` (new), and this spec folder). The
edits to the four base files are this spec's feature work, written from the shipped script and
harness, not retrospective edits; the questions are asked of everything the diff touched.

1. *A pattern no standard covers?* From the first round, two, written into
   `base/process/standards-sync.md` as feature work: the sync itself (what it writes, the `base:`
   section rule, the sibling default, the self-copy) and the scratch-fixture shape for testing a
   script that runs in a consuming project (a checkout whose `HEAD` holds the working tree's
   files beside a scratch Agent OS install, `mk_upstream` and `mk_project`). The revision taught
   two more, written into the same standard as feature work and verified by the harness: a script
   that writes several things checks every precondition, builds them in a temporary directory and
   swaps them in, so a refusal writes nothing (test u, `git status` empty after a refused commit);
   and a sync's default ref is origin's default branch, never a checkout's `HEAD`, with a warning
   on an explicit ref off it (test o). Nothing else new: the stderr report follows `gate.sh`'s
   `ok   <what>` shape, the JSON object is the issue's ask, and the test transcripts follow the
   fourth spec's, as does this revision's record (a "Revision after review" section here, the
   dispositions tabled in `plan.md`).
2. *A standard wrong or stale?* First round, corrected as feature work: `standards-index.md`'s
   interim hand-copy sentence and "named here when it ships"; `verification-gate.md`'s count and
   transcript claim; both "does not pass the gate" sentences, now "does not merge", true since the
   owner enabled branch protection after PR 7 and recorded here. The review found three more in
   this spec's own text, each corrected in place as feature work on this branch:
   `standards-sync.md`'s claim that a project carries "the version of the script that produced
   its tree" (the tree is written by the running copy; the standard now says what the last-act
   copy means), its "every other line left as it was" with `--init`'s blank-line normalization
   unsaid, and `verification-gate.md`'s "fifteen (a to n)", which is sixteen with j, beside a
   transcript sentence that was false while j was not rerun (now "a to n except j", j rerun).
   The verification-gate sentence stays an in-place edit, the owner's choice on the review's item
   18: the file's "In this repository" paragraph is Task 5 of the first plan, and the file is in
   this spec's scope as feature work, not a retrospective edit. Found while reading, not changed:
   `verification-gate.md` says every spec keeps its green run and that a step that cannot pass on
   the shipped tree is a defect in the tree, and `standards-index.md` says `check-index.sh`
   refuses an untracked file under `base/`; together they mean a spec that adds a base standard
   cannot show the gate green on its own tree before the owner stages the file, which this spec
   met at its first hand-over. That is a gap in the gate standard, proposed below.
3. *A deliberate deviation?* At the first hand-over, one: `gate-run.txt` held the tree's run with
   its one named step-3 report beside a green run on a temporary copy with the new standard
   git-added, because staging is the owner's. Superseded: the owner committed, and the tree's run
   is green. None in the revision. The gate files changed in this spec, which the issue frames as
   theirs; the base edits are on this spec's branch for the owner's review.
4. *A moved pointer?* None moved. New pointers added where a standard named a thing that now
   exists: `standards-index.md` at `standards-sync.md` and `--index-only`,
   `verification-gate.md` at the sync standard, `--check` and the project workflow's checkout of
   `patchbay-standards`, `standards-retrospective.md` unchanged but for the merge wording (its
   two pointers still resolve).

No project standard exists to edit. `index.yml`: `process/standards-sync` added and the
`process/standards-index` description rewritten because its rule changed, in the same change set,
as `standards-index.md` directs; the `process/standards-sync` description names the default ref
since the revision changed that rule. The symlink follows.

### Standards retrospective (proposed, base)

- `base/process/verification-gate.md` — "Every step that can fail is proven to fail" or "Every
  spec keeps its green run": say what a spec that adds a tracked-only input (a new standard under
  `base/`) records when the owner has not yet staged it, since `scripts/check-index.sh` refuses an
  untracked file by design and an agent never stages. This spec's answer at its first hand-over,
  the tree's run beside a green run on a temporary copy with the file git-added, both in
  `gate-run.txt`, is the shape to write down or to replace. Proposed, not applied; a base standard
  changes in its own spec here, with the owner.
