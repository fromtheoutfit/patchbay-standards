# References for the two base standards (gate and index)

## Similar Implementations

### The two shipped base standards

- **Location:** `base/process/ownership.md`, `base/process/standards-retrospective.md`
- **Relevance:** Shape and voice for the two new files.
- **Key patterns:** one opening paragraph saying what the standard governs and why; headed rule
  sections whose first words are bold and imperative; exceptions named inline with their condition;
  a closing "In a consuming project" section naming the synced path.

## Shipped sources each standard is verified against

### `base/process/verification-gate.md`

- `scripts/gate.sh` — `set -euo pipefail`, the numbered step banners, the pinned version in one
  variable, the pinned tool run through `uvx`, `--strict-config`, the closing line naming the
  retrospective as step 4.
- `scripts/check-index.sh` — a failing step names its reason (`FAIL  ...`) and exits non-zero.
- `.pymarkdown.yaml` — the rule set in a versioned config file; its header says it changes only
  outside a spec.
- `agent-os/specs/2026-11-04-0750-shape-spec-gate-retrospective/verification/gate-run.txt` — the
  green run kept with the spec.
- `agent-os/specs/2026-11-04-0750-shape-spec-gate-retrospective/verification/gate-negative-tests.txt`
  — six broken scratchpad copies, each failing with its named reason and exit status; later steps
  not reached.
- `CHANGELOG.md` — the Unreleased entry naming what a sync would bring in (the Version step).
- `README.md`, `.claude/commands/agent-os/shape-spec.md` Task N and Step 8, `CLAUDE.md` "Specs"
  — the gate as the definition of done, fix at the cause, do not bypass.

### `base/process/standards-index.md`

- `index.yml` — one `base:` section, keys as paths relative to `base/` without `.md`, one
  description line per entry, no `: ` in a value.
- `scripts/check-index.sh` — every file has an entry, no entry lacks a file, only `.md` under
  `base/`, `agent-os/standards/index.yml` identical to `index.yml`.
- `agent-os/standards/` listing — `index.yml` identical to the root, `base` a symlink to
  `../../base`.
- `base/process/standards-retrospective.md`, "Keep the index in step" — a standard not indexed is
  invisible; a base change carries its entry; the description is what retrieval matches.
- `.claude/commands/agent-os/index-standards.md` lines 66–99 and `inject-standards.md` lines
  61, 78 — the stock commands read two levels, folder then file, and match descriptions.

## Revision after review (2026-11-04)

- The review comment on PR 5 (30 findings, five groups, one open question): the list every
  change in the revision answers.
- `scripts/gate.sh` line 35 and `scripts/check-index.sh` lines 7-8, 18, 31-41 — the closing line
  names one judgment step; the header points at the trimmed `index.yml` header; `comm` runs in
  the user's locale over `LC_ALL=C` input.
- `.claude/commands/agent-os/index-standards.md` Steps 1, 5 and 6 — the reserved `root` section;
  stale entries removed without confirmation; the whole file regenerated; folders alphabetized;
  descriptions one short sentence.
- The first commit (`9833422`) — the `README.md` fix was one blank line after the heading.
- Two reproductions made outside the tree during shaping: `comm -23` without `LC_ALL=C` on
  C-sorted `{process/B, process/a_z, process/ab}` against `{process/a_z, process/ab}` reports all
  three missing under `LANG=en_US.UTF-8`; pymarkdownlnt 0.9.41 with `--strict-config` and a
  misspelled `line_lenght: 120` key reports `MD013 Expected: 80` and no config error, while an
  unparsable file fails with "not a valid YAML file" and exit 1.
