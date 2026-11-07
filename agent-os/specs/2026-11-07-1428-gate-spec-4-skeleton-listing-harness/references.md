# References for Gate Spec 4: the Skeleton, the Listing Rule and the Harness

Every patchbay path below is read at `main` (`3f910d8`, the merge of fromtheoutfit/patchbay#9,
whose tree is identical to its head `799cfde`), with `git -C ../patchbay show main:<path>`; the
sibling's working tree is on another branch and is not read.

## Similar Implementations

### patchbay's gate skeleton

- **Location:** `../patchbay` `scripts/gate.sh` at `main`
- **Relevance:** the skeleton #20 proposal 6 asks for, shipped there first: the root guard asked
  of git, `listed` with `sort -zu` and its empty record, and every reader failing without it.
  Its step 5 is the refusal form of proposal 8.
- **Key patterns:** `cdup=$(git rev-parse --show-cdup 2>/dev/null) && [ -z "$cdup" ]`;
  `… | LC_ALL=C sort -zu && printf '\0'`; `[ -n "$f" ] || { ok=1; break; }` with
  `[ -n "$ok" ] || fail …` after the loop; step 5's `git ls-files -z --others --ignored
  --exclude-standard -- tests conftest.py && printf '\0'`, read the same way.

### patchbay's harness

- **Location:** `../patchbay` `scripts/gate-negative-tests.sh` at `main`, tests g, p, q and r
- **Relevance:** g is the negative test of the skeleton (the copy entered in upper case, a
  three-way conflict counted with `times`, a corrupt index, each with the old gate shown); r puts
  a git on `PATH` that refuses one call, for a listing git cannot make after step 1 has listed;
  p is the force-added case; q the refusal form.
- **Key patterns:** `NEGUP` and the upper-case `<COPY …>` in `shown`; the skip on a
  case-sensitive file system; `times <n> <line>` (`grep -cxF`); the shim matching
  `$GATE_TEST_REFUSE` within the call's arguments.

### patchbay's revision evidence

- **Location:** `../patchbay` `agent-os/specs/2026-11-07-0711-gate-revision-after-pr-9-review/`
  `verification/probes.txt`, `reason-assertion-mutations.txt`, `gate-sh-diff.txt`, `shape.md`
- **Relevance:** the probes #20's proposals 1, 3, 4, 6 and 8 rest on; the mutations M1–M4 of the
  skeleton guards and step 5's refusal; the diff that names the skeleton hunks as patchbay's
  deviation until the sync; the retrospective that filed the proposals.
- **Key patterns:** a probe transcript that shows each setup before its result; one mutation per
  guard, its `diff -u`, the covering test, `UNEXPECTED` and the count.

### patchbay's first gate spec

- **Location:** `../patchbay` `agent-os/specs/2026-11-06-1527-gate-skeleton-dev-pins-toolchain-tier/`
  `shape.md`, `verification/probes.txt`, `verification/gate-negative-tests.txt`
- **Relevance:** where the tracked-and-ignored refusal was first proposed (`git ls-files -ci
  --exclude-standard`), from the force-add probes of ruff and mypy; and the sync to `11ceffd`
  that added no CHANGELOG entry (#20 proposal 5).

### This repository's mutation transcripts

- **Location:** `agent-os/specs/2026-11-05-2019-gate-spec-2-five-base-proposals/verification/reason-assertion-mutations.txt`,
  `agent-os/specs/2026-11-06-1244-revision-after-pr-18-review/verification/only-assertion-mutations.txt`
- **Relevance:** #17 proposal 2 is verified against the first; the second is the shape of a
  mutation proof of a harness assertion (`only`).
- **Key patterns:** a fresh copy of the tree as git lists it, outside the repository and not a
  git repository, so a test's runs of scripts from history are skipped; the `sed` and its effect
  shown; the covering test run; the `UNEXPECTED` lines and the count.

### This repository's harness, tests g, k, w and y

- **Location:** `scripts/gate-negative-tests.sh`
- **Relevance:** w holds step 1's file-list cases and y step 2's, so the new cases join them; g
  and k carry `only`, the exclusive check #17 proposal 5 writes the standard for.
