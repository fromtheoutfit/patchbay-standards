# References for the Revision after the Review of PR 23

## Similar Implementations

### The review

- **Location:** the owner's comment on fromtheoutfit/patchbay-standards#23, "Review findings
  (head `00cf7ca`)", 2026-11-07
- **Relevance:** the nine findings this spec answers, most severe first. Only #1 was reproduced
  there; this spec probes or reproduces the rest before fixing them.

### check-index.sh's listing and report

- **Location:** `scripts/check-index.sh` at `00cf7ca`
- **Relevance:** the model for #7 and #8. It lists to temp files and checks git's status directly
  (`if ! git … ls-files … > "$tmp/files.raw" …; then FAIL …`), and reports every offender under
  one FAIL line, each indented eight spaces, which the harness's `only` reads.
- **Key patterns:** `mktemp -d` and its trap; `FAIL  <reason>:` then `sed 's/^/        /'`.

### The eleventh spec's evidence and cases

- **Location:** `agent-os/specs/2026-11-07-1428-gate-spec-4-skeleton-listing-harness/verification/`
  (`probes.txt`, `guard-mutations.txt`, `gate-sh-diff.txt`), and tests w, y, m, h and u in
  `scripts/gate-negative-tests.sh`
- **Relevance:** the guards this revision changes, the cases that cover them, and the mutation
  transcript's shape; the `UPC`/`UPP` blocks finding #9 names.

### patchbay#12

- **Location:** fromtheoutfit/patchbay#12
- **Relevance:** the work patchbay's gate spec takes after its sync. Items 2–4 and 6 describe the
  skeleton this revision changes again, so its body is rewritten in place.
