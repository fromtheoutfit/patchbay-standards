# Gate spec 4: issues #17, #19 and #20 together

## Context

Three open issues carry owner-approved base proposals:

- **#17:** six proposals from this repository's own specs.
- **#19:** one, a kept transcript holds one run.
- **#20:** from patchbay's gate specs, revised 2026-11-07. It carries 1 and 3–8; 2 is withdrawn.

All three edit `base/process/verification-gate.md`. #17 and #20 also edit `standards-sync.md`, and #20 edits `toolchain.md`. #20 changes this repository's gate skeleton and `sync-standards.sh:97`. #17's 4 and 5 and #19 are rules about the harness. Landing them apart would rewrite the same paragraphs three times and rerun the harness three times, so one gate spec carries them.

Every rule is written from shipped code. That means this repository's scripts after this spec changes them, and patchbay `main` (`3f910d8`, whose tree is identical to #9's head `799cfde`) for patchbay's cases. Where a proposal and the code disagree, the code wins and `shape.md` says so.

Branch: `task/17-gate-spec-4-land-six-base-proposals-from-this-repositorys-specs-verification-gatemd-standards-syncmd`.

No stage, commit, push or PR by the agent.

## Shaping answers (owner, 2026-11-07)

- **Scope:** as described: one spec folder, in the sequence the owner gave, with `gate-sh-diff.txt` against patchbay `main`.
- **Visuals:** none.
- **References:** as proposed (see `references.md` below).
- **Standards:** `process/verification-gate`, `process/standards-sync`, `process/standards-retrospective`, `process/ownership`, `process/standards-index`.
  - `python/toolchain` is recorded as Core, not applying: there is no package here. It is edited as feature work.
- **The -ci refusal:** whole tree, in step 1 of the shared skeleton, unconditional.
- **`check-index.sh`:** all three fixes, with tests: the root guard, `sort -u`, and a FAIL line naming the listing when git cannot list.
- **#20-5:** a rule only. The sync's commit adds the CHANGELOG entry; the script keeps its four writes.
- **#17-4:** the fixture rule plus a rerun trigger. No fixture rewrite.
- **#17-6 applied here:** the agent files one patchbay issue at the end, with no attribution.

## Decisions for shape.md (first one cites all three issues)

1. **#17, #19 and #20 are one gate spec.** The reason is the overlap in Context above. Proposals that need gate files changed:
   - #20: 1, 6 and 7.
   - #17: 4 and 5, harness only. 5's harness half (`only`) already shipped in PR 18's revision; this spec writes the standard text.
2. **Code wins over the proposal text.** Record each disagreement:
   - **#20-1** restated binds only steps that keep the second form. The owner chose an unconditional whole-tree refusal in step 1, so the standard is written from step 1 as shipped.
   - **#20-5** says "the sync also writes". The script is unchanged, so the rule is that the sync's commit carries the entry.
   - **#20-6** names `gate.sh` only. `check-index.sh` has the same guard and gets the same fixes (owner).
   - **#20-4's command lines** are checked word for word against patchbay `main`'s `gate.sh`.
3. **New cases fold into existing letters** (w, y, m, h, u), since a–z are taken. The harness gains `times <n> <line>`, an exact count, as patchbay's has. That is a change to the harness's assertions, so it gets #17-2's mutation proof.
4. **Every guard this spec adds has a mutation proof:** the guard reverted on a scratch copy, the covering cases `UNEXPECTED`, harness exit 1.
5. **Tool-behaviour rules are rerun as probes at the pins before they are written.**
6. **Global excludes count in the -ci refusal** (`--exclude-standard`). A tracked file matched by a developer's global excludes fails locally and not in CI. The probe shows it, and it is recorded as a known limit, as `--others` already is for untracked files.

## Task 1: Save spec documentation

Create `agent-os/specs/2026-11-07-1428-gate-spec-4-skeleton-listing-harness/`. It was saved at 14:28.

- `plan.md`: this plan.
- `shape.md`:
  - Core Architecture: `python/toolchain` not applied.
  - Scope, Shaping answers, Decisions, Context and Standards Applied.
  - Verification Gate, filled in Task 9.
  - Standards Retrospective, filled last.
- `standards.md`: the five standards in full as they read at `11ceffd`.
- `references.md`:
  - patchbay `main`: `scripts/gate.sh` (skeleton, step 5 refusal) and harness tests g, p, q and r.
  - The revision's `verification/` files: `probes.txt`, `reason-assertion-mutations.txt` and `gate-sh-diff.txt`.
  - This repository's mutation transcripts: the 2019 spec's `reason-assertion-mutations.txt` and the 1244 spec's `only-assertion-mutations.txt`.
- No `visuals/`.

## Task 2: Probes → `verification/probes.txt`

