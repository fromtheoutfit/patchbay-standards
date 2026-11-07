# Events

What a patchbay package has done, it says after doing it, as an event published on a bus. This
standard says what an event is, how the bus delivers it, and what a subscriber and a subscription
are. Every rule names the file of a consuming project it is verified against, the test that holds
it and the probe a rule about a tool's behaviour rests on. It was written from patchbay
(`fromtheoutfit/patchbay`) at `7471387`, the merge of its PR 11, whose contracts spec
(`agent-os/specs/2026-11-07-0806-contracts-models-events-errors-fake/`) and its revision after the
review of that pull request (`agent-os/specs/2026-11-07-1432-contracts-revision-after-pr-11-review/`)
record each choice as a Decision with its reason. The probes it cites are in the
`verification/probes.txt` of the spec of issue #21 in `patchbay-standards`, which reruns
patchbay's own at its pins, cited by name (`footing.py` C).

An event is a model, and every rule of `base/python/models.md` holds of it; where `Subscriber`
lives, beside the bus, is `base/python/layout.md`'s; the errors the bus raises are
`base/python/errors.md`'s.

## The event

- **An event is a frozen model on the package's base**, `Event`, every event type its subclass with
  `frozen=True` on its class line. Its payload is typed fields on its own class, never a dict.
  Beside the payload every event carries `name`, `version` (the payload's shape, `1` or more, so a
  subscriber can tell a later shape), `at`, `source` (what built it) and `correlation_id` (the
  call it belongs to), the last two non-empty. Verified against `src/patchbay/events.py` and
  `tests/unit/test_events.py` (`test_each_event_names_itself_in_past_tense_dotted_form`,
  `test_an_event_says_where_it_came_from`, `test_an_event_is_frozen`,
  `test_an_event_round_trips_through_json`).
