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
  (evidence section 5) and was not chosen. **Corrected after the review of PR 16** (below): that
  probe's range held `0.12.24`, one of the versions uv 0.13.7 declares compatible, so it could not
  tell the claims apart; uv's documentation was right, and the rule now says the range contains
  the pinned uv.
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
  the list. **Corrected after the review of PR 16** (below): three of the six are conflicts ruff
  warns of, not findings the tree trips.
- **The gate's tool steps are named here**: format check, lint, types, tests, with patchbay's
  reasons from its toolchain spec's Decisions, one step per tool; the opener and `--locked` are
  cited.
- **"The gate's tools and the hooks run as `uv run --locked`"**, not "every command": patchbay's
  `README.md` names `uv run pre-commit install` and `uv run pre-commit run --all-files` without it,
  and the header of `.pre-commit-config.yaml` the same two. They are the named exception, and the
  hooks they run still use `--locked`. Found reading the tree back, after the plan. **Withdrawn
  after the review of PR 16** (below): there is no exception; the two commands run under
  `--locked`.
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

## Revision after the review of PR 16 (2026-11-06)

The owner's review of PR 16 at `f3fdbf4` (hosted `gate` run 42249866406, success) listed 11
findings in a PR comment. Each was checked against ruff 0.17.4 and uv 0.13.7 on scratch exports of
patchbay `73a583a`, and against uv's source at its `0.13.7` tag where uv's documentation and the
first round's probe disagreed; the dispositions are tabled in `plan.md` under "Revision after the
review of PR 16". Shaped in plan mode with the owner: scope, visuals, references, the snapshot,
the range and patchbay#7 as recommended; the values family-wide, and #15's body edited, the
owner's choices over the recommendations. The decisions that correct or extend the ones above:

- **The whole review, in this spec folder** (owner), as gate specs 2 and 3 did; `standards.md`
  stays the snapshot from shaping (owner).
- **The range contains the pinned uv** (owner; findings 2 and 4). uv 0.13.7's
  `check_direct_build` uses the bundled backend when the range contains the running uv or one of
  `COMPATIBLE_VERSIONS` (`0.9.30`, `0.10.12`, `0.11.33`, `0.12.24`) and no `==` names another
  version; otherwise `uv build` and `uv sync` build through PEP 517 with a uv_build from the
  index, which succeeds online and fails offline (evidence section 5, five cases each way). The
  first round's `>=0.12.0,<0.13.0` held `0.12.24` and could not tell the claims apart: uv's
  documentation was right. A bump inside the minor now changes nothing; a bump past the upper
  bound moves the range in that gate spec. Nothing fails online when the two part, so the range is
  held by reading `pyproject.toml`, as the review says.
- **CPY001 stays** (finding 5, answered by a probe). `ruff rule CPY001` reports it stable since
  0.16.0, not preview, and `ALL` over the tree with the selection reset reports it on all three
  files (evidence section 4). The finding's premise matched an early probe of this revision's that
  overrode `lint.ignore` alone: ruff's command-line `--config` is a layer of its own, an empty
  `ignore` there does not re-enable what the file ignores, and only a `select` in the same layer
  resets it, as `--show-settings` shows (section 4).
- **Two kinds of ignore** (finding 1). The reset run shows `ruff check` and `ruff format` warning
  that D203/D211 and D212/D213 are incompatible, and `ruff format` that COM812 conflicts with the
  formatter; the tree trips CPY001, S101 and INP001. The method now covers both: a finding is
  ignored where the rule is wrong for the tree, a conflict so the choice is written down.
- **3.12 and 100 are the family's** (owner; finding 6). Changing either is a change to this
  standard first; each project's gate spec follows its sync. The review's per-project values were
  not taken.
- **`--locked` everywhere, no exception** (finding 7). With a ruff pin edited and `uv lock` not
  run, `uv run --locked pre-commit --version` refuses, plain `uv run` rewrites `uv.lock` to
  `0.17.3` and runs, and `uv run --locked pre-commit install` and `run --all-files` work on a fresh
  lock (evidence section 8). patchbay's README and hook header say plain `uv run`: a comment on
  fromtheoutfit/patchbay#7 (owner).