Read-only evidence, gathered before any gate file is edited. Each probe runs on a scratch copy, its setup is shown before its result is read, and the versions are printed: git 2.54, bash 3.2.57, uv 0.13.7.

1. **git and bash, here:**
   - a path at stages 1–3 is listed 3× by `ls-files --cached`, and once after `sort -zu`;
   - entered in upper case, `pwd -P` keeps the typed case and differs from `--show-toplevel`, while `--show-cdup` is empty. A subdirectory gives `../`, and so does a copy without `.git` inside another repository;
   - on a corrupt index, `ls-files` exits 128, and the `… | sort -zu && printf '\0'` reader sees no empty record;
   - `ls-files -z --cached --ignored --exclude-standard` lists:
     - a tracked file matched by `.gitignore`, by `.git/info/exclude`, and by `core.excludesFile`;
     - not an untracked ignored file;
     - not a file whose pattern is negated (`!`).
   - `rev-parse --show-cdup` still works on a corrupt index.
2. **pytest 9.2.0, on `git archive 3f910d8` of `../patchbay` in scratch** (git-inited, `uv sync --locked`), for #17-3 and #20-8:
   - an unknown key in `[tool.pytest.ini_options]` gives exit 4 under `--strict-config`, and a warning with exit 0 without it;
   - an ignored `conftest.py` in a collected directory is loaded, `--ignore` or not, and so is one at the root;
   - an ignored root `pytest.ini` is read over `pyproject.toml`. If it is, step 5's `.py`-only refusal misses it: that is an item for the patchbay issue and a retrospective note, not a change to the rule text.
3. **ruff 0.17.4 and mypy 2.4.1, same export**, for #20-1 and #20-4:
   - the walk under `respect-gitignore` skips a force-added file `.gitignore` matches, and so does `exclude_gitignore`;
   - given git's list, both read it;
   - in a linked worktree, a module hidden only by `info/exclude`: git's list hides it, and mypy under `exclude_gitignore` names it.

## Task 3: Skeleton fixes and negative tests (gate green after)

- **`scripts/gate.sh`, matching patchbay `main`'s skeleton:**
  - **Root guard:** `cdup=$(git rev-parse --show-cdup 2>/dev/null) && [ -z "$cdup" ] || fail 1/3 "not a git work tree rooted at $root; …"`, with the message unchanged.
  - **`listed`:** `git ls-files -z --cached --others --exclude-standard -- "$@" | LC_ALL=C sort -zu && printf '\0'`.
  - **Readers of `listed`, steps 1 and 2:** each stops at the empty record. Without it, the step fails with "git could not list the files under scripts/ (see above)", or "git could not list the .md files under base/ and README.md (see above)" for step 2.
  - **Header:** the listing paragraph says each path is listed once, the listing ends in an empty record, and the root guard asks git.
- **`scripts/check-index.sh`:**
  - **Root guard** at line 27: `--show-cdup` empty, with the same FAIL text.
  - **Listing:** both `ls-files` calls are guarded. `FAIL  git could not list the files under base/ (see above)`, exit 1. Then `sort -u`.
  - **Header** updated.
