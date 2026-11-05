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

# Revision after the review of PR 9 (2026-11-05)

Shaped in plan mode with `/agent-os:shape-spec`. The first round's plan (issue #8, the five parts) is
the spec folder's `plan.md`; this plan is the revision and is appended there by Task 1. Owner's
answers this round: the whole review (22 items), on the same branch, recorded in the existing spec
folder `agent-os/specs/2026-11-05-1441-sync-script-and-standards-sync/` under "Revision after
review" as the fourth spec did for PR 7; visuals none; references and standards as the first round,
`process/standards-sync` added to the standards list.

## Context

PR 9 (head `3d3e111`) carries the fifth spec. The owner's review comment lists 22 findings, two
reproduced on macOS and blocking: BSD `head -n 0` exits 1, so a `base:` section or an `--init`
insertion point on line 1 crashes the splice (item 1), and a sync that fails in `regen_index` has
already replaced `base/` and `.version`, leaving the project half-synced (item 2). The rest: the
self-copy claim is false (3), the default ref pins a feature-branch HEAD silently (4), `git archive`
applies the checkout's eol settings (5, reproduced here: `-c core.autocrlf=true` gives `\r\n`), a
subdirectory path passes validation then fails with exit 128 (6), the index is written by truncation
(7), the JSON claims the script copy before it runs (8), mode conflicts exit 2 unnamed (9), `json_str`
misses control characters (10); four harness findings (11–14); four standards findings (15–18); four
cleanups (19–22). Branch is clean at `3d3e111`; the tree's gate is green (every file tracked).

## Decisions (owner's, this round)

- **Scope: all 22 items, same spec folder.** Dispositions tabled below and in the spec's `plan.md`;
  decisions in `shape.md`'s "Revision after review (2026-11-05)"; a fresh `gate-run.txt`, every
  negative test rerun (`gate-negative-tests.txt`, and j in `ci-negative-test.txt`, so the
  verification-gate sentence about "the current transcript" reads true), and the hosted run on PR 9
  recorded by id.
- **Item 3: keep the last-act copy, fix the words.** No exec. The script header and
  `standards-sync.md` say: the project's copy is replaced with the script at the pinned commit as
  the last thing the sync writes, so the next sync runs it; the sync that delivers a change to the
  script is run by the copy before it.
- **Item 4: the default ref is origin's default branch.** `<ref>` defaults to the checkout's
  `refs/remotes/origin/HEAD` (`origin/main` here); a checkout with no `origin/HEAD` is told to pass
  a ref or set it (`git remote set-head origin --auto`), exit 2. An explicit ref whose commit is not
  an ancestor of origin's default branch is synced with a `WARN` line on stderr naming it. The
  scratch upstream in the harness gets `origin/main` so the default is exercised.
- **Item 18: fix the sentence in place as feature work.** `verification-gate.md`'s "In this
  repository" paragraph is in this spec's scope (Task 5 of the first plan); the sentence is corrected
  with j rerun so it reads true, and `shape.md`'s retrospective answer 2 says the edit was feature
  work, not a retrospective edit.
- **Item 5: read blobs with `git cat-file`**, not `git archive` (mine): `git ls-tree -r -z` the
  commit for `base`, `index.yml`, `scripts/sync-standards.sh`, refuse any entry that is not a
  regular blob (mode 100644/100755) or whose path holds a control character (exit 2, named), write
  each with `git cat-file blob`. Raw bytes: no eol conversion, no attribute, no filter.
- **Item 10: control characters in paths are refused**, so the newline-separated lists and the
  JSON hold by construction; `json_str` keeps escaping `\` and `"`. The upstream path and the ref
  are checked the same way.
- **Item 15: CI guidance** in `standards-sync.md`: both repositories under the workspace, the
  project in a subdirectory and `patchbay-standards` beside it, checked out at the commit in
  `.version` (a step reads the file and passes it as `ref:`, or `fetch-depth: 0`), the gate run with
  `working-directory` set to the project. Prose and the shape of the steps, not a YAML listing.

