# Revision after the review of PR 25

## Context

PR 25 (head `050d8b1`) carries the thirteenth spec, issue #21: six new base standards and the
corrections to `base/python/toolchain.md`. The owner's review (PR comment, 2026-11-07T21:25:30Z)
lists 14 findings: two serious, five on accuracy, seven on consistency. Each was checked against
the shipped files before shaping.
- **#1:** probe o's "escape" line holds the literal U+0661.
- **#4:** `strict_nested.py` case 2 shows a strict outer model with a lax inner one accepting
  `'0.5'`.
- **#5:** a custom tzinfo that answers zero for `None` and +1h at an instant is accepted by
  `Event`, and its instant is still converted correctly.
- **#6:** `10**400 / 1` raises `OverflowError`.

This revision answers all 14 in a new spec folder on the same branch, so PR 25 carries the fix.
The thirteenth spec's folder stays its record, unedited. Branch:
`task/21-standards-spec-write-basepython-models-errors-events-testing-typing-and-layout-from-patchbays-contracts-spec-and-correct-toolchainmd`.
No stage, commit, push or PR by the agent.

## Shaping answers (owner, 2026-11-07)

- **Scope:** all 14 findings, in a new folder. The thirteenth spec's two misstatements, #1's
  "not its escape" and #7's "a to o", are recorded as corrected here. Each factual finding is
  probed first. No gate file changes. The harness is rerun only if a file under `base/` is added,
  removed or renamed; none is.
- **Visuals:** none.
- **References:** the review; the thirteenth spec's folder; the PR 23 revision, as the shape of a
  revision; patchbay at `7471387`.
- **Standards:** the five `process/*` standards, snapshotted at `050d8b1`. The seven Python and test
  standards are the text under review, so they go in `references.md`.
- **#8 and #9:** `python/errors` joins Step 5a, making the tier toolchain, layout, typing, models
  and errors. Here, Step 5b leaves out every standard under `python/` and `testing/`.
- **#3:** a `layout.md` rule: no two modules of the package share a basename, subpackages
  included. `tests.md` points to it.
- **#13:** trim, and keep provenance per standard. Each standard keeps one provenance line, and its
  two closing sections shrink to the line that differs.
- **#5:** reword the rule to the check, name the gap, and file a patchbay issue. Its text is shown
  to the owner before filing, with no attribution.

## Dispositions

