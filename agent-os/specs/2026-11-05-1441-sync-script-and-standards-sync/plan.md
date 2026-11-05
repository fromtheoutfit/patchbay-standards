# Sync spec: `scripts/sync-standards.sh`, the safe index regeneration, and `base/process/standards-sync.md`

Shaped 2026-11-05 in plan mode with `/agent-os:shape-spec`; the Step 1–5 questions and the four design
decisions were asked and answered by the owner (recorded under Decisions).

## Context

GitHub issue #8. Until a sync script exists, a consuming project copies the `base:` section by hand at a
recorded commit (`base/process/standards-index.md` allows this as the interim) and the stock
`/agent-os:index-standards` is unsafe on a synced index with no safe replacement. This spec ships the
sync, the drift check, the safe regeneration, and the standard that describes them, verified against
the scripts as shipped. Branch `feature/8-sync-spec-...` is checked out and clean at `a05a630`.

Branch protection on `main` now exists (`required_status_checks.contexts: ["gate"]`, `strict: true`,
`enforce_admins: true`), so the "does not pass the gate" wording can become "does not merge".

Build order (owner's), gate green after each part: sync script + negative tests on a scratch project;
drift check; index regeneration (`--index-only`); `standards-sync.md` and the `standards-index.md`
pointers written from the shipped script; "does not merge" with the protection output recorded.

## Decisions

- **Issue #8 is the scope.** Nothing outside it changes but `CHANGELOG.md`, `index.yml` (new entry,
  rewritten `standards-index` description) and the spec folder. README unchanged (reads true).
- **Drift check is `--check` on the sync script** (owner): one file copied into each project, one
  version carried; it reuses the export and the section extraction, writes nothing.
- **Upstream path argument with a sibling default** (owner): `<path>` defaults to
  `../patchbay-standards`, the sibling layout every checkout follows; a path that is not a
  patchbay-standards checkout fails with exit 2 naming the path. A project's CI adds one checkout step
  for the sibling. No clone fallback, no manifest.
- **Replace by `git archive` into a temp dir, compare by sorted lists + `cmp`, then swap** (owner):
  needs only git, tar, comm, cmp; the sync's report and `--check` use the same comparison so they
  cannot disagree. Swap is `rm -rf` then `mv` (a directory nothing else holds open).
- **Self-copy from the synced commit, `mv`'d over the project's script as the last act** (owner): tree
  and script come from one commit; the running bash keeps the old inode.
- **All four base standards are feature-specific** (owner); three are edited as this spec's feature
  work on this branch (`standards-index`, `standards-retrospective`, `verification-gate`), written
  last from the shipped files, never from this plan.
- **Section extraction rule** (decided here, documented in the script header): the `base:` section is
  the line `base:` (nothing after the colon) plus every following line that is indented, blank, or a
  column-0 comment, ending at the last indented line; trailing blanks/comments and the next
  column-0 key belong to the project. Two `base:` lines, or a `base:` line with content after the
  colon, is "not parseable" (exit 2). `--init` inserts the section with one blank line each side,
  before the first column-0 key other than `root:` that sorts after `base` (C collation), else at EOF;
  with no index file at all it creates `agent-os/standards/index.yml` holding the section alone.
- **Exit codes**: 0 success; 1 a failed check (drift under `--check`, or the post-write verification
  of a sync); 2 usage and preconditions (bad flag, not at a git work-tree root, running inside
  patchbay-standards itself where `agent-os/standards/base` is a symlink, upstream not a checkout or
  ref not a commit, no parseable `base:` section without `--init`, `--check`/`--index-only` with a ref,
  `--check` with no `.version`).
- **`.version` is the one non-`.md` file under a project's `agent-os/standards/base/`**, written after
  the swap, excluded from every comparison.
- **Project-side file list mirrors `check-index.sh`**: tracked plus untracked-not-ignored under
  `agent-os/standards/base`, existing on disk; an ignored `.DS_Store` is never drift.
- **No Plan/Explore subagents**: the repository is five scripts and four standards, all read.

## Task 1: Save spec documentation

`agent-os/specs/2026-11-05-1441-sync-script-and-standards-sync/` with `plan.md` (this plan),
`shape.md` (template from `shape-spec.md`: Core Architecture "none yet; see Step 5a", Scope, Decisions
above with issue #8 as the first, Context: visuals none / references / product N/A, Standards Applied,
Verification Gate and Standards Retrospective filled at the end), `standards.md` (full text of the
four `base/process/*.md` as they read now), `references.md` (check-index.sh awk + tracked-files
rule, gate-negative-tests.sh `mk`/`run`/`hdr`/`note`, gate.sh banners, the four spec folders),
`verification/` (filled by Task 7). No `visuals/`.

## Task 2: `scripts/sync-standards.sh` and its negative tests (sync behaviours)

New file, bash 3.2-compatible (no `mapfile`, no associative arrays), `set -euo pipefail`,
`export LC_ALL=C`, header in the style of `scripts/check-index.sh` listing every behaviour and the
section rule. Usage:

