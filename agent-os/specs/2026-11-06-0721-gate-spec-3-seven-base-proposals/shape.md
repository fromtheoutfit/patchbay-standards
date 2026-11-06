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

## Revision after review (2026-11-06)

The owner's review of PR 14 at `2138d96` (hosted gate run 42227921959, success) listed 12 findings,
each checked against the code, with pymarkdownlnt 0.9.41's exit codes and uv 0.13.7's
`required-version` enforcement run. Four were to fix before merge: the gate's tool pins sat in
`[dependency-groups]`, which the standard gave to the package, so a feature spec could bump one; this
`shape.md`'s gate paragraph still described step 2 without its install; z's header claimed an
ok-line order and "3/3 never printed" that `run` does not check; the pinned invocation was written
twice in `scripts/gate.sh`. Eight were minor: the j replay's ordering carried over untracked; "refuses
any other version on every command" overstated uv; z's unpublished-pin case needed the network and
uv's own wording; the install check runs `pymarkdown version`, so a crash at start-up would read as a
failed install; i3's traceback filter could hide a line; `bash` was missing from z's precondition
loop; the CI heading "nothing else" read tighter than its body; two uvx resolutions per run. The owner
and the agent went through them in plan mode; the dispositions are tabled in `plan.md` under
"Revision after the review of PR 14". Four were the owner's choices, each the recommended option; the
rest follow the review's suggestion. The decisions that extend the ones above:

- **The whole review, on this branch, in this spec folder**, as gate spec 2's revision did. Every
  transcript in `verification/` is rerun, j's included, and `verification/review-mutations.txt` shows
  the new assertions discriminate.
- **The gate's tool pins are gate files** (owner's choice over recording only, or giving the gate the
  whole dev group). In a manifest, the pins of the tools the gate runs, and what the lockfile
  resolves for them, change only in the gate's own spec; the group's other entries, a test library a
  feature spec adds among them, stay the package's. patchbay's `pyproject.toml` header and its
  `CLAUDE.md` say `[dependency-groups]` is the package's, against its own dev-group comment ("A pin is
  bumped deliberately, in the gate's own spec"); the standard takes the comment's side, and an issue
  in patchbay records the rest for its own gate spec.
- **Every `gate.sh` failure is checked to stop where it says** (owner's choice over asserting in z
  only, or trimming the claims). The harness's `check` asserts any text it is given, whatever the
  status, so a passing run can name lines its output must hold; and a reason that names
  `FAIL  step N/M`, or `gate.sh`'s usage or cd line, marks the run `UNEXPECTED` when a later step's
  banner was printed. The "never printed" claims of e, f, i, w, y and z and x's "no step banner" are
  checks now, not notes.
- **z's unpublished pin asserts the gate's line, not uv's** (owner's choice over a setup probe). The
  `FAIL  step 2/3` line naming 0.9.999 as the install tells the install check from its absence; uv's
  sentence was the unpinned local uv's wording and needed the network.
