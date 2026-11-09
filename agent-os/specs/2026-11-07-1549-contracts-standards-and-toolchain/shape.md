# The Contracts Standards and the Toolchain Corrections (issue #21) — Shaping Notes

Shaped 2026-11-07 in plan mode with `/agent-os:shape-spec`. The owner answered the Step 1, 2, 3
and 5 questions and two design questions, recorded under Shaping answers; Step 4 was skipped, this
repository having no `agent-os/product/`.

## Core Architecture (Non-Negotiable)

`base/python/toolchain` — applies to consuming projects; this repository has no package, so it
does not apply here (Step 5a). This spec adds `base/python/layout`, `base/python/typing` and
`base/python/models` to the tier; none of the four applies here.

## Scope

GitHub issue #21, "Standards spec: write base/python models, errors, events, testing, typing and
layout from patchbay's contracts spec, and correct toolchain.md", as revised 2026-11-07. Six new
base standards, `base/python/layout.md`, `typing.md`, `models.md`, `errors.md`, `events.md` and
`base/testing/tests.md`, and the two corrections to `base/python/toolchain.md` (#21 proposals 7
and 8), every rule written from fromtheoutfit/patchbay at `origin/main` (`7471387`): `src/patchbay/`,
`tests/unit/`, the contracts spec folder and its revision, their probes and the revision's
`footing.py`. All six indexed, `python/toolchain`'s description revised, `layout`, `typing` and
`models` added to Step 5a of this repository's `shape-spec.md`, one CHANGELOG entry. No gate file
changes. Gate green, `verification/gate-run.txt` with date and branch, present-and-file for any
proposal; no stage, commit, push or pull request by an agent.

## Shaping answers

- **Step 1, scope:** as stated above, with every probe a rule rests on rerun at patchbay's pins on
  a scratch export, new probes where patchbay has none, and the harness rerun under the fixture
  rule, since `base/` gains files and a directory.
- **Step 2, visuals:** none.
- **Step 3, references:** patchbay at `7471387` (`src/patchbay/*`, `tests/unit/*`, both contracts
  spec folders); `base/python/toolchain.md` as the shape every new standard takes and the file
  corrected; the toolchain spec, for the rules it deferred and its evidence form
  (`references.md`).
- **Step 4, product context:** `agent-os/product/` does not exist here. Skipped.
- **Step 5, standards:** the five under `base/process`, feature-specific, in `standards.md`.
  `python/toolchain` is Step 5a and does not apply here; its text as shaped is in
  `references.md`, since this spec corrects it.
- **patchbay's follow-up** (owner): the work patchbay does after its sync is added to
  fromtheoutfit/patchbay#12's body in place, a "Revised 2026-11-07" paragraph, not a comment, and
  #12 is named in the CHANGELOG entry. patchbay's next sync is planned after #21 and #22 merge, so
  one sync brings all of it, and #12's spec takes the Step 5a and Docs work too.
- **Suppressions** (owner): the reason half is written, "each with its reason beside it",
  verified against the four suppressions in patchbay's `src/`. No tool checks the reason; review
  does.

## Decisions

- **GitHub issue #21 is the scope, read as it stands: revised 2026-11-07 after the review of
  fromtheoutfit/patchbay#11** (updated 2026-11-07T20:39:13Z). Its eight proposals are the
  inventory; the rules are written from patchbay's shipped files and from probes rerun here, never
  from the proposals' text. Its "Depends on" is met: patchbay#11 merged as `7471387`. The owner's
  arguments override its text in two places:
  - **The test standard is `base/testing/tests.md`**, not `base/python/testing.md`: how a test is
    written is not Python's alone, and it is the path the toolchain spec deferred its test rules
    to. `base/` gains the folder `testing/`.
  - **`models` joins `layout` and `typing` in Step 5a.**
- **The rules come from #21's proposals and the toolchain spec's deferrals** to `layout.md` and
  `tests.md`. What the tree shows that neither names is not added silently; the retrospective
  records it.
- **Each standard takes `toolchain.md`'s shape**: a header naming the commit and spec folders it
  was written from; rule sections, each bullet a rule with its named exceptions, ending "Verified
  against" its file, the test that holds it and the probe a tool's behaviour rests on; then "In
  this repository" (no package; it does not apply) and "In a consuming project". No "consider", no
  "prefer".