```
scripts/sync-standards.sh [--init] [<path-to-patchbay-standards> [<ref>]]   sync (default ref: HEAD)
scripts/sync-standards.sh --index-only [<path>]                               regenerate base: alone
scripts/sync-standards.sh --check [<path>]                                    drift check (Task 3)
```

Runs from the consuming project's root (cwd), not from `$(dirname "$0")`, because the first run is
`../patchbay-standards/scripts/sync-standards.sh --init`. Steps:

1. Parse flags; usage text on `--help`/bad flag (exit 2). Preconditions as in Decisions.
2. Resolve upstream: `up=$(cd "$path" && pwd -P)`; `git -C "$up" rev-parse --show-toplevel`; sha from
   `rev-parse --verify "$ref^{commit}"` (sync) or from `.version` (`--index-only`, `--check`);
   `cat-file -e` for `$sha:base`, `$sha:index.yml`, `$sha:scripts/sync-standards.sh`, else exit 2.
3. Export: `git -C "$up" archive --format=tar "$sha" base index.yml scripts/sync-standards.sh | tar -x
   -C "$tmp"` (never the working tree). `tmp=$(mktemp -d)`, trap cleans it.
4. `base_section <file>` (awk, rule in Decisions) and `section_bounds <file>` (first/last line
   numbers, or none). Regenerated index = head before + upstream section + tail after; `--init`
   insertion per Decisions. Section replaced only when its bytes differ (`cmp`), so the status is
   `created | replaced | unchanged`.
5. Compare (shared with Task 3): project list (tracked + untracked-not-ignored, on disk, minus
   `.version`) vs export list (`find -type f`), both sorted, checked sorted, `comm` for
   added/removed, `cmp` for changed.
6. Sync: `rm -rf agent-os/standards/base && mv "$tmp/base" agent-os/standards/base`; write
   `"$sha"` to `.version`; regenerate index; re-run the comparison and the section `cmp` as a
   post-write verification (exit 1 if they disagree); copy `$tmp/scripts/sync-standards.sh` to
   `scripts/sync-standards.sh.new` then `mv` over (`chmod +x`) as the last act, status
   `installed | updated | unchanged`.
