# Verification Gate

The gate is the definition of done in every patchbay repository. It is the final task of every spec,
included without asking, whether or not `/agent-os:shape-spec` shaped the work, and a spec is not
complete until every step of it passes. A spec with a red step, a skipped step or an unrecorded
retrospective is unfinished work, however small the change; a one-file fix is exactly the kind of
work that quietly invents a pattern, so the gate runs on it too.

This standard fixes the shape of the gate: what every repository's gate does and in what order.
Each repository fills in its own runnable step list and the tools behind it; that list is named in
the repository's `scripts/gate.sh` and in the gate task of its `shape-spec.md`, and the tools are
the toolchain standard's to name. This standard names none.

## One script

- **`scripts/gate.sh` runs every runnable step, in a fixed order, as one command**, and exits
  non-zero at the first step that fails. Later steps do not run: a failing step 1 is reported
  before step 2 has a chance to pass, so a green run means every step ran and every step passed.
- **Every step reports by name.** Each step prints a numbered banner, and what passed is named
  (`ok   <what>`) or what failed is named with its reason and the offending path; a bare exit code
  is not a report. The script ends by naming the judgment steps that follow it, so a reader of the
  transcript knows the run was not the whole gate.
- **The script runs from the repository root** wherever it is invoked from, and assumes nothing
  the repository's toolchain does not already provide.

## Pinned

- **A tool's version is pinned in the script**, in one named variable per tool, with the date it
  was published beside it. The pinned tool is run through the runner that executes it without
  installing it into the project; the runner itself is the one tool the repository's toolchain
  standard already assumes. Nothing else is installed to run the gate. A pin is bumped
  deliberately, outside a spec, and the gate rerun.
- **A rule set lives in a versioned config file**, at the repository root, named in the script,
  and is read strictly: a config the tool cannot parse fails the step rather than falling back
  to defaults. The file's header says which step reads it and that it changes only outside a spec.

## The fixed order

The runnable steps come first, in the order the script runs them. Three judgment steps follow,
in this order, and nothing in the script runs any of them:

1. **Docs.** The documentation the change touches reads true after it: the README, the headers of
   the files changed, and the command text that describes them. A pointer the change moved is
   moved in every file that holds it.
2. **Version.** The change is recorded under `[Unreleased]` in `CHANGELOG.md`, naming what a sync
   or a release would bring in. Where the repository carries a version number, it is bumped in the
   same change.
3. **Standards retrospective.** Per `base/process/standards-retrospective.md`: the four questions
   answered against the diff, the answer recorded in `shape.md`. "No changes" is valid; silence is
   not.

Each judgment step is recorded in the spec's `shape.md`, under `## Verification Gate` for the first
two and `## Standards Retrospective` for the third. A spec whose `shape.md` records the green run
but not the judgment steps has not finished the gate.

## A failing step is fixed at its cause

- **The cause is fixed and the whole gate rerun from step 1.** A fix that lets the step pass
  without fixing what it reported is not a fix: skipping the step, loosening the rule set,
  excluding the file it named, or editing the script to pass. Each of those is a change to the
  gate, which the last section forbids inside a spec.
- **A step that cannot pass on the shipped tree is a defect in the tree**, not a reason to bypass
  the step. The first spec in `patchbay-standards` fixed the one line in `README.md` the lint
  refused rather than exclude the file; that is the whole of the rule.

## Every step that can fail is proven to fail

- **A step is shown to discriminate by a negative test**: a copy of the tree, broken in one way,
  that must fail that step with the named reason and the expected exit status, with the steps after
  it never reached. A step that has never been seen to fail is not known to check anything.
- **The spec that adds or changes a step ships its negative test**, and keeps the transcript in
  that spec's `verification/` folder. Negative tests run on scratchpad copies, never on the tree
  itself, and are rerun whenever the gate's files change.
- **Every spec keeps its green run** as `verification/gate-run.txt` in its spec folder, so the
  claim "gate green" has the transcript beside it.

## The gate's own files change only outside a spec

- **The script, the rule-set config and the gate task text in `shape-spec.md` are never changed
  as a side effect of a spec whose feature is something else**, and never from inside a
  retrospective. A gate that rewrites its own terms during the process it governs is what this rule
  exists to prevent.
- **A change to the gate is its own work**: on its own branch, with the owner, shaped as a spec
  whose feature is the gate, carrying the negative test for every step it adds or changes. The
  spec that first built the gate is the one named exception, and it carried six.

## In a consuming project

This standard is synced in as `agent-os/standards/base/process/verification-gate.md`. The
project's `scripts/gate.sh` runs its own step list in this shape; its `shape-spec.md` lists those
steps in the gate task, followed by Docs, Version and the standards retrospective; its `CLAUDE.md`
names the script as the definition of done. In `patchbay-standards` the runnable steps are three:
every script under `scripts/` parses, the standards and the README lint clean against the pinned
rule set, and the index lists exactly the files under `base/`.
