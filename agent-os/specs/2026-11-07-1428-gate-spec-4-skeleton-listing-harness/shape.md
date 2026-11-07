# Gate Spec 4: the Skeleton, the Listing Rule and the Harness — Shaping Notes

Shaped 2026-11-07 in plan mode with `/agent-os:shape-spec`. The owner answered the Step 1–5
questions and five design questions, recorded under Shaping answers and Decisions. Every answer
was the recommended option.

## Core Architecture (Non-Negotiable)

`base/python/toolchain` applies to consuming projects. This repository has no package, so it does
not apply here (Step 5a). This spec edits it as feature work (#20 proposal 4).

## Scope

Three issues, every proposal in them approved by the owner:

- **fromtheoutfit/patchbay-standards#17:** six proposals from this repository's own specs, to
  `base/process/verification-gate.md` (1–5) and `base/process/standards-sync.md` (6).
- **#19:** one, to `verification-gate.md`: a kept negative-test transcript holds one run.
- **#20**, as its body reads after its revision of 2026-11-07: proposals 1, 3, 6 and 8 to
  `verification-gate.md`, 4 to `base/python/toolchain.md`, 5 to `standards-sync.md`, and 7 to
  `scripts/sync-standards.sh`. Proposal 2 is withdrawn there.

A gate spec: `scripts/gate.sh`, `scripts/check-index.sh`, `scripts/sync-standards.sh`, the
harness and the gate task text change, each changed guard with its negative test and a mutation
that shows the test discriminates. The standards are written from those scripts as shipped, and
from fromtheoutfit/patchbay at `main` (`3f910d8`) for the cases #17 and #20 cite there. There is a
`CHANGELOG.md` entry, the gate is green, and `verification/gate-run.txt` has the date and branch.
No stage, commit, push or PR by an agent.

## Shaping answers

- **Step 1, scope:** the three issues as one gate spec on this branch, in the owner's sequence:
  the skeleton fixes with their tests and `sync-standards.sh:97`; the tracked-and-ignored refusal
  in step 1; the harness rules; the standards text; the CHANGELOG. `verification/gate-sh-diff.txt`
  against patchbay `main`, since the skeleton changes.
- **Step 2, visuals:** none.
- **Step 3, references:** patchbay's skeleton, harness tests g, p, q and r, and its revision's
  evidence; this repository's two mutation transcripts. See `references.md`.
- **Step 4, product context:** no `agent-os/product/`, so skipped.
- **Step 5, standards:** `process/verification-gate`, `process/standards-sync`,
  `process/standards-retrospective`, `process/ownership` and `process/standards-index`,
  snapshotted at `11ceffd` in `standards.md`.
- **The tracked-and-ignored refusal:** the whole tree, in step 1 of the shared skeleton, refused
  unconditionally.
- **`scripts/check-index.sh`:** its root guard, its listing without `-u`, and its bare exit when
  git cannot list are all fixed here, with tests.
- **#20 proposal 5:** a rule, not a script change: the sync's commit adds the entry.
- **#17 proposal 4:** the fixture rule and a rerun trigger; no fixture rewrite.
- **#17 proposal 6, applied to this spec:** the agent files one issue on fromtheoutfit/patchbay at
  the end, without attribution, recording the work patchbay's gate spec takes after its sync.

## Decisions

- **#17, #19 and #20 are one gate spec, because they write the same paragraphs and the same
  files.** All three edit `base/process/verification-gate.md`: #17's five proposals and #19's one
  rewrite "Every step that can fail is proven to fail" and "Every spec keeps its green run", and
  #20's 1, 3, 6 and 8 rewrite the listing bullet of "One script". #17 (6) and #20 (5) both edit
  "Pinned, not tracking" in `standards-sync.md`, and #20 (4) edits `toolchain.md`. #20's 6 and 7
  change `scripts/gate.sh` and `scripts/sync-standards.sh`, and #17's 4 and 5 and #19 are rules
  about the harness that changes with them. Landed apart, the same paragraphs would be rewritten
  three times and the harness rerun three times; together, one spec writes each paragraph once
  from the scripts as they end up, and one harness run covers every change. Proposals that need a
  gate file changed: #20's 1, 6 and 7, and #17's 4 and 5 (the harness; 5's harness half, `only`,
  shipped in PR 18's revision, so here it is the standard's text).
