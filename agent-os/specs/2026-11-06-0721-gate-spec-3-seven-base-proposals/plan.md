# Gate spec 3: land the seven base proposals from patchbay's toolchain spec and its PR 4 revision

GitHub issue #12. Shaped 2026-11-06 in plan mode with `/agent-os:shape-spec`. The owner answered
the Step 1–5 questions and four design questions; every answer was the recommended option.
Branch `task/12-gate-spec-3-…` is clean at `57d362d` (`main`, with PR 11 merged, so #11 has landed).

## Context

patchbay's toolchain spec (`agent-os/specs/2026-11-05-2018-toolchain-ruff-mypy-pytest-full-gate/`)
and its revision after the PR 4 review (`…/2026-11-05-2057-toolchain-revision-after-pr-4-review/`)
record seven base proposals between them. PR 4 is merged, so patchbay's `origin/main` is `73a583a`,
whose tree is identical to `2121c27`. Every patchbay file is read with
`git -C ../patchbay show origin/main:<path>`, never from its working tree. The seven:

1. Pins live in the script when there is no manifest; otherwise they are exact in the dev group
   and resolved in the lockfile, and the gate runs under the locked mode.
2. The rule set may be the manifest's `[tool.*]` sections, and the file's header says which
   sections are which.
3. The runner's own version may be pinned in the manifest, and the CI action reads it from there.
4. CI for a package: setup-uv, then `uv sync --locked`, with a cache keyed on the lockfile.
5. A lockfile step's negative test: a pin edited and the lockfile left, beside the rule set's
   changed value, unparsable value and unparsable file.
6. The step that installs the toolchain fails as itself, before any tool runs.
7. The proposals heading is `###`.

Each rule is written from the shipped files, never from the proposal text.

The shaping found that this repository's own gate has the defect class proposals 5 and 6 address.
`uvx --from pymarkdownlnt==0.9.999 …` exits 1 with "No solution found when resolving tool
dependencies" (probed 2026-11-06). pymarkdown also exits 1 for a finding, and step 2 reports both
as "pymarkdown reported findings, or could not run". The standard's "a config the tool cannot
parse fails the step" also has no negative test here. The owner chose general rules with this
repository's gate changed to meet them.

Also found while shaping: the issue says the revised workflow's hosted run is recorded at the end
of the revision spec's `verification/ci-negative-test.txt`. At `73a583a` it is not; that file
still says the owner will record it. The runs exist and are read with `gh`:

- 42149183261: `pull_request` on `2121c27`, success. Its log reads `Found version for uv in
  patchbay/pyproject.toml: 0.13.7`, and the cache key is
  `setup-uv-2-x86_64-unknown-linux-gnu-ubuntu-24.04-3.12.3-<hash of uv.lock>`.
- 42150149022: `push` on `73a583a`, success.

## Decisions (owner's answers)

- **Scope:** issue #12 as written. shape.md's first Decision cites it. Out of scope: gate spec 2's
  two open proposals (the mutation check and the consuming-project issue) and issue #13.
  Visuals: none.
- **References:**
  - patchbay at `origin/main` `73a583a`: `pyproject.toml`, `uv.lock`, `scripts/gate.sh` step 2,
    the harness's h, m, n, o and j, and both specs' `shape.md` and transcripts.
  - setup-uv's `README.md` at `68559e9`, lines 26–34, 48–52 and 221–222.
  - Hosted runs 42149183261 and 42150149022, read with `gh`.
  - This repository's gate files.
- **Standards:** all five `base/process` standards go into `standards.md`. The core tier is empty
  and there is no `agent-os/product/`.
- **Proposals 5 and 6 are general, and this repository's gate changes to meet them.**
  - A step that installs a pinned tool fails as itself.
  - A rule set is proven by three cases: a changed value applied, an unparsable value refused,
    and an unparsable file refused.
  - A pin is proven applied: a lockfile pin edited without re-locking, or a script pin naming no
    published version, fails the install.
  - Here, step 2 gains an uvx-on-PATH check and an install of the pin with its own reason. New
    test z covers it, and test i gains the two refusals.
- **Proposal 6's rule goes under "One script"**, beside "Every step reports by name". Its proof
  (patchbay n, o, m's stray `[`, and z here) goes under "Every step that can fail is proven to
  fail", with proposal 5.
- **The rules are tool-neutral.** "Pinned" and "CI" speak of the manifest, the lockfile, the
  runner and its locked mode, so the standard's "names no step and no tool" stays true.
  - "In a consuming project" names the uv forms; every consuming project is a uv package.
  - "In this repository" names the no-manifest form.
- **The uv pin here stays setup-uv's `version:` input**, as the issue says. `gate.yml` is unchanged
  and caching stays off, with no lockfile to key on. shape.md records that a local run's uv is
  unpinned in this form.
- **Step 2 is not part of the shared skeleton**, which is the `cd` and usage checks, `step`,
  `fail`, `listed`, `present`, step 1 and the closing line. So no `gate-sh-diff.txt` is needed.
  patchbay meets every new rule from its own files, so no issue is opened there.

## Task 1: Save spec documentation

Create `agent-os/specs/2026-11-06-0721-gate-spec-3-seven-base-proposals/` with:

- **`plan.md`**: this plan.
- **`shape.md`**:
  - the template, with Scope citing issue #12 and Shaping answers;
  - Decisions as above, the first one citing #12;
  - the hosted-run finding;
  - Context and Standards Applied.
  - Verification Gate and Standards Retrospective are left to fill at the end.
- **`standards.md`**: the five standards in full, as they read at `57d362d`.
- **`references.md`**: the four references above, with what each proves.
- **`verification/patchbay-evidence.txt`**, recorded by command:
  - patchbay's `origin/main` sha, compared with `git ls-remote`;
  - the setup-uv README lines at `68559e9`, through `gh api`;
  - the `gh run list` rows and the `gh run view 42149183261 --log` lines for the version lookup and
    the cache key;
  - the transcript lines of patchbay tests h, m, n and o that each rule cites.

## Task 2: This repository's gate files

Each change is made with its negative test, and the gate is green before the rules are written.

- **`scripts/gate.sh`, step 2**, after the listing and its presence checks:
  1. `command -v uvx || fail 2/3 "uvx is not on PATH; …"`.
  2. `v=$(uvx --from "pymarkdownlnt==$PYMARKDOWN_VERSION" pymarkdown version) || fail 2/3 "uvx
     could not install pymarkdownlnt==$PYMARKDOWN_VERSION, the pinned version (see above)"`.
  3. `ok   pymarkdownlnt==$PYMARKDOWN_VERSION installed (pymarkdown $v)`.
  4. Then the scan, with the reason "pymarkdown reported findings, or could not read
     `.pymarkdown.yaml` (see above)".

  Also update the banner and the header paragraph, which cite the "One script" rule. The listing
  stays first, so y's "refused before pymarkdown runs" stays true.
- **`scripts/gate-negative-tests.sh`:**
  - **New test z** runs on a copy:
    - The clean copy passes, showing the install's `ok` line.
    - With `PATH=/usr/bin:/bin`, step 2 must fail by name with uvx's reason. A setup guard stops
      the harness (`die`) if uvx is found there.
    - With `PYMARKDOWN_VERSION=0.9.999` set by sed in the copy's `gate.sh` (guarded with
      `grep -qx`), step 2 must fail as the install. The assertion holds "No solution found …"
      and the install's `FAIL` line, and `3/3` is never printed.
  - **Test i** gains two cases, each through `gate.sh` and asserting pymarkdown's own message plus
    the scan's `FAIL` line:
    - `line_length: wide`, refused under `--strict-config`;
    - a stray `[` appended to `.pymarkdown.yaml`, refused as YAML.

    If pymarkdown does not refuse a case, the reason assertion marks it `UNEXPECTED`. The rule's
    wording then follows what the test shows, never the plan.
  - **Tests e, i and y** carry the new scan reason. e also asserts the install's `ok` line before
    MD009, as patchbay's h shows `ok   the locked toolchain synced`.
  - Add z to the default and `all` lists and the header's test list.
- **Run:** the gate on the tree, then `scripts/gate-negative-tests.sh` and
  `scripts/gate-negative-tests.sh j`. Iterate until there are 0 unexpected.

## Task 3: `base/process/verification-gate.md`, written from the files

Each sentence cites what verifies it, and the files are read again here, not the proposals.

- **"One script":** a new bullet for proposal 6. The step that installs the pinned toolchain runs
  before any tool the step runs, with its own reason. Install failures include:
  - a lockfile that no longer matches its manifest;
  - a manifest or lockfile the runner cannot read;
  - a package that will not build;
  - a runner that is not the pinned version;
  - a pin naming no published version;
  - a runner missing from PATH.

  Such a failure is never reported as the first tool's finding. The tools then run under the
  locked mode, a check the install has passed. Sources: patchbay `gate.sh` step 2, and this
  repository's step 2 as shipped.
- **"Pinned":**
  - Bullet 1, rewritten for proposal 1. Each pin is exact, in one place, with its publish date.
    With no manifest, the pin is in the script and runs through a runner that installs nothing
    into the project. With a manifest, the pin is in its dev group and resolved in the lockfile,
    and the gate runs under the locked mode, so an edit without re-locking fails and the lockfile
    is never rewritten. A type checker or test runner needs the project installed. Sources:
    patchbay `pyproject.toml` `[dependency-groups] dev`, `uv.lock` and test n; here,
    `PYMARKDOWN_VERSION`.
  - Bullet 2 for proposal 2. The rule set is a versioned config file, or the manifest's tool
    sections. In the second case those sections are the gate's file, the rest of the manifest
    changes in any spec, and the header says which is which. Sources: patchbay `pyproject.toml`'s
    header, its `CLAUDE.md` gate-files list, and test m.
  - A runner bullet for proposal 3. Where the manifest can pin the runner and the runner refuses
    any other version on every command, the version is written there once, and a local run and CI
    use the same runner. Sources: patchbay `[tool.uv]` and test o.
  - The "key not refused / changed value" sentence moves into the negative-test bullet below.
- **"Every step that can fail is proven to fail":** a new bullet for proposal 5 and the proof of 6.
  - A rule set is proven read by its changed value, its unparsable value and its unparsable file:
    patchbay m, and i here.
  - A pin is proven applied: patchbay n for a lockfile pin, z here for a script pin, and patchbay
    o for a runner pinned in the manifest.
  - The install's own reasons are shown, and the first tool's failing case shows the install
    passed first: patchbay h, and e here.
- **"CI"**, for proposals 3 and 4:
  - "Install the runner the script already assumes" gains "and, under a lockfile, the locked
    toolchain as its own step from the project's directory". That step checks nothing the
    script's install does not. Sources: patchbay `gate.yml`, its gate step 2, and test j.
  - The runner's version comes from the action's input, or the action reads it from the manifest
    and takes no input. A failed lookup is loud: the action would install the latest runner, which
    then refuses itself. Sources: setup-uv's README at `68559e9`, run 42149183261's log, and test o.
  - "Caches nothing" becomes "nothing but what a key that changes with the lockfile holds". The
    rule is written from the hosted key, which includes the platform and the lock's hash.
- **"The gate's own files":** the rule-set config may be a manifest's tool sections.
- **"In this repository":**
  - step 2's uvx check, install and scan;
  - the no-manifest form: the pin in the script, `.pymarkdown.yaml`, uv as setup-uv's input, no
    cache because there is no lockfile;
  - "nineteen for the gate's scripts (… w, x, y and z)", and i's three cases;
  - the current transcripts' home becomes issue #12.
- **"In a consuming project":** the uv forms, from patchbay's files.
  - `[dependency-groups] dev` pins, exact and dated, in `uv.lock`, run with `uv run --locked`.
  - The `[tool.*]` sections are the gate's, and the header says so.
  - `[tool.uv] required-version`.
  - Step 2 opens with `uv sync --locked`, with its own reason.
  - The workflow: setup-uv by commit, with `working-directory` and no `version`, the cache on with
    `cache-dependency-glob: uv.lock`, then a `uv sync --locked` step, then the gate.
  - No standard that has not shipped is named, including the toolchain standard (#4).

## Task 4: The proposals heading (proposal 7) and the Docs edits that follow

- `base/process/standards-retrospective.md:73`: `##` becomes
  `### Standards retrospective (proposed, base)`, matching its own template at line 126. Nothing
  else changes.
- `CLAUDE.md:70`, and `.claude/commands/agent-os/shape-spec.md:100` and `:206`, get the same fix.
  Line 206 is gate-task text, so it changes in this gate spec, before the final harness run.
- `shape-spec.md`'s gate-task step 2 and its template's Verification Gate paragraph, and
  `CLAUDE.md`'s Specs bullet, say that step 2 installs the pinned pymarkdown as its own check, as
  the script does.

## Task 5: `index.yml`

Rewrite the `process/verification-gate` description for the new rules:

- install as itself;
- pins in the script or in the lockfile, run locked;
- rules in a config or in the manifest's tool sections;
- the runner pinned once;
- CI installing the runner and the locked toolchain, with a cache only on a lockfile key;
- rule sets and pins proven by negative tests.

Keep it one sentence with no `: ` or ` #`. Step 3 must agree.

## Task 6: `CHANGELOG.md`, under `[Unreleased]`

- **Added:** "Seventh spec, `…/2026-11-06-0721-gate-spec-3-seven-base-proposals/` (issue #12), the
  third gate spec", with sub-bullets for `verification-gate.md` (proposals 1–6, "In this
  repository" and "In a consuming project") and for the harness (z and i's cases).
- **Changed:** `scripts/gate.sh` step 2; `CLAUDE.md` and `shape-spec.md`; `index.yml`. **The
  `standards-retrospective.md` heading fix gets its own line.**

## Task 7 (FINAL): Verification gate

1. `bash -n` on every shell script under `scripts/` as git lists them, at a work-tree top that is
   the repository root.
2. Under the new step 2: uvx on PATH, then the pinned pymarkdown installed, then pymarkdown over
   the `.md` files under `base/` and `README.md` as git lists them, with no findings.
3. `scripts/check-index.sh`: `index.yml` equals the tracked files under `base/`, and the symlink is
   in place.
4. **Docs**, recorded in `shape.md`. Read back:
   - `verification-gate.md` sentence by sentence against the file each cites;
   - the `gate.sh` and harness headers against their code;
   - `.pymarkdown.yaml` and the `gate.yml` header (both still true);
   - `README.md` (names no step);
   - `CLAUDE.md` and `shape-spec.md`;
   - the "nineteen" count against the default test list;
   - no line over 100 columns in `base/`, `CLAUDE.md` or `CHANGELOG.md`.

   Also grep outside `agent-os/specs/` for the stale wording: "could not run", "pinned in the
   script" with no condition, "caches nothing", `## Standards retrospective (proposed`.
5. **Version:** the `[Unreleased]` entries. There is no version to bump.
6. **Standards retrospective**, last, from the shipped diff. Rules this spec teaches beyond the
   seven are proposals under `### Standards retrospective (proposed, base)`; otherwise "no
   changes". Its edits are listed separately when reporting.

Gate files change in Tasks 2 and 4, so every negative test runs after the last of those edits.
`verification/gate-negative-tests.txt` holds every test but j, and `verification/ci-negative-test.txt`
holds j. Each header names the date and branch, and each last line reads `N runs, 0 unexpected`.
`shape.md` records the results, the transcripts and the hosted-run note, which the owner records
after the push.

Then run `scripts/gate.sh` on the tree as the last act, writing `verification/gate-run.txt` with
the date and branch on its first line. Run it under `bash -c` so `${PIPESTATUS[0]}` is bash's.
Then stop and print `git status --short`. Nothing is staged, committed, pushed or opened as a PR,
and no attribution is added anywhere.

## Files

- **Modified:** `scripts/gate.sh`, `scripts/gate-negative-tests.sh`,
  `base/process/verification-gate.md`, `base/process/standards-retrospective.md`, `index.yml`,
  `CLAUDE.md`, `.claude/commands/agent-os/shape-spec.md`, `CHANGELOG.md`.
- **New:** the spec folder.
- **Unchanged and verified:** `.github/workflows/gate.yml`, `.pymarkdown.yaml`,
  `scripts/check-index.sh`, `scripts/sync-standards.sh`, `README.md`.

# Revision after the review of PR 14 (2026-11-06)

Shaped 2026-11-06 in plan mode with `/agent-os:shape-spec`; the first round's plan (issue #12) is
above, and this revision is appended by its Task 1. Branch `task/12-gate-spec-3-…`, clean at
`2138d96`, which is PR 14's head. The hosted gate run 42227921959 (`pull_request`, `2138d96`) succeeded.

## Context

The owner's review comment on PR 14 lists 12 findings against `2138d96`: 4 to fix before merge and 8
minor. Each was checked against the files while shaping, and every one holds. This plan addresses all
12, in this spec's own folder, as the PR 11 revision of gate spec 2 did:

- a "Revision after review" section in `shape.md`;
- the dispositions tabled below, copied into `plan.md`;
- every transcript rerun.

The owner chose four of the dispositions, each time the recommended option. The others follow the
review's own suggestion.

## Dispositions

| # | Finding | Disposition |
|---|---------|-------------|
| 1 | The tool pins sit in `[dependency-groups]`, which the standard gives to the package | **Owner:** the pins of the tools the gate runs, and what the lockfile resolves for them, are gate files; the group's other entries stay the package's. Changes go in "Pinned" bullets 1 and 3, "The gate's own files" and "In a consuming project". A new patchbay issue covers its `pyproject.toml` header and `CLAUDE.md`. |
| 2 | `shape.md:109`'s gate paragraph is stale | Rewrite it as the template now reads: the pin is installed through `uvx` as its own check first. |
| 3 | z's header claims an ok-line order and "3/3 never printed", and neither is checked | **Owner:** assert both, for every `gate.sh` failure (see Task 2). |
| 4 | The pinned invocation is written out twice | Build it once, `pmd=(uvx --from "pymarkdownlnt==$PYMARKDOWN_VERSION" pymarkdown)`, and use it in both calls. |
| 5 | j's replay prints its lines out of order, and nothing tracks it | **Owner:** fix here: the replay runs `python -u`, as patchbay's harness does. |
| 6 | "Refuses any other version on every command" overstates uv | Probe it with uv 0.13.7. Write "on every command that reads the project" in "Pinned", and tighten "CI"'s "at its first command" the same way. |
| 7 | z's unpublished-pin case needs the network and uv's own wording | **Owner:** assert only the gate's FAIL line naming 0.9.999. The header no longer says this case needs the network. |
| 8 | The install check runs `pymarkdown version`, so a startup crash reads as "could not install" | Reword the reason: "…, the pinned version, or pymarkdown would not start (see above)". Write the general rule as "before any tool checks the tree". `pymarkdown version` checks nothing, and uvx has no install-only form. |
| 9 | i3's awk filter can swallow a line | End the elision at the first unindented line, with `next` on the `Traceback` line, and add an `END` that prints the note. |
| 10 | `bash` is missing from z's precondition loop | The loop becomes `bash dirname git sort head grep`, the commands steps 1 and 2 use; the header names them. |
| 11 | The heading "runs the same script and nothing else" reads tighter than its body | Reword to "runs the same script, and checks nothing the script does not"; the `index.yml` description follows. |
| 12 | Two uvx resolutions per run | Folded into 4 and accepted: each call resolves from the warm cache. Recorded, not changed. |

## Task 1: Save spec documentation (revised in place)

- **`plan.md`**: append "Revision after the review of PR 14", containing this Context and the table above.
- **`shape.md`**:
  - after Decisions, add "Revision after review (2026-11-06)": a summary of the review, the four owner
    choices, and the decisions that extend the ones above;
  - fix the Verification Gate paragraph (finding 2).

  Results, Docs, Version and the Standards Retrospective are rewritten at the end, from the revised diff.

## Task 2: Gate files (`scripts/gate.sh`, `scripts/gate-negative-tests.sh`)

- **`gate.sh` step 2 (findings 4 and 8)**:
  - define `pmd=(…)` once, then use `v=$("${pmd[@]}" version) || fail 2/3 "uvx could not install
    pymarkdownlnt==$PYMARKDOWN_VERSION, the pinned version, or pymarkdown would not start (see above)"`
    and `"${pmd[@]}" --strict-config --config .pymarkdown.yaml scan "${md[@]}"`;
  - update the header's install paragraph to match.
- **Harness `check` (finding 3)**: two new assertions.
  1. Text given to `check` is asserted whatever the expected status. A run expecting 0 can now name
     lines its output must hold, in order.
  2. A new helper, `later <n> <file>`, uses awk over `== K/M` banners to find any banner past step n.
     `check` marks the run `UNEXPECTED` ("a step after step N was reached") when either holds:
     - the reason names `FAIL  step N/M` and the output has a banner past step N;
     - the reason is `gate.sh`'s usage line or its cd line (N = 0) and the output has any banner.

  This turns into checks the "never printed" claims in e, f, i, w and y; the "no step banner" claims
  in x; z's claims; and j2's claims. It also covers the old-script runs in w and y, which stop where
  their reasons say.
- **Test z (findings 3, 7 and 10)**:
  - The clean run is written in the same form as i's first case: the output goes to `run.raw`, then
    `shown`, then `check 0 "$got" $'ok   pymarkdownlnt==\nok   no findings' …`.
  - The precondition loop adds `bash` and `dirname`.
  - The unpublished-pin case asserts only `FAIL  step 2/3: uvx could not install
    pymarkdownlnt==0.9.999, the pinned version, or pymarkdown would not start (see above)`.
  - Update z's header and notes, and the "Needs" line: z needs only what every `gate.sh` test needs.
- **Test i3 (finding 9)**: the awk filter as tabled.
- **j (finding 5)**: `uv run --quiet --no-project --with pyyaml python -u -`.
- **Header**: lines 2–16 say that a failure's later steps are checked as never reached, and that a
  passing run may name its lines. Update `check`'s comment line too.
- **Run**: the gate on the tree, then `scripts/gate-negative-tests.sh` and `scripts/gate-negative-tests.sh
  j`, iterating until both report 0 unexpected.

## Task 3: Show the new assertions discriminate (`verification/review-mutations.txt`)

This follows gate spec 2's `reason-assertion-mutations.txt`. Each mutation is made in a scratch copy of
the repository's listed files, outside the tree, and the harness runs from that copy:

1. **The gate runs every step and exits 1 at the end.** `fail` sets a flag instead of exiting, and the
   closing line exits with the flag. Then run e and f: each still exits 1 with its FAIL line, and only
   the new banner check marks it `UNEXPECTED`.
2. **The install check deleted.** Run z: the unpublished pin now fails as "pymarkdown reported
   findings…", and the gate-line-only assertion marks it `UNEXPECTED`.

## Task 4: `base/process/verification-gate.md` (findings 1, 3, 6, 8 and 11)

- **Probe (finding 6)** in the scratchpad, with uv 0.13.7 and a `pyproject.toml` declaring
  `required-version = "==0.1.0"`. Run `uv --version`, `uv tool list`, `uv lock`, `uv sync` and
  `uv run true`, and record the commands and output as a new section of
  `verification/patchbay-evidence.txt`. The wording follows what the probe shows.
- **"One script"**: the install rule reads "before any tool checks the tree" (finding 8).
- **"Pinned"**:
  - bullet 1: the pins of the tools the gate runs are gate files: in the script, as part of it; in a
    manifest, the development group's tool pins and what the lockfile resolves for them. The group's
    other entries are the project's.
  - bullet 2: "on every command that reads the project".
  - bullet 3: the tool sections, with those pins, are the gate's, and the rest of the manifest is the
    project's.
- **Harness bullet**: a run that fails at a step also shows no later step reached, and a passing run
  may name its lines.
- **"CI"**: the heading is reworded (finding 11), and the pinned runner's refusal comes at "its first
  command that reads the project, the locked install".
- **"The gate's own files"**: add the tool pins, in the script or in the manifest's development group
  with their lockfile resolution.
- **"In this repository"**: the install check starts `pymarkdown version`, so a pymarkdown that will
  not start fails there, by the same reason.
- **"In a consuming project"**:
  - `[tool.*]`, plus the tool pins in `[dependency-groups] dev` with what `uv.lock` resolves for them,
    are the gate's;
  - `[project]`, `[build-system]` and the rest of `[dependency-groups]` are the package's;
  - drop "as the file's header says", since patchbay's header says otherwise until its issue lands.

## Task 5: Docs follow-through

- **`index.yml`**: the `process/verification-gate` description gets "the tool pins among the gate's
  files" and "CI runs the same script and checks nothing it does not". It keeps no `: ` and no ` #`.
- **`CHANGELOG.md`**: revise the Seventh spec entry to the shipped state, with one sentence naming
  the PR 14 review and the patchbay issue. Changed lines for `gate.sh` and the harness reflect what
  shipped. The heading-fix line stays its own.
- **`shape-spec.md` (a gate file)**: change it only if its step-2 text stops being true. Check
  `CLAUDE.md` the same way.

## Task 6: patchbay issue (finding 1, the owner's choice)

Open it after Task 4's text is final:
`gh issue create -R fromtheoutfit/patchbay`, with no attribution.

- **Title:** "Gate spec: the dev group's tool pins are gate files (patchbay-standards PR 14)".
- **Body**:
  - the contradiction: the `pyproject.toml` header says `[dependency-groups]` is the package's, its
    own dev-group comment says pins change only in the gate's spec, and `CLAUDE.md` gate-files lines
    85–86 agree with the header;
  - the revised rule;
  - that hypothesis and pre-commit need classifying;
  - the `[tool.uv]` comment's "any other uv refuses to run here" (finding 6's overstatement).

  All of it is for patchbay's own gate spec after it syncs past PR 14. Record the issue number in
  `shape.md` and `CHANGELOG.md`.

## Task 7 (FINAL): Verification gate

1–3. Run `scripts/gate.sh`: `bash -n` under `scripts/`; uvx on PATH, the pinned pymarkdown
installed, then pymarkdown over `base/` and `README.md` as git lists them; then `check-index.sh`.

Gate files change in Task 2, so every negative test runs after the last edit to them.
- `verification/gate-negative-tests.txt` holds every test but j; `verification/ci-negative-test.txt`
  holds j.
- Each file has its date and branch in the header, and `N runs, 0 unexpected` on its last line.
- `ci-negative-test.txt` also records PR 14's hosted run on its first head: 42227921959,
  `pull_request`, `2138d96`, success. The revision's own hosted run is the owner's to record after
  the push.

4. **Docs**, recorded in `shape.md`:
   - every sentence changed in `verification-gate.md`, read against the probe, patchbay's files and
     this repository's scripts;
   - the `gate.sh` and harness headers against their code;
   - `CLAUDE.md` and `shape-spec.md`;
   - a grep outside `agent-os/specs/` for the old reason, "on every command", "and nothing else" and
     "there is no version";
   - no line over 100 columns.
5. **Version**: the revised `[Unreleased]` entries. There is no version to bump.
6. **Standards retrospective**, last, from the revised diff against `main`: "no changes", or
   proposals under `### Standards retrospective (proposed, base)`. Its edits are listed separately.

Last act: run `scripts/gate.sh` under `bash -c` into `verification/gate-run.txt`, with the date and
branch on its first line, then print `git status --short`. Nothing is staged, committed or pushed,
and nothing is added to PR 14. The only outward action is the patchbay issue the owner chose.

## Files

- **Modified:**
  - `scripts/gate.sh`, `scripts/gate-negative-tests.sh`;
  - `base/process/verification-gate.md`;
  - `index.yml`, `CHANGELOG.md`;
  - the spec folder: `shape.md`, `plan.md` and `verification/*`, with `review-mutations.txt` new.
- **Unchanged unless the Docs step shows otherwise:** `CLAUDE.md`, `.claude/commands/agent-os/shape-spec.md`,
  `.github/workflows/gate.yml`, `.pymarkdown.yaml`, `base/process/standards-retrospective.md`.
