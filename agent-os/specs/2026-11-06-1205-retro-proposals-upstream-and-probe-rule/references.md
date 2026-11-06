# References for Base Proposals Upstream and the Probe Rule (issues #13 and #15)

## Similar Implementations

### The shape of a filed issue: fromtheoutfit/patchbay-standards#12 and #15

- **Location:** `gh issue view 12`, `gh issue view 15`
- **Relevance:** #13 asks that approved proposals become one issue "shaped like issues #10 and
  #12". #12 is the gate-spec form, with sections per base file and numbered proposals, each with
  its verification pointer, plus "Depends on", "Not in this issue" and "Rules". #15 is the
  standards-spec form: one section per base file, the case, the evidence pointer, "Depends on"
  naming a branch and its pull request, and "Rules".
- **Key patterns:** a title naming a gate spec or a standards spec; one section per proposal with
  the shipped file and test it rests on; a "Depends on" line; the closing Rules line (shaped in
  plan mode, CHANGELOG, gate green, no commit, PR or push by an agent). #10 has the same shape but
  is not used as a template, because its body ends with an AI-attribution footer.

### A recorded proposal: the toolchain spec's `(proposed, base)` block

- **Location:** `agent-os/specs/2026-11-06-1040-python-toolchain-standard/shape.md`, lines
  390–413
- **Relevance:** the first proposal here that was filed as an issue (#15) and had its number
  written beside it, "Proposed, not applied; filed as #15". Its second proposal has no issue,
  which is the gap #13 closes.
- **Key patterns:** the change, the shipped file and section it is verified against, then the
  outcome.

### #15's evidence: the toolchain spec's probes on `main`

- **Location:** `agent-os/specs/2026-11-06-1040-python-toolchain-standard/verification/patchbay-evidence.txt`
  at `main` (`0b1d0dc`), sections 4 and 5, and the same file at `f3fdbf4`, the first round
- **Relevance:** section 5 is the case of discriminating cases and of the source deciding:
  - uv's documented condition;
  - the first round's `>=0.12.0,<0.13.0`, which held `0.12.24`;
  - `COMPATIBLE_VERSIONS` and `check_direct_build` at the `0.13.7` tag;
  - five ranges, each run offline and online for `uv build` and `uv sync`.

  Section 4 is the case of a setup shown to have done what it claims: `--show-settings` for an
  override of `lint.ignore` alone, then with the selection reset. At `f3fdbf4`, section 5 still
  holds the first round's "whatever the range" reading.
- **Key patterns:** each probe states what it is chosen to tell apart, and each command's output
  is kept verbatim.

### An earlier probe: the third spec's evidence section 6

- **Location:** `agent-os/specs/2026-11-06-0721-gate-spec-3-seven-base-proposals/verification/patchbay-evidence.txt`,
  `## 6. uv's required-version, probed`
- **Relevance:** the first time the method was used here. uv's `required-version` refusal was
  probed rather than taken from the documentation.

### Where a consuming project takes a gate-task change: patchbay#5, #6 and #7

- **Location:** `gh issue view 5 -R fromtheoutfit/patchbay` and #6, #7
- **Relevance:** each time a base change here asked something of patchbay's gate files, patchbay
  recorded the work in an issue for its own gate spec after the sync. It never folded the work
  into the sync commit. The standards-sync note follows them, and this spec's patchbay follow-up
  is a comment on #7.