- **`.python-version` is the second exception** (finding 8): uv reads it to choose and fetch the
  interpreter (patchbay's README, line 48), and `uv init` writes it (evidence section 6).
- **`--strict-config` stands on its own reason** (finding 3): with it pytest exits 4 on `-o` of an
  unknown key, without it only warns (evidence section 9). `verification-gate.md`'s "A key the tool
  does not know is not refused" is too general for pytest under this flag, proposed below;
  patchbay's comment citing it goes in the same comment on #7.
- **Step 5a and 5b** (finding 9): the heading says the tier is always included in a consuming
  project, the template's line names the tier, and Step 5b leaves it out of what it proposes here.
  Outside the gate task.
- **Named, and short** (findings 10 and 11): `scripts/sync-standards.sh --check` for "the drift
  check"; the CHANGELOG Added entry cut to the file, the spec, the evidence and the follow-ups;
  the index description tightened and corrected. PR 16's body is rewritten to match.
- **#15's body is edited** (owner) to the corrected case and the wider rule below, since the case
  it cited was wrong.
- **The evidence script removes nothing**: every export and output directory is a fresh
  `mktemp -d` under the scratch directory, and a probe file is moved out of its export after its
  run.

## Context

- **Visuals:** None.
- **References:** `references.md`.
- **Product alignment:** N/A (no `agent-os/product/`).

## Standards Applied

**Core (Step 5a, consuming projects):**

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
  cache). Issues opened, edited and commented on as the owner chose, with no attribution (listed
  under "Not done by the agent").
- `process/standards-sync` — how the file reaches a consuming project, as
  `agent-os/standards/base/python/toolchain.md`, and its index entry with the `base:` section.

## Verification Gate

Spec is not complete until `scripts/gate.sh` passes — `bash -n` on every shell script under
`scripts/` as git lists them, `pymarkdown`, installed at its pin through `uvx` as its own check,
over the `.md` files under `base/` and `README.md` as git lists them, and
`scripts/check-index.sh` — and the three judgment steps are recorded, in this order: Docs,
Version, then the standards retrospective below.

**Results (2026-11-06, after the review of PR 16):** `scripts/gate.sh` exit 0 on the tree, run as
the last act before hand-over on branch
`feature/4-write-basepythontoolchainmd-one-tool-per-job-pyprojecttoml-the-only-config`;
`verification/gate-run.txt` holds the one transcript, the date and the branch on its first line.
`base/python/toolchain.md` is tracked since the owner's commit `f3fdbf4`, so step 3 reads it on the
tree (6 standards) and pymarkdown lints it among seven files. The first round's two transcripts,
the tree with the file untracked and a git-added copy green, are replaced by this one. No gate file
changed in either round (the gate script, the scripts it runs, the pin, `.pymarkdown.yaml`, the
workflow and the gate task in `shape-spec.md`), so no negative test was rerun.
`verification/patchbay-evidence.txt`, regenerated after the review, holds what the rules were read
from and the probes: 37 commands in nine sections.

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

After the review of PR 16, every changed sentence of `toolchain.md` read back against the evidence
and patchbay's files:

- "Every tool runs as `uv run --locked`": section 8 (the refusal, the rewrite to `0.17.3`, the hook
  installed and run) and section 3's README and hook-header lines, which patchbay has yet to change
  (#7).
- "Two exceptions": the README's line 48 and section 6 (`.python-version` written, `3.12`).
- The three build bullets: section 5 (the source's lines 40, 330–332 and 352–355, and the five
  cases offline and online for `uv build` and `uv sync`), section 6, `pyproject.toml` lines 30 and
  38, and uv's page for the upper bound.
- "The floor is the family's" and the width: the owner's decision; lines 60, 63 and 99.
- The ruff method and the six entries: section 4's reset run (two warnings from `ruff check`, three
  from `ruff format`, 13 findings), the settings lines and the rule metadata.
- `--strict-config`: section 9. `scripts/sync-standards.sh --check`: `standards-sync.md`.

`shape-spec.md`: the Step 5a heading, Step 5b's new sentence and the template's line read
together, and the gate task is untouched. `index.yml`: the description against the revised
standard, PyYAML reads it, no `: ` and no ` #`, and `check-index.sh` agrees on the tree.
`CHANGELOG.md`: the cut entry against the spec folder. Searched the standard for the replaced
wording ("drift check", "uv run pre-commit", "as the gate standard asks", "configure no tool",
"whatever the range", "lower bound the uv", "tripped six"): none remains. No line of the changed
files exceeds 100 characters but the pre-existing ones of `shape-spec.md`.

