# References for the gate spec (issue #3)

## Similar Implementations

### The gate scripts as shipped on `origin/main` (aaacc57)

- **Location:** `scripts/gate.sh`, `scripts/check-index.sh`, `.pymarkdown.yaml`
- **Relevance:** the files this spec changes; every rule written in part 6 is verified against
  them as they ship at the end of this spec, not against `plan.md`.
- **Key patterns:** `step()` banners numbered `n/3`; `ok   <what>` on success, `FAIL  <reason>:`
  with indented paths on failure; `set -euo pipefail` and `cd "$(dirname "$0")/.."`; the pin as
  one named variable with its publish date beside it; `LC_ALL=C sort` on every list.

### The first spec's negative tests

- **Location:** `agent-os/specs/2026-11-04-0750-shape-spec-gate-retrospective/verification/gate-negative-tests.txt`
- **Relevance:** the shape of a negative-test transcript: a lettered heading naming the break and
  the step that must catch it, the output, `exit=N`. Test c is replaced here; a, b, d, e, f are rerun.
- **Key patterns:** one break per copy; the copy lives in the scratchpad, never in the tree.

### The third spec's `shape.md` and `gate-run.txt`

- **Location:** `agent-os/specs/2026-11-05-0741-retrospective-points-at-owners/shape.md`,
  `.../verification/gate-run.txt`
- **Relevance:** the shape of the spec files (Shaping answers, Decisions with their why, the
  retrospective's four questions answered against the diff, Results under Verification Gate) and
  the `gate-run.txt` first line: date, two spaces, `branch <name>`.

### The issue #3 reproduction

- **Location:** issue #3, "scripts/check-index.sh", second bullet
- **Relevance:** the `comm` locale case, reproduced on this machine at shaping time with
  `comm -23 <(printf 'process/B\nprocess/a_z\nprocess/ab\n') <(printf 'process/a_z\nprocess/ab\n')`:
  three lines under `en_US.UTF-8`, one under `C`.

### The two actions and uv, verified today (2026-11-05)

- `actions/checkout` v7.0.1, published 2026-07-20, tag at `3d3c42e5aac5ba805825da76410c181273ba90b1`.
- `astral-sh/setup-uv` v10.3.3, published 2026-10-28, tag at `68559e99cc807c1eb7e9238fd43a15bba460eec2`;
  its `version` input takes an exact uv version.
- `astral-sh/uv` 0.13.7, published 2026-11-03; the version installed here.

### The first review of PR 7 (2026-11-05)

- **Location:** the owner's review comment on PR 7, 27 findings at `cf1bdf0`
- **Relevance:** the second round of this spec; `plan.md` tables every disposition. Findings 1 and
  3 were reproduced here before the fix (`sort -c` on the stripped list; a C-quoted `café.md`), and
  the harness shows the `cf1bdf0` script passing an unindexed standard under GNU `comm`.
- **Hosted runs:** 42062523298 (push) and 42062688286 (pull_request) on `cf1bdf0`, both success,
  the job ten seconds; the triggers shipped here make the next head run once.