| # | Finding | Disposition | Files |
|---|---|---|---|
| 1 | Probe o's "escape" is the literal | Probe p reruns it with a real `"\u0661"` escape; `tests.md` cites o for the literal and p for the escape | `tests.md`; probes |
| 2 | Two `conftest.py` are a duplicate module to mypy | The unique-basename rule covers every module under `tests/`, `conftest.py` included, so `tests/` holds at most one `conftest.py`, in the directory above every test that takes its fixtures. Probe q shows mypy refusing two while pytest collects them | `tests.md` |
| 3 | The mirror rule collides with unique basenames | New `layout.md` rule: no two modules share a basename (patchbay's seven don't; probe n says why). `tests.md`'s mirror rule points to it | `layout.md`, `tests.md` |
| 4 | Strict is not inherited by a nested model | "a dict for a nested model on the base, validated as strictly; a nested model not on the base is held to its own config" (`strict_nested.py` 2) | `models.md` |
| 5 | `utcoffset(None)` is not "every instant" | State the check and what passes and fails; name the gap (a tzinfo answering zero for `None` passes, converted at its instant's offset). Probe r. File the patchbay issue | `events.md`; patchbay issue |
| 6 | "at any size" | int/int overflows only when the quotient exceeds the largest float, which a length over a positive rate never does. Probe s | `models.md` |
| 7 | "a to o" | Recorded as corrected in this shape.md: a–f and j–o. The thirteenth spec's folder is untouched | shape.md |
| 8 | Step 5b leaves out only the four | Here, Step 5b leaves out every standard under `python/` and `testing/` | `shape-spec.md` |
| 9 | errors in 5b, yet the core tier builds on it | `python/errors` joins Step 5a; `errors.md`'s closing line says Step 5a | `shape-spec.md`, `errors.md`, patchbay#12 |
| 10 | Two intros misdescribe their evidence | Covered by #13's one-line provenance, which names both probe files and how probes are cited | six standards |
| 11 | The `issubclass` ignore's code is unclear | Name each of the six with its code | `tests.md` |
| 12 | Bare `layout`, `typing`, `models` | Full keys (`base/python/layout`, …) in the Step 5b prompt and the template line | `shape-spec.md` |
| 13 | Provenance repeated six times | One line per standard: written from patchbay at `7471387`, choices in its two contracts spec folders, probes in the `verification/probes.txt` of #21's spec and of this revision (patchbay's cited by name, ours by letter). "In this repository" and "In a consuming project" shrink to one line each: no package here, and synced as `agent-os/standards/base/…` in Step 5a or 5b | six standards |
| 14 | Unreflowed paragraph | Reflow the "In this repository" paragraph | `toolchain.md` |

## Task 1: Save spec documentation

Create `agent-os/specs/2026-11-07-2041-revision-after-pr-25-review/`:
- **plan.md:** this plan.
- **shape.md:** the shaping answers, Decisions (the review is the scope; the dispositions), Context,
  Standards Applied (Core: the five Step 5a standards, none applying here), the Verification Gate
  and the Retrospective.
- **standards.md:** the five `process/*` standards in full at `050d8b1`, with headings shifted as
  the last spec did.
- **references.md:** the review, the thirteenth spec's folder, the PR 23 revision, patchbay at
  `7471387`, and the seven standards as the text under review.

## Task 2: Probes (`verification/probes.txt`)

Run as the thirteenth spec ran them: on the scratch export of patchbay at `7471387`, through
`uv run --locked`, with `VIRTUAL_ENV` unset, each source shown before its output. The probe's bytes
are shown too (`od -c` on the escape line), so the setup is seen to do what it claims.
- **p:** `"\u0661"` written as the six-character escape, beside the literal in a string and in a
  comment. RUF001 and RUF003 report the literal only.
- **q:** `tests/unit/conftest.py` beside `tests/unit/testing/conftest.py`, no `__init__.py`. mypy
  over both reports `Duplicate module named "conftest"`, while pytest collects and runs them. If
  pytest also refuses, the rule's reason says so.
- **r:** a tzinfo answering `timedelta(0)` for `None` and +1h at an instant is accepted by `Event`
  and held as the same instant in UTC. Also shown: UTC, `timezone.utc`, `ZoneInfo("UTC")` and
  pydantic's Z pass; naive, `+01:00` and London in January and July are refused.
- **s:** `8 / 10**400` is `0.0`; `10**400 / 1` and `2**1024 / 1` raise `OverflowError`; `2**1024 / 3`
  is finite.

The tools are the thirteenth spec's scratch scripts (`probes_transcript.sh`, `extract.py`),
adapted for these four.

## Task 3: The six standards and toolchain.md

- **`base/testing/tests.md`:**
  - #2: the unique-basename rule covers every module under `tests/`, `conftest.py` included, with
    at most one `conftest.py` (probes n and q);
  - #3: the mirror rule points to `layout.md`'s new rule;
  - #1: the confusable rule cites probe o (the literal) and probe p (the escape);
  - #11: each of the six ignores named with its code;
  - #13: the trimmed provenance and closing lines.
- **`base/python/layout.md`:**
  - #3: new bullet. No two modules of the package share a basename, subpackages included, so each
    module's test module has a name no other has (`base/testing/tests.md`). Verified against
    `src/patchbay/`'s seven modules; probe n;
  - #13.
- **`base/python/models.md`:** #4, #6, #13.
- **`base/python/events.md`:** #5 (rewritten against probe r and `footing.py` C), #13.
- **`base/python/errors.md`:** #9, the closing line says Step 5a; #13.
- **`base/python/typing.md`:** #13.
- **`base/python/toolchain.md`:** #14, the reflow only.
- Each "In this repository" line still names Step 5a where it applies, now for five standards.

## Task 4: `index.yml`

Each description is rewritten where its rule changed, in the same change set
(`standards-index.md`):
- `python/layout`: no two modules share a basename;
- `python/events`: the zone check reworded;
- `testing/tests`: at most one `conftest.py`, and basenames unique across `tests/`;
- the others only if their text changed what they decide.

Keep each to one line, with no `: ` and no ` #`, and read it back as YAML.

## Task 5: `.claude/commands/agent-os/shape-spec.md` (not the gate task)

- Step 5a lists `base/python/errors` as its fifth entry, and its note says these five do not apply
  here.
- The Step 5b note leaves out every standard under `python/` and `testing/` here. It says each is
  about a package and this repository has none, while a consuming project's Step 5a includes the
  core five and Step 5b surfaces the rest.
- In the Step 5b prompt and the `shape.md` template's Core Architecture and Standards Applied
  lines, the full keys (#12).

## Task 6: CHANGELOG, patchbay#12, and the patchbay issue (#5)

- **CHANGELOG:** a "Fourteenth spec" entry under `[Unreleased]` / `### Added`, one bullet per file
  changed. The thirteenth entry gains one sentence: Step 5a now holds errors too, by the
  fourteenth spec, as the eleventh entry was pointed at the twelfth.
- **fromtheoutfit/patchbay#12, body revised in place:** item 10 lists errors too (Step 5a is five,
  Step 5b leaves those five out), and item 11 names this revision.
- **New patchbay issue** for `Event.at`: the check `utcoffset(None) == 0` passes a tzinfo whose
  offset at the instant is not zero. Proposed: also refuse unless `at.utcoffset() == timedelta(0)`.
  It is verified against probe r and has a Rules line.

Both texts are shown to the owner with AskUserQuestion, and applied or filed only on approval.
Each is read back after, with no attribution.

## Task 7 (FINAL): Verification gate

1. Rerun `patchbay-evidence.txt` for the revised standards, from the thirteenth spec's script, into
   `verification/`. Every cited test is found and passes by node id, and every cited name is found.
2. `scripts/gate.sh` on the tree, in one run (every file under `base/` is tracked since
   `050d8b1`), exit 0, recorded as `verification/gate-run.txt` with the date and branch. No harness
   rerun: no file under `base/` is added, removed or renamed, and no gate file changes.
3. **Docs:** read against the change and recorded:
   - `CLAUDE.md`, `README.md` and `shape-spec.md`;
   - the seven standards' pointers to each other;
   - `standards-sync.md`, for patchbay#12;
   - `verification-gate.md`, for no rerun;
   - #24's proposals, still true (they cite the thirteenth spec's files).
4. **Version:** the CHANGELOG entry.
5. **Retrospective:** the four questions against the diff from `050d8b1`. The lesson of #1 is
   recorded: a probe's setup was not shown to do what it claimed, against a rule that exists. Any
   base proposal is presented with AskUserQuestion and filed, or marked declined. Always record
   `Proposals sent upstream:`.
6. The gate rerun is the last act. Then print `git status --short` and stop.

## Verification

- `scripts/gate.sh` exits 0 on the tree, with 12 standards and no findings.
- Probes p–s show what each reworded rule says: the escape not reported, two `conftest.py` refused
  by mypy, the custom tzinfo accepted at the same instant, int/int overflow only past float max.
- `grep -n "consider\|prefer"` finds nothing in the six standards. The bare keys are gone from
  `shape-spec.md`. Each standard has one provenance line, and "In this repository" and "In a
  consuming project" are one line each.
- The `index.yml` YAML parses with 12 entries.
