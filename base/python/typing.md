# Typing

A patchbay package is typed so that mypy, strict over the package and its tests, refuses what the
contracts forbid before a test runs. This standard says how keys, protocols, generics and
re-exports are written for mypy to hold them, and which annotation form pydantic needs. Every rule
names the file of a consuming project it is verified against, the test that holds it and the probe
a rule about a tool's behaviour rests on. It was written from patchbay (`fromtheoutfit/patchbay`)
at `7471387`, the merge of its PR 11, whose contracts spec
(`agent-os/specs/2026-11-07-0806-contracts-models-events-errors-fake/`) and its revision after the
review of that pull request (`agent-os/specs/2026-11-07-1432-contracts-revision-after-pr-11-review/`)
record each choice as a Decision with its reason. The probes it cites are in the
`verification/probes.txt` of the spec of issue #21 in `patchbay-standards`, which reruns
patchbay's own at its pins, cited by name (`typing_probe.py` E), and adds the ones patchbay
lacked, cited by letter (probe k).

mypy's configuration, strict with `implicit_reexport = false`, is `base/python/toolchain.md`'s. How
mypy reads a model's frozenness is `base/python/models.md`'s, and the variance of the subscriber
protocol `base/python/events.md`'s.

## Keys

- **Distinct keys are distinct `NewType`s**, so mypy refuses one where the other is expected, and a
  plain `str` where either is: patchbay's `ParameterId`, the key a host knows a parameter by, and
  `PresetKey`, the key a preset file knows a value by. Each is a `str` at runtime, so a key costs
  nothing to build or to serialize. Verified against `src/patchbay/models.py` and
  `tests/unit/test_models.py` (`test_a_preset_key_is_not_a_parameter_id`, whose coded ignore holds
  mypy's refusal); probe `typing_probe.py` E and F.

## Protocols

- **A protocol's data member is a read-only property**, so an implementation may give it as a
  plain attribute or as a property: `Instrument.name`. Verified against `src/patchbay/contracts.py`
  and `tests/unit/test_contracts.py` (`test_an_object_with_every_member_is_an_instrument`, whose
  `_Silent` gives `name` as a class attribute); probe `runtime.py` 7.
- **A protocol method's parameters are positional-only**, so an implementation names its own:
  every method of `Instrument`, and `Subscriber.__call__`. Verified against
  `src/patchbay/contracts.py`, `src/patchbay/events.py` and `tests/unit/test_contracts.py`; probe
  `typing_probe.py` H.
- **A protocol is checked at runtime with `isinstance`, which asks only whether every member's name
  is there**, under `@runtime_checkable`; a member's signature is mypy's to hold, and its
  behaviour the contract suite's (`base/testing/tests.md`). `issubclass` is refused for a protocol
  with a data member, by mypy statically and by Python at runtime, and is not used. Verified
  against `src/patchbay/contracts.py` and `tests/unit/test_contracts.py`
  (`test_an_object_with_every_member_is_an_instrument`,
  `test_an_object_missing_a_member_is_not_an_instrument`,
  `test_issubclass_is_refused_for_a_protocol_with_a_data_member`); probe `runtime.py` 7.

## Generics

- **Generics use PEP 695's syntax**: a type parameter list on the class or function,
  `class Subscriber[E: Event]`, `def _refusing[**P, R]`, `def of_type[E: Event]`, and the `type`
  statement for an alias, `type ContractTest = Callable[[Instrument, EventBus], None]`. There is
  no `TypeVar`, `ParamSpec`, `Generic` or `TypeAlias` in `src/` or `tests/`. Under
  `select = ["ALL"]` at the 3.12 floor, ruff asks for it: UP046 for a `Generic` class, UP047 for a
  function over a `TypeVar`, UP040 for a `TypeAlias`. Verified against `src/patchbay/events.py`,
  `src/patchbay/models.py`, `src/patchbay/testing/contract_tests.py` and
  `src/patchbay/testing/recording.py`; probe m.

## Re-exports

- **A module re-exports a name by listing it in its `__all__`**, never by importing it alone: under
  `implicit_reexport = false` mypy refuses `from module import name` for a name the module imports
  but does not list, and `--implicit-reexport` lifts the refusal. `patchbay.contracts` imports
  `Subscriber` from `patchbay.events` and lists it in its `__all__`, and every name the package's
  root exports is in the root's `__all__` (`base/python/layout.md`). Verified against
  `src/patchbay/contracts.py`, `src/patchbay/__init__.py`, `pyproject.toml` (`[tool.mypy]`) and
  `tests/unit/test_contracts.py` (`test_subscriber_is_the_events_module_s_own`); probe k.

## Annotations pydantic reads

- **A module whose annotations pydantic reads carries no `from __future__ import annotations`**:
  every module that defines a model. With it, ruff under `select = ["ALL"]` reports an import used
  only in a field's annotation (TC003 for the standard library) and asks for it under
  `if TYPE_CHECKING:`, where pydantic cannot reach it, and the model moved so is not fully defined
  at its first use. Without it, ruff reads the annotation as evaluated at runtime and asks nothing.
  Verified against `src/patchbay/` and `tests/` (no module carries the import); probe l.

## In this repository

`patchbay-standards` has no package: no `pyproject.toml`, no Python under `src/` or `tests/`. This
standard does not apply here, and no file here verifies it. Its rules were read from patchbay at
`7471387`; a spec that changes one reads it again from a consuming project's shipped files and
reruns the probes a rule rests on. Step 5a of this repository's `shape-spec.md` lists this standard
with the note that it applies to consuming projects; a spec shaped here records it under "Core
Architecture" as not applying and does not copy it into `standards.md`.

## In a consuming project

This standard is synced in as `agent-os/standards/base/python/typing.md`. Every rule above is the
project's, verified against the project's own files it names. The project's `shape-spec.md` lists
it in Step 5a, the tier every spec includes without asking, with its full content in that spec's
`standards.md`.
