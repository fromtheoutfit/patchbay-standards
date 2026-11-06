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

## Revision after review (2026-11-05)

The owner's review of PR 11 at `a5f88ae` listed 10 findings, posted as plausible, none verified:
three in the gate scripts (step 1's work-tree guard accepted a copy without `.git` inside another
repository; test w asserted only exit 1, which every failure of `gate.sh` now gives, so its cases
passed with the guards they named deleted; setup steps inside cases were unguarded), five where the
documents disagreed with the scripts (step 2 walked the disk against the listing rule; the fixture
clone does not carry every branch; the `gate.sh` header cited `check-index.sh`'s rule, which step 1
does not apply; the two `gate.sh` differed in a fourth way; the test count read as fifteen), and
two minor (a failing `cd` exited 1 with no `FAIL` line, and a broken symlink was reported missing;
step 1 listed twice with a redundant `-c`). A first-round transcript bug was found while reading:
`verification/gate-negative-tests.txt`'s header had an empty date and branch. The owner and the
agent went through the findings in plan mode; the dispositions are tabled in `plan.md` under
"Revision after the review of PR 11". Four were the owner's choices; the rest were accepted as the
review recommends. The decisions that extend or reverse the ones above:

- **The whole review, on this branch, in this spec folder.** Every transcript in `verification/`
  is rerun, j's included, and the diff against patchbay's `gate.sh` regenerated.
- **Every failing run names its reason** (owner's choice over asserting only `gate.sh`'s runs). A
  run that expects a status other than 0 also names a fixed string its output must hold, the
  `FAIL` or refusal line with its path where one is printed, copied from the run's recorded output;
  a run without it is `UNEXPECTED` as a wrong status is. That covers a to n, e, f, w, x, y, i, j
  and o to v's exits 1 and 2: `gate.sh`, `check-index.sh` and `sync-standards.sh` each give one
  status for several reasons, so a status alone cannot tell a guard from its absence.
