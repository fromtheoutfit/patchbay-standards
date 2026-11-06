# Plan: issues #13 and #15 — present-and-file base proposals, and the probe rule

## Context

Two open issues each edit `base/process/standards-retrospective.md`, in different sections, so one
spec carries both:

- **#13**: today a consuming project's retrospective records base proposals in `shape.md`, and
  someone copies them into an issue here by hand later. Four proposals recorded here since the
  fifth spec have no issue at all, which is exactly that gap. #13 moves the hand-off into the
  gate's last step. Proposals are presented to the owner (AskUserQuestion, multi-select). The
  approved ones are filed as one issue on `patchbay-standards`, a declined one is marked in
  `shape.md`, and the issue number goes beside each proposal.
- **#15**: the toolchain spec (issue #4) showed that a rule resting on a tool's behaviour can be
  "verified" by a probe that cannot tell the claims apart (the `>=0.12.0,<0.13.0` range held
  `0.12.24`), or by a probe whose setup did not do what it claimed (the `lint.ignore`-only
  override). Its documentation-vs-probe disagreement was settled by uv's source at `0.13.7`. The
  rule goes under "Verify against the code, not against the spec".

Spec folder: `agent-os/specs/2026-11-06-1205-retro-proposals-upstream-and-probe-rule/`, on the
current branch `feature/13-…` (the name covers #13 only; shape.md says it carries #15 too).

## Shaping answers (owner, 2026-11-06)

- Scope: the issues' files plus the sentences the Docs step would otherwise find false (CLAUDE.md,
  shape-spec.md Step 5 and Step 9, the template's (proposed, base) paragraph).
- Visuals: none. References: #12 and #15 as the shape of a filed issue (#10 is not used: its body
  ends with an AI-attribution footer); the toolchain evidence sections 4–5 on `main`, its first
  round at `f3fdbf4`, the third spec's evidence section 6; the toolchain shape.md proposals block.
- Product context: no `agent-os/product/`; skipped. Standards: all five `base/process/*`.
  `base/python/toolchain` is recorded as not applying (no package).
- **Gate spec too.** The gate task text in `shape-spec.md` is a gate file
  (`verification-gate.md`, "The gate's own files change only in their own spec"). The new
  sub-step is judgment, so there is no new negative test. `scripts/gate-negative-tests.sh` is
  rerun after the last gate-file edit.
- **Sync note: the project's own gate spec, after the sync.** This replaces #13's "in their next
  sync's change set", which contradicts standards-sync "Pinned, not tracking" and the gate-file
  rule. It matches patchbay#5/#6/#7.
- **The four earlier unfiled proposals are presented now** with this spec's own. Each is re-read
  against today's text first, and the approved ones go in the same issue.
- **patchbay follow-up: a comment on fromtheoutfit/patchbay#7** (no attribution) adding the
  present-and-file step to its list. #7 goes in the CHANGELOG entry.

Decided in the plan (adjust at approval if wrong):

- The "Depends on" line names the repository and branch that hold the evidence, plus the pull
  request once the owner opens it. The issue is filed before the spec reports done, so no PR
  exists yet; #15 did the same.
- The issue shape is described in words in the standard (a title naming it a gate spec or a
  standards spec, one section per proposal with its verification pointer, "Depends on", the Rules
  line), citing `fromtheoutfit/patchbay-standards#12` as the example.
- #15's case is written language-neutral, like the sibling-project paragraph: no tool names and
  no spec paths, because the file is synced into projects where those paths don't exist.
