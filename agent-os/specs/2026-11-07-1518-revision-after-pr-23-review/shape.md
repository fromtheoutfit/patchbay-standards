# The Revision after the Review of PR 23 — Shaping Notes

Shaped 2026-11-07 in plan mode with `/agent-os:shape-spec`. The owner answered the Step 1–5
questions and four design questions, recorded under Shaping answers and Decisions. Every answer
was the recommended option.

## Core Architecture (Non-Negotiable)

`base/python/toolchain` applies to consuming projects. This repository has no package, so it does
not apply here (Step 5a).

## Scope

The owner's review of fromtheoutfit/patchbay-standards#23 at `00cf7ca`, the eleventh spec
(`agent-os/specs/2026-11-07-1428-gate-spec-4-skeleton-listing-harness/`, issues #17, #19 and #20),
lists nine findings, most severe first. Only #1 was reproduced there. This spec answers all nine:

1. `scripts/sync-standards.sh`'s root guard passes inside `.git/` or a bare repository, and the
   script writes into the git directory.
2. The same guard in `scripts/gate.sh` and `scripts/check-index.sh` reports the wrong reason there.
3. The refusal of a tracked file git ignores reads per-machine excludes over the whole tree.
4. `sync-standards.sh`'s `project_files` exits 128 bare when git cannot list.
5. The listing form depends on `pipefail`, and the rule does not say so.
6. The refusal's advice fails for a file under an ignored directory.
7. The refusal stops at the first file.
8. The empty-record sentinel is written out three times.
9. The harness's upper-case setup is repeated in m, w and u.

A gate spec, on the same branch, so PR 23 carries it. There is a `CHANGELOG.md` entry, the gate is
green, and `verification/gate-run.txt` has the date and branch. No stage, commit, push or PR by an
agent.

## Shaping answers

- **Step 1, scope:** all nine, in a new spec folder; the eleventh spec's folder stays its record.
- **Step 2, visuals:** none.
- **Step 3, references:** the review, `check-index.sh`'s listing and report, the eleventh spec's
  evidence and cases, patchbay#12. See `references.md`.
- **Step 4, product context:** no `agent-os/product/`, so skipped.
- **Step 5, standards:** `process/verification-gate`, `process/standards-sync`,
  `process/standards-retrospective`, `process/ownership` and `process/standards-index`,
  snapshotted at `00cf7ca` in `standards.md`.
- **#3:** committed `.gitignore` files only, over the paths the gate's listings read.
- **#5 and #8:** the temp-file listing; `gate.sh` gains a temporary directory.
- **#4:** exit 2, by name, nothing written.
- **patchbay#12:** its body edited in place, with a "Revised 2026-11-07" paragraph.

## Decisions

- **The review is the scope, answered in a folder of its own** (owner). Every finding is
  reproduced or probed before it is fixed (`verification/probes.txt`); each changed guard carries
  a negative test that runs the script at `00cf7ca` where it had the bug, and a mutation.
- **The root guard asks git two things** (#1, #2): that this directory is inside a work tree
  (`git rev-parse --is-inside-work-tree` prints `true`) and that it is the top (`--show-cdup`
  empty). `--show-cdup` alone prints nothing in `.git/` and in a bare repository. The same guard
  in all three scripts; no paths compared.
- **The refusal reads committed `.gitignore` files only, over the paths the gate's listings read**
  (#3, owner): `git ls-files -z --cached --ignored --exclude-per-directory=.gitignore -- scripts
  base README.md`. Every clone of a commit gets the same answer, and a file no step reads never
  fails the gate. `.git/info/exclude` and the global excludes file are the machine's, and the
  refusal does not read them. The pathspec is the union of the gate's listings, which differs per
  repository; patchbay's is `.`. The refusal form for a walking tool (patchbay's step 5) keeps
  `--exclude-standard`: it guards what the tool reads on that machine, which those files are.
- **The refusal names every offender under one FAIL line** (#7), each indented eight spaces, as
  `check-index.sh` reports, and its advice covers a file under an ignored directory (#6).
- **The listing is written to a temporary file and git's status checked directly** (#5, #8,
  owner): no empty record, no `ok=` flag, no `pipefail` dependency. `gate.sh` makes its temporary
  directory with `mktemp -d` in step 1, after the root guard; a failure fails step 1 by name, so the
  exit contract keeps its three meanings.
- **A listing git cannot make in `sync-standards.sh` is exit 2, by name** (#4, owner). The first
  listing comes before any write, and nothing between it and the verification listing writes
  `.git/index`, so a failure is always a refusal with nothing written.
- **The upper-case runs share two helpers** (#9): `upper`, which says once when the file system is
  case-sensitive, and `upper_run`, which runs a command from the copy's path in upper case.
- **Where a review fix and the probed behaviour disagree, the probe wins**, and this section says so.

## Context

- **Visuals:** None.
- **References:** `references.md`.
- **Product alignment:** N/A; there is no `agent-os/product/` here.

## Standards Applied

**Core (Step 5a, consuming projects):**

- `base/python/toolchain` — not applied here: no package (Step 5a).

**Feature-specific:**

- `process/verification-gate` — the gate's own spec: the skeleton, the listing rule, each changed
  guard with its negative test and mutation.
- `process/standards-sync` — `sync-standards.sh` is a gate file in every project; its root check
  and its listing change, with tests t and u.
- `process/standards-retrospective` — the probe rule; present-and-file for any proposal.
- `process/ownership` — no stage, commit or push; the issue edit carries no attribution.
- `process/standards-index` — the descriptions kept in step.

## Verification Gate

Spec is not complete until `scripts/gate.sh` passes — `bash -n` on every shell script under
`scripts/` as git lists them, at a work-tree top that is the repository root, as git says, with no
tracked file a `.gitignore` ignores; `pymarkdown`, installed at its pin through `uvx` as its own
check, over the `.md` files under `base/` and `README.md` as git lists them; and
`scripts/check-index.sh` — and the three judgment steps are recorded, in this order: Docs,
Version, then the standards retrospective below.

**Results (2026-11-07):** exit 0 on branch
`task/17-gate-spec-4-land-six-base-proposals-from-this-repositorys-specs-verification-gatemd-standards-syncmd`,
`verification/gate-run.txt`, the last thing done before hand-over. The gate was green after each
of the root guard, the temp-file listing, the refusal, the sync's listing and the standards text.
Every gate file changed, so every negative test was rerun after the last edit:

- `verification/probes.txt`: git and bash at their pins and the scripts at `00cf7ca` and `11ceffd`,
  before any gate file was edited. #1 reproduced as the review did; #2–#6 confirmed by probe. The
  review's advice for #6 (`!build/` and narrower patterns) is not the form the probe showed
  working: ignoring the directory's contents (`dir/*`) and then re-including the file is, and the
  refusal's advice says that. The probe decided.
- `verification/gate-negative-tests.txt`: one run, every test but j, `194 runs, 0 unexpected`,
  `harness exit=0`.
- `verification/ci-negative-test.txt`: j, `2 runs, 0 unexpected`; the workflow is unchanged. PR 23's
  hosted run at `00cf7ca` is recorded there (42408145838, success).
- `verification/guard-mutations.txt`: M1–M11, each guard this revision added or changed put back,
  deleted or its status ignored in a fresh copy, each `UNEXPECTED`, harness exit 1.
- `verification/gate-sh-diff.txt`: against patchbay `main`. Beyond step lists, pins, paths and the
  refusal's pathspec it holds exactly the skeleton hunks patchbay takes, as fromtheoutfit/patchbay#12
  now says.

**Docs (step 4):**

- **Script headers, each read against the code beside it:** `scripts/gate.sh` (the listing
  paragraph: files in a temporary directory with git's status checked, the guard's two questions,
  the refusal's scope and report; step 1's needs gain `mktemp`), `scripts/check-index.sh` (the
  guard), `scripts/sync-standards.sh` (the guard; a listing git cannot make among the exit-2
  reasons), `scripts/gate-negative-tests.sh` (the test list for m, w and y, the `mktemp` shim,
  `upper` and `upper_run`, t among the tests that run a script from history).
- **`CLAUDE.md` and the gate task in `.claude/commands/agent-os/shape-spec.md`** (step 1 and the
  template's Verification Gate paragraph): "a tracked file a `.gitignore` ignores".
- **`README.md`:** one line, naming nothing this revision changed; reads true.
- **`base/process/verification-gate.md`, `base/process/standards-sync.md` and `index.yml`:** each
  rewritten paragraph re-read against the scripts as shipped; the `verification-gate`
  description follows the text, with no `: `. Searched the tree outside `agent-os/specs/` and
  `CHANGELOG.md` for "tracked file git ignores", "empty record", `printf '\0'`, "sentinel",
  `ls-files -ci`, `ok=` and `cached --ignored --exclude-standard`: the only hits are `--check`'s
  own `ok` flag in `sync-standards.sh`, which is not a listing.
- **The eleventh spec's folder** is its record and unchanged; its `CHANGELOG.md` entry gains one
  sentence saying what this revision replaced.
- **Line widths:** no prose line this revision added is over 100 columns.

**Version (step 5):** under `[Unreleased]`, `### Added`, in `CHANGELOG.md`: the twelfth spec's
entry, naming the review, the scripts, the standards and fromtheoutfit/patchbay#12. No version
bump: this repository has none.

## Standards Retrospective

Step 6, always last, from the shipped diff against `00cf7ca`. This revision's feature is the
review's nine findings, two base standards' text among them; the retrospective asks what the work
taught beyond them.

1. *A pattern no standard covers?* None. `upper` and `upper_run` are harness helpers, the `mktemp`
   on `PATH` is the git shim's seam for another command, and `git_list` and `fail_list` are the
   skeleton, which `verification-gate.md` now names. The global excludes file is set for a case by
   `GIT_CONFIG_GLOBAL`, not `HOME`, which would move uv's cache; a harness detail, not a rule.
2. *A standard wrong or stale?* None found beyond the review's own findings, which this revision
   fixed in its feature diff. fromtheoutfit/patchbay-standards#22's first proposal, mutations for
   the guards a gate spec adds, holds again: this revision shows its eleven the same way.
3. *A deliberate deviation?*
   - **Deviation, not a standard change:** the plan gave `upper` a copy argument; it takes none,
     since the file system's case-sensitivity is one fact for the whole scratch directory.
   - **Deviation, not a standard change:** the first form of step 1's `mktemp` check sent
     `mktemp`'s own message to `/dev/null`, and w's new case came back `UNEXPECTED` for it; the
     message is shown now, under "(see above)".
   - **Deviation, not a standard change:** w's shim pattern is ` --exclude-standard -- scripts `,
     since the refusal's pathspec also holds ` -- scripts `; u's corrupt-index sync names
     `HEAD~1`, since by then the checkout's `origin/main` holds u's `base: {}` commit.
   - **Deviation, not a standard change:** `VIRTUAL_ENV`, which this shell set to an unrelated
     project, was unset for every recorded run, as each transcript says.
4. *A moved pointer?* Fixed in the feature diff: `verification-gate.md` names this revision for
   the current transcripts and the current diff; the eleventh spec's `CHANGELOG.md` entry says
   what this revision replaced. fromtheoutfit/patchbay#12 is rewritten to read true of the revised
   skeleton. No standard names a file this revision moved or removed.

No standard is changed or proposed by this retrospective, and it edited no file outside this spec
folder.

Proposals sent upstream: none
