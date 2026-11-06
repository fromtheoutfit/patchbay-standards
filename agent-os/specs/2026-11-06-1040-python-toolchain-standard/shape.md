# The Python toolchain standard (issue #4) — Shaping Notes

Shaped 2026-11-06 in plan mode with `/agent-os:shape-spec`, the Step 1–5 questions and seven
design questions asked and answered by the owner (recorded under Shaping answers and Decisions).
Each answer was the recommended option except three: the scope, which the owner narrowed to
tooling in a note on the layout answer; the layout, for which no option was recommended; and the
patchbay follow-up, where the owner chose an issue over recording only.

## Core Architecture (Non-Negotiable)

None at shaping: Step 5a was empty. This spec adds `base/python/toolchain` to the tier. It applies
to consuming projects, and this repository has no package, so it does not apply to this spec.

## Scope

GitHub issue #4, "Write base/python/toolchain.md — one tool per job, pyproject.toml the only
config". Write `base/python/toolchain.md` from patchbay's files at its `origin/main` (`73a583a`):
`pyproject.toml`, `uv.lock`, `.pre-commit-config.yaml`, `scripts/gate.sh`,
`.github/workflows/gate.yml` and the Decisions of its two toolchain spec folders, with the proofs
the issue comment cites beside them. Every rule names the file it is verified against; rules have
named exceptions, and none says "consider" or "prefer". Point `verification-gate.md` at it, add it
to this repository's Step 5a with the note that it applies to consuming projects, and index it.
CHANGELOG entry, gate green, `verification/gate-run.txt` with date and branch; no commit, stage,
PR or push by an agent.

## Shaping answers

- **Step 1, scope:** the standard is about tooling. The package-surface and test-writing rules the
  issue comment lists from the review of patchbay PR 4 are left out and recorded under the
  Standards Retrospective below as deferred, each with the standard it waits for. Owner: "A pytest
  or hypothesis configuration key stays here; a rule about how to write a test does not."
