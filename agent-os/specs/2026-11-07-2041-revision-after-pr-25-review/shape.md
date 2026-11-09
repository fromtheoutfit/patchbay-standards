# The Revision after the Review of PR 25 — Shaping Notes

Shaped 2026-11-07 in plan mode with `/agent-os:shape-spec`. The owner answered the Step 1, 2, 3 and
5 questions and four design questions, recorded under Shaping answers; Step 4 was skipped, this
repository having no `agent-os/product/`. Every answer was the recommended option but one: for
finding 5 the owner chose to file a patchbay issue as well as reword the rule.

## Core Architecture (Non-Negotiable)

`base/python/toolchain`, `base/python/layout`, `base/python/typing` and `base/python/models` —
apply to consuming projects; this repository has no package, so they do not apply here (Step 5a).
This spec adds `base/python/errors` to the tier; it does not apply here either.

## Scope

The owner's review of fromtheoutfit/patchbay-standards#25 at `050d8b1` (a PR comment,
2026-11-07T21:25:30Z), the thirteenth spec
(`agent-os/specs/2026-11-07-1549-contracts-standards-and-toolchain/`, issue #21), lists fourteen
findings: two serious, five of accuracy, seven of consistency. This spec answers all fourteen, in a
folder of its own on the same branch, so PR 25 carries it. A standards spec: no gate file changes.
CHANGELOG entry, gate green, `verification/gate-run.txt` with date and branch. No stage, commit,
push or pull request by an agent.

## Shaping answers

- **Step 1, scope:** all fourteen, in a new folder. The thirteenth spec's folder stays its record,
  unedited; its two misstatements are recorded as corrected here. Every factual finding is
  reproduced or probed before it is fixed. The harness is rerun only if a file under `base/` is
  added, removed or renamed.
- **Step 2, visuals:** none.
- **Step 3, references:** the review, the thirteenth spec's folder, the revision after the review
  of PR 23 as a revision's shape, patchbay at `7471387` (`references.md`).
- **Step 4, product context:** no `agent-os/product/`. Skipped.
- **Step 5, standards:** the five under `base/process`, snapshotted at `050d8b1` in `standards.md`.
  The seven Python and test standards are the text under review, listed in `references.md`.
- **Findings 8 and 9, the tiers** (owner): `python/errors` joins Step 5a, five standards; here,
  Step 5b leaves out every standard under `python/` and `testing/`.
- **Finding 3, the mirror** (owner): a `layout.md` rule, no two modules of the package share a
  basename, `tests.md` pointing to it.
- **Finding 13, the provenance** (owner): trimmed and kept per standard: one provenance line, and
  one line each for "In this repository" and "In a consuming project".
- **Finding 5, the UTC rule** (owner): the rule reworded to its check, the gap named, and a
  patchbay issue filed, its text approved first.

## Decisions

- **The review is the scope, answered in a folder of its own.** Each finding was checked against
  the shipped files before shaping; the four that rest on a tool's behaviour are probed here, p to
  s (`verification/probes.txt`), the letters going on from the thirteenth spec's so a letter names
  one probe. The probe file of p is written with the escape as six ASCII characters and its bytes
  are shown before ruff runs: a `\u` escape typed into a tool call reaches the file as the
  character, which is how the thirteenth spec's probe o came to hold the literal.
- **The dispositions, one per finding:**
  1. *Probe o's "escape" is the literal.* Confirmed: the thirteenth spec's `probes.txt` shows
     `DIGIT = "١"`, reported RUF001, and its summary's "not its escape" was never tested. Probe p
     writes the escape and shows RUF001 and RUF003 reporting the character and neither its escape.
     `tests.md` cites o for the character, p for the escape. The thirteenth spec's summary line
     stays as recorded; this is its correction.
  2. *Two `conftest.py` are one module name to mypy.* Confirmed by probe q: "Duplicate module named
     conftest", pytest loading both. `tests.md`: every module under `tests/` has a basename of its
     own, `conftest.py` included, so `tests/` holds one `conftest.py` at most, in the directory that
     holds every test taking its fixtures.
  3. *The mirror rule meets the basename rule.* `layout.md` gains: no two modules of the package
     share a basename, its subpackages' included, `__init__.py` the named exception; patchbay's
     seven are seven names. `tests.md`'s mirror points to it.
  4. *Strict is not inherited.* Confirmed by `strict_nested.py` 2. `models.md`: a dict for a
     nested model is validated by the nested model's own config, strict where it is on the base;
     every model a model holds is on the base, so strict holds at every depth.
  5. *`utcoffset(None)` is not every instant.* Confirmed by probe r: a `tzinfo` answering zero for
     `None` and +01:00 at every instant is accepted, held as the same instant in UTC. `events.md`
     states the check, what passes and what is refused, and names that case.
     fromtheoutfit/patchbay#13 proposes the check also refuse a nonzero offset at the instant.
  6. *"at any size".* Confirmed by probe s: `10**400 / 1` and `2**1024 / 1` raise `OverflowError`.
     `models.md`: int over int overflows only where the quotient passes the largest float, as an
     array's length over a positive rate never does.
  7. *"a to o".* The thirteenth spec's new probes are a to f and j to o; its `shape.md` says "a to
     o" and stays as recorded; this is its correction.
  8. *Step 5b left out only four.* Here, Step 5b leaves out every standard under `python/` and
     `testing/`, each about a package.
  9. *errors in Step 5b.* `python/errors` joins Step 5a; `errors.md`'s closing lines say so;
     fromtheoutfit/patchbay#12, revised in place again, lists five.
  10. *Two intros misdescribe their evidence.* Gone with 13: the one provenance line names both
      specs' `verification/` and how probes are cited.
  11. *The `issubclass` ignore's code.* Each of the six is named with its code.
  12. *Bare keys.* The Step 5b prompt and the `shape.md` template name each standard by its full
      key, `base/python/layout` and so on.
  13. *Provenance repeated.* One line per standard: written from patchbay at `7471387`, whose
      contracts spec and its revision record the choices, the evidence in the `verification/` of
      #21's spec and of this revision. "In this repository" and "In a consuming project" are one
      line each. A standard not re-read later keeps citing the commit it was verified at, which
      stays true.
  14. *`toolchain.md`'s paragraph.* Reflowed.
- **No harness rerun.** No file under `base/` is added, removed or renamed, and no gate file
  changes, so the fixture rule does not ask for one (`base/process/verification-gate.md`).

## Context

- **Visuals:** None.
- **References:** `references.md`.
- **Product alignment:** N/A.

## Standards Applied

**Core (Step 5a, consuming projects):**

- `base/python/toolchain`, `base/python/layout`, `base/python/typing`, `base/python/models`,
  `base/python/errors` — not applied here: no package (Step 5a). All five are text this spec revises.

**Feature-specific:**

- `base/process/standards-retrospective` — the probes p to s, the citation check rerun, the
  proposal presented and filed.
- `base/process/standards-index` — three descriptions rewritten where their rules changed.
- `base/process/verification-gate` — the gate run; no harness rerun, as above.
- `base/process/standards-sync` — patchbay#12 revised in place for the tier.
- `base/process/ownership` — no stage, commit or push; every issue text approved before it was
  sent, with no attribution.

## Verification Gate

Spec is not complete until `scripts/gate.sh` passes — `bash -n` on every shell script under
`scripts/` as git lists them, with no tracked file a `.gitignore` ignores, `pymarkdown`, installed
at its pin through `uvx` as its own check, over the `.md` files under `base/` and `README.md` as
git lists them, and `scripts/check-index.sh` — and the three judgment steps are recorded, in this
order: Docs, Version, then the standards retrospective below.

**Results (2026-11-07):** exit 0 on branch
`task/21-standards-spec-write-basepython-models-errors-events-testing-typing-and-layout-from-patchbays-contracts-spec-and-correct-toolchainmd`,
one run on the tree (every file under `base/` is tracked since `050d8b1`), pymarkdown finding
nothing in 13 files and step 3 agreeing on 12 standards: `verification/gate-run.txt`, the last
thing done before hand-over. No gate file changed and no file under `base/` was added, removed or
renamed, so no negative test was rerun. The other verification files:

- `verification/probes.txt`: probes p to s, each source shown before its output, p's escape shown
  byte by byte.
- `verification/patchbay-evidence.txt`: the citation check rerun on the standards as revised: 270
  tests pass on the export of `7471387`, the 77 the seven standards cite are found by name and pass
  by node id, 200 cases, and 23 cited names are found.

**Docs (step 4):**

- **`README.md`** and **`CLAUDE.md`:** name no tier and no standard by topic; read true.
- **`.claude/commands/agent-os/shape-spec.md`:** Step 5a lists five; Step 5b's note leaves out
  `python/` and `testing/` here and says what a consuming project does; the prompt and the
  template's two lines name full keys. The gate task and its template paragraph are untouched.
- **The seven standards:** every `base/...md` each names exists; every probe letter cited is
  defined, a to f and j to o in the thirteenth spec's `probes.txt`, p to s in this one's; every
  test and name cited is found at `7471387` (`verification/patchbay-evidence.txt`); none says
  "consider" or "prefer". `layout.md` and `tests.md` point to each other for the basename rule.
- **`base/process/standards-index.md`:** the descriptions of `python/layout`, `python/events` and
  `testing/tests` are rewritten with their rules, one line each, no `: ` and no ` #`; read back as
  YAML, twelve entries. `python/errors`'s rule did not change, only its tier, which no description
  names.
- **`base/process/standards-sync.md`:** the change of tier leaves patchbay's Step 5a behind, and
  the CHANGELOG entry and patchbay#12 name the work. Reads true.
- **`base/process/verification-gate.md`:** the fixture rule asks for no rerun here (above); its "In
  this repository" reads true.
- **fromtheoutfit/patchbay-standards#24:** its four proposals cite the thirteenth spec's files,
  which stand as recorded; none is made true or false by this revision (`layout.md` still lacks
  `py.typed`, `tests.md` the event-assertion rule).
- **fromtheoutfit/patchbay#12** (revised in place, read back identical but for the final newline,
  2026-11-08T01:59:38Z) and **fromtheoutfit/patchbay#13** (filed, read back the same way,
  2026-11-08T01:59:40Z): texts approved by the owner first; no attribution.