## Dispositions

| # | Finding | Disposition |
|---|---|---|
| 1 | `head -n 0` on a line-1 section or insertion point | Fix: one awk for bounds, one awk splice, one awk insertion; no `head`/`tail`. Test r: line-1 cases, with the `3d3e111` script shown crashing. |
| 2 | Failed sync leaves `base/` and `.version` new, index old | Fix: build `base/` (with `.version`), the index and the section in `$tmp`, check every precondition (target index parseable included), then swap. Exit 2 writes nothing; shown in u. |
| 3 | Self-copy claim false | Owner: keep the copy, reword header and standard. |
| 4 | Default ref is HEAD | Owner: `origin/HEAD`; warn on an unpushed explicit ref. Tests o, u. |
| 5 | `git archive` applies eol/attributes | Fix: `ls-tree` + `cat-file blob`. |
| 6 | Subdirectory path → exit 128 | Fix: `up=$(git -C "$path" rev-parse --show-toplevel)`; shown in u as a positive. |
| 7 | Index written by truncation | Fix: temp file beside it, `mv`. |
| 8 | JSON before the script copy | Fix: copy, then print. |
| 9 | Mode conflicts unnamed | Fix: `die 2` naming both flags. Test u. |
| 10 | `json_str` and control characters | Fix: refuse control characters in paths (exit 2); see Decisions. |
| 11 | Hard-coded entry counts in p, q | Fix: counts computed from the upstream index. |
| 12 | No line-1 test | Fix: r gains the no-index sync-again and `--index-only` cases, `--init` on `testing:` at line 1 and on a comment above it. |
| 13 | `first_sync` unchecked | Fix: `first_sync x \|\| continue` in p, q, s, t, v. |
| 14 | Oracle runs to EOF | Fix: `expected_section` trims trailing blank/comment lines (a different implementation from the script's); r syncs an upstream index with a trailing comment. |
| 15 | CI guidance incomplete | Fix: see Decisions. |
| 16 | `--init` normalizes blank lines | Fix: say so in the header and the standard. |
| 17 | Count and transcript claim | Fix: "fifteen (a to n except j)"; j rerun here, `ci-negative-test.txt` recorded. |
| 18 | In-place rewrite vs proposal | Owner: in place, as feature work; `shape.md` reworded. |
| 19 | Two awk state machines, repeated messages | Fix: one `section_bounds`, extraction by line range, messages in one place. |
| 20 | Dead `: >`, double sort | Fix. |
| 21 | `mk_upstream` repeats `mk` | Fix: `mk_upstream() { mk "$1" && commit ... && origin/main; }`. |
| 22 | Export before cheap checks, second archive | Fix: checks first; one export, a pristine copy kept for the post-swap verification. |

## Task 1: Records first

Append this plan to the spec's `plan.md` as `# Revision after the review of PR 9 (2026-11-05)` with
the table. Add `## Revision after review (2026-11-05)` to `shape.md` after Decisions, in the fourth
spec's form: the review's size, the owner's four choices, and the decisions that extend or reverse
the first round's (default ref, the self-copy wording, export by `cat-file`, build-then-swap, the
refusals). Results, Docs, Version and the retrospective are rewritten at the end (Task 6).

## Task 2: `scripts/sync-standards.sh`

Bash 3.2, `set -euo pipefail`, `LC_ALL=C`, header rewritten to match. Order of the script:

1. **Flags** as now; `--index-only`/`--check` conflicts and repeats `die 2 "one mode per run: ..."`;
   `--*` unknown, too many arguments, a ref with `--check`/`--index-only`, `--init` outside a sync:
   all `die 2` by name (usage on stderr first).
