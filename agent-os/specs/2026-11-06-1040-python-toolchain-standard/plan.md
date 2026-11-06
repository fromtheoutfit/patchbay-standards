# Issue #4: write base/python/toolchain.md

## Context

Issue #4 asks for the first standard every Python patchbay package follows: one tool per job,
with `pyproject.toml` as the only config file. The issue body is the earlier intent. The issue
comment is the inventory of what patchbay shipped, now merged at `origin/main` `73a583a` (equal to
`ls-remote`). Where they differ, the shipped tree wins. Pin placement, locking, `[tool.uv]
required-version`, the `[tool.*]` gate-file split, `uv sync --locked` and CI are already in
`base/process/verification-gate.md` (issue #12). This standard cites them and does not restate
them. Branch: `feature/4-write-basepythontoolchainmd-one-tool-per-job-pyprojecttoml-the-only-config`.

## Shaping answers (owner, 2026-11-06)

- **Step 1, scope:** tooling only. These go to `shape.md`'s retrospective as **deferred**:
  - to `base/python/layout.md`: the package-surface rules (`__version__` from
    importlib.metadata with no fallback, imported installed; private import binding; `__all__`
    held by a test);
  - to `base/testing/tests.md`: the test-writing rules (one basename per test file,
    `pytestconfig.rootpath`, a strategy generating only inputs its property is true of with
    `@example`, `conftest.py` only for a shared fixture, `[0-9]` not `\d`, confusables written as
    escapes with RUF001/RUF003 kept).

  A pytest or hypothesis *configuration key* stays in toolchain.md.
- **Step 2, visuals:** none. **Step 3, references:** the named patchbay files plus the comment's
  proofs (`src/patchbay/__init__.py`, `tests/unit/*.py`, `.python-version`, `.gitignore`,
  `verification/wheel-license.txt`). **Step 4:** no `agent-os/product/`, so skipped. **Step 5:**
  all five `process/*` standards, feature-specific.
- **Layout:** `##` rule sections, then a short `## In this repository` (no package, the standard
  does not apply) and `## In a consuming project` (every rule above is the project's).
- **Build backend:** the range as shipped, `uv_build>=X.Y.Z,<X.(Y+1).0`. Its floor is the uv that
  `required-version` pins, so uv builds with its own bundled backend, as uv's build-backend docs
  say. A uv bump past the range moves the range in the same spec.
- **Split:** toolchain.md owns which tool does which job, what each `[tool.*]` section says, and
  the order of a consuming project's tool steps. verification-gate.md's sentence "The standard
  that names a repository's steps is cited here when it ships" is changed to cite toolchain.md, a
  one-line pointer edit made as this spec's feature work.
- **noqa:** only the code half is a rule: `# noqa: <code>`, never blanket. PGH004 and RUF100 under
  ALL enforce it, and I probe both. The reason half is left to the gate standard's "reviewed as the
  loosening it is". The rule says patchbay has no noqa yet.
- **ty:** left out. `shape.md` records the intent.
- **Step 5a here:** list toolchain with a note that it applies to consuming projects. A spec here
  records it under Core Architecture as not applying and does not copy it into `standards.md`. The
  "empty for now" wording is rewritten to match.
- **patchbay follow-up:** open an issue in fromtheoutfit/patchbay, with no attribution, for its
  Step 5a and `tech-stack.md` citation after its sync.

## Task 1: Save spec documentation

`agent-os/specs/2026-11-06-<HHMM from date at save>-python-toolchain-standard/` contains:

- `plan.md`: this plan.
- `shape.md`: the template.
  - Core Architecture: "None at shaping; this spec adds `base/python/toolchain`, which applies to
    consuming projects".
  - The **first Decision cites issue #4** as the scope, with the body as intent, the comment as
    the inventory, and the tree winning.
  - Then the answers above as Decisions, with the build-backend and split reasons.
- `standards.md`: the full text of the five `base/process/*.md` as they read now.
- `references.md`: patchbay at `73a583a`, file by file; uv's build-backend docs
  (docs.astral.sh/uv/concepts/build-backend/); the process standards as the shape to follow.

## Task 2: Evidence (`verification/patchbay-evidence.txt`)

Record by command:

- patchbay's `origin/main` and `ls-remote` agree on `73a583a`.
- The lines each rule cites, via `git show origin/main:<path>` / `grep -n`.
- Probes on a scratch export, `git archive origin/main`, run with `uv sync --locked` and
  `uv run --locked ruff check`:
  - a blanket `# noqa` is refused by PGH004;
  - a `# noqa: <code>` that suppresses nothing is refused by RUF100;
  - a `sys.version_info < (3, 11)` branch is refused by UP036;
  - a `typing_extensions` import of a name `typing` has at 3.12 is refused by UP035.
- `uv build --offline --no-cache` on the export: it passes at the shipped range, and fails with
  the range moved off 0.13 (does the bundled backend need the index?).

A rule is written only as strongly as its probe shows. Where a probe is inconclusive, the reason
cites uv's docs and the probe's output is recorded as it came out.

## Task 3: Write `base/python/toolchain.md`

Every rule names the consuming-project file it is verified against. Each rule has its named
exceptions, and none says "consider" or "prefer". Lines stay at or under 100 columns.

- **Intro:** the standard was written from patchbay `73a583a` and its two toolchain specs. Pins,
  locking, `required-version`, which sections are whose, and CI are `verification-gate.md`'s.
- **One tool per job:**
  - uv for environments, dependencies, the lockfile and the build; `uv.lock` is committed
    (`.gitignore`, git ls-files);
  - ruff lints and formats (no black);
  - mypy checks types;
  - pytest runs tests, and hypothesis supplies property inputs under pytest;
  - pre-commit runs the hooks, and the gate never runs it.

  The gate's tools and the hook entries run as `uv run --locked` (gate.sh,
  `.pre-commit-config.yaml`). The person's one-time `uv run pre-commit install` is named as the
  exception.
- **pyproject.toml is the only config file:** `[tool.*]` and nowhere else; the header's list of
  absent files. Named exception: `.pre-commit-config.yaml`, which only registers hooks, because
  pre-commit cannot read them from `pyproject.toml`. `.python-version` names the interpreter and
  `uv.lock` is the resolution.
- **The build:**
  - the uv_build range, floored at the pinned uv, with the reason;
  - `[tool.uv.build-backend] module-name` when the import name differs from the distribution
    name;
  - `license` as SPDX, with `license-files = ["LICENSE"]` stated (no default glob; patchbay's
    `wheel-license.txt` and its license-file test).
- **Python 3.12 is the floor:** `requires-python`, `.python-version`, ruff `target-version` and
  mypy `python_version`, raised together in one spec, which is the gate's own spec since two of
  the four are `[tool.*]`. The code is written for the floor: the UP rules under ALL, per the
  probes. A backport fails the dependency Decision.
- **Dependencies:**
  - adding one is a Decision: what it does, why the standard library cannot, its license
    (`pyproject.toml` header, the toolchain spec);
  - it is added by the spec that uses it (`dependencies = []`);
  - the dev group's non-gate entries take the gate pins' form (exact, with a date).
- **ruff:**
  - `target-version` and `line-length = 100`, with their reasons;
  - `select = ["ALL"]` and the ignore-list method: fix the code where the rule is right, ignore
    only where it is wrong, one comment per rule, nothing from memory (ISC001 and PLR2004 not
    listed);
  - patchbay's six entries (D203, D213, COM812, CPY001; S101 and INP001 under `tests/**`) as the
    starting list, each with a reason that holds for every package;
  - the coded-noqa rule;
  - the rule set changes in the gate's spec, cited.
- **mypy:** strict over `src` and `tests`; `python_version`; `warn_unreachable`;
  `implicit_reexport = false` stated. One override per untyped package with a comment, never a
  global ignore. None exists yet; that is the named exception.
- **pytest and hypothesis:** `testpaths`; `-q --strict-markers --strict-config` with reasons;
  markers registered with their meaning; nothing more until a spec needs it. hypothesis has no
  section.
- **pre-commit:** two `repo: local` hooks, `ruff check --fix` then `ruff format` (ruff's order,
  which the tree reverses from the issue), with `language: system`, `types_or`,
  `require_serial: true`, and `minimum_pre_commit_version` set to the dev pin. No mirror, never
  mypy or pytest, and the person installs the git hook.
- **The gate's tool steps:** after step 1 and before the drift check: format check, lint, types,
  tests, one step per tool, each with patchbay's reason. The `uv sync --locked` opener and the
  `--locked` form are the gate standard's (scripts/gate.sh).
- **In this repository / In a consuming project:** as answered. Synced in as
  `agent-os/standards/base/python/toolchain.md`, it is in the project's own Step 5a.

## Task 4: Point the gate standard at it

In `base/process/verification-gate.md`, the sentence "The standard that names a repository's steps
is cited here when it ships." becomes a sentence saying a consuming project's tool steps and their
order are `base/python/toolchain.md`'s. This is a pointer, so the `process/verification-gate`
index description is unchanged.

## Task 5: shape-spec Step 5a, and the index

- In `.claude/commands/agent-os/shape-spec.md`, outside the gate task:
  - Step 5a lists `base/python/toolchain` with the consuming-project note and "recorded, not
    copied" here;
  - Step 5b's "(Step 5a) is empty for now" prompt and "once it exists" are rewritten;
  - the shape.md template's Core Architecture line and its "Core (always applied)" line are
    rewritten.
- `index.yml` gets `python/toolchain` after `process/*`, sorted, with a one-line description of
  what it decides (no `: `, no ` #`).

## Task 6: patchbay issue, CHANGELOG, shape.md

- Open the fromtheoutfit/patchbay issue. After the sync that brings toolchain.md in:
  - Step 5a of its `shape-spec.md` lists it, and the template lines follow;
  - `agent-os/product/tech-stack.md` cites it;
  - that spec's Docs step reads it against the tree.

  No attribution.
- `CHANGELOG.md [Unreleased]`:
  - an Added entry for the eighth spec (issue #4) and `base/python/toolchain.md`, naming the
    issue;
  - Changed lines for the `verification-gate.md` pointer, shape-spec's Step 5a, 5b and template,
    and `index.yml`.
- `shape.md`:
  - Docs: every toolchain.md sentence read back against the patchbay file it names; CLAUDE.md
    ("follows the standards under base/") and README read true unchanged.
  - Version.
  - Retrospective: the deferred inventory, each item with its target file and its patchbay proof;
    ty and the noqa reason half; "no gate file changed, no negative test rerun".

## Task 7 (final): Verification gate

1. Steps 1–3: `scripts/gate.sh` is the last act.
   - `verification/gate-run.txt` starts with the date and branch, and holds two transcripts, run
     under `bash -c` for `PIPESTATUS`:
     - (1) the tree: step 3 names the untracked `base/python/toolchain.md` and its entry;
     - (2) a scratch copy, git-added in the `mk` pattern of `scripts/gate-negative-tests.sh`:
       exit 0, 6 standards.
   - No `git add` is done to make the tree pass. No gate file changes, so the negative tests are
     not rerun.
2. Steps 4–6 (Docs, Version, Retrospective) are recorded in `shape.md`, in that order.

Then stop and print `git status --short`. In the hand-over:

- list the retrospective's files separately;
- say that the owner's `git add base/python/toolchain.md` turns the tree run green;
- give the patchbay issue's number.

Nothing is staged, committed or pushed, and no PR is opened. After that, save a feedback memory:
a base standard keeps to its topic, and layout and test-writing rules wait for their own standard.
