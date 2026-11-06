# Base Proposals Upstream and the Probe Rule (issues #13 and #15) — Shaping Notes

Shaped 2026-11-06 in plan mode with `/agent-os:shape-spec`. The owner answered the Step 1–5
questions and four design questions, recorded below under Shaping answers and Decisions. Every
answer was the recommended option except two: the four earlier unfiled proposals, which the owner
chose to present now rather than leave forward-only, and the patchbay follow-up, where the owner
chose a comment on fromtheoutfit/patchbay#7 over a new issue.

## Core Architecture (Non-Negotiable)

`base/python/toolchain` applies to consuming projects. This repository has no package, so it does
not apply here (Step 5a).

## Scope

GitHub issues #13 ("Retrospective: present base proposals to the owner and file the approved ones
as an issue before the spec completes") and #15 ("Standards spec: a rule resting on how a tool
behaves is verified by running it, not by its documentation"), in one spec.

- **#13**:
  - `base/process/standards-retrospective.md` gains the present-and-file step. Proposals are
    shown to the owner with AskUserQuestion, and the approved ones are filed as one issue on
    `patchbay-standards` before the spec reports done. A declined one is marked in `shape.md`,
    and the issue number goes beside each proposal.
  - This repository's `shape-spec.md` gains the step in its gate task and the
    `Proposals sent upstream:` line in its `shape.md` template.
  - `base/process/standards-sync.md` "In a consuming project" says where a project makes the
    same change.
- **#15**: "Verify against the code, not against the spec" gains the probe rule, as corrected in
  the issue's body. A probe's cases tell the competing claims apart, its setup is shown to have
  done what it claims, and the tool's source at the pinned version decides a probe-versus-docs
  disagreement.
