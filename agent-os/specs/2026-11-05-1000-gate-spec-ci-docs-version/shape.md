# Gate spec: CI, Docs and Version as judgment steps, and the PR 5 gate-file fixes — Shaping Notes

Shaped 2026-11-05 in plan mode with `/agent-os:shape-spec`, the questions asked and answered by the
owner (Steps 1–5 and the four design decisions, recorded under Decisions).

## Core Architecture (Non-Negotiable)

None yet; see Step 5a of `.claude/commands/agent-os/shape-spec.md`. The first base standards will
fill this tier.

## Scope

GitHub issue #3, "Gate spec: CI workflow, Docs and Version as judgment steps, and the gate-file
fixes from the PR 5 review". The one gate spec: `base/process/verification-gate.md` says the gate's
files change only in a spec whose feature is the gate, so every change the PR 5 review found
against a gate file lands here, together, each changed step carrying its negative test. In the
owner's order, the gate green at the end of each part:

1. `scripts/check-index.sh`: `comm` under `LC_ALL=C` like the sorts that feed it; the file list is
   the tracked files under `base/` (`git ls-files`); the header points at
   `base/process/standards-index.md`. Negative tests g and h.
2. `agent-os/standards/index.yml` becomes a symlink to `../../index.yml`; the `cmp` check becomes
   an is-a-symlink-to-that-target check. Negative tests c1 and c2 replace the first spec's c.
3. `.pymarkdown.yaml` shown to be read: negative test i, a config that changes a default, shown to
   apply.
4. Docs and Version as judgment steps 4 and 5, the retrospective 6, in `shape-spec.md`'s gate
   task, `gate.sh`'s closing line and `CLAUDE.md`.
5. `.github/workflows/gate.yml`: one job, on push and pull_request, checkout, uv, `scripts/gate.sh`,
   nothing else, actions pinned. Negative test j, proved without a push.
6. The CI, Docs and Version rules in `verification-gate.md` and the "In this repository" update in
   `standards-index.md`, written last, from the shipped files.

CHANGELOG entry under Unreleased; gate green; `verification/gate-run.txt`; no commit, stage, PR or
push by an agent.

## Shaping answers

- **Step 1, scope:** exactly the issue, in the six-part order above. `shape-spec.md`'s empty Core
  Architecture tier stays empty.
- **Step 2, visuals:** none.
- **Step 3, references:** the shipped gate files and the three spec folders; see `references.md`.
- **Step 4, product context:** `agent-os/product/` does not exist. Skipped.
- **Step 5, standards:** all four under `base/process`, included.

## Decisions

- **GitHub issue #3 is the scope.** Its six sections are the six parts; its "Rules" paragraph is
  this spec's definition of done. Nothing outside it changes but `CHANGELOG.md`, this spec folder
  and the `index.yml` description the gate rule change requires.
- **This is the gate's own spec.** Every gate file (`scripts/gate.sh`, `scripts/check-index.sh`,
  `.pymarkdown.yaml` unchanged but tested, the gate task in `shape-spec.md`) changes here and
  nowhere else, as `verification-gate.md` directs; the two base standards are edited as this spec's
  feature work on its own branch, as `CLAUDE.md` and the retrospective standard direct, and
  written last, from the shipped files, never from `plan.md`.
- **Action pins are full commit SHAs with the tag in a comment**, verified to exist on 2026-11-05:
  `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1` (v7.0.1, 2026-07-20) and
  `astral-sh/setup-uv@68559e99cc807c1eb7e9238fd43a15bba460eec2` (v10.3.3, 2026-10-28). Why: a tag
  can be moved; a commit cannot. The CI rule says "pinned to a commit".
