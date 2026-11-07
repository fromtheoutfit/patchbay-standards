# Revision after the review of PR 23

## Context

PR 23 (head `00cf7ca`) carries the eleventh spec: the gate spec of #17, #19 and #20. The owner's review lists nine findings; only #1 was reproduced.

- **1:** `sync-standards.sh`'s new `--show-cdup` root guard passes inside `.git/` or a bare repo. The script then writes into the git directory.
- **2:** the same guard in `gate.sh` and `check-index.sh` reports the wrong reason there.
- **3:** the tracked-and-ignored refusal reads per-machine excludes over the whole tree.
- **4:** `sync-standards.sh`'s `project_files` exits 128 bare when git cannot list.
- **5:** the listing form silently depends on `pipefail`.
- **6:** the refusal's advice fails when a parent directory is ignored.
- **7:** the refusal stops at the first file.
- **8:** the sentinel workaround is written out three times.
- **9:** the harness's upper-case setup is repeated three times.

This revision answers all nine in a new spec folder on the same branch, so PR 23 carries it. The eleventh spec's folder stays its record. No stage, commit, push or PR by the agent.

## Shaping answers (owner, 2026-11-07)

- **Scope:** all nine, in a new folder. Visuals: none. References and standards: as proposed (below).
- **#3:** only committed `.gitignore` files count, over the paths the gate's listings read: `git ls-files -z --cached --ignored --exclude-per-directory=.gitignore -- scripts base README.md`.
- **#5 and #8:** the temp-file listing. `listed <file> <path...>` runs `git ls-files … > <file>.raw && LC_ALL=C sort -zu <file>.raw > <file>`, and each caller checks the status. There is no sentinel, no `ok=` flag and no `pipefail` dependency. `gate.sh` gains `mktemp -d` and a trap.
- **#4:** exit 2, by name, with nothing written.
- **patchbay#12:** its body is edited in place, with a "Revised 2026-11-07" paragraph, the numbers kept and no attribution.

## Decisions for shape.md