- **A rule that would need a second adapter to be true is left out** and listed under Deferred.
- **One home per rule, a pointer from the other topic.** Each standard keeps to its topic: layout
  is where things live, typing the type system's rules, models `PatchbayModel` and its guarantees,
  errors the hierarchy and what escapes, events `Event`, the bus and `Subscriber`, tests how a
  test is written and the contract suite. Where a rule fits two:

  | Rule | Home | Pointer from |
  | --- | --- | --- |
  | `frozen=True` as the class keyword, which mypy reads | models | typing |
  | No `from __future__ import annotations` where pydantic reads annotations | typing | models |
  | Re-export through `__all__` under `implicit_reexport = false` | typing | layout |
  | `Subscriber[E: Event]`, contravariant | events | typing |
  | `Subscriber` beside the bus, breaking the events and contracts cycle | layout | events |
  | The errors module a leaf, its fields plain values | errors | layout |
  | `ContractViolationError(AssertionError)` with fields | tests | errors |
  | A coded `# type: ignore` in a test holding a refusal | tests | toolchain |
  | Every suppression coded, with its reason | toolchain | models, events |
  | A third party's method wrapped, never restated | models | toolchain |
  | A package imported directly is declared | toolchain | errors |
- **The evidence is this spec's own**: `verification/patchbay-evidence.txt` (the commit, the
  export, the cited tests run by node id, the wheel's files), `verification/probes.txt` (patchbay's
  probes rerun at its pins, and the new ones), `verification/gate-run.txt`, and the harness rerun,
  `verification/gate-negative-tests.txt` and `verification/ci-negative-test.txt`.
- **Step 5a here**: the tier lists the four with the note that they apply to consuming projects;
  Step 5b's note and prompt and the `shape.md` template's two lines say the same. None of these is
  the gate task, so no gate file changes.

## Deferred

Rules that would need a second adapter to be true, each left out until one ships:

- How an adapter's own errors relate to `PatchbayError`: a root of its own beneath it, or
  `PatchbayError`'s subclasses directly (errors).
- That an adapter's own models derive from `PatchbayModel`. The mechanism is written: a model that
  derives from the base has the promise at any depth, which a test holds (models).
- What modules an adapter package holds (layout).
- Whether an adapter defines events of its own (events).
- An adapter's `conftest.py` returning its own instrument from the `instrument` fixture on the
  `bus` fixture, and where its contract run lives; the `integration` marker's use (tests).

## Context

- **Visuals:** None.
- **References:** `references.md`.
- **Product alignment:** N/A.

## Standards Applied

**Core (Step 5a, consuming projects):**

- `base/python/toolchain` — not applied here: no package (Step 5a). Corrected by this spec.

**Feature-specific:**

- `base/process/standards-retrospective` — the rules are verified against shipped code and probes
  rerun at the pinned versions; any base proposal goes to the owner and upstream.
- `base/process/standards-index` — six new keys, each description saying what the standard decides.
- `base/process/verification-gate` — the gate run, two transcripts for new files under `base/`,
  and the harness rerun when a spec adds files under a directory it copies.
- `base/process/standards-sync` — the CHANGELOG entry names patchbay and the work its gate spec
  after the sync takes.
- `base/process/ownership` — no stage, commit, push or pull request; issue text with no
  attribution, changed only after the owner approves it.

## Verification Gate

Spec is not complete until `scripts/gate.sh` passes — `bash -n` on every shell script under
`scripts/` as git lists them, with no tracked file a `.gitignore` ignores, `pymarkdown`, installed
at its pin through `uvx` as its own check, over the `.md` files under `base/` and `README.md` as
git lists them, and `scripts/check-index.sh` — and the three judgment steps are recorded, in this
order: Docs, Version, then the standards retrospective below.

**Results (2026-11-07):** `verification/gate-run.txt`, on branch
`task/21-standards-spec-write-basepython-models-errors-events-testing-typing-and-layout-from-patchbays-contracts-spec-and-correct-toolchainmd`,
the last thing done before hand-over, holds two runs, as "Every step that can fail is proven to
fail" directs for a spec that adds files under `base/`. On the tree, steps 1 and 2 pass, pymarkdown
finding nothing in 13 files, and step 3 fails, exit 1, naming the six new standards, untracked, and
their six entries: an agent never stages. On a scratch copy of the tree with every file git-added,
the gate exits 0, step 3 agreeing on 12 standards. The owner's `git add` of the six turns the tree's
run green. No gate file changed, so no negative test was added; the harness was rerun whole, all
cases and j, under the fixture rule, since `base/` gained six files and the folder `testing/`, which
`mk` copies: 194 runs and 2 runs, 0 unexpected each (`verification/gate-negative-tests.txt`,
`verification/ci-negative-test.txt`). Its first run reported nine runs `UNEXPECTED`, every one the
same pymarkdown finding in the clean copies, MD018 on a wrapped line of `base/python/toolchain.md`
beginning `#21`: a defect in the tree, fixed at its cause by rewording the line, and the run was
not kept. The other verification files:

