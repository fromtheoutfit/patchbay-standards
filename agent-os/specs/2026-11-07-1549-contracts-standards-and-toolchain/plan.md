# Issue #21: six base standards from patchbay's contracts, and toolchain.md corrected

## Context

fromtheoutfit/patchbay#10 shipped the first code in core: the `Instrument` protocol, the models,
errors, events and their bus, and `FakeInstrument` with the contract tests. It merged as patchbay
PR 11, so `origin/main` is `7471387`, whose tree is the same as `f5023c5`. The contracts spec and
its revision after PR 11's review recorded eight base proposals. The owner approved them, and they
are filed as fromtheoutfit/patchbay-standards#21, revised in place 2026-11-07 (updated
20:39:13Z). This spec lands them: six new standards, and two corrections to
`base/python/toolchain.md`, which the same tree made stale. Every rule is written from patchbay's
shipped files and from probes rerun at its pins, never from the proposals' text
(`base/process/standards-retrospective.md`, "Verify against the code, not against the spec").

Branch: `task/21-standards-spec-write-basepython-models-errors-events-testing-typing-and-layout-from-patchbays-contracts-spec-and-correct-toolchainmd`.

## Shaping answers (owner, 2026-11-07)

- **Step 1, scope:** as stated. The six standards, the toolchain corrections, the index, Step 5a,
  one CHANGELOG entry, no gate file. Probes rerun at patchbay's pins, new probes where patchbay
  has none, and the harness rerun under the fixture rule.
- **Step 2, visuals:** none.
- **Step 3, references:** patchbay at `7471387`, meaning `src/patchbay/*`, `tests/unit/*` and both
  contracts spec folders (shape.md, probes.txt with footing.py and footing_typing.py,
  mutations.txt, uv-lock-diff.txt). Here, `base/python/toolchain.md`, as the shape each standard
  takes, and the toolchain spec (`2026-11-06-1040`), for the rules it deferred and its
  `patchbay-evidence.txt` form.
- **Step 4:** no `agent-os/product/` here; skipped.
- **Step 5, standards:** all five `process/*` standards go into `standards.md`. `python/toolchain`
  is in Step 5a and does not apply here; it is also the file this spec corrects, so its text goes
  in `references.md`.
- **Follow-up in patchbay:** add the work to fromtheoutfit/patchbay#12's body in place, as a
  "Revised 2026-11-07" paragraph, not as a comment, and name #12 in the CHANGELOG. Reason:
  patchbay's next sync follows #21 and #22, so one sync and #12's spec take all of it.
- **Suppressions:** write the reason half too ("each with its reason beside it"), verified
  against the four in `src/`. No tool checks the reason; review does.

## Decisions

- **#21, as revised 2026-11-07 after fromtheoutfit/patchbay#11's review, is the scope**. This is
  shape.md's first Decision. The owner's arguments override its text in two places:
  - the test standard is `base/testing/tests.md`, not `base/python/testing.md`; the toolchain spec
    deferred its test rules to that path;
  - `models` joins `layout` and `typing` in Step 5a.
- **Rules come from #21's eight proposals and the toolchain spec's deferrals** to `layout.md` and
  `tests.md`. Anything else found in the tree (for example `py.typed`) is not added silently: it
  goes to the retrospective.
- **Each standard takes `toolchain.md`'s shape.** A header saying it was written from patchbay at
  `7471387` and which spec folders record the choices. Then rule sections, each bullet a rule
  with its named exceptions and ending `Verified against <file> (<test>)` and the probe where one
  exists. No "consider" or "prefer". Last come "In this repository" (no package; does not apply)
  and "In a consuming project" (synced in; Step 5a for layout, typing and models, Step 5b for the
  rest).
- **A rule that would need a second adapter to be true is left out** and named under Deferred:
  - an adapter's own errors and how its root relates to `PatchbayError`;
  - that an adapter's models derive from `PatchbayModel` (the mechanism stays: a derived model has
    the promise, by test);
  - an adapter package's modules;
  - an adapter's events;
  - an adapter's `conftest.py` copying `bus` and `instrument`, and where its contract run lives;
  - the `integration` marker's use.
