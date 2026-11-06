# Gate spec 3: land the seven base proposals from patchbay's toolchain spec and its PR 4 revision — Shaping Notes

Shaped 2026-11-06 in plan mode with `/agent-os:shape-spec`, the Step 1–5 questions and four design
questions asked and answered by the owner (recorded under Shaping answers and Decisions); every
answer was the recommended option.

## Core Architecture (Non-Negotiable)

None yet; see Step 5a of `.claude/commands/agent-os/shape-spec.md`. The first base standards will
fill this tier.

## Scope

GitHub issue #12, "Gate spec 3: land the seven base proposals from patchbay's toolchain spec and
its PR 4 revision". The second batch of proposals from a consuming project: patchbay's toolchain
spec (fromtheoutfit/patchbay#2) and its revision after the review of fromtheoutfit/patchbay#4
record seven changes to `base/process/verification-gate.md` and
`base/process/standards-retrospective.md` under "Standards retrospective (proposed, base)". This
spec writes each as a rule from patchbay's shipped files at `origin/main` and from this
repository's own files, never from the proposals' text; changes this repository's `scripts/gate.sh`
and harness where a rule, written general, applies to them, with a negative test each; rewrites
the `process/verification-gate` index description; and records the heading fix as its own line in
`CHANGELOG.md`. Gate green, `verification/gate-run.txt` with date and branch; no commit, stage, PR
or push by an agent.

## Shaping answers

- **Step 1, scope:** issue #12 as written. Gate spec 2's two open proposals (the mutation check of
  an assertion; the issue opened in a consuming project) and issue #13 stay out.
- **Step 2, visuals:** none.
- **Step 3, references:** patchbay's files at `origin/main` `73a583a`; setup-uv's `README.md` at the
  pinned commit; patchbay's hosted runs 42149183261 and 42150149022, by id; this repository's gate
  files. See `references.md`.
- **Step 4, product context:** `agent-os/product/` does not exist. Skipped.
- **Step 5, standards:** all five under `base/process`, in `standards.md`; two are edited here as
  feature work.

## Decisions

- **GitHub issue #12 is the scope.** Its sections (`verification-gate.md` proposals 1–6,
  `standards-retrospective.md` proposal 7, `index.yml`, this repository's gate files) are the
  tasks; its "Rules" paragraph is this spec's definition of done. Nothing outside it changes but
  `CHANGELOG.md`, the `##` heading and the step-2 wording that `CLAUDE.md` and `shape-spec.md`
  copy (the Docs step), and this spec folder. #11 has landed (`main` is `57d362d`) and patchbay
  PR 4 is merged (`origin/main` `73a583a`), so both of the issue's dependencies hold.
- **Proposals 5 and 6 are general, and this repository's gate changes to meet them** (owner's
  choice over a harness-only change or lockfile-only rules). Found while shaping:
  `uvx --from pymarkdownlnt==0.9.999 …` exits 1 with "No solution found when resolving tool
  dependencies", the status pymarkdown gives a finding, and step 2 reported both as "pymarkdown
  reported findings, or could not run"; that is the defect class of patchbay's PR 4 finding 5 in
  the no-manifest form. And the standard's "a config the tool cannot parse fails the step" had no
  negative test here. So: a step that installs a pinned tool fails as itself; a rule set is proven
  by a changed value applied, an unparsable value and an unparsable file each refused; a pin is
  proven applied. Here step 2 checks `uvx` is on PATH and installs the pin as its own check before
  the scan (new test z), and test i gains the two refusals.
- **Proposal 6's rule lives under "One script"** (owner's choice), beside "Every step reports by
  name", since it is about how a step reports; its proof sits under "Every step that can fail is
  proven to fail" with proposal 5.
