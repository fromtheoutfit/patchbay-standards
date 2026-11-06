# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Consuming projects pin `base/` to a commit; the `base/` lines in each entry are what a sync would
bring in.

## [Unreleased]

### Added

- Tenth spec, `agent-os/specs/2026-11-06-1244-revision-after-pr-18-review/`: the owner's review of
  PR 18 (the ninth spec, issues #13 and #15), twelve findings, each re-checked against `1e88c77`
  and answered in the spec's `plan.md`. A gate spec as well, since the gate task text and the
  harness change. Follow-ups: #17's body and a comment there (proposal 5's harness half landed here;
  finding 7's analysis for proposal 4); #19, its retrospective's one proposal, approved by the
  owner; and the section name in the comment on fromtheoutfit/patchbay#7.
  - `base/process/standards-retrospective.md`: a question to the owner carries at most three
    proposals and a "None of these" option, four questions to a call. An issue is a gate spec when
    any proposal it carries needs a gate file changed, and says which. When the pull request opens,
    whoever writes its body names the issue, adds the pull request to the issue's "Depends on"
    line and checks every path the issue cites at its head. The `Proposals sent upstream:` line
    has four forms, a declined proposal named by its file and a short name, not its place.
  - `base/process/standards-sync.md`: the `.claude/commands/` rule is one paragraph in "What the
    sync writes, and nothing else", with its reason corrected (the sync writes only its four
    things; the gate task is a gate file, which changes in the gate's own spec), and the paragraph
    at the end of "In a consuming project" is gone. A project's change to a base standard goes
    upstream by the retrospective's route, not "by a pull request there".

- Ninth spec, `agent-os/specs/2026-11-06-1205-retro-proposals-upstream-and-probe-rule/` (issues
  #13 and #15, one spec because both edit `base/process/standards-retrospective.md`), a gate spec
  as well, since the gate task text in `shape-spec.md` is a gate file. Its retrospective is the
  first to present base proposals and file them the new way. `verification/issue-15-evidence.txt`
  holds the lines on `main` the probe rule rests on, and the negative tests and the CI replay are
  rerun there. Follow-ups: #17, the six base proposals its retrospective presented (four from
  earlier specs, never filed, and two of its own), all approved by the owner; and a comment on
  fromtheoutfit/patchbay#7, whose gate spec adds the step after its next sync.
  - `base/process/standards-retrospective.md`: "Verify against the code, not against the spec"
    gains the probe rule (#15). A rule that rests on how a tool behaves is verified by running the
    tool at its pinned version on a scratch copy, with the transcript in `verification/`. The
    probe's cases tell the competing claims apart, its setup is shown to have done what it
    claims, and where probe and documentation disagree the tool's source at the pinned version
    decides. A spec that changes such a rule reruns the probe. The case is the toolchain spec's,
    without tool names. A new section, "Base proposals go to the owner, then upstream" (#13):
    every base proposal is presented to the owner with AskUserQuestion before the spec reports
    done, the approved ones are filed as one issue on `patchbay-standards` with no attribution,
    its number is written beside each, and a declined one is marked `declined by owner, <date>`.
    A proposal neither filed nor declined fails the gate. "Who owns which standard" routes a
    proposal that way, and "Recording the answer" gains the `Proposals sent upstream:` line and
    the outcome at the end of each entry.
  - `base/process/standards-sync.md`: the sync writes nothing under `.claude/commands/`. A
    gate-task step that a base change asks for, the present-and-file step the first, is made in
    the project's own gate spec after the sync, with its template line. Placed at the end of "In a
    consuming project", and moved into "What the sync writes, and nothing else" by the tenth spec.

- Eighth spec, `agent-os/specs/2026-11-06-1040-python-toolchain-standard/` (issue #4):
  `base/python/toolchain.md`, the first standard about Python packages, written from patchbay's
  files at `origin/main` (`73a583a`) and the Decisions of its two toolchain specs. The standard is
  its own summary, and this entry does not repeat it. `verification/patchbay-evidence.txt` records
  what was read and the probes of ruff 0.17.4 and uv 0.13.7 the rules rest on, with uv's source at
  `0.13.7` where its documentation and a probe disagreed. Revised after the review of PR 16
  (eleven findings, one answered by a probe). Follow-ups: fromtheoutfit/patchbay#7 and #15.

- Seventh spec, `agent-os/specs/2026-11-06-0721-gate-spec-3-seven-base-proposals/` (issue #12), the
  third gate spec: the seven base proposals from patchbay's toolchain spec and its revision after
  the review of fromtheoutfit/patchbay#4 landed, each rule written from patchbay's shipped files
  at its `origin/main` (`73a583a`) and from this repository's gate, never from the proposals'
  text. Written general, two of them reach this repository's gate, which changes to meet them
  with a negative test each. `verification/patchbay-evidence.txt` records what the rules were
  read from, patchbay's hosted runs 42149183261 and 42150149022 among it. Revised after the review
  of PR 14 (twelve findings): the gate's tool pins are gate files, the harness checks that a
  failure's later steps never ran, z asserts the gate's own lines, and the wording below; the
  rest of patchbay's side is fromtheoutfit/patchbay#6.
  - `base/process/verification-gate.md`: "One script" gains the install rule (a step that installs
    its pinned tools checks the install on its own, before any tool checks the tree, with its own
    reason, so
    a stale lockfile, an unreadable manifest, a package that will not build, a missing or wrong
    runner or an unpublished pin is never reported as the first tool's finding); "Pinned" says
    where a pin lives (in the script with no package manifest, otherwise exact in the manifest's
    development group, resolved in the lockfile, every tool run under the locked mode so a pin
    edited without re-locking fails, the pins gate files either way: in a manifest, the pins of
    the tools the gate runs and what the lockfile resolves for them, the group's other entries the
    project's), that the runner's own version is pinned once in the manifest where the runner
    refuses any other on every command that reads the project's settings (probed with uv 0.13.7),
    and that the rule set may be the manifest's tool sections, the header saying which sections
    are the gate's; the harness bullet adds that a run failing at a step is held to no later
    step's banner and a passing run may name its lines; "Every step that can fail is
    proven to fail" gains the proof of a rule set (a changed value applied, an unparsable value
    and an unparsable file refused), of a pin (one that cannot install, in a lockfile, the script
    or the manifest's runner pin) and of the install (failing by its own reason, passing before
    the first tool's failure); "CI", whose heading now reads "runs the same script, and checks
    nothing the script does not", installs the locked toolchain as its own step where there is a
    lockfile, reads the runner's version from the manifest where it pins one (a failed lookup is
    loud, refused at the locked install), and admits a cache only on a key that changes with the
    lockfile; "The gate's own files" names the tool pins and a manifest's tool sections; "In this
    repository" gains step 2's install (its check runs `pymarkdown version`, uvx having no
    install-only form), the no-manifest form (pin in the script, uv as setup-uv's input, no
    cache), tests i and z and the count of nineteen; "In a consuming project" gains the uv forms
    (`[dependency-groups] dev` pins in `uv.lock`, gate files with the `[tool.*]` sections,
    `uv run --locked`, `[tool.uv] required-version`, `uv sync --locked` opening the first tool's
    step, setup-uv by commit with no `version` and its cache on `uv.lock`, a `uv sync --locked`
    step before the gate).
  - `scripts/gate-negative-tests.sh`: test z (the clean copy's named lines, the install's `ok`
    line before the lint's; `uvx` hidden by `PATH=/usr/bin:/bin`, where z's setup checks bash,
    dirname, git, sort, head and grep are, fails step 2 by name; a pin naming pymarkdownlnt
    0.9.999, never published, fails step 2 as the install, the gate's own line asserted and not
    uv's wording, pymarkdown never linting); test i gains `line_length: wide`, refused under
    `--strict-config` naming the property, and a stray `[` appended to `.pymarkdown.yaml`, refused
    as YAML naming the file, its traceback elided from the print up to the first unindented line;
    e asserts the install's `ok` line before MD009. `check` asserts any text it is given, whatever
    the status, and holds a reason naming `FAIL  step N/M`, or `gate.sh`'s usage or cd line, to no
    step banner past step N, so the "never printed" of e, f, i, w, x, y and z is checked; the j
    replay runs its Python with `-u`, so each step's line prints before its output. Transcripts
    in the spec's `verification/`, j rerun there, `review-mutations.txt` showing a gate that runs
    every step and one without the install check each caught.

- Sixth spec, `agent-os/specs/2026-11-05-2019-gate-spec-2-five-base-proposals/` (issue #10), the
  second gate spec: the five base proposals from patchbay's first two specs landed, each rule
  written from patchbay's shipped files at its `origin/main` and from this repository's gate files
  once aligned, never from the proposals' text; every gate file that changed carries its negative
  test. Revised after the review of PR 11 (ten findings): step 1's root guard, step 2's git list,
  the reason every failing test run asserts, the `cd` and symlink cases and the fixture's wording,
  below. The two repositories' `scripts/gate.sh` share one skeleton; patchbay takes this
  revision's changes to it in its own gate spec after its next sync (fromtheoutfit/patchbay#5).
  - `base/process/verification-gate.md`: "One script" fixes the exit contract (exit 1 at the
    first failing step after `FAIL  step N/M: <reason>` on stderr, whatever the tool returned;
    any argument, or a repository root the script cannot enter, is exit 2 with no step run) and
    gains the listing rule (a step that reads files from the tree reads the files git lists,
    tracked plus untracked-not-ignored, at a work-tree top that is the repository root: git's
    list with each path checked on the disk and a symlink to nothing named, or a tool that reads
    `.gitignore` itself and is given no path git ignores; a copy nested in another repository is
    refused by name); "Every step that can fail is proven to fail" gains the harness shape
    (`mktemp -d` under a hard failure, the scratch directory refused when empty or inside the
    repository before the trap is set, a setup failure stopping the harness, every run asserting
    its expected status and every failing run its reason, the last line of a transcript counting
    the mismatches); "In this repository" rewritten from the aligned scripts (step 1's root guard
    and shell-only parse, step 2's git list, the test count, the current transcripts' home, the
    skeleton the two repositories' `scripts/gate.sh` share and the diff a spec that changes it
    records); "In a consuming project" names the skeleton, the project's step 1, the listing rule
    for its later steps, the exit contract, the pin step and the fixture.
  - `base/process/standards-sync.md` "In a consuming project": the pin step as the form a
    project's workflow uses (a `run` step with an `id` writes `.version` to `GITHUB_OUTPUT` as
    `sha`, the second checkout takes it as `ref` at the default depth; the default branch with
    full history fails on a pin later squashed or deleted), and the fixture a project's negative
    tests use for the drift check (one local clone of the sibling into the scratch directory per
    run, which shares the sibling's objects and so holds the pin whichever ref reaches it, where a
    `--no-local` or `file://` clone would not; each case as `<case>/patchbay` beside a
    `<case>/patchbay-standards` symlink, the sibling never written, the missing-sibling case made
    by removing the symlink, the CI replay from the scratch workspace).
  - `scripts/gate-negative-tests.sh`: tests w (step 1 lists files with git: an ignored
    `scripts/.DS_Store` passes; a tracked `scripts/notes.txt`, a tracked script missing from the
    disk, a tracked symlink to nothing, a copy without `.git` and the same copy inside another
    repository are each refused by name), x (`--help` and a stray argument exit 2 with the usage
    line, a script that cannot enter the repository root exits 2 saying so; the clean copy exits
    0) and y (step 2 lists with git: an ignored draft under `base/` is never linted, the same file
    tracked is, a tracked standard missing from the disk is refused by name); w and y also run
    PR 11's first head, `a5f88ae`, on the bugs they guard. Transcripts in the spec's
    `verification/`, j rerun there, with the guard deletions the reason assertion catches;
    `verification/gate-sh-diff.txt` is the `diff -u` of patchbay's `scripts/gate.sh` at
    `origin/main` against this repository's.

- Fifth spec, `agent-os/specs/2026-11-05-1441-sync-script-and-standards-sync/` (issue #8): the sync
  that makes a second patchbay repository possible, and the standard that describes it, verified
  against the script as shipped.
  - `scripts/sync-standards.sh`: run from a consuming project's root, with the sibling
    `../patchbay-standards` as the default path and its `origin/HEAD`, origin's default branch, as
    the default ref; an explicit ref off that branch is synced with a warning. Reads `base/`,
    `index.yml` and the script itself out of the commit's tree with `git cat-file`, raw, never the
    working tree; checks every precondition, builds the new `base/`, `.version` and index in a
    temporary directory, then swaps them in, so a refusal writes nothing; replaces
    `agent-os/standards/base/` whole; writes the commit to `agent-os/standards/base/.version`;
    replaces the `base:` section of `agent-os/standards/index.yml` byte for byte and leaves every
    other line in place; verifies the result against the export; copies itself from the same
    commit over the project's copy as the last thing it writes. Reports what changed on stderr and
    one JSON object on stdout; exit 0, 1 on a failed check, 2 on usage or a precondition, each
    named. `--init` creates the `base:` section (and the index) for a first sync, one blank line
    on each side; `--index-only` regenerates the section alone, the safe replacement for the stock
    `index-standards` on a synced index; `--check` is the drift check, naming every file missing,
    extra or changed, a differing section and a differing script. Revised after the owner's review
    of PR 9, 22 findings with two reproduced on macOS (BSD `head -n 0` crashed the splice of a
    section on line 1, and a sync that failed there was left half-written); the dispositions are
    in the spec's `plan.md`.
  - `scripts/gate-negative-tests.sh`: tests o to v for the sync, each on a scratch checkout whose
    `HEAD` and `origin/main` hold the working tree's files beside a scratch Agent OS project with
    its own index sections and two local standards: o (first sync, the sibling default, `--init`
    pinning `origin/main` with `HEAD` ahead, the warning on an explicit `HEAD`, a path inside the
    checkout), p (a working-tree edit is not synced, a committed and pushed addition is), q (a
    removed file is removed), r (own sections survive byte for byte against a hand-built index in
    six layouts, the section on line 1 created, replaced and regenerated, the upstream index's
    trailing comment staying upstream, the PR 9 head's script shown crashing and leaving the
    project half-synced), s (a hand-edited entry is drift and `--index-only` repairs it), t
    (`--check` on a one-byte edit, an extra file, a missing file, an ignored stray, a ref, a
    missing `.version`), u (refusals by name, each writing nothing), v (the script copies itself
    from the commit, not the working tree, as the last thing it writes). Transcripts in the spec's
    `verification/`, the CI replay j rerun there too.
  - `base/process/standards-sync.md`: what the sync writes and nothing else; the invariant and
    `--check`; pinned, not tracking, with the default ref, the sync commit's title and scope; the
    `base:` section rule, `--index-only` and `--init`; a base edit is a pull request here; the
    layout of a consuming project's gate workflow. Indexed in `index.yml`.
  - `verification/branch-protection.txt`: the `gh api .../branches/main/protection` output showing
    the `gate` check required on `main`, which the "does not merge" wording below is verified
    against.

- Fourth spec, `agent-os/specs/2026-11-05-1000-gate-spec-ci-docs-version/` (issue #3), the gate's
  own spec: every gate file changes here and nowhere else, each changed step with its negative test.
  - `.github/workflows/gate.yml`: the gate's workflow. One job on every pull request and every push
    to `main`: checkout, uv, `scripts/gate.sh`, nothing else. `actions/checkout` v7.0.1 and
    `astral-sh/setup-uv` v10.3.3 pinned by commit with the tag beside it, uv pinned to 0.13.7,
    runner `ubuntu-24.04`, a ten-minute timeout, no persisted credential, no cache. The job's run
    steps are replayed from the workflow file on a broken copy before any push
    (`verification/ci-negative-test.txt`); the hosted runs on the pull request are recorded there
    by id.
  - `agent-os/standards/index.yml` is a symlink to `../../index.yml`, as `agent-os/standards/base`
    is to `../../base`: one index to edit, nothing to keep equal.
  - Docs and Version as judgment steps 4 and 5 of the gate, the standards retrospective 6, in
    `shape-spec.md`'s gate task, `scripts/gate.sh`'s header and closing line, and `CLAUDE.md`.
  - `scripts/gate-negative-tests.sh`: every negative test as a committed script, not run by the
    gate, parsed by step 1, each test on a temporary copy. Transcripts in `verification/`: the
    first spec's a, b, d, e, f on the shipped scripts; c1, c2, c3 (a regular file with matching
    bytes, a symlink elsewhere, a directory) replacing c; g (the `comm` locale case); h (an
    untracked standard refused, an ignored stray not); i (`.pymarkdown.yaml` shown to be read);
    k (a key that is a prefix of another, with the PR 7 head's script shown passing an unindexed
    standard under GNU `comm`); l (a non-ASCII path); m (not a git work tree); n (a tracked file
    missing from the disk); j (the CI replay).
  - `base/process/verification-gate.md`: the Docs and Version rules in "The fixed order", a "CI"
    section, the workflow added to the protected gate files, "In this repository" and "In a
    consuming project" updated, all written from the shipped files.
  - `base/process/standards-index.md`: the tracked-files rule under "Every standard and nothing
    else" and the symlink under "In this repository", written from the shipped script.

- Second spec, `agent-os/specs/2026-11-04-1016-gate-and-index-standards/` (issue #1): the two base
  standards the first retrospective recorded as missing, written from the shipped gate and index
  and revised after the review of PR 5 so every claim is backed by a shipped file.
  - `base/process/verification-gate.md`: one `scripts/gate.sh` runs the runnable steps in a fixed
    order and stops at the first failure; versions pinned in the script, rule sets in a versioned
    config; the runnable steps followed by the standards retrospective as judgment recorded in
    `shape.md`; a failing step fixed at its cause; every step proven to fail by a negative test;
    every spec's `gate-run.txt` dated; the gate's own files changed only in their own spec.
  - `base/process/standards-index.md`: two-level keys as paths relative to their section without
    the `.md`, the reserved `root` section, the description line says what the standard decides
    and holds no `: ` or ` #`, every standard indexed and nothing else, a consuming project's
    `base:` section identical to the root's at the pinned commit with no entry edited by hand, the
    stock `index-standards` command not run on a synced index, the `agent-os/standards/base`
    symlink never ships.
  - Both indexed in `index.yml` and `agent-os/standards/index.yml`.

- First spec, `agent-os/specs/2026-11-04-0750-shape-spec-gate-retrospective/`: the process
  backbone, modelled on the Loser League repository.
  - `.claude/commands/agent-os/shape-spec.md` customized: an empty "Core Architecture
    (always included)" tier, the snapshot paragraph, the final verification-gate task, and
    the rule that a base standard is never edited in place during a spec but proposed in
    `shape.md` and sent here as a pull request.
  - The verification gate, `scripts/gate.sh`: `bash -n` on every file under `scripts/`,
    pymarkdown 0.9.41 through `uvx` over `base/` and `README.md` (rules in `.pymarkdown.yaml`),
    and `scripts/check-index.sh` holding `index.yml` equal to the files under `base/` and to
    `agent-os/standards/index.yml`; the standards retrospective as step 4.
  - `base/process/standards-retrospective.md`: the retrospective standard, language-neutral,
    with base ownership and the `(proposed, base)` recording shape.
  - `base/process/ownership.md`: a person owns every commit, pull request, approval and
    merge; an agent never lands work; system-wide tools are asked for before install.
  - `index.yml` at the root (one `base:` section), `agent-os/standards/index.yml` identical to
    it, and `agent-os/standards/base` as a symlink to `base/`.
  - `CLAUDE.md`: Git, Ownership, no-AI-attribution and specs-and-retrospective rules.

### Changed

- `.claude/commands/agent-os/shape-spec.md` (review of PR 18): gate step 6 records
  `Proposals sent upstream:` always, `none` when there is no proposal, and splits the proposals
  three to a question with "None of these"; the template's line shows its four forms.
- `CLAUDE.md` (review of PR 18): the retrospective records `Proposals sent upstream:` either way.
- `scripts/gate-negative-tests.sh` (review of PR 18): `only <entry>...` holds the entries a run
  lists under its FAIL lines to exactly those named, where `says()` finds the named lines in order
  and nothing more. g's second case and both of k's "alone" cases use it.
  `verification/only-assertion-mutations.txt` shows it catch g's old fixture and an extra entry
  beside k's, which `says()` passed. The header says so.
- `base/process/verification-gate.md` (review of PR 18): the harness pointer names the tenth spec.
- `base/python/toolchain.md` (review of PR 18): raising the floor lands in `patchbay-standards` by
  its own spec, from a project a proposal its retrospective sends upstream, not "a pull request".
- `index.yml` (review of PR 18): `process/standards-retrospective` adds the pull-request link and
  the declined proposal named.
- The ninth spec's `verification/gate-negative-tests.txt` ends on its green run; the first run,
  `139 runs, 1 unexpected`, is `verification/gate-negative-tests-first-run.txt`, and the pointers
  to it in that spec's `shape.md` and #17 follow.
- `.claude/commands/agent-os/shape-spec.md` (issues #13 and #15):
  - Gate step 6 gains the present-and-file step.
  - The `shape.md` template gains `Proposals sent upstream:` under `## Standards Retrospective`,
    and each `(proposed, base)` entry ends with its issue or `declined by owner, <date>`.
  - Step 5 and Step 9 say a base proposal is presented to the owner and filed as an issue here,
    whose spec lands it as a pull request.
- `CLAUDE.md` (issues #13 and #15): the Specs section says the same route.
- `scripts/gate-negative-tests.sh` (issues #13 and #15): test g empties its copy's `base/` whole
  and recreates `base/process/`, so its three standards are all `base/` holds. Since issue #4
  added `base/python/toolchain.md`, the copy also held `python/toolchain`, so g's "all three
  indexed" case exited 1. The toolchain spec changed no gate file and did not rerun the tests, so
  the first rerun here found it.
- `base/process/verification-gate.md` (issues #13 and #15): "In this repository" names this spec
  as the one that last changed the harness and holds the current transcripts.
- `index.yml` (issues #13 and #15): the `process/standards-retrospective` description is
  rewritten for the probe rule and the present-and-file step; `process/standards-sync` says the
  sync writes nothing under `.claude/commands`.
- `base/process/verification-gate.md` (issue #4): the introduction's "The standard that names a
  repository's steps is cited here when it ships" now cites it: a consuming project's tool steps,
  and the order they run in, are `base/python/toolchain.md`'s.
- `.claude/commands/agent-os/shape-spec.md` (issue #4): Step 5a, empty until now, lists
  `base/python/toolchain` and is headed "always included in a consuming project"; a spec here
  records it under "Core Architecture" as not applying and does not copy it into `standards.md`,
  and Step 5b leaves it out of the standards it proposes. Step 5b's prompt and the `shape.md`
  template's "Core Architecture" and "Core (Step 5a, consuming projects)" lines say the same. The
  gate task is unchanged.
- `index.yml` (issue #4): `python/toolchain` added under `base:`, after the `process/` keys.
- `scripts/gate.sh` (issue #12): step 2 installs the pin as its own check before pymarkdown lints.
  `uvx` missing from `PATH` fails the step by name; `uvx --from pymarkdownlnt==$PYMARKDOWN_VERSION
  pymarkdown version` fails it as the install, "uvx could not install pymarkdownlnt==<pin>, the
  pinned version, or pymarkdown would not start", where a pin never published was reported
  before as "pymarkdown reported findings, or could not run"; `ok   pymarkdownlnt==<pin>
  installed through uvx` names the version that ran. The pinned invocation is built once, `pmd`,
  for the install and the scan. The scan's reason is now "pymarkdown reported findings, or could
  not read .pymarkdown.yaml". The header says so, citing the rule.
- `base/process/standards-retrospective.md` (issue #12): the proposals heading in "Who owns which
  standard" is `### Standards retrospective (proposed, base)`, as the file's own "Recording the
  answer" template and every spec's `shape.md` have it, not `##`.
- `CLAUDE.md` and `.claude/commands/agent-os/shape-spec.md` (issue #12): the proposals heading is
  `###`, in `CLAUDE.md`'s Specs section and in `shape-spec.md`'s Step 5 and gate step 6; step 2 is
  described as the script runs it, the pin installed through `uvx` as its own check first.
- `index.yml` (issue #12): the `process/verification-gate` description rewritten for the install
  rule, the pins' two homes, the runner's pin, the rule set in a manifest's tool sections, CI's
  locked install and lockfile-keyed cache, and the rule set's and pin's negative tests; after the
  review of PR 14, the install before any tool checks the tree, CI checking nothing the script
  does not, the tool pins among the gate's files, and a negative test's later steps checked as
  never reached.
- `scripts/gate.sh` (issue #10): aligned with patchbay's, then revised after the review of PR 11.
  Exits 1 at the first failing step after `FAIL  step N/3: <reason>` on stderr, whatever
  `bash -n`, pymarkdown or `check-index.sh` returned (test f recorded `bash -n`'s 2 before); any
  argument is usage, exit 2, no step run, and a repository root it cannot enter is exit 2, said.
  Step 1 refuses a tree whose work-tree top is not the repository root, then lists `scripts/`
  with one `git ls-files -z --cached --others --exclude-standard` in place of `find`, so an
  ignored stray is never parsed and a script added before it is staged is; a file ending in `.sh`
  or starting with a bash shebang is parsed, any other file fails the step by name, and a tracked
  file missing from the disk or a symlink to nothing fails by name. Step 2 passes pymarkdown the
  `.md` files under `base/` and `README.md` as git lists them, not `--recurse`, so an ignored
  draft is never linted. The header says the exit contract, the listing rule, citing the
  standard, and what each step needs.
- `scripts/gate-negative-tests.sh` (issue #10): the harness shape patchbay's has, then revised
  after the review of PR 11. The scratch directory comes from `mktemp -d` under a hard failure
  and is refused when empty or at or under the repository before the trap is set; every setup
  step that fails stops the harness by name (exit 2); `run` takes the status each case expects
  and, for a failure, the lines its output must hold, prints `exit=N` or marks it `UNEXPECTED`,
  and the harness ends with `N runs, M unexpected` and exits 1 on any mismatch. Every existing
  case asserts the status the fifth spec's transcript recorded and, when it fails, the reason it
  printed; e and f end in the `FAIL` line.
- `CLAUDE.md` and `.claude/commands/agent-os/shape-spec.md` (issue #10): steps 1 and 2 described
  as the script does them, the files under `scripts/`, `base/` and `README.md` as git lists them,
  and the exit contract named.
- `index.yml` (issue #10): the `process/verification-gate` description rewritten for the exit
  contract, the git listing, the asserting harness and the shared skeleton;
  `process/standards-sync` names the CI checkout at the pin read from `.version`.
- `base/process/standards-index.md` (issue #8): the interim hand-copy sentence and "named here when
  it ships" are pointers at `base/process/standards-sync.md` and `scripts/sync-standards.sh
  --index-only`; a base change without its index entry "does not merge" (the `gate` check is
  required on `main`) rather than "does not pass the gate".
  `base/process/standards-retrospective.md`: the same "does not merge" in "Keep the index in step".
  `base/process/verification-gate.md`: the negative-test count in "In this repository" rewritten
  from the shipped harness (fifteen, a to n except j), the current transcripts' home, j's included,
  and `sync-standards.sh --check` named as a consuming project's gate step with the workflow's
  checkout of `patchbay-standards` at the pinned commit.
  `index.yml`: the `process/standards-index` description rewritten for the sync, and the
  `process/standards-sync` description naming the default ref.
- `scripts/check-index.sh` (issue #3): `LC_ALL=C` is exported once, so `comm` collates like the
  sorts that feed it (under `en_US.UTF-8` a C-sorted list with one entry missing reported every
  entry missing); every list is sorted after its last transform and both are checked sorted before
  `comm`, whose exit is tested on its own (the PR 7 head sorted before stripping, so GNU `comm`
  refused the input and the script read that as nothing missing); the file list is
  `git ls-files -- base` with paths unquoted, so an ignored `.DS_Store` is not refused, a standard
  never added to git is refused by name, a tracked file missing from the disk is refused, and a
  non-ASCII path passes; outside a git work tree the step fails by name; the project index is
  checked to be a symlink to `../../index.yml` instead of compared byte for byte, a directory
  reported as such; the header points at `base/process/standards-index.md`.
- `index.yml`: the `process/verification-gate` description rewritten for the judgment steps and CI;
  the header says tracked files and the symlink.
- `scripts/gate.sh`, `.pymarkdown.yaml`: a pin or rule set is bumped "in the gate's own spec", as
  the gate standard says, not "outside a spec".
- `base/process/standards-retrospective.md` (issue #2, third spec
  `agent-os/specs/2026-11-05-0741-retrospective-points-at-owners/`): "Keep the index in step" and
  "Never edit this file from inside a retrospective" are each a short pointer at the standard that
  owns the rule, `base/process/standards-index.md` and `base/process/verification-gate.md`. The
  sync-script sentence, the `base:`-first ordering sentence and the gate-file list are gone, and
  the retrospective is changed "in its own spec" rather than "outside a spec", as the file's
  ownership section and the gate standard already say. Nothing else in the file changes.
- `index.yml` and `agent-os/standards/index.yml`: the header trimmed to a pointer at the index
  standard; all four descriptions shortened to one sentence each.
- The first spec's `shape.md` unspliced: its filled-in retrospective moved from inside Scope to its
  own heading, replacing the stale "no changes" block, and the moved text's "markdownlint-cli2"
  updated to "pymarkdown". Two records corrected after the review of PR 5: negative test e does
  not show the config is read (its rules are defaults), and the gate run agreed on 2 standards,
  not 1.
- `.gitignore` added, ignoring `.DS_Store`.
