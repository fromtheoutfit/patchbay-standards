# Verification Gate

The gate is the definition of done in every patchbay repository. It is the final task of every spec,
included without asking, whether or not `/agent-os:shape-spec` shaped the work, and a spec is not
complete until every step of it passes. A spec with a red step, a skipped step or an unrecorded
retrospective is unfinished work, however small the change; a one-file fix is exactly the kind of
work that quietly invents a pattern, so the gate runs on it too.

This standard fixes the shape of the gate: what every repository's gate does and in what order.
The runnable step list is each repository's own, named in its `scripts/gate.sh` and in the gate
task of its `shape-spec.md`; this standard names no step and no tool. The standard that names a
repository's steps is cited here when it ships.

## One script

- **`scripts/gate.sh` runs every runnable step, in a fixed order, as one command**, and exits
  non-zero at the first step that fails. Later steps do not run: a failing step 1 is reported
  before step 2 has a chance to pass, so a green run means every step ran and every step passed.
- **Every step reports by name.** Each step prints a numbered banner, and what passed is named
  (`ok   <what>`) or what failed is named with its reason and the offending path; a bare exit code
  is not a report. The script ends by naming the step that follows it, so a reader of the
  transcript knows the run was not the whole gate.
- **The script runs from the repository root** wherever it is invoked from, and assumes nothing
  the repository does not already provide.

## Pinned

- **A tool's version is pinned in the script**, in one named variable per tool, with the date it
  was published beside it. The pinned tool is run through a runner that executes it without
  installing it into the project, and the runner is one the repository already assumes. Nothing
  else is installed to run the gate. A pin is bumped deliberately, outside a spec, and the gate
  rerun.
- **A rule set lives in a versioned config file**, at the repository root, named in the script;
  a config the tool cannot parse fails the step. The file's header says which step reads it and
  that it changes only outside a spec.

## The fixed order

The runnable steps come first, in the order the script runs them. One judgment step follows, and
nothing in the script runs it:

- **The standards retrospective**, per `base/process/standards-retrospective.md`: the four
  questions answered against the diff, the answer recorded in the spec's `shape.md` under
  `## Standards Retrospective`. "No changes" is valid; silence is not.

A spec whose `shape.md` records the green run but not the retrospective has not finished the
gate.

## A failing step is fixed at its cause

- **The cause is fixed and the whole gate rerun from step 1.** A fix that lets the step pass
  without fixing what it reported is not a fix. Skipping the step, loosening the rule set,
  excluding the file it named or editing the script to pass each change a gate file, which the
  section below forbids inside a spec; a suppression comment placed in the file the step named
  loosens the rule for that file alone and is reviewed as the loosening it is.
- **A step that cannot pass on the shipped tree is a defect in the tree**, not a reason to bypass
  the step. The first spec in `patchbay-standards` added the one blank line `README.md` lacked
  after its heading rather than exclude the file; that is the whole of the rule.

## Every step that can fail is proven to fail

- **A step is shown to discriminate by a negative test**: a copy of the tree, broken in one way,
  that must fail that step with the named reason and the expected exit status, with the steps after
  it never reached. A step that has never been seen to fail is not known to check anything.
- **The spec that adds or changes a step ships its negative test**, and keeps the transcript in
  that spec's `verification/` folder. Negative tests run on a temporary copy outside the tree,
  never on the tree itself, and are rerun whenever the gate's files change.
- **Every spec keeps its green run** as `verification/gate-run.txt` in its spec folder, so the
  claim "gate green" has the transcript beside it. The first line of the transcript gives the date
  and the branch the run was made on, and the run is the last thing done before the work is
  handed over: an edit after the run is not covered by it. A transcript recorded before this rule
  stays as it was recorded.

## The gate's own files change only in their own spec

- **The gate script, every script it runs, the rule-set config and the gate task text in
  `shape-spec.md` are never changed as a side effect of a spec whose feature is something else**,
  and never from inside a retrospective. A gate that rewrites its own terms during the process it
  governs is what this rule exists to prevent.
- **A change to the gate is its own spec**, whose feature is the gate: on its own branch, with the
  owner, carrying the negative test for every step it adds or changes. A finding against a gate
  file made during some other spec is recorded in that spec's retrospective as a proposal and
  waits for the gate's spec.

## In this repository

The runnable steps are three: every script under `scripts/` parses, the standards under `base/`
and `README.md` lint clean against the pinned rule set, and `index.yml` lists exactly the files
under `base/`. `scripts/gate.sh` names the tool, its pin and its config; `scripts/check-index.sh`
is the third step. Every spec folder under `agent-os/specs/` holds its `verification/gate-run.txt`,
and the spec that built the gate holds the six negative tests beside it.

## In a consuming project

This standard is synced in as `agent-os/standards/base/process/verification-gate.md`. The
project's `scripts/gate.sh` runs its own step list in this shape; its `shape-spec.md` lists those
steps in the gate task, followed by the standards retrospective; its `CLAUDE.md` names the script
as the definition of done.