- **The rules are tool-neutral** (owner's choice). "Pinned" and "CI" speak of the package manifest,
  the lockfile, the runner and its locked mode, so the standard's "names no step and no tool"
  stays true; "In a consuming project" names the uv forms (every consuming project is a uv
  package), and "In this repository" the no-manifest form.
- **The uv pin here stays setup-uv's `version:` input** (owner's choice, as the issue says).
  `.github/workflows/gate.yml` is unchanged; caching stays off, with no lockfile to key it on. In
  this form a local run's uv is whatever is on PATH; only CI's is pinned. A `uv.toml` with
  `required-version` would be read by setup-uv too, but whether `uvx`, the only uv command the
  gate runs, honours a local `uv.toml` was not verified, and the issue keeps the input.
- **Step 2 is not part of the skeleton the two `scripts/gate.sh` share** (the `cd` and usage checks,
  `step`, `fail`, `listed`, `present`, step 1 with its root guard, the closing line), so no
  `gate-sh-diff.txt` is recorded. patchbay meets every new rule from its own files (they are the
  source), so no issue is opened there; its harness still lacks the reason assertion, which
  fromtheoutfit/patchbay#5 already records.
- **The hosted proof of proposals 3 and 4 is read here by id.** The issue says the revised
  workflow's hosted run is recorded at the end of the revision spec's
  `verification/ci-negative-test.txt`; at `73a583a` that file records only run 42145584983 (on
  `92c2ec2`, the workflow before the revision) and says the revised run is the owner's to record.
  Runs 42149183261 (`2121c27`) and 42150149022 (`73a583a`) exist, both success, and the first's
  log shows setup-uv finding 0.13.7 in `patchbay/pyproject.toml` and the cache key;
  `verification/patchbay-evidence.txt` holds both.
- **The patchbay checkout is read at `origin/main`**, never from its working tree, which is on the
  merged feature branch.

## Context

- **Visuals:** None.
- **References:** `references.md`.
- **Product alignment:** N/A (no `agent-os/product/`).

## Standards Applied

**Core (always applied):**
- none yet (Step 5a)

**Feature-specific:**
- `process/verification-gate` — the gate's own spec: `scripts/gate.sh` step 2 and the harness
  change with their negative tests; edited as feature work from patchbay's files and this
  repository's (proposals 1–6, "In this repository", "In a consuming project").
- `process/standards-retrospective` — governs the closing step; its proposals heading is edited
  here as feature work (proposal 7), not from the retrospective.
- `process/standards-index` — the `process/verification-gate` description rewritten because its
  rule changes, in the same change set; the symlink follows.
- `process/ownership` — no commit, stage, push, PR, approval or merge by an agent; nothing
  installed (bash, git and uv are already present).
- `process/standards-sync` — the CI layout of a consuming project is unchanged; read for "In a
  consuming project".

## Verification Gate

Spec is not complete until `scripts/gate.sh` passes — `bash -n` on every shell script under
`scripts/` as git lists them, `pymarkdown` over the `.md` files under `base/` and `README.md` as
git lists them, and `scripts/check-index.sh` — and the three judgment steps are recorded, in this
order: Docs, Version, then the standards retrospective below.

**Results (2026-11-06):** `scripts/gate.sh` exit 0 on the tree, run as the last act before
hand-over on branch
`task/12-gate-spec-3-land-the-seven-base-proposals-from-patchbays-toolchain-spec-and-its-pr-4-revision`;
`verification/gate-run.txt` holds the transcript with the date and branch on its first line. Gate
files changed in this spec (`scripts/gate.sh`, the harness, the gate task in `shape-spec.md`), so
every negative test ran after the last edit to any of them, each run asserting its status and,
when it fails, its reason:

- `verification/gate-negative-tests.txt`: every test but j, 139 runs, 0 unexpected, the harness's
  exit 0 on its last line (gate spec 2 recorded 133; i's two cases and z's four runs are new). z:
  the clean copy prints `ok   pymarkdownlnt==0.9.41 installed through uvx (pymarkdown version:
  0.9.41)` before `ok   no findings`; under `PATH=/usr/bin:/bin` step 1 passes and step 2 fails
  "uvx is not on PATH"; with the copy's pin at 0.9.999, uv says "there is no version of
  pymarkdownlnt==0.9.999" and step 2 fails "uvx could not install pymarkdownlnt==0.9.999, the
  pinned version", `3/3` never printed. i: `line_length: wide` fails step 2 with "The value for
  property 'plugins.md013.line_length' must be of type 'int'."; a stray `[` fails it with
  "'…/.pymarkdown.yaml' is not a valid YAML file", the traceback elided from the print and kept in
  the checked output. e asserts the install's `ok` line before MD009. Both refusals were first
  probed on scratch copies of `.pymarkdown.yaml`, and the assertions copied from the output.