- **The thirteenth spec's folder:** unedited. Its `verification/probes.txt` summary says ruff
  reports the literal and "not its escape", and its `shape.md` says the new probes run "a to o";
  dispositions 1 and 7 above are their corrections.

**Version (step 5):** the fourteenth spec's entry under `[Unreleased]`, `### Added`, in
`CHANGELOG.md`; the thirteenth's bullet on `shape-spec.md` gains that the fourteenth adds
`base/python/errors` to the tier. No version to bump.

## Standards Retrospective

Step 6, always last, from the shipped diff against `050d8b1`.

1. *A pattern no standard covers?* The one-line provenance and closing form the six took
   (finding 13). `base/python/toolchain.md`, the one base standard written from a consuming project
   before them, keeps the long form of its closing sections: proposed below.
2. *A standard wrong or stale?* The six and `shape-spec.md`, as the review found; corrected as this
   spec's feature work. No other standard read stale (Docs, above).
3. *A deliberate deviation?*
   - **Deviation, not a standard change:** the thirteenth spec's probe o did not show its setup
     doing what it claimed, against `base/process/standards-retrospective.md`'s "the probe's setup
     is shown to have done what it claims before its result is read". The rule stands and was not
     followed; probe p shows its bytes. The cause, a `\u` escape decoded in a tool call before it
     reached the file, is this environment's, not a standard's.
   - **Deviation, not a standard change:** the thirteenth spec's folder is left as recorded, two
     statements in it false; this spec's dispositions 1 and 7 are their corrections, as the
     revision after the review of PR 23 left the eleventh spec's folder.