- **Where a proposal and the shipped code disagree, the code wins**, and each case is named here:
  - **#20 proposal 1**, restated on 2026-11-07, binds only a step that keeps the second form, a
    tool that reads `.gitignore` itself. No step here keeps it, and patchbay `main` has no such
    refusal: its test p reads a force-added file at step 2. The owner chose the refusal in step 1
    of the shared skeleton, over the whole tree, unconditionally, so every later step sees one set
    whichever form it takes. The standard is written from step 1 as shipped.
  - **#20 proposal 5** says the sync writes the `CHANGELOG.md` entry. `scripts/sync-standards.sh`
    is unchanged and still writes four things; the rule is that the sync's commit carries the
    entry, written from what the script reports.
  - **#20 proposal 6** names `scripts/gate.sh`. `scripts/check-index.sh` has the same root guard,
    lists without `-u`, and exits bare when git cannot list; it gets the same fixes, by the owner's
    answer, and the standard names it.
  - **#20 proposal 4's command lines** are checked word for word against patchbay `main`'s
    `scripts/gate.sh`.
- **The new cases join the tests that hold their step** (w for step 1, y for step 2, m and h for
  `check-index.sh`, u for the sync's refusals), since every letter a to z is taken. Each runs the
  script before this spec, at `11ceffd`, where it had the bug.
- **The harness gains `times <n> <line>`**, an exact count of one whole line, as patchbay's has: a
  conflicted path listed once is a passing run, and only a count tells it from three. A change to
  the harness's assertions, so it carries #17 proposal 2's proof: the copy with `-u` removed comes
  back `UNEXPECTED`.
- **Every guard this spec adds is shown to discriminate by a mutation**, the guard reverted in a
  fresh copy and its covering test `UNEXPECTED`, harness exit 1: `verification/guard-mutations.txt`.
- **Every rule about how a tool behaves is probed at its pin before it is written**
  (`base/process/standards-retrospective.md`): git and bash on scratch copies here; pytest, ruff
  and mypy on an export of patchbay at `3f910d8`, its `.venv` synced locked:
  `verification/probes.txt`.
- **Global excludes count in the refusal.** `--exclude-standard` reads `core.excludesFile`, so a
  tracked file a developer's global excludes match fails step 1 on that machine and not in CI. That
  is the listing's existing limit, which already reads global excludes for untracked files; the
  probe shows it, and the fix is a negation pattern in `.gitignore`, not a weaker listing.
- **A spec that adds, removes or renames a file under a directory the harness copies reruns the
  harness** (#17 proposal 4, the trigger chosen at shaping), and a case whose expectation depends on
  what a copied directory holds sets the whole of that directory. The audit at `1e88c77` stands: g
  was the one case silently dependent on the copied `base/`, and it now empties it.

## Context

- **Visuals:** None.
- **References:** `references.md`.
- **Product alignment:** N/A; there is no `agent-os/product/` here.

## Standards Applied

**Core (Step 5a, consuming projects):**

- `base/python/toolchain` — not applied here: no package (Step 5a). Edited as feature work.

**Feature-specific:**

- `process/verification-gate` — the gate's own spec: the skeleton, the listing rule, the harness,
  each changed guard with its negative test.
- `process/standards-sync` — `sync-standards.sh` is a gate file in every project, changed here
  with tests o to v; "Pinned, not tracking" gains two rules.
- `process/standards-retrospective` — the probe rule; present-and-file for any proposal.
- `process/ownership` — no stage, commit or push; issues without attribution.
- `process/standards-index` — the three descriptions kept in step with what the standards decide.

## Verification Gate

Spec is not complete until `scripts/gate.sh` passes — `bash -n` on every shell script under
`scripts/` as git lists them, at a work-tree top that is the repository root, with no tracked file
git ignores; `pymarkdown`, installed at its pin through `uvx` as its own check, over the `.md` files
under `base/` and `README.md` as git lists them; and `scripts/check-index.sh` — and the three
judgment steps are recorded, in this order: Docs, Version, then the standards retrospective below.

**Results (2026-11-07):** exit 0 on branch
`task/17-gate-spec-4-land-six-base-proposals-from-this-repositorys-specs-verification-gatemd-standards-syncmd`,
`verification/gate-run.txt`, the last thing done before hand-over. The gate was green after each
step of the owner's sequence: the skeleton fixes, the refusal, the harness rules, the standards
text. Every gate file changed, so every negative test was rerun after the last edit:

- `verification/probes.txt`: git, bash, pytest, ruff and mypy at their pins, before any gate file
  was edited. All six sections confirm the claims the rules rest on, and section 5 found a gap in
  patchbay's step 5: an ignored root `pytest.ini` is read, and its refusal does not name it.
- `verification/gate-negative-tests.txt`: one run, every test but j, `167 runs, 0 unexpected`,
  `harness exit=0`. The run before it, made before the base text was trimmed (Retrospective,
  deviations), gave the same count and was replaced, not kept.
- `verification/ci-negative-test.txt`: j, `2 runs, 0 unexpected`; the workflow is unchanged.
- `verification/guard-mutations.txt`: M1–M10, each guard this spec added put back or deleted in a
  fresh copy, each `UNEXPECTED`, harness exit 1. M2 is `times`' proof.
- `verification/gate-sh-diff.txt`: against patchbay `main`. Beyond step lists, pins and paths it
  holds exactly the refusal, the hunk patchbay takes after its sync.

**Docs (step 4):**

- **Script headers, each read against the code beside it:**
  - `scripts/gate.sh`: the listing paragraph (each path once, the empty record, the root guard
    asked of git, step 1's refusal) and step 1's banner. Its shared sentences now match patchbay
    `main`'s byte for byte, as `verification/gate-sh-diff.txt` shows.
  - `scripts/check-index.sh`: the root guard, each path once, a listing git cannot make.
  - `scripts/sync-standards.sh`: the root asked of git.
  - `scripts/gate-negative-tests.sh`: `times`, the shim, the mutation rule, one run per kept
    transcript, the fixture rule and rerun trigger, the test list (h, m, w, y, u), and which tests
    run scripts from history and when they are skipped.
- **`CLAUDE.md` and the gate task in `.claude/commands/agent-os/shape-spec.md`** (step 1 and the
  `shape.md` template's Verification Gate paragraph): step 1 refuses a tracked file git ignores.
  The plan's Task N in `plan.md` already says so.
- **`README.md`:** one line, naming nothing this spec changed; reads true.
- **The three standards and `index.yml`:** each rewritten paragraph re-read against the scripts as
  shipped and patchbay at `3f910d8`; the three descriptions say what each standard now decides,
  with no `: `. Searched the tree outside `agent-os/specs/` and `CHANGELOG.md` for
  `show-toplevel`, `sort -z;`, `issue #10 holds`, `holds the current`, "A key the tool does not
  know", `ruff format --check .`, `exclude_gitignore` and "spec that last changed the harness":
  every remaining hit is deliberate (the standard naming the comparison it forbids, the sync
  script resolving a checkout's top without comparing, the harness showing git's top in w).
- **Line widths:** no prose line this spec added is over 100 columns.

**Version (step 5):** under `[Unreleased]`, `### Added`, in `CHANGELOG.md`: the eleventh spec's
entry, naming the three issues, the `base/` lines, the gate files, the sync-commit entry rule and
patchbay's work (fromtheoutfit/patchbay#12). No version bump: this repository has none.

## Standards Retrospective

Step 6, always last, from the shipped diff against `11ceffd`. This spec's feature is base standards
text, landed as the three issues approved it; the retrospective asks what the work taught beyond
them.

1. *A pattern no standard covers?*
   - **Each guard a gate spec adds was shown covered by a mutation** (Decision, at shaping). The
     landed rule (#17 proposal 2) covers a change to the harness's assertions; a first draft of
     the base text extended it to every added guard, beyond what the owner approved, and was
     trimmed back before the last harness run. Proposed below.
   - **A negative test of a fixed bug also runs the script from before the fix**, where its
     commit is present, to show the case fails there as the bug did: h, m, u, w and y here, at
     `11ceffd`, as g, k, l, r, w and y did before, and patchbay's g. Every gate spec has copied it,
     and no standard says it. Proposed below.
   - The git shim that refuses one call reaches a listing failure no broken tree can reach once
     an earlier listing has passed. The harness bullet already asks every step that can fail to be
     shown failing, and z hides `uvx` by `PATH` the same way. Not proposed.
2. *A standard wrong or stale?* The refusal form, as landed, says what pytest loads (`conftest.py`)
   but not that the tool's configuration is among what it reads: the probe found pytest reading an
   ignored root `pytest.ini` in place of `pyproject.toml`. The rule's "any file git ignores there
   that the tool would read" covers it, and patchbay's step 5 misses it (fromtheoutfit/patchbay#12,
   item 8). A first draft named it in the base text, which the plan had said it would not, and was
   trimmed back. Proposed below.
3. *A deliberate deviation?*
   - **Deviation, not a standard change:** the plan gave w a shim run refusing ` --ignored `. It
     was not added: the corrupt index, with the real git, already fails at the refusal's listing
     first, and M6 shows that case covers the guard.
   - **Deviation, not a standard change:** `VIRTUAL_ENV`, which this shell set to an unrelated
     project, was unset for every recorded run; uv would only have warned that it ignored it. Each
     transcript says so.
   - The proposals where the shipped code won are Decisions, not deviations: #20's 1, 5 and 6 and
     4's command lines.
4. *A moved pointer?* Fixed in this spec's feature diff: "the spec of issue #10 holds the current
   diff" and "the revision after the review of PR 18 holds the current transcripts" in
   `verification-gate.md` now name this spec; `toolchain.md` names `3f910d8` beside `73a583a`;
   the three descriptions in `index.yml` follow the text. No standard names a file this spec moved
   or removed.

No project standard exists here to edit. The retrospective's own change set is this section and
the issue below; it edited no file outside this spec folder.

Proposals sent upstream: fromtheoutfit/patchbay-standards#22; declined:
`base/process/verification-gate.md` (old-script demo).

### Standards retrospective (proposed, base)

Presented to the owner on 2026-11-07 with AskUserQuestion, multi-select, in one question: the
three below and "None of these". Two were approved and filed as one issue,
fromtheoutfit/patchbay-standards#22, a standards spec since neither needs a gate file changed here,
with no AI attribution; one was declined.

- `base/process/verification-gate.md` — "A change to the harness's assertions is shown to
  discriminate": a guard a gate spec adds is shown covered the same way, put back or deleted in a
  fresh copy, its covering case `UNEXPECTED`, harness exit 1. Verified against
  `verification/guard-mutations.txt` (M1–M10, `scripts/gate.sh`, `check-index.sh` and
  `sync-standards.sh` as shipped) and patchbay's revision `reason-assertion-mutations.txt`
  M1–M4. Proposed, not applied; filed as fromtheoutfit/patchbay-standards#22.
- `base/process/verification-gate.md` — "Every step that can fail is proven to fail": a negative
  test of a fixed bug also runs the script at a commit before the fix, where the clone holds it,
  and shows the case failing there as the bug did, skipped by name where the commit is absent.
  Verified against `scripts/gate-negative-tests.sh` (`old_file`; h, m, u, w and y at `11ceffd`) and
  its transcript in `verification/gate-negative-tests.txt`. Proposed, not applied; declined by
  owner, 2026-11-07.
- `base/process/verification-gate.md` — "One script", the refusal form: the tool's configuration
  is among what it would read; pytest 9.2.0 reads an ignored `pytest.ini` at the root in place of
  `pyproject.toml`. Verified against `verification/probes.txt` section 5; patchbay's step 5 takes
  the refusal in fromtheoutfit/patchbay#12. Proposed, not applied; filed as
  fromtheoutfit/patchbay-standards#22.
