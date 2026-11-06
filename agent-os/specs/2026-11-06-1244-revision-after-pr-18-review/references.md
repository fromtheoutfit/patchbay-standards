# References for the Revision after the Review of PR 18

## Similar Implementations

### The review: the owner's comment on PR 18

- **Location:** `gh pr view 18 --comments`, "Review findings — `1e88c77`" (2026-11-06)
- **Relevance:** the 12 findings this spec answers, with line numbers at `1e88c77`.
- **Key patterns:** each finding names a file and line. The scope note puts 1–4 and 8–12 in this
  PR, 6 and 7 with the harness, and 5 on this branch.

### A revision's disposition table: the PR 16 revision

- **Location:** `agent-os/specs/2026-11-06-1040-python-toolchain-standard/shape.md`, "Revision
  after the review of PR 16", and its `plan.md`
- **Relevance:** the last time a review's findings were answered one by one.
- **Key patterns:** each finding checked against the shipped files before it is answered; a
  finding answered by a probe says so; the record of what was wrong first stays.

### The question tool's limits (finding 2)

- **Location:** AskUserQuestion's schema: `questions` 1–4 items, each with `options` 2–4 items
  and `multiSelect`; a free-text "Other" answer is always added.
- **Relevance:** one question holds at most four options, so three proposals and an explicit
  "None of these". Four questions a call hold twelve proposals.

### The harness's assertions (finding 6)

- **Location:** `scripts/gate-negative-tests.sh`, `says()`, `check()`, `run()` and `shown()`
  (lines 67–102 at `1e88c77`); tests g and k
- **Relevance:** `says` finds each expected line in order, as a substring, and nothing more. g's
  second case and k's two "must fail naming process/zeta alone" cases claim more than that.
- **Key patterns:** `shown` leaves the printed output in `$NEG/run.out` for a check after `run`;
  `check` counts runs and unexpected results, and the harness ends on that count.

### A mutation transcript: the sixth spec's `reason-assertion-mutations.txt`

- **Location:** `agent-os/specs/2026-11-05-2019-gate-spec-2-five-base-proposals/verification/reason-assertion-mutations.txt`
- **Relevance:** the form for showing an assertion discriminates: a copy of the tree as git lists
  it, in scratch, one guard changed, the cases run from the copy and coming back `UNEXPECTED`.

### The ninth spec's first negative-test run (finding 5)

- **Location:** the run saved in this session's scratch directory before g was fixed,
  `139 runs, 1 unexpected`, `harness exit=1`
- **Relevance:** the whole of it becomes the ninth's `verification/gate-negative-tests-first-run.txt`,
  so that `gate-negative-tests.txt` ends on its green run.