4. *A moved pointer?* `base/python/errors` moved tier: its closing lines, `shape-spec.md` and
   patchbay#12 follow it. No path moved.

No project standard exists to edit. `index.yml`'s three descriptions changed with their rules, as
feature work. The retrospective's own change set is this section and the CHANGELOG entry's
"Proposals sent upstream" bullet.

Proposals sent upstream: fromtheoutfit/patchbay-standards#26

### Standards retrospective (proposed, base)

Presented to the owner on 2026-11-07 with AskUserQuestion, multi-select, in one question ending
with "None of these". Approved and filed as fromtheoutfit/patchbay-standards#26, a standards spec,
since it needs no gate file changed, with its verification pointer, a "Depends on" naming this
branch, and the rules its spec is held to. No AI attribution. Read back from GitHub, identical but
for the final newline `gh` drops (2026-11-08T02:00:06Z).

- `base/python/toolchain.md` — "In this repository" and "In a consuming project" take the one-line
  form the six took after this review; what its "In this repository" says beyond that is the
  header's (the commit each section was read at) or `verification-gate.md`'s (pymarkdown's
  no-manifest form); its header keeps the per-section commits. Verified against the six standards
  as this spec ships them. Proposed, not applied; filed as fromtheoutfit/patchbay-standards#26.