- **Docs fixes** (owner's scope): the sentences that would read false afterwards, in `CLAUDE.md`,
  `shape-spec.md` Step 5 and Step 9 and the template's `(proposed, base)` paragraph. Also the
  `index.yml` description.
- **Verification**: #15's rule is verified against the toolchain spec's
  `verification/patchbay-evidence.txt` on `main`. #13's is verified by running it: this spec's
  own retrospective is the first to follow the new step. A `CHANGELOG.md` entry, gate green,
  `verification/gate-run.txt` with date and branch, and no stage, commit, push or PR by an agent.

## Shaping answers

- **Step 1, scope:** the issues' files plus the Docs fixes above.
- **Step 2, visuals:** none.
- **Step 3, references:**
  - #12 and #15 as the shape of a filed issue. #10 is not used as a template, because its body
    ends with an AI-attribution footer.
  - The toolchain evidence, sections 4–5 on `main` and its first round at `f3fdbf4`.
  - The third spec's evidence section 6.
  - The toolchain `shape.md`'s proposals block.

  See `references.md`.
- **Step 4, product context:** `agent-os/product/` does not exist here, so this step was skipped.
- **Step 5, standards:** the five `base/process/*` standards, feature-specific, in `standards.md`.
- **Gate file:** a gate spec too, with the negative tests rerun.
- **Sync note:** the project's own gate spec, after the sync.
- **Earlier unfiled proposals:** presented now (the owner's choice over forward-only).
- **patchbay follow-up:** a comment on fromtheoutfit/patchbay#7 (the owner's choice over a new
  issue), with #7 in the CHANGELOG entry.

## Decisions

- **Issues #13 and #15 share one spec because both edit `base/process/standards-retrospective.md`**,
  in different sections: #13 adds a section after "Who owns which standard" and changes
  "Recording the answer"; #15 extends "Verify against the code, not against the spec". The
  retrospective standard changes only in its own spec ("Never edit this file from inside a
  retrospective"). Two specs would mean two branches editing one file and two reviews of one
  standard. One spec lands both, on this branch, whose name covers #13 only.
- **This spec is a gate spec as well** (owner). `verification-gate.md` lists "the gate task text
  in `shape-spec.md`" among the gate's own files, and #13 adds a step to it.
  - The step is judgment, which no machine runs, so there is no negative test for it.
  - The standard says the negative tests are rerun whenever the gate's files change, so
    `scripts/gate-negative-tests.sh` and the CI replay j are rerun after the last edit to the
    gate task, with transcripts in `verification/`.
  - No script, pin, rule set or workflow changes.
- **The consuming-project note points at the project's own gate spec, after the sync** (owner).
  #13 says projects make the change "in their next sync's change set". That contradicts two
  rules: `standards-sync.md` "Pinned, not tracking" (the sync commit changes nothing but `base/`,
  `.version`, the `base:` section and the script), and the gate-file rule (the gate task changes
  only in the gate's own spec). The note says the sync writes nothing under `.claude/commands/`,
  and that a base change asking for a step in the gate task is made in the project's gate spec
  after the sync. patchbay#5, #6 and #7 took base changes the same way.
- **The filed issue's "Depends on" line names the repository and branch that hold the evidence,
  and the pull request once the owner opens it.** The issue is filed before the spec reports
  done, and an agent never opens a pull request, so at filing time there is none to name. #15 did
  the same.
- **The issue's shape is described in words in the standard, with
  `fromtheoutfit/patchbay-standards#12` cited as the example.** The shape: a title naming it a
  gate spec or a standards spec, one section per proposal with its verification pointer,
  "Depends on", and the Rules line. The reference is written in full because the file is synced
  into projects where a bare `#12` is their own issue.
- **#15's case is written without tool names or spec paths**, like the sibling-project paragraph
  beside it. The file is synced into projects where this repository's spec folders do not exist;
  the evidence is named in this spec's `shape.md` and in #15.
- **The four earlier proposals' outcomes are recorded here**, and the specs that recorded them
  keep their `shape.md` as written, records of what they knew then (the fourth spec left the
  second spec's record the same way). The new rule binds a spec from this one on; the four are
  presented now because the owner chose to.

## Found during implementation

- **Test g of the harness was stale on `main`, and is fixed here** (owner, asked when the rerun
  found it).
  - The first rerun after the gate-task edit ended `139 runs, 1 unexpected`.
  - g removed only `base/process/*.md` from its copy and wrote an index of three `process/`
    entries. Since issue #4 added `base/python/toolchain.md`, the copy also held
    `python/toolchain`, and g's "all three indexed, must pass" case exited 1.
  - The toolchain spec changed no gate file and reran no negative test, so nothing saw it.
  - g now empties its copy's `base/` whole and recreates `base/process/`, a one-line change to
    `scripts/gate-negative-tests.sh` as this gate spec's feature work. The whole harness and j
    were rerun after it: `139 runs, 0 unexpected` and `2 runs, 0 unexpected`.
  - The first run's g section is kept at the end of `verification/gate-negative-tests.txt`.
- **`verification-gate.md`'s harness pointer moves to this spec.** "In this repository" said "the
  spec that last changed the harness (issue #12) holds the current transcripts, j's included".
  This spec changed the harness, so it now names issues #13 and #15. The third spec updated the
  same pointer the same way. This is a pointer this gate spec's own change made stale, so it is
  fixed as feature work, not proposed.
- **The four earlier proposals were still open against today's text**, each re-read before it was
  presented (Standards Retrospective below).

## #15's rule against the evidence on `main`

`verification/issue-15-evidence.txt` reads every line from `main` (`0b1d0dc`) or from `f3fdbf4`, an
ancestor of `main`, never from the working tree. Each part of the rule, and the line it rests on:

- **"Running the tool at its pinned version, on a scratch copy, with the transcript in
  `verification/`"**: the toolchain evidence header (scratch exports of patchbay `73a583a`, uv
  0.13.7) and every section of it.
- **"Cases chosen so they can tell the competing claims apart"**:
  - Transcript section 4: the first round at `f3fdbf4` probed three ranges, `>=0.13.7,<0.14.0`,
    `>=0.12.0,<0.13.0` and `==0.13.7`, all of them bundled builds, and read the result as
    "whatever the range says"; the standard at `f3fdbf4`, lines 53–58, said so.
  - Transcript section 3: the regenerated section 5 on `main` adds `>=0.8.0,<0.9.0` and
    `==0.13.6`, outside every accepted version. Each builds through PEP 517 with uv_build from
    the index, exit 2 for `uv build` and exit 1 for `uv sync` offline, exit 0 online.
- **"Where a probe and the documentation disagree, the tool's source at the pinned version
  decides"**: transcript section 2. The documented condition; the `0.13.7` tag at `316c827`;
  `COMPATIBLE_VERSIONS` (`0.12.24` among them) at line 40 of `metadata.rs`, the range test at
  330, the `==` test at 352. The source said the documentation was right.
- **"The setup shown to have done what it claims before its result is read"**: transcript section
  5. `--show-settings` with `lint.ignore = []` alone leaves `missing-copyright-notice` "not
  enabled", and with the selection reset it is "enabled". The reset run then reports CPY001 on
  all three files, 13 findings in all.
- **"A spec that changes such a rule reruns the probe"**: transcript section 7, the evidence file
  regenerated after the review of PR 16, its header on `main` against `f3fdbf4`'s.
- **The earlier instance**: transcript section 6, the third spec's probe of `required-version`.
  The cases tell apart the commands uv refuses (`uv lock`, `uv sync`, `uv run`, `uv version`,
  `uv pip list`, `uv cache dir`, `uv python list`, each exit 2) from those it does not
  (`uv --version`, `uv self version`, `uv tool list`, `uvx`, each exit 0).

The standard's case paragraph is that evidence without tool names. A range held a second accepted
version; the source lists it; ranges outside every accepted version, and an exact pin of another,
build from the index and fail offline. A layered override did not reset the file's list, the same
reading a review finding made, and the printed settings showed it.

## Context

- **Visuals:** None.
- **References:** `references.md`.
- **Product alignment:** N/A (no `agent-os/product/`).

## Standards Applied

**Core (Step 5a, consuming projects):**

- `base/python/toolchain` — not applied here: no package (Step 5a)

**Feature-specific:**

- `process/standards-retrospective` — edited here as feature work (#13 and #15); the closing step,
  and the first retrospective to follow the new step.
- `process/standards-sync` — edited here as feature work: the "In a consuming project" note.
- `process/verification-gate` — the gate task text in `shape-spec.md` is a gate file, so this is a
  gate spec too and the negative tests are rerun; the judgment steps and their order.
- `process/ownership` — `gh issue create` and the #7 comment are allowed with no attribution; no
  stage, commit, push or pull request by an agent.
- `process/standards-index` — the `process/standards-retrospective` description rewritten in the
  same change set, with no `: ` and no ` #`.

## Verification Gate

Spec is not complete until `scripts/gate.sh` passes — `bash -n` on every shell script under
`scripts/` as git lists them, `pymarkdown`, installed at its pin through `uvx` as its own check,
over the `.md` files under `base/` and `README.md` as git lists them, and
`scripts/check-index.sh` — and the three judgment steps are recorded, in this order: Docs,
Version, then the standards retrospective below.

**Results (2026-11-06):**
- `scripts/gate.sh` exit 0 on the tree, run as the last act before hand-over on branch
  `feature/13-retrospective-present-base-proposals-to-the-owner-and-file-the-approved-ones-as-an-issue-before-the-spec-completes`.
- `verification/gate-run.txt` holds the one transcript, with the date and the branch on its first
  line. No file was added under `base/`, so step 3 reads the tree (6 standards), and pymarkdown
  lints seven files.
- Two gate files changed: the gate task text in `shape-spec.md` (step 6) and test g of
  `scripts/gate-negative-tests.sh`.
  - So `scripts/gate-negative-tests.sh` (every test but j) was rerun after the last of them:
    `139 runs, 0 unexpected`, harness exit 0, in `verification/gate-negative-tests.txt`, which
    also keeps the first run's g section, `139 runs, 1 unexpected`.
  - The CI replay j is `2 runs, 0 unexpected`, in `verification/ci-negative-test.txt`.
  - The hosted run of this branch's pull request is the owner's to record there after the push.
- `verification/issue-15-evidence.txt` holds the lines on `main` the probe rule rests on.

**Docs (step 4):** every changed sentence was read back against what it describes.

- `base/process/standards-retrospective.md`:
  - The probe rule against the evidence, mapped above.
  - "Base proposals go to the owner, then upstream" against this spec's own run of it: the six
    proposals presented with AskUserQuestion, both questions multi-select, each proposal with its
    file and test; #17 created with `gh issue create --repo fromtheoutfit/patchbay-standards`,
    titled a gate spec, one numbered section per proposal with its verification pointer, a
    "Depends on" naming this branch and its pull request to come, the Rules line, and no
    attribution; the number written beside each proposal below.
  - The shape it cites, `fromtheoutfit/patchbay-standards#12`, ends with its Rules section.
  - The "Who owns which standard" route and the approval sentence agree with the new section.
  - Both "Recording the answer" shapes carry the `Proposals sent upstream:` line, and this
    `shape.md` uses the second shape.
- `base/process/standards-sync.md`, the note: the sync's four writes in "What the sync writes, and
  nothing else" include nothing under `.claude/commands/`; the gate files in `verification-gate.md`
  include "the gate task text in `shape-spec.md`"; and patchbay#5, #6 and #7 each took a base
  change in a gate spec after the sync.
- `base/process/verification-gate.md`: the harness pointer names this spec, whose
  `verification/` holds the current transcripts, j's included.
- `.claude/commands/agent-os/shape-spec.md`: gate step 6, the template's `Proposals sent upstream:`
  line and its `(proposed, base)` paragraph and entry, Step 5 and Step 9 say the same route as the
  standard. The rest of the gate task, Step 8 and the tips read true unchanged.
- `CLAUDE.md`'s Specs section says the same route; its "The retrospective is the gate's last step"
  bullet still points at the standard for the full rules.
- `index.yml`:
  - `process/standards-retrospective` is rewritten for both rules, and `process/standards-sync`
    gains the `.claude/commands` decision.
  - PyYAML reads the file, no description holds `: ` or ` #`, and `check-index.sh` agrees on the
    tree.
- `CHANGELOG.md`: the Added and Changed entries against the diff, and the follow-ups against #17
  and the #7 comment.
- Read true unchanged:
  - `README.md`;
  - `scripts/gate.sh`'s header and closing line, which name steps 4–6 and point at the standard;
  - the harness header, which still describes g;
  - `.github/workflows/gate.yml`;
  - `verification-gate.md`'s retrospective bullet in "The fixed order" (a pointer to the standard)
    and its "recorded in that spec's retrospective as a proposal and waits for the gate's spec";
  - `standards-sync.md`'s "changed in `patchbay-standards` by a pull request there", where the
    pull request is still how a change lands;
  - `toolchain.md`'s "a change to this standard first, a pull request to `patchbay-standards`".
- No "becomes a pull request" remains in the files git lists outside `agent-os/specs/` and
  `CHANGELOG.md`.
- No line of the changed files exceeds 100 characters but pre-existing ones: in `shape-spec.md`
  (79, 82 and the tips) and throughout `scripts/gate-negative-tests.sh`. The harness line changed
  here (test g) is within 100.

**Version (step 5):** recorded under `[Unreleased]` in `CHANGELOG.md`.
- Added: the ninth spec, with its two standards changes and the follow-ups (#17, and the comment
  on fromtheoutfit/patchbay#7).
- Changed: `shape-spec.md`, `CLAUDE.md`, `scripts/gate-negative-tests.sh` (test g),
  `verification-gate.md` (the harness pointer) and `index.yml`.
- The repository has no version number to bump.

**Not done by the agent, by rule:** no file staged, committed or pushed, and no pull request
opened. On GitHub, with no attribution: #17 opened, its six proposals approved by the owner in
this spec's retrospective; a comment on fromtheoutfit/patchbay#7, as the owner chose at shaping.
Noted for the owner and not acted on: the bodies of #10 and #13 end with an AI-attribution footer.

## Standards Retrospective

Step 6, always last. Per `base/process/standards-retrospective.md`, and the first retrospective to
follow its new step. Applied 2026-11-06 from the shipped diff against `main` (`0b1d0dc`):

- `.claude/commands/agent-os/shape-spec.md`, `CHANGELOG.md`, `CLAUDE.md`;
- `base/process/standards-retrospective.md`, `base/process/standards-sync.md`,
  `base/process/verification-gate.md`;
- `index.yml`, `scripts/gate-negative-tests.sh`, and this spec folder.

The two standards changes, the gate task, the test g fix and the harness pointer are this spec's
feature work, not retrospective edits. The questions are asked of everything the diff touched.

1. *A pattern no standard covers?* Two, both from test g.
   - A negative test's case depended on what the copied tree's `base/` held, and went stale when
     a later spec added a file there. That spec reran nothing, since it changed no gate file.
   - The harness checks a failure's named lines in order but not that nothing else is reported,
     so a case whose reason says "alone" passed with a second offending line. Both are proposed
     below.
   - The present-and-file step itself is this spec's feature, written as a rule before it was
     used.
2. *A standard wrong or stale?* The harness pointer in `verification-gate.md`, made stale by this
   spec's own change to the harness, is fixed as feature work.
   - `verification-gate.md`'s "rerun whenever the gate's files change" was followed by the
     toolchain spec and did not catch g. That is the first proposal from question 1, not a
     separate one.
   - The four earlier proposals, re-read against today's `verification-gate.md` and
     `standards-sync.md`, are all still open (below).
   - #13's "in their next sync's change set" was the issue's wording, not a standard's. It is
     settled in Decisions.
3. *A deliberate deviation?*
   - **Deviation, not a standard change:** the outcomes of the four earlier proposals are
     recorded here, not beside them in their own specs' `shape.md`, which stay as written. The
     rule binds the spec that records a proposal, and these four predate it. Presenting them here
     was the owner's choice, made once.
4. *A moved pointer?* The harness pointer, above. `standards-sync.md` names the new section by its
   heading, "Base proposals go to the owner, then upstream", and the gate task names it the same
   way. No file was renamed or removed.

No project standard exists to edit. `index.yml` was rewritten with the feature work in the same
change set, as `standards-index.md` directs; the symlink follows. The retrospective's own change
set is this section and the issue it filed. It edited no file outside this spec folder.

Proposals sent upstream: fromtheoutfit/patchbay-standards#17.

### Standards retrospective (proposed, base)

Proposals, never local edits. The owner was presented all six on 2026-11-06, with AskUserQuestion
in two multi-select questions (the earlier four, then this spec's two), and approved all six. They
were filed together as fromtheoutfit/patchbay-standards#17, a gate spec.

This spec's own:

- `base/process/verification-gate.md` — "Every step that can fail is proven to fail": a case whose
  expectation depends on what a copied directory holds sets the whole of that directory. Test g
  removed only `base/process/*.md` and went stale when issue #4 added `base/python/`. Verified
  against `scripts/gate-negative-tests.sh` test g as fixed here, and
  `verification/gate-negative-tests.txt`: the first run's g section, `exit=1  UNEXPECTED
  (expected 0)` and `139 runs, 1 unexpected`, then `139 runs, 0 unexpected` after the fix.
  Proposed, not applied; filed as fromtheoutfit/patchbay-standards#17 (proposal 4).
- `base/process/verification-gate.md` — the harness bullet: a case whose reason is the whole of
  what a step must report asserts that nothing else is reported. `says()` checks the named lines in
  order and nothing more, so the stale g's "must name process/B alone" passed with
  `python/toolchain` beside `process/B`. Verified against the first run's g section, second case
  (exit 1, not `UNEXPECTED`), and `says()` as shipped. Proposed, not applied; filed as
  fromtheoutfit/patchbay-standards#17 (proposal 5).

Recorded by earlier specs, never filed, and presented here:

- `base/process/verification-gate.md` — "Every spec keeps its green run": what a spec that adds a
  file under `base/` records before the owner stages it, which is the tree's run, failing step 3
  by name, beside a green run on a git-added scratch copy. Recorded by
  `agent-os/specs/2026-11-05-1441-sync-script-and-standards-sync/`. Verified against the
  toolchain spec's `verification/gate-run.txt` at `f3fdbf4` (exit 1, then exit 0). Filed as
  fromtheoutfit/patchbay-standards#17 (proposal 1).
- `base/process/verification-gate.md` — "Every step that can fail is proven to fail": a change to
  the harness's assertions is shown to discriminate by a copy with the guard under test deleted,
  whose cases must come back `UNEXPECTED`, harness exit 1. Recorded by
  `agent-os/specs/2026-11-05-2019-gate-spec-2-five-base-proposals/`. Verified against its
  `verification/reason-assertion-mutations.txt` (9 `UNEXPECTED`). Filed as
  fromtheoutfit/patchbay-standards#17 (proposal 2).
- `base/process/verification-gate.md` — "A key the tool does not know is not refused" holds of
  pymarkdown and not of pytest under `--strict-config` (exit 4). Recorded by
  `agent-os/specs/2026-11-06-1040-python-toolchain-standard/`. Verified against its
  `verification/patchbay-evidence.txt` section 9. Filed as fromtheoutfit/patchbay-standards#17
  (proposal 3).
- `base/process/standards-sync.md` — "Pinned, not tracking": a base change that leaves a consuming
  project's gate files out of step names the project and the work in its `CHANGELOG.md` entry,
  and an issue in that project records the work for the gate spec after its sync. Recorded by
  `agent-os/specs/2026-11-05-2019-gate-spec-2-five-base-proposals/`. Verified against that spec's
  `CHANGELOG.md` entry and fromtheoutfit/patchbay#5, #6 and #7. Filed as
  fromtheoutfit/patchbay-standards#17 (proposal 6).