2. **Preconditions, cheap first, nothing exported yet**: cwd is the work-tree top; `$base` not a
   symlink; `$path` is a git checkout, `up=$(git -C "$path" rev-parse --show-toplevel)` (resolved,
   so a subdirectory works); `$up`, `$ref` hold no control character; the project's index
   `section_state` is `ok`, or `none` with `--init` in a sync (else `die 2`, the message in one
   function). Commit: a sync resolves `$ref` (default from `git -C "$up" symbolic-ref --quiet --short
   refs/remotes/origin/HEAD`, else `die 2`); the other modes read `.version`. `cat-file -e` for the
   three paths. Warning: in a sync, when `origin/HEAD` exists and `merge-base --is-ancestor "$sha"
   refs/remotes/origin/HEAD` fails, `WARN  <sha> is not on origin/main: ...` on stderr.
3. **Export once** (`export_commit`): `git -C "$up" ls-tree -r -z "$sha" -- base index.yml
   scripts/sync-standards.sh > "$tmp/tree"`; read with `read -r -d ''`, split mode/type/path; refuse
   mode not 100644/100755 and control characters; `git cat-file blob "$sha:$path" >
   "$tmp/export/$path"`. Then `section_state "$tmp/export/index.yml"` must be `ok` (`die 2 "index.yml
   at $sha has no parseable base: section"`), and `base_section` of it to `$tmp/section.new`.
4. **Section helpers**: `section_bounds <file>` (the one awk, prints `start end`); `base_section` is
   `awk -v s -v e 'NR>=s && NR<=e'`; `section_state` as now on top of bounds; `splice_section`
   (awk: at `NR==s` print `section.new`, print lines `NR<s || NR>e`); `insert_section <at>` (awk
   buffering lines before `at`, trailing blanks stripped, one blank, the section, one blank, the
   rest; `at` 0 = end of file; an empty or absent file gets the section alone). Header documents
   the normalization: the blank lines directly above the insertion collapse to one, a missing final
   newline is added.
5. **`build_index`** (no write): sets `index_status` created|replaced|unchanged and writes
   `$tmp/index.new` when it changes. `write_index`: `cp "$tmp/index.new" "$idx.new" && mv
   "$idx.new" "$idx"` (same directory; `mkdir -p` for a created file).
6. **`project_files`**: `git ls-files -z` + `--others --exclude-standard -z` into a file, read with
   `-d ''`, refuse control characters, on-disk regular files, minus `.version`, `sort -u` once.
   `compare` keeps `sort -c`, `comm`, `cmp`; no second sort, no dead `: >`.
7. **Modes**: `check` as now (export, compare, section, script; JSON; exit 0/1). `index-only`:
   `build_index`, `write_index` when changed, report, JSON. `sync`: `compare` → `.pre` lists;
   `build_index`; `cp -R "$tmp/export/base" "$tmp/new/base"`, `.version` written inside it; then the
   swap: `rm -rf "$base"; mv "$tmp/new/base" "$base"`; `write_index` when changed; verify against the
   pristine export (`compare` + `section_differs`, `die 1`); script copy (`.new`, `chmod +x`, `mv`)
   when it differs; then the stderr report, the JSON, `ok   synced to <sha>`.
8. `json_str` escapes `\` and `"` (paths are control-free by 2 and 3).

## Task 3: `scripts/gate-negative-tests.sh`

- Helpers: `mk_upstream() { mk "$1" && commit "$1" "the working tree" && push_upstream "$1"; }`
  where `push_upstream <dir>` sets `refs/remotes/origin/main` to HEAD and `origin/HEAD` to it (what a
  push would leave); `first_sync` callers use `|| continue`; `expected_section <upstream>` =
  `sed -n '/^base:/,$p'` then an awk that drops trailing blank and comment lines (a second
  implementation of the rule); `expected_index` uses it; `entries <file>` for counts;
  `old_script` generalized to `old_file <name> <sha> <path>` for the `3d3e111` sync script.
- o: the default ref is `origin/main`, not HEAD: one extra empty commit ahead, `--init` pins
  `origin/main`; then an explicit `HEAD` sync shows the `WARN` line and pins HEAD. A subdirectory path
  (`../patchbay-standards/base`) is accepted and reported resolved.