- `verification/patchbay-evidence.txt`: `7471387` is `origin/main` and `ls-remote`'s `main`, and its
  tree is the checkout's; the export synced at patchbay's pins; the whole suite, 270 passed; the 77
  tests the seven standards cite, found by name and run by node id, 200 cases passed; 23 cited
  helpers and names, each found; the wheel's files and the modules an import loads; ruff and mypy
  clean; the four suppressions in `src/` and six in `tests/`.
- `verification/probes.txt`: eleven of patchbay's probes rerun verbatim, each output identical to
  its record; the new probes a to o, each source shown before its output.

**Docs (step 4):**

- **`README.md`:** three lines, the repository's purpose; reads true.
- **`CLAUDE.md`:** names no standard by topic and no Step 5a tier; its gate paragraph and its
  account of `base/` read true.
- **`.claude/commands/agent-os/shape-spec.md`:** Step 5a, Step 5b's note and prompt and the
  `shape.md` template's two lines name the four, as feature work; the gate task and its template
  paragraph are untouched.
- **`base/python/toolchain.md`:** corrected as feature work. Its other sections were read against
  patchbay at `7471387`: between `3f910d8` and `7471387` patchbay changed only `[project]
  dependencies`, not `scripts/`, `.pre-commit-config.yaml`, `.python-version`, `.gitignore`,
  `.github/` or any `[tool.*]` section, so "The gate's tool steps", the ignore list, "pytest and
  hypothesis" and "pre-commit" read true. Its header and "In this repository" name `7471387`.
- **`base/process/verification-gate.md`:** "A consuming project's tool steps ... are
  `base/python/toolchain.md`'s" reads true. "In this repository" says the spec that last changed
  the harness holds the current transcripts: true of the harness, which this spec did not change;
  where a rerun under the fixture rule keeps its transcripts is unsaid, proposal 4 below.
- **`base/process/standards-sync.md`:** Step 5a is not a gate file, but the work a consuming project
  does after the sync is named as its rule asks for gate files: the CHANGELOG entry names patchbay
  and #12, revised in place. Reads true.
- **`base/process/standards-index.md`:** every file under `base/` is a `.md` and indexed, keys
  alphabetical, each description one line with no `: ` and no ` #`; read back as YAML, twelve
  entries. Reads true.
- **`base/process/standards-retrospective.md`:** its example project standard,
  `agent-os/standards/testing/fixtures.md`, sits in a project's own `testing/` folder and
  `testing:` section, beside the synced `agent-os/standards/base/testing/tests.md` and its key
  `testing/tests`, so nothing collides. Reads true.
- **The six new standards:** every `base/...md` each names exists; every patchbay file, test,
  helper and probe each cites is found at `7471387` (`verification/patchbay-evidence.txt`,
  `verification/probes.txt`); none says "consider" or "prefer".
- **fromtheoutfit/patchbay#12:** retitled to name #21 and its body revised in place as the owner
  chose, the text approved first; read back identical (2026-11-07T21:12:38Z). No attribution.

**Version (step 5):** the thirteenth spec's entry under `[Unreleased]`, `### Added`, in
`CHANGELOG.md`, naming each new standard, toolchain.md's corrections, `index.yml`, Step 5a, the
harness rerun, patchbay#12 and the proposals' issue. This repository has no version to bump.

## Standards Retrospective

Step 6, always last, from the shipped diff against `b89838c`.

1. *A pattern no standard covers?* Two in how this spec verified its standards, and two in the
   tree it read that #21 did not carry:
   - each test a standard cites was found by name and run by node id on an export at the commit
     the standard names, and the project's recorded probes rerun verbatim and compared: no
     standard asks for either (proposal 1);
   - the harness rerun under the fixture rule kept its transcripts here: the rule says when to
     rerun, not where the run is kept (proposal 4);
   - patchbay ships `py.typed` (proposal 2), and its contracts spec decided that every public
     method that changes state has a test asserting its event (proposal 3). The scope decision
     kept both out of this spec's standards; each is proposed instead.
