# References for gate spec 3 (issue #12)

Every patchbay file is read at its `origin/main`, `73a583a` (PR 4 merged; the tree is identical to
PR 4's head `2121c27`), with `git -C ../patchbay show origin/main:<path>`, never from its working
tree. `verification/patchbay-evidence.txt` records the commands and their output.

## Similar Implementations

### patchbay's gate at `origin/main`

- **Location:** `../patchbay`: `pyproject.toml`, `uv.lock`, `scripts/gate.sh`,
  `scripts/gate-negative-tests.sh`, `.github/workflows/gate.yml`, `CLAUDE.md`, and the two spec
  folders `agent-os/specs/2026-11-05-2018-toolchain-ruff-mypy-pytest-full-gate/` and
  `agent-os/specs/2026-11-05-2057-toolchain-revision-after-pr-4-review/` (their `shape.md`
  "(proposed, base)" sections and `verification/` transcripts).
- **Relevance:** the shipped code every one of proposals 1 to 6 is verified against.
- **Key patterns:**
  - `pyproject.toml`'s header: `[project]`, `[build-system]` and `[dependency-groups]` are the
    package's and change in any spec; the `[tool.*]` sections are the gate's (proposal 2).
  - `[dependency-groups] dev`: each tool `==`, its publish date in a comment beside it, resolved
    in `uv.lock` (proposal 1).
  - `[tool.uv] required-version = "==0.13.7"`: every uv command in the repository refuses
    another uv (proposal 3).
  - `scripts/gate.sh` step 2: `command -v uv` by name, then `uv sync --locked` with its own `fail`
    reason and `ok   the locked toolchain synced`, then `uv run --locked ruff format --check .`
    with a reason only about formatting (proposal 6). Steps 3–5 are `uv run --locked <tool>`.
  - `.github/workflows/gate.yml`: setup-uv by commit with `working-directory: patchbay`, no
    `version`, `enable-cache: true`, `cache-dependency-glob: uv.lock`; then a `uv sync --locked`
    run step from `patchbay/`; then the gate (proposals 3 and 4).
  - The harness: h (the first tool's failure after the sync's `ok` line), m (the rule set: a
    changed `line-length` applied, `"wide"` refused by ruff, a stray `[` refused by uv's sync), n
    (a pin edited without re-locking: the stale lockfile, by the sync), o (`required-version` set
    to a uv not running: both versions named, by the sync), j (the CI replay runs the sync step,
    the `uses` steps standing in) (proposals 4 to 6).

### setup-uv at the pinned commit

- **Location:** `astral-sh/setup-uv` `README.md` at `68559e99cc807c1eb7e9238fd43a15bba460eec2`
  (v10.3.3), lines 26–34, 46–52 and 219–232, read with `gh api`.
- **Relevance:** proposal 3's lookup: with no `version` input the action reads `required-version`
  from `uv.toml` or `pyproject.toml` in the working directory, and installs the latest uv if none
  is found; `working-directory` sets where it looks.
- **Key patterns:** a failed lookup installs the latest uv, which the manifest's
  `required-version` then refuses at the first uv command: loud, not a drift.

### Hosted runs of patchbay's workflow

- **Location:** runs 42149183261 (`pull_request`, `2121c27`, success) and 42150149022 (`push`,
  `73a583a`, success), read with `gh run list` and `gh run view --log`.
- **Relevance:** the proof the issue says is recorded in the revision spec's
  `ci-negative-test.txt`; at `73a583a` it is not (that file records only 42145584983, the workflow
  before the revision), so it is read here by id.
- **Key patterns:** `Found version for uv in patchbay/pyproject.toml: 0.13.7`, `Successfully
  installed uv version 0.13.7`; the cache key
  `setup-uv-2-x86_64-unknown-linux-gnu-ubuntu-24.04-3.12.3-<hash>`, the platform, the runner image,
  the interpreter and a hash of the files `cache-dependency-glob` names, so a changed `uv.lock`
  misses it.

### This repository's gate

- **Location:** `scripts/gate.sh`, `scripts/gate-negative-tests.sh`, `.pymarkdown.yaml`,
  `.github/workflows/gate.yml`, `base/process/verification-gate.md` as gate spec 2 (issue #10)
  left them, and that spec's `shape.md` and `verification/`.
- **Relevance:** the no-manifest form every rule keeps, and the gate this spec changes: step 2
  installs the pinned pymarkdown as itself (test z), and test i proves the rule set's three cases.
- **Key patterns:** `PYMARKDOWN_VERSION` with its date in the script, run through `uvx`; the
  harness's `run`/`check`/`says` reason assertion; `mk` copies; `old_file` for history; j's
  replay.
