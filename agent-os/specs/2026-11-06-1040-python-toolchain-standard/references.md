# References for the Python toolchain standard (issue #4)

## Similar Implementations

### patchbay at `origin/main` (`73a583a`), the tree the standard is written from

- **Location:** `../patchbay`, every file read with `git show origin/main:<path>`, never from the
  checkout, which is on the merged feature branch; `origin/main` equals `ls-remote` (blobs in
  `verification/patchbay-evidence.txt`, section 2).
- **Relevance:** the first consuming project, and the only Python package. Every rule in
  `base/python/toolchain.md` names the file of a consuming project it is verified against, read
  here in patchbay's form.
- **Key patterns:**
  - `pyproject.toml`: the header (the files that do not exist; which sections are whose; adding a
    dependency is a Decision), `license` and `license-files`, `requires-python`, `[build-system]`,
    `[tool.uv]`, `[tool.uv.build-backend]`, `[dependency-groups] dev` with a date and a job
    beside each pin, `[tool.ruff]`, `[tool.ruff.lint]` and its per-file ignores, `[tool.mypy]`
    with its override comment, `[tool.pytest.ini_options]`.
  - `uv.lock`: the resolution, the only lockfile; `.gitignore` leaves `uv.lock` commented out and
    ignores `.hypothesis/`.
  - `.python-version`: `3.12`.
  - `.pre-commit-config.yaml`: two `repo: local` ruff hooks through `uv run --locked`, the header
    saying why the file exists.
  - `scripts/gate.sh`: steps 2 to 5, the tool order, `uv sync --locked` opening step 2.
  - `.github/workflows/gate.yml`: setup-uv reading `required-version`, then `uv sync --locked`;
    the gate standard's, read so toolchain.md does not restate it.
  - `README.md`: `uv run pre-commit install` and `uv run pre-commit run --all-files`, the two
    commands without `--locked`.
  - `src/patchbay/__init__.py`, `tests/unit/test_package.py`, `tests/unit/test_version.py`: the
    issue comment's proofs; the license-file test is cited, the package-surface and test-writing
    rules they hold are deferred (`shape.md`).
  - `agent-os/specs/2026-11-05-2018-toolchain-ruff-mypy-pytest-full-gate/shape.md` and
    `agent-os/specs/2026-11-05-2057-toolchain-revision-after-pr-4-review/shape.md`: each choice
    as a Decision with its reason; the second's `verification/wheel-license.txt`, the wheel before
    and after `license-files`.

### uv's build-backend documentation

- **Location:** <https://docs.astral.sh/uv/concepts/build-backend/>, read 2026-11-06.
- **Relevance:** the build-backend pin. The page gives `requires = ["uv_build>=0.13.7,<0.14"]`,
  says the upper bound "ensures that your package continues to build correctly as new versions are
  released" and that uv_build "follows the same versioning policy as uv", and that uv uses its
  bundled backend "if its version is compatible with the `uv_build` requirement", otherwise a
  compatible uv_build package; other frontends "will always use the `uv_build` package".
- **Key patterns:** the upper bound's reason, cited. The bundled-backend condition is **not** what
  uv 0.13.7 does: offline and with no cache it builds with the bundled backend whatever the range,
  and warns when the range does not contain it (`verification/patchbay-evidence.txt`, section 5).
  The standard says what the probe shows.

### This repository's process standards

- **Location:** `base/process/*.md`.
- **Relevance:** the shape of a base standard: an introduction, rule sections of bold-led bullets,
  then "In this repository" and "In a consuming project"; and `verification-gate.md`, whose
  "Pinned", "CI" and "In a consuming project" own the rules toolchain.md cites and does not
  restate.
- **Key patterns:** a rule names the file it is verified against; a rule with no file behind it is
  not written (the never-name-what-has-not-shipped rule the earlier specs applied).
