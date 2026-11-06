# References for gate spec 2 (issue #10)

Every patchbay file is read at `origin/main` of `../patchbay` (`0916b55`, the merge of its PR 3),
with `git -C ../patchbay show origin/main:<path>`; the checkout's working tree is on a feature
branch and is not consulted.

## Similar Implementations

### patchbay `scripts/gate.sh`

- **Location:** `../patchbay`, `origin/main:scripts/gate.sh`
- **Relevance:** The gate this repository's `scripts/gate.sh` is aligned with; after this spec
  the two differ only in their step lists (`verification/gate-sh-diff.txt`).
- **Key patterns:** the usage check (`$# -ne 0` is exit 2); `fail <step> <reason>` printing
  `FAIL  step N/M: <reason>` on stderr and exiting 1; step 1's loop over
  `git -c core.quotePath=false ls-files -z` (tracked, then `--others --exclude-standard`) piped
  through `LC_ALL=C sort -zu`, each file checked present, `.sh` or a bash shebang, `bash -n`;
  the header's exit-status and listing paragraphs; the pins block with its place-holder comment.

### patchbay `scripts/gate-negative-tests.sh`

- **Location:** `../patchbay`, `origin/main:scripts/gate-negative-tests.sh`
- **Relevance:** The harness shape this repository's harness adopts.
- **Key patterns:** `die` for a setup failure (exit 2); `NEG=$(mktemp -d) || die`, refused when
  empty or not a directory, resolved with `pwd -P`, refused at or under the repository, then
  `trap 'rm -rf "${NEG:?}"' EXIT`; `run <case> <expected> <cmd...>` printing `exit=N` or
  `exit=N  UNEXPECTED (expected M)` and counting; `replay <case> <expected>` for j; the closing
  `N runs, M unexpected` and `[ "$unexpected" -eq 0 ]`; `mk` laying each case out as
  `<case>/patchbay` beside a `<case>/patchbay-standards` symlink to one clone of the sibling per
  run; tests g (step 1's list) and u (usage), mirrored here as w and x.

### patchbay `.github/workflows/gate.yml`

- **Location:** `../patchbay`, `origin/main:.github/workflows/gate.yml`
- **Relevance:** The pin step proposal 5 is written from.
- **Key patterns:** `id: pin` reading `.version` with `tr -d '[:space:]'` into `GITHUB_OUTPUT`
  as `sha=`; the second `actions/checkout` with `repository:`, `ref: ${{ steps.pin.outputs.sha }}`,
  `path:` and `persist-credentials: false`, no `fetch-depth`; the gate run with
  `working-directory: patchbay`.

### patchbay's two spec records

- **Location:** `origin/main:agent-os/specs/2026-11-05-1733-bootstrap-shape-spec-gate-ci-docs/shape.md`
  and `origin/main:agent-os/specs/2026-11-05-1759-gate-revision-after-pr-3-review/shape.md`
- **Relevance:** The proposals, under "Standards retrospective (proposed, base)", and the tests
  each cites (a, d, u; g; j). Read for what each proposal claims and where it points; the rules
  are written from the files above, not from this text.

### This repository's gate files

- **Location:** `scripts/gate.sh`, `scripts/gate-negative-tests.sh`, `scripts/check-index.sh`,
  `scripts/sync-standards.sh` (the listing at lines 267–268), `.github/workflows/gate.yml`
- **Relevance:** What is aligned, and the two scripts that already list files with git
  (`check-index.sh` for `base/`, `sync-standards.sh` for a project's `base/`), which the general
  listing rule is verified against beside `gate.sh` step 1.

### The fourth and fifth spec folders

- **Location:** `agent-os/specs/2026-11-05-1000-gate-spec-ci-docs-version/`,
  `agent-os/specs/2026-11-05-1441-sync-script-and-standards-sync/`
- **Relevance:** The gate spec's record shape (`plan.md`, `shape.md` with Docs and Version before
  the retrospective, transcripts with the date and branch on line 1); the fifth spec's
  `verification/gate-negative-tests.txt`, whose 114 `exit=` lines are the expected statuses the
  rewritten `run` calls assert.

## Added for the revision after the review of PR 11 (2026-11-05)

### The owner's review of PR 11

- **Location:** the comment on pull request 11 (`IC_kwDOVh8HmM8AAAABjddnnw`), 2026-11-05, "Review
  findings"; read with `gh pr view 11 --json comments`.
- **Relevance:** The ten findings this revision addresses, none verified when posted. Dispositions
  in `plan.md` under "Revision after the review of PR 11", decisions in `shape.md`'s "Revision after
  review".

### `scripts/check-index.sh`'s root guard

- **Location:** `scripts/check-index.sh`, lines 26–31.
- **Relevance:** The model for finding 1: `root=$(pwd -P)`, and `git rev-parse --show-toplevel`
  must succeed and equal it, or the script fails by name. `gate.sh` step 1 takes the same guard, so
  a copy without `.git` inside another repository is refused at step 1, not listed against the
  outer repository.

### The fifth spec's revision record

- **Location:** `agent-os/specs/2026-11-05-1441-sync-script-and-standards-sync/plan.md` ("Revision
  after the review of PR 9") and its `shape.md` ("Revision after review").
- **Relevance:** The shape of a review round in the same spec folder: the owner's choices named, a
  disposition table, every transcript rerun, Results, Docs, Version and the retrospective rewritten
  from the revised diff; `old_file` showing a bug as it was at the PR's first head.

### patchbay's gate and harness at `origin/main`

- **Location:** `../patchbay`, `origin/main` (`0916b55`): `scripts/gate.sh` and
  `scripts/gate-negative-tests.sh` (the fixture: `git clone -q "$SIBLING" "$NEG/patchbay-standards"`,
  and the header comment "which carries every branch and so the pinned commit").
- **Relevance:** Step 1 there is this repository's step 1 as the first round shipped it, so
  findings 1, 9 and 10 hold there too and are patchbay's to take after its next sync (the issue
  opened in Task 6). Its harness runs only `sync-standards.sh --check` against the clone, which
  reads the pin from `.version`; finding 5's corrected sentence is written from that and from a
  scratch experiment on a local clone.