- `verification/ci-negative-test.txt`: j, 2 runs, 0 unexpected; j1 runs step 2's install on the
  clean copy and passes, j2 fails at step 3 (the gate) with `FAIL  step 1/3`. The workflow is
  unchanged since the fourth spec. The hosted run on this pull request is the owner's to read back
  and record at its end after the push.
- `verification/patchbay-evidence.txt`: what the rules were read from, by command: patchbay's
  `origin/main` (`73a583a`, equal to `ls-remote`, the same tree as `2121c27`), setup-uv's README at
  `68559e9`, the hosted runs and run 42149183261's version lookup and cache key, patchbay's
  `pyproject.toml`, `gate.sh` step 2, workflow and `uv.lock`, and its tests h, m, n and o as
  recorded.
- The gate and the harness ran under `/bin/bash` 3.2.57 and uv 0.13.7, on `PATH` here.

**Docs (step 4):** `base/process/verification-gate.md` read back sentence by sentence against the
file each states:

- "One script", the install rule: patchbay `gate.sh` step 2 (`command -v uv`, `uv sync --locked`
  with its own reason naming a stale lockfile, an unreadable file, a package that will not build
  and the wrong uv; then `uv run --locked ruff format --check .`, whose reason is about formatting)
  and this repository's step 2 (`command -v uvx`, the install, the scan's reason).
- "Pinned": patchbay's dev group (`==` with a publish date beside each), `uv.lock`, the header's
  "writes nothing but the ignored .venv and caches" with `.venv` in its `.gitignore`, test n; its
  `[tool.uv]` comment and test o; its `pyproject.toml` header (the package's sections and the
  gate's); here `PYMARKDOWN_VERSION` and `.pymarkdown.yaml`'s header (which step, gate's own spec).
- "Every step that can fail is proven to fail": patchbay m (40 applied, `"wide"` refused by ruff
  after `ok   the locked toolchain synced`, `[` refused by uv's sync), n, o and h; here i, z and e.
- "CI": patchbay's workflow (setup-uv with `working-directory: patchbay`, no `version`,
  `enable-cache: true`, `cache-dependency-glob: uv.lock`, a `uv sync --locked` run step, the gate),
  setup-uv's README (no version: `required-version` from `uv.toml` or `pyproject.toml` in the
  working directory, else the latest), run 42149183261's log and cache key; here
  `.github/workflows/gate.yml` (`version: "0.13.7"`, `enable-cache: false`).
- "In this repository": step 2 against `scripts/gate.sh`; "nineteen … w, x, y and z" counted
  against the default test list (a b c1 c2 c3 d e f g h i k l m n w x y z: 19); the transcripts'
  home now issue #12. "In a consuming project": patchbay's `pyproject.toml`, `gate.sh` and workflow.
  The skeleton paragraph is unchanged and true: step 2 is not in the skeleton.

`base/process/standards-retrospective.md`: the one heading, now `###` as its template at line 126.
`scripts/gate.sh`'s header (the install paragraph, what step 2 needs, the closing "nothing is
installed … but the pinned pymarkdown, which uvx keeps in the uv cache") against the code below it.
`scripts/gate-negative-tests.sh`'s header (z, i's cases, e's `ok` line, z's needs) against its
cases. `.pymarkdown.yaml`'s header (step 2 reads it; tool pinned in `scripts/gate.sh`) and
`.github/workflows/gate.yml`'s (uv pinned to the version proven with; caching off, nothing to key
it on) read true unchanged. `CLAUDE.md`'s Specs section and `.claude/commands/agent-os/shape-spec.md`
(Step 5, the gate task's steps 2 and 6, the template's Verification Gate paragraph) say step 2 and
the `###` heading as the script and the standard have them. `index.yml`: the
`process/verification-gate` description rewritten because its rule changed; no `: ` and no ` #`;
step 3 agrees on 5 standards. `README.md` names no gate step and reads true unchanged. Searched
outside `agent-os/specs/` for the old wording ("could not run", "caches nothing" with no
condition, "pinned in the script" as the only home, `## Standards retrospective (proposed`,
"eighteen", "Nothing is installed to run the gate."): what remains is history in `CHANGELOG.md`,
the second spec's entry and this spec's `scripts/gate.sh` line quoting the reason it replaces. No line in `base/`, `CLAUDE.md` or `CHANGELOG.md` exceeds 100 columns.