- **`scripts/sync-standards.sh:96–99`:** `--show-cdup` empty, with the same die text. The header's usage line says the root is asked of git.
- **Harness `scripts/gate-negative-tests.sh`:**
  - **`NEGUP`, and `shown()`**: the copy's path in upper case, and shortened to `<COPY X>`.
  - **`times <n> <line>`** (patchbay's form).
  - **A git shim on `PATH` in `$NEG/shim`**, refusing a call that matches `$GATE_TEST_REFUSE` (patchbay's r).
  - **Old scripts at `11ceffd`, shown failing as they were:**
    - **w:**
      - in upper case, the new gate passes all three steps (case-insensitive filesystems only; otherwise skipped with a note), and the old one fails at step 1;
      - `scripts/conflict.sh` at stages 1–3 is listed once (`times 1`), against `times 3` for the old gate;
      - on a corrupt index, step 1 fails naming its listing, where the old gate says "git lists no file under scripts/";
      - with the shim refusing ` -- scripts `, step 1 fails by name. After Task 4 the corrupt index fails at the -ci listing first, so this is the run that keeps covering the scripts listing.
    - **y:** with the shim refusing ` -- base README.md `, step 2 fails by name.
    - **m:**
      - in upper case, `check-index.sh` passes, and the old one fails;
      - on a corrupt index, it fails naming the listing, where the old one exits 128 bare.
    - **h:** `base/process/conflict.md`, indexed, at stages 1–3, passes. The old script reports it missing.
    - **u:** in upper case, `sync-standards.sh --check` passes, and the old one refuses it with exit 2.
  - **Harness header:** the test list and these descriptions.
- **Run:** `scripts/gate-negative-tests.sh w y m h u x z`, kept on the console only, then `scripts/gate.sh` must be green.

## Task 4: Tracked-and-ignored refusal in step 1 (gate green after)

- **`gate.sh` step 1, after the root guard:** a reader over `git ls-files -z --cached --ignored --exclude-standard && printf '\0'`.
  - The first path listed fails the step: `FAIL  step 1/3: <path> is tracked but git ignores it; stop ignoring it (a ! pattern) or untrack it`, with the final wording settled in the code.
  - With no empty record: "git could not list the tracked files git ignores (see above)".
  - The banner and header say so.
- **y, restructured:**
  - the ignored draft still passes, and the a5f88ae demo is kept;
  - force-added, step 1 refuses it by name, exit 1, `2/3` never printed;
  - the old gate at `11ceffd` on the same: step 1 passes, and step 2 lints it, the state the refusal closes;
  - tracked and matched only by `.git/info/exclude`: refused;
  - untracked with its `.gitignore` line removed: listed, and step 2 fails on its findings, read once git lists it.
- **w:** with the shim refusing ` --ignored `, step 1 fails naming the -ci listing. A corrupt index now fails at the -ci listing first, which is asserted.
- **Run:** w, y, z and x, then the gate must be green.

## Task 5: Harness rules (gate green after)

- **#19, in the harness header:** a kept transcript holds one run and ends on its count. An earlier run kept as evidence goes in a file of its own (patchbay's sentence).
- **#17-5, exclusive check:** `only` is already here, used by g and k's "alone" cases. Confirm that no new case claims "alone" without `only`. There is no code change.
- **#17-2 and Decision 4, mutation proof → `verification/guard-mutations.txt`.** Each mutation is a fresh copy of the tree as git lists it, outside the repository, with one guard reverted; the covering tests are then run, and each must come back `UNEXPECTED`, harness exit 1. The mutation, shown by `sed`, the test and the result:

  | Mutation | Test run | Expected result |
  |---|---|---|
  | M1: gate root guard back to the string comparison | w | the upper-case run |
  | M2: `listed` without `-u` | w | `times 1` found 3; this is the proof for `times` |
  | M3: step 1's empty-record check removed | w | the shim run |
  | M4: step 2's empty-record check removed | y | the shim run |
  | M5: the -ci refusal removed | y | the force-added run |
  | M6: the -ci empty-record check removed | w | the shim run |
  | M7: `check-index.sh` root guard back | m | |
  | M8: `check-index.sh` `sort` without `-u` | h | |
  | M9: `check-index.sh` listing guard removed | m | |
  | M10: `sync-standards.sh` root check back | u | |

  Script edits end here. Any later script edit reruns the mutations.

## Task 6: `verification/gate-sh-diff.txt`

`diff -u` of this repository's shipped `gate.sh` against patchbay `main`'s. The header names two kinds of hunk:

- **Allowed:** step lists, pins and paths.
- **The skeleton hunk patchbay takes after its sync:** the -ci refusal. Patchbay's earlier deviation hunks (`--show-cdup`, `-u`, the empty record) now match.

## Task 7: Standards text (gate green after)

Each change is written from the shipped files above.

- **`base/process/verification-gate.md`:**
  - **"One script", the listing bullet:**
    - root guard asked of git, comparing no paths (#20-6);
    - `listed` with `sort -zu`, each path once, ending in the empty record; every reader fails by name without it (#20-6);
    - the first step refuses a tracked file git ignores, so every later step sees one set. This is written unconditionally (#20-1, owner);
    - the missing-file clause binds the git's-list form (#20-3);
    - the refusal form: a step whose tool walks a directory and reads files no list holds back first refuses, by name, what git ignores there that the tool would read (#20-8, verified against patchbay step 5 and its test q).
  - **"Every step that can fail is proven to fail":**
    - some tools refuse an unknown key (pytest under `--strict-config`, exit 4) and some do not (pymarkdown). The changed value stays the proof that the file is read (#17-3);
    - fixtures: a case whose expectation depends on what a copied directory holds sets the whole of it, and a case needing one file dies by name without it. A spec that adds, removes or renames a file under a directory the harness copies reruns the harness (#17-4);
    - a case whose reason is all a step reports asserts that nothing else is reported (`only`) (#17-5);
    - a change to the harness's assertions is shown to discriminate by mutation, with its transcript in `verification/` (#17-2);
    - a kept transcript holds one run and ends on its count (#19).
  - **"Every spec keeps its green run":** a spec that adds a file under `base/` records the tree's run, which step 3 fails naming the file, beside a green run on a scratch copy with the file git-added, both in `gate-run.txt`. The hand-over says the owner's `git add` turns it green (#17-1).
  - **"In this repository" and "In a consuming project":**
    - step 1's root guard and refusal, the `check-index.sh` guard and the tests named;
    - the current transcripts live in this spec;
    - this spec holds the current diff, and patchbay takes the -ci hunk.
- **`base/process/standards-sync.md`, "Pinned, not tracking":**
  - the sync's commit changes the synced files and `CHANGELOG.md`, which gains one `[Unreleased]` entry naming the old and new commit the script reports (#20-5, rule only);
  - a base change that leaves a consuming project's gate files out of step names the project and the work in this repository's CHANGELOG entry, and an issue in that project records it for the gate spec after its sync (#17-6);
  - the root check is asked of git, and a root typed in another case is the root (#20-7, test u).
- **`base/python/toolchain.md`:**
  - **"The gate's tool steps":**
    - `uv run --locked ruff format --check -- <the .py and .pyi files git lists>`;
    - `ruff check -- <same>`;
    - `mypy -- <those under src/ and tests/>`, each path checked on the disk;
    - then `pytest`, after the refusal.
  - **"mypy":** `files` is what a bare run walks, and there is no `exclude_gitignore`, and why (#20-4).
  - **The header and "In this repository":** these rules were re-read at patchbay `3f910d8` and probed again.
- **`index.yml`:** the descriptions of these three standards kept in step, with no `: `.
- **Gate task text:** step 1 of the gate task in `.claude/commands/agent-os/shape-spec.md` and its `shape.md` template paragraph, and the matching phrase in `CLAUDE.md`, gain "no tracked file git ignores". This is a gate file, changed in the gate's own spec.

## Task 8: CHANGELOG and the patchbay issue

- **`CHANGELOG.md`:** an "Eleventh spec" entry under `[Unreleased]`, `### Added`, naming #17, #19 and #20:
  - the `base/` lines, and the gate files changed;
  - the sync-commit entry rule from #20;
  - patchbay and its work, per #17-6, with the issue number.
- **The patchbay issue:** filed with `gh issue create --repo fromtheoutfit/patchbay`, with no attribution. It records the work for patchbay's gate spec after it syncs to this change, each item verified against this spec's files:
  - its sync commit carries the CHANGELOG entry, and its CHANGELOG header is revised;
  - step 1 takes the -ci hunk, and p's force-added case moves to step 1;
  - g's upper-case run now passes step 6;
  - `gate-sh-diff` is re-recorded;
  - the gate task and `CLAUDE.md` step 1 text;
  - any `pytest.ini` gap Task 2 finds.
- **Its number** goes into CHANGELOG and `shape.md`.

## Task 9 (FINAL): Verification gate

1. **Rerun the whole harness**, one run per transcript:
   - `scripts/gate-negative-tests.sh` → `verification/gate-negative-tests.txt`, ending `N runs, 0 unexpected` / `harness exit=0`;
   - `scripts/gate-negative-tests.sh j` → `verification/ci-negative-test.txt`.
2. **Gate steps 1–3:** `scripts/gate.sh` → `verification/gate-run.txt`. The first line gives the date and branch; this is the last thing done before hand-over. One transcript: no file is added under `base/`.
   1. **Step 1:** `bash -n` on every shell script under `scripts/` as git lists them, at a work-tree top that is the repository root, with no tracked file git ignores. Every script must parse, and any other file fails by name.
   2. **Step 2:** `pymarkdown` through `uvx`, pinned in `gate.sh`, rules in `.pymarkdown.yaml`. The pin is installed as its own check first, then the `.md` files under `base/` and `README.md` as git lists them are linted, with no findings.
   3. **Step 3:** `scripts/check-index.sh`: `index.yml` lists exactly the tracked files under `base/`, and the index symlink holds.
3. **Docs (step 4), recorded in `shape.md`:**
   - the headers of every changed script;
   - `CLAUDE.md`, `README.md` and the `shape-spec.md` gate task and template;
   - the three standards and `index.yml`.
4. **Version (step 5):** the CHANGELOG entry. No version bump.
5. **Standards retrospective (step 6, last):**
   - the four questions against the diff;
   - deviations recorded;
   - `Proposals sent upstream:` in one of its four forms;
   - any base proposals presented with AskUserQuestion (multi-select, at most three to a question, "None of these" last), the approved ones filed as one issue on `patchbay-standards` with no attribution, the number written beside each, and the declined ones marked.
   - The retrospective's own edits are listed apart from the feature's.
6. **Stop and print `git status --short`.**

If any step fails, fix the cause, never bypass it, and rerun from step 1.

## Verification summary

- **Gate green after each of Tasks 3, 4, 5 and 7**, and at the end.
- **Every new guard:** a negative test that asserts its status, its reason and that no later step was reached, with the old script shown failing, plus a mutation `UNEXPECTED`.
- **The final harness:** `0 unexpected` in a transcript of one run.
- **Probes** at the pins for every rule about a tool's behaviour.