1. **The review is the scope, answered in a folder of its own.** Every finding is reproduced or probed before it is fixed. Each changed guard carries a negative test, the script at `00cf7ca` shown failing where it had the bug, and a mutation.
2. **Root guard (#1, #2):** git must say the directory is inside a work tree (`git rev-parse --is-inside-work-tree` prints `true`) and is its top (`--show-cdup` empty). The same guard goes in all three scripts, and no paths are compared.
3. **Refusal (#3, #6, #7):** committed `.gitignore` files only, so every clone gets the same answer.
   - `.git/info/exclude` and the global file are the machine's, and the refusal does not read them.
   - The pathspec is the union of the gate's listings: allowed to differ per repository; patchbay's is `.`.
   - One FAIL line names every offender as indented entries, as `check-index.sh` does. The advice covers a file under an ignored directory: re-include the directory (`!dir/`) and narrow its patterns, or untrack the file.
   - **The refusal form (patchbay's step 5) keeps `--exclude-standard`:** it guards what the walking tool reads on this machine, which those files are.
4. **Listing (#5, #8):** the rule names the temp-file form and why: a process substitution and a pipe both lose git's status, and a reader checks git's status directly.
   - A failed `mktemp -d`, or an empty result, fails step 1 by name.
   - **The exit contract is unchanged:** 0, every step passed; 1, a step failed; 2, not run as the gate.
5. **Sync listing (#4):** `project_files` lists to files and checks git's status; on failure it exits 2 with "git could not list the files under agent-os/standards/base (see above)".
   - The first listing comes before any write, and nothing between it and the verification listing writes `.git/index`. A failure is therefore always a refusal with nothing written.
6. **Harness (#9):** an `upper <copy>` predicate prints the skip note once, on a case-sensitive file system, and returns 1.
   - `upper_run <copy> <status> [<text>] <cmd…>` runs a command from the copy's upper-case path. It is built on `NEGUP`, with bash 3.2's empty-array rule under `set -u` respected.
   - It replaces the `UPC`/`UPP` blocks in m, w and u.
7. **Where a review fix and the code disagree, the code wins**, as probed, and `shape.md` says so. Two candidates:
   - whether `!dir/` re-includes as the advice says;
   - whether `--exclude-per-directory` alone gives `-i` an exclude source.

## Task 1: Save spec documentation

Create `agent-os/specs/2026-11-07-1518-revision-after-pr-23-review/`. It was saved at 15:18.

- `plan.md`.
- `shape.md`: Core not applied, Scope, Shaping answers, Decisions, Context, Standards Applied, and the Gate and Retrospective sections.
- `standards.md`: the five standards in full at `00cf7ca`.
- `references.md`:
  - the review comment;
  - `check-index.sh`'s temp-file listing and FAIL-with-entries output;
  - the eleventh spec's `probes.txt`, `guard-mutations.txt` and cases w, y, m, h and u;
  - patchbay#12.

## Task 2: Probes → `verification/probes.txt`

Scratch only, at git 2.54 and bash 3.2, each setup shown before its result.

1. **`--show-cdup` and `--is-inside-work-tree`** at a top, a subdirectory, `.git/`, `.git/objects/`, a bare repository, a copy without `.git` inside another repository, outside any repository, and the top typed in upper case.
2. **Reproduce #1:** the script at `00cf7ca` run with `--init` from a scratch project's `.git/` writes `agent-os/standards/` there, then dies bare. The fixed guard must refuse with exit 2, as the script at `11ceffd` did.
3. **`ls-files --cached --ignored --exclude-per-directory=.gitignore`:**
   - it lists tracked files the root and nested `.gitignore` files match, and not those matched only by `info/exclude` or the global file;
   - a pathspec limits it;
   - a `!file` under an ignored directory leaves the file ignored, and `!dir/` plus narrower patterns re-includes it (#6);
   - `-i` with that exclude source alone works.
4. **#5:** without `pipefail`, `git ls-files … | sort -zu && printf '\0'` on a corrupt index prints the empty record.
5. **#4:** `sync-standards.sh --check` at `00cf7ca`, on a corrupt project index, exits 128 bare.

## Task 3: Root guard (#1, #2); gate green after

- **`gate.sh`, `check-index.sh` and `sync-standards.sh`:**
  - the guard as in Decision 2, with the same FAIL or die text as now;
  - their headers updated.
- **Harness cases:**
  - **w:** a copy of the tree (without its `.git`) under another repository's `.git/`, and inside a bare repository. Step 1 must fail by name, and the gate at `00cf7ca` reports the listing instead.
  - **m:** the same two places for `check-index.sh`.
  - **u:** `--init` from the project's `.git/` is refused with exit 2 and nothing is written there. The script at `00cf7ca` writes `agent-os/standards/` into `.git/`, shown by `ls`.

## Task 4: The temp-file listing (#5, #8); gate green after

- **`gate.sh`:**
  - **`mktemp -d`**, checked non-empty and a directory, then the trap, all after the root guard in step 1;
  - **`listed`** in the temp-file form;
  - **readers:** steps 1 and 2 read the file after `listed … || fail <step> "git could not list …"`, and the refusal reads its own listing the same way;
  - **removed:** every sentinel and `ok=` flag;
  - **header:** the listing paragraph rewritten to match.
- **Harness:**
  - **w:** a `mktemp` on `PATH` that fails makes step 1 fail by name.
  - **w and y:** the shim cases and w's corrupt index keep their reasons; the refusal's reason text follows Task 5.

## Task 5: The refusal (#3, #6, #7); gate green after

- **`gate.sh` step 1:**
  - the listing as in the shaping answer, read from its temp file;
  - when it lists anything, one `FAIL  step 1/3: …:` line with the advice, every path indented eight spaces, then exit 1, through a `fail_list` helper;
  - the banner says "no tracked file a .gitignore ignores".
- **y, restructured:**
  - force-added `base/process/draft.md` is refused, `only base/process/draft.md`;
  - two force-added files are refused together, `only` both. The gate at `00cf7ca` names one;
  - a tracked file matched only by `.git/info/exclude` passes. The gate at `00cf7ca` refuses it, which is the per-machine dependence;
  - so does one matched only by a global excludes file (`HOME` at a scratch directory);
  - a force-added `vendor/x.txt` under an ignored `vendor/`, which no step reads, passes;
  - untracked, with no pattern matching it, the draft is linted at step 2.

## Task 6: `sync-standards.sh` `project_files` (#4); gate green after

- **The code:** both `ls-files` calls write to files, git's status is checked, and a failure is `die 2` by name.
- **Tests t and u:** on a corrupt project index, `--check` and a sync each exit 2 naming the listing, with `.version` and `index.yml` unchanged (cmp against saved copies). The script at `00cf7ca` exits 128.

## Task 7: Harness (#9) and mutations

- **`upper` and `upper_run`** in m, w and u, as in Decision 6. The header gains them, the mktemp shim, and the new places tested.
- **`verification/guard-mutations.txt`:** a fresh copy of the tree as git lists it, one guard reverted or deleted, the covering test, each `UNEXPECTED` with harness exit 1.

  | Mutation | Test |
  |---|---|
  | `--is-inside-work-tree` removed from `gate.sh` | w |
  | `--is-inside-work-tree` removed from `check-index.sh` | m |
  | `--is-inside-work-tree` removed from `sync-standards.sh` | u |
  | `listed`'s `&&` broken, git's status lost | w shim |
  | step 2's `|| fail` removed | y shim |
  | the refusal's listing check removed | w corrupt index |
  | the refusal back to `--exclude-standard` | y, info/exclude |
  | the refusal's pathspec removed | y, vendor |
  | the refusal stopping at the first path | y, two files |
  | the `mktemp` check removed | w mktemp shim |
  | `project_files`' listing check removed | t |

  Script edits end here. Any later script edit reruns the mutations.

## Task 8: `verification/gate-sh-diff.txt`

`diff -u` against patchbay `main`'s `gate.sh`. The header names the allowed hunks and the skeleton hunks patchbay takes: the guard, `listed` and the temp directory, and the refusal's form and output.

## Task 9: Standards and docs text; gate green after

- **`base/process/verification-gate.md`:**
  - the first-step bullet (the guard, the refusal's scope, output and advice, the global-excludes sentence replaced);
  - the "A listing git cannot make" bullet (the temp-file form, and why: neither a pipe nor a process substitution keeps git's status);
  - "In this repository": the tests and the current transcripts, and that this spec holds the current diff.
- **`base/process/standards-sync.md`:** the root check (inside a work tree and its top), and a listing git cannot make is exit 2 by name.
- **`index.yml`:** the descriptions kept in step.
- **The gate task in `shape-spec.md`, its template, and `CLAUDE.md`:** "no tracked file a .gitignore ignores".

## Task 10: CHANGELOG and patchbay#12

- **`CHANGELOG.md`:** a "Twelfth spec" entry under `[Unreleased]`. The eleventh's entry gains short notes where this revision replaced what it says, as the ninth's entry did.
- **patchbay#12:** its body edited in place. Items 2–4 and 6 are rewritten: the guard, the temp-file `listed`, and the `.gitignore`-only refusal over `.` with its list output. The numbers are kept.

## Task 11 (FINAL): Verification gate

1. **The whole harness, one run per transcript:** `verification/gate-negative-tests.txt`, then j into `verification/ci-negative-test.txt`.
2. **`scripts/gate.sh` into `verification/gate-run.txt`**, with the date and branch first; the last thing done before hand-over.
   1. **Step 1:** `bash -n` on every shell script under `scripts/` as git lists them, at a work-tree top that is the repository root, as git says, with no tracked file a `.gitignore` ignores.
   2. **Step 2:** `pymarkdown` through `uvx` at its pin, installed as its own check first.
   3. **Step 3:** `scripts/check-index.sh`.
3. **Docs (step 4), recorded in `shape.md`:** the script headers, `CLAUDE.md`, `README.md`, the gate task and template, the standards and `index.yml`.
4. **Version (step 5):** the CHANGELOG entry. No version bump.
5. **Standards retrospective (step 6, last):**
   - the four questions against the diff;
   - `Proposals sent upstream:` in one of its four forms;
   - any base proposals presented with AskUserQuestion (multi-select, at most three to a question, "None of these" last), the approved ones filed as one issue with no attribution, and the declined ones marked.
6. **Stop and print `git status --short`.**

If any step fails, fix the cause and rerun from step 1.

## Verification summary

- **Gate green after Tasks 3, 4, 5, 6 and 9**, and at the end.
- **Each finding:** reproduced or probed first; a negative test asserting its status, its reason and that no later step was reached, with the script at `00cf7ca` shown where it had the bug; and a mutation `UNEXPECTED`.
- **The final harness:** `0 unexpected` in a transcript of one run.