- The four old proposals' outcomes are recorded in this spec's `shape.md`. The earlier specs'
  `shape.md` files are records and are left as written (precedent: the fourth spec's Docs step).

## Task 1: Save spec documentation

Create the spec folder with `plan.md` (this plan), `shape.md`, `standards.md` (the full text of the
five `base/process/*` standards as they read now) and `references.md`; no `visuals/`. The first
Decision in `shape.md` cites #13 and #15 and says why they share a spec: both edit
`standards-retrospective.md` in different sections, so one branch avoids two specs racing on one
file. The "Core Architecture" section records `base/python/toolchain` as not applying.

## Task 2: #15, the probe rule

`base/process/standards-retrospective.md`, "Verify against the code, not against the spec". After
the sibling-project paragraph, add:

- **The same holds of a tool's documentation and of a probe.** A rule that rests on how a tool
  behaves is verified by running the tool at its pinned version, on a scratch copy, with the
  transcript in the spec's `verification/`. Three bullets, as #15's corrected body has them:
  - cases chosen so they can tell the competing claims apart, not only the case that confirms
    the expected one;
  - the setup shown to have done what it claims before the result is read;
  - where probe and documentation disagree, the tool's source at the pinned version decides.
- "A spec that changes such a rule reruns the probe."
- A short case paragraph, language-neutral, covering all three: a range that held a second
  accepted version, the source listing it, and cases outside every accepted version failing
  offline; and a layered override that did not reset the file's list, shown by the printed
  settings.

Verify against `main`: write `verification/issue-15-evidence.txt` from `git show main:<path>`
greps, never the working tree. It holds:

- toolchain evidence §5: the doc quote, tag sha `316c827…`, `COMPATIBLE_VERSIONS` line 40, the
  range test 330, the `==` test 352, the five cases offline and online;
- §4: the three `--show-settings` runs and the reset run's 13 findings, CPY001 on all three
  files;
- `git show f3fdbf4:` the first round's "whatever the range";
- the third spec's `## 6. uv's required-version, probed`.

Each bullet of the rule names the lines it rests on, and `shape.md` records the mapping.

## Task 3: #13, the present-and-file step

`base/process/standards-retrospective.md`:

- **New section after "Who owns which standard"**, e.g. `## Base proposals go to the owner, then
  upstream`. It covers:
  - A retrospective that records an entry under `### Standards retrospective (proposed, base)` is
    not complete until every proposal is presented to the owner, each in one or two sentences
    with the shipped file and test it is verified against, and the owner is asked which to send
    upstream (AskUserQuestion, multi-select; "none" is an answer).
  - The approved proposals become **one issue on `patchbay-standards`**, created with `gh` from
    the project's machine, no attribution (`base/process/ownership.md`), in the shape decided
    above. Its number is recorded in `shape.md` beside each proposal.
  - A declined proposal stays, marked `declined by owner, <date>`.
  - **A proposal neither filed nor marked declined is a gate failure for the spec.**
  - The rule holds in `patchbay-standards` too: a proposal here becomes an issue here, and its
    own spec lands it as a pull request.
- **"Who owns which standard"**: the route sentence becomes "goes to the owner and, approved,
  upstream as an issue (below), whose spec lands it as a pull request". "Every standards edit is
  approved by a person" now names both points: the owner sending the proposal, and the PR.
- **"Recording the answer"**: both shapes gain `Proposals sent upstream: #N | none | declined: …`.
  `none` means no proposal was recorded; `#N; declined: …` is the mixed form. The proposal example
  ends `filed as fromtheoutfit/patchbay-standards#N` or `declined by owner, <date>`, and the
  closing paragraph says each entry carries one of the two.

`base/process/standards-sync.md`, "In a consuming project", gets one short paragraph:

- The sync writes nothing under `.claude/commands/`.
- A base change that asks for a step in the gate task of the project's `shape-spec.md` (the
  present-and-file step is the first) is made in the project's own gate spec after the sync that
  brings it in. The template line that goes with it is made there too, since the gate task is a
  gate file (`base/process/verification-gate.md`).

## Task 4: this repository's shape-spec and CLAUDE.md (gate file: last gate-file edit here)

`.claude/commands/agent-os/shape-spec.md`:

- **Gate task step 6** (lines 215–221): add the step, pointing at the standard. Present every
  proposal with AskUserQuestion (multi-select, one or two sentences each, file and test, "none"
  an answer); file the approved ones as one issue on `patchbay-standards` with `gh`, no
  attribution, its number beside each; mark the rest `declined by owner, <date>`; record
  `Proposals sent upstream:`. A proposal neither filed nor declined fails the gate.