**Version (step 5):** recorded under `[Unreleased]` in `CHANGELOG.md`: the Added entry for this
spec, cut after the review of PR 16 to the file, the spec, the evidence and the follow-ups
(fromtheoutfit/patchbay#7 and #15), and saying it was revised after the review; Changed lines for
the `verification-gate.md` pointer, `shape-spec.md`'s Step 5a, 5b and template as revised, and
`index.yml`. The repository has no version number to bump.

**Not done by the agent, by rule:** no file staged, committed or pushed, no pull request opened;
the owner reads the diff at commit time, committed the first round as `f3fdbf4` and opened PR 16.
On GitHub, each as the owner chose and with no attribution: fromtheoutfit/patchbay#7 opened, and
commented on after the review; #15 opened, and its body edited after the review; PR 16's title and
body rewritten at the owner's request, and its body again after the revision.

## Standards Retrospective

Step 6, always last. Per `base/process/standards-retrospective.md`. Applied 2026-11-06 from the
shipped diff against `main` (`f877544`), and again after the review of PR 16 from the revised diff
against `f3fdbf4`: `base/python/toolchain.md` (new),
`base/process/verification-gate.md`, `.claude/commands/agent-os/shape-spec.md`, `index.yml`,
`CHANGELOG.md`, and this spec folder. The new standard, the pointer in `verification-gate.md` and
the Step 5a tier are this spec's feature work, written from patchbay's files and the probes, not
retrospective edits; the questions are asked of everything the diff touched.

1. *A pattern no standard covers?* Two. The first is the deferred inventory below: rules patchbay
   ships that no standard holds yet, kept out of this one by the owner's scope. The second is a
   method this spec used and the third spec (issue #12) used before it: a rule that rests on how
   a tool behaves is verified by running the tool at its pinned version on a scratch export, with
   the transcript in `verification/`. The review of PR 16 sharpened it twice: the first round's uv
   probe used a range that could not tell uv's documentation from the conclusion drawn, and an
   early ruff probe's setup did not do what it claimed. So a probe's cases are chosen to tell the
   claims apart, its setup is shown to have done what it claims, and where a probe and the
   documentation disagree the tool's source at the pinned version decides. Proposed below, as #15.
2. *A standard wrong or stale?* One pointer, made true as feature work:
   `verification-gate.md`'s "cited here when it ships" now cites the standard that shipped.
   Nothing else read stale. The issue body's wording (bare `uv run`, the hook order, a literal
   backend version, ty) is the issue's, not a standard's, and the tree won. After the review, three
   of this spec's own first-round reasons were wrong (the bundled backend, conflict warnings read
   as findings, the `--strict-config` citation), each fixed in the standard as feature work; and
   `verification-gate.md`'s "A key the tool does not know is not refused" is too general, since
   pytest under `--strict-config` refuses one. Proposed below.
3. *A deliberate deviation?* None from the standards as they read. Met again, not changed: a spec
   that adds a file under `base/` cannot show step 3 green on its own tree before the owner stages
   it. The first round's `gate-run.txt` kept the two transcripts the fifth spec (issue #8) used,
   and that spec's proposal for `verification-gate.md`, what such a spec records, is still open and
   not repeated here. After the owner's commit, the revision's run is on the tree.
4. *A moved pointer?* None moved. The pointer added is in Decisions. `toolchain.md` names patchbay
   files by path at `73a583a`; a later patchbay spec that moves one is caught by the Docs step of
   #7's spec, which reads the standard against its tree. The review found "the drift check", a
   term no standard defines; the standard now names `scripts/sync-standards.sh --check`.

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
  the same holds of a tool's documentation and of a probe. A rule that rests on how a tool behaves
  is verified by running the tool at its pinned version, on a scratch copy, with the transcript in
  the spec's `verification/`. The probe's cases are chosen so they can tell the competing claims
  apart, its setup is shown to have done what it claims, and where a probe and the documentation
  disagree, the tool's source at the pinned version decides. A spec that changes the rule reruns
  the probe. Verified against this spec's `verification/patchbay-evidence.txt`: section 5 (uv's
  documented condition, the first round's range that held `0.12.24`, the source's
  `COMPATIBLE_VERSIONS`, and five cases that tell the claims apart) and section 4 (a command-line
  `lint.ignore` that does not reset the file's, shown by `--show-settings`); and the third spec's
  section 6 (uv's `required-version` refusal, probed). Proposed, not applied; filed as #15, its
  body edited after the review of PR 16.
- `base/process/verification-gate.md` — "Every step that can fail is proven to fail": "A key the
  tool does not know is not refused, so the changed value is what shows the file is read" holds of
  pymarkdown and not of every tool: pytest under `--strict-config` refuses one (exit 4). The
  changed value stays the proof that a file is read; the sentence says some tools do not refuse an
  unknown key, rather than that none does. Verified against this spec's
  `verification/patchbay-evidence.txt` section 9 and patchbay's `pyproject.toml` `addopts`.
  Proposed, not applied.