- **One home per rule, with a pointer from the other topic:**

  | Rule | Home | Pointer from |
  |---|---|---|
  | `frozen=True` as the class keyword, since mypy reads it and not `model_config` | models | typing |
  | No `from __future__ import annotations` where pydantic reads annotations | typing | models |
  | Re-export through `__all__` under `implicit_reexport = false` | typing | layout |
  | `Subscriber[E: Event]`, contravariant | events | typing |
  | `Subscriber` beside the bus, which breaks the events/contracts cycle | layout | events |
  | The errors module a leaf, its fields plain values | errors | layout (build order) |
  | `ContractViolationError(AssertionError)` with fields | tests | errors (named exception to one root) |
  | A coded `# type: ignore` in a test holding a refusal | tests | toolchain (mypy) |
  | Every suppression coded, with its reason | toolchain | models (`__hash__`, base-init marker), events (BLE001) |
  | A third party's method wrapped, never restated | models | toolchain (PLR0913 has no case) |
  | An imported package declared | toolchain | errors (`ErrorDetails`) |
- **Evidence files:**
  - `verification/patchbay-evidence.txt`: the commit, the export, the named tests run by node id,
    the wheel listing;
  - `verification/probes.txt`: the reruns and the new probes;
  - `verification/gate-run.txt`;
  - `verification/gate-negative-tests.txt` and `verification/ci-negative-test.txt`: the harness
    rerun.

## Task 1: Save spec documentation

Create `agent-os/specs/2026-11-07-1549-contracts-standards-and-toolchain/`:

