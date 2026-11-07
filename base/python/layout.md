# Layout

Where everything in a patchbay package lives: its modules, the subpackage its consumers' tests use,
what its `__init__.py` holds, and the one direction its modules import in. Every rule names the
file of a consuming project it is verified against and the test that holds it. It was written from
patchbay (`fromtheoutfit/patchbay`) at `7471387`, the merge of its PR 11, whose contracts spec
(`agent-os/specs/2026-11-07-0806-contracts-models-events-errors-fake/`) and its revision after the
review of that pull request (`agent-os/specs/2026-11-07-1432-contracts-revision-after-pr-11-review/`)
record each choice as a Decision with its reason; the toolchain spec of issue #4 in
`patchbay-standards` deferred its `__init__.py` rules here. The evidence it cites is in the
`verification/patchbay-evidence.txt` of the spec of issue #21 in `patchbay-standards`.

Where a test file lives is `base/testing/tests.md`'s; how a name is re-exported so mypy sees it is
`base/python/typing.md`'s.

## The package

- **`src/<package>/` holds one module per concern.** patchbay's core holds four: `contracts.py`,
  the protocol an adapter implements; `models.py`, the values that cross a boundary; `events.py`,
  the events, their bus and its subscriptions; `errors.py`, the exceptions. Verified against
  `src/patchbay/` and the docstring of `src/patchbay/__init__.py`.
- **What a consumer's tests use is a `testing/` subpackage, shipped in the wheel**, a module per
  thing it holds: patchbay's `patchbay.testing` holds the contract tests (`contract_tests.py`),
  the reference implementation they are proven against (`fake.py`) and a subscriber that records
  what it receives (`recording.py`). The root does not re-export it and no module outside it
  imports it, so importing the package loads none of it; a consumer imports it by name. It imports
  no pytest (`base/testing/tests.md`). Verified against `src/patchbay/testing/`, its
  `__init__.py`'s docstring, `src/patchbay/__init__.py`, and the wheel's files and the modules an
  import of the package loads, in the `verification/patchbay-evidence.txt` named above.

## `__init__.py`

- **A package's `__init__.py` holds its re-exports and `__all__`, the root's `__version__` too, and
  nothing else**: no definition and no logic. A module the root imports for itself is bound to a
  private name (`import importlib.metadata as _metadata`), so every public name the root binds is
  an export. `testing/__init__.py` holds re-exports and `__all__` alone. Verified against
  `src/patchbay/__init__.py`, `src/patchbay/testing/__init__.py` and `tests/unit/test_package.py`
  (`test_public_names_are_in_all`).
- **`__version__` is read from the installed distribution's metadata**,
  `importlib.metadata.version("<distribution>")`, so `pyproject.toml` is the one place the version
  is written. Nothing falls back around it: where no distribution is installed, as from a bare
  `src/` on `sys.path`, `importlib.metadata` raises `PackageNotFoundError` and the import fails,
  rather than the package inventing a version. Verified against `src/patchbay/__init__.py`, its
  docstring, and `tests/unit/test_version.py` (`test_version_matches_pyproject`).
- **A test holds the root's surface to `__all__`**: every name the root binds without a leading
  underscore is in `__all__`; every name in `__all__` is bound, and listed once; and each is the
  very object its module defines, not a copy or a second type. Submodules are left out of the
  first: importing `patchbay.errors` binds `errors` on the package, the import system's doing and
  not an export, and `from patchbay import *` does not import them. Verified against
  `tests/unit/test_package.py` (`test_public_names_are_in_all`, `test_every_name_in_all_resolves`,
  `test_the_package_re_exports_the_contract_surface`).

## One direction of import

- **The modules import in one direction, from the errors module up to the root, and are built in
  that order with the gate green after each.** The errors module is the leaf and imports nothing
  from its package (`base/python/errors.md`). In patchbay, `models.py` imports `errors.py`;
  `events.py` imports both; `contracts.py` imports `events.py` and `models.py`; the `testing`
  modules import those; `__init__.py` imports the four. They were built in that order, errors,
  models, events, contracts, the `testing` subpackage with the fake, the contract tests, then
  `__init__.py`, with the gate green after each, at 28, 103, 127, 131, 162, 186 and 188 tests: a
  module cannot pass mypy before what it imports exists. Verified against the imports of each
  module in `src/patchbay/` and the contracts spec's `shape.md` ("Results").
- **A protocol that a module's own API takes lives in that module, beside the API**, so no two
  modules import each other: `Subscriber` is defined in `events.py`, beside the
  `EventBus.subscribe` that takes it, and `contracts.py` re-exports it (`base/python/typing.md`,
  "Re-exports"). `Subscriber` is bounded by `Event`: placed in `contracts.py`, it would have
  `contracts.py` import `Event` from `events.py`, and `events.py` import `Subscriber` from
  `contracts.py` for `subscribe`. Verified against
  `src/patchbay/events.py`, `src/patchbay/contracts.py` and `tests/unit/test_contracts.py`
  (`test_subscriber_is_the_events_module_s_own`).

## In this repository

`patchbay-standards` has no package: no `pyproject.toml`, no Python under `src/` or `tests/`. This
standard does not apply here, and no file here verifies it. Its rules were read from patchbay at
`7471387`; a spec that changes one reads it again from a consuming project's shipped files. Step 5a
of this repository's `shape-spec.md` lists this standard with the note that it applies to
consuming projects; a spec shaped here records it under "Core Architecture" as not applying and
does not copy it into `standards.md`.

## In a consuming project

This standard is synced in as `agent-os/standards/base/python/layout.md`. Every rule above is the
project's, verified against the project's own files it names. The project's `shape-spec.md` lists
it in Step 5a, the tier every spec includes without asking, with its full content in that spec's
`standards.md`.