- **uv is pinned to 0.13.7** (published 2026-11-03, the version on the owner's machine) through
  setup-uv's `version` input, and the runner image to `ubuntu-24.04`, not `-latest`. Why: CI runs
  what the gate was proven with; a pin is bumped deliberately, like the pymarkdown pin.
- **The CI negative test is a local run of the workflow's own steps**, in a scratch copy with a
  broken script, showing the one `run` step exits non-zero; GitHub fails a job at the first step
  that exits non-zero. `act` is not installed and the owner was asked rather than it being
  installed; the owner declined. The owner owns pushes, so the real run happens when the PR opens.
- **"Does not pass the gate" stays** in `standards-retrospective.md` and `standards-index.md`.
  `main` has no branch protection today (`gh api .../branches/main/protection` returns 404), so no
  check is required to merge and "does not merge" would be written from intention. The owner will
  enable branch protection on `main` requiring the gate check after this merges; the wording
  upgrades to "does not merge" once that setting exists and can be verified, in its own spec.
- **Negative tests for the tracked-files list run in a scratch `git init` fixture** with the files
  `git add`ed: `git ls-files` reads the index, so no commit is made anywhere. Every negative test
  runs on a copy in the scratchpad, never on the tree.
- **The first spec's six negative tests stay as recorded**; a, b, d, e, f are rerun here on the
  shipped scripts, c is replaced by c1 and c2, and this spec's `verification/` holds the current set.
- **`index.yml` changes one description**, `process/verification-gate`, because its rule changes
  (CI and the judgment steps); the index standard says the description is rewritten in the same
  change set. The symlink follows the root file by construction.

## Context

- **Visuals:** None.
- **References:** `references.md`.
- **Product alignment:** N/A (no `agent-os/product/`).

## Standards Applied

**Core (always applied):**
- none yet (Step 5a)

**Feature-specific:**
- `process/ownership` — no commit, stage, push, PR, approval or merge by an agent; `act` asked for
  and not installed; the gate's pinned tool runs through `uvx`, already present.
- `process/standards-retrospective` — governs the closing step and the rule that a rewritten
  standard is verified against shipped files; its "does not pass the gate" wording is left alone.
- `process/standards-index` — edited here as feature work: the tracked-files list and the symlink.
- `process/verification-gate` — edited here as feature work: the judgment steps and the CI rule;
  also the rule that puts every gate-file change in this one spec with its negative test.

## Revision after review (2026-11-05)

The first review of PR 7 listed 27 findings at `cf1bdf0`; the owner and the agent went through
them in plan mode and decided each. The dispositions are tabled in `plan.md`. Four were the owner's
choices; the rest were accepted as the review recommends. The decisions that extend or reverse
the ones above:

- **Finding 1 was real and blocking.** The expected list was sorted before `base/` and `.md` were
  stripped, so a key that is a prefix of another (`testing`, `testing-fakes`) left it unsorted; on
  ubuntu GNU `comm` refuses unsorted input and the script read its exit as "nothing missing", so CI
  passed an unindexed standard. The script now exports `LC_ALL=C` once, sorts after each transform,
  checks both lists sorted and tests `comm`'s exit on its own. Test k shows the `cf1bdf0` script
  passing `zeta.md` unindexed under GNU `comm` (`gcomm` first on PATH) and the shipped one failing
  by name.
- **The script reports what it reads.** It runs only in a git work tree whose top is the repository
  root and says so otherwise (test m); it refuses an untracked file under `base/` (test h, so a
  standard never added to git no longer passes when it has no entry) and a tracked file missing
  from the disk (test n); paths come unquoted (test l, `café.md`); a directory at the symlink's path
  is named as one (test c3).
- **The workflow's triggers are pull requests and pushes to `main`** (owner's choice), so a PR head
  runs once; `enable-cache: false`, `persist-credentials: false`, `timeout-minutes: 10`.