- **Step 2 reads the files git lists** (owner's choice over narrowing the rule). pymarkdown is
  passed the Markdown files under `base/` and `README.md` as one `git ls-files -z --cached
  --others --exclude-standard` lists them, not `--recurse`, so an ignored draft is never linted
  here and never in CI. The rule is worded per the owner so a tool that reads `.gitignore` itself
  and is given no path git ignores meets it too: patchbay's toolchain steps need no list plumbing
  where the tool honours `.gitignore`. (The owner wrote "given no untracked path"; read as "no path
  git ignores", since an untracked file git does not ignore must be seen; confirmed with the plan.)
- **The two `gate.sh` share one skeleton, as a rule; patchbay takes this round's changes later**
  (owner's choice, reversing the first round's "read the same apart from their step lists" as a
  fact of the two files). Findings 1, 9 and 10 change step 1 here, and patchbay's step 1 at
  `0916b55` is the first round's; until patchbay syncs past this pull request and aligns in its
  own gate spec, the regenerated `verification/gate-sh-diff.txt` shows those skeleton hunks beside
  the allowed ones. An issue in patchbay records the work (Task 6). The header line finding 6
  rewrites now names the standard by the path each repository spells from its root, which the
  rule allows.
- **The fixture sentence says what the shipped fixture does** (owner's choice over prescribing a
  stronger fixture): a local clone shares the sibling's objects, so it holds the pin whenever the
  sibling does, whichever ref reaches it, and `--check` reads the pin from `.version`, never a
  branch or `origin/HEAD`. patchbay's harness is unchanged by it; its own header comment carries
  the same wrong clause and is named in the issue.
- **A failing `cd` is exit 2, named**: no step ran, and 2 is the contract's "not run as the gate".
- **Step 1 refuses a symlink to nothing by name**, before the missing-file check;
  `scripts/check-index.sh` reports one under `base/` as "tracked but missing on disk", which is
  noted and left, since nothing in this review is about that script.

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

The revision after the review of PR 11 applies the same five, `process/verification-gate` and
`process/standards-sync` as they read at `a5f88ae` (appended to `standards.md`); both are edited
again as feature work, the second only in its fixture sentence.

## Verification Gate

Spec is not complete until `scripts/gate.sh` passes — `bash -n` on every shell script under
`scripts/` as git lists them, `pymarkdown` over the `.md` files under `base/` and `README.md` as
git lists them, and `scripts/check-index.sh` — and the three judgment steps are recorded, in this
order: Docs, Version, then the standards retrospective below.

**Results (2026-11-05, after the review of PR 11):** `scripts/gate.sh` exit 0 on the tree, run as
the last act before hand-over on branch
`task/10-gate-spec-2-land-the-five-base-proposals-from-patchbays-first-specs-and-align-this-repositorys-gate`;
`verification/gate-run.txt` holds the transcript with the date and branch on its first line,
replacing the first round's. Both gate files changed again, so every negative test ran after the
last edit to either, and every transcript in `verification/` was rewritten; each header now carries
its date and branch, which the first round's had left empty.

- `verification/gate-negative-tests.txt`: every test but j, 133 runs, 0 unexpected, the harness's
  exit 0 on its last line. 54 of those runs expect a failure, and each now names the reason its
  output must hold as well as its status: one or more lines, each found in order as a fixed string
  within a line (`says`, an awk `index` over `ENVIRON`, so a backslash in a recorded line stays
  literal), copied from the first round's recorded output and reproduced. New since the first
  round: in w, a tracked `scripts/dangling.sh` is "a symlink to nothing", the copy without `.git`
  is "not a git work tree rooted at <copy w>", and the same copy inside an outer repository fails
  step 1 by name while the `a5f88ae` script passes step 1 there and is stopped only by
  `check-index.sh` at step 3 (finding 1, shown as it was); in x, `bash -c` with `$0` under a
  missing directory exits 2 with "gate: cannot enter the repository root"; y, an ignored
  `base/process/draft.md` with two findings leaves the gate green while the `a5f88ae` script lints
  it and fails step 2 (finding 4, shown as it was), the same file force-added fails step 2, and a
  tracked standard deleted from the disk fails step 2 by name before pymarkdown runs. Every setup
  step in a case now stops the harness by name.
- `verification/ci-negative-test.txt`: j, 2 runs, 0 unexpected; j2 asserts the `FAIL  step 1/3`
  line and the job's failure at step 3. The workflow is unchanged since the fourth spec. Its end
  records the hosted run on PR 11's first head: run 42145529273, `pull_request`, `a5f88ae`,
  success. The revision's head exists once the owner commits and pushes it, and its run is the
  owner's to record there.
- `verification/reason-assertion-mutations.txt`: the evidence for finding 2. Three copies of the
  tree, each with one guard of step 1 deleted (the symlink check, the missing-file check, the root
  guard), run through w and y: every affected case still exits 1, the status it expects, so the
  first round's status-only harness would have passed it; the reason assertion marks it
  `UNEXPECTED` (1, 2 and 2 runs) and the harness exits 1 each time.
- `verification/gate-sh-diff.txt`: the `diff -u` of patchbay's `scripts/gate.sh` at `origin/main`
  (`0916b55`) against this repository's, regenerated. Its header names the two kinds of hunk: the
  ones the rule allows (step lists, pins, paths, N/M) and the skeleton this revision changed, which
  patchbay takes in its own gate spec, fromtheoutfit/patchbay#5, opened in Task 6.
- Finding 5's sentence was written from a scratch experiment and patchbay's harness at `0916b55`
  (which runs only `sync-standards.sh --check` against its clone): a sibling whose pin only
  `refs/remotes/origin/main` reaches, with a feature branch checked out, cloned three ways:

  ```text
  local    refs: origin origin/feature origin/main  | origin/HEAD -> origin/feature | pin present: yes
  nolocal  refs: origin origin/feature origin/main  | origin/HEAD -> origin/feature | pin present: no
  fileurl  refs: origin origin/feature origin/main  | origin/HEAD -> origin/feature | pin present: no
  ```

  and `scripts/sync-standards.sh` reads `origin/HEAD` only in a sync (lines 155–171), never in
  `--check`, which reads `.version` (line 162).
- The gate and the harness ran under `/bin/bash` 3.2.57, the bash on `PATH` here; CI's ubuntu bash
  runs the gate on the hosted run after the push.

**Docs (step 4):** `scripts/gate.sh`'s header read against the code below it: the exit contract
with the `cd` case, the listing paragraph now citing `base/process/verification-gate.md` rather
than `check-index.sh` (finding 6), step 1's root guard, the presence checks, step 2's list, what
each step needs. `scripts/gate-negative-tests.sh`'s header read against its helpers and cases: the
reason assertion, the guarded setup, the test list with y, w's and x's new cases, the scripts from
history (g, k, l, r, w and y). `base/process/verification-gate.md` read back line by line against
the scripts: the `cd` exit 2, the listing rule (`check-index.sh` reads the two sets apart and by
line with `core.quotePath=false`, which the rule's wording allows; `gate.sh` reads both in one `-z`
call), the reason assertion, step 1's guard, step 2's list and test y, "eighteen for the gate's
scripts (a to n but j, with c as c1 to c3, and w, x and y)" counted against the default test list,
the skeleton's members against `gate.sh` (patchbay's has the `cd` and usage checks, `step`, `fail`,
step 1 and the closing line, and lacks `listed`, `present` and the root guard until patchbay#5).
`base/process/standards-sync.md`'s fixture sentence against the experiment above.
`CLAUDE.md`'s Specs section and `.claude/commands/agent-os/shape-spec.md` (the gate task's steps 1
and 2, its "runs steps 1–3" sentence, the template's Verification Gate paragraph) say steps 1 and 2
as the script runs them and the exit contract with the `cd` case. `index.yml`: the
`process/verification-gate` description rewritten because its rule changed (2 when not run as the
gate, the files git lists at the root, the reason asserted, the shared skeleton); it holds no `: `
and no ` #`, and step 3 agrees on 5 standards; `process/standards-sync`'s description does not
name the fixture and reads true. `README.md` names no gate step and reads true unchanged;
`.github/workflows/gate.yml` is unchanged and its header true. Searched outside `agent-os/specs/`
for the old wording ("over `base/` and `README.md`", `--recurse`, "carries every branch", "read
the same apart", "seventeen"): what remains is history in `CHANGELOG.md`'s first-spec entry and
test i's direct pymarkdown call, which shows the config read on a copy whose files are all
tracked, not the gate's listing. No line in `base/`, `CLAUDE.md` or `CHANGELOG.md` exceeds 100 columns.

**Version (step 5):** recorded under `[Unreleased]` in `CHANGELOG.md`: the sixth spec's Added
entry revised to the shipped state, with one sentence naming the PR 11 review and patchbay#5, and
its Changed entries for `scripts/gate.sh`, `scripts/gate-negative-tests.sh`, the two documents and
`index.yml` revised the same way. The repository has no version number to bump.

**Outward, done by the agent with the owner's approval in the plan:** fromtheoutfit/patchbay#5,
"Gate spec 2: take patchbay-standards PR 11's gate skeleton and harness changes", with no AI
attribution.

**Not done by the agent, by rule:** no file staged, committed or pushed, no pull request edited;
the owner reads the diff at commit time.

## Standards Retrospective

Step 6, always last. Per `base/process/standards-retrospective.md`. Applied 2026-11-05 at the first
hand-over and again after the review of PR 11, from the revised diff against `main`
(`.claude/commands/agent-os/shape-spec.md`, `CHANGELOG.md`, `CLAUDE.md`,
`base/process/standards-sync.md`, `base/process/verification-gate.md`, `index.yml`,
`scripts/gate-negative-tests.sh`, `scripts/gate.sh`, and this spec folder). The edits to the two
base files are this spec's feature work, written from the shipped scripts, patchbay's files and the
clone experiment, not retrospective edits; the questions are asked of everything the diff touched.

1. *A pattern no standard covers?* The first round's five proposals and the diff record are rules,
   as feature work. This revision wrote two more into `verification-gate.md` as feature work,
   because the review's findings were against that file: a failing run asserts its reason, and the
   two repositories' `scripts/gate.sh` share a named skeleton that a consuming project takes after
   its sync. It taught two more that no standard holds, proposed below rather than edited, since
   base files are not edited from a retrospective: the mutation check that proves an assertion
   discriminates (`verification/reason-assertion-mutations.txt`), and the issue opened in a
   consuming project when a base change leaves its gate files out of step with a rule
   (fromtheoutfit/patchbay#5). The `says` matcher, the `shown` helper and test y's shape are
   details of the harness rule.
2. *A standard wrong or stale?* Six sentences, each corrected as feature work from the files:
   the listing rule (a step that walked the disk here; a guard that accepted a nested copy; one
   call; the symlink case; a tool that honours `.gitignore`), the exit contract's missing `cd`
   case, the harness rule's status-only assertion, "seventeen … except j, w and x" (eighteen), the
   two `gate.sh` "read the same" (now the skeleton rule), and `standards-sync.md`'s "carries every
   branch". Found while reading, not changed: `scripts/check-index.sh` reports a tracked symlink to
   nothing under `base/` as "tracked but missing on disk", and `scripts/sync-standards.sh` passes
   `-c core.quotePath=false` beside `-z` (lines 267–268), harmless and not false against the rule's
   wording; neither script is in this review's scope, and each is a gate file that changes only in
   its own spec. The fifth spec's open proposal (what a spec records when a new base file is not
   yet staged) is still open and still not this spec's.
3. *A deliberate deviation?* One, temporary and recorded: until patchbay syncs past this pull
   request and closes patchbay#5, its `scripts/gate.sh` lacks the skeleton this revision changed,
   and `verification/gate-sh-diff.txt` shows exactly those hunks beyond the allowed ones. The
   rule says the project takes the change in its own gate spec after the sync, so this is the
   rule's own sequence, not a departure from it.
4. *A moved pointer?* One, updated: `scripts/gate.sh`'s header cites the standard for the listing
   rule instead of `scripts/check-index.sh`. "The spec that last changed the harness holds the
   current transcripts" still names issue #10, and this spec's `verification/` holds them. No file
   was renamed.

No project standard exists to edit. `index.yml`: the `process/verification-gate` description
rewritten because its rule changed, in the same change set, as `standards-index.md` directs; the
symlink follows. No retrospective edit beyond the feature work above.

### Standards retrospective (proposed, base)

Proposals, never local edits; each becomes a pull request to `patchbay-standards`, or is folded
into this pull request as feature work if the owner says so, approved by a person.

- `base/process/verification-gate.md`, "Every step that can fail is proven to fail": a change to
  the harness's assertions is shown to discriminate as a step is, by a copy of the tree with the
  guard under test deleted, run through the cases that cover it, which must come back `UNEXPECTED`
  with the harness exiting 1; the transcript is kept in the spec's `verification/`. Verified by
  `verification/reason-assertion-mutations.txt`: three deletions, each case still exit 1, each
  caught only by the reason.
- `base/process/standards-sync.md`, "Pinned, not tracking": a base change that leaves a consuming
  project's gate files out of step with a rule names the project and the work in its `CHANGELOG.md`
  entry, and an issue in that project records the work for the gate spec that follows its sync.
  Verified by this spec's `CHANGELOG.md` entry and fromtheoutfit/patchbay#5.
