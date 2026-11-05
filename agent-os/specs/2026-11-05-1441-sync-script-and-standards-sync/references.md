# References for the sync spec (issue #8)

## Similar Implementations

### `scripts/check-index.sh`

- **Location:** `scripts/check-index.sh`
- **Relevance:** Gate step 3; the only script here that reads the `base:` section of an index.
- **Key patterns:** the awk that walks the `base:` section by indentation; the tracked-files list
  (`git ls-files -- base` plus `--others --exclude-standard`, paths unquoted, each checked on disk);
  `export LC_ALL=C` once; every list sorted after its last transform and checked sorted before
  `comm`; every failure named with its reason and path; a precondition (not a git work tree) fails by
  name.

### `scripts/gate-negative-tests.sh`

- **Location:** `scripts/gate-negative-tests.sh`
- **Relevance:** The harness the sync tests join (tests o–v).
- **Key patterns:** `mk` builds a copy in `mktemp -d` and git-adds it; `run` runs a command in the
  copy, prints its output with the temp path rewritten to `<copy x>` and the exit status; `hdr` and
  `note`; a positive case shown passing beside each negative; nothing in the tree is touched.

### `scripts/gate.sh`

- **Location:** `scripts/gate.sh`
- **Relevance:** Step 1 parses every file under `scripts/`, so the new script is covered by the gate
  the moment it lands; its banner and `ok   <what>` report shape is the one the sync's stderr report
  follows.

### The four spec folders

- **Location:** `agent-os/specs/2026-11-04-0750-*`, `2026-11-04-1016-*`, `2026-11-05-0741-*`,
  `2026-11-05-1000-*`
- **Relevance:** The `shape.md` shape (gate results first, Docs, Version, retrospective last), the
  `verification/` transcripts with the date and branch on the first line, and the fourth spec's
  decision that "does not merge" waits for branch protection, which this spec closes.

### `.claude/commands/agent-os/index-standards.md`

- **Location:** `.claude/commands/agent-os/index-standards.md`
- **Relevance:** The stock regeneration the sync's `--index-only` replaces on a synced index: it
  rewrites the whole file, `root` first then sections alphabetical, one blank line between sections.
  `--init` inserts the `base:` section where that ordering puts it.

## Added for the revision after the review of PR 9 (2026-11-05)

### The owner's review of PR 9

- **Location:** the comment on https://github.com/fromtheoutfit/patchbay-standards/pull/9 dated
  2026-11-05, "Review of 3d3e111"; read with `gh pr view 9 --json comments`.
- **Relevance:** The 22 findings this revision addresses; two reproduced on macOS. Dispositions in
  `plan.md`, decisions in `shape.md`'s "Revision after review".

### The fourth spec's revision record

- **Location:** `agent-os/specs/2026-11-05-1000-gate-spec-ci-docs-version/shape.md` ("Revision
  after review") and its `plan.md` ("Revision after the first review of PR 7").
- **Relevance:** The shape of a review round recorded in the same spec folder: the owner's choices
  named, the rest accepted as the review recommends, a disposition table in `plan.md`, every
  transcript rerun.
- **Key patterns:** showing the bug as it was with the script from history (`old_script`, now
  `old_file`) beside the shipped one; the hosted run recorded by id in `ci-negative-test.txt`.