7. Report on stderr (`sync base standards: <old|none> -> <new>  (<up>, ref <ref>)`, then one line per
   `added`/`removed`/`changed` path, `index ...`, `script ...`); one JSON object on stdout built by a
   small escaper (`\` and `"`): `{"mode":"sync","upstream":...,"ref":...,"old":<sha|null>,"new":...,
   "added":[...],"removed":[...],"changed":[...],"index":"...","script":"..."}`.

Negative tests appended to `scripts/gate-negative-tests.sh` (letters continue: `o p q r s t u v`,
added to the default list, the usage line and header). New helpers beside `mk`:

- `mk_upstream <dir>`: git init + copy of the working tree's `base/ scripts/ index.yml .gitignore
  .pymarkdown.yaml README.md` + commit (identity via `-c user.name/user.email`, `commit.gpgsign=false`),
  so the shipped (possibly uncommitted) script is what the scratch checkout holds at HEAD.
- `mk_project <dir>`: a realistic Agent OS install, git init + commit: `pyproject.toml`
  (`[project] name = "scratch"`), `CLAUDE.md`, `agent-os/standards/index.yml` with a header comment,
  `root:` (`coding-style`), a blank line, a comment line, `testing:` (`fixtures`), a trailing comment;
  `agent-os/standards/coding-style.md`; `agent-os/standards/testing/fixtures.md`. No `base:` section.
- `run` reused (it rewrites `$NEG/<x>` to `<copy x>`); tests nest as `$NEG/o/project` beside
  `$NEG/o/patchbay-standards` so the sibling default is what is exercised.

Tests in this task: **o** first sync (no `--init` → exit 2 naming the missing section, tree untouched;
with no sibling present → exit 2 naming `../patchbay-standards`; `--init` with the default path →
exit 0, `.version` equals upstream HEAD, section `cmp`-equal to the upstream's, script installed, own
sections byte-identical by `cmp` against a hand-built expected file); **p** a working-tree edit in the
upstream is not synced (project file still equals the committed bytes; report lists no change), then an
upstream commit adding `base/process/new.md` + entry is synced (reported `added`, index `replaced`);
**q** an upstream commit removing it is synced (file gone, reported `removed`); **u** refusals: run
inside the scratch upstream itself (symlink), not a work-tree root, a plain directory as `<path>`, a
ref that is not a commit, an unknown flag — each exit 2 by name; **v** self-copy: an upstream commit
touching `scripts/sync-standards.sh` (appended comment) is copied on the next sync (`updated`, bytes
equal, exit 0, JSON printed), and a working-tree edit to it is not.

Gate green after this task (step 1 parses the new script).

## Task 3: `--check`, the drift check

Same script: resolve the commit from `.version` (exit 2 if absent or not in the checkout), export,
run the comparison of Task 2 step 5 plus `cmp` of the two `base:` sections plus `cmp` of
`scripts/sync-standards.sh`; report `missing`/`extra`/`changed` paths, `index identical|differs`,
`script matches|differs` on stderr; JSON `{"mode":"check","commit":...,"missing":[],"extra":[],
"changed":[],"index":"...","script":"...","ok":true|false}`; exit 0 clean, 1 drift. Writes nothing.

Test **t**: after a sync `--check` passes; a one-byte edit to a synced file fails naming the path
(exit 1); an extra file under base/ is `extra`; a deleted file is `missing`; an ignored `.DS_Store`
is not drift; `--check <ref>` and `--check` without `.version` are exit 2. Gate green.

## Task 4: `--index-only`, the safe regeneration

Same script: commit from `.version`, export, regenerate the `base:` section only (Task 2 step 4),
touch no file under base/ and not the script; JSON `{"mode":"index-only","commit":...,"index":"..."}`.

Tests: **s** a hand-edited description in the project's `base:` section is reported by `--check`
(exit 1, `index differs`); `--index-only` repairs it (`replaced`), `--check` then passes, and
`git status --short agent-os/standards/base scripts` is empty (nothing else touched); **r** own
sections survive: the decorated index of `mk_project` after `--init`, after a no-op second sync, and
after `--index-only` each `cmp`-equal to the hand-built expected file, and the pre/post parts are
byte-identical to the original. Gate green.

## Task 5: `base/process/standards-sync.md`, pointers, `index.yml`

Written from the shipped script and harness, not from this plan. Lines ≤ 100 columns, pymarkdown clean.

- **`base/process/standards-sync.md`** (new): intro (how a project takes `base/`; pinned, not
  tracking); "What the sync writes and nothing else" (base/ whole, `.version`, the `base:` section,
  `scripts/sync-standards.sh`); "The invariant" (base/ minus `.version`, and the `base:` section,
  byte-identical to patchbay-standards at the pinned commit; `--check` holds it and is a step of the
  project's gate); "From a commit, never the working tree"; "Syncing forward" (deliberately, in its
  own change set after reading this repository's `CHANGELOG.md`; commit title
  `chore: sync base standards to <sha>`; touches nothing else); "The index" (`base:` replaced whole,
  own sections untouched in place and in order, `--index-only`, `--init`, the stock
  `index-standards` not run on a synced index); "A base edit is a pull request here"; "In this
  repository" (the script's home, refuses to run here, tests o–v); "In a consuming project" (sibling
  default, first run `../patchbay-standards/scripts/sync-standards.sh --init`, CI checks out the
  sibling, the gate step).
- **`base/process/standards-index.md`**: the interim hand-copy sentence and "named here when it
  ships" replaced by pointers at `standards-sync.md` and `scripts/sync-standards.sh --index-only`;
  "In a consuming project" points at the sync.
- **`base/process/verification-gate.md`**: "In this repository" test count rewritten from the shipped
  harness; "In a consuming project" names `scripts/sync-standards.sh --check` as a gate step and the
  script as a gate file there (one sentence, pointer to `standards-sync.md`).
- **`index.yml`**: add `process/standards-sync` (between `standards-retrospective` and
  `verification-gate`; description says what it decides, no `: ` and no ` #`, so "the base section"
  not "`base:` section"); rewrite the `process/standards-index` description (its rule changed).
  Symlink follows.

Gate green (`check-index.sh` sees the new file and entry).

## Task 6: "does not merge"

`gh api repos/fromtheoutfit/patchbay-standards/branches/main/protection` output saved to
`verification/branch-protection.txt` (dated first line). Then, verified against it:
`standards-retrospective.md` "so a proposal without its entry does not pass the gate" → "does not
merge: the `gate` check is required on `main`"; `standards-index.md` "the gate does not pass without
it" → the same. Gate green.

## Task 7: Verification gate

1. `scripts/gate.sh` (bash -n on scripts/, pymarkdown 0.9.41 over base/ and README.md,
   check-index.sh) — exit 0; transcript `verification/gate-run.txt`, first line date + branch, run as
   the last act.
2. `scripts/gate-negative-tests.sh` (default set, now a–v) → `verification/gate-negative-tests.txt`;
   every new negative fails by name with the expected status, positives pass.
3. **Docs** in `shape.md`: README, CLAUDE.md, the new script's header, the harness header/usage,
   `index.yml` header, the four standards read against the shipped files; `shape-spec.md` unchanged.
4. **Version**: `CHANGELOG.md` `[Unreleased]`: Added — fifth spec (the script and its three modes, the
   tests o–v, `standards-sync.md`); Changed — `standards-index.md`, `standards-retrospective.md`,
   `verification-gate.md`, `index.yml`, `gate-negative-tests.sh`. No version number here.
5. **Standards retrospective** in `shape.md`, from `git diff origin/main`, four questions; the base
   edits are feature work on this branch, so no `(proposed, base)` list unless something outside the
   issue surfaces.
6. Stop; print `git status --short`. No stage, commit, PR or push.

## Files

New: `scripts/sync-standards.sh`, `base/process/standards-sync.md`, the spec folder.
Changed: `scripts/gate-negative-tests.sh`, `base/process/standards-index.md`,
`base/process/standards-retrospective.md`, `base/process/verification-gate.md`, `index.yml`,
`CHANGELOG.md`.