**Version (step 5):** recorded under `[Unreleased]` in `CHANGELOG.md`: an Added entry for this
spec (the `verification-gate.md` rules and the harness's z and i cases) and Changed entries for
`scripts/gate.sh` step 2, `CLAUDE.md` and `shape-spec.md`, and `index.yml`; **the
`standards-retrospective.md` heading fix is its own Changed line**. The repository has no version
number to bump.

**Not done by the agent, by rule:** no file staged, committed or pushed, no pull request opened,
no issue opened or commented on; the owner reads the diff at commit time.

## Standards Retrospective

Step 6, always last. Per `base/process/standards-retrospective.md`. Applied 2026-11-06 from the
shipped diff against `main` (`57d362d`): `.claude/commands/agent-os/shape-spec.md`,
`CHANGELOG.md`, `CLAUDE.md`, `base/process/standards-retrospective.md`,
`base/process/verification-gate.md`, `index.yml`, `scripts/gate-negative-tests.sh`,
`scripts/gate.sh`, and this spec folder. The edits to the two base files are this spec's feature
work, written from patchbay's files and this repository's shipped gate, not retrospective edits;
the questions are asked of everything the diff touched.

1. *A pattern no standard covers?* None left over. The seven proposals are rules, as feature work,
   and the two this repository's gate now follows (the install as itself; the rule set's three
   cases and the pin's case) are shown by its own tests. The harness details this spec added, z's
   `PATH=/usr/bin:/bin` with a setup guard that `uvx` is absent there and `git` present, and i's
   traceback elided from the print but not from the check, are instances of the harness rule
   ("a setup step that fails stops the harness by name"; "every run … names the reason its output
   must hold"), not new patterns.
2. *A standard wrong or stale?* The seven, corrected as feature work. Found while reading, not
   changed, each outside this spec's plan: the j replay prints the job's own lines after the
   gate's output, because its Python writes to a file without `-u` and buffers (gate spec 2's
   transcript shows the same order; patchbay's harness passes `-u`), a readability defect of a
   gate file for the next gate spec here; patchbay's `command -v uv` in step 2 has no negative
   test, against the existing "a step that has never been seen to fail is not known to check
   anything", for patchbay's own gate spec; and the revision spec's
   `verification/ci-negative-test.txt` in patchbay does not record the revised workflow's hosted
   run that issue #12 says it does (runs 42149183261 and 42150149022 are read here instead), a
   patchbay record for its owner.
3. *A deliberate deviation?* None from the standards as they now read. This repository's local
   uv is unpinned, which is the no-manifest form "Pinned" now names, not a deviation.
4. *A moved pointer?* One, updated: "the spec that last changed the harness" now names issue #12,
   whose `verification/` holds the current transcripts. `scripts/gate.sh`'s header cites "One
   script" for the install rule. No file was renamed or removed.

No project standard exists to edit. `index.yml`: the `process/verification-gate` description
rewritten because its rule changed, in the same change set, as `standards-index.md` directs; the
symlink follows. No retrospective edit beyond the feature work above, and no proposal: this spec
taught no base standard anything the seven did not already say.