- **The j replay runs its Python with `-u`** (owner's choice over an issue), as patchbay's harness
  does, so each step's line prints before its output.
- **The install check's reason names the start-up too.** uvx has no form that installs a tool
  without running it, and `pymarkdown version` checks nothing in the tree; the reason now reads "uvx
  could not install pymarkdownlnt==…, the pinned version, or pymarkdown would not start", and the
  general rule says "before any tool checks the tree". The invocation is built once, `pmd=(…)`; the
  two resolutions it makes are accepted (finding 12).

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
`scripts/` as git lists them, `pymarkdown`, installed at its pin through `uvx` as its own check,
over the `.md` files under `base/` and `README.md` as git lists them, and
`scripts/check-index.sh` — and the three judgment steps are recorded, in this order: Docs,
Version, then the standards retrospective below.

**Results (2026-11-06, after the review of PR 14):** `scripts/gate.sh` exit 0 on the tree, run as
the last act before hand-over on branch
`task/12-gate-spec-3-land-the-seven-base-proposals-from-patchbays-toolchain-spec-and-its-pr-4-revision`;
`verification/gate-run.txt` holds the transcript with the date and branch on its first line. Gate
files changed in this spec and again in its revision (`scripts/gate.sh`, the harness; the gate task
in `shape-spec.md` in the first round), so every negative test ran after the last edit to any of
them, each run asserting its status, its reason when it fails, no step past the one a `gate.sh`
reason fails at, and the lines a passing run names:

- `verification/gate-negative-tests.txt`: every test but j, 139 runs, 0 unexpected, the harness's
  exit 0 on its last line (gate spec 2 recorded 133; i's two cases and z's four runs are new). z:
  the clean copy's named lines, `ok   pymarkdownlnt==0.9.41 installed through uvx (pymarkdown
  version: 0.9.41)` before `ok   no findings`; under `PATH=/usr/bin:/bin` step 1 passes and step 2
  fails "uvx is not on PATH"; with the copy's pin at 0.9.999 step 2 fails "uvx could not install
  pymarkdownlnt==0.9.999, the pinned version, or pymarkdown would not start", `3/3` never printed,
  which is now checked. i: `line_length: wide` fails step 2 with "The value for property
  'plugins.md013.line_length' must be of type 'int'."; a stray `[` fails it with
  "'…/.pymarkdown.yaml' is not a valid YAML file", the traceback's 37 lines elided from the print
  up to the exception line and kept in the checked output. e asserts the install's `ok` line
  before MD009. The banner check holds every `gate.sh` failure in e, f, i, w, x, y and z to its
  step, the old scripts' runs in w and y included, and j2's.
- `verification/ci-negative-test.txt`: j, 2 runs, 0 unexpected; the replay's Python under `-u`, so
  `step 3: run scripts/gate.sh` prints before the gate's output; j1 passes with step 2's install,
  j2 fails at step 3 (the gate) with `FAIL  step 1/3`. The workflow is unchanged since the fourth
  spec. The hosted run on PR 14's first head is recorded at its end, read back with `gh`: run
  42227921959, `pull_request`, `2138d96`, success. The revision's own hosted run is the owner's to
  read back and record after the push.
- `verification/review-mutations.txt`: the new assertions shown to discriminate, each mutation in a
  scratch copy of the listed files. no-exit (`fail` sets a flag, the closing line exits with it):
  the harness at `2138d96` passes e and f (2 runs, 0 unexpected); the shipped one marks both
  `UNEXPECTED`, "a step after step 2 was reached" and "a step after step 1". no-install (the
  install check's three lines deleted): z's clean run lacks its named `ok` line and the unpublished
  pin fails as "pymarkdown reported findings", each `UNEXPECTED` (4 runs, 2 unexpected).
- `verification/patchbay-evidence.txt`: what the rules were read from, by command: patchbay's
  `origin/main` (`73a583a`, equal to `ls-remote`, the same tree as `2121c27`), setup-uv's README at
  `68559e9`, the hosted runs and run 42149183261's version lookup and cache key, patchbay's
  `pyproject.toml`, `gate.sh` step 2, workflow and `uv.lock`, its tests h, m, n and o as recorded;
  after the review, section 6, uv 0.13.7 under a `required-version` it does not meet (every command
  that reads the project's settings refuses, exit 2; `uv --version`, `uv self version`,
  `uv tool list` and `uvx` run), and section 7, patchbay's `CLAUDE.md` gate-files list.
- The gate and the harness ran under `/bin/bash` 3.2.57 and uv 0.13.7, on `PATH` here.

**Docs (step 4):** `base/process/verification-gate.md` read back sentence by sentence against the
file each states, in the first round and again for every sentence the revision changed:

- "One script", the install rule: patchbay `gate.sh` step 2 (`command -v uv`, `uv sync --locked`
  with its own reason naming a stale lockfile, an unreadable file, a package that will not build
  and the wrong uv; then `uv run --locked ruff format --check .`, whose reason is about formatting)
  and this repository's step 2 (`command -v uvx`, the install through `pmd`, the scan's reason).
  "Before any tool checks the tree": `uv sync --locked` runs no tool; `pymarkdown version` checks
  nothing in the tree.
- "Pinned": patchbay's dev group (`==` with a publish date beside each, and the comment above it:
  "A pin is bumped deliberately, in the gate's own spec"), `uv.lock`, the header's "writes nothing
  but the ignored .venv and caches" with `.venv` in its `.gitignore`, test n; its `[tool.uv]`
  comment and test o; the probe in `patchbay-evidence.txt` section 6 for "every command that reads
  the project's settings"; its `pyproject.toml` header (the package's sections and the gate's),
  which says `[dependency-groups]` is the package's, against the standard as revised, and is
  fromtheoutfit/patchbay#6; here `PYMARKDOWN_VERSION` and `.pymarkdown.yaml`'s header.
- "Every step that can fail is proven to fail": patchbay m (40 applied, `"wide"` refused by ruff
  after `ok   the locked toolchain synced`, `[` refused by uv's sync), n, o and h; here i, z and e;
  the harness bullet's banner check and named lines against `check` and `later` in the harness and
  `review-mutations.txt`.
- "CI": patchbay's workflow (setup-uv with `working-directory: patchbay`, no `version`,
  `enable-cache: true`, `cache-dependency-glob: uv.lock`, a `uv sync --locked` run step, the gate),
  setup-uv's README (no version: `required-version` from `uv.toml` or `pyproject.toml` in the
  working directory, else the latest), run 42149183261's log and cache key; "refuses at the locked
  install, its first command that reads the project's settings": the workflow's first uv command is
  `uv sync --locked` and section 6's probe refuses it; here `.github/workflows/gate.yml`
  (`version: "0.13.7"`, `enable-cache: false`).
- "The gate's own files": the tool pins added, as "Pinned" says.
- "In this repository": step 2 against `scripts/gate.sh` (the install check's `pymarkdown version`
  and the shared reason); "nineteen … w, x, y and z" counted against the default test list (a b c1
  c2 c3 d e f g h i k l m n w x y z: 19); the transcripts' home issue #12. "In a consuming
  project": patchbay's `pyproject.toml`, `gate.sh` and workflow, the tool pins as the gate's per
  the revised rule. The skeleton paragraph is unchanged and true: step 2 is not in the skeleton.

`base/process/standards-retrospective.md`: the one heading, now `###` as its template at line 126.
`scripts/gate.sh`'s header (the install paragraph, `pymarkdown version` checking nothing in the
tree, the invocation built once, what step 2 needs, the closing "nothing is installed … but the
pinned pymarkdown, which uvx keeps in the uv cache") against the code below it.
`scripts/gate-negative-tests.sh`'s header (the banner check and named lines, z, i's cases, e's `ok`
line, the commands z needs on `/usr/bin:/bin`) against `check`, `later` and its cases.
`.pymarkdown.yaml`'s header (step 2 reads it; tool pinned in `scripts/gate.sh`) and
`.github/workflows/gate.yml`'s ("the same scripts/gate.sh, and nothing else": true here, with no
lockfile to install; uv pinned to the version proven with; caching off, nothing to key it on) read
true unchanged. `CLAUDE.md`'s Specs section ("CI … runs `scripts/gate.sh` … and nothing else",
true here for the same reason) and `.claude/commands/agent-os/shape-spec.md` (Step 5, the gate
task's steps 2 and 6, the template's Verification Gate paragraph) say step 2 and the `###` heading
as the script and the standard have them, unchanged by the revision. `index.yml`: the
`process/verification-gate` description rewritten because its rule changed, and again for the
revision (the install before any tool checks the tree, CI checking nothing the script does not,
a later step checked as never reached, the tool pins among the gate's files); no `: ` and no ` #`; step 3 agrees on 5 standards. `README.md`
names no gate step and reads true unchanged. Searched outside `agent-os/specs/` for the replaced
wording ("could not run", "caches nothing" with no condition, "pinned in the script" as the only
home, `## Standards retrospective (proposed`, "eighteen", "Nothing is installed to run the gate.",
"before any tool runs", "on every command," with no condition, "there is no version", the
install's old reason): what remains is history in `CHANGELOG.md`, the second spec's entry and this
spec's `scripts/gate.sh` line quoting the reason it replaces, and the two "nothing else" lines
above, true here. No line in `base/`, `CLAUDE.md` or `CHANGELOG.md` exceeds 100 columns.

**Version (step 5):** recorded under `[Unreleased]` in `CHANGELOG.md`: an Added entry for this
spec (the `verification-gate.md` rules and the harness's z and i cases), revised to the shipped
state with one sentence naming the review of PR 14 and fromtheoutfit/patchbay#6, and Changed
entries for `scripts/gate.sh` step 2 (the invocation built once, the install's reason), `CLAUDE.md`
and `shape-spec.md`, and `index.yml`; **the `standards-retrospective.md` heading fix is its own
Changed line**. The repository has no version number to bump.

**Not done by the agent, by rule:** no file staged, committed or pushed, no pull request opened or
commented on; the owner reads the diff at commit time. One issue was opened, as the owner chose in
the revision's shaping: fromtheoutfit/patchbay#6, with no attribution.

## Standards Retrospective

Step 6, always last. Per `base/process/standards-retrospective.md`. Applied 2026-11-06 from the
shipped diff against `main` (`57d362d`), and again after the review of PR 14 from the revised diff:
`.claude/commands/agent-os/shape-spec.md`, `CHANGELOG.md`, `CLAUDE.md`,
`base/process/standards-retrospective.md`, `base/process/verification-gate.md`, `index.yml`,
`scripts/gate-negative-tests.sh`, `scripts/gate.sh`, and this spec folder. The edits to the two
base files are this spec's feature work, written from patchbay's files, this repository's shipped
gate and, after the review, uv's behaviour as probed, not retrospective edits; the questions are
asked of everything the diff touched.

1. *A pattern no standard covers?* None left over. The seven proposals are rules, as feature work,
   and the two this repository's gate now follows (the install as itself; the rule set's three
   cases and the pin's case) are shown by its own tests. The review's two harness assertions, a
   failure's later steps checked as never reached and a passing run's named lines, were a gap
   between the standard's "the steps after it never reached" and what the harness checked; they
   are written into the harness bullet as feature work of this gate spec, not left as a pattern.
   z's `PATH=/usr/bin:/bin` with a setup guard naming each command the steps use, and i's
   traceback elided from the print but not from the check, are instances of the harness rule.
2. *A standard wrong or stale?* The seven, and the review's corrections (the tool pins' owner, uv's
   refusal, the CI heading, the install rule's "before any tool checks the tree"), as feature work.
   The review also settled one of the first round's findings: the j replay's ordering is fixed
   here (`-u`). Found while reading, not changed: patchbay's `command -v uv` in step 2 has no
   negative test, against the existing "a step that has never been seen to fail is not known to
   check anything", for patchbay's own gate spec; the revision spec's
   `verification/ci-negative-test.txt` in patchbay does not record the revised workflow's hosted
   run that issue #12 says it does (runs 42149183261 and 42150149022 are read here instead), a
   patchbay record for its owner; patchbay's `pyproject.toml` header, `CLAUDE.md` and `[tool.uv]`
   comment, now behind the standard, are fromtheoutfit/patchbay#6.
3. *A deliberate deviation?* None from the standards as they now read. This repository's local
   uv is unpinned, which is the no-manifest form "Pinned" names, not a deviation; section 6's probe
   shows `uvx`, the one uv command the gate runs, ignores a `pyproject.toml`'s `required-version`,
   so a manifest pin would not bind it either (a `uv.toml` was not probed).
4. *A moved pointer?* One, updated: "the spec that last changed the harness" names issue #12,
   whose `verification/` holds the current transcripts. `scripts/gate.sh`'s header cites "One
   script" for the install rule. No file was renamed or removed.

No project standard exists to edit. `index.yml`: the `process/verification-gate` description
rewritten because its rule changed, in the same change set, as `standards-index.md` directs; the
symlink follows. No retrospective edit beyond the feature work above, and no proposal: this spec
taught no base standard anything the seven and the review's findings did not already say.