- **plan.md**: this plan.
- **shape.md**: the Shaping answers, the Decisions (the first cites #21 as revised), Deferred,
  Context, Standards Applied ("Core Architecture" holds the four Step 5a standards, none applying
  here), the Verification Gate and the Standards Retrospective, both filled in at the end.
- **standards.md**: `process/ownership`, `standards-index`, `standards-retrospective`,
  `standards-sync` and `verification-gate`, in full, as of shaping.
- **references.md**: patchbay's files and spec folders as listed above, `base/python/toolchain.md`
  (the shape, and the text corrected) and the toolchain spec. No `visuals/`.

## Task 2: patchbay evidence at 7471387 (`verification/patchbay-evidence.txt`)

1. Show the commit:
   - `git -C ../patchbay rev-parse origin/main` is `7471387…`, and equals `git ls-remote` for main;
   - `git diff --stat f5023c5 7471387` is empty.
2. Export with `git archive 7471387` into the scratchpad. Run `uv sync --locked` there (uv 0.13.7
   matches `required-version`).
3. Run the full suite, then every test a rule cites by node id. Record pass counts.
4. Run `uv build` and list the wheel's files: `patchbay/testing/*` ships, and so does `py.typed`.
5. Run `uv run --locked mypy` and `ruff check` clean: no missing-stub error, so numpy, pydantic and
   pydantic-core are typed. List the suppressions with `grep` (four in `src/`, six in `tests/`).

## Task 3: probes at patchbay's pins (`verification/probes.txt`)

Pins: python 3.12.16, pydantic 2.14.3, pydantic-core 2.50.4, numpy 2.5.4, mypy 2.4.1, ruff 0.17.4,
pytest 9.2.0. Probes run from the export through `uv run --locked`, with the scripts kept in a
scratchpad folder of their own. Each source is shown before its output, and each probe's cases
tell the competing claims apart.

- **Reruns, verbatim from patchbay's two probes.txt files:** `runtime.py`, `typing_probe.py`,
  `strict_nested.py`, `frozen_kw.py`, `frozen_kw2.py`, `config_form.py`, `models_init.py`,
  `footing.py` (A–E), `footing_typing.py`, and the revision's `mutations.py`. Each output is
  compared with the recorded one, and any difference is named. Also the tool-behaviour lines of
  `findings.py` that rules rest on: 6 (`nextafter` at 2**53 and at float max), 11
  (`ValidationError.errors` is callable) and 12 (`ErrorDetails` is not re-exported).
- **New probes, where no patchbay probe covers a claim:**
  - a. A non-`ValueError` raised in a nested validator passes pydantic-core unwrapped, aborts the
    outer validation and loses the outer location; a `ValueError` beside it is collected with its
    path.
  - b. ruff:
    - PGH003 on a blanket `# type: ignore`, none on a coded one;
    - D401 on a non-imperative docstring in a plain function, and on one prefixed `test_`. This
      decides whether "the prefix waived it" holds.
    - PLR2004 on an inlined `60` or `2`.
  - c. mypy strict `warn_unused_ignores`: an unused coded ignore fails, and a used one passes.
  - d. `python -O` strips `assert`; a raised `AssertionError` subclass survives it.
  - e. pytest collects a `test_`-named function imported into a test module, and not an unprefixed
    one.
  - j. ruff N818 on an exception class whose name does not end in `Error`.
  - k. Under `implicit_reexport = false`, mypy refuses `from patchbay.contracts import Parameter`
    and accepts `Subscriber`.
  - l. With `from __future__ import annotations`:
    - ruff ALL asks for a field-only import to move under `TYPE_CHECKING` (TC00x);
    - once moved, the model is not fully defined at first use;
    - neither happens without the future import.
  - m. ruff on a `TypeVar`-generic class and function: whether UP046 and UP047 report. This sets
    the PEP 695 rule's wording.
  - n. mypy refuses two `test_x.py` files in different folders under `tests/` with no
    `__init__.py`: a duplicate module.
  - o. `\d` matches U+0661; and RUF001 on a literal confusable digit, but not on its escape.

  A probe that contradicts a rule changes the rule, or drops it, before the rule is written.

## Tasks 4–9: the six standards (rule inventory; each bullet carries its pointers)

**4. `base/python/layout.md`, where things live:**
- `src/<package>/`:
  - a module per concern; core's are `contracts`, `models`, `events` and `errors`;
  - a `testing/` subpackage holding what an adapter's tests use, shipped in the wheel, not
    re-exported by the root, and imported by nothing in the package.
- `__init__.py` holds only re-exports, `__all__`, `__version__`, and its own imports bound to
  private names. `__version__` is `importlib.metadata.version(<distribution>)`, with no fallback.
  `testing/__init__.py` holds re-exports and `__all__` only.
- The surface test (`test_package.py`):
  - every public name the root binds is in `__all__`;
  - every name in `__all__` resolves, each once, to the object its module defines;
  - submodules are left out, since importing one binds it.
- Modules are built in dependency order, gate green after each, the errors module first as a
  leaf (errors.md). Core's order: errors, models, events, contracts, testing, the contract tests,
  `__init__`. The protocol a module's API takes sits beside that API (`Subscriber` in `events.py`),
  so no import cycle forms.
- Pointer: where test files live is tests.md's.

**5. `base/python/typing.md`, the type system's rules:**
- Distinct keys are distinct `NewType`s; mypy refuses one for the other.
- Protocols:
  - data members are read-only properties;
  - methods' parameters are positional-only;
  - the runtime check is `isinstance`, by name only;
  - `issubclass` is refused for a protocol with a data member (mypy and Python).
- Generics use PEP 695: `class X[T]`, `def f[**P, R]`, `type Alias = …`. Probe m sets whether this
  is "as ruff asks".
- Re-export through `__all__` under `implicit_reexport = false`.
- No `from __future__ import annotations` in a module whose annotations pydantic reads.
- Pointers: the frozen keyword is models.md's; `Subscriber`'s variance is events.md's.

**6. `base/python/models.md`, `PatchbayModel` and its guarantees:**
- One public base:
  - frozen by the class keyword on the base and every subclass line;
  - `extra="forbid"`, `allow_inf_nan=False` and `strict=True`, with strict's three admissions
    named;
  - a model's own config merges with the base's, as `Patch`'s base64 and `RenderResult`'s
    arbitrary types do.
- A model's own entry points refuse as the package's validation error, chained from pydantic's.
  Validation pydantic runs for something else raises pydantic's error. A derived model has the
  promise at any depth. `model_copy(update=…)` is not a way in. Why no hook covers every path:
  probe a.
- The three classmethods are wrapped under `if not TYPE_CHECKING:`, never restated. `__init__`
  carries `__pydantic_base_init__`. Validators raise `ValueError`.
- JSON-form data has one entry point, `from_json_data`.
- Containers are read-only:
  - a mapping is sorted and held as a `MappingProxyType`, with a wrap serializer;
  - an array is copied, unwriteable and finite, and its model defines `__eq__` with
    `np.array_equal`;
  - an unhashable model says so with `__hash__: ClassVar[None] = None`;
  - bytes go into JSON as base64.
- Ids are non-empty everywhere, mapping keys included.
- A quantity every implementation computes alike is one exact method (`samples`, `sample_at`).

**7. `base/python/errors.md`, the hierarchy and what escapes:**
- One root per package (named exception: the contract suite's violation, tests.md). No built-in
  narrower than `Exception` in any MRO.
- Names end in `Error` (N818).
- Fields:
  - each is a constructor argument, kept as an attribute and passed to `Exception` in order;
  - `__str__` is built from them;
  - no field takes a third party's method name (`.details`, `.exceptions`).
- No built-in exception leaves a public method. An error raised in place of another is chained
  from it. Named exception: `from None` where the replaced error is the lookup's own `KeyError`.
- The errors module imports nothing from its package, and its fields are plain values.
- Pointers:
  - what pydantic raises for something else (models.md);
  - what the bus raises and lets through (events.md);
  - the declared `pydantic-core` (toolchain.md).

**8. `base/python/events.md`, Event, bus and Subscriber:**
- An event:
  - is a frozen model on the base;
  - has a dotted lowercase past-tense name, fixed by a `Literal` default (the test checks the
    shape; past tense is for review);
  - carries typed fields, never a dict, plus `version >= 1`, a non-empty `source` and a non-empty
    `correlation_id`.
- An event is stamped in UTC when built. A given time is judged by its zone
  (`utcoffset(None) == timedelta(0)`) and held as `datetime.UTC`; a naive time or a DST zone is
  refused in every season.
- The bus:
  - is synchronous and in-process;
  - delivers in subscription order over a snapshot, so a subscribe or cancel during a publish
    takes effect from the next event;
  - never alters an event;
  - runs every subscriber, then raises one error carrying each failure, chained from the first;
  - catches `Exception` only, under the one coded BLE001.
- `subscribe` refuses a bad type or a non-callable subscriber, with nothing subscribed.
  `Subscription`:
  - `cancel()` takes effect from the next event, and a second call does nothing;
  - it is a context manager;
  - the bus drops a cancelled subscription;
  - each `subscribe` makes its own.
- `Subscriber[E: Event]` is contravariant, with a positional-only `__call__`, runtime-checkable,
  under two `subscribe` overloads.

**9. `base/testing/tests.md`, how a test is written and the contract suite:**
- Test files:
  - tests mirror the source, one test module per module (named exception: the root `__init__` has
    `test_package.py` and `test_version.py`);
  - each basename is used once under `tests/`, which has no `__init__.py` (probe n);
  - a `conftest.py` sits only where its fixtures are shared, and they are function-scoped.
- Inside a test:
  - repository files are read through `pytestconfig.rootpath`;
  - a property's strategy generates only valid inputs, with a known counterexample pinned by
    `@example`;
  - patterns use `[0-9]` and escape a confusable character (probe o);
  - a coded `# type: ignore` holds a refusal mypy must keep making. There are six in patchbay's
    tests (probe c).
- The contract suite:
  - it lives in the protocol package's `testing/`, as plain `<property>(instrument, bus)` functions
    with no `test_` prefix (probe e) and imperative docstrings (probe b);
  - they are listed once in a tuple a consumer parametrizes over;
  - a violation is an `AssertionError` subclass with fields: no `assert` (probe d), no pytest
    import;
  - each test computes its expectation from the parameters and the contract alone;
  - an out-of-range value is one float past the bound (`nextafter`), with none past a bound that
    has no finite float beyond it;
  - each test is proven by a fake broken its way, asserting its reason, with every test in the
    table once;
  - the widest-bounds fake passes them all (mutations rerun);
  - the properties include a refusal that changes nothing and publishes nothing, one event per
    call carried out, a patch refused part way, and an impossible render;
  - the `bus` and `instrument` fixtures are function-scoped in the `conftest.py` beside the tests
    that run the suite.

## Task 10: `base/python/toolchain.md` corrections (#21 proposals 7 and 8)

- **Header and "In this repository":** Dependencies and the suppression rules were read again at
  `7471387` by this spec.
- **Dependencies:**
  - the "empty `dependencies`" example becomes patchbay's three runtime dependencies, each added
    by the spec that first imports it;
  - a runtime dependency is a range: the floor is the version the gate ran and the ceiling is the
    next major. The dev group's exact pins stay;
  - a package the code imports directly is declared (`pydantic-core` for `ErrorDetails`);
  - the spec that adds one shows the lock diff, with no change to a tool the gate runs
    (`typing-extensions` included). Declaring one already locked changes only the package's own
    entry.
- **ruff:**
  - a suppression goes only where the code cannot change, coded, with its reason beside it. `src/`
    holds four: BLE001, `attr-defined` and two `assignment`;
  - a third party's method is wrapped, never restated, so PLR0913 has no case;
  - PLR2004 and D401, tripped by the revision, were fixed in the code. The "patchbay's run gave
    neither" parenthetical is updated to match.
- **mypy:**
  - a `# type: ignore` names its code (PGH003);
  - in a test, an ignore may hold a refusal (pointer to tests.md);
  - "imports nothing untyped yet" is rewritten as: the three runtime dependencies are typed, with
    no override.

## Task 11: `index.yml`

Add `python/errors`, `python/events`, `python/layout`, `python/models`, `python/typing` and
`testing/tests`, keys alphabetical. Each gets one line saying what it decides, with no `: ` and no
` #`. Revise `python/toolchain`'s description for the ranges, the declared direct imports, and
coded suppressions with reasons. The symlink follows.

## Task 12: this repository's `.claude/commands/agent-os/shape-spec.md`

- Step 5a lists `base/python/layout`, `typing` and `models` beside `toolchain`, one line each.
- The "does not apply here" sentence covers all four.
- In Step 5b, the "leave the Step 5a standards out" note and its prompt name all four.
- In the `shape.md` template, the "Core Architecture" and "Standards Applied, Core" lines list all
  four.
- The gate task and its template paragraph are untouched; they are gate files.

## Task 13: `CHANGELOG.md`

One entry under `[Unreleased]` / `### Added`: "Thirteenth spec, `agent-os/specs/2026-11-07-1549-…`
(issue #21)". It holds `base/` lines for each new standard and for toolchain.md's corrections,
plus `index.yml`, `shape-spec.md` Step 5a and the harness rerun. It names
**fromtheoutfit/patchbay#12, revised in place**, for the work after patchbay's sync (Step 5a, the
template lines, and the Docs read of the six and of toolchain's corrected text).

## Task 14: fromtheoutfit/patchbay#12, revised in place

1. Draft the new body: a second "**Revised 2026-11-07 for fromtheoutfit/patchbay-standards#21.**"
   paragraph, plus:
   - a "Depends on" line for the #21 pull request;
   - items for Step 5a and the template lines;
   - the Docs read;
   - "Nothing to change" amended for toolchain's corrections, which were written from patchbay's
     `main`.
2. Show the owner the exact text with AskUserQuestion. Apply it only on approval, with
   `gh issue edit 12 --repo fromtheoutfit/patchbay --body-file`, and read it back. No
   attribution.

## Task 15 (FINAL): verification gate

1. **Harness rerun under the fixture rule.** `base/` gains files and the `testing/` directory, and
   `mk` copies `base/`. Run `scripts/gate-negative-tests.sh` (every test but j) and `… j`. Keep
   one run each as `verification/gate-negative-tests.txt` and `ci-negative-test.txt`. Each ends
   on `0 unexpected`; a case that goes stale is reported, not edited, since the harness is a gate
   file.
2. **`scripts/gate.sh`:**
   - steps 1–2 pass on the tree. Step 3 fails, naming the six untracked files, since an agent
     never stages;
   - a scratch copy of the tree, git-added, passes all three steps, exit 0.

   Both transcripts go in `verification/gate-run.txt`, first line the date and the branch. The
   hand-over says the owner's `git add` turns the tree run green.
3. **Docs:** read against the shipped change, recorded in shape.md:
   - `README.md` and `CLAUDE.md`;
   - `toolchain.md`'s pointers into patchbay;
   - `verification-gate.md` ("the current transcripts") and `standards-sync.md`;
   - the retrospective's `testing/fixtures.md` example;
   - each new standard's pointers to the others.
4. **Version:** the CHANGELOG entry. There is no version to bump.
5. **Standards retrospective:** the four questions against the diff. Any base proposal is
   presented with AskUserQuestion (multi-select, at most three per question, "None of these"),
   and the approved ones are filed as one issue on patchbay-standards with no attribution, or
   marked declined. Always record `Proposals sent upstream:`. Retrospective edits are listed
   apart from the feature's.
6. Rerun the gate last (tree, then copy) and rewrite `gate-run.txt` from that run. Then print
   `git status --short` and stop. No stage, commit, push or PR.

## Verification

- `scripts/gate.sh` on a git-added copy exits 0, with step 3 counting 12 standards (6 + 6). On the
  tree, step 3 names exactly the six new files.
- The harness ends `… 0 unexpected`, `harness exit=0`, for both runs.
- Every `Verified against` in the six standards and in toolchain.md names a file present at
  `7471387`, and every test it names passed by node id in `patchbay-evidence.txt`. Every probe it
  names is in `probes.txt` with output matching the rule.
- `rg -n 'consider|prefer' base/python base/testing` finds nothing in the new text.
- `scripts/check-index.sh` agrees with the six new keys (on the copy).
