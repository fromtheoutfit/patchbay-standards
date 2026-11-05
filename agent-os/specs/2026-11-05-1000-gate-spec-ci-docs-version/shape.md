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

## Standards Retrospective

Per `base/process/standards-retrospective.md`. Applied 2026-11-05 from the shipped diff
(`git diff origin/main`: `.claude/commands/agent-os/shape-spec.md`, `.github/workflows/gate.yml`,
`CHANGELOG.md`, `CLAUDE.md`, `agent-os/standards/index.yml` (typechange to a symlink),
`base/process/standards-index.md`, `base/process/verification-gate.md`, `index.yml`,
`scripts/check-index.sh`, `scripts/gate.sh`, and this spec folder). The edits to the two base
standards are this spec's feature work (part 6), written from the shipped files, not retrospective
edits; the questions are asked of everything the diff touched.

1. *A pattern no standard covers?* Two, both written into the gate standard as feature work before
   use, in the order the retrospective standard asks for, and verified against the shipped file:
   the CI shape (`.github/workflows/gate.yml`: one job, the script and nothing else, every action
   pinned by commit with the tag beside it, the runner pinned) and the way a workflow is proven to
   fail without a push (`verification/ci-negative-test.txt`: the job's steps read from the workflow
   file and run on a broken copy). Nothing else new: the symlink repeats the shape
   `agent-os/standards/base` already had, and the negative-test transcript follows the first spec's.
2. *A standard wrong or stale?* Two, corrected as feature work from the shipped scripts:
   `standards-index.md` said the project index is "identical, byte for byte" and held by `cmp`
   (now a symlink, held by `readlink`) and that `check-index.sh` lists "files under `base/`" (now
   the tracked files, `git ls-files`); `verification-gate.md` said one judgment step follows the
   script (now three) and listed the gate files without the workflow. Found while reading, not
   changed: `standards-retrospective.md` says a proposal without its entry "does not pass the
   gate", which stays true and stays as it is; the owner will require the `gate` check on `main`
   after this merges, and the wording upgrades to "does not merge" in its own spec once that setting
   exists and can be verified with `gh api repos/.../branches/main/protection`.
3. *A deliberate deviation?* None. The gate standard's "In this repository" counts this spec's
   negative tests as "ten for the scripts and one for the workflow"; the first spec's six stay as
   recorded, as the standard's own transcript rule says.
4. *A moved pointer?* Three, fixed: `scripts/check-index.sh`'s header pointed at the `index.yml`
   header PR 5 trimmed (now `base/process/standards-index.md`); `shape-spec.md`'s tips said the
   retrospective is "gate step 4" (now 6); `verification-gate.md`'s "In a consuming project" said the
   gate task is followed by the retrospective alone (now Docs, Version and the retrospective).

No project standard exists to edit. `index.yml`: the `process/verification-gate` description is
rewritten because the rule changed, in the same change set, as `standards-index.md` directs; the
`process/standards-index` description still says what that standard decides. The symlink follows.

Standards retrospective: no changes beyond the feature work above. No `(proposed, base)` list:
this is `patchbay-standards`, the two base edits are on this spec's own branch, and the owner
approves them as the pull request.

## Verification Gate

Spec is not complete until `scripts/gate.sh` passes — `bash -n` on every file under `scripts/`,
`pymarkdown` over `base/` and `README.md`, and `scripts/check-index.sh` — and the three judgment
steps are recorded here: Docs, Version and the standards retrospective above.

**Results (2026-11-05):** `scripts/gate.sh` exit 0, run as the last act before hand-over on branch
`feature/3-gate-spec-ci-workflow-docs-and-version-as-judgment-steps-and-the-gate-file-fixes-from-the-pr-5-review`,
at `origin/main` aaacc57 plus this work; `verification/gate-run.txt` holds the transcript with the
date and branch on its first line. Both scripts parse; pymarkdown 0.9.41 reports no findings over
`base/` and `README.md`; `index.yml` and the tracked files under `base/` agree on 4 standards and
`agent-os/standards/index.yml` is a symlink to `../../index.yml`. The gate was green at the end of
each of the six parts, run after each. Every gate file changed here, so the full negative-test set
was rerun after the last gate-file edit: a, b, c1, c2, d, e, f, g, h, i in
`verification/gate-negative-tests.txt`, each failing with the named reason and exit status, and j in
`verification/ci-negative-test.txt`. Test g shows the bug against `origin/main`'s script in the same
environment. Test i also records that a misspelled `line_lenght` key is not refused by
`--strict-config` but cannot pass here silently, because the default 80 then fails this tree
wrapped at 100.

**Docs (step 4):** `README.md` reads true unchanged. `CLAUDE.md` names the three runnable steps, the
three judgment steps in order, and the workflow. `scripts/gate.sh`'s header names steps 4–6 and the
workflow; `scripts/check-index.sh`'s header names the tracked-files rule and the symlink and points
at the index standard. `.github/workflows/gate.yml`'s header points at the gate standard's "CI".
`index.yml`'s header still names `check-index.sh` as holding it to the files under `base/`; the
"and to `agent-os/standards/index.yml`" clause reads true of the symlink check. `shape-spec.md`'s
gate task, Step 8 reminder, Step 9 text, `shape.md` template and tips all say steps 1–6. Every
standard that names a gate file was read against it: `verification-gate.md` and
`standards-index.md` are the shipped text; `standards-retrospective.md`'s two pointers still
resolve and its "does not pass the gate" is still true. The second spec's `shape.md`, which says
Docs and Version are "ahead of the gate files until issue #3 lands", is a record and is left as
written.

**Version (step 5):** recorded under `[Unreleased]` in `CHANGELOG.md`, Added for the workflow, the
symlink, the judgment steps, the negative tests and the two standards, Changed for
`check-index.sh` and the index description. The repository has no version number to bump.

**Standards retrospective (step 6):** above.

**Not done by the agent, by rule:** no file staged, committed or pushed; `act` not installed; the
first GitHub run of the workflow happens when the owner opens the pull request. The owner stages the
typechange of `agent-os/standards/index.yml` with the rest.
