# References for the Revision after the Review of PR 25

## Similar Implementations

### The owner's review of PR 25

- **Location:** the comment on fromtheoutfit/patchbay-standards#25, 2026-11-07T21:25:30Z, at the
  pull request's head `050d8b1`.
- **Relevance:** the scope: fourteen findings, two serious, five of accuracy, seven of consistency,
  each answered in `shape.md`'s dispositions.

### The thirteenth spec, `agent-os/specs/2026-11-07-1549-contracts-standards-and-toolchain/`

- **Relevance:** the spec under review, kept as its record. Its `verification/probes.txt` holds the
  probes the standards cite by name and by letter (a to f, j to o), its
  `verification/patchbay-evidence.txt` the citation check this revision reruns, and its shape.md
  the two statements this revision records as corrected (#1, #7).
- **Key patterns:** the transcript scripts (kept in that session's scratchpad, shown in the
  transcripts' headers) and the export of patchbay at `7471387` they run on.

### The revision after the review of PR 23, `agent-os/specs/2026-11-07-1518-revision-after-pr-23-review/`

- **Relevance:** the shape of a revision in this repository: a folder of its own on the same
  branch, the reviewed spec's folder left as its record, every finding reproduced or probed before
  it is fixed, a disposition per finding, patchbay#12 revised in place.

### patchbay at `origin/main` (`7471387`)

- **Location:** `../patchbay`, exported with `git archive 7471387` into the scratchpad.
- **Relevance:** every rule the standards keep is verified against its files; the new rule of
  `layout.md` (#3) against `src/patchbay/`'s module names, and `events.md`'s (#5) against
  `src/patchbay/events.py` (`_in_utc`).

### The text under review, at `050d8b1`

- `base/python/layout.md`, `typing.md`, `models.md`, `errors.md`, `events.md`,
  `base/testing/tests.md` and `base/python/toolchain.md`; `index.yml`;
  `.claude/commands/agent-os/shape-spec.md` (Step 5a, Step 5b, the `shape.md` template).