- **An event's name is dotted lowercase words, in the past tense, fixed per class by a `Literal`
  default**: `parameter.changed`, `patch.loaded`, `render.completed`. Two words or more, each a
  lowercase letter then letters, digits or underscores; a class cannot be built under another
  name. The shape is validated; the tense is the reviewer's to hold, no check reading it. Verified
  against `src/patchbay/events.py` (`_NAME`, each subclass's `name`) and `tests/unit/test_events.py`
  (`test_an_event_s_name_is_fixed_by_its_class`, `test_an_event_s_name_is_dotted_lowercase_words`,
  `test_a_name_with_digits_and_underscores_is_an_event_s_name`).
- **An event is stamped with the UTC time it was built**, `at` defaulting to `datetime.now(UTC)`.
  A time given for `at` is judged by its zone, not by its instant's offset: it is accepted only in
  a zone whose offset is zero at every instant, `tzinfo.utcoffset(None) == timedelta(0)`, and held
  as `datetime.UTC`, so a time read back from JSON, whose zone pydantic parses as its own, is held
  the same way. A naive time is refused, and so is a zone with daylight saving, such as
  Europe/London, in every season: whether an event is valid never depends on when it was built.
  Verified against `src/patchbay/events.py` (`_in_utc`) and `tests/unit/test_events.py`
  (`test_an_event_is_stamped_in_utc_when_built`, `test_an_event_s_time_is_refused_unless_utc`, its
  London cases in January and July, `test_a_time_in_utc_is_held_as_datetime_utc`,
  `test_an_event_round_trips_through_json`); probe `footing.py` C.

## The bus

- **The bus is synchronous and in-process**: `publish` calls every subscriber whose type the event
  is, in the order they subscribed, and returns once all have run. It never alters an event: each
  subscriber receives the very object published. Verified against `src/patchbay/events.py`
  (`EventBus`) and `tests/unit/test_events.py`
  (`test_publish_delivers_to_every_subscriber_once_in_subscription_order`,
  `test_subscribe_by_type_receives_only_that_type`, `test_subscribe_to_the_base_event_is_every_event`,
  `test_publish_with_no_subscribers_does_nothing`).
- **A publish delivers over a snapshot of the subscriptions it began with**, so a subscription
  made or cancelled during a publish takes effect from the next event. Verified against
  `src/patchbay/events.py` and `tests/unit/test_events.py`
  (`test_a_subscriber_added_during_a_publish_starts_with_the_next_event`,
  `test_a_cancel_during_a_publish_takes_effect_from_the_next_event`).
- **A subscriber that raises hides the event from no other.** The bus runs every subscriber, then
  raises one error carrying each failure in the order raised, chained from the first: patchbay's
  `SubscriberFailedError(event_name, exceptions)`. It catches `Exception` only, under the one
  coded `# noqa: BLE001` with its reason beside it (`base/python/toolchain.md`, "ruff"): a
  `BaseException` that is not an `Exception`, `KeyboardInterrupt` and its kind, stops delivery where
  it is raised. Verified against `src/patchbay/events.py` (`_deliver`) and
  `tests/unit/test_events.py` (`test_a_failing_subscriber_hides_the_event_from_no_other`,
  `test_a_base_exception_stops_delivery_where_it_is_raised`); probe b.

## Subscribing

- **`subscribe` refuses a bad subscription where it is made**: an event type that is neither
  `None`, for every event, nor a subclass of `Event`, and a subscriber that cannot be called, each
  raise the package's error, patchbay's `SubscriptionRejectedError`, with nothing subscribed. A
  bad subscription then fails once, where it is made, and not at every publish after it. The
  types already say so to mypy; the check says so to a caller mypy never saw. Verified against
  `src/patchbay/events.py` and `tests/unit/test_events.py`
  (`test_a_bad_subscription_is_refused_where_it_is_made`).
- **`subscribe` returns a `Subscription`**, which says what it delivers and to whom:
  - `cancel()` ends it from the next event, and a second `cancel()` does nothing;
  - it is a context manager that cancels on leaving the block, whether the block returned or
    raised, and what the block raised goes on;
  - the bus drops a cancelled subscription, so it holds the subscriber no longer and the
    subscriber can be collected;
  - each `subscribe` is a subscription of its own, so one subscriber subscribed twice receives
    twice and is cancelled one subscription at a time.

  Verified against `src/patchbay/events.py` (`Subscription`, `EventBus._remove`) and
  `tests/unit/test_events.py` (`test_a_subscription_says_what_it_delivers_and_to_whom`,
  `test_cancel_ends_delivery_and_a_second_cancel_does_nothing`,
  `test_a_subscription_is_a_context_manager_that_cancels_on_exit`,
  `test_a_cancelled_subscriber_is_no_longer_held_by_the_bus`,
  `test_each_subscribe_is_its_own_subscription`).
- **The subscriber protocol is generic and contravariant**: `Subscriber[E: Event]`, a
  `runtime_checkable` protocol whose one member is `__call__(self, event: E, /) -> None`. A
  subscriber for one type takes that type, and a handler of the base event serves for any type:
  mypy accepts `subscribe(ParameterChanged, handler)` for a handler taking a `ParameterChanged` and
  refuses that handler where every event is wanted. The event is positional-only, so a subscriber
  names its parameter as it likes, and any function will do. `subscribe` has two overloads,
  `(type[E], Subscriber[E])` and `(None, Subscriber[Event])`. Verified against
  `src/patchbay/events.py` and `tests/unit/test_events.py` (`test_a_function_is_a_subscriber`);
  probe `typing_probe.py` G, H and I.

## In this repository

`patchbay-standards` has no package: no `pyproject.toml`, no Python under `src/` or `tests/`. This
standard does not apply here, and no file here verifies it. Its rules were read from patchbay at
`7471387`; a spec that changes one reads it again from a consuming project's shipped files and
reruns the probes a rule rests on.

## In a consuming project

This standard is synced in as `agent-os/standards/base/python/events.md`. Every rule above is the
project's, verified against the project's own files it names. Step 5b of the project's
`shape-spec.md` surfaces it from the index for a spec that adds an event or touches the bus.
