# References for pointing the retrospective standard at the owning standards

## Similar Implementations

### The pointer the gate standard already makes

- **Location:** `base/process/verification-gate.md`, "The fixed order" (cites
  `base/process/standards-retrospective.md` for the judgment step) and the opening paragraph ("the
  standard that names a repository's steps is cited here when it ships").
- **Relevance:** the shape of a section that states its own rule in one breath and hands the detail
  to the standard that owns it.
- **Key patterns:** name the owning standard by path; say what is that standard's, not a summary of
  it that can drift.

### The issue #1 spec folder

- **Location:** `agent-os/specs/2026-11-04-1016-gate-and-index-standards/`
- **Relevance:** shape of `plan.md`, `shape.md`, `standards.md`, `references.md`; the CHANGELOG entry
  form; `verification/gate-run.txt` with date and branch on its first line. Its `shape.md`
  retrospective holds the proposal this spec applies.

## Shipped sources each sentence of the new text is verified against

### "Keep the index in step"

| Sentence | Shipped source on `main` (0c6f91c) |
|---|---|
| A standard added, renamed or removed carries its index entry in the same change set; project sections by hand | `base/process/standards-index.md`, "Two indexes, one `base:` section" bullet 3; "The description line" bullet 3 |
| A base proposal's entry goes in the root `index.yml`; `scripts/check-index.sh` holds the index to the files under `base/` | `standards-index.md`, "Every standard and nothing else" bullets 1 and 3; `scripts/check-index.sh` lines 18–42 |
| "does not pass the gate" | `scripts/gate.sh` step 3 runs `check-index.sh` and exits non-zero on failure; no `.github/` exists, so nothing else refuses it |
| The format, the description line and the two-index relation are `standards-index.md`'s | its opening paragraph: "This standard fixes the index's format and how a consuming project's index relates to the root index" |
| Gone: "copied verbatim by the sync script" | `scripts/check-index.sh` contains no sync; `grep -n sync scripts/*.sh` is empty |
| Gone: `base:` "followed by the project's own sections" | `.claude/commands/agent-os/index-standards.md` Step 6, "Alphabetize folders"; `standards-index.md` "Keys" bullet 3 |

### "Never edit this file from inside a retrospective"

| Sentence | Shipped source on `main` (0c6f91c) |
|---|---|
| The retrospective is changed in its own spec, with the user, on its own branch | `standards-retrospective.md`, "Who owns which standard", the parenthetical; `CLAUDE.md` "Specs & the standards retrospective", bullet 5 |
| The gate's own files are under the same rule; which files, and that they change only in a spec whose feature is the gate | `base/process/verification-gate.md`, "The gate's own files change only in their own spec", both bullets |
| Gone: the list `shape-spec.md`, `scripts/gate.sh`, `scripts/check-index.sh`, `.pymarkdown.yaml` | the same section of `verification-gate.md` names the set ("the gate script, every script it runs, the rule-set config and the gate task text in `shape-spec.md`") |
