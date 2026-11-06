# Plan: the tenth spec, the revision after the review of PR 18

## Context

The owner's review of PR 18 (`1e88c77`, the ninth spec, issues #13 and #15) lists 12 findings
in one PR comment.

- Most are about the new process text: rules that contradict each other or can't be followed as
  written.
- One is a defect in an evidence file, and two are about the harness.

Each finding was re-checked against the branch at shaping. All 12 hold, two with corrections:

- **Finding 7 is narrower than stated.** Only g rewrote its own index while keeping the copied
  `base/`. Cases a, n and y depend on `base/process/ownership.md` existing, but they fail loudly
  at setup (`die`, exit 2), not silently.
- **Finding 6 also covers k.** Both of k's "must fail naming process/zeta alone" cases are
  unasserted, like g's second case.

One more stale route is out of the review: `standards-sync.md:59`, "changed in
`patchbay-standards` by a pull request there", the same as finding 12.

Spec folder: `agent-os/specs/2026-11-06-1244-revision-after-pr-18-review/` (owner: a new folder),
on the same branch, `feature/13-…`, so the owner's commit lands on PR 18.

## Shaping answers (owner, 2026-11-06)

- **Scope:** all 12 findings plus `standards-sync.md:59`, in a tenth spec folder.
- **Visuals:** none.
- **References:**
  - the review comment;
  - the PR 16 revision as the model for a disposition table;
  - the AskUserQuestion limits: 2–4 options a question, 1–4 questions a call;
  - the harness's `says()`/`check()` and test k;
  - the saved first run (139 runs, 1 unexpected).
- **Standards:** the same five `base/process/*`. `standards.md` is the snapshot at `1e88c77`;
  the ninth's is left as it was. `base/python/toolchain` gets a Docs edit but does not apply here.
- **Findings 6 and 7:** fix 6 here. Finding 7's analysis, and the standard text for both, go to
  #17 as a comment.
- **Finding 4:** whoever writes the PR body links the issue and checks its paths. Applied now to
  #17 and PR 18.
- **Findings 1 and 10:** one clause in "What the sync writes, and nothing else". The paragraph at
  the end of "In a consuming project" is removed, overriding #13's placement.
- **Finding 5:** corrected in the ninth's folder, as a record correction.

Decided in the plan (adjust at approval if wrong):

- **Finding 11:** an issue is titled a gate spec when any approved proposal needs a gate file
  changed. It says which proposals do, and its standards proposals ride with it, as #10 and #12
  carried theirs. #17 already complies: its "This repository's gate files" section names 4 and 5.
- **The ninth's presentation** (four proposals in one question, "none" only through the free-text
  answer) was made before the rule said how to split. The tenth's `shape.md` records that, and
  the six are not re-presented.
- **PR 18's body is not edited in this spec.** Under finding 4's answer, the body's writer checks
  paths at the PR's head, which waits for the owner's push. The hand-over says so.

## Task 1: Save spec documentation

- **`plan.md`:** this plan, with the disposition table of the 12 findings below.
- **`shape.md`:**
  - the first Decision: this spec answers the review of PR 18, and why it is a new folder;
  - "Core Architecture", recording `base/python/toolchain` as not applying.
- **`standards.md`:** the five `base/process/*` at `1e88c77`, verbatim.
- **`references.md`.**

| # | Finding | Disposition |
| --- | --- | --- |
| 1, 10 | sync note's reason false; third copy | one clause in "What the sync writes"; paragraph removed |
| 2 | one question can't hold the proposals and "none" | split rule in the standard and gate step 6 |
| 3 | `Proposals sent upstream:` only when a proposal exists | always, in gate step 6 and `CLAUDE.md` |
| 4 | issue filed before push; links never re-checked | PR-body writer links and checks; #17 now |
| 5 | ninth transcript's last line `harness exit=1` | split the file in the ninth's folder |
| 6 | "alone" not asserted (g, and k) | `only` check in the harness, proven by mutation |
| 7 | `mk` copies live `base/` | analysed: only g was exposed; to #17 as a comment |
| 8 | template's forms read as exclusive | the four forms spelled out |
| 9 | declined named by position | named by file and short name |
| 11 | mixed gate and standards proposals in one issue | gate spec if any needs a gate file; says which |
| 12 | `toolchain.md:94` old route | route corrected; `standards-sync.md:59` too |

## Task 2: the standards text

`base/process/standards-retrospective.md`, "Base proposals go to the owner, then upstream":

- **Finding 2:** at most three proposals to a question, each question ending with a "None of
  these" option, four questions to a call. More proposals take further calls.
- **Finding 4:** "Depends on" names the repository and branch, whose evidence lands when the
  owner pushes. When the PR opens, whoever writes its body (the owner, or an agent asked to):
  - names the issue in the body;
  - adds the PR to the issue's "Depends on" line;
  - checks that every path the issue cites exists at the PR's head.
- **Finding 11:** the title rule above.
- **"Recording the answer" (findings 8, 9):** the line's four forms:
  - `none` (no proposal recorded);
  - `#N` (all filed);
  - `#N; declined: …` (some declined);
  - `declined: …` (every one declined, no issue).

  A declined proposal is named by its file and a short name, never by position. The example uses
  `declined: \`base/process/verification-gate.md\` (<short name>)`.