- **The CI-proof rule is narrowed** (owner's choice): the local replay proves the job's control flow
  before any push; the hosted run on the pull request is the proof of the workflow, recorded by
  run id and conclusion once it exists; portability is the script's own, proven by its tests. The
  runs on `cf1bdf0`, 42062523298 (push) and 42062688286 (pull_request), both success, are
  recorded in `verification/ci-negative-test.txt`; the next head's run is read back by the owner
  or the next session.
- **The harness is committed** as `scripts/gate-negative-tests.sh` (owner's choice): parsed by
  step 1, not run by the gate, every copy in `mktemp -d`; both transcripts are its output.
- **The one-workflow rule is scoped to the gate's workflow**; a project may have other workflows.
- **"A config the tool cannot parse fails the step" is narrowed**: an unknown key is not refused,
  so the spec that changes the config shows a changed value applied in a negative test.
- **Pins are bumped "in the gate's own spec"** everywhere: the standard's Pinned section,
  `gate.sh`'s pin comment and `.pymarkdown.yaml`'s header had said "outside a spec".
- **The `shape.md` template records the gate first and the retrospective last**, with slots for
  Docs and Version, and names the root `index.yml` as the file the retrospective updates here;
  the stock `index-standards.md` and `discover-standards.md` stay stock (owner's choice). This file
  is reordered to match.

## Verification Gate

Spec is not complete until `scripts/gate.sh` passes — `bash -n` on every file under `scripts/`,
`pymarkdown` over `base/` and `README.md`, and `scripts/check-index.sh` — and the three judgment
steps are recorded, in this order: Docs, Version, then the standards retrospective below.

**Results (2026-11-05, first hand-over):** `scripts/gate.sh` exit 0 at the end of each of the six
parts; the negative tests a, b, c1, c2, d, e, f, g, h, i and the CI replay j run from a scratchpad
harness. Superseded by the review of PR 7.

**Results (2026-11-05, after the review of PR 7):** `scripts/gate.sh` exit 0, run as the last act
before hand-over on branch
`feature/3-gate-spec-ci-workflow-docs-and-version-as-judgment-steps-and-the-gate-file-fixes-from-the-pr-5-review`;
`verification/gate-run.txt` holds the transcript with the date and branch on its first line. The
three scripts parse; pymarkdown 0.9.41 reports no findings over `base/` and `README.md`;
`index.yml` and the tracked files under `base/` agree on 4 standards and
`agent-os/standards/index.yml` is a symlink to `../../index.yml`. Every gate file changed, so
`scripts/gate-negative-tests.sh` was run after the last gate-file edit: a, b, c1, c2, c3, d, e, f,
g, h, i, k, l, m, n in `verification/gate-negative-tests.txt`, each negative failing with the
named reason and exit status, k and l also passing where they must, and j in
`verification/ci-negative-test.txt` with the hosted runs so far by id.

**Docs (step 4):** `README.md` reads true unchanged. `CLAUDE.md` names the three runnable steps,
the three judgment steps in order, and the workflow's triggers as shipped. `scripts/gate.sh`'s
header names steps 4–6 and the workflow, its pin comment says "in the gate's own spec", its step 3
banner says tracked files. `scripts/check-index.sh`'s header lists every check it makes and points
at the index standard. `scripts/gate-negative-tests.sh`'s header says what it is and that the gate
does not run it. `.pymarkdown.yaml`'s header points at the gate standard. `index.yml`'s header
says tracked files and the symlink. `.github/workflows/gate.yml`'s header points at the gate
standard's "CI" and explains its four settings. `shape-spec.md`'s gate task, Step 5 snapshot
paragraph ("gate step 6"), Step 8 reminder, Step 9 text, `shape.md` template and tips agree with
the gate as shipped. The two base standards are the shipped text, read against the scripts and
the workflow line by line; `standards-retrospective.md`'s two pointers still resolve and its
"does not pass the gate" is still true. The second spec's `shape.md`, which says Docs and Version
are "ahead of the gate files until issue #3 lands", is a record and is left as written. No line in
`base/` or `CLAUDE.md` exceeds 100 columns.

**Version (step 5):** recorded under `[Unreleased]` in `CHANGELOG.md`: Added for the workflow,
the symlink, the judgment steps, the harness and its tests, and the two standards; Changed for
`check-index.sh`, the index header and description, and the pin wording in `gate.sh` and
`.pymarkdown.yaml`. The repository has no version number to bump.

**Not done by the agent, by rule:** no file staged, committed or pushed; `act` not installed; the
next hosted run of the workflow happens when the owner pushes this head to the pull request. The
owner stages the typechange of `agent-os/standards/index.yml` with the rest.

## Standards Retrospective

Step 6, always last. Per `base/process/standards-retrospective.md`. Applied 2026-11-05 from the
shipped diff (`git diff origin/main`: `.claude/commands/agent-os/shape-spec.md`,
`.github/workflows/gate.yml`, `.pymarkdown.yaml`, `CHANGELOG.md`, `CLAUDE.md`,
`agent-os/standards/index.yml` (typechange to a symlink), `base/process/standards-index.md`,
`base/process/verification-gate.md`, `index.yml`, `scripts/check-index.sh`,
`scripts/gate-negative-tests.sh`, `scripts/gate.sh`, and this spec folder). The edits to the two
base standards are this spec's feature work (part 6 and the review), written from the shipped
files, not retrospective edits; the questions are asked of everything the diff touched.

1. *A pattern no standard covers?* Three, each written into the gate standard as feature work
   before use and verified against the shipped file: the CI shape (`.github/workflows/gate.yml`),
   the way a workflow is proven before and after a push (the replay in
   `scripts/gate-negative-tests.sh` j, the hosted run by id), and the negative tests as a committed
   script beside the gate's. Nothing else new: the symlink repeats the shape
   `agent-os/standards/base` already had, and the transcript shape follows the first spec's.
2. *A standard wrong or stale?* Corrected as feature work from the shipped scripts:
   `standards-index.md` said the project index is "identical, byte for byte" and held by `cmp`
   (now a symlink, held by `readlink`), that the files are "under `base/`" (now the tracked files,
   with untracked and missing-on-disk files refused), and that a never-added standard "cannot pass
   locally" (true now that an untracked file is refused; it was not true at `cf1bdf0`, as the
   review showed); `verification-gate.md` said one judgment step follows the script (now three),
   listed the gate files without the workflow, gave opposite pin rules ("outside a spec" and "in
   the gate's own spec"), claimed a config the tool cannot parse fails the step without saying an
   unknown key does not, bound every workflow of a project to the gate's shape, and let a local
   replay stand as proof of the hosted run. Found while reading, not changed:
   `standards-retrospective.md` says a proposal without its entry "does not pass the gate", which
   stays true and stays as it is; the owner will require the `gate` check on `main` after this
   merges, and the wording upgrades to "does not merge" in its own spec once that setting exists
   and can be verified with `gh api repos/.../branches/main/protection`.
3. *A deliberate deviation?* None. The gate standard's "In this repository" counts this spec's
   tests as fifteen for the scripts and the CI replay; the first spec's six stay as recorded, as
   the standard's own transcript rule says. The stock `index-standards.md` and
   `discover-standards.md` still name `agent-os/standards/index.yml` as the file to update; here
   that is the symlink, and `standards-index.md` already says the stock regeneration is not run on
   a synced index. Left as stock by the owner's choice, recorded here, not a standard change.
4. *A moved pointer?* Fixed: `scripts/check-index.sh`'s header pointed at the `index.yml` header
   PR 5 trimmed (now `base/process/standards-index.md`); `shape-spec.md` said the retrospective is
   "gate step 4" in its tips and in the Step 5 snapshot paragraph (now 6); `.pymarkdown.yaml`'s
   header pointed at `standards-retrospective.md` for the rule PR 6 moved to
   `verification-gate.md`; `verification-gate.md`'s "In a consuming project" said the gate task is
   followed by the retrospective alone (now Docs, Version and the retrospective); `index.yml`'s
   header said the script holds it equal to the files under `base/` and to the project index (now
   the tracked files, and the symlink).

No project standard exists to edit. `index.yml`: the `process/verification-gate` description is
rewritten because the rule changed, in the same change set, as `standards-index.md` directs; the
`process/standards-index` description still says what that standard decides. The symlink follows.

Standards retrospective: no changes beyond the feature work above. No `(proposed, base)` list:
this is `patchbay-standards`, the two base edits are on this spec's own branch, and the owner
approves them as the pull request.