2. *A standard wrong or stale?* `base/python/toolchain.md`, as #21 said: its empty-dependencies
   example and "patchbay has none yet", corrected as feature work. No other standard read stale
   (Docs, above).
3. *A deliberate deviation?*
   - **Deviation, not a standard change:** where the owner's arguments override #21's text, the
     test standard's path (`base/testing/tests.md`) and `models` in Step 5a. Decisions, above.
   - **Deviation, not a standard change:** #21 proposal 8's "PLR2004 and D401, which the revision's
     tree tripped, were [fixed in the code]" is written for D401 alone. Probe b shows D401 reports
     the contract tests' first-round docstring once unprefixed. PLR2004 reports a magic value in a
     comparison and not one in arithmetic, and the one constant the revision added for a literal,
     `_SECONDS_PER_MINUTE`, is used in arithmetic, so the shipped tree shows no PLR2004 fix. The
     claim rests on the revision's record, not its code, and is left out.
   - **Deviation, not a standard change:** the rules that would need a second adapter to be true
     are left out (Deferred, above).
4. *A moved pointer?* None. `toolchain.md`'s pointers into patchbay (`tests/unit/test_package.py`,
   `pyproject.toml`'s sections, the uv-lock diffs) resolve at `7471387`.

No project standard exists to edit. `index.yml` gained its six entries and `python/toolchain`'s
description as feature work; the retrospective edited no file under `base/` and no index entry.
Its own change set is this section and the CHANGELOG entry's "Proposals sent upstream" line.

Proposals sent upstream: fromtheoutfit/patchbay-standards#24

### Standards retrospective (proposed, base)

Presented to the owner on 2026-11-07 with AskUserQuestion, multi-select, in two questions (1 to 3,
then 4), each ending with "None of these". All four were approved and filed as one issue,
fromtheoutfit/patchbay-standards#24, a standards spec, since none needs a gate file changed. It has
one section per proposal with its verification pointers, a "Depends on" naming this branch and
patchbay at `7471387`, and the rules its spec is held to. No AI attribution. Read back from GitHub,
identical but for the final newline `gh` drops (2026-11-07T21:12:56Z).

1. `base/process/standards-retrospective.md`, "Verify against the code, not against the spec": a
   base standard written from a consuming project's files is checked against that project at the
   commit it names. Every test it cites runs by node id on an export of that commit, found by
   name, and every helper and name it cites is found; the project's recorded probes a rule rests
   on rerun verbatim from its transcripts at its pins, each output compared with its record.
   Verified against `verification/patchbay-evidence.txt` (section 3) and `verification/probes.txt`
   (section 1). Proposed, not applied; filed as fromtheoutfit/patchbay-standards#24.
2. `base/python/layout.md`: the package ships `py.typed`, empty, beside its `__init__.py`, so a
   consumer's mypy reads its inline types (PEP 561). Verified against patchbay's
   `src/patchbay/py.typed`, the wheel's files (`verification/patchbay-evidence.txt`, section 4) and
   its `agent-os/product/tech-stack.md`; the probe of a consumer's mypy with and without it is the
   landing spec's. Proposed, not applied; filed as fromtheoutfit/patchbay-standards#24.
3. `base/testing/tests.md`: every public method that changes state has a test asserting the event
   it publishes, once, and one that a refused call publishes none; the event mechanism's own
   methods assert delivery. Verified against patchbay's contracts spec Decision and
   `tests/unit/testing/test_fake.py` (`test_set_stores_the_value_then_publishes_parameter_changed_once`,
   `test_a_refused_set_changes_nothing_and_publishes_nothing` and four beside them) and
   `tests/unit/test_events.py`. Proposed, not applied; filed as
   fromtheoutfit/patchbay-standards#24.
4. `base/process/verification-gate.md`, "Every step that can fail is proven to fail": a rerun under
   the fixture rule keeps its transcripts in the rerunning spec's `verification/`, one run each, its
   header naming the files added and that no gate file changed; "In this repository" says where
   the latest run is. Verified against `verification/gate-negative-tests.txt` and
   `verification/ci-negative-test.txt`, whose first run caught the MD018 defect. Proposed, not
   applied; filed as fromtheoutfit/patchbay-standards#24.