`base/process/standards-sync.md` (findings 1, 10, and line 59):

- In "What the sync writes, and nothing else", one clause: nothing else is written, and
  `.claude/commands/` is not among the four. So a gate-task step a base standard asks for is made
  in the project's own gate spec after the sync, the gate task being a gate file.
- Delete the closing paragraph of "In a consuming project".
- Line 57–60: a project's change goes upstream by the retrospective's route (a proposal the owner
  sends upstream as an issue, whose spec lands it as a pull request).

`base/python/toolchain.md:94` (finding 12): "a change to this standard first, landed in
`patchbay-standards` by its own spec (from a project, a proposal its retrospective sends
upstream)".

## Task 3: the gate task and `CLAUDE.md` (gate files)

- **`.claude/commands/agent-os/shape-spec.md`, gate step 6 (findings 2, 3):**
  - the split (three proposals and "None of these" a question, four questions a call);
  - record `Proposals sent upstream:` always, `none` when there is no proposal.
- **The template's line (finding 8):** the four forms, with declined proposals named.
- **`CLAUDE.md:61` (finding 3):** record `Standards retrospective: no changes` and
  `Proposals sent upstream: none`.

## Task 4: the exclusive check (finding 6), and the ninth's transcript (finding 5)

`scripts/gate-negative-tests.sh`:

- Add `only <entry>...`. The last run's entry lines (`^        `, the names under a FAIL line)
  must be exactly those, in order. Otherwise it prints `UNEXPECTED (listed: …)` and counts one
  unexpected, without counting another run.
- Call it after g's second case (`process/B`) and both of k's "alone" cases (`process/zeta`).
- Add a header sentence for it.

`verification/only-assertion-mutations.txt` (the method of #17's proposal 2): a copy of the tree
as git lists it, in scratch, with three mutations.

- **M1: g's fixture reverted to `rm "$NEG/g/base/process/"*.md`.** Run g: case 2's `only` comes
  back `UNEXPECTED (listed: process/B, python/toolchain)`, and the harness exits 1.
- **M2: the same, with `only` removed.** Case 2 passes, which shows `only` is what catches it.
- **M3: k with a second unindexed file added beside zeta.** `only` is UNEXPECTED, and the
  `says` reason alone still passes.

Finding 5, in the ninth's folder:

- Split `verification/gate-negative-tests.txt`. It keeps its header, worded for the split, and
  the green run, and ends `harness exit=0`.
- The whole saved first run (`neg-before-g-fix.out`, `139 runs, 1 unexpected`) goes to
  `verification/gate-negative-tests-first-run.txt`, with a header.
- Update the pointers to it: the ninth `shape.md`'s "Found during implementation", Results and
  the proposal-4 entry, plus #17's proposal 4.

`base/process/verification-gate.md`: "the spec that last changed the harness" names this spec.

## Task 5: #17 (findings 4, 6, 7)

- **Edit #17's body:**
  - "Depends on" gains PR 18;
  - proposal 4's transcript pointer moves to `gate-negative-tests-first-run.txt`;
  - check every path #17 cites against `1e88c77`, and against the tree for the moved one.
- **Comment on #17, no attribution:**
  - the harness half of proposal 5 lands in PR 18's revision (`only`, in g and k), so the
    standard text remains;
  - finding 7's analysis: only g rewrote its own index, while a, n and y fail loudly at setup if
    `ownership.md` moves, and i's MD013 cases depend on the real tree's line lengths;
  - the review's finding 11 rule, which #17 meets.

## Task 6: rerun the negative tests

After the last gate-file edit, rerun:

- `scripts/gate-negative-tests.sh` → this spec's `verification/gate-negative-tests.txt`, ending
  `0 unexpected` / `harness exit=0`;
- `scripts/gate-negative-tests.sh j` → `verification/ci-negative-test.txt`, which also records
  the hosted run 42263204683 of `1e88c77`, success.

## Task N (FINAL): Verification gate

1–3. `scripts/gate.sh` on the tree.

4. **Docs**, in `shape.md`: every changed sentence, read back.
   - Re-search `base/`, `CLAUDE.md` and `shape-spec.md` for "pull request" routes and for
     "Proposals sent upstream".
   - `index.yml`'s `process/standards-sync` and `process/standards-retrospective` descriptions,
     against the moved clause and the new rules.
   - The ninth's `CHANGELOG` sub-bullet that places the note in "In a consuming project" is
     corrected to "What the sync writes".
   - Line widths, and PyYAML.
5. **Version:** the tenth spec's Added entry (revision of PR 18, twelve findings) and its Changed
   lines.
6. **Retrospective**, the four questions from the diff against `1e88c77`. Any proposal is
   presented by the corrected rule, at most three to a question with "None of these". The
   approved ones are filed as one issue and declined ones marked, and `Proposals sent upstream:`
   is always recorded.

Then, as the last act: `scripts/gate.sh` → `verification/gate-run.txt`, with the date and branch on
its first line. Stop, and print `git status --short`.

## Not done by the agent

No stage, commit, push or PR. GitHub writes are limited to #17's body edit and comment, plus any
issue the retrospective files on approval, all without attribution. PR 18's body is updated after
the owner pushes, if asked.