- p, q: counts computed; `push_upstream` after each commit. v: the same.
- r: after the no-index `--init` (section on line 1) a committed upstream description edit is
  synced (section replaced at line 1), a hand edit then `--index-only`; `--init` on an index whose
  first line is `testing:` and on one with `# comment` directly above it; an upstream index with a
  trailing comment and blank line synced, the trailing lines not in the project. The `3d3e111`
  script run on the line-1 case: `head: illegal line count -- 0`, and `git status` showing `base/`
  and `.version` changed with the index not (items 1 and 2 as they were).
- u: `--check --index-only` named; a target commit whose `index.yml` is `base: {}` refused (exit 2)
  with `git status` empty after; no `origin/HEAD` in the checkout and no ref → exit 2 named.
- Header paragraph on o–v updated (origin/main, the two fixtures).

Run the default set and j; both transcripts to `verification/`.

## Task 4: Standards and docs, from the shipped files

- `base/process/standards-sync.md`: "What the sync writes" (script copy wording per the owner;
  default ref; `git cat-file`, raw, so neither an uncommitted edit nor the checkout's line-ending
  settings reach the project; exit 2 cases now including a target commit with no parseable section,
  two mode flags, a control character in a path, no `origin/HEAD`; "built in a temporary directory
  and swapped in, so exit 2 leaves the project as it was"). "Pinned, not tracking": the default is
  origin's default branch; an explicit unpushed ref is warned about. "The index": `--init`'s
  normalization. "In a consuming project": the CI layout (Decisions, item 15).
- `base/process/verification-gate.md`: "fifteen for the gate's scripts (a to n except j)"; "the spec
  that last changed the harness holds the current transcripts, j's included"; "In a consuming
  project": the sibling is checked out under the workspace at the commit in `.version`.
- `base/process/standards-index.md`: unchanged unless a sentence reads false after Task 2 (checked).
- `index.yml`: `process/standards-sync` description reread; changed only if its rule changed.
- `CHANGELOG.md`: the fifth spec's Added entry revised to the shipped script (cat-file, the default
  ref, build-then-swap, the refusals) with one sentence naming the PR 9 review; lines ≤ 100.

## Task 5: Hosted run

`gh run list --workflow gate --branch <branch>` (read only): the run on `3d3e111`, id and
conclusion, recorded at the end of `verification/ci-negative-test.txt`; the next head's run is read
back by the owner or the next session after the push.

## Task 6: Verification gate

1. `scripts/gate.sh` → exit 0 on the tree (every input tracked), transcript `verification/gate-run.txt`
   replaced (date and branch first line, run under `bash -c` for `PIPESTATUS`), the last act.
2. Negative tests: default set → `gate-negative-tests.txt`; `j` → `ci-negative-test.txt`.
3. **Docs**: header, harness header/usage, the three standards and `index.yml` read against the
   shipped script; `README.md`, `CLAUDE.md` unchanged and true. Recorded in `shape.md`.
4. **Version**: `CHANGELOG.md` entry as revised. Recorded.
5. **Retrospective** rewritten from the revised diff against `main`: answer 2 reworded (item 18);
   the `(proposed, base)` item about an unstaged new standard stays (it came from the first
   hand-over and is still a gap); any new pattern this round taught (build-then-swap for a script
   that writes several things; the pushed-ref default) is already in `standards-sync.md` as feature
   work.
6. Stop; print `git status --short`. No stage, commit, push or PR edit.

## Files

Changed: `scripts/sync-standards.sh`, `scripts/gate-negative-tests.sh`, `base/process/standards-sync.md`,
`base/process/verification-gate.md`, `CHANGELOG.md`, the spec folder (`plan.md`, `shape.md`,
`verification/gate-run.txt`, `verification/gate-negative-tests.txt`, new `verification/ci-negative-test.txt`).
Possibly: `base/process/standards-index.md`, `index.yml`.
