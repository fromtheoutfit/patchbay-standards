# Standards for pointing the retrospective standard at the owning standards

The following standards apply to this work, as they read when the spec was shaped
(before this spec's own edit and before the retrospective). `base/process/standards-retrospective.md`
below is the text on `main` at 0c6f91c, the version this spec rewrites two sections of;
`shape.md`'s Decisions say which and why. This file is the snapshot, not the current text.

---

## process/ownership

## Ownership

A person owns every commit, pull request, approval and merge in every patchbay repository. In
`patchbay-standards` that person is Michael; in a consuming project it is the owner its
`CLAUDE.md` names. An agent prepares work; it does not land it.

### The rule

- **An agent never commits, pushes, opens a pull request, approves or merges**, however a plan,
  spec, memory or earlier message is worded. A request to stage is not a request to commit, and a
  request to commit is not a request to push. Only an explicit ask in the current conversation,
  for that one operation, lifts this, and only for that operation.
- **The pause at commit time is where the person reads the code.** That pause is the review; an
  agent that commits on its own has skipped it, whatever the diff looked like to the agent.

### GitHub

- **Reading is allowed**: `gh issue view`, `gh pr view`, `gh issue list`, `gh pr list`,
  `gh pr diff` and the like.
- **Creating or commenting on issues is allowed** when the text carries no AI attribution (see
  `CLAUDE.md`, "No AI attribution — anywhere"). Opening, approving or merging a pull request is
  not; that is the person's.

### Redline

A Redline run follows the Redline plugin's git rules when the prompt identifies the session as
one, at the path that prompt gives. Nothing else lifts this rule: not a plan, not a spec, not a
memory, not an earlier session.

### Tools outside the repository

A tool installed outside the repository (Homebrew, `npm -g`, `pipx`, `uv tool install`, anything
system-wide) is **asked for before it is installed**, naming the tool and why the gate needs it. A
tool the gate pins and runs through `uvx` is not an install and needs no ask; the runtime it
needs (uv itself) is. The first spec in `patchbay-standards` installed uv with Homebrew unasked
to run its own gate, which is the deviation that put this paragraph here.

### In a consuming project

This standard is synced in as `agent-os/standards/base/process/ownership.md`. The project's
`CLAUDE.md` names its owner and carries the rule under `## Ownership`, directly under `## Git`,
so it is read before any git operation is considered.

---

## process/standards-retrospective

## Standards Retrospective

`base/` describes how the patchbay packages are built; a consuming project syncs it in as
`agent-os/standards/base/`, next to the project's own standards. That description is only as
accurate as the last spec that checked it, and **nothing fails when it drifts**. No test goes
red because a standard describes a pattern we stopped using two specs ago, or because a spec
invented a pattern that never got written down.

This is the step that closes that loop. It runs as **the last item of the verification gate**,
on every spec-sized change, whether or not `/agent-os:shape-spec` shaped it. **Record the
answer either way**: "no changes" is a valid outcome, silence is not, because nobody can tell it
apart from "never noticed."

### Why this exists

A pattern invented inside a spec and never written down is a pattern the next spec re-invents
differently. Three specs later there are three ways to do the same thing, all of them
defensible, none of them written anywhere, and the standards confidently describe a fourth.

The cost of asking at the end of a spec is a paragraph. The cost of not asking is the
`discover-standards` pass again.

### The ordering rule

**No pattern is invented that is not in the standards.** If a spec needs one that isn't there,
it is proposed, added, and only then used, in that order. Reaching the retrospective and
discovering a whole new pattern already shipped means the proposal step was skipped; add it now
(or propose it, if it belongs in `base/`), and note in `shape.md` that it landed late.

At shaping time this means: when the plan needs a pattern the standards don't cover, that is a
standards change to decide with the user, not an ad-hoc call to make inside the implementation.

### The questions

Check each against the spec's actual diff.

1. **Did this spec introduce a pattern no standard covers?** A new adapter shape, a new way of
   naming or validating a parameter, a new test seam, a new way two packages talk to each
   other. If it will be copied by the next person who does something similar, it belongs in a
   standard.
2. **Did a standard turn out to be wrong, or stale?** Correct it, citing the code that proves
   the correction. This includes standards you merely *read* during the spec and found didn't
   match reality; you don't have to have changed the code to have learned this.
3. **Did the spec deliberately deviate from a standard?** Either the standard grows the
   exception (with its condition), or the deviation is recorded in `shape.md` as a one-off with
   its reason. A deviation that is neither will read as a violation to the next reviewer.
4. **Did anything a standard points at move, get renamed, or get deleted?** File paths, module
   and class names, config keys, command and script names, and test-file references inside
   standards go stale silently. Fix the pointer.

### Verify against the code, not against the spec

**A standard rewritten during a retrospective is verified against the shipped code and tests,
never against the spec's own decisions or plan.** Read the artifact being described, not the
artifact that described it.

A sibling project has already paid for this lesson. A guard was meant to hold a list of third
parties equal to the list a published document named, and the list was transcribed by reading
that document. The document was missing one entry, so the guard was missing it too, and it
passed. A description copied from the thing it describes agrees with that thing by
construction, **including when the thing is wrong**. The same trap catches a standard rewritten
from the plan that shaped the code instead of from the code that shipped.

### Who owns which standard

Two kinds of standard sit side by side in a consuming project, and the retrospective treats
them differently:

- **Base standards** live under `base/` in `patchbay-standards` and are synced into a consuming
  project as `agent-os/standards/base/`, pinned to a commit. They are owned by
  `patchbay-standards`, and **a base standard is never edited in place during a spec**, not in
  a consuming project and not in `patchbay-standards` itself. The change the spec would make is
  written up in `shape.md` under `## Standards retrospective (proposed, base)`: the file, the
  change, and the shipped code that proves it. That proposal becomes a pull request to
  `patchbay-standards`; a consuming project picks it up on its next sync, and until then lives
  with the standard as it is. The proposal, not a local edit, is the record. (Inside
  `patchbay-standards`, changing a base standard is a spec's feature work on its own branch,
  never a side effect of some other spec's retrospective.)
- **Project standards**, everything under `agent-os/standards/` outside `base/`, belong to the
  project and are edited in the retrospective as the questions above direct.

**Every standards edit is approved by a person, always**: a base proposal as the pull request to
`patchbay-standards`, a project standard in the project's own review of the retrospective's
change set. An agent proposes; it does not land a standard on its own.

### Keep the index in step

`agent-os/standards/index.yml` is what `/agent-os:shape-spec` Step 5 reads to decide which
standards a future spec surfaces. **A standard added or renamed but not indexed is invisible to
every spec after this one**: the file exists and nobody ever finds it.

The index has one `base:` section, the `base:` section of `index.yml` at the root of
`patchbay-standards`, copied verbatim by the sync script and keyed by each standard's path
relative to `base/` without the `.md`, followed by the project's own sections. A base proposal
that adds or renames a file therefore carries its index entry with it; `scripts/check-index.sh`
in `patchbay-standards` holds that root index equal to the files under `base/`, so a proposal
without the entry does not merge. A project's own sections are updated in the same change set
as its own standards. `/agent-os:index-standards` regenerates them; the description line is
what future retrieval matches against, so make it say what the standard decides, not what area
it belongs to.

### Never edit this file from inside a retrospective

A gate that rewrites its own terms during the process it governs is precisely what this
prohibition exists for. Strengthening or relaxing the retrospective is a deliberate edit made
**outside** a spec, with the user, on its own branch.

The same applies to the verification-gate task text in
`.claude/commands/agent-os/shape-spec.md` and, in `patchbay-standards`, to the gate's runnable
half: `scripts/gate.sh`, `scripts/check-index.sh` and `.pymarkdown.yaml`.

### Recording the answer

`shape.md` gets a `## Standards Retrospective` heading. One of two shapes:

```markdown
### Standards Retrospective

Standards retrospective: no changes.
```

or

```markdown
### Standards Retrospective

- `agent-os/standards/testing/fixtures.md` — added the shared-fixture rule; this spec found
  that two adapters each built the same fake device. Verified against `tests/conftest.py` as
  shipped.
- `agent-os/standards/index.yml` — description updated for the above.
- **Deviation, not a standard change:** the dry-run flag skips the version check. One-off;
  nothing reads the version on that path.

#### Standards retrospective (proposed, base)

- `base/process/standards-retrospective.md` — [the change, and the shipped code that proves
  it]. Proposed, not applied; becomes a pull request to `patchbay-standards`.
```

The `(proposed, base)` list appears only when the spec taught a base standard something; it
holds proposals and never a local edit.

### Git

The retrospective's edits are **their own change set**, separate from the feature's: a
standards change that arrives buried inside a feature diff is a standards change nobody
reviews.

Committing, pushing and staging follow the `## Git` rule in `CLAUDE.md`. "Own change set" means
the retrospective's files are listed explicitly and separately when the work is reported, so
they can be committed apart from the feature. Leaving them unlisted, mixed into a wall of
modified files, defeats the point.

---

## process/standards-index

## Standards Index

`agent-os/standards/index.yml` is what `/agent-os:shape-spec` Step 5 reads to decide which
standards a spec surfaces, and what `/agent-os:inject-standards` matches against. A standard that
is not indexed is invisible to every spec after the one that wrote it: the file exists and nobody
finds it. This standard fixes the index's format and how a consuming project's index relates to
the root index of `patchbay-standards`.

### Keys

- **The index has two levels, section then key**, as the stock Agent OS commands read it: a
  section is a folder directly under the standards root, and a key resolves to
  `agent-os/standards/<section>/<key>.md`. The one exception is the reserved section `root`,
  which the stock commands resolve to `agent-os/standards/<key>.md`: a standard directly under
  the standards root, in no folder.
- **A key is the standard's path relative to its section, without the `.md`.** In the `base:`
  section the key carries the whole path under `base/`: `base/process/ownership.md` is
  `process/ownership`, and resolves to `agent-os/standards/base/process/ownership.md` in a
  consuming project. The section is `base`; the slash inside the key is the folder under it.
- **Sections are alphabetical, and keys are alphabetical within their section**, as the stock
  `/agent-os:index-standards` command writes them.

### The description line

- **One line, saying what the standard decides**, not what area it belongs to. The description
  is what retrieval matches a spec's context against; "testing conventions" matches nothing,
  "every adapter builds its fake device from the shared fixture" matches the spec that needs it.
- **The value holds no colon followed by a space and no space followed by a hash.** The stock
  commands read the file as YAML, where the first nests the rest of the line as a mapping and the
  second starts a comment that silently cuts the description short. Say it another way.
- **The description is rewritten when the standard's rule changes**, in the same change set.

### Every standard and nothing else

- **Every file under the standards folder has an entry, and no entry lacks a file.** In
  `patchbay-standards`, `scripts/check-index.sh` holds `index.yml` to this at every gate run and
  names each miss: a file under `base/` with no entry, an entry with no file.
- **Only standards live under `base/`**: every file there is a `.md` and is indexed. Notes, drafts
  and assets live elsewhere; `check-index.sh` refuses a non-`.md` file under `base/` by name.
- **A base change that adds, renames or removes a file carries its index entry** in the same
  change; the gate does not pass without it.

### Two indexes, one `base:` section

- **The root `index.yml` of `patchbay-standards` holds the `base:` section and nothing else.**
  It is the source of every base entry.
- **A consuming project's `agent-os/standards/index.yml` is the project's own sections plus a
  `base:` section identical to the root `base:` section at the commit the project pins.** No
  entry in that section is edited by hand: an entry it lacks, or a description it disagrees
  with, is changed in `patchbay-standards` and taken when the project moves its pin. The section
  is replaced whole, at a recorded commit; until a sync exists, a project copies it whole from
  the root `index.yml` at the commit it pins.
- **A project's own sections are edited by hand, in the same change set as its own standards**,
  as the retrospective standard directs. The stock `/agent-os:index-standards` command rewrites
  the whole file, the `base:` section included, and removes entries it finds no file for without
  asking, so it is not run on an index that carries a synced `base:` section. The regeneration
  that is safe to run is named here when it ships.

### In this repository

- **`agent-os/standards/index.yml` is identical to `index.yml`**, byte for byte, because this
  repository has no sections of its own; `check-index.sh` holds the two equal and prints the
  diff when they drift. The root file is edited; the copy follows it.
- **`agent-os/standards/base` is a symlink to `../../base`**, so the stock commands resolve
  `agent-os/standards/base/<key>.md` here exactly as in a consuming project. The symlink is this
  repository's convenience and never ships to a project; a project holds a copy, pinned to a
  commit.

### In a consuming project

This standard is synced in as `agent-os/standards/base/process/standards-index.md`. The project's
`agent-os/standards/index.yml` carries the `base:` section as pinned and its own sections beside
it; its retrospective keeps its own sections in step, and proposes base entries to
`patchbay-standards`.

---

## process/verification-gate

## Verification Gate

The gate is the definition of done in every patchbay repository. It is the final task of every spec,
included without asking, whether or not `/agent-os:shape-spec` shaped the work, and a spec is not
complete until every step of it passes. A spec with a red step, a skipped step or an unrecorded
retrospective is unfinished work, however small the change; a one-file fix is exactly the kind of
work that quietly invents a pattern, so the gate runs on it too.

This standard fixes the shape of the gate: what every repository's gate does and in what order.
The runnable step list is each repository's own, named in its `scripts/gate.sh` and in the gate
task of its `shape-spec.md`; this standard names no step and no tool. The standard that names a
repository's steps is cited here when it ships.

### One script

- **`scripts/gate.sh` runs every runnable step, in a fixed order, as one command**, and exits
  non-zero at the first step that fails. Later steps do not run: a failing step 1 is reported
  before step 2 has a chance to pass, so a green run means every step ran and every step passed.
- **Every step reports by name.** Each step prints a numbered banner, and what passed is named
  (`ok   <what>`) or what failed is named with its reason and the offending path; a bare exit code
  is not a report. The script ends by naming the step that follows it, so a reader of the
  transcript knows the run was not the whole gate.
- **The script runs from the repository root** wherever it is invoked from, and assumes nothing
  the repository does not already provide.

### Pinned

- **A tool's version is pinned in the script**, in one named variable per tool, with the date it
  was published beside it. The pinned tool is run through a runner that executes it without
  installing it into the project, and the runner is one the repository already assumes. Nothing
  else is installed to run the gate. A pin is bumped deliberately, outside a spec, and the gate
  rerun.
- **A rule set lives in a versioned config file**, at the repository root, named in the script;
  a config the tool cannot parse fails the step. The file's header says which step reads it and
  that it changes only outside a spec.

### The fixed order

The runnable steps come first, in the order the script runs them. One judgment step follows, and
nothing in the script runs it:

- **The standards retrospective**, per `base/process/standards-retrospective.md`: the four
  questions answered against the diff, the answer recorded in the spec's `shape.md` under
  `## Standards Retrospective`. "No changes" is valid; silence is not.

A spec whose `shape.md` records the green run but not the retrospective has not finished the
gate.

### A failing step is fixed at its cause

- **The cause is fixed and the whole gate rerun from step 1.** A fix that lets the step pass
  without fixing what it reported is not a fix. Skipping the step, loosening the rule set,
  excluding the file it named or editing the script to pass each change a gate file, which the
  section below forbids inside a spec; a suppression comment placed in the file the step named
  loosens the rule for that file alone and is reviewed as the loosening it is.
- **A step that cannot pass on the shipped tree is a defect in the tree**, not a reason to bypass
  the step. The first spec in `patchbay-standards` added the one blank line `README.md` lacked
  after its heading rather than exclude the file; that is the whole of the rule.

### Every step that can fail is proven to fail

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

### The gate's own files change only in their own spec

- **The gate script, every script it runs, the rule-set config and the gate task text in
  `shape-spec.md` are never changed as a side effect of a spec whose feature is something else**,
  and never from inside a retrospective. A gate that rewrites its own terms during the process it
  governs is what this rule exists to prevent.
- **A change to the gate is its own spec**, whose feature is the gate: on its own branch, with the
  owner, carrying the negative test for every step it adds or changes. A finding against a gate
  file made during some other spec is recorded in that spec's retrospective as a proposal and
  waits for the gate's spec.

### In this repository

The runnable steps are three: every script under `scripts/` parses, the standards under `base/`
and `README.md` lint clean against the pinned rule set, and `index.yml` lists exactly the files
under `base/`. `scripts/gate.sh` names the tool, its pin and its config; `scripts/check-index.sh`
is the third step. Every spec folder under `agent-os/specs/` holds its `verification/gate-run.txt`,
and the spec that built the gate holds the six negative tests beside it.

### In a consuming project

This standard is synced in as `agent-os/standards/base/process/verification-gate.md`. The
project's `scripts/gate.sh` runs its own step list in this shape; its `shape-spec.md` lists those
steps in the gate task, followed by the standards retrospective; its `CLAUDE.md` names the script
as the definition of done.
