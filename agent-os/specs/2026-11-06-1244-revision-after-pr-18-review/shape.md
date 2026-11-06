# The Revision after the Review of PR 18 — Shaping Notes

Shaped 2026-11-06 in plan mode with `/agent-os:shape-spec`. The owner answered the Step 1–5
questions and four design questions, recorded under Shaping answers and Decisions. Every answer
was the recommended option except one: the owner chose a new spec folder over revising the ninth's.

## Core Architecture (Non-Negotiable)

`base/python/toolchain` applies to consuming projects. This repository has no package, so it does
not apply here (Step 5a). This spec edits one sentence of it as a Docs fix (finding 12).

## Scope

The owner's review of PR 18 at `1e88c77`, the ninth spec
(`agent-os/specs/2026-11-06-1205-retro-proposals-upstream-and-probe-rule/`, issues #13 and #15),
lists 12 findings in one comment. This spec answers all 12, plus a thirteenth instance of
finding 12 found at shaping: `standards-sync.md:59`, "changed in `patchbay-standards` by a pull
request there".

- **Findings 1–4 and 8–12:** base-standard and gate-task text.
- **Finding 5:** an evidence file in the ninth's folder.
- **Finding 6:** the harness's missing exclusive assertion, fixed here.
- **Finding 7:** analysed, and sent to #17.

There is a `CHANGELOG.md` entry, the gate is green, and `verification/gate-run.txt` has the date
and branch. No stage, commit, push or PR by an agent.

## Shaping answers

- **Step 1, scope:** all 12 and `standards-sync.md:59`, in a new spec folder (the owner's choice
  over revising the ninth's).
- **Step 2, visuals:** none.
- **Step 3, references:** the review, the PR 16 revision, the question tool's limits, the
  harness's assertions and test k, the saved first run. See `references.md`.
- **Step 4, product context:** no `agent-os/product/`, so skipped.
- **Step 5, standards:** the same five `base/process/*`, snapshotted at `1e88c77` in this
  folder's `standards.md`. The ninth's snapshot is left as it was.
- **Findings 6 and 7:** fix 6 here; 7's analysis and both standard texts go to #17.
- **Finding 4:** whoever writes the PR body links the issue and checks its paths, applied now to
  #17 and PR 18.
- **Findings 1 and 10:** one clause in "What the sync writes, and nothing else"; the paragraph is
  removed.
- **Finding 5:** corrected in the ninth's folder.

## Decisions

- **This spec answers the review of PR 18, in a folder of its own** (owner). The ninth spec's
  folder stays its record, corrected only where finding 5 needs it. The branch is the ninth's, so
  the owner's commit lands on PR 18.
- **Every finding was re-checked against `1e88c77` before it was answered**, since the review says
  its findings were not. All 12 hold. Two needed corrections:
  - **Finding 7 is narrower than stated.** Only g wrote its own `index.yml` while keeping the rest
    of the copied `base/`. a, b, d, h, k and l add to a copy whose `base/` and `index.yml` agree.
    a, n and y depend on `base/process/ownership.md` existing, and fail at setup by name (exit 2)
    if it moves. i's MD013 cases depend on the tree holding lines longer than 60 and 80 columns,
    and would come back `UNEXPECTED`, not pass, if it did not.
  - **Finding 6 also covers k.** Its two "must fail naming process/zeta alone" cases are checked
    by `says()` alone, like g's second case. r's "alone" cases are byte comparisons (`cmp`),
    exclusive already.
- **Finding 1's reason, corrected.** The gate task is a gate file, so a step a base standard asks
  of it is made in the project's gate spec: that part held. "So the sync's change set does not
  carry it" did not, since the sync replaces `scripts/sync-standards.sh`, a gate file. The sync
  leaves `.claude/commands/` alone because it writes only its four things.
- **Finding 11: a gate spec when any approved proposal needs a gate file changed.** The issue says
  which proposals do, and its standards proposals ride with it, as #10 carried a `standards-sync.md`
  proposal and #12 a `standards-retrospective.md` one. #17 already says so of its proposals 4 and
  5.
- **The ninth's presentation stands.** It put four proposals in one question, "none" only through
  the free-text answer, before the rule said how to split. The owner answered all six, and they
  are not presented again.
- **PR 18's body is not edited here.** The rule for finding 4 has the body's writer check paths at
  the PR's head, which waits for the owner's push. #17 is updated now because PR 18 exists and
  `1e88c77` is pushed.

## Context

- **Visuals:** None.
- **References:** `references.md`.
- **Product alignment:** N/A (no `agent-os/product/`).

## Standards Applied

**Core (Step 5a, consuming projects):**

- `base/python/toolchain` — not applied here: no package (Step 5a); line 94 edited as a Docs fix

**Feature-specific:**

- `process/standards-retrospective` — edited as feature work (findings 2, 4, 8, 9, 11).
- `process/standards-sync` — edited as feature work (findings 1, 10 and line 59).
- `process/verification-gate` — the gate task and the harness are gate files, so this is a gate
  spec and the negative tests are rerun; its harness pointer names this spec.
- `process/ownership` — #17's edit and comment with no attribution; no stage, commit, push or PR.
- `process/standards-index` — descriptions read against the changed rules.

## Verification Gate

Spec is not complete until `scripts/gate.sh` passes — `bash -n` on every shell script under
`scripts/` as git lists them, `pymarkdown`, installed at its pin through `uvx` as its own check,
over the `.md` files under `base/` and `README.md` as git lists them, and
`scripts/check-index.sh` — and the three judgment steps are recorded, in this order: Docs,
Version, then the standards retrospective below.

**Results (2026-11-06):** `scripts/gate.sh` exit 0 on the tree, run as the last act before
hand-over on branch
`feature/13-retrospective-present-base-proposals-to-the-owner-and-file-the-approved-ones-as-an-issue-before-the-spec-completes`;
`verification/gate-run.txt` holds the transcript, with the date and branch on its first line.

- Two gate files changed: the gate task text in `shape-spec.md` (step 6) and the harness (`only`).
- `scripts/gate-negative-tests.sh` (every test but j) was rerun after the last of them:
  `139 runs, 0 unexpected`, harness exit 0, in `verification/gate-negative-tests.txt`. g's second
  case and k's two "alone" cases each print an `only=` line.
- The first rerun after those edits ended `139 runs, 5 unexpected` (j: 1). Every clean-copy run of
  the gate failed step 2 on MD013 at `base/python/toolchain.md:97`, 133 columns, a line my reflow
  of finding 12's edit had joined. The line was rewrapped and the suite rerun. That run's output
  was not kept; the transcript's header says so.
- j is `2 runs, 0 unexpected`, in `verification/ci-negative-test.txt`, which also records the
  hosted run of `1e88c77`, 42263204683, `success`. The ninth's `ci-negative-test.txt` left that
  run for the owner to record; it is recorded here.
- `verification/only-assertion-mutations.txt`, three mutations on scratch copies:
  - M1, g's old fixture with `only`: `UNEXPECTED (listed: process/B python/toolchain)`, 2
    unexpected;
  - M2, the same without `only`: case 2 passes, 1 unexpected, the ninth's first run;
  - M3, k with `process/eta` beside zeta: `UNEXPECTED (listed: process/eta process/zeta)`, while
    `says()` passes.

**Docs (step 4):** every changed sentence was read back against what it describes.

- **`standards-retrospective.md`:**
  - The split rule rests on AskUserQuestion's limits, 2–4 options a question and 1–4 questions a
    call. Its schema is the tool's own definition, and this session ran both limits: four options
    in one question in the ninth's presentation, four questions in one call at this spec's
    shaping. That is the probe rule of #15 applied to the tool the rule names.
  - The title rule matches #10 (gate spec 2, carrying a `standards-sync.md` proposal) and #12
    (gate spec 3, carrying a `standards-retrospective.md` one), and #17 says which of its
    proposals touch gate files.
  - The PR-link rule was applied to #17. Its "Depends on" names PR #18, and every repository path
    it cites exists at `1e88c77` and on the tree. The two moved pointers (proposals 4 and 5, to
    `gate-negative-tests-first-run.txt`, which lands with the owner's push) and proposal 6's
    section name are corrected.
  - The four forms and the named declined example read together with the template's four lines.
- **`standards-sync.md`:**
  - The new paragraph sits after the four writes, in the section that lists them. Its reason is
    the one finding 1 gives, and the gate-file part names `verification-gate.md`'s rule.
  - The closing paragraph of "In a consuming project" is gone.
  - Lines 57–62 point at the retrospective's route and its section by name.
- **`toolchain.md`, the floor bullet:** the route matches the retrospective's.
- **`shape-spec.md`:** gate step 6 and the template's four lines read together with the standard.
  `CLAUDE.md`'s retrospective bullet says the line is recorded either way.
- **`verification-gate.md`:** the harness pointer names this spec, whose `verification/` holds the
  current transcripts, j's included.
- **The harness header** describes `only` as the code does: an assertion on the last run, not
  another run, reading the eight-space entry lines of `run.out`.
- **`index.yml`:** `process/standards-retrospective` gains the pull-request link and the declined
  proposal named. `process/standards-sync` still reads true: the sync writes nothing under
  `.claude/commands`, and the step is the project's gate spec. PyYAML reads the file, with no `: `
  and no ` #`.
- **`CHANGELOG.md`:** the ninth's `standards-sync.md` bullet now names where the paragraph is.
- **Searches:** no "by a pull request", "a pull request to `patchbay-standards`" or "becomes a
  pull" route remains in `base/`, `CLAUDE.md`, `.claude/` or `README.md`. Every
  `Proposals sent upstream` mention agrees with the four forms.
- **Line widths:** no changed line exceeds 100 columns. `toolchain.md` 188 and 206 and the
  harness's long lines predate this spec.
- **The ninth's records:** its `shape.md` pointers to the first run are corrected. Its Docs line
  that read `toolchain.md:94` as true stays as written, a record of what it read; finding 12
  corrected it here.

**Version (step 5):** recorded under `[Unreleased]` in `CHANGELOG.md`.

- Added: the tenth spec, with its two standards changes and the follow-ups (#17's body and
  comment, #19, the #7 comment's section name).
- Changed: `shape-spec.md`, `CLAUDE.md`, the harness, `verification-gate.md`, `toolchain.md`,
  `index.yml`, and the ninth's transcript split.
- The ninth's `standards-sync.md` bullet is corrected in place. There is no version number to bump.

**Not done by the agent, by rule:** no file staged, committed or pushed, and no pull request
opened or edited. On GitHub, with no attribution:

- #17's body edited twice (Depends on, the moved pointers, proposal 6's section) and commented on;
- #19 opened, its proposal approved by the owner;
- the section name in the comment on fromtheoutfit/patchbay#7, at the owner's choice.

PR 18's body is for whoever writes it after the owner pushes, under the new rule.

## Standards Retrospective

Step 6, always last, from the shipped diff against `1e88c77`:

- `.claude/commands/agent-os/shape-spec.md`, `CHANGELOG.md`, `CLAUDE.md`;
- `base/process/standards-retrospective.md`, `base/process/standards-sync.md`,
  `base/process/verification-gate.md`, `base/python/toolchain.md`;
- `index.yml`, `scripts/gate-negative-tests.sh`;
- the ninth spec's `verification/` and `shape.md`, and this spec folder.

Every edit to those is this spec's feature work, the answer to a finding. The questions are asked
of all of it.

1. *A pattern no standard covers?* One.
   - A kept negative-test transcript holds one run and ends on its count, and an earlier run kept
     as evidence goes in its own file. The ninth broke it without a rule to break (finding 5), and
     this spec split its file. Proposed below.
   - The `only` assertion is the harness half of #17's proposal 5, whose standard text is already
     upstream. It is not proposed again.
2. *A standard wrong or stale?* The review's twelve, fixed as feature work.
   - One more of finding 12's kind, `standards-sync.md:59`, fixed with it.
   - Considered and not proposed: the ninth's Docs search missed two old routes because it
     searched one phrasing. The Docs rule already says every standard that names the change is
     read; the miss was in following it, not in the rule.
3. *A deliberate deviation?*
   - **Deviation, not a standard change:** the ninth's six proposals were presented four in one
     question, "none" only through the free-text answer, before the split rule existed. The owner
     answered all six, and they are not presented again.
   - **Deviation, not a standard change:** the failing first rerun of this spec's negative tests
     was not kept. The rule proposed below asks only that a kept earlier run sit in its own file.
4. *A moved pointer?* The `.claude/commands/` paragraph moved within `standards-sync.md`. The
   pointers that named its old section were corrected:
   - the ninth's CHANGELOG bullet;
   - #17's proposal 6;
   - the comment on fromtheoutfit/patchbay#7, at the owner's choice.

   The ninth's first-run pointers followed the split. The harness pointer in
   `verification-gate.md` names this spec.

No project standard exists to edit. `index.yml` was updated with the feature work in the same
change set. The retrospective's own change set is this section and #19; it edited no file outside
this spec folder.

Proposals sent upstream: fromtheoutfit/patchbay-standards#19.

### Standards retrospective (proposed, base)

Presented to the owner on 2026-11-06 by the corrected rule: one question, the proposal and a
"None of these" option. Approved, and filed as fromtheoutfit/patchbay-standards#19, a standards
spec, since it needs no gate file changed.

- `base/process/verification-gate.md` — "Every step that can fail is proven to fail": each kept
  negative-test transcript holds one run of the harness and ends on that run's count, and an
  earlier run kept as evidence goes in a file of its own. Verified against the ninth spec's
  `verification/gate-negative-tests.txt` (ends `harness exit=0`) and
  `verification/gate-negative-tests-first-run.txt` (ends `harness exit=1`), as split here, and
  the header of `scripts/gate-negative-tests.sh`. Proposed, not applied; filed as
  fromtheoutfit/patchbay-standards#19.