- **Step 2, visuals:** none.
- **Step 3, references:** the files named in the scope, plus the comment's proofs
  (`src/patchbay/__init__.py`, `tests/unit/test_package.py`, `tests/unit/test_version.py`,
  `.python-version`, `.gitignore`, the revision spec's `verification/wheel-license.txt`); see
  `references.md`.
- **Step 4, product context:** `agent-os/product/` does not exist here. Skipped.
- **Step 5, standards:** all five under `base/process`, feature-specific, in `standards.md`.
- **Layout:** rule sections first, then a short "In this repository" (no package; the standard does
  not apply) and "In a consuming project" (every rule above is the project's).
- **Build backend:** the range as shipped, floored at the pinned uv.
- **Split with the gate standard:** tools here, with the gate standard's pointer edited.
- **noqa:** the code half only.
- **ty:** left out.
- **Step 5a here:** recorded, not copied.
- **patchbay follow-up:** an issue in patchbay (owner's choice over recording only).

## Decisions

- **GitHub issue #4 is the scope.** Its body is the earlier intent; its comment is the inventory of
  what patchbay shipped and where each choice is recorded. Where they differ, the shipped tree
  wins and the standard says what the tree does: `uv run --locked`, not bare `uv run`; the hooks
  `ruff check --fix` then `ruff format`, not the issue's order; the build backend a range, not a
  literal (below); `tests/conftest.py` absent. The issue's question at its end, how a base standard
  for consuming repositories is verified when this repository has no Python, is answered by
  patchbay existing: the standard is verified against patchbay's files at a commit, and says in
  "In this repository" that it does not apply here. Nothing outside the scope changes but
  `CHANGELOG.md` and this spec folder.
- **The patchbay checkout is read at `origin/main`**, never from its working tree, which is on the
  merged feature branch; `origin/main` equals `ls-remote` (`verification/patchbay-evidence.txt`).
- **Tooling only** (owner). The standard says which tool does which job, what each tool's
  configuration says and the order the gate runs them in. How the package exposes its surface and
  how a test is written are other standards' (deferred below). A configuration key that is about
  tests (`testpaths`, `--strict-markers`, the `"tests/**"` per-file ignores, mypy's `files`) stays.
- **The build backend is the range `uv init` writes, floored at the pinned uv** (owner). As
  shipped, `uv_build>=X.Y.Z,<X.(Y+1).0` with the lower bound the uv `[tool.uv] required-version`
  pins, not the issue's literal version: the tree wins, `uv init` at 0.13.7 writes exactly
  `>=0.13.7,<0.14.0` (evidence section 6), and uv's documentation gives the upper bound as what
  keeps the package building as uv_build, versioned as uv is, moves. At shaping the floor's reason
  was uv's documented condition, that uv uses its bundled backend only when its version satisfies
  the range. **The probe disproved it** (evidence section 5): under uv 0.13.7, offline with no
  cache, `uv build` and `uv sync`'s editable build both use the bundled backend whatever the range,
  and a range without the running uv is a warning, `does not contain the current uv version`, the
  build succeeding. The rule is unchanged and its reason is the probe's: inside the range the build
  is clean, and since nothing fails when the range and the pin part, the floor is held by reading
  `pyproject.toml`, the spec that moves `required-version` past the range moving the range with it
  (the gate's spec, `[tool.uv]` being a gate file). A literal `==0.13.7` builds the same under uv
  (evidence section 5) and was not chosen.
- **The split with the gate standard** (owner). `verification-gate.md` owns where a pin lives, the
  locked mode, `required-version`, which sections of `pyproject.toml` are the gate's, the
  `uv sync --locked` opener and CI; `toolchain.md` cites them and restates none. `toolchain.md`
  owns which tool does which job, what each `[tool.*]` section says and the order of the tool
  steps. The one sentence of `verification-gate.md` that anticipated this standard, "The standard
  that names a repository's steps is cited here when it ships", now cites it: feature work of this
  spec, a pointer, so the `process/verification-gate` index description is unchanged. The dev
  group's entries that are not gate tools take the gate pins' form (exact, dated); which of them
  are gate files is the gate standard's, and patchbay's classification of hypothesis and
  pre-commit is fromtheoutfit/patchbay#6.
- **noqa: the code half is the rule** (owner). `# noqa: <code>`, never blanket, verified against
  `select = ["ALL"]` by probes: PGH004 refuses a blanket noqa that suppresses a finding, RUF100 a
  coded one that suppresses nothing, and a coded one that suppresses what it names passes
  (evidence section 4). The issue's "with a reason" has no file behind it and is left to
  `verification-gate.md`'s "reviewed as the loosening it is". patchbay has no noqa yet; the rule
  says so.
- **ty is left out** (owner). The issue's "ty replaces mypy when it reaches 1.0, as one spec" is
  in no file of patchbay's tree or its specs. The intent is recorded here: the spec that replaces
  mypy rewrites the mypy section, and is the gate's own spec, since `[tool.mypy]` is a gate file.
- **"Modern syntax, no shims"** is written as what ruff enforces under `ALL` and the floor's
  `target-version`: UP036 refuses a version branch below the floor, UP035 a `typing_extensions`
  import of a name `typing` has (evidence section 4); a backport is a dependency, and fails the
  Decision's "why the standard library cannot".
- **The six ignores are patchbay's, each listed when a package's own run trips it.** Their reasons
  (ruff's two incompatible docstring pairs, the formatter's trailing commas, the license in
  `LICENSE`, pytest's `assert`, `tests/` not a package) hold of any patchbay package, but the
  method says nothing is listed from memory, so the standard does not tell a new package to copy
  the list.
- **The gate's tool steps are named here**: format check, lint, types, tests, with patchbay's
  reasons from its toolchain spec's Decisions, one step per tool; the opener and `--locked` are
  cited.
- **"The gate's tools and the hooks run as `uv run --locked`"**, not "every command": patchbay's
  `README.md` names `uv run pre-commit install` and `uv run pre-commit run --all-files` without it,
  and the header of `.pre-commit-config.yaml` the same two. They are the named exception, and the
  hooks they run still use `--locked`. Found reading the tree back, after the plan.
- **`module-name` is a rule** where the import name is not the distribution's: without it the
  export fails to build, `Expected a Python module at: src/patchbay_core/__init__.py` (evidence
  section 7).
- **Step 5a here: recorded, not copied** (owner). The tier lists `base/python/toolchain` with the
  note that it applies to consuming projects; a spec shaped here records it under "Core
  Architecture" as not applying and does not copy it into `standards.md`. Step 5b's text and
  prompt and the `shape.md` template's two lines say the same. None of these is the gate task.
- **The follow-up in patchbay is an issue** (owner), fromtheoutfit/patchbay#7: after the sync
  that brings the standard in, its `shape-spec.md` Step 5a lists it, with the template lines that
  follow, its `agent-os/product/tech-stack.md` cites it, and that spec's Docs step reads it
  against the tree. No attribution.

## Context

- **Visuals:** None.
- **References:** `references.md`.
- **Product alignment:** N/A (no `agent-os/product/`).

## Standards Applied

**Core (always applied):**

- none at shaping (Step 5a was empty); `base/python/toolchain`, added by this spec, does not apply
  here

**Feature-specific:**

- `process/verification-gate` — the rules `toolchain.md` cites and does not restate; its pointer
  sentence edited as feature work; the gate this spec ends with, no gate file changed.
- `process/standards-index` — the `python/toolchain` key, a new `python` folder under `base/`, a
  description that says what it decides, with no `: ` and no ` #`.
- `process/standards-retrospective` — the closing step, with the deferred inventory; base changes
  proposed, not edited.
- `process/ownership` — no stage, commit, push, PR, approval or merge by an agent; nothing
  installed (uv 0.13.7 was on `PATH`; the probes wrote only to the scratch directory and uv's
  cache). One issue opened in patchbay, as the owner chose, with no attribution.
- `process/standards-sync` — how the file reaches a consuming project, as
  `agent-os/standards/base/python/toolchain.md`, and its index entry with the `base:` section.

## Verification Gate

Spec is not complete until `scripts/gate.sh` passes — `bash -n` on every shell script under
`scripts/` as git lists them, `pymarkdown`, installed at its pin through `uvx` as its own check,
over the `.md` files under `base/` and `README.md` as git lists them, and
`scripts/check-index.sh` — and the three judgment steps are recorded, in this order: Docs,
Version, then the standards retrospective below.

**Results (2026-11-06):** `scripts/gate.sh` run as the last act before hand-over on branch
`feature/4-write-basepythontoolchainmd-one-tool-per-job-pyprojecttoml-the-only-config`;
`verification/gate-run.txt` holds two transcripts, its first line giving the date and the branch.
On the tree: steps 1 and 2 pass, pymarkdown linting the new standard as one of seven files git
lists, and step 3 exits 1 naming the one file, `base/python/toolchain.md`, untracked, and its entry
`python/toolchain`, by design: `scripts/check-index.sh` refuses an untracked file under `base/`,
and staging is the owner's. On a scratch copy of the gate's files with that file git-added, the
copy pattern of `scripts/gate-negative-tests.sh`: exit 0, 6 standards. The owner's `git add
base/python/toolchain.md` turns the tree's run into the second. No gate file changed (the gate
script, the scripts it runs, the pin, `.pymarkdown.yaml`, the workflow and the gate task in
`shape-spec.md` are untouched), so no negative test was rerun. `verification/patchbay-evidence.txt`
holds what the rules were read from and the probes, 13 runs.

**Docs (step 4):** `base/python/toolchain.md` read back sentence by sentence against the patchbay
file each rule names, at `73a583a` (`verification/patchbay-evidence.txt`, section 3), and against
the probes (sections 4 to 7) for what a file cannot show:

- "One tool per job": the dev group's five pins and their comments, the `[tool.ruff]` comment
  ("there is no black"), `uv.lock` the only lockfile and `.gitignore`'s commented `uv.lock` line,
  the absent installer files; `scripts/gate.sh` lines 73–89 and the hook entries for `--locked`;
  the README's two `uv run pre-commit` lines and the hook file's header for the exception, which
  this read-back added (the plan named one command, the tree has two).
- "pyproject.toml is the only config file": the header's list, lines 1–3; the hook file's header.
- "The build": `[build-system]` lines 29–31 and `required-version` line 38; sections 5 and 6 for
  the bundled backend, the warning and `uv init`'s range; uv's page for the upper bound's reason
  and for other frontends, whose wording ("will always use the `uv_build` package") the read-back
  restored where the draft had said "from the index"; `module-name` line 41 and section 7;
  `license-files` lines 19–22, `wheel-license.txt`, `test_package.py`.
- "Python 3.12 is the floor": lines 26, 60 and 99 and `.python-version`; section 4's UP036 and
  UP035.
- "Dependencies": the header, lines 5–7; `dependencies = []`, line 27; the toolchain spec's
  Decisions (the five dependencies, pydantic and typer not added); the dev group.
- "ruff": lines 56–92, the comments and the six codes; the toolchain spec for ISC001 and PLR2004;
  section 4 for PGH004 and RUF100; `verification-gate.md`'s "A failing step is fixed at its
  cause" and "The gate's own files change only in their own spec".
- "mypy": lines 94–107. "pytest and hypothesis": lines 109–117, `.gitignore` line 51 for
  `.hypothesis/`, the toolchain spec for no `filterwarnings` and no hypothesis section.
- "pre-commit": the hook file, lines 9–25, and its header; the toolchain spec for the mirror and
  the order's reason. "The gate's tool steps": `scripts/gate.sh` lines 56–92, the toolchain spec
  for the reasons.
- "In this repository": `git ls-files` lists no `pyproject.toml`, `uv.lock`, `src/` or `tests/`;
  `scripts/gate.sh` runs pymarkdown through `uvx` with its pin in the script. "In a consuming
  project": the sync standard's path; patchbay's Step 5a does not list it yet, which is #7.

`base/process/verification-gate.md`: the edited sentence reads true against `toolchain.md`'s "The
gate's tool steps"; its "this standard names no step and no tool" still holds of its general
sections. `.claude/commands/agent-os/shape-spec.md`: Step 5a, Step 5b's text and prompt and the
template's two lines say the same thing, and the gate task, Step 8 and Step 9 are untouched and
true. `index.yml`: the key sorts after `process/`, the description has no `: ` and no ` #`, PyYAML
reads the file, and `scripts/check-index.sh` agrees on the copy (6 standards). `CLAUDE.md` ("Work
is shaped with `/agent-os:shape-spec` and follows the standards under `base/`") and `README.md`
read true unchanged: following a standard that says it does not apply here is consistent with
both. Searched the files git lists outside `agent-os/specs/` and `CHANGELOG.md` for the replaced
wording ("when it ships", "empty for now", "once it exists", "none yet", case-insensitive): no
Step 5a or pointer wording remains. What matches is about other things: `toolchain.md`'s "patchbay
has none yet" of a noqa, the stock `plan-product.md`'s "none yet" of future features, and the
"once it exists" of a hosted run's record in `verification-gate.md` and the harness. No line of
`base/python/toolchain.md`, `verification-gate.md` or the new `CHANGELOG.md` lines exceeds 100
characters (one line of `toolchain.md` is 101 bytes for its `…`); the over-long lines of
`shape-spec.md` (79, 82, 394–396) predate this spec, and its edited lines are within 100.

**Version (step 5):** recorded under `[Unreleased]` in `CHANGELOG.md`: an Added entry for this
spec and `base/python/toolchain.md`, naming the issue, the evidence and fromtheoutfit/patchbay#7;
Changed lines for the `verification-gate.md` pointer, `shape-spec.md`'s Step 5a, 5b and template,
and `index.yml`. The repository has no version number to bump.

**Not done by the agent, by rule:** no file staged, committed or pushed, no pull request opened;
the owner reads the diff at commit time. One issue opened, as the owner chose in shaping:
fromtheoutfit/patchbay#7, with no attribution.

## Standards Retrospective

Step 6, always last. Per `base/process/standards-retrospective.md`. Applied 2026-11-06 from the
shipped diff against `main` (`f877544`): `base/python/toolchain.md` (new),
`base/process/verification-gate.md`, `.claude/commands/agent-os/shape-spec.md`, `index.yml`,
`CHANGELOG.md`, and this spec folder. The new standard, the pointer in `verification-gate.md` and
the Step 5a tier are this spec's feature work, written from patchbay's files and the probes, not
retrospective edits; the questions are asked of everything the diff touched.

1. *A pattern no standard covers?* Two. The first is the deferred inventory below: rules patchbay
   ships that no standard holds yet, kept out of this one by the owner's scope. The second is a
   method this spec used and the third spec (issue #12) used before it: a rule that rests on how
   a tool behaves is verified by running the tool at its pinned version on a scratch export, with
   the transcript in `verification/`, never by its documentation alone. Here uv's documentation
   described a condition uv 0.13.7 does not apply. Proposed below.
2. *A standard wrong or stale?* One pointer, made true as feature work:
   `verification-gate.md`'s "cited here when it ships" now cites the standard that shipped.
   Nothing else read stale. The issue body's wording (bare `uv run`, the hook order, a literal
   backend version, ty) is the issue's, not a standard's, and the tree won.
3. *A deliberate deviation?* None from the standards as they read. Met again, not changed: a spec
   that adds a file under `base/` cannot show step 3 green on its own tree before the owner stages
   it. `gate-run.txt` keeps the two transcripts the fifth spec (issue #8) used, and that spec's
   proposal for `verification-gate.md`, what such a spec records, is still open and not repeated
   here.
4. *A moved pointer?* None moved. The pointer added is in Decisions. `toolchain.md` names patchbay
   files by path at `73a583a`; a later patchbay spec that moves one is caught by the Docs step of
   #7's spec, which reads the standard against its tree.

No project standard exists to edit. `index.yml`: `python/toolchain` added in the same change set,
as `standards-index.md` directs; the symlink follows.

**Deferred, not in this standard** (owner's scope; each waits for the standard named, which is
not written; the patchbay file at `73a583a` is the proof to write it from):

- To `base/python/layout.md`:
  - `__version__` is read from the installed distribution with `importlib.metadata.version`, with
    no fallback: the package is imported installed, and from a bare `src/` the import fails rather
    than invent a version. `src/patchbay/__init__.py`;
    `tests/unit/test_version.py::test_version_matches_pyproject`.
  - A module's own imports are bound to private names (`import importlib.metadata as _metadata`).
    `src/patchbay/__init__.py`.
  - Every public name is in `__all__`, and a test holds it.
    `tests/unit/test_package.py::test_public_names_are_in_all`.
- To `base/testing/tests.md`:
  - One basename per test file across `tests/`, since `tests/` is not a package and mypy, with
    `files = ["src", "tests"]`, refuses a duplicate module. The comment on `INP001` in
    `pyproject.toml`'s per-file ignores. (The ignore itself is in `toolchain.md`.)
  - Tests read the repository's `pyproject.toml` through `pytestconfig.rootpath`, not a path
    counted up from the test file. `tests/unit/test_version.py::test_version_matches_pyproject`.
  - A property's strategy generates only inputs the property is true of, and a known
    counterexample is pinned with `@example`.
    `tests/unit/test_version.py::test_release_pattern_rejects_a_non_numeric_segment`.
  - `tests/conftest.py` exists only when a fixture is shared. Absent from the tree
    (`verification/patchbay-evidence.txt`, section 3).
  - A version or digit pattern uses `[0-9]`, not `\d`, which takes any Unicode decimal digit; a
    confusable character in source is written as an escape, as RUF001 and RUF003 ask, the rules
    kept. `tests/unit/test_version.py`.

**Not written, by decision:** ty replacing mypy (no file behind it; Decisions); the reason half of
a noqa (no file checks it; Decisions).

### Standards retrospective (proposed, base)

Proposals, never local edits; each becomes a pull request to `patchbay-standards`, approved by a
person.

- `base/process/standards-retrospective.md` — "Verify against the code, not against the spec":
  the same holds of a tool's documentation. A rule that rests on how a tool behaves is verified by
  running the tool at its pinned version, on a scratch copy, with the transcript in the spec's
  `verification/`, not by the tool's documentation. A spec that changes the rule reruns the probe.
  Verified against this spec's `verification/patchbay-evidence.txt` section 5 (uv's documented
  condition for its bundled backend, not applied by uv 0.13.7) and the third spec's
  `verification/patchbay-evidence.txt` section 6 (uv's `required-version` refusal, probed).
  `base/python/toolchain.md`'s "In this repository" already says its own rules are reread and
  reprobed. Proposed, not applied; filed as #15.