- **shape.md template**: `Proposals sent upstream: {#N} | none | declined: {…}` under
  `## Standards Retrospective`, before the `###` subsection. The (proposed, base) paragraph and
  entry line (lines 349–352) say each proposal is presented and ends with its issue or its
  declined marker.
- **Docs fixes**: Step 5 (line 100, "becomes a pull request to this repository") and Step 9
  (lines 259–262) say the same route.

`CLAUDE.md` lines 70–72: "the proposal becomes a pull request here" becomes "presented to the owner
before the spec is done, the approved ones filed as one issue here, whose spec lands them as a pull
request".

`index.yml`: the `process/standards-retrospective` description is rewritten for both rules, with no
`: ` and no ` #`. `process/standards-sync` is read against the note and changed only if the note
adds a decision it omits.

## Task 5: rerun the negative tests

After Task 4's gate-task edit, run `scripts/gate-negative-tests.sh` (bash, zsh-safe) and keep its
transcript in `verification/gate-negative-tests.txt`. Its last line must be `N runs, 0 unexpected`
and `harness exit=0`. Use the third spec's header form: the date, the branch, and "every test but
j". The CI replay j goes in `verification/ci-negative-test.txt`. The workflow is unchanged, but the
rule reruns every negative test when a gate file changes. No harness change, so the "current
transcripts" pointer to issue #12 in `verification-gate.md` stays true.

## Task N (FINAL): Verification gate

1–3. `scripts/gate.sh`: `bash -n` over `scripts/`, pymarkdown at its pin over `base/` and
     `README.md`, and `scripts/check-index.sh`. No new file under `base/`, so step 3 runs on the
     tree.
4. **Docs**, recorded in `shape.md`: every edited sentence is read back. Also read:
   - `README.md` and `scripts/gate.sh`'s header and closing line (both unchanged);
   - `verification-gate.md` lines 88–90 and 185, `standards-sync.md` lines 57–60 and
     `toolchain.md` line 94, each still true as a pointer;
   - every remaining "becomes a pull request" in the files git lists outside `agent-os/specs/`;
   - line widths of 100 or less, and PyYAML reading `index.yml`.
5. **Version**: under `[Unreleased]`, an Added entry "Ninth spec, … (issues #13 and #15)" and
   Changed lines for each edited file. Follow-ups: the new issue and fromtheoutfit/patchbay#7.
6. **Standards retrospective**, the first to follow the new step:
   - Answer the four questions from the shipped diff against `main` (`0b1d0dc`), and record any
     proposal under `### Standards retrospective (proposed, base)`.
   - Re-read the four earlier proposals against today's `verification-gate.md` and
     `standards-sync.md`, and write each in one or two sentences with its file and test:
     - fifth spec: what a spec adding a base file records before staging;
     - sixth spec: the guard-deletion proof of a harness assertion change;
     - sixth spec: a project's out-of-step gate files named in CHANGELOG and an issue;
     - toolchain spec: "a key the tool does not know is not refused".
   - Present them all with AskUserQuestion, multi-select. That is up to four proposals per
     question, so the old four and this spec's own go in separate questions; "none" goes through
     the free-text answer.
   - File the approved ones as one issue here with `gh issue create`, no attribution, shaped as
     decided, "Depends on" naming this branch.
   - Record `Proposals sent upstream:`, the issue number beside each proposal, and
     `declined by owner, 2026-11-06` beside each declined one.
   - Comment on fromtheoutfit/patchbay#7: after the sync, patchbay's gate spec adds the step to
     its shape-spec gate task and the template line, with line numbers read from
     `git -C ../patchbay show origin/main:.claude/commands/agent-os/shape-spec.md`.
   - Update the CHANGELOG follow-ups with the numbers.
   - List the retrospective's own edits apart from the feature's.

Then, as the last act: rerun `scripts/gate.sh` and save `verification/gate-run.txt`, with the
date and branch on its first line and exit 0. Stop, and print `git status --short`.

## Not done by the agent

No stage, commit, push or PR. GitHub writes are limited to the owner-approved issue and the
owner-requested #7 comment, both without attribution. Noted for the owner, not acted on: #13's and
#10's bodies end with an AI-attribution footer.
